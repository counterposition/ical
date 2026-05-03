#!/bin/sh

if out=$(go vet ./... 2>&1); then
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  printf '%s' "$out" | jq -Rs '{decision:"block",reason:("go vet failed:\n"+.)}' && exit 0
fi

printf '%s\n' '{"decision":"block","reason":"go vet failed; run go vet ./... for details. jq is not installed, so the hook could not include full output."}'
