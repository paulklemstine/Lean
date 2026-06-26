/-
Copyright (c) 2025. All rights reserved.

# Idempotent Large Deviations: Exponential Tilting (Esscher Transform)

This file develops the **idempotent exponential tilt** (the max-plus Esscher /
Cramér change of measure) and uses it to *constructively* realise the supporting
line of the Legendre–Fenchel duality from
`Catalog/Tropical/MeasureTheory/LargeDeviations.lean`.

Classically the tilt `dP^λ ∝ exp(λ·X) dP` shifts the cumulant generating function
by `Λ^λ(μ) = Λ(λ+μ) - Λ(λ)` and makes the deviation point `x_λ = Λ'(λ)` *typical*.
In the idempotent world the tilt is the additive reweighting
`w^λ(x) = λ·val(x) + w(x) - Λ(λ)`, where `Λ` is the idempotent CGF.  We prove:

* the idempotent tilt of **any** max-plus measure is a tropical probability;
* the rate function tilts affinely, `I^λ(x) = I(x) - λ·val(x) + Λ(λ)`;
* the CGF satisfies the exact cocycle law `Λ^λ(μ) = Λ(λ+μ) - Λ(λ)`;
* every full-support point of the tilt is a **Cramér-exposed** point, where the
  Legendre–Fenchel biconjugate recovers the rate function exactly — and such a
  point always exists, so *for every slope `λ` the idempotent Cramér duality is
  tight somewhere*.

This is the constructive counterpart to the `DualityGap.lean` obstruction: tilting
explains exactly *which* points are reached by a supporting line of slope `λ`.

## Main results

* `tiltedMeasure_isProb` — the idempotent tilt is a tropical probability.
* `tilted_rate` — affine tilt of the rate function.
* `tilted_cgf` — **cocycle law** for the idempotent CGF under tilting.
* `tilt_provides_support` — a full-support tilt point has a supporting line.
* `tilt_cramer_tight` — at such a point the biconjugate equals the rate.
* `exists_cramer_tight_point` — for every slope a Cramér-tight point exists.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The classical Cramér tilt should have an exact
  idempotent analogue, and — bold claim — tilting should *constructively* produce
  the supporting lines whose mere existence was assumed in
  `lfBiconj_eq_rate_of_support`.  Conjecture: for every slope `λ` there is a point
  at which the idempotent Cramér duality is tight, so the duality gap of
  `DualityGap.lean` can only ever occur *away* from the tilt-exposed points.
Experiment (Experimenter): Defined the additive tilt `w^λ = λ·val + w - Λ(λ)` and
  proved (i) it is always a tropical probability (subtracting the sup normalises),
  (ii) the rate function tilts affinely, and (iii) the CGF cocycle law via
  `Finset.sup'_add_const`.  A point `x` is "full-support" under the tilt iff
  `w^λ(x)=0` iff `λ·val x + w x = Λ(λ)` iff `x` maximises the tilted observable;
  at such `x`, `I(x) = λ·val x - Λ(λ)` is exactly the supporting-line identity, so
  the catalog lemma `lfBiconj_eq_rate_of_support` applies verbatim.  Existence is the
  idempotent normalisation `idempotentRate_eq_zero_somewhere` applied to the tilt.
Analysis (Analyst): The conjecture SURVIVES.  Tilting is the missing constructor:
  it shows the supporting-line hypothesis of `lfBiconj_eq_rate_of_support` is never
  vacuous — every slope exposes at least one point.  The `DualityGap.lean` spike is
  consistent: its middle point is simply not tilt-exposed by ANY slope (no `λ` makes
  it a maximiser), which is exactly why the biconjugate misses it.
Critique (Critic): `tiltedMeasure` is a genuine reweighting (not a rename), the
  `isProb` proof uses `Finset.sup'_add_const`/`le_antisymm` rather than `decide`,
  and `tilt_cramer_tight` genuinely consumes the catalog result
  `lfBiconj_eq_rate_of_support`.  The construction needs no hypothesis on `P` at all,
  which strengthens the original statement.
-- !-- end Lab Notes -- !--
-/

import Mathlib
import Catalog.Tropical.MeasureTheory.Basic
import Catalog.Tropical.MeasureTheory.LargeDeviations

namespace TropicalLDP.Tilting

open TropicalMeasureTheory TropicalLDP Finset

