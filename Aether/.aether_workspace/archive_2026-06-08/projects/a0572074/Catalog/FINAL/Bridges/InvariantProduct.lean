/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Categorical Products for Invariant-Bearing Systems

This file establishes that systems equipped with a complexity/energy/valuation
functional form a category with genuine categorical products.

## Main Results

- `InvObj`: A structure pairing a carrier type with an invariant map `Inv : Carrier → α`.
- `InvHom`: Morphisms that are non-increasing with respect to invariants.
- `prodObj`: The product object using `max` on invariants.
- `prod_universal`: The full universal property of the categorical product.
- `max_prod_is_initial`: `max` is the least invariant making both projections morphisms.

## Mathematical Significance

The `max` invariant on products is not an arbitrary choice — it is the *optimal*
categorical product invariant for order-controlled morphisms:
- In thermodynamic language, `max` gives bottleneck energy.
- In automata theory, it models synchronized product complexity.
- In lattice reduction, it yields sup-norm height.
- In security, it tracks worst-case attack cost across composed protocols.

The universal property ensures that every future theorem about invariant-preserving
maps can be stated once and inherited by products automatically.
-/

import Mathlib

/-! ## Core Structures -/

/-- An invariant-bearing object: a carrier type with a valuation/energy/complexity map. -/
structure InvObj (α : Type*) where
  Carrier : Type*
  Inv : Carrier → α

/-- A morphism between invariant-bearing objects: a function that does not increase the invariant.
    The orientation `B.Inv (toFun x) ≤ A.Inv x` makes morphisms "energy-dissipating" or
    "complexity non-increasing", which is natural for security/energy/height bounds. -/
structure InvHom {α : Type*} [Preorder α] (A B : InvObj α) where
  toFun : A.Carrier → B.Carrier
  monotone_inv : ∀ x, B.Inv (toFun x) ≤ A.Inv x

/-! ## Extensionality -/

@[ext]
theorem InvHom.ext {α : Type*} [Preorder α] {A B : InvObj α}
    {f g : InvHom A B} (h : ∀ x, f.toFun x = g.toFun x) : f = g := by
  cases f; cases g; congr; exact funext h

/-! ## Identity and Composition -/

/-- The identity morphism on an invariant-bearing object. -/
def InvHom.id {α : Type*} [Preorder α] (A : InvObj α) : InvHom A A where
  toFun := _root_.id
  monotone_inv := fun _ => le_refl _

/-- Composition of invariant-bearing morphisms. -/
def InvHom.comp {α : Type*} [Preorder α] {A B C : InvObj α}
    (g : InvHom B C) (f : InvHom A B) : InvHom A C where
  toFun := g.toFun ∘ f.toFun
  monotone_inv := fun x => le_trans (g.monotone_inv (f.toFun x)) (f.monotone_inv x)

/-! ## Product Object -/

/-- The product of two invariant-bearing objects, with invariant given by `max`.
    This is the categorical product: `max` is the least invariant on `T × U`
    that makes both projections into morphisms. -/
def prodObj {α : Type*} [LinearOrder α] (T U : InvObj α) : InvObj α where
  Carrier := T.Carrier × U.Carrier
  Inv := fun p => max (T.Inv p.1) (U.Inv p.2)

/-! ## Projection Morphisms -/

/-- First projection from the product. The morphism condition holds because
    `T.Inv p.1 ≤ max (T.Inv p.1) (U.Inv p.2)`. -/
def fstHom {α : Type*} [LinearOrder α] (T U : InvObj α) :
    InvHom (prodObj T U) T where
  toFun := Prod.fst
  monotone_inv := fun _ => le_max_left _ _

/-- Second projection from the product. The morphism condition holds because
    `U.Inv p.2 ≤ max (T.Inv p.1) (U.Inv p.2)`. -/
def sndHom {α : Type*} [LinearOrder α] (T U : InvObj α) :
    InvHom (prodObj T U) U where
  toFun := Prod.snd
  monotone_inv := fun _ => le_max_right _ _

/-! ## Universal Pairing -/

/-- The universal lift into the product: given morphisms `f : S ⟶ T` and `g : S ⟶ U`,
    construct the unique morphism `S ⟶ T × U`. The invariant bound follows from
    `max_le` applied to the individual bounds `f.monotone_inv` and `g.monotone_inv`. -/
def prodLift {α : Type*} [LinearOrder α]
    {S T U : InvObj α} (f : InvHom S T) (g : InvHom S U) :
    InvHom S (prodObj T U) where
  toFun := fun x => (f.toFun x, g.toFun x)
  monotone_inv := fun x => max_le (f.monotone_inv x) (g.monotone_inv x)

/-! ## Commutation Laws -/

/-- First projection composed with the lift recovers `f`. -/
theorem fst_comp_prodLift {α : Type*} [LinearOrder α]
    {S T U : InvObj α} (f : InvHom S T) (g : InvHom S U) :
    ∀ x, (fstHom T U).toFun ((prodLift f g).toFun x) = f.toFun x := by
  intro x; rfl

/-- Second projection composed with the lift recovers `g`. -/
theorem snd_comp_prodLift {α : Type*} [LinearOrder α]
    {S T U : InvObj α} (f : InvHom S T) (g : InvHom S U) :
    ∀ x, (sndHom T U).toFun ((prodLift f g).toFun x) = g.toFun x := by
  intro x; rfl

/-! ## Uniqueness -/

/-
Any morphism into the product that agrees with `f` on first components and `g` on
    second components must equal `prodLift f g`. This is the uniqueness half of the
    universal property.
