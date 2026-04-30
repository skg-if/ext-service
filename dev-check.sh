#!/usr/bin/env bash
# dev-check.sh — SKG-IF local development check and run
#
# NOTE: This script is specific to the ext-srv extension and is provided without any guarantees.
#
# 1. Ontology syntax check (riot — srv.ttl only)
# 2. SHACL generation from srv.ttl (shacl-extractor); validates cardinality format; riot-validates output
# 3. Cross-file alignment: ontology ↔ JSON-LD context ↔ SHACL ↔ OpenAPI overlay + rdfs:label check
# 4. Generate consolidated OpenAPI spec (core + ext-srv service overlay)
# 5. Lint core OpenAPI spec with Spectral
# 6. Lint consolidated OpenAPI spec with Spectral
# 7. Check ext-srv context file compatibility (all srv_* properties declared)
# 8. Copy consolidated spec to api/Docker/ and start the development stack
# 9. API health checks against Prism
#
# Usage:
#   ./dev-check.sh              # run all steps including docker compose up
#   ./dev-check.sh --no-docker  # run checks only, skip docker compose up
#   ./dev-check.sh --check-only # same as --no-docker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API_DIR="$(cd "$SCRIPT_DIR/../api" && pwd)"

ONTOLOGY_TTL="$SCRIPT_DIR/data-model/ontology/current/srv.ttl"
SHACL_TTL="$SCRIPT_DIR/data-model/shacl/current/shacl.ttl"
CORE_SPEC="$API_DIR/openapi/ver/current/skg-if-openapi.yaml"
OVERLAY="$SCRIPT_DIR/api/ver/current/service-overlay.yaml"
CONSOLIDATED="$SCRIPT_DIR/consolidated-openapi.yaml"
SKG_CTX_DIR="$(cd "$SCRIPT_DIR/../shacl-extractor/context/ver" && pwd)"                   # core entity context versions dir
API_CTX="$API_DIR/openapi/ver/current/context/skg-if-api.json"                              # API-layer context (pagination etc.)
EXT_CTX="$SCRIPT_DIR/context/ver/current/skg-if.json"                                       # service extension context
SPECTRAL_RULESET="$API_DIR/.spectral.yaml"
DOCKER_DIR="$SCRIPT_DIR/api/Docker"
SHACL_EXTRACTOR_DIR="$(cd "$SCRIPT_DIR/../shacl-extractor" && pwd)"
SHACL_EXTRACTOR_PY="$SHACL_EXTRACTOR_DIR/.venv/bin/python"

START_DOCKER=true
for arg in "$@"; do
    case "$arg" in
        --no-docker|--check-only) START_DOCKER=false ;;
    esac
