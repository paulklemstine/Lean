import Mathlib
import EML.FixedPointConvergence
import EML.FixedPointBracket
import EML.FixedPointMonotoneParam

/-!
# EML Fixed-Point Theorem: Monotone Dependence of the Fixed Point on the Translation `c`

This file is the companion to `EML.FixedPointMonotoneParam`, which proved the EML
fixed point `x*(a)` is monotone in the scaling parameter `a`. Here we prove the
analogous **comparative-statics law for the translation parameter `c`** of the
operator `f_c(x) = exp(a) · log(b·x + c)`:

* `op_le_op_of_c_le` / `op_lt_op_of_c_lt` — pointwise (strict) monotonicity of the
  operator in `c`;
* `fixedPoint_le_of_c_le` / `fixedPoint_lt_of_c_lt` — increasing `c` (strictly)
  raises the fixed point;
* `fixedPoint_unique_le_of_c_le` — the unique fixed point of the larger `c`
  dominates any fixed point of the smaller `c`.

The mechanism reuses the monotone-iteration machinery
(`orbit_mono_of_subsolution`, `iterSeq_converges`) from the catalog, but the
`c`-monotonicity is structurally *cleaner* than the `a`-monotonicity: it needs no
positivity of the fixed point, only positivity of the log argument `b·x₁ + c₁`,
because `log` is increasing in its argument regardless of sign of the output.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The EML fixed point `x*(c)` is (strictly) increasing in
the translation `c`. Bold framing: among the three EML knobs `(a, b, c)`, both the
multiplicative scaling `a` and the additive shift `c` move the equilibrium the
*same* direction (upward), so the equilibrium response surface is jointly
monotone — there is no antagonism between the two controls.

Experiment (Experimenter): With `c₁ ≤ c₂` and the log argument positive at the
smaller shift (`0 < b·x₁ + c₁`), `log(b·x+c₁) ≤ log(b·x+c₂)` by `Real.log_le_log`,
and `exp a ≥ 0`, so `f_{c₁} ≤ f_{c₂}` pointwise. A fixed point `x₁` of `f_{c₁}` is
then a sub-solution of `f_{c₂}`, and `orbit_mono_of_subsolution` plus
`iterSeq_converges` push the larger orbit up to `x₂ ≥ x₁` (strict if `c₁ < c₂`).

Analysis (Analyst): The key insight is that the sub-solution principle is the
*single* engine behind monotone dependence on **any** parameter the operator is
monotone in; `a` and `c` are two instances, and the only difference is the side
condition that certifies `f_{small} ≤ f_{big}` at the fixed point (positivity of
`x₁` for `a`, positivity of the argument for `c`).

Critique (Critic): Is the positivity side condition `0 < b·x₁ + c₁` redundant? No:
it is exactly the domain condition making `log` defined/monotone there, and it is
automatically available from `arg_pos` whenever `x₁` lies in the smaller operator's
invariant interval — so the hypothesis is honest, not hidden. Is the result a
relabelling of the `a`-result? No: the side condition and the pointwise inequality
proof differ, and `c`-monotonicity holds even for non-positive fixed points where
the `a`-result fails.

Synthesis (PI): EML equilibria depend monotonically and jointly on both `a` and
`c`. This makes the two-parameter family a *lattice-ordered* control space for the
converged output, which is exactly the structure needed to bisection-search
parameters to hit a target equilibrium.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-
Monotonicity of the EML operator in the translation `c`, pointwise: when the
log argument at the smaller shift is positive, increasing `c` increases `f_c(x)`.
-/
theorem op_le_op_of_c_le (a b c₁ c₂ x : ℝ) (hc : c₁ ≤ c₂)
    (harg : 0 < b * x + c₁) :
    EMLIterOp a b c₁ x ≤ EMLIterOp a b c₂ x := by
  exact mul_le_mul_of_nonneg_left ( Real.log_le_log ( by linarith ) ( by linarith ) ) ( by positivity )

/-
Strict monotonicity of the EML operator in `c`, pointwise.
-/
theorem op_lt_op_of_c_lt (a b c₁ c₂ x : ℝ) (hc : c₁ < c₂)
    (harg : 0 < b * x + c₁) :
    EMLIterOp a b c₁ x < EMLIterOp a b c₂ x := by
  exact mul_lt_mul_of_pos_left ( Real.log_lt_log harg ( by linarith ) ) ( Real.exp_pos _ )

