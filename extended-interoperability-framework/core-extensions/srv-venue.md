---
title: Venue
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 2
---

{: .highlight }
Please note that the Service extension is still **work in progress**. Please follow the issue tracker [here](https://github.com/skg-if/ext-srv/issues).

# (srv) Venue

This extension adds a new type to the core [Venue] entity.

## Extended types

### `srv_portal`

A portal or catalogue through which services are discoverable and accessible.

Portals aggregate and catalog metadata of services, supporting users in search and access.

```json
{
    "local_identifier": "https://ror.org/03sj9b840",
    "entity_type": "venue",
    "name": "EOSC node",
    "website": "https://open-science-cloud.ec.europa.eu",
    "types": ["srv_portal"]
}
```

## Related properties

Services can reference venues/portals via `srv_venues`:

```json
"srv_venues": [
    {
        "local_identifier": "https://ror.org/03sj9b840",
        "entity_type": "venue",
        "name": "EOSC node",
        "types": ["srv_portal"]
    }
]
```

----
[Venue]: {% link interoperability-framework/docs/venue.md %}
