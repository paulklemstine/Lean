import Mathlib
import EML.FixedPointConvergence
import EML.FixedPointThreshold

/-!
# EML Fixed-Point Theorem: The Sharp Existence Dichotomy

`EML.FixedPointThreshold` proved the **necessary** half of a sharp admissibility
criterion for the EML single operator `f(x) = exp(a) · log(x + c)` (case `b = 1`):
a fixed point in the natural domain `x + c > 0` forces `c ≥ exp(a)·(1 - a)`.
That file only established a *concrete* counterexample below the threshold and an
*ad hoc* positive instance for `c = 2`; the matching general **sufficiency** was
left open.

This file closes the gap and proves the full **dichotomy**:

  `(∃ x, x + c > 0 ∧ f(x) = x)  ↔  exp(a)·(1 - a) ≤ c`.

The forward direction is `EMLIterOp.fixedPoint_imp_c_ge_threshold` (catalog).
The new content is the reverse direction: whenever the residual maximum
`exp(a)·(a-1) + c` is positive we *construct* a fixed point by the intermediate
value theorem using two fully explicit witnesses, and at the boundary we reuse
the neutral fixed point `exp(a) - c` from the threshold file.

## Main results

* `EMLIterOp.residual_neg_left` — the explicit left witness
  `xL = exp(-(c/exp a + 1)) - c` lies in the domain and has strictly negative
  residual `f(xL) - xL = -exp a - exp(-(c/exp a + 1)) < 0`.
* `EMLIterOp.exists_fixedPoint_of_supercritical` — if `exp(a)·(a-1) + c > 0`
  then a domain fixed point exists (IVT between `xL` and `x0 = exp a - c`).
* `EMLIterOp.fixedPoint_exists_iff` — the sharp existence dichotomy.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The necessary condition `c ≥ exp(a)(1-a)` proved in
the threshold file is in fact *sharp and sufficient*: above it a fixed point must
exist, so existence is governed exactly by the sign of the residual maximum.

Experiment (Experimenter): The residual `g(x) = exp(a)·log(x+c) - x` attains its
maximum `exp(a)(a-1)+c` at `x0 = exp a - c` (where `x0 + c = exp a`). When this
maximum is positive, `g(x0) > 0`. We need a point with `g < 0` to run IVT. The
slick choice is the *left* witness `xL` with `xL + c = exp(-M)`, `M = c/exp a + 1`:
there `g(xL) = -exp a · M - exp(-M) + c = -(c + exp a) - exp(-M) + c
= -exp a - exp(-M) < 0`, a constant negative value independent of the supercritical
slack. Continuity of `g` on `[xL, x0]` plus `intermediate_value_Icc` yields a root,
whose argument `x + c ≥ exp(-M) > 0` is in the domain. At the boundary
`c = exp(a)(1-a)` the maximum is `0` and the neutral fixed point already recorded
in the threshold file supplies existence.

Analysis (Analyst): The decisive structural fact is that the *left* witness has a
residual that is negative unconditionally (it equals `-exp a - exp(-M)`), so the
only inequality that actually carries the supercritical hypothesis is `g(x0) > 0`.
This cleanly separates "can the diagonal be reached" (a one-line sign condition)
from the analytic machinery.

Critique (Critic): Could the constructed root coincide with the left endpoint and
escape the domain? No: `g(xL) < 0` strictly while the root has `g = 0`, so it is
distinct, and any point of `[xL, x0]` has argument `≥ exp(-M) > 0`. Is the
boundary case a gap? No: it is discharged separately via the threshold file's
neutral fixed point. Together with the catalog's necessity lemma this is a true
iff, not a one-sided estimate.

Synthesis (PI): Existence of an EML fixed point (for `b = 1`) is *exactly*
`exp(a)·(1-a) ≤ c`. This upgrades the catalog's one-sided threshold to a complete
classification of the admissible parameter region.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set

namespace EMLIterOp

/-
**Explicit left witness with negative residual.** With `b = 1`, set
`M = c / exp a + 1` and `xL = exp(-M) - c`. Then `xL` is in the natural domain
(`xL + c = exp(-M) > 0`) and its residual is the strictly negative constant
`f(xL) - xL = -exp a - exp(-M)`.
-/
theorem residual_neg_left (a c : ℝ) :
    0 < (exp (-(c / exp a + 1)) - c) + c ∧
      EMLIterOp a 1 c (exp (-(c / exp a + 1)) - c) - (exp (-(c / exp a + 1)) - c)
        = -exp a - exp (-(c / exp a + 1)) := by
  unfold EMLIterOp; ring_nf; norm_num [ Real.exp_pos ] ;
  linarith [ mul_inv_cancel_left₀ ( ne_of_gt ( Real.exp_pos a ) ) c ]

