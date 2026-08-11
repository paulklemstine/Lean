/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The unbalanced 4-cycle achieves spectral radius `√2`

For a *signed* graph, the signed adjacency matrix `B = (b_ij)` has
`b_ij = σ(i,j)` if `{i,j}` is an edge and `0` otherwise, where `σ` assigns a sign
`±1` to each edge.  The classical Δ-bound (developed in
`Novelty/SignedGraphSpectralEquality.lean`) says every eigenvalue `μ` satisfies
`|μ| ≤ Δ`, the maximum degree.

This file treats the **unbalanced 4-cycle** `C₄`: the cycle on vertices
`0,1,2,3` with edges `{0,1},{1,2},{2,3},{3,0}` given signs `+,+,+,-` so that the
product of signs around the cycle is `-1` (this is what "unbalanced" means).  We
prove, entirely by direct matrix computation and *without* invoking the general
Bilu–Linial existence theorem, that:

* `B_unbalanced` — the product of the four edge signs around the cycle is `-1`.
* `B_sq_eq_two_smul_one` — `B² = 2·I` by direct computation.
* `B_eigenvalue_sq_eq_two` — hence every eigenvalue `μ` (with a nonzero
  eigenvector) satisfies `μ² = 2`.
* `B_eigenvalue_abs_eq_sqrt_two` — so `|μ| = √2`: the spectral radius is exactly
  `√2`.
* `B_degree` / `B_maxDeg_bound` — the maximum degree is `Δ = 2`, so the trivial
  Δ-bound only gives `|μ| ≤ 2`, whereas the true value `√2 < 2` (`sqrt_two_lt_two`)
  is a strict improvement for this specific signing.

This is a self-contained companion to `Novelty/SignedGraphSpectralEquality.lean`.
-/
import Mathlib
import Novelty.SignedGraphSpectralEquality

open Matrix

namespace UnbalancedC4

/-- The signed adjacency matrix of the unbalanced 4-cycle on vertices `0,1,2,3`
with edges `{0,1},{1,2},{2,3},{3,0}` and signs `+,+,+,-`.  The product of the
signs around the cycle is `(+1)(+1)(+1)(-1) = -1`, so the cycle is unbalanced. -/
def B : Matrix (Fin 4) (Fin 4) ℝ := !![0,1,0,-1; 1,0,1,0; 0,1,0,1; -1,0,1,0]

/-- `B` is symmetric. -/
theorem B_isSymm : B.IsSymm := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [B, Matrix.transpose_apply]

/-- Every entry of `B` is a sign `-1`, `0`, or `1`. -/
theorem B_entries (i j : Fin 4) : B i j = -1 ∨ B i j = 0 ∨ B i j = 1 := by
  fin_cases i <;> fin_cases j <;> simp [B]

/-- `B` has no loops (zero diagonal). -/
theorem B_diag (i : Fin 4) : B i i = 0 := by
  fin_cases i <;> simp [B]

/-- **Unbalanced.** The product of the four edge signs around the cycle
`0→1→2→3→0` equals `-1`. -/
theorem B_unbalanced : B 0 1 * B 1 2 * B 2 3 * B 3 0 = -1 := by
  simp [B]

/-- **Key computation.** `B² = 2·I`. -/
theorem B_sq_eq_two_smul_one : B * B = 2 • (1 : Matrix (Fin 4) (Fin 4) ℝ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [B, Matrix.mul_apply, Fin.sum_univ_four] <;> norm_num

/-- Every eigenvalue `μ` of `B` (with a nonzero eigenvector) satisfies `μ² = 2`. -/
theorem B_eigenvalue_sq_eq_two (v : Fin 4 → ℝ) (μ : ℝ) (hv : v ≠ 0)
    (heig : B *ᵥ v = μ • v) : μ ^ 2 = 2 := by
  -- Applying `B` twice gives `μ² • v` on one hand and `(B*B) *ᵥ v = 2 • v` on the
  -- other, so `(μ² - 2) • v = 0`; a nonzero coordinate of `v` forces `μ² = 2`.
  have key : (μ ^ 2) • v = (2 : ℝ) • v := by
    have h1 : B *ᵥ (B *ᵥ v) = (μ ^ 2) • v := by
      rw [heig, Matrix.mulVec_smul, heig, smul_smul]; ring_nf
    have h2 : B *ᵥ (B *ᵥ v) = (2 : ℝ) • v := by
      rw [Matrix.mulVec_mulVec, B_sq_eq_two_smul_one]
      ext i; simp [Matrix.mulVec, dotProduct, Matrix.one_apply, two_mul, Pi.smul_apply]
    rw [← h1, h2]
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hv
  have hc := congr_fun key i
  simp only [Pi.smul_apply, smul_eq_mul] at hc
  exact mul_right_cancel₀ hi hc

/-- **Spectral radius.** Every eigenvalue `μ` of `B` (with a nonzero eigenvector)
has absolute value exactly `√2`. -/
theorem B_eigenvalue_abs_eq_sqrt_two (v : Fin 4 → ℝ) (μ : ℝ) (hv : v ≠ 0)
    (heig : B *ᵥ v = μ • v) : |μ| = Real.sqrt 2 := by
  have h := B_eigenvalue_sq_eq_two v μ hv heig
  rw [← Real.sqrt_sq_eq_abs, h]

/-- Every vertex of the 4-cycle has degree `2`: the absolute row sums are all `2`. -/
theorem B_degree (i : Fin 4) : ∑ j, |B i j| = 2 := by
  fin_cases i <;> simp [B, Fin.sum_univ_four] <;> norm_num

/-- **Δ-bound for this graph.** Since the maximum degree is `Δ = 2`, the classical
bound only yields `|μ| ≤ 2`. -/
theorem B_maxDeg_bound (v : Fin 4 → ℝ) (μ : ℝ) (hv : v ≠ 0)
    (heig : B *ᵥ v = μ • v) : |μ| ≤ 2 :=
  SignedGraphSpectral.eigenvalue_abs_le_maxDeg B v μ 2 hv heig
    (fun i => le_of_eq (B_degree i))

/-- The achieved spectral radius `√2` is strictly smaller than the Δ-bound `2`. -/
theorem sqrt_two_lt_two : Real.sqrt 2 < 2 := by
  nlinarith [Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0), Real.sqrt_nonneg 2]

/-- **Strict improvement.** For the unbalanced 4-cycle, the actual spectral radius
`√2` is strictly below the trivial max-degree bound `2`. -/
theorem improved_over_maxDeg (v : Fin 4 → ℝ) (μ : ℝ) (hv : v ≠ 0)
    (heig : B *ᵥ v = μ • v) : |μ| = Real.sqrt 2 ∧ Real.sqrt 2 < 2 :=
  ⟨B_eigenvalue_abs_eq_sqrt_two v μ hv heig, sqrt_two_lt_two⟩

end UnbalancedC4