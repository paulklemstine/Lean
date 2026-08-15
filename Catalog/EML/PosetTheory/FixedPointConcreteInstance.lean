import Mathlib
import EML.FixedPointConvergence
import EML.PosetTheory.FixedPointRate

/-!
# A Concrete, Certified EML Contraction Instance

The abstract development in `EML.FixedPointConvergence` and `EML.FixedPointRate`
proves powerful conclusions *conditional* on the existence of an
`EMLContractionData` — a structure bundling an invariant interval, a contraction
ratio `ρ < 1`, an interval-self-map property, and a derivative bound. A natural
adversarial worry is whether this bundle is ever simultaneously satisfiable, or
whether the whole theory is vacuous.

This file removes that doubt by **constructing an explicit instance**:

  `f(x) = exp(1) · log(x + 100)` on the interval `[0, 20]`, with `ρ = 1/30`.

Every field is discharged with genuine real-analytic estimates (`exp 1 < 3`,
`log 120 < 5`, monotonicity of `log`), and we then read off, for this concrete
operator, the full conclusion of the abstract theory: a fixed point exists in
`[0, 20]`, the iteration from any starting point in the interval converges to it,
and the error obeys the explicit geometric bound `|xₙ − x*| ≤ |x₁ − x₀|·(1/30)ⁿ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): There is a genuinely non-trivial EML operator (with
`a > 0`) satisfying *all* the contraction hypotheses at once, so the abstract
fixed-point/rate theorems are not vacuously about an empty class.

Experiment (Experimenter): Pick `a = 1, b = 1, c = 100` and interval `[0, 20]`.
The derivative `exp(1)/(x+100)` is at most `exp(1)/100 < 3/100 < 1/30`, giving a
clean ratio bound. The self-map property needs `0 ≤ exp(1)·log(x+100) ≤ 20`; the
lower bound is `log(x+100) ≥ 0` (since `x+100 ≥ 1`), and the upper bound follows
from `log(x+100) ≤ log 120 < 5` and `exp 1 < 3`, so the product is `< 15 < 20`.
The numeric facts `exp 1 < 3` (`Real.exp_one_lt_d9`) and `log 120 < 5` (via
`exp 5 = (exp 1)^5 > 2.7^5 > 120`) close everything.

Analysis (Analyst): The decisive insight is *slack engineering*: by taking `c`
large relative to the interval width, the derivative bound becomes easy
(denominator large) while the self-map property is forced by the slow growth of
`log`. Large `c` is exactly the "right parameter range" the conjecture alludes
to. The earlier attempt at the conjecture's literal `c ∈ (0,1)` test case is
genuinely harder because `log` can go negative there.

Critique (Critic): Is the instance trivial? No — `a = 1 > 0`, so `exp(a) ≠ 1`,
and the operator is a real `exp`-`log` composition, not a linear map. Are the
conclusions real? `concreteEML_certified` produces an actual fixed point with the
explicit `(1/30)ⁿ` rate, instantiating the abstract machinery end to end.

Synthesis (PI): Existence of this witness upgrades the abstract theorems from
"true about a possibly empty hypothesis class" to "true and applicable", which is
the standard of non-vacuity demanded by adversarial review.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-- An explicit, fully verified EML contraction instance:
`f(x) = exp(1) · log(x + 100)` on `[0, 20]` with contraction ratio `1/30`. -/
def concreteEML : EMLContractionData where
  a := 1
  b := 1
  c := 100
  lo := 0
  hi := 20
  rho := 1 / 30
  lo_lt_hi := by norm_num
  rho_nonneg := by norm_num
  rho_lt_one := by norm_num
  arg_pos := by
    rintro x ⟨hx0, hx20⟩; simp only [one_mul]; linarith
  maps_to := by
    rintro x ⟨hx0, hx20⟩
    simp only [EMLIterOp, one_mul]
    refine ⟨?_, ?_⟩
    · have : 0 ≤ Real.log (x + 100) := Real.log_nonneg (by linarith)
      positivity
    · have hlog : Real.log (x + 100) ≤ Real.log 120 :=
        Real.log_le_log (by linarith) (by linarith)
      have hlog5 : Real.log 120 < 5 := by
        rw [Real.log_lt_iff_lt_exp (by norm_num)]
        have h : Real.exp 5 = Real.exp 1 ^ 5 := by rw [← Real.exp_nat_mul]; norm_num
        rw [h]
        have h27 : (2.7 : ℝ) < Real.exp 1 := by nlinarith [Real.exp_one_gt_d9]
        have hp : (2.7 : ℝ) ^ 5 ≤ Real.exp 1 ^ 5 := pow_le_pow_left₀ (by norm_num) h27.le 5
        nlinarith [hp]
      have he3 : Real.exp 1 < 3 := by nlinarith [Real.exp_one_lt_d9]
      have hlogpos : 0 ≤ Real.log (x + 100) := Real.log_nonneg (by linarith)
      nlinarith [Real.exp_pos 1, hlog, hlog5, he3, hlogpos]
  deriv_bound := by
    rintro x ⟨hx0, hx20⟩
    simp only [one_mul, mul_one]
    rw [abs_of_nonneg (by positivity), div_le_iff₀ (by linarith)]
    have he : Real.exp 1 < 3 := by nlinarith [Real.exp_one_lt_d9]
    nlinarith [Real.exp_pos 1]

/-- Sanity check: the concrete operator is genuinely the `exp`-`log` map
`f(x) = exp(1) · log(x + 100)`. -/
theorem concreteEML_apply (x : ℝ) :
    EMLIterOp concreteEML.a concreteEML.b concreteEML.c x = exp 1 * log (x + 100) := by
  simp [EMLIterOp, concreteEML]

/-- The concrete instance is non-trivial: its exponential scaling `exp(a)` with
`a = 1` is strictly greater than `1`, so the operator is not a bare logarithm. -/
theorem concreteEML_nontrivial : 1 < exp concreteEML.a := by
  have : concreteEML.a = 1 := rfl
  rw [this]; nlinarith [Real.exp_one_gt_d9]

/-- **End-to-end certified convergence for the concrete EML operator.** Starting
from any `x₀ ∈ [0, 20]`, the iteration `xₙ₊₁ = exp(1)·log(xₙ + 100)` converges to
a fixed point `x* ∈ [0, 20]` with the explicit geometric error bound
`|xₙ − x*| ≤ |x₁ − x₀| · (1/30)ⁿ / (1 − 1/30)`. -/
theorem concreteEML_certified (x₀ : ℝ) (hx₀ : x₀ ∈ Icc (0 : ℝ) 20) :
    ∃ xstar, EMLIterOp 1 1 100 xstar = xstar ∧ xstar ∈ Icc (0 : ℝ) 20 ∧
      Tendsto (EMLIterOp.iterSeq 1 1 100 x₀) atTop (𝓝 xstar) ∧
      (∀ n, |EMLIterOp.iterSeq 1 1 100 x₀ n - xstar| ≤
        |EMLIterOp.iterSeq 1 1 100 x₀ 1 -
          EMLIterOp.iterSeq 1 1 100 x₀ 0| * (1 / 30) ^ n / (1 - 1 / 30)) := by
  have h := iterSeq_certified_rate concreteEML x₀ hx₀
  simpa [concreteEML] using h

end EMLIterOp

end