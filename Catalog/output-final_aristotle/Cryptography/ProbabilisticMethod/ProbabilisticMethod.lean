import Mathlib

/-!
# The probabilistic method: the first-moment (union bound) principle and the independent
Lovász Local Lemma

The *probabilistic method* proves the existence of a combinatorial object by exhibiting a
probability space in which a random object has the desired property with positive probability.

This file formalizes the two cleanest incarnations, in `Mathlib`'s measure-theoretic
probability framework.

* `ProbMethod.exists_forall_notMem_of_sum_measure_lt_one` — the **first-moment / union-bound
  principle**: if the total probability `∑ᵢ P(Aᵢ)` of finitely many "bad" events is `< 1`,
  then there is an outcome avoiding *every* `Aᵢ`. This is exactly the argument behind
  Erdős's Ramsey lower bound (the expected number of monochromatic cliques is `< 1`).
* `ProbMethod.measure_iInter_compl_pos_of_sum_lt_one` — the quantitative version giving
  `0 < P(⋂ᵢ Aᵢᶜ)`.
* `ProbMethod.iIndep_measure_iInter_compl_eq_prod` and
  `ProbMethod.iIndep_measure_iInter_compl_pos` — the **Lovász Local Lemma in the independent
  case** (dependency degree `d = 0`): for mutually independent events,
  `P(⋂ᵢ Aᵢᶜ) = ∏ᵢ (1 - P(Aᵢ))`, which is positive as soon as each `P(Aᵢ) < 1`.

All statements hold over an arbitrary probability space; the finite index makes them
constructive existence principles.
-/

open MeasureTheory ProbabilityTheory Finset

namespace ProbMethod

variable {Ω ι : Type*} [Fintype ι] [MeasurableSpace Ω]
  (μ : Measure Ω) [IsProbabilityMeasure μ] {A : ι → Set Ω}

/-- **First-moment principle**, quantitative form. If the expected number of bad events
(`∑ᵢ P(Aᵢ)`) is `< 1`, then the probability that *no* bad event occurs is strictly positive. -/
theorem measure_iInter_compl_pos_of_sum_lt_one
    (hA : ∀ i, MeasurableSet (A i)) (h : ∑ i, μ (A i) < 1) :
    0 < μ (⋂ i, (A i)ᶜ) := by
  -- Since the union of the complements is measurable, we can apply the measure complement property.
  have union_compl_meas : MeasurableSet (⋃ i, A i) := by
    exact MeasurableSet.iUnion hA;
  rw [ ← Set.compl_iUnion, measure_compl ] <;> norm_num [ union_compl_meas ];
  exact lt_of_le_of_lt ( MeasureTheory.measure_iUnion_fintype_le _ _ ) h

/-- **The probabilistic method / union bound.** If the total probability of finitely many
events is `< 1`, then some outcome lies outside all of them. This is the engine of Erdős's
non-constructive existence proofs. -/
theorem exists_forall_notMem_of_sum_measure_lt_one
    (hA : ∀ i, MeasurableSet (A i)) (h : ∑ i, μ (A i) < 1) :
    ∃ ω, ∀ i, ω ∉ A i := by
  have hpos := measure_iInter_compl_pos_of_sum_lt_one μ hA h
  obtain ⟨ω, hω⟩ := MeasureTheory.nonempty_of_measure_ne_zero hpos.ne'
  exact ⟨ω, fun i => Set.mem_iInter.mp hω i⟩

/-- **Lovász Local Lemma, independent case.** For mutually independent events, the probability
that none of them occurs is the product of the complementary probabilities. -/
theorem iIndep_measure_iInter_compl_eq_prod
    (hind : iIndepSet A μ) (hA : ∀ i, MeasurableSet (A i)) :
    μ (⋂ i, (A i)ᶜ) = ∏ i, (1 - μ (A i)) := by
  rw [ ProbabilityTheory.iIndepSet_iff_iIndep ] at hind;
  convert hind.meas_iInter _ using 1;
  · exact Finset.prod_congr rfl fun i _ => by rw [ MeasureTheory.measure_compl ( hA i ) ( MeasureTheory.measure_ne_top _ _ ), MeasureTheory.IsProbabilityMeasure.measure_univ ] ;
  · exact fun i => MeasurableSpace.measurableSet_generateFrom ( Set.mem_singleton _ ) |> MeasurableSet.compl

/-- **Lovász Local Lemma, independent case (positivity).** For mutually independent events
each of probability `< 1`, the probability that none occurs is strictly positive — hence some
outcome avoids all of them. -/
theorem iIndep_measure_iInter_compl_pos
    (hind : iIndepSet A μ) (hA : ∀ i, MeasurableSet (A i)) (hlt : ∀ i, μ (A i) < 1) :
    0 < μ (⋂ i, (A i)ᶜ) := by
  rw [iIndep_measure_iInter_compl_eq_prod μ hind hA, pos_iff_ne_zero, Finset.prod_ne_zero_iff]
  intro i _ hc
  exact absurd (hlt i) (not_lt.mpr (tsub_eq_zero_iff_le.mp hc))

end ProbMethod