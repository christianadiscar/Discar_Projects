#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

status=0

echo "[check] Package.swift swift-tools-version"
first_line="$(head -n 1 Package.swift || true)"
if [[ "$first_line" != "// swift-tools-version: 5.9" ]]; then
  echo "ERROR: Package.swift first line must be '// swift-tools-version: 5.9'"
  status=1
fi

extra_tools_lines=$(rg -n "swift-tools-version:" Package.swift | wc -l | tr -d ' ')
if [[ "$extra_tools_lines" != "1" ]]; then
  echo "ERROR: Package.swift should contain exactly one swift-tools-version declaration (found $extra_tools_lines)"
  status=1
fi

echo "[check] macOS/iOS deployment targets"
if ! rg -q "\.iOS\(\.v17\)" Package.swift; then
  echo "ERROR: Expected iOS target .v17 in Package.swift"
  status=1
fi
if ! rg -q "\.macOS\(\.v13\)" Package.swift; then
  echo "ERROR: Expected macOS target .v13 in Package.swift"
  status=1
fi

echo "[check] no macOS 14-only Observation macros"
if rg -n "@Bindable|@Observable" Sources/MovePlannerApp >/dev/null; then
  echo "ERROR: Found @Bindable/@Observable in Sources/MovePlannerApp; use ObservableObject + EnvironmentObject for Xcode 15/macOS 13"
  status=1
fi

echo "[check] expected state management exists"
if ! rg -q "@StateObject private var store" Sources/MovePlannerApp/MovePlannerApp.swift; then
  echo "ERROR: MovePlannerApp.swift should use @StateObject for store"
  status=1
fi
if ! rg -q "@EnvironmentObject private var store" Sources/MovePlannerApp/ContentView.swift; then
  echo "ERROR: ContentView.swift should use @EnvironmentObject store"
  status=1
fi

if [[ "$status" -eq 0 ]]; then
  echo "Preflight passed ✅"
else
  echo "Preflight failed ❌"
fi

exit "$status"
