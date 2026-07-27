# Design conventions — defaults, greps, and the config schema

Brand-neutral defaults for when no project config is set. Project config
(`## design-audit` in `.claude/acstack.md`) always overrides these; a
grep hit is a candidate, and each finding still names the exact
convention it violates.

## Config schema

```markdown
## design-audit
- palette: #0f172a, #f8fafc, #3b82f6, #64748b   # allowed hex values
- product-names: Acme, AcmeCloud                 # exact required casings
```

Both keys optional. With no `palette`, flag only obvious raw-hex sprawl
(many distinct hex literals, or raw hex next to design tokens), never
brand conformance — and say which in scope.

## 1. Palette + branding

```bash
git grep -nE '#[0-9a-fA-F]{3,8}\b' -- '*.css' '*.scss' '*.js' '*.jsx' '*.ts' '*.tsx' '*.vue' '*.svelte'
git grep -nE 'rgb\(|rgba\(|hsl\('
```

- A hex literal not in `palette:` is a finding when a palette is set.
- Raw hex sitting beside a design token (`var(--…)`, a theme object,
  Tailwind config) is a finding regardless — the token exists to be
  used.
- Product names: grep each configured name case-insensitively, flag the
  casings that don't match the configured one.

## 2. Honest data labels

```bash
git grep -niE '(mock|sample|dummy|placeholder|fake|lorem|test)\s*(data|value|user|chart)'
git grep -niE '(faker|mockData|SAMPLE_|DUMMY_|generateFake|randomInt|Math\.random)'
```

- Data marked mock/sample/fake in code but rendered in a user-facing
  surface with no visible "sample" / "illustrative" / "AI-generated"
  label is a finding.
- A chart or metric whose numbers come from a random/generated source
  and reads as real is the headline case — the honest-measurement
  principle in pixels.
- AI-generated content (copy, images) shown without an
  "AI-generated" affordance where the product's context implies real
  provenance.

## 3. Slop detection

```bash
git grep -niE '\b(lorem ipsum|dolor sit)\b'
git grep -niE '\b(simply|just|seamlessly|effortlessly|powerful|blazing|cutting-edge|revolutionary|unleash)\b' -- '*.html' '*.jsx' '*.tsx' '*.vue' '*.svelte' '*.md'
git grep -nE '(console\.(log|debug)|TODO|FIXME|XXX)' -- '*.jsx' '*.tsx' '*.vue' '*.svelte' '*.html'
```

- Lorem/placeholder remnants in anything shippable.
- Hedge/marketing filler in product copy ("simply click", "blazing
  fast") — flag, propose the plain rewrite.
- Emoji-decorated headings in product UI (distinct from intentional
  brand voice — note it, let the user rule).
- Uniform gradient-card grids: many cards sharing one gradient template
  — the generated-dashboard tell. Reported as a pattern with the file,
  not line-by-line.
- Debug strings reaching rendered output.

## 4. Client-facing language

```bash
git grep -niE '(stack trace|traceback|Exception|Error:|undefined|NaN|\[object Object\])' -- '*.html' '*.jsx' '*.tsx' '*.vue' '*.svelte'
```

- Error UI exposing internals (stack traces, table/column names, file
  paths, framework errors) — a finding here AND a cross-reference to
  /secure when it leaks system structure.
- Internal codenames or jargon in user-visible strings.
- Terminology drift: the same domain object named differently across
  screens. Report the pair with both locations — consistency is the
  convention, and the fix names which term wins.
