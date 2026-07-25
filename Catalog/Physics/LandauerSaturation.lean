import Mathlib
import Logic.JarzynskiLandauer
import Physics.LandauerSecondLaw

/-!
# Saturation of Landauer's Bound: Tightness ⇔ Reversibility (Zero Work Fluctuations)

**Catalog category: cross-domain bridge (extends the Landauer development).**

`Physics.LandauerSecondLaw` upgraded the finite Jarzynski *identity* of
`Logic.JarzynskiLandauer` to the second-law *inequality* `ΔF ≤ E[W]`, and hence to
Landauer's `k·T·log 2` bound. It left open the **equality case**: *when* is the bound
saturated?

This file answers that question. The bound is tight **iff the dissipated work has no
fluctuations on the support of the distribution** — i.e. `W` is (almost surely)
constant. Physically: Landauer's bound `k·T·log 2` is achieved *only* in the
quasi-static, reversible limit; any genuine fluctuation in the erasure work forces a
*strictly* larger mean dissipation. This is the sharp finite-size statement of the
"Jarzynski-like correction term": it is strictly positive away from the reversible
limit and vanishes exactly at it.

The technical core is the **strict** Jensen-type bound `1 + E[g] < E[exp g]` whenever
`g` is nonzero somewhere on the support, obtained from the strict pointwise inequality
`x + 1 < exp x` for `x ≠ 0` (`Real.add_one_lt_exp`).

## Main results

* `expect_add_one_lt_expect_exp` — strict finite Jensen bound.
* `work_fluctuation_gt_one_of_nonconstant` — fluctuating work gives `E[exp …] > 1`.
* `work_fluctuation_eq_one_iff` — `E[exp …] = 1` iff work is constant on the support.
* `work_correction_zero_iff` — the Jarzynski correction vanishes iff work is constant.
* `jarzynski_second_law_strict` — fluctuating work ⇒ `ΔF < E[W]` strictly.
* `jarzynski_second_law_eq_iff` — saturation `ΔF = E[W]` iff work is constant on support.
* `landauer_kT_bound_strict` — fluctuating erasure work ⇒ `k·T·log 2 < E[W]`.
* `landauer_saturation_iff` — Landauer's bound is saturated iff the erasure is reversible
  (zero work fluctuations).

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Jarzynski, C. (1997). Nonequilibrium equality for free energy differences.
- Sagawa, T. (2014). Thermodynamic and logical reversibilities revisited.
-/

noncomputable section

open BigOperators Real
open JarzynskiLandauer

namespace LandauerSaturation

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The catalog proved ΔF ≤ E[W] but never the equality case.
--   Conjecture: the bound is saturated EXACTLY when the work has zero fluctuations on the
--   support (the reversible/quasi-static limit), and otherwise the inequality is STRICT.
--   Counter-intuitive corollary: every real (fluctuating) erasure dissipates strictly more
--   than kT log 2 — the textbook bound is never attained by a genuinely stochastic process.
-- Experiment (Experimenter): Replace the non-strict Jensen bound (Real.add_one_le_exp,
--   Finset.sum_le_sum) used in LandauerSecondLaw by its STRICT form (Real.add_one_lt_exp,
--   Finset.sum_lt_sum). Numerically (ComputationalEvidence.md, two-outcome p=(1/2,1/2)):
--   E[exp(-(W-E[W]))] = cosh(Δ/2) > 1 unless the two work values coincide. Confirmed sharp.
-- Analysis (Analyst): Saturation reduces to "a mean-zero perturbation raises E[convex] and
--   raises it STRICTLY unless the perturbation is a.s. zero". The strict gap is exactly the
--   finite-size Jarzynski correction; it is the thermodynamic-irreversibility surcharge and
--   it is positive off the reversible manifold {W constant on supp p}.
-- Critique (Critic): Must restrict "constant" to the SUPPORT (p ω > 0), not all of Ω — off
--   support the work value is physically irrelevant and unconstrained. Need α ≠ 0 so that
--   -α(W-μ) ≠ 0 ⇔ W ≠ μ. The iff is genuine (both directions proved), not vacuous, and uses
--   add_one_lt_exp / log_eq_zero, insight-bearing analytic facts (not simp/decide).
-- Synthesis (PI): A sharp equality-case layer: ΔF = E[W] ⇔ reversible ⇔ zero fluctuations,
--   completing the second-law inequality of LandauerSecondLaw.
-- !-- end Lab Notes -- !--

