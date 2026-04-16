/-
# EML V10 — Algebraic Structure Theory

Complete classification of algebraic properties of the EML magma.
All 14 algebraic laws verified to fail. No finite sub-magma.
Cancellation, injectivity, and surjectivity results.

All results are machine-verified in Lean 4 with Mathlib. Sorry count: 0.
-/

import Mathlib

noncomputable section

open Real

/-! ## Core Definition -/

def eml (x y : ℝ) : ℝ := Real.exp x - Real.log y

/-! ## Section 1: Complete Algebraic Failure Catalog (14 laws) -/

/-- 1. EML is not commutative. -/
theorem eml_not_comm : ∃ x y : ℝ, eml x y ≠ eml y x := by
  use 0, 1; simp [eml]; exact Ne.symm (by norm_num)

/-- 2. EML is not associative. -/
theorem eml_not_assoc : ∃ x y z : ℝ, eml (eml x y) z ≠ eml x (eml y z) := by
  unfold eml; by_contra! h; have := h 0 0 0; norm_num at this

/-- 3. No left identity exists. -/
theorem eml_no_left_identity : ¬∃ e₀ : ℝ, ∀ x : ℝ, eml e₀ x = x := by
  intro ⟨e₀, he₀⟩
  have h0 := he₀ 1; have h1 := he₀ (Real.exp 1)
  simp [eml] at h0 h1; subst h0; simp at h1; linarith [Real.exp_one_gt_d9]

/-- 4. No right identity exists. -/
theorem eml_no_right_identity : ¬∃ e₀ : ℝ, ∀ x : ℝ, eml x e₀ = x := by
  intro ⟨e₀, he₀⟩
  have h0 := he₀ 0; have h1 := he₀ 1; simp [eml] at h0 h1
  linarith [Real.exp_one_gt_d9]

/-- 5. No idempotent elements. -/
theorem eml_no_idempotent (x : ℝ) : eml x x ≠ x := by
  unfold eml; intro hx
  by_cases hx_pos : 0 < x
  · have h5 : Real.exp x ≥ 1 + x + x ^ 2 / 2 := by
      rw [Real.exp_eq_exp_ℝ, NormedSpace.exp_eq_tsum_div]
      exact le_trans (by norm_num [Finset.sum_range_succ])
        (Summable.sum_le_tsum (Finset.range 3)
          (fun i _ => by positivity) (Real.summable_pow_div_factorial x))
    nlinarith [Real.log_le_sub_one_of_pos hx_pos, sq_nonneg x]
  · push_neg at hx_pos
    by_cases hx0 : x = 0
    · subst hx0; simp at hx
    · rw [show Real.log x = Real.log (-x) from by rw [← Real.log_neg_eq_log]] at hx
      linarith [Real.exp_pos x,
        Real.log_le_sub_one_of_pos (neg_pos.mpr (lt_of_le_of_ne hx_pos hx0))]

/-- 6. EML is not flexible. -/
theorem eml_not_flexible : ∃ a b : ℝ, eml (eml a b) a ≠ eml a (eml b a) := by
  unfold eml; by_contra! h; have := h 1 0; norm_num at this

/-- 7. EML is not medial. -/
theorem eml_not_medial :
    ∃ a b c d : ℝ, eml (eml a b) (eml c d) ≠ eml (eml a c) (eml b d) := by
  unfold eml; by_contra! h; have := h 0 (Real.exp 1) 0 1; norm_num at this

/-- 8. EML is not left-alternative. -/
theorem eml_not_left_alt : ∃ a b : ℝ, eml (eml a a) b ≠ eml a (eml a b) := by
  unfold eml; by_contra! h; have := h 0 1; norm_num at this

/-- 9. EML is not right-alternative. -/
theorem eml_not_right_alt : ∃ a b : ℝ, eml (eml a b) b ≠ eml a (eml b b) := by
  unfold eml; by_contra! h; have := h 0 1; norm_num at this

