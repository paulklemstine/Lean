/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Adding an antichain to a `B_d`-free family, and strict monotonicity of `La`

This file continues the study of weak/strong `B_d`-free families begun in
`Catalog/Bridges/B3FreeFamilies.lean`, `…Bounds.lean` and `…Levels.lean`.

## Main results

* `weakFree_union_antichain`, `strongFree_union_antichain` — if `F` is weak (strong)
  `B_d`-free and `L` is an antichain, then `F ∪ L` is weak (strong) `B_(d+1)`-free.
  The proof produces, for every antichain `A` of `B_(d+1)`, an order embedding
  `B_d ↪ B_(d+1)` whose image avoids `A` (`liftUp`).
* `weakFree_of_not_hasChain`, `strongFree_of_not_hasChain` — a family of height at most
  `d` (no chain of `d + 1` sets) is weak `B_d`-free.  This generalizes `layers_weakFree`,
  and together with `not_hasChain_of_weakFree` brackets weak `B_d`-freeness between
  height `≤ d` and height `≤ 2^d − 1`.
* `weakFree_of_card_image_le` — a family realizing at most `d` distinct set sizes is weak
  `B_d`-free (no completeness or symmetry hypothesis, unlike `levelFamily_weakFree_iff`).
* `La_boolLat_lt_succ`, `LaStar_boolLat_lt_succ` — **strict monotonicity of `La(n, B_d)`
  and `La*(n, B_d)` in `d`, for every `n ≥ d`**, and `La_boolLat_lt_succ_iff`: strictness
  holds exactly when `d ≤ n`.  Previously strictness was known only for `n = d + 1`.
* `exists_not_weakFree_of_height_succ`, `exists_weakFree_hasChain` — both height
  thresholds are sharp: some family of height `d + 1` contains a copy of `B_d`, and some
  weak `B_d`-free family contains a chain of `2^d − 1` sets.
* `La_boolLat_add_le` — `La(n, B_d) + k ≤ La(n, B_(d+k))` for `d + k ≤ n + 1`.
* `La_succ_pigeonhole` — a quantitative form,
  `2^n + n · La(n, B_d) ≤ (n + 1) · La(n, B_(d+1))`, valid for all `n` and `d`.
-/

import Mathlib
import Catalog.Bridges.B3FreeFamilies
import Catalog.Bridges.B3FreeFamiliesBounds
import Catalog.Bridges.B3FreeFamiliesLevels

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## An order embedding `B_d ↪ B_(d+1)` avoiding a prescribed antichain -/

section Lift

variable {d : ℕ}

/-- `B_d` sits inside `B_(d+1)` as the subsets not containing the last atom. -/
def castLat (X : BoolLat d) : BoolLat (d + 1) := X.map Fin.castSuccEmb

theorem castLat_subset_iff {X Y : BoolLat d} : castLat X ⊆ castLat Y ↔ X ⊆ Y :=
  Finset.map_subset_map

theorem last_not_mem_castLat (X : BoolLat d) : Fin.last d ∉ castLat X := by
  simp only [castLat, Finset.mem_map]
  rintro ⟨i, -, hi⟩
  exact absurd hi (Fin.castSucc_lt_last i).ne

open scoped Classical in
/-- Given an upward-closed predicate `U` on `B_d`, the map sending `X` to `X` (viewed in
`B_(d+1)`), resp. to `X` together with the last atom when `U X` holds, is an order
embedding of `B_d` into `B_(d+1)`. -/
noncomputable def liftUp (U : BoolLat d → Prop) (X : BoolLat d) : BoolLat (d + 1) :=
  if U X then insert (Fin.last d) (castLat X) else castLat X

open scoped Classical in
theorem liftUp_subset_iff {U : BoolLat d → Prop} (hU : ∀ X Y : BoolLat d, X ⊆ Y → U X → U Y)
    {X Y : BoolLat d} : liftUp U X ⊆ liftUp U Y ↔ X ⊆ Y := by
  unfold liftUp
  by_cases hx : U X <;> by_cases hy : U Y <;> simp only [if_pos, hx, hy, if_false]
  · rw [Finset.insert_subset_iff]
    constructor
    · rintro ⟨-, h⟩
      exact castLat_subset_iff.1
        ((Finset.subset_insert_iff_of_notMem (last_not_mem_castLat X)).1 h)
    · intro h
      exact ⟨Finset.mem_insert_self _ _,
        (castLat_subset_iff.2 h).trans (Finset.subset_insert _ _)⟩
  · constructor
    · intro h
      exact absurd (h (Finset.mem_insert_self _ _)) (last_not_mem_castLat Y)
    · intro h
      exact absurd (hU X Y h hx) hy
  · rw [Finset.subset_insert_iff_of_notMem (last_not_mem_castLat X), castLat_subset_iff]
  · exact castLat_subset_iff

