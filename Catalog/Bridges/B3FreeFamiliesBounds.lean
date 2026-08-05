/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Maximality of layer families, exact values, and a general upper bound for `La(n, B_d)`

This file continues `Catalog/Bridges/B3FreeFamilies.lean`, which sets up the framework of
weak/strong `P`-free families surrounding the paper *On the maximum size of `B_3`-free
families*.

## Main results

* `not_strongFree_insert_layers`, `layers_maximal_weakFree`, `layers_maximal_strongFree` —
  **maximality of the layer construction**: adding to `d` consecutive layers any set whose
  size lies outside the corresponding interval creates a strong (hence weak) copy of `B_d`.
  Consequently an `ε`-improvement can never be obtained by enlarging the layer family.
* `La_boolLat_eq_of_card_eq_succ`, `LaStar_boolLat_eq_of_card_eq_succ`, `La_boolLat3_fin4` —
  the exact value `La(d+1, B_d) = La*(d+1, B_d) = 2^(d+1) - 2`, attained by the `d` layers
  `1, …, d`; in particular `La(4, B_3) = 14`.  Hence `La` and `La*` agree for `n ∈ {d, d+1}`
  (`La_eq_LaStar_of_card_eq_succ`).
* `La_boolLat_lt_succ_of_card_eq_succ`, `La_boolLat3_lt_boolLat4_fin4` — strict
  monotonicity `La(d+1, B_d) < La(d+1, B_(d+1))`.
* `not_hasChain_of_weakFree`, `card_le_of_not_hasChain`, `La_boolLat_le` — a chain of
  `2^d` sets contains a weak copy of `B_d`, and a Mirsky-type peeling of maximal sets
  combined with Sperner's theorem gives the **general upper bound**
  `La(n, B_d) ≤ (2^d - 1) · C(n, ⌊n/2⌋)`; for `d = 3` this brackets the paper's quantity,
  `3 · C(n, ⌊n/2⌋-2) ≤ La(n, B_3) ≤ 7 · C(n, ⌊n/2⌋)` (`La_boolLat3_bounds`).
-/

import Mathlib
import Catalog.Bridges.B3FreeFamilies

namespace B3Free

open Finset

variable {α : Type*} [DecidableEq α] [Fintype α]

/-! ## Maximality of the layer families

The `d`-layer construction is not only weak `B_d`-free: it is a *maximal* such
family.  Adding any further set to `layers α a d` creates a strong (hence also a
weak) copy of `B_d`.  So the `ε`-improvement of Ellis–Ivan–Leader (and of the
`B_3` paper) can never be obtained by enlarging the layer family; sets have to be
deleted first.
-/

section Maximality

variable {d : ℕ}

omit [DecidableEq α] [Fintype α] in
/-- Replacing the value of a strong copy at the bottom element `∅` by a set `A` lying
strictly below all the other values again produces a strong copy. -/
theorem isStrongCopy_update_bot {ι : BoolLat d → Finset α} (h : IsStrongCopy ι)
    (A : Finset α) (hlt : ∀ X : BoolLat d, X ≠ ∅ → A ⊂ ι X) :
    IsStrongCopy (fun X : BoolLat d => if X = ∅ then A else ι X) := by
  classical
  constructor
  · intro X Y hXY
    simp only at hXY
    by_cases hX : X = ∅ <;> by_cases hY : Y = ∅
    · rw [hX, hY]
    · rw [if_pos hX, if_neg hY] at hXY
      exact absurd hXY (hlt Y hY).ne
    · rw [if_neg hX, if_pos hY] at hXY
      exact absurd hXY.symm (hlt X hX).ne
    · rw [if_neg hX, if_neg hY] at hXY
      exact h.1 hXY
  · intro X Y
    simp only
    by_cases hX : X = ∅ <;> by_cases hY : Y = ∅
    · rw [if_pos hX, if_pos hY, hX, hY]
      exact ⟨fun hc => absurd rfl hc.ne, fun hc => absurd rfl hc.ne⟩
    · rw [if_pos hX, if_neg hY, hX]
      refine iff_of_true (hlt Y hY) ?_
      simpa [Finset.lt_iff_ssubset, Finset.empty_ssubset, Finset.nonempty_iff_ne_empty] using hY
    · rw [if_neg hX, if_pos hY, hY]
      refine iff_of_false (fun hc => absurd (hlt X hX) (asymm hc)) ?_
      simp
    · rw [if_neg hX, if_neg hY]
      exact h.2 X Y

