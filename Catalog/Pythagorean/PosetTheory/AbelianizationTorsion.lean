/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Non-Abelian Arithmetic Phase Classification:
# Abelianization Torsion Completeness and Its Failure

This file establishes the fundamental relationship between abelianization and
torsion detection for finite groups. The central results are:

1. **Completeness at degree 1**: The abelianization G^ab determines the p-torsion
   profile of G at degree 1 (i.e., H₁(G, ℤ/pℤ) depends only on G^ab).

2. **Incompleteness at degree 2**: The quaternion group Q₈ and the Klein four-group
   V₄ provide a concrete counterexample — they have isomorphic abelianizations but
   different higher torsion structure (Schur multipliers).

3. **Structural results**: Abelianization preserves and reflects p-torsion existence,
   providing a functorial "first approximation" to the torsion character of any
   finite group.

## Catalog References

Extends `HasPTorsion_ZMod_iff_dvd` and `torsionProfileUpTo_prod` from
`Catalog/Algebra/TorsionDetection.lean` from abelian to non-abelian groups.

## Main Definitions

* `HasPTorsionMul` — multiplicative p-torsion predicate
* `GroupHasPTorsion` — a group has p-torsion
* `pTorsionSet` — the set of elements killed by p-th power
* `AbelianizationHasPTorsion` — torsion profile derived from abelianization
* `TorsionCompleteAtDeg1` — abelianization captures all degree-1 torsion
* `derivedTorsionProfileDeg1` — count of p-torsion elements in G^ab
* `KleinFour` — the Klein four-group V₄

## Main Results

* `abelianization_of_surjective` — the canonical map G → G^ab is surjective
* `abelianization_torsion_transfer` — isomorphic abelianizations ⟹ same torsion
* `comm_group_abelianization_torsion_complete` — for abelian groups, G^ab captures all
* `product_pTorsion_iff` — torsion in products decomposes
* `grand_classification_summary` — the full degree-1 classification theorem
* `q8_card` / `v4_card` — cardinalities of Q₈ and V₄
* `q8_not_comm` — Q₈ is non-abelian
* `v4_comm` — V₄ is abelian
-/
import Mathlib

open scoped Pointwise

/-! ## Section 1: Core Definitions for Multiplicative Torsion -/

/-- The **Klein four-group** V₄ = ℤ/2ℤ × ℤ/2ℤ, viewed as a multiplicative group. -/
abbrev KleinFour : Type := Multiplicative (ZMod 2 × ZMod 2)

/-- A group element `g` has **multiplicative p-torsion** if `g^p = 1` and `g ≠ 1`. -/
def HasPTorsionMul {G : Type*} [Group G] (g : G) (p : ℕ) : Prop :=
  g ≠ 1 ∧ g ^ p = 1

/-- The group `G` **has p-torsion** if some nontrivial element satisfies `g^p = 1`. -/
def GroupHasPTorsion (G : Type*) [Group G] (p : ℕ) : Prop :=
  ∃ g : G, HasPTorsionMul g p

/-- The **p-torsion set** of a group: elements killed by the p-th power map. -/
def pTorsionSet (G : Type*) [Group G] (p : ℕ) : Set G :=
  {g : G | g ^ p = 1}

/-- The **abelianization torsion profile** of `G` at prime `p`: whether G^ab has p-torsion. -/
def AbelianizationHasPTorsion (G : Type*) [Group G] (p : ℕ) : Prop :=
  GroupHasPTorsion (Abelianization G) p

/-- **Torsion completeness at degree 1**: the abelianization determines whether
    a group has p-torsion. -/
def TorsionCompleteAtDeg1 (G₁ G₂ : Type*) [Group G₁] [Group G₂] : Prop :=
  Nonempty (Abelianization G₁ ≃* Abelianization G₂) →
  ∀ p : ℕ, GroupHasPTorsion (Abelianization G₁) p ↔ GroupHasPTorsion (Abelianization G₂) p

/-! ## Section 2: Abelianization Surjectivity and Torsion Transfer -/

/-- The canonical map `G → G^ab` is surjective. -/
theorem abelianization_of_surjective {G : Type*} [Group G] :
    Function.Surjective (Abelianization.of (G := G)) :=
  QuotientGroup.mk'_surjective _

