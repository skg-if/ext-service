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

echo "  Starting Prism + FastAPI + Swagger UI..."
echo "  → Prism mock/proxy:  http://localhost:4010"
echo "  → Swagger UI:        http://localhost:8080"
echo "  Press Ctrl+C to stop."
echo ""

cd "$DOCKER_DIR"
docker compose up
