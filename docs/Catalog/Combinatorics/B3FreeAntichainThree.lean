/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The strong extremal number of the three-element antichain: `La*(n, A₃) = 2n`

`Catalog/Combinatorics/B3FreeWeakStrongGap.lean` computes `La*(n, A₂) = n + 1`: a strong
`A₂`-free family is a chain, and the longest chain in `2^[n]` has `n + 1` members.  The
next case is the first genuinely two-dimensional one.  A strong `A₃`-free family is a
family with **no three pairwise incomparable sets**; by Dilworth's theorem such a family is
a union of two chains, and the Greene–Kleitman philosophy predicts that the optimum is the
total length `(n + 1) + (n − 1)` of the two longest chains of a symmetric chain
decomposition.  We prove exactly that, and *without* invoking Dilworth or Greene–Kleitman:

* **Upper bound.**  Sets of equal size are pairwise incomparable, so a strong `A_m`-free
  family meets every layer in fewer than `m` sets (`card_filter_card_lt_of_strongFree`).
  For `m = 3` this gives at most `2` sets per layer, and the two extreme layers contain a
  single set each, whence `|F| ≤ 2 + 2(n − 1) = 2n`.
* **Lower bound.**  An explicit union of two chains of the right lengths: the `n + 1`
  initial segments and the `n − 1` complements of the *proper nonempty* initial segments.
  A union of two chains never contains three pairwise incomparable sets
  (`strongFree_three_of_union_chains`), and the two chains are disjoint
  (`disjoint_initialSegFamily_coInitialSegFamily`).

## Main result

* `LaStar_antiPoset_three` — `La*(n, A₃) = 2n` for every `n ≥ 1`.

Together with `LaStar_antiPoset_two` this confirms the Greene–Kleitman prediction
`La*(n, A_m) = Σ_{i<m−1}(n + 1 − 2i)` in the first two cases.
-/

import Mathlib
import Combinatorics.B3FreeWeakStrongGap

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Layer bound for strong antichain-free families -/

