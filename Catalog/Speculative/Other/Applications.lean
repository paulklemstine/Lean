/-! # CatalogBuild.Speculative.Other.Applications

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 8
-/

import Mathlib

theorem binaural_beat_bound (fL fR : ℝ) (hL : 0 < fL) (hR : 0 < fR) :
    |fL - fR| < fL + fR := by
  cases abs_cases ( fL - fR ) <;> linarith


theorem nyquist_bound (B fs : ℝ) (hB : 0 < B) (hfs : fs < 2 * B) :
    fs / (2 * B) < 1 := by
  rwa [ div_lt_one ( by positivity ) ]


theorem stereoscopic_disparity_decreasing
    (d : ℝ) (hd : 0 < d) :
    StrictAntiOn (fun z => d / z) (Set.Ioi 0) := by
  exact fun x hx y hy hxy => mul_lt_mul_of_pos_left ( inv_strictAnti₀ hx hxy ) hd


theorem sigmoid_range_bounded (x : ℝ) :
    0 < 1 / (1 + Real.exp (-x)) ∧ 1 / (1 + Real.exp (-x)) < 1 := by
  exact ⟨ by positivity, by rw [ div_lt_iff₀ ] <;> linarith [ Real.exp_pos ( -x ) ] ⟩


theorem autoheal_defect_convergence
    (defect : ℕ → ℝ) (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1)
    (h_step : ∀ n, defect (n + 1) ≤ r * defect n)
    (h_nonneg : ∀ n, 0 ≤ defect n) :
    Filter.Tendsto defect Filter.atTop (nhds 0) := by
  -- By induction, we can show that defect n ≤ r^n * defect 0 for all n.
  have h_induction : ∀ n, defect n ≤ r ^ n * defect 0 := by
    exact fun n => Nat.recOn n ( by norm_num ) fun n ih => by rw [ pow_succ', mul_assoc ] ; nlinarith [ h_step n, h_nonneg n ] ;
  exact squeeze_zero ( fun n => h_nonneg n ) h_induction ( by simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1 ) tendsto_const_nhds )


theorem verified_repair_correct
    {State : Type*} (spec : State → Prop)
    (repair : State → State)
    (h_repair_meets_spec : ∀ s, spec (repair s)) (s : State) :
    spec (repair s) := by
  exact h_repair_meets_spec s


theorem wavefront_coherence_bound (n : ℕ) (phases : Fin n → ℝ) :
    ‖∑ i : Fin n, Complex.exp (↑(phases i) * Complex.I)‖ ≤ n := by
  exact le_trans ( norm_sum_le _ _ ) ( by simp +decide [ Complex.norm_exp ] )


theorem phase_deformation_monotone
    {α : Type*} [Preorder α]
    (f : α → α) (hm : Monotone f) (a b : α) (hab : a ≤ b) :
    f a ≤ f b := by
  exact hm hab
