import Mathlib
import EML.FixedPointConvergence
import EML.FixedPointConcreteInstance
import EML.FixedPointBracket

/-!
# Certified Enclosure for the Concrete EML Operator

This file connects the abstract two-sided enclosure `EMLIterOp.certified_enclosure`
(from `EML.FixedPointBracket`) to the explicit operator `concreteEML` built in
`EML.FixedPointConcreteInstance`, namely `f(x) = exp(1)·log(x + 100)` on `[0, 20]`.

Because that instance has `b = 1 > 0`, the monotone bracket applies verbatim: the
orbit started at `0` rises to the fixed point from below, the orbit started at
`20` falls to it from above, and the gap closes.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The abstract bracket should specialize, with no extra
analytic work, to the catalog's already-certified concrete operator.

Experiment (Experimenter): `concreteEML.b = 1`, so `0 < concreteEML.b` is
`by norm_num`. Feeding this and the instance into `certified_enclosure` and
unfolding the `concreteEML` projections (`simp [concreteEML]`) yields the explicit
statement with `lo = 0`, `hi = 20`, `a = 1`, `b = 1`, `c = 100`.

Analysis (Analyst): The insight is compositionality: the abstract enclosure
theorem and the concrete existence witness are *orthogonal* deliverables that
multiply together, so a single specialization produces a fully concrete,
self-validating iteration with a guaranteed interval certificate at each step.

Critique (Critic): Is anything vacuous? No — the conclusion exhibits two genuine
real orbits `fⁿ(0)` and `fⁿ(20)` that provably sandwich a real fixed point and a
width tending to `0`; it is the abstract theorem with all parameters pinned to
concrete numerals.

Synthesis (PI): The EML catalog now offers, for a fully explicit operator, an
iteration that emits a rigorous enclosure `[fⁿ(0), fⁿ(20)] ∋ x*` at every step.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-- **Certified enclosure for `f(x) = exp(1)·log(x + 100)` on `[0, 20]`.** The
lower orbit `fⁿ(0)` and upper orbit `fⁿ(20)` bracket the unique fixed point at
every step, both converge to it, and the bracket width tends to `0`. -/
theorem concreteEML_enclosure :
    ∃ xstar, EMLIterOp 1 1 100 xstar = xstar ∧ xstar ∈ Icc (0 : ℝ) 20 ∧
      (∀ n, EMLIterOp.iterSeq 1 1 100 0 n ≤ xstar) ∧
      (∀ n, xstar ≤ EMLIterOp.iterSeq 1 1 100 20 n) ∧
      Tendsto (EMLIterOp.iterSeq 1 1 100 0) atTop (𝓝 xstar) ∧
      Tendsto (EMLIterOp.iterSeq 1 1 100 20) atTop (𝓝 xstar) ∧
      Tendsto (fun n => EMLIterOp.iterSeq 1 1 100 20 n -
        EMLIterOp.iterSeq 1 1 100 0 n) atTop (𝓝 0) := by
  have hb : 0 < concreteEML.b := by norm_num [concreteEML]
  have h := certified_enclosure concreteEML hb
  simpa [concreteEML] using h

end EMLIterOp

end