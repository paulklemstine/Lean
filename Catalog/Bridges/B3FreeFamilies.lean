/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Weak and strong `P`-free families and the layer number `e(P)`

This file formalizes the basic framework surrounding the paper
*On the maximum size of `B_3`-free families*, and proves the exact value of the
"number of free consecutive layers" invariant for the Boolean lattice posets `B_d`.

## Framework

Following the paper, a family `𝒢` of sets is a **weak copy** of a poset `P` if
there is a bijection `ι : P → 𝒢` with `ι p ⊂ ι q` whenever `p < q`, and a
**strong copy** if moreover `ι p ⊂ ι q` holds *only* when `p < q`.  A family is
weak (strong) `P`-free if it contains no weak (strong) copy of `P`.
`La(n, P)` (`La*(n, P)`) is the maximum size of a weak (strong) `P`-free family
in `2^[n]`.

The poset `B_d` is the Boolean lattice on `d` atoms, formalized here as
`Finset (Fin d)` with the inclusion order (`BoolLat d`).

## Main results

* `layers_weakFree` — any `d` consecutive layers of `2^[n]` are weak `B_d`-free;
  hence `e(B_d) ≥ d` and `La(n, B_d) ≥ ∑ᵢ C(n, i)` over `d` consecutive layers
  (`sum_choose_le_La`).
* `exists_strongCopy_layers` — any `d + 1` consecutive layers of `2^[n]`
  (with enough room, `a + d ≤ n`) contain a *strong* copy of `B_d`.
* `weakFree_layers_iff`, `strongFree_layers_iff` — combining the two: `k`
  consecutive layers are weak (strong) `B_d`-free **iff** `k ≤ d`.  This is the
  statement `e(B_d) = e*(B_d) = d`.
* `La_boolLatOne_eq` — **Sperner's theorem in this language**: `La(n, B_1)` is
  exactly `C(n, ⌊n/2⌋)`, i.e. for `d = 1` the layer construction is optimal and
  no `ε`-improvement is possible.  (The content of the paper is that for `d = 3`,
  in contrast, a positive `ε`-improvement does exist.)
* `La_mono_of_strictMono`, `La_boolLat_mono` — `La` is monotone along strictly
  monotone injections of posets, in particular `La(n, B_d) ≤ La(n, B_(d+1))`.
* `mul_choose_le_La`, `three_mul_choose_le_La_boolLat3` — quantitative forms of the
  layer bound, e.g. `3 · C(n, ⌊n/2⌋ - 2) ≤ La(n, B_3)`.
* `La_lt_two_pow`, `La_boolLat_eq_of_card_eq`, `La_boolLat3_fin3` — `La(n, B_d) < 2^n`
  for `d ≤ n`, with the exact values `La(d, B_d) = 2^d - 1` and `La(3, B_3) = 7`.
* `LaStar_boolLat_eq_of_card_eq`, `La_eq_LaStar_of_card_eq` — the same exact value for the
  strong extremal function, so `La(d, B_d) = La*(d, B_d) = 2^d - 1`.

Maximality of the layer construction, the exact value `La(d+1, B_d) = 2^(d+1) - 2`, and the
general upper bound `La(n, B_d) ≤ (2^d - 1)·C(n, ⌊n/2⌋)` are proved in
`Catalog/Bridges/B3FreeFamiliesBounds.lean`.
-/

import Mathlib

namespace B3Free

open Finset

/-! ## Weak and strong copies -/

variable {α : Type*}

/-- `ι` realizes a *weak copy* of the poset `P` inside the subsets of `α`:
it is injective and strictly increasing for inclusion. -/
def IsWeakCopy {P : Type*} [Preorder P] (ι : P → Finset α) : Prop :=
  Function.Injective ι ∧ ∀ p q : P, p < q → ι p ⊂ ι q

/-- `ι` realizes a *strong (induced) copy* of the poset `P`: it is injective and
strict inclusion of images happens exactly for strictly comparable elements. -/
def IsStrongCopy {P : Type*} [Preorder P] (ι : P → Finset α) : Prop :=
  Function.Injective ι ∧ ∀ p q : P, ι p ⊂ ι q ↔ p < q

