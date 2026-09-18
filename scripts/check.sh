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
#   19 /refactor keeps its proof rule      20 /design keeps its 8-item spine
#   21 skill-hygiene rule set stays whole  22 grader case flag named at every site
#   23 marked counts match derivations    24 eval isolation named at every site
#   25 owed-markers name a live carrier   26 no mode section left without a procedure
#   27 plugin manifests agree with pack  28 startup description budget
#   29 conditional-branch waste per skill  30 unsupplied-section rule has one home
#   31 never-guess rule stays unconditional  32 deny set has one canonical home
#   33 READONLY_SKILLS states its own size    34 commit subjects match the 3 shapes
#   35 near-term open tasks state a done-condition
#   36 /learn sighting trail is a list   37 PLAN.md identifiers are unique
#   38 class-D skills state the scope of their verdict
#   39 CI shard partition covers every matrix case
#   40 PLAN.md headings match a known shape
#   41 /audit's target roster agrees in all three places
#   42 /verify's verdict set stays exhaustive
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

  # DUPLICATE KEYS. A YAML parser takes the LAST value for a repeated key;
  # the `name` read above takes the FIRST (`head -1`). So two `name:` lines
  # let this guard validate a value the host never sees — the pack's own
  # "verify the consumed form, not the authored form" rule, broken by the
  # guard that exists to enforce it. Reproduced 2026-09-16 (external review):
  # the guard read `tc` while PyYAML read `wrong`, and check.sh exited 0.
  # The fix is NOT to replicate YAML's precedence — a guard that reimplements
  # a parser is a second parser to keep in sync. It is to refuse the
  # ambiguity: a key appears at most once, so first and last are the same
  # line and there is nothing to disagree about.
  # `description` is EXCLUDED on purpose: the loop above checks EVERY
  # description line, so for that key the guard is stricter than the parser
  # (it can over-report, never under-report) and the matrix case that seeds a
  # hazard on a second description line must keep failing for ITS reason.
  dupkeys="$(printf '%s\n' "$fm" | sed -n 's/^\([a-z][a-z-]*\):.*/\1/p' | grep -v '^description$' | sort | uniq -d || true)"
  if [ -n "$dupkeys" ]; then
    echo "FAIL frontmatter: $f repeats frontmatter key(s): $(printf '%s' "$dupkeys" | tr '\n' ' ')— a YAML parser takes the LAST value and this guard reads the FIRST, so the value checked is not the value served"
    fail=1
  fi

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

# 5. Shell syntax (+ shellcheck when available). SCOPE IS DERIVED, NOT LISTED
#    (4.82): scripts/shell-sources.sh enumerates every tracked shell source,
#    and CI's shellcheck step reads the same script. Until 2026-08-16 three
#    rosters lived here and in check.yml and no two agreed — 7 files got
#    `bash -n`, 6 got shellcheck, and four scripts were linted by nothing.
shell_sources="$(bash scripts/shell-sources.sh)"
if [ -z "$shell_sources" ]; then
  echo "FAIL syntax: scripts/shell-sources.sh returned no files — the derivation is broken"
  fail=1
fi
while IFS= read -r s; do
  [ -n "$s" ] || continue
  bash -n "$s" || { echo "FAIL syntax: $s"; fail=1; }
done <<< "$shell_sources"
if command -v shellcheck >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  if ! shellcheck -S warning $shell_sources; then
    echo "FAIL syntax: shellcheck reported findings in the derived shell set (listed above)"
    fail=1
  fi
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
  # EXTENSION SCOPE (4.55c, 2026-08-08). Both loops below match ANY
  # extension (`\.[A-Za-z0-9]+`), not a named list. They matched `(md|sh)`
  # until a `.py` citation was found dead in the field:
  # skills/ship/SKILL.md cited `references/regression-gate.py`, which
  # resolves under skills/ship/ where no such file exists — invisible for
  # as long as it shipped, purely because of the extension. A named list is
  # a denylist wearing an allowlist's clothes: it silently passes every
  # extension nobody thought of (the §13 ruling). An extension is still
  # REQUIRED, so prose like "the references/ directory" is not a citation.
  for r in $(grep -ohE '(^|[^./])references/[A-Za-z0-9._-]+\.[A-Za-z0-9]+' "$f" | sed -E 's|^[^r]*r|r|' | grep -E '^references/' | sort -u); do
    [ -f "$sdir/$r" ] || { echo "FAIL crossref: $f cites $r but $sdir/$r does not exist"; fail=1; }
  done
  for r in $(grep -ohE '\.\./[A-Za-z0-9._/-]+\.[A-Za-z0-9]+' "$f" | sort -u); do
    [ -f "$d/$r" ] || { echo "FAIL crossref: $f cites $r but it does not resolve from $d/"; fail=1; }
  done
done
if hits="$(grep -rnE 'skills/[a-z-]+/references/' skills/ 2>/dev/null)"; then
  echo "FAIL crossref: repo-root-relative citation — use ../ or ../../ so installs resolve:"
  printf '%s\n' "$hits"
  fail=1