omit [DecidableEq α] [Fintype α] in
/-- Replacing the value of a strong copy at the top element by a set `A` lying strictly
above all the other values again produces a strong copy. -/
theorem isStrongCopy_update_top {ι : BoolLat d → Finset α} (h : IsStrongCopy ι)
    (A : Finset α) (hlt : ∀ X : BoolLat d, X ≠ Finset.univ → ι X ⊂ A) :
    IsStrongCopy (fun X : BoolLat d => if X = Finset.univ then A else ι X) := by
  classical
  constructor
  · intro X Y hXY
    simp only at hXY
    by_cases hX : X = Finset.univ <;> by_cases hY : Y = Finset.univ
    · rw [hX, hY]
    · rw [if_pos hX, if_neg hY] at hXY
      exact absurd hXY.symm (hlt Y hY).ne
    · rw [if_neg hX, if_pos hY] at hXY
      exact absurd hXY (hlt X hX).ne
    · rw [if_neg hX, if_neg hY] at hXY
      exact h.1 hXY
  · intro X Y
    simp only
    by_cases hX : X = Finset.univ <;> by_cases hY : Y = Finset.univ
    · rw [if_pos hX, if_pos hY, hX, hY]
      exact ⟨fun hc => absurd rfl hc.ne, fun hc => absurd rfl hc.ne⟩
    · rw [if_pos hX, if_neg hY, hX]
      refine iff_of_false (fun hc => absurd (hlt Y hY) (asymm hc)) ?_
      intro hc
      exact hY (Finset.univ_subset_iff.1 (Finset.lt_iff_ssubset.1 hc).subset)
    · rw [if_neg hX, if_pos hY, hY]
      refine iff_of_true (hlt X hX) ?_
      simpa [Finset.lt_iff_ssubset] using Finset.ssubset_univ_iff.2 hX
    · rw [if_neg hX, if_neg hY]
      exact h.2 X Y

omit [Fintype α] in
/-- Inside any set `C` with `a + d ≤ |C|` one finds a base set of size `a` together with
`d` further elements of `C` outside it. -/
theorem exists_base_and_atoms {a : ℕ} {C : Finset α} (h : a + d ≤ C.card) :
    ∃ (s : Finset α) (f : Fin d → α), Function.Injective f ∧ (∀ i, f i ∉ s) ∧
      s.card = a ∧ s ⊆ C ∧ ∀ i, f i ∈ C := by
  classical
  obtain ⟨t, htC, ht⟩ := Finset.exists_subset_card_eq (s := C) (n := a + d) h
  obtain ⟨s, hst, hs⟩ := Finset.exists_subset_card_eq (s := t) (n := a) (by omega)
  have hucard : (t \ s).card = d := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.2 hst, ht, hs]
    omega
  obtain ⟨e⟩ : Nonempty (Fin d ≃ (t \ s : Finset α)) :=
    ⟨(Finset.equivFinOfCardEq hucard).symm⟩
  refine ⟨s, fun i => (e i : α), fun i j hij => e.injective (Subtype.ext hij), fun i => ?_, hs,
    hst.trans htC, fun i => ?_⟩
  · have h2 := (e i).2
    simp only [Finset.mem_sdiff] at h2
    exact h2.2
  · have h2 := (e i).2
    simp only [Finset.mem_sdiff] at h2
    exact htC h2.1

/-- If `s` leaves room for `d` more elements, one finds `d` distinct elements outside `s`. -/
theorem exists_atoms_outside {s : Finset α} (h : s.card + d ≤ Fintype.card α) :
    ∃ f : Fin d → α, Function.Injective f ∧ ∀ i, f i ∉ s := by
  classical
  have hcard : d ≤ (Finset.univ \ s).card := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.2 (Finset.subset_univ s), Finset.card_univ]
    omega
  obtain ⟨u, hu, hucard⟩ := Finset.exists_subset_card_eq hcard
  obtain ⟨e⟩ : Nonempty (Fin d ≃ (u : Finset α)) := ⟨(Finset.equivFinOfCardEq hucard).symm⟩
  refine ⟨fun i => (e i : α), fun i j hij => e.injective (Subtype.ext hij), fun i => ?_⟩
  have h2 := hu (e i).2
  simp only [Finset.mem_sdiff] at h2
  exact h2.2

