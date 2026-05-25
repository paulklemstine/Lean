/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# A Locally Preordered 2-Category of Research Theories

This file constructs the 2-dimensional semantics of theory translation.
Research theories (carrier + ℕ-valued invariant) form the objects of a
locally preordered 2-category, where:

- **0-cells** are `ResearchTheory` instances,
- **1-cells** are `OrderedTheoryHom` morphisms (invariant-monotone and
  invariant-order-preserving maps),
- **2-cells** `OrderedTheoryHom2 f g` witness that morphism `g` uniformly
  dominates `f` at the invariant level.

## Mathematical discovery

Horizontal composition of 2-cells is NOT automatically valid for plain
`TheoryHom`: the axiom `∀ x, T.Inv x ≤ U.Inv (f.toFun x)` only relates
source and target invariants, but does not ensure that the function preserves
the invariant *order* on the target carrier. We isolate the precise
strengthening: `OrderedTheoryHom`, which adds
`inv_action_monotone : ∀ a b, T.Inv a ≤ T.Inv b → U.Inv (toFun a) ≤ U.Inv (toFun b)`.

We also observe that a **terminal object** does not exist in full generality
in this category. The monotonicity condition `T.Inv x ≤ U.Inv (f x)` requires
the target to have large enough invariants, so no single theory can receive a
morphism from every theory. Instead, we construct the **initial object**
(empty carrier) and a **canonical least embedding** into the universal `NatTheory`.

## Cross-domain connections

- **Category theory**: hom-preorders yield an order-enriched category / thin bicategory.
- **Abstract interpretation**: 2-cells compare approximations.
- **Program semantics**: interpretations as compilers, 2-cells as optimization certificates.
- **Proof theory**: one encoding dominates another if it certifies higher invariants.
-/

import Mathlib
import Bridges.TheoryMorphisms

/-! ## §1. 2-Cells: Pointwise Invariant Domination -/

/-- A **2-cell** `TheoryHom2 f g` witnesses that morphism `g` uniformly
    dominates `f` at the invariant level: for every source element `x`,
    the invariant of `g(x)` is at least that of `f(x)` in the target. -/
def TheoryHom2 {T U : ResearchTheory} (f g : TheoryHom T U) : Prop :=
  ∀ x : T.Carrier, U.Inv (f.toFun x) ≤ U.Inv (g.toFun x)

/-! ## §2. Vertical Composition and Identity of 2-Cells -/

theorem TheoryHom2.refl {T U : ResearchTheory} (f : TheoryHom T U) :
    TheoryHom2 f f :=
  fun _ => le_refl _

theorem TheoryHom2.trans {T U : ResearchTheory} {f g h : TheoryHom T U} :
    TheoryHom2 f g → TheoryHom2 g h → TheoryHom2 f h :=
  fun hfg hgh x => le_trans (hfg x) (hgh x)

/-! ## §3. Right-Whiskering for plain TheoryHom -/

/-- Post-composition preserves 2-cells for plain `TheoryHom`. -/
theorem TheoryHom2.whisker_left_plain {T U V : ResearchTheory}
    (h : TheoryHom T U)
    {f₂ g₂ : TheoryHom U V} (hfg : TheoryHom2 f₂ g₂) :
    TheoryHom2 (TheoryHom.comp h f₂) (TheoryHom.comp h g₂) :=
  fun x => hfg (h.toFun x)

/-! ## §4. Ordered Theory Morphisms -/

/-- An **ordered theory morphism** strengthens `TheoryHom` with invariant
    order preservation: if `T.Inv a ≤ T.Inv b` then
    `U.Inv (f a) ≤ U.Inv (f b)`. This is the precise condition needed
    for horizontal composition of 2-cells. -/
structure OrderedTheoryHom (T U : ResearchTheory) extends TheoryHom T U where
  inv_action_monotone : ∀ a b : T.Carrier,
    T.Inv a ≤ T.Inv b → U.Inv (toFun a) ≤ U.Inv (toFun b)