/-- A family `F` is *weak `P`-free* if it contains no weak copy of `P`. -/
def WeakFree (F : Finset (Finset α)) (P : Type*) [Preorder P] : Prop :=
  ¬ ∃ ι : P → Finset α, IsWeakCopy ι ∧ ∀ p, ι p ∈ F

/-- A family `F` is *strong `P`-free* if it contains no strong copy of `P`. -/
def StrongFree (F : Finset (Finset α)) (P : Type*) [Preorder P] : Prop :=
  ¬ ∃ ι : P → Finset α, IsStrongCopy ι ∧ ∀ p, ι p ∈ F

theorem IsStrongCopy.isWeakCopy {P : Type*} [Preorder P] {ι : P → Finset α}
    (h : IsStrongCopy ι) : IsWeakCopy ι :=
  ⟨h.1, fun _ _ hpq => (h.2 _ _).2 hpq⟩

/-- Weak freeness is the stronger notion. -/
theorem WeakFree.strongFree {F : Finset (Finset α)} {P : Type*} [Preorder P]
    (h : WeakFree F P) : StrongFree F P :=
  fun ⟨ι, hι, hmem⟩ => h ⟨ι, hι.isWeakCopy, hmem⟩

theorem WeakFree.mono {F G : Finset (Finset α)} {P : Type*} [Preorder P]
    (h : WeakFree G P) (hFG : F ⊆ G) : WeakFree F P :=
  fun ⟨ι, hι, hmem⟩ => h ⟨ι, hι, fun p => hFG (hmem p)⟩

theorem StrongFree.mono {F G : Finset (Finset α)} {P : Type*} [Preorder P]
    (h : StrongFree G P) (hFG : F ⊆ G) : StrongFree F P :=
  fun ⟨ι, hι, hmem⟩ => h ⟨ι, hι, fun p => hFG (hmem p)⟩

/-! ## Layers of the Boolean lattice -/

variable [DecidableEq α] [Fintype α]

/-- The `k` consecutive layers of `2^α` with sizes in `[a, a + k)`. -/
def layers (α : Type*) [Fintype α] [DecidableEq α] (a k : ℕ) : Finset (Finset α) :=
  {A : Finset α | a ≤ A.card ∧ A.card < a + k}

theorem mem_layers {a k : ℕ} {A : Finset α} :
    A ∈ layers α a k ↔ a ≤ A.card ∧ A.card < a + k := by
  simp [layers]

theorem layers_mono {a k l : ℕ} (h : k ≤ l) : layers α a k ⊆ layers α a l := by
  intro A hA
  rw [mem_layers] at hA ⊢
  exact ⟨hA.1, lt_of_lt_of_le hA.2 (by omega)⟩

