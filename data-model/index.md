---
title: Data model
parent: Service
layout: default
nav_order: 3
# nav_exclude: false
---

# Extended data model

{: .important }
To prevent possible clashes with other extensions, each extension is assigned a unique prefix (e.g., the acronym you provided upon requesting an extension) that you need to prepend when defining new properties and relations for core entities. For this extension, the acronym is `srv`.

## Main objective
This extension extends the [SKG-IF Ontology](https://w3id.org/skg-if/ontology/) by introducing:
- A *new entity Service*, which models software applications or components that provide specific functionality over a network, typically accessed through an API or web application;
- Supporting entities such as *APIProfile*, *FacilityPortal*, *ResearchInfrastructure*, and *HostingOrganisation*;
- New properties for describing service characteristics, availability, audience, and relationships to research products.

The data model is summarised in the following [Graffoo diagram](https://essepuntato.it/graffoo):

![srv diagram]({% link ext-srv/data-model/graphs/srv.png %})


## Expected outcomes
In this modelling phase, two outcomes are expected
- A **OWL/RDF ontology** files, in four formats, i.e., `.ttl`, `.nt`, `.xml`, `.json`;
- An `.html` **documentation page** of the developed ontology.

These files need to be placed as indicated [here](../structure). In this way, everything will be automatically wired-up in order to deliver behind w3id.org and content negotiation all the assets developed within the extension.

For example: this extension's ontology can be found at  [https://w3id.org/skg-if/extension/srv/ontology](https://w3id.org/skg-if/extension/srv/ontology).


## Methodological considerations
A good Relation Database always start with requirements analysis and ER diagrams, rather than getting hands dirty with table schemas in the DBMS of reference.

Similarly, here we start with the **development of a formal ontology** that is plugged on top of the one defined by the core SKG-IF data model. As a refresher, or to getting started with ontology development, a good reading list could be the following:
- [Noy, N. F., & McGuinness, D. L. (2001). *Ontology development 101: A guide to creating your first ontology.*](https://protege.stanford.edu/publications/ontology_development/ontology101.pdf)
- [Parlar, S. (2019). *Ontologies: In Detail. How to develop an ontology?*](https://medium.com/analytics-vidhya/ontologies-in-detail-2916f9226133)

More in-depth, advanced methodologies are available here:
- [Suárez-Figueroa, M. C., & others. (2012). *NeOn Methodology for Building Ontology Networks: Specification, Scheduling and Reuse*. IOS Press.](https://oa.upm.es/3879/2/MARIA_DEL-_CARMEN_SUAREZ_DE_FIGUEROA_BAONZA.pdf)
- [Peroni, S. (2015). *SAMOD: an agile methodology for the development of ontologies*. In Formal Ontology in Information Systems (FOIS) (pp. 37-50). IOS Press.](https://essepuntato.it/samod/)
- [Gómez-Pérez, A., Fernández-López, M., & Corcho, O. (2004). *Ontological Engineering: With Examples from the Areas of Knowledge Management, E-commerce and the Semantic Web*. Springer.](https://link.springer.com/book/10.1007/b97353)

In order to avoid reinventing the wheel, the **reuse of ontologies and vocabularies** already present in the literature is encouraged, such as:
- [Schema.org](https://schema.org)
- [SPAR Ontologies](http://www.sparontologies.net)
- [Linked Open Vocabularies (LOV)](https://lov.linkeddata.es/dataset/lov/)
- [DAML Ontology Library](https://www.daml.org/ontologies/)


### Developing the ontology
For sizeable and reasonably small ontologies, editing the required OWL files (e.g., `.ttl`) is a viable way to proceed, while for more complex models an ontology visual editor could come handy. 
In this regards, [**Protégé**](https://protege.stanford.edu) is suggested for its live and broad community of adopters, and because it is an open source, free software.

Remember to create all the requested formats in order to fullfil context negotiation requirements.
This can be done with either manually, or with the support of external tools. 
With Protégé, for example, the ontology is developed within the GUI and it can be exported in any format of choice.
In case the ontology was developed manually, it can be imported in Protégé in the chosen format and then exported in the other ones. 
Similarly With other tools, such as [WIDOCO](https://github.com/dgarijo/Widoco), it is easy to convert one format into others (see [the next section](#producing-the-documentation)).

A few **simple, yet optional, recommendations** are provided for guide the development process:
- When developing SKG-O, this extension and RA-SKG, the reuse of properties defined in external ontologies has been done as a "light import", i.e., without redefining domain and range (co-domain). The actual domain and range is defined at the annotation level and will be enforced at [SHACL](./shacl) level.
- To improve readability, use labels in the ontology description for entities and properties "surfacing" to the actual [extended Interoperability Framework](../extended-interoperability-framework/), i.e., as terms in the [JSON-LD context](../context/). Here below, a triple for a label used for this extension is reported.

    ```
    <http://schema.org/comment> rdfs:label "schema:comment (SKG-IF labels: srv_comments)" .
    ```

-  SKG-IF provides a [SHACL extractor](https://github.com/skg-if/shacl-extractor) that simplifies and streamlines the creation from scratch of the required [SHACL file](./shacl) starting from the ontology description produced in this phase. To this end, the following template is advised in order to parse automatically the descriptions.

    ```
    propertyName -[cardinality]-> targetType
    ```

    For example:

    ```
    dcterms:title -[1]-> rdfs:Literal
    frapo:hasGrantNumber -[0..1]-> xsd:string
    frapo:hasFundingAgency -[0..N]-> frapo:FundingAgency
    ```

    The cardinality can be specified as:
    - A single number (e.g., `[1]`) for exact cardinality
    - A range with minimum and maximum (e.g., `[0..1]`). Use N for unlimited maximum cardinality (e.g., `[1..N]`)

### Producing the documentation
In order to produce the `.html` documentation of the developed ontology, no specific tool or format is required.
In principle, the documentation can adhere to any format of choice and be developed with the preferred method.

However, we suggest the use of [**WIDOCO**](https://github.com/dgarijo/Widoco), which can potentially streamline the workflow.
For this extension, WIDOCO can be run from the dockerised version with

```
docker run -ti --rm \
  -v `pwd`/ontology/current:/usr/local/widoco/in:Z \
  -v `pwd`/ontology/current/doc:/usr/local/widoco/out:Z \
  dgarijo/widoco -ontFile in/srv.ttl -outFolder out -rewriteAll -uniteSections
```

Or using the JAR directly:

```
java -jar widoco.jar -ontFile srv.ttl -outFolder ./doc -rewriteAll -uniteSections
```

The `-uniteSections` flag combines all sections into a single HTML file, which renders correctly when opened locally.

#### Customising the introduction

The file `ontology/current/intro-en.html` contains a custom introduction section with links to the source schemas and catalogues that informed this extension. After running Widoco, replace the placeholder introduction in the generated `index-en.html` with this content. The file includes usage instructions in an HTML comment.

The files produced should be placed in the extension repository as indicated [here](../structure).

In case the HTML does not render properly on your local machine, please refer to [this](https://github.com/dgarijo/Widoco?tab=readme-ov-file#browser-issues-why-cant-i-see-the-generated-documentation--visualization).
It is most probably a JS-related issue and will be rendered properly once pushed on GitHub.