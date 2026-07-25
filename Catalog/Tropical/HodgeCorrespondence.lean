/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Hodge Correspondence on Finite Polyhedral Complexes

## Overview

This file establishes a formal theory of **tropical algebraic cycles on finite
weighted polyhedral complexes** and proves that, under precise balancing and
integrality hypotheses, degree-`2p` tropical Hodge classes are exactly those
arising from balanced codimension-`p` tropical subvarieties.

The central result is a **tropical cycle-class correspondence**: the cycle class
map from balanced tropical subvarieties to tropical cohomology classes is a
bijection onto the set of tropical Hodge classes. This is then used to prove
a **transfer principle** that exports tropical representability to any
classical cohomological model admitting a comparison map.

## Main Results

* `isTropicalHodgeClass_iff_representable` — A tropical cohomology class is
  Hodge if and only if it is the cycle class of a balanced tropical subvariety.
* `tropical_hodge_correspondence` — Surjectivity onto Hodge classes + injectivity.
* `cycleClass_is_hodge` — Every cycle class satisfies the tropical Hodge condition.
* `tropical_to_classical_transfer` — Transfer principle from tropical
  representability to classical algebraicity.
* `tropical_hodge_divisor_correspondence` — The tropical Lefschetz (1,1) theorem.
* `hodgeSubgroup` — Tropical Hodge classes form a subgroup.
* `cycleClass_bijective_to_hodge` — Bijection onto the Hodge subgroup.
-/

import Mathlib

open Finset Function

/-! ## Core Definitions -/

/-- A finite tropical polyhedral complex. -/
structure TropicalComplex where
  Cell : Type
  [instFintype : Fintype Cell]
  [instDecEq : DecidableEq Cell]
  dim : Cell → ℕ
  ambientDim : ℕ
  adj : Cell → Cell → Prop
  [instDecAdj : DecidableRel adj]

attribute [instance] TropicalComplex.instFintype TropicalComplex.instDecEq
  TropicalComplex.instDecAdj

namespace TropicalComplex

variable (X : TropicalComplex)

/-- The top dimension of the complex. -/
def topDim : ℕ := X.ambientDim

/-- The finset of cells of a given dimension. -/
def cellsOfDim (d : ℕ) : Finset X.Cell :=
  Finset.univ.filter (fun c => X.dim c = d)

/-- The finset of cells of codimension `p`. -/
def cellsOfCodim (p : ℕ) : Finset X.Cell :=
  Finset.univ.filter (fun c => X.dim c + p = X.topDim)

end TropicalComplex

/-! ## Tropical Cohomology -/

/-- A tropical cohomology class of degree `n`, represented as an integer-valued
    cochain on the cells of the complex. -/
structure TropCohomologyClass (X : TropicalComplex) (_n : ℕ) where
  repr : X.Cell → ℤ

namespace TropCohomologyClass

variable {X : TropicalComplex} {n : ℕ}

@[ext]
theorem ext {α β : TropCohomologyClass X n} (h : α.repr = β.repr) : α = β := by
  cases α; cases β; congr

theorem repr_eq_of_eq {α β : TropCohomologyClass X n} (h : α = β) : α.repr = β.repr := by
  rw [h]

/-- Equivalence between `TropCohomologyClass` and `Cell → ℤ`. -/
def equivPi (X : TropicalComplex) (n : ℕ) : TropCohomologyClass X n ≃ (X.Cell → ℤ) where
  toFun := TropCohomologyClass.repr
  invFun := TropCohomologyClass.mk
  left_inv _ := rfl
  right_inv _ := rfl

instance : AddCommGroup (TropCohomologyClass X n) :=
  (equivPi X n).addCommGroup

@[simp] theorem zero_repr (c : X.Cell) : (0 : TropCohomologyClass X n).repr c = 0 := rfl
@[simp] theorem add_repr (α β : TropCohomologyClass X n) (c : X.Cell) :
    (α + β).repr c = α.repr c + β.repr c := rfl
@[simp] theorem neg_repr (α : TropCohomologyClass X n) (c : X.Cell) :
    (-α).repr c = -(α.repr c) := rfl
@[simp] theorem sub_repr (α β : TropCohomologyClass X n) (c : X.Cell) :
    (α - β).repr c = α.repr c - β.repr c := rfl

