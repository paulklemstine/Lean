# Summary of changes for run 9e9204a0-33db-4cab-9bad-6261c09413c7
## Split Geometry: Direction-Dependent Curvature on ℝ²

### Deliverables

**Lean file**: `Computation/SplitGeometry.lean` — 188 lines, fully proven (0 sorries), builds cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

**Research directions**: `FUTURE_DIRECTIONS.md` — 5 falsifiable conjectures extending the work.

### Mathematical Content

We formalize a "split geometry" on ℝ² defined by the diagonal Riemannian metric ds² = sech²(y) dx² + cosh²(x) dy², whose Gaussian curvature K(x,y) = sech²(x) - sech²(y) changes sign across the diagonals y = ±x. This creates a geometry that is simultaneously elliptic and hyperbolic depending on direction — a rigorous realization of "parallel lines that both converge and diverge."

### Proven Theorems (14 total, all sorry-free)

**Core results (non-trivial)**:
1. **`splitCurvature_eq_zero_iff`**: K(x,y) = 0 if and only if |x| = |y| — the phase boundary is exactly the pair of diagonals.
2. **`splitCurvature_pos_iff`**: 0 < K(x,y) ↔ |x| < |y| — complete sign characterization via strict monotonicity of cosh on [0,∞).
3. **`splitCurvature_bound`**: -1 < K(x,y) < 1 for all (x,y) — strict boundedness of curvature.
4. **`splitMetricDet_ge_one_iff`**: det(g) ≥ 1 ↔ |y| ≤ |x| — the metric determinant characterizes which curvature region you're in.

**Supporting results**:
- `cosh_sq_strictMonoOn`: cosh² is strictly monotone on [0,∞)
- `cosh_lt_cosh_iff_abs_lt`: cosh(x) < cosh(y) ↔ |x| < |y|
- `splitCurvature_antisymm`: K(x,y) = -K(y,x)
- Metric positive definiteness (`splitG11_pos`, `splitG22_pos`)
- Phase boundary vanishing (`splitCurvature_zero_diag`, `splitCurvature_zero_antidiag`)
- Determinant positivity (`splitMetricDet_pos`)

### Key Insight

The entire curvature analysis reduces to the strict monotonicity of cosh on [0,∞) combined with the evenness cosh(-x) = cosh(x). The curvature K = sech²(x) - sech²(y) is positive when cosh(x) < cosh(y), which by monotonicity + evenness is exactly |x| < |y|. This single observation drives the full sign characterization, the phase boundary theorem, and the determinant classification.