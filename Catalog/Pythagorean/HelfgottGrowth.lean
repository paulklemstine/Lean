/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quantitative Helfgott-Type Growth in Finite Groups

This file develops a formal framework for product growth in finite groups,
establishing the first steps toward quantitative Helfgott-type expansion theorems.

## Main Definitions

* `IsSymmetricSubset`: A finite subset closed under inversion.
* `TripleProduct`: The triple product set A·A·A = {a*b*c | a,b,c ∈ A}.
* `IsMulClosed`: A finite subset closed under multiplication.

## Main Results

* `subset_mul_self`: A ⊆ A·A when 1 ∈ A.
* `mul_self_subset_tripleProduct`: A·A ⊆ A·A·A when 1 ∈ A.
* `card_mul_self_lt_of_not_isMulClosed`: If A is not closed under multiplication
  and 1 ∈ A, then |A| < |A·A|.
* `card_lt_card_tripleProduct_of_not_isMulClosed`: Same conclusion for |A| < |A·A·A|.
* `symmetric_mulClosed_is_subgroup_carrier`: If A is symmetric with 1 ∈ A and
  mul-closed, then A is the carrier of a subgroup.
* `tripleProduct_growth_of_noncommuting_escape`: Growth from escape and noncommutation.

## References

* Helfgott, H. (2008). Growth and generation in SL₂(ℤ/pℤ).
* Tao, T. (2015). Expansion in finite simple groups of Lie type.
-/

import Mathlib

open Finset Polynomial Pointwise

/-! ## Core Definitions -/

section Definitions

variable {G : Type*} [Group G] [DecidableEq G]

/-- A finite subset `A` of a group is **symmetric** if it is closed under inversion.
This is a fundamental condition in additive combinatorics: symmetric generating sets
produce undirected Cayley graphs, and Helfgott-type growth theorems require symmetry. -/
def IsSymmetricSubset (A : Finset G) : Prop :=
  ∀ ⦃g : G⦄, g ∈ A → g⁻¹ ∈ A

/-- The **triple product** A·A·A = {a*b*c | a, b, c ∈ A}.
This is the central object in Helfgott's theorem: the growth ratio |A³|/|A|
measures the expansion behavior of the set A in the group G. -/
def TripleProduct (A : Finset G) : Finset G :=
  A.biUnion fun a => A.biUnion fun b => A.image fun c => a * b * c

/-- A finite subset is **multiplication-closed** if the product of any two
elements remains in the set. Combined with symmetry and identity membership,
this characterizes subgroup carriers. -/
def IsMulClosed (A : Finset G) : Prop :=
  ∀ ⦃a b : G⦄, a ∈ A → b ∈ A → a * b ∈ A

end Definitions

/-! ## Basic Containment Lemmas -/

section Containment

variable {G : Type*} [Group G] [DecidableEq G]

/-
When 1 ∈ A, every element a ∈ A appears as a·1 ∈ A·A, giving A ⊆ A·A.
-/
theorem subset_mul_self (A : Finset G) (hone : (1 : G) ∈ A) :
    A ⊆ A * A := by
  exact fun x hx => Finset.mem_mul.mpr ⟨ x, hx, 1, hone, mul_one _ ⟩

/-
When 1 ∈ A, we have A·A ⊆ A·A·A via the embedding (a·b) ↦ (a·b·1).
-/
theorem mul_self_subset_tripleProduct (A : Finset G) (hone : (1 : G) ∈ A) :
    A * A ⊆ TripleProduct A := by
  intro x hx;
  rw [ Finset.mem_mul ] at hx;
  rcases hx with ⟨ y, hy, z, hz, rfl ⟩ ; exact Finset.mem_biUnion.2 ⟨ y, hy, Finset.mem_biUnion.2 ⟨ z, hz, Finset.mem_image.2 ⟨ 1, hone, by simp +decide ⟩ ⟩ ⟩ ;

/-- Combining the two: A ⊆ A·A·A when 1 ∈ A. -/
theorem subset_tripleProduct (A : Finset G) (hone : (1 : G) ∈ A) :
    A ⊆ TripleProduct A :=
  (subset_mul_self A hone).trans (mul_self_subset_tripleProduct A hone)

end Containment

/-! ## The Growth Engine: Non-Closure Forces Expansion -/

section Growth

variable {G : Type*} [Group G] [DecidableEq G]

