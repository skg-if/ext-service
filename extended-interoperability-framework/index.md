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

Supporting entities include:
- **APIProfile** - pairs service endpoints with API specifications
- **FacilityPortal** - organizational facility that operates services
- **ResearchInfrastructure** - organisation providing facilities and services for research
- **HostingOrganisation** - organisation responsible for hosting a service

## Relationships to core entities
The Service entity can be linked to core SKG-IF entities:
- **Research products** via `srv_deployment_of` (software deployed by the service) and `related_products` (conceptually related products)
- **Organisations** via `srv_hosting_organisation`, `srv_hosting_legal_entity`, and `relevant_organisations`
- **Topics** via `disciplines` and `srv_topics`

For the full property specification, see the [Service] documentation.

----
[Service]: {% link ext-srv/Service.md %}
