import MachineLearning.ShefferFunction.Lean.ShefferAlgebra

/-!
# The Lipschitz barrier for the Sheffer algebra

`ExtendedTheorems.lean` is written against three upstream modules that are absent from this
repository (`ShefferAI.Lean.UniversalApproximation`, `.FutureTheorems`, `.AdvancedTheorems`,
`.NewTheorems`).  The results it actually uses from them are the closure of the Sheffer
algebra under scalar multiplication and the exclusion of `x²`.  This file supplies both,
from scratch.

The exclusion of `x²` is the **Lipschitz barrier**: every Sheffer expression is globally
Lipschitz, because the only nonlinear building block, softplus, is `1`-Lipschitz and the
three closure operations (affine pre-composition, affine combination, composition) all
preserve global Lipschitz continuity.  Since `x ↦ x²` is not globally Lipschitz on `ℝ`, it
is not in the algebra — and hence the algebra is not closed under pointwise multiplication.
-/

open Real

noncomputable section

/-- The Sheffer algebra is closed under multiplication by a scalar. -/
theorem sheffer_smul_closed {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) (α : ℝ) :
    (fun x => α * f x) ∈ ShefferAlgebra := by
  have h := sheffer_affine_comb_closed hf hf α 0 0
  convert h using 1
  ext x
  ring

/-- **Every Sheffer expression is globally Lipschitz.**  The constant is produced by
structural induction: `1` for softplus, `C·|a|` for an affine pre-composition,
`|α|C₁ + |β|C₂` for an affine combination and `C₁C₂` for a composition. -/
theorem shefferExpr_lipschitz (e : ShefferExpr) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ x y : ℝ, |e.eval x - e.eval y| ≤ C * |x - y| := by
  induction e with
  | base =>
      exact ⟨1, zero_le_one, fun x y => by simpa using softplus_abs_sub_le x y⟩
  | affine_pre a b e ih =>
      obtain ⟨C, hC, h⟩ := ih
      refine ⟨C * |a|, by positivity, fun x y => ?_⟩
      have hstep := h (a * x + b) (a * y + b)
      have harg : |a * x + b - (a * y + b)| = |a| * |x - y| := by
        rw [show a * x + b - (a * y + b) = a * (x - y) by ring, abs_mul]
      simp only [ShefferExpr.eval]
      calc |e.eval (a * x + b) - e.eval (a * y + b)| ≤ C * |a * x + b - (a * y + b)| := hstep
        _ = C * |a| * |x - y| := by rw [harg]; ring
  | affine_comb α β γ e₁ e₂ ih₁ ih₂ =>
      obtain ⟨C₁, hC₁, h₁⟩ := ih₁
      obtain ⟨C₂, hC₂, h₂⟩ := ih₂
      refine ⟨|α| * C₁ + |β| * C₂, by positivity, fun x y => ?_⟩
      have hd : α * e₁.eval x + β * e₂.eval x + γ - (α * e₁.eval y + β * e₂.eval y + γ)
          = α * (e₁.eval x - e₁.eval y) + β * (e₂.eval x - e₂.eval y) := by ring
      have hax : |α * (e₁.eval x - e₁.eval y)| = |α| * |e₁.eval x - e₁.eval y| := abs_mul _ _
      have hbx : |β * (e₂.eval x - e₂.eval y)| = |β| * |e₂.eval x - e₂.eval y| := abs_mul _ _
      have h1 := h₁ x y
      have h2 := h₂ x y
      simp only [ShefferExpr.eval]
      calc |α * e₁.eval x + β * e₂.eval x + γ - (α * e₁.eval y + β * e₂.eval y + γ)|
          = |α * (e₁.eval x - e₁.eval y) + β * (e₂.eval x - e₂.eval y)| := by rw [hd]
        _ ≤ |α * (e₁.eval x - e₁.eval y)| + |β * (e₂.eval x - e₂.eval y)| := abs_add_le _ _
        _ = |α| * |e₁.eval x - e₁.eval y| + |β| * |e₂.eval x - e₂.eval y| := by rw [hax, hbx]
        _ ≤ (|α| * C₁ + |β| * C₂) * |x - y| := by
            have ha : (0 : ℝ) ≤ |α| := abs_nonneg α
            have hb : (0 : ℝ) ≤ |β| := abs_nonneg β
            nlinarith [abs_nonneg (x - y)]
  | comp e₁ e₂ ih₁ ih₂ =>
      obtain ⟨C₁, hC₁, h₁⟩ := ih₁
      obtain ⟨C₂, hC₂, h₂⟩ := ih₂
      refine ⟨C₁ * C₂, by positivity, fun x y => ?_⟩
      have hstep := h₁ (e₂.eval x) (e₂.eval y)
      have h2 := h₂ x y
      simp only [ShefferExpr.eval]
      calc |e₁.eval (e₂.eval x) - e₁.eval (e₂.eval y)| ≤ C₁ * |e₂.eval x - e₂.eval y| := hstep
        _ ≤ C₁ * (C₂ * |x - y|) := by nlinarith
        _ = C₁ * C₂ * |x - y| := by ring

/-- Every member of the Sheffer algebra is globally Lipschitz. -/
theorem sheffer_lipschitz {f : ℝ → ℝ} (hf : f ∈ ShefferAlgebra) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ x y : ℝ, |f x - f y| ≤ C * |x - y| := by
  obtain ⟨e, rfl⟩ := hf
  exact shefferExpr_lipschitz e

/-- **The Lipschitz barrier.**  `x ↦ x²` is not globally Lipschitz, hence not a Sheffer
function.  This is the structural obstruction behind `sheffer_not_mul_closed`. -/
theorem sq_not_mem_sheffer : (fun x : ℝ => x ^ 2) ∉ ShefferAlgebra := by
  intro hmem
  obtain ⟨C, hC, h⟩ := sheffer_lipschitz hmem
  have hx := h (C + 1) 0
  simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, sub_zero] at hx
  rw [abs_of_nonneg (by positivity), abs_of_nonneg (by linarith)] at hx
  nlinarith

end