---
title: Software service (legacy)
parent: Generic service
grand_parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 1
---
# Software Service (legacy)

{: .warning }
This document is kept for reference only. It represents an earlier draft of the Service entity specification. The current specification is maintained in [Generic service]({% link ext-srv/extended-interoperability-framework/Service.md %}).



## Properties

The properties set was suggested and informed from a number of examples both thematic and general:
- The different CMDI schema for tools & services used in the [VLO catalogue], esp the  [UDPipe example] 
- [SSHOMP catalogue] (tools and services) different examples
- [ELG catalogue] (tools and services) different examples
- [CLARIN LR Switchboard schema]
- The [Schema.org SoftwareApplication] type has many useful properties 
- The [EOSC Service Profile 4.1 rc (latest) and 5.0]


### `local_identifier`
*String* (mandatory): Unique code identifying a [Software Service] in the SKG (if any, otherwise "stateless identifier").

{: .highlight }
**Suggestion:** Use a URL as a string to make this entity dereferenceable on the Web. For additional information, see the [section 'Local identifiers of entities' of the Interoperability Framework](/interoperability-framework/#local-identifiers-of-entities).

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

### `names`
*Object* (optional): The names of a [Software service] (multiple for multilingualism). 

The object is a dictionary, the keys represent language codes following [ISO 639-1]; the special key `none` is reserved whenever the information about the language is not available or cannot be shared.

```json
"names": {
    "en": ["UDPipe", "UDPipe 2", "UDPipe 2.0"],
    "zh-cn": "UDPipe 工具"        
}
```

### `descriptions`
*Object* (optional): The description of a [Software service] (multiple for multilingualism).

The object is a dictionary, the keys represent language codes following [ISO 639-1]; the special key `none` is reserved whenever the informtion about the language is not available or cannot be shared.

```json
"descriptions": {
    "en": ["UDPipe 2 is a Python prototype, capable of performing tagging, lemmatization and syntactic analysis of CoNLL-U input. It took part in several competitions, reaching excellent results in all of them", "Summary"],
    "none": ["ontaligestring"]
}
```


### `indended_audience`
*Object* (optional): the audience(s) that the service is intended to be used by
This can  both express desire and/or design of the service operators. Values are mandatory taken from 
the https://vocabs.sshopencloud.eu/browse/sshoc-audience/en/page/audienceScheme 
```json
"intended_audience": ["Institution", "Student"]
```

### `audiencebyjurisdiction`
*Object* (optional): the jurisdiction that is given by the service operator's legal status limits
the audience. value take from https://github.com/EOSC-PLATFORM/service-profile/blob/4.0/docs/_vocabularies/DS_JURISDICTION.rst  
```json
"jurisdiction": ["ds_jurisdiction_research_infrastructure", "ds_jurisdiction-regional"
    ]
```

### `disciplines`
*List* (optional):  The disciplines for which a [Software Service] is dedicated. 
The disciplines must be specified using the Library of Congress Classification codes, 
available at https://id.loc.gov/authorities/classification (e.g. PA3000-PA3049 for classical literature). 
In case a [Software Service] is discipline agnostic, the string all should be specified.
```json
"discipline": [
    "QC790.95-QC791.8"
]
```

### `accessiblefor free`
*String* (mandatory): Field stating what kind of entity is being serialised. 

access_rights Object (recommended): The access right for the specific materialisation.

It specifies the following properties:

status String (mandatory): describe if the manifestation is open access (open), closed access (closed), under embargo (embargoed), restricted access (restricted), or unavailable for some reason (unavailable).
description String (recommended): describe and qualify the specific status selected.

Needed for parsing purposes; fixed to `service`.

```json
"entity_type": "service"
```

### `invocation_type`
*List* (mandatory): the way the service is used or called. multiple values are possible, access rights and licenses are assued to be the same.
values are specified by vocabulary https://vocabs.sshopencloud.eu/vocabularies/invocation-type/invocationTypeScheme

```json
"invocation_type": ["RESTfull webservice", "Web Application"]
```

### `life_cycle_status`
*List* (optional): indicates the development cycle and/or maturity status of the service. values are by vocabulary
https://vocabs.sshopencloud.eu/browse/eosc-life-cycle-status/en/. Originally specified in the EOSC Service Profile. Could extend with TRL classifications.
```json
"life_cycle_status": ["Production", "TRL6"]    
```    

### `website`
*String* (mandatory): landingpage for the service. preferably one maintained by the service operator 


```json
"website": "https://ufal.mff.cuni.cz/udpipe/2"
```

### `availablity_geographic`
*List* (optional): list of countries and regions where the service is made available eg. for license reasons 
```json
"availability_geographic": ["European Union","United Kingdom"]
]   
```   

###processing_language
*List* (optional) if applicable the content language the service is able to process, values provided as ISO369-2 language codes
```json
"processing_language": ["de","nl"]
```


### `keywords`
*List* (optional): list of keywords relevant for service discovery, values may be simple strings or concept URIs
```json
"keywords": ["https://www.wikidata.org/wiki/Q30642","parsing",]
]    
```

### `venues`
*Object*  (optional): A service can be part of a website or online platform that serves as a centralized gateway to a variety of services, information, and resources
```json
"venue" 
    {   
        "local_identifier": "https://cloud.gate.ac.uk",
        "identifiers": {
            "scheme": "URI",
            "value": "https://cloud.gate.ac.uk"
        },
        "name": "Gate Cloud",          
        "type": "portal",         
        "site": "https://cloud.gate.ac.uk",
        "contributions": [ {"by": "University of Sheffield", "role": "operator"}
        ]            
    }        
]    
```

### `isDeploymentOf`
*List* (optional) Research Product of type software or github link that the service is based on
```json
"isDeploymentOf": ["https://github.com/ufal/udpipe"]
```

### `contributions`
*List* of contributions (optional): 
```json
"contributions": [ 
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

