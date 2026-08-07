/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.Flags

/-!
# Schubert calculus II: coordinate subspaces, opposite flags and the duality theorem

Working in the coordinate space `Kⁿ` we introduce the standard flag `E₀ ⊂ E₁ ⊂ ⋯` (spanned by
the first coordinates) and the *opposite* flag `E'₀ ⊂ E'₁ ⊂ ⋯` (spanned by the last
coordinates), and we prove the two facts that make Schubert calculus an *enumerative* theory:

* `SchubertCalculus.finrank_inf_std_add_finrank_inf_opp_le` (**the basic inequality**):
  for every subspace `W` and every `i ≤ n`,
  `dim (W ⊓ Eᵢ) + dim (W ⊓ E'_{n-i}) ≤ dim W`.
  This is the source of *all* vanishing statements `σ_λ · σ_μ = 0` for non-complementary
  Schubert classes.

* `SchubertCalculus.transverse_eq_coord` and
  `SchubertCalculus.transverse_setOf_eq_singleton` (**the duality theorem**):
  if a `k`-dimensional subspace `W` achieves equality in the basic inequality for all `i`
  (the *complementary/transverse* case), then `W` is forced to be the coordinate subspace
  spanned by the standard basis vectors indexed by its jump set — and conversely each
  coordinate subspace is such a point. Hence a complementary pair of Schubert conditions
  relative to opposite flags is satisfied by *exactly one* point of the Grassmannian:
  the Poincaré duality relation `σ_λ · σ_λᵛ = 1` at the level of points.

The proof of duality is a dimension count: forcing equality makes
`dim (W ⊓ E_{s+1}) + dim (W ⊓ E'_{n-s}) = dim W + 1`, so the two subspaces of `W` meet in a
nonzero vector, which must lie on the coordinate line `E_{s+1} ⊓ E'_{n-s} = K · eₛ`.
-/

namespace SchubertCalculus

open Module Submodule Finset

variable (K : Type*) [Field K] {n : ℕ}

/-! ### Coordinate subspaces -/

/-- The coordinate subspace of `Kⁿ` spanned by the basis vectors indexed by `s`. -/
def coord (s : Finset (Fin n)) : Submodule K (Fin n → K) where
  carrier := {x | ∀ i ∉ s, x i = 0}
  zero_mem' := by intro i _; rfl
  add_mem' := by
    intro x y hx hy i hi
    simp [hx i hi, hy i hi]
  smul_mem' := by
    intro c x hx i hi
    simp [hx i hi]

variable {K}

@[simp] lemma mem_coord {s : Finset (Fin n)} {x : Fin n → K} :
    x ∈ coord K s ↔ ∀ i ∉ s, x i = 0 := Iff.rfl

lemma coord_inf (s t : Finset (Fin n)) : coord K s ⊓ coord K t = coord K (s ∩ t) := by
  ext x
  simp only [Submodule.mem_inf, mem_coord, Finset.mem_inter, not_and_or]
  constructor
  · rintro ⟨hs, ht⟩ i (h | h)
    · exact hs i h
    · exact ht i h
  · intro h
    exact ⟨fun i hi => h i (Or.inl hi), fun i hi => h i (Or.inr hi)⟩

lemma coord_mono {s t : Finset (Fin n)} (h : s ⊆ t) : coord K s ≤ coord K t :=
  fun _ hx i hi => hx i fun hs => hi (h hs)

@[simp] lemma coord_univ : coord K (Finset.univ : Finset (Fin n)) = ⊤ := by
  ext x; simp

@[simp] lemma coord_empty : coord K (∅ : Finset (Fin n)) = ⊥ := by
  ext x
  constructor
  · intro hx
    have h : ∀ i, x i = 0 := fun i => hx i (by simp)
    simpa [funext_iff] using h
  · intro hx i _
    have h : x = 0 := by simpa using hx
    simp [h]

