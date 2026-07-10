import Mathlib

/-!
# The Lovász Local Lemma: the general chain-rule positivity principle

The independent case of the Lovász Local Lemma (`ProbabilisticMethod.lean`) shows that for
*mutually independent* bad events `Aᵢ`, the probability that none occurs is the product
`∏ᵢ (1 - P(Aᵢ))`, which is positive as soon as every `P(Aᵢ) < 1`.

The genuine content of the Local Lemma is to reach the same *positivity* conclusion,
`P(⋂ᵢ Aᵢᶜ) > 0`, **without** full independence. This file isolates the measure-theoretic
backbone of every such argument: a **chain-rule / greedy positivity principle**.

The hypothesis is exactly the general "conditional avoidability" condition that the
Local-Lemma inductive estimates are designed to establish: for every finite set `S` of
already-avoided events and every further event `Aᵢ` with `i ∉ S`, as long as `S` itself is
avoidable with positive probability, the event `Aᵢ` does *not* fill up the whole conditional
space, i.e. `P(Aᵢ ∩ ⋂_{j∈S} Aⱼᶜ) < P(⋂_{j∈S} Aⱼᶜ)` (equivalently the conditional probability
`P(Aᵢ | ⋂_{j∈S} Aⱼᶜ) < 1`).

* `ProbMethod.measure_biInter_compl_pos_of_cond_lt`: under this condition, *every* finite
  family `⋂_{j∈S} Aⱼᶜ` has positive probability (proved by induction on `S`).
* `ProbMethod.measure_iInter_compl_pos_of_cond_lt`: consequently `P(⋂ᵢ Aᵢᶜ) > 0`, and
* `ProbMethod.exists_forall_notMem_of_cond_lt`: some outcome avoids *every* bad event.

Specialising the hypothesis to independent events recovers the independent Local Lemma; the
remaining work for the full asymmetric Local Lemma is precisely to *verify* the conditional
hypothesis from a dependency graph with `e·p·(d+1) ≤ 1` (see `FUTURE_DIRECTIONS.md`).
-/

open MeasureTheory Finset

namespace ProbMethod

variable {Ω ι : Type*} [Fintype ι] [MeasurableSpace Ω]
  (μ : Measure Ω) [IsProbabilityMeasure μ] {A : ι → Set Ω}

/-
**Chain-rule positivity, induction form.** If every bad event `Aᵢ` is conditionally
avoidable given any positively-probable family of already-avoided events, then *every* finite
family `⋂_{j ∈ S} Aⱼᶜ` is avoided with strictly positive probability. Proof by induction on
`S`: the empty family is the whole space, and inserting one more event strictly decreases the
measure by less than its whole mass.
-/
omit [Fintype ι] in
theorem measure_biInter_compl_pos_of_cond_lt
    (hA : ∀ i, MeasurableSet (A i))
    (hcond : ∀ (S : Finset ι) (i : ι), i ∉ S →
      0 < μ (⋂ j ∈ S, (A j)ᶜ) → μ (A i ∩ ⋂ j ∈ S, (A j)ᶜ) < μ (⋂ j ∈ S, (A j)ᶜ)) :
    ∀ S : Finset ι, 0 < μ (⋂ j ∈ S, (A j)ᶜ) := by
  intro S;
  induction' S using Finset.induction with i S hiS ih;
  all_goals try exact Classical.decEq _;
  · simp +decide [ MeasureTheory.IsProbabilityMeasure.measure_univ ];
  · simp_all +decide;
    rw [ show ( A i ) ᶜ ∩ ⋂ j ∈ S, ( A j ) ᶜ = ( ⋂ j ∈ S, ( A j ) ᶜ ) \ ( A i ∩ ⋂ j ∈ S, ( A j ) ᶜ ) by ext; aesop ] ; rw [ MeasureTheory.measure_diff ] <;> norm_num [ hA, ih.ne' ] ; aesop;
    · exact fun j hj => Set.inter_subset_right.trans ( Set.iInter₂_subset j hj );
    · exact MeasurableSet.nullMeasurableSet ( hA i |> MeasurableSet.inter <| MeasurableSet.biInter ( Finset.countable_toSet S ) fun j hj => MeasurableSet.compl <| hA j )

/-- **The Lovász Local Lemma, chain-rule positivity form.** If each bad event is conditionally
avoidable given any positively-probable family of already-avoided events, then the probability
that *no* bad event occurs is strictly positive. This is the general positivity conclusion of
the Local Lemma, with the dependency structure abstracted into the conditional hypothesis. -/
theorem measure_iInter_compl_pos_of_cond_lt
    (hA : ∀ i, MeasurableSet (A i))
    (hcond : ∀ (S : Finset ι) (i : ι), i ∉ S →
      0 < μ (⋂ j ∈ S, (A j)ᶜ) → μ (A i ∩ ⋂ j ∈ S, (A j)ᶜ) < μ (⋂ j ∈ S, (A j)ᶜ)) :
    0 < μ (⋂ i, (A i)ᶜ) := by
  have h := measure_biInter_compl_pos_of_cond_lt μ hA hcond Finset.univ
  simpa using h

/-- **The probabilistic method via the Local Lemma.** Under the conditional-avoidability
hypothesis, some outcome lies outside *every* bad event. -/
theorem exists_forall_notMem_of_cond_lt
    (hA : ∀ i, MeasurableSet (A i))
    (hcond : ∀ (S : Finset ι) (i : ι), i ∉ S →
      0 < μ (⋂ j ∈ S, (A j)ᶜ) → μ (A i ∩ ⋂ j ∈ S, (A j)ᶜ) < μ (⋂ j ∈ S, (A j)ᶜ)) :
    ∃ ω, ∀ i, ω ∉ A i := by
  have hpos := measure_iInter_compl_pos_of_cond_lt μ hA hcond
  obtain ⟨ω, hω⟩ := MeasureTheory.nonempty_of_measure_ne_zero hpos.ne'
  exact ⟨ω, fun i => Set.mem_iInter.mp hω i⟩

end ProbMethod