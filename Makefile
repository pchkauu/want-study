.PHONY: bootstrap proto proto-check format analyze test test-go test-flutter build-macos compose-up compose-down

bootstrap:
	fvm install 3.47.4
	fvm flutter pub get

proto:
	sh tool/generate_proto.sh

proto-check: proto
	buf lint
	buf build
	git diff --exit-code -- app/desktop/lib/src/proto service/api/internal/proto

format:
	buf format -w proto
	fvm dart format app/desktop/lib package/study/lib package/study/test app/desktop/test
	cd service/api && gofmt -w ./cmd ./internal

analyze:
	buf lint
	buf build
	fvm flutter analyze
	cd service/api && go vet ./...

test: test-go test-flutter

test-go:
	cd service/api && go test ./...

test-flutter:
	cd package/study && fvm flutter test
	cd app/desktop && fvm flutter test

build-macos:
	cd app/desktop && fvm flutter build macos --release

compose-up:
	docker compose up -d --build

compose-down:
	docker compose down
