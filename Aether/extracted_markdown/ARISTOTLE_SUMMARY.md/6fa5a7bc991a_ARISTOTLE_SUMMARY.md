# Summary of changes for run ebb3cba3-3ab9-4852-a80b-587f7ce98195
Delivered a self-contained Lean 4 formalization of percolation thresholds, building on the existing finite-graph foundations in `Catalog/Algebra/Percolation.lean`.

**New files (both build clean, `sorry` = 0 on all theorems):**

1. `Catalog/Physics/PercolationThreshold.lean` (imports Mathlib). An abstract theory of the critical probability:
   - `OrderParameter` structure (monotone, non-negative order parameter `θ(p)`), with `pc := sSup {p | θ p = 0}`.
   - `theta_eq_zero_of_lt_pc` and `theta_pos_of_gt_pc`: the defining dichotomy — no percolation strictly below `p_c`, percolation strictly above it.
   - `dual_involutive`, `dual_fixedPoint_iff`: the duality involution `p ↦ 1-p` has unique fixed point `1/2`.
   - `selfDual_pc_eq_half`, `square_bond_pc_eq_half`, `triangular_site_pc_eq_half`: self-dual / self-matching thresholds equal `1/2`.
   - `CrossingFunction.crossing_at_half` and `crossing_half_unique`: the self-dual square-crossing probability is `1/2` (uniquely, under strict monotonicity) — the combinatorial core behind Cardy/conformal invariance.

2. `Catalog/Physics/PercolationCrossing.lean`. The deterministic endpoints bracketing the phase transition on the `n×n` grid:
   - `allClosed_no_crossing` (`θ(0)=0`), `gridGraph_reachable_column` (vertical reachability backbone), and `allOpen_crossing` (`θ(1)=1`, via an explicit column walk).

Each file contains `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and short `-- !-- comment -- !--` proof sketches. The work intentionally formalizes the self-dual cases exactly while documenting (in the notebook and future directions) that the square *site* threshold has no known closed form because that lattice is not self-dual.

`FUTURE_DIRECTIONS.md` (project root) gives a synthesis, a results summary table, and 5 falsifiable research directions (deriving square-bond self-duality from planar duality; a monotone-coupling theorem to derive `θ` monotonicity via Russo's formula; rigorous bounds for square site percolation; the triangular star–triangle relation; and a discrete Cardy/conformal-invariance observable), each with a "The key insight is..." sentence and a "Why now?" justification.