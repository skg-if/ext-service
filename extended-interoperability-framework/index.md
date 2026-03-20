---
title: Interoperability framework
parent: Service
layout: default
nav_order: 2
has_toc: false
# nav_exclude: true
---
# (srv) Interoperability framework

{: .important }
To prevent possible clashes with other extensions, each extension is assigned a unique prefix (e.g., the acronym you provided upon requesting an extension) that you need to prepend when defining new properties and relations for core entities. For this extension, the acronym is `srv`.

## Extension-specific entities
This extension introduces a new entity [Service] that models software applications or components providing specific functionality over a network, typically accessed through an API or web application.

Supporting classes include:
- **srv:APIProfile** - pairs service endpoints with API specifications
- **srv:FacilityPortal** - organizational facility that operates services

## Extensions to core entities

### Organisation
New types for modeling service operations:
- `hosting_organisation` - organisation responsible for hosting and operating a service
- `research_infrastructure` - organisation providing facilities, resources and services for research communities

### Venue
New type for portal functionality:
- `srv_portal` - a portal/catalogue through which services are discoverable and accessible

## Relationships to core entities
The Service entity can be linked to core SKG-IF entities:
- **Research products** via `srv_deployment_of` (software deployed by the service), `cito:isDocumentedBy` (`is_documented_by`) and `cito:isCitedBy` (`is_cited_by`) — grouped under `related_products` in the JSON-LD serialisation
- **Organisations** via `srv_has_hosting_organisation`, `srv_has_research_infrastructure`, `srv_has_hosting_legal_entity`, and `relevant_organisations`
- **Venues** via `srv_venues`
- **Topics** via `disciplines` and `topics`

For the full property specification, see the [Service] documentation.

----
[Service]: {% link ext-srv/Service.md %}
