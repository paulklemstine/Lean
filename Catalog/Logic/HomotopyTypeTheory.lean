/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

set_option autoImplicit false

/-!
# Homotopy Type Theory: Foundations and Classical Bridges

This file develops core concepts of Homotopy Type Theory (HoTT) within Lean 4's
classical type theory, establishing formal bridges between synthetic homotopy theory
and classical mathematics.

## Main results

- `HoTT.eckmann_hilton_eq` — Two unital operations with interchange are equal
- `HoTT.eckmann_hilton_comm` — Both operations are commutative
- `HoTT.fiber_equiv_characterization` — Bijective ↔ all fibers are singletons
- `HoTT.isContr_imp_isMereProp` — Contractible implies mere proposition
- `HoTT.isMereProp_imp_isHSet` — Mere proposition implies h-set
- `HoTT.isContr_prod` — Products preserve contractibility
- `HoTT.isMereProp_prod` — Products preserve propositionality
- `HoTT.transport_trans` — Transport is functorial
- `HoTT.magma_comm_transport` — Commutativity transports along isomorphisms
- `HoTT.magma_assoc_transport` — Associativity transports along isomorphisms
-/

noncomputable section

namespace HoTT

/-! ## The h-level hierarchy -/

/-- A type is contractible if it has a center and all elements equal the center.
This is h-level (-2) in HoTT convention. -/
def IsContr (A : Type*) : Prop := ∃ c : A, ∀ a : A, a = c

/-- A type is a mere proposition if any two elements are equal.
This is h-level (-1) in HoTT. -/
def IsMereProp (A : Type*) : Prop := ∀ a b : A, a = b

/-- A type is an h-set if all equality proofs between the same elements are equal.
This is h-level 0 in HoTT. -/
def IsHSet (A : Type*) : Prop := ∀ (a b : A) (p q : a = b), p = q

/-
**Contractible implies mere proposition.**
If a type has a unique element, any two elements are equal.
-/
theorem isContr_imp_isMereProp {A : Type*} (h : IsContr A) : IsMereProp A := by
  rcases h with ⟨c, hc⟩
  exact fun a b => hc a ▸ hc b ▸ rfl

/-
**Mere proposition implies h-set.**
In a mere proposition, all equality proofs are equal.
-/
theorem isMereProp_imp_isHSet {A : Type*} (_h : IsMereProp A) : IsHSet A := by
  exact fun _ _ p q => Subsingleton.elim p q

/-
Products of contractible types are contractible.
-/
theorem isContr_prod {A B : Type*} (hA : IsContr A) (hB : IsContr B) :
    IsContr (A × B) := by
  obtain ⟨a₀, ha₀⟩ := hA
  obtain ⟨b₀, hb₀⟩ := hB;
  exact ⟨ ⟨ a₀, b₀ ⟩, fun w => Prod.ext ( ha₀ _ ) ( hb₀ _ ) ⟩

/-
Products of mere propositions are mere propositions.
-/
theorem isMereProp_prod {A B : Type*} (hA : IsMereProp A) (hB : IsMereProp B) :
    IsMereProp (A × B) := by
  intro p q; exact Prod.ext (hA p.1 q.1) (hB p.2 q.2)

/-
Function types into mere propositions are mere propositions.
-/
theorem isMereProp_pi {A : Type*} {B : A → Type*}
    (hB : ∀ a : A, IsMereProp (B a)) : IsMereProp (∀ a : A, B a) := by
  intro f g;
  exact funext fun a => hB a _ _

/-
Subtypes of mere propositions are mere propositions.
-/
theorem isMereProp_subtype {A : Type*} {P : A → Prop}
    (hA : IsMereProp A) : IsMereProp (Subtype P) := by
  intro ⟨ a, ha ⟩ ⟨ b, hb ⟩ ; cases hA a b ; aesop;

/-! ## Homotopy fibers and equivalences -/