open scoped Classical in
theorem liftUp_injective {U : BoolLat d → Prop} (hU : ∀ X Y : BoolLat d, X ⊆ Y → U X → U Y) :
    Function.Injective (liftUp U) := by
  intro X Y hXY
  exact Finset.Subset.antisymm ((liftUp_subset_iff hU).1 hXY.subset)
    ((liftUp_subset_iff hU).1 hXY.symm.subset)

open scoped Classical in
theorem liftUp_lt_iff {U : BoolLat d → Prop} (hU : ∀ X Y : BoolLat d, X ⊆ Y → U X → U Y)
    {X Y : BoolLat d} : liftUp U X < liftUp U Y ↔ X < Y := by
  rw [Finset.lt_iff_ssubset, Finset.ssubset_iff_subset_ne, Finset.lt_iff_ssubset,
    Finset.ssubset_iff_subset_ne, liftUp_subset_iff hU]
  exact and_congr_right fun _ => not_congr ⟨fun h => liftUp_injective hU h, fun h => by rw [h]⟩

end Lift

/-! ## Enlarging a `B_d`-free family by an antichain -/

section UnionAntichain

variable {d : ℕ} {F L : Finset (Finset α)}

open scoped Classical in
omit [DecidableEq α] [Fintype α] in
/-- The upward closure of the sets of `B_d` whose image lands in the antichain. -/
private theorem liftUp_notMem_of_antichain {ι : BoolLat (d + 1) → Finset α}
    (hmono : ∀ p q : BoolLat (d + 1), p < q → ι p ⊂ ι q)
    (hL : IsAntichain (· ⊆ ·) (L : Set (Finset α)))
    (U : BoolLat d → Prop) (hUdef : ∀ Y, U Y ↔ ∃ Z ⊆ Y, ι (castLat Z) ∈ L)
    (X : BoolLat d) : ι (liftUp U X) ∉ L := by
  by_cases hx : U X
  · rw [liftUp, if_pos hx]
    intro hmemL
    obtain ⟨Z, hZX, hZ⟩ := (hUdef X).1 hx
    have hss : castLat Z < insert (Fin.last d) (castLat X) := by
      rw [Finset.lt_iff_ssubset, Finset.ssubset_iff_subset_ne]
      refine ⟨(castLat_subset_iff.2 hZX).trans (Finset.subset_insert _ _), fun hEq => ?_⟩
      exact last_not_mem_castLat Z (hEq ▸ Finset.mem_insert_self _ _)
    have hlt := hmono _ _ hss
    exact hL hZ hmemL hlt.ne hlt.subset
  · rw [liftUp, if_neg hx]
    intro hmemL
    exact hx ((hUdef X).2 ⟨X, Finset.Subset.refl X, hmemL⟩)

omit [Fintype α] in
/-- **Adding an antichain raises the dimension by at most one.**  If `F` is weak
`B_d`-free and `L` is an antichain, then `F ∪ L` is weak `B_(d+1)`-free. -/
theorem weakFree_union_antichain (hF : WeakFree F (BoolLat d))
    (hL : IsAntichain (· ⊆ ·) (L : Set (Finset α))) :
    WeakFree (F ∪ L) (BoolLat (d + 1)) := by
  classical
  rintro ⟨ι, ⟨hinj, hmono⟩, hmem⟩
  set U : BoolLat d → Prop := fun Y => ∃ Z ⊆ Y, ι (castLat Z) ∈ L with hUdef
  have hU : ∀ X Y : BoolLat d, X ⊆ Y → U X → U Y := by
    rintro X Y hXY ⟨Z, hZX, hZ⟩
    exact ⟨Z, hZX.trans hXY, hZ⟩
  have havoid : ∀ X : BoolLat d, ι (liftUp U X) ∉ L :=
    liftUp_notMem_of_antichain hmono hL U (fun _ => Iff.rfl)
  refine hF ⟨fun X => ι (liftUp U X), ⟨hinj.comp (liftUp_injective hU), fun p q hpq => ?_⟩,
    fun X => ?_⟩
  · exact hmono _ _ ((liftUp_lt_iff hU).2 hpq)
  · rcases Finset.mem_union.1 (hmem (liftUp U X)) with h | h
    · exact h
    · exact absurd h (havoid X)

