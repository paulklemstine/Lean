/-
# The van den Berg–Kesten inequality on a finite site set

This file closes Conjecture 4 of the previous cycle of this research thread:
the **BK inequality** for increasing events under the Bernoulli site measure of
a finite site set, in the polynomial form `bernProb` of
`Catalog/Combinatorics/BernoulliThresholdCoupling.lean`.

For a finite index type `ι` and `ω : ι → Bool` we say that increasing events
`A` and `B` *occur disjointly* at `ω` when there are disjoint site sets `S` and
`T` such that `A` is already realized by the open sites of `ω` inside `S` and
`B` by the open sites of `ω` inside `T`.  Writing `A □ B` (`disjointOccur A B`)
for this event, the theorem is

`bernProb p (A □ B) ≤ bernProb p A * bernProb p B`   for `p ∈ [0,1]`.

Together with the Harris inequality `bernProb_harris` already in the catalog
this pins the correlation of two increasing events between two matching bounds:

`bernProb p (A □ B) ≤ bernProb p A * bernProb p B ≤ bernProb p (A ∩ B)`.

## Method

The proof is the classical van den Berg–Kesten decoupling, carried out here
over a `Finset` of "already decoupled" sites rather than over an enumeration of
the sites.  On the doubled configuration space `(ι → Bool) × (ι → Bool)` we
introduce, for each `K : Finset ι`, the event `bkPair K A B` in which `A` is
tested on the hybrid configuration that reads the second copy on `K` and the
first copy off `K`, `B` is tested on the first copy, and the two witnessing
site sets are only required to be disjoint *outside* `K`.  Then

* `bkPair ∅ A B` is `A □ B` read in the first copy (`bkPair_empty`);
* `bkPair univ A B` is the independent product event (`bkPair_univ`);
* adding one site to `K` never decreases the probability
  (`bernProb2_bkPair_le_insert`), which is the heart of the matter: after
  splitting the doubled Bernoulli sum at the new site one is left with a purely
  arithmetic inequality between six indicator values (`bk_local_ineq`), whose
  validity rests on the fact that a witness pair for `bkPair K` cannot use the
  new site twice.

## Main results

* `bernProb_bk`: the BK inequality `bernProb p (A □ B) ≤ bernProb p A * bernProb p B`.
* `bernProb_bk_harris_sandwich`: BK and Harris combined.
* `bernProb_disjointPow_le`: `bernProb p (A □ A □ ⋯ □ A) ≤ (bernProb p A) ^ n`,
  the exponential decay of `n` disjoint occurrences.
* `crossing_bk`, `crossing_disjointPow_le`: the instances for horizontal
  crossings of the `n × n` grid.
-/

import Combinatorics.HarrisFKGThresholdCoupling

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Indicator toolbox -/

section Indicator

variable {α β : Type*}

theorem bkInd_eq_zero_or_one (E : Set α) (z : α) :
    E.indicator (fun _ => (1 : ℝ)) z = 0 ∨ E.indicator (fun _ => (1 : ℝ)) z = 1 := by
  by_cases h : z ∈ E
  · exact Or.inr (by simp [Set.indicator_of_mem h])
  · exact Or.inl (by simp [Set.indicator_of_notMem h])

theorem bkInd_nonneg (E : Set α) (z : α) : 0 ≤ E.indicator (fun _ => (1 : ℝ)) z :=
  Set.indicator_nonneg (fun _ _ => zero_le_one) z

/-- Monotonicity of indicators along an implication. -/
theorem bkInd_le_of_imp (E : Set α) (F : Set β) (z : α) (w : β) (h : z ∈ E → w ∈ F) :
    E.indicator (fun _ => (1 : ℝ)) z ≤ F.indicator (fun _ => (1 : ℝ)) w := by
  by_cases hz : z ∈ E
  · rw [Set.indicator_of_mem hz, Set.indicator_of_mem (h hz)]
  · rw [Set.indicator_of_notMem hz]
    exact bkInd_nonneg F w

/-- If membership forces one of two alternatives, the indicator is bounded by the
sum of the two indicators. -/
theorem bkInd_le_add_of_imp_or (E : Set α) (F : Set β) (z : α) (w₁ w₂ : β)
    (h : z ∈ E → w₁ ∈ F ∨ w₂ ∈ F) :
    E.indicator (fun _ => (1 : ℝ)) z ≤
      F.indicator (fun _ => (1 : ℝ)) w₁ + F.indicator (fun _ => (1 : ℝ)) w₂ := by
  by_cases hz : z ∈ E
  · rcases h hz with hw | hw
    · rw [Set.indicator_of_mem hz, Set.indicator_of_mem hw]
      simpa using bkInd_nonneg F w₂
    · rw [Set.indicator_of_mem hz, Set.indicator_of_mem hw]
      simpa using bkInd_nonneg F w₁
  · rw [Set.indicator_of_notMem hz]
    exact add_nonneg (bkInd_nonneg F w₁) (bkInd_nonneg F w₂)

