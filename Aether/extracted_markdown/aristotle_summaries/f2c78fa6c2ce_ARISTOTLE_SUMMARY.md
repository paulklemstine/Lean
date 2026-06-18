# Summary of changes for run 29485182-fb0b-4362-8663-a96103343284
## Summary

This was a genuine cold start: the catalog placeholders cited by the brief (`chipFiring_degree_invariant`, `Divisor`, `rho_serre_duality`, `CDPRAllocation`, `MetricChainOfLoops`, etc.) did **not** exist anywhere in the project. I therefore built the combinatorial foundation of Baker–Norine tropical divisor theory from scratch on top of Mathlib.

### Deliverables

**1. New Lean file** — `Catalog/Tropical/BakerNorine/Core.lean` (module `Tropical.BakerNorine.Core`), self-contained, importing Mathlib. It builds cleanly with **zero `sorry`** and every main theorem depends only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

**2. Seven proved theorems** (well above the 2–4 requested), centered on packaging chip-firing as a single group homomorphism, the graph Laplacian `lapHom : (V → ℤ) →+ (V → ℤ)`:
- `FinGraph.lapHom_degHom_zero` — firing preserves total degree (the chip-firing degree invariant), via antisymmetry of the Laplacian summand.
- `FinGraph.linearEquiv_degHom_eq` — degree is well defined on linear-equivalence classes.
- `FinGraph.picDeg` / `picDeg_mk` / `FinGraph.picDeg_surjective` — the degree descends to a surjective Abel–Jacobi homomorphism `Pic Γ →+ ℤ` on the Picard/Jacobian quotient `(V → ℤ)/range(lapHom)`.
- `FinGraph.handshake_even` — the handshaking lemma `2 ∣ ∑ deg v`.
- `FinGraph.canonical_degree_eq` and `FinGraph.canonical_degree_genus` — `deg K = ∑deg − 2|V| = 2g − 2` for the canonical divisor and genus.
- `rho_serre_duality` — Serre-duality self-symmetry of the Brill–Noether number `ρ(g,r,d) = g − (r+1)(g−d+r)` under `(r,d) ↦ (r−d+g−1, 2g−2−d)`.

**3. Proof sketches** — each theorem carries a concise `-- !-- ... -- !--` proof-sketch block.

**4. `FUTURE_DIRECTIONS.md`** — a narrative synthesis, results table, and five falsifiable directions (full Baker–Norine Riemann–Roch via q-reduced divisors/Dhar's algorithm; finiteness of `Pic⁰` and the Matrix–Tree theorem; the discrete Abel–Jacobi isomorphism; genus behavior under graph operations; lifting Serre duality to a structural involution), each with a "The key insight is…" sentence and a "Why now?" justification grounded in the theorems proved here.

**5. Lab Notebook** — a `-- !-- Lab Notebook -- !--` block in the Lean file with Hypothesis, Result, Insight, and Failure analysis.

### Build note
The buildable Lean package is the `Catalog/` directory (its `lakefile.toml`/manifest match the pinned Mathlib commit; the repository-root lakefile is stale and references paths that do not exist). I linked `Catalog/.lake` to the populated package cache so the project compiles, and verified the new module builds with `lake build Tropical.BakerNorine.Core`. The new file is independent of the project's other (partially broken) catalog modules.