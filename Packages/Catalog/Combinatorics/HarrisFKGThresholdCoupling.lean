/-
# The finite Harris/FKG inequality for the threshold coupling

Continuing `Catalog/Combinatorics/BernoulliThresholdCoupling.lean`, this file
proves that increasing events on a finite site set are positively correlated
under the Bernoulli site measure of any density `p ∈ [0,1]`, both in the
polynomial form `bernProb` and in the measure form given by the independent
uniform key coupling `keyMeasure`.

The engine is the log-supermodularity (in fact, exact multiplicativity) of the
Bernoulli weight, `weight_inf_mul_weight_sup`, combined with Mathlib's
Fortuin–Kasteleyn–Ginibre inequality `fkg` on the distributive lattice
`ι → Bool`.

## Main results

* `weight_inf_mul_weight_sup`: `weight p η * weight p ξ =
  weight p (η ⊓ ξ) * weight p (η ⊔ ξ)`.
* `bernProb_harris`: **Harris inequality**,
  `bernProb p A * bernProb p B ≤ bernProb p (A ∩ B)` for increasing `A`, `B`.
* `keyMeasure_harris`: the same statement on the key probability space.
* `bernProb_harris_compl`: the complementary (increasing versus decreasing)
  negative-correlation form.
* `bernProb_harris_biInter`: the finite-family version.
* `bernProb_harris_compl_compl`, `bernProb_harris_biInter_compl`: the decreasing
  side, obtained from the increasing one by inclusion–exclusion.
* `bernProb_biUnion_ge`: the product form of the square-root trick, bounding the
  probability of a union of increasing events from below.
* `crossing_harris_open_site`, `crossing_harris`: applications to horizontal
  crossings of the `n × n` grid.
-/

import Combinatorics.FiniteRussoFormula

open Finset MeasureTheory

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Log-supermodularity of the Bernoulli weight -/