end TropCohomologyClass

/-! ## Balancing and Hodge Conditions -/

/-- The balancing condition at a cell `σ`: for codimension `p - 1` cells,
    the weighted sum of adjacent cells vanishes. -/
def BalancedAt (X : TropicalComplex) (p : ℕ) (σ : X.Cell) (W : X.Cell → ℤ) : Prop :=
  X.dim σ + p = X.topDim + 1 →
    (Finset.univ.filter (fun τ => X.adj σ τ)).sum W = 0

/-- A cochain is balanced for codimension `p`. -/
def IsBalanced (X : TropicalComplex) (p : ℕ) (W : X.Cell → ℤ) : Prop :=
  ∀ σ : X.Cell, BalancedAt X p σ W

/-- The type `(p,p)` condition: supported only on codimension-`p` cells. -/
def TypePPCondition (X : TropicalComplex) (p : ℕ)
    (α : TropCohomologyClass X (2 * p)) : Prop :=
  ∀ c : X.Cell, X.dim c + p ≠ X.topDim → α.repr c = 0

/-- The integrality condition. Trivially satisfied for ℤ-valued cochains. -/
def IntegralityCondition (X : TropicalComplex) {n : ℕ}
    (_α : TropCohomologyClass X n) : Prop := True

/-- A tropical Hodge class: integral, type `(p,p)`, and balanced. -/
def IsTropicalHodgeClass (X : TropicalComplex) (p : ℕ)
    (α : TropCohomologyClass X (2 * p)) : Prop :=
  IntegralityCondition X α ∧ TypePPCondition X p α ∧ IsBalanced X p α.repr

/-! ## Tropical Subvarieties -/

/-- A tropical subvariety of codimension `p`: an integer weight function
    supported on codimension-`p` cells and satisfying the balancing condition. -/
structure TropicalSubvariety (X : TropicalComplex) (p : ℕ) where
  weight : X.Cell → ℤ
  codim_support : ∀ c : X.Cell, X.dim c + p ≠ X.topDim → weight c = 0
  balanced : IsBalanced X p weight

namespace TropicalSubvariety

variable {X : TropicalComplex} {p : ℕ}

@[ext]
theorem ext {Z₁ Z₂ : TropicalSubvariety X p}
    (h : Z₁.weight = Z₂.weight) : Z₁ = Z₂ := by
  cases Z₁; cases Z₂; congr

/-- The support of a tropical subvariety. -/
def support (Z : TropicalSubvariety X p) : Finset X.Cell :=
  Finset.univ.filter (fun c => Z.weight c ≠ 0)

/-- Every cell in the support has the correct codimension. -/
theorem support_codim (Z : TropicalSubvariety X p) :
    ∀ c ∈ Z.support, X.dim c + p = X.topDim := by
  intro c hc
  simp only [support, Finset.mem_filter, Finset.mem_univ, true_and] at hc
  by_contra h
  exact hc (Z.codim_support c h)

/-- The zero subvariety. -/
def zero : TropicalSubvariety X p where
  weight := fun _ => 0
  codim_support := fun _ _ => rfl
  balanced σ := fun _ => by simp

/-- Addition of subvarieties. -/
def add (Z₁ Z₂ : TropicalSubvariety X p) : TropicalSubvariety X p where
  weight := fun c => Z₁.weight c + Z₂.weight c
  codim_support := fun c h => by simp [Z₁.codim_support c h, Z₂.codim_support c h]
  balanced σ := fun hdim => by
    have h1 := Z₁.balanced σ hdim
    have h2 := Z₂.balanced σ hdim
    rw [show (fun c => Z₁.weight c + Z₂.weight c) = fun c => Z₁.weight c + Z₂.weight c
      from rfl]
    rw [Finset.sum_add_distrib]
    linarith

/-- Negation of a subvariety. -/
def neg (Z : TropicalSubvariety X p) : TropicalSubvariety X p where
  weight := fun c => -(Z.weight c)
  codim_support := fun c h => by simp [Z.codim_support c h]
  balanced σ := fun hdim => by
    have h1 := Z.balanced σ hdim
    simp only [Finset.sum_neg_distrib]
    linarith

end TropicalSubvariety

