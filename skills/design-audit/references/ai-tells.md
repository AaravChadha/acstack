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

## Two rules that outrank every tell below

**1. Concentration, not presence. The threshold is a number: THREE.** A
surface — one file, or one route's files — needs **three or more distinct
tells** before it is reported as machine-generated. One or two are listed
as candidates with their `file:line`, and the report says explicitly that
the count is below the bar. Within a named cluster (see Config) the bar is
**two of the cluster's three signals**, because the signals are chosen to
be independent.

Why a number at all: "one tell is a choice, the full set is a signature"
was already written here and did nothing, because it left every reader to
pick their own bar — and a checker with no threshold reports a lone
`animate-pulse` as evidence of a generated interface. That is the finding
nobody trusts, and an audit nobody trusts is not run.

**2. Self-reference escape hatch.** Skip `examples/`, `fixtures/`,
`__mocks__/`, `stories/`, `__fixtures__/` and `*.stories.*` when auditing a
project. Those directories are where slop is planted ON PURPOSE — a design
system's story file exists to render the ugly state, and reporting it is
noise that trains the reader to ignore the whole report.

> **This pack's own controls deliberately bypass rule 2, and must.**
> `scripts/controls.sh` runs these greps directly against
> `fixtures/design-audit/`, because the seeded plant IS the thing under
> test. If a future reader "fixes" the controls to honour the escape hatch,
> every positive control goes dark while still printing `ok`. The hatch is
> a rule for auditing SOMEONE'S PROJECT, not a rule for the grep.

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
git grep -niE '(john (doe|smith)|jane doe|acme (corp|inc)|nexus|@example\.(com|net|org)|@[A-Za-z0-9.-]+\.(example|invalid|test|localhost)([^A-Za-z0-9.-]|$)|@localhost([^A-Za-z0-9.-]|$))'
git grep -niE 'trusted by [0-9,]+|[0-9,]+\+ (users|customers|developers)'
git grep -nE '<input[^>]*placeholder=' -- '*.html' '*.jsx' '*.tsx' '*.vue'
```

The `<input>` grep is a **pairing** check: an input with a placeholder and
no associated `<label>` is the finding, not the placeholder itself.

The address half of the fabricated-content grep **enumerates RFC 2606**
rather than sampling it: `example.com/net/org` as second-level names, and
`.example`, `.invalid`, `.test`, `.localhost` as reserved TLDs. It sampled
two second-level forms and no TLD until 2026-08-14, so a `.example` address
in a live audit was caught by a model citing the RFC and not by this
pattern (4.71) — the fifth time a denylist here has shipped a hole. The
trailing `([^A-Za-z0-9.-]|$)` is what keeps `sub.test.com` and
`localhost.example-corp.com` out; both are plausible real domains and a
grep that flags them trains its reader to ignore it.

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

## 7. Typography — the face nobody chose

| Tell | Signature |
|---|---|
| Inter or Geist as the only face | One `font-family`, no pairing, no display face. The default of every generated interface since 2023 |
| The "tasteful free font" cluster | `Space Grotesk`, `Sora`, `Syne`, `Outfit` — reached for to look deliberate, which is what makes them a tell |
| Serif-italic accent word inside a sans headline | "Build something *beautiful*" — the one flourish, in every generated hero |
| Arrow glyph stapled to a CTA | `Get started →`. The typographic sibling of the em-dash tell in §3: punctuation doing the work the copy should |

```bash
git grep -nE 'font-family:[^;]*(Inter|Geist)|font-(sans|display):[^;]*(Inter|Geist)'
git grep -nE '(Space Grotesk|Sora|Syne|Outfit)'
git grep -nE '(italic|<em)[^<]{0,40}(serif)|(serif)[^<]{0,40}(italic|<em)'
git grep -nE '(Get started|Learn more|Read more|Explore|Get in touch)[[:space:]]*(→|&rarr;)'
```

The first is an **entry point, not a verdict**: Inter is a good face and
using it is not a defect. The finding is Inter as the ONLY face, so read
what else the file declares before reporting it. The third is likewise a
locator — find the pairing, then look at whether it is one accent word in a
headline or a real editorial voice.

## 8. Component-library defaults left untouched

Shipping the starter's defaults is the tell — not the library.

| Tell | Signature |
|---|---|
| The default radius, never revisited | `--radius: 0.5rem` verbatim from the shadcn init |
| `zinc`/`slate` as the entire neutral ramp | No project ever chose both and nothing else |
| Icon in a rounded square chip | A Lucide glyph inside `rounded-lg` + `bg-primary/10`, repeated per feature |
| `Sparkles` meaning "AI" | The single most-reached-for icon in generated product UI |

```bash
git grep -nE '\-\-radius:[[:space:]]*0\.5rem'
git grep -nE '(bg|text|border)-(zinc|slate)-[0-9]{2,3}'
git grep -nE 'Sparkles'
git grep -nE 'rounded-(lg|xl)[^"]*bg-primary/10|bg-primary/10[^"]*rounded-(lg|xl)'
```

## 9. Imagery — placeholders wearing a product's face

The §2 honesty tells applied to pixels rather than numbers.

| Tell | Signature |
|---|---|
| Generated-avatar services in shipped UI | `dicebear`, `pravatar.cc`, `ui-avatars.com` |
| An empty media box standing in for a screenshot | `aspect-video` over a flat `bg-muted` with no child |
| Stock hotlinks as product imagery | `images.unsplash.com` referenced directly from markup |

```bash
git grep -niE '(dicebear|pravatar\.cc|ui-avatars\.com)'
git grep -nE 'aspect-video[^"]*bg-(muted|gray|zinc|slate)'
git grep -nE 'images\.unsplash\.com'
```

## Config

`banned-palette:` in a `## design-audit` section lists hex values that are
findings wherever they appear — the generated-UI default accents. It layers
**over** `palette:`: `palette` says what is allowed, `banned-palette` says
what is never allowed even if someone adds it to the palette.

