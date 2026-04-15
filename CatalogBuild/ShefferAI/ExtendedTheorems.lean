/-! # CatalogBuild.ShefferAI.ExtendedTheorems

Auto-generated from theorem catalog database.
Domain: ShefferAI
Declarations: 19
-/

import Mathlib
import ShefferAI.Lean.AdvancedTheorems
import ShefferAI.Lean.FutureTheorems
import ShefferAI.Lean.NewTheorems
import ShefferAI.Lean.ShefferAlgebra
import ShefferAI.Lean.SoftplusBasic
import ShefferAI.Lean.UniversalApproximation

noncomputable section

/-- Every Sheffer expression defines a continuous function. -/
theorem sheffer_expr_continuous (e : ShefferExpr) : Continuous e.eval := by
  induction e with
  | base => exact softplus_continuous
  | affine_pre a b e ih =>
    simp only [ShefferExpr.eval]
    exact ih.comp ((continuous_const.mul continuous_id).add continuous_const)
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ =>
    simp only [ShefferExpr.eval]
    exact ((continuous_const.mul ih₁).add (continuous_const.mul ih₂)).add continuous_const
  | comp e₁ e₂ ih₁ ih₂ =>
    exact ih₁.comp ih₂


/-- Every Sheffer expression defines a differentiable function.
This is the "Smoothness Barrier": any non-differentiable function
is structurally excluded from the Sheffer algebra. -/
theorem sheffer_expr_differentiable (e : ShefferExpr) : Differentiable ℝ e.eval := by
  induction e with
  | base => exact softplus_differentiable
  | affine_pre a b e ih =>
    show Differentiable ℝ (fun x => e.eval (a * x + b))
    exact ih.comp ((differentiable_const a |>.mul differentiable_id).add (differentiable_const b))
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ =>
    show Differentiable ℝ (fun x => α * e₁.eval x + β * e₂.eval x + γ)
    exact ((differentiable_const α |>.mul ih₁).add
           (differentiable_const β |>.mul ih₂)).add (differentiable_const γ)
  | comp e₁ e₂ ih₁ ih₂ =>
    exact ih₁.comp ih₂


