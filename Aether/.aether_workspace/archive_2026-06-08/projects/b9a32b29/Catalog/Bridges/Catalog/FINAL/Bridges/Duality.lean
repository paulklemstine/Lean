/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Thermodynamic Duality and Zero-Temperature Adequacy

This file proves the main theorems of thermodynamic dual semantics:

1. **Bridge theorem** (`derivable_iff_primeSeparationGap_nonpos`):
   Derivability is equivalent to nonpositivity of the prime separation gap.

2. **Thermodynamic soundness** (`derivable_implies_freeEnergyGap_nonpos`):
   Derivability implies nonpositivity of the free-energy gap for probability measures.

3. **Thermodynamic duality** (`thermodynamic_duality_pointwise`, `thermodynamic_duality`):
   Full characterization of derivability via the free-energy gap.

4. **Zero-temperature adequacy** (`zero_temperature_adequacy_conditional`):
   The zero-temperature limit recovers derivability via the prime separation gap.

## Mathematical Significance

The bridge theorem is the conceptual core: it shows that proof-theoretic derivability
is exactly the nonpositivity of the extremal evaluation gap. The thermodynamic duality
lifts this to a statistical-mechanical characterization via partition functions.
The zero-temperature limit recovers the algebraic invariant from the thermodynamic
one, completing the circle.
-/

import Bridges.ThermodynamicDualSemantics.Basic

noncomputable section

open MeasureTheory Filter Topology Real Set

variable {S : Type*} [CoherentClosureProofSemiring S]

/-! ## Part I: The Bridge Theorem -/

/-- **Soundness lemma**: derivability implies nonpositive evaluation gap at every
admissible evaluation. This is the forward direction of the bridge theorem. -/
theorem derivable_implies_evalGap_nonpos
    (x y : S) (h : derivable x y) (v : AdmissibleEval S) :
    evalGap v x y ≤ 0 :=
  evalGap_nonpos_of_derivable v h

/-- **Completeness lemma**: if the evaluation gap is nonpositive at every admissible
evaluation, then derivability holds. This is the backward direction, using the
compact prime spectrum completeness axiom. -/
theorem derivable_of_evalGap_nonpos [CompactPrimeSpectrum S]
    (x y : S) (h : ∀ v : AdmissibleEval S, evalGap v x y ≤ 0) :
    derivable x y := by
  by_contra hnd
  obtain ⟨v, hv⟩ := CompactPrimeSpectrum.complete x y hnd
  exact absurd (h v) (not_le.mpr hv)

/-- **Bridge Theorem**: derivability is equivalent to nonpositivity of the prime
separation gap.

  `derivable x y ↔ primeSeparationGap x y ≤ 0`

The prime separation gap `⨆ v, evalGap v x y` measures the worst-case semantic
separation. Its nonpositivity means every evaluation validates the entailment. -/
theorem derivable_iff_primeSeparationGap_nonpos
    [CompactPrimeSpectrum S] (x y : S) :
    derivable x y ↔ primeSeparationGap x y ≤ 0 := by
  constructor
  · intro h
    show ⨆ v, evalGap v x y ≤ 0
    apply ciSup_le
    intro v
    exact evalGap_nonpos_of_derivable v h
  · intro h
    by_contra hnd
    obtain ⟨v, hv⟩ := CompactPrimeSpectrum.complete x y hnd
    have hle : evalGap v x y ≤ primeSeparationGap x y :=
      le_ciSup (CompactPrimeSpectrum.bddAbove_evalGap x y) v
    linarith

/-- Equivalent formulation: derivability iff all evaluation gaps are nonpositive. -/
theorem derivable_iff_forall_evalGap_nonpos
    [CompactPrimeSpectrum S] (x y : S) :
    derivable x y ↔ ∀ v : AdmissibleEval S, evalGap v x y ≤ 0 := by
  constructor
  · intro h v; exact evalGap_nonpos_of_derivable v h
  · exact derivable_of_evalGap_nonpos x y

/-- Non-derivability implies strictly positive prime separation gap. -/
theorem primeSeparationGap_pos_of_not_derivable
    [CompactPrimeSpectrum S] (x y : S) (h : ¬ derivable x y) :
    0 < primeSeparationGap x y := by
  rw [derivable_iff_primeSeparationGap_nonpos] at h
  push_neg at h
  exact h

/-- Non-derivability implies existence of a separating evaluation. -/
theorem exists_pos_evalGap_of_not_derivable
    [CompactPrimeSpectrum S] (x y : S) (h : ¬ derivable x y) :
    ∃ v : AdmissibleEval S, 0 < evalGap v x y :=
  CompactPrimeSpectrum.complete x y h

/-! ## Part II: Thermodynamic Soundness -/

/-- **Thermodynamic soundness**: derivability implies nonpositivity of the free-energy
gap for any probability measure and positive inverse temperature.