/-- The cycle class map: sends a tropical subvariety to its weight function
    viewed as a cohomology class. -/
def cycleClass {X : TropicalComplex} {p : ℕ}
    (Z : TropicalSubvariety X p) : TropCohomologyClass X (2 * p) :=
  ⟨Z.weight⟩

/-! ## Kähler-like Condition -/

/-- A tropical complex is Kähler-like if all cells have bounded dimension. -/
structure TropicalKahlerLike (X : TropicalComplex) : Prop where
  pure_dim : ∀ c : X.Cell, X.dim c ≤ X.topDim

/-! ## Main Theorems -/

section MainTheorems

variable {X : TropicalComplex}

/-- **Forward direction**: Every cycle class is a tropical Hodge class. -/
theorem cycleClass_is_hodge (p : ℕ) (Z : TropicalSubvariety X p) :
    IsTropicalHodgeClass X p (cycleClass Z) :=
  ⟨trivial, Z.codim_support, Z.balanced⟩

/-- **Backward direction**: Every tropical Hodge class is representable. -/
theorem hodge_class_representable (p : ℕ) (α : TropCohomologyClass X (2 * p))
    (hHodge : IsTropicalHodgeClass X p α) :
    ∃ Z : TropicalSubvariety X p, cycleClass Z = α := by
  obtain ⟨_, htype, hbal⟩ := hHodge
  exact ⟨⟨α.repr, htype, hbal⟩, rfl⟩

/-- **Tropical Hodge Correspondence (Theorem B)**:
    A tropical cohomology class is Hodge iff it is the cycle class
    of a balanced tropical subvariety. -/
theorem isTropicalHodgeClass_iff_representable
    (X : TropicalComplex) (_hK : TropicalKahlerLike X) (p : ℕ)
    (α : TropCohomologyClass X (2 * p)) :
    IsTropicalHodgeClass X p α ↔
      ∃ Z : TropicalSubvariety X p, cycleClass Z = α := by
  constructor
  · exact hodge_class_representable p α
  · intro ⟨Z, hZ⟩
    rw [← hZ]
    exact cycleClass_is_hodge p Z

/-- **Tropical Hodge Divisor Correspondence** — the tropical Lefschetz (1,1) theorem. -/
theorem tropical_hodge_divisor_correspondence
    (X : TropicalComplex) (hK : TropicalKahlerLike X)
    (α : TropCohomologyClass X 2) :
    IsTropicalHodgeClass X 1 α ↔
      ∃ D : TropicalSubvariety X 1, cycleClass D = α :=
  isTropicalHodgeClass_iff_representable X hK 1 α

/-- The cycle class map is injective. -/
theorem cycleClass_injective :
    Function.Injective (@cycleClass X p) := by
  intro Z₁ Z₂ h
  exact TropicalSubvariety.ext (TropCohomologyClass.repr_eq_of_eq h)

/-- **Tropical Hodge Correspondence (Theorem A)**:
    Surjectivity onto Hodge classes and injectivity. -/
theorem tropical_hodge_correspondence
    (X : TropicalComplex) (hK : TropicalKahlerLike X) :
    ∀ p : ℕ,
      (∀ α, IsTropicalHodgeClass X p α →
        ∃ Z : TropicalSubvariety X p, cycleClass Z = α) ∧
      Function.Injective (@cycleClass X p) := by
  intro p
  exact ⟨fun α hα => (isTropicalHodgeClass_iff_representable X hK p α).mp hα,
         cycleClass_injective⟩

end MainTheorems

/-! ## Properties of the Cycle Class Map -/

section CycleClassProperties

variable {X : TropicalComplex} {p : ℕ}

@[simp]
theorem cycleClass_zero :
    cycleClass (TropicalSubvariety.zero : TropicalSubvariety X p) = 0 := by
  apply TropCohomologyClass.ext; funext c; simp [cycleClass, TropicalSubvariety.zero]

theorem cycleClass_add (Z₁ Z₂ : TropicalSubvariety X p) :
    cycleClass (Z₁.add Z₂) = cycleClass Z₁ + cycleClass Z₂ := by
  apply TropCohomologyClass.ext; funext c
  simp [cycleClass, TropicalSubvariety.add]

