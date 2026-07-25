import Mathlib
import EML.FixedPointConvergence
import EML.FixedPointRate

/-!
# EML Fixed-Point Theorem: Monotone Two-Sided Certified Enclosure

`EML.FixedPointConvergence` proves the EML iteration converges and
`EML.FixedPointRate` gives an explicit geometric *a priori* error bound. Both are
*one-sided*: they control the distance to a limit but do not by themselves
produce a **computable bracket** `[ℓₙ, uₙ]` provably containing the fixed point
at every finite step.

This file supplies exactly that, under the natural extra hypothesis `b > 0`
(which makes the EML operator monotone increasing). Starting the iteration from
the two endpoints of the invariant interval yields:

* an increasing lower orbit `ℓₙ = fⁿ(lo)`,
* a decreasing upper orbit `uₙ = fⁿ(hi)`,
* both squeezing the unique fixed point: `ℓₙ ≤ x* ≤ uₙ` for every `n`,
* with the bracket width `uₙ − ℓₙ → 0`.

This is a *certified enclosure*: at any step `n` the computed pair `(ℓₙ, uₙ)`
is a rigorous interval guaranteed to contain `x*`, which is what makes the EML
operator usable inside verified/interval-arithmetic algorithms.

## Main results

* `EMLIterOp.op_monotoneOn` — `b > 0 ⇒` the operator is monotone on `[lo, hi]`.
* `EMLIterOp.iterSeq_lo_mono` — the lower orbit increases.
* `EMLIterOp.iterSeq_hi_anti` — the upper orbit decreases.
* `EMLIterOp.certified_enclosure` — the full bracket: a unique fixed point `x*`
  with `ℓₙ ≤ x* ≤ uₙ`, both orbits converging to `x*`, and width `→ 0`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Because `f(x) = exp(a)·log(b·x+c)` is monotone
increasing when `b > 0`, the Banach iteration should be *bracketing*: iterating
from `lo` rises to `x*` from below while iterating from `hi` falls to `x*` from
above. This converts the one-sided rate bound into a two-sided, finitely
checkable enclosure.

Experiment (Experimenter): Monotonicity reduces to `Real.log_le_log` composed
with `exp a > 0` and `b·u+c ≤ b·v+c`. The orbit monotonicity is a clean
induction: `lo ≤ f(lo)` (from `maps_to`) propagates through the monotone `f`;
symmetrically `f(hi) ≤ hi`. The squeeze `ℓₙ ≤ x* ≤ uₙ` is another induction using
`f(x*) = x*`. Identifying both orbit limits with the *same* `x*` uses the
contraction uniqueness lemma `fixedPoint_unique`.

Analysis (Analyst): The key insight is that contraction + monotonicity is
strictly stronger than contraction alone: it upgrades "converges with rate `ρⁿ`"
to "is trapped in a nested sequence of intervals of width `→ 0`". The nestedness
needs no new analytic input beyond monotonicity of `log`.

Critique (Critic): Does `b > 0` exclude the catalog's concrete instance? No — the
`concreteEML` instance has `b = 1 > 0`, so the enclosure applies to it verbatim.
Is the width-to-zero claim independent of the bracket? It follows because both
orbits converge to the same `x*`, so the difference tends to `0 − 0`. No
circularity: uniqueness is proved from the contraction bound, not assumed.

Synthesis (PI): The EML iteration is not just convergent but *self-validating*:
every step emits a certificate `[ℓₙ, uₙ] ∋ x*`. This is the form a numerical
analyst actually wants, and it composes with the explicit `ρⁿ` rate from
`FixedPointRate` to bound how many steps a target enclosure width requires.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set Filter Topology

namespace EMLIterOp

/-- When `b > 0`, the EML operator `f(x) = exp(a)·log(b·x+c)` is monotone on the
invariant interval (where the log argument is positive): `u ≤ v ⇒ f(u) ≤ f(v)`. -/
theorem op_monotoneOn (a b c lo hi : ℝ) (hb : 0 < b)
    (harg : ∀ x ∈ Icc lo hi, 0 < b * x + c)
    {u v : ℝ} (hu : u ∈ Icc lo hi) (huv : u ≤ v) :
    EMLIterOp a b c u ≤ EMLIterOp a b c v := by
  have hau : 0 < b * u + c := harg u hu
  have hlog : Real.log (b * u + c) ≤ Real.log (b * v + c) :=
    Real.log_le_log hau (by nlinarith [hb])
  have hexp : 0 ≤ Real.exp a := (Real.exp_pos a).le
  simpa [EMLIterOp] using mul_le_mul_of_nonneg_left hlog hexp

