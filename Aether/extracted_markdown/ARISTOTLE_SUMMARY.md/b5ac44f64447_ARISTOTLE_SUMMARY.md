# Summary of changes for run 39f43859-8dad-44bf-99a0-0171de8cc3f8
## Split Geometry: Formalized in Lean 4

### Deliverables

**`Geometry/SplitGeometry.lean`** — 245 lines, 17 theorems/lemmas, **0 sorries**. Fully verified, clean build.

**`FUTURE_DIRECTIONS.md`** — 5 research directions with key insights and justifications.

### Mathematical Content

Defines the **split metric** on ℝ²: ds² = sech²(y)dx² + cosh²(x)dy², a Riemannian metric whose Gaussian curvature K(x,y) = sech²(x) − sech²(y) continuously changes sign across the diagonals |x| = |y|.

### Proved Theorems (all with PEGB)

**Theorem 1 — Metric Positive Definiteness:**
- `g₁₁_pos`: sech²(y) > 0 everywhere
- `g₂₂_pos`: cosh²(x) > 0 everywhere  
- `det_pos`: metric determinant > 0 everywhere
- Example: at origin, both components equal 1 (Euclidean)
- Generalization: `diagonal_metric_pos_def` for arbitrary positive functions
- Boundary: `g₁₁_bounded_below` — sech² bounded away from 0 on compact sets

**Theorem 2 — Phase Boundary Characterization:**
- `curvature_eq_zero_iff`: K(x,y) = 0 ⟺ |x| = |y| (the diagonals)
- Examples: K(1,1) = 0, K(t,−t) = 0, K(0,0) = 0
- Generalization: `even_strictly_mono_diff_zero_iff` for arbitrary even strictly monotone functions
- Boundary: fails for non-even functions (counterexample provided)

**Theorem 3 — Curvature Sign Theorem:**
- `curvature_pos_of_elliptic`: K > 0 when |x| < |y| (elliptic region)
- `curvature_neg_of_hyperbolic`: K < 0 when |x| > |y| (hyperbolic region)
- Examples: K(0,1) > 0, K(1,0) < 0
- Generalization: `sign_change_general` for arbitrary StrictAnti even functions
- Boundary: constant functions give K = 0 everywhere

**Additional results:** `curvature_abs_lt_one` (global curvature bound), `curvature_swap` (antisymmetry K(x,y) = −K(y,x)), `curvature_origin` (flat at origin), `sech_sq_eq_one_iff`, `sech_sq_pos`, `sech_sq_le_one`.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).