/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Theory Morphisms Core: Certified Invariant-Preserving Bridges

This file defines a formal framework for **theory specifications** equipped with
invariants, witness predicates, and certified lower bounds, together with
**theory morphisms** that preserve witnesses and are monotone on invariants.

The key results are:
- `TheoryHom.transport_witness`: every certified morphism transports lower-bound
  information from source to target theory.
- `TheoryHom.comp`: morphisms compose, enabling indirect theorem transfer.
- `TheoryHom.transport_witness_comp`: composed morphisms transport witnesses.
- `TheoryHom.comp_assoc`: composition is associative.
- Category laws (identity, associativity, unit laws).
- Gap theorem: depth gaps obstruct morphism existence.

## Mathematical significance

This framework turns a catalog of mathematical theories into a **category of
invariant-bearing specifications** where theorems transport along certified
morphisms. It is the formal backbone of automated conceptual transfer across
formalized mathematics.
-/

import Mathlib

/-! ## §1. Theory Specifications -/

/-- A **theory specification** packages a carrier type, an invariant function,
    a witness predicate, a lower bound, and a soundness proof that every
    witness achieves the lower bound. This is the fundamental unit of the
    bridge framework. -/
structure TheorySpec where
  /-- The carrier type of objects in this theory -/
  α : Type
  /-- The invariant function measuring complexity/depth/dimension -/
  inv : α → ℕ
  /-- A predicate selecting "meaningful" or "valid" elements -/
  Witness : α → Prop
  /-- A certified lower bound on the invariant for all witnesses -/
  lowerBound : ℕ
  /-- Soundness: every witness achieves the lower bound -/
  sound : ∀ x, Witness x → lowerBound ≤ inv x

/-! ## §2. Theory Morphisms -/

/-- A **theory morphism** from S to T is a function on carriers that
    preserves the witness predicate and is monotone on invariants. -/
structure TheoryHom (S T : TheorySpec) where
  /-- The underlying function on carriers -/
  map : S.α → T.α
  /-- Witness preservation: witnesses map to witnesses -/
  preservesWitness : ∀ {x}, S.Witness x → T.Witness (map x)
  /-- Invariant monotonicity: the invariant cannot decrease -/
  monotoneInv : ∀ x, S.inv x ≤ T.inv (map x)

/-! ## §3. Transport Theorems -/

/-- **Transport theorem**: every certified theory morphism transports all
    lower-bound information encoded in the source theory. If x is a witness
    in S, then f(x) achieves the source lower bound in the target theory. -/
theorem TheoryHom.transport_witness
    {S T : TheorySpec} (f : TheoryHom S T) :
    ∀ x, S.Witness x → S.lowerBound ≤ T.inv (f.map x) :=
  fun x hw => le_trans (S.sound x hw) (f.monotoneInv x)

/-- **Transport with target bound**: if the source lower bound is at most
    the target lower bound, witnesses transport with the source bound. -/
theorem TheoryHom.transport_lowerBound
    {S T : TheorySpec} (f : TheoryHom S T) :
    S.lowerBound ≤ T.lowerBound →
    ∀ x, S.Witness x → S.lowerBound ≤ T.inv (f.map x) :=
  fun _ x hw => f.transport_witness x hw

/-! ## §4. Category Structure -/

/-- Extensionality for theory morphisms. -/
@[ext]
theorem TheoryHom.ext {S T : TheorySpec}
    {f g : TheoryHom S T} (h : f.map = g.map) : f = g := by
  cases f; cases g; simp_all

/-- The identity morphism on a theory specification. -/
def TheoryHom.id (S : TheorySpec) : TheoryHom S S where
  map := _root_.id
  preservesWitness := fun hw => hw
  monotoneInv := fun _ => le_refl _

/-- Composition of theory morphisms. -/
def TheoryHom.comp {A B C : TheorySpec}
    (g : TheoryHom B C) (f : TheoryHom A B) : TheoryHom A C where
  map := g.map ∘ f.map
  preservesWitness := fun hw => g.preservesWitness (f.preservesWitness hw)
  monotoneInv := fun x => le_trans (f.monotoneInv x) (g.monotoneInv (f.map x))

/-- **Composition is associative**. -/
theorem TheoryHom.comp_assoc
    {A B C D : TheorySpec}
    (f : TheoryHom A B) (g : TheoryHom B C) (h : TheoryHom C D) :
    (h.comp g).comp f = h.comp (g.comp f) := by
  ext; rfl

/-- Left identity law. -/
theorem TheoryHom.id_comp {S T : TheorySpec} (f : TheoryHom S T) :
    f.comp (TheoryHom.id S) = f := by
  ext; rfl

/-- Right identity law. -/
theorem TheoryHom.comp_id {S T : TheorySpec} (f : TheoryHom S T) :
    (TheoryHom.id T).comp f = f := by
  ext; rfl

/-! ## §5. Composed Transport -/

/-- **Transport through composed morphisms**: witnesses transport along
    chains of morphisms. This is the formal heart of indirect bridge discovery. -/
