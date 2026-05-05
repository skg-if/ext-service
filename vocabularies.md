## Vocabulary properties and scoped context design

### Current state (ext-srv context)

All ext-srv vocabulary properties use `@vocab` in their scoped contexts (fixed 2026-05-03):

```json
"srv_invocation_type":         { "@id": "srv:invocationType",            "@type": "@vocab", "@context": { "@vocab": "sshopencloudvocabs:invocation-type/" } },
"srv_life_cycle_status":       { "@id": "srv:eoscLifeCycleStatus",       "@type": "@vocab", "@context": { "@vocab": "sshopencloudvocabs:eosc-life-cycle-status/" } },
"srv_availability_geographic": { "@id": "srv:geographicalAvailability",  "@type": "@vocab", "@context": { "@vocab": "sshopencloudvocabs:eosc-geographical-availability/" } },
"srv_audience_byrole":         { "@id": "srv:intendedAudienceRole",      "@type": "@vocab", "@context": { "@vocab": "sshopencloudvocabs:sshoc-audience/" } },
"srv_supported_language":      { "@id": "srv:supportedLanguage",         "@type": "@vocab", "@context": { "@vocab": "http://lexvo.org/id/iso639-3/" } }
```

The core property `disciplines` is left untouched (see below):

```json
"disciplines": { "@id": "dcterms:subject", "@type": "@vocab", "@context": { "@base": "http://id.loc.gov/authorities/classification/" } }
```

---

### @base vs @vocab in scoped contexts

**Rule**: for `@type: @vocab` term definitions, use `@vocab` in the scoped context, not `@base`.

Reasons:
- `@vocab` expands CURIEs; `@base` does not — so `"@base": "sshopencloudvocabs:invocation-type"` silently
  fails to expand the CURIE and produces wrong IRIs for bare terms
- `@base` also requires a trailing `/` for correct RFC 3986 path resolution; `@vocab` concatenates directly
- The JSON-LD 1.1 spec (section 4.1.8, examples 45–46) consistently uses `@vocab` in scoped contexts
- Both CURIE form (`sshocinvt:webApplication`) and bare term (`webApplication`) must produce the same IRI;
  this only works reliably with `@vocab`

The canonical test is in `examples/canonical_vocab_resolution.json`.

---

### The disciplines / dcterms:subject anomaly

The core context uses `@base` for `disciplines`. Analysis shows this choice has no strong justification:

1. **`dcterms:subject` has no formal range** in the DCMI Terms specification. The range is intentionally open;
   the spec only recommends "refer to the subject with a URI from a controlled vocabulary."

2. **The SKG-IF data-model ontology types the range as `owl:Thing`** (the most general OWL class), consistent
   with the open DCMI range — but then the context hardwires LOC classification via `@base`. These two layers
   contradict each other: the ontology says open, the context says LOC-only.

3. **LOC classification resources are effectively SKOS concepts**. The LOC Linked Data service types its
   classification records as `lcc:ClassNumber` and `madsrdf:Topic`. MADS/RDF explicitly declares
   `madsrdf:Authority owl:equivalentClass skos:Concept`, so `madsrdf:Topic` (a subclass) is semantically
   equivalent to a SKOS concept. The sshopencloud vocabularies are also SKOS concepts. There is no meaningful
   structural difference between the two cases.

4. **Conclusion**: the `@base` choice for `disciplines` in the core context is not semantically justified.
   `@vocab` would be equally correct (and more consistent with the spec). Ext-srv does not change the core
   definition, but this is a known issue to raise with the core team.

---

### Vocabulary prefixes declared in ext-srv context

```json
"sshopencloudvocabs": "https://vocabs.sshopencloud.eu/vocabularies/",
"sshocaudience":      "https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/",
"sshocinvt":          "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/",
"elcs":               "https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/",
"eoscgeoavail":       "https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/",
"lexvo-iso639-3":     "http://lexvo.org/id/iso639-3/"
```

These prefixes allow CURIE-form values in examples (e.g. `sshocinvt:webApplication`). The scoped `@vocab`
in each term definition allows bare-term form (e.g. `webApplication`) as an equivalent alternative.
Both forms are demonstrated in `examples/canonical_vocab_resolution.json`.