variable {X : Type*} [Fintype X] [Nonempty X]

/-- The **idempotent exponential tilt** of `P` by slope `lam` along observable
`val`: the additive reweighting `w^λ(x) = λ·val(x) + w(x) - Λ(λ)`, where
`Λ = idempotentCGF P val` is the idempotent cumulant generating function. -/
noncomputable def tiltedMeasure (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) :
    MaxPlusMeasure X :=
  ⟨fun x => lam * val x + P.weight x - idempotentCGF P val lam⟩

theorem tiltedMeasure_weight (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) (x : X) :
    (tiltedMeasure P val lam).weight x
      = lam * val x + P.weight x - idempotentCGF P val lam := rfl

/-
The idempotent tilt of **any** max-plus measure is a tropical probability:
subtracting the cumulant generating function normalises the total mass to `0`.
-/
instance tiltedMeasure_isProb (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) :
    IsTropicalProbability X (tiltedMeasure P val lam) := by
  constructor;
  · convert Finset.sup'_add_const ( Finset.univ_nonempty ) ( fun x => lam * val x + P.weight x ) ( -idempotentCGF P val lam ) using 1;
    exact Eq.symm ( by rw [ idempotentCGF_eq ] ; ring );
  · intro x
    simp [tiltedMeasure_weight];
    exact Finset.le_sup' ( fun x => lam * val x + P.weight x ) ( Finset.mem_univ x )

/-
**Affine tilt of the rate function**: `I^λ(x) = I(x) - λ·val(x) + Λ(λ)`.
-/
theorem tilted_rate (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) (x : X) :
    idempotentRate (tiltedMeasure P val lam) x
      = idempotentRate P x - lam * val x + idempotentCGF P val lam := by
  unfold idempotentRate tiltedMeasure; ring;

/-
**Cocycle law for the idempotent CGF under tilting**:
`Λ^λ(μ) = Λ(λ+μ) - Λ(λ)`.  This is the exact idempotent analogue of the classical
`E^λ[exp(μX)] = E[exp((λ+μ)X)]/E[exp(λX)]`.
-/
theorem tilted_cgf (P : MaxPlusMeasure X) (val : X → ℝ) (lam mu : ℝ) :
    idempotentCGF (tiltedMeasure P val lam) val mu
      = idempotentCGF P val (lam + mu) - idempotentCGF P val lam := by
  unfold idempotentCGF tiltedMeasure;
  convert sup'_add_const ( Finset.univ_nonempty ) ( fun x => ( lam + mu ) * val x + P.weight x ) ( -idempotentCGF P val lam ) using 1;
  unfold maxPlusIntegral; congr; ext; ring;

/-
A **full-support point** of the tilt (weight `0`) carries a supporting line of
slope `lam` for the rate function: `I(x) = λ·val(x) - Λ(λ)`.
-/
theorem tilt_provides_support (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) (x : X)
    (hx : (tiltedMeasure P val lam).weight x = 0) :
    idempotentRate P x = lam * val x - idempotentCGF P val lam := by
  unfold idempotentRate tiltedMeasure at *; norm_num at *; linarith;

/-- **Cramér duality is tight at tilt-exposed points**: at a full-support point of
the tilt, the Legendre–Fenchel biconjugate recovers the rate function exactly.
Uses the catalog result `lfBiconj_eq_rate_of_support`. -/
theorem tilt_cramer_tight (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) (x : X)
    (hx : (tiltedMeasure P val lam).weight x = 0) :
    lfBiconj P val (val x) = idempotentRate P x :=
  lfBiconj_eq_rate_of_support P val x (tilt_provides_support P val lam x hx)

/-
**Existence of a Cramér-tight point for every slope**: for any `lam` there is a
point at which the idempotent Cramér duality holds with equality.  Hence the
supporting-line hypothesis of `lfBiconj_eq_rate_of_support` is never vacuous.
-/
theorem exists_cramer_tight_point (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) :
    ∃ x : X, lfBiconj P val (val x) = idempotentRate P x := by
  have := @TropicalLDP.idempotentRate_eq_zero_somewhere X _ _ ( tiltedMeasure P val lam );
  obtain ⟨ x, hx ⟩ := this;
  exact ⟨ x, tilt_cramer_tight P val lam x ( by unfold idempotentRate at hx; linarith ) ⟩

end TropicalLDP.Tilting