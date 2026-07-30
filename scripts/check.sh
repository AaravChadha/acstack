#!/usr/bin/env bash
# acstack pack guard — run before committing pack changes (CI runs it too).
# The numbered sections below are the SINGLE enumeration of what this guard
# covers; adding a section means updating this list in the same commit. (The
# list went stale twice while copies lived in README and here separately —
# README now points at this header instead of enumerating.)
#   1  principles-block byte-identity       2  banned personal/client names
#   3  frontmatter safety + strict parse    3b POSIX-ERE hazards in greps
#   4  SKILL.md line budgets                5  shell syntax + shellcheck
#   6  VERSION/CHANGELOG agreement          7  routing lines present
#   8  cross-references + citations resolve 9  config-key reachability
#   10 verdict-first stance present
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"
fail=0
skipped=0

extract_principles() {
  awk '/<!-- acstack:principles -->/{f=1} f{print} /<!-- \/acstack:principles -->/{f=0}' "$1"
}

# 1. Principles block: canonical copy lives in README.md; every SKILL.md
#    must match it byte-for-byte.
canon="$(extract_principles README.md)"
if [ -z "$canon" ]; then
  echo "FAIL principles: README.md has no acstack:principles block (canonical copy required)"
  fail=1
else
  for f in skills/*/SKILL.md; do
    if ! diff <(printf '%s\n' "$canon") <(extract_principles "$f") >/dev/null; then
      echo "FAIL principles: $f drifts from README canonical block"
      fail=1
    fi
  done
fi

# 2. Banned names: client/collaborator/project-specific terms must never
#    appear in pack content. Word-boundary, case-insensitive.
#    The list itself lives OUTSIDE the tracked tree: it names the clients and
#    collaborators being protected, so committing it publishes exactly what it
#    guards. Until 2026-07-29 this script hardcoded a real roster AND excluded
#    scripts/ from its own sweep, so it could never catch itself.
BANNED_FILE="${ACSTACK_BANNED_FILE:-.acstack-banned}"
[ -f "$BANNED_FILE" ] || BANNED_FILE="$HOME/.claude/acstack-banned"
if [ ! -f "$BANNED_FILE" ]; then
  echo "SKIP banned names: no list found (.acstack-banned or ~/.claude/acstack-banned)."
  echo "     Copy .acstack-banned.example and edit it. A missing list is NOT a pass —"
  echo "     nothing was checked."
  skipped=$((skipped + 1))
else
  BANNED="$(grep -vE '^\s*(#|$)' "$BANNED_FILE" | paste -sd'|' -)"
  if [ -z "$BANNED" ]; then
    echo "SKIP banned names: $BANNED_FILE has no entries — nothing was checked."
    skipped=$((skipped + 1))
  elif hits="$(grep -riEnw "$BANNED" \
        skills/ templates/ docs/ scripts/ setup \
        CONDUCT.md README.md AGENTS.md PLAN.md JOURNAL.md 2>/dev/null)"; then
    echo "FAIL banned names:"
    printf '%s\n' "$hits"
    fail=1
  fi
fi

# 3. Frontmatter safety. An unquoted YAML scalar ends at " #" (comment) and
#    is ambiguous at ": ". /ship shipped truncated at "wiring Fixes #N",
#    losing its whole trigger sentence. Every rule here is covered by the
#    matrix in docs/guard-matrix.sh — extend that FIRST, then this.
for f in skills/*/SKILL.md; do
  dir="$(basename "$(dirname "$f")")"
  # normalize CRLF, then take only the frontmatter block (between the first
  # two --- lines). Anything outside it is body text, not frontmatter.
  fm="$(tr -d '\r' < "$f" | awk 'NR==1 && $0!="---"{exit} NR==1{next} /^---$/{exit} {print}')"
  if [ -z "$fm" ]; then
    echo "FAIL frontmatter: $f has no --- delimited frontmatter block"
    fail=1; continue
  fi

  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1 | sed 's/[[:space:]]*$//')"
  [ "$name" = "$dir" ] || { echo "FAIL frontmatter: $f declares name '$name' but lives in skills/$dir/"; fail=1; }

  descs="$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p')"
  if [ -z "$descs" ]; then
    echo "FAIL frontmatter: $f has no description"
    fail=1; continue
  fi

  # check EVERY description line, not just the first — a hazard on a second
  # one was a real false negative when this used `head -1`.
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    case "$d" in
      '"'*)
        printf '%s' "$d" | grep -qE '^"([^"\\]|\\.)*"[[:space:]]*(#.*)?$' \
          || { echo "FAIL description: $f has an unterminated double-quoted description"; fail=1; }
        continue ;;
      "'"*)
        printf '%s' "$d" | grep -qE "^'([^']|'')*'[[:space:]]*(#.*)?\$" \
          || { echo "FAIL description: $f has an unterminated single-quoted description"; fail=1; }
        continue ;;
      '#'*)
        echo "FAIL description: $f starts with '#' — YAML reads the value as null"
        fail=1; continue ;;
    esac
    printf '%s' "$d" | grep -q ' #' && { echo "FAIL description: $f has an unquoted ' #' — YAML truncates it into a comment"; fail=1; }
    printf '%s' "$d" | grep -q ': '  && { echo "FAIL description: $f has an unquoted ': ' — quote the description"; fail=1; }
  done <<EOF