done

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
info() { echo -e "\n${BOLD}${YELLOW}▶ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# ── Preflight ─────────────────────────────────────────────────────────────────
info "Checking prerequisites"

[[ -f "$ONTOLOGY_TTL" ]] || fail "Ontology not found: $ONTOLOGY_TTL"
[[ -f "$SHACL_TTL"    ]] || warn "shacl.ttl not found — will be generated in Step 2"
[[ -f "$CORE_SPEC"    ]] || fail "Core spec not found: $CORE_SPEC"
[[ -f "$OVERLAY"      ]] || fail "Service overlay not found: $OVERLAY"
[[ -f "$SKG_CTX_DIR/current/skg-if.json" ]] || fail "Core entity context not found: $SKG_CTX_DIR/current/skg-if.json"
[[ -f "$API_CTX"      ]] || fail "API context not found: $API_CTX"
[[ -f "$EXT_CTX"      ]] || fail "Ext-srv context not found: $EXT_CTX"

command -v riot      &>/dev/null || fail "'riot' not found — brew install jena"
command -v speakeasy &>/dev/null || fail "'speakeasy' not found — install from https://www.speakeasy.com"
command -v npx       &>/dev/null || fail "'npx' not found — install Node.js"
command -v python3   &>/dev/null || fail "'python3' not found"
python3 -c "import rdflib" 2>/dev/null || fail "'rdflib' not found — pip install rdflib"
[[ -f "$SHACL_EXTRACTOR_PY" ]] || fail "shacl-extractor venv not found at $SHACL_EXTRACTOR_PY — run 'uv sync' in $SHACL_EXTRACTOR_DIR"
ok "All prerequisites met"

# ── Step 1: Ontology syntax ───────────────────────────────────────────────────
info "Step 1: Ontology syntax check"

riot --validate "$ONTOLOGY_TTL" 2>&1 \
    && ok "srv.ttl syntax OK" \
    || fail "srv.ttl has syntax errors"

# ── Step 2: SHACL generation ──────────────────────────────────────────────────
info "Step 2: SHACL generation from srv.ttl"

SHACL_GENERATED="$(mktemp /tmp/srv-shacl-XXXXXX.ttl)"
trap 'rm -f "$SHACL_GENERATED"' EXIT

# Requires shacl-extractor with ext-*** module name fix (PR: dgbroeder/shacl-extractor fix/ext-module-name)
# Without it, the shapes prefix would be 'ontology_sh:' instead of 'srv_sh:'.
"$SHACL_EXTRACTOR_PY" -m src.main \
    "$ONTOLOGY_TTL" \
    "$SHACL_GENERATED" \
    --shapes-base https://w3id.org/skg-if/shapes/srv/ 2>&1 \
    && ok "SHACL generated from srv.ttl" \
    || fail "SHACL extraction failed — fix dc:description cardinality format in srv.ttl"

riot --validate "$SHACL_GENERATED" 2>&1 \
    && ok "Generated SHACL syntax OK" \
    || fail "Generated SHACL has syntax errors"

if [[ -f "$SHACL_TTL" ]]; then
    if diff -q "$SHACL_TTL" "$SHACL_GENERATED" &>/dev/null; then
        ok "shacl.ttl is up to date"
    else
        warn "shacl.ttl differs from freshly generated SHACL — updating"
        cp "$SHACL_GENERATED" "$SHACL_TTL"
        ok "shacl.ttl updated"
    fi
else
    cp "$SHACL_GENERATED" "$SHACL_TTL"
    ok "shacl.ttl created"
fi

# ── Step 3: Cross-file alignment check ───────────────────────────────────────
info "Step 3: Cross-file alignment check"

python3 - "$ONTOLOGY_TTL" "$SHACL_TTL" "$EXT_CTX" "$OVERLAY" "$SKG_CTX_DIR" << 'PYEOF'
import sys, json, re, os
from rdflib import Graph, RDF, OWL

ontology_path, shacl_path, ctx_path, overlay_path, skg_ctx_dir = \
    sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]

from rdflib import RDFS
SRV_NS      = "https://w3id.org/skg-if/extension/srv/ontology/"
SH_PATH     = "http://www.w3.org/ns/shacl#path"
PROP_TYPES  = {str(OWL.ObjectProperty), str(OWL.DatatypeProperty)}
ENTITY_TYPES = PROP_TYPES | {str(OWL.Class), str(RDFS.Class)}

warnings = []

# ── Parse ontology: srv:* properties and classes ──────────────────────────────
g_ont = Graph()
g_ont.parse(ontology_path, format="turtle")
ont_srv_props    = {str(s) for s, p, o in g_ont          # properties only (for Checks 1 & 3)
                    if str(p) == str(RDF.type) and str(o) in PROP_TYPES
                    and str(s).startswith(SRV_NS)}
ont_srv_entities = {str(s) for s, p, o in g_ont          # properties + classes (for Check 2)
                    if str(p) == str(RDF.type) and str(o) in ENTITY_TYPES
                    and str(s).startswith(SRV_NS)}

# ── Parse SHACL: all srv:* sh:path values ────────────────────────────────────
g_shacl = Graph()
g_shacl.parse(shacl_path, format="turtle")
shacl_srv_paths = {str(o) for s, p, o in g_shacl
                   if str(p) == SH_PATH and str(o).startswith(SRV_NS)}

# ── Parse JSON-LD context: build term → full URI map ─────────────────────────
ctx = json.load(open(ctx_path)).get("@context", {})

# Prefix map: context keys whose value is a namespace URI (ends with / or #)
prefix_map = {k: v for k, v in ctx.items()
              if isinstance(v, str) and not k.startswith("@") and not k.startswith("_")
              and (v.endswith("/") or v.endswith("#"))}

def resolve_curie(val):
    if not val or val.startswith("@"):
        return None
    if val.startswith("http"):
        return val
    if ":" in val:
        pfx, local = val.split(":", 1)
        if pfx in prefix_map:
            return prefix_map[pfx] + local
    return None