/-- Corollary: every function in the Sheffer algebra is differentiable. -/
theorem sheffer_algebra_differentiable {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    Differentiable ℝ f := by
  obtain ⟨e, he⟩ := hf
  rw [he]
  exact sheffer_expr_differentiable e


/-- Corollary: every function in the Sheffer algebra is continuous. -/
theorem sheffer_algebra_continuous {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    Continuous f := by
  exact (sheffer_algebra_differentiable hf).continuous


lemma abs_not_differentiableAt_zero : ¬ DifferentiableAt ℝ (fun x : ℝ => |x|) 0 := by
  exact not_differentiableAt_abs_zero


/-- The absolute value function is NOT in the Sheffer algebra. -/
theorem abs_not_mem_sheffer : (fun x : ℝ => |x|) ∉ ShefferAlgebra := by
  intro h
  exact abs_not_differentiableAt_zero (sheffer_algebra_differentiable h 0)


lemma max_zero_not_differentiableAt_zero :
    ¬ DifferentiableAt ℝ (fun x : ℝ => max 0 x) 0 := by
  intro h_diff
  have h_abs : DifferentiableAt ℝ (fun x : ℝ => |x|) 0 := by
    convert h_diff.const_mul 2 |> DifferentiableAt.sub <| differentiableAt_id using 1 ; ext ; norm_num ; ring;
    cases max_cases ( 0 : ℝ ) ‹_› <;> cases abs_cases ‹_› <;> linarith;
  exact not_differentiableAt_abs_zero h_abs


/-- ReLU (= max(0, x)) is NOT in the Sheffer algebra.
This is a fundamental structural difference between softplus and ReLU:
softplus is smooth, ReLU has a kink at 0. -/
theorem relu_not_mem_sheffer : (fun x : ℝ => max 0 x) ∉ ShefferAlgebra := by
  intro h
  exact max_zero_not_differentiableAt_zero (sheffer_algebra_differentiable h 0)


/-- σ(x) = log 2 if and only if x = 0 -/
theorem softplus_eq_log2_iff (x : ℝ) : softplus x = Real.log 2 ↔ x = 0 := by
  constructor
  · intro h
    have h0 : softplus 0 = Real.log 2 := softplus_zero
    exact softplus_strictMono.injective (h.trans h0.symm)
  · intro h
    rw [h]
    exact softplus_zero


/-- σ(2x) ≤ 2σ(x): softplus of double is at most double of softplus.
Immediate corollary of subadditivity σ(x+y) ≤ σ(x) + σ(y). -/
theorem softplus_double_ineq (x : ℝ) : softplus (2 * x) ≤ 2 * softplus x := by
  have h := softplus_subadditive x x
  have : x + x = 2 * x := by ring
  rw [this] at h
  linarith


/-- σ(3x) ≤ 3σ(x): subadditivity for triple -/
theorem softplus_triple_ineq (x : ℝ) : softplus (3 * x) ≤ 3 * softplus x := by
  have h12 := softplus_subadditive (2 * x) x
  have h2 := softplus_double_ineq x
  have : 2 * x + x = 3 * x := by ring
  rw [this] at h12
  linarith


/-- The Sheffer algebra is closed under negation -/
theorem sheffer_neg_closed {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    (fun x => -f x) ∈ ShefferAlgebra := by
  have := sheffer_smul_closed hf (-1)
  convert this using 1
  ext x; ring


/-- The Sheffer algebra is NOT closed under pointwise multiplication.
Proof: x ∈ ShefferAlg (identity), so if closed under multiplication,
x · x = x² ∈ ShefferAlg. But x² ∉ ShefferAlg by the Lipschitz barrier. -/
theorem sheffer_not_mul_closed :
    ¬ ∀ f g : ℝ → ℝ, f ∈ ShefferAlgebra → g ∈ ShefferAlgebra →
      (fun x => f x * g x) ∈ ShefferAlgebra := by
  intro h
  have hid := id_mem_sheffer
  have hmul := h _ _ hid hid
  have h_eq : (fun x : ℝ => (fun x => x) x * (fun x => x) x) = (fun x : ℝ => x ^ 2) := by
    ext x; ring
  rw [h_eq] at hmul
  exact sq_not_mem_sheffer hmul


theorem softplus_surjective_pos (y : ℝ) (hy : y > 0) :
    ∃ x : ℝ, softplus x = y := by
  use Real.log ( Real.exp y - 1 );
  unfold softplus; rw [ Real.exp_log ] <;> norm_num [ Real.exp_pos, hy ] ;


theorem sigmoid_surjective_unit (y : ℝ) (hy0 : 0 < y) (hy1 : y < 1) :
    ∃ x : ℝ, logisticSigmoid x = y := by
  unfold logisticSigmoid;
  exact ⟨ Real.log ( y / ( 1 - y ) ), by rw [ Real.exp_log ( div_pos hy0 ( sub_pos.mpr hy1 ) ), div_eq_iff ] <;> nlinarith [ div_mul_cancel₀ y ( ne_of_gt ( sub_pos.mpr hy1 ) ) ] ⟩


theorem sigmoid_logit_inverse (y : ℝ) (hy0 : 0 < y) (hy1 : y < 1) :
    logisticSigmoid (Real.log (y / (1 - y))) = y := by
  unfold logisticSigmoid;
  rw [ Real.exp_log ( div_pos hy0 ( sub_pos.mpr hy1 ) ), div_eq_iff ] <;> nlinarith [ div_mul_cancel₀ y ( by linarith : ( 1 - y ) ≠ 0 ) ]


/-- |σ(x) - σ(y)| ≤ |x - y| restated without LipschitzWith -/
theorem softplus_diff_le (x y : ℝ) :
    |softplus x - softplus y| ≤ |x - y| := by
  have h := softplus_lipschitz
  have := h.dist_le_mul x y
  simp [dist_eq_norm, Real.norm_eq_abs] at this
  linarith


/-- σ(x + c) is in the Sheffer algebra for any constant c -/
theorem softplus_translate_mem_sheffer (c : ℝ) :
    (fun x => softplus (x + c)) ∈ ShefferAlgebra := by
  have := sheffer_affine_pre_closed softplus_mem_sheffer 1 c
  convert this using 1
  ext x; simp


/-- S(x) + S(-x) = 1 restated -/
theorem sigmoid_sum_one (x : ℝ) : logisticSigmoid x + logisticSigmoid (-x) = 1 :=
  sigmoid_complement x


end