-/
theorem prodLift_unique {α : Type*} [LinearOrder α]
    {S T U : InvObj α} (f : InvHom S T) (g : InvHom S U)
    (h : InvHom S (prodObj T U))
    (hfst : ∀ x, (fstHom T U).toFun (h.toFun x) = f.toFun x)
    (hsnd : ∀ x, (sndHom T U).toFun (h.toFun x) = g.toFun x) :
    h = prodLift f g := by
  exact InvHom.ext fun x => by exact Prod.ext ( hfst x ) ( hsnd x ) ;

/-! ## Full Universal Property -/

/-
The full universal property of the categorical product: for any `S` with morphisms
    `f : S ⟶ T` and `g : S ⟶ U`, there exists a *unique* morphism `h : S ⟶ T × U`
    such that `π₁ ∘ h = f` and `π₂ ∘ h = g`.
-/
theorem prod_universal {α : Type*} [LinearOrder α]
    {S T U : InvObj α} (f : InvHom S T) (g : InvHom S U) :
    ∃! h : InvHom S (prodObj T U),
      (∀ x, (fstHom T U).toFun (h.toFun x) = f.toFun x) ∧
      (∀ x, (sndHom T U).toFun (h.toFun x) = g.toFun x) := by
  -- Apply the uniqueness result to conclude the proof.
  apply ExistsUnique.intro (prodLift f g);
  · exact ⟨ fst_comp_prodLift f g, snd_comp_prodLift f g ⟩;
  · -- Apply the uniqueness result to conclude the proof. If y satisfies the conditions, then by definition of prodLift, y must be equal to prodLift f g.
    intros y hy
    apply prodLift_unique f g y hy.left hy.right

/-! ## Extensionality for Product Morphisms -/

/-
Two morphisms into a product are equal if they agree on both components.
-/
theorem prod_hom_ext {α : Type*} [LinearOrder α]
    {S T U : InvObj α}
    {h k : InvHom S (prodObj T U)}
    (hfst : ∀ x, (h.toFun x).1 = (k.toFun x).1)
    (hsnd : ∀ x, (h.toFun x).2 = (k.toFun x).2) :
    h = k := by
  exact InvHom.ext fun x => Prod.ext ( hfst x ) ( hsnd x )

/-! ## Optimality of Max Invariant -/

/-
The `max` invariant is the *least* invariant on `T × U` making both projections
    into morphisms. This shows the product construction is not arbitrary but optimal:
    any other invariant that makes projections valid must dominate `max`.
-/
theorem max_prod_is_initial {α : Type*} [LinearOrder α]
    {T U : InvObj α}
    {I : T.Carrier × U.Carrier → α}
    (hfst : ∀ p, T.Inv p.1 ≤ I p)
    (hsnd : ∀ p, U.Inv p.2 ≤ I p) :
    ∀ p, max (T.Inv p.1) (U.Inv p.2) ≤ I p := by
  exact fun p => max_le ( hfst p ) ( hsnd p )

/-! ## Additive Product Variant -/

/-- The additive product of two invariant-bearing objects, with invariant given by `+`.
    This models independent energy accumulation rather than bottleneck cost. -/
def addProdObj {α : Type*} [Add α] (T U : InvObj α) : InvObj α where
  Carrier := T.Carrier × U.Carrier
  Inv := fun p => T.Inv p.1 + U.Inv p.2

/-
In an ordered additive monoid with canonical ordering, the additive invariant
    dominates each component, making both projections into morphisms.
-/
theorem add_prod_proj_bounds {α : Type*} [Preorder α] [AddCommMonoid α] [AddLeftMono α] [AddRightMono α]
    {T U : InvObj α} (hT : ∀ x, (0 : α) ≤ T.Inv x) (hU : ∀ x, (0 : α) ≤ U.Inv x)
    (p : T.Carrier × U.Carrier) :
    T.Inv p.1 ≤ T.Inv p.1 + U.Inv p.2 ∧
    U.Inv p.2 ≤ T.Inv p.1 + U.Inv p.2 := by
  exact ⟨le_add_of_nonneg_right (hU p.2), le_add_of_nonneg_left (hT p.1)⟩

/-! ## Comparison: Max vs Additive Product -/

/-
The `max` invariant is always dominated by the additive invariant when values are
    nonneg. This gives a comparison functor from max-products to additive-products.
-/
theorem max_le_add_inv {α : Type*} [LinearOrder α] [AddCommMonoid α] [AddLeftMono α] [AddRightMono α]
    {a b : α} (ha : 0 ≤ a) (hb : 0 ≤ b) :
    max a b ≤ a + b := by
  exact max_le ( le_add_of_nonneg_right hb ) ( le_add_of_nonneg_left ha )

/-! ## Category Laws -/

/-
Left identity for composition.
-/
theorem InvHom.id_comp {α : Type*} [Preorder α] {A B : InvObj α} (f : InvHom A B) :
    InvHom.comp (InvHom.id B) f = f := by
  exact InvHom.ext fun _ => rfl

/-
Right identity for composition.
-/
theorem InvHom.comp_id {α : Type*} [Preorder α] {A B : InvObj α} (f : InvHom A B) :
    InvHom.comp f (InvHom.id A) = f := by
  exact InvHom.ext fun _ => rfl

/-
Associativity of composition.
-/
theorem InvHom.comp_assoc {α : Type*} [Preorder α] {A B C D : InvObj α}
    (h : InvHom C D) (g : InvHom B C) (f : InvHom A B) :
    InvHom.comp (InvHom.comp h g) f = InvHom.comp h (InvHom.comp g f) := by
  exact InvHom.ext fun _ => rfl