omit [Fintype α] in
/-- The strong analogue: if `F` is strong `B_d`-free and `L` is an antichain, then
`F ∪ L` is strong `B_(d+1)`-free. -/
theorem strongFree_union_antichain (hF : StrongFree F (BoolLat d))
    (hL : IsAntichain (· ⊆ ·) (L : Set (Finset α))) :
    StrongFree (F ∪ L) (BoolLat (d + 1)) := by
  classical
  rintro ⟨ι, ⟨hinj, hstrong⟩, hmem⟩
  have hmono : ∀ p q : BoolLat (d + 1), p < q → ι p ⊂ ι q := fun p q hpq => (hstrong p q).2 hpq
  set U : BoolLat d → Prop := fun Y => ∃ Z ⊆ Y, ι (castLat Z) ∈ L with hUdef
  have hU : ∀ X Y : BoolLat d, X ⊆ Y → U X → U Y := by
    rintro X Y hXY ⟨Z, hZX, hZ⟩
    exact ⟨Z, hZX.trans hXY, hZ⟩
  have havoid : ∀ X : BoolLat d, ι (liftUp U X) ∉ L :=
    liftUp_notMem_of_antichain hmono hL U (fun _ => Iff.rfl)
  refine hF ⟨fun X => ι (liftUp U X), ⟨hinj.comp (liftUp_injective hU), fun p q => ?_⟩,
    fun X => ?_⟩
  · rw [hstrong, liftUp_lt_iff hU]
  · rcases Finset.mem_union.1 (hmem (liftUp U X)) with h | h
    · exact h
    · exact absurd h (havoid X)

end UnionAntichain

/-! ## Families of bounded height are `B_d`-free -/

section Height

variable {F : Finset (Finset α)}

omit [DecidableEq α] [Fintype α] in
theorem HasChain.mono {F G : Finset (Finset α)} {k : ℕ} (h : HasChain F k) (hFG : F ⊆ G) :
    HasChain G k := by
  obtain ⟨c, hc, hmem⟩ := h
  exact ⟨c, hc, fun i => hFG (hmem i)⟩

omit [DecidableEq α] [Fintype α] in
/-- A chain has pairwise distinct cardinalities. -/
theorem card_injective_of_chain {k : ℕ} {c : Fin k → Finset α} (hc : StrictMono c) :
    Function.Injective (fun i : Fin k => (c i).card) := by
  have hcard : ∀ i j : Fin k, i < j → (c i).card < (c j).card := fun i j hij =>
    Finset.card_lt_card (Finset.lt_iff_ssubset.1 (hc hij))
  intro i j hij
  by_contra hne
  rcases lt_or_gt_of_ne hne with h1 | h1
  · exact absurd hij (hcard i j h1).ne
  · exact absurd hij.symm (hcard j i h1).ne

/-- A chain in `F` minus its maximal sets extends by one maximal set. -/
theorem hasChain_succ_of_hasChain_sdiff_maxSets {k : ℕ}
    (h : HasChain (F \ maxSets F) (k + 1)) : HasChain F (k + 2) := by
  classical
  obtain ⟨c, hc, hmem⟩ := h
  have hlast := hmem (Fin.last k)
  rw [Finset.mem_sdiff] at hlast
  obtain ⟨B, hBmax, hAB⟩ := exists_maxSet_superset hlast.1
  have hne : c (Fin.last k) ≠ B := fun hEq => hlast.2 (hEq ▸ hBmax)
  have hssub : c (Fin.last k) ⊂ B := Finset.ssubset_iff_subset_ne.2 ⟨hAB, hne⟩
  refine ⟨fun i => if hi : (i : ℕ) ≤ k then c ⟨i, by omega⟩ else B, fun i j hij => ?_,
    fun i => ?_⟩
  · dsimp only
    by_cases hi : (i : ℕ) ≤ k <;> by_cases hj : (j : ℕ) ≤ k
    · rw [dif_pos hi, dif_pos hj]
      exact hc (Fin.mk_lt_mk.2 (Fin.lt_def.1 hij))
    · rw [dif_pos hi, dif_neg hj]
      have hle : (⟨i, by omega⟩ : Fin (k + 1)) ≤ Fin.last k := Fin.le_last _
      exact lt_of_le_of_lt (hc.monotone hle) (Finset.lt_iff_ssubset.2 hssub)
    · exfalso
      have h1 := i.isLt
      have h2 := j.isLt
      have h3 : (i : ℕ) < (j : ℕ) := hij
      omega
    · exfalso
      have h1 := i.isLt
      have h2 := j.isLt
      have h3 : (i : ℕ) < (j : ℕ) := hij
      omega
  · dsimp only
    by_cases hi : (i : ℕ) ≤ k
    · rw [dif_pos hi]
      exact (Finset.mem_sdiff.1 (hmem _)).1
    · rw [dif_neg hi]
      exact maxSets_subset F hBmax