$descs
EOF

  # strict parse: every frontmatter line is a known key (the whole block
  # must survive into the live skill listing, not just the description).
  unknown="$(printf '%s\n' "$fm" | grep -vE '^(name|description|argument-hint|allowed-tools|disable-model-invocation):' | grep -vE '^[[:space:]]*$' || true)"
  if [ -n "$unknown" ]; then
    echo "FAIL frontmatter: $f has unknown or malformed frontmatter line(s): $(printf '%s' "$unknown" | head -1)"
    fail=1
  fi
done

# 3b. POSIX-ERE hazards in documented grep commands. `git grep -E` does not
#     support \b (matches nothing, silently) or \s (parses as literal 's').
#     Both shipped in reference files and made /design-audit's and /secure's
#     primary checks report clean on dirty input.
if hits="$(grep -rnE '^[[:space:]]*git grep' skills/*/references/*.md 2>/dev/null | grep -E '\\b|\\s')"; then
  echo "FAIL regex: \\b or \\s in a git grep -E command (POSIX ERE lacks both; use -w and [[:space:]])"
  printf '%s\n' "$hits"
  fail=1
fi

# 4. SKILL.md line budget (< 500 per Claude Code guidance).
for f in skills/*/SKILL.md; do
  lines="$(wc -l < "$f" | tr -d ' ')"
  if [ "$lines" -ge 500 ]; then
    echo "FAIL budget: $f is $lines lines (limit 500)"
    fail=1
  fi
done

# 5. Shell syntax (+ shellcheck when available).
for s in setup scripts/check.sh; do
  bash -n "$s" || { echo "FAIL syntax: $s"; fail=1; }
done
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning setup scripts/check.sh || fail=1
fi

# 6. VERSION / CHANGELOG agreement. VERSION is one bare semver line and must
#    equal the first versioned heading in CHANGELOG.md (dated or "unreleased").
if [ ! -f VERSION ] || ! grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' VERSION; then
  echo "FAIL version: VERSION missing or not a single bare semver line"
  fail=1
elif [ ! -f CHANGELOG.md ]; then
  echo "FAIL version: CHANGELOG.md missing (VERSION exists without its record)"
  fail=1
else
  ver="$(tr -d '[:space:]' < VERSION)"
  head_ver="$(grep -m1 -E '^## [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | awk '{print $2}')"
  if [ "$ver" != "$head_ver" ]; then
    echo "FAIL version: VERSION is $ver but CHANGELOG.md's first versioned heading is ${head_ver:-absent}"
    fail=1
  fi
fi

# 7. Routing line: every skill names its neighbors (five wave-1 skills
#    shipped without one for two waves).
for f in skills/*/SKILL.md; do
  grep -q 'Adjacent skills:' "$f" || { echo "FAIL routing: $f has no 'Adjacent skills:' line"; fail=1; }
done