/-- The size of `k` consecutive layers is the corresponding sum of binomial
coefficients. -/
theorem card_layers (a k : ℕ) :
    (layers α a k).card = ∑ i ∈ Finset.Ico a (a + k), (Fintype.card α).choose i := by
  classical
  have hEq : layers α a k
      = (Finset.Ico a (a + k)).biUnion (fun i => Finset.powersetCard i Finset.univ) := by
    ext A
    simp only [mem_layers, Finset.mem_biUnion, Finset.mem_Ico, Finset.mem_powersetCard]
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨A.card, ⟨h1, h2⟩, Finset.subset_univ _, rfl⟩
    · rintro ⟨i, ⟨h1, h2⟩, -, rfl⟩
      exact ⟨h1, h2⟩
  rw [hEq, Finset.card_biUnion]
  · refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.card_powersetCard, Finset.card_univ]
  · intro i _ j _ hij
    refine Finset.disjoint_left.2 fun A hA hA' => ?_
    rw [Finset.mem_powersetCard] at hA hA'
    exact hij (hA.2 ▸ hA'.2 ▸ rfl)

/-! ## The Boolean lattice poset `B_d` -/

/-- The Boolean lattice poset `B_d`, as the subsets of a `d`-element set. -/
abbrev BoolLat (d : ℕ) : Type := Finset (Fin d)

omit [DecidableEq α] [Fintype α] in
/-- A weak copy of `B_d` contains a strictly increasing chain of `d + 1` sets,
hence the largest set of the copy exceeds the smallest by at least `d` in size. -/
theorem exists_card_add_le_of_isWeakCopy {d : ℕ} {ι : BoolLat d → Finset α}
    (h : IsWeakCopy ι) : ∃ p q : BoolLat d, (ι p).card + d ≤ (ι q).card := by
  classical
  set S : ℕ → BoolLat d := fun k => Finset.univ.filter (fun i : Fin d => (i : ℕ) < k) with hS
  have hchain : ∀ k, k < d → S k < S (k + 1) := by
    intro k hk
    refine lt_of_le_of_ne ?_ ?_
    · intro i hi
      simp only [hS, Finset.mem_filter, Finset.mem_univ, true_and] at hi ⊢
      omega
    · intro hEq
      have : (⟨k, hk⟩ : Fin d) ∈ S (k + 1) := by
        simp [hS]
      rw [← hEq] at this
      simp [hS] at this
  have key : ∀ k, k ≤ d → (ι (S 0)).card + k ≤ (ι (S k)).card := by
    intro k
    induction k with
    | zero => intro _; simp
    | succ n ih =>
      intro hn
      have h1 := ih (by omega)
      have h2 : ι (S n) ⊂ ι (S (n + 1)) := h.2 _ _ (hchain n (by omega))
      have h3 := Finset.card_lt_card h2
      omega
  exact ⟨S 0, S d, key d le_rfl⟩

/-- **`d` consecutive layers are weak `B_d`-free**, i.e. `e(B_d) ≥ d`. -/
theorem layers_weakFree (a d : ℕ) : WeakFree (layers α a d) (BoolLat d) := by
  rintro ⟨ι, hι, hmem⟩
  obtain ⟨p, q, hpq⟩ := exists_card_add_le_of_isWeakCopy hι
  have h1 := (mem_layers.1 (hmem p)).1
  have h2 := (mem_layers.1 (hmem q)).2
  omega

/-! ## Strong copies inside `d + 1` layers -/

section Construction

variable {d : ℕ} (s : Finset α) (f : Fin d → α)

omit [Fintype α] in
private theorem mem_union_image_iff (hf : Function.Injective f) (hdisj : ∀ i, f i ∉ s)
    (X : BoolLat d) (i : Fin d) : f i ∈ s ∪ X.image f ↔ i ∈ X := by
  simp only [Finset.mem_union, Finset.mem_image]
  constructor
  · rintro (hs | ⟨j, hj, hji⟩)
    · exact absurd hs (hdisj i)
    · exact hf hji ▸ hj
  · exact fun hi => Or.inr ⟨i, hi, rfl⟩

omit [Fintype α] in
private theorem union_image_subset_iff (hf : Function.Injective f) (hdisj : ∀ i, f i ∉ s)
    (X Y : BoolLat d) : s ∪ X.image f ⊆ s ∪ Y.image f ↔ X ⊆ Y := by
  constructor
  · intro h i hi
    have : f i ∈ s ∪ X.image f := (mem_union_image_iff s f hf hdisj X i).2 hi
    exact (mem_union_image_iff s f hf hdisj Y i).1 (h this)
  · intro h A hA
    rcases Finset.mem_union.1 hA with hA | hA
    · exact Finset.mem_union_left _ hA
    · obtain ⟨i, hi, rfl⟩ := Finset.mem_image.1 hA
      exact Finset.mem_union_right _ (Finset.mem_image_of_mem f (h hi))

omit [Fintype α] in
/-- Given a base set `s` and `d` further elements outside `s`, the sets
`s ∪ f '' X` form a strong copy of `B_d`. -/
theorem isStrongCopy_union_image (hf : Function.Injective f) (hdisj : ∀ i, f i ∉ s) :
    IsStrongCopy (fun X : BoolLat d => s ∪ X.image f) := by
  constructor
  · intro X Y hXY
    apply Finset.Subset.antisymm
    · exact (union_image_subset_iff s f hf hdisj X Y).1 (le_of_eq hXY)
    · exact (union_image_subset_iff s f hf hdisj Y X).1 (le_of_eq hXY.symm)
  · intro X Y
    rw [Finset.ssubset_iff_subset_ne, Finset.lt_iff_ssubset, Finset.ssubset_iff_subset_ne]
    constructor
    · rintro ⟨h1, h2⟩
      refine ⟨(union_image_subset_iff s f hf hdisj X Y).1 h1, ?_⟩
      rintro rfl
      exact h2 rfl
    · rintro ⟨h1, h2⟩
      refine ⟨(union_image_subset_iff s f hf hdisj X Y).2 h1, ?_⟩
      intro hEq
      apply h2
      apply Finset.Subset.antisymm h1
      exact (union_image_subset_iff s f hf hdisj Y X).1 (le_of_eq hEq.symm)

omit [Fintype α] in
theorem card_union_image (hf : Function.Injective f) (hdisj : ∀ i, f i ∉ s) (X : BoolLat d) :
    (s ∪ X.image f).card = s.card + X.card := by
  rw [Finset.card_union_of_disjoint, Finset.card_image_of_injective _ hf]
  refine Finset.disjoint_right.2 fun A hA hA' => ?_
  obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 hA
  exact hdisj i hA'

end Construction

/-- **`d + 1` consecutive layers contain a strong copy of `B_d`** (given enough
room in the ground set). -/
theorem exists_strongCopy_layers {a d : ℕ} (h : a + d ≤ Fintype.card α) :
    ∃ ι : BoolLat d → Finset α, IsStrongCopy ι ∧ ∀ X, ι X ∈ layers α a (d + 1) := by
  classical
  obtain ⟨t, -, ht⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset α))
    (n := a + d) (by simpa using h)
  obtain ⟨s, hst, hs⟩ := Finset.exists_subset_card_eq (s := t) (n := a) (by omega)
  have hucard : (t \ s).card = d := by
    rw [Finset.card_sdiff, Finset.inter_eq_left.2 hst, ht, hs]
    omega
  obtain ⟨e⟩ : Nonempty (Fin d ≃ (t \ s : Finset α)) :=
    ⟨(Finset.equivFinOfCardEq hucard).symm⟩
  set f : Fin d → α := fun i => (e i : α) with hf
  have hfinj : Function.Injective f := by
    intro i j hij
    exact e.injective (Subtype.ext hij)
  have hdisj : ∀ i, f i ∉ s := by
    intro i
    have h2 := (e i).2
    simp only [Finset.mem_sdiff] at h2
    exact h2.2
  refine ⟨fun X => s ∪ X.image f, isStrongCopy_union_image s f hfinj hdisj, fun X => ?_⟩
  rw [mem_layers, card_union_image s f hfinj hdisj, hs]
  have : X.card ≤ d := by
    simpa using Finset.card_le_card (Finset.subset_univ X)
  omega