ctx_uri_map = {}
for k, v in ctx.items():
    if k.startswith("_") or k.startswith("@"):
        continue
    raw_id = v.get("@id") if isinstance(v, dict) else v if isinstance(v, str) else None
    uri = resolve_curie(raw_id)
    if uri:
        ctx_uri_map[k] = uri

# srv_* context terms that map into the srv: namespace
srv_ctx = {k: v for k, v in ctx_uri_map.items()
           if k.startswith("srv_") and v.startswith(SRV_NS)}

# ── Check 1: SHACL srv:* paths declared in ontology? ─────────────────────────
undeclared = sorted(shacl_srv_paths - ont_srv_props)
if undeclared:
    for uri in undeclared:
        warnings.append(f"SHACL sh:path srv:{uri[len(SRV_NS):]} not declared as property in srv.ttl")
else:
    print(f"  ✓ All {len(shacl_srv_paths)} SHACL srv:* paths declared in ontology")

# ── Check 2: Context srv_*→srv:* terms all resolve to a declared ontology entity ─
stale = {k: v for k, v in srv_ctx.items() if v not in ont_srv_entities}
if stale:
    for term, uri in sorted(stale.items()):
        warnings.append(f"Context '{term}' maps to srv:{uri[len(SRV_NS):]} — not declared in ontology")
else:
    print(f"  ✓ All {len(srv_ctx)} context srv_*→srv:* mappings resolve to declared ontology entities")

# ── Check 3: Ontology srv:* properties covered by at least one context term? ─
covered = set(srv_ctx.values())
uncovered = sorted(ont_srv_props - covered)
if uncovered:
    for uri in uncovered:
        warnings.append(f"Ontology property srv:{uri[len(SRV_NS):]} has no srv_* term in context")
else:
    print(f"  ✓ All {len(ont_srv_props)} ontology srv:* properties covered in context")

# ── Check 4: Context srv_* terms present in overlay schema? (informational) ──
overlay_text = open(overlay_path).read()  # reused by Check 5
overlay_srv = set(re.findall(r'(?m)^[ \t]{4,}(srv_\w+)\s*:', overlay_text))
ctx_srv_all  = {k for k in ctx if k.startswith("srv_")}
not_in_overlay = sorted(ctx_srv_all - overlay_srv)
if not_in_overlay:
    for term in not_in_overlay:
        warnings.append(f"Context term '{term}' absent from overlay schema (may be intentional)")
else:
    print(f"  ✓ All context srv_* terms present in overlay schema")

# ── Check 5: Core context version pinned in overlay matches local 'current' ───
m = re.search(r'skg-if/context/(\d+\.\d+\.\d+)/skg-if\.json', overlay_text)
if not m:
    warnings.append("Could not find pinned skg-if core context version in overlay")
else:
    pinned_ver = m.group(1)
    versioned_path = os.path.join(skg_ctx_dir, pinned_ver, "skg-if.json")
    current_path   = os.path.join(skg_ctx_dir, "current",   "skg-if.json")
    if not os.path.exists(versioned_path):
        warnings.append(f"Pinned core context version {pinned_ver} not found locally ({versioned_path})")
    else:
        pinned_text  = open(versioned_path).read()
        current_text = open(current_path).read()
        if pinned_text == current_text:
            print(f"  ✓ Core context 'current' matches pinned version {pinned_ver}")
        else:
            warnings.append(
                f"Core context 'current' differs from pinned version {pinned_ver} "
                f"— update the version pin in overlay or sync 'current'"
            )

# ── Check 6: Ext-srv context terms don't conflict with core context ───────────
core_ctx = json.load(open(os.path.join(skg_ctx_dir, "current", "skg-if.json"))).get("@context", {})
core_prefix_map = {k: v for k, v in core_ctx.items()
                   if isinstance(v, str) and not k.startswith("@") and not k.startswith("_")
                   and (v.endswith("/") or v.endswith("#"))}

def resolve_core(val):
    if not val or val.startswith("@"):
        return None
    if val.startswith("http"):
        return val
    if ":" in val:
        pfx, local = val.split(":", 1)
        if pfx in core_prefix_map:
            return core_prefix_map[pfx] + local
    return None

