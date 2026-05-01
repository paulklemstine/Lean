/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Symmetric Functions and the S₃ Weyl Group

## Overview

This file formalizes the **tropical Satake correspondence for GL₃**,
establishing that tropical elementary symmetric polynomials provide a
complete invariant for the action of the Weyl group S₃ on integer triples.

In the tropical semiring (ℤ, max, +), the elementary symmetric polynomials
are obtained from the classical ones by the substitution rule:
- Classical addition → tropical addition (= max)
- Classical multiplication → tropical multiplication (= +)

This gives: e₁(a,b,c) = max(a,b,c), e₂(a,b,c) = max(a+b, a+c, b+c),
and e₃(a,b,c) = a + b + c.

## Main Results

* `TropicalSatake.e₂_eq_sum_sub_min` - Key identity: e₂ = (a+b+c) - min(a,b,c)
* `TropicalSatake.separates_orbits` - **Tropical Chevalley Theorem**: The map
  (e₁, e₂, e₃) separates S₃-orbits — if two triples have the same tropical
  symmetric polynomials, they are permutations of each other.
* `TropicalSatake.image_characterization` - **Tropical Satake Cone**: The image
  of (e₁, e₂, e₃) is precisely {(x,y,z) : 2x ≥ y ∧ 2y ≥ x+z}, which is the
  dominant Weyl chamber for GL₃.
* `TropicalSatake.tropical_power_sum` - Tropical power sums satisfy p_k = k · e₁.

## Mathematical Significance

The classical Satake isomorphism identifies the spherical Hecke algebra of a
reductive group G over a non-archimedean local field with the representation ring
of the Langlands dual group. For G = GL₃, the Weyl group is S₃, and the
cocharacter lattice is ℤ³. In the tropical limit (as the residue field size q → 0),
the Hecke algebra structure tropicalizes, and the Satake isomorphism becomes the
correspondence formalized here: S₃-orbits on ℤ³ are classified by the tropical
elementary symmetric polynomials, with image the dominant Weyl chamber.

## References

* [Maclagan-Sturmfels, *Introduction to Tropical Geometry*]
* [Gross, *Tropical geometry and mirror symmetry*]
-/

namespace TropicalSatake

/-! ### Definitions -/

/-- First tropical elementary symmetric polynomial: e₁(a,b,c) = max(a, b, c).
    This is the tropicalization of the classical e₁ = a + b + c. -/
def e₁ (a b c : ℤ) : ℤ := max a (max b c)

/-- Second tropical elementary symmetric polynomial: e₂(a,b,c) = max(a+b, a+c, b+c).
    This is the tropicalization of the classical e₂ = ab + ac + bc. -/
def e₂ (a b c : ℤ) : ℤ := max (a + b) (max (a + c) (b + c))

/-- Third tropical elementary symmetric polynomial: e₃(a,b,c) = a + b + c.
    This is the tropicalization of the classical e₃ = abc. -/
def e₃ (a b c : ℤ) : ℤ := a + b + c

/-! ### S₃ Invariance

The tropical elementary symmetric polynomials are invariant under all permutations
of their arguments. We prove invariance under the two generators of S₃:
the transposition (12) and the 3-cycle (123). Together these generate all six
permutations.
-/

/-
e₁ is invariant under transposition of the first two arguments
-/
theorem e₁_swap12 (a b c : ℤ) : e₁ b a c = e₁ a b c := by
  unfold e₁; ac_rfl

/-
e₁ is invariant under cyclic permutation
-/
theorem e₁_cycle (a b c : ℤ) : e₁ b c a = e₁ a b c := by
  unfold e₁;
  grind

/-
e₂ is invariant under transposition of the first two arguments
-/
theorem e₂_swap12 (a b c : ℤ) : e₂ b a c = e₂ a b c := by
  unfold e₂; simp +decide [ max_comm ] ;
  ring

/-
e₂ is invariant under cyclic permutation
-/
theorem e₂_cycle (a b c : ℤ) : e₂ b c a = e₂ a b c := by
  unfold e₂;
  grind

/-
e₃ is invariant under transposition of the first two arguments
-/
theorem e₃_swap12 (a b c : ℤ) : e₃ b a c = e₃ a b c := by
  unfold e₃; rw [ add_comm b a ] ;