# 8. Cross-references resolve. Three forms:
#    8a  /skill-name tokens name real skills/ dirs (or the exception list);
#    8b  bare references/<file> citations exist under the citing skill;
#    8c  ../ citations resolve from the citing file (the ONLY portable
#        cross-skill form — installs symlink every skill dir side by side,
#        so ../../<skill>/references/… resolves there too);
#    plus: repo-root-relative skills/<x>/references/ citations are
#    themselves a failure — they resolve in this repo but not on installs.
XREF_EXCEPTIONS='doctor|script|api|dev'
#   doctor — Claude Code's built-in diagnostic, named in /health's lineage note
#   script — the </script> HTML fragment in /qa's adversarial bank
#   api    — URL path in /secure's exploit-scenario example
#   dev    — /dev/null in documented commands
for f in skills/*/SKILL.md skills/*/references/*.md; do
  d="$(dirname "$f")"
  case "$d" in */references) sdir="$(dirname "$d")" ;; *) sdir="$d" ;; esac
  toks="$(grep -oE '(^|[^A-Za-z0-9_/.`])/[a-z][a-z-]+:?' "$f" | sed -E 's|^[^/]*/|/|' | sort -u || true)"
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    case "$t" in *:) continue ;; esac   # HTML markers like <!-- /acstack:principles -->
    name="${t#/}"
    printf '%s' "$name" | grep -qE "^($XREF_EXCEPTIONS)$" && continue
    [ -d "skills/$name" ] || { echo "FAIL crossref: $f references $t but skills/$name/ does not exist"; fail=1; }
  done <<EOF
$toks
EOF
  for r in $(grep -ohE '(^|[^./])references/[A-Za-z0-9._-]+\.(md|sh)' "$f" | sed -E 's|^[^r]*r|r|' | grep -E '^references/' | sort -u); do
    [ -f "$sdir/$r" ] || { echo "FAIL crossref: $f cites $r but $sdir/$r does not exist"; fail=1; }
  done
  for r in $(grep -ohE '\.\./[A-Za-z0-9._/-]+\.(md|sh)' "$f" | sort -u); do
    [ -f "$d/$r" ] || { echo "FAIL crossref: $f cites $r but it does not resolve from $d/"; fail=1; }
  done
done
if hits="$(grep -rnE 'skills/[a-z-]+/references/' skills/ 2>/dev/null)"; then
  echo "FAIL crossref: repo-root-relative citation — use ../ or ../../ so installs resolve:"
  printf '%s\n' "$hits"
  fail=1
fi

# 9. Config-key reachability: every key in README's config table appears in
#    templates/acstack.md AND is read by each /skill the table names.
rows="$(grep -E '^\|[[:space:]]*`[^/]' README.md || true)"
while IFS= read -r row; do
  [ -n "$row" ] || continue
  c1="$(printf '%s' "$row" | awk -F'|' '{print $2}')"
  c3="$(printf '%s' "$row" | awk -F'|' '{print $(NF-1)}')"
  keys="$(printf '%s' "$c1" | grep -oE '`[^`]+`' | tr -d '`')"
  for k in $keys; do
    case "$k" in '##') continue ;; esac   # section-form rows (## Collaborators)
    grep -q -- "$k" templates/acstack.md \
      || { echo "FAIL config: README documents '$k' but templates/acstack.md never mentions it"; fail=1; }
    for c in $(printf '%s' "$c3" | grep -oE '/[a-z-]+' || true); do
      sdir="skills/${c#/}"
      [ -d "$sdir" ] || { echo "FAIL config: README names consumer $c for '$k' but $sdir/ does not exist"; fail=1; continue; }
      grep -rq -- "$k" "$sdir" \
        || { echo "FAIL config: README says $c consumes '$k' but nothing in $sdir/ mentions it"; fail=1; }
    done
  done
done <<EOF
$rows
EOF

# 10. Verdict-first stance present in every report-shaped skill (five of
#     them violated the pack's own stance while it was documented nowhere
#     mechanical). Enumerated list — update it when a report skill lands.
REPORT_SKILLS="audit challenge design-audit health migrate-check plan-review qa resume retro secure triage"
for s in $REPORT_SKILLS; do
  grep -qi 'verdict' "skills/$s/SKILL.md" \
    || { echo "FAIL verdict: skills/$s/SKILL.md never states its verdict stance"; fail=1; }
done

if [ "$fail" -eq 0 ]; then
  if [ "$skipped" -gt 0 ]; then
    echo "check.sh: no failures, but $skipped check(s) SKIPPED — coverage is incomplete"
  else
    echo "check.sh: all clean"
  fi
else
  exit 1
fi
