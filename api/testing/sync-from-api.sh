#!/usr/bin/env bash
# sync-from-api.sh
# Compares files in ext-srv/api/testing against their source in the sibling api repo.
#
# [SYNC]     files are boilerplate — can be auto-copied with --apply
# [DIVERGED] files have intentional local changes — always shown as diff, never auto-copied
#
# Usage:
#   ./sync-from-api.sh           # show status of all tracked files
#   ./sync-from-api.sh --apply   # copy changed [SYNC] files from api repo
#   ./sync-from-api.sh --diff    # also show full diff for changed [SYNC] files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$(realpath "$SCRIPT_DIR/../../../api")"

APPLY=false
SHOW_DIFF=false
for arg in "$@"; do
  case $arg in
    --apply) APPLY=true ;;
    --diff)  SHOW_DIFF=true ;;
  esac
done

if [ ! -d "$API_DIR" ]; then
  echo "ERROR: api repo not found at $API_DIR"
  exit 1
fi

changed=0
diverged=0

check() {
  local mode="$1"    # SYNC or DIVERGED
  local label="$2"   # display name
  local src="$3"     # path relative to API_DIR
  local dst="$4"     # path relative to SCRIPT_DIR

  local src_full="$API_DIR/$src"
  local dst_full="$SCRIPT_DIR/$dst"

  if [ ! -f "$src_full" ]; then
    printf "  %-12s %s\n" "[MISSING]" "$label  (not found in api: $src)"
    return
  fi

  if [ ! -f "$dst_full" ]; then
    printf "  %-12s %s\n" "[NEW]" "$label  (present in api, missing here)"
    if [ "$mode" = "SYNC" ] && [ "$APPLY" = true ]; then
      cp "$src_full" "$dst_full"
      echo "               → copied"
    fi
    changed=$((changed + 1))
    return
  fi

  if diff -q "$src_full" "$dst_full" > /dev/null 2>&1; then
    printf "  %-12s %s\n" "[ok]" "$label"
  elif [ "$mode" = "SYNC" ]; then
    printf "  %-12s %s\n" "[CHANGED]" "$label  ← upstream has changes"
    changed=$((changed + 1))
    if [ "$SHOW_DIFF" = true ]; then
      diff --color=always "$dst_full" "$src_full" || true
    fi
    if [ "$APPLY" = true ]; then
      cp "$src_full" "$dst_full"
      echo "               → copied"
    fi
  else
    printf "  %-12s %s\n" "[DIVERGED]" "$label  ← review manually (diff below)"
    diverged=$((diverged + 1))
    diff --color=always "$dst_full" "$src_full" || true
  fi
}

echo ""
echo "api repo: $API_DIR"
echo ""
echo "── docker_build/ boilerplate (auto-syncable with --apply) ──────────────────"
check SYNC     "Dockerfile"        "openapi/docker_build/Dockerfile"       "docker_build/Dockerfile"
check SYNC     ".python-version"   "openapi/docker_build/.python-version"  "docker_build/.python-version"
check SYNC     "pyproject.toml"    "openapi/docker_build/pyproject.toml"   "docker_build/pyproject.toml"
check SYNC     "uv.lock"           "openapi/docker_build/uv.lock"          "docker_build/uv.lock"
check SYNC     "base_query.py"     "openapi/docker_build/base_query.py"    "docker_build/base_query.py"

echo ""
echo "── diverged files (manual merge required) ───────────────────────────────────"
check DIVERGED "docker_build/app.py"  "openapi/docker_build/app.py"  "docker_build/app.py"
echo "   (review any ext-srv specific filter changes)"
echo ""
check DIVERGED "docker-compose.yml"   "Docker/docker-compose.yml"    "docker-compose.yml"
echo "   (ext-srv change: app.py mount is ./docker_build/app.py, not ../openapi/docker_build/app.py)"

echo ""
if [ "$changed" -gt 0 ] && [ "$APPLY" = false ]; then
  echo "$changed changed SYNC file(s). Run with --apply to update."
fi
if [ "$diverged" -gt 0 ]; then
  echo "$diverged diverged file(s) require manual review."
fi
if [ "$changed" -eq 0 ] && [ "$diverged" -eq 0 ]; then
  echo "All files match upstream."
fi
echo ""
