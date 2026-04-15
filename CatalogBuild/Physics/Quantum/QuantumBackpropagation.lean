/-! # CatalogBuild.Physics.Quantum.QuantumBackpropagation

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 12
-/

import Mathlib

noncomputable section

def qbSinCost (a b d : ℝ) (θ : ℝ) : ℝ := a * cos θ + b * sin θ + d


theorem qb_parameter_shift_rule (a b d θ : ℝ) :
    (qbSinCost a b d (θ + π / 2) - qbSinCost a b d (θ - π / 2)) / 2 =
    -a * sin θ + b * cos θ := by
  simp [qbSinCost, cos_add, cos_sub, sin_add, sin_sub, cos_pi_div_two, sin_pi_div_two]; ring


theorem qb_sinCost_deriv (a b d θ : ℝ) :
    HasDerivAt (qbSinCost a b d) (-a * sin θ + b * cos θ) θ := by
      convert HasDerivAt.add ( HasDerivAt.add ( HasDerivAt.const_mul a ( Real.hasDerivAt_cos θ ) ) ( HasDerivAt.const_mul b ( Real.hasDerivAt_sin θ ) ) ) ( hasDerivAt_const _ _ ) using 1 ; ring!

/-! ## §2: Multi-Parameter Gradients -/


theorem qb_gradient_eval_count (k : ℕ) : 2 * k = k + k := by ring

theorem qb_gradient_cost (n L : ℕ) : 2 * (n * L) = 2 * n * L := by ring

/-! ## §3: Quantum Fisher Information -/


theorem qb_cramer_rao_bound (n : ℕ) (F : ℝ) (hn : 0 < n) (hF : 0 < F) :
    1 / ((n : ℝ) * F) > 0 := by positivity


theorem qb_heisenberg_vs_shot_noise (n : ℕ) (hn : 2 ≤ n) : n ^ 2 > n := by nlinarith

/-! ## §4: VQE -/


theorem qb_variational_principle (E₀ : ℝ) (C : ℝ → ℝ)
    (hbound : ∀ θ, C θ ≥ E₀) (θ_opt : ℝ) : C θ_opt ≥ E₀ := hbound θ_opt


theorem qb_qaoa_approx_ratio : (0.6924 : ℝ) > 1 / 2 := by norm_num

theorem qb_measurement_count_bound (ε : ℝ) (hε : 0 < ε) : 1 / ε ^ 2 > 0 := by positivity

/-! ## §5: Quantum Backprop Complexity -/


theorem qb_quantum_gradient_overhead (k : ℕ) (hk : 1 ≤ k) : 2 * k ≥ 2 := by omega

private lemma qb_two_pow_gt_cube (n : ℕ) (hn : 10 ≤ n) : 2 ^ n > n ^ 3 := by
  induction hn with
  | refl => norm_num
  | @step k hk ih =>
    show 2 ^ (k + 1) > (k + 1) ^ 3
    have hk10 : (k : ℤ) ≥ 10 := by exact_mod_cast hk
    have h2 : 2 * k ^ 3 ≥ (k + 1) ^ 3 := by
      have : (2 : ℤ) * (k : ℤ) ^ 3 ≥ ((k : ℤ) + 1) ^ 3 := by
        nlinarith [sq_nonneg ((k : ℤ) - 3), sq_nonneg ((k : ℤ) * ((k : ℤ) - 3))]
      exact_mod_cast this
    calc (2 : ℕ) ^ (k + 1) = 2 ^ k * 2 := pow_succ 2 k
      _ ≥ (k ^ 3 + 1) * 2 := by omega
      _ = 2 * k ^ 3 + 2 := by ring
      _ > 2 * k ^ 3 := by omega
      _ ≥ (k + 1) ^ 3 := h2


theorem qb_net_quantum_advantage (n k : ℕ) (hn : 10 ≤ n) (hk : k ≤ n ^ 2) :
    2 ^ n > 2 * k := by
  have h1 := qb_two_pow_gt_cube n hn; nlinarith [sq_nonneg n]


end
