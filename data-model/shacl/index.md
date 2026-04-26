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

The SHACL shapes are auto-generated from the OWL ontology (`srv.ttl`) using the [SKG-IF SHACL extractor](https://github.com/skg-if/shacl-extractor) and are available at:

[https://w3id.org/skg-if/extension/srv/validation/shacl/](https://w3id.org/skg-if/extension/srv/validation/shacl/)

## Generation

The extractor reads structured cardinality annotations embedded in the `dc:description` of each class block in `srv.ttl`. Each annotation follows the micro-syntax:

```
* property -[min..max]-> RangeClass
```

For example:

```turtle
* srv:invocationType -[0..N]-> skos:Concept
* foaf:name -[1..1]-> rdfs:Literal
```

From these annotations the extractor generates `sh:PropertyShape` nodes with `sh:minCount`, `sh:maxCount`, and appropriate `sh:nodeKind` or `sh:datatype` constraints. The result is written to `data-model/shacl/current/shacl.ttl` and can be regenerated directly with:

```bash
cd ../shacl-extractor
python -m src.main \
    ../ext-srv/data-model/ontology/current/srv.ttl \
    ../ext-srv/data-model/shacl/current/shacl.ttl \
    --shapes-base https://w3id.org/skg-if/shapes/srv/
```

(or by running `dev-check.sh`)

The SHACL file should not be edited manually — any changes to the shapes must be made in the ontology (`srv.ttl`) and regenerated.