#!/usr/bin/env bash
# acstack pack guard — run before committing pack changes (CI runs it too).
# The numbered sections below are the SINGLE enumeration of what this guard
# covers; adding a section means updating this list in the same commit. (The
# list went stale twice while copies lived in README and here separately —
# README now points at this header instead of enumerating.)
#   1  principles-block byte-identity       2  banned personal/client names
#   3  frontmatter safety + strict parse    3b POSIX-ERE hazards in greps
#   3c git-grep drop carries grep fallback  4  SKILL.md line budgets
#   5  shell syntax + shellcheck
#   6  VERSION/CHANGELOG agreement          7  routing lines present
#   8  cross-references + citations resolve 9  config-key reachability
#   10 verdict-first stance present         11 positive controls (fixtures)
#   12 runtime preamble identity + budget  13 read-only tool declarations
#   13a no read-only claim escapes §13     14 referral roster == typed-only set
#   15 conduct block identity              16 retired commit-format guarded
#   17 simplicity ladder keeps its floor   18 update msg re-links, not just pull
#   19 /refactor keeps its proof rule
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"
fail=0
skipped=0
WORKTMP_RO="$(mktemp)"; trap 'rm -f "$WORKTMP_RO"' EXIT

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
#     Backreferences are the same class and worse: \1 is an INVALID ESCAPE in
#     ERE, so the grep errors out and matches nothing at all. Added 2026-08-03
#     after a \1 shipped in test-audit-rules.md — its positive control caught
#     it, but the hazard guard above had not.
if hits="$(grep -rnE '^[[:space:]]*(\$[[:space:]]*)?git grep' skills/*/references/*.md 2>/dev/null | grep -E '\\[1-9]')"; then
  echo "FAIL regex: backreference (\\1-\\9) in a git grep -E command — POSIX ERE has none; the grep errors out and matches NOTHING"
  printf '%s\n' "$hits"
  fail=1
fi

# 3c. A skill that forbids shell `git grep` (its patterns dropped to the
#     read-only Grep tool, post-RCE) MUST also give the Grep-tool-absent
#     fallback — plain `grep -rnE`. Without it, a harness with no Grep tool
#     degrades to the exact `git grep` form the fix removed; the 2026-08-03
#     live shakedown watched /health do precisely that.
for f in $(grep -rl 'grants no shell' skills/*/SKILL.md skills/*/references/*.md 2>/dev/null || true); do
  grep -q 'grep -rnE' "$f" \
    || { echo "FAIL grep-fallback: $f forbids shell git grep but states no Grep-tool-absent fallback (grep -rnE)"; fail=1; }
done

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
REPORT_SKILLS="audit challenge design-audit health migrate-check plan-review qa resume retro secure triage why"
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

# 13. Structurally read-only skills declare a no-write tool set.
#     ALLOWLIST, not a denylist, and the allowlist is the AUDITED UNION of what
#     the six skills actually grant — not a plausible-looking set of read-only-
#     sounding commands. A denylist was tried and failed twice: it missed
#     `find`/`awk`/`git config`, and the very commit that added those introduced
#     `sed -n` — which writes, because `sed -n -i ''` is valid and prefix grants
#     permit any command STARTING with the string. A later audit named 18 more
#     misses. A denylist cannot be finished; an allowlist can be reviewed — so it
#     must actually BE reviewed. The 2026-08-03 falsification round found the
#     first allowlist never had been: it carried sort/uniq/git show/git
#     symbolic-ref (all write/mutate under free args) as UNUSED entries, now
#     removed. Adding an entry is a deliberate edit — confirm it accepts NO write
#     under any argument suffix first. Two parsing bugs were closed the same day:
#     the final comma-token was dropped unvalidated (`printf '%s'` left it
#     unterminated so `read` skipped it), and a second `allowed-tools:` line hid
#     grants from `head -1`.
#
#     KNOWN RESIDUAL, deliberately accepted (2026-08-03, narrowed same day).
#     `git log` and `git diff` accept `--output=FILE`, which overwrites any path,
#     and no read-only tool shows history or diffs a range — so the skills that
#     need them keep the grant and this guard certifies "declares only commands
#     whose DOCUMENTED use is read-only", NOT "cannot write under any argument".
#     Two sharper holes were CLOSED, not accepted: `git grep` (whose `-O<pager>`
#     runs an arbitrary program) was dropped from all four skills that had it —
#     they apply their patterns with the read-only Grep tool now (the /health
#     find/awk→Read/Glob precedent), so it is off this allowlist entirely; and
#     `gh auth status` was narrowed to an exact grant (no `:*`) so `--show-token`
#     cannot be appended to print a live token.
READONLY_SKILLS="secure health design-audit audit resume migrate-check why"
SAFE_TOOLS="Read|Grep|Glob"
# Audited union of Bash grants across the six skills above (2026-08-03). Every
# entry read-only in its DOCUMENTED use; the git log/diff residual above is the
# accepted exception, not an oversight. git grep is deliberately ABSENT — it is
# applied through the Grep tool, not shell.
SAFE_BASH="cat|ls|wc|grep|diff|readlink|command -v|git log|git diff|git status|git ls-files|git rev-parse|git check-ignore|git remote get-url|gh auth status|gh issue list|gh label list|gh pr view|gh pr diff|npx prisma migrate status"
for s_ in $READONLY_SKILLS; do
  f="skills/$s_/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "FAIL readonly: $f is listed as read-only but does not exist"
    fail=1; continue
  fi
  # A second allowed-tools: line would hide grants from the head -1 below, and
  # a real YAML loader honors the last duplicate key, not the first — so the
  # form check.sh inspects would not be the form Claude Code consumes.
  if [ "$(grep -c '^allowed-tools:' "$f")" -gt 1 ]; then
    echo "FAIL readonly: $f has more than one allowed-tools: line — only the first is enforced; merge them"
    fail=1; continue
  fi
  tools="$(sed -n 's/^allowed-tools:[[:space:]]*//p' "$f" | head -1)"
  if [ -z "$tools" ]; then
    echo "FAIL readonly: $f declares no allowed-tools — its read-only promise is prose"
    fail=1; continue
  fi
  # printf '%s\n' (NOT '%s'): without the trailing newline the final comma-field
  # arrives at `read` unterminated, `read` returns false, and the loop never
  # validates the LAST tool in the list. Every skill's last grant went unchecked.
  printf '%s\n' "$tools" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | while IFS= read -r t; do
    [ -n "$t" ] || continue
    case "$t" in
      Bash\(*\)) cmd="${t#Bash(}"; cmd="${cmd%)}"; cmd="${cmd%:\*}"
        printf '%s' "$cmd" | grep -qxE "$SAFE_BASH" \
          || echo "FAIL readonly: $f grants Bash($cmd) — not on the read-only allowlist"
        ;;
      *) printf '%s' "$t" | grep -qxE "$SAFE_TOOLS" \
          || echo "FAIL readonly: $f grants '$t' — not on the read-only allowlist" ;;
    esac
  done > "$WORKTMP_RO" 2>/dev/null || true
  if [ -s "$WORKTMP_RO" ]; then cat "$WORKTMP_RO"; fail=1; fi