/-- Adding a set `A` that is *too large* to the `d` layers starting at `a` creates a strong
copy of `B_d` whose top element is `A`. -/
theorem not_strongFree_insert_of_le_card {a : ℕ} {A : Finset α} (hA : a + d ≤ A.card) :
    ¬ StrongFree (insert A (layers α a d)) (BoolLat d) := by
  classical
  obtain ⟨s, f, hf, hdisj, hs, hsA, hfA⟩ := exists_base_and_atoms (C := A) hA
  have hcopy : IsStrongCopy (fun X : BoolLat d => s ∪ X.image f) :=
    isStrongCopy_union_image s f hf hdisj
  have hcard : ∀ X : BoolLat d, (s ∪ X.image f).card = a + X.card := by
    intro X
    rw [card_union_image s f hf hdisj, hs]
  have hsub : ∀ X : BoolLat d, s ∪ X.image f ⊆ A := by
    intro X B hB
    rcases Finset.mem_union.1 hB with hB | hB
    · exact hsA hB
    · obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hB
      exact hfA i
  have hsmall : ∀ X : BoolLat d, X ≠ Finset.univ → X.card < d := by
    intro X hX
    simpa using Finset.card_lt_card (Finset.ssubset_univ_iff.2 hX)
  have hlt : ∀ X : BoolLat d, X ≠ Finset.univ → s ∪ X.image f ⊂ A := by
    intro X hX
    refine Finset.ssubset_iff_subset_ne.2 ⟨hsub X, fun hEq => ?_⟩
    have h1 := hcard X
    rw [hEq] at h1
    have h2 := hsmall X hX
    omega
  intro hfree
  refine hfree ⟨fun X => if X = Finset.univ then A else s ∪ X.image f,
    isStrongCopy_update_top hcopy A hlt, fun X => ?_⟩
  by_cases hX : X = Finset.univ
  · simp [hX]
  · simp only [if_neg hX]
    refine Finset.mem_insert_of_mem ?_
    rw [mem_layers, hcard X]
    have := hsmall X hX
    omega

/-- Adding a set `A` that is *too small* to the `d` layers starting at `a` creates a strong
copy of `B_d` whose bottom element is `A`. -/
theorem not_strongFree_insert_of_card_lt {a : ℕ} {A : Finset α}
    (h : a + d ≤ Fintype.card α) (hA : A.card < a) :
    ¬ StrongFree (insert A (layers α a d)) (BoolLat d) := by
  classical
  obtain ⟨s, hAs, -, hs⟩ := Finset.exists_subsuperset_card_eq (n := a - 1)
    (Finset.subset_univ A) (by omega) (by rw [Finset.card_univ]; omega)
  obtain ⟨f, hf, hdisj⟩ := exists_atoms_outside (s := s) (d := d) (by rw [hs]; omega)
  have hcopy : IsStrongCopy (fun X : BoolLat d => s ∪ X.image f) :=
    isStrongCopy_union_image s f hf hdisj
  have hcard : ∀ X : BoolLat d, (s ∪ X.image f).card = (a - 1) + X.card := by
    intro X
    rw [card_union_image s f hf hdisj, hs]
  have hpos : ∀ X : BoolLat d, X ≠ ∅ → 1 ≤ X.card := by
    intro X hX
    exact Finset.card_pos.2 (Finset.nonempty_iff_ne_empty.2 hX)
  have hle : ∀ X : BoolLat d, X.card ≤ d := by
    intro X
    simpa using Finset.card_le_card (Finset.subset_univ X)
  have hlt : ∀ X : BoolLat d, X ≠ ∅ → A ⊂ s ∪ X.image f := by
    intro X hX
    refine Finset.ssubset_iff_subset_ne.2 ⟨hAs.trans Finset.subset_union_left, fun hEq => ?_⟩
    have h1 := hcard X
    rw [← hEq] at h1
    have h2 := hpos X hX
    omega
  intro hfree
  refine hfree ⟨fun X => if X = ∅ then A else s ∪ X.image f,
    isStrongCopy_update_bot hcopy A hlt, fun X => ?_⟩
  by_cases hX : X = ∅
  · simp [hX]
  · simp only [if_neg hX]
    refine Finset.mem_insert_of_mem ?_
    rw [mem_layers, hcard X]
    have h1 := hpos X hX
    have h2 := hle X
    omega

