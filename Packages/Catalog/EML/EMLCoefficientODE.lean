import Mathlib

/-!
# Concrete First-Order ODEs with Exponential–Logarithmic Coefficients

This file realizes the abstract first-order solution calculus of
`EML.EMLLogDerivHom` over the *analytic* differential field of real functions,
where the derivation is the genuine derivative and `exp`/`log` are the genuine
transcendental functions.  The central object is the linear ODE

    y′(x) = c(x)·y(x)

with an **exponential–logarithmic coefficient** `c`, i.e. `c` built from `Real.exp`
and `Real.log`.  The master construction is the antiderivative substitution
`y = exp ∘ F`: if `F′ = c` then `(exp ∘ F)′ = c·(exp ∘ F)`, so every coefficient
that is an explicit derivative gives an explicit closed-form solution.

We instantiate this for the three archetypal EML coefficients:

* **logarithmic** `c(x) = log x`, solved by `y(x) = exp(x·log x − x)`
  (the antiderivative `∫ log = x log x − x`, the "Stirling exponent");
* **exponential** `c(x) = exp x`, solved by `y(x) = exp(exp x)` (the
  Gompertz/double-exponential);
* **power / inverse-linear** `c(x) = a/x`, solved by `y(x) = exp(a·log x) = x^a`.

We also prove the infinitesimal **uniqueness-up-to-constant** law: any solution of
`y′ = c·y` divided by the canonical solution `exp ∘ F` has zero derivative at each
point — the analytic shadow of `EML.EMLDifferentialGalois.firstOrder_ratio_isConstant`.

## Main results

* `hasDerivAt_exp_comp_solves` — master lemma: `F′(x) = c ⇒ (exp ∘ F)′(x) = c·exp(F x)`.
* `solves_log_coeff` — `(fun x => exp(x·log x − x))` solves `y′ = (log x)·y` for `x > 0`.
* `solves_exp_coeff` — `(fun x => exp(exp x))` solves `y′ = (exp x)·y`.
* `solves_power_coeff` — `(fun x => exp(a·log x))` solves `y′ = (a/x)·y` for `x > 0`.
* `solution_ratio_hasDerivAt_zero` — infinitesimal uniqueness up to a constant.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the abstract "exp of an antiderivative" solution of
`y′ = a·y` should specialize, with `a` an explicit exp/log expression, to genuine
closed-form solutions of real ODEs with exponential–logarithmic coefficients —
turning the algebraic homomorphism of `EMLLogDerivHom` into honest analysis.

Experiment (Experimenter): the master lemma is exactly `HasDerivAt.exp`
(`(exp ∘ F)′ = exp(F)·F′`) with a `mul_comm`. The three instances each amount to
computing one antiderivative: `∫ log = x log x − x` (via the product rule
`(x log x)′ = log x + 1` and subtracting `x`), `∫ exp = exp`, and `∫ a/x = a log x`
(`const_mul` on `hasDerivAt_log`). The only non-formal step is the algebraic
simplification `1·log x + x·x⁻¹ − 1 = log x`, closed by `mul_inv_cancel₀` + `ring`.
Uniqueness-up-to-constant is the quotient rule `HasDerivAt.div` with the numerator
of the derivative collapsing to `0` by `ring`.

Analysis (Analyst): these are the canonical members of each EML coefficient class.
The logarithmic case is notable: `exp(x log x − x)` is the continuous Stirling
exponent, so the ODE `y′ = (log x) y` is the differential equation satisfied by the
Gamma-function-like growth — an EML ODE whose solution is genuinely transcendental
(not Liouvillian over `ℝ(x)` in the naive sense), in contrast to the power case
`x^a` which is algebraic-over-`ℝ(x)` only for rational `a`.

Critique (Critic): non-vacuous and load-bearing — the `x > 0` hypotheses are
exactly what `Real.hasDerivAt_log` needs, and dropping them makes the statements
false (`log` is not differentiable at `0`). Every proof produces a genuine
`HasDerivAt` witness verified by Mathlib's calculus, not `rfl`/`decide`.

Synthesis (PI): with `EMLLogDerivHom` (algebra) and this file (analysis), the
catalog now has the *positive* theory of first-order EML ODEs — explicit solutions
for the log, exp, and power coefficient classes plus infinitesimal uniqueness —
complementing the *negative* (obstruction) theory for the second-order Airy
equation in `EMLDiffObstruction`/`EMLAiryRiccati`.
-- !-- Lab Notes -- !--
-/

open Real

namespace EMLCoefficientODE