done

# 13a. Forcing function: any skill that declares a no-write allowed-tools set is
#      claiming structural read-only capability and MUST be in READONLY_SKILLS,
#      so the loop above checks its grants against the allowlist. Otherwise a new
#      read-only skill silently escapes §13 — the denylist-can't-be-finished
#      problem one level up, at skill enumeration instead of command names.
#      Derive-and-diff, the same shape §14 uses for the referral roster.
#      Skills with NO allowed-tools line (/qa, /plan, /challenge, …) default to
#      all tools and make no structural claim — out of scope here; their conduct
#      promises bind them instead. A writer that declares Write/Edit is likewise
#      not a read-only declarer.
declared_ro="$({ for f in skills/*/SKILL.md; do
    at="$(sed -n 's/^allowed-tools:[[:space:]]*//p' "$f" | head -1)"
    [ -n "$at" ] || continue
    printf '%s' "$at" | grep -qwE 'Write|Edit|NotebookEdit' && continue
    basename "$(dirname "$f")"
  done | sort -u; } || true)"
want_ro="$(printf '%s\n' $READONLY_SKILLS | sort -u)"
if [ "$declared_ro" != "$want_ro" ]; then
  echo "FAIL readonly: skills declaring a no-write allowed-tools set != READONLY_SKILLS"
  echo "     declared no-write: $(printf '%s' "$declared_ro" | tr '\n' ' ')"
  echo "     READONLY_SKILLS:   $(printf '%s' "$want_ro" | tr '\n' ' ')"
  fail=1
fi

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

# 16. Retired subtask-commit-format must not reappear as the CURRENT format.
#     The 2026-07-29 verdict (task 4.16) switched the default to
#     `task <n>: <desc>` / `ticket #<n>: <desc>`; "a decision recorded but never
#     emitted" is exactly the class this guards. Matches only the default/example
#     forms — README's demo transcript carries a real old-format commit subject,
#     and /retro's history-detection pattern keeps the bare old string on
#     purpose, so neither is a match here.
if hits="$(grep -En 'completed task <number>|completed task 3\.2\.1' \
      README.md CONDUCT.md AGENTS.md skills/*/SKILL.md \
      bin/acstack-config templates/acstack.md 2>/dev/null)"; then
  echo "FAIL commit-format: retired 'completed task' form still documented as the current format:"
  printf '%s\n' "$hits"
  fail=1
fi

# 17. The simplicity ladder keeps its safety floor (task 4.40). A "write less
#     code" rule with no floor is how validation, error handling, security,
#     and accessibility get trimmed as padding — the one failure mode the
#     source material (ponytail) explicitly warns against. Couple them: if the
#     ladder is documented, the never-cut clause must be documented too.
if grep -q 'simplicity ladder' skills/do/SKILL.md; then
  for term in validation 'error handling' security accessibility; do
    grep -qi "$term" skills/do/SKILL.md \
      || { echo "FAIL ladder: /do documents the simplicity ladder but its never-cut floor lost '$term'"; fail=1; }
  done
fi

# 19. /refactor keeps its proof rule. The skill's entire value is "green
#     before, green after, SAME COUNT" plus never editing a test to force
#     green. Trim either and it becomes "refactor and hope" while still
#     reading like a safety skill — the same floor-erosion class as §17.
if [ -f skills/refactor/SKILL.md ]; then
  grep -qi 'same test count\|same count' skills/refactor/SKILL.md \
    || { echo "FAIL refactor: /refactor no longer states the same-test-count rule — its proof is gone"; fail=1; }
  grep -qiE 'never (delete|edit|change|fix).{0,40}test|fix the code, never the test' skills/refactor/SKILL.md \
    || { echo "FAIL refactor: /refactor lost its never-edit-a-test-to-go-green rule"; fail=1; }
fi

# 18. The update instruction must re-link, not just pull. A pull that adds a
#     skill leaves it unlinked and therefore invisible — /why shipped on
#     2026-08-03 and no user or model could invoke it. `pull` alone is an
#     incomplete instruction, and the incompleteness is silent.
if ! grep -q 'setup' bin/acstack-update-check; then
  echo "FAIL update-msg: bin/acstack-update-check tells the user to pull without re-running setup — a new skill would stay unlinked and invisible"
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