conflicts = []
for term, ext_uri in ctx_uri_map.items():
    if term not in core_ctx:
        continue
    core_val = core_ctx[term]
    raw = core_val.get("@id") if isinstance(core_val, dict) else core_val if isinstance(core_val, str) else None
    core_uri = resolve_core(raw)
    if core_uri and core_uri != ext_uri:
        conflicts.append(f"'{term}': ext-srv → <{ext_uri}>  vs  core → <{core_uri}>")

if conflicts:
    for c in conflicts:
        warnings.append(f"Conflicting term definition with core context: {c}")
else:
    print(f"  ✓ No conflicting term definitions between ext-srv and core context")

# ── Check 7: rdfs:label (SKG-IF labels: X) present and X in ext-srv context ──
RDFS_LABEL = str(RDFS.label)
label_issues = []
for prop_uri in sorted(ont_srv_props):
    labels = [str(o) for s, p, o in g_ont
              if str(s) == prop_uri and str(p) == RDFS_LABEL]
    if not labels:
        label_issues.append(f"srv:{prop_uri[len(SRV_NS):]} has no rdfs:label")
        continue
    found = False
    for lbl in labels:
        m = re.search(r'\(SKG-IF labels:\s*(\w+)\)', lbl)
        if m:
            json_name = m.group(1)
            if json_name not in ctx:
                label_issues.append(
                    f"srv:{prop_uri[len(SRV_NS):]} rdfs:label references "
                    f"'{json_name}' — not found in ext-srv context")
            found = True
            break
    if not found:
        label_issues.append(
            f"srv:{prop_uri[len(SRV_NS):]} rdfs:label missing '(SKG-IF labels: X)' pattern")

if label_issues:
    for issue in label_issues:
        warnings.append(f"Label: {issue}")
else:
    print(f"  ✓ All {len(ont_srv_props)} ontology srv:* properties have correct SKG-IF label format")

# ── Summary ───────────────────────────────────────────────────────────────────
if warnings:
    print(f"\n  {len(warnings)} alignment warning(s):")
    for w in warnings:
        print(f"  ⚠ {w}")
PYEOF

ok "Alignment check complete"

# ── Step 3b: Service.md ↔ ontology alignment check ───────────────────────────
info "Step 3b: Service.md ↔ ontology alignment check"

python3 - "$ONTOLOGY_TTL" "$EXT_CTX" "$SKG_CTX_DIR" "$SCRIPT_DIR/extended-interoperability-framework/extension-entities/Service.md" << 'PYEOF'
import sys, json, re

ontology_path, ext_ctx_path, skg_ctx_dir, service_md_path = \
    sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

warnings = []

# ── Parse @prefix declarations from srv.ttl ───────────────────────────────────
ontology_text = open(ontology_path).read()
ttl_prefixes = {}
for m in re.finditer(r'@prefix\s+(\w+):\s+<([^>]+)>', ontology_text):
    ttl_prefixes[m.group(1)] = m.group(2)

def resolve_ttl_curie(curie):
    if curie.startswith("http"):
        return curie
    if ":" in curie:
        pfx, local = curie.split(":", 1)
        if pfx in ttl_prefixes:
            return ttl_prefixes[pfx] + local
    return curie

# ── Build URI → alias reverse map from core + ext-srv contexts ───────────────
def load_ctx(path):
    try:
        return json.load(open(path)).get("@context", {})
    except Exception:
        return {}

core_ctx = load_ctx(f"{skg_ctx_dir}/current/skg-if.json")
ext_ctx  = load_ctx(ext_ctx_path)

def build_prefix_map(ctx):
    return {k: v for k, v in ctx.items()
            if isinstance(v, str) and not k.startswith("@") and not k.startswith("_")
            and (v.endswith("/") or v.endswith("#"))}

all_prefix = {**build_prefix_map(core_ctx), **build_prefix_map(ext_ctx)}

