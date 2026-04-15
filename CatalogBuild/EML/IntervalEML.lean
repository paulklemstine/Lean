/-! # CatalogBuild.EML.IntervalEML

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The real EML operator: eml(x, y) = exp(x) - ln(y). -/
def emlI (x y : ℝ) : ℝ := Real.exp x - Real.log y


/-- EML is strictly increasing in its first argument. -/
theorem emlI_strictMono_fst (y : ℝ) : StrictMono (fun x => emlI x y) := by
  intro a b hab
  simp only [emlI]
  linarith [Real.exp_strictMono hab]


/-- EML is monotone (non-decreasing) in its first argument. -/
theorem emlI_mono_fst (y : ℝ) : Monotone (fun x => emlI x y) :=
  (emlI_strictMono_fst y).monotone


/-- EML is strictly decreasing in its second argument on (0, ∞). -/
theorem emlI_strictAnti_snd (x : ℝ) : StrictAntiOn (fun y => emlI x y) (Ioi 0) := by
  intro a ha b hb hab
  simp only [emlI]
  linarith [Real.log_lt_log (mem_Ioi.mp ha) hab]


/-- **Interval EML Theorem**: For x ∈ [x_lo, x_hi] and y ∈ [y_lo, y_hi] with y_lo > 0,
the EML output lies in [eml(x_lo, y_hi), eml(x_hi, y_lo)].
This is the foundation of verified interval arithmetic on the OISCC. -/
theorem emlI_interval_enclosure
    {x x_lo x_hi y y_lo y_hi : ℝ}
    (hx_lo : x_lo ≤ x) (hx_hi : x ≤ x_hi)
    (hy_lo_pos : 0 < y_lo) (hy_lo : y_lo ≤ y) (hy_hi : y ≤ y_hi) :
    emlI x_lo y_hi ≤ emlI x y ∧ emlI x y ≤ emlI x_hi y_lo := by
  constructor
  · simp only [emlI]
    have h1 : Real.exp x_lo ≤ Real.exp x := Real.exp_le_exp.mpr hx_lo
    have h2 : Real.log y ≤ Real.log y_hi :=
      Real.log_le_log (lt_of_lt_of_le hy_lo_pos hy_lo) hy_hi
    linarith
  · simp only [emlI]
    have h1 : Real.exp x ≤ Real.exp x_hi := Real.exp_le_exp.mpr hx_hi
    have h2 : Real.log y_lo ≤ Real.log y :=
      Real.log_le_log hy_lo_pos hy_lo
    linarith


/-- EML(x, y) ≥ 1 + x - ln(y) (from exp(x) ≥ 1 + x). -/
theorem emlI_lower_bound (x y : ℝ) :
    x + 1 - Real.log y ≤ emlI x y := by
  simp only [emlI]
  linarith [Real.add_one_le_exp x]


/-- For y ≥ 1, EML(0, y) ≤ 1. -/
theorem emlI_zero_ge_one (y : ℝ) (hy : 1 ≤ y) :
    emlI 0 y ≤ 1 := by
  simp only [emlI, Real.exp_zero]
  linarith [Real.log_nonneg hy]


/-- For any y, EML(0, y) = 1 - ln(y). -/
theorem emlI_at_zero (y : ℝ) :
    emlI 0 y = 1 - Real.log y := by
  simp [emlI, Real.exp_zero]


/-- Double exp tower: eml(eml(x, 1), 1) = exp(exp(x)). -/
theorem emlI_double_exp (x : ℝ) :
    emlI (emlI x 1) 1 = Real.exp (Real.exp x) := by
  simp [emlI, Real.log_one]


/-- Triple exp tower: eml(eml(eml(x, 1), 1), 1) = exp(exp(exp(x))). -/
theorem emlI_triple_exp (x : ℝ) :
    emlI (emlI (emlI x 1) 1) 1 = Real.exp (Real.exp (Real.exp x)) := by
  simp [emlI, Real.log_one]


/-- The diagonal map is bounded below by 1 for 0 < x ≤ 1. -/
theorem emlDiag_ge_one (x : ℝ) (hx : 0 < x) (hx1 : x ≤ 1) :
    1 ≤ emlDiag x := by
  simp only [emlDiag, emlI]
  have h1 : x + 1 ≤ Real.exp x := Real.add_one_le_exp x
  have h2 : Real.log x ≤ 0 := Real.log_nonpos (le_of_lt hx) hx1
  linarith


theorem emlDiag_no_fixed_point (x : ℝ) (hx : 0 < x) :
    emlDiag x > x := by
  -- We need exp(x) - ln(x) > x for x > 0.
  have h_exp_ln_x_gt_x : ∀ x : ℝ, 0 < x → Real.exp x - Real.log x > x := by
    intro x hx;
    have := Real.add_one_le_exp ( x - 1 );
    rw [ show x = ( x - 1 ) + 1 by ring, Real.exp_add ];
    have := Real.exp_one_gt_d9.le ; norm_num1 at * ; nlinarith [ Real.log_le_sub_one_of_pos ( by linarith : 0 < x - 1 + 1 ) ];
  exact h_exp_ln_x_gt_x x hx


end