theorem TheoryHom.transport_witness_comp
    {A B C : TheorySpec}
    (f : TheoryHom A B) (g : TheoryHom B C) :
    ∀ x, A.Witness x → A.lowerBound ≤ C.inv ((g.comp f).map x) :=
  (g.comp f).transport_witness

/-- **Three-step transport**: witnesses survive three-step compositions. -/
theorem TheoryHom.transport_witness_comp₃
    {A B C D : TheorySpec}
    (f : TheoryHom A B) (g : TheoryHom B C) (h : TheoryHom C D) :
    ∀ x, A.Witness x → A.lowerBound ≤ D.inv ((h.comp (g.comp f)).map x) :=
  (h.comp (g.comp f)).transport_witness

/-! ## §6. Lower Bound Transfer -/

/-- A theory spec **satisfies** its lower bound existentially if there exists
    a witness. -/
def TheorySpec.hasWitness (S : TheorySpec) : Prop :=
  ∃ x, S.Witness x

/-- **Existential transfer**: if S has a witness and there is a morphism to T,
    then T has an element achieving S's lower bound. -/
theorem TheoryHom.transfer_exists
    {S T : TheorySpec} (f : TheoryHom S T)
    (hw : S.hasWitness) :
    ∃ y : T.α, S.lowerBound ≤ T.inv y := by
  obtain ⟨x, hx⟩ := hw
  exact ⟨f.map x, f.transport_witness x hx⟩

/-! ## §7. Domination Preorder -/

/-- Theory S is dominated by T if there exists a morphism S → T. -/
def TheorySpec.dominatedBy (S T : TheorySpec) : Prop :=
  Nonempty (TheoryHom S T)

theorem TheorySpec.dominatedBy_refl (S : TheorySpec) :
    S.dominatedBy S :=
  ⟨TheoryHom.id S⟩

theorem TheorySpec.dominatedBy_trans {S T U : TheorySpec} :
    S.dominatedBy T → T.dominatedBy U → S.dominatedBy U := by
  rintro ⟨f⟩ ⟨g⟩
  exact ⟨g.comp f⟩

/-! ## §8. Bounded Depth and Gap Theorem -/

/-- A theory has bounded depth n if every element has invariant ≤ n. -/
def TheorySpec.hasBoundedInv (S : TheorySpec) (n : ℕ) : Prop :=
  ∀ x, S.inv x ≤ n

/-- **Gap theorem**: if S has a witness but T has bounded invariant below
    S's lower bound, no morphism S → T exists. -/
theorem TheorySpec.no_morphism_of_gap
    {S T : TheorySpec}
    (hw : S.hasWitness)
    (hbound : T.hasBoundedInv (S.lowerBound - 1))
    (hpos : 0 < S.lowerBound) :
    IsEmpty (TheoryHom S T) := by
  constructor
  intro f
  obtain ⟨x, hx⟩ := hw
  have h1 := f.transport_witness x hx
  have h2 := hbound (f.map x)
  omega

/-! ## §9. Coproduct -/

/-- Coproduct of theory specifications. -/
def TheorySpec.coprod (S T : TheorySpec) : TheorySpec where
  α := S.α ⊕ T.α
  inv := fun | .inl x => S.inv x | .inr y => T.inv y
  Witness := fun | .inl x => S.Witness x | .inr y => T.Witness y
  lowerBound := min S.lowerBound T.lowerBound
  sound := by
    intro x hx
    match x, hx with
    | .inl a, ha => exact le_trans (Nat.min_le_left _ _) (S.sound a ha)
    | .inr b, hb => exact le_trans (Nat.min_le_right _ _) (T.sound b hb)

/-- Left injection into coproduct. -/
def TheorySpec.coprod_inl (S T : TheorySpec) : TheoryHom S (S.coprod T) where
  map := Sum.inl
  preservesWitness := fun hw => hw
  monotoneInv := fun _ => le_refl _

/-- Right injection into coproduct. -/
def TheorySpec.coprod_inr (S T : TheorySpec) : TheoryHom T (S.coprod T) where
  map := Sum.inr
  preservesWitness := fun hw => hw
  monotoneInv := fun _ => le_refl _

/-! ## §10. Product -/

/-- Product of theory specifications. -/
def TheorySpec.prod (S T : TheorySpec) : TheorySpec where
  α := S.α × T.α
  inv := fun p => S.inv p.1 + T.inv p.2
  Witness := fun p => S.Witness p.1 ∧ T.Witness p.2
  lowerBound := S.lowerBound + T.lowerBound
  sound := fun ⟨x, y⟩ ⟨hx, hy⟩ => Nat.add_le_add (S.sound x hx) (T.sound y hy)

/-- Left projection from product is monotone when the product invariant
    uses max instead of sum. Here we provide a weaker version: the
    projection maps (x,y) to x, and the product invariant S.inv x + T.inv y
    is always ≥ S.inv x. -/
def TheorySpec.prod_fst_witness (S T : TheorySpec) :
    ∀ (p : (S.prod T).α), (S.prod T).Witness p → S.Witness p.1 :=
  fun ⟨_, _⟩ hw => hw.1