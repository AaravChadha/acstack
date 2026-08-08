// ESCAPE-HATCH FIXTURE (method rule 2). This file is full of tells ON
// PURPOSE — a story file exists to render the state under test, including
// the ugly one. When auditing a project, /design-audit must SKIP this path.
//
// The control asserts both halves separately, because they can regress
// independently: (1) the raw grep still matches this content, proving the
// slop is really here; (2) the documented escape-hatch path list still
// matches this file's directory, proving the skill would skip it.
// Asserting only (2) would pass on an empty file.

export const GeneratedHero = () => (
  <section style={{ background: "#F4F1EA" }}>
    <span className="eyebrow">Introducing</span>
    <h1 className="font-serif">
      Ship <em>faster</em>
    </h1>
    <a href="#">Learn more →</a>
    <img src="https://api.dicebear.com/7.x/bottts/svg?seed=demo" alt="" />
    <div className="aspect-video bg-muted" />
  </section>
);