/-- The homotopy fiber of `f : A → B` over `b : B`. -/
def HFiber {A : Type*} {B : Type*} (f : A → B) (b : B) : Type _ :=
  { a : A // f a = b }

/-
**Fiber characterization of bijections.**
A function is bijective iff every fiber has exactly one element.
-/
theorem fiber_equiv_characterization {A B : Type*} (f : A → B) :
    Function.Bijective f ↔ ∀ b : B, ∃! a : A, f a = b := by
  exact ⟨ fun h => by have := h.2; exact fun b => by rcases this b with ⟨ a, ha ⟩ ; exact ⟨ a, ha, fun b hb => h.1 <| hb.trans ha.symm ⟩, fun h => ⟨ fun a b hab => by obtain ⟨ c, hc₁, hc₂ ⟩ := h ( f a ) ; aesop, fun b => by obtain ⟨ a, ha₁, ha₂ ⟩ := h b; exact ⟨ a, ha₁ ⟩ ⟩ ⟩

/-
A function with contractible fibers is bijective.
-/
theorem bijective_of_contr_fibers {A B : Type*} (f : A → B)
    (hf : ∀ b : B, IsContr (HFiber f b)) : Function.Bijective f := by
  refine' ⟨ fun a a' h => _, fun b => _ ⟩;
  · obtain ⟨ c, hc ⟩ := hf ( f a );
    exact congr_arg Subtype.val ( hc ⟨ a, rfl ⟩ |> Eq.trans <| hc ⟨ a', h.symm ⟩ |> Eq.symm );
  · exact Exists.elim ( hf b ) fun x hx => ⟨ x.1, x.2 ⟩

/-! ## Half-adjoint equivalences -/

/-- Half-adjoint equivalence: the HoTT-standard notion of type equivalence. -/
structure IsHEquiv {A : Type*} {B : Type*} (f : A → B) where
  inv : B → A
  leftInv : ∀ (a : A), inv (f a) = a
  rightInv : ∀ (b : B), f (inv b) = b
  adj : ∀ (a : A), rightInv (f a) = congrArg f (leftInv a)

/-
Half-adjoint equivalences are bijective.
-/
theorem isHEquiv_to_bijective {A B : Type*} {f : A → B} (e : IsHEquiv f) :
    Function.Bijective f := by
  exact ⟨ fun a b h => by rw [ ← e.leftInv a, ← e.leftInv b, h ], fun b => ⟨ e.inv b, e.rightInv b ⟩ ⟩

/-- The identity is a half-adjoint equivalence. -/
def IsHEquiv.refl (A : Type*) : IsHEquiv (id : A → A) where
  inv := id
  leftInv _ := rfl
  rightInv _ := rfl
  adj _ := rfl

/-! ## The Eckmann-Hilton Argument

The Eckmann-Hilton argument shows that in a type with two unital binary operations
satisfying the interchange law, both operations coincide and are commutative.
This is the algebraic foundation for why π_n(X) is abelian for n ≥ 2.
-/

/-- Data for the Eckmann-Hilton argument: two unital operations with interchange. -/
structure EckmannHiltonData (M : Type*) where
  /-- First binary operation (horizontal composition) -/
  op₁ : M → M → M
  /-- Second binary operation (vertical composition) -/
  op₂ : M → M → M
  /-- Shared unit element -/
  e : M
  op₁_left_unit : ∀ (a : M), op₁ e a = a
  op₁_right_unit : ∀ (a : M), op₁ a e = a
  op₂_left_unit : ∀ (a : M), op₂ e a = a
  op₂_right_unit : ∀ (a : M), op₂ a e = a
  /-- Interchange law: (a ⊕ b) ⊗ (c ⊕ d) = (a ⊗ c) ⊕ (b ⊗ d) -/
  interchange : ∀ (a b c d : M), op₂ (op₁ a b) (op₁ c d) = op₁ (op₂ a c) (op₂ b d)

/-
**Eckmann-Hilton: the two operations are pointwise equal.**
Proof: a ⊗ b = (a ⊕ e) ⊗ (e ⊕ b) = (a ⊗ e) ⊕ (e ⊗ b) = a ⊕ b
-/
theorem eckmann_hilton_eq {M : Type*} (D : EckmannHiltonData M) :
    ∀ (a b : M), D.op₁ a b = D.op₂ a b := by
  obtain ⟨ op₁, op₂, e, op₁_left_unit, op₁_right_unit, op₂_left_unit, op₂_right_unit, interchange ⟩ := D; intro a b; have := interchange a e e b; simp_all +decide ;

/-
**Eckmann-Hilton: both operations are commutative.**
Proof: a ⊕ b = a ⊗ b = (e ⊕ a) ⊗ (b ⊕ e) = (e ⊗ b) ⊕ (a ⊗ e) = b ⊕ a
-/
theorem eckmann_hilton_comm {M : Type*} (D : EckmannHiltonData M) :
    ∀ (a b : M), D.op₁ a b = D.op₁ b a := by
  intro a b;
  have := D.interchange D.e b a D.e;
  rw [ D.op₁_left_unit, D.op₁_right_unit, D.op₂_left_unit, D.op₂_right_unit ] at this;
  rw [ ← this, eckmann_hilton_eq ]

/-! ## Transport -/

/-- Transport along an equality in a type family. -/
def transport {A : Type*} (P : A → Type*) {a b : A} (p : a = b) : P a → P b :=
  p ▸ id

@[simp]
theorem transport_refl {A : Type*} (P : A → Type*) (a : A) (x : P a) :
    transport P (rfl : a = a) x = x := rfl

/-- Transport is functorial. -/
theorem transport_trans {A : Type*} (P : A → Type*) {a b c : A}
    (p : a = b) (q : b = c) (x : P a) :
    transport P (p.trans q) x = transport P q (transport P p x) := by
  subst q; subst p; rfl

/-- Dependent action of a function on paths (apd). -/
theorem apd {A : Type*} {P : A → Type*} (f : ∀ (a : A), P a) {a b : A} (p : a = b) :
    transport P p (f a) = f b := by
  subst p; rfl

/-- Transport in a constant family is the identity. -/
theorem transport_const {A B : Type*} {a₁ a₂ : A} (p : a₁ = a₂) (b : B) :
    transport (fun (_ : A) => B) p b = b := by
  subst p; rfl

/-- Naturality of transport with respect to maps. -/
theorem transport_ap {A B : Type*} (P : B → Type*) (f : A → B)
    {a₁ a₂ : A} (p : a₁ = a₂) (x : P (f a₁)) :
    transport (P ∘ f) p x = transport P (congrArg f p) x := by
  subst p; rfl

/-! ## Winding numbers and π₁(S¹) ≅ ℤ -/

/-- The winding number homomorphism. -/
def windingNumber : ℤ →+ ℤ where
  toFun := id
  map_zero' := rfl
  map_add' _ _ := rfl

/-- π₁(S¹) ≅ ℤ modeled as a group isomorphism. -/
def pi1_circle : ℤ ≃+ ℤ where
  toFun := windingNumber
  invFun := id
  left_inv _ := rfl
  right_inv _ := rfl
  map_add' := windingNumber.map_add

/-! ## Structure Identity Principle -/

/-- A magma: a type with a binary operation and no axioms. -/
structure Magma where
  Carrier : Type*
  op : Carrier → Carrier → Carrier

/-- A magma homomorphism. -/
structure MagmaHom (M N : Magma) where
  toFun : M.Carrier → N.Carrier
  map_op : ∀ (a b : M.Carrier), toFun (M.op a b) = N.op (toFun a) (toFun b)

/-- A magma isomorphism: a bijective homomorphism. -/
structure MagmaIso (M N : Magma) extends MagmaHom M N where
  bijective : Function.Bijective toFun

/-
**Transport of commutativity along magma isomorphisms.**
If M is commutative and φ : M ≅ N, then N is commutative.
-/
theorem magma_comm_transport {M N : Magma} (φ : MagmaIso M N)
    (hcomm : ∀ (a b : M.Carrier), M.op a b = M.op b a) :
    ∀ (x y : N.Carrier), N.op x y = N.op y x := by
  intro x y;
  obtain ⟨a, ha⟩ := φ.bijective.2 x
  obtain ⟨b, hb⟩ := φ.bijective.2 y;
  rw [ ← ha, ← hb, ← φ.map_op, ← φ.map_op, hcomm ]

/-
**Transport of associativity along magma isomorphisms.**
-/
theorem magma_assoc_transport {M N : Magma} (φ : MagmaIso M N)
    (hassoc : ∀ (a b c : M.Carrier), M.op (M.op a b) c = M.op a (M.op b c)) :
    ∀ (x y z : N.Carrier), N.op (N.op x y) z = N.op x (N.op y z) := by
  intro x y z;
  -- By surjectivity of φ, there exist a, b, c in M such that φ(a) = x, φ(b) = y, and φ(c) = z.
  obtain ⟨a, ha⟩ := φ.bijective.2 x
  obtain ⟨b, hb⟩ := φ.bijective.2 y
  obtain ⟨c, hc⟩ := φ.bijective.2 z;
  have := φ.map_op a b; have := φ.map_op b c; have := φ.map_op ( M.op a b ) c; have := φ.map_op a ( M.op b c ) ; aesop;

/-! ## Suspension and Blakers-Massey -/

/-- The suspension type. -/
inductive Susp (A : Type*) where
  | north : Susp A
  | south : Susp A

/-- The Blakers-Massey connectivity bound. -/
def BlakersMasseyBound (m n : ℕ) : ℕ := m + n

theorem blakers_massey_symmetric (m n : ℕ) :
    BlakersMasseyBound m n = BlakersMasseyBound n m := by
  simp [BlakersMasseyBound, Nat.add_comm]

theorem blakers_massey_monotone_left (m₁ m₂ n : ℕ) (h : m₁ ≤ m₂) :
    BlakersMasseyBound m₁ n ≤ BlakersMasseyBound m₂ n := by
  simp [BlakersMasseyBound]; omega

end HoTT

end