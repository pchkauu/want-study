FROM golang:1.27.1-alpine AS build

WORKDIR /src/service/api
COPY service/api/go.mod service/api/go.sum* ./
RUN go mod download
COPY service/api ./
RUN CGO_ENABLED=0 go build -trimpath -o /out/want-study-api ./cmd/api

FROM alpine:3.23
RUN apk add --no-cache ca-certificates
COPY --from=build /out/want-study-api /want-study-api
COPY db/migration /migration
EXPOSE 50051
ENTRYPOINT ["/want-study-api"]
CMD ["serve", "--migration-path", "/migration"]
