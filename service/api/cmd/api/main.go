package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pchkauu/want-study/service/api/internal/importer"
	"github.com/pchkauu/want-study/service/api/internal/migration"
	healthv1 "github.com/pchkauu/want-study/service/api/internal/proto/grpc/health/v1"
	"github.com/pchkauu/want-study/service/api/internal/server"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

const defaultAddress = "127.0.0.1:50051"

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	if err := run(os.Args[1:], logger); err != nil {
		logger.Error("command failed", "error", err)
		os.Exit(1)
	}
}

func run(arguments []string, logger *slog.Logger) error {
	if len(arguments) == 0 {
		return errors.New("expected serve, health, or import-cpp-study command")
	}
	switch arguments[0] {
	case "serve":
		return serve(arguments[1:], logger)
	case "health":
		return health(arguments[1:])
	case "import-cpp-study":
		return importCppStudy(arguments[1:], logger)
	default:
		return fmt.Errorf("unknown command %q", arguments[0])
	}
}

func importCppStudy(arguments []string, logger *slog.Logger) error {
	flags := flag.NewFlagSet("import-cpp-study", flag.ContinueOnError)
	repository := flags.String("repository", "", "cpp-study repository root")
	dryRun := flags.Bool("dry-run", false, "validate without database writes")
	apply := flags.Bool("apply", false, "write the snapshot in one transaction")
	migrationPath := flags.String("migration-path", "../../db/migration", "migration directory")
	if err := flags.Parse(arguments); err != nil {
		return err
	}
	if *repository == "" || *dryRun == *apply {
		return errors.New("set --repository and exactly one of --dry-run or --apply")
	}
	snapshot, err := importer.Load(*repository)
	if err != nil {
		return err
	}
	for _, warning := range snapshot.Warnings {
		logger.Warn("import warning", "line", warning.Line, "reason", warning.Reason)
	}
	logger.Info("snapshot validated", "lessons", len(snapshot.Lessons), "tasks", 23, "warnings", len(snapshot.Warnings))
	if *dryRun {
		return nil
	}
	databaseURL := os.Getenv("WANT_STUDY_DATABASE_URL")
	if databaseURL == "" {
		return errors.New("WANT_STUDY_DATABASE_URL is required")
	}
	ctx := context.Background()
	if err = migration.Up(ctx, databaseURL, *migrationPath); err != nil {
		return err
	}
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		return fmt.Errorf("open database pool: %w", err)
	}
	defer pool.Close()
	studyID, err := importer.Apply(ctx, pool, snapshot)
	if err != nil {
		return err
	}
	logger.Info("snapshot imported", "study_id", studyID)
	return nil
}

func serve(arguments []string, logger *slog.Logger) error {
	flags := flag.NewFlagSet("serve", flag.ContinueOnError)
	migrationPath := flags.String("migration-path", "../../db/migration", "migration directory")
	if err := flags.Parse(arguments); err != nil {
		return err
	}
	databaseURL := os.Getenv("WANT_STUDY_DATABASE_URL")
	if databaseURL == "" {
		return errors.New("WANT_STUDY_DATABASE_URL is required")
	}
	address := os.Getenv("WANT_STUDY_GRPC_ADDRESS")
	if address == "" {
		address = defaultAddress
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	if err := migration.Up(ctx, databaseURL, *migrationPath); err != nil {
		return err
	}
	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		return fmt.Errorf("open database pool: %w", err)
	}
	defer pool.Close()
	if err = pool.Ping(ctx); err != nil {
		return fmt.Errorf("ping database: %w", err)
	}
	listener, err := net.Listen("tcp", address)
	if err != nil {
		return fmt.Errorf("listen: %w", err)
	}
	grpcServer := grpc.NewServer(grpc.UnaryInterceptor(server.LoggingInterceptor(logger)))
	server.Register(grpcServer, server.New(pool))
	serveError := make(chan error, 1)
	go func() { serveError <- grpcServer.Serve(listener) }()
	logger.Info("api started", "address", address)
	select {
	case <-ctx.Done():
		grpcServer.GracefulStop()
		return nil
	case err = <-serveError:
		return err
	}
}

func health(arguments []string) error {
	flags := flag.NewFlagSet("health", flag.ContinueOnError)
	address := flags.String("address", defaultAddress, "gRPC address")
	if err := flags.Parse(arguments); err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	connection, err := grpc.NewClient(*address, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return err
	}
	defer connection.Close()
	response, err := healthv1.NewHealthClient(connection).Check(ctx, &healthv1.HealthCheckRequest{})
	if err != nil {
		return err
	}
	if response.Status != healthv1.HealthCheckResponse_SERVING {
		return fmt.Errorf("service is %s", response.Status)
	}
	return nil
}
