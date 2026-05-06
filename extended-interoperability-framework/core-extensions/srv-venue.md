---
title: Venue
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 2
---

{: .highlight }
Please note that the Service extension is still **work in progress**. Please follow the issue tracker [here](https://github.com/skg-if/ext-srv/issues).

# Venue extended by the Service extension

The [Service] extension introduces a new type of Venue for modelling portal functionality: "portal". This is expressed by the value `srv_portal` of the `types` property.

## New Venue type

### `srv_portal`

A "portal" venue aggregates and catalogs service metadata, supporting users in discovery and access.

```json
{
    "local_identifier": "https://ror.org/03sj9b840",
    "entity_type": "venue",
    "name": "EOSC node",
    "website": "https://open-science-cloud.ec.europa.eu",
    "types": ["srv_portal"]
}
```

----
[Venue]: {% link interoperability-framework/docs/venue.md %}
[Service]: {% link ext-srv/extended-interoperability-framework/extension-entities/Service.md %}