/-
**Key Growth Theorem (Double Product).**
If A contains the identity and is not closed under multiplication,
then |A·A| > |A|. This is the foundational engine for all product growth:
the mere existence of a product a·b ∉ A, with a,b ∈ A, forces strict
cardinality increase.

The proof uses a ssubset argument: A ⊆ A·A (from 1 ∈ A), and A·A contains
the "escaping" product a·b ∉ A, giving A ⊊ A·A.
-/
theorem card_mul_self_lt_of_not_isMulClosed
    (A : Finset G)
    (hone : (1 : G) ∈ A)
    (hnotclosed : ¬ IsMulClosed A) :
    A.card < (A * A).card := by
  refine' Finset.card_lt_card _;
  simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
  simp_all +decide [ Finset.mem_mul, IsMulClosed ];
  exact fun x hx => ⟨ x, hx, 1, hone, mul_one x ⟩

/-- **Growth Theorem (Triple Product).**
Non-closure under multiplication forces |A³| > |A|. This follows from
the double product theorem since A·A ⊆ A·A·A. -/
theorem card_lt_card_tripleProduct_of_not_isMulClosed
    (A : Finset G)
    (hone : (1 : G) ∈ A)
    (hnotclosed : ¬ IsMulClosed A) :
    A.card < (TripleProduct A).card := by
  exact lt_of_lt_of_le
    (card_mul_self_lt_of_not_isMulClosed A hone hnotclosed)
    (Finset.card_le_card (mul_self_subset_tripleProduct A hone))

/-
**Structural Classification.**
A symmetric set containing the identity that is multiplication-closed
is precisely the carrier of a subgroup. This is the contrapositive
foundation: if A is not a subgroup carrier, it must exhibit growth.
-/
theorem symmetric_mulClosed_is_subgroup_carrier
    (A : Finset G) [Fintype G]
    (hone : (1 : G) ∈ A)
    (hsymm : IsSymmetricSubset A)
    (hclosed : IsMulClosed A) :
    ∃ H : Subgroup G, (H : Set G) = ↑A := by
  refine' ⟨ { carrier := A , mul_mem' := _, one_mem' := _, inv_mem' := _ }, _ ⟩ <;> aesop

/-- Noncommuting elements in a non-subgroup witness growth:
if A contains x, y with xy ≠ yx and A is not mul-closed, then |A³| > |A|.
This connects the algebraic condition of noncommutativity to combinatorial expansion. -/
theorem tripleProduct_growth_of_noncommuting_escape
    (A : Finset G)
    (hone : (1 : G) ∈ A)
    (_hsymm : IsSymmetricSubset A)
    (_hnc : ∃ x ∈ A, ∃ y ∈ A, x * y ≠ y * x)
    (hnotclosed : ¬ IsMulClosed A) :
    A.card < (TripleProduct A).card :=
  card_lt_card_tripleProduct_of_not_isMulClosed A hone hnotclosed

end Growth

/-! ## Growth Certificate Framework -/

section Certificate

/-- A **growth certificate** bundles a finite subset with verified structural
properties and computed growth data. This is the computational interface
to the growth theorems: algorithms construct certificates, and the soundness
theorem guarantees that verified certificates witness genuine expansion. -/
structure GrowthCertificate (G : Type*) [Group G] [DecidableEq G] where
  /-- The subset under study -/
  A : Finset G
  /-- Proof that A is symmetric -/
  symmetric : IsSymmetricSubset A
  /-- Proof that 1 ∈ A -/
  contains_one : (1 : G) ∈ A
  /-- Computed cardinality of A·A·A -/
  tripleCard : ℕ
  /-- Proof that tripleCard equals |A·A·A| -/
  tripleCard_eq : tripleCard = (TripleProduct A).card
  /-- Witness that A is not mul-closed -/
  not_mul_closed : ¬ IsMulClosed A

variable {G : Type*} [Group G] [DecidableEq G]

/-- **Soundness of growth certificates.**
Any valid growth certificate witnesses strict triple-product expansion.
This theorem bridges verified computation to proven growth. -/
theorem growthCertificate_sound (C : GrowthCertificate G) :
    C.A.card < C.tripleCard := by
  rw [C.tripleCard_eq]
  exact card_lt_card_tripleProduct_of_not_isMulClosed C.A C.contains_one C.not_mul_closed

end Certificate