/-- `k` consecutive layers of `2^α` are weak `B_d`-free exactly when `k ≤ d`.
Together with `layers_weakFree` this is the statement `e(B_d) = d`. -/
theorem weakFree_layers_iff {a d k : ℕ} (h : a + d ≤ Fintype.card α) :
    WeakFree (layers α a k) (BoolLat d) ↔ k ≤ d := by
  constructor
  · intro hfree
    by_contra hk
    obtain ⟨ι, hι, hmem⟩ := exists_strongCopy_layers (α := α) (a := a) (d := d) h
    exact hfree ⟨ι, hι.isWeakCopy, fun X => layers_mono (by omega) (hmem X)⟩
  · intro hk
    exact (layers_weakFree (α := α) a d).mono (layers_mono hk)

/-- `k` consecutive layers of `2^α` are strong `B_d`-free exactly when `k ≤ d`.
This is the statement `e*(B_d) = d`. -/
theorem strongFree_layers_iff {a d k : ℕ} (h : a + d ≤ Fintype.card α) :
    StrongFree (layers α a k) (BoolLat d) ↔ k ≤ d := by
  constructor
  · intro hfree
    by_contra hk
    obtain ⟨ι, hι, hmem⟩ := exists_strongCopy_layers (α := α) (a := a) (d := d) h
    exact hfree ⟨ι, hι, fun X => layers_mono (by omega) (hmem X)⟩
  · intro hk
    exact ((layers_weakFree (α := α) a d).mono (layers_mono hk)).strongFree

/-! ## The extremal functions `La` and `La*` -/