/-- The lower orbit `fⁿ(lo)` is monotone increasing (when `b > 0`). -/
theorem iterSeq_lo_mono (D : EMLContractionData) (hb : 0 < D.b) :
    Monotone (fun n => EMLIterOp.iterSeq D.a D.b D.c D.lo n) := by
  have hlo : D.lo ∈ Icc D.lo D.hi := ⟨le_refl _, D.lo_lt_hi.le⟩
  have hstep : ∀ n, EMLIterOp.iterSeq D.a D.b D.c D.lo n ≤
      EMLIterOp.iterSeq D.a D.b D.c D.lo (n + 1) := by
    intro n
    induction n with
    | zero =>
        have := (D.maps_to D.lo hlo).1
        simpa [EMLIterOp.iterSeq] using this
    | succ k ih =>
        have hmem : EMLIterOp.iterSeq D.a D.b D.c D.lo k ∈ Icc D.lo D.hi :=
          EMLIterOp.iterSeq_mem_Icc D.a D.b D.c D.lo D.lo D.hi hlo D.maps_to k
        have hmem1 : EMLIterOp.iterSeq D.a D.b D.c D.lo (k + 1) ∈ Icc D.lo D.hi :=
          EMLIterOp.iterSeq_mem_Icc D.a D.b D.c D.lo D.lo D.hi hlo D.maps_to (k + 1)
        have := op_monotoneOn D.a D.b D.c D.lo D.hi hb D.arg_pos hmem ih
        simpa [EMLIterOp.iterSeq] using this
  exact monotone_nat_of_le_succ hstep

/-- The upper orbit `fⁿ(hi)` is monotone decreasing (when `b > 0`). -/
theorem iterSeq_hi_anti (D : EMLContractionData) (hb : 0 < D.b) :
    Antitone (fun n => EMLIterOp.iterSeq D.a D.b D.c D.hi n) := by
  have hhi : D.hi ∈ Icc D.lo D.hi := ⟨D.lo_lt_hi.le, le_refl _⟩
  have hstep : ∀ n, EMLIterOp.iterSeq D.a D.b D.c D.hi (n + 1) ≤
      EMLIterOp.iterSeq D.a D.b D.c D.hi n := by
    intro n
    induction n with
    | zero =>
        have := (D.maps_to D.hi hhi).2
        simpa [EMLIterOp.iterSeq] using this
    | succ k ih =>
        have hmem : EMLIterOp.iterSeq D.a D.b D.c D.hi k ∈ Icc D.lo D.hi :=
          EMLIterOp.iterSeq_mem_Icc D.a D.b D.c D.hi D.lo D.hi hhi D.maps_to k
        have hmem1 : EMLIterOp.iterSeq D.a D.b D.c D.hi (k + 1) ∈ Icc D.lo D.hi :=
          EMLIterOp.iterSeq_mem_Icc D.a D.b D.c D.hi D.lo D.hi hhi D.maps_to (k + 1)
        have := op_monotoneOn D.a D.b D.c D.lo D.hi hb D.arg_pos hmem1 ih
        simpa [EMLIterOp.iterSeq] using this
  exact antitone_nat_of_succ_le hstep

/-- Squeeze from below: if `x*` is a fixed point in the interval, then every
lower-orbit iterate stays at or below it. -/
theorem iterSeq_lo_le_fixedPoint (D : EMLContractionData) (hb : 0 < D.b)
    {xstar : ℝ} (hfix : EMLIterOp D.a D.b D.c xstar = xstar)
    (hmem : xstar ∈ Icc D.lo D.hi) (n : ℕ) :
    EMLIterOp.iterSeq D.a D.b D.c D.lo n ≤ xstar := by
  have hlo : D.lo ∈ Icc D.lo D.hi := ⟨le_refl _, D.lo_lt_hi.le⟩
  induction n with
  | zero => simpa [EMLIterOp.iterSeq] using hmem.1
  | succ k ih =>
      have hmemk : EMLIterOp.iterSeq D.a D.b D.c D.lo k ∈ Icc D.lo D.hi :=
        EMLIterOp.iterSeq_mem_Icc D.a D.b D.c D.lo D.lo D.hi hlo D.maps_to k
      have hstep := op_monotoneOn D.a D.b D.c D.lo D.hi hb D.arg_pos hmemk ih
      calc EMLIterOp.iterSeq D.a D.b D.c D.lo (k + 1)
            = EMLIterOp D.a D.b D.c (EMLIterOp.iterSeq D.a D.b D.c D.lo k) := rfl
        _ ≤ EMLIterOp D.a D.b D.c xstar := hstep
        _ = xstar := hfix