@[ext]
theorem OrderedTheoryHom.ext' {T U : ResearchTheory}
    {f g : OrderedTheoryHom T U} (h : f.toFun = g.toFun) : f = g := by
  cases f; cases g; simp only [mk.injEq]; exact TheoryHom.ext h

def OrderedTheoryHom.id (T : ResearchTheory) : OrderedTheoryHom T T where
  toFun := _root_.id
  monotone_inv := fun _ => le_refl _
  inv_action_monotone := fun _ _ h => h

def OrderedTheoryHom.comp {T U V : ResearchTheory}
    (f : OrderedTheoryHom T U) (g : OrderedTheoryHom U V) :
    OrderedTheoryHom T V where
  toFun := g.toFun ∘ f.toFun
  monotone_inv := fun x => le_trans (f.monotone_inv x) (g.monotone_inv (f.toFun x))
  inv_action_monotone := fun _ _ hab =>
    g.inv_action_monotone _ _ (f.inv_action_monotone _ _ hab)

theorem OrderedTheoryHom.comp_assoc {T U V W : ResearchTheory}
    (f : OrderedTheoryHom T U) (g : OrderedTheoryHom U V) (h : OrderedTheoryHom V W) :
    OrderedTheoryHom.comp (OrderedTheoryHom.comp f g) h =
      OrderedTheoryHom.comp f (OrderedTheoryHom.comp g h) := by
  apply ext'; rfl

theorem OrderedTheoryHom.id_comp {T U : ResearchTheory} (f : OrderedTheoryHom T U) :
    OrderedTheoryHom.comp (OrderedTheoryHom.id T) f = f := by
  apply ext'; rfl

theorem OrderedTheoryHom.comp_id {T U : ResearchTheory} (f : OrderedTheoryHom T U) :
    OrderedTheoryHom.comp f (OrderedTheoryHom.id U) = f := by
  apply ext'; rfl

/-! ## §5. 2-Cells for Ordered Morphisms -/

def OrderedTheoryHom2 {T U : ResearchTheory}
    (f g : OrderedTheoryHom T U) : Prop :=
  ∀ x : T.Carrier, U.Inv (f.toFun x) ≤ U.Inv (g.toFun x)

theorem OrderedTheoryHom2.refl {T U : ResearchTheory}
    (f : OrderedTheoryHom T U) : OrderedTheoryHom2 f f :=
  fun _ => le_refl _

theorem OrderedTheoryHom2.trans {T U : ResearchTheory}
    {f g h : OrderedTheoryHom T U} :
    OrderedTheoryHom2 f g → OrderedTheoryHom2 g h → OrderedTheoryHom2 f h :=
  fun hfg hgh x => le_trans (hfg x) (hgh x)

/-! ## §6. Horizontal Composition of 2-Cells -/

/-- Left-whiskering: pre-composing with an ordered morphism preserves 2-cells. -/
theorem OrderedTheoryHom2.whisker_left {T U V : ResearchTheory}
    (f : OrderedTheoryHom T U)
    {g₁ g₂ : OrderedTheoryHom U V} (hg : OrderedTheoryHom2 g₁ g₂) :
    OrderedTheoryHom2 (OrderedTheoryHom.comp f g₁) (OrderedTheoryHom.comp f g₂) :=
  fun x => hg (f.toFun x)

/-- Right-whiskering: post-composing with an ordered morphism preserves 2-cells,
    using the `inv_action_monotone` field. -/
theorem OrderedTheoryHom2.whisker_right {T U V : ResearchTheory}
    {f₁ f₂ : OrderedTheoryHom T U} (hf : OrderedTheoryHom2 f₁ f₂)
    (g : OrderedTheoryHom U V) :
    OrderedTheoryHom2 (OrderedTheoryHom.comp f₁ g) (OrderedTheoryHom.comp f₂ g) :=
  fun x => g.inv_action_monotone _ _ (hf x)

