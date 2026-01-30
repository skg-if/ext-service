---
title: Generic service 
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 2
---

*Please note that the Service extension is still work in progress*
*this extension md file was previously named "SoftwareExtension"

# SKG-IF Service Extension

A Service is a type of software application or component that provides specific 
functionality or operations over a network, often via the internet, and is typically accessed 
through an interface such as an API or a web application.
(note: Service is renaming of Software Service, which is still used in many OSTrails discussion documents)



## Properties

The properties set was suggested and informed from a number of examples both thematic and general:
- The different CMDI schema for tools & services used in the [VLO catalogue], esp the [UDPipe example] 
- [SSHOMP catalogue] (tools and services) different examples
- [ELG catalogue] (tools and services) different examples
- [CLARIN LR Switchboard schema]
- The [Schema.org SoftwareApplication] type has many useful properties 
- The [EOSC Service Profile 4.1 rc (latest) and 5.0]



### `local_identifier`
*String* (mandatory): Unique code identifying a [Software Service] in the SKG (if any, otherwise "stateless identifier").

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
*Object* (optional): The names of a [Software service] (multiple for multilingualism). 

The object is a dictionary, the keys represent language codes following [ISO 639-1]; the special key `none` is reserved whenever the information about the language is not available or cannot be shared.

```json
    "name": {
        "en": "UDPipe",
        "zh-cn": "UDPipe 工具"        
    },
    "other_names": {
        "en": ["UDPipe 2", "UDPipe 2.0"]
    }
```

### `description`
*Object* (optional): The description of a [Service] (multiple for multilingualism).

The object is a dictionary, the keys represent language codes following [ISO 639-1]; the special key `none` is reserved whenever the informtion about the language is not available or cannot be shared.

```json
    "descriptions": {
        "en": ["UDPipe 2 is a Python prototype, capable of performing tagging, lemmatization and syntactic analysis of CoNLL-U input. It took part in several competitions, reaching excellent results in all of them", "Summary"],
        "cs": ["UDPipe je trénovatelný nástroj pro tokenizaci, tagging, lemmatizaci a závislostní parsing CoNLL-U souborů. UDPipe je jazykově nezávislý a pro natrénování modelů využívá anotovaná data ve formátu Universal Dependencies"]
        "none": ["ontaligestring"]
    }
```


### `audience_byrole`
*Object* (optional): The audience(s) that the service is intended to be used by.
This can both express desire and/or design of the service operators. Values are mandatory taken from 
the https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/audienceScheme 

```json
    "@context": {
        "sshocaudience": "https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/"
    },
    "audience_byrole": ["sshocaudience:public", "sshocaudience:student" ]
```

### `srv_audience_byjurisdiction`
*List* (optional): The jurisdiction that is given by the service operator's legal status limits.
The audience. Values taken from either `Global`, `Institution`, `National`, or `Regional` aka multiple countries, from https://zenodo.org/records/15516020).

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

### `isaccessible_for free`
*Boolean* (optional): A property to signal that the Service is accessible for free.

``` json
    "is_accessible_for_free": true
```

### `invocation_type`
*List* (mandatory): The way the service is used or called. Multiple values are possible, access rights and licenses are assued to be the same.
Values are specified by the vocabulary: https://vocabs.sshopencloud.eu/vocabularies/invocation-type/invocationTypeScheme

```json
    "@context": {
        "sshocinvt": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/"
    },
    "srv_invocation_type": [ "sshocinvt:restfullWebservice", "sshocinvt:webApplication" ]
```

### `life_cycle_status`
*List* (optional): Indicates the development cycle and/or maturity status of the service. Values are by the vocabulary:
https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/ Originally specified in the EOSC Service Profile. Could be extended with TRL classifications.

```json
     "@context": {
        "elcs": "https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/"
     },
    "life_cycle_status": ["elcs:life_cycle_status_production", "elcs:TRL6" ]    
```    

### `availablity_geographic`
*List* (optional): list of countries and regions where the service is made available, eg. for license reasons.
Values are by the vocabulary: https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/

```json
     "@context": {
        "eoscgeoavail": "https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/"

     },
    "availability_geographic": ["eoscgeoavail:eu","eoscgeoavail:uk"]
```    

### `website`
*String* (mandatory): Landing page for the service. Preferably one maintained by the service operator.

```json
    "website": "https://ufal.mff.cuni.cz/udpipe/2"
```

### `supported_language`

*List* (optional): If applicable the language(s) the service is able to process.
Values provided as [ISO 369-3] language codes via the [Lexvo] vocabulary: http://lexvo.org/id/iso-639-3/

``` json
    "@context": {
       "lexvo-iso639-3": "http://lexvo.org/id/iso639-3/"
     },
     "supported_language": ["lexvo-iso639-3:ger","lexvo-iso639-3:dut"]
```

