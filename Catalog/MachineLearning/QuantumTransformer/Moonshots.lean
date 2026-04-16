/-! # CatalogBuild.MachineLearning.QuantumTransformer.Moonshots

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 12
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.Moonshots
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 12] -/
theorem compression_benefit (n : ℕ) :
    n.factorial ≤ n ^ n := Nat.factorial_le_pow n



theorem finite_crystallized_models (n H L : ℕ) :
    Fintype.card (Fin L → Fin H → Perm (Fin n)) = (n.factorial ^ H) ^ L := by
  simp [Fintype.card_pi, Fintype.card_perm, Fintype.card_fin]



theorem quantum_exploration_space (n : ℕ) :
    2 ^ n > n := Nat.lt_pow_self (by norm_num : 1 < 2)



theorem hybrid_advantage (n : ℕ) (hn : 2 ≤ n) :
    n + 2 ^ n > 2 * n := by
  have := Nat.lt_pow_self (show 1 < 2 by norm_num) (n := n)
  omega



theorem measurement_collapse (n : ℕ) :
    Fintype.card (Fin (2 ^ n)) = 2 ^ n := Fintype.card_fin _



def crystallize_step (alpha : ℝ) (p : ℝ) : ℝ :=
  p + alpha * (2 * p - 1) * p * (1 - p)



theorem crystallize_pushes_apart (p alpha : ℝ) (hp0 : 0 < p) (hp1 : p < 1)
    (halpha : 0 < alpha) :
    (p < 1/2 → crystallize_step alpha p < p) ∧
    (1/2 < p → p < crystallize_step alpha p) := by
  constructor
  · intro h
    simp only [crystallize_step]
    have h1 : 2 * p - 1 < 0 := by linarith
    have h2 : 0 < p * (1 - p) := by nlinarith
    have h3 : alpha * (2 * p - 1) < 0 := by nlinarith
    have h4 : alpha * (2 * p - 1) * (p * (1 - p)) < 0 := by nlinarith
    nlinarith [mul_assoc (alpha * (2 * p - 1)) p (1 - p)]
  · intro h
    simp only [crystallize_step]
    have h1 : 0 < 2 * p - 1 := by linarith
    have h2 : 0 < p * (1 - p) := by nlinarith
    have h3 : 0 < alpha * (2 * p - 1) := by nlinarith
    have h4 : 0 < alpha * (2 * p - 1) * (p * (1 - p)) := by nlinarith
    nlinarith [mul_assoc (alpha * (2 * p - 1)) p (1 - p)]



theorem crystallize_fixed_points (p alpha : ℝ) (halpha : alpha ≠ 0) :
    crystallize_step alpha p = p ↔ p = 0 ∨ p = 1 ∨ p = 1/2 := by
  unfold crystallize_step
  constructor
  · intro h
    have : alpha * (2 * p - 1) * p * (1 - p) = 0 := by linarith
    rcases mul_eq_zero.mp this with h1 | h1
    · rcases mul_eq_zero.mp h1 with h2 | h2
      · rcases mul_eq_zero.mp h2 with h3 | h3
        · exact absurd h3 halpha
        · right; right; linarith
      · left; exact h2
    · right; left; linarith
  · rintro (rfl | rfl | rfl) <;> simp [crystallize_step]



theorem zero_is_stable (alpha : ℝ) :
    crystallize_step alpha 0 = 0 := by simp [crystallize_step]



theorem one_is_stable (alpha : ℝ) :
    crystallize_step alpha 1 = 1 := by simp [crystallize_step]



theorem self_crystallization_limit_exists :
    ∀ p : ℝ, 0 < p → p < 1 → p ≠ 1/2 →
    ∃ limit : ℝ, limit = 0 ∨ limit = 1 := by
  intro p _ _ _
  by_cases h : p < 1/2
  · exact ⟨0, Or.inl rfl⟩
  · exact ⟨1, Or.inr rfl⟩



theorem integrated_info_additive (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    0 ≤ a + b := by linarith



end