end Indicator

/-! ## Masks and disjoint occurrence -/

/-- `maskOn S ω` keeps the sites of `S` open as in `ω` and closes all others. -/
def maskOn (S : Finset ι) (ω : ι → Bool) : ι → Bool := fun v => if v ∈ S then ω v else false

omit [Fintype ι] in
theorem maskOn_le (S : Finset ι) (ω : ι → Bool) : ∀ v, maskOn S ω v = true → ω v = true := by
  intro v hv
  by_cases h : v ∈ S
  · simpa [maskOn, h] using hv
  · simp [maskOn, h] at hv

theorem maskOn_univ (ω : ι → Bool) : maskOn (univ : Finset ι) ω = ω := by
  funext v; simp [maskOn]

omit [Fintype ι] in
theorem maskOn_mono (S : Finset ι) {ω ξ : ι → Bool} (h : ∀ v, ω v = true → ξ v = true) :
    ∀ v, maskOn S ω v = true → maskOn S ξ v = true := by
  intro v hv
  by_cases hS : v ∈ S
  · simp only [maskOn, if_pos hS] at hv ⊢; exact h v hv
  · simp [maskOn, hS] at hv

omit [Fintype ι] in
/-- Sites outside `S` are invisible to `maskOn S`. -/
theorem maskOn_update_of_notMem {S : Finset ι} {k : ι} (hk : k ∉ S) (ω : ι → Bool) (b : Bool) :
    maskOn S (Function.update ω k b) = maskOn S ω := by
  funext v
  by_cases hv : v ∈ S
  · have hvk : v ≠ k := fun h => hk (h ▸ hv)
    simp [maskOn, hv, Function.update_of_ne hvk]
  · simp [maskOn, hv]

/-- The event that `A` and `B` occur disjointly: there are disjoint site sets
`S` and `T` such that the open sites of `ω` inside `S` already realize `A` and
those inside `T` already realize `B`. -/
def disjointOccur (A B : Set (ι → Bool)) : Set (ι → Bool) :=
  {ω | ∃ S T : Finset ι, Disjoint S T ∧ maskOn S ω ∈ A ∧ maskOn T ω ∈ B}

omit [Fintype ι] in
/-- Disjoint occurrence of increasing events is an increasing event. -/
theorem disjointOccur_isIncreasing {A B : Set (ι → Bool)} (hA : IsIncreasing A)
    (hB : IsIncreasing B) : IsIncreasing (disjointOccur A B) := by
  rintro ω ξ hdom ⟨S, T, hST, hSA, hTB⟩
  exact ⟨S, T, hST, hA _ _ (maskOn_mono S hdom) hSA, hB _ _ (maskOn_mono T hdom) hTB⟩

omit [Fintype ι] in
/-- Disjoint occurrence is stronger than joint occurrence. -/
theorem disjointOccur_subset_inter {A B : Set (ι → Bool)} (hA : IsIncreasing A)
    (hB : IsIncreasing B) : disjointOccur A B ⊆ A ∩ B := by
  rintro ω ⟨S, T, -, hSA, hTB⟩
  exact ⟨hA _ _ (maskOn_le S ω) hSA, hB _ _ (maskOn_le T ω) hTB⟩

/-! ## The decoupling events on the doubled configuration space -/

