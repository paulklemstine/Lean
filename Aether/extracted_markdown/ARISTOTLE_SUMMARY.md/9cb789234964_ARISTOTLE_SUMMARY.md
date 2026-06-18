# Summary of changes for run cd989b41-58df-4fd3-b216-5ff5409c9048
## Completed: Split Geometry Curvature Theory

### Deliverables

**`Geometry/SplitCurvature.lean`** — A self-contained Lean 4 formalization of the curvature theory for the split metric ds² = sech²(y) dx² + cosh²(x) dy², with **7 theorems, 0 sorry, standard axioms only**.

### Theorem Declarations

| # | Name | Statement | Status |
|---|------|-----------|--------|
| 1 | `splitCurvature_antisymm` | K(x,y) = -K(y,x) | **proved** |
| 2 | `splitCurvature_zero_iff` | K(x,y) = 0 ↔ \|x\| = \|y\| | **proved** |
| 3 | `splitCurvature_pos_iff` | K(x,y) > 0 ↔ \|x\| < \|y\| | **proved** |
| 4 | `splitCurvature_bound` | \|K(x,y)\| < 1 for all (x,y) | **proved** |
| 5 | `splitCurvature_neg_iff` | K(x,y) < 0 ↔ \|y\| < \|x\| | **proved** |
| 6 | `splitMetricDet_pos` | det(g) > 0 everywhere | **proved** |
| 7 | `splitCurvature_origin` | K(0,0) = 0 | **proved** |

### Key Results

- **Antisymmetry** (Theorem 1): The curvature K(x,y) = 1/cosh²(x) - 1/cosh²(y) satisfies K(x,y) = -K(y,x), establishing a Z₂ symmetry that exchanges elliptic and hyperbolic regions.

- **Phase boundary characterization** (Theorem 2): The zero set of the curvature is exactly the pair of diagonal lines \|x\| = \|y\|, proved via the injectivity of 1/cosh² modulo absolute value. The most technically demanding auxiliary lemma (`one_div_cosh_sq_eq_iff`) required reducing cosh equality to exponential equations.

- **Curvature sign characterization** (Theorem 3): K > 0 precisely in the "elliptic" region \|x\| < \|y\|, and K < 0 in the "hyperbolic" region \|x\| > \|y\|. This is the central geometric result — it gives a complete qualitative picture of the curvature landscape.

- **Uniform curvature bound** (Theorem 4): \|K\| < 1 everywhere, with the bound sharp but never attained. Proved using the pointwise estimates 0 < 1/cosh²(t) ≤ 1.

### Supporting Infrastructure

Four auxiliary lemmas on the function 1/cosh²: positivity, upper bound ≤ 1, strict monotonicity in \|·\|, and injectivity modulo absolute value. These form a reusable toolkit for the (α,β)-family generalization.

### `FUTURE_DIRECTIONS.md`

Five research directions with falsifiable hypotheses: geodesic equations and phase boundary crossing, area integrals / Gauss-Bonnet, the (α,β)-parameter family, completeness analysis, and spectral decomposition of the split Laplacian. Each includes test criteria and implications of both positive and negative outcomes.