def ctx_to_reverse_map(ctx):
    """Build URI → alias map.
    Two-pass: direct (non-nested) entries take priority; nested entries fill gaps only.
    This avoids collisions where a URI has both a direct alias and a nested alias
    (e.g. dcterms:relation → relevant_organisations direct, srv_other nested)
    while still mapping URIs that only appear as nested entries (cito:isCitedBy → is_cited_by).
    """
    def resolve(raw):
        if not raw or raw == "@nest":
            return None
        if raw.startswith("http"):
            return raw
        if ":" in raw:
            pfx, local = raw.split(":", 1)
            if pfx in all_prefix:
                return all_prefix[pfx] + local
        return None

    direct = {}
    nested = {}
    for k, v in ctx.items():
        if k.startswith("_") or k.startswith("@"):
            continue
        is_nested = isinstance(v, dict) and "@nest" in v
        raw = v.get("@id") if isinstance(v, dict) else v if isinstance(v, str) else None
        uri = resolve(raw)
        if not uri:
            continue
        if is_nested:
            nested.setdefault(uri, k)   # keep first nested alias per URI
        else:
            direct[uri] = k             # direct alias always wins
    return {**nested, **direct}         # direct overrides nested

uri_to_alias = {**ctx_to_reverse_map(core_ctx), **ctx_to_reverse_map(ext_ctx)}

# ── URIs intentionally absent from Service.md ────────────────────────────────
ONT_SKIP = {
    resolve_ttl_curie("schema:provider"),            # noted "not used for now" in srv.ttl
    resolve_ttl_curie("srv:relatedResearchProduct"),  # superproperty, no JSON-LD alias
}

# ── Parse srv:Service cardinality block ───────────────────────────────────────
service_m = re.search(
    r'srv:Service\s+a\s+owl:Class\s*;.*?dc:description\s+"""(.*?)"""',
    ontology_text, re.DOTALL
)
if not service_m:
    print("  ✗ Could not locate srv:Service dc:description block", file=sys.stderr)
    sys.exit(1)

ont_props = {}  # alias → {min, max}
no_alias  = []
for line in service_m.group(1).splitlines():
    m = re.match(r'\*\s+(\S+)\s+-\[([^\]]+)\]->', line.strip())
    if not m:
        continue
    prop_uri = resolve_ttl_curie(m.group(1))
    if prop_uri in ONT_SKIP:
        continue
    lo, hi = (m.group(2).split("..") + [m.group(2)])[:2] if ".." in m.group(2) \
              else (m.group(2), m.group(2))
    min_c = int(lo) if str(lo).isdigit() else 0
    max_c = None if hi == "N" else (int(hi) if str(hi).isdigit() else 1)
    alias = uri_to_alias.get(prop_uri)
    if not alias:
        no_alias.append(prop_uri)
        continue
    if alias not in ont_props:
        ont_props[alias] = {"min": min_c, "max": max_c}
    else:
        # same alias, multiple range entries → keep most permissive
        ont_props[alias]["min"] = min(ont_props[alias]["min"], min_c)
        ont_props[alias]["max"] = None

for uri in no_alias:
    warnings.append(f"Ontology property <{uri}> has no alias in either context")

# ── Parse Service.md property sections ───────────────────────────────────────
service_md = open(service_md_path).read()

md_props = {}  # alias → {mandatory, is_list}

# Top-level: ### `alias`  (possible trailing spaces)\n+  (possible indent)*Type* (card)
for m in re.finditer(
    r'^###\s+`(\w+)`[ \t]*\n+[ \t]*\*([^*]+)\*[ \t]*\((mandatory|optional|recommended)\)',
    service_md, re.MULTILINE
):
    alias     = m.group(1)
    type_label = m.group(2).strip().lower()
    card_label = m.group(3).lower()
    md_props[alias] = {"mandatory": card_label == "mandatory", "is_list": type_label == "list"}

# Sub-entries inside `related_products` only: - `alias` *Type* (card)
rp_m = re.search(r'^###\s+`related_products`.*?(?=^###|\Z)', service_md, re.MULTILINE | re.DOTALL)
if rp_m:
    for m in re.finditer(
        r'^-\s+`(\w+)`\s+\*([^*]+)\*\s+\((mandatory|optional)\)',
        rp_m.group(0), re.MULTILINE
    ):
        alias     = m.group(1)
        type_label = m.group(2).strip().lower()
        card_label = m.group(3).lower()
        md_props[alias] = {"mandatory": card_label == "mandatory", "is_list": type_label == "list"}

# ── Aliases that appear in Service.md for structural/core reasons ─────────────
MD_STRUCTURAL = {"local_identifier", "entity_type", "related_products"}