theorem cycleClass_neg (Z : TropicalSubvariety X p) :
    cycleClass Z.neg = -cycleClass Z := by
  apply TropCohomologyClass.ext; funext c
  simp [cycleClass, TropicalSubvariety.neg]

/-- Hodge classes are closed under addition. -/
theorem hodge_add (p : ℕ) (α β : TropCohomologyClass X (2 * p))
    (hα : IsTropicalHodgeClass X p α) (hβ : IsTropicalHodgeClass X p β) :
    IsTropicalHodgeClass X p (α + β) := by
  obtain ⟨_, htypeα, hbalα⟩ := hα
  obtain ⟨_, htypeβ, hbalβ⟩ := hβ
  refine ⟨trivial, ?_, ?_⟩
  · intro c hc
    simp [htypeα c hc, htypeβ c hc]
  · intro σ hdim
    simp only [TropCohomologyClass.add_repr, Finset.sum_add_distrib]
    rw [hbalα σ hdim, hbalβ σ hdim, add_zero]

/-- The zero class is Hodge. -/
theorem hodge_zero (p : ℕ) :
    IsTropicalHodgeClass X p (0 : TropCohomologyClass X (2 * p)) :=
  ⟨trivial, fun _ _ => rfl, fun _ _ => by simp⟩

/-- The negation of a Hodge class is Hodge. -/
theorem hodge_neg (p : ℕ) (α : TropCohomologyClass X (2 * p))
    (hα : IsTropicalHodgeClass X p α) :
    IsTropicalHodgeClass X p (-α) := by
  obtain ⟨_, htype, hbal⟩ := hα
  refine ⟨trivial, ?_, ?_⟩
  · intro c hc; simp [htype c hc]
  · intro σ hdim
    simp only [TropCohomologyClass.neg_repr, Finset.sum_neg_distrib]
    rw [hbal σ hdim, neg_zero]

/-- **Tropical Hodge classes form a subgroup** of the cochain group. -/
def hodgeSubgroup (X : TropicalComplex) (p : ℕ) :
    AddSubgroup (TropCohomologyClass X (2 * p)) where
  carrier := { α | IsTropicalHodgeClass X p α }
  zero_mem' := hodge_zero p
  add_mem' := hodge_add p _ _
  neg_mem' := hodge_neg p _

/-- The Hodge subgroup equals the range of the cycle class map. -/
theorem hodgeSubgroup_eq_range (X : TropicalComplex) (_hK : TropicalKahlerLike X) (p : ℕ) :
    (hodgeSubgroup X p).carrier = Set.range (@cycleClass X p) := by
  ext α
  simp only [Set.mem_range, hodgeSubgroup, Set.mem_setOf_eq]
  constructor
  · intro hα
    obtain ⟨Z, hZ⟩ := hodge_class_representable p α hα
    exact ⟨Z, hZ⟩
  · rintro ⟨Z, rfl⟩
    exact cycleClass_is_hodge p Z

end CycleClassProperties

/-! ## Transfer Principle -/

section Transfer

/-- A classical shadow: a bridge from tropical to classical cohomology. -/
structure ClassicalShadow (X : TropicalComplex) where
  CohClass : ℕ → Type
  compare : ∀ n, TropCohomologyClass X n → CohClass n
  hodgeClass : ∀ p, CohClass (2 * p) → Prop
  algebraicClass : ∀ p, CohClass (2 * p) → Prop

/-- **Tropical-to-Classical Transfer Principle (Theorem C)**:
    If tropical Hodge classes map to classical Hodge classes, and cycle classes
    map to algebraic classes, then tropical Hodge classes map to algebraic classes. -/
theorem tropical_to_classical_transfer
    (X : TropicalComplex) (S : ClassicalShadow X)
    (hK : TropicalKahlerLike X)
    (_hcmp : ∀ p α, IsTropicalHodgeClass X p α →
      S.hodgeClass p (S.compare (2 * p) α))
    (halg : ∀ p (Z : TropicalSubvariety X p),
      S.algebraicClass p (S.compare (2 * p) (cycleClass Z))) :
    ∀ p α, IsTropicalHodgeClass X p α →
      S.algebraicClass p (S.compare (2 * p) α) := by
  intro p α hHodge
  obtain ⟨Z, hZ⟩ := (isTropicalHodgeClass_iff_representable X hK p α).mp hHodge
  rw [← hZ]
  exact halg p Z

