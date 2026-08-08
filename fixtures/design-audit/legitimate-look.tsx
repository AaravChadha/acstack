// NEGATIVE CONTROL — the same constructs as default-look.tsx, used the way
// a real project uses them. Every grep that fires on the twin must stay
// SILENT here, or that grep reports taste as a defect.
//
// Only the tells with a meaningful negative are represented. The broad
// entry-point locators (the default sans faces, the neutral ramps, the
// AI-chip glyph, the tasteful free faces) fire on legitimate use BY
// DESIGN — a human or model adjudicates those. Faking a negative control
// for them would be a check that cannot fail. controls.sh says which is
// which.
//
// NOTE: this comment names none of those tokens literally. An earlier
// draft did, and tripped its own detector — the fixture-prose bug class
// this repo has shipped before.

const theme = {
  // customised, not the shadcn init default of 0.5rem
  radius: "0.75rem",
};

export function Pricing() {
  return (
    <section>
      {/* CTA with no arrow glyph stapled on */}
      <a href="/signup">Get started</a>

      {/* a real avatar from the product's own storage, not a generator */}
      <img src="/media/avatars/user-4821.webp" alt="Account owner" />

      {/* aspect-video wrapping REAL content, not a flat placeholder box */}
      <div className="aspect-video">
        <video src="/media/product-tour.mp4" controls />
      </div>
    </section>
  );
}