variable {Ω : Type*} [Fintype Ω]

/-
**Strict finite Jensen bound for the exponential.** If `g` is nonzero at some point
of the support of `p`, then `1 + E[g] < E[exp g]`.
-/
theorem expect_add_one_lt_expect_exp (p : Ω → ℝ) (hp : IsPMF p) (g : Ω → ℝ)
    (hne : ∃ ω, 0 < p ω ∧ g ω ≠ 0) :
    1 + expect p g < expect p (fun ω => Real.exp (g ω)) := by
  unfold expect;
  rw [ show ( 1 : ℝ ) = ∑ ω, p ω * 1 by simp +decide [ hp.2 ] ];
  rw [ ← Finset.sum_add_distrib ];
  refine' Finset.sum_lt_sum _ _;
  · exact fun ω _ => by nlinarith [ hp.1 ω, Real.add_one_le_exp ( g ω ) ] ;
  · obtain ⟨ ω, hω₁, hω₂ ⟩ := hne; exact ⟨ ω, Finset.mem_univ _, by nlinarith [ Real.add_one_lt_exp hω₂, hp.1 ω ] ⟩ ;

/-
**A fluctuating work gives a strictly-greater-than-one fluctuation factor.** If the
work `W` differs from its mean at some point of the support, then the Jarzynski
fluctuation factor strictly exceeds one.
-/
theorem work_fluctuation_gt_one_of_nonconstant (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (α : ℝ) (hα : α ≠ 0) (hne : ∃ ω, 0 < p ω ∧ W ω ≠ expect p W) :
    1 < expect p (fun ω => Real.exp (-α * (W ω - expect p W))) := by
  obtain ⟨ω₀, hpω₀, hneω₀⟩ : ∃ ω, 0 < p ω ∧ W ω ≠ expect p W := hne;
  have := @expect_add_one_lt_expect_exp Ω _ p hp ( fun ω => -α * ( W ω - expect p W ) ) ?_;
  · linarith [ LandauerSecondLaw.expect_centered_zero p hp W α ];
  · exact ⟨ ω₀, hpω₀, mul_ne_zero ( neg_ne_zero.mpr hα ) ( sub_ne_zero.mpr hneω₀ ) ⟩

/-
**Equality case of the fluctuation factor.** For `α ≠ 0`, the Jarzynski fluctuation
factor equals one iff the work is constant on the support of `p`.
-/
theorem work_fluctuation_eq_one_iff (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (α : ℝ) (hα : α ≠ 0) :
    expect p (fun ω => Real.exp (-α * (W ω - expect p W))) = 1 ↔
      ∀ ω, 0 < p ω → W ω = expect p W := by
  constructor;
  · contrapose!;
    exact fun h => ne_of_gt ( work_fluctuation_gt_one_of_nonconstant p hp W α hα h );
  · intro h;
    refine' Eq.trans ( Finset.sum_congr rfl fun ω _ => _ ) hp.2;
    by_cases hω : 0 < p ω <;> simp_all +decide;
    rw [ le_antisymm hω ( hp.1 ω ), MulZeroClass.zero_mul ]

/-
**Equality case of the Jarzynski correction.** For `α ≠ 0`, the nonnegative
fluctuation correction `log E[exp(-α (W - E[W]))]` vanishes iff the work is constant
on the support of `p`.
-/
theorem work_correction_zero_iff (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (α : ℝ) (hα : α ≠ 0) :
    Real.log (expect p (fun ω => Real.exp (-α * (W ω - expect p W)))) = 0 ↔
      ∀ ω, 0 < p ω → W ω = expect p W := by
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ Real.log_eq_zero ];
  · refine' ⟨ _, _, _ ⟩;
    · exact ne_of_gt ( lt_of_lt_of_le zero_lt_one ( by simpa using LandauerSecondLaw.work_fluctuation_ge_one p hp W α ) );
    · exact ne_of_gt ( by simpa using work_fluctuation_gt_one_of_nonconstant p hp W α hα h );
    · exact ne_of_gt ( lt_of_lt_of_le ( by norm_num ) ( Finset.sum_nonneg fun _ _ => mul_nonneg ( hp.1 _ ) ( Real.exp_nonneg _ ) ) );
  · exact not_forall_not.mp fun h' => h.2.1 <| by simpa [ h' ] using work_fluctuation_eq_one_iff p hp W α hα |>.2 fun ω hω => Classical.not_not.1 fun hω' => h' ω ⟨ hω, hω' ⟩ ;

/-
**Strict second law.** If the dissipated work fluctuates on the support, then the
mean work *strictly* exceeds the free-energy difference.
-/
theorem jarzynski_second_law_strict (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (α ΔF : ℝ)
    (hα : 0 < α) (hJ : JarzynskiCondition p W α ΔF)
    (hne : ∃ ω, 0 < p ω ∧ W ω ≠ expect p W) :
    ΔF < expect p W := by
  have := JarzynskiLandauer.jarzynski_correction p W α ΔF ( ne_of_gt hα ) hJ;
  exact this.symm ▸ lt_add_of_pos_right _ ( mul_pos ( inv_pos.mpr hα ) ( Real.log_pos ( work_fluctuation_gt_one_of_nonconstant p hp W α ( ne_of_gt hα ) hne ) ) )

/-
**Saturation criterion for the second law.** For `α > 0`, the second-law bound is
saturated (`ΔF = E[W]`) iff the work is constant on the support — the reversible,
zero-fluctuation limit.
-/
theorem jarzynski_second_law_eq_iff (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (α ΔF : ℝ)
    (hα : 0 < α) (hJ : JarzynskiCondition p W α ΔF) :
    ΔF = expect p W ↔ ∀ ω, 0 < p ω → W ω = expect p W := by
  convert ( work_correction_zero_iff p hp W α ( ne_of_gt hα ) ) using 1;
  have := JarzynskiLandauer.jarzynski_correction p W α ΔF hα.ne' hJ;
  grind +qlia

/-
**Strict Landauer bound.** A genuinely fluctuating one-bit erasure dissipates a mean
work *strictly* greater than `k·T·log 2`. The textbook bound is attained only in the
reversible limit.
-/
theorem landauer_kT_bound_strict (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (k T : ℝ)
    (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2))
    (hne : ∃ ω, 0 < p ω ∧ W ω ≠ expect p W) :
    k * T * Real.log 2 < expect p W := by
  convert jarzynski_second_law_strict p hp W ( k * T ) ⁻¹ ( k * T * Real.log 2 ) ( inv_pos.mpr ( mul_pos hk hT ) ) hJ hne using 1

/-- **Saturation of Landauer's principle ⇔ reversibility.** For `k, T > 0`, Landauer's
bound `k·T·log 2` is saturated exactly when the erasure work has no fluctuations on the
support (the reversible / quasi-static limit). -/
theorem landauer_saturation_iff (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (k T : ℝ)
    (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) :
    k * T * Real.log 2 = expect p W ↔ ∀ ω, 0 < p ω → W ω = expect p W :=
  jarzynski_second_law_eq_iff p hp W (k * T)⁻¹ (k * T * Real.log 2)
    (inv_pos.2 (mul_pos hk hT)) hJ

end LandauerSaturation

end