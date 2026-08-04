# AI tells — the signatures of machine-generated UI

Generated interfaces fail in a recognisable way. Not "ugly" — *samey*: the
same violet gradient, the same eyebrow above the same heading, the same
`99.9%` stat nobody measured. This file turns those into findable
violations.

> **Regex note.** These are POSIX ERE — `\b` matches nothing, `\s` parses as
> a literal `s`, and `\1` is an invalid escape that makes the whole grep
> error out and match NOTHING. Use `-w` and `[[:space:]]`. Apply with the
> **Grep tool**; with no Grep tool use plain `grep -rnE` — never shell
> `git grep`, whose `-O` runs an arbitrary program.

**Every hit is a candidate, not a finding.** One gradient is a choice; the
full set is a signature. Report `file:line`, the tell, and the fix — and
when a project has *deliberately* chosen a look, say so and drop it rather
than reporting taste as a defect.

**Severity order is fixed: accessibility, then honesty, then everything
else.** A violet gradient is embarrassing. Unreadable text and a fabricated
statistic are harm. Report in that order regardless of hit count.

**Hedge copy is NOT here.** That list is canonical in
`design-conventions.md` §3; this file adds only tells absent from it.

---

## 1. Accessibility floor — report first, always

| Tell | Why it matters |
|---|---|
| Body text below 4.5:1 contrast, large text below 3:1 | The floor. Below it the interface is unusable for some users, not merely unfashionable |
| Emoji used as an icon | Screen readers announce them as words ("rocket") mid-sentence, and they render differently per platform |
| Heading levels skipped (`h1` → `h3`) | Heading order is the document outline a screen-reader user navigates by |
| Motion with no `prefers-reduced-motion` branch | Vestibular triggers; the query is one media block |
| `backdrop-filter` with no `prefers-reduced-transparency` branch | Same class, newer property |

```bash
git grep -nE 'aria-hidden="false"|role="img"[^>]*>[^<]' -- '*.html' '*.jsx' '*.tsx'
git grep -nE '<(button|a|h[1-6])[^>]*>[^<]*[^ -~<]' -- '*.html' '*.jsx' '*.tsx' '*.vue' '*.svelte'
git grep -nE 'animation:|transition:|@keyframes' -- '*.css' '*.scss'
git grep -nE 'prefers-reduced-(motion|transparency)' -- '*.css' '*.scss'
```

**The emoji grep matches any non-ASCII in a button or heading**, not an
enumerated emoji list. An enumerated list is a denylist and cannot be
finished — the previous version named seven emoji and missed the one this
pack's own fixture seeds (🔔), so it reported clean on the pack's own
before-page. The cost is a false positive on legitimately accented text
("Café"); drop those on sight. A loud false positive beats a silent miss,
which is the same trade the fixture rules make.

The last two are read **together**: motion present and the media query
absent is the finding. Heading order and contrast are judgment — grep finds
the headings and the colour pairs; a human or model compares them.

## 2. Honesty tells — fabricated substance

The `/design-audit` honest-data check covers mock data wearing a real face.
These are its content siblings: numbers, names, and screenshots invented to
look like evidence.

| Tell | Signature |
|---|---|
| Marketing-shaped statistics nobody measured | `99.9%`, `10x faster`, `#1 in`, `trusted by 10,000+` |
| Filler identities | `John Doe`, `Acme`, `Nexus`, `example.com` in shipped UI |
| A chart or stat block used as decoration | Present as data, wired to nothing |
| A "screenshot" built from divs | Implies a real product view that does not exist |
| Placeholder text used as a label | `placeholder` doing a `<label>`'s job |

```bash
git grep -nE '(99\.9[0-9]*%|100% (uptime|accurate|secure)|[0-9]+x (faster|better|more))'
git grep -niE '(john (doe|smith)|jane doe|acme (corp|inc)|nexus|@example\.(com|org))'
git grep -niE 'trusted by [0-9,]+|[0-9,]+\+ (users|customers|developers)'
git grep -nE '<input[^>]*placeholder=' -- '*.html' '*.jsx' '*.tsx' '*.vue'
```

The `<input>` grep is a **pairing** check: an input with a placeholder and
no associated `<label>` is the finding, not the placeholder itself.

## 3. The visual signature — impeccable's detector set, re-expressed

Individually defensible; together they are the tell.

| Tell | Signature |
|---|---|
| Violet/purple gradient as the default accent | `from-purple-*`, `from-violet-*`, `linear-gradient` into `#8b5cf6`-family |
| Gradient text | `bg-clip-text` with a gradient background |
| A gradient orb standing in for "AI" | An orb/blob/glow near AI or assistant copy |
| Kicker/eyebrow above every heading | `eyebrow`, `kicker`, `overline` class names |
| Numbered section labels (`01 — Features`) | Two-digit label before a heading |
| Cards nested inside cards | Border inside border inside border |
| Icon-tile feature grids | 3- or 4-up grid, each cell an icon over a bold line |
| Pulsing dots and glow rings | `animate-pulse` on decorative elements |
| Rounded card with a left accent stripe | The generated "callout": `border-left: 4px solid <accent>` on a rounded card, used for every note, tip and warning alike |
| Em-dash overuse in UI copy | More em dashes than sentences |

