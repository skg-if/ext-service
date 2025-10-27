---
title: JSON-LD context
parent: Extension template
layout: default
nav_order: 5
has_toc: false
# nav_exclude: false
---

# Extended JSON-LD context

{: .important }
To prevent possible clashes with other extensions, each extension is assigned a unique prefix (e.g., the acronym you provided upon requesting an extension) that you need to prepend when defining new properties and relations for core entities. For this extension, the acronym is `tmpl`.

## Expected outcome
In this extension development phase, the JSON-LD context is produced and placed as indicated in the repository structure [guidelines](../structure), in order to be served behind w3id.org.

For example, the current (i.e., last) version of the JSON-LD context is available at [https://w3id.org/skg-if/extension/tmpl/context/skg-if.json](https://w3id.org/skg-if/extension/tmpl/context/skg-if.json).


## Methodological considerations
This phase is manual and maps the JSON terms that will "surface" in the [extended Interoperability Framework](../extended-interoperability-framework) to the ontology [previously developed](../data-model).