/-
e₃ is invariant under cyclic permutation
-/
theorem e₃_cycle (a b c : ℤ) : e₃ b c a = e₃ a b c := by
  unfold e₃; omega

/-! ### Key Identity

The crucial algebraic identity connecting e₂ to e₃ and the minimum:
  e₂(a,b,c) = (a + b + c) - min(a, min(b, c))

This identity arises because max(a+b, a+c, b+c) = (a+b+c) - min(a,b,c):
each pairwise sum a+b equals the total sum minus the omitted element c,
so taking the max of pairwise sums corresponds to omitting the minimum element.
-/

/-
Key identity: e₂(a,b,c) = (a+b+c) - min(a, min(b,c)).
    This follows from the observation that max(a+b, a+c, b+c) = (a+b+c) - min(a,b,c),
    since each pairwise sum omits one element and we maximize by omitting the smallest.
-/
theorem e₂_eq_sum_sub_min (a b c : ℤ) :
    e₂ a b c = a + b + c - min a (min b c) := by
  unfold e₂; cases le_total a b <;> cases le_total b c <;> cases le_total a c <;> simp +decide [ *, min_def ] <;> omega;

/-! ### Multiset Sorted Form

Every triple {a,b,c} as a multiset equals {max, mid, min} where mid is determined
by the sum, max, and min. This is the key structural lemma for orbit separation.
-/

/-
Every triple forms the same multiset as its sorted version (max, mid, min).
    Here mid = sum - max - min is the middle element.
-/
theorem multiset_eq_sorted (a b c : ℤ) :
    ({a, b, c} : Multiset ℤ) =
    {max a (max b c),
     a + b + c - max a (max b c) - min a (min b c),
     min a (min b c)} := by
  -- By definition of multiset equality, we need to show that the collections of elements are equal.
  apply Multiset.eq_of_le_of_card_le;
  · simp +decide [ Multiset.le_iff_count ];
    intro x; by_cases ha : x = a <;> by_cases hb : x = b <;> by_cases hc : x = c <;> simp +decide [ ha, hb, hc ] ;
    all_goals simp_all +decide [ Multiset.count_cons, Multiset.count_singleton ];
    all_goals split_ifs <;> omega;
  · simp +zetaDelta at *

/-! ### Tropical Chevalley Theorem (Orbit Separation)

The main theorem: the tropical elementary symmetric polynomials
completely separate the orbits of the S₃ action on ℤ³. That is,
if two triples have the same values of e₁, e₂, e₃, then they are
permutations of each other (have the same underlying multiset).

This is the tropical analogue of the fundamental theorem of symmetric
polynomials for n = 3.
-/

