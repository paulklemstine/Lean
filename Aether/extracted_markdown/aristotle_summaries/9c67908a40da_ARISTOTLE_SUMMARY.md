# Summary of changes for run 61e6fd41-4517-4d03-aac5-455dcef98c3f
Delivered a new, self-contained Lean 4 research file plus the required research narrative, extending the project's tropical (min-plus) catalog from algebra to *root geometry*.

**New file: `Catalog/Tropical/NewtonQuadratic.lean`** (sorry-free; all theorems verified to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

It introduces the tropical quadratic `tropQuad c0 c1 c2 x = min(min c0 (c1+x)) (c2+2x)` and the tropical-root predicate `IsTropRoot` (the defining minimum attained by at least two affine pieces), then proves four results:

1. `tropQuad_root_separated` — in the non-degenerate Newton-polygon regime (`2*c1 ≤ c0+c2`) the roots are exactly the two corners `c1-c2` and `c0-c1`.
2. `tropQuad_root_degenerate` — in the degenerate regime (`c0+c2 < 2*c1`) there is a single double root `(c0-c2)/2`.
3. `tropQuad_vieta` — the tropical Vieta formula: any two distinct roots sum to `c0-c2` (min-plus analogue of "product of roots = a0/a2").
4. `tropQuad_concaveOn` — the value function is globally concave, the structural fact underlying its continuous-piecewise-linear (CPL) shape, linking to the catalog's ReLU/CPL programme.

The switch between regimes is governed by the tropical discriminant `c0 + c2 - 2*c1`. The file includes the requested `-- !-- comment -- !--` proof-sketch blocks for each theorem and an `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis), plus a module docstring documenting the catalog synthesis (building on the `Tropical.Core.*` / `Tropical.MinPlusAlgebra` min-plus semiring foundations).

**`Catalog/Tropical/FUTURE_DIRECTIONS.md`** — a freeform narrative with a synthesis, results summary, and five falsifiable research directions (tropical cubic / general Newton polygon, tropical fundamental theorem of algebra, full tropical Vieta for symmetric functions, the root set as the non-differentiability locus, and perturbation/conditioning of tropical roots), each with a "The key insight is..." sentence and a "Why now?" justification.

Note: the project's existing `lakefile.toml` default build targets point at root-level directories while sources live under `Catalog/`, so the whole-project default build is pre-existing-broken; I verified the new file independently against the prebuilt Mathlib, and each main theorem compiles cleanly with only standard axioms.