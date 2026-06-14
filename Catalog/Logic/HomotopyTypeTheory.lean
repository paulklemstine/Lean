/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

set_option autoImplicit false

/-!
# Synthetic Homotopy Type Theory: h-Levels, Homotopy Fibres, and Magma Transport

This is the foundational synthetic-HoTT module of the catalog. It introduces the
basic homotopy-theoretic predicates used throughout the "homotopy & path spaces"
research program:

* `HoTT.IsContr` — h-level `(-2)`: a type is *contractible* when it has a centre to
  which every point is equal.
* `HoTT.IsMereProp` — h-level `(-1)`: a type is a *mere proposition* when any two
  points are equal.
* `HoTT.HFiber f b` — the *homotopy fibre* `{ a // f a = b }` of `f` over `b`.

It proves the one-directional bridge `HoTT.bijective_of_contr_fibers` (contractible
fibres ⇒ bijective), and develops a small **algebraic transport** layer:
`HoTT.Magma`, `HoTT.MagmaHom`, `HoTT.MagmaIso`, and the named-isomorphism transport
lemmas `HoTT.magma_comm_transport` / `HoTT.magma_assoc_transport` that move
commutativity and associativity across a magma isomorphism. These are the
foundations extended by `Speculative.AutoResearch.PathSpaceHLevels` and
`Speculative.AutoResearch.EquivalenceCalculus`.
-/

namespace HoTT

universe u v w

/-! ## The h-level hierarchy (lowest two levels) -/

/-- A type is **contractible** (h-level `-2`) when it has a centre of contraction
to which every point is equal. -/
def IsContr (A : Type u) : Prop := ∃ c : A, ∀ a : A, a = c

/-- A type is a **mere proposition** (h-level `-1`) when any two of its points are
equal. -/
def IsMereProp (A : Type u) : Prop := ∀ a b : A, a = b

/-- The **homotopy fibre** of `f : A → B` over `b : B`: the type of points of `A`
mapped by `f` to `b`. -/
def HFiber {A : Type u} {B : Type v} (f : A → B) (b : B) : Type u :=
  { a : A // f a = b }

/-! ## Contractible fibres yield bijectivity (one direction) -/

/-- **Contractible fibres ⇒ bijective.** If every homotopy fibre of `f` is
contractible then `f` is a bijection. The full characterisation (both directions)
is `HoTT.bijective_iff_contr_fibers` in `PathSpaceHLevels`. -/
theorem bijective_of_contr_fibers {A : Type u} {B : Type v} (f : A → B)
    (hf : ∀ b, IsContr (HFiber f b)) : Function.Bijective f := by
  refine ⟨fun a a' h => ?_, fun b => ?_⟩
  · obtain ⟨c, hc⟩ := hf (f a)
    exact congrArg Subtype.val ((hc ⟨a, rfl⟩).trans (hc ⟨a', h.symm⟩).symm)
  · obtain ⟨c, _⟩ := hf b
    exact ⟨c.1, c.2⟩

/-! ## Magmas and structure transport along isomorphisms -/

/-- A **magma**: a type with a binary operation. -/
structure Magma where
  /-- The underlying carrier type. -/
  Carrier : Type u
  /-- The binary operation. -/
  op : Carrier → Carrier → Carrier

/-- A **magma homomorphism**: a map commuting with the binary operations. -/
structure MagmaHom (M N : Magma) where
  /-- The underlying function. -/
  toFun : M.Carrier → N.Carrier
  /-- The homomorphism law. -/
  map_op : ∀ a b, toFun (M.op a b) = N.op (toFun a) (toFun b)

/-- A **magma isomorphism**: a magma homomorphism whose underlying map is
bijective. -/
structure MagmaIso (M N : Magma) where
  /-- The underlying homomorphism. -/
  hom : MagmaHom M N
  /-- The underlying map is a bijection. -/
  bijective : Function.Bijective hom.toFun

/-- **Commutativity transports along an isomorphism.** If `M` is commutative and
`e : MagmaIso M N`, then `N` is commutative. -/
theorem magma_comm_transport {M N : Magma} (e : MagmaIso M N)
    (hcomm : ∀ (a b : M.Carrier), M.op a b = M.op b a) :
    ∀ (x y : N.Carrier), N.op x y = N.op y x := by
  intro x y
  obtain ⟨a, rfl⟩ := e.bijective.2 x
  obtain ⟨b, rfl⟩ := e.bijective.2 y
  rw [← e.hom.map_op, ← e.hom.map_op, hcomm]

/-- **Associativity transports along an isomorphism.** If `M` is associative and
`e : MagmaIso M N`, then `N` is associative. -/
theorem magma_assoc_transport {M N : Magma} (e : MagmaIso M N)
    (hassoc : ∀ (a b c : M.Carrier), M.op (M.op a b) c = M.op a (M.op b c)) :
    ∀ (x y z : N.Carrier), N.op (N.op x y) z = N.op x (N.op y z) := by
  intro x y z
  obtain ⟨a, rfl⟩ := e.bijective.2 x
  obtain ⟨b, rfl⟩ := e.bijective.2 y
  obtain ⟨c, rfl⟩ := e.bijective.2 z
  rw [← e.hom.map_op, ← e.hom.map_op, ← e.hom.map_op, ← e.hom.map_op, hassoc]

end HoTT