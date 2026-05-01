import Mathlib

/-! # Transcendental Derivative Bridge

Proves derivative properties of exp and log:
1. exp'(x) = exp(x) — exp is its own derivative (FIXED POINT of differentiation)
2. Chain rule for exp: (exp ∘ f)'(x) = exp(f(x)) · f'(x)
3. Chain rule for log: (log ∘ f)'(x) = f'(x) / f(x) — logarithmic differentiation
4. exp is strictly monotone (via derivative > 0)
5. exp is everywhere positive
6. exp and exp∘f are differentiable whenever f is

The FIXED POINT property exp' = exp makes exp the most important
function in mathematics: eigenfunction of differentiation.
-/

namespace TranscendentalDerivativeBridge

/-! ## Section 1: The Exponential Function -/

/-- **exp is its own derivative**: HasDerivAt exp (exp x) x.
    exp is a FIXED POINT of the differentiation operator.
    THE defining property of the exponential function. -/
theorem exp_deriv_self (x : ℝ) :
    HasDerivAt Real.exp (Real.exp x) x :=
  Real.hasDerivAt_exp x

/-- **Chain rule for exp**: (exp ∘ f)'(x) = exp(f(x)) · f'(x).
    The most important chain rule in calculus. -/
theorem chain_rule_exp {f : ℝ → ℝ} {f' x : ℝ}
    (hf : HasDerivAt f f' x) :
    HasDerivAt (fun y => Real.exp (f y)) (Real.exp (f x) * f') x :=
  HasDerivAt.exp hf

/-- **exp composed with differentiable function is differentiable**. -/
theorem differentiable_exp_comp {f : ℝ → ℝ}
    (hf : Differentiable ℝ f) :
    Differentiable ℝ fun x => Real.exp (f x) :=
  Differentiable.exp hf

/-- **exp is differentiable everywhere on ℝ**. -/
theorem exp_differentiable : Differentiable ℝ Real.exp :=
  Real.differentiable_exp

/-- **exp is strictly increasing**: exp' > 0 ⟹ exp is StrictMono.
    Follows from deriv > 0 via the MVT (DifferentialCalculusBridge). -/
theorem exp_strict_mono : StrictMono Real.exp :=
  Real.exp_strictMono

/-- **exp is everywhere positive**: exp(x) > 0 for all x.
    Fundamental property: exp never touches zero. -/
theorem exp_positive (x : ℝ) : 0 < Real.exp x :=
  Real.exp_pos x

/-! ## Section 2: The Logarithm -/

/-- **Chain rule for log**: (log ∘ f)'(x) = f'(x) / f(x).
    LOGARITHMIC DIFFERENTIATION: the standard technique for
    differentiating products and powers. -/
theorem chain_rule_log {f : ℝ → ℝ} {f' x : ℝ}
    (hf : HasDerivAt f f' x) (hf0 : f x ≠ 0) :
    HasDerivAt (fun y => Real.log (f y)) (f' / f x) x :=
  HasDerivAt.log hf hf0

/-! ## Section 3: Derivative of exp∘f = exp·f' -/

/-- **Derivative of exp∘f**: deriv (exp ∘ f)(x) = exp(f(x)) · f'(x).
    The derivative form of the chain rule for exp. -/
theorem deriv_exp_comp_rule {f : ℝ → ℝ} {x : ℝ}
    (hf : DifferentiableAt ℝ f x) :
    deriv (fun y => Real.exp (f y)) x = Real.exp (f x) * deriv f x :=
  deriv_exp hf

/-! ## Section 4: Exp is differentiable at every point -/

/-- **exp is differentiable at every point**. -/
theorem exp_differentiable_at (x : ℝ) :
    DifferentiableAt ℝ Real.exp x :=
  Real.differentiableAt_exp

end TranscendentalDerivativeBridge