fi
#    8d  a `../` path inside a FENCED block of a reference file. Those blocks are
#        templates that get emitted into the adopter's own repo, where a
#        pack-relative path resolves to nothing. §8 above cannot catch this: the
#        path is valid IN SITU (it resolves from the skill directory) and only
#        breaks in the copy. Shipped in two templates until shakedown 9 —
#        /eval-spec's and /audit's — so every adopter's eval/spec.md carried a
#        dead link. Name the source descriptively in emitted text instead.
awk '
  /^[[:space:]]*```/ { infence = !infence; next }
  infence && /\.\.\// { printf "%s:%d: %s\n", FILENAME, FNR, $0 }
' skills/*/references/*.md > "$WORKTMP_RO" 2>/dev/null || true
if [ -s "$WORKTMP_RO" ]; then
  echo "FAIL crossref: pack-relative path inside an emitted template block — it will not resolve in the adopter's copy:"
  cat "$WORKTMP_RO"
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
#     mechanical).
#     MEMBERSHIP IS DERIVED, NOT LISTED (5.4). This was a hardcoded roster of
#     twelve names, and it under-counted on the very commit that added
#     /verify — a skill whose description literally returns four verdicts and
#     whose report shape is "Verdict on the first line". That is the
#     under-counts-silently-the-day-a-name-appears class the pack has already
#     recorded. A skill is report-shaped when its own SKILL.md carries a
#     `## Report shape` section or promises a verdict in its description;
#     both are the skill's own words, so a new one enrols itself.
# The historical roster is a FLOOR, not the definition. Deriving alone was
# measured narrower than the list it replaced — it dropped audit,
# design-audit, resume, retro and triage, which carry a verdict stance
# without saying "verdict" in their description or heading. Shrinking the
# checked set while claiming to widen it is the same silent under-count one
# layer down, so the two are unioned: the floor cannot regress, and a new
# skill enrols itself without anyone remembering.
REPORT_FLOOR="audit challenge design-audit health migrate-check plan-review qa resume retro secure triage why"
REPORT_SKILLS="$REPORT_FLOOR"
for f in skills/*/SKILL.md; do
  s_="$(basename "$(dirname "$f")")"
  case " $REPORT_SKILLS " in *" $s_ "*) continue ;; esac
  if grep -qE '^## Report shape' "$f" \
     || awk '/^description:/{print; exit}' "$f" | grep -qiE 'verdict|GO/NO-GO|GO or NO-GO'; then
    REPORT_SKILLS="$REPORT_SKILLS $s_"
  fi
done
for s in $REPORT_SKILLS; do
  grep -qi 'verdict' "skills/$s/SKILL.md" \
    || { echo "FAIL verdict: skills/$s/SKILL.md never states its verdict stance"; fail=1; }
done
# The derivation must not collapse to nothing: an empty roster would pass
# this section silently, which is the failure it exists to prevent.
rs_n=0; for s in $REPORT_SKILLS; do rs_n=$((rs_n + 1)); done
rf_n=0; for s in $REPORT_FLOOR; do rf_n=$((rf_n + 1)); done
if [ "$rs_n" -lt "$rf_n" ]; then
  echo "FAIL verdict: $rs_n report-shaped skill(s) checked, below the floor of $rf_n — the set shrank, which is the under-count this derivation replaced"
  fail=1
fi

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
#     the 9 read-only skills actually grant — not a plausible-looking set of read-only-
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
#
#     THE PREAMBLE IS OUTSIDE THIS CERTIFICATION (stated 2026-08-04, task 4.41).
#     The marker-fenced runtime block every skill carries runs `readlink`,
#     `dirname`, and the three `bin/acstack-*` helpers — none of which any skill
#     grants, because a grant cannot name a path resolved at run time. Two
#     consequences, both accepted rather than hidden: under a strict permission
#     harness a skill may prompt for its own preamble (it degrades to markdown
#     on any refusal, so nothing breaks), and `acstack-update-check` WRITES
#     `~/.acstack/update-stamp` AND runs `git fetch` inside the PACK repo,
#     writing its `.git/FETCH_HEAD` (observed live 2026-08-04) — so "read-only"
#     describes what a skill does to the PROJECT it is pointed at, not a claim
#     that the pack touches nothing on the machine. Note the consequence for
#     sandboxed work: a session told "do not touch <pack>" cannot honour that
#     while running any skill, short of `runtime: off`.
#     That stamp is the pack's only machine-local state and is documented as
#     such. This section certifies the declared tool set; it does not and cannot
#     certify the preamble.
READONLY_SKILLS="secure health design-audit audit resume migrate-check why contract-check deps"
SAFE_TOOLS="Read|Grep|Glob"
# Audited union of Bash grants across the 9 read-only skills above (2026-08-03). Every
# entry read-only in its DOCUMENTED use; the git log/diff residual above is the
# accepted exception, not an oversight. git grep is deliberately ABSENT — it is
# applied through the Grep tool, not shell.
# `npm view` added 2026-08-17 for /deps' maintenance check: it queries the
# registry and prints metadata, installing nothing and writing nothing. Network
# reads were ALREADY in this union — gh auth status, gh issue list, gh label
# list, gh pr view, gh pr diff — so this adds no new class of capability, only
# a non-GitHub registry. Recorded because widening a security allowlist should
# never be a silent side effect of building a skill.
# `git for-each-ref` and `gh pr list` added 2026-09-16 for /resume's claim
# check (5.17.5): the first lists refs and has no mutating flag at all; the
# second is the same class as `gh issue list`, already here. No new class of
# capability — a ref listing and a GitHub read.
SAFE_BASH="cat|ls|wc|grep|diff|readlink|command -v|git log|git diff|git status|git ls-files|git rev-parse|git check-ignore|git remote get-url|gh auth status|gh issue list|gh label list|gh pr view|gh pr diff|npx prisma migrate status|npm view|git for-each-ref|gh pr list"
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

# 21. The skill-hygiene rule set (4.28) stays whole. Five rules across five
#     skills, landed in one commit because they are one rule set — and the
#     failure mode is a later edit quietly dropping one, leaving the pack
#     inconsistent about what it will and will not report. Each rule earns
#     its place by SUPPRESSING noise, so its absence is invisible in a green
#     run: nothing fails, the reports just get worse.
hyg_rule() { # file pattern description
  grep -qi "$2" "$1" \
    || { echo "FAIL hygiene: $3 (4.28's rule set is incomplete)"; fail=1; }
}
[ -f skills/audit/references/code-report-template.md ] && \
  hyg_rule skills/audit/references/code-report-template.md 'Do NOT flag these' \
    "/audit lost its do-not-flag blocklist"
[ -f skills/audit/SKILL.md ] && \
  hyg_rule skills/audit/SKILL.md 'need the pass at all' \
    "/audit lost its does-this-need-the-pass triage opener"
[ -f skills/qa/SKILL.md ] && \
  hyg_rule skills/qa/SKILL.md 'need the pass at all' \
    "/qa lost its does-this-need-the-pass triage opener"
[ -f skills/secure/SKILL.md ] && \
  hyg_rule skills/secure/SKILL.md 'never deletes' \
    "/secure lost the rule that a written justification DEMOTES a finding rather than dropping it"
[ -f skills/ship/references/ship-gates.md ] && \
  hyg_rule skills/ship/references/ship-gates.md 'One comment per issue' \
    "/ship lost one-comment-per-issue"
[ -f skills/do/SKILL.md ] && \
  hyg_rule skills/do/SKILL.md 'NOT sufficient' \
    "/do lost the claim/requires/not-sufficient evidence table"

# 20. /design keeps its production-readiness spine. The skill's whole claim is
#     that it produces production-grade UI rather than a pretty mockup, and
#     that claim rests on two things: all EIGHT items, and the rule that a
#     style dial can never lower the floor. Trim either and it silently
#     becomes the style-matching skill 4.30 exists not to be — the same
#     floor-erosion class as §17 and §19.
if [ -f skills/design/SKILL.md ]; then
  # Match the BOLDED list form, not the bare words: the frontmatter
  # description names most of these too, so a loose grep stays green while
  # the body item is gone. (Caught by its own fail-first probe, 2026-08-04.)
  for item in 'States, all of them' 'Real content' 'Responsive behaviour' 'Accessibility floor' \
              'Interaction feel' 'Theming' 'Performance-shaped choices' 'UX writing'; do
    grep -q "\*\*$item" skills/design/SKILL.md \
      || { echo "FAIL design: /design lost production-readiness item '$item' — seven of eight is a mockup generator"; fail=1; }
  done
  grep -qi 'never lower the floor' skills/design/SKILL.md \
    || { echo "FAIL design: /design lost the rule that a style dial cannot lower the production-readiness floor"; fail=1; }
  grep -qi 'rollback' skills/design/SKILL.md \
    || { echo "FAIL design: /design lost the optimistic/rollback requirement — the item a demo always skips"; fail=1; }
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

# 22. Grader case flag named at every site. Exact-grade normalization is
#     defined in four places: grader-rules.md (canonical), the spec template,
#     /eval-run's grading rules, and the runner template. Shakedown 10 found
#     them disagreeing — the spec template documented a per-case
#     `case_sensitive: true` flag while both /eval-run sites folded case
#     unconditionally, so a runner scaffolded verbatim from the template
#     silently ignored a flag the spec documents. All four must name the
#     flag; dropping it from one is invisible in a green run — nothing
#     fails, the scaffolds just grade against the spec. Same floor-erosion
#     class as §17/§19/§21. Token-presence only, stated honestly: a site
#     can keep the token while inverting the meaning (the runner template's
#     CODE block did exactly that on this check's first day, caught by a
#     falsification review, not by this grep) — semantic agreement belongs
#     to review rounds; this check makes silent DROP loud, nothing more.
for f in \
  skills/eval-spec/references/grader-rules.md \
  skills/eval-spec/references/eval-spec-template.md \
  skills/eval-run/SKILL.md \
  skills/eval-run/references/runner-template.md; do
  if [ -f "$f" ]; then
    grep -q 'case_sensitive' "$f" \
      || { echo "FAIL grader-case: $f defines exact-grade behavior but never names the case_sensitive flag — the four grader sites have diverged"; fail=1; }
  else
    echo "FAIL grader-case: $f is missing — the grader-site agreement check cannot run"; fail=1
  fi
done

# 23. Marked count claims agree with their derivations. A count duplicated
#     outside its single enumeration goes stale: this repo produced six
#     instances in three days, and /audit docs — which has carried "stale
#     counts vs greppable reality" since it shipped — never once ran,
#     because nobody types it without already suspecting drift. The one
#     implementation lives in scripts/count-check.sh; controls.sh runs the
#     SAME script against seeded fixtures, so a regressed comparison fails
#     there rather than reporting clean here. HONEST SCOPE: marked claims
#     only. A clean run means every marked count agrees with its
#     derivation, NEVER that these documents have no stale numbers — which
#     is why the verified list is printed rather than swallowed.
if [ -f scripts/count-check.sh ]; then
  # No arguments = the contracted set. The roster and the reason for every
  # inclusion and exclusion live in count-check.sh, which is where the guard
  # is read; passing the list here made it an unstated contract (4.55b).
  if cnt_out="$(bash scripts/count-check.sh 2>&1)"; then
    printf '%s\n' "$cnt_out"
  else
    printf '%s\n' "$cnt_out"
    fail=1
  fi
else
  echo "FAIL count: scripts/count-check.sh is missing — every marked count is unverified"
  fail=1
fi

# 24. Eval-runner isolation named at every site. An eval that runs the
#     subject through the operator's own agent configuration measures the
#     operator, not the subject — and it lands hardest in the BASELINE arm,
#     where ambient config can make a candidate look better or worse than
#     it is. The rule has to hold across three files that are edited
#     separately; the failure mode is a later edit dropping it from ONE,
#     which is invisible in a green run because nothing errors and the
#     numbers just quietly stop meaning what they claim. controls.sh
#     proves the documented FLAGS still catch a seeded unisolated runner;
#     this proves the rule is still stated where a reader would meet it.
for f in \
  skills/eval-spec/references/eval-spec-template.md \
  skills/eval-run/SKILL.md \
  skills/eval-run/references/runner-template.md; do
  if [ ! -f "$f" ]; then
    echo "FAIL eval-isolation: $f is missing — the isolation-site agreement check cannot run"; fail=1; continue
  fi
  grep -qiE 'isolat' "$f" \
    || { echo "FAIL eval-isolation: $f no longer names runner isolation — an eval site dropped the rule"; fail=1; }
  grep -qiE 'pin' "$f" \
    || { echo "FAIL eval-isolation: $f no longer names the subject-model pin — an unpinned eval is not comparable"; fail=1; }
done
# Same shape, second rule (4.46): the per-category non-regression floor is
# stated where the spec is written, where the eval is run, and where the
# ship gate decides. Dropping it from one leaves a release gate that reads
# one aggregate — which a run can lift while a category collapses.
for f in \
  skills/eval-spec/references/eval-spec-template.md \
  skills/eval-run/SKILL.md \
  skills/ship/SKILL.md; do
  if [ ! -f "$f" ]; then
    echo "FAIL eval-isolation: $f is missing — the non-regression site check cannot run"; fail=1; continue
  fi
  # Anchored on `non-regression`, not a bare `regress`. The looser pattern
  # was tried first and was WEAK: every site also names `regression-gate.py`,
  # so a mutation that deleted the rule statement still matched the tool's
  # filename and the seeded defect passed. Same weak-pattern class the
  # matrix caught on 4.19 and again on 4.47.
  grep -qiE 'non-regression' "$f" \
    || { echo "FAIL eval-isolation: $f no longer states the per-category non-regression floor — a release gate reading one aggregate"; fail=1; }
done

# 25. Owed-markers name a live carrier. AGENTS.md's third verification rule
#     has been broken three times and caught by hand every time — most
#     recently b566654's regression debt, written as owed in two places with
#     no open task carrying it. `[owed: N.NN]` must name a task that EXISTS
#     and is OPEN; `[owed: declined — reason]` must carry an actual reason.
#     scripts/reach-check.sh holds the one implementation and controls.sh
#     runs the SAME script against seeded fixtures. HONEST SCOPE: marked
#     obligations only — unmarked "this owes X" prose is invisible here, a
#     limit measured rather than assumed (see the script's header for the
#     rejected bare-numeric approach and its six false positives).
if [ -f scripts/reach-check.sh ]; then
  if reach_out="$(bash scripts/reach-check.sh PLAN.md JOURNAL.md AGENTS.md 2>&1)"; then
    printf '%s\n' "$reach_out"
  else
    printf '%s\n' "$reach_out"
    fail=1
  fi
else
  echo "FAIL reach: scripts/reach-check.sh is missing — owed-markers are unverified"
  fail=1
fi

# 26. No mode section left without a procedure (4.49). Progressive
#     disclosure moves a mode's body into references/ and leaves a pointer.
#     Two ways that goes wrong. A pointer citing a file that does not exist
#     is ALREADY caught by section 8 (crossref) — verified 2026-08-06 by
#     seeding one, so this section deliberately does not duplicate it. The
#     shape section 8 CANNOT see is the silent one: a `## Mode:` heading
#     whose body was moved out and whose pointer was then dropped, leaving
#     a heading that cites nothing and says nothing. That passed every
#     other check on a seeded run — the skill still loads, the section
#     still renders, and it simply stops knowing how to do one thing. A
#     mode section must therefore either cite a reference or carry a real
#     body; five content lines is the floor, since a pointer is four.
while IFS= read -r hit; do
  [ -n "$hit" ] || { continue; }
  echo "FAIL modesection: $hit"
  fail=1
done < <(
  for f in skills/*/SKILL.md; do
    awk -v F="$f" '
      /^## /{
        if (h != "" && h ~ /^## (Mode|Target)/ && cite == 0 && body < 5)
          printf "%s: section %s cites no reference and carries no procedure (%d content lines) — a split stranded this mode\n", F, h, body
        h=$0; body=0; cite=0; next
      }
      { if ($0 ~ /references\/[A-Za-z0-9._-]+\.md/) cite=1
        if ($0 ~ /[^[:space:]]/) body++ }
      END{
        if (h != "" && h ~ /^## (Mode|Target)/ && cite == 0 && body < 5)
          printf "%s: section %s cites no reference and carries no procedure (%d content lines) — a split stranded this mode\n", F, h, body
      }
    ' "$f"
  done
)

