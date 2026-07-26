/-
# The Boltzmann Bridge VI — The Interleaving Metric Quotient

This file discharges **Future Direction 1** of Boltzmann Bridge V
(`Applications.BoltzmannBridge.InterleavingMetric`).  The arc is:

* **II — `HigherPersistence`**: the filtration calculus (`Filtration`,
  `sublevelFaces`, `sublevel_mono`, the Vietoris–Rips `diamWeight`).
* **III — `PersistenceStability`**: the set-inclusion interleaving lemmas.
* **IV — `BottleneckStability`**: the relational interleaving preorder
  (`Interleaved`, `Interleaved_refl/symm/mono/trans`) and a real `interleavingDist`.
* **V — `InterleavingMetric`**: the `ℝ≥0∞`-valued `eInterleavingDist` and the
  representation theorem `interleavingPseudoEMetric : PseudoEMetricSpace
  (Filtration α)`.  Its honest defect: distinct filtrations can sit at extended
  distance `0`, so the structure is only a *pseudo*metric.
* **VI — `InterleavingQuotient` (this file)**: remove that defect categorically.
  `eInterleavingDist` already satisfies the pseudo-emetric axioms, so Mathlib's
  `SeparationQuotient` functor manufactures a true `EMetricSpace`
  (`interleavingEMetric`) for free, with the canonical map an **isometry**
  (`edist_quotient_mk`).  The kernel of the quotient is described intrinsically:
  two filtrations are identified **iff** their extended interleaving distance is
  `0` (`mk_eq_mk_iff_eInterleavingDist_zero`), and this holds **iff** there are
  admissible interleavings of arbitrarily small magnitude
  (`eInterleavingDist_eq_zero_iff`).  A literal `0`-interleaving is sufficient but,
  in general, not necessary (`mk_eq_mk_of_interleaved_zero`).

The decisive observation: the metric/pseudo-metric/true-metric ladder of the
whole arc is climbed purely by changing codomains (`ℝ → ℝ≥0∞`, Bridge V) and then
applying the universal `SeparationQuotient` reflection (this file).  The
distance-`0` kernel that Bridge V could only *document* is here *quotiented out*
by a universal construction, and characterised intrinsically.

## Main results

* `edist_quotient_mk` — `SeparationQuotient.mk` is an isometry for `eInterleavingDist`.
* `interleavingEMetric` — the genuine `EMetricSpace` on `SeparationQuotient (Filtration α)`.
* `mk_eq_mk_iff_eInterleavingDist_zero` — the metric kernel equals the distance-`0` relation.
* `eInterleavingDist_eq_zero_iff` — distance `0` ⇔ arbitrarily small interleavings.
* `mk_eq_mk_of_interleaved_zero` — a `0`-interleaving identifies in the quotient.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-- The pseudo-emetric structure of Bridge V, promoted to a (file-local) instance
so that the universal `SeparationQuotient` machinery of Mathlib applies. -/
noncomputable local instance interleavingPseudoEMetricInst :
    PseudoEMetricSpace (Filtration α) :=
  interleavingPseudoEMetric

-- !-- The instance's `edist` field is `eInterleavingDist` by construction, so this
-- !-- is `SeparationQuotient.edist_mk` followed by `rfl`. -- !--
/-- **The quotient map is an isometry.**  The extended distance between two
filtration classes in the `SeparationQuotient` is the extended interleaving
distance of any representatives. -/
theorem edist_quotient_mk (F G : Filtration α) :
    edist (SeparationQuotient.mk F) (SeparationQuotient.mk G) = eInterleavingDist F G := by
  rw [SeparationQuotient.edist_mk]; rfl

-- !-- Mathlib turns any `PseudoEMetricSpace` into an `EMetricSpace` on its
-- !-- `SeparationQuotient`; `inferInstance` finds it from the local instance above. -- !--
/-- **The representation theorem upgraded.**  The separation quotient of the
filtration pseudo-emetric space is a genuine `EMetricSpace`: distinct points are
now at strictly positive distance. -/
noncomputable def interleavingEMetric : EMetricSpace (SeparationQuotient (Filtration α)) :=
  inferInstance

-- !-- `SeparationQuotient.mk_eq_mk` reduces equality of classes to `Inseparable`,
-- !-- and `EMetric.inseparable_iff` turns that into `edist = 0`, which is
-- !-- `eInterleavingDist = 0` definitionally. -- !--
/-- **The metric kernel is the distance-`0` relation.**  Two filtrations are
identified in the separation quotient iff their extended interleaving distance is
`0`. -/
theorem mk_eq_mk_iff_eInterleavingDist_zero (F G : Filtration α) :
    (SeparationQuotient.mk F : SeparationQuotient (Filtration α)) = SeparationQuotient.mk G
      ↔ eInterleavingDist F G = 0 := by
  rw [SeparationQuotient.mk_eq_mk, EMetric.inseparable_iff]
  rfl

