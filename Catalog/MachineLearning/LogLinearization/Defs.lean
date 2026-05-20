import Mathlib

/-!
# Log-Linearization: Definitions

This file defines the core concepts for the theory of log-linearization
on the positive quadrant: multiplicative separability, log-additive separability,
the interaction defect, and the log pullback.
-/

open Real

/-- A function `f : ℝ → ℝ → ℝ` is **multiplicatively separable on the positive quadrant**
if there exist continuous positive factors `φ` and `ψ` such that `f(x,y) = φ(x) · ψ(y)`
for all positive `x, y`. -/
def MultiplicativelySeparableOnPos (f : ℝ → ℝ → ℝ) : Prop :=
  ∃ φ ψ : ℝ → ℝ,
    Continuous φ ∧ Continuous ψ ∧
    (∀ ⦃x : ℝ⦄, 0 < x → 0 < φ x) ∧
    (∀ ⦃y : ℝ⦄, 0 < y → 0 < ψ y) ∧
    ∀ ⦃x y : ℝ⦄, 0 < x → 0 < y → f x y = φ x * ψ y

/-- A function `f : ℝ → ℝ → ℝ` is **log-additively separable on the positive quadrant**
if there exist continuous functions `u` and `v` such that
`log(f(x,y)) = u(log x) + v(log y)` for all positive `x, y`. -/
def LogAdditivelySeparableOnPos (f : ℝ → ℝ → ℝ) : Prop :=
  ∃ u v : ℝ → ℝ,
    Continuous u ∧ Continuous v ∧
    ∀ ⦃x y : ℝ⦄, 0 < x → 0 < y →
      Real.log (f x y) = u (Real.log x) + v (Real.log y)

/-- The **interaction defect** of a bivariate function at four points.
For multiplicatively separable functions, this equals 1. -/
noncomputable def interactionDefect (f : ℝ → ℝ → ℝ)
    (x₁ x₂ y₁ y₂ : ℝ) : ℝ :=
  (f x₁ y₁ * f x₂ y₂) / (f x₁ y₂ * f x₂ y₁)

/-- The **log pullback** of `f` via exponentiation:
`G(s,t) = log(f(eˢ, eᵗ))`. This converts the positive quadrant to all of `ℝ²`. -/
noncomputable def logPullback (f : ℝ → ℝ → ℝ) (s t : ℝ) : ℝ :=
  Real.log (f (Real.exp s) (Real.exp t))

/-- The **log interaction defect** measures the additive failure of log-separability
at four points. It equals `log(interactionDefect f ...)` when all values are positive. -/
noncomputable def logInteractionDefect (f : ℝ → ℝ → ℝ)
    (x₁ x₂ y₁ y₂ : ℝ) : ℝ :=
  Real.log (f x₁ y₁) + Real.log (f x₂ y₂) -
  Real.log (f x₁ y₂) - Real.log (f x₂ y₁)