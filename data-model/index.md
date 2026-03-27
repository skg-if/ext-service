---
title: Data model
parent: Service
layout: default
nav_order: 3
has_toc: false
# nav_exclude: false
---

# Service Extension Data Model

The Service extension data model extends the [SKG-IF Ontology](https://w3id.org/skg-if/ontology/) by introducing:
- A new entity **srv:Service**, modelling software applications or components that provide specific functionality over a network, typically accessed through an API or web application;
- Supporting entities **srv:APIProfile** and **srv:FacilityPortal**;
- New properties for describing service characteristics, availability, audience, and relationships to research products, organisations, and venues.

The model is summarised in the following [Graffoo diagram](https://essepuntato.it/graffoo):

![srv diagram]({% link ext-srv/data-model/graphs/srv.png %})

The data model is implemented as an OWL ontology called the **"SKG-IF Ontology: Service Extension"** (SRV-O). Rather than creating new terms from scratch, it reuses and extends existing ontologies including [Schema.org](https://schema.org), the [SPAR Ontologies](http://www.sparontologies.net), [DCAT](https://www.w3.org/TR/vocab-dcat/), and [SKOS](https://www.w3.org/TR/skos-reference/).

Data conforming to this extension is described through the [ext-srv JSON-LD context](https://w3id.org/skg-if/extension/srv/context/skg-if.json) and validated using a dedicated [SHACL document](https://w3id.org/skg-if/extension/srv/validation/shacl/). The SHACL file is auto-generated from the ontology using the [SKG-IF SHACL extractor](https://github.com/skg-if/shacl-extractor).

The ontology is available at [https://w3id.org/skg-if/extension/srv/ontology](https://w3id.org/skg-if/extension/srv/ontology) in four serialisation formats (`.ttl`, `.nt`, `.xml`, `.json`) with an [HTML documentation page](https://skg-if.github.io/ext-srv/data-model/ontology/current/srv.html).

## Methodology

The Service entity model was developed by investigating and comparing existing community metadata solutions for describing tools and services. The property set was informed by the following sources:

- The [CMDI schemas for tools & services][VLO catalogue] used in the CLARIN VLO, in particular the [UDPipe example]
- [SSHOMP catalogue] (tools and services)
- [ELG catalogue] (tools and services)
- The [CLARIN LR Switchboard schema]
- [Schema.org SoftwareApplication] type
- The [EOSC Service Profile 4.1 rc / 5.0]

Rather than adopting any single schema, the extension reuses and aligns terms from these sources with existing Semantic Web vocabularies (Schema.org, SPAR, DCAT, SKOS) and maps them to a JSON-LD context compatible with the SKG-IF framework.

[VLO catalogue]: https://vlo.clarin.eu/?2
[UDPipe example]: https://vlo.clarin.eu/record/https_58__47__47_hdl.handle.net_47_11234_47_1-1702_64_format_61_cmdi?q=UDPipe
[SSHOMP catalogue]: https://marketplace.sshopencloud.eu
[ELG catalogue]: https://live.european-language-grid.eu/catalogue/
[CLARIN LR Switchboard schema]: https://www.clarin.eu/sites/default/files/zinn-CLARIN2016_paper_26.pdf
[Schema.org SoftwareApplication]: https://schema.org/SoftwareApplication
[EOSC Service Profile 4.1 rc / 5.0]: https://eosc-service-profile.readthedocs.io/en/latest/introduction.html
