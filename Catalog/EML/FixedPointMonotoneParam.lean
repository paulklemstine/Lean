import Mathlib
import EML.FixedPointConvergence
import EML.FixedPointBracket

/-!
# EML Fixed-Point Theorem: Monotone Dependence of the Fixed Point on the Scaling Parameter `a`

`EML.FixedPointConvergence` establishes that the EML single operator
`f_a(x) = exp(a) · log(b·x + c)` is a contraction on an invariant interval with a
unique fixed point `x*(a)`, and `EML.FixedPointBracket` adds monotonicity of the
operator in its *argument* (`op_monotoneOn`) together with a two-sided certified
enclosure.

None of the existing files address how the fixed point *moves* as the parameter
`a` varies. This file proves the **comparative-statics law** for the EML scheme:

* `fixedPoint_le_of_a_le` — increasing the scaling parameter `a` (weakly) raises
  the fixed point;
* `fixedPoint_lt_of_a_lt` — strictly increasing `a` strictly raises the fixed
  point;
* `fixedPoint_unique_le_of_a_le` — the *unique* fixed point of the larger
  parameter dominates any fixed point of the smaller one.

The mechanism is monotone-iteration sandwiching: the smaller-parameter fixed
point `x₁` is a sub-solution for the larger operator (`f_{a₂}(x₁) ≥ x₁` because
`exp` is increasing and `log(b·x₁+c) ≥ 0` at a positive fixed point), so the
larger orbit started at `x₁` increases monotonically up to `x₂(a₂)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For the EML operator `f_a(x) = exp(a)·log(b·x+c)`
with `b > 0`, the fixed point `x*(a)` is a (strictly) increasing function of `a`
on the parameter range where a positive fixed point exists. Bolder corollary:
the dependence is strict, so distinct `a` give distinct dynamical equilibria — an
EML layer's scaling knob is an injective control of its resting state.

Experiment (Experimenter): Two operators sharing `(b,c,lo,hi)` but with
`a₁ ≤ a₂` satisfy `f_{a₁} ≤ f_{a₂}` pointwise wherever `log(b·x+c) ≥ 0`. At a
positive fixed point `x₁` of `f_{a₁}` the catalog lemma `fixedPoint_arg_gt_one`
gives `b·x₁+c > 1`, hence `log(b·x₁+c) > 0`, so `f_{a₂}(x₁) ≥ x₁` (strict when
`a₁ < a₂`). The orbit of `f_{a₂}` started at `x₁` is then monotone increasing
(catalog `op_monotoneOn`) and converges to a fixed point `x₂` of `f_{a₂}`
(catalog `iterSeq_converges`). Monotone limits dominate every term, so
`x₁ ≤ x₂` (strictly via the first step `f_{a₂}(x₁) > x₁`).

Analysis (Analyst): The key insight is that a fixed point of the *smaller*
operator is a **sub-solution** of the *larger* one, and contraction turns
sub-solutions into lower bounds for the limit. This is exactly Tarski/monotone-
iteration reasoning specialised to the EML contraction, and it needs no
derivative-of-fixed-point machinery (no implicit function theorem): only
monotonicity of `exp`, `log`, and the operator suffices.

Critique (Critic): Is positivity of `x₁` essential? Yes — without it
`log(b·x₁+c)` could be negative and the inequality `f_{a₂}(x₁) ≥ x₁` reverses, so
the hypothesis is load-bearing, not decorative. Does the result collapse to a
triviality? No: it is false for general non-monotone maps, and the proof genuinely
uses `b > 0` (monotonicity) plus the contraction limit. Is strictness vacuous?
No: it is witnessed by the first orbit step being strictly above `x₁`.

Synthesis (PI): EML scaling is a *monotone, injective* control on the scheme's
equilibrium. Combined with the catalog's certified rate, this means an EML
iterative algorithm can be tuned: nudging `a` upward provably and continuously
raises the converged output, never overshooting into a different basin.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-
Monotonicity of the EML operator in the scaling parameter `a`, pointwise:
when `log(b·x+c) ≥ 0`, increasing `a` increases `f_a(x)`.
-/
theorem op_le_op_of_a_le (a₁ a₂ b c x : ℝ) (ha : a₁ ≤ a₂)
    (hlog : 0 ≤ Real.log (b * x + c)) :
    EMLIterOp a₁ b c x ≤ EMLIterOp a₂ b c x := by
  exact mul_le_mul_of_nonneg_right ( Real.exp_le_exp.mpr ha ) hlog

/-
Strict monotonicity of the EML operator in `a`, pointwise: when
`log(b·x+c) > 0`, strictly increasing `a` strictly increases `f_a(x)`.
-/
theorem op_lt_op_of_a_lt (a₁ a₂ b c x : ℝ) (ha : a₁ < a₂)
    (hlog : 0 < Real.log (b * x + c)) :
    EMLIterOp a₁ b c x < EMLIterOp a₂ b c x := by
  exact mul_lt_mul_of_pos_right ( Real.exp_lt_exp.mpr ha ) hlog

/-
If a point `p` in the invariant interval is a sub-solution of the operator
(`p ≤ f(p)`), then the orbit started at `p` is monotone increasing.
-/
theorem orbit_mono_of_subsolution (D : EMLContractionData) (hb : 0 < D.b)
    (p : ℝ) (hp : p ∈ Icc D.lo D.hi)
    (hsub : p ≤ EMLIterOp D.a D.b D.c p) :
    Monotone (fun n => EMLIterOp.iterSeq D.a D.b D.c p n) := by
  refine' monotone_nat_of_le_succ _;
  intro n;
  induction' n with n ih;
  · exact hsub;
  · apply EMLIterOp.op_monotoneOn;
    exacts [ hb, fun x hx => D.arg_pos x hx, EMLIterOp.iterSeq_mem_Icc D.a D.b D.c p D.lo D.hi hp D.maps_to n, ih ]

/-
**Comparative statics (weak form).** Fix the operator data `D` (with `b > 0`).
If `x₁` is a positive fixed point of the smaller-parameter operator `f_{a₁}` with
`a₁ ≤ D.a`, lying in the invariant interval, then there is a fixed point `x₂` of
`f_{D.a}` in the interval with `x₁ ≤ x₂`. Increasing the scaling parameter raises
the equilibrium.
-/
theorem fixedPoint_le_of_a_le (D : EMLContractionData) (hb : 0 < D.b)
    (a₁ : ℝ) (ha : a₁ ≤ D.a)
    (x₁ : ℝ) (hx₁mem : x₁ ∈ Icc D.lo D.hi) (hx₁pos : 0 < x₁)
    (hfix₁ : EMLIterOp a₁ D.b D.c x₁ = x₁) :
    ∃ x₂, EMLIterOp D.a D.b D.c x₂ = x₂ ∧ x₂ ∈ Icc D.lo D.hi ∧ x₁ ≤ x₂ := by
  have hlog : 0 ≤ Real.log (D.b * x₁ + D.c) := by
    apply le_of_lt;
    apply EMLIterOp.fixedPoint_arg_gt_one a₁ D.b D.c x₁ hfix₁ hx₁pos (D.arg_pos x₁ hx₁mem) |> fun h => Real.log_pos h;
  obtain ⟨x₂, hlim, hfix₂, hmem₂⟩ := EMLIterOp.iterSeq_converges D x₁ hx₁mem;
  refine' ⟨ x₂, hfix₂, hmem₂, _ ⟩;
  refine' le_of_tendsto_of_tendsto' tendsto_const_nhds hlim fun n => _;
  exact EMLIterOp.orbit_mono_of_subsolution D hb x₁ hx₁mem ( by simpa [ hfix₁ ] using EMLIterOp.op_le_op_of_a_le a₁ D.a D.b D.c x₁ ha hlog ) |> fun h => h ( Nat.zero_le n ) |> le_trans ( by simp +decide [ EMLIterOp.iterSeq ] )

/-
**Comparative statics (strict form).** Strictly increasing the scaling
parameter strictly raises the fixed point: if `a₁ < D.a` and `x₁` is a positive
fixed point of `f_{a₁}` in the interval, the resulting fixed point `x₂` of
`f_{D.a}` satisfies `x₁ < x₂`.
-/
theorem fixedPoint_lt_of_a_lt (D : EMLContractionData) (hb : 0 < D.b)
    (a₁ : ℝ) (ha : a₁ < D.a)
    (x₁ : ℝ) (hx₁mem : x₁ ∈ Icc D.lo D.hi) (hx₁pos : 0 < x₁)
    (hfix₁ : EMLIterOp a₁ D.b D.c x₁ = x₁) :
    ∃ x₂, EMLIterOp D.a D.b D.c x₂ = x₂ ∧ x₂ ∈ Icc D.lo D.hi ∧ x₁ < x₂ := by
  -- By the properties of the contraction mapping, there exists a unique fixed point $x_2$ in $[D.lo, D.hi]$.
  obtain ⟨x₂, hx₂⟩ : ∃ x₂, EMLIterOp D.a D.b D.c x₂ = x₂ ∧ x₂ ∈ Set.Icc D.lo D.hi := by
    -- By the properties of the contraction mapping, there exists a unique fixed point $x_2$ in $[D.lo, D.hi]$ because $D$ is a contraction mapping.
    have := EMLIterOp.iterSeq_converges D x₁ hx₁mem;
    aesop;
  refine' ⟨ x₂, hx₂.1, hx₂.2, lt_of_le_of_ne _ _ ⟩;
  · apply EMLIterOp.fixedPoint_le_of_a_le D hb a₁ ha.le x₁ hx₁mem hx₁pos hfix₁ |> fun ⟨ x₂', hx₂' ⟩ => by
      have := EMLIterOp.fixedPoint_unique D.a D.b D.c D.lo D.hi D.rho D.lo_lt_hi D.rho_lt_one D.rho_nonneg D.arg_pos D.deriv_bound x₂' x₂ hx₂'.2.1 hx₂.2 hx₂'.1 hx₂.1; aesop;
  · rintro rfl;
    unfold EMLIterOp at *;
    nlinarith [ Real.exp_pos a₁, Real.exp_lt_exp.2 ha, Real.log_pos ( show 1 < D.b * x₁ + D.c from EMLIterOp.fixedPoint_arg_gt_one a₁ D.b D.c x₁ hfix₁ hx₁pos ( D.arg_pos x₁ hx₁mem ) ) ]

/-
**Comparative statics for the unique fixed point.** Under contraction, the
larger parameter's fixed point is unique, so *every* fixed point `x₂` of `f_{D.a}`
in the interval dominates the smaller parameter's positive fixed point `x₁`.
-/
theorem fixedPoint_unique_le_of_a_le (D : EMLContractionData) (hb : 0 < D.b)
    (a₁ : ℝ) (ha : a₁ ≤ D.a)
    (x₁ : ℝ) (hx₁mem : x₁ ∈ Icc D.lo D.hi) (hx₁pos : 0 < x₁)
    (hfix₁ : EMLIterOp a₁ D.b D.c x₁ = x₁)
    (x₂ : ℝ) (hx₂mem : x₂ ∈ Icc D.lo D.hi)
    (hfix₂ : EMLIterOp D.a D.b D.c x₂ = x₂) :
    x₁ ≤ x₂ := by
  obtain ⟨x₂', hfix₂', hmem₂', hle⟩ : ∃ x₂', EMLIterOp D.a D.b D.c x₂' = x₂' ∧ x₂' ∈ Icc D.lo D.hi ∧ x₁ ≤ x₂' := by
    apply_rules [ EMLIterOp.fixedPoint_le_of_a_le ];
  have := EMLIterOp.fixedPoint_unique D.a D.b D.c D.lo D.hi D.rho D.lo_lt_hi D.rho_lt_one D.rho_nonneg D.arg_pos D.deriv_bound x₂' x₂ hmem₂' hx₂mem hfix₂' hfix₂; aesop;

end EMLIterOp

end