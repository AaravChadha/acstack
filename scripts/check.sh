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
#   10 verdict-first stance present         11 positive controls (fixtures)
#   12 runtime preamble identity + budget  13 read-only tool declarations
#   14 referral roster == typed-only set        15 conduct block identity
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
# ACSTACK_BANNED_FILE, when set, is authoritative — set-but-missing is a
# SKIP, never a fallback — so harnesses can pin the sweep deterministically.
if [ -n "${ACSTACK_BANNED_FILE:-}" ]; then
  BANNED_FILE="$ACSTACK_BANNED_FILE"
else
  BANNED_FILE=".acstack-banned"
  [ -f "$BANNED_FILE" ] || BANNED_FILE="$HOME/.claude/acstack-banned"
fi
if [ ! -f "$BANNED_FILE" ]; then
  echo "SKIP banned names: no list found (.acstack-banned or ~/.claude/acstack-banned)."
  echo "     Copy .acstack-banned.example and edit it. A missing list is NOT a pass —"
  echo "     nothing was checked."
  skipped=$((skipped + 1))
else
  BANNED="$({ grep -vE '^[[:space:]]*(#|$)' "$BANNED_FILE" || true; } | paste -sd'|' -)"
  if [ -z "$BANNED" ]; then
    echo "SKIP banned names: $BANNED_FILE has no entries — nothing was checked."
    skipped=$((skipped + 1))
  else
    # a malformed entry must fail LOUDLY: grep exit 2 (bad pattern) used to
    # be conflated with exit 1 (clean) and silently disabled the whole sweep.
    rc=0; printf '' | grep -qEi "$BANNED" 2>/dev/null || rc=$?
    if [ "$rc" -ge 2 ]; then
      echo "FAIL banned: $BANNED_FILE contains an invalid regex entry — the sweep CANNOT run"
      fail=1
    else
      rc=0; hits="$(grep -riEnw "$BANNED" \
            skills/ templates/ docs/ scripts/ setup bin/ fixtures/ .github/ \
            CONDUCT.md README.md AGENTS.md PLAN.md JOURNAL.md CHANGELOG.md \
            PRINCIPLES.md CONTRIBUTING.md .acstack-banned.example 2>&1)" || rc=$?
      if [ "$rc" -eq 0 ]; then
        echo "FAIL banned names:"
        printf '%s\n' "$hits"
        fail=1
      elif [ "$rc" -ge 2 ]; then
        echo "FAIL banned: sweep errored rather than matching (rc=$rc):"
        printf '%s\n' "$hits" | head -3
        fail=1
      fi
    fi
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
if hits="$(grep -rnE '^[[:space:]]*(\$[[:space:]]*)?git grep' skills/*/references/*.md 2>/dev/null | grep -E '\\b|\\s')"; then
  echo "FAIL regex: \\b or \\s in a git grep -E command (POSIX ERE lacks both; use -w and [[:space:]])"
  printf '%s\n' "$hits"
  fail=1
fi

# 4. SKILL.md line budget (< 500 per Claude Code guidance).
for f in skills/*/SKILL.md; do
  lines="$(grep -c '' "$f" || true)"   # counts a final unterminated line too; wc -l does not
  if [ "$lines" -ge 500 ]; then
    echo "FAIL budget: $f is $lines lines (limit 500)"
    fail=1
  fi
done

# 5. Shell syntax (+ shellcheck when available).
for s in setup scripts/check.sh scripts/controls.sh docs/guard-matrix.sh bin/acstack-config bin/acstack-update-check bin/acstack-recall; do
  bash -n "$s" || { echo "FAIL syntax: $s"; fail=1; }
done
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning setup scripts/check.sh scripts/controls.sh bin/acstack-config bin/acstack-update-check bin/acstack-recall || fail=1
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
  head_ver="$(grep -m1 -E '^## [0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | awk '{print $2}' || true)"
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
XREF_EXCEPTIONS='doctor|script|api|dev|acstack|sandbox'
#   doctor  — Claude Code's built-in diagnostic, named in /health's lineage note
#   script  — the </script> HTML fragment in /qa's adversarial bank
#   api     — URL path in /secure's exploit-scenario example
#   dev     — /dev/null in documented commands
#   acstack — block-marker close tags (<!-- /acstack:principles -->)
#   sandbox — URL path in /audit's report-template example
for f in skills/*/SKILL.md skills/*/references/*.md; do
  d="$(dirname "$f")"
  case "$d" in */references) sdir="$(dirname "$d")" ;; *) sdir="$d" ;; esac
  # two extraction passes: plain refs (backtick still excluded as a preceding
  # char — `x`/word is a prose separator, not a ref) and code-span refs like
  # `/name`, which the first pass structurally cannot see.
  # A skill reference is /name — never followed by another '/', which is
  # what a filesystem path looks like (#!/usr/bin/env, /etc/hosts). Capture
  # the following character so path-shaped tokens can be dropped.
  # NOTE: `grep -v` exits 1 on no output, and pipefail would kill the whole
  # script silently — the early-death class. The `|| true` is load-bearing.
  toks="$({ { grep -oE '(^|[^A-Za-z0-9_/.`])/[a-z][a-z-]+[/:]?' "$f" || true; grep -oE '`/[a-z][a-z-]+`' "$f" | tr -d '`' || true; } \
    | sed -E 's|^[^/]*/|/|' | grep -v '/$' | sort -u; } || true)"
  while IFS= read -r t; do
    [ -n "$t" ] || continue
    t="${t%:}"   # a colon-suffixed ref is still a ref (only /acstack markers are exempt, via the list)
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
# Scope to THE config table, located by its header — README has other
# tables with backticked first cells (the footprint table), and matching
# on formatting alone made every path in them look like a config key.
if ! grep -q '^| Key | Values' README.md; then
  echo "FAIL config: README has no '| Key | Values' config-table header — the reachability check cannot run"
  fail=1