# ── Properties exempt from single/list check (e.g. language-map objects) ──────
CARDINALITY_LIST_EXEMPT = {"descriptions"}  # @language container: Object in JSON, [0..N] in RDF

# ── Check A: Ontology properties absent from Service.md ──────────────────────
missing_in_md = sorted(a for a in ont_props if a not in md_props)
if missing_in_md:
    for alias in missing_in_md:
        warnings.append(f"Property '{alias}' in ontology but absent from Service.md")
else:
    print(f"  ✓ All {len(ont_props)} ontology Service properties documented in Service.md")

# ── Check B: Service.md properties absent from ontology ──────────────────────
missing_in_ont = sorted(a for a in md_props if a not in ont_props and a not in MD_STRUCTURAL)
if missing_in_ont:
    for alias in missing_in_ont:
        warnings.append(f"Property '{alias}' in Service.md but absent from ontology cardinality block")
else:
    print(f"  ✓ All {len(md_props)} Service.md properties accounted for in ontology")

# ── Check C: Cardinality consistency ─────────────────────────────────────────
card_ok = 0
for alias in sorted(ont_props):
    if alias not in md_props:
        continue
    ont, md = ont_props[alias], md_props[alias]
    ont_mandatory = ont["min"] >= 1
    ont_list      = ont["max"] is None or ont["max"] > 1
    issues = []
    if ont_mandatory != md["mandatory"]:
        issues.append(
            f"mandatory/optional — ontology: {'mandatory' if ont_mandatory else 'optional'}, "
            f"Service.md: {'mandatory' if md['mandatory'] else 'optional'}"
        )
    if alias not in CARDINALITY_LIST_EXEMPT and ont_list != md["is_list"]:
        issues.append(
            f"single/list — ontology: {'list' if ont_list else 'single'}, "
            f"Service.md: {'list' if md['is_list'] else 'single'}"
        )
    if issues:
        for issue in issues:
            warnings.append(f"Cardinality mismatch '{alias}': {issue}")
    else:
        card_ok += 1

if not any("Cardinality mismatch" in w for w in warnings):
    print(f"  ✓ All {card_ok} cardinalities consistent between ontology and Service.md")

# ── Summary ───────────────────────────────────────────────────────────────────
if warnings:
    print(f"\n  {len(warnings)} Service.md alignment warning(s):")
    for w in warnings:
        print(f"  ⚠ {w}")
PYEOF

ok "Service.md alignment check complete"

# ── Step 4: Generate consolidated spec ───────────────────────────────────────
info "Step 4: Generating consolidated OpenAPI spec"
speakeasy overlay apply \
    -s "$CORE_SPEC" \
    -o "$OVERLAY" \
    > "$CONSOLIDATED" \
    && ok "consolidated-openapi.yaml generated → $CONSOLIDATED" \
    || fail "speakeasy overlay apply failed"

# ── Step 5: Lint core spec ────────────────────────────────────────────────────
info "Step 5: Linting core OpenAPI spec"
npx --yes @stoplight/spectral-cli lint "$CORE_SPEC" \
    --ruleset "$SPECTRAL_RULESET" \
    && ok "Core spec lint passed" \
    || fail "Core spec lint failed — fix errors before continuing"

# ── Step 6: Lint consolidated spec ───────────────────────────────────────────
info "Step 6: Linting consolidated OpenAPI spec"
npx @stoplight/spectral-cli lint "$CONSOLIDATED" \
    --ruleset "$SPECTRAL_RULESET" \
    && ok "Consolidated spec lint passed" \
    || fail "Consolidated spec lint failed"

# ── Step 7: Context compatibility check ──────────────────────────────────────
info "Step 7: Checking JSON-LD context compatibility"

python3 - "$OVERLAY" "$EXT_CTX" "$API_CTX" << 'PYEOF'
import sys, json, re

overlay_path, ext_ctx_path, api_ctx_path = sys.argv[1], sys.argv[2], sys.argv[3]
errors = []

# Validate context files are well-formed JSON
for label, path in [("ext-srv context", ext_ctx_path), ("API context", api_ctx_path)]:
    try:
        json.load(open(path))
        print(f"  ✓ {label} is valid JSON")
    except json.JSONDecodeError as e:
        print(f"  ✗ {label} JSON parse error: {e}", file=sys.stderr)
        sys.exit(1)