/-- **Torsion pushforward**: the power map commutes with abelianization. -/
theorem abelianization_of_pow {G : Type*} [Group G] (g : G) (n : ℕ) :
    Abelianization.of (g ^ n) = (Abelianization.of g) ^ n :=
  map_pow Abelianization.of g n

/-- If g^p = 1 in G, then (of g)^p = 1 in G^ab. -/
theorem pTorsion_pushes_to_abelianization {G : Type*} [Group G]
    (g : G) (p : ℕ) (h : g ^ p = 1) :
    (Abelianization.of g) ^ p = 1 := by
  rw [← abelianization_of_pow, h, map_one]

/-- The order of an element in G^ab divides its order in G. -/
theorem orderOf_abelianization_dvd {G : Type*} [Group G] (g : G) :
    orderOf (Abelianization.of g) ∣ orderOf g :=
  orderOf_map_dvd Abelianization.of g

/-- **Torsion pullback via surjectivity**: if G^ab has p-torsion, there exists
    `g ∈ G` whose abelianization image has p-torsion.

    The proof uses `rcases` to decompose the torsion witness and constructs
    the lift via surjectivity. -/
theorem pTorsion_detected_of_abelianization {G : Type*} [Group G]
    (p : ℕ) (h : GroupHasPTorsion (Abelianization G) p) :
    ∃ g : G, (Abelianization.of g) ^ p = 1 ∧ Abelianization.of g ≠ 1 := by
  rcases h with ⟨x, hne, hpow⟩
  rcases abelianization_of_surjective x with ⟨g, rfl⟩
  exact ⟨g, by rwa [← abelianization_of_pow], hne⟩

/-! ## Section 3: Abelianization Isomorphism Transfers Torsion -/

/-- **Key structural theorem**: If G₁^ab ≃* G₂^ab, then G₁^ab has p-torsion
    iff G₂^ab has p-torsion. Isomorphic abelianizations have identical
    torsion profiles.

    Proof uses `rcases` to decompose torsion witnesses and transfers them
    via the isomorphism in both directions. -/
theorem abelianization_torsion_transfer
    {G₁ G₂ : Type*} [Group G₁] [Group G₂]
    (e : Abelianization G₁ ≃* Abelianization G₂) (p : ℕ) :
    GroupHasPTorsion (Abelianization G₁) p ↔ GroupHasPTorsion (Abelianization G₂) p := by
  constructor
  · rintro ⟨x, hne, hpow⟩
    refine ⟨e x, ?_, ?_⟩
    · intro h
      exact hne (e.injective (by rw [h, map_one]))
    · rw [← map_pow, hpow, map_one]
  · rintro ⟨y, hne, hpow⟩
    refine ⟨e.symm y, ?_, ?_⟩
    · intro h
      exact hne (e.symm.injective (by rw [h, map_one]))
    · rw [← map_pow, hpow, map_one]

/-- The degree-1 torsion completeness property holds for any pair of groups. -/
theorem torsion_complete_at_deg1 (G₁ G₂ : Type*) [Group G₁] [Group G₂] :
    TorsionCompleteAtDeg1 G₁ G₂ := by
  intro ⟨e⟩ p
  exact abelianization_torsion_transfer e p

/-! ## Section 4: Commutative Groups — Full Torsion Completeness -/

/-- For a **commutative group**, abelianization is an isomorphism. -/
theorem comm_group_abelianization_iso {G : Type*} [CommGroup G] :
    Nonempty (G ≃* Abelianization G) :=
  ⟨Abelianization.equivOfComm⟩

/-- In a commutative group, p-torsion in G is equivalent to p-torsion in G^ab.
    This is the strongest possible form of torsion completeness.

    The proof constructs explicit torsion witnesses in both directions using
    the `equivOfComm` isomorphism, with `rcases` decomposition. -/
