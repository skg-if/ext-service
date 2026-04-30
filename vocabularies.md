# ext-srv Controlled Vocabularies

Properties with a fixed or externally-defined set of values.

| Property | Type | Prefix | Vocabulary | Examples |
|---|---|---|---|---|
| `srv_audience_by_jurisdiction` | Closed enum — validated against explicit list in API overlay | — | [EOSC DS_JURISDICTION](https://eosc-service-profile.readthedocs.io/en/5.0/_vocabularies/DS_JURISDICTION.html) | `"Global"`, `"National"` |
| `srv_audience_byrole` | CURIE format validated in API overlay; concept existence not checked | `sshocaudience:` = `https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/` | [SSHOMP sshoc-audience](https://vocabs.sshopencloud.eu/vocabularies/sshoc-audience/audienceScheme) | `"sshocaudience:public"`, `"sshocaudience:researcher"` |
| `srv_invocation_type` | CURIE format validated in API overlay; concept existence not checked | `sshocinvt:` = `https://vocabs.sshopencloud.eu/vocabularies/invocation-type/` | [SSHOMP invocation-type](https://vocabs.sshopencloud.eu/vocabularies/invocation-type/) | `"sshocinvt:restfullWebservice"`, `"sshocinvt:webApplication"` |
| `srv_life_cycle_status` | CURIE format validated in API overlay; concept existence not checked | `elcs:` = `https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/` | [SSHOMP eosc-life-cycle-status](https://vocabs.sshopencloud.eu/vocabularies/eosc-life-cycle-status/) | `"elcs:life_cycle_status_production"`, `"elcs:TRL6"` |
| `srv_availability_geographic` | CURIE format validated in API overlay; concept existence not checked | `eoscgeoavail:` = `https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/` | [SSHOMP eosc-geographical-availability](https://vocabs.sshopencloud.eu/vocabularies/eosc-geographical-availability/) | `"eoscgeoavail:eu"`, `"eoscgeoavail:uk"` |
| `srv_supported_language` | 3-letter code pattern validated in API overlay; ISO 639-3 code validity not checked | `lexvo-iso639-3:` = `http://lexvo.org/id/iso639-3/` | [Lexvo ISO 639-3](http://lexvo.org/id/iso639-3/) | `"lexvo-iso639-3:eng"`, `"lexvo-iso639-3:nld"` |
| `disciplines` | Free string; no format validation in API overlay | `loc:` = `http://id.loc.gov/authorities/` | [Library of Congress Classification](https://id.loc.gov/authorities/classification) | `"QC790.95-QC791.8"`, `"all"` |
