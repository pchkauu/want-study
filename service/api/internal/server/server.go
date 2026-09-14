package server

import (
	"context"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	healthv1 "github.com/pchkauu/want-study/service/api/internal/proto/grpc/health/v1"
	wantstudyv1 "github.com/pchkauu/want-study/service/api/internal/proto/wantstudy/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Services struct {
	wantstudyv1.UnimplementedStudyCatalogServiceServer
	wantstudyv1.UnimplementedLessonContentServiceServer
	wantstudyv1.UnimplementedKnowledgeServiceServer
	wantstudyv1.UnimplementedExportServiceServer

	pool *pgxpool.Pool
}

func New(pool *pgxpool.Pool) *Services {
	return &Services{pool: pool}
}

func Register(grpcServer *grpc.Server, services *Services) {
	wantstudyv1.RegisterStudyCatalogServiceServer(grpcServer, services)
	wantstudyv1.RegisterLessonContentServiceServer(grpcServer, services)
	wantstudyv1.RegisterKnowledgeServiceServer(grpcServer, services)
	wantstudyv1.RegisterExportServiceServer(grpcServer, services)
	healthv1.RegisterHealthServer(grpcServer, healthService{})
}

func LoggingInterceptor(logger *slog.Logger) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, request any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		started := time.Now()
		response, err := handler(ctx, request)
		logger.InfoContext(ctx, "grpc request", "method", info.FullMethod, "code", status.Code(err), "duration_ms", time.Since(started).Milliseconds())
		return response, err
	}
}

type healthService struct {
	healthv1.UnimplementedHealthServer
}

func (healthService) Check(context.Context, *healthv1.HealthCheckRequest) (*healthv1.HealthCheckResponse, error) {
	return &healthv1.HealthCheckResponse{Status: healthv1.HealthCheckResponse_SERVING}, nil
}

func (healthService) Watch(_ *healthv1.HealthCheckRequest, stream grpc.ServerStreamingServer[healthv1.HealthCheckResponse]) error {
	if err := stream.Send(&healthv1.HealthCheckResponse{Status: healthv1.HealthCheckResponse_SERVING}); err != nil {
		return status.Error(codes.Unavailable, "health stream unavailable")
	}
	<-stream.Context().Done()
	return stream.Context().Err()
}