/-- **The layer family is maximal**: adding to `layers α a d` any set whose size lies
outside the interval `[a, a + d)` creates a strong copy of `B_d`. -/
theorem not_strongFree_insert_layers {a : ℕ} {A : Finset α}
    (h : a + d ≤ Fintype.card α) (hA : A ∉ layers α a d) :
    ¬ StrongFree (insert A (layers α a d)) (BoolLat d) := by
  rw [mem_layers] at hA
  push_neg at hA
  rcases lt_or_ge A.card a with h1 | h1
  · exact not_strongFree_insert_of_card_lt h h1
  · exact not_strongFree_insert_of_le_card (hA h1)

/-- The weak form of maximality of the layer family. -/
theorem not_weakFree_insert_layers {a : ℕ} {A : Finset α}
    (h : a + d ≤ Fintype.card α) (hA : A ∉ layers α a d) :
    ¬ WeakFree (insert A (layers α a d)) (BoolLat d) :=
  fun hw => not_strongFree_insert_layers h hA hw.strongFree

/-- **Maximality, in extremal form**: a weak `B_d`-free family containing the `d` layers
starting at `a` equals those layers. -/
theorem layers_maximal_weakFree {a : ℕ} (h : a + d ≤ Fintype.card α)
    {F : Finset (Finset α)} (hF : WeakFree F (BoolLat d)) (hsub : layers α a d ⊆ F) :
    F = layers α a d := by
  by_contra hne
  obtain ⟨A, hAF, hA⟩ := Finset.exists_of_ssubset (lt_of_le_of_ne hsub (Ne.symm hne))
  exact not_weakFree_insert_layers h hA (hF.mono (Finset.insert_subset hAF hsub))

/-- The same statement for strong `B_d`-free families. -/
theorem layers_maximal_strongFree {a : ℕ} (h : a + d ≤ Fintype.card α)
    {F : Finset (Finset α)} (hF : StrongFree F (BoolLat d)) (hsub : layers α a d ⊆ F) :
    F = layers α a d := by
  by_contra hne
  obtain ⟨A, hAF, hA⟩ := Finset.exists_of_ssubset (lt_of_le_of_ne hsub (Ne.symm hne))
  exact not_strongFree_insert_layers h hA (hF.mono (Finset.insert_subset hAF hsub))

/-- Maximality in the case of interest, `d = 3`. -/
theorem layers_maximal_weakFree_boolLat3 {a : ℕ} (h : a + 3 ≤ Fintype.card α)
    {F : Finset (Finset α)} (hF : WeakFree F (BoolLat 3)) (hsub : layers α a 3 ⊆ F) :
    F = layers α a 3 :=
  layers_maximal_weakFree h hF hsub

end Maximality

/-! ## An exact value: ground set of size `d + 1`

On a ground set with `d + 1` elements the extremal family is again a family of
layers, namely all sets except `∅` and the ground set: `La(d+1, B_d) = 2^(d+1) - 2`.
-/

section CardSucc

variable {d : ℕ}

/-- If `|α| = d + 1` then for every set `A` there is a strong copy of `B_d` in `2^α`
avoiding `A`: use the subsets of `α ∖ {j}` for some `j ∈ A`, or the sets containing a
fixed `j` when `A = ∅`. -/
theorem exists_strongCopy_avoiding (hcard : Fintype.card α = d + 1) (A : Finset α) :
    ∃ ι : BoolLat d → Finset α, IsStrongCopy ι ∧ ∀ X, ι X ≠ A := by
  classical
  rcases Finset.eq_empty_or_nonempty A with rfl | ⟨j, hj⟩
  · obtain ⟨j⟩ : Nonempty α := Fintype.card_pos_iff.1 (by omega)
    obtain ⟨f, hf, hdisj⟩ := exists_atoms_outside (s := ({j} : Finset α)) (d := d)
      (by rw [Finset.card_singleton, hcard]; omega)
    refine ⟨fun X => {j} ∪ X.image f, isStrongCopy_union_image _ f hf hdisj, fun X hX => ?_⟩
    simp only at hX
    have hmem : j ∈ ({j} : Finset α) ∪ X.image f :=
      Finset.mem_union_left _ (Finset.mem_singleton_self j)
    rw [hX] at hmem
    simp at hmem
  · obtain ⟨f, hf, hdisj⟩ := exists_atoms_outside (s := ({j} : Finset α)) (d := d)
      (by rw [Finset.card_singleton, hcard]; omega)
    have hdisj' : ∀ i, f i ∉ (∅ : Finset α) := by simp
    refine ⟨fun X => ∅ ∪ X.image f, isStrongCopy_union_image _ f hf hdisj', fun X hX => ?_⟩
    simp only at hX
    have hjn : j ∉ (∅ : Finset α) ∪ X.image f := by
      simp only [Finset.empty_union, Finset.mem_image]
      rintro ⟨i, -, rfl⟩
      exact hdisj i (Finset.mem_singleton_self _)
    rw [hX] at hjn
    exact hjn hj