/-- **Full horizontal composition**: given 2-cells `f₁ ≤ g₁ : T → U` and
    `f₂ ≤ g₂ : U → V`, deduce `f₂ ∘ f₁ ≤ g₂ ∘ g₁ : T → V`. -/
theorem OrderedTheoryHom2.hcomp
    {T U V : ResearchTheory}
    {f₁ g₁ : OrderedTheoryHom T U} {f₂ g₂ : OrderedTheoryHom U V}
    (h₁ : OrderedTheoryHom2 f₁ g₁) (h₂ : OrderedTheoryHom2 f₂ g₂) :
    OrderedTheoryHom2 (OrderedTheoryHom.comp f₁ f₂) (OrderedTheoryHom.comp g₁ g₂) :=
  fun x => le_trans (h₂ (f₁.toFun x)) (g₂.inv_action_monotone _ _ (h₁ x))

/-! ## §7. Interchange Law -/

/-- The 2-categorical interchange law: composing vertically then horizontally
    gives the same result as composing horizontally then vertically. -/
theorem OrderedTheoryHom2.interchange
    {T U V : ResearchTheory}
    {f₁ f₂ f₃ : OrderedTheoryHom T U}
    {g₁ g₂ g₃ : OrderedTheoryHom U V}
    (hf₁₂ : OrderedTheoryHom2 f₁ f₂)
    (hf₂₃ : OrderedTheoryHom2 f₂ f₃)
    (hg₁₂ : OrderedTheoryHom2 g₁ g₂)
    (hg₂₃ : OrderedTheoryHom2 g₂ g₃) :
    OrderedTheoryHom2
      (OrderedTheoryHom.comp f₁ g₁)
      (OrderedTheoryHom.comp f₃ g₃) :=
  OrderedTheoryHom2.hcomp
    (OrderedTheoryHom2.trans hf₁₂ hf₂₃)
    (OrderedTheoryHom2.trans hg₁₂ hg₂₃)

/-! ## §8. Hom-Categories are Preorders -/

instance TheoryHom.instPreorder' {T U : ResearchTheory} :
    Preorder (TheoryHom T U) where
  le f g := TheoryHom2 f g
  le_refl f := TheoryHom2.refl f
  le_trans _ _ _ := TheoryHom2.trans

theorem TheoryHom.le_def {T U : ResearchTheory} {f g : TheoryHom T U} :
    f ≤ g ↔ TheoryHom2 f g :=
  Iff.rfl

/-- Antisymmetry holds when the target invariant is injective. -/
theorem TheoryHom.antisymm_of_inv_injective {T U : ResearchTheory}
    (hInj : Function.Injective U.Inv)
    {f g : TheoryHom T U}
    (hfg : f ≤ g) (hgf : g ≤ f) : f = g := by
  ext x; exact hInj (le_antisymm (hfg x) (hgf x))

instance OrderedTheoryHom.instPreorder' {T U : ResearchTheory} :
    Preorder (OrderedTheoryHom T U) where
  le f g := OrderedTheoryHom2 f g
  le_refl f := OrderedTheoryHom2.refl f
  le_trans _ _ _ := OrderedTheoryHom2.trans

/-- Composition is monotone in the right argument. -/
theorem OrderedTheoryHom.comp_monotone_right' {T U V : ResearchTheory}
    (f : OrderedTheoryHom T U) :
    Monotone (fun g : OrderedTheoryHom U V => OrderedTheoryHom.comp f g) :=
  fun _ _ hg => OrderedTheoryHom2.whisker_left f hg

/-- Composition is monotone in the left argument. -/
theorem OrderedTheoryHom.comp_monotone_left' {T U V : ResearchTheory}
    (g : OrderedTheoryHom U V) :
    Monotone (fun f : OrderedTheoryHom T U => OrderedTheoryHom.comp f g) :=
  fun _ _ hf => OrderedTheoryHom2.whisker_right hf g