# Load ext-srv context declared terms
ext_ctx = json.load(open(ext_ctx_path)).get("@context", {})
declared = set(k for k in ext_ctx if not k.startswith("@") and not k.startswith("_"))

# Extract srv_* property names used in the overlay YAML (simple text scan)
overlay_text = open(overlay_path).read()
used_srv = set(re.findall(r'\bsrv_\w+', overlay_text))

missing = sorted(p for p in used_srv if p not in declared)
if missing:
    for m in missing:
        print(f"  ⚠ '{m}' used in overlay but not declared in ext-srv context")
else:
    print(f"  ✓ All {len(used_srv)} srv_* overlay properties are declared in ext-srv context")

if errors:
    for e in errors:
        print(f"  ✗ {e}", file=sys.stderr)
    sys.exit(1)
PYEOF

ok "Context compatibility check complete"

# ── Step 8: Docker ────────────────────────────────────────────────────────────
if [[ "$START_DOCKER" == false ]]; then
    echo ""
    ok "All checks passed. Skipping docker compose (--no-docker)."
    exit 0
fi

info "Step 8: Starting Docker development stack"

[[ -d "$DOCKER_DIR" ]] || fail "api/Docker/ directory not found — see api/CLAUDE.md for setup"

cp "$CONSOLIDATED" "$DOCKER_DIR/openapi.yaml"
ok "Copied consolidated spec to $DOCKER_DIR/openapi.yaml"
sleep 2   # let Prism detect the spec change and begin reload before we poll

echo "  Starting Prism + FastAPI + Swagger UI..."
echo "  → Prism mock/proxy:  http://localhost:4010"
echo "  → Swagger UI:        http://localhost:8080"
echo ""

cd "$DOCKER_DIR"
docker compose up -d \
    && ok "Containers started (detached)" \
    || fail "docker compose up failed"

# Restart fastapi to ensure it loads the latest app.py from the volume mount.
# uvicorn StatReload can miss changes due to macOS bind-mount cache timing.
docker compose restart fastapi \
    && ok "FastAPI restarted (latest app.py loaded)" \
    || fail "docker compose restart fastapi failed"

echo ""
echo "  Opening container log stream in a new Terminal window..."
osascript - "$DOCKER_DIR" <<'APPLESCRIPT'
on run argv
    set dockerDir to item 1 of argv
    tell application "Terminal"
        do script "echo '── SKG-IF dev stack logs ──' && cd " & quoted form of dockerDir & " && docker compose logs -f"
        activate
    end tell
end run
APPLESCRIPT

ok "Done. Use 'docker compose down' in $DOCKER_DIR to stop."

# ── Step 9: API health checks ────────────────────────────────────────────────
info "Step 9: Waiting for Prism to be ready"

PRISM_URL="http://localhost:4010"
MAX_WAIT=30
for i in $(seq 1 $MAX_WAIT); do
    if curl -s -o /dev/null -w "%{http_code}" "$PRISM_URL/services" | grep -q "^[23]"; then
        ok "Prism is ready (after ${i}s)"
        break
    fi
    if [[ $i -eq $MAX_WAIT ]]; then
        fail "Prism did not become ready after ${MAX_WAIT}s"
    fi
    sleep 1
done

info "Step 9: Running API health checks against $PRISM_URL"

PASS=0; FAIL=0

# Helper: run a curl call, check expected HTTP status, optionally grep response body
api_test() {
    local description="$1"
    local expected_status="$2"
    local url="$3"
    local body_check="${4:-}"   # optional string that must appear in the response body

    local response
    response=$(curl -s -w "\n__STATUS__%{http_code}" "$url") \
        || response=$'\n__STATUS__000'
    local body="${response%$'\n'__STATUS__*}"
    local status="${response##*__STATUS__}"

    local status_ok=false
    local body_ok=true

    [[ "$status" == "$expected_status" ]] && status_ok=true
    if [[ -n "$body_check" ]] && ! echo "$body" | grep -q "$body_check"; then
        body_ok=false
    fi

    if $status_ok && $body_ok; then
        ok "[$status] $description"
        PASS=$((PASS+1))
    else
        local reason=""
        $status_ok || reason+=" status=${status} (expected ${expected_status})"
        $body_ok   || reason+=" missing '${body_check}' in body"
        echo -e "${RED}✗${NC} [$status] $description —$reason"
        FAIL=$((FAIL+1))
    fi
}

