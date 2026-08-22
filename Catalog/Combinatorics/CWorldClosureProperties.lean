/-
# Closure Properties of the Representable Class

The characterisation `representable_iff` of `Combinatorics.CWorldFiltration`
("representable = finite + rooted + directed + antisymmetric") turns questions about
bounded morphisms into questions about three elementary order properties.  This file
harvests that: each closure property below is proved by checking the three properties,
with no further work on morphisms.

## Main results

* `representable_of_orderIso` — representability is an order-isomorphism invariant.
* `representable_prod` — the class is closed under binary products.
* `representable_upperSet` — every principal filter `↑p` of a representable poset is
  representable (rooted at `p`, and directedness and antisymmetry are inherited).
* `representable_of_boundedLattice` — every finite lattice with `⊥` and `⊤` is
  representable; in particular every finite Boolean algebra and every finite chain.
* `representable_pi` — the class is closed under finite products indexed by a fintype.
-/

import Combinatorics.CWorldFiltration

namespace CWorldFiltration

open Function

/-- Representability only depends on the isomorphism type of the order. -/
theorem representable_of_orderIso {P Q : Type} [Preorder P] [Preorder Q] [Fintype P]
    [Fintype Q] [Nonempty P] (e : P ≃o Q) (hP : Representable P) : Representable Q := by
  haveI : Nonempty Q := ⟨e (Classical.arbitrary P)⟩
  obtain ⟨⟨r, hr⟩, hdir, hanti⟩ := (representable_iff P).mp hP
  refine (representable_iff Q).mpr ⟨⟨e r, fun q => ?_⟩, ?_, ?_⟩
  · simpa using e.monotone (hr (e.symm q))
  · intro x y
    obtain ⟨z, hz₁, hz₂⟩ := hdir (e.symm x) (e.symm y)
    exact ⟨e z, by simpa using e.monotone hz₁, by simpa using e.monotone hz₂⟩
  · intro p q hpq hqp
    have := hanti (e.symm p) (e.symm q) (e.symm.monotone hpq) (e.symm.monotone hqp)
    simpa using congrArg e this

/-- The class of representable finite orders is closed under binary products. -/
theorem representable_prod {P Q : Type} [Preorder P] [Preorder Q] [Fintype P] [Fintype Q]
    [Nonempty P] [Nonempty Q] (hP : Representable P) (hQ : Representable Q) :
    Representable (P × Q) := by
  obtain ⟨⟨rP, hrP⟩, hdirP, hantiP⟩ := (representable_iff P).mp hP
  obtain ⟨⟨rQ, hrQ⟩, hdirQ, hantiQ⟩ := (representable_iff Q).mp hQ
  refine (representable_iff (P × Q)).mpr ⟨⟨(rP, rQ), fun p => ⟨hrP p.1, hrQ p.2⟩⟩, ?_, ?_⟩
  · rintro ⟨x₁, x₂⟩ ⟨y₁, y₂⟩
    obtain ⟨z₁, hz₁, hz₁'⟩ := hdirP x₁ y₁
    obtain ⟨z₂, hz₂, hz₂'⟩ := hdirQ x₂ y₂
    exact ⟨(z₁, z₂), ⟨hz₁, hz₂⟩, ⟨hz₁', hz₂'⟩⟩
  · rintro ⟨p₁, p₂⟩ ⟨q₁, q₂⟩ ⟨h₁, h₂⟩ ⟨h₁', h₂'⟩
    exact Prod.ext (hantiP _ _ h₁ h₁') (hantiQ _ _ h₂ h₂')

/-- Every principal filter of a representable order is representable. -/
theorem representable_upperSet {P : Type} [Preorder P] [Fintype P] [Nonempty P]
    (hP : Representable P) (p : P) : Representable {q : P // p ≤ q} := by
  obtain ⟨-, hdir, hanti⟩ := (representable_iff P).mp hP
  haveI : Nonempty {q : P // p ≤ q} := ⟨⟨p, le_rfl⟩⟩
  refine (representable_iff {q : P // p ≤ q}).mpr ⟨⟨⟨p, le_rfl⟩, fun q => q.2⟩, ?_, ?_⟩
  · rintro ⟨x, hx⟩ ⟨y, hy⟩
    obtain ⟨z, hz₁, hz₂⟩ := hdir x y
    exact ⟨⟨z, le_trans hx hz₁⟩, hz₁, hz₂⟩
  · rintro ⟨x, hx⟩ ⟨y, hy⟩ h h'
    exact Subtype.ext (hanti x y h h')

/-- **Every finite bounded lattice is representable** — in particular every finite
Boolean algebra, every finite chain and every finite distributive lattice. -/
theorem representable_of_boundedLattice (P : Type) [Lattice P] [BoundedOrder P] [Fintype P] :
    Representable P := by
  haveI : Nonempty P := ⟨⊥⟩
  exact (representable_iff P).mpr
    ⟨⟨⊥, fun _ => bot_le⟩, fun x y => ⟨x ⊔ y, le_sup_left, le_sup_right⟩,
      fun _ _ h h' => le_antisymm h h'⟩

/-- The class of representable finite orders is closed under products indexed by a
fintype. -/
theorem representable_pi {ι : Type} [Fintype ι] (P : ι → Type) [∀ i, Preorder (P i)]
    [∀ i, Fintype (P i)] [∀ i, Nonempty (P i)] [DecidableEq ι]
    (h : ∀ i, Representable (P i)) : Representable (∀ i, P i) := by
  haveI : Nonempty (∀ i, P i) := ⟨fun i => Classical.arbitrary (P i)⟩
  choose root hroot using fun i => ((representable_iff (P i)).mp (h i)).1
  have hdir : ∀ i, ∀ x y : P i, ∃ z, x ≤ z ∧ y ≤ z := fun i => ((representable_iff (P i)).mp (h i)).2.1
  have hanti : ∀ i, ∀ x y : P i, x ≤ y → y ≤ x → x = y :=
    fun i => ((representable_iff (P i)).mp (h i)).2.2
  refine (representable_iff (∀ i, P i)).mpr ⟨⟨root, fun f i => hroot i (f i)⟩, ?_, ?_⟩
  · intro x y
    choose z hz₁ hz₂ using fun i => hdir i (x i) (y i)
    exact ⟨z, fun i => hz₁ i, fun i => hz₂ i⟩
  · intro x y hxy hyx
    funext i
    exact hanti i (x i) (y i) (hxy i) (hyx i)

end CWorldFiltration