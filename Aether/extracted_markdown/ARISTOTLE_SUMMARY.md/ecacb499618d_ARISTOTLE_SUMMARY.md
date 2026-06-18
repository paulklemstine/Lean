# Summary of changes for run 1a8cd93d-d2da-4473-a8ff-2dfddaf4c1a7
Completed a research cycle on **Tropical Persistent Topology** (TDA view of tropical polynomials) in the Tropical domain.

## Deliverables

**1. Verified Lean 4 file** — `Catalog/Tropical/Persistence/SublevelFiltration.lean` (compiles cleanly, 0 sorries, only standard axioms `propext`/`Classical.choice`/`Quot.sound`).

It formalizes tropical polynomials on ℝⁿ as finite max-plus families of affine monomials, and proves:
- `convexOn_monomial`, `convexOn_toFun` — tropical polynomials are convex functions (finite max of affine maps).
- `convex_sublevel`, `sublevel_mono`, `isPreconnected_sublevel`, `isConnected_sublevel` — the sublevel filtration consists of nested convex (hence connected) sets.
- `nonempty_sublevel_upward`, `H0_single_bar` — the degree-0 persistence diagram is a single bar `[birth, ∞)`: no merging or splitting of components, ever.
- `tropAdd`/`tropMul` with `toFun_tropAdd` (= pointwise max), `toFun_tropMul` (= pointwise sum), `toFun_distrib` (distributivity), `toFun_tropAdd_self` (tropical idempotence), and `sublevel_tropAdd` (filtration of a sum = intersection). These connect the catalog's pointwise tropical-semiring identities (`Tropical/Core/TropicalSemiringProperties.lean`) to the structured/geometric layer.
- `abs_sup'_sub_sup'_le` and `toFun_stable` — a dimension-free 1-Lipschitz stability bound of the value function in the coefficients (the pointwise core of barcode stability).

**2. Lab Notes** — four inline `-- !-- Lab Notes -- !--` blocks (H1–H4) recording hypotheses, experimental outcomes, an explicit failure analysis (the abandoned `sup'`-over-sum-type-union approach vs. the working elementwise `le_sup'`/`sup'_le` characterization), and insights linking the results back to catalog semiring laws.

**3. `Catalog/Tropical/Persistence/FUTURE_DIRECTIONS.md`** — five bold, testable conjectures (C1 degree-k persistence collapse / contractibility; C2 tropical-hypersurface region counts under ⊕/⊗; C3 barcode stability, whose pointwise core is now proved; C4 Newton-polytope ↔ birth-value dictionary; C5 functoriality of persistence as a tropical-semiring self-map).

Constraints respected: only standard Lean 4 code — no ARTICLE/RESEARCH_PAPER prose, no Python, no HTML, no package files, no added axioms or `@[implemented_by]`.

Verification note: the repository's root `lakefile.toml` lib globs point at top-level paths while sources live under `Catalog/`, so the file was verified directly with `lake env lean` (exit 0, no diagnostics) and via `#print axioms`.