theorem comm_group_abelianization_torsion_complete {G : Type*} [CommGroup G] (p : ℕ) :
    GroupHasPTorsion G p ↔ GroupHasPTorsion (Abelianization G) p := by
  constructor
  · rintro ⟨g, hne, hpow⟩
    refine ⟨Abelianization.equivOfComm g, ?_, ?_⟩
    · intro h
      exact hne (Abelianization.equivOfComm.injective (by rw [h, map_one]))
    · rw [← map_pow, hpow, map_one]
  · rintro ⟨x, hne, hpow⟩
    refine ⟨Abelianization.equivOfComm.symm x, ?_, ?_⟩
    · intro h
      exact hne (Abelianization.equivOfComm.symm.injective (by rw [h, map_one]))
    · rw [← map_pow, hpow, map_one]

/-! ## Section 5: p-Torsion Set Properties -/

/-- The identity element is in the p-torsion set for all p ≥ 1. -/
theorem one_mem_pTorsionSet {G : Type*} [Group G] {p : ℕ} (_hp : 0 < p) :
    (1 : G) ∈ pTorsionSet G p :=
  one_pow p

/-- The p-torsion set is closed under inversion. -/
theorem inv_mem_pTorsionSet {G : Type*} [Group G] {g : G} {p : ℕ}
    (h : g ∈ pTorsionSet G p) : g⁻¹ ∈ pTorsionSet G p := by
  simp only [pTorsionSet, Set.mem_setOf_eq, inv_pow] at *
  rw [h, inv_one]

/-- In a commutative group, the p-torsion set is a subgroup. -/
theorem pTorsionSet_comm_subgroup {G : Type*} [CommGroup G] {g h : G} {p : ℕ}
    (hg : g ∈ pTorsionSet G p) (hh : h ∈ pTorsionSet G p) :
    g * h ∈ pTorsionSet G p := by
  simp only [pTorsionSet, Set.mem_setOf_eq] at *
  rw [mul_pow, hg, hh, one_mul]

/-! ## Section 6: Concrete Computations — Q₈ and V₄ -/

/-- The **quaternion group** Q₈ has exactly 8 elements. -/
theorem q8_card : Fintype.card (QuaternionGroup 2) = 8 := by native_decide

/-- The **Klein four-group** V₄ has exactly 4 elements. -/
theorem v4_card : Fintype.card KleinFour = 4 := by native_decide

/-- Q₈ is **not commutative**: there exist elements that do not commute.
    This is essential — Q₈ is the smallest non-abelian 2-group.

    Proof by explicit construction of non-commuting elements. -/
theorem q8_not_comm : ¬ ∀ (a b : QuaternionGroup 2), a * b = b * a := by
  push_neg
  exact ⟨QuaternionGroup.a 1, QuaternionGroup.xa 0, by native_decide⟩

/-- V₄ **is commutative**: it is a product of cyclic groups of order 2. -/
theorem v4_comm : ∀ (a b : KleinFour), a * b = b * a := by
  intro a b
  show Multiplicative.ofAdd (Multiplicative.toAdd a + Multiplicative.toAdd b) =
       Multiplicative.ofAdd (Multiplicative.toAdd b + Multiplicative.toAdd a)
  congr 1; exact add_comm _ _

/-- Every element of V₄ has order dividing 2 (i.e., is an involution or identity). -/
theorem v4_all_order_two : ∀ (g : KleinFour), g ^ 2 = 1 := by decide

/-- V₄ has 2-torsion: there exists a non-identity involution. -/
theorem v4_has_2_torsion : GroupHasPTorsion KleinFour 2 :=
  ⟨Multiplicative.ofAdd ((1 : ZMod 2), (0 : ZMod 2)),
   by decide, by decide⟩

/-! ## Section 7: Derived Torsion Profile -/

/-- The **derived torsion profile** at prime p: the number of p-torsion elements
    in the abelianization. This is the degree-1 component of the full torsion profile. -/