/-
**Comparative statics in `c` (weak form).** Fix operator data `D` (with
`b > 0`). If `x₁` is a fixed point of the smaller-shift operator `f_{c₁}` with
`c₁ ≤ D.c`, lying in the invariant interval and with positive log argument, then
there is a fixed point `x₂` of `f_{D.c}` in the interval with `x₁ ≤ x₂`.
-/
theorem fixedPoint_le_of_c_le (D : EMLContractionData) (hb : 0 < D.b)
    (c₁ : ℝ) (hc : c₁ ≤ D.c)
    (x₁ : ℝ) (hx₁mem : x₁ ∈ Icc D.lo D.hi) (harg₁ : 0 < D.b * x₁ + c₁)
    (hfix₁ : EMLIterOp D.a D.b c₁ x₁ = x₁) :
    ∃ x₂, EMLIterOp D.a D.b D.c x₂ = x₂ ∧ x₂ ∈ Icc D.lo D.hi ∧ x₁ ≤ x₂ := by
  have hsub : x₁ ≤ EMLIterOp D.a D.b D.c x₁ := by
    convert EMLIterOp.op_le_op_of_c_le _ _ _ _ _ hc _ using 1 ; aesop;
    linarith;
  -- By the properties of the contraction mapping, there exists a fixed point `x₂` in the interval `[lo, hi]` such that `x₂ = EMLIterOp D.a D.b D.c x₂`.
  obtain ⟨x₂, hx₂⟩ : ∃ x₂, EMLIterOp D.a D.b D.c x₂ = x₂ ∧ x₂ ∈ Icc D.lo D.hi ∧ Tendsto (fun n => EMLIterOp.iterSeq D.a D.b D.c x₁ n) Filter.atTop (nhds x₂) := by
    convert EMLIterOp.iterSeq_converges D x₁ hx₁mem using 1;
    grind;
  refine' ⟨ x₂, hx₂.1, hx₂.2.1, le_of_tendsto_of_tendsto' tendsto_const_nhds hx₂.2.2 fun n => _ ⟩;
  induction' n with n ih;
  · rfl;
  · exact le_trans hsub ( EMLIterOp.op_monotoneOn D.a D.b D.c D.lo D.hi hb ( fun x hx => D.arg_pos x hx ) ( by aesop ) ih )

/-
**Comparative statics in `c` (strict form).** Strictly increasing the shift
strictly raises the fixed point.
-/
theorem fixedPoint_lt_of_c_lt (D : EMLContractionData) (hb : 0 < D.b)
    (c₁ : ℝ) (hc : c₁ < D.c)
    (x₁ : ℝ) (hx₁mem : x₁ ∈ Icc D.lo D.hi) (harg₁ : 0 < D.b * x₁ + c₁)
    (hfix₁ : EMLIterOp D.a D.b c₁ x₁ = x₁) :
    ∃ x₂, EMLIterOp D.a D.b D.c x₂ = x₂ ∧ x₂ ∈ Icc D.lo D.hi ∧ x₁ < x₂ := by
  -- Step 1: Use `op_lt_op_of_c_lt` to establish strict step inequality.
  have hstrict : x₁ < EMLIterOp D.a D.b D.c x₁ := by
    grind +suggestions;
  -- By `orbit_mono_of_subsolution`, the shifted iterates `iterSeq D.a D.b D.c x₁ n` (starting from `x₁`) are monotone increasing.
  have h_mono : Monotone (fun n => EMLIterOp.iterSeq D.a D.b D.c x₁ n) := by
    apply orbit_mono_of_subsolution D hb x₁ hx₁mem (by linarith);
  obtain ⟨ x₂, hlim, hfix₂, hmem₂ ⟩ := EMLIterOp.iterSeq_converges D x₁ hx₁mem;
  refine' ⟨ x₂, hfix₂, hmem₂, _ ⟩;
  exact lt_of_lt_of_le hstrict ( le_of_tendsto_of_tendsto tendsto_const_nhds hlim ( Filter.eventually_atTop.mpr ⟨ 1, fun n hn => h_mono hn ⟩ ) )

/-
**Comparative statics in `c` for the unique fixed point.** Every fixed point
`x₂` of `f_{D.c}` in the interval dominates a smaller-shift fixed point `x₁`.
-/
theorem fixedPoint_unique_le_of_c_le (D : EMLContractionData) (hb : 0 < D.b)
    (c₁ : ℝ) (hc : c₁ ≤ D.c)
    (x₁ : ℝ) (hx₁mem : x₁ ∈ Icc D.lo D.hi) (harg₁ : 0 < D.b * x₁ + c₁)
    (hfix₁ : EMLIterOp D.a D.b c₁ x₁ = x₁)
    (x₂ : ℝ) (hx₂mem : x₂ ∈ Icc D.lo D.hi)
    (hfix₂ : EMLIterOp D.a D.b D.c x₂ = x₂) :
    x₁ ≤ x₂ := by
  obtain ⟨x₂', hfix₂', hmem₂', hle⟩ : ∃ x₂', EMLIterOp D.a D.b D.c x₂' = x₂' ∧ x₂' ∈ Icc D.lo D.hi ∧ x₁ ≤ x₂' := by
    apply EMLIterOp.fixedPoint_le_of_c_le D hb c₁ hc x₁ hx₁mem harg₁ hfix₁;
  have := @EMLIterOp.fixedPoint_unique D.a D.b D.c D.lo D.hi D.rho D.lo_lt_hi D.rho_lt_one D.rho_nonneg D.arg_pos D.deriv_bound x₂' x₂ hmem₂' hx₂mem hfix₂' hfix₂; aesop;

end EMLIterOp

end