### `topics`
*List* (optional):  [Topic] object identifiers relevant for the scope (topic) of a [Service].
_HOTE:_ this is description is not consistent with other examples , should be discussed and repaired.

```json
    "topics":  [
    {
            "term": "topic_1",
            "provenance": [
                {
                    "associated_with": "openaire-infra",
                    "trust": 0.7
                }
            ]
    } ]
```

### `srv_research_infrastructure` 
*List* (optional): Is associated with an [Organisation] that provides facilities, resources and services for the research communities to conduct research. Query responses can return a complete Organisation information but should minimally return "local_identifier" and "entity_type".

```json
[
    {
        "local_identifier": "https://ror.org/03wp25384",
        "entity_type": "organisation",
        "name": "CLARIN ERIC",
        "types": [
        "facility",
        "srv_research_infrastructure"
        ],
        "country": "NL"
    } ,
    {
        "local_identifier": "https://ror.org/03wp25384",
        "entity_type": "organisation",
    }
]
```
### `srv_hosting_organisation` 
*List* (optional): Is depending on [Organisation] organisation reponsible for hosting a service or infrastructure component. Query responses can return a complete Organisation information, but should minimally return `local_identifier` and `entity_type`.
```json
            {
              "local_identifier": "https://ror.org/00dd4fz34",
              "entity_type": "organisation",
              "name": "Digital Research Infrastructure for Language Technologies, Arts and Humanities",
              "short_name": "LINDAT",
              "types": [
                "facility",
                "srv_hosting_organisation"
              ],
              "country": "CZ"
            },
            { "local_identifier": "https://ror.org/00dd4fz34", 
              "entity_type": "organisation"
            }
```
### `srv_hosting_legal_entity` 
*List* (optional): Is the specific [Organisation] organisation legally reponsible for the service operation and publishing.
Query responses can return a complete Organisation iinformation, but should minimally return "local_identifier" and "entity_type".

```json
            {
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


### `relevant_organisations`
*List* (optional): [Organisation] identifiers associated with and relevant for a [Service].
Identifiers can be of local or global identifier system type eg. ror, uri. Organizations can be given additional types: "research_infrastructure", "hosting_organisation" and "hosting_legal_entity".

```json
	"relevant_organisations": ["https://ror.org/024d6js02", "https://ror.org/03wp25384"]

``` 

### `related_products`
*Object* (optional): A dictionary of objects representing related [Research products], where the semantics of such relationships is specified as a key. 
#TODO: THIS LIST HAS TO BE MODFIED FOR SERVICE/SOFTWARE RELATIONS
It is structured as follows:
- `cites` *List* (optional): [Research products] identifiers that are cited by a given [Research product].
- `is_supplemented_by` *List* (optional): [Research products] identifiers that are supplement of a given [Research product].
- `is_documented_by` *List* (optional): [Research products] identifiers that documents a given [Research product].
- `is_new_version_of` *List* (optional): [Research products] identifiers that are prior versions of a given [Research product].
- `is_part_of` *List* (optional): [Research products] identifiers that contain the current [Research product].

```json
    "srv_related_products": {
        "cites": ["product_2", "product_3", "product_4"],
        "is_supplemented_by": ["product_7", "product_8", "product_9"],
        "is_documented_by": ["product_10", "product_13"],
        "is_new_version_of": ["product_10", "product_13"],
        "is_part_of": ["product_11"]
    }
```


### `keywords`
*List* (optional): List of keywords relevant for service discovery, values may be simple strings or concept URIs.

```json
    "keywords": ["https://www.wikidata.org/wiki/Q30642","parsing",]
``` 

### `srv_deployment_of`
*List* (optional): Research Product of type software, software class or sourcecode repository link that the service is based on.

```json
    "srv_deployment_of": [
        { "@id": "https://github.com/ufal/udpipe", "@type": "schema:SoftwareSourceCode"},
        { "@id": "http://example.org/research_product/RP_101", "@type": "skg:research_product"}
    ]
    
```

### `srv_contributions`
*List* (optional) [Agents] that contributed to a [Service] (optional): 
A dictionary of objects representing contributing [Agents], where the semantics of the contributionis specified as a key.
#TODO: THIS LIST OF CONTRIBUTION TYPES HAS TO BE MODFIED FOR SERVICE/SOFTWARE CONTRIBUTIONS
#Recommended to use the specific properties such  as "research_infrastructure", "hosting_organisation" etc. to measure contribution of organisations. Individual person contributions of software developers, data managers etc. are well taken care under research-products. It is difficult to track individiual contributions to operations anyway

It is structured as follows:

```json
    "srv_contributions": [ 
           {
                    "by": "University of Sheffield",
                    "role": "operator"
                },
                {
                    "by": "UK Research and Innovation agency",
                    "role": "funder"
                }  
]    
```


----
[Research product]: {% link interoperability-framework/docs/research-product.md %}
[Agent]: {% link interoperability-framework/docs/agent.md %}
[ISO 639-1]: https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

