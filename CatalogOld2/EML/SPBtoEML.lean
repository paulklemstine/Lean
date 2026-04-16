/-! # CatalogBuild.EML.SPBtoEML

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 9
-/

import Mathlib

noncomputable section

theorem log_spb_norm (x y : ℝ) (h : 1 - x * y ≠ 0) :
    log (1 + (spb x y) ^ 2) =
    log (1 + x ^ 2) + log (1 + y ^ 2) - 2 * log |1 - x * y| := by
  convert congr_arg Real.log ( spb_norm_ratio x y h ) using 1;
  rw [ Real.log_div, Real.log_mul ] <;> first | positivity | aesop;


theorem eml_is_neg_log (y : ℝ) : eml 0 y = 1 - log y := by simp [eml]

theorem eml_identity_val : eml 0 1 = 1 := by simp [eml, Real.log_one]

theorem exp_arctan_spb_mul (x y : ℝ) (h : 0 < 1 - x * y) :
    exp (arctan (spb x y)) = exp (arctan x) * exp (arctan y) := by
  rw [arctan_spb_add x y h, Real.exp_add]


theorem wick_rotation (x y : ℝ) :
    spb x (-y) = (x - y) / (1 + x * y) := by
  unfold spb; ring_nf


def cauchyEntropy (x : ℝ) : ℝ := log (1 + x ^ 2)


theorem cauchyEntropy_nonneg (x : ℝ) : 0 ≤ cauchyEntropy x := by
  unfold cauchyEntropy; apply Real.log_nonneg; linarith [sq_nonneg x]


theorem cauchyEntropy_eq_zero_iff (x : ℝ) : cauchyEntropy x = 0 ↔ x = 0 := by
  constructor;
  · intro hx;
    contrapose! hx;
    exact ne_of_gt ( Real.log_pos <| by nlinarith [ mul_self_pos.2 hx ] );
  · unfold cauchyEntropy; aesop;


theorem cauchyEntropy_spb (x y : ℝ) (h : 1 - x * y ≠ 0) :
    cauchyEntropy (spb x y) =
    cauchyEntropy x + cauchyEntropy y - 2 * log |1 - x * y| :=
  log_spb_norm x y h


end