lemma coord_eq_span (s : Finset (Fin n)) :
    coord K s =
      Submodule.span K ((fun i : Fin n => (Pi.single i (1 : K) : Fin n → K)) ''
        (s : Set (Fin n))) := by
  apply le_antisymm
  · intro x hx
    have hx' : x = ∑ i ∈ s, x i • (Pi.single i (1 : K) : Fin n → K) := by
      funext j
      by_cases hj : j ∈ s
      · rw [Finset.sum_apply, Finset.sum_eq_single j]
        · simp
        · intro b _ hb; simp [Ne.symm hb]
        · intro h; exact absurd hj h
      · rw [Finset.sum_apply, Finset.sum_eq_zero, hx j hj]
        intro b hb
        have : b ≠ j := fun h => hj (h ▸ hb)
        simp [this]
    rw [hx']
    refine Submodule.sum_mem _ fun i hi => Submodule.smul_mem _ _ ?_
    exact Submodule.subset_span ⟨i, hi, rfl⟩
  · rw [Submodule.span_le]
    rintro _ ⟨i, hi, rfl⟩ j hj
    have : j ≠ i := fun h => hj (h ▸ hi)
    simp [this]

/-- The standard basis vectors are pairwise distinct. -/
lemma single_one_injective :
    Function.Injective (fun i : Fin n => (Pi.single i (1 : K) : Fin n → K)) := by
  intro i j h
  by_contra hne
  have := congrFun h i
  simp [hne] at this

lemma finrank_coord (s : Finset (Fin n)) : finrank K (coord K s) = s.card := by
  classical
  have hli : LinearIndepOn K id
      ((fun i : Fin n => (Pi.single i (1 : K) : Fin n → K)) '' (s : Set (Fin n))) :=
    (((Pi.linearIndependent_single_one (Fin n) K).linearIndepOn).mono
      (Set.subset_univ _)).id_image
  rw [coord_eq_span s, finrank_span_set_eq_card hli,
    Set.toFinset_image, Finset.card_image_of_injective _ single_one_injective]
  simp


/-! ### The standard flag and its opposite -/

variable (K)

/-- The indices of the first `i` coordinates. -/
def stdSet (n i : ℕ) : Finset (Fin n) := Finset.univ.filter fun j => (j : ℕ) < i

/-- The indices of the last `i` coordinates. -/
def oppSet (n i : ℕ) : Finset (Fin n) := Finset.univ.filter fun j => n - i ≤ (j : ℕ)

variable {K}

@[simp] lemma mem_stdSet {i : ℕ} {j : Fin n} : j ∈ stdSet n i ↔ (j : ℕ) < i := by
  simp [stdSet]

@[simp] lemma mem_oppSet {i : ℕ} {j : Fin n} : j ∈ oppSet n i ↔ n - i ≤ (j : ℕ) := by
  simp [oppSet]

lemma card_stdSet {i : ℕ} (hi : i ≤ n) : (stdSet n i).card = i := by
  have himg : (stdSet n i).image Fin.val = Finset.range i := by
    ext m
    simp only [Finset.mem_image, mem_stdSet, Finset.mem_range]
    constructor
    · rintro ⟨j, hj, rfl⟩; exact hj
    · intro hm
      exact ⟨⟨m, lt_of_lt_of_le hm hi⟩, hm, rfl⟩
  have := congrArg Finset.card himg
  rwa [Finset.card_image_of_injective _ Fin.val_injective, Finset.card_range] at this

lemma card_oppSet {i : ℕ} (hi : i ≤ n) : (oppSet n i).card = i := by
  have himg : (oppSet n i).image Fin.val = Finset.Ico (n - i) n := by
    ext m
    simp only [Finset.mem_image, mem_oppSet, Finset.mem_Ico]
    constructor
    · rintro ⟨j, hj, rfl⟩; exact ⟨hj, j.isLt⟩
    · rintro ⟨h1, h2⟩
      exact ⟨⟨m, h2⟩, h1, rfl⟩
  have := congrArg Finset.card himg
  rw [Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico] at this
  omega

lemma stdSet_mono {i j : ℕ} (h : i ≤ j) : stdSet n i ⊆ stdSet n j := by
  intro x hx; simp only [mem_stdSet] at hx ⊢; omega

lemma oppSet_mono {i j : ℕ} (h : i ≤ j) : oppSet n i ⊆ oppSet n j := by
  intro x hx; simp only [mem_oppSet] at hx ⊢; omega

@[simp] lemma stdSet_self : stdSet n n = Finset.univ := by
  ext j; simp [j.isLt]

@[simp] lemma oppSet_self : oppSet n n = Finset.univ := by
  ext j; simp

/-- The standard complete flag of `Kⁿ`, whose `i`-th member is spanned by the first `i`
standard basis vectors. -/
def stdFlag (K : Type*) [Field K] (n : ℕ) : CompleteFlag K (Fin n → K) n where
  part i := coord K (stdSet n i)
  mono := fun _ _ h => coord_mono (stdSet_mono h)
  finrank_part := fun i hi => by rw [finrank_coord, card_stdSet hi]
  part_top := by rw [stdSet_self, coord_univ]

/-- The flag opposite to the standard flag: its `i`-th member is spanned by the *last* `i`
standard basis vectors. -/
def oppFlag (K : Type*) [Field K] (n : ℕ) : CompleteFlag K (Fin n → K) n where
  part i := coord K (oppSet n i)
  mono := fun _ _ h => coord_mono (oppSet_mono h)
  finrank_part := fun i hi => by rw [finrank_coord, card_oppSet hi]
  part_top := by rw [oppSet_self, coord_univ]

@[simp] lemma stdFlag_part (i : ℕ) : (stdFlag K n).part i = coord K (stdSet n i) := rfl

@[simp] lemma oppFlag_part (i : ℕ) : (oppFlag K n).part i = coord K (oppSet n i) := rfl

/-- The two opposite flags are transverse at complementary levels: `Eᵢ ∩ E'_{n-i} = 0`. -/
lemma stdSet_inter_oppSet {i : ℕ} (hi : i ≤ n) : stdSet n i ∩ oppSet n (n - i) = ∅ := by
  ext j
  simp only [Finset.mem_inter, mem_stdSet, mem_oppSet, Finset.notMem_empty, iff_false, not_and]
  omega

/-- At one level higher, the intersection is exactly a coordinate line. -/
lemma stdSet_succ_inter_oppSet {s : ℕ} (hs : s < n) :
    stdSet n (s + 1) ∩ oppSet n (n - s) = {(⟨s, hs⟩ : Fin n)} := by
  ext j
  simp only [Finset.mem_inter, mem_stdSet, mem_oppSet, Finset.mem_singleton]
  constructor
  · rintro ⟨h1, h2⟩
    have : (j : ℕ) = s := by omega
    exact Fin.ext this
  · rintro rfl
    simp
    omega

/-- The opposite flag member is the complementary coordinate subspace. -/
lemma oppSet_eq_compl_stdSet {i : ℕ} (hi : i ≤ n) : oppSet n (n - i) = (stdSet n i)ᶜ := by
  ext j
  simp only [mem_oppSet, Finset.mem_compl, mem_stdSet, not_lt]
  omega


/-! ### The basic inequality and the duality theorem -/

/-- **The basic inequality of Schubert calculus.** For every subspace `W` of `Kⁿ` and every
`i ≤ n`, the dimensions cut out by two opposite flags at complementary levels add up to at
most `dim W`. Equality is the transversality (complementarity) condition. -/
theorem finrank_inf_std_add_finrank_inf_opp_le (W : Submodule K (Fin n → K)) {i : ℕ}
    (hi : i ≤ n) :
    finrank K ((W ⊓ coord K (stdSet n i) : Submodule K (Fin n → K))) +
      finrank K ((W ⊓ coord K (oppSet n (n - i)) : Submodule K (Fin n → K))) ≤ finrank K W := by
  set A : Submodule K (Fin n → K) := W ⊓ coord K (stdSet n i) with hAdef
  set B : Submodule K (Fin n → K) := W ⊓ coord K (oppSet n (n - i)) with hBdef
  have hinf : A ⊓ B = ⊥ := by
    have hle : A ⊓ B ≤ coord K (stdSet n i) ⊓ coord K (oppSet n (n - i)) :=
      inf_le_inf inf_le_right inf_le_right
    rw [coord_inf, stdSet_inter_oppSet hi, coord_empty] at hle
    exact le_bot_iff.mp hle
  have hsup : A ⊔ B ≤ W := sup_le inf_le_left inf_le_left
  have key := Submodule.finrank_sup_add_finrank_inf_eq A B
  rw [hinf, finrank_bot] at key
  have hmono : finrank K ((A ⊔ B : Submodule K (Fin n → K))) ≤ finrank K W :=
    Submodule.finrank_mono hsup
  omega

/-- A subspace is *transverse* (to the pair of opposite flags) when it achieves equality in
the basic inequality at every level. Geometrically: `W` lies in the intersection of a
Schubert cell for the standard flag with the *complementary* Schubert cell for the opposite
flag. -/
def IsTransverse (W : Submodule K (Fin n → K)) : Prop :=
  ∀ i ≤ n, finrank K ((W ⊓ coord K (stdSet n i) : Submodule K (Fin n → K))) +
    finrank K ((W ⊓ coord K (oppSet n (n - i)) : Submodule K (Fin n → K))) = finrank K W

/-- Key step of the duality theorem: a transverse subspace contains the coordinate line
`K · e_s` for every jump `s` of its standard flag filtration. -/
theorem coord_singleton_le_of_transverse (W : Submodule K (Fin n → K)) (hW : IsTransverse W)
    {s : Fin n} (hs : (s : ℕ) ∈ (stdFlag K n).jumpSet W) : coord K {s} ≤ W := by
  obtain ⟨hsn, hstep⟩ := (CompleteFlag.mem_jumpSet (stdFlag K n) W).mp hs
  set A : Submodule K (Fin n → K) := W ⊓ coord K (stdSet n ((s : ℕ) + 1)) with hAdef
  set B : Submodule K (Fin n → K) := W ⊓ coord K (oppSet n (n - (s : ℕ))) with hBdef
  have hA : finrank K A = finrank K ((W ⊓ coord K (stdSet n (s : ℕ)) : Submodule K (Fin n → K)))
      + 1 := hstep
  have hB : finrank K ((W ⊓ coord K (stdSet n (s : ℕ)) : Submodule K (Fin n → K))) +
      finrank K B = finrank K W := hW (s : ℕ) hsn.le
  have hsup : A ⊔ B ≤ W := sup_le inf_le_left inf_le_left
  have hmono : finrank K ((A ⊔ B : Submodule K (Fin n → K))) ≤ finrank K W :=
    Submodule.finrank_mono hsup
  have key := Submodule.finrank_sup_add_finrank_inf_eq A B
  have hline : A ⊓ B ≤ coord K {s} := by
    have hle : A ⊓ B ≤ coord K (stdSet n ((s : ℕ) + 1)) ⊓ coord K (oppSet n (n - (s : ℕ))) :=
      inf_le_inf inf_le_right inf_le_right
    rwa [coord_inf, stdSet_succ_inter_oppSet hsn, show (⟨(s : ℕ), hsn⟩ : Fin n) = s from rfl]
      at hle
  have hcard : finrank K (coord K ({s} : Finset (Fin n))) = 1 := by
    rw [finrank_coord]; simp
  have hge : 1 ≤ finrank K ((A ⊓ B : Submodule K (Fin n → K))) := by omega
  have hle' : finrank K ((A ⊓ B : Submodule K (Fin n → K))) ≤ 1 := by
    rw [← hcard]; exact Submodule.finrank_mono hline
  have heq : A ⊓ B = coord K {s} :=
    Submodule.eq_of_le_of_finrank_eq hline (by omega)
  rw [← heq]
  exact le_trans inf_le_left inf_le_left

/-- The jump set of `W`, transported to `Fin n`. -/
noncomputable def jumpFinset (W : Submodule K (Fin n → K)) : Finset (Fin n) :=
  Finset.univ.filter fun j : Fin n => (j : ℕ) ∈ (stdFlag K n).jumpSet W

/-- Transporting a set of indices from `ℕ` to `Fin n` and back is the identity, as soon as
the set is contained in `{0, …, n-1}`. -/
lemma image_val_filter_mem {S : Finset ℕ} (hS : S ⊆ Finset.range n) :
    (Finset.univ.filter fun j : Fin n => (j : ℕ) ∈ S).image Fin.val = S := by
  ext m
  simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨j, hj, rfl⟩; exact hj
  · intro hm
    exact ⟨⟨m, Finset.mem_range.mp (hS hm)⟩, hm, rfl⟩

lemma image_val_jumpFinset (W : Submodule K (Fin n → K)) :
    (jumpFinset W).image Fin.val = (stdFlag K n).jumpSet W :=
  image_val_filter_mem ((stdFlag K n).jumpSet_subset W)

lemma card_jumpFinset (W : Submodule K (Fin n → K)) :
    (jumpFinset W).card = finrank K W := by
  have h := congrArg Finset.card (image_val_jumpFinset W)
  rw [Finset.card_image_of_injective _ Fin.val_injective] at h
  rw [h, (stdFlag K n).card_jumpSet W]

/-- **The duality theorem, rigidity half.** A transverse subspace is *forced* to be the
coordinate subspace spanned by the basis vectors indexed by its jump set. This is the
statement that a complementary pair of Schubert conditions has at most one solution. -/
theorem transverse_eq_coord (W : Submodule K (Fin n → K)) (hW : IsTransverse W) :
    W = coord K (jumpFinset W) := by
  have hle : coord K (jumpFinset W) ≤ W := by
    rw [coord_eq_span]
    rw [Submodule.span_le]
    rintro _ ⟨j, hj, rfl⟩
    have hjmem : (j : ℕ) ∈ (stdFlag K n).jumpSet W := by
      simpa [jumpFinset] using hj
    refine coord_singleton_le_of_transverse W hW hjmem ?_
    intro i hi
    have : i ≠ j := by simpa using hi
    simp [this]
  refine (Submodule.eq_of_le_of_finrank_eq hle ?_).symm
  rw [finrank_coord, card_jumpFinset]

/-! ### Coordinate subspaces are exactly the transverse points -/

lemma finrank_inf_coord (S t : Finset (Fin n)) :
    finrank K ((coord K S ⊓ coord K t : Submodule K (Fin n → K))) = (S ∩ t).card := by
  rw [coord_inf, finrank_coord]

/-- Every coordinate subspace is transverse. -/
theorem transverse_coord (S : Finset (Fin n)) : IsTransverse (coord K S) := by
  intro i hi
  rw [finrank_inf_coord, finrank_inf_coord, finrank_coord, oppSet_eq_compl_stdSet hi]
  have hsdiff : S ∩ (stdSet n i)ᶜ = S \ stdSet n i := by
    ext j; simp [Finset.mem_sdiff]
  rw [hsdiff, Finset.card_inter_add_card_sdiff]

lemma inter_stdSet_succ (S : Finset (Fin n)) {i : ℕ} (hi : i < n) :
    S ∩ stdSet n (i + 1) =
      if (⟨i, hi⟩ : Fin n) ∈ S then insert (⟨i, hi⟩ : Fin n) (S ∩ stdSet n i)
      else S ∩ stdSet n i := by
  by_cases h : (⟨i, hi⟩ : Fin n) ∈ S
  · rw [if_pos h]
    ext j
    simp only [Finset.mem_inter, mem_stdSet, Finset.mem_insert, Fin.ext_iff]
    constructor
    · rintro ⟨hjS, hjlt⟩
      rcases Nat.lt_succ_iff_lt_or_eq.mp hjlt with h' | h'
      · exact Or.inr ⟨hjS, h'⟩
      · exact Or.inl h'
    · rintro (h' | ⟨hjS, hjlt⟩)
      · refine ⟨?_, by omega⟩
        have : j = (⟨i, hi⟩ : Fin n) := Fin.ext h'
        rwa [this]
      · exact ⟨hjS, by omega⟩
  · rw [if_neg h]
    ext j
    simp only [Finset.mem_inter, mem_stdSet]
    constructor
    · rintro ⟨hjS, hjlt⟩
      refine ⟨hjS, ?_⟩
      rcases Nat.lt_succ_iff_lt_or_eq.mp hjlt with h' | h'
      · exact h'
      · exfalso
        exact h (by rwa [show (⟨i, hi⟩ : Fin n) = j from Fin.ext h'.symm])
    · rintro ⟨hjS, hjlt⟩
      exact ⟨hjS, by omega⟩

lemma card_inter_stdSet_succ (S : Finset (Fin n)) {i : ℕ} (hi : i < n) :
    (S ∩ stdSet n (i + 1)).card =
      (S ∩ stdSet n i).card + (if (⟨i, hi⟩ : Fin n) ∈ S then 1 else 0) := by
  rw [inter_stdSet_succ S hi]
  by_cases h : (⟨i, hi⟩ : Fin n) ∈ S
  · rw [if_pos h, if_pos h, Finset.card_insert_of_notMem (by simp)]
  · rw [if_neg h, if_neg h, add_zero]

/-- The jump set of a coordinate subspace is its index set. -/
theorem jumpSet_coord (S : Finset (Fin n)) :
    (stdFlag K n).jumpSet (coord K S) = S.image Fin.val := by
  ext i
  rw [CompleteFlag.mem_jumpSet]
  simp only [stdFlag_part, finrank_inf_coord, Finset.mem_image]
  constructor
  · rintro ⟨hi, hstep⟩
    rw [card_inter_stdSet_succ S hi] at hstep
    refine ⟨⟨i, hi⟩, ?_, rfl⟩
    by_contra hmem
    rw [if_neg hmem] at hstep
    omega
  · rintro ⟨j, hj, rfl⟩
    refine ⟨j.isLt, ?_⟩
    rw [card_inter_stdSet_succ S j.isLt, if_pos (by simpa using hj)]

/-- **The duality theorem.** For each index set `S`, there is *exactly one* subspace of `Kⁿ`
which is transverse for the pair of opposite flags and has jump set `S`, namely the
coordinate subspace `coord S`. This is the point-level form of the Schubert calculus
identity `σ_λ · σ_λᵛ = 1`. -/
theorem transverse_setOf_eq_singleton (S : Finset (Fin n)) :
    {W : Submodule K (Fin n → K) | IsTransverse W ∧
      (stdFlag K n).jumpSet W = S.image Fin.val} = {coord K S} := by
  ext W
  simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨hT, hJ⟩
    rw [transverse_eq_coord W hT]
    congr 1
    ext j
    simp only [jumpFinset, Finset.mem_filter, Finset.mem_univ, true_and, hJ,
      Finset.mem_image]
    constructor
    · rintro ⟨j', hj', hval⟩
      rwa [← Fin.ext hval]
    · intro hj
      exact ⟨j, hj, rfl⟩
  · rintro rfl
    exact ⟨transverse_coord S, jumpSet_coord S⟩


/-- **Completeness of the Schubert cell decomposition.** Every `k`-element set of jump
positions is realised: the Schubert cells of the standard flag are indexed exactly by the
`k`-element subsets of `{0, …, n-1}`. -/
theorem exists_subspace_with_jumpSet {S : Finset ℕ} (hS : S ⊆ Finset.range n) :
    ∃ W : Submodule K (Fin n → K),
      finrank K W = S.card ∧ (stdFlag K n).jumpSet W = S := by
  classical
  refine ⟨coord K (Finset.univ.filter fun j : Fin n => (j : ℕ) ∈ S), ?_, ?_⟩
  · rw [finrank_coord]
    have := congrArg Finset.card (image_val_filter_mem hS)
    rwa [Finset.card_image_of_injective _ Fin.val_injective] at this
  · rw [jumpSet_coord, image_val_filter_mem hS]

end SchubertCalculus