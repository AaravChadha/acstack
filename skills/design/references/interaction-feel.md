# Interaction feel — how an interface behaves under the hand

"Feels like magic" is not a look. It is a set of behaviours, and every one
of them is specifiable. When someone reaches for a material name — "liquid
glass" — to describe an interface, they are almost always describing how it
*moved*, not what it was made of.

Framework-agnostic throughout: CSS, Pointer Events and
`requestAnimationFrame` are the vocabulary. A spring library is an option,
never a dependency.

Re-expressed and credited: `emilkowalski/skills` (`apple-design`), itself
distilled from Apple's *Designing Fluid Interfaces*.

## 1. Response — feedback on pointer-DOWN

Feedback is owed the instant a finger or cursor goes down, not when it
comes up. A button that only reacts on release feels broken even when it is
fast, because the acknowledgement arrives after the decision.

Continuous during the gesture, not only at its end: a drag that updates on
drop is a form submission wearing a gesture's clothes.

## 2. Direct manipulation — 1:1 tracking

The thing under the finger moves with the finger, exactly. Two rules people
skip:

- **Respect the grab offset.** Grabbing a card 40px from its left edge and
  seeing it jump so its centre snaps to the cursor breaks the illusion that
  you are holding an object.
- **`setPointerCapture`** so the gesture survives the pointer leaving the
  element. Without it, moving fast drops the drag.

## 3. Interruptibility — the single most important principle

**Any animation must be reversible mid-flight.** If a panel is sliding in
and the user swipes back, it must reverse from where it *is*, not finish
and then leave.

Four consequences:

- **Animate from the presentation value**, not the target. Starting from
  the model value produces a visible jump on interrupt.
- **Never lock input during an animation.** A modal that ignores taps until
  its entrance finishes is telling the user their input is less important
  than the transition.
- **Blend velocity on reversal** — the object should turn around carrying
  its speed, not stop and restart.
- **Decompose 2D into independent X and Y springs** so a diagonal gesture
  can reverse on one axis while continuing on the other.

## 4. Springs over durations

Anything touchable gets a spring, expressed as **damping / response**, not
a duration. A duration says "this takes 300ms regardless of what you did";
a spring says "this settles naturally from wherever it is at whatever speed
it is going."

Shipped values worth starting from:

| Motion | damping / response |
|---|---|
| Move (general translation) | 1.0 / 0.4 |
| Rotation | 0.8 / 0.4 |
| Drawer / sheet | 0.8 / 0.3 |

Damping `1.0` is critically damped — no overshoot. **Bounce is earned only
after a momentum-carrying gesture**; a button that bounces on click is
decoration, and the same overshoot after a flick is physics.

Durations remain correct for non-interactive, non-interruptible transitions
(a toast auto-dismissing, a skeleton crossfade).

## 5. Velocity handoff and momentum projection

When a gesture ends, the object keeps the gesture's velocity. Dropping to
zero and starting a fresh animation is the single most common tell that
motion was bolted on afterwards.

To project where a flick lands, use the **exponential-decay form**:

```
projected = current + velocity * decayRate / (1000 - decayRate)
```

with a decay rate near `0.998`. **Not** the textbook `v² / 2a` — that
models constant deceleration, which is not what scroll physics does, and it
overshoots badly at high velocity.

## 6. Spatial consistency

- **Enter and exit are symmetric.** In from the right means out to the
  right. Disagreeing paths read as two different objects.
- **`transform-origin` is the trigger.** A popover grows from the control
  that opened it, not from its own centre — that is what makes it feel
  *caused by* the tap rather than merely appearing after it.
- **Rubber-banding at boundaries.** Resistance past the end of a list says
  "this is the end" while still tracking the finger; a hard stop reads as a
  bug.

## 7. Materials — translucency as hierarchy

Translucency is information, not decoration: it says *what is above what*.

- **Never stack light on light.** Two translucent surfaces on top of each
  other destroy legibility and break GPU compositing.
- **Bigger surfaces read thicker.** A full-screen sheet needs more blur and
  more opacity than a small popover, or it looks like a smudge.
- **Vibrancy for legibility**, not for effect — text over a blurred
  backdrop needs its own treatment to stay readable.
- **Scroll edge effects over hard dividers.** Content passing under sticky
  chrome should be revealed by a material change, not cut by a 1px line.
- **Materialize, don't just fade.** Animate blur radius *and* scale
  together; opacity alone looks like a slide, not an appearance.
- **Light mode is not inverted dark mode.** A translucent surface in light
  needs a *thinner* mix and *higher* saturation than its dark counterpart.
  Inverted tokens are exactly why light themes read as grey.

## 8. Multimodal — one frame

Visual, sound and haptic land on the **same frame**. A haptic 80ms after
the visual is worse than no haptic: it reads as a second, unexplained
event.

## 9. Naming motions — the reverse lookup

People describe motion by its *effect*, not its name: "the bouncy thing when
a popover opens", "make it feel snappier". Without shared names the
conversation loops. Translate the description into a named motion, say the
name back, and build that.

| What they describe | The motion | What it is |
|---|---|---|
| "bouncy thing when it opens" | **Pop in** | Scale from ~0.9 with a spring that overshoots slightly |
| "grows out of the button" | **Origin expand** | Scale from the trigger's `transform-origin` |
| "slides up from the bottom" | **Sheet** | Y-translate with a drawer spring (0.8 / 0.3) |
| "fades but also moves a bit" | **Fade-rise** | Opacity plus a small Y-translate — the default entrance |
| "snappy" | **Shorter response, same damping** | Not "faster duration" |
| "smoother" | **Higher damping** | Removes overshoot; it is not about speed |
| "springy / alive" | **Lower damping** | Overshoot — earn it with a gesture first |
| "it jumps" | **Interrupt bug** | Animating from the model value, not the presentation value (§3) |
| "laggy" | **Duration over ~300ms**, or work on the main thread |

Naming it converts a taste argument into a parameter change.

## 10. Where motion belongs — propose, never sprinkle

Motion is **proposed** at specific moments, not applied as a layer. Each
candidate must answer *what does this tell the user?* If the answer is
"nothing, it looks nice", it is decoration — cut it (see delight vs whimsy
in SKILL.md).

The moments that genuinely earn motion:

- **State changes that would otherwise pop** — appearing, disappearing,
  reordering. Motion carries continuity so the user tracks the object.
- **Causality** — the popover growing from its trigger says *this caused
  that*.
- **Direct manipulation** — anything under the finger (§2).
- **Boundaries and limits** — rubber-banding says "this is the end".
- **Continuity across a route or layout change** — a shared element moving
  rather than two unrelated screens.
- **Feedback on an action whose result is not instant** — the only honest
  use of a loading animation.

Everywhere else — decorative loops, entrance animations on static content,
hover flourishes on non-interactive elements — the default is **no motion**.

## 11. Reduced-motion, transparency and contrast are THREE signals

They are independent preferences and must be handled separately:

- `prefers-reduced-motion` → cross-fade instead of translate; never remove
  the state change itself, only the travel.
- `prefers-reduced-transparency` → solid surfaces, keeping the hierarchy
  translucency was carrying.
- `prefers-contrast` → stronger borders and text, not just darker grey.

Honouring one and ignoring the others is the common failure. Reduced motion
does not imply reduced transparency.
