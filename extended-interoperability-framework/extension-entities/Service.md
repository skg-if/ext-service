---
title: Generic service 
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 2
---

{: .highlight }
Please note that the Service extension is still **work in progress**. Please follow the issue tracker [here](https://github.com/skg-if/ext-srv/issues).

# SKG-IF Service Extension

A Service is a type of software application or component that provides specific functionality or operations over a network, often via the internet, and is typically accessed through an interface such as an API or a web application.

## Properties

Properties introduced by this extension that are not defined by an authoritative external vocabulary (such as Schema.org) or by the SKG-IF core entities are prefixed with `srv_` to avoid clashes with properties of the same name potentially introduced by other extensions.

## Extensions to core entities

This extension adds new types to existing SKG-IF core entities:

### Organisation
New types for modeling service operations:
- `hosting_organisation` - organisation responsible for hosting and operating a service
- `research_infrastructure` - organisation providing facilities, resources and services for research communities

### Venue
New type for portal functionality:
- `srv_portal` - a portal/catalogue through which services are discoverable and accessible

## Properties

### `local_identifier`
*String* (mandatory): URL uniquely identifying this Service within the SKG. Should be an absolute URL or a short string resolved to a URL via `@base` in the context of JSON-LD. Can be derived from an existing persistent identifier (e.g. a handle).

{: .highlight }
**Suggestion:** Use a URL as a string to make this entity dereferenceable on the Web. For additional information, see the [section 'Local identifiers of entities' of the Interoperability Framework](/interoperability-framework/#local-identifiers-of-entities). A local_identifier can also be (derived) from an existing persistent identifier.

```json
"local_identifier": "11234/1-4816"
```

### `identifiers`
*List* (recommended): Objects representing external identifiers for the entity. 

Each identifier is structured as follows:
- `scheme` *String* (mandatory): The scheme for the external identifier.
- `value` *String* (mandatory): The external identifier.

**Note:** the current version of SKG-IF includes the following types of identifiers (to be specified as strings in the field “scheme”): `doi`, `handle`, `pmid`, `url`, `omid`, ...

```json
"identifiers": [
    {
        "scheme": "handle",
        "value": "11234/1-4816"
    },
    {
        "scheme": "doi",
        "value": "10.18653/v1/K18-2020"
    }
]
```

### `entity_type`
*String* (mandatory): Field stating what kind of entity is being serialised. 

Needed for parsing purposes; fixed to `service`.

```json
"entity_type": "service"
```

### `name`
*String* (mandatory): The canonical name of the service in English. Maps to `foaf:name`.

```json
"name": "UDPipe"
```

### `other_names`
*List* (optional): Accepted alternative names, e.g. native language names or short codes. Maps to `skos:altLabel`.

```json
"other_names": ["UDPipe 工具", "UDPipe 2"]
```

<!-- Previously other_names was modelled as a multilingual object:
    "other_names": {
        "en": ["UDPipe 2", "UDPipe 2.0"]
    }
    This form is superseded by the flat list above. -->


### `descriptions`
*Object* (optional): The descriptions of a [Service] (multiple for multilingualism).

The object is a dictionary, the keys represent language codes following [ISO 639-1]; the special key `none` is reserved whenever the informtion about the language is not available or cannot be shared.

```json
"descriptions": {
    "en": ["UDPipe 2 is a Python prototype, capable of performing tagging, lemmatization and syntactic analysis of CoNLL-U input. It took part in several competitions, reaching excellent results in all of them", "Summary"],
    "cs": ["UDPipe je trénovatelný nástroj pro tokenizaci, tagging, lemmatizaci a závislostní parsing CoNLL-U souborů. UDPipe je jazykově nezávislý a pro natrénování modelů využívá anotovaná data ve formátu Universal Dependencies"],
    "none": ["ontaligestring"]
}
```


### `srv_audience_byrole`
*List* (optional): The audience(s) that the service is intended to be used by
This can both express desire and/or design of the service operators. Values are mandatory taken from 
the https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/audienceScheme 

```json
"@context": {
    "sshocaudience": "https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/"
},
"srv_audience_byrole": ["sshocaudience:public", "sshocaudience:student" ]
```

### `srv_audience_byjurisdiction`
*List* (optional): The jurisdiction that is given by the service operator's legal status limits.
the audience. Values taken from either `Global`, `Institution`, `National`, or `Regional` aka multiple countries, from (https://zenodo.org/records/15516020).
```json
"srv_audience_byjurisdiction": ["Institution", "National" ]
```

### `disciplines`
*List* (optional):  The disciplines to which a [Software Service] is dedicated. 
The disciplines must be specified using the Library of Congress Classification codes, 
available at https://id.loc.gov/authorities/classification (e.g. PA3000-PA3049 for classical literature). 
In case a [Service] is discipline agnostic, the string "all" should be specified.

```json
"@context": {
    "loc": "https://id.loc.gov/authorities/classification/"
},
"disciplines": [
    "loc:QC790.95-QC791.8"
]
```
```json
"@context": {
    "loc": "https://id.loc.gov/authorities/classification/"
},
"disciplines": ["all"]
```

### `is_accessible_for_free`
*Boolean* (optional): A property to signal that the Service is accessible for free.

``` json

    "is_accessible_for_free": true
```

### `srv_invocation_type`
*List* (optional): The way the service is used or called. Multiple values are possible, access rights and licenses are assumed to be the same. Values are specified by vocabulary: https://vocabs.sshopencloud.eu/vocabularies/invocation-type/invocationTypeScheme

```json
"@context": {
    "sshocinvt": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/"
},
"srv_invocation_type": [ "sshocinvt:restfullWebservice", "sshocinvt:webApplication" ]
```

### `srv_life_cycle_status`
*List* (optional): Indicates the development cycle and/or maturity status of the service. Values are by vocabulary:
https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/ Originally specified in the EOSC Service Profile. Could be extended with TRL classifications.

```json
"@context": {
    "elcs": "https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/"
    },
"srv_life_cycle_status": ["elcs:life_cycle_status_production", "elcs:TRL6" ]
```

### `srv_availability_geographic`
*List* (optional): list of countries and regions where the service is made available, eg. for license reasons. Values are by the vocabulary: https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/

```json
"@context": {
    "eoscgeoavail": "https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/"

    },
"srv_availability_geographic": ["eoscgeoavail:eu","eoscgeoavail:uk"]
```    

### `website`
*String* (optional): Landingpage for the service. Preferably one maintained by the service operator

```json
"website": "https://ufal.mff.cuni.cz/udpipe/2"
```

### `srv_api_profile`
*String or Object* (optional): IRI of the API profile/standard, either as a simple link or a structured object with endpoint and documentation URLs.

Simple form (a single URL pointing to API documentation or reference):
```json
"srv_api_profile": "https://lindat.mff.cuni.cz/services/udpipe/api-reference.php"
```

Structured form (object with `dcat:endpointURL` and `schema:url`):
```json
"srv_api_profile": {
    "dcat:endpointURL": ["https://lindat.mff.cuni.cz/services/udpipe/api/process"],
    "schema:url": [
        "https://lindat.mff.cuni.cz/services/udpipe/",
        "https://lindat.mff.cuni.cz/services/udpipe/api-reference.php",
        "https://ufal.mff.cuni.cz/udpipe"
    ]
}
```

### `srv_supported_language`

*List* (optional) if applicable the language(s) the service is able to process, values provided as ISO369-3 language codes using Lexvo.org published vocabulary
_NOTE_ properties introduced by this extension, that are not from external origin or also used in core entities are prefixed with "srv_" to avoid clashes with properties with the same name potententially introduced by other extensions

``` json
"@context": {
    "lexvo-iso639-3": "http://lexvo.org/id/iso639-3"
},
"srv_supported_language": ["lexvo-iso639-3/deu","lexvo-iso639-3/nld"]
```

### `topics`
*List* (optional): [Topic] entities relevant for the scope of a [Service]. Each entry wraps a Topic reference via the `term` key. The Topic is identified by its `local_identifier` (preferably a Wikidata IRI) and may inline `entity_type`, `identifiers`, and human-readable `labels` for convenience.

_NOTE_: Unlike research products, services assert topics directly — no provenance or trust scores apply here.

```json
"topics": [
    {
        "term": {
            "local_identifier": "https://www.wikidata.org/wiki/Q8162",
            "entity_type": "topic",
            "identifiers": [
                {
                    "scheme": "wikidata",
                    "value": "https://www.wikidata.org/wiki/Q8162"
                }
            ],
            "labels": {
                "en": "Linguistics"
            }
        }
    },
    {
        "term": {
            "local_identifier": "https://www.wikidata.org/wiki/Q30642",
            "entity_type": "topic",
            "identifiers": [
                {
                    "scheme": "wikidata",
                    "value": "https://www.wikidata.org/wiki/Q30642"
                }
            ],
            "labels": {
                "en": "Natural Language Processing"
            }
        }
    }
]
```

### `srv_has_research_infrastructure`

*List* (optional): Is associated with an [Organisation] that provides facilities, resources and services for the research communities to conduct research.
_NOTE_ Each item may be a `local_identifier` for an Organisation or an Organisation object. API responses may expand identifiers to Organisation objects. Also include each organisation's `local_identifier` in `relevant_organisations` (see below).
Simple form (`local_identifier`, preferred for input/storage):
```json
"srv_has_research_infrastructure": [
    "https://ror.org/03wp25384"
]
```
Expanded form (Organisation object, as returned by API with `embedding=true`):
```json
"srv_has_research_infrastructure": [
    {
        "local_identifier": "https://ror.org/03wp25384",
        "entity_type": "organisation",
        "name": "CLARIN ERIC",
        "types": [
        "facility",
        "research_infrastructure"
        ],
        "country": "NL"
    }
]
```

### `srv_has_hosting_organisation`
*List* (optional): Is depending on [Organisation] responsible for hosting a service or infrastructure component.
_NOTE_ Each item may be a `local_identifier` for an Organisation or an Organisation object. API responses may expand identifiers to Organisation objects. Also include each organisation's `local_identifier` in `relevant_organisations` (see below).

Simple form (`local_identifier`, preferred for input/storage):
```json
"srv_has_hosting_organisation": [
    "https://ror.org/00dd4fz34"
]
```
Expanded form (Organisation object, as returned by API with `embedding=true`):
```json
"srv_has_hosting_organisation": [
    {
        "local_identifier": "https://ror.org/00dd4fz34",
        "entity_type": "organisation",
        "name": "Digital Research Infrastructure for Language Technologies, Arts and Humanities",
        "short_name": "LINDAT",
        "types": [
        "facility",
        "hosting_organisation"
        ],
        "country": "CZ"
    }
]
```

### `srv_has_hosting_legal_entity`
*String* (optional): Is the specific [Organisation] legally responsible for the service operation and publishing.
_NOTE_ The value may be a `local_identifier` for an Organisation or an Organisation object. API responses may expand the identifier to an Organisation object. Also include this organisation's `local_identifier` in `relevant_organisations` (see below).

Simple form (`local_identifier`, preferred for input/storage):
```json
"srv_has_hosting_legal_entity": "https://ror.org/024d6js02"
```
Expanded form (Organisation object, as returned by API with `embedding=true`):
```json
"srv_has_hosting_legal_entity": {
    "local_identifier": "https://ror.org/024d6js02",
    "entity_type": "organisation",
    "name": "Charles University",
    "types": [
        "education",
        "research"
    ],
    "country": "CZ"
}
```


### `srv_venues`
*List* (optional): Portals or catalogues through which the service is advertised and accessible. Each entry references a [Venue] with type `srv_portal`.
_NOTE_ Each item may be a `local_identifier` for a Venue or a Venue object. API responses may expand identifiers to Venue objects.

Simple form (`local_identifier`, preferred for input/storage):
```json
"srv_venues": [
    "https://ror.org/03sj9b840",
    "https://portal.ariadne-infrastructure.eu"
]
```
Expanded form (Venue objects, as returned by API with `embedding=true`):
```json
"srv_venues": [
    {
        "local_identifier": "https://ror.org/03sj9b840",
        "entity_type": "venue",
        "name": "EOSC node",
        "types": ["srv_portal"],
        "website": "https://open-science-cloud.ec.europa.eu/support/getting-started-eosc-eu-node"
    },
    {
        "local_identifier": "https://portal.ariadne-infrastructure.eu",
        "entity_type": "venue",
        "name": "Ariadne portal",
        "types": ["srv_portal"],
        "website": "https://portal.ariadne-infrastructure.eu/about"
    }
]
```

### `relevant_organisations`
*List* (optional): Generic queryable index of all [Organisation] identifiers associated with and relevant for a [Service].
Identifiers can be of local or global identifier system type e.g. ror, uri. Organisations can be given additional types: `"research_infrastructure"`, `"hosting_organisation"` and `"hosting_legal_entity"` to indicate their role.

_NOTE_ Each item may be a plain identifier string or an Organisation object. API responses may expand identifiers to Organisation objects.

For semantically typed roles use the specific `srv_has_*` properties and include their `local_identifier` here for completeness.

Simple form (flat identifier strings, preferred for input/storage):
```json
	"relevant_organisations": ["https://ror.org/024d6js02", "https://ror.org/03wp25384"]
```

Expanded form (as may be returned by the API):
```json
"relevant_organisations": [
    {
        "local_identifier": "https://ror.org/024d6js02",
        "entity_type": "organisation",
        "name": "Charles University",
        "types": ["education", "research"],
        "country": "CZ"
    },
    {
        "local_identifier": "https://ror.org/03wp25384",
        "entity_type": "organisation"
    }
]
```

### `related_products`
*Object* (optional): JSON-LD grouping collecting typed relations to [Research products].
The key is the relation type; values are lists of identifiers.

Applicable relation types:
- `is_documented_by` *List* (optional): Research products documenting this service.
- `is_cited_by` *List* (optional): Research products citing this service.

```json
"related_products": {
    "is_documented_by": ["https://doi.org/10.1007/s10579-010-9130-z"],
    "is_cited_by": ["https://doi.org/10.18653/v1/2020.acl-main.1"]
}
```

> **Future extension — `related_services` on Research products**: There is a use case for extending the core `research_product` entity with a reciprocal `related_services` nested property, supporting the following relation types from the research product side:
> - `cites` — a publication cites a service
> - `documents` — a publication documents a service
> - `is_created_by` — a dataset was created by a service


### `srv_keywords`
*List* (optional): List of keywords relevant for service discovery, values may be simple strings or concept URIs. Maps to `schema:keyword`.

```json
"srv_keywords": ["https://www.wikidata.org/wiki/Q30642","parsing"]
``` 

### `srv_deployment_of`                                                                           
  *List* (optional) The software that this service is a running instance of.                        
                                                                                                    
  Can be:
  - A plain string `local_identifier` — treated as a cross-reference to an `skg:research_product` (type software) in the SKG-IF graph
  - A typed external reference:
    - `fabio:Software` — an external software entity identified by a GitHub/GitLab URL, handle, or DOI. It is a bibliographic class — its inherited properties are about identifying and citing software (DOI, handle, version, date), not describing its technical characteristics.

```json
  "srv_deployment_of": [
      "local-id-of-udpipe-software",
      { "@id": "https://github.com/ufal/udpipe", "@type": "fabio:Software" },
      { "@id": "https://hdl.handle.net/11234/1-1452", "@type": "fabio:Software" }
  ]
```


### `srv_contributions`

> **Removed**: The `srv_has_hosting_organisation`, `srv_has_research_infrastructure`, and `relevant_organisations` properties are considered sufficient to capture the organisational relationships of a service. A general agent+role contribution pattern (as used for research products) is for now not recommended for services, as operational contributions are difficult to track at that level of granularity. `srv_contributions` has been removed.


----
[Research product]: {% link interoperability-framework/docs/research-product.md %}
[Agent]: {% link interoperability-framework/docs/agent.md %}
[ISO 639-1]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes
[VLO catalogue]: https://vlo.clarin.eu/?2
[UDPipe example]: https://vlo.clarin.eu/record/https_58__47__47_hdl.handle.net_47_11234_47_1-1702_64_format_61_cmdi?q=UDPipe
[SSHOMP catalogue]: https://marketplace.sshopencloud.eu
[ELG catalogue]: https://live.european-language-grid.eu/catalogue/
[CLARIN LR Switchboard schema]: https://www.clarin.eu/sites/default/files/zinn-CLARIN2016_paper_26.pdf
[Schema.org SoftwareApplication]: https://schema.org/SoftwareApplication
[EOSC Service Profile 4.1 rc (latest) and 5.0]: https://eosc-service-profile.readthedocs.io/en/latest/introduction.html