# 27. Plugin manifests agree with the pack (4.57). The plugin path is a
#     SECOND install route, and a second route that silently rots is worse
#     than none — an adopter installs a version that does not exist. These
#     are the three facts that can drift without anyone noticing, since
#     nothing else in the tree reads .claude-plugin/.
if [ ! -f .claude-plugin/plugin.json ]; then
  # Absence used to be silence: this whole section ran only `if` the file
  # existed, so deleting the manifest — which removes the plugin install
  # route entirely — left check.sh green (external review, 2026-09-16). A
  # missing manifest is the loudest version of the drift this section
  # polices, not an exemption from it.
  echo "FAIL plugin: .claude-plugin/plugin.json is missing — the plugin install route is gone, and this section's checks silently did not run"
  fail=1
fi
if [ -f .claude-plugin/plugin.json ]; then
  pv="$(grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' .claude-plugin/plugin.json | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
  rv="$(tr -d '[:space:]' < VERSION 2>/dev/null)"
  if [ "$pv" != "$rv" ]; then
    echo "FAIL plugin: .claude-plugin/plugin.json says version $pv but VERSION says $rv"
    fail=1
  fi
  pn="$(grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]+"' .claude-plugin/plugin.json | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
  # the entry's name lives INSIDE "plugins"; a positional grab picks the
  # owner's name instead — which is exactly what the first draft did.
  mn="$(sed -n '/"plugins"/,$p' .claude-plugin/marketplace.json 2>/dev/null | grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
  if [ -n "$mn" ] && [ "$pn" != "$mn" ]; then
    echo "FAIL plugin: plugin.json name '$pn' and marketplace.json entry '$mn' disagree — install resolves neither"
    fail=1
  fi
  # the declared skills root must exist, or every skill silently vanishes
  for sp in $(grep -oE '"\./[A-Za-z0-9_/-]*"' .claude-plugin/plugin.json | tr -d '"'); do
    [ -e "$sp" ] || { echo "FAIL plugin: plugin.json declares skills path $sp which does not exist"; fail=1; }
  done
