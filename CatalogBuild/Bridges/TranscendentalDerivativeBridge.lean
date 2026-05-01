/-! # CatalogBuild.Bridges.TranscendentalDerivativeBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 9
-/

import Mathlib

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


/-- **Chain rule for log**: (log ∘ f)'(x) = f'(x) / f(x).
LOGARITHMIC DIFFERENTIATION: the standard technique for
differentiating products and powers. -/
theorem chain_rule_log {f : ℝ → ℝ} {f' x : ℝ}
    (hf : HasDerivAt f f' x) (hf0 : f x ≠ 0) :
    HasDerivAt (fun y => Real.log (f y)) (f' / f x) x :=
  HasDerivAt.log hf hf0


/-- **Derivative of exp∘f**: deriv (exp ∘ f)(x) = exp(f(x)) · f'(x).
The derivative form of the chain rule for exp. -/
theorem deriv_exp_comp_rule {f : ℝ → ℝ} {x : ℝ}
    (hf : DifferentiableAt ℝ f x) :
    deriv (fun y => Real.exp (f y)) x = Real.exp (f x) * deriv f x :=
  deriv_exp hf


/-- **exp is differentiable at every point**. -/
theorem exp_differentiable_at (x : ℝ) :
    DifferentiableAt ℝ Real.exp x :=
  Real.differentiableAt_exp

