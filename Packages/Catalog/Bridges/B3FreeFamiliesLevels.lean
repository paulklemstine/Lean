/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Level (size-determined) families and the exact level-restricted extremal number

This file continues `Catalog/Bridges/B3FreeFamilies.lean` and
`Catalog/Bridges/B3FreeFamiliesBounds.lean`, which set up the framework of weak/strong
`P`-free families surrounding the paper *On the maximum size of `B_3`-free families*.

The paper's headline result is that `La(n, B_3) ≥ (3 + ε) C(n, ⌊n/2⌋)` for some absolute
`ε > 0`, i.e. that the three-layer construction is *not* optimal.  Here we prove a
complementary structural statement: **no improvement at all can come from a family that is
determined by the sizes of its sets** — equivalently, from a family invariant under the
permutations of the ground set.  Among all such families the `d` central layers are exactly
optimal.

## Main results

* `levelFamily` — the family of all subsets whose size lies in a prescribed set `S` of
  levels, and `card_levelFamily : |𝓛(S)| = ∑_{i ∈ S} C(n, i)`.
* `exists_strongCopy_levelFamily` — if `S` contains `d + 1` levels that are realized in
  `2^[n]`, then `𝓛(S)` contains a *strong* copy of `B_d`.  The levels need **not** be
  consecutive; this generalizes `exists_strongCopy_layers`.
* `levelFamily_weakFree_iff`, `levelFamily_strongFree_iff` — `𝓛(S)` is weak (strong)
  `B_d`-free **iff** at most `d` levels of `S` are realized.
* `sum_choose_le_sum_choose_window` — for a unimodal binomial row, any `d` levels have total
  weight at most that of `d` consecutive levels around the middle.
* `card_levelFamily_le_layers`, `level_extremal` — **exact level-restricted
  extremal number**: a weak `B_d`-free level family has at most `|layers α a d|` sets, for
  the central window `a`, and this is attained.
* `symmetric_weakFree_card_le`, `symmetric_weakFree_card_le_mul` — the same bound for every
  permutation-invariant weak `B_d`-free family, and the clean corollary
  `|F| ≤ d · C(n, ⌊n/2⌋)`: the `ε`-improvement of the paper must break the symmetry of the
  cube.
* `La_boolLat_eq_two_pow_of_lt`, `LaStar_boolLat_eq_two_pow_of_lt` — the degenerate range
  `n < d`, where the whole power set is `B_d`-free.
* `strongFree_boolLatOne_iff`, `LaStar_boolLatOne_eq` — Sperner's theorem also for the
  strong extremal function, `La*(n, B_1) = C(n, ⌊n/2⌋)`.
-/

import Mathlib
import Catalog.Bridges.B3FreeFamilies

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Level families -/

/-- The family of all subsets of `α` whose size lies in `S`. -/
def levelFamily (α : Type*) [Fintype α] [DecidableEq α] (S : Finset ℕ) : Finset (Finset α) :=
  {A : Finset α | A.card ∈ S}

theorem mem_levelFamily {S : Finset ℕ} {A : Finset α} :
    A ∈ levelFamily α S ↔ A.card ∈ S := by
  simp [levelFamily]

theorem levelFamily_mono {S T : Finset ℕ} (h : S ⊆ T) : levelFamily α S ⊆ levelFamily α T := by
  intro A hA
  rw [mem_levelFamily] at hA ⊢
  exact h hA

/-- `k` consecutive layers form the level family of an interval of levels. -/
theorem layers_eq_levelFamily (a k : ℕ) :
    layers α a k = levelFamily α (Finset.Ico a (a + k)) := by
  ext A
  simp [mem_layers, mem_levelFamily, Finset.mem_Ico]

