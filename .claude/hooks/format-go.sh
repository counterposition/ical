#!/bin/sh

if ! command -v jq >/dev/null 2>&1; then
  echo "Claude hook: jq not found; skipping Go formatting" >&2
  exit 0
fi

file_path=$(jq -r '.tool_input.file_path // empty')
if [ -z "$file_path" ] || [ "${file_path##*.}" != "go" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

if command -v goimports >/dev/null 2>&1; then
  goimports -w "$file_path"
elif command -v gofmt >/dev/null 2>&1; then
  echo "Claude hook: goimports not found; falling back to gofmt" >&2
  gofmt -w "$file_path"
else
  echo "Claude hook: neither goimports nor gofmt found; skipping Go formatting" >&2
fi