fi
rows="$({ awk '/^\| Key \| Values/{f=1; next} f && !/^\|/{exit} f' README.md | grep -E '^\|[[:space:]]*`[^/]'; } || true)"
if [ -z "$rows" ] && grep -q '^| Key | Values' README.md; then
  echo "FAIL config: config table found but no key rows parsed — the check would pass vacuously"
  fail=1
fi
while IFS= read -r row; do
  [ -n "$row" ] || continue
  c1="$(printf '%s' "$row" | awk -F'|' '{print $2}')"
  c3="$(printf '%s' "$row" | awk -F'|' '{print $(NF-1)}')"
  keys="$(printf '%s' "$c1" | grep -oE '`[^`]+`' | tr -d '`' || true)"
  if [ -z "$keys" ]; then
    echo "FAIL config: unparseable key cell in README config row: $row"
    fail=1; continue
  fi
  for k in $keys; do
    case "$k" in '##') continue ;; esac   # section-form rows (## Collaborators)
    if [ "$k" = "Collaborators" ]; then
      grep -q '^## Collaborators' templates/acstack.md \
        || { echo "FAIL config: templates/acstack.md lost its '## Collaborators' section"; fail=1; }
      grep -rq 'Collaborators' skills/plan/ \
        || { echo "FAIL config: /plan never mentions Collaborators"; fail=1; }
      continue
    fi
    # key-shaped matches only — a bare substring was satisfied by prose
    # ("pushes" matched the key push), making the guard vacuous.
    grep -qE "(^|[[:space:]])${k}:" templates/acstack.md \
      || { echo "FAIL config: README documents '$k' but templates/acstack.md has no '${k}:' line"; fail=1; }
    for c in $(printf '%s' "$c3" | grep -oE '/[a-z-]+' || true); do
      sdir="skills/${c#/}"
      [ -d "$sdir" ] || { echo "FAIL config: README names consumer $c for '$k' but $sdir/ does not exist"; fail=1; continue; }
      grep -rqE "\`${k}\`|${k}:|<${k}>" "$sdir" \
        || { echo "FAIL config: README says $c consumes '$k' but $sdir/ never names it as \`$k\`, ${k}:, or <${k}>"; fail=1; }
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

# 11. Positive controls: every check-shaped skill's documented detection
#     command is re-run against a seeded fixture (scripts/controls.sh).
#     A pattern edit that stops catching its plant fails HERE, before it
#     ships as a false pass.
if [ -d fixtures ]; then
  if ! ctrl_out="$(bash scripts/controls.sh 2>&1)"; then
    echo "FAIL controls: a documented check missed its seeded plant:"
    printf '%s\n' "$ctrl_out" | grep 'FAIL control'
    fail=1
  fi
else
  echo "FAIL controls: fixtures/ directory missing — the positive-control layer is gone"
  fail=1
fi

# 12. Runtime preamble: marker-fenced block present in every SKILL.md,
#     byte-identical to README's canonical copy, and within the hard line
#     budget. Raising the budget means editing this constant in a visible
#     commit (founding doc trust item 9).
PREAMBLE_BUDGET=12
extract_runtime() {
  awk '/<!-- acstack:runtime -->/{f=1} f{print} /<!-- \/acstack:runtime -->/{f=0}' "$1"
}
rcanon="$(extract_runtime README.md)"
if [ -z "$rcanon" ]; then
  echo "FAIL runtime: README.md has no acstack:runtime block (canonical copy required)"
  fail=1
