import Bridges.BerggrenHarmonicSingularity

/-!
# Ray rigidity: the Berggren walk is reconstructible from a single typical ray

This file closes Conjecture 5 of the previous cycle.  Earlier work proved that distinct
weight vectors give mutually singular harmonic measures (`bernoulli_mutuallySingular`), i.e.
that the *measure* remembers the walk.  Here we show that a *single boundary ray* already
remembers it: there is a Borel map

`ratio : Bdry → (Letter → ℝ)`,  `ratio x a = limsup_n (1/n) #{i < n : x i = a}`,

defined on **all** of the boundary, which is almost surely equal to the weight vector `P.p`,
and which is a *complete invariant*: two Berggren walks are equal iff one single ray is
typical for both.

## Main results

* `measurable_ratio` : `ratio` is Borel.
* `typical` : the set of rays realising the letter frequencies of `P`; it is measurable
  (`measurableSet_typical`) and conull (`typical_measure_one`), hence nonempty.
* `ratio_eq_of_mem_typical`, `ratio_ae_eq` : `ratio x = P.p` for every typical `x`, hence
  `bernoulli P`-a.e.
* `typical_disjoint` : distinct walks have disjoint sets of typical rays.
* `eq_of_mem_typical_inter` : **one common typical ray forces the walks to coincide.**
* `ray_rigidity_tfae` : for two Berggren walks `P, Q` the following are equivalent —
  the weight vectors agree; some ray is typical for both; the harmonic measures agree;
  the harmonic measures are *not* mutually singular.  So the family of harmonic measures is
  rigid: there is no intermediate behaviour between "equal" and "mutually singular".
* `ratio_complete_invariant` : the induced map from walks to the a.e.-value of `ratio` is
  injective, i.e. `ratio` is a complete invariant of the walk read off one typical ray.
-/

namespace BerggrenHarmonic

open MeasureTheory Filter Set
open scoped ENNReal Topology

/-- The empirical frequency of the Berggren move `a` among the first `n` letters of a ray. -/
noncomputable def freqAt (a : Letter) (n : ℕ) (x : Bdry) : ℝ :=
  (∑ i ∈ Finset.range n, ind a (x i)) / n

lemma measurable_freqAt (a : Letter) (n : ℕ) : Measurable (freqAt a n) :=
  (Finset.measurable_sum _ (fun i _ => measurable_letter_coord (ind a) i)).div_const _

lemma freqSet_eq (a : Letter) (t : ℝ) :
    freqSet a t = {x | Tendsto (fun n => freqAt a n x) atTop (𝓝 t)} := rfl

/-- The statistic read off a boundary ray: the vector of asymptotic letter frequencies,
defined everywhere by taking `limsup`s. -/
noncomputable def ratio (x : Bdry) (a : Letter) : ℝ :=
  limsup (fun n => freqAt a n x) atTop

lemma measurable_ratio (a : Letter) : Measurable (fun x => ratio x a) :=
  Measurable.limsup (fun n => measurable_freqAt a n)

/-- The set of rays along which every Berggren move occurs with the frequency prescribed by
the weight vector `P`. -/
def typical (P : ProbVec) : Set Bdry := ⋂ a : Letter, freqSet a (P.p a)

lemma mem_typical_iff {P : ProbVec} {x : Bdry} :
    x ∈ typical P ↔ ∀ a, Tendsto (fun n => freqAt a n x) atTop (𝓝 (P.p a)) := by
  simp only [typical, Set.mem_iInter, freqSet, Set.mem_setOf_eq]
  exact Iff.rfl

lemma measurableSet_typical (P : ProbVec) : MeasurableSet (typical P) :=
  MeasurableSet.iInter (fun a => measurableSet_freqSet a (P.p a))

/-- **Almost every boundary ray is typical for the walk that generated it.** -/
theorem typical_measure_one (P : ProbVec) : bernoulli P (typical P) = 1 := by
  have h : ∀ a : Letter, bernoulli P (freqSet a (P.p a))ᶜ = 0 := by
    intro a
    have h1 := freqSet_measure_one P a
    have := measure_compl (μ := bernoulli P) (measurableSet_freqSet a (P.p a))
      (by rw [h1]; exact ENNReal.one_ne_top)
    rw [this, measure_univ, h1, tsub_self]
  have hc : bernoulli P (typical P)ᶜ = 0 := by
    have hsub : (typical P)ᶜ ⊆ ⋃ a : Letter, (freqSet a (P.p a))ᶜ := by
      intro x hx
      simpa [typical, Set.mem_iUnion] using hx
    refine le_antisymm ?_ (zero_le _)
    calc bernoulli P (typical P)ᶜ ≤ bernoulli P (⋃ a : Letter, (freqSet a (P.p a))ᶜ) :=
          measure_mono hsub
      _ ≤ ∑' a : Letter, bernoulli P (freqSet a (P.p a))ᶜ := measure_iUnion_le _
      _ = 0 := by simp [h]
  have := measure_add_measure_compl (μ := bernoulli P) (measurableSet_typical P)
  rw [hc, add_zero, measure_univ] at this
  exact this

