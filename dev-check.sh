#!/usr/bin/env bash
# dev-check.sh — SKG-IF local development check and run
#
# 1. Generate consolidated OpenAPI spec (core + ext-srv service overlay)
# 2. Lint core and consolidated specs with Spectral
# 3. Check ext-srv context file compatibility (all srv_* properties declared)
# 4. Copy consolidated spec to api/Docker/ and start the development stack
#
# Usage:
#   ./dev-check.sh              # run all steps including docker compose up
#   ./dev-check.sh --no-docker  # run checks only, skip docker compose up
#   ./dev-check.sh --check-only # same as --no-docker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API_DIR="$(cd "$SCRIPT_DIR/../api" && pwd)"

CORE_SPEC="$API_DIR/openapi/ver/current/skg-if-openapi.yaml"
OVERLAY="$SCRIPT_DIR/api/ver/current/service-overlay.yaml"
#CONSOLIDATED="$API_DIR/consolidated-openapi.yaml"
CONSOLIDATED="$SCRIPT_DIR/consolidated-openapi.yaml"
CORE_CTX="$API_DIR/openapi/ver/current/context/skg-if-api.json"
EXT_CTX="$SCRIPT_DIR/context/ver/current/skg-if.json"
SPECTRAL_RULESET="$API_DIR/.spectral.yaml"
#DOCKER_DIR="$API_DIR/Docker"
DOCKER_DIR="$SCRIPT_DIR/api/Docker"

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

[[ -f "$CORE_SPEC"   ]] || fail "Core spec not found: $CORE_SPEC"
[[ -f "$OVERLAY"     ]] || fail "Service overlay not found: $OVERLAY"
[[ -f "$CORE_CTX"    ]] || fail "Core context not found: $CORE_CTX"
[[ -f "$EXT_CTX"     ]] || fail "Ext-srv context not found: $EXT_CTX"

command -v speakeasy &>/dev/null || fail "'speakeasy' not found — install from https://www.speakeasy.com"
command -v npx       &>/dev/null || fail "'npx' not found — install Node.js"
command -v python3   &>/dev/null || fail "'python3' not found"
ok "All prerequisites met"

# ── Step 1: Generate consolidated spec ───────────────────────────────────────
info "Step 1: Generating consolidated OpenAPI spec"
speakeasy overlay apply \
    -s "$CORE_SPEC" \
    -o "$OVERLAY" \
    > "$CONSOLIDATED" \
    && ok "consolidated-openapi.yaml generated → $CONSOLIDATED" \
    || fail "speakeasy overlay apply failed"

# ── Step 2: Lint core spec ────────────────────────────────────────────────────
info "Step 2: Linting core OpenAPI spec"
npx --yes @stoplight/spectral-cli lint "$CORE_SPEC" \
    --ruleset "$SPECTRAL_RULESET" \
    && ok "Core spec lint passed" \
    || fail "Core spec lint failed — fix errors before continuing"

# ── Step 3: Lint consolidated spec ───────────────────────────────────────────
info "Step 3: Linting consolidated OpenAPI spec"
npx @stoplight/spectral-cli lint "$CONSOLIDATED" \
    --ruleset "$SPECTRAL_RULESET" \
    && ok "Consolidated spec lint passed" \
    || fail "Consolidated spec lint failed"

# ── Step 4: Context compatibility check ──────────────────────────────────────
info "Step 4: Checking JSON-LD context compatibility"

python3 - "$OVERLAY" "$EXT_CTX" "$CORE_CTX" << 'PYEOF'
import sys, json, re

overlay_path, ext_ctx_path, core_ctx_path = sys.argv[1], sys.argv[2], sys.argv[3]
errors = []
warnings = []

# Validate context files are well-formed JSON
for label, path in [("ext-srv context", ext_ctx_path), ("core API context", core_ctx_path)]:
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

# ── Step 5: Docker ────────────────────────────────────────────────────────────
if [[ "$START_DOCKER" == false ]]; then
    echo ""
    ok "All checks passed. Skipping docker compose (--no-docker)."
    exit 0
fi

info "Step 5: Starting Docker development stack"

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

# ── Step 6: API smoke tests ───────────────────────────────────────────────────
info "Step 6: Waiting for Prism to be ready"

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

info "Step 6: Running API smoke tests against $PRISM_URL"

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
[[ $FAIL -eq 0 ]] && ok "All API smoke tests passed." || fail "${FAIL} smoke test(s) failed."