/-- The size of a level family is the corresponding sum of binomial coefficients.  Levels
above `n` contribute `0`, so no truncation of `S` is needed. -/
theorem card_levelFamily (S : Finset ℕ) :
    (levelFamily α S).card = ∑ i ∈ S, (Fintype.card α).choose i := by
  classical
  have hEq : levelFamily α S = S.biUnion (fun i => Finset.powersetCard i Finset.univ) := by
    ext A
    simp only [mem_levelFamily, Finset.mem_biUnion, Finset.mem_powersetCard]
    constructor
    · exact fun h => ⟨A.card, h, Finset.subset_univ _, rfl⟩
    · rintro ⟨i, hi, -, rfl⟩
      exact hi
  rw [hEq, Finset.card_biUnion]
  · refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.card_powersetCard, Finset.card_univ]
  · intro i _ j _ hij
    refine Finset.disjoint_left.2 fun A hA hA' => ?_
    rw [Finset.mem_powersetCard] at hA hA'
    exact hij (hA.2 ▸ hA'.2 ▸ rfl)

/-! ## A weak copy of `B_d` realizes `d + 1` distinct levels -/

omit [DecidableEq α] [Fintype α] in
/-- A weak copy of `B_d` contains sets of `d + 1` distinct sizes. -/
theorem exists_card_image_of_isWeakCopy {d : ℕ} {ι : BoolLat d → Finset α}
    (h : IsWeakCopy ι) :
    ∃ T : Finset ℕ, T.card = d + 1 ∧ ∀ m ∈ T, ∃ X : BoolLat d, (ι X).card = m := by
  classical
  set S : ℕ → BoolLat d := fun k => Finset.univ.filter (fun i : Fin d => (i : ℕ) < k) with hS
  have hchain : ∀ k, k < d → S k < S (k + 1) := by
    intro k hk
    refine lt_of_le_of_ne ?_ ?_
    · intro i hi
      simp only [hS, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
      omega
    · intro hEq
      have : (⟨k, hk⟩ : Fin d) ∈ S (k + 1) := by simp [hS]
      rw [← hEq] at this
      simp [hS] at this
  have hmono : ∀ j k, j ≤ k → k ≤ d → (ι (S j)).card + (k - j) ≤ (ι (S k)).card := by
    intro j k hjk
    induction k with
    | zero => intro _; simp_all
    | succ m ih =>
      intro hm
      rcases Nat.lt_or_ge j (m + 1) with hlt | hge
      · have h1 := ih (by omega) (by omega)
        have h2 : ι (S m) ⊂ ι (S (m + 1)) := h.2 _ _ (hchain m (by omega))
        have h3 := Finset.card_lt_card h2
        omega
      · have : j = m + 1 := by omega
        subst this
        simp
  refine ⟨(Finset.range (d + 1)).image (fun k => (ι (S k)).card), ?_, ?_⟩
  · rw [Finset.card_image_of_injOn, Finset.card_range]
    intro j hj k hk hjk
    simp only [Finset.coe_range, Set.mem_Iio] at hj hk
    have hjk' : (ι (S j)).card = (ι (S k)).card := hjk
    by_contra hne
    rcases Nat.lt_or_ge j k with hlt | hge
    · have := hmono j k (le_of_lt hlt) (by omega)
      omega
    · have hlt : k < j := by omega
      have := hmono k j (le_of_lt hlt) (by omega)
      omega
  · intro m hm
    obtain ⟨k, -, rfl⟩ := Finset.mem_image.1 hm
    exact ⟨S k, rfl⟩

/-- **At most `d` levels are weak `B_d`-free.** -/
theorem levelFamily_weakFree_of_card_le {d : ℕ} {S : Finset ℕ} (hS : S.card ≤ d) :
    WeakFree (levelFamily α S) (BoolLat d) := by
  classical
  rintro ⟨ι, hι, hmem⟩
  obtain ⟨T, hTcard, hT⟩ := exists_card_image_of_isWeakCopy hι
  have hsub : T ⊆ S := by
    intro m hm
    obtain ⟨X, rfl⟩ := hT m hm
    exact mem_levelFamily.1 (hmem X)
  have := Finset.card_le_card hsub
  omega

/-! ## A strong copy of `B_d` spread over `d + 1` arbitrary levels -/

section Construction

variable {d : ℕ}

/-- The combinatorial index gadget: for `X ⊆ Fin d` the set of positions
`X ∪ [d, d + (t |X| - |X|))` inside `ℕ`, where `t` lists the target levels. -/
private def idxSet (d : ℕ) (t : ℕ → ℕ) (X : BoolLat d) : Finset ℕ :=
  X.image Fin.val ∪ Finset.Ico d (d + (t X.card - X.card))

private theorem mem_idxSet {t : ℕ → ℕ} {X : BoolLat d} {m : ℕ} :
    m ∈ idxSet d t X ↔ ((∃ i ∈ X, (i : ℕ) = m) ∨ (d ≤ m ∧ m < d + (t X.card - X.card))) := by
  simp [idxSet, Finset.mem_union, Finset.mem_image, Finset.mem_Ico, and_comm]

private theorem card_idxSet {t : ℕ → ℕ} (ht : ∀ k ≤ d, k ≤ t k) (X : BoolLat d) :
    (idxSet d t X).card = t X.card := by
  classical
  have hXcard : X.card ≤ d := by simpa using Finset.card_le_card (Finset.subset_univ X)
  have hdisj : Disjoint (X.image Fin.val) (Finset.Ico d (d + (t X.card - X.card))) := by
    refine Finset.disjoint_left.2 fun m hm hm' => ?_
    obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hm
    rw [Finset.mem_Ico] at hm'
    exact absurd hm'.1 (by omega)
  rw [idxSet, Finset.card_union_of_disjoint hdisj,
    Finset.card_image_of_injective _ Fin.val_injective, Nat.card_Ico]
  have := ht X.card hXcard
  omega

private theorem idxSet_subset_of_subset {t : ℕ → ℕ} (hmono : ∀ j k, j ≤ k → k ≤ d →
    t j - j ≤ t k - k) {X Y : BoolLat d} (hXY : X ⊆ Y) : idxSet d t X ⊆ idxSet d t Y := by
  intro m hm
  have hYcard : Y.card ≤ d := by simpa using Finset.card_le_card (Finset.subset_univ Y)
  rw [mem_idxSet] at hm ⊢
  rcases hm with ⟨i, hi, rfl⟩ | ⟨h1, h2⟩
  · exact Or.inl ⟨i, hXY hi, rfl⟩
  · refine Or.inr ⟨h1, ?_⟩
    have := hmono X.card Y.card (Finset.card_le_card hXY) hYcard
    omega

private theorem idxSet_not_subset_of_not_subset {t : ℕ → ℕ} {X Y : BoolLat d}
    (hXY : ¬ X ⊆ Y) : ¬ idxSet d t X ⊆ idxSet d t Y := by
  obtain ⟨i, hiX, hiY⟩ := Finset.not_subset.1 hXY
  intro hsub
  have hm : (i : ℕ) ∈ idxSet d t X := mem_idxSet.2 (Or.inl ⟨i, hiX, rfl⟩)
  rcases mem_idxSet.1 (hsub hm) with ⟨j, hj, hji⟩ | ⟨h1, -⟩
  · exact hiY (Fin.val_injective hji ▸ hj)
  · exact absurd i.2 (by omega)

end Construction

omit [DecidableEq α] in
/-- **Strong copies over arbitrary levels.**  If `t 0 < t 1 < ⋯ < t d ≤ n` are `d + 1`
levels, then the sets of these levels contain a strong copy of `B_d` whose element of rank
`k` has size exactly `t k`.  For `t k = a + k` this is `exists_strongCopy_layers`. -/
theorem exists_strongCopy_of_levels {d : ℕ} (t : ℕ → ℕ)
    (hstep : ∀ k < d, t k < t (k + 1)) (hlast : t d ≤ Fintype.card α) :
    ∃ ι : BoolLat d → Finset α, IsStrongCopy ι ∧ ∀ X : BoolLat d, (ι X).card = t X.card := by
  classical
  -- monotonicity consequences of the strict step condition
  have hmono : ∀ j k, j ≤ k → k ≤ d → t j - j ≤ t k - k := by
    intro j k hjk hkd
    induction k with
    | zero => simp_all
    | succ m ih =>
      rcases Nat.lt_or_ge j (m + 1) with hlt | hge
      · have h1 := ih (by omega) (by omega)
        have h2 := hstep m (by omega)
        omega
      · have : j = m + 1 := by omega
        subst this; exact le_rfl
  have hge : ∀ k ≤ d, k ≤ t k := by
    intro k hk
    induction k with
    | zero => exact Nat.zero_le _
    | succ m ih =>
      have h1 := ih (by omega)
      have h2 := hstep m (by omega)
      omega
  have hdle : d ≤ Fintype.card α := le_trans (hge d le_rfl) hlast
  -- the index sets live inside `range n`
  have hlt : ∀ X : BoolLat d, ∀ m ∈ idxSet d t X, m < Fintype.card α := by
    intro X m hm
    have hXcard : X.card ≤ d := by simpa using Finset.card_le_card (Finset.subset_univ X)
    have hXle : t X.card - X.card ≤ t d - d := hmono X.card d hXcard le_rfl
    rw [mem_idxSet] at hm
    rcases hm with ⟨i, -, rfl⟩ | ⟨-, h2⟩
    · exact lt_of_lt_of_le i.2 hdle
    · have := hge d le_rfl
      omega
  set σ := Fintype.equivFin α with hσ
  set ι : BoolLat d → Finset α :=
    fun X => Finset.univ.filter (fun a : α => (σ a : ℕ) ∈ idxSet d t X) with hι
  -- transferring subset relations
  have hsub : ∀ X Y : BoolLat d, ι X ⊆ ι Y ↔ idxSet d t X ⊆ idxSet d t Y := by
    intro X Y
    constructor
    · intro h m hm
      have hmlt : m < Fintype.card α := hlt X m hm
      have : σ.symm ⟨m, hmlt⟩ ∈ ι X := by
        simp only [hι, Finset.mem_filter, Finset.mem_univ, true_and, Equiv.apply_symm_apply]
        exact hm
      have := h this
      simpa [hι, Equiv.apply_symm_apply] using this
    · intro h a ha
      simp only [hι, Finset.mem_filter, Finset.mem_univ, true_and] at ha ⊢
      exact h ha
  have hcard : ∀ X : BoolLat d, (ι X).card = (idxSet d t X).card := by
    intro X
    refine Finset.card_bij (fun a _ => (σ a : ℕ)) ?_ ?_ ?_
    · intro a ha
      simpa [hι] using ha
    · intro a ha b hb hab
      exact σ.injective (Fin.val_injective hab)
    · intro m hm
      refine ⟨σ.symm ⟨m, hlt X m hm⟩, ?_, by simp⟩
      simp only [hι, Finset.mem_filter, Finset.mem_univ, true_and, Equiv.apply_symm_apply]
      exact hm
  refine ⟨ι, ⟨?_, ?_⟩, ?_⟩
  · intro X Y hXY
    by_contra hne
    have h' : ¬ X ⊆ Y ∨ ¬ Y ⊆ X := by
      by_contra hcon
      push_neg at hcon
      exact hne (Finset.Subset.antisymm hcon.1 hcon.2)
    rcases h' with h' | h'
    · exact idxSet_not_subset_of_not_subset h' ((hsub X Y).1 (by rw [hXY]))
    · exact idxSet_not_subset_of_not_subset h' ((hsub Y X).1 (by rw [hXY]))
  · intro X Y
    rw [Finset.ssubset_iff_subset_ne, Finset.lt_iff_ssubset, Finset.ssubset_iff_subset_ne]
    constructor
    · rintro ⟨h1, h2⟩
      have hXY : X ⊆ Y := by
        by_contra hcon
        exact idxSet_not_subset_of_not_subset hcon ((hsub X Y).1 h1)
      refine ⟨hXY, ?_⟩
      rintro rfl
      exact h2 rfl
    · rintro ⟨h1, h2⟩
      refine ⟨(hsub X Y).2 (idxSet_subset_of_subset hmono h1), ?_⟩
      intro hEq
      have hYX : Y ⊆ X := by
        by_contra hcon
        exact idxSet_not_subset_of_not_subset hcon ((hsub Y X).1 (le_of_eq hEq.symm))
      exact h2 (Finset.Subset.antisymm h1 hYX)
  · intro X
    rw [hcard X, card_idxSet hge X]

/-! ## Which level families are `B_d`-free -/

/-- Levels above `n` are not realized, so they can be discarded. -/
theorem levelFamily_filter_le (S : Finset ℕ) :
    levelFamily α S = levelFamily α (S.filter (· ≤ Fintype.card α)) := by
  classical
  ext A
  simp only [mem_levelFamily, Finset.mem_filter]
  exact ⟨fun h => ⟨h, by simpa using Finset.card_le_card (Finset.subset_univ A)⟩, fun h => h.1⟩

/-- **Strong copies inside a level family.**  If `S` realizes at least `d + 1` levels of
`2^[n]`, then `𝓛(S)` contains a strong copy of `B_d`. -/
theorem exists_strongCopy_levelFamily {d : ℕ} {S : Finset ℕ}
    (hS : d + 1 ≤ (S.filter (· ≤ Fintype.card α)).card) :
    ∃ ι : BoolLat d → Finset α, IsStrongCopy ι ∧ ∀ X, ι X ∈ levelFamily α S := by
  classical
  obtain ⟨T, hTsub, hTcard⟩ :=
    Finset.exists_subset_card_eq (s := S.filter (· ≤ Fintype.card α)) (n := d + 1) hS
  set iso := T.orderIsoOfFin hTcard with hiso
  set t : ℕ → ℕ := fun k => (iso ⟨min k d, by omega⟩ : ℕ) with ht
  have hmemT : ∀ k, t k ∈ T := fun k => (iso ⟨min k d, by omega⟩).2
  have hstep : ∀ k < d, t k < t (k + 1) := by
    intro k hk
    have hlt : (⟨min k d, by omega⟩ : Fin (d + 1)) < ⟨min (k + 1) d, by omega⟩ := by
      simp only [Fin.mk_lt_mk]
      omega
    have := (iso.lt_iff_lt).2 hlt
    simpa [ht] using this
  have hlast : t d ≤ Fintype.card α := by
    have := hTsub (hmemT d)
    simpa using (Finset.mem_filter.1 this).2
  obtain ⟨ι, hι, hcard⟩ := exists_strongCopy_of_levels (α := α) (d := d) t hstep hlast
  refine ⟨ι, hι, fun X => ?_⟩
  rw [mem_levelFamily, hcard X]
  exact (Finset.mem_filter.1 (hTsub (hmemT X.card))).1

/-- **A level family is weak `B_d`-free exactly when it uses at most `d` realized
levels.**  This generalizes `weakFree_layers_iff` from consecutive to arbitrary levels. -/
theorem levelFamily_weakFree_iff {d : ℕ} {S : Finset ℕ} :
    WeakFree (levelFamily α S) (BoolLat d) ↔
      (S.filter (· ≤ Fintype.card α)).card ≤ d := by
  classical
  constructor
  · intro hfree
    by_contra hcon
    obtain ⟨ι, hι, hmem⟩ := exists_strongCopy_levelFamily (α := α) (d := d) (S := S) (by omega)
    exact hfree ⟨ι, hι.isWeakCopy, hmem⟩
  · intro hS
    rw [levelFamily_filter_le]
    exact levelFamily_weakFree_of_card_le hS

/-- The strong analogue: a level family is strong `B_d`-free exactly when it uses at most
`d` realized levels.  In particular weak and strong freeness agree on level families. -/
theorem levelFamily_strongFree_iff {d : ℕ} {S : Finset ℕ} :
    StrongFree (levelFamily α S) (BoolLat d) ↔
      (S.filter (· ≤ Fintype.card α)).card ≤ d := by
  classical
  constructor
  · intro hfree
    by_contra hcon
    obtain ⟨ι, hι, hmem⟩ := exists_strongCopy_levelFamily (α := α) (d := d) (S := S) (by omega)
    exact hfree ⟨ι, hι, hmem⟩
  · intro hS
    exact (levelFamily_weakFree_iff.2 hS).strongFree

theorem levelFamily_weakFree_iff_strongFree {d : ℕ} {S : Finset ℕ} :
    WeakFree (levelFamily α S) (BoolLat d) ↔ StrongFree (levelFamily α S) (BoolLat d) := by
  rw [levelFamily_weakFree_iff, levelFamily_strongFree_iff]

/-! ## Unimodality of the binomial row and the optimal window of levels -/

/-- If `i ≤ j` and `i + j ≤ n`, then `j` is at least as close to the middle of the `n`-th
binomial row as `i`, hence `C(n, i) ≤ C(n, j)`. -/
theorem choose_le_choose_of_add_le {n i j : ℕ} (hij : i ≤ j) (hsum : i + j ≤ n) :
    n.choose i ≤ n.choose j := by
  rcases Nat.lt_or_ge (n / 2) j with hj | hj
  · have hjn : j ≤ n := by omega
    have h1 : n - j ≤ n / 2 := by omega
    have h2 : i ≤ n - j := by omega
    have := choose_le_choose_of_le_half h2 h1
    rwa [Nat.choose_symm hjn] at this
  · exact choose_le_choose_of_le_half hij hj

/-- The mirror image of `choose_le_choose_of_add_le`: if `j ≤ i` and `n ≤ i + j`, then
`C(n, i) ≤ C(n, j)`. -/
theorem choose_le_choose_of_le_add {n i j : ℕ} (hji : j ≤ i) (hsum : n ≤ i + j) :
    n.choose i ≤ n.choose j := by
  rcases Nat.lt_or_ge n i with hin | hin
  · simp [Nat.choose_eq_zero_of_lt hin]
  · have hjn : j ≤ n := le_trans hji hin
    have h1 : n - i ≤ n - j := by omega
    have h2 : (n - i) + (n - j) ≤ n := by omega
    have := choose_le_choose_of_add_le h1 h2
    rwa [Nat.choose_symm hin, Nat.choose_symm hjn] at this

/-- The starting level of the window of `d` consecutive levels centred in the `n`-th
binomial row. -/
def centralStart (n d : ℕ) : ℕ := (n + 1 - d) / 2

/-- **The best `d` levels are `d` consecutive central levels.**  For any set `S` of at most
`d` levels, the total number of sets on the levels of `S` is at most the number of sets on
the `d` central levels. -/
theorem sum_choose_le_sum_choose_window {n d : ℕ} (hdn : d ≤ n + 1)
    {S : Finset ℕ} (hS : S.card ≤ d) :
    ∑ i ∈ S, n.choose i ≤
      ∑ i ∈ Finset.Ico (centralStart n d) (centralStart n d + d), n.choose i := by
  classical
  set a := centralStart n d with ha
  set W := Finset.Ico a (a + d) with hW
  have ha1 : n ≤ 2 * a + d := by
    simp only [ha, centralStart]
    omega
  have ha2 : 2 * a + d ≤ n + 1 := by
    simp only [ha, centralStart]
    omega
  have hWcard : W.card = d := by simp [hW]
  -- every level outside the window is dominated by every level inside it
  have key : ∀ s ∈ S \ W, ∀ w ∈ W, n.choose s ≤ n.choose w := by
    intro s hs w hw
    rw [Finset.mem_sdiff] at hs
    rw [hW, Finset.mem_Ico] at hw
    have hsW : ¬ (a ≤ s ∧ s < a + d) := by
      intro h
      exact hs.2 (by rw [hW, Finset.mem_Ico]; exact h)
    rcases Nat.lt_or_ge s a with hlt | hge
    · exact choose_le_choose_of_add_le (by omega) (by omega)
    · have hs' : a + d ≤ s := by omega
      exact choose_le_choose_of_le_add (by omega) (by omega)
  -- the part of `S` outside the window is no bigger than the part of the window outside `S`
  have hcard : (S \ W).card ≤ (W \ S).card := by
    have h1 := Finset.card_inter_add_card_sdiff S W
    have h2 := Finset.card_inter_add_card_sdiff W S
    have h3 : (W ∩ S).card = (S ∩ W).card := by rw [Finset.inter_comm]
    omega
  have hdiff : ∑ i ∈ S \ W, n.choose i ≤ ∑ i ∈ W \ S, n.choose i := by
    rcases Finset.eq_empty_or_nonempty (S \ W) with hemp | hne
    · simp [hemp]
    · have hne' : (W \ S).Nonempty := Finset.card_pos.1 (by
        have := Finset.card_pos.2 hne
        omega)
      obtain ⟨w0, hw0, hw0min⟩ := Finset.exists_min_image (W \ S) (fun i => n.choose i) hne'
      have hw0W : w0 ∈ W := (Finset.mem_sdiff.1 hw0).1
      calc ∑ i ∈ S \ W, n.choose i ≤ (S \ W).card • n.choose w0 :=
            Finset.sum_le_card_nsmul _ _ _ (fun s hs => key s hs w0 hw0W)
        _ ≤ (W \ S).card • n.choose w0 := by
            simp only [smul_eq_mul]
            exact Nat.mul_le_mul_right _ hcard
        _ ≤ ∑ i ∈ W \ S, n.choose i :=
            Finset.card_nsmul_le_sum _ _ _ (fun w hw => hw0min w hw)
  have hsplit1 : ∑ i ∈ S ∩ W, n.choose i + ∑ i ∈ S \ W, n.choose i = ∑ i ∈ S, n.choose i :=
    Finset.sum_inter_add_sum_diff S W _
  have hsplit2 : ∑ i ∈ W ∩ S, n.choose i + ∑ i ∈ W \ S, n.choose i = ∑ i ∈ W, n.choose i :=
    Finset.sum_inter_add_sum_diff W S _
  have hcomm : ∑ i ∈ W ∩ S, n.choose i = ∑ i ∈ S ∩ W, n.choose i := by rw [Finset.inter_comm]
  omega

/-! ## The level-restricted extremal number -/

/-- **No level family beats the central layers.**  Every weak `B_d`-free level family has at
most as many sets as the `d` central layers. -/
theorem card_levelFamily_le_layers {d : ℕ} {S : Finset ℕ}
    (hdn : d ≤ Fintype.card α + 1) (hfree : WeakFree (levelFamily α S) (BoolLat d)) :
    (levelFamily α S).card ≤ (layers α (centralStart (Fintype.card α) d) d).card := by
  classical
  have hSd : (S.filter (· ≤ Fintype.card α)).card ≤ d := levelFamily_weakFree_iff.1 hfree
  rw [levelFamily_filter_le, card_levelFamily, card_layers]
  exact sum_choose_le_sum_choose_window hdn hSd

/-- **The exact level-restricted extremal number.**  The maximal size of a weak `B_d`-free
family determined by the sizes of its sets is exactly the size of the `d` central layers,
and the maximum is attained by those layers.  So the `ε`-improvement of the paper cannot
come from a family defined by a set of levels. -/
theorem level_extremal {d : ℕ} (hdn : d ≤ Fintype.card α + 1) :
    IsGreatest {m : ℕ | ∃ S : Finset ℕ,
        WeakFree (levelFamily α S) (BoolLat d) ∧ (levelFamily α S).card = m}
      (layers α (centralStart (Fintype.card α) d) d).card := by
  constructor
  · refine ⟨Finset.Ico (centralStart (Fintype.card α) d) (centralStart (Fintype.card α) d + d),
      ?_, ?_⟩
    · rw [← layers_eq_levelFamily]
      exact layers_weakFree _ _
    · rw [← layers_eq_levelFamily]
  · rintro m ⟨S, hfree, rfl⟩
    exact card_levelFamily_le_layers hdn hfree

/-- The central layers are of course admissible, so the level-restricted extremal number is
a genuine lower bound for `La(n, B_d)`. -/
theorem card_central_layers_le_La (d : ℕ) :
    (layers α (centralStart (Fintype.card α) d) d).card ≤ La α (BoolLat d) :=
  card_le_La (layers_weakFree _ _)

/-! ## Permutation-invariant families -/

/-- A family is *symmetric* if it is invariant under the permutations of the ground set. -/
def SymmetricFamily (F : Finset (Finset α)) : Prop :=
  ∀ (e : Equiv.Perm α) (A : Finset α), A ∈ F → A.image e ∈ F

/-- Two sets of the same size are carried onto each other by a permutation of the ground
set. -/
theorem exists_perm_image_eq {A B : Finset α} (h : A.card = B.card) :
    ∃ e : Equiv.Perm α, A.image e = B := by
  classical
  have hA : Fintype.card {a : α // a ∈ A} = Fintype.card {a : α // a ∈ B} := by
    simpa using h
  have hAc : Fintype.card {a : α // a ∉ A} = Fintype.card {a : α // a ∉ B} := by
    rw [Fintype.card_subtype_compl, Fintype.card_subtype_compl, hA]
  obtain ⟨e1⟩ : Nonempty ({a : α // a ∈ A} ≃ {a : α // a ∈ B}) := ⟨Fintype.equivOfCardEq hA⟩
  obtain ⟨e2⟩ : Nonempty ({a : α // a ∉ A} ≃ {a : α // a ∉ B}) := ⟨Fintype.equivOfCardEq hAc⟩
  refine ⟨(Equiv.sumCompl (· ∈ A)).symm.trans
    ((Equiv.sumCongr e1 e2).trans (Equiv.sumCompl (· ∈ B))), ?_⟩
  have hsub : A.image ((Equiv.sumCompl (· ∈ A)).symm.trans
      ((Equiv.sumCongr e1 e2).trans (Equiv.sumCompl (· ∈ B)))) ⊆ B := by
    intro b hb
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.1 hb
    simp only [Equiv.trans_apply, Equiv.sumCompl_symm_apply_of_pos ha,
      Equiv.sumCongr_apply, Sum.map_inl, Equiv.sumCompl_apply_inl]
    exact (e1 ⟨a, ha⟩).2
  refine Finset.eq_of_subset_of_card_le hsub ?_
  rw [Finset.card_image_of_injective _ (Equiv.injective _), ← h]

/-- A symmetric family is exactly the level family of the set of sizes it realizes. -/
theorem symmetricFamily_eq_levelFamily {F : Finset (Finset α)} (hF : SymmetricFamily F) :
    F = levelFamily α (F.image Finset.card) := by
  classical
  ext A
  rw [mem_levelFamily, Finset.mem_image]
  constructor
  · exact fun hA => ⟨A, hA, rfl⟩
  · rintro ⟨B, hB, hcard⟩
    obtain ⟨e, he⟩ := exists_perm_image_eq (A := B) (B := A) hcard
    exact he ▸ hF e B hB

/-- **No `ε`-improvement from symmetric families.**  A permutation-invariant weak `B_d`-free
family has at most as many sets as the `d` central layers.  The paper's `(3 + ε)`
construction must therefore break the symmetry of the cube. -/
theorem symmetric_weakFree_card_le {d : ℕ} {F : Finset (Finset α)}
    (hdn : d ≤ Fintype.card α + 1) (hsym : SymmetricFamily F)
    (hfree : WeakFree F (BoolLat d)) :
    F.card ≤ (layers α (centralStart (Fintype.card α) d) d).card := by
  classical
  rw [symmetricFamily_eq_levelFamily hsym] at hfree ⊢
  exact card_levelFamily_le_layers hdn hfree

/-- The same statement for `d = 3`, the poset of the paper: a symmetric weak `B_3`-free
family is never larger than the three central layers. -/
theorem symmetric_weakFree_boolLat3_card_le {F : Finset (Finset α)}
    (hdn : 3 ≤ Fintype.card α + 1) (hsym : SymmetricFamily F)
    (hfree : WeakFree F (BoolLat 3)) :
    F.card ≤ (layers α (centralStart (Fintype.card α) 3) 3).card :=
  symmetric_weakFree_card_le hdn hsym hfree

/-- The `d` central layers carry at most `d · C(n, ⌊n/2⌋)` sets. -/
theorem card_central_layers_le_mul (d : ℕ) :
    (layers α (centralStart (Fintype.card α) d) d).card
      ≤ d * (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  rw [card_layers]
  calc ∑ i ∈ Finset.Ico (centralStart (Fintype.card α) d) (centralStart (Fintype.card α) d + d),
        (Fintype.card α).choose i
      ≤ (Finset.Ico (centralStart (Fintype.card α) d)
          (centralStart (Fintype.card α) d + d)).card •
            (Fintype.card α).choose (Fintype.card α / 2) :=
        Finset.sum_le_card_nsmul _ _ _ (fun i _ => Nat.choose_le_middle i _)
    _ = d * (Fintype.card α).choose (Fintype.card α / 2) := by simp

/-- **Symmetric families never reach `(d + ε)·C(n, ⌊n/2⌋)`.**  A permutation-invariant weak
`B_d`-free family has at most `d·C(n, ⌊n/2⌋)` sets: for such families the layer invariant
`e(B_d) = d` is a hard ceiling, with no `ε` to be gained. -/
theorem symmetric_weakFree_card_le_mul {d : ℕ} {F : Finset (Finset α)}
    (hdn : d ≤ Fintype.card α + 1) (hsym : SymmetricFamily F)
    (hfree : WeakFree F (BoolLat d)) :
    F.card ≤ d * (Fintype.card α).choose (Fintype.card α / 2) :=
  le_trans (symmetric_weakFree_card_le hdn hsym hfree) (card_central_layers_le_mul d)

/-- The case of the paper: a symmetric weak `B_3`-free family has at most
`3·C(n, ⌊n/2⌋)` sets, so the `(3 + ε)`-construction is necessarily asymmetric. -/
theorem symmetric_weakFree_boolLat3_card_le_mul {F : Finset (Finset α)}
    (hdn : 3 ≤ Fintype.card α + 1) (hsym : SymmetricFamily F)
    (hfree : WeakFree F (BoolLat 3)) :
    F.card ≤ 3 * (Fintype.card α).choose (Fintype.card α / 2) :=
  symmetric_weakFree_card_le_mul hdn hsym hfree

/-! ## Two easy complements -/

omit [DecidableEq α] in
/-- If the ground set is too small, no weak copy of `B_d` fits at all. -/
theorem weakFree_univ_of_card_lt {d : ℕ} (h : Fintype.card α < d) :
    WeakFree (Finset.univ : Finset (Finset α)) (BoolLat d) := by
  classical
  rintro ⟨ι, ⟨hinj, -⟩, -⟩
  have h1 : Fintype.card (BoolLat d) ≤ Fintype.card (Finset α) :=
    Fintype.card_le_of_injective ι hinj
  simp only [BoolLat, Fintype.card_finset, Fintype.card_fin] at h1
  exact absurd h1 (by
    have : (2 : ℕ) ^ Fintype.card α < 2 ^ d := Nat.pow_lt_pow_right (by norm_num) h
    omega)

/-- For `n < d` the whole power set is weak `B_d`-free, so `La(n, B_d) = 2^n`. -/
theorem La_boolLat_eq_two_pow_of_lt {d : ℕ} (h : Fintype.card α < d) :
    La α (BoolLat d) = 2 ^ Fintype.card α := by
  classical
  refine le_antisymm (Finset.sup_le fun F _ => ?_) ?_
  · simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ F)
  · have := card_le_La (α := α) (P := BoolLat d) (weakFree_univ_of_card_lt h)
    simpa [Finset.card_univ] using this

/-- The strong analogue of `La_boolLat_eq_two_pow_of_lt`. -/
theorem LaStar_boolLat_eq_two_pow_of_lt {d : ℕ} (h : Fintype.card α < d) :
    LaStar α (BoolLat d) = 2 ^ Fintype.card α := by
  classical
  refine le_antisymm (Finset.sup_le fun F _ => ?_) ?_
  · simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ F)
  · have := card_le_LaStar (α := α) (P := BoolLat d)
      (weakFree_univ_of_card_lt h).strongFree
    simpa [Finset.card_univ] using this

omit [DecidableEq α] [Fintype α] in
/-- For the two-element chain `B_1` weak and strong copies coincide. -/
theorem isWeakCopy_iff_isStrongCopy_boolLatOne {ι : BoolLat 1 → Finset α} :
    IsWeakCopy ι ↔ IsStrongCopy ι := by
  constructor
  · rintro ⟨hinj, hmono⟩
    refine ⟨hinj, fun p q => ⟨fun hpq => ?_, fun hpq => hmono _ _ hpq⟩⟩
    rcases boolLatOne_eq (X := p) with rfl | rfl <;> rcases boolLatOne_eq (X := q) with rfl | rfl
    · exact absurd (Finset.lt_iff_ssubset.2 hpq) (lt_irrefl _)
    · exact empty_lt_univ_boolLatOne
    · exact absurd (Finset.lt_iff_ssubset.2 hpq)
        (asymm (Finset.lt_iff_ssubset.2 (hmono _ _ empty_lt_univ_boolLatOne)))
    · exact absurd (Finset.lt_iff_ssubset.2 hpq) (lt_irrefl _)
  · exact fun h => h.isWeakCopy

omit [DecidableEq α] [Fintype α] in
/-- Strong `B_1`-freeness is again exactly the antichain property. -/
theorem strongFree_boolLatOne_iff {F : Finset (Finset α)} :
    StrongFree F (BoolLat 1) ↔ IsAntichain (· ⊆ ·) (F : Set (Finset α)) := by
  rw [← weakFree_boolLatOne_iff]
  constructor
  · rintro hfree ⟨ι, hι, hmem⟩
    exact hfree ⟨ι, isWeakCopy_iff_isStrongCopy_boolLatOne.1 hι, hmem⟩
  · exact fun h => h.strongFree

/-- **Sperner's theorem for the strong extremal function**: `La*(n, B_1) = C(n, ⌊n/2⌋)`.
Together with `La_boolLatOne_eq` this shows `La(n, B_1) = La*(n, B_1)`. -/
theorem LaStar_boolLatOne_eq :
    LaStar α (BoolLat 1) = (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  refine le_antisymm (Finset.sup_le fun F hF => ?_) ?_
  · rw [Finset.mem_filter] at hF
    exact (strongFree_boolLatOne_iff.1 hF.2).sperner
  · rw [← La_boolLatOne_eq (α := α)]
    exact La_le_LaStar _

/-- For `d = 1` the weak and the strong extremal functions agree for every `n`. -/
theorem La_eq_LaStar_boolLatOne : La α (BoolLat 1) = LaStar α (BoolLat 1) := by
  rw [La_boolLatOne_eq, LaStar_boolLatOne_eq]

end B3Free