open scoped Classical in
/-- `La(α, P)`: the maximum size of a weak `P`-free family of subsets of `α`. -/
noncomputable def La (α : Type*) [Fintype α] [DecidableEq α] (P : Type*) [Preorder P] : ℕ :=
  ((Finset.univ : Finset (Finset (Finset α))).filter (fun F => WeakFree F P)).sup Finset.card

open scoped Classical in
/-- `La*(α, P)`: the maximum size of a strong `P`-free family of subsets of `α`. -/
noncomputable def LaStar (α : Type*) [Fintype α] [DecidableEq α] (P : Type*) [Preorder P] : ℕ :=
  ((Finset.univ : Finset (Finset (Finset α))).filter (fun F => StrongFree F P)).sup Finset.card

theorem card_le_La {P : Type*} [Preorder P] {F : Finset (Finset α)} (h : WeakFree F P) :
    F.card ≤ La α P := by
  classical
  apply Finset.le_sup (f := Finset.card)
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact h

theorem card_le_LaStar {P : Type*} [Preorder P] {F : Finset (Finset α)} (h : StrongFree F P) :
    F.card ≤ LaStar α P := by
  classical
  apply Finset.le_sup (f := Finset.card)
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact h

theorem La_le_LaStar (P : Type*) [Preorder P] : La α P ≤ LaStar α P := by
  classical
  refine Finset.sup_le fun F hF => ?_
  rw [Finset.mem_filter] at hF
  exact card_le_LaStar hF.2.strongFree

/-- **Lower bound from the layer construction**: `La(n, B_d) ≥ ∑ᵢ C(n, i)` over any
`d` consecutive layers. -/
theorem sum_choose_le_La (a d : ℕ) :
    ∑ i ∈ Finset.Ico a (a + d), (Fintype.card α).choose i ≤ La α (BoolLat d) := by
  rw [← card_layers (α := α) a d]
  exact card_le_La (layers_weakFree a d)

/-- The same lower bound for the strong extremal function. -/
theorem sum_choose_le_LaStar (a d : ℕ) :
    ∑ i ∈ Finset.Ico a (a + d), (Fintype.card α).choose i ≤ LaStar α (BoolLat d) := by
  rw [← card_layers (α := α) a d]
  exact card_le_LaStar (layers_weakFree a d).strongFree

/-! ## Sperner's theorem: the case `d = 1` -/

theorem boolLatOne_eq {X : BoolLat 1} : X = ∅ ∨ X = Finset.univ := by
  classical
  rcases Finset.eq_empty_or_nonempty X with h | h
  · exact Or.inl h
  · refine Or.inr (Finset.eq_univ_of_card X ?_)
    have h1 : 1 ≤ X.card := Finset.card_pos.2 h
    have h2 : X.card ≤ 1 := by simpa using Finset.card_le_card (Finset.subset_univ X)
    simp; omega

theorem empty_lt_univ_boolLatOne : (∅ : BoolLat 1) < Finset.univ := by
  refine lt_of_le_of_ne (Finset.empty_subset _) ?_
  intro h
  have : (0 : Fin 1) ∈ (∅ : BoolLat 1) := by rw [h]; exact Finset.mem_univ _
  simp at this

omit [DecidableEq α] [Fintype α] in
/-- Weak `B_1`-freeness is exactly the antichain property. -/
theorem weakFree_boolLatOne_iff {F : Finset (Finset α)} :
    WeakFree F (BoolLat 1) ↔ IsAntichain (· ⊆ ·) (F : Set (Finset α)) := by
  classical
  constructor
  · intro hfree A hA B hB hne hAB
    refine hfree ⟨fun X => if X = ∅ then A else B, ⟨?_, ?_⟩, ?_⟩
    · intro X Y hXY
      rcases boolLatOne_eq (X := X) with rfl | rfl <;>
        rcases boolLatOne_eq (X := Y) with rfl | rfl <;> simp_all
    · intro p q hpq
      rcases boolLatOne_eq (X := p) with rfl | rfl
      · rcases boolLatOne_eq (X := q) with rfl | rfl
        · exact absurd hpq (lt_irrefl _)
        · simpa [Finset.univ_eq_empty_iff, Finset.ssubset_iff_subset_ne] using
            ⟨hAB, hne⟩
      · exact absurd (lt_of_lt_of_le hpq (Finset.subset_univ q)) (lt_irrefl _)
    · intro p
      rcases boolLatOne_eq (X := p) with rfl | rfl
      · simpa using hA
      · simpa [Finset.univ_eq_empty_iff] using hB
  · rintro hanti ⟨ι, ⟨hinj, hmono⟩, hmem⟩
    have hlt : ι ∅ ⊂ ι Finset.univ := hmono _ _ empty_lt_univ_boolLatOne
    exact hanti (hmem ∅) (hmem Finset.univ) (fun hEq => absurd hEq hlt.ne) hlt.subset