/-! ## §9. Initial Theory -/

/-- The initial theory has empty carrier. There is a unique morphism
    FROM it to any theory (vacuously satisfying all conditions). -/
def InitialTheory : ResearchTheory where
  Carrier := Empty
  Inv := Empty.elim

def fromInitial (T : ResearchTheory) : TheoryHom InitialTheory T where
  toFun := Empty.elim
  monotone_inv := fun x => x.elim

theorem fromInitial_unique (T : ResearchTheory)
    (f : TheoryHom InitialTheory T) :
    f = fromInitial T := by
  ext x; exact x.elim

instance initial_hom_subsingleton (T : ResearchTheory) :
    Subsingleton (TheoryHom InitialTheory T) :=
  ⟨fun f g => (fromInitial_unique T f).trans (fromInitial_unique T g).symm⟩

/-- 2-cells from the initial theory are trivially true. -/
theorem TheoryHom2_fromInitial (T : ResearchTheory)
    (f g : TheoryHom InitialTheory T) :
    TheoryHom2 f g :=
  fun x => x.elim

/-- The initial theory also admits ordered morphisms. -/
def OrderedTheoryHom.fromInitial (T : ResearchTheory) :
    OrderedTheoryHom InitialTheory T where
  toFun := Empty.elim
  monotone_inv := fun x => x.elim
  inv_action_monotone := fun a _ _ => a.elim

/-! ## §10. Canonical Embedding into NatTheory -/

/-- The natural number theory: carrier ℕ with identity invariant.
    Every theory embeds canonically into it. -/
def NatTheory : ResearchTheory where
  Carrier := ℕ
  Inv := _root_.id

/-- Canonical embedding of any theory T into NatTheory via the invariant. -/
def toNatTheory (T : ResearchTheory) : TheoryHom T NatTheory where
  toFun := T.Inv
  monotone_inv := fun _ => le_refl _

/-- The canonical embedding is the *least* morphism into NatTheory:
    any other morphism maps to values at least as large. -/
theorem toNatTheory_least (T : ResearchTheory)
    (f : TheoryHom T NatTheory) :
    TheoryHom2 (toNatTheory T) f := by
  intro x
  exact f.monotone_inv x

/-! ## §11. Nontrivial Example: Two Distinct Morphisms with a 2-Cell -/

/-- Source theory: Bool carrier with invariant values 1 and 2. -/
private def SrcEx : ResearchTheory where
  Carrier := Bool
  Inv := fun b => bif b then 2 else 1

/-- Target theory: Bool carrier with invariant values 5 and 10. -/
private def TgtEx : ResearchTheory where
  Carrier := Bool
  Inv := fun b => bif b then 10 else 5

/-- Low morphism: maps everything to `false` (invariant 5). -/
private def mLow : TheoryHom SrcEx TgtEx where
  toFun := fun _ => false
  monotone_inv := by intro x; cases x <;> simp [SrcEx, TgtEx]

/-- High morphism: maps everything to `true` (invariant 10). -/
private def mHigh : TheoryHom SrcEx TgtEx where
  toFun := fun _ => true
  monotone_inv := by intro x; cases x <;> simp [SrcEx, TgtEx]

/-- **Nontrivial 2-cell**: `mLow ≤₂ mHigh` (invariant 5 ≤ 10 everywhere).
    This demonstrates that 2-cells are not vacuous. -/
theorem TheoryHom2.nontrivial_example :
    TheoryHom2 mLow mHigh := by
  intro x; simp [mLow, mHigh, TgtEx]

/-- The two morphisms are genuinely different functions. -/
theorem morphism_low_ne_high : mLow ≠ mHigh := by
  intro h
  have := congr_fun (congr_arg TheoryHom.toFun h) false
  simp [mLow, mHigh] at this

