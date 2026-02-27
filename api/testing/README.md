# ext-srv API Testing Setup

Local development environment for testing the SKG-IF service extension API (`/services` endpoint).
Runs Prism (proxy mode) in front of a FastAPI backend, with Swagger UI for interactive browsing.

## Architecture

```
HTTP client
    ↓
Prism :4010  [proxy mode — validates requests/responses against the OpenAPI spec]
    ↓
FastAPI :8000  [serves service JSON-LD files from examples/]
```

Swagger UI is available at :8080.

## Prerequisites

- Docker and Docker Compose
- The sibling `api` repo present at `../../../api` (for the sync script)

## Setup

### 1. Copy the OpenAPI spec

The spec used here is the consolidated spec (core + service overlay applied):

```bash
cp ../../../api/consolidated-openapi.yaml ./openapi.yaml
```

### 2. Provide service data

The FastAPI backend reads JSON-LD files from `examples/` (the repository's single source of truth).
`docker-compose.yml` mounts `../../examples` by default — no manual data copy or symlink needed.

### 3. Start

```bash
docker compose up
```

| Service    | URL                        |
|------------|----------------------------|
| Prism      | http://localhost:4010       |
| Swagger UI | http://localhost:8080       |
| FastAPI    | internal only (port 8000)  |

### Environment variables

| Variable        | Default             | Purpose                              |
|-----------------|---------------------|--------------------------------------|
| `OPENAPI_SPEC`  | `./openapi.yaml`    | Path to the OpenAPI spec             |
| `DATA_PATH`     | `./data`            | Root data directory                  |
| `SERVICES_DATA` | `../../examples`    | Services JSON-LD directory           |

Example with overrides:

```bash
DATA_PATH=/absolute/path/to/data docker compose up
```

## Service-specific changes in app.py

This `docker_build/app.py` is based on `api/openapi/docker_build/app.py` with no functional differences for Service entities — `name` is used as the standard field for service names.

## Docker images

| Image | Purpose | Origin |
|-------|---------|--------|
| [`vicding81/athenstest:latest`](https://hub.docker.com/r/vicding81/athenstest) | FastAPI backend serving JSON-LD files | Developed by Vic Ding (KNAW Humanities Cluster / Digital Infrastructure, [qiqing.ding@di.huc.knaw.nl](mailto:qiqing.ding@di.huc.knaw.nl)) as part of the SKG-IF API CI validation pipeline |
| [`stoplight/prism:4`](https://hub.docker.com/r/stoplight/prism) | OpenAPI proxy/mock server | [Prism](https://stoplight.io/open-source/prism) by StopLight (open source, Apache 2.0) |
| [`swaggerapi/swagger-ui`](https://hub.docker.com/r/swaggerapi/swagger-ui) | Interactive API documentation | [Swagger UI](https://swagger.io/tools/swagger-ui/) by SmartBear (open source, Apache 2.0) |

## Keeping in sync with the api repo

Use `sync-from-api.sh` to check for upstream changes:

```bash
./sync-from-api.sh           # show status
./sync-from-api.sh --apply   # copy changed boilerplate files (Dockerfile, pyproject.toml, uv.lock, ...)
./sync-from-api.sh --diff    # also show diffs for changed boilerplate files
```

`app.py` and `docker-compose.yml` are marked `[DIVERGED]` and are never auto-copied — review their diffs manually and apply relevant upstream changes by hand.