/-- **Sperner's theorem, restated**: `La(n, B_1) = C(n, ⌊n/2⌋)`.  For `d = 1` the
layer construction is optimal: no `ε`-improvement is possible. -/
theorem La_boolLatOne_eq :
    La α (BoolLat 1) = (Fintype.card α).choose (Fintype.card α / 2) := by
  classical
  refine le_antisymm ?_ ?_
  · refine Finset.sup_le fun F hF => ?_
    rw [Finset.mem_filter] at hF
    exact (weakFree_boolLatOne_iff.1 hF.2).sperner
  · have := sum_choose_le_La (α := α) (Fintype.card α / 2) 1
    simpa using this


/-! ## Monotonicity in the poset, and general bounds -/

omit [DecidableEq α] [Fintype α] in
/-- If `P` embeds into `Q` by a strictly monotone injection, then a weak `P`-free
family is also weak `Q`-free (restrict a copy of `Q` along the embedding). -/
theorem WeakFree.of_strictMono {P Q : Type*} [Preorder P] [Preorder Q]
    {F : Finset (Finset α)} (e : P → Q) (hmono : StrictMono e)
    (hinj : Function.Injective e) (h : WeakFree F P) : WeakFree F Q := by
  rintro ⟨ι, ⟨hι, hmonoι⟩, hmem⟩
  exact h ⟨ι ∘ e, ⟨hι.comp hinj, fun p q hpq => hmonoι _ _ (hmono hpq)⟩, fun p => hmem (e p)⟩

/-- `La` is monotone along strictly monotone injections of posets. -/
theorem La_mono_of_strictMono {P Q : Type*} [Preorder P] [Preorder Q] (e : P → Q)
    (hmono : StrictMono e) (hinj : Function.Injective e) : La α P ≤ La α Q := by
  classical
  refine Finset.sup_le fun F hF => ?_
  rw [Finset.mem_filter] at hF
  exact card_le_La (WeakFree.of_strictMono e hmono hinj hF.2)

/-- The Boolean lattice `B_d` embeds into `B_(d+1)`, hence `La(n, B_d) ≤ La(n, B_(d+1))`. -/
theorem La_boolLat_mono (d : ℕ) : La α (BoolLat d) ≤ La α (BoolLat (d + 1)) := by
  classical
  refine La_mono_of_strictMono (fun X : BoolLat d => X.map (Fin.castSuccEmb)) ?_ ?_
  · intro X Y hXY
    rw [Finset.lt_iff_ssubset, Finset.ssubset_iff_subset_ne] at hXY ⊢
    refine ⟨Finset.map_subset_map.2 hXY.1, fun hEq => hXY.2 (Finset.map_injective _ hEq)⟩
  · exact fun X Y hXY => Finset.map_injective _ hXY

/-- With enough room in the ground set the full power set is *not* `B_d`-free, so the
extremal number is strictly smaller than `2 ^ n`. -/
theorem La_lt_two_pow {d : ℕ} (h : d ≤ Fintype.card α) : La α (BoolLat d) < 2 ^ Fintype.card α := by
  classical
  have huniv : ¬ WeakFree (Finset.univ : Finset (Finset α)) (BoolLat d) := by
    obtain ⟨ι, hι, -⟩ := exists_strongCopy_layers (α := α) (a := 0) (d := d) (by simpa using h)
    exact fun hfree => hfree ⟨ι, hι.isWeakCopy, fun X => Finset.mem_univ _⟩
  have hcard : (Finset.univ : Finset (Finset α)).card = 2 ^ Fintype.card α := by
    simp [Finset.card_univ]
  have hle : La α (BoolLat d) ≤ 2 ^ Fintype.card α - 1 := by
    refine Finset.sup_le fun F hF => ?_
    rw [Finset.mem_filter] at hF
    have hne : F ≠ Finset.univ := fun hEq => huniv (hEq ▸ hF.2)
    exact Nat.le_pred_of_lt (hcard ▸ Finset.card_lt_card
      (lt_of_le_of_ne (Finset.subset_univ F) hne))
  have hpos : 0 < 2 ^ Fintype.card α := pow_pos (by norm_num) _
  omega