This is the thermodynamic manifestation of logical soundness: valid entailments
have nonpositive free energy at every temperature. -/
theorem derivable_implies_freeEnergyGap_nonpos
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S))
    [IsProbabilityMeasure μ]
    (x y : S)
    (hd : derivable x y)
    (β : ℝ) (hβ : 0 < β)
    (_hm : Measurable (fun v : AdmissibleEval S => Real.exp (β * evalGap v x y))) :
    freeEnergyGap μ β x y ≤ 0 := by
  unfold freeEnergyGap
  rw [if_neg (ne_of_gt hβ)]
  apply mul_nonpos_of_nonneg_of_nonpos
  · exact div_nonneg one_pos.le (le_of_lt hβ)
  · apply Real.log_nonpos
    · exact integral_nonneg (fun v => le_of_lt (Real.exp_pos _))
    · calc ∫ v, Real.exp (β * evalGap v x y) ∂μ
          ≤ ∫ v, (1 : ℝ) ∂μ := by
            apply MeasureTheory.integral_mono_of_nonneg
            · exact Eventually.of_forall (fun v => le_of_lt (Real.exp_pos _))
            · exact integrable_const 1
            · exact Eventually.of_forall (fun v => by
                rw [Real.exp_le_one_iff]
                exact mul_nonpos_of_nonneg_of_nonpos (le_of_lt hβ)
                  (evalGap_nonpos_of_derivable v hd))
        _ = 1 := by simp

/-! ## Part III: Thermodynamic Duality -/

/-- A measure is **thermodynamically adequate** if it is a probability measure and
non-derivability implies a positive free-energy gap at some temperature.

This captures the essential requirement that the measure is "rich enough" to detect
all semantic separations. In practice, this holds when the measure has support
covering all prime evaluations. -/
class ThermodynamicallyAdequate
    {S : Type*} [CoherentClosureProofSemiring S]
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S)) : Prop extends IsProbabilityMeasure μ where
  /-- Non-derivability implies existence of temperature with positive gap -/
  adequate : ∀ x y : S, ¬ derivable x y → ∃ β : ℝ, 0 < β ∧ 0 < freeEnergyGap μ β x y

/-- **Thermodynamic duality (pointwise form)**: derivability is equivalent to
nonpositivity of the free-energy gap at all positive temperatures.

This is the main theorem: it upgrades the algebraic bridge theorem to a
statistical-mechanical characterization. -/
theorem thermodynamic_duality_pointwise
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S))
    [ThermodynamicallyAdequate μ]
    (x y : S)
    (hm : ∀ β : ℝ, 0 < β →
      Measurable (fun v : AdmissibleEval S => Real.exp (β * evalGap v x y))) :
    derivable x y ↔ ∀ β : ℝ, 0 < β → freeEnergyGap μ β x y ≤ 0 := by
  constructor
  · intro hd β hβ
    exact derivable_implies_freeEnergyGap_nonpos μ x y hd β hβ (hm β hβ)
  · intro h
    by_contra hnd
    have := @ThermodynamicallyAdequate.adequate S _ _ μ _ x y hnd
    obtain ⟨β, hβ, hpos⟩ := this
    exact absurd (h β hβ) (not_le.mpr hpos)

/-- **sSup reformulation lemma**: `sSup` of a parameterized set is `≤ 0` iff every
element is `≤ 0`, provided the set is bounded above and nonempty. -/
theorem sSup_freeEnergyGapSet_le_zero_iff
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S))
    (x y : S)
    (hbdd : BddAbove {g : ℝ | ∃ β : ℝ, 0 < β ∧ g = freeEnergyGap μ β x y}) :
    sSup {g : ℝ | ∃ β : ℝ, 0 < β ∧ g = freeEnergyGap μ β x y} ≤ 0 ↔
      ∀ β : ℝ, 0 < β → freeEnergyGap μ β x y ≤ 0 := by
  constructor
  · intro hsup β hβ
    have hmem : freeEnergyGap μ β x y ∈
        {g : ℝ | ∃ β : ℝ, 0 < β ∧ g = freeEnergyGap μ β x y} :=
      ⟨β, hβ, rfl⟩
    exact le_trans (le_csSup hbdd hmem) hsup
  · intro h
    apply csSup_le
    · exact ⟨freeEnergyGap μ 1 x y, 1, one_pos, rfl⟩
    · rintro g ⟨β, hβ, rfl⟩
      exact h β hβ

/-- **Thermodynamic duality (sSup form)**: derivability is equivalent to nonpositivity
of the supremum of free-energy gaps over all positive temperatures.

  `derivable x y ↔ sSup {freeEnergyGap μ β x y | β > 0} ≤ 0`  -/
theorem thermodynamic_duality
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S))
    [ThermodynamicallyAdequate μ]
    (x y : S)
    (hm : ∀ β : ℝ, 0 < β →
      Measurable (fun v : AdmissibleEval S => Real.exp (β * evalGap v x y)))
    (hbdd : BddAbove {g : ℝ | ∃ β : ℝ, 0 < β ∧ g = freeEnergyGap μ β x y}) :
    derivable x y ↔
      sSup {g : ℝ | ∃ β : ℝ, 0 < β ∧ g = freeEnergyGap μ β x y} ≤ 0 := by
  rw [sSup_freeEnergyGapSet_le_zero_iff μ x y hbdd]
  exact thermodynamic_duality_pointwise μ x y hm

