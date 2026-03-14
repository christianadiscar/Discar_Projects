#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

status=0

if command -v rg >/dev/null 2>&1; then
  SEARCH_BIN="rg"
else
  SEARCH_BIN="grep"
  echo "WARN: 'rg' (ripgrep) not found; falling back to grep."
fi

match_count() {
  local pattern="$1"
  local file="$2"
  if [[ "$SEARCH_BIN" == "rg" ]]; then
    rg -n "$pattern" "$file" | wc -l | tr -d ' '
  else
    grep -nE "$pattern" "$file" | wc -l | tr -d ' '
  fi
}

has_match() {
  local pattern="$1"
  shift
  if [[ "$SEARCH_BIN" == "rg" ]]; then
    rg -q "$pattern" "$@"
  else
    grep -qE "$pattern" "$@"
  fi
}

echo "[check] Package.swift swift-tools-version"
first_line="$(head -n 1 Package.swift || true)"
if [[ "$first_line" != "// swift-tools-version: 5.9" ]]; then
  echo "ERROR: Package.swift first line must be '// swift-tools-version: 5.9'"
  status=1
fi

extra_tools_lines=$(match_count "swift-tools-version:" Package.swift)
if [[ "$extra_tools_lines" != "1" ]]; then
  echo "ERROR: Package.swift should contain exactly one swift-tools-version declaration (found $extra_tools_lines)"
  status=1
fi

echo "[check] macOS/iOS deployment targets"
if ! has_match "\.iOS\(\.v17\)" Package.swift; then
  echo "ERROR: Expected iOS target .v17 in Package.swift"
  status=1
fi
if ! has_match "\.macOS\(\.v13\)" Package.swift; then
  echo "ERROR: Expected macOS target .v13 in Package.swift"
  status=1
fi

echo "[check] no macOS 14-only Observation macros"
if has_match "@Bindable|@Observable" Sources/MovePlannerApp/*.swift; then
  echo "ERROR: Found @Bindable/@Observable in Sources/MovePlannerApp; use ObservableObject + EnvironmentObject for Xcode 15/macOS 13"
  status=1
fi

echo "[check] expected state management exists"
if ! has_match "@StateObject private var store" Sources/MovePlannerApp/MovePlannerApp.swift; then
  echo "ERROR: MovePlannerApp.swift should use @StateObject for store"
  status=1
fi
if ! has_match "@EnvironmentObject private var store" Sources/MovePlannerApp/ContentView.swift; then
  echo "ERROR: ContentView.swift should use @EnvironmentObject store"
  status=1
fi

if [[ "$status" -eq 0 ]]; then
  echo "Preflight passed ✅"
else
  echo "Preflight failed ❌"
fi

exit "$status"