/-- Below the middle layer, binomial coefficients increase, so `d` consecutive layers
starting at `a` each have size at least `C(n, a)`. -/
theorem choose_le_choose_of_le_half {n a i : ℕ} (hai : a ≤ i) (hi : i ≤ n / 2) :
    n.choose a ≤ n.choose i := by
  induction i with
  | zero =>
    have ha : a = 0 := by omega
    simp [ha]
  | succ j ih =>
    rcases Nat.lt_or_ge a (j + 1) with hlt | hge
    · have hja : a ≤ j := by omega
      exact le_trans (ih hja (by omega)) (Nat.choose_le_succ_of_lt_half_left (by omega))
    · have : a = j + 1 := by omega
      simp [this]

/-- **Quantitative layer bound**: `d · C(n, a) ≤ La(n, B_d)` whenever the `d` layers
starting at `a` all lie weakly below the middle layer. -/
theorem mul_choose_le_La {a d : ℕ} (h : a + d ≤ Fintype.card α / 2 + 1) :
    d * (Fintype.card α).choose a ≤ La α (BoolLat d) := by
  refine le_trans ?_ (sum_choose_le_La (α := α) a d)
  have hcard : (Finset.Ico a (a + d)).card = d := by simp
  calc d * (Fintype.card α).choose a
      = ∑ _i ∈ Finset.Ico a (a + d), (Fintype.card α).choose a := by
        rw [Finset.sum_const, hcard, smul_eq_mul]
    _ ≤ ∑ i ∈ Finset.Ico a (a + d), (Fintype.card α).choose i := by
        refine Finset.sum_le_sum fun i hi => ?_
        rw [Finset.mem_Ico] at hi
        exact choose_le_choose_of_le_half hi.1 (by omega)

/-! ## The case `d = 3`: the setting of the paper -/

/-- `e(B_3) = 3`: exactly three consecutive layers of `2^[n]` can be taken while
staying weak `B_3`-free. -/
theorem weakFree_layers_boolLat3_iff {a k : ℕ} (h : a + 3 ≤ Fintype.card α) :
    WeakFree (layers α a k) (BoolLat 3) ↔ k ≤ 3 :=
  weakFree_layers_iff h

/-- `e*(B_3) = 3`: the same holds for strong copies. -/
theorem strongFree_layers_boolLat3_iff {a k : ℕ} (h : a + 3 ≤ Fintype.card α) :
    StrongFree (layers α a k) (BoolLat 3) ↔ k ≤ 3 :=
  strongFree_layers_iff h

/-- The three-layer lower bound `La(n, B_3) ≥ C(n,a) + C(n,a+1) + C(n,a+2)`. -/
theorem three_layer_le_La_boolLat3 (a : ℕ) :
    (Fintype.card α).choose a + (Fintype.card α).choose (a + 1)
      + (Fintype.card α).choose (a + 2) ≤ La α (BoolLat 3) := by
  have := sum_choose_le_La (α := α) a 3
  have hsum : ∑ i ∈ Finset.Ico a (a + 3), (Fintype.card α).choose i
      = (Fintype.card α).choose a + (Fintype.card α).choose (a + 1)
        + (Fintype.card α).choose (a + 2) := by
    have h3 : a + 3 = a + 2 + 1 := by omega
    rw [h3, Finset.sum_Ico_succ_top (by omega), Finset.sum_Ico_succ_top (by omega),
      Finset.sum_Ico_succ_top (by omega)]
    simp
  omega

/-- A near-middle form of the three-layer bound: `3 · C(n, ⌊n/2⌋ - 2) ≤ La(n, B_3)`. -/
theorem three_mul_choose_le_La_boolLat3 (h : 4 ≤ Fintype.card α) :
    3 * (Fintype.card α).choose (Fintype.card α / 2 - 2) ≤ La α (BoolLat 3) := by
  refine mul_choose_le_La (α := α) (a := Fintype.card α / 2 - 2) (d := 3) ?_
  omega