omit [DecidableEq α] [Fintype α] in
/-- Sets of a common size are pairwise incomparable, so a strong `A_m`-free family
contains fewer than `m` sets of any fixed size. -/
theorem card_filter_card_lt_of_strongFree {m i : ℕ} {F : Finset (Finset α)}
    (h : StrongFree F (AntiPoset m)) :
    (F.filter fun A => A.card = i).card < m := by
  classical
  by_contra hcon
  push_neg at hcon
  set G : Finset (Finset α) := F.filter (fun A => A.card = i) with hGdef
  have hle : Fintype.card (AntiPoset m) ≤ Fintype.card {B : Finset α // B ∈ G} := by
    simpa [AntiPoset.card, Fintype.card_coe] using hcon
  obtain ⟨g⟩ := Function.Embedding.nonempty_of_card_le hle
  refine h ⟨fun p => (g p : Finset α), ⟨fun p q hpq => g.injective (Subtype.ext hpq), ?_⟩, ?_⟩
  · intro p q
    refine iff_of_false ?_ (AntiPoset.not_lt p q)
    intro hss
    have h1 : ((g p : Finset α)).card = i := (Finset.mem_filter.1 (g p).2).2
    have h2 : ((g q : Finset α)).card = i := (Finset.mem_filter.1 (g q).2).2
    have h3 := Finset.card_lt_card hss
    dsimp only at h3
    omega
  · intro p
    exact (Finset.mem_filter.1 (g p).2).1

omit [DecidableEq α] [Fintype α] in
/-- The extreme layers of the cube contain a single set, so a strong `A₃`-free family
meets them in at most one set. -/
theorem card_filter_card_eq_zero_le_one {F : Finset (Finset α)} :
    (F.filter fun A => A.card = 0).card ≤ 1 := by
  refine Finset.card_le_one.2 fun A hA B hB => ?_
  rw [Finset.mem_filter, Finset.card_eq_zero] at hA hB
  rw [hA.2, hB.2]

omit [DecidableEq α] in
theorem card_filter_card_eq_card_le_one {F : Finset (Finset α)} :
    (F.filter fun A => A.card = Fintype.card α).card ≤ 1 := by
  refine Finset.card_le_one.2 fun A hA B hB => ?_
  rw [Finset.mem_filter, Finset.card_eq_iff_eq_univ] at hA hB
  rw [hA.2, hB.2]

omit [DecidableEq α] in
/-- **Upper bound**: a family without three pairwise incomparable sets has at most `2n`
members. -/
theorem card_le_two_mul_of_strongFree_three {F : Finset (Finset α)}
    (hn : 1 ≤ Fintype.card α) (h : StrongFree F (AntiPoset 3)) :
    F.card ≤ 2 * Fintype.card α := by
  classical
  obtain ⟨k, hk⟩ : ∃ k, Fintype.card α = k + 1 := ⟨Fintype.card α - 1, by omega⟩
  have hfib : F.card =
      ∑ i ∈ Finset.range (Fintype.card α + 1), (F.filter fun A => A.card = i).card :=
    Finset.card_eq_sum_card_fiberwise fun A _ =>
      Finset.mem_range.2 (Nat.lt_succ_of_le (Finset.card_le_univ A))
  set f : ℕ → ℕ := fun i => (F.filter fun A => A.card = i).card with hf
  have hle2 : ∀ i, f i ≤ 2 := fun i =>
    Nat.lt_succ_iff.1 (card_filter_card_lt_of_strongFree (i := i) h)
  have h0 : f 0 ≤ 1 := card_filter_card_eq_zero_le_one
  have htop : f (Fintype.card α) ≤ 1 := card_filter_card_eq_card_le_one
  have hsplit : ∑ i ∈ Finset.range (k + 2), f i
      = (∑ i ∈ Finset.range k, f (i + 1)) + f 0 + f (k + 1) := by
    rw [Finset.sum_range_succ, Finset.sum_range_succ']
  have hmid : ∑ i ∈ Finset.range k, f (i + 1) ≤ 2 * k := by
    calc ∑ i ∈ Finset.range k, f (i + 1)
        ≤ ∑ _i ∈ Finset.range k, 2 := Finset.sum_le_sum fun i _ => hle2 (i + 1)
      _ = 2 * k := by simp [Finset.sum_const, Nat.mul_comm]
  rw [hfib, hk] at *
  rw [hsplit]
  omega

/-! ## Two disjoint chains of total length `2n` -/

theorem mem_initialSeg {i : ℕ} {a : α} :
    a ∈ initialSeg α i ↔ ((Fintype.equivFin α) a : ℕ) < i := by
  simp [initialSeg]

/-- The complements of the proper nonempty initial segments: a chain of `n − 1` sets,
disjoint from the chain of initial segments. -/
noncomputable def coInitialSegFamily (α : Type*) [DecidableEq α] [Fintype α] :
    Finset (Finset α) :=
  (Finset.Ico 1 (Fintype.card α)).image fun i => (initialSeg α i)ᶜ

theorem coInitialSeg_subset {i j : ℕ} (h : i ≤ j) :
    (initialSeg α j)ᶜ ⊆ (initialSeg α i)ᶜ :=
  Finset.compl_subset_compl.2 (initialSeg_subset h)

theorem coInitialSeg_ne {i j : ℕ} (hij : i < j) (hi : i < Fintype.card α) :
    (initialSeg α i)ᶜ ≠ (initialSeg α j)ᶜ := by
  intro hEq
  have hmem : (Fintype.equivFin α).symm ⟨i, hi⟩ ∈ (initialSeg α i)ᶜ := by
    simp [Finset.mem_compl, mem_initialSeg]
  rw [hEq, Finset.mem_compl, mem_initialSeg] at hmem
  simp only [Equiv.apply_symm_apply] at hmem
  exact hmem hij

theorem card_coInitialSegFamily :
    (coInitialSegFamily α).card = Fintype.card α - 1 := by
  rw [coInitialSegFamily, Finset.card_image_of_injOn, Nat.card_Ico]
  intro i hi j hj hij
  simp only [Finset.coe_Ico, Set.mem_Ico] at hi hj
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · exact coInitialSeg_ne h hi.2 hij
  · exact coInitialSeg_ne h hj.2 hij.symm

/-- Every nonempty initial segment contains the first element of the enumeration, whereas
no complemented initial segment `(initialSeg α i)ᶜ` with `i ≥ 1` does. -/
theorem disjoint_initialSegFamily_coInitialSegFamily :
    Disjoint (initialSegFamily α) (coInitialSegFamily α) := by
  refine Finset.disjoint_left.2 fun A hA hA' => ?_
  simp only [initialSegFamily, coInitialSegFamily, Finset.mem_image, Finset.mem_range,
    Finset.mem_Ico] at hA hA'
  obtain ⟨j, -, rfl⟩ := hA
  obtain ⟨i, ⟨hi1, hi2⟩, hEq⟩ := hA'
  have hpos : 0 < Fintype.card α := lt_of_le_of_lt (Nat.zero_le i) hi2
  -- the last element of the enumeration lies in `(initialSeg α i)ᶜ`, hence in `initialSeg α j`
  have hlast : (Fintype.equivFin α).symm ⟨Fintype.card α - 1, by omega⟩ ∈ (initialSeg α i)ᶜ := by
    simp only [Finset.mem_compl, mem_initialSeg, Equiv.apply_symm_apply, not_lt]
    omega
  rw [hEq, mem_initialSeg] at hlast
  simp only [Equiv.apply_symm_apply] at hlast
  -- hence `j ≥ 1`, so the first element lies in `initialSeg α j` but not in `(initialSeg α i)ᶜ`
  have hj1 : 1 ≤ j := by omega
  have hfirst : (Fintype.equivFin α).symm ⟨0, hpos⟩ ∈ initialSeg α j := by
    simp only [mem_initialSeg, Equiv.apply_symm_apply]
    omega
  rw [← hEq, Finset.mem_compl, mem_initialSeg] at hfirst
  simp only [Equiv.apply_symm_apply] at hfirst
  exact hfirst (by omega)

/-! ## A union of two chains has no three pairwise incomparable sets -/

/-- The three elements of the three-element antichain. -/
def y0 : AntiPoset 3 := (0 : Fin 3)

/-- The second element of the three-element antichain. -/
def y1 : AntiPoset 3 := (1 : Fin 3)

/-- The third element of the three-element antichain. -/
def y2 : AntiPoset 3 := (2 : Fin 3)

omit [Fintype α] in
/-- **Pigeonhole**: any three members of a union of two chains contain two comparable ones,
so the union is strong `A₃`-free. -/
theorem strongFree_three_of_union_chains {C₁ C₂ : Finset (Finset α)}
    (h₁ : ∀ A ∈ C₁, ∀ B ∈ C₁, A ⊆ B ∨ B ⊆ A)
    (h₂ : ∀ A ∈ C₂, ∀ B ∈ C₂, A ⊆ B ∨ B ⊆ A) :
    StrongFree (C₁ ∪ C₂) (AntiPoset 3) := by
  classical
  rintro ⟨ι, ⟨hinj, hstr⟩, hmem⟩
  have key : ∀ p q : AntiPoset 3, p ≠ q → ∀ C : Finset (Finset α),
      (∀ A ∈ C, ∀ B ∈ C, A ⊆ B ∨ B ⊆ A) → ι p ∈ C → ι q ∈ C → False := by
    intro p q hpq C hC hp hq
    have hne : ι p ≠ ι q := fun hEq => hpq (hinj hEq)
    rcases hC _ hp _ hq with hsub | hsub
    · exact AntiPoset.not_lt p q ((hstr p q).1 (Finset.ssubset_iff_subset_ne.2 ⟨hsub, hne⟩))
    · exact AntiPoset.not_lt q p ((hstr q p).1 (Finset.ssubset_iff_subset_ne.2 ⟨hsub, hne.symm⟩))
  have m0 := Finset.mem_union.1 (hmem y0)
  have m1 := Finset.mem_union.1 (hmem y1)
  have m2 := Finset.mem_union.1 (hmem y2)
  rcases m0 with h0 | h0 <;> rcases m1 with h1 | h1 <;> rcases m2 with h2 | h2
  · exact key y0 y1 (by decide) C₁ h₁ h0 h1
  · exact key y0 y1 (by decide) C₁ h₁ h0 h1
  · exact key y0 y2 (by decide) C₁ h₁ h0 h2
  · exact key y1 y2 (by decide) C₂ h₂ h1 h2
  · exact key y1 y2 (by decide) C₁ h₁ h1 h2
  · exact key y0 y2 (by decide) C₂ h₂ h0 h2
  · exact key y0 y1 (by decide) C₂ h₂ h0 h1
  · exact key y0 y1 (by decide) C₂ h₂ h0 h1

theorem initialSegFamily_isChain :
    ∀ A ∈ initialSegFamily α, ∀ B ∈ initialSegFamily α, A ⊆ B ∨ B ⊆ A := by
  intro A hA B hB
  simp only [initialSegFamily, Finset.mem_image, Finset.mem_range] at hA hB
  obtain ⟨i, -, rfl⟩ := hA
  obtain ⟨j, -, rfl⟩ := hB
  rcases le_total i j with h | h
  · exact Or.inl (initialSeg_subset h)
  · exact Or.inr (initialSeg_subset h)

theorem coInitialSegFamily_isChain :
    ∀ A ∈ coInitialSegFamily α, ∀ B ∈ coInitialSegFamily α, A ⊆ B ∨ B ⊆ A := by
  intro A hA B hB
  simp only [coInitialSegFamily, Finset.mem_image, Finset.mem_Ico] at hA hB
  obtain ⟨i, -, rfl⟩ := hA
  obtain ⟨j, -, rfl⟩ := hB
  rcases le_total i j with h | h
  · exact Or.inr (coInitialSeg_subset h)
  · exact Or.inl (coInitialSeg_subset h)


/-! ## A general layer bound for all antichains -/

omit [DecidableEq α] in
/-- Every layer of the cube has `C(n, i)` members, so a strong `A_m`-free family meets
layer `i` in at most `min (m − 1) C(n, i)` sets. -/
theorem card_filter_card_le_choose {i : ℕ} {F : Finset (Finset α)} :
    (F.filter fun A => A.card = i).card ≤ (Fintype.card α).choose i := by
  classical
  have hsub : (F.filter fun A => A.card = i) ⊆ Finset.powersetCard i Finset.univ := by
    intro A hA
    rw [Finset.mem_filter] at hA
    exact Finset.mem_powersetCard.2 ⟨Finset.subset_univ _, hA.2⟩
  calc (F.filter fun A => A.card = i).card
      ≤ (Finset.powersetCard i (Finset.univ : Finset α)).card := Finset.card_le_card hsub
    _ = (Fintype.card α).choose i := by
        rw [Finset.card_powersetCard, Finset.card_univ]

/-- **General upper bound for antichains**: a family of subsets of an `n`-set with no `m`
pairwise incomparable members has at most `Σ_i min (m − 1) C(n, i)` members.  For `m = 2`
this is `n + 1` and for `m = 3` it is `2n`, both of which are attained
(`LaStar_antiPoset_two`, `LaStar_antiPoset_three`). -/
theorem LaStar_antiPoset_le_sum_min {m : ℕ} :
    LaStar α (AntiPoset m) ≤
      ∑ i ∈ Finset.range (Fintype.card α + 1), min (m - 1) ((Fintype.card α).choose i) := by
  classical
  refine Finset.sup_le fun F hF => ?_
  rw [Finset.mem_filter] at hF
  have hfib : F.card =
      ∑ i ∈ Finset.range (Fintype.card α + 1), (F.filter fun A => A.card = i).card :=
    Finset.card_eq_sum_card_fiberwise fun A _ =>
      Finset.mem_range.2 (Nat.lt_succ_of_le (Finset.card_le_univ A))
  rw [hfib]
  refine Finset.sum_le_sum fun i _ => le_min ?_ card_filter_card_le_choose
  have := card_filter_card_lt_of_strongFree (i := i) hF.2
  omega

/-! ## The exact value -/

/-- **`La*(n, A₃) = 2n`**: the maximum size of a family of subsets of an `n`-set with no
three pairwise incomparable members is `2n`, attained by the union of the chain of initial
segments with the chain of complements of the proper nonempty initial segments. -/
theorem LaStar_antiPoset_three (hn : 1 ≤ Fintype.card α) :
    LaStar α (AntiPoset 3) = 2 * Fintype.card α := by
  classical
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    exact card_le_two_mul_of_strongFree_three hn hF.2
  · have hfree : StrongFree (initialSegFamily α ∪ coInitialSegFamily α) (AntiPoset 3) :=
      strongFree_three_of_union_chains initialSegFamily_isChain coInitialSegFamily_isChain
    have hcard : (initialSegFamily α ∪ coInitialSegFamily α).card = 2 * Fintype.card α := by
      rw [Finset.card_union_of_disjoint disjoint_initialSegFamily_coInitialSegFamily,
        card_initialSegFamily, card_coInitialSegFamily]
      omega
    have := card_le_LaStar hfree
    omega

/-- The Greene–Kleitman prediction `La*(n, A_m) = Σ_{i<m−1}(n + 1 − 2i)` holds for
`m = 2, 3`: the two values are `n + 1` and `(n + 1) + (n − 1) = 2n`. -/
theorem LaStar_antiPoset_three_eq_sum_two_longest_chains (hn : 1 ≤ Fintype.card α) :
    LaStar α (AntiPoset 3)
      = LaStar α (AntiPoset 2) + (Fintype.card α - 1) := by
  rw [LaStar_antiPoset_three hn, LaStar_antiPoset_two]
  omega

end B3Free