/-- **Bounded height implies `B_d`-freeness.**  A family containing no chain of `d + 1`
sets is weak `B_d`-free.  This generalizes `layers_weakFree`: `d` consecutive layers form
a family of height `d`.  Together with `not_hasChain_of_weakFree` it sandwiches weak
`B_d`-freeness between height `≤ d` and height `≤ 2^d − 1`. -/
theorem weakFree_of_not_hasChain :
    ∀ {d : ℕ} {F : Finset (Finset α)}, ¬ HasChain F (d + 1) → WeakFree F (BoolLat d) := by
  intro d
  induction d with
  | zero =>
    intro F h
    have hempty : F = ∅ := by
      by_contra hne
      obtain ⟨A, hA⟩ : ∃ A, A ∈ F := Finset.nonempty_iff_ne_empty.2 hne
      refine h ⟨fun _ => A, fun i j hij => ?_, fun _ => hA⟩
      exfalso
      have hi := i.isLt
      have hj := j.isLt
      have hij' : (i : ℕ) < (j : ℕ) := hij
      omega
    rintro ⟨ι, -, hmem⟩
    have := hmem ∅
    rw [hempty] at this
    simp at this
  | succ k ih =>
    intro F h
    have hsub : ¬ HasChain (F \ maxSets F) (k + 1) := fun hc =>
      h (hasChain_succ_of_hasChain_sdiff_maxSets hc)
    have hfree := ih hsub
    have hunion := weakFree_union_antichain hfree (isAntichain_maxSets F)
    rwa [Finset.sdiff_union_of_subset (maxSets_subset F)] at hunion

/-- The strong analogue of `weakFree_of_not_hasChain`. -/
theorem strongFree_of_not_hasChain {d : ℕ} (h : ¬ HasChain F (d + 1)) :
    StrongFree F (BoolLat d) :=
  (weakFree_of_not_hasChain h).strongFree

/-- **Few sizes implies `B_d`-freeness.**  If the members of `F` realize at most `d`
distinct sizes, then `F` is weak `B_d`-free.  This drops the "level family" hypothesis of
`levelFamily_weakFree_of_card_le`: the family need not contain *all* sets of those
sizes, and need not be permutation invariant. -/
theorem weakFree_of_card_image_le {d : ℕ} (h : (F.image Finset.card).card ≤ d) :
    WeakFree F (BoolLat d) := by
  classical
  refine weakFree_of_not_hasChain ?_
  rintro ⟨c, hc, hmem⟩
  have hinj : Function.Injective (fun i : Fin (d + 1) => (c i).card) :=
    card_injective_of_chain hc
  have hsub : (Finset.univ : Finset (Fin (d + 1))).image (fun i => (c i).card)
      ⊆ F.image Finset.card := by
    intro m hm
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hm
    exact Finset.mem_image_of_mem _ (hmem i)
  have hle := Finset.card_le_card hsub
  rw [Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin] at hle
  omega

omit [DecidableEq α] [Fintype α] in
/-- The two chain criteria bracket weak `B_d`-freeness. -/
theorem hasChain_bracket {d : ℕ} (h : WeakFree F (BoolLat d)) :
    ¬ HasChain F (2 ^ d) :=
  not_hasChain_of_weakFree h

end Height

/-! ## Sharpness of the two height criteria

`weakFree_of_not_hasChain` says height `≤ d` forces weak `B_d`-freeness, and
`not_hasChain_of_weakFree` says weak `B_d`-freeness forces height `≤ 2^d − 1`.  Both
thresholds are attained: there is a family of height `d + 1` containing a weak copy of
`B_d`, and a weak `B_d`-free family containing a chain of `2^d − 1` sets.
-/