fi

# 28. Startup description budget (4.59). Every skill's `description:` is
#     loaded at EVERY session start, for every user, whether or not anything
#     is invoked. It is the only budget in this pack that grows
#     MONOTONICALLY, and it was unguarded until 2026-08-08 — while 4.49 spent
#     a task optimising a body budget that sat at 212 lines against a 500
#     cap, i.e. with 60% headroom. Caps are decided in PLAN, not here.
#     TOTAL RAISED 12000 -> 13500 by PLAN 5.7 (2026-09-08); per-description
#     stays 600, unchanged since 4.59. The basis is what GOOD folding of the
#     remaining roadmap costs, derived from observed rates: /board absorbing
#     six wave-6 tasks as lenses at the measured /audit rate (496 chars for
#     five targets), /skill standalone, and wave 7 folded once rather than
#     four-into-one — 2156 total, plus 333 for estimate error.
#     THE CAP IS STILL BELOW WHAT THE ROADMAP COSTS UNFOLDED (15444 if every
#     planned skill shipped as its own skill), which is the point: 4.59's
#     mode-first ruling stands and this still forces ~1944 chars of folding.
#     5.7 raised it because the old number had begun forcing BAD folds --
#     jamming /deploy, /incident, /document and /cost into one skill to
#     satisfy arithmetic -- not because it bound. Chars, not tokens: chars
#     are deterministic.
BUDGET_TOTAL=13500
BUDGET_ONE=600
desc_tot=0
for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  dl="$(awk '/^description:[[:space:]]/{s=$0; sub(/^description:[[:space:]]*/,"",s); print length(s); exit}' "$f")"
  if [ -z "$dl" ]; then
    echo "FAIL budget: $f has no single-line description: — the startup cost cannot be measured"
    fail=1; continue
  fi
  desc_tot=$((desc_tot + dl))
  if [ "$dl" -gt "$BUDGET_ONE" ]; then
    echo "FAIL budget: $f description is $dl chars (cap $BUDGET_ONE) — one description must not eat the shared startup budget"
    fail=1
  fi
done
if [ "$desc_tot" -gt "$BUDGET_TOTAL" ]; then
  echo "FAIL budget: skill descriptions total $desc_tot chars (cap $BUDGET_TOTAL, ~$((desc_tot/4)) tokens loaded at EVERY session start)"
  echo "             Adding a skill is not free. Make it a mode of an existing skill, or trim."
  fail=1
fi

# 29. Conditional-branch waste (4.61). 4.49 shortlisted split candidates by
#     SIZE, corrected its criterion mid-task, and never regenerated the list
#     — so /audit at 68% conditional was never examined while two skills with
#     ZERO conditional content were measured and declined. The scan is a
#     script precisely so that cannot recur, and it is run HERE because a
#     threshold nothing enforces is decoration (4.59's lesson, one task old).
#     Threshold and its derivation live in the script.
if [ -x scripts/conditional-ratio.sh ] || [ -f scripts/conditional-ratio.sh ]; then
  if ratio_out="$(bash scripts/conditional-ratio.sh 2>&1)"; then
    if printf '%s' "$ratio_out" | grep -q 'OVER'; then
      echo "FAIL ratio: a skill wastes more conditional content per invocation than the threshold allows:"
      printf '%s\n' "$ratio_out" | grep 'OVER'
      echo "            Split it into references/, or record a reason in PLAN.md and raise the threshold deliberately."
      fail=1
    fi
  else
    echo "FAIL ratio: scripts/conditional-ratio.sh did not run"
    fail=1
  fi
fi

# 30. The unsupplied-section rule has exactly ONE home (4.68). mode-seed.md
#     and brief-template.md each carried half of it and the halves
#     disagreed — the procedure said write `TBD — not supplied at seed
#     time`, the template said record "none known yet" instead of omitting
#     the section. A session reaches the template THROUGH the procedure
#     (mode-seed.md cites it), so it reads both and gets two instructions
#     for one field; shakedown 15 watched a live run follow the template.
#     Same class as 4.52, where two files shipped contradictory grading
#     rules and every multi-keyword expected was mis-graded. The canonical
#     site must hold BOTH states; the template must hold NEITHER and point
#     instead. Token-presence only, stated honestly (as §22): this makes a
#     silent RE-STATEMENT loud, and cannot prove the two agree in meaning.
seed_ms=skills/plan/references/mode-seed.md
seed_bt=skills/plan/references/brief-template.md
if [ -f "$seed_ms" ] && [ -f "$seed_bt" ]; then
  for tok in 'TBD — not supplied at seed time' 'none known yet'; do
    grep -qF "$tok" "$seed_ms" \
      || { echo "FAIL seed-rule: $seed_ms no longer states '$tok' — the canonical unsupplied-section rule must carry BOTH states, or the template's half becomes load-bearing again"; fail=1; }
    grep -qF "$tok" "$seed_bt" \
      && { echo "FAIL seed-rule: $seed_bt restates '$tok' — it must point at mode-seed.md, not carry a second copy that can drift (4.68)"; fail=1; }
  done
  grep -qF 'mode-seed.md' "$seed_bt" \
    || { echo "FAIL seed-rule: $seed_bt does not cite mode-seed.md — a pointer that stops pointing is how the two halves diverged"; fail=1; }
else
  echo "FAIL seed-rule: $seed_ms or $seed_bt is missing — the unsupplied-section agreement check cannot run"; fail=1
fi

# 31. The never-guess rule stays UNCONDITIONAL (4.67). It shipped nested
#     inside mode-seed.md's "when nobody can answer" paragraph, so a
#     headless run that decided the branch did not apply to it took the
#     never-guess rule out of scope too — and invented a volume, a cadence
#     and a domain landmine, the last being the field the rule names as
#     costliest to fabricate. Position IS the contract here: a rule that
#     binds on every path must be read before the branch that does not.
#     Same floor-erosion class as §17/§19/§21/§22, and checked the only way
#     prose position can be — by line order. It cannot prove the rule is
#     obeyed; only that it has not been re-nested.
if [ -f "$seed_ms" ]; then
  ng="$(grep -nEi 'never (guess|invent)' "$seed_ms" | head -1 | cut -d: -f1)"
  br="$(grep -nF 'Unsupplied sections' "$seed_ms" | head -1 | cut -d: -f1)"
  if [ -z "$ng" ]; then
    echo "FAIL never-guess: $seed_ms no longer states a never-guess rule at all (4.67)"; fail=1
  elif [ -z "$br" ]; then
    echo "FAIL never-guess: $seed_ms no longer has the 'Unsupplied sections' block — §30 and §31 are both anchored on it"; fail=1
  elif [ "$ng" -ge "$br" ]; then
    echo "FAIL never-guess: $seed_ms states never-guess at line $ng, AFTER the unsupplied-sections block at line $br — it has been re-nested inside the branch it escaped in 4.67"; fail=1
  fi
  grep -qF 'every path through this mode' "$seed_ms" \
    || { echo "FAIL never-guess: $seed_ms no longer says the rule binds on every path — without that clause a reader re-scopes it to one branch (4.67)"; fail=1; }
  grep -qEi 'deriving is not guessing' "$seed_ms" \
    || { echo "FAIL never-guess: $seed_ms dropped the deriving-is-not-guessing carve-out — suppressing landmines read out of the source is a regression, not a fix (4.67)"; fail=1; }
fi