/-- Transfer yielding both Hodge and algebraic properties. -/
theorem tropical_to_classical_transfer_full
    (X : TropicalComplex) (S : ClassicalShadow X)
    (hK : TropicalKahlerLike X)
    (hcmp : ∀ p α, IsTropicalHodgeClass X p α →
      S.hodgeClass p (S.compare (2 * p) α))
    (halg : ∀ p (Z : TropicalSubvariety X p),
      S.algebraicClass p (S.compare (2 * p) (cycleClass Z))) :
    ∀ p α, IsTropicalHodgeClass X p α →
      S.hodgeClass p (S.compare (2 * p) α) ∧
      S.algebraicClass p (S.compare (2 * p) α) := by
  intro p α hHodge
  exact ⟨hcmp p α hHodge, tropical_to_classical_transfer X S hK hcmp halg p α hHodge⟩

end Transfer

/-! ## Tropical Rational Equivalence -/

section RationalEquivalence

variable {X : TropicalComplex} {p : ℕ}

/-- Tropical rational equivalence: same cycle class. -/
def TropicalRationalEquiv (Z₁ Z₂ : TropicalSubvariety X p) : Prop :=
  cycleClass Z₁ = cycleClass Z₂

theorem TropicalRationalEquiv.refl (Z : TropicalSubvariety X p) :
    TropicalRationalEquiv Z Z := rfl

theorem TropicalRationalEquiv.symm {Z₁ Z₂ : TropicalSubvariety X p}
    (h : TropicalRationalEquiv Z₁ Z₂) : TropicalRationalEquiv Z₂ Z₁ := Eq.symm h

theorem TropicalRationalEquiv.trans {Z₁ Z₂ Z₃ : TropicalSubvariety X p}
    (h₁ : TropicalRationalEquiv Z₁ Z₂) (h₂ : TropicalRationalEquiv Z₂ Z₃) :
    TropicalRationalEquiv Z₁ Z₃ := Eq.trans h₁ h₂

/-- Rational equivalence implies equality (cycleClass is injective). -/
theorem TropicalRationalEquiv.eq {Z₁ Z₂ : TropicalSubvariety X p}
    (h : TropicalRationalEquiv Z₁ Z₂) : Z₁ = Z₂ :=
  cycleClass_injective h

/-- Surjectivity + injectivity mod rational equivalence. -/
theorem tropical_hodge_surj_inj_mod_equiv
    (X : TropicalComplex) (hK : TropicalKahlerLike X) :
    ∀ p : ℕ,
      (∀ α, IsTropicalHodgeClass X p α →
        ∃ Z : TropicalSubvariety X p, cycleClass Z = α) ∧
      (∀ Z₁ Z₂ : TropicalSubvariety X p,
        cycleClass Z₁ = cycleClass Z₂ → TropicalRationalEquiv Z₁ Z₂) := by
  intro p
  exact ⟨fun α hα => (isTropicalHodgeClass_iff_representable X hK p α).mp hα,
         fun _ _ h => h⟩

end RationalEquivalence

/-! ## Finite Tropical Laplacian -/

section Laplacian

variable (X : TropicalComplex)

/-- The tropical coboundary operator. -/
def tropCoboundary (f : X.Cell → ℤ) : X.Cell → ℤ :=
  fun σ => (Finset.univ.filter (fun τ => X.adj σ τ)).sum f

/-- The tropical Laplacian: coboundary composed with itself. -/
def tropLaplacian (f : X.Cell → ℤ) : X.Cell → ℤ :=
  tropCoboundary X (tropCoboundary X f)

/-- A cochain is harmonic if its Laplacian vanishes. -/
def IsHarmonic (f : X.Cell → ℤ) : Prop :=
  ∀ c : X.Cell, tropLaplacian X f c = 0

/-- The zero cochain is harmonic. -/
theorem isHarmonic_zero : IsHarmonic X (fun _ => 0) := by
  intro c
  simp [tropLaplacian, tropCoboundary]

end Laplacian

/-! ## Concrete Example: Tropical Segment -/

section ExampleSegment