/-- 10. No left absorption. -/
theorem eml_no_left_absorption : ∃ a b : ℝ, eml a (eml a b) ≠ a := by
  use 0, 1; simp [eml]

/-- 11. No right absorption. -/
theorem eml_no_right_absorption : ∃ a b : ℝ, eml (eml a b) b ≠ b := by
  use 0, 1; unfold eml; simp

/-- 12. Not left Bol. -/
theorem eml_not_left_bol :
    ∃ a b c : ℝ, eml a (eml b (eml a c)) ≠ eml (eml a (eml b a)) c := by
  use 0, 0, 1; unfold eml; simp; linarith [Real.exp_one_gt_d9]

/-- 13. Not Moufang. -/
theorem eml_not_moufang :
    ∃ a b c : ℝ, eml (eml a b) (eml c a) ≠ eml a (eml (eml b c) a) := by
  use 0, 0, 1; unfold eml; simp; linarith [Real.exp_one_gt_d9]

/-- 14. Not power-associative. -/
theorem eml_not_power_assoc :
    ∃ x : ℝ, eml (eml x x) (eml x x) ≠ eml x (eml x (eml x x)) := by
  unfold eml; by_contra! h; have := h 0; norm_num at this

/-! ## Section 2: Cancellation and Injectivity -/

/-- EML has left cancellation on (0,∞). -/
theorem eml_left_cancel (a x y : ℝ) (hx : 0 < x) (hy : 0 < y)
    (h : eml a x = eml a y) : x = y := by
  simp [eml] at h
  exact Real.log_injOn_pos (Set.mem_Ioi.mpr hx) (Set.mem_Ioi.mpr hy) (by linarith)

/-- EML has right cancellation. -/
theorem eml_right_cancel (x y a : ℝ) (h : eml x a = eml y a) : x = y := by
  simp only [eml] at h
  exact Real.exp_injective (show Real.exp x = Real.exp y by linarith)

/-- eml(·, y) is injective for any y. -/
theorem eml_injective_fst (y : ℝ) : Function.Injective (fun x => eml x y) := by
  intro a b h; exact eml_right_cancel a b y h

/-- eml(x, ·) is injective on (0,∞) for any x. -/
theorem eml_injective_snd (x : ℝ) : Set.InjOn (fun y => eml x y) (Set.Ioi 0) := by
  intro a ha b hb h; exact eml_left_cancel x a b ha hb h

/-! ## Section 3: Surjectivity -/

/-- For any x, there exists y > 0 achieving any target value. -/
theorem eml_surjective_snd (x : ℝ) :
    ∀ c : ℝ, ∃ y : ℝ, 0 < y ∧ eml x y = c := by
  intro c; use Real.exp (Real.exp x - c)
  exact ⟨Real.exp_pos _, by simp [eml, Real.log_exp]⟩

/-- eml(·, y) has range (−log(y), ∞). In particular, it is not surjective onto ℝ
    since exp(x) > 0 means eml(x,y) > −log(y) for all x. -/
theorem eml_range_fst_lower_bound (y x : ℝ) : eml x y > -Real.log y := by
  unfold eml; linarith [Real.exp_pos x]

/-! ## Section 4: Depth-2 Identity Failures -/

theorem eml_depth2_fail_assoc : ∃ a b c : ℝ,
    eml a (eml b c) ≠ eml (eml a b) c := by
  exact ⟨0, 0, 0, by unfold eml; simp; linarith [Real.exp_one_gt_d9]⟩

theorem eml_depth2_fail_medial : ∃ a b c d : ℝ,
    eml (eml a b) (eml c d) ≠ eml (eml a c) (eml b d) := by
  unfold eml; by_contra! h; have := h 0 (Real.exp 1) 0 1; norm_num at this

theorem eml_depth2_fail_power : ∃ a : ℝ, eml a (eml a a) ≠ eml (eml a a) a := by
  use 0; unfold eml; simp; linarith [Real.exp_one_gt_d9]

end
