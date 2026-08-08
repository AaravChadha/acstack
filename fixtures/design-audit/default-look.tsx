// SEEDED FIXTURE — the 2026 default generated look, plus the tell classes
// added in PLAN 4.54/4.60. Every construct here is deliberate; this file
// exists to be caught. Its legitimate twin is legitimate-look.tsx, which
// uses the same constructs in ways that must NOT be reported.
//
// Cream-editorial cluster: signals A (cream bg), B (serif display), C (rust
// accent) all present, so it clears the two-of-three cluster bar.
import { Sparkles } from "lucide-react";

const theme = {
  background: "#F4F1EA",
  accent: "#C1440E",
};

export function Hero() {
  return (
    <section style={{ background: "#FAF7F0", fontFamily: "Playfair Display, serif" }}>
      <div className="rounded-lg bg-primary/10">
        <Sparkles className="h-4 w-4" />
        <span>AI</span>
      </div>

      <h1 className="font-sans">
        Build something <em className="font-serif italic">beautiful</em>
      </h1>

      <a className="bg-zinc-900 text-slate-50" href="/signup">
        Get started →
      </a>

      <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Casey" alt="" />
      <img src="https://i.pravatar.cc/64" alt="" />

      <div className="aspect-video bg-muted" />

      <figure>
        <img src="https://images.unsplash.com/photo-1521737604893" alt="" />
      </figure>
    </section>
  );
}
