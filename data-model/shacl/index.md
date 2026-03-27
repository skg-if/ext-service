---
title: SHACL
parent: Service
layout: default
nav_order: 4
has_toc: false
# nav_exclude: true
---

# SHACL

The Service extension provides a [SHACL](https://www.w3.org/TR/shacl/) document for validating data conforming to the `srv:Service` data model.

The SHACL shapes are auto-generated from the OWL ontology using the [SKG-IF SHACL extractor](https://github.com/skg-if/shacl-extractor) and are available at:

[https://w3id.org/skg-if/extension/srv/validation/shacl/](https://w3id.org/skg-if/extension/srv/validation/shacl/)

The SHACL file should not be edited manually — any changes to the shapes must be made in the ontology (`srv.ttl`) and regenerated.