/-
**Tropical Chevalley Theorem for GL₃**: The tropical elementary symmetric
    polynomials separate S₃-orbits.

    If e₁(a,b,c) = e₁(a',b',c'), e₂(a,b,c) = e₂(a',b',c'), and
    e₃(a,b,c) = e₃(a',b',c'), then {a,b,c} = {a',b',c'} as multisets,
    i.e., (a',b',c') is a permutation of (a,b,c).

    *Proof sketch*: The tropical symmetric polynomials determine the sorted
    triple via max = e₁, min = e₃ - e₂, mid = e₂ - e₁. Since both triples
    have the same sorted form, their multisets agree.
-/
theorem separates_orbits (a b c a' b' c' : ℤ)
    (h1 : e₁ a b c = e₁ a' b' c')
    (h2 : e₂ a b c = e₂ a' b' c')
    (h3 : e₃ a b c = e₃ a' b' c') :
    ({a, b, c} : Multiset ℤ) = {a', b', c'} := by
  convert multiset_eq_sorted a b c using 1;
  convert multiset_eq_sorted a' b' c' using 1;
  unfold e₁ e₂ e₃ at *;
  grind +splitImp

/-! ### Tropical Satake Cone (Image Characterization)

The image of the map (e₁, e₂, e₃) : ℤ³ → ℤ³ is precisely the set of
triples (x, y, z) satisfying the dominance conditions 2x ≥ y and 2y ≥ x + z.
This is the tropical analogue of the Weyl chamber / dominant coweight cone
for GL₃.
-/

/-
Forward direction: the tropical symmetric polynomials satisfy the
    dominance inequality 2·e₁ ≥ e₂.
-/
theorem dominance_e1_e2 (a b c : ℤ) : 2 * e₁ a b c ≥ e₂ a b c := by
  unfold e₁ e₂;
  grind

/-
Forward direction: the tropical symmetric polynomials satisfy the
    dominance inequality 2·e₂ ≥ e₁ + e₃.
-/
theorem dominance_e2_e3 (a b c : ℤ) : 2 * e₂ a b c ≥ e₁ a b c + e₃ a b c := by
  unfold e₁ e₂ e₃;
  grind

/-
Backward direction: any triple satisfying the dominance conditions
    lies in the image of (e₁, e₂, e₃).
-/
theorem satake_cone_surj (x y z : ℤ) (hxy : 2 * x ≥ y) (hyz : 2 * y ≥ x + z) :
    ∃ a b c : ℤ, e₁ a b c = x ∧ e₂ a b c = y ∧ e₃ a b c = z := by
  use x, y - x, z - y;
  unfold e₁ e₂ e₃;
  grind

/-- **Tropical Satake Cone**: The image of (e₁, e₂, e₃) : ℤ³ → ℤ³ is exactly
    the dominant Weyl chamber {(x,y,z) : 2x ≥ y ∧ 2y ≥ x+z}.

    The forward direction says that the sorted values (max, mid, min) satisfy
    max ≥ mid ≥ min, which translates to 2x ≥ y and 2y ≥ x+z in the
    (e₁, e₂, e₃) coordinates. The backward direction constructs a witness
    a = x, b = y-x, c = z-y. -/
theorem image_characterization (x y z : ℤ) :
    (∃ a b c : ℤ, e₁ a b c = x ∧ e₂ a b c = y ∧ e₃ a b c = z) ↔
    (2 * x ≥ y ∧ 2 * y ≥ x + z) := by
  constructor
  · rintro ⟨a, b, c, h1, h2, h3⟩
    exact ⟨h1 ▸ h2 ▸ dominance_e1_e2 a b c, h1 ▸ h2 ▸ h3 ▸ dominance_e2_e3 a b c⟩
  · rintro ⟨hxy, hyz⟩
    exact satake_cone_surj x y z hxy hyz

/-! ### Tropical Power Sums

The tropical power sum p_k(a,b,c) = max(k·a, k·b, k·c) satisfies the
remarkably simple identity p_k = k · e₁ for all k ≥ 1. This is a dramatic
simplification compared to the classical Newton's identities, and reflects
the fact that in tropical arithmetic, taking the k-th power (= multiplying by k)
commutes with taking the maximum.
-/

/-- Tropical power sum p_k(a,b,c) = max(k·a, k·b, k·c) -/
def tropPowerSum (k : ℕ) (a b c : ℤ) : ℤ := max (k * a) (max (k * b) (k * c))

/-
**Tropical Newton's identity**: For k ≥ 1, the tropical power sum
    p_k(a,b,c) = k · e₁(a,b,c).

    In classical algebra, Newton's identities express power sums in terms of
    elementary symmetric polynomials via complicated recurrences. In tropical
    algebra, the relationship collapses: p_k = k · e₁, because
    max(k·a, k·b, k·c) = k · max(a, b, c) for k ≥ 1.
-/
theorem tropical_power_sum (k : ℕ) (_hk : k ≥ 1) (a b c : ℤ) :
    tropPowerSum k a b c = k * e₁ a b c := by
  unfold tropPowerSum e₁; ring_nf
  simp +decide [mul_max_of_nonneg]

/-! ### Injectivity of the Satake Transform

The orbit separation theorem can be restated as: the tropical Satake transform
(e₁, e₂, e₃) is injective on S₃-orbits. We formalize this by showing that
the transform is injective on sorted triples (the canonical orbit representatives).
-/

/-
The Satake transform is injective on sorted triples: if two sorted triples
    have the same tropical symmetric polynomials, they are equal.
-/
theorem satake_injective_sorted (a b c a' b' c' : ℤ)
    (hab : a ≥ b) (hbc : b ≥ c) (hab' : a' ≥ b') (hbc' : b' ≥ c')
    (h1 : e₁ a b c = e₁ a' b' c')
    (h2 : e₂ a b c = e₂ a' b' c')
    (h3 : e₃ a b c = e₃ a' b' c') :
    a = a' ∧ b = b' ∧ c = c' := by
  unfold e₁ e₂ e₃ at *;
  grind

end TropicalSatake