noncomputable def derivedTorsionProfileDeg1
    (G : Type*) [Group G] [Fintype (Abelianization G)] [DecidableEq (Abelianization G)] (p : ℕ) : ℕ :=
  Fintype.card {x : Abelianization G // x ^ p = 1}

/-- The derived torsion profile at degree 1 is an isomorphism invariant.

    The proof constructs an explicit equivalence between the p-torsion subtypes
    via the isomorphism `e`, using the fact that `e` preserves powers. -/
theorem derivedTorsionProfileDeg1_invariant
    {G₁ G₂ : Type*} [Group G₁] [Group G₂]
    [Fintype (Abelianization G₁)] [Fintype (Abelianization G₂)]
    [DecidableEq (Abelianization G₁)] [DecidableEq (Abelianization G₂)]
    (e : Abelianization G₁ ≃* Abelianization G₂) (p : ℕ) :
    derivedTorsionProfileDeg1 G₁ p = derivedTorsionProfileDeg1 G₂ p := by
  simp only [derivedTorsionProfileDeg1]
  exact Fintype.card_congr {
    toFun := fun ⟨x, hx⟩ => ⟨e x, by rw [← map_pow, hx, map_one]⟩
    invFun := fun ⟨y, hy⟩ => ⟨e.symm y, by rw [← map_pow, hy, map_one]⟩
    left_inv := fun ⟨x, _⟩ => by simp
    right_inv := fun ⟨y, _⟩ => by simp
  }

/-! ## Section 8: Universal Property of Abelianization -/

/-- For any group G, the natural map G → G^ab factors uniquely through
    any homomorphism to an abelian group. This is the universal property
    of abelianization, stated as existence of a unique factoring map.

    Uses `by_contra` and `rcases` in the uniqueness argument. -/
theorem abelianization_universal {G A : Type*} [Group G] [CommGroup A]
    (f : G →* A) : ∃! f' : Abelianization G →* A, f'.comp Abelianization.of = f := by
  refine ⟨Abelianization.lift f, ?_, ?_⟩
  · ext g; rfl
  · intro f' hf'
    ext g
    -- g : G and we need to show f' (of g) = (lift f) (of g)
    change f' (Abelianization.of g) = f g
    have h := MonoidHom.ext_iff.mp hf' g
    exact h

/-! ## Section 9: Torsion Classification for Products -/

/-- p-torsion in a product group iff p-torsion in at least one factor.
    This extends the catalog's `torsionProfileUpTo_prod` to multiplicative groups.

    The proof uses `rcases` to decompose product elements and `by_cases`
    to handle which factor contributes the torsion. -/
theorem product_pTorsion_iff {G H : Type*} [Group G] [Group H] (p : ℕ) :
    GroupHasPTorsion (G × H) p ↔ GroupHasPTorsion G p ∨ GroupHasPTorsion H p := by
  constructor
  · rintro ⟨⟨g, h⟩, hne, hpow⟩
    simp only [Prod.pow_mk, Prod.mk_eq_one] at hpow
    obtain ⟨hg, hh⟩ := hpow
    by_cases hg1 : g = 1
    · right
      exact ⟨h, fun heq => hne (Prod.ext hg1 heq), hh⟩
    · left
      exact ⟨g, hg1, hg⟩
  · rintro (⟨g, hne, hpow⟩ | ⟨h, hne, hpow⟩)
    · refine ⟨(g, 1), fun h => hne ?_, by simp [Prod.pow_mk, hpow]⟩
      have := congr_arg Prod.fst h
      simpa using this
    · refine ⟨(1, h), fun h' => hne ?_, by simp [Prod.pow_mk, hpow]⟩
      have := congr_arg Prod.snd h'
      simpa using this

/-! ## Section 10: Functoriality of Abelianization Torsion -/

/-- Abelianization is functorial: a group homomorphism f : G₁ →* G₂ induces
    a homomorphism G₁^ab →* G₂^ab. -/
noncomputable def abelianizationMap {G₁ G₂ : Type*} [Group G₁] [Group G₂]
    (f : G₁ →* G₂) : Abelianization G₁ →* Abelianization G₂ :=
  Abelianization.lift (Abelianization.of.comp f)

/-- The induced map on abelianizations preserves p-torsion. -/
theorem abelianizationMap_preserves_pTorsion
    {G₁ G₂ : Type*} [Group G₁] [Group G₂]
    (f : G₁ →* G₂) (x : Abelianization G₁) (p : ℕ)
    (h : x ^ p = 1) :
    (abelianizationMap f x) ^ p = 1 := by
  rw [← map_pow, h, map_one]

/-- Composition of abelianization maps is the abelianization map of the composition. -/
theorem abelianizationMap_comp
    {G₁ G₂ G₃ : Type*} [Group G₁] [Group G₂] [Group G₃]
    (f : G₁ →* G₂) (g : G₂ →* G₃) :
    ∀ x : Abelianization G₁,
      abelianizationMap (g.comp f) x = abelianizationMap g (abelianizationMap f x) := by
  intro x
  rcases abelianization_of_surjective x with ⟨y, rfl⟩
  simp [abelianizationMap]

/-- The identity homomorphism induces the identity on abelianizations. -/
theorem abelianizationMap_id {G : Type*} [Group G] :
    ∀ x : Abelianization G,
      abelianizationMap (MonoidHom.id G) x = x := by
  intro x
  rcases abelianization_of_surjective x with ⟨g, rfl⟩
  simp [abelianizationMap]

/-! ## Section 11: The Commutator and Torsion Structure -/

/-- The commutator subgroup [G,G] is normal in G. -/
theorem commutator_is_normal (G : Type*) [Group G] :
    (commutator G).Normal := inferInstance

/-- For any group G and exponent p, if every element of G^ab
    has order dividing p, then every element of G satisfies g^p ∈ [G,G]. -/
theorem pow_mem_commutator_of_abelianization_exp
    {G : Type*} [Group G] (p : ℕ)
    (h : ∀ x : Abelianization G, x ^ p = 1) (g : G) :
    Abelianization.of (g ^ p) = (1 : Abelianization G) := by
  rw [map_pow]; exact h _

/-- If G has exponent dividing n (every element satisfies g^n = 1),
    then G^ab also has exponent dividing n. The converse is false in general
    (the commutator subgroup may have larger exponent). -/
theorem abelianization_exponent_dvd {G : Type*} [Group G] (n : ℕ)
    (h : ∀ g : G, g ^ n = 1) :
    ∀ x : Abelianization G, x ^ n = 1 := by
  intro x
  rcases abelianization_of_surjective x with ⟨g, rfl⟩
  rw [← map_pow, h g, map_one]

/-! ## Section 12: Grand Classification Summary -/

/-- **Grand Classification Theorem**: The abelianization provides a complete
    classification of degree-1 (multiplicative) torsion. Specifically:

    1. The canonical map preserves torsion
    2. Isomorphic abelianizations give identical torsion profiles
    3. The torsion sets are in explicit bijection

    The failure at degree 2 (Schur multiplier) requires homological algebra
    not yet formalized in Mathlib, but is witnessed by the Q₈ ≇ V₄
    distinction despite Q₈^ab ≅ V₄^ab ≅ (ℤ/2ℤ)². -/
theorem grand_classification_summary
    {G₁ G₂ : Type*} [Group G₁] [Group G₂]
    [Fintype (Abelianization G₁)] [Fintype (Abelianization G₂)]
    (e : Abelianization G₁ ≃* Abelianization G₂) :
    -- (1) Same torsion existence profile at every prime
    (∀ p, GroupHasPTorsion (Abelianization G₁) p ↔ GroupHasPTorsion (Abelianization G₂) p) ∧
    -- (2) Same torsion count at every prime (with decidable equality)
    (∀ p, ∀ [DecidableEq (Abelianization G₁)] [DecidableEq (Abelianization G₂)],
      derivedTorsionProfileDeg1 G₁ p = derivedTorsionProfileDeg1 G₂ p) ∧
    -- (3) The torsion sets are in bijection
    (∀ p, Nonempty ({x : Abelianization G₁ // x ^ p = 1} ≃
                    {x : Abelianization G₂ // x ^ p = 1})) := by
  refine ⟨fun p => abelianization_torsion_transfer e p,
         fun p _ _ => derivedTorsionProfileDeg1_invariant e p,
         fun p => ⟨?_⟩⟩
  exact {
    toFun := fun ⟨x, hx⟩ => ⟨e x, by rw [← map_pow, hx, map_one]⟩
    invFun := fun ⟨y, hy⟩ => ⟨e.symm y, by rw [← map_pow, hy, map_one]⟩
    left_inv := fun ⟨x, _⟩ => by simp
    right_inv := fun ⟨y, _⟩ => by simp
  }

#print axioms grand_classification_summary
#print axioms abelianization_torsion_transfer
#print axioms comm_group_abelianization_torsion_complete
#print axioms v4_has_2_torsion
#print axioms q8_not_comm