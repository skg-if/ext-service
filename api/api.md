---
title: API extensions
parent: Service
layout: default
nav_order: 5
---

# API extensions

The Service extension introduces a new SKG-IF entity to model software-based services that process data in research workflows (creation, extraction, preparation, analysis, etc.). To prevent clashes with other extensions, properties use the `srv_` prefix where needed.



It relies on [Research product] (of type software) and code repository entities for detailed modeling of the software source code, but adds information related to operational and usage aspects. Additional references to [Organisation] and [Grant] can be provided for acknowledgement.

To support this, the SKG-IF API is extended using an OpenAPI overlay applied to the core specification.

## Creating the Service OpenAPI specification

Apply the [Service overlay](https://skg-if.github.io/ext-srv/api/ver/current/service-overlay.yaml) to the [SKG-IF core OpenAPI specification](https://skg-if.github.io/api/openapi/ver/current/skg-if-openapi.yaml) using [Speakeasy](https://www.speakeasy.com/openapi/overlays):

```sh
speakeasy overlay apply -s skg-if-openapi.yaml -o service-overlay.yaml
```

The overlay can be used on its own or combined with other SKG-IF extension overlays.

## Endpoints

The Service extension adds the following endpoints:

| Endpoint | Description |
|----------|-------------|
| `GET /services` | Get a list of services with optional filtering |
| `GET /services/{short_local_identifier}` | Get a single service by its identifier |

## Extended core entities

### Organisation types

The overlay extends the `Organisation` entity with additional types for modeling service operations:

- `srv_hosting_organisation` - organisation responsible for hosting and operating a service
- `srv_research_infrastructure` - organisation providing facilities, resources and services for research communities

### Venue types

The overlay extends the `Venue` entity with:

- `srv_portal` - a portal/catalogue through which services are discoverable and accessible

## Query filters

### Attribute filters

Exact match filters on attributes of the `service` object and its related entities.
The `country` filter is a shorthand that resolves via `srv_has_hosting_organisation.country`.

| Filter key | Example |
|---|---|
| entity_type | `entity_type:service` |
| identifiers.scheme | `identifiers.scheme:handle` |
| identifiers.value | `identifiers.value:https://hdl.handle.net/11234/1-1702` |
| name | `name:UDPipe` |
| website | `website:https://ufal.mff.cuni.cz/udpipe` |
| country | `country:CZ` (shorthand for `srv_has_hosting_organisation.country`) |
| srv_invocation_type | `srv_invocation_type:sshocinvt:webApplication` |
| relevant_organisations.name | `relevant_organisations.name:CLARIN` |
| relevant_organisations.identifiers.scheme | `relevant_organisations.identifiers.scheme:ror` |
| relevant_organisations.identifiers.value | `relevant_organisations.identifiers.value:https://ror.org/03wp25384` |
| srv_has_hosting_legal_entity.name | `srv_has_hosting_legal_entity.name:Charles University` |
| srv_has_hosting_legal_entity.identifiers.scheme | `srv_has_hosting_legal_entity.identifiers.scheme:ror` |
| srv_has_hosting_legal_entity.identifiers.value | `srv_has_hosting_legal_entity.identifiers.value:https://ror.org/024d6js02` |
| srv_has_hosting_organisation.name | `srv_has_hosting_organisation.name:LINDAT` |
| srv_has_hosting_organisation.identifiers.scheme | `srv_has_hosting_organisation.identifiers.scheme:ror` |
| srv_has_hosting_organisation.identifiers.value | `srv_has_hosting_organisation.identifiers.value:https://ror.org/00dd4fz34` |
| srv_has_research_infrastructure.name | `srv_has_research_infrastructure.name:CLARIN ERIC` |
| srv_has_research_infrastructure.identifiers.scheme | `srv_has_research_infrastructure.identifiers.scheme:ror` |
| srv_has_research_infrastructure.identifiers.value | `srv_has_research_infrastructure.identifiers.value:https://ror.org/03wp25384` |

### Convenience filters

Substring and cross-field search filters — not direct attributes of the `service` object.

| Filter key | Filter value | Returns |
|---|---|---|
| cf.search.name | string | services with `name` containing the value (case-insensitive) |
| cf.search.keyword | string | services with a keyword containing the value |
| cf.search.org_name | string | services with any related organisation `name` or `short_name` containing the value (searches across `relevant_organisations`, `srv_has_hosting_legal_entity`, `srv_has_hosting_organisation`, `srv_has_research_infrastructure`) |

### Query parameter syntax examples

```
/services?filter=identifiers.scheme:handle,identifiers.value:https://hdl.handle.net/11234/1-1702
/services?filter=cf.search.name:UDPipe
/services?filter=cf.search.keyword:morphology
/services?filter=cf.search.name:UDPipe&page=1&page_size=5
/services?filter=country:CZ&page=1&page_size=10
/services?filter=srv_invocation_type:sshocinvt:webApplication
/services?filter=relevant_organisations.name:CLARIN
/services?filter=srv_has_hosting_organisation.name:LINDAT
/services?filter=srv_has_research_infrastructure.name:CLARIN ERIC
/services?filter=srv_has_hosting_legal_entity.identifiers.scheme:ror,srv_has_hosting_legal_entity.identifiers.value:https://ror.org/024d6js02
/services?filter=relevant_organisations.identifiers.scheme:ror,relevant_organisations.identifiers.value:https://ror.org/03wp25384
/services?filter=cf.search.org_name:LINDAT
```

## Local testing setup

See [`api/testing/`](testing/README.md) for a self-contained Docker Compose setup (Prism proxy + FastAPI + Swagger UI) for testing the `/services` endpoint against local JSON-LD data.

---

## TODO — implementation notes (identified 2026-04-13)

The ext-srv **spec** (service-overlay.yaml) is well-aligned with the core SKG-IF API spec.
The notes below concern the reference DEMOSERVICES implementation (`skg-if-ServiceServiceAPI`).

### 1. `@context` without `@base` — spec gap, not implementation bug

The service-overlay requires `minItems: 4` context entries (core, API, `@base`, ext-srv),
but the list endpoint intentionally returns 3 — no `@base`.
**Reason:** the server aggregates records from multiple sources, each with a different
`@base`. The loader resolves all `local_identifier` values to absolute IRIs at startup,
so a shared `@base` is neither available nor necessary.
**Action needed:** the `minItems: 4` constraint in the overlay spec does not accommodate
multi-source aggregators. Relax it to `minItems: 3` (or make `@base` explicitly optional)
and note in the spec that aggregator implementations may omit `@base` when all
`local_identifier` values are already absolute IRIs. Single-source implementations
(and single-entity responses) correctly include `@base`.

### 2. `source` filter — document in overlay or mark as extension

The implementation accepts `filter=source:elg` (and `source:sshomp`, `source:vlo`, etc.)
to filter by harvest source. This is documented in the implementation's CLAUDE.md but
does not appear in the service-overlay attribute-filter table.
**Fix:** add `source` as an optional implementation-extension filter key in
service-overlay.yaml and api.md, with a note that the available values are
deployment-specific.

### 3. `part_of.local_identifier` omits active filter params

Per the core spec examples, `part_of.local_identifier` should represent the full filtered
search, e.g. `.../services?filter=cf.search.name:UDPipe`. The implementation currently
sets it to the bare endpoint URL without query params, regardless of the active filter.
```python
# current (server.py)
"part_of": {"local_identifier": base_url, ...}   # bare URL only
# should be
"part_of": {"local_identifier": f"{base_url}?{filter_qs.lstrip('&')}" if filter else base_url, ...}
```
**Fix:** include the active `filter` (and optionally `page_size`) in
`part_of.local_identifier` to match the spec intent.

### 4. Handle identifier value format — pipeline data issue

The service-overlay filter example uses a full resolver URL:
`identifiers.value:https://hdl.handle.net/11234/1-1702`
but DEMOSERVICES_VLO records store handle values with a bare `hdl:` prefix:
`{"scheme": "handle", "value": "hdl:11471/521.1.1"}`.
A client following the spec example will not find VLO records by handle.
This is a data-normalisation issue in the VLO enrichment pipeline, not in this server.
**Fix:** normalise handle values in the VLO pipeline to bare handles (e.g. `11471/521.1.1`)
and align the filter example accordingly, or explicitly document the `hdl:` prefix
convention as an allowed identifier value form.
