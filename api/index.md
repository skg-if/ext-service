---
title: API extensions
parent: Service
layout: default
nav_order: 7
---

# API extensions

{: .important }
To prevent clashes with other extensions, properties use the `srv_` prefix where needed. See [api.md](api.md) for details.

The Service extension modifies the SKG-IF API via an OpenAPI overlay:
- Adds `/services` endpoint
- Extends `Organisation` with new types
- Extends `Venue` with portal functionality

See [service-overlay.yaml](ver/current/service-overlay.yaml) for the full specification.
