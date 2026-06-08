/-
# HoTT Foundations: Core Definitions

Core definitions for a synthetic HoTT fragment in Lean 4:
- `Contractible`: data-carrying contractibility witness
- `Equiv'`: bespoke equivalence with computational content
- `IdentitySystem`: identity system via contractible total spaces
- `HProp'`: universe of h-propositions

## Relationship to catalog
- Strengthens `HoTT.isContr` (Prop-valued) to `Contractible` (data-valued)
- Provides `Equiv'` independent of Mathlib's `Equiv` for HoTT-style reasoning
- `IdentitySystem` is a genuinely new concept not in the catalog
-/

import Mathlib

universe u v w

namespace HoTTFound

/-! ## Contractible types -/

/-- A type is contractible if it has a center of contraction and every element
    is equal to that center. This is a data-carrying structure, not merely a
    proposition, enabling constructive extraction of witnesses. -/
structure Contractible (X : Sort u) where
  center : X
  contr : ∀ y : X, y = center

/-! ## Equivalences -/

/-- A bespoke equivalence structure with full computational content.
    Records forward map, inverse map, and both roundtrip equalities. -/
structure Equiv' (α : Sort u) (β : Sort v) where
  toFun : α → β
  invFun : β → α
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y

infixl:25 " ≃' " => Equiv'

namespace Equiv'

/-- The identity equivalence. -/
def refl (α : Sort u) : α ≃' α :=
  ⟨id, id, fun _ => rfl, fun _ => rfl⟩

/-- The inverse of an equivalence. -/
def symm {α : Sort u} {β : Sort v} (e : α ≃' β) : β ≃' α :=
  ⟨e.invFun, e.toFun, e.right_inv, e.left_inv⟩

/-- Composition of equivalences. -/
def trans {α : Sort u} {β : Sort v} {γ : Sort w}
    (e₁ : α ≃' β) (e₂ : β ≃' γ) : α ≃' γ where
  toFun := e₂.toFun ∘ e₁.toFun
  invFun := e₁.invFun ∘ e₂.invFun
  left_inv x := by simp [Function.comp]; rw [e₂.left_inv, e₁.left_inv]
  right_inv y := by simp [Function.comp]; rw [e₁.right_inv, e₂.right_inv]

end Equiv'

/-! ## Identity Systems -/

/-- An identity system on `A` based at `a₀` with family `R` consists of:
    - a reflexivity witness `rflR : R a₀`
    - a proof that the total space `Σ a, R a` is contractible

    This captures the HoTT idea that `R` behaves like the identity/path family
    from `a₀`. The fundamental theorem says this data yields an equivalence
    `(a₀ = a) ≃' R a` for all `a`. -/
structure IdentitySystem (A : Sort u) (a₀ : A) (R : A → Sort v) where
  rflR : R a₀
  contr_total : Contractible (Σ' a : A, R a)
  center_eq : contr_total.center = ⟨a₀, rflR⟩

/-! ## HProp: universe of propositions -/

/-- A universe of h-propositions (proof-irrelevant types).
    Equality in this universe corresponds to logical equivalence. -/
structure HProp' where
  carrier : Prop

/-- Logical equivalence between h-propositions. -/
def HPropEquiv (P Q : HProp') : Prop := P.carrier ↔ Q.carrier

/-! ## Basic lemmas about Contractible -/

/-- A contractible type is a subsingleton: any two elements are equal. -/
theorem contractible_subsingleton
    {X : Sort u} (h : Contractible X) : Subsingleton X :=
  ⟨fun a b => by rw [h.contr a, h.contr b]⟩

/-- PUnit is contractible. -/
def contractible_punit : Contractible PUnit :=
  ⟨PUnit.unit, fun y => by cases y; rfl⟩

/-- The based path space `Σ x, a₀ = x` is contractible. -/
def contractible_based_paths {A : Sort u} (a₀ : A) :
    Contractible (Σ' x : A, a₀ = x) :=
  ⟨⟨a₀, rfl⟩, fun ⟨x, p⟩ => by cases p; rfl⟩

/-- The based path space forms an identity system. -/
def pathIdentitySystem {A : Sort u} (a₀ : A) :
    IdentitySystem A a₀ (fun a => a₀ = a) where
  rflR := rfl
  contr_total := contractible_based_paths a₀
  center_eq := rfl

/-- Contractibility yields a concrete witness: we can extract the center. -/
def contractible_witness
    {A : Type u} {B : A → Type v}
    (h : Contractible (Sigma B)) :
    (a : A) × B a :=
  ⟨h.center.1, h.center.2⟩

/-- Contractible types have a unique element. -/
theorem contractible_unique {X : Sort u} (h : Contractible X) :
    ∀ x : X, x = h.center :=
  h.contr

end HoTTFound