/-- If `|α| = d + 1`, then removing a single set from `2^α` never yields a
strong `B_d`-free family. -/
theorem not_strongFree_erase (hcard : Fintype.card α = d + 1) (A : Finset α) :
    ¬ StrongFree ((Finset.univ : Finset (Finset α)).erase A) (BoolLat d) := by
  classical
  obtain ⟨ι, hι, hne⟩ := exists_strongCopy_avoiding hcard A
  exact fun hfree =>
    hfree ⟨ι, hι, fun X => Finset.mem_erase.2 ⟨hne X, Finset.mem_univ _⟩⟩

/-- If `|α| = d + 1`, then removing a single set from `2^α` never yields a
weak `B_d`-free family. -/
theorem not_weakFree_erase (hcard : Fintype.card α = d + 1) (A : Finset α) :
    ¬ WeakFree ((Finset.univ : Finset (Finset α)).erase A) (BoolLat d) :=
  fun hfree => not_strongFree_erase hcard A hfree.strongFree

/-- On a ground set of size `d + 1` every strong `B_d`-free family misses at least two
sets. -/
theorem card_le_of_strongFree_card_succ (hcard : Fintype.card α = d + 1)
    {F : Finset (Finset α)} (hF : StrongFree F (BoolLat d)) : F.card ≤ 2 ^ (d + 1) - 2 := by
  classical
  have hunivcard : (Finset.univ : Finset (Finset α)).card = 2 ^ (d + 1) := by
    simp [Finset.card_univ, hcard]
  by_contra hlt
  push_neg at hlt
  by_cases hFu : F = Finset.univ
  · exact not_strongFree_erase hcard (∅ : Finset α)
      ((hFu ▸ hF).mono (Finset.erase_subset _ _))
  · obtain ⟨A, hA⟩ : ∃ A, A ∉ F := by
      by_contra hc
      push_neg at hc
      exact hFu (Finset.eq_univ_of_forall hc)
    have hsub : F ⊆ Finset.univ.erase A := fun B hB =>
      Finset.mem_erase.2 ⟨fun hEq => hA (hEq ▸ hB), Finset.mem_univ _⟩
    have hcard2 : ((Finset.univ : Finset (Finset α)).erase A).card = 2 ^ (d + 1) - 1 := by
      rw [Finset.card_erase_of_mem (Finset.mem_univ A), hunivcard]
    have hEq : F = Finset.univ.erase A :=
      Finset.eq_of_subset_of_card_le hsub (by omega)
    exact not_strongFree_erase hcard A (hEq ▸ hF)

