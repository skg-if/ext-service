---
title: Interoperability framework
parent: Service
layout: default
nav_order: 2
has_toc: false
# nav_exclude: true
---
# (srv) Interoperability framework

The acronym **`srv`** identifies this extension in the repository name (`ext-srv`), w3id.org URL paths, and ontology file names. It is also the OWL namespace prefix for new terms (`srv:camelCase`, declared as `vann:preferredNamespacePrefix` in `srv.ttl`) and the JSON-LD alias prefix for extension-introduced terms (`srv_snake_case`). This applies to all terms defined or introduced by this extension, including reused external vocabulary properties and entity type values, to prevent clashes with terms introduced by other extensions.

> **Note on general-purpose types:** Some terms such as `srv_hosting_organisation` and `srv_research_infrastructure` carry the `srv_` prefix for clash-prevention reasons only. Conceptually they are general organisation roles relevant beyond the Service extension and would be better placed in the SKG-IF core. The prefix reflects a process constraint — the core entity change process did not accommodate these types in time — not a judgement that they are extension-specific in nature.

## Extensions to core entities

### Organisation
New types for modeling service operations:
- `srv_hosting_organisation` - organisation responsible for hosting and operating a service
- `srv_research_infrastructure` - organisation providing facilities, resources and services for research communities

### Venue
New type for portal functionality:
- `srv_portal` - a portal/catalogue through which services are discoverable and accessible

## Extension-specific entities
This extension introduces a new entity [Service] that models software applications or components providing specific functionality over a network, typically accessed through an API or web application.

---
[Service]: {% link ext-srv/extended-interoperability-framework/extension-entities/Service.md %}
