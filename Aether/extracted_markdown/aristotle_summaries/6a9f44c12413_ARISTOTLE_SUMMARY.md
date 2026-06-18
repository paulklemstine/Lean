# Summary of changes for run 0a99e3df-e86f-4e1a-ac3d-9eeda1bf8869
# Lorentzian Equivalence via Hessian Descent — Complete Deliverables

## Formally Verified Mathematics (HessianDescent.lean)

A 454-line Lean 4 file with **zero sorries** and clean axioms (propext, Classical.choice, Quot.sound only). Contains:

### New Definitions (4 total)
1. **`MixedDirectionalLogConcave`** — Mixed directional log-concavity on polynomial coefficients: c(α + 2eᵢ)·c(α + 2eⱼ) ≤ c(α + eᵢ + eⱼ)²
2. **`AxisDirectionalLogConcave`** — Axis log-concavity: c(α + 2eᵢ)·c(α) ≤ c(α + eᵢ)²
3. **`HasExchangeSupport`** — M-convexity exchange property on polynomial support
4. **`HessianDescentCertificate`** — Bundled discrete certificate structure

### Main Theorems (12+ fully proved, 0 sorry)

**Theorem A: Forward Direction** (`lorentzian_implies_pairwise_det`): If a positive symmetric matrix has Lorentzian signature (at most one positive eigenvalue), then A(i,i)·A(j,j) ≤ A(i,j)² for all i,j. Uses by-contradiction with constructed orthogonal test vectors.

**Theorem B: 2×2 Full Equivalence** (`dim_two_equivalence`, `two_by_two_full_equivalence`): For 2×2 matrices, Lorentzian signature ⟺ det ≤ 0. Both directions proved with explicit witness construction (w = (1, b/a)).

**Theorem C: Counterexample** (`pairwise_det_not_sufficient_for_lorentzian`): The 3×3 matrix [[1,1,1],[1,1,−1],[1,−1,1]] satisfies all pairwise conditions but is NOT Lorentzian (eigenvalues 2,2,−1). Proved by showing all candidate witnesses w are forced to be zero, then constructing a positive-form test vector.

Additional proved theorems:
- `rank_one_lorentzian` — Rank-one matrices u⊗u always have Lorentzian signature
- `mixed_lc_geometric_mean` — Geometric mean bound from mixed LC
- `mixed_lc_smul` — Scaling preserves mixed LC (uses `nlinarith` with `sq_nonneg`)
- `dim_one_always_lorentzian` — 1×1 matrices are trivially Lorentzian
- `nonneg_counterexample_pairwise_det` — Second counterexample with nonneg entries
- `hessianDescent_sound_degree2` — Certificate soundness
- Various structural lemmas and closure properties

### Key Mathematical Finding
The pairwise 2×2 minor condition A(i,i)·A(j,j) ≤ A(i,j)² is **necessary** for Lorentzian signature in all dimensions but **sufficient only for n ≤ 2**. This was verified both formally (counterexample proof) and computationally (~10% of random 3×3 nonneg matrices satisfying the condition are not Lorentzian).

## Written Deliverables

- **ARTICLE.md** — 2,500-word popular science article on turning curvature into arithmetic
- **RESEARCH_PAPER.md** — Full research paper with abstract, theorems, algorithms, experiments, and references
- **FUTURE_DIRECTIONS.md** — 5 specific research directions with conjectures, tests, and domain bridges

## Python Code

- **demo.py** — 4-part demo: forward verification, counterexample search (confirming 2×2 equivalence with 0/10,000 counterexamples and 3×3 failure with ~100/1,000), certificate checking, dimension sweep
- **algorithms.py** — Certificate checking library with full type hints and docstrings
- **applications.py** — Applications to matroid theory (exchange checking for uniform matroids), statistical physics (Ising partition functions), and convexity certification
- **viz_hessian_descent.py** — 3-panel matplotlib visualization

## Other Deliverables

- **interactive_demo.html** — Interactive 2×2 Lorentzian explorer with sliders and real-time phase diagram
- **PACKAGE.json** — Complete JSON bundle of all artifacts
- **hessian_descent_viz.png** — Generated visualization