Pack default (the violet-gradient family):
`#8b5cf6, #a855f7, #7c3aed, #6366f1, #d946ef`

### The default-look clusters — reviewed 2026-08-08

**A hex denylist cannot be finished, and this one went stale.** The list
above is violet, which is where generated design clustered in 2024–25. It
is no longer where it clusters, and a longer list would fail the same way
next year — the third appearance of the denylist class in this repo. So the
list stays for what it still catches, and **the pack default is a cluster
check instead**: a *shape*, matched by co-occurrence rather than by
enumeration.

**A cluster is a finding only when TWO of its three signals co-occur** in
the same surface (method rule 1). Its signals are chosen to be independent,
so two together are already unlikely by accident.

| Cluster | Signal A | Signal B | Signal C |
|---|---|---|---|
| Cream editorial | background near `#F4F1EA` / `#FAF7F0` / `oklch(0.97…)` cream | serif display face | terracotta / rust accent (`#C', '#B` warm mid-tones) |
| Dark acid | near-black background (`#0A0A0A`–`#111`) | a single acid-green or vermilion accent | no third hue anywhere |
| Broadsheet | hairline rules (`1px` borders as structure) | `border-radius: 0` throughout | dense multi-column text |
| Violet gradient | `#8b5cf6`-family accent | gradient text or orb | icon-tile feature grid |

```bash
git grep -niE '(#F4F1EA|#FAF7F0|#FDFBF7|bg-\[#F[0-9A-Fa-f]{5}\]|cream)'
git grep -niE '[Ff]ont-?[Ff]amily[^;]*(Playfair|Fraunces|Instrument Serif|Lora|EB Garamond)'
git grep -niE '(#C1[0-9A-Fa-f]{4}|#B[0-9A-Fa-f]{5}|terracotta|rust|clay)'
git grep -nE 'border-radius:[[:space:]]*0(px)?;|rounded-none'
```

**Review date is load-bearing.** This table describes where generated
design clustered on **2026-08-08**, sourced from Anthropic's own
`frontend-design` skill and an independent tells list that both named the
cream/serif look. It will go stale. Re-read it at each pack version and
move the date, or delete the table rather than let it quietly misinform —
an undated aesthetic claim is a stale claim with no expiry printed on it.

**With `palette:` configured, clusters are NOT reported.** A project that
chose cream and said so has made a decision, and reporting a decision back
as a defect is exactly the taste-as-defect failure this file opens by
forbidding. The cluster check exists for the unconfigured case, where the
alternative is no signal at all.

## Credits

Rule *ideas* here are re-expressed from public work, never copied:
`pbakaus/impeccable` (the detector-rule shape), `Leonxlnx/taste-skill`
(content tells and banned palettes), `emilkowalski/skills` (motion bounds
and interaction feel), `ngocanhnckh/liquid-glass-frontend-skill`
(translucency failure modes), `jiji262/claude-design-skill` (the AI-orb and
decorative-chart tells).
