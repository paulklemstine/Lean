import Mathlib

/-!
# Weakly `D_k`-free families in the Boolean lattice: core theory

This file develops, from scratch, the combinatorial core needed to analyse
*weakly `D_k`-free* families of subsets of `[n] = {0, …, n-1}`.

The `k`-diamond `D_k` is the poset with a bottom element `A`, a top element `C`
and `k` pairwise incomparable middle elements.  A family `F ⊆ 2^[n]` *weakly
contains* `D_k` if there are `A, C ∈ F` and `k` distinct sets `B₁, …, B_k ∈ F`
with `A ⊊ Bᵢ ⊊ C` for every `i` (no induced-ness is required: the `Bᵢ` may be
comparable with each other, whence the adjective *weak*).

The main results are:

* `WeakD6.card_openInterval` — the open interval `(A, C)` in `2^[n]` has exactly
  `2^(|C| - |A|) - 2` elements;
* `WeakD6.threeLayers_weaklyDiamondFree_three` — a family living in three
  consecutive layers is weakly `D₃`-free, hence (`WeakD6.weaklyDiamondFree_mono`)
  weakly `D₆`-free.  This is the classical baseline construction of size
  `≈ 3·C(n, ⌊n/2⌋)`;
* `WeakD6.fourLayer_weaklyD6Free_iff` — the *interval-exclusion criterion*: a
  family confined to **four** consecutive layers is weakly `D₆`-free **iff**
  every distance-`3` interval with both endpoints in the family misses at least
  one of its six interior sets.

The second bullet is the deterministic heart of the "three middle layers"
baseline; the third is the deterministic heart of any attempt to beat it, and is
used in `Physics.WeakD6AbelianNoGo` to obstruct labelling constructions.
-/

namespace WeakD6

open Finset

/-- The `k`-th layer of the Boolean lattice `2^[n]`. -/
def layer (n k : ℕ) : Finset (Finset ℕ) := (Finset.range n).powersetCard k

@[simp] lemma mem_layer {n k : ℕ} {S : Finset ℕ} :
    S ∈ layer n k ↔ S ⊆ Finset.range n ∧ S.card = k := by
  simp [layer, Finset.mem_powersetCard]

lemma card_layer (n k : ℕ) : (layer n k).card = n.choose k := by
  simp [layer, Finset.card_powersetCard]

/-- Layers are pairwise disjoint. -/
lemma layer_disjoint {n k l : ℕ} (h : k ≠ l) : Disjoint (layer n k) (layer n l) := by
  refine Finset.disjoint_left.2 ?_
  intro S hS hS'
  rw [mem_layer] at hS hS'
  exact h (hS.2 ▸ hS'.2 ▸ rfl)

/-- `F` weakly contains the `k`-diamond `D_k`. -/
def WeaklyContainsDiamond (k : ℕ) (F : Finset (Finset ℕ)) : Prop :=
  ∃ A ∈ F, ∃ C ∈ F, ∃ S : Finset (Finset ℕ),
    S ⊆ F ∧ S.card = k ∧ ∀ B ∈ S, A ⊂ B ∧ B ⊂ C

/-- `F` is weakly `D_k`-free. -/
def WeaklyDiamondFree (k : ℕ) (F : Finset (Finset ℕ)) : Prop := ¬ WeaklyContainsDiamond k F

/-- Weak containment is monotone in the number of middle elements. -/
lemma weaklyContainsDiamond_mono {k l : ℕ} (hkl : k ≤ l) {F : Finset (Finset ℕ)}
    (h : WeaklyContainsDiamond l F) : WeaklyContainsDiamond k F := by
  obtain ⟨A, hA, C, hC, S, hSF, hScard, hS⟩ := h
  obtain ⟨S', hS'S, hS'card⟩ := Finset.exists_subset_card_eq (by omega : k ≤ S.card)
  exact ⟨A, hA, C, hC, S', hS'S.trans hSF, hS'card, fun B hB => hS B (hS'S hB)⟩

/-- Weak freeness is antitone in the number of middle elements. -/
lemma weaklyDiamondFree_mono {k l : ℕ} (hkl : k ≤ l) {F : Finset (Finset ℕ)}
    (h : WeaklyDiamondFree k F) : WeaklyDiamondFree l F :=
  fun hl => h (weaklyContainsDiamond_mono hkl hl)

