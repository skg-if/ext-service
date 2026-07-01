---
title: Organisation
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 3
---

# Organisation extended by the Service extension

This extension introduces two new types of Organisation for modelling service operations: "hosting organisation" and "research infrastructure". These are expressed by values `srv_hosting_organisation` and `srv_research_infrastructure` of the `types` property.

## New Organisation types

### `srv_hosting_organisation`

A "hosting organisation" hosts and operates a service or infrastructure component.

```json
{
    "local_identifier": "https://ror.org/00dd4fz34",
    "entity_type": "organisation",
    "name": "Digital Research Infrastructure for Language Technologies, Arts and Humanities",
    "short_name": "LINDAT",
    "types": ["facility", "srv_hosting_organisation"],
    "country": "CZ"
}
```

### `srv_research_infrastructure`

A "research infrastructure" provides facilities, resources and services for research communities.

```json
{
    "local_identifier": "https://ror.org/03wp25384",
    "entity_type": "organisation",
    "name": "CLARIN ERIC",
    "types": ["facility", "srv_research_infrastructure"],
    "country": "NL"
}
```

----
[Organisation]: {% link interoperability-framework/docs/agent.md %}