/--
**Sufficiency above the threshold.** If the residual maximum
`exp(a)·(a-1) + c` is strictly positive, then the EML operator with `b = 1` has a
fixed point in its natural domain `x + c > 0`. The fixed point is produced by the
intermediate value theorem applied to `g(x) = f(x) - x` on `[xL, x0]`, where
`xL = exp(-(c/exp a + 1)) - c` has `g(xL) < 0` and `x0 = exp a - c` has
`g(x0) = exp(a)(a-1) + c > 0`.
-/
theorem exists_fixedPoint_of_supercritical (a c : ℝ)
    (hsup : 0 < exp a * (a - 1) + c) :
    ∃ x : ℝ, 0 < x + c ∧ EMLIterOp a 1 c x = x := by
  -- Set M = c / exp a + 1, xL = exp(-M) - c, x0 = exp a - c.
  set M := c / Real.exp a + 1
  set xL := Real.exp (-M) - c
  set x0 := Real.exp a - c;
  -- By the intermediate value theorem, since $g(xL) < 0$ and $g(x0) > 0$, there exists $x \in [xL, x0]$ such that $g(x) = 0$.
  have h_ivt : ∃ x ∈ Set.Icc xL x0, EMLIterOp a 1 c x - x = 0 := by
    apply_rules [ intermediate_value_Icc ];
    · simp +zetaDelta at *;
      nlinarith [ Real.exp_pos a, Real.exp_neg a, mul_inv_cancel₀ ( ne_of_gt ( Real.exp_pos a ) ), Real.add_one_le_exp a, Real.add_one_le_exp ( -a ), mul_div_cancel₀ c ( ne_of_gt ( Real.exp_pos a ) ) ];
    · apply_rules [ ContinuousOn.sub, ContinuousOn.mul, continuousOn_const, continuousOn_id ];
      refine' continuousOn_of_forall_continuousAt fun x hx => ContinuousAt.log ( ContinuousAt.add ( continuousAt_const.mul continuousAt_id ) continuousAt_const ) _;
      nlinarith [ hx.1, hx.2, Real.exp_pos ( -M ), Real.exp_pos a, mul_div_cancel₀ c ( ne_of_gt ( Real.exp_pos a ) ) ];
    · constructor;
      · linarith [ residual_neg_left a c |>.2, Real.exp_pos a, Real.exp_pos ( -M ) ];
      · unfold EMLIterOp; norm_num;
        simp +zetaDelta at *;
        linarith;
  exact h_ivt.imp fun x hx => ⟨ by linarith [ hx.1.1, Real.exp_pos ( -M ) ], by linarith ⟩

/--
**The sharp existence dichotomy.** For the EML operator with `b = 1`, a fixed
point exists in the natural domain `x + c > 0` if and only if the parameters lie
on or above the closed-form threshold `c ≥ exp(a)·(1 - a)`. The forward direction
is the catalog's `fixedPoint_imp_c_ge_threshold`; the reverse splits into the
strict case (IVT via `exists_fixedPoint_of_supercritical`) and the boundary case
(the neutral fixed point from `threshold_fixedPoint_neutral`).
-/
theorem fixedPoint_exists_iff (a c : ℝ) :
    (∃ x : ℝ, 0 < x + c ∧ EMLIterOp a 1 c x = x) ↔ exp a * (1 - a) ≤ c := by
  refine' ⟨ fun ⟨ x, hx₁, hx₂ ⟩ => _, fun hc => _ ⟩;
  · exact EMLIterOp.fixedPoint_imp_c_ge_threshold a c x hx₁ hx₂
  · by_cases h : c = Real.exp a * ( 1 - a );
    · exact ⟨ Real.exp a - c, by linarith [ Real.exp_pos a ], by simpa [ h ] using EMLIterOp.threshold_fixedPoint_neutral a |>.1 ⟩;
    · exact exists_fixedPoint_of_supercritical a c ( by contrapose! h; nlinarith [ Real.exp_pos a ] )

end EMLIterOp

end