/-- **`La(d + 1, B_d) = 2^(d+1) - 2`.**  The extremal family is again a union of `d`
consecutive layers, namely all sets except `∅` and the ground set. -/
theorem La_boolLat_eq_of_card_eq_succ (hcard : Fintype.card α = d + 1) :
    La α (BoolLat d) = 2 ^ (d + 1) - 2 := by
  classical
  have hpow : 2 ≤ 2 ^ (d + 1) := by
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
    _ ≤ 2 ^ (d + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  have hunivcard : (Finset.univ : Finset (Finset α)).card = 2 ^ (d + 1) := by
    simp [Finset.card_univ, hcard]
  refine le_antisymm ?_ ?_
  · refine Finset.sup_le fun F hF => ?_
    rw [Finset.mem_filter] at hF
    exact card_le_of_strongFree_card_succ hcard hF.2.strongFree
  · have hlow := sum_choose_le_La (α := α) 1 d
    rw [hcard, show 1 + d = d + 1 from by omega] at hlow
    have hsum : ∑ i ∈ Finset.Ico 1 (d + 1), (d + 1).choose i = 2 ^ (d + 1) - 2 := by
      have h2 : ∑ i ∈ Finset.range (d + 2), (d + 1).choose i = 2 ^ (d + 1) :=
        Nat.sum_range_choose (d + 1)
      rw [Finset.range_eq_Ico, Finset.sum_eq_sum_Ico_succ_bot (by omega),
        show d + 2 = (d + 1) + 1 from rfl, Finset.sum_Ico_succ_top (by omega)] at h2
      simp only [Nat.choose_zero_right, Nat.choose_self, zero_add] at h2
      omega
    omega

/-- The weak and strong extremal numbers also agree on a ground set of size `d + 1`:
`La*(d+1, B_d) = 2^(d+1) - 2 = La(d+1, B_d)`. -/
theorem LaStar_boolLat_eq_of_card_eq_succ (hcard : Fintype.card α = d + 1) :
    LaStar α (BoolLat d) = 2 ^ (d + 1) - 2 := by
  classical
  refine le_antisymm ?_ ?_
  · refine Finset.sup_le fun F hF => ?_
    rw [Finset.mem_filter] at hF
    exact card_le_of_strongFree_card_succ hcard hF.2
  · rw [← La_boolLat_eq_of_card_eq_succ (α := α) hcard]
    exact La_le_LaStar _

/-- For `n = d + 1` the weak and strong extremal numbers still coincide, so any
separation of `La` and `La*` for `B_d` must occur for `n ≥ d + 2`. -/
theorem La_eq_LaStar_of_card_eq_succ (hcard : Fintype.card α = d + 1) :
    La α (BoolLat d) = LaStar α (BoolLat d) := by
  rw [La_boolLat_eq_of_card_eq_succ hcard, LaStar_boolLat_eq_of_card_eq_succ hcard]

/-- The layer bound is tight on a ground set of size `d + 1`, and there strictly fewer
sets are allowed than for `B_(d+1)`: `La(d+1, B_d) < La(d+1, B_(d+1))`. -/
theorem La_boolLat_lt_succ_of_card_eq_succ (hcard : Fintype.card α = d + 1) :
    La α (BoolLat d) < La α (BoolLat (d + 1)) := by
  have hpow : 2 ≤ 2 ^ (d + 1) := by
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
    _ ≤ 2 ^ (d + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  rw [La_boolLat_eq_of_card_eq_succ hcard, La_boolLat_eq_of_card_eq (d := d + 1) hcard]
  omega

end CardSucc

/-! ## Chains, Mirsky-type partitions, and a general upper bound

A chain of `2^d` sets already contains a weak copy of `B_d` (map `B_d` into the chain
along the binary-encoding linear extension), so a weak `B_d`-free family has no chain of
`2^d` sets.  Peeling off maximal elements (a Mirsky-type argument) and applying Sperner's
theorem to each layer of maximal elements gives the general upper bound
`La(n, B_d) ≤ (2^d − 1) · C(n, ⌊n/2⌋)`.
-/

section Chains

/-- `F` contains a chain of `k` sets. -/
def HasChain (F : Finset (Finset α)) (k : ℕ) : Prop :=
  ∃ c : Fin k → Finset α, StrictMono c ∧ ∀ i, c i ∈ F

theorem sum_range_two_pow (m : ℕ) : ∑ i ∈ Finset.range m, 2 ^ i = 2 ^ m - 1 := by
  induction m with
  | zero => simp
  | succ n ih =>
    have h1 : 1 ≤ 2 ^ n := Nat.one_le_two_pow
    rw [Finset.sum_range_succ, ih]
    omega

theorem sum_two_pow_lt {d : ℕ} (X : BoolLat d) : ∑ i ∈ X, 2 ^ (i : ℕ) < 2 ^ d := by
  have h1 : ∑ i ∈ X, 2 ^ (i : ℕ) ≤ ∑ i ∈ (Finset.univ : Finset (Fin d)), 2 ^ (i : ℕ) :=
    Finset.sum_le_sum_of_subset (Finset.subset_univ X)
  have h2 : ∑ i ∈ (Finset.univ : Finset (Fin d)), 2 ^ (i : ℕ) = 2 ^ d - 1 := by
    rw [Fin.sum_univ_eq_sum_range (fun i => 2 ^ i) d, sum_range_two_pow]
  have h3 : 1 ≤ 2 ^ d := Nat.one_le_two_pow
  omega

/-- The binary encoding `X ↦ ∑_{i ∈ X} 2^i` is a linear extension of `B_d`. -/
def boolLatEncode {d : ℕ} (X : BoolLat d) : Fin (2 ^ d) :=
  ⟨∑ i ∈ X, 2 ^ (i : ℕ), sum_two_pow_lt X⟩

theorem boolLatEncode_strictMono {d : ℕ} : StrictMono (boolLatEncode (d := d)) := by
  intro X Y hXY
  have hss : X ⊂ Y := Finset.lt_iff_ssubset.1 hXY
  obtain ⟨j, hjY, hjX⟩ := Finset.exists_of_ssubset hss
  refine Fin.mk_lt_mk.2 ?_
  exact Finset.sum_lt_sum_of_subset hss.subset hjY hjX (pow_pos (by norm_num) _)
    (fun k _ _ => Nat.zero_le _)

/-- The binary encoding is injective (binary representation is unique). -/
theorem boolLatEncode_injective {d : ℕ} : Function.Injective (boolLatEncode (d := d)) := by
  intro X Y hXY
  have hval : ∑ i ∈ X, 2 ^ (i : ℕ) = ∑ i ∈ Y, 2 ^ (i : ℕ) := congrArg Fin.val hXY
  have h : ∑ j ∈ X.image (Fin.val), 2 ^ j = ∑ j ∈ Y.image (Fin.val), 2 ^ j := by
    rw [Finset.sum_image (fun a _ b _ hab => Fin.val_injective hab),
      Finset.sum_image (fun a _ b _ hab => Fin.val_injective hab)]
    exact hval
  exact Finset.image_injective Fin.val_injective
    (Finset.geomSum_injective (n := 2) (by norm_num) h)

omit [DecidableEq α] [Fintype α] in
/-- A chain of `2^d` sets contains a weak copy of `B_d`, so a weak `B_d`-free family
contains no such chain. -/
theorem not_hasChain_of_weakFree {d : ℕ} {F : Finset (Finset α)}
    (h : WeakFree F (BoolLat d)) : ¬ HasChain F (2 ^ d) := by
  rintro ⟨c, hc, hmem⟩
  refine h ⟨c ∘ boolLatEncode, ⟨hc.injective.comp boolLatEncode_injective,
    fun p q hpq => ?_⟩, fun p => hmem _⟩
  exact Finset.lt_iff_ssubset.1 (hc (boolLatEncode_strictMono hpq))

/-- The maximal members of a family. -/
def maxSets (F : Finset (Finset α)) : Finset (Finset α) :=
  F.filter (fun A => ∀ B ∈ F, ¬ A ⊂ B)

theorem maxSets_subset (F : Finset (Finset α)) : maxSets F ⊆ F := Finset.filter_subset _ _

theorem isAntichain_maxSets (F : Finset (Finset α)) :
    IsAntichain (· ⊆ ·) (maxSets F : Set (Finset α)) := by
  intro A hA B hB hne hAB
  rw [Finset.mem_coe, maxSets, Finset.mem_filter] at hA hB
  exact hA.2 B hB.1 (Finset.ssubset_iff_subset_ne.2 ⟨hAB, hne⟩)

/-- Every member of a family lies below a maximal member. -/
theorem exists_maxSet_superset {F : Finset (Finset α)} {A : Finset α} (hA : A ∈ F) :
    ∃ B ∈ maxSets F, A ⊆ B := by
  classical
  obtain ⟨B, hB⟩ := Finset.exists_maximal (s := F.filter (fun C => A ⊆ C))
    ⟨A, Finset.mem_filter.2 ⟨hA, Finset.Subset.refl A⟩⟩
  have hBmem := Finset.mem_filter.1 hB.1
  refine ⟨B, Finset.mem_filter.2 ⟨hBmem.1, fun C hC hBC => ?_⟩, hBmem.2⟩
  have hCmem : C ∈ F.filter (fun C => A ⊆ C) :=
    Finset.mem_filter.2 ⟨hC, hBmem.2.trans hBC.subset⟩
  exact absurd (hB.2 hCmem hBC.subset) (by simpa using hBC.not_subset)

/-- **Mirsky-type bound.**  A family with no chain of `k + 1` sets has at most
`k · C(n, ⌊n/2⌋)` members: peel off the maximal sets, which form an antichain, and use
Sperner's theorem. -/
theorem card_le_of_not_hasChain {k : ℕ} :
    ∀ {F : Finset (Finset α)}, ¬ HasChain F (k + 1) →
      F.card ≤ k * (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  induction k with
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
    simp [hempty]
  | succ k ih =>
    intro F h
    have hsub : ¬ HasChain (F \ maxSets F) (k + 1) := by
      rintro ⟨c, hc, hmem⟩
      have hlast := hmem (Fin.last k)
      rw [Finset.mem_sdiff] at hlast
      obtain ⟨B, hBmax, hAB⟩ := exists_maxSet_superset hlast.1
      have hne : c (Fin.last k) ≠ B := fun hEq => hlast.2 (hEq ▸ hBmax)
      have hssub : c (Fin.last k) ⊂ B := Finset.ssubset_iff_subset_ne.2 ⟨hAB, hne⟩
      refine h ⟨fun i => if hi : (i : ℕ) ≤ k then c ⟨i, by omega⟩ else B, fun i j hij => ?_,
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
    have h1 := ih hsub
    have h2 : (maxSets F).card ≤ (Fintype.card α).choose (Fintype.card α / 2) :=
      (isAntichain_maxSets F).sperner
    have h3 : (F \ maxSets F).card + (maxSets F).card = F.card := by
      rw [Finset.card_sdiff_add_card, Finset.union_eq_left.2 (maxSets_subset F)]
    have : F.card ≤ k * (Fintype.card α).choose (Fintype.card α / 2)
        + (Fintype.card α).choose (Fintype.card α / 2) := by omega
    calc F.card ≤ k * (Fintype.card α).choose (Fintype.card α / 2)
          + (Fintype.card α).choose (Fintype.card α / 2) := this
      _ = (k + 1) * (Fintype.card α).choose (Fintype.card α / 2) := by ring

/-- **General upper bound**: `La(n, B_d) ≤ (2^d − 1) · C(n, ⌊n/2⌋)`.
For `d = 1` this is exactly Sperner's theorem. -/
theorem La_boolLat_le (d : ℕ) :
    La α (BoolLat d) ≤ (2 ^ d - 1) * (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  refine Finset.sup_le fun F hF => ?_
  rw [Finset.mem_filter] at hF
  have hpow : 1 ≤ 2 ^ d := Nat.one_le_two_pow
  refine card_le_of_not_hasChain (k := 2 ^ d - 1) ?_
  have hEq : 2 ^ d - 1 + 1 = 2 ^ d := by omega
  rw [hEq]
  exact not_hasChain_of_weakFree hF.2

/-- The upper bound for the poset of the paper: `La(n, B_3) ≤ 7 · C(n, ⌊n/2⌋)`. -/
theorem La_boolLat3_le : La α (BoolLat 3) ≤ 7 * (Fintype.card α).choose (Fintype.card α / 2) := by
  have := La_boolLat_le (α := α) 3
  norm_num at this
  exact this

/-- **Bracketing `La(n, B_3)`**: the three-layer construction from below and the
Mirsky/Sperner bound from above. -/
theorem La_boolLat3_bounds (h : 4 ≤ Fintype.card α) :
    3 * (Fintype.card α).choose (Fintype.card α / 2 - 2) ≤ La α (BoolLat 3) ∧
      La α (BoolLat 3) ≤ 7 * (Fintype.card α).choose (Fintype.card α / 2) :=
  ⟨three_mul_choose_le_La_boolLat3 h, La_boolLat3_le⟩

end Chains

/-- `La(4, B_3) = 14`, matching the brute-force computation in
`ComputationalEvidence.md`. -/
theorem La_boolLat3_fin4 : La (Fin 4) (BoolLat 3) = 14 := by
  have := La_boolLat_eq_of_card_eq_succ (α := Fin 4) (d := 3) (by simp)
  norm_num at this
  exact this

/-- `La(4, B_3) < La(4, B_4)`: strict monotonicity in the poset, in the smallest case
where both values are known. -/
theorem La_boolLat3_lt_boolLat4_fin4 : La (Fin 4) (BoolLat 3) < La (Fin 4) (BoolLat 4) :=
  La_boolLat_lt_succ_of_card_eq_succ (α := Fin 4) (d := 3) (by simp)

end B3Free