else
  inner="$(printf '%s\n' "$rcanon" | grep -vc 'acstack:runtime' || true)"
  if [ "${inner:-0}" -gt "$PREAMBLE_BUDGET" ]; then
    echo "FAIL runtime: preamble is $inner lines (budget $PREAMBLE_BUDGET) — raising the budget is a deliberate, visible edit"
    fail=1
  fi
  for f in skills/*/SKILL.md; do
    if ! diff <(printf '%s\n' "$rcanon") <(extract_runtime "$f") >/dev/null; then
      echo "FAIL runtime: $f drifts from (or lacks) README's canonical runtime block"
      fail=1
    fi
  done
fi

# 13. Structurally read-only skills declare a no-write tool set. Their
#     never-writes promise was prose until 2026-07-30; this makes it
#     mechanical. /migrate-check is the template these five copy. /qa is
#     excluded (network shape) and /retro is NOT read-only — it appends to
#     JOURNAL.md and commits (the 2026-07-29 correction).
READONLY_SKILLS="secure health design-audit audit resume migrate-check"
# Commands that write, delete, or publish. A scoped Bash() grant is not
# automatically safe: Bash(rm:*) is every bit as write-capable as Write.
WRITE_CMDS='rm|mv|cp|tee|touch|mkdir|sed -i|git commit|git add|git push|git checkout|git reset|git rm|gh issue create|gh issue edit|gh pr create|>'
for s in $READONLY_SKILLS; do
  f="skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "FAIL readonly: $f is listed as read-only but does not exist"
    fail=1; continue
  fi
  tools="$(sed -n 's/^allowed-tools:[[:space:]]*//p' "$f" | head -1)"
  if [ -z "$tools" ]; then
    echo "FAIL readonly: $f declares no allowed-tools — its read-only promise is prose"
    fail=1; continue
  fi
  case "$tools" in
    *Write*|*Edit*)   # *Edit* already covers NotebookEdit — listing both
                      # is dead code, which shellcheck (SC2222) catches
      echo "FAIL readonly: $f grants a write tool: $tools"; fail=1 ;;
  esac
  # bare Bash, and Bash(*) which is the same grant wearing parentheses
  printf '%s' "$tools" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | grep -qxE 'Bash|Bash\(\*\)' && { echo "FAIL readonly: $f grants unscoped Bash: $tools"; fail=1; }
  # a scoped grant that still writes
  if printf '%s' "$tools" | grep -qE "Bash\((${WRITE_CMDS})"; then
    echo "FAIL readonly: $f grants a write-capable Bash scope: $tools"
    fail=1
  fi
done

# 14. Referral roster: the acstack-referrals table in AGENTS.md must name
#     EXACTLY the skills carrying disable-model-invocation: true. An agent
#     cannot see those skills, so a stale roster is the difference between
#     a discoverable skill and one nobody finds.
# both pipelines end in grep: a no-match exits 1 and, under pipefail,
# would kill the script with ZERO output. The `|| true` is load-bearing.
roster="$({ awk '/BEGIN:acstack-referrals/,/END:acstack-referrals/' AGENTS.md \
  | grep -oE '^\| `/[a-z-]+`' | grep -oE '/[a-z-]+' | sed 's|/||' | sort -u; } || true)"
typed_only="$({ grep -l '^disable-model-invocation:[[:space:]]*true' skills/*/SKILL.md 2>/dev/null \
  | sed -E 's|skills/([^/]+)/SKILL.md|\1|' | sort -u; } || true)"
if [ -z "$roster" ]; then
  echo "FAIL referral: AGENTS.md has no acstack-referrals roster (or it lists no skills)"
  fail=1
elif [ "$roster" != "$typed_only" ]; then
  echo "FAIL referral: roster does not match the typed-only skill set"
  echo "     roster:     $(printf '%s' "$roster" | tr '\n' ' ')"
  echo "     typed-only: $(printf '%s' "$typed_only" | tr '\n' ' ')"
  fail=1
fi

# 15. Conduct block identity. CONDUCT.md is the canonical copy; AGENTS.md
#     embeds it, and /plan seed installs it into adopter repos. /health
#     promises adopters it verifies their copy against the pack's — so the
#     pack's own two copies must agree, or that promise is built on sand.
#     Fifteen guards existed around this file before one guarded the file.
extract_conduct() {
  awk '/<!-- BEGIN:acstack-conduct -->/{f=1} f{print} /<!-- END:acstack-conduct -->/{f=0}' "$1"
}
ccanon="$(extract_conduct CONDUCT.md)"
if [ -z "$ccanon" ]; then
  echo "FAIL conduct: CONDUCT.md has no marker-fenced acstack-conduct block"
  fail=1
elif ! diff <(printf '%s\n' "$ccanon") <(extract_conduct AGENTS.md) >/dev/null; then
  echo "FAIL conduct: AGENTS.md's conduct block drifts from CONDUCT.md's canonical copy"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  if [ "$skipped" -gt 0 ]; then
    echo "check.sh: no failures, but $skipped check(s) SKIPPED — coverage is incomplete"
  else
    echo "check.sh: all clean"
  fi
else
  exit 1
fi
