---
title: Interoperability framework
parent: Service
layout: default
nav_order: 2
has_toc: false
# nav_exclude: true
---
# (srv) Interoperability framework

The acronym **`srv`** identifies this extension in the repository name (`ext-srv`), w3id.org URL paths, and ontology file names. It is also the OWL namespace prefix for new terms (`srv:camelCase`, declared as `vann:preferredNamespacePrefix` in `srv.ttl`) and the JSON-LD alias prefix for extension-specific properties (`srv_snake_case`). Properties from the core or external vocabularies carry no `srv_` prefix.

## Extension-specific entities
This extension introduces a new entity [Service] that models software applications or components providing specific functionality over a network, typically accessed through an API or web application.

## Extensions to core entities

### Organisation
New types for modeling service operations:
- `hosting_organisation` - organisation responsible for hosting and operating a service
- `research_infrastructure` - organisation providing facilities, resources and services for research communities

### Venue
New type for portal functionality:
- `srv_portal` - a portal/catalogue through which services are discoverable and accessible

---
[Service]: {% link ext-srv/extended-interoperability-framework/extension-entities/Service.md %}