omit [DecidableEq ι] in
/-- The Bernoulli product weight is multiplicative along the lattice operations:
pairing two configurations coordinatewise into their meet and join permutes the
factors. -/
theorem weight_inf_mul_weight_sup (p : ℝ) (η ξ : ι → Bool) :
    weight p η * weight p ξ = weight p (η ⊓ ξ) * weight p (η ⊔ ξ) := by
  simp only [weight_eq_prod, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun v _ => ?_
  simp only [Pi.inf_apply, Pi.sup_apply]
  have key : ∀ a b : Bool,
      ((if a = true then p else 1 - p) * if b = true then p else 1 - p) =
        (if min a b = true then p else 1 - p) * if max a b = true then p else 1 - p := by
    intro a b
    cases a <;> cases b <;> simp [mul_comm]
  exact key (η v) (ξ v)

omit [Fintype ι] [DecidableEq ι] in
/-- The pointwise order on `ι → Bool` is domination of open sites. -/
theorem le_iff_open_subset {η ξ : ι → Bool} :
    η ≤ ξ ↔ ∀ v, η v = true → ξ v = true := by
  simp [Pi.le_def, Bool.le_iff_imp]

omit [Fintype ι] [DecidableEq ι] in
/-- An increasing event has a monotone indicator function. -/
theorem indicator_monotone {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    Monotone (A.indicator (fun _ => (1 : ℝ))) := by
  intro η ξ h
  by_cases hη : η ∈ A
  · rw [Set.indicator_of_mem hη,
      Set.indicator_of_mem (hA η ξ (le_iff_open_subset.mp h) hη)]
  · rw [Set.indicator_of_notMem hη]
    exact Set.indicator_nonneg (fun _ _ => zero_le_one) ξ

omit [Fintype ι] [DecidableEq ι] in
theorem indicator_nonneg' (A : Set (ι → Bool)) :
    0 ≤ A.indicator (fun _ => (1 : ℝ)) :=
  fun η => Set.indicator_nonneg (fun _ _ => zero_le_one) η

/-- Rewriting `bernProb` as a weighted sum of an indicator function. -/
theorem bernProb_eq_sum_mul_indicator (p : ℝ) (A : Set (ι → Bool)) :
    bernProb p A = ∑ η : ι → Bool, weight p η * A.indicator (fun _ => (1 : ℝ)) η := by
  refine Finset.sum_congr rfl fun η _ => ?_
  by_cases h : η ∈ A
  · rw [Set.indicator_of_mem h, Set.indicator_of_mem h, mul_one]
  · rw [Set.indicator_of_notMem h, Set.indicator_of_notMem h, mul_zero]

omit [Fintype ι] [DecidableEq ι] in
/-- The indicator of an intersection is the product of the indicators. -/
theorem indicator_inter (A B : Set (ι → Bool)) (η : ι → Bool) :
    (A ∩ B).indicator (fun _ => (1 : ℝ)) η =
      A.indicator (fun _ => (1 : ℝ)) η * B.indicator (fun _ => (1 : ℝ)) η := by
  by_cases hA : η ∈ A <;> by_cases hB : η ∈ B <;>
    simp [Set.indicator_of_mem, Set.indicator_of_notMem, hA, hB]

/-! ## The Harris inequality -/

/-- **Harris (FKG) inequality on a finite site set.**  Two increasing events are
positively correlated under the Bernoulli site measure of density `p`. -/
theorem bernProb_harris {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProb p A * bernProb p B ≤ bernProb p (A ∩ B) := by
  classical
  have h := fkg (μ := weight p) (f := A.indicator (fun _ => (1 : ℝ)))
    (g := B.indicator (fun _ => (1 : ℝ)))
    (fun η => weight_nonneg hp0 hp1 η) (indicator_nonneg' A) (indicator_nonneg' B)
    (indicator_monotone hA) (indicator_monotone hB)
    (fun a b => le_of_eq (weight_inf_mul_weight_sup p a b))
  rw [sum_weight p, one_mul] at h
  rw [bernProb_eq_sum_mul_indicator p A, bernProb_eq_sum_mul_indicator p B,
    bernProb_eq_sum_mul_indicator p (A ∩ B)]
  refine h.trans (le_of_eq (Finset.sum_congr rfl fun η _ => ?_))
  rw [indicator_inter]

omit [Fintype ι] [DecidableEq ι] in
/-- The intersection of increasing events is increasing. -/
theorem IsIncreasing.inter {A B : Set (ι → Bool)} (hA : IsIncreasing A)
    (hB : IsIncreasing B) : IsIncreasing (A ∩ B) :=
  fun η ξ h hη => ⟨hA η ξ h hη.1, hB η ξ h hη.2⟩

omit [Fintype ι] [DecidableEq ι] in
/-- The whole space is an increasing event. -/
theorem isIncreasing_univ : IsIncreasing (Set.univ : Set (ι → Bool)) :=
  fun _ _ _ _ => Set.mem_univ _

omit [Fintype ι] [DecidableEq ι] in
/-- An intersection of a finite family of increasing events is increasing. -/
theorem isIncreasing_biInter {κ : Type*} (s : Finset κ) (A : κ → Set (ι → Bool))
    (hA : ∀ k ∈ s, IsIncreasing (A k)) : IsIncreasing (⋂ k ∈ s, A k) := by
  intro η ξ h hη
  simp only [Set.mem_iInter] at hη ⊢
  exact fun k hk => hA k hk η ξ h (hη k hk)

/-- `bernProb` is additive on disjoint events. -/
theorem bernProb_union_of_disjoint (p : ℝ) {A B : Set (ι → Bool)}
    (h : Disjoint A B) :
    bernProb p (A ∪ B) = bernProb p A + bernProb p B := by
  rw [bernProb, bernProb, bernProb, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun η _ => congrFun (Set.indicator_union_of_disjoint h _) η

/-- The total mass is one. -/
theorem bernProb_univ (p : ℝ) : bernProb p (Set.univ : Set (ι → Bool)) = 1 := by
  rw [bernProb]
  simp only [Set.indicator_univ]
  exact sum_weight p

/-- The probabilities of an event and its complement add up to one. -/
theorem bernProb_add_bernProb_compl (p : ℝ) (A : Set (ι → Bool)) :
    bernProb p A + bernProb p Aᶜ = 1 := by
  rw [← bernProb_union_of_disjoint p disjoint_compl_right, Set.union_compl_self,
    bernProb_univ]

/-- **Negative correlation between an increasing and a decreasing event.**  For
increasing `A` and `B`, the event `A ∩ Bᶜ` is at most as likely as the product
of the probabilities of `A` and `Bᶜ`. -/
theorem bernProb_harris_compl {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProb p (A ∩ Bᶜ) ≤ bernProb p A * bernProb p Bᶜ := by
  have hsplit : bernProb p (A ∩ B) + bernProb p (A ∩ Bᶜ) = bernProb p A := by
    rw [← bernProb_union_of_disjoint p
      (Set.disjoint_of_subset Set.inter_subset_right Set.inter_subset_right
        disjoint_compl_right)]
    congr 1
    rw [← Set.inter_union_distrib_left, Set.union_compl_self, Set.inter_univ]
  have hB' : bernProb p Bᶜ = 1 - bernProb p B := by
    have := bernProb_add_bernProb_compl p B
    linarith
  have hkey := bernProb_harris hp0 hp1 hA hB
  rw [hB', mul_sub, mul_one]
  linarith

/-- **Harris inequality for a finite family of increasing events.** -/
theorem bernProb_harris_biInter {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {κ : Type*} [DecidableEq κ] (s : Finset κ) (A : κ → Set (ι → Bool))
    (hA : ∀ k ∈ s, IsIncreasing (A k)) :
    ∏ k ∈ s, bernProb p (A k) ≤ bernProb p (⋂ k ∈ s, A k) := by
  classical
  induction s using Finset.induction_on with
  | empty =>
    have hu : (⋂ k ∈ (∅ : Finset κ), A k) = (Set.univ : Set (ι → Bool)) := by simp
    rw [Finset.prod_empty, hu, bernProb_univ]
  | insert k s hk ih =>
    have hAk : IsIncreasing (A k) := hA k (Finset.mem_insert_self k s)
    have hAs : ∀ j ∈ s, IsIncreasing (A j) := fun j hj =>
      hA j (Finset.mem_insert_of_mem hj)
    have hrest : IsIncreasing (⋂ j ∈ s, A j) := isIncreasing_biInter s A hAs
    have hinter : (⋂ j ∈ insert k s, A j) = A k ∩ ⋂ j ∈ s, A j := by
      simp
    rw [Finset.prod_insert hk, hinter]
    refine le_trans (mul_le_mul_of_nonneg_left (ih hAs)
      (bernProb_nonneg hp0 hp1 (A k))) ?_
    exact bernProb_harris hp0 hp1 hAk hrest

/-! ## The decreasing side and the square-root trick -/

/-- Inclusion–exclusion for `bernProb`. -/
theorem bernProb_union_add_inter (p : ℝ) (A B : Set (ι → Bool)) :
    bernProb p (A ∪ B) + bernProb p (A ∩ B) = bernProb p A + bernProb p B := by
  rw [bernProb, bernProb, bernProb, bernProb, ← Finset.sum_add_distrib,
    ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun η _ => ?_
  by_cases hA : η ∈ A <;> by_cases hB : η ∈ B <;>
    simp [Set.indicator_of_mem, Set.indicator_of_notMem, hA, hB]

omit [Fintype ι] [DecidableEq ι] in
/-- The union of increasing events is increasing. -/
theorem isIncreasing_union {A B : Set (ι → Bool)} (hA : IsIncreasing A)
    (hB : IsIncreasing B) : IsIncreasing (A ∪ B) := by
  rintro η ξ h (hη | hη)
  · exact Or.inl (hA η ξ h hη)
  · exact Or.inr (hB η ξ h hη)

omit [Fintype ι] [DecidableEq ι] in
/-- A union of a finite family of increasing events is increasing. -/
theorem isIncreasing_biUnion {κ : Type*} (s : Finset κ) (A : κ → Set (ι → Bool))
    (hA : ∀ k ∈ s, IsIncreasing (A k)) : IsIncreasing (⋃ k ∈ s, A k) := by
  intro η ξ h hη
  simp only [Set.mem_iUnion] at hη ⊢
  obtain ⟨k, hk, hηk⟩ := hη
  exact ⟨k, hk, hA k hk η ξ h hηk⟩

/-- **Harris inequality for decreasing events.**  The complements of two
increasing events are positively correlated as well. -/
theorem bernProb_harris_compl_compl {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProb p Aᶜ * bernProb p Bᶜ ≤ bernProb p (Aᶜ ∩ Bᶜ) := by
  have hcompl : Aᶜ ∩ Bᶜ = (A ∪ B)ᶜ := (Set.compl_union A B).symm
  have hA' : bernProb p Aᶜ = 1 - bernProb p A := by
    have := bernProb_add_bernProb_compl p A; linarith
  have hB' : bernProb p Bᶜ = 1 - bernProb p B := by
    have := bernProb_add_bernProb_compl p B; linarith
  have hU : bernProb p (A ∪ B)ᶜ = 1 - bernProb p (A ∪ B) := by
    have := bernProb_add_bernProb_compl p (A ∪ B); linarith
  have hie := bernProb_union_add_inter p A B
  have hkey := bernProb_harris hp0 hp1 hA hB
  rw [hcompl, hA', hB', hU]
  nlinarith [hie, hkey]

/-- **Harris inequality for a finite family of decreasing events.** -/
theorem bernProb_harris_biInter_compl {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {κ : Type*} [DecidableEq κ] (s : Finset κ) (A : κ → Set (ι → Bool))
    (hA : ∀ k ∈ s, IsIncreasing (A k)) :
    ∏ k ∈ s, bernProb p (A k)ᶜ ≤ bernProb p (⋂ k ∈ s, (A k)ᶜ) := by
  classical
  induction s using Finset.induction_on with
  | empty =>
    have hu : (⋂ k ∈ (∅ : Finset κ), (A k)ᶜ) = (Set.univ : Set (ι → Bool)) := by simp
    rw [Finset.prod_empty, hu, bernProb_univ]
  | insert k s hk ih =>
    have hAk : IsIncreasing (A k) := hA k (Finset.mem_insert_self k s)
    have hAs : ∀ j ∈ s, IsIncreasing (A j) := fun j hj =>
      hA j (Finset.mem_insert_of_mem hj)
    have hrest : (⋂ j ∈ s, (A j)ᶜ) = (⋃ j ∈ s, A j)ᶜ := by
      simp [Set.compl_iUnion]
    have hinter : (⋂ j ∈ insert k s, (A j)ᶜ) = (A k)ᶜ ∩ ⋂ j ∈ s, (A j)ᶜ := by simp
    rw [Finset.prod_insert hk, hinter, hrest]
    refine le_trans (mul_le_mul_of_nonneg_left ((ih hAs).trans (le_of_eq (by rw [hrest])))
      (bernProb_nonneg hp0 hp1 (A k)ᶜ)) ?_
    exact bernProb_harris_compl_compl hp0 hp1 hAk (isIncreasing_biUnion s A hAs)

/-- **The square-root trick, product form.**  If a union of increasing events is
likely, then one of them is: the probability of the union is at least
`1 - ∏ (1 - bernProb p (A k))`. -/
theorem bernProb_biUnion_ge {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {κ : Type*} [DecidableEq κ] (s : Finset κ) (A : κ → Set (ι → Bool))
    (hA : ∀ k ∈ s, IsIncreasing (A k)) :
    ∏ k ∈ s, (1 - bernProb p (A k)) ≤ 1 - bernProb p (⋃ k ∈ s, A k) := by
  classical
  have hcompl : (⋂ k ∈ s, (A k)ᶜ) = (⋃ k ∈ s, A k)ᶜ := by simp [Set.compl_iUnion]
  have h := bernProb_harris_biInter_compl hp0 hp1 s A hA
  rw [hcompl] at h
  have hU : bernProb p (⋃ k ∈ s, A k)ᶜ = 1 - bernProb p (⋃ k ∈ s, A k) := by
    have := bernProb_add_bernProb_compl p (⋃ k ∈ s, A k); linarith
  rw [hU] at h
  refine le_trans (le_of_eq (Finset.prod_congr rfl fun k _ => ?_)) h
  have := bernProb_add_bernProb_compl p (A k)
  linarith

/-! ## The key-measure form -/

omit [Fintype ι] [DecidableEq ι] in
theorem eventKeys_inter (p : ℝ) (A B : Set (ι → Bool)) :
    eventKeys p (A ∩ B) = eventKeys p A ∩ eventKeys p B := rfl

/-- **Harris inequality on the key probability space.**  Under independent
uniform keys, the events `eventKeys p A` and `eventKeys p B` of two increasing
site events are positively correlated. -/
theorem keyMeasure_harris {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    keyMeasure ι (eventKeys p A) * keyMeasure ι (eventKeys p B) ≤
      keyMeasure ι (eventKeys p A ∩ eventKeys p B) := by
  rw [← eventKeys_inter, keyMeasure_eventKeys hp0 hp1, keyMeasure_eventKeys hp0 hp1,
    keyMeasure_eventKeys hp0 hp1, ← ENNReal.ofReal_mul (bernProb_nonneg hp0 hp1 A)]
  exact ENNReal.ofReal_le_ofReal (bernProb_harris hp0 hp1 hA hB)

/-! ## Application to grid crossings -/

omit [Fintype ι] [DecidableEq ι] in
/-- The event that a prescribed site is open is increasing. -/
theorem isIncreasing_openSite (v : ι) :
    IsIncreasing {η : ι → Bool | η v = true} :=
  fun _ _ h hη => h v hη

/-- The weights of the configurations opening a prescribed site sum to one after
removing that site's factor. -/
theorem sum_offWeight_filter (p : ℝ) (v : ι) :
    ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true), offWeight p v η = 1 := by
  classical
  have h := sum_weight (ι := ι) p
  rw [sum_split v] at h
  rw [← h]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hW : offWeight p v (Function.update η v false) = offWeight p v η :=
    offWeight_update p v η false
  rw [weight_eq_mul_offWeight p v η, weight_eq_mul_offWeight p v
    (Function.update η v false), Function.update_self, hW, hη]
  simp
  ring

/-- The probability that a prescribed site is open is `p`. -/
theorem bernProb_openSite (p : ℝ) (v : ι) :
    bernProb p {η : ι → Bool | η v = true} = p := by
  classical
  rw [bernProb, sum_split v]
  have hcalc : ∀ η ∈ univ.filter (fun η : ι → Bool => η v = true),
      {η : ι → Bool | η v = true}.indicator (weight p) η +
        {η : ι → Bool | η v = true}.indicator (weight p)
          (Function.update η v false) = p * offWeight p v η := by
    intro η hη
    simp only [mem_filter, mem_univ, true_and] at hη
    have hmem : η ∈ {η : ι → Bool | η v = true} := hη
    have hnot : Function.update η v false ∉ {η : ι → Bool | η v = true} := by
      simp [Set.mem_setOf_eq]
    rw [Set.indicator_of_mem hmem, Set.indicator_of_notMem hnot, add_zero,
      weight_eq_mul_offWeight p v η, hη]
    simp
  rw [Finset.sum_congr rfl hcalc, ← Finset.mul_sum, sum_offWeight_filter p v,
    mul_one]

/-- **Crossings and open sites are positively correlated.**  Conditioning on a
horizontal crossing of the `n × n` grid can only increase the chance that a
prescribed site is open. -/
theorem crossing_harris_open_site (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) (v : Fin n × Fin n) :
    p * bernProb p (crossingEvent n hn) ≤
      bernProb p (crossingEvent n hn ∩ {η | η v = true}) := by
  have h := bernProb_harris hp0 hp1 (crossingEvent_isIncreasing n hn)
    (isIncreasing_openSite v)
  rwa [bernProb_openSite p v, mul_comm] at h

/-- **Crossings are positively correlated with every increasing event.** -/
theorem crossing_harris (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {B : Set (Fin n × Fin n → Bool)} (hB : IsIncreasing B) :
    bernProb p (crossingEvent n hn) * bernProb p B ≤
      bernProb p (crossingEvent n hn ∩ B) :=
  bernProb_harris hp0 hp1 (crossingEvent_isIncreasing n hn) hB

end BernoulliThresholdCoupling