theorem typical_nonempty (P : ProbVec) : (typical P).Nonempty := by
  by_contra h
  rw [Set.not_nonempty_iff_eq_empty] at h
  have := typical_measure_one P
  rw [h, measure_empty] at this
  exact zero_ne_one this

/-- On a typical ray the everywhere-defined statistic `ratio` returns the weight vector. -/
theorem ratio_eq_of_mem_typical {P : ProbVec} {x : Bdry} (hx : x ∈ typical P) :
    ratio x = P.p := by
  funext a
  exact (mem_typical_iff.1 hx a).limsup_eq

/-- **The harmonic measure of the walk `P` is concentrated on the rays that reconstruct `P`.** -/
theorem ratio_ae_eq (P : ProbVec) : ∀ᵐ x ∂(bernoulli P), ratio x = P.p := by
  have h0 : bernoulli P (typical P)ᶜ = 0 := by
    have hcompl := measure_compl (μ := bernoulli P) (measurableSet_typical P)
      (by rw [typical_measure_one P]; exact ENNReal.one_ne_top)
    rw [hcompl, measure_univ, typical_measure_one P, tsub_self]
  refine measure_mono_null (fun x hx => ?_) h0
  exact fun hmem => hx (ratio_eq_of_mem_typical hmem)

/-- Distinct Berggren walks have disjoint sets of typical rays. -/
theorem typical_disjoint {P Q : ProbVec} (h : P.p ≠ Q.p) : Disjoint (typical P) (typical Q) := by
  rw [Set.disjoint_left]
  intro x hP hQ
  exact h (((ratio_eq_of_mem_typical hP).symm).trans (ratio_eq_of_mem_typical hQ))

/-- **A single ray typical for two walks forces the walks to be equal.**  This is the
ray-by-ray form of rigidity: the boundary behaviour of one trajectory determines the whole
transition law. -/
theorem eq_of_mem_typical_inter {P Q : ProbVec} {x : Bdry} (hP : x ∈ typical P)
    (hQ : x ∈ typical Q) : P.p = Q.p :=
  ((ratio_eq_of_mem_typical hP).symm).trans (ratio_eq_of_mem_typical hQ)

/-- **Rigidity of the family of Berggren harmonic measures.**  There is no intermediate
regime: two walks either coincide — in which case a single ray of one reconstructs the
other — or their harmonic measures are mutually singular. -/
theorem ray_rigidity_tfae (P Q : ProbVec) :
    List.TFAE
      [ P.p = Q.p,
        (typical P ∩ typical Q).Nonempty,
        bernoulli P = bernoulli Q,
        ¬ ((bernoulli P) ⟂ₘ (bernoulli Q)) ] := by
  tfae_have 1 → 2 := by
    intro h
    obtain ⟨x, hx⟩ := typical_nonempty P
    refine ⟨x, hx, ?_⟩
    have : typical P = typical Q := by
      unfold typical
      simp only [h]
    rw [← this]
    exact hx
  tfae_have 2 → 1 := by
    rintro ⟨x, hxP, hxQ⟩
    exact eq_of_mem_typical_inter hxP hxQ
  tfae_have 1 → 3 := by
    intro h
    have hstep : (fun _ : ℕ => P.stepMeasure) = (fun _ : ℕ => Q.stepMeasure) := by
      funext _
      have : P.pmf = Q.pmf := by
        ext a
        simp [ProbVec.pmf, congrFun h a]
      simp [ProbVec.stepMeasure, this]
    simp [bernoulli, hstep]
  tfae_have 3 → 4 := by
    intro h hsing
    rw [h] at hsing
    obtain ⟨s, hs, h0, hc⟩ := hsing
    have huniv : bernoulli Q Set.univ = 0 := by
      have hsplit : (Set.univ : Set Bdry) = s ∪ sᶜ := by simp
      rw [hsplit]
      exact le_antisymm (le_trans (measure_union_le _ _) (by rw [h0, hc]; simp)) (zero_le _)
    rw [measure_univ] at huniv
    exact one_ne_zero huniv
  tfae_have 4 → 1 := by
    intro h
    by_contra hne
    obtain ⟨a, ha⟩ : ∃ a, P.p a ≠ Q.p a := by
      by_contra hall
      exact hne (funext fun a => not_not.1 (fun hh => hall ⟨a, hh⟩))
    exact h (bernoulli_mutuallySingular P Q ⟨a, ha⟩)
  tfae_finish

/-- **`ratio` is a complete invariant.**  If the a.e. values of the frequency statistic under
two harmonic measures agree, the walks agree. -/
theorem ratio_complete_invariant {P Q : ProbVec}
    (h : ∀ᵐ x ∂(bernoulli P), ratio x = Q.p) : P.p = Q.p := by
  have hP := ratio_ae_eq P
  have hcomb : ∀ᵐ x ∂(bernoulli P), ratio x = P.p ∧ ratio x = Q.p := hP.and h
  obtain ⟨x, hx1, hx2⟩ := hcomb.exists
  exact hx1.symm.trans hx2

end BerggrenHarmonic