section Sharpness

/-- `k` consecutive layers have height exactly `k`. -/
theorem not_hasChain_layers (a k : ℕ) : ¬ HasChain (layers α a k) (k + 1) := by
  classical
  rintro ⟨c, hc, hmem⟩
  have hsub : (Finset.univ : Finset (Fin (k + 1))).image (fun i => (c i).card)
      ⊆ Finset.Ico a (a + k) := by
    intro m hm
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hm
    exact Finset.mem_Ico.2 (mem_layers.1 (hmem i))
  have hle := Finset.card_le_card hsub
  rw [Finset.card_image_of_injective _ (card_injective_of_chain hc), Finset.card_univ,
    Fintype.card_fin, Nat.card_Ico] at hle
  omega

/-- **The height criterion `weakFree_of_not_hasChain` is sharp**: as soon as the ground
set is large enough, some family of height `d + 1` contains a (strong, hence weak) copy
of `B_d`. -/
theorem exists_not_weakFree_of_height_succ {d : ℕ} (h : d ≤ Fintype.card α) :
    ∃ F : Finset (Finset α), ¬ HasChain F (d + 2) ∧ ¬ WeakFree F (BoolLat d) := by
  classical
  obtain ⟨ι, hι, hmem⟩ := exists_strongCopy_layers (α := α) (a := 0) (d := d) (by simpa using h)
  refine ⟨Finset.image ι Finset.univ, fun hchain => ?_, fun hfree => ?_⟩
  · exact not_hasChain_layers (α := α) 0 (d + 1)
      (hchain.mono (by
        intro A hA
        obtain ⟨X, -, rfl⟩ := Finset.mem_image.1 hA
        exact hmem X))
  · exact hfree ⟨ι, hι.isWeakCopy, fun X => Finset.mem_image_of_mem _ (Finset.mem_univ X)⟩

omit [DecidableEq α] [Fintype α] in
/-- A family with fewer than `2^d` members is weak `B_d`-free, simply because a copy of
`B_d` needs `2^d` distinct sets. -/
theorem weakFree_of_card_lt {d : ℕ} {F : Finset (Finset α)} (h : F.card < 2 ^ d) :
    WeakFree F (BoolLat d) := by
  classical
  rintro ⟨ι, ⟨hinj, -⟩, hmem⟩
  have hsub : Finset.image ι Finset.univ ⊆ F := by
    intro A hA
    obtain ⟨X, -, rfl⟩ := Finset.mem_image.1 hA
    exact hmem X
  have hcard := Finset.card_le_card hsub
  rw [Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_finset,
    Fintype.card_fin] at hcard
  omega

