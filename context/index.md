---
title: JSON-LD context
parent: Service
layout: default
nav_order: 5
has_toc: false
# nav_exclude: false
---

# JSON-LD Context

The Service extension provides a JSON-LD context that maps the `srv_*` property aliases used in the [extended Interoperability Framework](../extended-interoperability-framework) to their corresponding OWL ontology terms.

The context is available at:

[https://w3id.org/skg-if/extension/srv/context/skg-if.json](https://w3id.org/skg-if/extension/srv/context/skg-if.json)

It is designed to be layered on top of the core SKG-IF contexts. Example JSON-LD documents reference the following contexts in their `@context` array, in order:
1. [SKG-IF core context](https://w3id.org/skg-if/context/1.1.0/skg-if.json) (v1.1.0)
2. [SKG-IF API context](https://w3id.org/skg-if/context/1.0.0/skg-if-api.json) (pagination)
3. This extension context

Properties shared with the core context are declared with `@protected: true` to prevent accidental redefinition.