# 32. Irreversible-act deny set has ONE canonical home (4.76). README is
#     canonical; /health carries a byte-identical copy, so the row it reports
#     names exactly the entries a reader was told to paste. Same shape as §1.
#     WHAT THIS DOES NOT CERTIFY: that the entries protect anything. 4.66's
#     arm F watched `sh -c`, `bash -c` and a script file walk straight through
#     every one of them. This guard checks two lists agree, nothing more — and
#     the second half below exists so the honest framing cannot be dropped
#     while the list stays in sync.
extract_denyset() {
  awk '/<!-- acstack:deny-set -->/{f=1} f{print} /<!-- \/acstack:deny-set -->/{f=0}' "$1"
}
ds_canon="$(extract_denyset README.md)"
ds_health="$(extract_denyset skills/health/SKILL.md)"
if [ -z "$ds_canon" ]; then
  echo "FAIL deny-set: README.md has no acstack:deny-set block (canonical copy required, 4.76)"
  fail=1
elif [ -z "$ds_health" ]; then
  echo "FAIL deny-set: skills/health/SKILL.md has no acstack:deny-set block — /health cannot report on a set it does not carry (4.76)"
  fail=1
elif ! diff <(printf '%s\n' "$ds_canon") <(printf '%s\n' "$ds_health") >/dev/null; then
  echo "FAIL deny-set: skills/health/SKILL.md drifts from README's canonical deny set — /health would report on entries the README never told anyone to paste (4.76)"
  fail=1
fi
if [ -n "$ds_health" ]; then
  # Flattened AND squeezed: this phrase wraps in the source, and a line-wise
  # grep for it silently reported a missing declaration while it was present —
  # the third time in this repo a wrapped phrase defeated a control.
  health_flat="$(tr '\n' ' ' < skills/health/SKILL.md | tr -s ' ')"
  case "$health_flat" in
    *"never counts toward the issue total"*) : ;;
    *) echo "FAIL deny-set: /health's deny-set row no longer declares itself verdict-free — a pass here certifies a safety property a denylist cannot deliver (4.76)"; fail=1 ;;
  esac
fi

# 33. READONLY_SKILLS's stated size matches the list (4.78). /why was enrolled
#     2026-08-03 and both comments above the list kept saying "six" about a
#     list of seven for eleven days, through every audit in between — a stale
#     set-claim sitting inside the comment that certifies the read-only
#     allowlist, which is exactly the class AGENTS.md's "a claim about a set
#     enumerates the set" rule exists for. The claims are written as DIGITS so
#     they are machine-readable; the count of claims is asserted too, so
#     adding a third one silently is also a failure.
ro_n="$(echo "$READONLY_SKILLS" | wc -w | tr -d ' ')"
ro_claims="$(grep -oE 'the [0-9]+ read-only skills' scripts/check.sh | grep -oE '[0-9]+' || true)"
ro_seen=0
for c in $ro_claims; do
  ro_seen=$((ro_seen + 1))
  if [ "$c" -ne "$ro_n" ]; then
    echo "FAIL readonly-count: a comment claims '$c read-only skills' but READONLY_SKILLS lists $ro_n — the set claim went stale (4.78)"
    fail=1
  fi
done
if [ "$ro_seen" -ne 2 ]; then
  echo "FAIL readonly-count: expected 2 'the <N> read-only skills' claims around READONLY_SKILLS, found $ro_seen — a claim was added or dropped, and an unchecked claim is how the last one went stale (4.78)"
  fail=1
fi

# 34. Commit subjects match one of AGENTS.md's three documented shapes (4.79).
#     The rule and the log had disagreed since PLAN task IDs existed: AGENTS.md
#     claimed one shape and denied the most common one existed, and every audit
#     missed it because nobody compared the prose to `git log`. Checking the
#     PROSE is not possible here — this checks the LOG, which is the half that
#     goes stale silently.
#     SHALLOW CLONES: CI checks out depth 1, so there is exactly one subject to
#     test there. That is reported as a SKIP rather than passed off as coverage.
#     HONEST SCOPE: "verb-first" is checked as "starts lowercase", which is all
#     that shape can be mechanically. So this catches a capitalised or
#     merge-style subject, and a malformed `task`/`Journal` opener — it does
#     NOT check that a lowercase subject is well-formed prose, and it cannot.
if [ "$(git rev-parse --is-shallow-repository 2>/dev/null || echo true)" = "true" ]; then
  echo "SKIP commit-style: shallow clone — fewer subjects than the window, nothing meaningful checked."
  skipped=$((skipped + 1))
else
  subj_bad=0
  while IFS= read -r s_; do
    # REGEX, NOT GLOB. The shell glob `"task "[0-9]*": "*` means "task ",
    # then ONE character in 0-9, then anything — so `task 1x: malformed` and
    # `Journal 2 garbage` both passed a check whose whole job is the three
    # documented shapes (external review, 2026-09-16). Only the first
    # character was ever validated. These patterns spell the shapes out:
    #   task <n>[.<n>...][ + <n>[.<n>...]]: <description>
    #   Journal <YYYY-MM-DD>[ (<n>{st,nd,rd,th})]: <summary>
    # "verb-first" stays "starts lowercase" — that is all it can be
    # mechanically, and §34's header already says so.
    if printf '%s' "$s_" | grep -qE '^task [0-9]+(\.[0-9]+)*( \+ [0-9]+(\.[0-9]+)*)*: .'; then
      :                                   # task-closing, incl. `task 4.68 + 4.67: …`
    elif printf '%s' "$s_" | grep -qE '^[Tt]ask '; then
      echo "FAIL commit-style: subject opens as a task commit but not as \`task <number>: <description>\`: $s_"
      subj_bad=1
    elif printf '%s' "$s_" | grep -qE '^Journal [0-9]{4}-[0-9]{2}-[0-9]{2}( \([0-9]+(st|nd|rd|th)\))?: .'; then
      :                                   # journal entry, incl. `Journal <date> (3rd): …`
    elif printf '%s' "$s_" | grep -qE '^[Jj]ournal '; then
      echo "FAIL commit-style: subject opens as a journal commit but not as \`Journal <date>: <summary>\`: $s_"
      subj_bad=1
    elif printf '%s' "$s_" | grep -qE '^[a-z]'; then
      :                                   # verb-first, lowercase
    else
      echo "FAIL commit-style: subject matches none of AGENTS.md's three shapes: $s_"
      subj_bad=1
    fi
  done <<EOF
$(git log --format='%s' -20)
EOF
  [ "$subj_bad" -eq 0 ] || fail=1
fi

