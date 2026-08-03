// SEEDED FIXTURE for /design-audit's ai-tells.md (task 4.27).
// Every line below is a deliberate plant — one per rule class — so
// scripts/controls.sh can prove each documented grep still catches it.
// Do NOT "fix" these; they are the positive controls.
export function Hero() {
  return (
    <section>
      {/* PLANT: violet gradient default accent + gradient text */}
      <div className="bg-gradient-to-r from-purple-500 to-violet-600">
        <h1 className="bg-clip-text text-transparent">Ship faster</h1>
      </div>

      {/* PLANT: kicker/eyebrow above the heading */}
      <p className="eyebrow">INTRODUCING</p>
      <h2>The platform</h2>

      {/* PLANT: numbered section label */}
      <h3>01 — Features</h3>

      {/* PLANT: gradient orb standing in for "AI" */}
      <div className="ai-assistant-orb bg-gradient-to-br" aria-hidden="true" />

      {/* PLANT: pulsing decorative dot */}
      <span className="animate-pulse" />

      {/* PLANT: emoji used as an icon inside a button */}
      <button type="button">🚀 Launch</button>

      {/* PLANT: fabricated statistics and filler identities */}
      <p>99.9% uptime · 10x faster · trusted by 10,000+ developers</p>
      <blockquote>John Doe, Acme Corp — jane@example.com</blockquote>

      {/* PLANT: placeholder doing a label's job (no <label> anywhere) */}
      <input type="email" placeholder="Work email" />

      {/* PLANT: popover growing from its centre, not its trigger */}
      <div style={{ transformOrigin: 'center' }} role="dialog" />

      {/* PLANT: click handler with no :active state anywhere in app.css */}
      <button onClick={() => console.log('cta')}>Get started</button>
    </section>
  );
}
