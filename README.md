# Want Study

Desktop-приложение для конспектирования учебного материала, выполнения домашних заданий, ведения графа понятий и публикации Markdown в GitHub.

## Структура

```text
app/desktop/       Flutter Desktop
package/study/     домен, application, BLoC и UI
proto/wantstudy/v1 gRPC-контракты
service/api/       Go API и Markdown renderer
db/migration/      PostgreSQL-миграции
```

PostgreSQL — источник истины. Flutter подключается к локальному Go API по `127.0.0.1:50051`. PostgreSQL доступен только внутри Docker-сети.

## Запуск

Требуются Docker, FVM 3.2.1, Flutter 3.47.4, Go 1.27.1 и Buf 1.57.2.

```shell
make bootstrap
docker compose up -d --build
cd app/desktop && fvm flutter run -d macos
```

API применяет миграции перед запуском. Приложение проверяет стандартный gRPC health endpoint и показывает повторный запуск проверки при недоступном API.

## Проверки

```shell
make proto-check
make format
make analyze
make test
make build-macos
```

## Импорт cpp-study

Сначала проверьте точный snapshot `828752ff65d8b202d386e70d7bade74380fdf2d0`:

```shell
cd service/api
go run ./cmd/api import-cpp-study --repository /path/to/cpp-study --dry-run
go run ./cmd/api import-cpp-study --repository /path/to/cpp-study --apply
```

`apply` выполняется одной транзакцией. Повторный импорт того же репозитория блокируется.

## Публикация

Публикация работает только с выбранным Git root, текущей веткой с upstream и GitHub remote. Она блокируется при staged-файлах, отставании ветки, изменённых управляемых файлах, symlink и коллизиях путей. Чужие unstaged и untracked файлы не меняются.