# 35. Near-term open tasks state a done-condition (4.81). A task with no
#     `**Acceptance:**` is not ready work — /do stops on it and /resume reports
#     it as a finding about the plan rather than listing it as next. On
#     2026-08-14, 15 of the 20 remaining scheduled tasks were in exactly that
#     state, unnoticed through every audit because nothing checked.
#     SCOPE IS DERIVED, NOT LISTED: the topmost open wave and the next one.
#     It advances by itself as waves close, and keeps distant waves out
#     without an exemption list to go stale — a wave earns acceptance lines at
#     its own spec pass (docs/wave-<n>-specs.md), not years ahead, and
#     inventing done-conditions for unshaped skills is the guessing this pack
#     refuses everywhere else.
missing_acc="$(awk '
function flush() { if (tid != "" && topen && !tacc) print wname "\t" tid; tid=""; tacc=0; topen=0 }
/^## /{ flush(); inscope=0
  if ($0 ~ /^## \[ \] Wave /) { nopen++
    if (nopen<=2) { inscope=1; wname=$0; sub(/^## \[ \] /,"",wname); sub(/ —.*/,"",wname) } }
  next }
inscope && /^- \[[ x]\] \*\*/{ flush()
  topen = ($0 ~ /^- \[ \] \*\*/)
  tid=$0; sub(/^- \[[ x]\] \*\*/,"",tid); sub(/\*\*.*/,"",tid); next }
inscope && /\*\*Acceptance:\*\*/{ tacc=1 }
END{ flush() }
' PLAN.md)"
if [ -n "$missing_acc" ]; then
  printf '%s\n' "$missing_acc" | while IFS="$(printf '\t')" read -r w_ t_; do
    [ -n "$t_" ] || continue
    echo "FAIL acceptance: $w_ task $t_ is open with no **Acceptance:** line — not ready work (4.81)"
  done
  fail=1
fi

# 36. /learn's sighting trail stays a LIST, never a stored total (5.17.3).
#     A `**Seen:** N` you increment cannot survive two sessions: both read 1,
#     both write 2, git auto-merges the identical edit with no conflict, and
#     the true value 3 is lost — measured 2026-09-14. recount.sh cannot repair
#     it either, because an accumulator has no ground truth in the tree to
#     re-derive from. The fix was to reshape the data, and a reshape with no
#     guard is a proof that does not persist: nothing else would notice the
#     template sliding back to a digit.
#     ASSERTS THE POSITIVE SHAPE, not merely the absence of digits. A
#     denylist ("no numbers here") certifies nothing about what IS there — so
#     this requires the template to carry `**Seen:**` followed by an indented
#     dated line, AND separately rejects any numeric form. Either half
#     failing alone is a real defect.
learn_md="skills/learn/SKILL.md"
if [ -f "$learn_md" ]; then
  if ! grep -qE '^- \*\*Seen:\*\*$' "$learn_md"; then
    echo "FAIL seen-shape: $learn_md has no bare '- **Seen:**' line — the sighting trail must be a list, not a stored total (5.17.3)"
    fail=1
  elif ! grep -A1 -E '^- \*\*Seen:\*\*$' "$learn_md" | grep -qE '^  - <?[0-9Y]'; then
    echo "FAIL seen-shape: $learn_md's '- **Seen:**' is not followed by an indented dated line — the count must BE the lines (5.17.3)"
    fail=1
  fi
  if grep -qE '\*\*Seen:\*\* *[0-9]' "$learn_md"; then
    echo "FAIL seen-shape: $learn_md carries a numeric '**Seen:** N' — a stored total two sessions both increment merges silently and loses one (5.17.3)"
    fail=1
  fi
fi

# 37. Identifiers in PLAN.md are unique (5.17.1). Two sessions reading the
#     same plan both allocate "the next free number". Measured 2026-09-16 on
#     a scratch clone, three arms: /ticket filings at different offsets
#     merged with NO conflict; /ticket filings at the same offset and /plan
#     decimal phases at the same offset conflicted, and the keep-both
#     resolution that is right for journal entries left two identical IDs
#     standing. In every arm the only line that fired was §23 on the moved
#     count, and recount.sh then cleared it — the prescribed post-merge
#     sequence erased the sole symptom in two commands. A count is
#     re-derivable; a duplicate identifier is not. It is a collision the
#     merger must resolve by renumbering the later-merged filing, so it is
#     FAILED here and never repaired by a script.
#     SCOPE IS DERIVED, NOT LISTED: every checkbox line's bold ID at any
#     indent (subtasks included), and every wave heading's number or letter.
#     Empty set is clean: no duplicates, no output, no failure.
dup_ids="$(grep -oE '^ *- \[[ x]\] \*\*[0-9]+(\.[0-9]+)*\*\*' PLAN.md | sed -E 's/^ *- \[[ x]\] \*\*//; s/\*\*$//' | sort | uniq -d || true)"
for id_ in $dup_ids; do
  echo "FAIL identifier: PLAN.md task ID $id_ appears $(grep -cE "^ *- \[[ x]\] \*\*${id_//./\\.}\*\*" PLAN.md) times — a merge collision; keep both, renumber the later-merged filing (5.17.1)"
  fail=1
done
dup_waves="$(grep -oE '^## \[[ x]\] Wave [0-9A-Z]+(\.[0-9]+)?' PLAN.md | sed -E 's/^## \[[ x]\] Wave //' | sort | uniq -d || true)"
for w_ in $dup_waves; do
  echo "FAIL identifier: PLAN.md heading 'Wave $w_' appears $(grep -cE "^## \[[ x]\] Wave ${w_//./\\.}( |$)" PLAN.md) times — a merge collision; keep both, renumber the later-merged phase and its tasks (5.17.1)"
  fail=1
done

# 38. Class-D skills state the scope of their verdict (5.17.4/.5/.6). /health,
#     /resume and /ship each compute a verdict from git and PLAN state as seen
#     from one branch — journal staleness, the next unblocked tasks, the
#     release gates — and each read as project-wide. With several sessions
#     on one repo that is false: measured 2026-09-16 on this repo, /health's
#     whole-log rule reported 4 unjournaled commits on a branch with 0 of its
#     own, all four other sessions' merged PRs. One convention, three
#     carriers: a canonical scope line in the report, naming the branch and
#     stating that the merged tree is the integrator's to re-check. Asserted
#     as a positive shape on ONE source line, so a rewording cannot split it
#     past this check. The roster states its own size (§33's idiom): three,
#     because these are the skills whose verdict is computed from
#     branch-local state and reported as if it were the project's; a fourth
#     joins with its reason and this count in the same edit.
SCOPE_SKILLS="health resume ship"
scope_n=0; for s_ in $SCOPE_SKILLS; do scope_n=$((scope_n + 1)); done
if [ "$scope_n" -ne 3 ]; then
  echo "FAIL scope: SCOPE_SKILLS names $scope_n skill(s), expected 3 — a new branch-reading skill joins with its reason and this count in the same edit (5.17.4-6)"
  fail=1
fi
for s_ in $SCOPE_SKILLS; do
  f="skills/$s_/SKILL.md"
  if ! grep -qE '\*\*Scope:\*\* branch .*not the project' "$f" 2>/dev/null; then
    echo "FAIL scope: $f lacks the class-D scope line ('**Scope:** branch … not the project', one source line) — its verdict reads as project-wide (5.17.4-6)"
    fail=1
  fi
done

# 39. The CI shard partition covers every matrix case, exactly once (5.26).
#     Sharding buys wall clock at the price of a correctness obligation: N
#     shards are a full run ONLY if they provably partition the case set, and
#     a case landing in ZERO shards leaves every shard green and the aggregate
#     clean. That is this repo's most-repeated failure class and it is
#     invisible by construction, so it is proven here on every commit rather
#     than trusted. Cheap because `--list` executes no case and skips the
#     snapshot: ~0.02 s per walk, ~0.2 s for the whole section.
#     N IS DERIVED FROM THE WORKFLOW, never written here — a guard testing 4
#     while CI runs 8 proves nothing about CI. The workflow states N twice
#     (the `SHARDS` divisor and the literal `shard:` list), so the two are
#     asserted to agree first; that split is the drift this section opens with.
wf=".github/workflows/check.yml"
gm="docs/guard-matrix.sh"
if [ -f "$wf" ] && [ -f "$gm" ]; then
  shards_n="$(sed -n 's/^  SHARDS: *\([0-9][0-9]*\).*/\1/p' "$wf" | head -1)"
  shards_list="$(sed -n 's/^ *shard: *\[\(.*\)\].*/\1/p' "$wf" | head -1 | tr -d ' ')"
  if [ -z "$shards_n" ] || [ -z "$shards_list" ]; then
    echo "FAIL shard: $wf has no 'SHARDS:' divisor or no 'shard: [..]' list — the partition guard cannot derive N (5.26)"
    fail=1
  else
    want_list="$(seq 1 "$shards_n" | paste -sd, -)"
    if [ "$shards_list" != "$want_list" ]; then
      echo "FAIL shard: $wf lists shard: [$shards_list] but SHARDS is $shards_n (expected [$want_list]) — a shard nobody runs, or a divisor nobody covers (5.26)"
      fail=1
    else
      _sd="$(mktemp -d)"
      bash "$gm" "$PWD" --list 2>/dev/null | grep -v '^LISTED=' | grep . | sort > "$_sd/all"
      : > "$_sd/union"
      _i=1
      while [ "$_i" -le "$shards_n" ]; do
        bash "$gm" "$PWD" --list --shard "$_i/$shards_n" 2>/dev/null | grep -v '^LISTED=' | grep . >> "$_sd/union"
        _i=$((_i + 1))
      done
      sort "$_sd/union" > "$_sd/union_s"
      _declared="$(grep -cE '^([a-z]+case|check) ' "$gm")"
      _all="$(grep -c . "$_sd/all" || true)"
      _uni="$(grep -c . "$_sd/union_s" || true)"
      _dup="$(uniq -d < "$_sd/union_s" | grep -c . || true)"
      if [ "$_all" -ne "$_declared" ]; then
        echo "FAIL shard: --list named $_all case(s) but $_declared are declared — the lister and the counter disagree (5.26)"
        fail=1
      elif [ "$_dup" -ne 0 ]; then
        echo "FAIL shard: $_dup case(s) appear in more than one shard — a partition assigns each case exactly once (5.26)"
        uniq -d < "$_sd/union_s" | sed 's/^/           /' | head -5
        fail=1
      elif [ "$_uni" -ne "$_declared" ] || ! diff -q "$_sd/all" "$_sd/union_s" >/dev/null 2>&1; then
        echo "FAIL shard: the $shards_n shards cover $_uni of $_declared case(s) — a case in zero shards leaves every shard green (5.26)"
        comm -23 "$_sd/all" "$_sd/union_s" | sed 's/^/           uncovered: /' | head -5
        fail=1
      fi
      rm -rf "$_sd"
    fi
  fi
  # The fan-in must refuse a green aggregate over a red shard. Asserted as a
  # positive shape because the default propagation is easy to disable with one
  # continue-on-error, and the result would be a PR that goes green with a
  # failing guard in it.
  # THE WORKFLOW MUST INVOKE THE GUARDS. Nothing asserted that check.yml
  # actually runs them, so deleting the `run: bash scripts/check.sh` step
  # left check.sh green while CI checked nothing (external review,
  # 2026-09-16) — the guard cannot see its own absence from the pipeline.
  # The roster states its own size (§33's idiom): three entry points, and a
  # fourth joins with its reason and this count in the same edit.
  gate_cmds="scripts/check.sh docs/guard-matrix.sh shellcheck"
  gate_n=0; for g_ in $gate_cmds; do gate_n=$((gate_n + 1)); done
  if [ "$gate_n" -ne 3 ]; then
    echo "FAIL shard: gate_cmds names $gate_n entry point(s), expected 3 (5.29)"
    fail=1
  fi
  for g_ in $gate_cmds; do
    grep -q "$g_" "$wf" || {
      echo "FAIL shard: $wf never invokes '$g_' — the workflow can drop a guard and this check would not notice (5.29)"
      fail=1; }
  done

  # main's branch protection requires a context named `check`. Sharding renamed
  # the job that provided it and left none, so the first sharded PR was green
  # and BLOCKED forever. The job must exist, and — being the ONLY required
  # context — must vouch for every upstream job, or whatever it omits is
  # unguarded.
  if ! grep -qE '^  check:' "$wf"; then
    echo "FAIL shard: $wf declares no job named 'check' — main's branch protection requires that context and would block every PR forever (5.26)"
    fail=1
  fi
  # SCOPE DERIVED, NOT LISTED (4.82, and the reason this guard exists at all).
  # The fan-in is main's ONLY required context, so any job it does not depend
  # on is unguarded — and a hand-written needs list under-counts silently the
  # day a job is added. 5.20.2 is filed to add exactly that (a fast tier on
  # push, the slow gate before merge), so the trigger is scheduled, not
  # hypothetical. Both halves are checked: every job must be NEEDED, and every
  # needed job's result must be READ.
  # Scoped to the jobs: block — `on:`'s triggers (push, pull_request,
  # workflow_dispatch) sit at the SAME two-space indent as job names, and the
  # first draft of this line collected them as jobs. Found by this guard
  # firing on its own derivation, which is the argument for deriving in the
  # first place.
  _jobs="$(awk '/^jobs:[[:space:]]*$/{j=1; next} j && /^[^[:space:]]/{j=0} j' "$wf" \
            | sed -n 's/^  \([a-z][a-z0-9_-]*\):[[:space:]]*$/\1/p' | grep -v '^check$' || true)"
  _needs="$(sed -n 's/^    needs:[[:space:]]*\[\(.*\)\].*/\1/p' "$wf" | head -1 | tr -d ' ')"
  for _job in $_jobs; do
    case ",$_needs," in
      *",$_job,"*) ;;
      *) echo "FAIL shard: $wf declares job '$_job' but the required 'check' job does not need it — whatever the gate does not depend on is unguarded (5.26)"
         fail=1 ;;
    esac
  done
  _oldifs="$IFS"; IFS=','
  for _need in $_needs; do
    IFS="$_oldifs"
    if ! grep -q "needs.$_need.result" "$wf"; then
      echo "FAIL shard: $wf's required 'check' job needs '$_need' but never reads needs.$_need.result — a failing $_need job would pass the fan-in (5.26)"
      fail=1
    fi
    IFS=','
  done
  IFS="$_oldifs"
fi

# 40. Every `## ` heading in PLAN.md matches a known shape (5.31). An
#     unclosed code span turned prose into a live heading — `## Open items`
#     rendered twice, the second one a fragment ending mid-sentence — and
#     nothing noticed for weeks. That is not cosmetic: §35 scopes waves by
#     `^## `, so a phantom heading INSIDE a wave ends that wave's acceptance
#     coverage early and every task after it is silently unchecked.
#     A SHAPE, NOT A ROSTER, and not a count: the two obvious checks were
#     tried and rejected on evidence. Duplicate-heading detection does not
#     fire, because the broken span yields DIFFERENT text ("Open items` only,
#     so a"), not a duplicate. An odd-backtick-per-line scan is unusable
#     here — 57 lines in PLAN.md and 66 in JOURNAL.md legitimately split a
#     code span across a hard wrap. What a phantom heading cannot do is match
#     the three shapes a real one takes.
if [ -f PLAN.md ]; then
  # ANCHORED, not prefix-matched. The first draft allowed `^## Open items`
  # as a prefix — and the phantom heading this section exists to catch IS
  # `## Open items\` only, so a`, which starts with exactly that. It matched
  # the allow-pattern and the guard reported clean on its own defect. Caught
  # by seeding it, which is the only reason it is not still wrong.
  # The Wave half stays deliberately loose (`Wave .+`) because real headings
  # carry parentheticals — `Wave B (Deferred) — browser layer …` — and a
  # tighter form rejected two of them on the first run. It does not need to
  # be tight: a phantom heading made from prose will not begin `## [ ] Wave`,
  # and the two headings a phantom CAN imitate are matched exactly.
  badh="$(grep -nE '^## ' PLAN.md | grep -vE '^[0-9]+:## (Index of waves|\[[ x]\] Wave .+|Open items \(decide as we go\))$' || true)"
  if [ -n "$badh" ]; then
    echo "FAIL planhead: PLAN.md has heading(s) matching none of the known shapes"
    echo "           (## Index of waves | ## [ ] Wave … | ## Open items …):"
    printf '%s\n' "$badh" | sed 's/^/           /' | head -3
    echo "           An unclosed \` turns prose into a heading, and §35 scopes waves by ^## (5.31)."
    fail=1
  fi
fi

# 41. /audit's target roster agrees wherever it is stated (5.9). The roster
#     lives in THREE places — the `## Target: <name>` sections, the
#     `argument-hint`, and README's skill table — and they drifted: a
#     front-door read on 2026-09-08 found /audit "described with four
#     targets when it declares five". A skill that advertises a target it
#     does not have sends the reader to nothing; one that hides a target it
#     does have wastes it.
#     NAMES, NOT A COUNT. Comparing a spelled-out number ("five") would
#     re-create the same drift one layer down, and a count agreeing proves
#     nothing about WHICH names agree. The sections are the source of truth,
#     because they are the only form with a procedure behind them.
af="skills/audit/SKILL.md"
if [ -f "$af" ]; then
  t_sections="$(sed -n 's/^## Target: \([a-z-]*\).*/\1/p' "$af" | sort -u)"
  t_hint="$(sed -n 's/^argument-hint: *"\([a-z|]*\).*/\1/p' "$af" | tr '|' '\n' | grep . | sort -u)"
  if [ -z "$t_sections" ] || [ -z "$t_hint" ]; then
    echo "FAIL audittargets: $af has no '## Target:' sections or no parseable argument-hint — the roster cannot be derived"
    fail=1
  elif [ "$t_sections" != "$t_hint" ]; then
    echo "FAIL audittargets: $af's '## Target:' sections and its argument-hint name different targets:"
    echo "           sections:      $(printf '%s' "$t_sections" | tr '\n' ' ')"
    echo "           argument-hint: $(printf '%s' "$t_hint" | tr '\n' ' ')"
    fail=1
  else
    # WHERE THE ROSTER LIVES IS DERIVED, not named — but by STRUCTURE, not
    # by keyword. The roster moved out of README's skill table into
    # docs/SKILLS.md on 2026-09-17 and the first version of this check,
    # hardcoded to README.md, broke immediately. The second version matched
    # any markdown naming /audit near the word "target" and swept in
    # JOURNAL.md, PLAN.md, the guard scripts and .git/COMMIT_EDITMSG — every
    # file that has ever DISCUSSED the roster, rather than the one that
    # ADVERTISES it. The advertising form is a skill-table row; discussion
    # is prose. So: every `| \`/audit\` |` row, wherever it lives, names
    # every target, and at least one such row must exist.
    arows="$(grep -rn --include='*.md' --exclude-dir=.git -- '^| `/audit` |' . 2>/dev/null || true)"
    if [ -z "$arows" ]; then
      echo "FAIL audittargets: no skill-table row advertises /audit anywhere — a six-target skill nobody is told about"
      fail=1
    else
      # STRIP THE `file:line:` PREFIX BEFORE MATCHING. `grep -n` prepends the
      # path, and the path CONTAINS target names — `./docs/SKILLS.md` holds
      # the literal string `docs`, so a row that omitted the `docs` target
      # still matched and the guard passed. Found 2026-09-17 by an external
      # review of this very commit, hours after the guard was "proven both
      # arms": the matrix seed only ever removed the alphabetically-last
      # target (`tests`), which does not appear in any path, so the case
      # could not reach the defect. One arm of one input is not a proof.
      # Per-row verdict too: the old aggregate recheck let one incomplete row
      # borrow a target from another row, so a broken roster passed whenever
      # a second, complete one existed.
      bad_rows=0
      while IFS= read -r r_; do
        [ -n "$r_" ] || continue
        loc_="${r_%%:*}"                 # file
        body_="${r_#*:}"; body_="${body_#*:}"   # strip file: and line:
        for t_ in $t_sections; do
          printf '%s' "$body_" | grep -q "$t_" || {
            echo "FAIL audittargets: $af declares target '$t_' but $loc_ advertises a roster row that omits it"
            bad_rows=1; }
        done
      done <<EOF
$arows
EOF
      [ "$bad_rows" -eq 0 ] || fail=1
    fi
  fi
fi

# 42. /verify's verdict set stays exhaustive (5.4). The skill's whole
#     contract is that EVERY input lands on exactly one verdict. It ships
#     four — CONFIRMED, OVERSTATED, FALSE, UNVERIFIABLE — and the fourth is
#     the load-bearing one: a claim naming no acceptance fits none of the
#     other three, and forcing it into FALSE asserts something about a system
#     that was never tested.
#     WHY THIS IS GUARDED AT ALL: /migrate-check shipped a `Flagged` SQL class
#     matching neither of its two verdicts, unnoticed until an external review
#     on 2026-09-17 (5.31). That gap is invisible — every individual verdict
#     reads fine, and only the SET is wrong. Dropping UNVERIFIABLE here would
#     recreate it exactly, and nothing else in the tree would notice.
#     The roster states its own size (§33's idiom): a fifth verdict joins with
#     its reason and this count in the same edit.
vf="skills/verify/SKILL.md"
if [ -f "$vf" ]; then
  # DERIVE THE SET FROM THE SKILL, then diff it against the skill's own prose
  # claim. The first version of this section listed four names here and
  # compared them to a literal `4` three lines below — both in this file, so a
  # single coordinated edit satisfied it while `## The four verdicts` in the
  # skill went stale. That is the direction the /migrate-check defect actually
  # ran: a class ADDED with no verdict, not a verdict deleted. §33's idiom is
  # derive-then-diff-against-a-claim-elsewhere, and this now implements it.
  # THE REQUIRED VOCABULARY IS A FLOOR HELD OUTSIDE THE SKILL. Deriving the
  # set from the skill's own table and then checking those same names are in
  # it is tautological: rename every UNVERIFIABLE to INCONCLUSIVE and the
  # derivation finds four names, the heading still says four, and nothing
  # fires. That is exactly what the `verify loses a verdict` matrix case
  # seeds, and this section's previous version reported got=PASS want=FAIL
  # against it — the third distinct way §42 has been wrong. A floor cannot
  # be renamed out of existence by editing the file it polices.
  VERIFY_FLOOR="CONFIRMED OVERSTATED FALSE UNVERIFIABLE"
  for v_ in $VERIFY_FLOOR; do
    grep -q "\*\*$v_\*\*" "$vf" \
      || { echo "FAIL verdicts: $vf no longer names the required verdict '$v_' — renaming one does not change the count, so only a floor held outside the skill can catch it (5.4)"; fail=1; }
  done
  VERIFY_VERDICTS="$(grep -oE '^\| \*\*[A-Z]+\*\*' "$vf" | grep -oE '[A-Z]+' | sort -u)"
  vv_n=0; for v_ in $VERIFY_VERDICTS; do vv_n=$((vv_n + 1)); done
  vv_claim="$(grep -oE '^## The ([a-z]+) verdicts' "$vf" | awk '{print $3}')"
  case "$vv_claim" in
    three) vv_want=3 ;; four) vv_want=4 ;; five) vv_want=5 ;; six) vv_want=6 ;;
    *) vv_want="" ;;
  esac
  if [ -z "$vv_want" ]; then
    echo "FAIL verdicts: $vf has no '## The <n> verdicts' heading to check the set against — the enumeration claims nothing (5.4)"
    fail=1
  elif [ "$vv_n" -ne "$vv_want" ]; then
    echo "FAIL verdicts: $vf's table defines $vv_n verdict(s) but its heading claims '$vv_claim' — a verdict added or removed without updating the claim is the stale-set-claim class (5.4)"
    fail=1
  fi
  for v_ in $VERIFY_VERDICTS; do
    grep -q "\*\*$v_\*\*" "$vf" \
      || { echo "FAIL verdicts: $vf no longer names '$v_' — /verify's contract is that every input lands on exactly one verdict, and a dropped one leaves a class matching none (5.4)"; fail=1; }
  done
  # the enumeration must also be STATED as exhaustive, not merely listed
  grep -qE 'Every input lands on exactly one' "$vf" \
    || { echo "FAIL verdicts: $vf lists verdicts but no longer claims the set is exhaustive — a list without that claim is what let /migrate-check's Flagged class match nothing (5.4)"; fail=1; }
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
