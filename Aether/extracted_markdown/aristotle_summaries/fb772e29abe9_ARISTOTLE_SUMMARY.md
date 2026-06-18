# Summary of changes for run 5fec663c-a419-4f18-84a1-2ed9306d1642
## Split Geometry — direction-dependent Riemannian metric on ℝ²

I formalized and rigorously analyzed the proposed "Impossible Geometry" with metric
`ds² = dx²/cosh²y + cosh²x·dy²` (diagonal `g = diag(sech²y, cosh²x)`), delivered as a
single self-contained, `sorry`-free Lean file plus a research roadmap:

- `Catalog/Geometry/SplitGeometry/Core.lean` — 12 proven theorems (no `sorry`; checked to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`).
- `Catalog/Geometry/SplitGeometry/FUTURE_DIRECTIONS.md` — synthesis, results summary, and 5 falsifiable research directions (each with a "key insight" and "why now").

### Key mathematical finding
Carrying the Brioschi orthogonal-metric curvature computation through to a rigorous closed form **refutes the concept's central conjecture**. The true Gaussian curvature is
`K(x,y) = −cosh²y + (2 − cosh²y)/(cosh²x·cosh²y)`,
which is **non-positive everywhere** and **zero only at the origin** — so the advertised elliptic region, sign change, and flat diagonal phase boundary `y = ±x` do not exist. The published formula `sech²x − sech²y` is correct only on the x-axis and is explicitly refuted off-axis.

### Headline theorems
- `Kcurv_eq` — rigorous closed form of the curvature, derived from the Brioschi formula via the connection (`deriv_Gcoef_apply`, `deriv_Ecoef_apply`, `brioschi_inner_x`, `brioschi_inner_y`) with `Wfun_eq_sqrt` certifying `W = √(EG)`.
- `Kcurv_nonpos` — `K(x,y) ≤ 0` everywhere (the conjectured elliptic region is empty).
- `Kcurv_eq_zero_iff` — `K(x,y) = 0 ↔ (x,y) = (0,0)` (the flat locus is a single point, not the diagonals).
- `split_conjecture_refuted` — the formula `sech²x − sech²y` fails at `(0,1)`.

Supporting results: `split_riemannian` (positive definiteness / genuine Riemannian metric) and the Levi-Civita Christoffel symbols `christoffel_1_12` (`Γ¹₁₂ = −tanh y`) and `christoffel_2_12` (`Γ²₁₂ = tanh x`).

Each theorem carries a `-- !-- … -- !--` proof sketch, and the file includes a `-- !-- Lab Notebook -- !--` block recording the hypothesis, the (refuted) result, the insight (`a·b² + b ≥ 2` for `a,b ≥ 1`), and the failure analysis. The file builds cleanly (`lake build Geometry.SplitGeometry.Core`). It cross-references the existing `Geometry/HyperbolicDisk/Core.lean` constant-curvature model, positioning Split Geometry as a variable-curvature deformation that stays in the non-positive (hyperbolic) regime.

Note: the original concept's curvature formula and Christoffel symbols were mathematically incorrect; the formalization documents this explicitly and supplies the corrected, machine-verified values.