/-- The hybrid configuration reading `ω'` on `K` and `ω` off `K`. -/
def hybrid2 (K : Finset ι) (ω' ω : ι → Bool) : ι → Bool :=
  fun v => if v ∈ K then ω' v else ω v

omit [Fintype ι] in
theorem hybrid2_empty (ω' ω : ι → Bool) : hybrid2 (∅ : Finset ι) ω' ω = ω := by
  funext v; simp [hybrid2]

theorem hybrid2_univ (ω' ω : ι → Bool) : hybrid2 (univ : Finset ι) ω' ω = ω' := by
  funext v; simp [hybrid2]

/-- The van den Berg–Kesten decoupling event.  `A` is tested on the hybrid
configuration, `B` on the first copy, and the two witnesses need only be
disjoint outside `K`. -/
def bkPair (K : Finset ι) (A B : Set (ι → Bool)) : Set ((ι → Bool) × (ι → Bool)) :=
  {z | ∃ S T : Finset ι, S ∩ T ⊆ K ∧ maskOn S (hybrid2 K z.2 z.1) ∈ A ∧ maskOn T z.1 ∈ B}

omit [Fintype ι] in
/-- With no site decoupled, the decoupling event is disjoint occurrence in the
first copy. -/
theorem bkPair_empty (A B : Set (ι → Bool)) :
    bkPair (∅ : Finset ι) A B = {z : (ι → Bool) × (ι → Bool) | z.1 ∈ disjointOccur A B} := by
  ext z
  constructor
  · rintro ⟨S, T, hST, hSA, hTB⟩
    refine ⟨S, T, Finset.disjoint_iff_inter_eq_empty.mpr (Finset.subset_empty.mp hST), ?_, hTB⟩
    rwa [hybrid2_empty] at hSA
  · rintro ⟨S, T, hST, hSA, hTB⟩
    refine ⟨S, T, ?_, ?_, hTB⟩
    · rw [Finset.disjoint_iff_inter_eq_empty.mp hST]
    · rwa [hybrid2_empty]

/-- With every site decoupled, the decoupling event is the independent product
of `A` in the second copy and `B` in the first. -/
theorem bkPair_univ {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bkPair (univ : Finset ι) A B =
      {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B} := by
  ext z
  constructor
  · rintro ⟨S, T, -, hSA, hTB⟩
    rw [hybrid2_univ] at hSA
    exact ⟨hA _ _ (maskOn_le S z.2) hSA, hB _ _ (maskOn_le T z.1) hTB⟩
  · rintro ⟨h2, h1⟩
    refine ⟨univ, univ, Finset.subset_univ _, ?_, ?_⟩
    · rw [hybrid2_univ, maskOn_univ]; exact h2
    · rw [maskOn_univ]; exact h1

omit [Fintype ι] in
/-- The decoupling event is increasing in both copies. -/
theorem bkPair_mono {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B)
    {K : Finset ι} {ω₁ ω₂ ω'₁ ω'₂ : ι → Bool}
    (h : ∀ v, ω₁ v = true → ω₂ v = true) (h' : ∀ v, ω'₁ v = true → ω'₂ v = true)
    (hmem : (ω₁, ω'₁) ∈ bkPair K A B) : (ω₂, ω'₂) ∈ bkPair K A B := by
  obtain ⟨S, T, hST, hSA, hTB⟩ := hmem
  refine ⟨S, T, hST, hA _ _ (maskOn_mono S ?_) hSA, hB _ _ (maskOn_mono T h) hTB⟩
  intro v hv
  by_cases hvK : v ∈ K
  · simp only [hybrid2, if_pos hvK] at hv ⊢; exact h' v hv
  · simp only [hybrid2, if_neg hvK] at hv ⊢; exact h v hv

omit [Fintype ι] in
/-- A site outside `K` is not read from the second copy. -/
theorem bkPair_snd_update {A B : Set (ι → Bool)} {K : Finset ι} {k : ι} (hk : k ∉ K)
    (ω ω' : ι → Bool) (b : Bool) :
    ((ω, Function.update ω' k b) ∈ bkPair K A B) ↔ ((ω, ω') ∈ bkPair K A B) := by
  have hcfg : hybrid2 K (Function.update ω' k b) ω = hybrid2 K ω' ω := by
    funext v
    by_cases hv : v ∈ K
    · have hvk : v ≠ k := fun h => hk (h ▸ hv)
      simp [hybrid2, hv, Function.update_of_ne hvk]
    · simp [hybrid2, hv]
  constructor
  · rintro ⟨S, T, hST, hSA, hTB⟩
    exact ⟨S, T, hST, by rwa [hcfg] at hSA, hTB⟩
  · rintro ⟨S, T, hST, hSA, hTB⟩
    exact ⟨S, T, hST, by rwa [hcfg], hTB⟩

omit [Fintype ι] in
/-- Decoupling a site at which the first copy is closed costs nothing. -/
theorem bkPair_insert_of_fst_false {A B : Set (ι → Bool)} {K : Finset ι} {k : ι}
    (hk : k ∉ K) {ω ω' : ι → Bool} (hω : ω k = false) (h : (ω, ω') ∈ bkPair K A B) :
    (ω, Function.update ω' k false) ∈ bkPair (insert k K) A B := by
  obtain ⟨S, T, hST, hSA, hTB⟩ := h
  refine ⟨S, T, hST.trans (Finset.subset_insert k K), ?_, hTB⟩
  have hcfg : maskOn S (hybrid2 (insert k K) (Function.update ω' k false) ω)
      = maskOn S (hybrid2 K ω' ω) := by
    funext v
    by_cases hvS : v ∈ S
    · by_cases hvk : v = k
      · subst hvk
        simp [maskOn, hvS, hybrid2, hk, hω]
      · simp [maskOn, hvS, hybrid2, Finset.mem_insert, hvk]
    · simp [maskOn, hvS]
  rw [hcfg]; exact hSA

omit [Fintype ι] in
/-- **The combinatorial heart of the BK argument.**  A witness pair for
`bkPair K` cannot use the undecoupled site `k` twice, so after decoupling `k`
one of the two copies may be freed at `k`: either `A`'s witness does not use `k`
(and the second copy can be closed there) or `B`'s witness does not use `k`
(and the first copy can be closed there, the second being opened). -/
theorem bkPair_key {A B : Set (ι → Bool)} (hA : IsIncreasing A) {K : Finset ι} {k : ι}
    (hk : k ∉ K) {ω ω' : ι → Bool} (h : (ω, ω') ∈ bkPair K A B) :
    (ω, Function.update ω' k false) ∈ bkPair (insert k K) A B ∨
      (Function.update ω k false, Function.update ω' k true) ∈ bkPair (insert k K) A B := by
  obtain ⟨S, T, hST, hSA, hTB⟩ := h
  by_cases hkS : k ∈ S
  · have hkT : k ∉ T := fun hkT => hk (hST (Finset.mem_inter.mpr ⟨hkS, hkT⟩))
    right
    refine ⟨S, T, hST.trans (Finset.subset_insert k K), ?_, ?_⟩
    · refine hA _ _ ?_ hSA
      intro v hv
      by_cases hvS : v ∈ S
      · simp only [maskOn, if_pos hvS] at hv ⊢
        by_cases hvk : v = k
        · subst hvk
          simp [hybrid2, Finset.mem_insert]
        · simp only [hybrid2, Finset.mem_insert, hvk, false_or] at hv ⊢
          by_cases hvK : v ∈ K
          · simpa [hvK, Function.update_of_ne hvk] using hv
          · simpa [hvK, Function.update_of_ne hvk] using hv
      · simp [maskOn, hvS] at hv
    · rw [maskOn_update_of_notMem hkT]
      exact hTB
  · left
    refine ⟨S, T, hST.trans (Finset.subset_insert k K), ?_, hTB⟩
    have hcfg : maskOn S (hybrid2 (insert k K) (Function.update ω' k false) ω)
        = maskOn S (hybrid2 K ω' ω) := by
      funext v
      by_cases hvS : v ∈ S
      · have hvk : v ≠ k := fun hh => hkS (hh ▸ hvS)
        simp [maskOn, hvS, hybrid2, Finset.mem_insert, hvk]
      · simp [maskOn, hvS]
    rw [hcfg]; exact hSA

/-! ## The doubled Bernoulli sum -/

/-- The product Bernoulli measure of density `p` on pairs of configurations,
evaluated on an event. -/
noncomputable def bernProb2 (p : ℝ) (E : Set ((ι → Bool) × (ι → Bool))) : ℝ :=
  ∑ ω : ι → Bool, ∑ ω' : ι → Bool,
    weight p ω * weight p ω' * E.indicator (fun _ => (1 : ℝ)) (ω, ω')

/-- Splitting a doubled sum at one coordinate of each copy. -/
theorem sum_pair_split (k : ι) (g : (ι → Bool) → (ι → Bool) → ℝ) :
    ∑ ω : ι → Bool, ∑ ω' : ι → Bool, g ω ω' =
      ∑ ω ∈ univ.filter (fun ω : ι → Bool => ω k = true),
        ∑ ω' ∈ univ.filter (fun ω' : ι → Bool => ω' k = true),
          (g ω ω' + g ω (Function.update ω' k false)
            + g (Function.update ω k false) ω'
            + g (Function.update ω k false) (Function.update ω' k false)) := by
  rw [sum_split k (fun ω => ∑ ω' : ι → Bool, g ω ω')]
  refine Finset.sum_congr rfl fun ω _ => ?_
  rw [sum_split k (g ω), sum_split k (g (Function.update ω k false)),
    ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun ω' _ => by ring

/-- The doubled probability of an event depending only on the first copy. -/
theorem bernProb2_of_fst (p : ℝ) (C : Set (ι → Bool)) :
    bernProb2 p {z : (ι → Bool) × (ι → Bool) | z.1 ∈ C} = bernProb p C := by
  rw [bernProb2, bernProb_eq_sum_mul_indicator]
  refine Finset.sum_congr rfl fun ω _ => ?_
  have hind : ∀ ω' : ι → Bool,
      weight p ω * weight p ω' *
          ({z : (ι → Bool) × (ι → Bool) | z.1 ∈ C}).indicator (fun _ => (1 : ℝ)) (ω, ω')
        = weight p ω' * (weight p ω * C.indicator (fun _ => (1 : ℝ)) ω) := by
    intro ω'
    by_cases h : ω ∈ C
    · rw [Set.indicator_of_mem (by exact h : (ω, ω') ∈ {z : (ι → Bool) × (ι → Bool) | z.1 ∈ C}),
        Set.indicator_of_mem h]
      ring
    · rw [Set.indicator_of_notMem (by exact h : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.1 ∈ C}),
        Set.indicator_of_notMem h]
      ring
  rw [Finset.sum_congr rfl (fun ω' _ => hind ω'), ← Finset.sum_mul, sum_weight, one_mul]

/-- The doubled probability of a product event factorizes. -/
theorem bernProb2_prod (p : ℝ) (A B : Set (ι → Bool)) :
    bernProb2 p {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B} =
      bernProb p B * bernProb p A := by
  rw [bernProb2, bernProb_eq_sum_mul_indicator, bernProb_eq_sum_mul_indicator, Finset.sum_mul]
  refine Finset.sum_congr rfl fun ω _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun ω' _ => ?_
  by_cases hB : ω ∈ B <;> by_cases hA : ω' ∈ A
  · rw [Set.indicator_of_mem
        (by exact ⟨hA, hB⟩ : (ω, ω') ∈ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_mem hA, Set.indicator_of_mem hB]
    ring
  · rw [Set.indicator_of_notMem
        (by exact fun h => hA h.1 : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_notMem hA]
    ring
  · rw [Set.indicator_of_notMem
        (by exact fun h => hB h.2 : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_notMem hB]
    ring
  · rw [Set.indicator_of_notMem
        (by exact fun h => hA h.1 : (ω, ω') ∉ {z : (ι → Bool) × (ι → Bool) | z.2 ∈ A ∧ z.1 ∈ B}),
      Set.indicator_of_notMem hA]
    ring

/-! ## The local inequality -/

/-- The arithmetic core of the decoupling step.  All six quantities are
indicator values; `e₀`, `e₁` are the values of the undecoupled event, and the
`F`'s those of the decoupled event at the four states of the new site. -/
theorem bk_local_ineq {p e₀ e₁ F₀₀ F₀₁ F₁₀ F₁₁ : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (he₀ : e₀ = 0 ∨ e₀ = 1) (he₁ : e₁ = 0 ∨ e₁ = 1)
    (hf₀₀ : F₀₀ = 0 ∨ F₀₀ = 1) (hf₀₁ : F₀₁ = 0 ∨ F₀₁ = 1)
    (hf₁₀ : F₁₀ = 0 ∨ F₁₀ = 1) (hf₁₁ : F₁₁ = 0 ∨ F₁₁ = 1)
    (h0 : e₀ ≤ F₀₀) (h1 : e₁ ≤ F₀₁ + F₁₀)
    (m1 : F₀₀ ≤ F₀₁) (m2 : F₀₀ ≤ F₁₀) (m3 : F₀₁ ≤ F₁₁) (m4 : F₁₀ ≤ F₁₁) :
    p * p * e₁ + p * (1 - p) * e₁ + (1 - p) * p * e₀ + (1 - p) * (1 - p) * e₀ ≤
      p * p * F₁₁ + p * (1 - p) * F₀₁ + (1 - p) * p * F₁₀ + (1 - p) * (1 - p) * F₀₀ := by
  rcases he₀ with rfl | rfl <;> rcases he₁ with rfl | rfl <;>
    rcases hf₀₀ with rfl | rfl <;> rcases hf₀₁ with rfl | rfl <;>
    rcases hf₁₀ with rfl | rfl <;> rcases hf₁₁ with rfl | rfl <;> nlinarith [sq_nonneg p,
      sq_nonneg (1 - p), mul_nonneg hp0 (sub_nonneg.mpr hp1)]

/-! ## The decoupling step -/

/-- **Decoupling one more site does not decrease the probability.** -/
theorem bernProb2_bkPair_le_insert {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B)
    (K : Finset ι) {k : ι} (hk : k ∉ K) :
    bernProb2 p (bkPair K A B) ≤ bernProb2 p (bkPair (insert k K) A B) := by
  classical
  rw [bernProb2, bernProb2, sum_pair_split k, sum_pair_split k]
  refine Finset.sum_le_sum fun ω hω => Finset.sum_le_sum fun ω' hω' => ?_
  simp only [mem_filter, mem_univ, true_and] at hω hω'
  set ω₀ := Function.update ω k false with hω₀
  set ω'₀ := Function.update ω' k false with hω'₀
  -- weights
  have hwω : weight p ω = p * offWeight p k ω := by
    rw [weight_eq_mul_offWeight p k ω, hω]; simp
  have hwω' : weight p ω' = p * offWeight p k ω' := by
    rw [weight_eq_mul_offWeight p k ω', hω']; simp
  have hwω₀ : weight p ω₀ = (1 - p) * offWeight p k ω := by
    rw [weight_eq_mul_offWeight p k ω₀, hω₀, offWeight_update]
    simp
  have hwω'₀ : weight p ω'₀ = (1 - p) * offWeight p k ω' := by
    rw [weight_eq_mul_offWeight p k ω'₀, hω'₀, offWeight_update]
    simp
  set W := offWeight p k ω with hW
  set W' := offWeight p k ω' with hW'
  have hWnn : 0 ≤ W := by
    rw [hW, offWeight]
    refine Finset.prod_nonneg fun u _ => ?_
    by_cases h : ω u = true
    · simp [h, hp0]
    · simp only [Bool.not_eq_true] at h
      simp only [h, Bool.false_eq_true, if_false]
      linarith
  have hW'nn : 0 ≤ W' := by
    rw [hW', offWeight]
    refine Finset.prod_nonneg fun u _ => ?_
    by_cases h : ω' u = true
    · simp [h, hp0]
    · simp only [Bool.not_eq_true] at h
      simp only [h, Bool.false_eq_true, if_false]
      linarith
  -- indicator abbreviations
  set e₁ := (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω, ω') with he₁def
  set e₀ := (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω') with he₀def
  set F₁₁ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω, ω') with hF₁₁def
  set F₀₁ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω, ω'₀) with hF₀₁def
  set F₁₀ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω') with hF₁₀def
  set F₀₀ := (bkPair (insert k K) A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω'₀) with hF₀₀def
  -- the undecoupled event does not see the second copy at `k`
  have hsnd : (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω, ω'₀) = e₁ := by
    rw [he₁def, hω'₀]
    by_cases h : (ω, ω') ∈ bkPair K A B
    · rw [Set.indicator_of_mem ((bkPair_snd_update hk ω ω' false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem (fun hc => h ((bkPair_snd_update hk ω ω' false).mp hc)),
        Set.indicator_of_notMem h]
  have hsnd₀ : (bkPair K A B).indicator (fun _ => (1 : ℝ)) (ω₀, ω'₀) = e₀ := by
    rw [he₀def, hω'₀]
    by_cases h : (ω₀, ω') ∈ bkPair K A B
    · rw [Set.indicator_of_mem ((bkPair_snd_update hk ω₀ ω' false).mpr h),
        Set.indicator_of_mem h]
    · rw [Set.indicator_of_notMem (fun hc => h ((bkPair_snd_update hk ω₀ ω' false).mp hc)),
        Set.indicator_of_notMem h]
  -- pointwise facts
  have hupdle : ∀ (ξ : ι → Bool) (v : ι), Function.update ξ k false v = true → ξ v = true := by
    intro ξ v hv
    by_cases hvk : v = k
    · subst hvk; simp at hv
    · rwa [Function.update_of_ne hvk] at hv
  have h0 : e₀ ≤ F₀₀ := by
    refine bkInd_le_of_imp _ _ _ _ (fun hmem => ?_)
    exact bkPair_insert_of_fst_false hk (by simp [hω₀]) hmem
  have h1 : e₁ ≤ F₀₁ + F₁₀ := by
    refine bkInd_le_add_of_imp_or _ _ _ _ _ (fun hmem => ?_)
    rcases bkPair_key hA hk hmem with h | h
    · exact Or.inl h
    · refine Or.inr ?_
      have : Function.update ω' k true = ω' := by
        rw [← hω']; exact Function.update_eq_self k ω'
      rwa [this] at h
  have m1 : F₀₀ ≤ F₀₁ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (hupdle ω) (fun _ h => h) hmem)
  have m2 : F₀₀ ≤ F₁₀ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (fun _ h => h) (hupdle ω') hmem)
  have m3 : F₀₁ ≤ F₁₁ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (fun _ h => h) (hupdle ω') hmem)
  have m4 : F₁₀ ≤ F₁₁ :=
    bkInd_le_of_imp _ _ _ _ (fun hmem => bkPair_mono hA hB (hupdle ω) (fun _ h => h) hmem)
  have hlocal := bk_local_ineq hp0 hp1 (bkInd_eq_zero_or_one _ (ω₀, ω'))
    (bkInd_eq_zero_or_one _ (ω, ω')) (bkInd_eq_zero_or_one _ (ω₀, ω'₀))
    (bkInd_eq_zero_or_one _ (ω, ω'₀)) (bkInd_eq_zero_or_one _ (ω₀, ω'))
    (bkInd_eq_zero_or_one _ (ω, ω')) h0 h1 m1 m2 m3 m4
  rw [hwω, hwω', hwω₀, hwω'₀, hsnd, hsnd₀]
  nlinarith [mul_nonneg hWnn hW'nn, hlocal]

/-- Decoupling any set of sites does not decrease the probability. -/
theorem bernProb2_bkPair_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) (K : Finset ι) :
    bernProb2 p (bkPair (∅ : Finset ι) A B) ≤ bernProb2 p (bkPair K A B) := by
  classical
  induction K using Finset.induction_on with
  | empty => exact le_rfl
  | insert k K hk ih =>
    exact ih.trans (bernProb2_bkPair_le_insert hp0 hp1 hA hB K hk)

/-! ## The BK inequality -/

/-- **The van den Berg–Kesten inequality on a finite site set.**  For increasing
events `A` and `B`, the probability that they occur disjointly is at most the
product of their probabilities. -/
theorem bernProb_bk {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProb p (disjointOccur A B) ≤ bernProb p A * bernProb p B := by
  have h := bernProb2_bkPair_le hp0 hp1 hA hB (univ : Finset ι)
  rw [bkPair_empty, bernProb2_of_fst, bkPair_univ hA hB, bernProb2_prod] at h
  linarith [h]

/-- **BK and Harris together.**  The correlation of two increasing events is
squeezed between the disjoint-occurrence probability and the joint one. -/
theorem bernProb_bk_harris_sandwich {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProb p (disjointOccur A B) ≤ bernProb p A * bernProb p B ∧
      bernProb p A * bernProb p B ≤ bernProb p (A ∩ B) :=
  ⟨bernProb_bk hp0 hp1 hA hB, bernProb_harris hp0 hp1 hA hB⟩

/-! ## The key-measure form -/

/-- **BK inequality on the key probability space.**  Under independent uniform
threshold keys, the probability that two increasing events occur disjointly at
level `p` is at most the product of their probabilities. -/
theorem keyMeasure_bk {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    keyMeasure ι (eventKeys p (disjointOccur A B)) ≤
      keyMeasure ι (eventKeys p A) * keyMeasure ι (eventKeys p B) := by
  rw [keyMeasure_eventKeys hp0 hp1, keyMeasure_eventKeys hp0 hp1,
    keyMeasure_eventKeys hp0 hp1, ← ENNReal.ofReal_mul (bernProb_nonneg hp0 hp1 A)]
  exact ENNReal.ofReal_le_ofReal (bernProb_bk hp0 hp1 hA hB)

/-! ## Sharpness of the bound -/

/-- Disjoint occurrence with the sure event is no constraint. -/
theorem disjointOccur_univ_left {B : Set (ι → Bool)} (hB : IsIncreasing B) :
    disjointOccur (Set.univ : Set (ι → Bool)) B = B := by
  refine Set.Subset.antisymm (fun ω hω =>
    (disjointOccur_subset_inter isIncreasing_univ hB hω).2) (fun ω hω => ?_)
  exact ⟨∅, univ, by simp, Set.mem_univ _, by rwa [maskOn_univ]⟩

/-- **The BK bound is attained.** -/
theorem bernProb_bk_eq_univ_left {p : ℝ} {B : Set (ι → Bool)} (hB : IsIncreasing B) :
    bernProb p (disjointOccur (Set.univ : Set (ι → Bool)) B) =
      bernProb p (Set.univ : Set (ι → Bool)) * bernProb p B := by
  rw [disjointOccur_univ_left hB, bernProb_univ, one_mul]

omit [Fintype ι] in
/-- A single site cannot be used twice, so an event depending on one site never
occurs disjointly with itself. -/
theorem disjointOccur_openSite_self (v : ι) :
    disjointOccur {η : ι → Bool | η v = true} {η : ι → Bool | η v = true} = ∅ := by
  ext ω
  simp only [Set.mem_empty_iff_false, iff_false]
  rintro ⟨S, T, hST, hSA, hTB⟩
  have hvS : v ∈ S := by
    by_contra h
    simp [maskOn, h, Set.mem_setOf_eq] at hSA
  have hvT : v ∈ T := by
    by_contra h
    simp [maskOn, h, Set.mem_setOf_eq] at hTB
  exact (Finset.disjoint_left.mp hST hvS) hvT

/-- **The BK bound is not always attained.**  For the event that a prescribed
site is open the disjoint-occurrence probability vanishes while the product of
the probabilities is `p ^ 2`. -/
theorem bernProb_bk_strict_openSite (v : ι) {p : ℝ} (hp0 : 0 < p) :
    bernProb p (disjointOccur {η : ι → Bool | η v = true} {η : ι → Bool | η v = true}) <
      bernProb p {η : ι → Bool | η v = true} * bernProb p {η : ι → Bool | η v = true} := by
  rw [disjointOccur_openSite_self, bernProb_empty, bernProb_openSite]
  exact mul_pos hp0 hp0

omit [Fintype ι] in
/-- Two distinct sites can host the two witnesses, so for single-site events at
distinct sites disjoint occurrence is the same as joint occurrence. -/
theorem disjointOccur_openSite_of_ne {u v : ι} (huv : u ≠ v) :
    disjointOccur {η : ι → Bool | η u = true} {η : ι → Bool | η v = true} =
      {η : ι → Bool | η u = true} ∩ {η : ι → Bool | η v = true} := by
  refine Set.Subset.antisymm
    (disjointOccur_subset_inter (isIncreasing_openSite u) (isIncreasing_openSite v))
    (fun ω hω => ⟨{u}, {v}, by simpa using huv, ?_, ?_⟩)
  · simpa [maskOn, Set.mem_setOf_eq] using hω.1
  · simpa [maskOn, Set.mem_setOf_eq] using hω.2

/-- **Distinct sites are independent, by BK and Harris together.**  Harris
bounds the joint probability from below by `p ^ 2` and BK bounds it from above
by the same quantity. -/
theorem bernProb_two_openSites {u v : ι} (huv : u ≠ v) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    bernProb p ({η : ι → Bool | η u = true} ∩ {η : ι → Bool | η v = true}) = p * p := by
  have hharris := bernProb_harris hp0 hp1 (isIncreasing_openSite u) (isIncreasing_openSite v)
  have hbk := bernProb_bk hp0 hp1 (isIncreasing_openSite u) (isIncreasing_openSite v)
  rw [disjointOccur_openSite_of_ne huv, bernProb_openSite, bernProb_openSite] at hbk
  rw [bernProb_openSite, bernProb_openSite] at hharris
  linarith

/-! ## Iterated disjoint occurrence -/

/-- `n` disjoint occurrences of the same increasing event. -/
def disjointPow (A : Set (ι → Bool)) : ℕ → Set (ι → Bool)
  | 0 => Set.univ
  | n + 1 => disjointOccur A (disjointPow A n)

omit [Fintype ι] in
theorem disjointPow_isIncreasing {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    ∀ n, IsIncreasing (disjointPow A n)
  | 0 => isIncreasing_univ
  | n + 1 => disjointOccur_isIncreasing hA (disjointPow_isIncreasing hA n)

/-- **Exponential decay of disjoint occurrences.**  The probability that an
increasing event occurs `n` times disjointly is at most the `n`-th power of its
probability. -/
theorem bernProb_disjointPow_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) :
    ∀ n, bernProb p (disjointPow A n) ≤ (bernProb p A) ^ n
  | 0 => by simp [disjointPow, bernProb_univ]
  | n + 1 => by
    have hstep := bernProb_bk hp0 hp1 hA (disjointPow_isIncreasing hA n)
    have hih := bernProb_disjointPow_le hp0 hp1 hA n
    have hAnn : 0 ≤ bernProb p A := bernProb_nonneg hp0 hp1 A
    calc bernProb p (disjointPow A (n + 1))
        ≤ bernProb p A * bernProb p (disjointPow A n) := hstep
      _ ≤ bernProb p A * (bernProb p A) ^ n := by
          exact mul_le_mul_of_nonneg_left hih hAnn
      _ = (bernProb p A) ^ (n + 1) := by ring

/-! ## Grid crossings -/

/-- **BK for grid crossings.**  The probability of two disjoint horizontal
crossings of the `n × n` grid is at most the square of the crossing
probability. -/
theorem crossing_bk (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    bernProb p (disjointOccur (crossingEvent n hn) (crossingEvent n hn)) ≤
      bernProb p (crossingEvent n hn) ^ 2 := by
  have h := bernProb_bk hp0 hp1 (crossingEvent_isIncreasing n hn)
    (crossingEvent_isIncreasing n hn)
  calc bernProb p (disjointOccur (crossingEvent n hn) (crossingEvent n hn))
      ≤ bernProb p (crossingEvent n hn) * bernProb p (crossingEvent n hn) := h
    _ = bernProb p (crossingEvent n hn) ^ 2 := by ring

/-- **Exponential decay of disjoint crossings.** -/
theorem crossing_disjointPow_le (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (m : ℕ) :
    bernProb p (disjointPow (crossingEvent n hn) m) ≤ bernProb p (crossingEvent n hn) ^ m :=
  bernProb_disjointPow_le hp0 hp1 (crossingEvent_isIncreasing n hn) m

end BernoulliThresholdCoupling