/-- Squeeze from above: every upper-orbit iterate stays at or above the fixed
point. -/
theorem iterSeq_fixedPoint_le_hi (D : EMLContractionData) (hb : 0 < D.b)
    {xstar : ℝ} (hfix : EMLIterOp D.a D.b D.c xstar = xstar)
    (hmem : xstar ∈ Icc D.lo D.hi) (n : ℕ) :
    xstar ≤ EMLIterOp.iterSeq D.a D.b D.c D.hi n := by
  have hhi : D.hi ∈ Icc D.lo D.hi := ⟨D.lo_lt_hi.le, le_refl _⟩
  induction n with
  | zero => simpa [EMLIterOp.iterSeq] using hmem.2
  | succ k ih =>
      have hmemk : EMLIterOp.iterSeq D.a D.b D.c D.hi k ∈ Icc D.lo D.hi :=
        EMLIterOp.iterSeq_mem_Icc D.a D.b D.c D.hi D.lo D.hi hhi D.maps_to k
      have hstep := op_monotoneOn D.a D.b D.c D.lo D.hi hb D.arg_pos hmem ih
      calc xstar = EMLIterOp D.a D.b D.c xstar := hfix.symm
        _ ≤ EMLIterOp D.a D.b D.c (EMLIterOp.iterSeq D.a D.b D.c D.hi k) := hstep
        _ = EMLIterOp.iterSeq D.a D.b D.c D.hi (k + 1) := rfl

/-- **Certified two-sided enclosure.** For an EML contraction with `b > 0` there
is a unique fixed point `x*` in the interval such that the lower orbit `fⁿ(lo)`
and upper orbit `fⁿ(hi)` bracket it at every step, `ℓₙ ≤ x* ≤ uₙ`, both converge
to `x*`, and the bracket width `uₙ − ℓₙ` tends to `0`. -/
theorem certified_enclosure (D : EMLContractionData) (hb : 0 < D.b) :
    ∃ xstar, EMLIterOp D.a D.b D.c xstar = xstar ∧ xstar ∈ Icc D.lo D.hi ∧
      (∀ n, EMLIterOp.iterSeq D.a D.b D.c D.lo n ≤ xstar) ∧
      (∀ n, xstar ≤ EMLIterOp.iterSeq D.a D.b D.c D.hi n) ∧
      Tendsto (EMLIterOp.iterSeq D.a D.b D.c D.lo) atTop (𝓝 xstar) ∧
      Tendsto (EMLIterOp.iterSeq D.a D.b D.c D.hi) atTop (𝓝 xstar) ∧
      Tendsto (fun n => EMLIterOp.iterSeq D.a D.b D.c D.hi n -
        EMLIterOp.iterSeq D.a D.b D.c D.lo n) atTop (𝓝 0) := by
  have hlo : D.lo ∈ Icc D.lo D.hi := ⟨le_refl _, D.lo_lt_hi.le⟩
  have hhi : D.hi ∈ Icc D.lo D.hi := ⟨D.lo_lt_hi.le, le_refl _⟩
  -- limit of the lower orbit
  obtain ⟨xstar, hlim_lo, hfix, hmem⟩ := EMLIterOp.iterSeq_converges D D.lo hlo
  -- limit of the upper orbit (a fixed point in the interval)
  obtain ⟨ystar, hlim_hi, hfixy, hmemy⟩ := EMLIterOp.iterSeq_converges D D.hi hhi
  -- uniqueness identifies the two limits
  have hxy : ystar = xstar :=
    EMLIterOp.fixedPoint_unique D.a D.b D.c D.lo D.hi D.rho D.lo_lt_hi
      D.rho_lt_one D.rho_nonneg D.arg_pos D.deriv_bound ystar xstar hmemy hmem hfixy hfix
  have hlim_hi' : Tendsto (EMLIterOp.iterSeq D.a D.b D.c D.hi) atTop (𝓝 xstar) := by
    rw [← hxy]; exact hlim_hi
  refine ⟨xstar, hfix, hmem, ?_, ?_, hlim_lo, hlim_hi', ?_⟩
  · exact iterSeq_lo_le_fixedPoint D hb hfix hmem
  · exact iterSeq_fixedPoint_le_hi D hb hfix hmem
  · have : Tendsto (fun n => EMLIterOp.iterSeq D.a D.b D.c D.hi n -
        EMLIterOp.iterSeq D.a D.b D.c D.lo n) atTop (𝓝 (xstar - xstar)) :=
      hlim_hi'.sub hlim_lo
    simpa using this

end EMLIterOp

end