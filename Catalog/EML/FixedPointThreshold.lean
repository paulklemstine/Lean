import Mathlib
import EML.FixedPointConvergence

/-!
# EML Fixed-Point Theorem: The Sharp Existence Threshold

This file is a *critical / adversarial* companion to `EML.FixedPointConvergence`
and `EML.FixedPointRate`, which prove that the EML single operator
`f(x) = exp(a) · log(b·x + c)` contracts to a unique fixed point on a suitable
invariant interval, and that a concrete instance (`c = 100`) exists.

The original conjecture states a *specific test case*: `a ∈ (0,1)`, `b = 1`,
`c ∈ (0,1)`. The concrete-instance file deliberately used a large `c` and
remarked that small `c` "is genuinely harder". This file resolves the test case
**negatively and sharply**:

* For `b = 1` and *any* `x` in the natural domain `x + c > 0`, the residual
  `f(x) - x` is bounded above by the single number `exp(a)·(a-1) + c`, attained
  exactly when `x + c = exp(a)`.
* Consequently a fixed point can exist in the domain **only if**
  `c ≥ exp(a)·(1 - a)`. This is the sharp existence threshold.
* For the literal test value `a = 1/2, c = 1/2` (and a whole region of the
  conjecture's `(0,1)×(0,1)` box) **no fixed point exists at all** — so the
  conjecture, taken literally, is false.
* On the threshold itself, `c = exp(a)·(1-a)`, the unique candidate fixed point
  `x* = exp(a) - c` has derivative *exactly* `1`: it is neutral, never a
  contraction. So the boundary is also outside the contraction regime.

## Main results

* `EMLIterOp.residual_le` — `f(x) - x ≤ exp(a)·(a-1) + c` on the domain.
* `EMLIterOp.no_fixedPoint_of_subcritical` — no domain fixed point when
  `exp(a)·(a-1) + c < 0`.
* `EMLIterOp.no_fixedPoint_half_half` — concrete falsification of the test case.
* `EMLIterOp.fixedPoint_imp_c_ge_threshold` — existence forces `c ≥ exp(a)(1-a)`.
* `EMLIterOp.threshold_fixedPoint_neutral` — at the threshold the fixed point is
  neutral (`f'(x*) = 1`), so not a contraction.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The conjecture's own literal test case `b=1`,
`c ∈ (0,1)`, `a ∈ (0,1)` should *fail*: for small `c` the map `log(x+c)` dips too
far negative for `exp(a)·log(x+c)` to climb back to the diagonal. There should be
a clean closed-form threshold in `c` separating "fixed point exists" from "no
fixed point".

Experiment (Experimenter): Maximize the residual `g(x) = exp(a)·log(x+c) - x`
over the domain `x + c > 0`. Substituting `u = x + c` reduces the problem to
maximizing `exp(a)·log u - u`, whose maximum is at `u = exp(a)` with value
`exp(a)·(a-1)`. The whole estimate collapses to the elementary inequality
`log s ≤ s - 1` (`Real.log_le_sub_one_of_pos`) after the rescaling `s = u/exp(a)`.
Numerically, for `a = c = 1/2` the maximum residual is `≈ -0.324 < 0`, so the
diagonal is never met.

Analysis (Analyst): The decisive structural fact is that the residual's maximum
is a *single transcendental number* `exp(a)·(a-1) + c`, linear in `c`. Existence
of a fixed point is therefore equivalent (necessary direction proved here) to a
one-line inequality `c ≥ exp(a)·(1-a)`. The earlier `c = 2` and `c = 100`
instances satisfy it with room to spare; the test-case region `(0,1)×(0,1)` mostly
violates it because `exp(a)·(1-a) → 1` as `a → 0`.

Critique (Critic): Is the falsification an artifact of `Real.log`'s junk value on
negatives? No — we restrict to the genuine domain `x + c > 0`, exactly the
hypothesis (`arg_pos`) under which the whole catalog's contraction theory is
stated. (On the full line `Real.log` uses `log|x+c|` and an unphysical crossing
reappears, which is precisely why the domain restriction is the honest statement.)
Is the boundary case a loophole? No: `threshold_fixedPoint_neutral` shows the
boundary fixed point has `f' = 1`, so it is never a contraction either.

Synthesis (PI): The convergence theory is correct but its hypotheses are *not
vacuous in the other direction*: there is a sharp, closed-form admissibility
threshold `c ≥ exp(a)(1-a)`, and the conjecture's advertised `c ∈ (0,1)` test
case lies (largely) below it. This both falsifies the literal conjecture and
pins down the exact parameter window where the catalog's positive results apply.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set

namespace EMLIterOp

/-- The pointwise residual bound: on the natural domain `x + c > 0`, the EML
operator with `b = 1` satisfies `f(x) - x ≤ exp(a)·(a-1) + c`. The bound is the
maximum of `g(x) = exp(a)·log(x+c) - x`, attained when `x + c = exp(a)`, and
reduces to `log s ≤ s - 1`. -/
theorem residual_le (a c x : ℝ) (hx : 0 < x + c) :
    EMLIterOp a 1 c x - x ≤ exp a * (a - 1) + c := by
  have hea : 0 < Real.exp a := Real.exp_pos a
  have hu : (0 : ℝ) < x + c := hx
  have hs : 0 < (x + c) / Real.exp a := by positivity
  have h := Real.log_le_sub_one_of_pos hs
  rw [Real.log_div (ne_of_gt hu) (Real.exp_ne_zero a), Real.log_exp] at h
  have h2 := mul_le_mul_of_nonneg_left h hea.le
  rw [mul_sub, mul_sub] at h2
  have hcancel : Real.exp a * ((x + c) / Real.exp a) = x + c := by field_simp
  rw [hcancel] at h2
  have hf : EMLIterOp a 1 c x = Real.exp a * Real.log (x + c) := by
    simp [EMLIterOp, one_mul]
  rw [hf]
  nlinarith [h2]

/-- **No fixed point below the threshold.** If `exp(a)·(a-1) + c < 0`, the EML
operator with `b = 1` has no fixed point in its natural domain `x + c > 0`. -/
theorem no_fixedPoint_of_subcritical (a c : ℝ)
    (hsub : exp a * (a - 1) + c < 0) :
    ∀ x : ℝ, 0 < x + c → EMLIterOp a 1 c x ≠ x := by
  intro x hx hfix
  have hle := residual_le a c x hx
  rw [hfix] at hle
  simp only [sub_self] at hle
  linarith

/-- **Concrete falsification of the conjecture's test case.** For `a = 1/2`,
`b = 1`, `c = 1/2` (inside the advertised `(0,1)×(0,1)` box), the EML operator has
no fixed point in its natural domain. -/
theorem no_fixedPoint_half_half :
    ∀ x : ℝ, 0 < x + (1/2 : ℝ) → EMLIterOp (1/2) 1 (1/2) x ≠ x := by
  apply no_fixedPoint_of_subcritical
  have h1 : (1 : ℝ) < Real.exp (1/2) := by
    have := Real.add_one_le_exp (1/2 : ℝ)
    linarith
  nlinarith [h1]

/-- **Sharp necessary condition.** If the EML operator with `b = 1` has a fixed
point in its natural domain `x + c > 0`, then the parameters must satisfy
`c ≥ exp(a)·(1 - a)`. Equivalently, no admissible fixed point exists for
`c < exp(a)·(1-a)`. -/
theorem fixedPoint_imp_c_ge_threshold (a c x : ℝ)
    (hx : 0 < x + c) (hfix : EMLIterOp a 1 c x = x) :
    exp a * (1 - a) ≤ c := by
  have hle := residual_le a c x hx
  rw [hfix] at hle
  simp only [sub_self] at hle
  nlinarith [hle]

/-- **Neutrality on the threshold.** At the critical parameter
`c = exp(a)·(1 - a)`, the point `x* = exp(a) - c` is a genuine fixed point of the
EML operator with `b = 1`, and the derivative there is exactly `1`: the fixed
point is neutral, hence never a contraction. This shows the boundary of the
existence region is also the boundary of the contraction region. -/
theorem threshold_fixedPoint_neutral (a : ℝ) :
    let c := exp a * (1 - a)
    EMLIterOp a 1 c (exp a - c) = exp a - c ∧
      deriv (EMLIterOp a 1 c) (exp a - c) = 1 := by
  intro c
  have hea : 0 < Real.exp a := Real.exp_pos a
  have harg : (1 : ℝ) * (exp a - c) + c = exp a := by ring
  have hargpos : 0 < (1 : ℝ) * (exp a - c) + c := by rw [harg]; exact hea
  constructor
  · have hf : EMLIterOp a 1 c (exp a - c) = Real.exp a * Real.log (exp a) := by
      simp only [EMLIterOp]; rw [harg]
    rw [hf, Real.log_exp]
    show Real.exp a * a = exp a - c
    simp only [c]; ring
  · rw [EMLIterOp.deriv_eq a 1 c (exp a - c) hargpos, harg]
    field_simp

end EMLIterOp

end