/-! ### Master construction: exponential of an antiderivative -/

/-- **Master lemma.** If `F` has derivative `c` at `x`, then `exp ∘ F` solves the
first-order linear ODE `y′ = c·y` at `x`: its derivative there is `c·exp(F x)`.
Every coefficient `c` that is an explicit derivative `F′` yields the explicit
solution `exp ∘ F`. -/
theorem hasDerivAt_exp_comp_solves (F : ℝ → ℝ) (c x : ℝ) (h : HasDerivAt F c x) :
    HasDerivAt (fun t => Real.exp (F t)) (c * Real.exp (F x)) x := by
  simpa [mul_comm] using h.exp

/-! ### Logarithmic coefficient: `y′ = (log x)·y` -/

/-- **Logarithmic-coefficient ODE.** For `x > 0`, the "Stirling exponent"
`y(x) = exp(x·log x − x)` solves `y′ = (log x)·y`.  Here `x·log x − x` is the
antiderivative `∫ log`. -/
theorem solves_log_coeff (x : ℝ) (hx : 0 < x) :
    HasDerivAt (fun t => Real.exp (t * Real.log t - t))
      (Real.log x * Real.exp (x * Real.log x - x)) x := by
  have hF : HasDerivAt (fun t => t * Real.log t - t) (Real.log x) x := by
    have h1 : HasDerivAt (fun t => t * Real.log t) (1 * Real.log x + x * x⁻¹) x :=
      (hasDerivAt_id x).mul (Real.hasDerivAt_log (ne_of_gt hx))
    have h2 : HasDerivAt (fun t => t * Real.log t - t) (1 * Real.log x + x * x⁻¹ - 1) x :=
      h1.sub (hasDerivAt_id x)
    have heq : 1 * Real.log x + x * x⁻¹ - 1 = Real.log x := by
      rw [mul_inv_cancel₀ (ne_of_gt hx)]; ring
    rwa [heq] at h2
  simpa [mul_comm] using hF.exp

/-! ### Exponential coefficient: `y′ = (exp x)·y` -/

/-- **Exponential-coefficient ODE.** The double-exponential `y(x) = exp(exp x)`
solves `y′ = (exp x)·y` everywhere. -/
theorem solves_exp_coeff (x : ℝ) :
    HasDerivAt (fun t => Real.exp (Real.exp t))
      (Real.exp x * Real.exp (Real.exp x)) x := by
  simpa [mul_comm] using (Real.hasDerivAt_exp x).exp

/-! ### Power / inverse-linear coefficient: `y′ = (a/x)·y` -/

/-- **Power-coefficient ODE.** For `x > 0` and any exponent `a`, the power
`y(x) = exp(a·log x) = x^a` solves `y′ = (a/x)·y`.  This is the elementary EML
coefficient `a/x = a·(log x)′`. -/
theorem solves_power_coeff (a x : ℝ) (hx : 0 < x) :
    HasDerivAt (fun t => Real.exp (a * Real.log t))
      ((a / x) * Real.exp (a * Real.log x)) x := by
  have hF : HasDerivAt (fun t => a * Real.log t) (a / x) x := by
    simpa [div_eq_mul_inv] using (Real.hasDerivAt_log (ne_of_gt hx)).const_mul a
  simpa [mul_comm] using hF.exp

/-! ### Infinitesimal uniqueness up to a constant -/

/-- **Uniqueness up to a constant (infinitesimal form).** If `y` solves
`y′ = c·y` at `x` and `F′(x) = c`, then the ratio `y / (exp ∘ F)` has derivative
`0` at `x`.  This is the analytic counterpart of
`EMLDifferentialGalois.firstOrder_ratio_isConstant`: any two solutions of a
first-order EML equation differ by a constant. -/
theorem solution_ratio_hasDerivAt_zero (y F : ℝ → ℝ) (c x : ℝ)
    (hy : HasDerivAt y (c * y x) x) (hF : HasDerivAt F c x) :
    HasDerivAt (fun t => y t / Real.exp (F t)) 0 x := by
  have hz : HasDerivAt (fun t => Real.exp (F t)) (Real.exp (F x) * c) x := hF.exp
  have hzne : Real.exp (F x) ≠ 0 := Real.exp_ne_zero _
  have hdiv := hy.div hz hzne
  have heq :
      (c * y x * Real.exp (F x) - y x * (Real.exp (F x) * c)) / (Real.exp (F x)) ^ 2 = 0 := by
    ring
  rwa [heq] at hdiv

end EMLCoefficientODE