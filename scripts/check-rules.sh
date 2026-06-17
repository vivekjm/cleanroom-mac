#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES="$ROOT/data/cleanup-rules.tsv"

[[ -f "$RULES" ]] || { printf 'missing rule catalog: %s\n' "$RULES" >&2; exit 1; }

awk -F '\t' '
  NR == 1 {
    if ($0 != "id\tcategory\tsafety\tdefault\topt_in\tpaths\tdescription") {
      print "invalid rule catalog header" > "/dev/stderr"
      exit 1
    }
    next
  }
  NF != 7 {
    printf "invalid field count on line %d: expected 7, got %d\n", NR, NF > "/dev/stderr"
    exit 1
  }
  $1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" || $6 == "" || $7 == "" {
    printf "empty field on line %d\n", NR > "/dev/stderr"
    exit 1
  }
  $4 != "yes" && $4 != "no" {
    printf "invalid default value on line %d: %s\n", NR, $4 > "/dev/stderr"
    exit 1
  }
  END {
    if (NR < 2) {
      print "rule catalog has no rules" > "/dev/stderr"
      exit 1
    }
  }
' "$RULES"

printf 'rule catalog ok\n'