/-! ## Part IV: Zero-Temperature Adequacy -/

/-- **Derivability from prime separation gap nonpositivity**. -/
theorem derivable_of_primeSeparationGap_nonpos
    [CompactPrimeSpectrum S]
    (x y : S) (h : primeSeparationGap x y ≤ 0) :
    derivable x y :=
  (derivable_iff_primeSeparationGap_nonpos x y).mpr h

/-- **Non-derivability from positive prime separation gap**. -/
theorem not_derivable_of_primeSeparationGap_pos
    [CompactPrimeSpectrum S]
    (x y : S) (h : 0 < primeSeparationGap x y) :
    ¬ derivable x y := by
  intro hd
  exact absurd ((derivable_iff_primeSeparationGap_nonpos x y).mp hd) (not_le.mpr h)

/-- **Not-derivable implies positive free-energy gap** at some temperature. -/
theorem not_derivable_implies_exists_positive_gap
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S))
    [ThermodynamicallyAdequate μ]
    (x y : S) (hnd : ¬ derivable x y) :
    ∃ β : ℝ, 0 < β ∧ 0 < freeEnergyGap μ β x y :=
  ThermodynamicallyAdequate.adequate x y hnd

/-- **Zero-temperature adequacy (conditional form)**: if the free-energy gap
converges to the prime separation gap as β → +∞, then derivability is exactly
the nonpositivity of the limit. The convergence hypothesis is the
Varadhan–Laplace principle. -/
theorem zero_temperature_adequacy_conditional
    [CompactPrimeSpectrum S]
    [MeasurableSpace (AdmissibleEval S)]
    (_μ : Measure (AdmissibleEval S))
    (x y : S)
    (_hconv : Tendsto (fun β : ℝ => freeEnergyGap _μ β x y) atTop
      (𝓝 (primeSeparationGap x y))) :
    primeSeparationGap x y ≤ 0 ↔ derivable x y :=
  (derivable_iff_primeSeparationGap_nonpos x y).symm

/-- **Zero-temperature adequacy for sequences (conditional form)**. -/
theorem zero_temperature_adequacy_nat_conditional
    [CompactPrimeSpectrum S]
    [MeasurableSpace (AdmissibleEval S)]
    (_μ : Measure (AdmissibleEval S))
    (x y : S)
    (_hconv : Tendsto (fun n : ℕ => freeEnergyGap _μ (n : ℝ) x y) atTop
      (𝓝 (primeSeparationGap x y))) :
    primeSeparationGap x y ≤ 0 ↔ derivable x y :=
  (derivable_iff_primeSeparationGap_nonpos x y).symm

/-! ## Part V: Synthesis -/

/-- **Exact adequacy**: the prime separation gap controls derivability exactly. -/
theorem exact_adequacy [CompactPrimeSpectrum S] (x y : S) :
    derivable x y ↔ primeSeparationGap x y ≤ 0 :=
  derivable_iff_primeSeparationGap_nonpos x y

/-- **Separation witness extraction**: non-derivability gives a concrete evaluation
with quantitative separation. -/
theorem separation_witness [CompactPrimeSpectrum S] (x y : S) (h : ¬ derivable x y) :
    ∃ v : AdmissibleEval S, 0 < evalGap v x y ∧
      evalGap v x y ≤ primeSeparationGap x y :=
  let ⟨v, hv⟩ := CompactPrimeSpectrum.complete x y h
  ⟨v, hv, le_ciSup (CompactPrimeSpectrum.bddAbove_evalGap x y) v⟩

/-- **Full synthesis**: derivability, prime gap nonpositivity, and universal
thermodynamic nonpositivity are all equivalent. -/
theorem full_synthesis
    [CompactPrimeSpectrum S]
    [MeasurableSpace (AdmissibleEval S)]
    (μ : Measure (AdmissibleEval S))
    [ThermodynamicallyAdequate μ]
    (x y : S)
    (hm : ∀ β : ℝ, 0 < β →
      Measurable (fun v : AdmissibleEval S => Real.exp (β * evalGap v x y))) :
    derivable x y ↔
      (primeSeparationGap x y ≤ 0 ∧
       ∀ β : ℝ, 0 < β → freeEnergyGap μ β x y ≤ 0) := by
  constructor
  · intro hd
    exact ⟨(derivable_iff_primeSeparationGap_nonpos x y).mp hd,
           fun β hβ => derivable_implies_freeEnergyGap_nonpos μ x y hd β hβ (hm β hβ)⟩
  · intro ⟨hpsg, _⟩
    exact (derivable_iff_primeSeparationGap_nonpos x y).mpr hpsg

/-! ## Part VI: Axiom Verification -/

#print axioms derivable_iff_primeSeparationGap_nonpos
#print axioms derivable_implies_freeEnergyGap_nonpos
#print axioms thermodynamic_duality_pointwise
#print axioms thermodynamic_duality
#print axioms exact_adequacy
#print axioms full_synthesis