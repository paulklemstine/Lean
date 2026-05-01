/-! # CatalogBuild.Bridges.DifferentialCalculusBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6
-/

import Mathlib

/-- **Rolle's Theorem**: If f is continuous on [a,b] and f(a) = f(b),
then ∃ c ∈ (a,b) with f'(c) = 0. Foundational case of the MVT. -/
theorem rolles_theorem {f : ℝ → ℝ} {a b : ℝ}
    (hab : a < b) (hf : ContinuousOn f (Set.Icc a b)) (hfeq : f a = f b) :
    ∃ c ∈ Set.Ioo a b, deriv f c = 0 :=
  exists_deriv_eq_zero hab hf hfeq


/-- **Derivative ≥ 0 implies monotone**: If f'(x) ≥ 0 on a convex set,
then f is monotone. This is the signature application of the MVT. -/
theorem deriv_nonneg_imp_mono {D : Set ℝ} (hD : Convex ℝ D) {f : ℝ → ℝ}
    (hf_cont : ContinuousOn f D) (hf_diff : DifferentiableOn ℝ f (interior D))
    (hf : ∀ x ∈ interior D, 0 ≤ deriv f x) :
    MonotoneOn f D :=
  monotoneOn_of_deriv_nonneg hD hf_cont hf_diff hf


/-- **Derivative ≤ 0 implies antitone**: The dual. -/
theorem deriv_nonpos_imp_antitone {D : Set ℝ} (hD : Convex ℝ D) {f : ℝ → ℝ}
    (hf_cont : ContinuousOn f D) (hf_diff : DifferentiableOn ℝ f (interior D))
    (hf : ∀ x ∈ interior D, deriv f x ≤ 0) :
    AntitoneOn f D :=
  antitoneOn_of_deriv_nonpos hD hf_cont hf_diff hf


/-- **Derivative > 0 implies strictly monotone**: Strict version. -/
theorem deriv_pos_imp_strict_mono {D : Set ℝ} (hD : Convex ℝ D) {f : ℝ → ℝ}
    (hf_cont : ContinuousOn f D)
    (hf : ∀ x ∈ interior D, 0 < deriv f x) :
    StrictMonoOn f D :=
  strictMonoOn_of_deriv_pos hD hf_cont hf


/-- **f''(x) ≥ 0 implies convex**: Second derivative test for convexity.
Connects differential calculus to Jensen's inequality:
convex functions are exactly those satisfying Jensen. -/
theorem deriv2_nonneg_imp_convex {D : Set ℝ} (hD : Convex ℝ D) {f : ℝ → ℝ}
    (hf_cont : ContinuousOn f D) (hf_diff : DifferentiableOn ℝ f (interior D))
    (hf_diff2 : DifferentiableOn ℝ (deriv f) (interior D))
    (hf : ∀ x ∈ interior D, 0 ≤ deriv^[2] f x) :
    ConvexOn ℝ D f :=
  convexOn_of_deriv2_nonneg hD hf_cont hf_diff hf_diff2 hf


/-- Differentiable functions are continuous.
Establishes the smoothness hierarchy: differentiable → continuous. -/
theorem differentiable_imp_continuous {f : ℝ → ℝ}
    (hf : Differentiable ℝ f) :
    Continuous f :=
  hf.continuous