/-- The open interval `(A, C)` of the Boolean lattice, as a finite set. -/
def openInterval (A C : Finset ℕ) : Finset (Finset ℕ) :=
  C.powerset.filter (fun B => A ⊂ B ∧ B ⊂ C)

@[simp] lemma mem_openInterval {A C B : Finset ℕ} :
    B ∈ openInterval A C ↔ A ⊂ B ∧ B ⊂ C := by
  simp only [openInterval, Finset.mem_filter, Finset.mem_powerset]
  constructor
  · rintro ⟨-, h⟩; exact h
  · rintro ⟨h1, h2⟩; exact ⟨h2.1, h1, h2⟩

/-- **Interval size.** The open interval between `A ⊊ C` has exactly
`2 ^ (|C| - |A|) - 2` elements. -/
lemma card_openInterval {A C : Finset ℕ} (hAC : A ⊆ C) (hne : A ≠ C) :
    (openInterval A C).card = 2 ^ (C.card - A.card) - 2 := by
  classical
  have hdcard : (C \ A).card = C.card - A.card := Finset.card_sdiff_of_subset hAC
  have hCA_ne : C \ A ≠ ∅ := by
    intro h
    exact hne (Finset.Subset.antisymm hAC (Finset.sdiff_eq_empty_iff_subset.1 h))
  set T : Finset (Finset ℕ) := ((C \ A).powerset.erase ∅).erase (C \ A) with hT
  have hcardT : T.card = 2 ^ (C.card - A.card) - 2 := by
    have h1 : ((C \ A).powerset.erase ∅).card = 2 ^ (C \ A).card - 1 := by
      rw [Finset.card_erase_of_mem (Finset.empty_mem_powerset _), Finset.card_powerset]
    have h2 : (C \ A) ∈ (C \ A).powerset.erase ∅ := by
      refine Finset.mem_erase.2 ⟨hCA_ne, Finset.mem_powerset_self _⟩
    rw [hT, Finset.card_erase_of_mem h2, h1, hdcard]
    have : 1 ≤ 2 ^ (C.card - A.card) := Nat.one_le_two_pow
    omega
  rw [← hcardT]
  refine Finset.card_bij' (fun B _ => B \ A) (fun D _ => A ∪ D) ?_ ?_ ?_ ?_
  · intro B hB
    rw [mem_openInterval] at hB
    obtain ⟨hAB, hBC⟩ := hB
    refine Finset.mem_erase.2 ⟨?_, Finset.mem_erase.2 ⟨?_, ?_⟩⟩
    · -- `B \ A ≠ C \ A`
      intro h
      have hBeq : B = C := by
        have hAB' : A ⊆ B := hAB.1
        have h' : B \ A = C \ A := h
        have h2 : A ∪ (B \ A) = A ∪ (C \ A) := by rw [h']
        rwa [Finset.union_sdiff_of_subset hAB', Finset.union_sdiff_of_subset hAC] at h2
      exact hBC.2 (by rw [hBeq])
    · -- `B \ A ≠ ∅`
      intro h
      have : B ⊆ A := Finset.sdiff_eq_empty_iff_subset.1 h
      exact hAB.2 this
    · exact Finset.mem_powerset.2 (Finset.sdiff_subset_sdiff hBC.1 (le_refl A))
  · intro D hD
    rw [hT] at hD
    obtain ⟨hDne, hD'⟩ := Finset.mem_erase.1 hD
    obtain ⟨hDempty, hDsub⟩ := Finset.mem_erase.1 hD'
    rw [Finset.mem_powerset] at hDsub
    have hdisj : Disjoint A D :=
      Finset.disjoint_left.2 fun a ha haD => (Finset.mem_sdiff.1 (hDsub haD)).2 ha
    rw [mem_openInterval]
    constructor
    · refine ⟨Finset.subset_union_left, ?_⟩
      intro hsub
      apply hDempty
      have : D ⊆ A := (Finset.union_subset_iff.1 hsub).2
      exact Finset.eq_empty_iff_forall_notMem.2 fun a ha =>
        Finset.disjoint_left.1 hdisj (this ha) ha
    · constructor
      · exact Finset.union_subset hAC (hDsub.trans Finset.sdiff_subset)
      · intro hsub
        apply hDne
        refine Finset.Subset.antisymm hDsub ?_
        intro a ha
        obtain ⟨haC, haA⟩ := Finset.mem_sdiff.1 ha
        rcases Finset.mem_union.1 (hsub haC) with h | h
        · exact absurd h haA
        · exact h
  · intro B hB
    rw [mem_openInterval] at hB
    exact Finset.union_sdiff_of_subset hB.1.1
  · intro D hD
    rw [hT] at hD
    obtain ⟨-, hD'⟩ := Finset.mem_erase.1 hD
    obtain ⟨-, hDsub⟩ := Finset.mem_erase.1 hD'
    rw [Finset.mem_powerset] at hDsub
    have hdisj : Disjoint A D :=
      Finset.disjoint_left.2 fun a ha haD => (Finset.mem_sdiff.1 (hDsub haD)).2 ha
    exact Finset.union_sdiff_cancel_left hdisj

/-- If `A ⊊ B ⊊ C` then `A ⊆ C` and `|A| + 2 ≤ |C|`. -/
lemma card_lt_of_between {A B C : Finset ℕ} (h1 : A ⊂ B) (h2 : B ⊂ C) :
    A ⊆ C ∧ A.card + 2 ≤ C.card := by
  refine ⟨h1.1.trans h2.1, ?_⟩
  have := Finset.card_lt_card h1
  have := Finset.card_lt_card h2
  omega

/-- **Baseline (three middle layers).** A family confined to three consecutive
layers is weakly `D₃`-free: between two of its members there are at most two
sets of the family. -/
theorem threeLayers_weaklyDiamondFree_three (k : ℕ) (F : Finset (Finset ℕ))
    (hF : ∀ S ∈ F, k ≤ S.card ∧ S.card ≤ k + 2) :
    WeaklyDiamondFree 3 F := by
  rintro ⟨A, hA, C, hC, S, hSF, hScard, hS⟩
  have hSne : S.Nonempty := Finset.card_pos.1 (by omega)
  obtain ⟨B₀, hB₀⟩ := hSne
  obtain ⟨hAC, hcard⟩ := card_lt_of_between (hS B₀ hB₀).1 (hS B₀ hB₀).2
  have hA' := hF A hA
  have hC' := hF C hC
  have hne : A ≠ C := by
    intro h; rw [h] at hcard; omega
  have hsub : S ⊆ openInterval A C := by
    intro B hB
    exact mem_openInterval.2 (hS B hB)
  have hcards : S.card ≤ (openInterval A C).card := Finset.card_le_card hsub
  rw [card_openInterval hAC hne, hScard] at hcards
  have : C.card - A.card = 2 := by omega
  rw [this] at hcards
  norm_num at hcards

/-- The three middle layers, as an explicit family. -/
def threeLayerFamily (n k : ℕ) : Finset (Finset ℕ) :=
  layer n k ∪ layer n (k + 1) ∪ layer n (k + 2)

/-- The baseline family is weakly `D₆`-free. -/
theorem threeLayerFamily_weaklyD6Free (n k : ℕ) :
    WeaklyDiamondFree 6 (threeLayerFamily n k) := by
  refine weaklyDiamondFree_mono (by norm_num) (threeLayers_weaklyDiamondFree_three k _ ?_)
  intro S hS
  simp only [threeLayerFamily, Finset.mem_union, mem_layer] at hS
  rcases hS with (h | h) | h <;> omega

/-- The baseline family has exactly `C(n,k) + C(n,k+1) + C(n,k+2)` members. -/
theorem card_threeLayerFamily (n k : ℕ) :
    (threeLayerFamily n k).card = n.choose k + n.choose (k + 1) + n.choose (k + 2) := by
  classical
  have h1 : Disjoint (layer n k) (layer n (k + 1)) := layer_disjoint (by omega)
  have h2 : Disjoint (layer n k ∪ layer n (k + 1)) (layer n (k + 2)) := by
    refine Finset.disjoint_union_left.2 ⟨layer_disjoint (by omega), layer_disjoint (by omega)⟩
  rw [threeLayerFamily, Finset.card_union_of_disjoint h2, Finset.card_union_of_disjoint h1,
    card_layer, card_layer, card_layer]

/-- **Interval exclusion is sufficient.**  If every distance-`3` interval with
endpoints in `F` misses an interior set, then `F` (confined to four consecutive
layers) is weakly `D₆`-free. -/
theorem fourLayer_weaklyD6Free_of_exclusion (k : ℕ) (F : Finset (Finset ℕ))
    (hF : ∀ S ∈ F, k ≤ S.card ∧ S.card ≤ k + 3)
    (hex : ∀ A ∈ F, ∀ C ∈ F, A ⊆ C → C.card = A.card + 3 →
      ∃ B, A ⊂ B ∧ B ⊂ C ∧ B ∉ F) :
    WeaklyDiamondFree 6 F := by
  rintro ⟨A, hA, C, hC, S, hSF, hScard, hS⟩
  have hSne : S.Nonempty := Finset.card_pos.1 (by omega)
  obtain ⟨B₀, hB₀⟩ := hSne
  obtain ⟨hAC, hcard⟩ := card_lt_of_between (hS B₀ hB₀).1 (hS B₀ hB₀).2
  have hA' := hF A hA
  have hC' := hF C hC
  have hne : A ≠ C := by intro h; rw [h] at hcard; omega
  have hsub : S ⊆ openInterval A C := fun B hB => mem_openInterval.2 (hS B hB)
  have hcards := Finset.card_le_card hsub
  rw [card_openInterval hAC hne, hScard] at hcards
  -- the interval must have distance exactly `3`
  have hd : C.card - A.card = 3 := by
    rcases (show C.card - A.card = 2 ∨ C.card - A.card = 3 by omega) with h | h
    · rw [h] at hcards; norm_num at hcards
    · exact h
  have hC3 : C.card = A.card + 3 := by omega
  obtain ⟨B, hAB, hBC, hBF⟩ := hex A hA C hC hAC hC3
  -- the six middle sets exhaust the interval, so `B` belongs to `S ⊆ F`
  have hIcard : (openInterval A C).card = 6 := by
    rw [card_openInterval hAC hne, hd]; norm_num
  have : S = openInterval A C :=
    Finset.eq_of_subset_of_card_le hsub (by omega)
  exact hBF (hSF (this ▸ mem_openInterval.2 ⟨hAB, hBC⟩))

/-- **Interval exclusion is necessary.**  If `F` is weakly `D₆`-free then every
distance-`3` interval with endpoints in `F` misses one of its six interior sets. -/
theorem exclusion_of_weaklyD6Free {F : Finset (Finset ℕ)} (hfree : WeaklyDiamondFree 6 F)
    {A C : Finset ℕ} (hA : A ∈ F) (hC : C ∈ F) (hAC : A ⊆ C) (hcard : C.card = A.card + 3) :
    ∃ B, A ⊂ B ∧ B ⊂ C ∧ B ∉ F := by
  by_contra hcon
  push_neg at hcon
  have hne : A ≠ C := by intro h; rw [h] at hcard; omega
  refine hfree ⟨A, hA, C, hC, openInterval A C, ?_, ?_, ?_⟩
  · intro B hB
    rw [mem_openInterval] at hB
    exact hcon B hB.1 hB.2
  · rw [card_openInterval hAC hne, show C.card - A.card = 3 by omega]; norm_num
  · intro B hB; exact mem_openInterval.1 hB

/-- **Interval-exclusion criterion** (both directions). -/
theorem fourLayer_weaklyD6Free_iff (k : ℕ) (F : Finset (Finset ℕ))
    (hF : ∀ S ∈ F, k ≤ S.card ∧ S.card ≤ k + 3) :
    WeaklyDiamondFree 6 F ↔
      ∀ A ∈ F, ∀ C ∈ F, A ⊆ C → C.card = A.card + 3 → ∃ B, A ⊂ B ∧ B ⊂ C ∧ B ∉ F :=
  ⟨fun h _ hA _ hC hAC hcard => exclusion_of_weaklyD6Free h hA hC hAC hcard,
   fun h => fourLayer_weaklyD6Free_of_exclusion k F hF h⟩

end WeakD6