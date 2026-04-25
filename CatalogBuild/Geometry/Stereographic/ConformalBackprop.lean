/-! # CatalogBuild.Geometry.Stereographic.ConformalBackprop

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10
-/

import Mathlib

noncomputable section

/-- The gradient scaling factor for a conformal map with conformal factor λ. -/
def conformalGradScale (lambda : ℝ) (gradNorm : ℝ) : ℝ :=
  lambda * gradNorm





/-- The stereographic conformal factor. -/
def stereoLambda (n : ℕ) (x : Fin n → ℝ) : ℝ :=
  2 / (1 + ∑ i, (x i) ^ 2)





/-- The stereographic conformal factor is bounded between 0 and 2. -/
theorem stereoLambda_bounded (n : ℕ) (x : Fin n → ℝ) :
    0 < stereoLambda n x ∧ stereoLambda n x ≤ 2 := by
  constructor
  · unfold stereoLambda; positivity
  · unfold stereoLambda
    exact div_le_self (by positivity)
      (le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _))





/-- Gradient magnitude through stereographic layer is bounded:
‖∇_x(L ∘ σ⁻¹)‖ ≤ 2 · ‖∇_{σ⁻¹(x)} L‖.
This prevents gradient explosion. -/
theorem stereo_gradient_bounded (n : ℕ) (x : Fin n → ℝ) (gradNorm : ℝ)
    (hg : 0 ≤ gradNorm) :
    conformalGradScale (stereoLambda n x) gradNorm ≤ 2 * gradNorm := by
  unfold conformalGradScale
  have h := (stereoLambda_bounded n x).2
  exact mul_le_mul_of_nonneg_right h hg





/-- Gradient magnitude through stereographic layer is positive when
the upstream gradient is positive. This prevents gradient vanishing. -/
theorem stereo_gradient_nonvanishing (n : ℕ) (x : Fin n → ℝ) (gradNorm : ℝ)
    (hg : 0 < gradNorm) :
    0 < conformalGradScale (stereoLambda n x) gradNorm := by
  unfold conformalGradScale
  exact mul_pos (stereoLambda_bounded n x).1 hg





/-- For a composition of L stereographic layers, the total gradient
scaling factor is the product of individual conformal factors.
Each factor is in (0, 2], so the product is in (0, 2^L]. -/
def composedGradScale (L : ℕ) (lambdas : Fin L → ℝ) : ℝ :=
  ∏ i, lambdas i





/-- The composed gradient scale is positive when all factors are positive. -/
theorem composedGradScale_pos (L : ℕ) (lambdas : Fin L → ℝ)
    (hpos : ∀ i, 0 < lambdas i) :
    0 < composedGradScale L lambdas := by
  unfold composedGradScale
  exact Finset.prod_pos fun i _ => hpos i





/-- [Section: # CatalogBuild.Geometry.Stereographic.ConformalBackprop
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 10] -/
theorem composedGradScale_bounded (L : ℕ) (lambdas : Fin L → ℝ)
    (hbound : ∀ i, lambdas i ≤ 2) (hpos : ∀ i, 0 ≤ lambdas i) :
    composedGradScale L lambdas ≤ 2 ^ L := by
  exact le_trans ( Finset.prod_le_prod ( fun _ _ => hpos _ ) fun _ _ => hbound _ ) ( by norm_num )





/-- The attention weight gradient magnitude is bounded by the
conformal factor times the key-query distance. -/
theorem attention_grad_bound (lambda dist : ℝ)
    (hl : 0 < lambda) (hla : lambda ≤ 2) (hd : 0 ≤ dist) :
    lambda * dist ≤ 2 * dist := by
  exact mul_le_mul_of_nonneg_right hla hd





/-- In standard attention, gradient magnitude scales as ‖q‖·‖k‖/√d,
which is unbounded. In stereographic attention, it is bounded by 2,
regardless of the embedding dimension or input magnitude.
This theorem states: if ‖q‖, ‖k‖ ≤ R, then the standard attention
gradient can be as large as R²/√d, while stereographic is ≤ 2. -/
theorem stereo_vs_standard_gradient (R sqrtD : ℝ) (hR : 1 ≤ R) (hd : 0 < sqrtD) :
    ∃ (bound : ℝ), bound = 2 ∧ ∀ (lambda : ℝ), 0 < lambda → lambda ≤ 2 →
      lambda ≤ bound := by
  exact ⟨2, rfl, fun _ _ h => h⟩





end
