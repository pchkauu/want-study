package server

import (
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/protoadapt"
)

const errorDomain = "wantstudy.dev"

func statusError(code codes.Code, reason, message string, details ...proto.Message) error {
	value := status.New(code, message)
	items := make([]protoadapt.MessageV1, 0, len(details)+1)
	items = append(items, protoadapt.MessageV1Of(&errdetails.ErrorInfo{Reason: reason, Domain: errorDomain}))
	for _, detail := range details {
		items = append(items, protoadapt.MessageV1Of(detail))
	}
	withDetails, err := value.WithDetails(items...)
	if err != nil {
		return value.Err()
	}
	return withDetails.Err()
}

func invalid(field, description string) error {
	detail := &errdetails.BadRequest{FieldViolations: []*errdetails.BadRequest_FieldViolation{{
		Field:       field,
		Description: description,
	}}}
	return statusError(codes.InvalidArgument, "VALIDATION_FAILED", "invalid request", detail)
}

func notFound(resource string) error {
	return statusError(codes.NotFound, "NOT_FOUND", resource+" not found")
}

func conflict(resource string, expected int64) error {
	detail := &errdetails.PreconditionFailure{Violations: []*errdetails.PreconditionFailure_Violation{{
		Type:        "VERSION_CONFLICT",
		Subject:     resource,
		Description: "stored version differs from expected version",
	}}}
	return statusError(codes.Aborted, "VERSION_CONFLICT", "concurrent change detected", detail)
}

func mapDatabaseError(err error) error {
	if errors.Is(err, pgx.ErrNoRows) {
		return notFound("resource")
	}
	var postgresError *pgconn.PgError
	if errors.As(err, &postgresError) {
		switch postgresError.Code {
		case "23505":
			return statusError(codes.AlreadyExists, "ALREADY_EXISTS", "resource already exists")
		case "23503":
			return statusError(codes.FailedPrecondition, "REFERENCE_NOT_FOUND", "referenced resource does not exist")
		case "23514", "22P02":
			return invalid("request", "value violates a storage constraint")
		}
	}
	return statusError(codes.Internal, "STORAGE_FAILURE", "storage operation failed")
}