```bash
git grep -nE 'from-(purple|violet|fuchsia|indigo)-[0-9]{2,3}'
git grep -niE 'linear-gradient\([^)]*(#(8|9)[0-9a-fA-F]{5}|purple|violet|fuchsia)'
git grep -nE '(bg-clip-text|background-clip:[[:space:]]*text)'
git grep -niE 'class(Name)?="[^"]*(eyebrow|kicker|overline)'
git grep -nE '>[[:space:]]*0[1-9][[:space:]]*(—|-|\.)[[:space:]]*[A-Z]'
git grep -nE 'animate-pulse'
git grep -nE 'border-left:[[:space:]]*[0-9]+px[[:space:]]*solid|border-l-[248]'
git grep -niE '(ai|assistant|magic|intelligen)[^<>]{0,40}(orb|blob|glow)|(orb|blob)[^<>]{0,40}gradient'
```

Nested cards and icon-tile grids are structural — grep the card/tile class,
then read the nesting. A count is not a finding.

## 4. Motion bounds

| Tell | Why |
|---|---|
| `ease-in` on a UI transition | Starts slow: the interface feels unresponsive to the click that caused it. `ease-out` for entrances |
| `transition: all` | Animates properties you never chose, including ones added later |
| `scale(0)` entrances | Nothing in the physical world grows from nothing |
| Durations over ~300ms on UI feedback | Past that it reads as lag, not animation |
| Animating `width`/`height`/`top`/`left` | Layout-triggering; use `transform` |

```bash
git grep -nE 'transition:[^;]*[[:space:]]all[[:space:]]'
git grep -nE 'ease-in([^-]|$)'
git grep -nE 'scale\(0(\.0+)?\)'
git grep -nE '(duration-|[[:space:]])[4-9][0-9]{2}ms|[1-9][0-9]{3,}ms'
git grep -nE 'transition:[^;]*(width|height|top|left|margin)'
```

## 5. Materials and translucency

Glass surfaces fail in specific, checkable ways.

| Tell | Why |
|---|---|
| `backdrop-filter` on an ancestor of a popover | It creates a **stacking context that traps z-index** — the popover clips inside the shell. Render it at the shell root |
| Two nested `backdrop-filter` surfaces | Stacked translucency destroys legibility AND breaks GPU compositing — a two-signal finding |
| Translucency over a flat fill | With nothing to refract it reads as a grey box, not glass |
| A popover over live content below ~94% opacity | Small text stops being readable |
| Ambient background loops on equal durations | They visibly re-sync; mismatch them (22s / 27s / 31s) |

```bash
git grep -nE 'backdrop-filter|backdrop-blur'
git grep -nE 'animation:[^;]*[0-9]+s' -- '*.css' '*.scss'
```

Both are entry points, not verdicts: find the surfaces, then read the
nesting, the layer beneath, and the durations.

## 6. Interaction feel — violations of *behaviour*

| Tell | Why |
|---|---|
| A click handler with no `:active`/pressed state | Feedback is owed on pointer-**down**, not on release |
| `transition`/`@keyframes` driving a draggable element | Neither can be grabbed and reversed mid-flight — it must be interruptible |
| Animation starting from the target value | Visible jump when interrupted; start from the current presentation value |
| A hard 1px divider under sticky chrome | A scroll edge effect belongs there |
| Enter and exit paths that disagree | In from the right, out the bottom reads as two different objects |
| `transform-origin: center` on a popover | It should grow from its trigger |

```bash
git grep -nE 'onClick|onPress|addEventListener\(.click' -- '*.jsx' '*.tsx' '*.vue' '*.svelte'
git grep -nE ':active|:hover'
git grep -nE '(transform-origin:|transformOrigin:)[[:space:]]*.?center'
git grep -nE 'position:[[:space:]]*sticky'
```

The first two are read together: click handlers far outnumbering `:active`
rules is the signal.

## Config

`banned-palette:` in a `## design-audit` section lists hex values that are
findings wherever they appear — the generated-UI default accents. It layers
**over** `palette:`: `palette` says what is allowed, `banned-palette` says
what is never allowed even if someone adds it to the palette.

Pack default (the violet-gradient family):
`#8b5cf6, #a855f7, #7c3aed, #6366f1, #d946ef`

## Credits

Rule *ideas* here are re-expressed from public work, never copied:
`pbakaus/impeccable` (the detector-rule shape), `Leonxlnx/taste-skill`
(content tells and banned palettes), `emilkowalski/skills` (motion bounds
and interaction feel), `ngocanhnckh/liquid-glass-frontend-skill`
(translucency failure modes), `jiji262/claude-design-skill` (the AI-orb and
decorative-chart tells).