/-- The 2-cell is strict: `mHigh ≰₂ mLow` (10 > 5). -/
theorem TheoryHom2.strict_example :
    ¬ TheoryHom2 mHigh mLow := by
  intro h
  have := h false
  simp [mLow, mHigh, TgtEx] at this

/-! ## §12. Locally Thin Bicategory Structure -/

/-- Bundle of all axioms for a locally preordered (thin) bicategory. -/
structure LocallyThinBicategoryData where
  /-- 0-cells -/
  Obj : Type 1
  /-- 1-cells -/
  Hom : Obj → Obj → Type
  /-- 2-cells as a preorder on hom-sets -/
  homPreorder : ∀ X Y : Obj, Preorder (Hom X Y)
  /-- Identity 1-cell -/
  id : ∀ X : Obj, Hom X X
  /-- Composition of 1-cells -/
  comp : ∀ {X Y Z : Obj}, Hom X Y → Hom Y Z → Hom X Z
  /-- Left unit law -/
  id_comp : ∀ {X Y : Obj} (f : Hom X Y), comp (id X) f = f
  /-- Right unit law -/
  comp_id : ∀ {X Y : Obj} (f : Hom X Y), comp f (id Y) = f
  /-- Associativity -/
  comp_assoc : ∀ {X Y Z W : Obj} (f : Hom X Y) (g : Hom Y Z) (h : Hom Z W),
    comp (comp f g) h = comp f (comp g h)
  /-- Horizontal composition is monotone in the left argument -/
  comp_mono_left : ∀ {X Y Z : Obj} (g : Hom Y Z)
    {f₁ f₂ : Hom X Y}, (homPreorder X Y).le f₁ f₂ →
    (homPreorder X Z).le (comp f₁ g) (comp f₂ g)
  /-- Horizontal composition is monotone in the right argument -/
  comp_mono_right : ∀ {X Y Z : Obj} (f : Hom X Y)
    {g₁ g₂ : Hom Y Z}, (homPreorder Y Z).le g₁ g₂ →
    (homPreorder X Z).le (comp f g₁) (comp f g₂)

/-- **Main theorem**: Research theories with ordered morphisms form a
    locally thin bicategory. All category laws hold definitionally,
    and composition is monotone in both arguments via whiskering. -/
noncomputable def researchTheoryBicategory : LocallyThinBicategoryData where
  Obj := ResearchTheory
  Hom := OrderedTheoryHom
  homPreorder := fun _ _ => OrderedTheoryHom.instPreorder'
  id := OrderedTheoryHom.id
  comp := fun f g => OrderedTheoryHom.comp f g
  id_comp := fun f => OrderedTheoryHom.id_comp f
  comp_id := fun f => OrderedTheoryHom.comp_id f
  comp_assoc := fun f g h => OrderedTheoryHom.comp_assoc f g h
  comp_mono_left := by
    intro X Y Z g₀ f₁ f₂ hf₀
    exact OrderedTheoryHom2.whisker_right hf₀ g₀
  comp_mono_right := by
    intro X Y Z f₀ g₁ g₂ hg₀
    exact OrderedTheoryHom2.whisker_left f₀ hg₀

/-- The bicategory satisfies the interchange law. -/
theorem researchTheoryBicategory_interchange
    {T U V : ResearchTheory}
    {f₁ f₂ f₃ : OrderedTheoryHom T U}
    {g₁ g₂ g₃ : OrderedTheoryHom U V}
    (hf₁₂ : OrderedTheoryHom2 f₁ f₂)
    (hf₂₃ : OrderedTheoryHom2 f₂ f₃)
    (hg₁₂ : OrderedTheoryHom2 g₁ g₂)
    (hg₂₃ : OrderedTheoryHom2 g₂ g₃) :
    OrderedTheoryHom2
      (OrderedTheoryHom.comp f₁ g₁)
      (OrderedTheoryHom.comp f₃ g₃) :=
  OrderedTheoryHom2.interchange hf₁₂ hf₂₃ hg₁₂ hg₂₃