/-! ## An exact value: ground set of size exactly `d` -/

/-- On a ground set of size exactly `d`, the maximum weak `B_d`-free family consists of
all subsets except one: `La(d, B_d) = 2^d - 1`.  The extremal family is the union of the
`d` layers `0, 1, …, d-1`, i.e. everything but the full set. -/
theorem La_boolLat_eq_of_card_eq {d : ℕ} (hcard : Fintype.card α = d) :
    La α (BoolLat d) = 2 ^ d - 1 := by
  refine le_antisymm ?_ ?_
  · have := La_lt_two_pow (α := α) (d := d) (le_of_eq hcard.symm)
    rw [hcard] at this
    omega
  · have hlow := sum_choose_le_La (α := α) 0 d
    have hsum : ∑ i ∈ Finset.Ico 0 (0 + d), (Fintype.card α).choose i = 2 ^ d - 1 := by
      have h2 : ∑ i ∈ Finset.range (d + 1), d.choose i = 2 ^ d := Nat.sum_range_choose d
      rw [Finset.sum_range_succ, Nat.choose_self] at h2
      have h3 : ∑ i ∈ Finset.Ico 0 (0 + d), (Fintype.card α).choose i
          = ∑ i ∈ Finset.range d, d.choose i := by
        rw [hcard, Finset.range_eq_Ico]
        norm_num
      omega
    omega

/-- The strong analogue of `La_lt_two_pow`. -/
theorem LaStar_lt_two_pow {d : ℕ} (h : d ≤ Fintype.card α) :
    LaStar α (BoolLat d) < 2 ^ Fintype.card α := by
  classical
  have huniv : ¬ StrongFree (Finset.univ : Finset (Finset α)) (BoolLat d) := by
    obtain ⟨ι, hι, -⟩ := exists_strongCopy_layers (α := α) (a := 0) (d := d) (by simpa using h)
    exact fun hfree => hfree ⟨ι, hι, fun X => Finset.mem_univ _⟩
  have hcard : (Finset.univ : Finset (Finset α)).card = 2 ^ Fintype.card α := by
    simp [Finset.card_univ]
  have hle : LaStar α (BoolLat d) ≤ 2 ^ Fintype.card α - 1 := by
    refine Finset.sup_le fun F hF => ?_
    rw [Finset.mem_filter] at hF
    have hne : F ≠ Finset.univ := fun hEq => huniv (hEq ▸ hF.2)
    exact Nat.le_pred_of_lt (hcard ▸ Finset.card_lt_card
      (lt_of_le_of_ne (Finset.subset_univ F) hne))
  have hpos : 0 < 2 ^ Fintype.card α := pow_pos (by norm_num) _
  omega

/-- On a ground set of size exactly `d` the weak and strong extremal numbers agree:
`La*(d, B_d) = 2^d - 1 = La(d, B_d)`. -/
theorem LaStar_boolLat_eq_of_card_eq {d : ℕ} (hcard : Fintype.card α = d) :
    LaStar α (BoolLat d) = 2 ^ d - 1 := by
  refine le_antisymm ?_ ?_
  · have := LaStar_lt_two_pow (α := α) (d := d) (le_of_eq hcard.symm)
    rw [hcard] at this
    omega
  · rw [← La_boolLat_eq_of_card_eq (α := α) hcard]
    exact La_le_LaStar _

/-- For `n = d` the weak and strong extremal numbers coincide. -/
theorem La_eq_LaStar_of_card_eq {d : ℕ} (hcard : Fintype.card α = d) :
    La α (BoolLat d) = LaStar α (BoolLat d) := by
  rw [La_boolLat_eq_of_card_eq hcard, LaStar_boolLat_eq_of_card_eq hcard]

/-- The smallest interesting exact value for `B_3`: `La(3, B_3) = 7`, matching the
brute-force computation recorded in `ComputationalEvidence.md`. -/
theorem La_boolLat3_fin3 : La (Fin 3) (BoolLat 3) = 7 := by
  have := La_boolLat_eq_of_card_eq (α := Fin 3) (d := 3) (by simp)
  norm_num at this
  exact this

end B3Free