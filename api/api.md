---
title: API extensions
parent: Service
layout: default
nav_order: 5
---

# API extensions

The Service extension introduces a new SKG-IF entity to model software-based services that process data in research workflows (creation, extraction, preparation, analysis, etc.).

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

- `hosting_organisation` - organisation responsible for hosting and operating a service
- `research_infrastructure` - organisation providing facilities, resources and services for research communities
- `srv_portal` - organisation responsible for aggregating and cataloging services

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
| cf.search.name | string | services with `name` or `srv_name` containing the value (case-insensitive) |
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
