---
title: Research product
parent: Interoperability framework
ancestor: Service
layout: default
nav_order: 2
# nav_exclude: true
---

# (Ext) Research product

{: .important }
To prevent possible clashes with other extensions, each extension is assigned a unique prefix (e.g., the acronym you provided upon requesting an extension) that you need to prepend when defining new properties and relations for core entities. For this extension, the acronym is `srv`.

By default, this extended core entity inherits all the properties defined in the core [Research product].
Here below, please describe the new properties and relations that the extension adds to the default [Research product].


## Properties

### `tmpl_comments`
*List* (optional): a list of [Comment] identifiers.

```json
    "tmpl_comments": ["comment_1", "comment_2"]
```

----
[Research product]: {% link interoperability-framework/docs/research-product.md %}
[Comment]: {% link ext-tmpl/extended-interoperability-framework/extension-entities/tmpl-comment.md %}