-- !-- Forward: `0 < ofReal ε` and `iInf = 0` give, via `iInf_lt_iff`, a witness
-- !-- subtype element below `ofReal ε`; `ofReal_lt_ofReal_iff` extracts `δ < ε`.
-- !-- Backward: each `δ < ε` gives `eInterleavingDist ≤ ofReal δ < ofReal ε`, and a
-- !-- value below every positive `ofReal ε` is `0`. -- !--
/-- **Distance `0` ⇔ arbitrarily small interleavings.**  The extended interleaving
distance is `0` exactly when, for every positive scale `ε`, there is an admissible
interleaving shift `δ < ε`.  This is the limiting characterisation of the metric
kernel: the infimum need not be attained, so `0` distance means only that
interleavings can be made arbitrarily tight. -/
theorem eInterleavingDist_eq_zero_iff (F G : Filtration α) :
    eInterleavingDist F G = 0 ↔ ∀ ε : ℝ, 0 < ε → ∃ δ : ℝ, Interleaved F G δ ∧ δ < ε := by
  constructor
  · intro h ε hε
    have hlt : eInterleavingDist F G < ENNReal.ofReal ε := by
      rw [h]; exact ENNReal.ofReal_pos.mpr hε
    rw [eInterleavingDist] at hlt
    obtain ⟨x, hx⟩ := iInf_lt_iff.mp hlt
    exact ⟨x.1, x.2, (ENNReal.ofReal_lt_ofReal_iff hε).mp hx⟩
  · intro h
    have key : ∀ ε : ℝ, 0 < ε → eInterleavingDist F G < ENNReal.ofReal ε := by
      intro ε hε
      obtain ⟨δ, hδ, hlt⟩ := h ε hε
      calc eInterleavingDist F G ≤ ENNReal.ofReal δ := eInterleavingDist_le F G hδ
        _ < ENNReal.ofReal ε := (ENNReal.ofReal_lt_ofReal_iff hε).mpr hlt
    -- a value below every positive `ofReal ε` is `0`
    set a := eInterleavingDist F G with ha
    rcases eq_or_ne a 0 with h0 | h0
    · exact h0
    · exfalso
      rcases eq_top_or_lt_top a with htop | hfin
      · have := key 1 (by norm_num); rw [htop] at this; simp at this
      · have hr : 0 < a.toReal := ENNReal.toReal_pos h0 hfin.ne
        have := key a.toReal hr
        rw [ENNReal.ofReal_toReal hfin.ne] at this
        exact lt_irrefl _ this

-- !-- `Interleaved F G 0` gives `eInterleavingDist ≤ ofReal 0 = 0`, hence `= 0`;
-- !-- then `mk_eq_mk_iff_eInterleavingDist_zero` identifies the classes. -- !--
/-- **A `0`-interleaving identifies in the quotient.**  If two filtrations are
literally `0`-interleaved, their classes coincide in the separation quotient.
(The converse fails in general: the infimum defining `eInterleavingDist` need not
be attained — see `eInterleavingDist_eq_zero_iff`.) -/
theorem mk_eq_mk_of_interleaved_zero (F G : Filtration α) (h : Interleaved F G 0) :
    (SeparationQuotient.mk F : SeparationQuotient (Filtration α)) = SeparationQuotient.mk G := by
  rw [mk_eq_mk_iff_eInterleavingDist_zero]
  have hle : eInterleavingDist F G ≤ ENNReal.ofReal 0 := eInterleavingDist_le F G h
  simpa using le_antisymm (by simpa using hle) (zero_le _)

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge V left a genuine *pseudo*-emetric defect: distinct filtrations can sit at
extended interleaving distance `0`, so `interleavingPseudoEMetric` is not a true
metric.  The hypothesis is that this defect is removed not by an ad-hoc quotient
construction but **categorically**, by Mathlib's universal `SeparationQuotient`
reflection, which turns any `PseudoEMetricSpace` into an `EMetricSpace` with the
quotient map an isometry — and that the distance-`0` kernel admits an intrinsic
description in terms of `Interleaved`.

## Result
Confirmed.  Promoting `eInterleavingDist` to a local `PseudoEMetricSpace` instance,
`SeparationQuotient (Filtration α)` is a genuine `EMetricSpace`
(`interleavingEMetric`) and `SeparationQuotient.mk` is an isometry
(`edist_quotient_mk`).  The kernel is exactly the distance-`0` relation
(`mk_eq_mk_iff_eInterleavingDist_zero`), which holds iff interleavings can be made
arbitrarily small (`eInterleavingDist_eq_zero_iff`).  A literal `0`-interleaving is
sufficient (`mk_eq_mk_of_interleaved_zero`).

## Insight
The whole metric ladder of the arc is climbed by *changing codomains*
(`ℝ → ℝ≥0∞`, Bridge V) and then applying *one universal construction*
(`SeparationQuotient`, this file).  The kernel characterisation
`eInterleavingDist_eq_zero_iff` is a pure infimum-in-`ℝ≥0∞` squeeze
(`iInf_lt_iff` one way, "below every positive `ofReal ε`" the other), exposing
that "distance `0`" is a *limiting* statement, not the attainment of a literal
`0`-interleaving.

## Failure analysis
`mk_eq_mk_of_interleaved_zero` is genuinely one-directional: the infimum defining
`eInterleavingDist` need not be attained, so distance `0` does **not** imply a
literal `0`-interleaving.  Upgrading the limiting characterisation
`eInterleavingDist_eq_zero_iff` to the clean algebraic equivalence
`eInterleavingDist F G = 0 ↔ Interleaved F G 0` requires closedness of the
witness set `{δ | Interleaved F G δ}` — deferred to Future Direction 1.
-/

end BoltzmannBridge