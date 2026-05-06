---
title: Organisation
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 3
---

{: .highlight }
Please note that the Service extension is still **work in progress**. Please follow the issue tracker [here](https://github.com/skg-if/ext-srv/issues).

# Organisation extended by the Service extension

This extension introduces two new types of Organisation for modelling service operations: "hosting organisation" and "research infrastructure". These are expressed by values `hosting_organisation` and `research_infrastructure` of the `types` property.

## New Organisation types

### `hosting_organisation`

A "hosting organisation" hosts and operates a service or infrastructure component.

```json
{
    "local_identifier": "https://ror.org/00dd4fz34",
    "entity_type": "organisation",
    "name": "Digital Research Infrastructure for Language Technologies, Arts and Humanities",
    "short_name": "LINDAT",
    "types": ["facility", "hosting_organisation"],
    "country": "CZ"
}
```

### `research_infrastructure`

A "research infrastructure" provides facilities, resources and services for research communities.

```json
{
    "local_identifier": "https://ror.org/03wp25384",
    "entity_type": "organisation",
    "name": "CLARIN ERIC",
    "types": ["facility", "research_infrastructure"],
    "country": "NL"
}
```

----
[Organisation]: {% link interoperability-framework/docs/agent.md %}
