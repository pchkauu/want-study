#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tool_root="$project_root/.tool"
go_bin="$tool_root/go/bin"
pub_cache="$tool_root/pub"

mkdir -p "$go_bin" "$pub_cache"
GOBIN="$go_bin" go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.11
GOBIN="$go_bin" go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1
PUB_CACHE="$pub_cache" fvm dart pub global activate protoc_plugin 25.1.0

PATH="$go_bin:$pub_cache/bin:$PATH" buf generate "$project_root"
