import Mathlib

/-! # Aristotle Loop Verification Theorems

Verified properties of the Aristotle Loop: regret bounds, EML function
analysis, and superadditivity.
-/

open scoped BigOperators

namespace AristotleLoop

/-! ## 1. Regret Theory -/

noncomputable def regret {D : Type*} [Fintype D] (optimal actual : D → ℝ) : ℝ :=
  ∑ d : D, (optimal d - actual d)

theorem regret_nonneg {D : Type*} [Fintype D] (optimal actual : D → ℝ)
    (h_opt : ∀ d, 0 ≤ optimal d) (h_act : ∀ d, actual d ≤ optimal d) :
    0 ≤ regret optimal actual := by
  unfold regret; apply Finset.sum_nonneg; intro d _; linarith [h_opt d, h_act d]

theorem ucb_ge_mean (mean : ℝ) (n_total n_prompt : ℕ) (c : ℝ) (hc : 0 ≤ c) :
    mean ≤ mean + c * Real.sqrt (Real.log n_total / n_prompt) := by
  linarith [mul_nonneg hc (Real.sqrt_nonneg (Real.log n_total / n_prompt))]

/-! ## 2. Catalog Size Bounds -/

theorem information_bound (N M : ℕ) (hM : 0 < M) : N * Real.log M ≥ 0 := by
  positivity

/-! ## 3. EML Function Properties -/

noncomputable def EML (a b : ℝ) : ℝ := Real.exp a - Real.log b

theorem eml_exp (a : ℝ) : EML a 1 = Real.exp a := by
  unfold EML; simp only [Real.log_one, sub_zero]

theorem eml_shift_log (b : ℝ) (hb : 0 < b) : EML 0 b = 1 - Real.log b := by
  unfold EML; simp only [Real.exp_zero, sub_zero]

theorem eml_closure_contains_affine (c1 : ℝ) (c2 : ℝ) (hc1 : 0 < c1) :
    ∃ a b : ℝ, EML a b = c1 + c2 := by
  use Real.log c1, Real.exp (-c2)
  unfold EML; simp only [Real.log_exp, Real.exp_log hc1, sub_neg_eq_add]

theorem eml_add_bridge (a a' : ℝ) :
    EML (a + a') 1 = EML a 1 * EML a' 1 := by
  unfold EML; simp only [Real.log_one, sub_zero, Real.exp_add]

theorem eml_div_eq_sub (a a' : ℝ) :
    EML a 1 / EML a' 1 = EML (a - a') 1 := by
  unfold EML; simp only [Real.log_one, sub_zero]
  -- After simp: Real.exp a / Real.exp a' = Real.exp (a - a')
  -- This is exactly Real.exp_sub applied as a division
  exact (Real.exp_sub a a').symm

/-! ## 4. Superadditivity -/

structure DomainSynergy (D : Type*) [Fintype D] where
  synergy : D → D → ℝ
  synergy_nonneg : ∀ i j, 0 ≤ synergy i j
  self_synergy : ∀ i, 1 ≤ synergy i i

theorem synergy_superadditivity (D : Type*) [Fintype D] (S : DomainSynergy D)
    (values : D → ℝ) (hv : ∀ i, 0 ≤ values i) :
    ∑ i, values i ≤ ∑ i, ∑ j, S.synergy i j * values j := by
  apply Finset.sum_le_sum; intro i _
  calc values i = 1 * values i := (one_mul _).symm
    _ ≤ S.synergy i i * values i := mul_le_mul_of_nonneg_right (S.self_synergy i) (hv i)
    _ ≤ ∑ j, S.synergy i j * values j := by
        apply Finset.single_le_sum (fun j _ => mul_nonneg (S.synergy_nonneg i j) (hv j))
        exact Finset.mem_univ i

/-! ## 5. Fixed Point Uniqueness -/

theorem contractive_unique (f : ℝ → ℝ) (c : ℝ)
    (_hc0 : 0 ≤ c) (hc1 : c < 1)
    (h_contract : ∀ x y, |f x - f y| ≤ c * |x - y|) :
    ∀ a b, f a = a → f b = b → a = b := by
  intro a b ha hb
  by_contra h_ne
  have h_contract_ab : |f a - f b| ≤ c * |a - b| := h_contract a b
  rw [ha, hb] at h_contract_ab
  have h_pos : 0 < |a - b| := abs_sub_pos.mpr h_ne
  -- From c < 1 and 0 < |a-b|: c * |a-b| < |a-b|
  have : c * |a - b| < 1 * |a - b| := mul_lt_mul_of_pos_right hc1 h_pos
  linarith

end AristotleLoop