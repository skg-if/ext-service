---
title: Interoperability framework
parent: Extension template
layout: default
nav_order: 2
has_toc: false
# nav_exclude: true
---
# (tmpl) Interoperability framework

{: .important }
To prevent possible clashes with other extensions, each extension is assigned a unique prefix (e.g., the acronym you provided upon requesting an extension) that you need to prepend when defining new properties and relations for core entities. For this extension, the acronym is `tmpl`.

## Core extensions
As an example, this template extends these core entities:
- [Extended research product] (extending the core [Research product]).


## Extension-specific entities
This template introduces a brand-new entity [Comment].


----
[Extended research product]: {% link ext-tmpl/extended-interoperability-framework/core-extensions/tmpl-research-product.md %}
[Comment]: {% link ext-tmpl/extended-interoperability-framework/extension-entities/tmpl-comment.md %}
[Research product]: {% link interoperability-framework/docs/research-product.md %}