/-- A chain of `m` sets exists whenever `m ≤ n + 1`. -/
theorem exists_chain_family {m : ℕ} (h : m ≤ Fintype.card α + 1) :
    ∃ F : Finset (Finset α), F.card = m ∧ HasChain F m := by
  classical
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · exact ⟨∅, by simp, ⟨fun i => i.elim0, fun i => i.elim0, fun i => i.elim0⟩⟩
  obtain ⟨t, -, ht⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset α))
    (n := m - 1) (by simp; omega)
  obtain ⟨e⟩ : Nonempty (Fin (m - 1) ≃ (t : Finset α)) := ⟨(Finset.equivFinOfCardEq ht).symm⟩
  set f : Fin (m - 1) → α := fun i => (e i : α) with hf
  have hfinj : Function.Injective f := fun i j hij => e.injective (Subtype.ext hij)
  set c : Fin m → Finset α :=
    fun i => (Finset.univ.filter (fun j : Fin (m - 1) => (j : ℕ) < (i : ℕ))).image f with hc
  have hcmono : StrictMono c := by
    intro i j hij
    have hij' : (i : ℕ) < (j : ℕ) := hij
    have hilt : (i : ℕ) < m - 1 := by
      have := j.isLt
      omega
    rw [Finset.lt_iff_ssubset, Finset.ssubset_iff_subset_ne]
    constructor
    · intro A hA
      obtain ⟨l, hl, rfl⟩ := Finset.mem_image.1 hA
      rw [Finset.mem_filter] at hl
      exact Finset.mem_image_of_mem _ (Finset.mem_filter.2 ⟨Finset.mem_univ _, by omega⟩)
    · intro hEq
      have hmem : f ⟨(i : ℕ), hilt⟩ ∈ c j :=
        Finset.mem_image_of_mem _ (Finset.mem_filter.2 ⟨Finset.mem_univ _, hij'⟩)
      rw [← hEq] at hmem
      obtain ⟨l, hl, hfl⟩ := Finset.mem_image.1 hmem
      rw [Finset.mem_filter] at hl
      have hl' : (l : ℕ) = (i : ℕ) := congrArg Fin.val (hfinj hfl)
      omega
  refine ⟨Finset.image c Finset.univ, ?_, ⟨c, hcmono, fun i =>
    Finset.mem_image_of_mem _ (Finset.mem_univ i)⟩⟩
  rw [Finset.card_image_of_injective _ hcmono.injective, Finset.card_univ, Fintype.card_fin]

/-- **The chain bound `not_hasChain_of_weakFree` is sharp**: a chain of `2^d − 1` sets is
weak `B_d`-free, so weak `B_d`-free families of height `2^d − 1` exist as soon as the
ground set is large enough. -/
theorem exists_weakFree_hasChain {d : ℕ} (h : 2 ^ d ≤ Fintype.card α + 2) :
    ∃ F : Finset (Finset α), WeakFree F (BoolLat d) ∧ HasChain F (2 ^ d - 1) := by
  have hpos : 1 ≤ 2 ^ d := Nat.one_le_two_pow
  obtain ⟨F, hcard, hchain⟩ := exists_chain_family (α := α) (m := 2 ^ d - 1) (by omega)
  exact ⟨F, weakFree_of_card_lt (by omega), hchain⟩

end Sharpness

/-! ## Strict monotonicity of `La` in the poset -/

section Strict

variable {d : ℕ}

open scoped Classical in
/-- The extremal number is attained. -/
theorem exists_extremal_weakFree (d : ℕ) :
    ∃ F : Finset (Finset α), WeakFree F (BoolLat d) ∧ F.card = La α (BoolLat d) := by
  classical
  have hne : (((Finset.univ : Finset (Finset (Finset α)))).filter
      (fun F => WeakFree F (BoolLat d))).Nonempty := by
    refine ⟨∅, Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_⟩⟩
    rintro ⟨ι, -, hmem⟩
    simpa using hmem ∅
  obtain ⟨F, hF, hsup⟩ := Finset.exists_mem_eq_sup _ hne Finset.card
  exact ⟨F, (Finset.mem_filter.1 hF).2, hsup.symm⟩

open scoped Classical in
/-- The extremal number for strong copies is attained. -/
theorem exists_extremal_strongFree (d : ℕ) :
    ∃ F : Finset (Finset α), StrongFree F (BoolLat d) ∧ F.card = LaStar α (BoolLat d) := by
  classical
  have hne : (((Finset.univ : Finset (Finset (Finset α)))).filter
      (fun F => StrongFree F (BoolLat d))).Nonempty := by
    refine ⟨∅, Finset.mem_filter.2 ⟨Finset.mem_univ _, ?_⟩⟩
    rintro ⟨ι, -, hmem⟩
    simpa using hmem ∅
  obtain ⟨F, hF, hsup⟩ := Finset.exists_mem_eq_sup _ hne Finset.card
  exact ⟨F, (Finset.mem_filter.1 hF).2, hsup.symm⟩

omit [DecidableEq α] [Fintype α] in
theorem isAntichain_singleton (A : Finset α) :
    IsAntichain (· ⊆ ·) (({A} : Finset (Finset α)) : Set (Finset α)) := by
  simp

/-- **Strict monotonicity of `La(n, B_d)` in `d`.**  This settles, for every `n ≥ d`,
the strictness part of the monotonicity `La_boolLat_mono`. -/
theorem La_boolLat_lt_succ (h : d ≤ Fintype.card α) :
    La α (BoolLat d) < La α (BoolLat (d + 1)) := by
  classical
  obtain ⟨F, hF, hcard⟩ := exists_extremal_weakFree (α := α) d
  have hlt : F.card < 2 ^ Fintype.card α := hcard ▸ La_lt_two_pow (α := α) h
  have hne : F ≠ Finset.univ := by
    intro hEq
    rw [hEq] at hlt
    simp [Finset.card_univ] at hlt
  obtain ⟨A, -, hA⟩ := Finset.exists_of_ssubset
    (lt_of_le_of_ne (Finset.subset_univ F) hne)
  have hfree := weakFree_union_antichain hF (isAntichain_singleton A)
  have hcard2 : (F ∪ {A}).card = F.card + 1 := by
    rw [Finset.union_comm, Finset.singleton_union, Finset.card_insert_of_notMem hA]
  have := card_le_La hfree
  omega

/-- The strong analogue of `La_boolLat_lt_succ`. -/
theorem LaStar_boolLat_lt_succ (h : d ≤ Fintype.card α) :
    LaStar α (BoolLat d) < LaStar α (BoolLat (d + 1)) := by
  classical
  obtain ⟨F, hF, hcard⟩ := exists_extremal_strongFree (α := α) d
  have hlt : F.card < 2 ^ Fintype.card α := hcard ▸ LaStar_lt_two_pow (α := α) h
  have hne : F ≠ Finset.univ := by
    intro hEq
    rw [hEq] at hlt
    simp [Finset.card_univ] at hlt
  obtain ⟨A, -, hA⟩ := Finset.exists_of_ssubset
    (lt_of_le_of_ne (Finset.subset_univ F) hne)
  have hfree := strongFree_union_antichain hF (isAntichain_singleton A)
  have hcard2 : (F ∪ {A}).card = F.card + 1 := by
    rw [Finset.union_comm, Finset.singleton_union, Finset.card_insert_of_notMem hA]
  have := card_le_LaStar hfree
  omega

/-- **Exact criterion for strictness**: `La(n, B_d) < La(n, B_(d+1))` holds precisely when
`d ≤ n`; for `d > n` both extremal numbers equal `2^n`. -/
theorem La_boolLat_lt_succ_iff :
    La α (BoolLat d) < La α (BoolLat (d + 1)) ↔ d ≤ Fintype.card α := by
  refine ⟨fun h => ?_, La_boolLat_lt_succ⟩
  by_contra hd
  push_neg at hd
  rw [La_boolLat_eq_two_pow_of_lt hd, La_boolLat_eq_two_pow_of_lt (by omega)] at h
  exact lt_irrefl _ h

/-- Iterating strict monotonicity: `La(n, B_d) + k ≤ La(n, B_(d+k))`. -/
theorem La_boolLat_add_le {k : ℕ} (h : d + k ≤ Fintype.card α + 1) :
    La α (BoolLat d) + k ≤ La α (BoolLat (d + k)) := by
  induction k with
  | zero => simp
  | succ m ih =>
    have h1 : La α (BoolLat d) + m ≤ La α (BoolLat (d + m)) := ih (by omega)
    have h2 : La α (BoolLat (d + m)) < La α (BoolLat (d + m + 1)) :=
      La_boolLat_lt_succ (by omega)
    have : d + (m + 1) = d + m + 1 := by omega
    rw [this]
    omega

/-- For the poset of the paper: `La(n, B_3) < La(n, B_4)` for every `n ≥ 3`. -/
theorem La_boolLat3_lt_boolLat4 (h : 3 ≤ Fintype.card α) :
    La α (BoolLat 3) < La α (BoolLat 4) :=
  La_boolLat_lt_succ h

/-- For the poset of the paper: `La(n, B_2) < La(n, B_3)` for every `n ≥ 2`. -/
theorem La_boolLat2_lt_boolLat3 (h : 2 ≤ Fintype.card α) :
    La α (BoolLat 2) < La α (BoolLat 3) :=
  La_boolLat_lt_succ h

end Strict

/-! ## A quantitative form of the strictness -/

section Quantitative

variable {d : ℕ}

/-- A single layer of the complement of `F` is a large antichain disjoint from `F`. -/
theorem exists_antichain_disjoint (F : Finset (Finset α)) :
    ∃ L : Finset (Finset α), Disjoint F L ∧ IsAntichain (· ⊆ ·) (L : Set (Finset α)) ∧
      2 ^ Fintype.card α ≤ F.card + (Fintype.card α + 1) * L.card := by
  classical
  set n := Fintype.card α with hn
  set C : Finset (Finset α) := Finset.univ \ F with hC
  set fib : ℕ → Finset (Finset α) := fun i => C.filter (fun A => A.card = i) with hfib
  have hcardC : C.card = ∑ i ∈ Finset.range (n + 1), (fib i).card := by
    refine Finset.card_eq_sum_card_fiberwise ?_
    intro A hA
    rw [Finset.mem_coe, Finset.mem_range]
    have : A.card ≤ n := by
      simpa [hn] using Finset.card_le_card (Finset.subset_univ A)
    omega
  obtain ⟨i₀, hi₀, hi₀eq⟩ := Finset.exists_mem_eq_sup (Finset.range (n + 1))
    ⟨0, Finset.mem_range.2 (by omega)⟩ (fun i => (fib i).card)
  refine ⟨fib i₀, ?_, ?_, ?_⟩
  · refine Finset.disjoint_right.2 fun A hA hAF => ?_
    have := (Finset.mem_filter.1 hA).1
    rw [hC, Finset.mem_sdiff] at this
    exact this.2 hAF
  · intro A hA B hB hne hAB
    rw [Finset.mem_coe, hfib, Finset.mem_filter] at hA hB
    exact hne (Finset.eq_of_subset_of_card_le hAB (by omega))
  · have hsum : ∑ i ∈ Finset.range (n + 1), (fib i).card
        ≤ ∑ _i ∈ Finset.range (n + 1), (fib i₀).card := by
      refine Finset.sum_le_sum fun i hi => ?_
      calc (fib i).card ≤ (Finset.range (n + 1)).sup (fun j => (fib j).card) :=
            Finset.le_sup (f := fun j => (fib j).card) hi
        _ = (fib i₀).card := hi₀eq
    have hsum2 : ∑ _i ∈ Finset.range (n + 1), (fib i₀).card = (n + 1) * (fib i₀).card := by
      rw [Finset.sum_const, Finset.card_range, smul_eq_mul]
    have hCcard : C.card = 2 ^ n - F.card := by
      rw [hC, Finset.card_univ_diff, Fintype.card_finset, hn]
    have hFle : F.card ≤ 2 ^ n := by
      rw [← Fintype.card_finset (α := α), ← Finset.card_univ]
      exact Finset.card_le_card (Finset.subset_univ F)
    omega

/-- **Quantitative strict monotonicity.**  Adjoining the largest layer of the complement
of an extremal weak `B_d`-free family gives
`2^n + n · La(n, B_d) ≤ (n + 1) · La(n, B_(d+1))`, a strengthening of
`La_boolLat_lt_succ` that holds for every `n` and `d`. -/
theorem La_succ_pigeonhole (d : ℕ) :
    2 ^ Fintype.card α + Fintype.card α * La α (BoolLat d)
      ≤ (Fintype.card α + 1) * La α (BoolLat (d + 1)) := by
  classical
  obtain ⟨F, hF, hcard⟩ := exists_extremal_weakFree (α := α) d
  obtain ⟨L, hdisj, hanti, hbig⟩ := exists_antichain_disjoint (α := α) F
  have hfree := weakFree_union_antichain hF hanti
  have hunion : (F ∪ L).card = F.card + L.card := Finset.card_union_of_disjoint hdisj
  have hle : F.card + L.card ≤ La α (BoolLat (d + 1)) := hunion ▸ card_le_La hfree
  have hstep : (Fintype.card α + 1) * (F.card + L.card)
      ≤ (Fintype.card α + 1) * La α (BoolLat (d + 1)) := Nat.mul_le_mul_left _ hle
  calc 2 ^ Fintype.card α + Fintype.card α * La α (BoolLat d)
      = 2 ^ Fintype.card α + Fintype.card α * F.card := by rw [hcard]
    _ ≤ (F.card + (Fintype.card α + 1) * L.card) + Fintype.card α * F.card :=
        Nat.add_le_add_right hbig _
    _ = (Fintype.card α + 1) * (F.card + L.card) := by ring
    _ ≤ (Fintype.card α + 1) * La α (BoolLat (d + 1)) := hstep

/-- The quantitative strictness for the poset of the paper. -/
theorem La_boolLat3_lt_boolLat4_quantitative :
    2 ^ Fintype.card α + Fintype.card α * La α (BoolLat 3)
      ≤ (Fintype.card α + 1) * La α (BoolLat 4) :=
  La_succ_pigeonhole 3

/-- A crude but unconditional consequence: `(n + 1) · La(n, B_(d+1)) ≥ 2^n`. -/
theorem two_pow_le_mul_La_succ (d : ℕ) :
    2 ^ Fintype.card α ≤ (Fintype.card α + 1) * La α (BoolLat (d + 1)) :=
  le_trans (Nat.le_add_right _ _) (La_succ_pigeonhole d)

end Quantitative

end B3Free