# ── /services  (list) ─────────────────────────────────────────────────────────
api_test "GET /services  (all)"                            200 "$PRISM_URL/services"                                                                    "@graph"
api_test "GET /services  page=1 page_size=5"              200 "$PRISM_URL/services?page=1&page_size=5"                                                  "@graph"

# ── /services  attribute filters ─────────────────────────────────────────────
api_test "filter: country:CZ"                             200 "$PRISM_URL/services?filter=country:CZ"                                                   "entity_type"
api_test "filter: name:UDPipe"                            200 "$PRISM_URL/services?filter=name:UDPipe"                                                  "UDPipe"
api_test "filter: identifiers.scheme:handle"              200 "$PRISM_URL/services?filter=identifiers.scheme:handle"                                    "handle"
api_test "filter: identifiers.value (handle URI)"         200 "$PRISM_URL/services?filter=identifiers.value:https://hdl.handle.net/11234/1-4816"        "11234"
api_test "filter: srv_invocation_type:webApplication"     200 "$PRISM_URL/services?filter=srv_invocation_type:sshocinvt:webApplication"                 "entity_type"
api_test "filter: relevant_organisations.name:CLARIN"     200 "$PRISM_URL/services?filter=relevant_organisations.name:CLARIN"                          "entity_type"
api_test "filter: srv_has_research_infrastructure.name"   200 "$PRISM_URL/services?filter=srv_has_research_infrastructure.name:CLARIN%20ERIC"          "entity_type"
api_test "filter: srv_has_hosting_organisation.name"      200 "$PRISM_URL/services?filter=srv_has_hosting_organisation.name:LINDAT"                     "entity_type"
api_test "filter: srv_has_hosting_legal_entity (ROR)"     200 "$PRISM_URL/services?filter=srv_has_hosting_legal_entity.identifiers.scheme:ror,srv_has_hosting_legal_entity.identifiers.value:https://ror.org/024d6js02" "entity_type"

# ── /services  convenience filters ───────────────────────────────────────────
api_test "cf.search.name:UDPipe"                          200 "$PRISM_URL/services?filter=cf.search.name:UDPipe"                                        "UDPipe"
api_test "cf.search.keyword:morphology"                   200 "$PRISM_URL/services?filter=cf.search.keyword:morphology"                                 "entity_type"
api_test "cf.search.org_name:LINDAT"                      200 "$PRISM_URL/services?filter=cf.search.org_name:LINDAT"                                    "entity_type"

# ── /services/{id}  (by identifier) — all local_identifier forms ─────────────
# form 2: plain string resolved via @base (slashes encoded as %2F)
api_test "GET /services/{id}  plain string (handle path)" 200 "$PRISM_URL/services/11234%2F1-4816"                                                                         "local_identifier"
api_test "GET /services/{id}  plain string (ATHENA)"      200 "$PRISM_URL/services/11500%2FATHENA-0000-0000-588F-D"                                                         "local_identifier"
# form 3: on-the-fly plain string (no slashes, resolved via @base)
api_test "GET /services/{id}  on-the-fly identifier"      200 "$PRISM_URL/services/otf___1730027051396___svc-test-1"                                                        "local_identifier"
# form 1: full URL — sandbox (percent-encoded)
api_test "GET /services/{id}  full URL sandbox"           200 "$PRISM_URL/services/https%3A%2F%2Fw3id.org%2Fskg-if%2Fsandbox%2Fclarin-vlo%2F11234%2F1-4816"                "local_identifier"
# form 1: full URL — non-sandbox (OpenCitations URI, srv_1.json)
api_test "GET /services/{id}  full URL non-sandbox"       200 "$PRISM_URL/services/https%3A%2F%2Fw3id.org%2Foc%2Fmeta%2Fra%2F0614010840729"                                "local_identifier"
# 404
api_test "GET /services/{id}  not found → 404"            404 "$PRISM_URL/services/does-not-exist"

# ── summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "  Tests passed: ${GREEN}${PASS}${NC}   Failed: ${RED}${FAIL}${NC}"
[[ $FAIL -eq 0 ]] && ok "All API health checks passed." || fail "${FAIL} API health check(s) failed."
