/-! # CatalogBuild.OISCC.Derivatives

Auto-generated from theorem catalog database.
Domain: OISCC
Declarations: 10
-/

import Mathlib

noncomputable section

def EML_calc (a b : ℝ) : ℝ := Real.exp a - Real.log b

def diag_calc (x : ℝ) : ℝ := Real.exp x - Real.log x


theorem EML_hasDerivAt_fst (a b : ℝ) :
    HasDerivAt (EML_calc · b) (Real.exp a) a := by
  convert (Real.hasDerivAt_exp a).sub (hasDerivAt_const a (Real.log b)) using 1; ring


theorem EML_hasDerivAt_snd (a b : ℝ) (hb : 0 < b) :
    HasDerivAt (EML_calc a ·) (-(b⁻¹)) b := by
  convert (hasDerivAt_const b (Real.exp a)).sub (Real.hasDerivAt_log hb.ne') using 1; ring


theorem diag_hasDerivAt (x : ℝ) (hx : 0 < x) :
    HasDerivAt diag_calc (Real.exp x - x⁻¹) x :=
  (Real.hasDerivAt_exp x).sub (Real.hasDerivAt_log hx.ne')


theorem diag_differentiable : DifferentiableOn ℝ diag_calc (Set.Ioi 0) :=
  fun x hx => (diag_hasDerivAt x hx).differentiableAt.differentiableWithinAt


theorem diag_deriv_pos (x : ℝ) (hx : 1 ≤ x) : Real.exp x - x⁻¹ > 0 := by
  have h1 : Real.exp x ≥ Real.exp 1 := Real.exp_le_exp.mpr hx
  have h2 : x⁻¹ ≤ 1 := inv_le_one_of_one_le₀ hx
  linarith [Real.exp_one_gt_d9]


theorem EML_gradient_nonzero (a : ℝ) : Real.exp a ≠ 0 := (Real.exp_pos a).ne'


theorem EML_gradient_norm_sq (a b : ℝ) (hb : 0 < b) :
    (Real.exp a) ^ 2 + (b⁻¹) ^ 2 > 0 := by positivity


theorem diag_convex_on : ConvexOn ℝ (Set.Ioi 0) diag_calc := by
  apply ConvexOn.sub;
  · have h_convex : ConvexOn ℝ Set.univ Real.exp := by
      exact convexOn_exp;
    exact h_convex.subset ( Set.subset_univ _ ) ( convex_Ioi _ );
  · exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi )


end