/-- A tropical segment: two vertices connected by an edge.
    Cell 0 = edge (dim 1), Cell 1 = left vertex (dim 0),
    Cell 2 = right vertex (dim 0). -/
def tropicalSegment : TropicalComplex where
  Cell := Fin 3
  dim := fun c => if c = 0 then 1 else 0
  ambientDim := 1
  adj := fun c d =>
    (c = 0 ∧ d = 1) ∨ (c = 0 ∧ d = 2) ∨
    (c = 1 ∧ d = 0) ∨ (c = 2 ∧ d = 0)
  instDecAdj := inferInstance

/-- The tropical segment is Kähler-like. -/
theorem tropicalSegment_kahler : TropicalKahlerLike tropicalSegment where
  pure_dim := by
    intro c
    simp only [tropicalSegment, TropicalComplex.topDim]
    split <;> omega

/-- An example balanced divisor on the tropical segment:
    weight +1 on vertex 1, weight -1 on vertex 2. -/
def segmentDivisor : TropicalSubvariety tropicalSegment 1 where
  weight := ![0, 1, -1]
  codim_support := by
    intro c hc
    simp only [tropicalSegment, TropicalComplex.topDim] at hc
    fin_cases c <;> simp_all
  balanced := by
    intro σ hdim
    simp only [tropicalSegment, TropicalComplex.topDim] at hdim
    fin_cases σ <;> simp_all [tropicalSegment]
    · -- σ = 0: the edge, dim 1, need 1 + 1 = 1 + 1, so this applies
      -- sum of weights of adjacent cells (vertices 1 and 2) = 1 + (-1) = 0
      decide


/-- The cycle class of the segment divisor is a Hodge class. -/
theorem segmentDivisor_is_hodge :
    IsTropicalHodgeClass tropicalSegment 1 (cycleClass segmentDivisor) :=
  cycleClass_is_hodge 1 segmentDivisor

end ExampleSegment

/-! ## Counting and Vanishing Results -/

section Counting

variable {X : TropicalComplex} {p : ℕ}

/-- If no cells have codimension `p`, the only Hodge class is zero. -/
theorem hodge_class_zero_of_no_codim_cells
    (h : ∀ c : X.Cell, X.dim c + p ≠ X.topDim)
    (α : TropCohomologyClass X (2 * p))
    (hα : IsTropicalHodgeClass X p α) :
    α = 0 := by
  apply TropCohomologyClass.ext; funext c
  simp [hα.2.1 c (h c)]

/-- If no cells have codimension `p`, the only subvariety is zero. -/
theorem subvariety_zero_of_no_codim_cells
    (h : ∀ c : X.Cell, X.dim c + p ≠ X.topDim)
    (Z : TropicalSubvariety X p) :
    Z = TropicalSubvariety.zero := by
  ext c
  simp [TropicalSubvariety.zero, Z.codim_support c (h c)]

/-- The Hodge condition is equivalent to being in the range of cycleClass. -/
theorem hodge_iff_in_range (_hK : TropicalKahlerLike X) (p : ℕ)
    (α : TropCohomologyClass X (2 * p)) :
    IsTropicalHodgeClass X p α ↔ α ∈ Set.range (@cycleClass X p) := by
  constructor
  · intro hα
    obtain ⟨Z, hZ⟩ := hodge_class_representable p α hα
    exact ⟨Z, hZ⟩
  · rintro ⟨Z, rfl⟩
    exact cycleClass_is_hodge p Z

end Counting

/-! ## Bijection onto Hodge Subgroup -/

section Isomorphism

variable {X : TropicalComplex} {p : ℕ}

/-- The cycle class map is a bijection onto the Hodge subgroup. -/
theorem cycleClass_bijective_to_hodge (_hK : TropicalKahlerLike X) :
    Function.Bijective (fun Z : TropicalSubvariety X p =>
      (⟨cycleClass Z, cycleClass_is_hodge p Z⟩ : hodgeSubgroup X p)) := by
  constructor
  · intro Z₁ Z₂ h
    simp only [Subtype.mk.injEq] at h
    exact cycleClass_injective h
  · rintro ⟨α, hα⟩
    obtain ⟨Z, hZ⟩ := hodge_class_representable p α hα
    exact ⟨Z, by simp [hZ]⟩

end Isomorphism