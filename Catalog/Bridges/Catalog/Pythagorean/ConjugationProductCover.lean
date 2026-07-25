/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Conjugation-Indexed Product Covering for Finite Groups

This file develops the theory of **product covering bounds** in finite groups,
where the covering efficiency of the product set A·A depends on conjugation
indices of the covering translates.

## Central Idea

Given a subgroup H of a group G and a set A covered by C left cosets of H,
the product set A·A can be covered by left cosets of H. For normal subgroups,
the bound is C² (since HgH = gH). For general subgroups, each double coset
HgH decomposes into [H : H ∩ g⁻¹Hg] left cosets, yielding the bound C²·L
where L = max conjugation index over covering translates.

## Main Definitions

* `conjugateSubgroup` — the conjugate gHg⁻¹ of a subgroup H
* `conjIntersection` — the intersection H ∩ g⁻¹Hg
* `SetCoveredByCosets` — a set is covered by left cosets indexed by T
* `doubleCosetSet` — the double coset HgH as a set
* `HeckeMultiplicity` — the number of left H-cosets in a double coset HgH

## Main Results

* `conjugateSubgroup_eq_of_normal` — gHg⁻¹ = H when H is normal
* `conjIntersection_eq_self_of_normal` — H ∩ g⁻¹Hg = H when H is normal
* `normal_coset_mul_mem` — product of coset elements for normal H
* `normal_product_covering` — product covering bound for normal subgroups
* `double_coset_eq_coset_of_normal` — HgH = gH for normal H
* `hecke_multiplicity_one_of_normal` — Hecke degree 1 for normal subgroups

## Cross-Domain Connection

The conjugation index [H : H ∩ g⁻¹Hg] equals the Hecke multiplicity —
the number of left H-cosets in the double coset HgH. This connects:
- **Group theory** (subgroup structure, conjugation)
- **Number theory** (Hecke operators, modular forms)
- **Representation theory** (double coset algebras)

## Conjecture

For any finite group G, subgroup H, and set A covered by C left translates of H,
the product set A·A is covered by at most C²·L translates of H, where
L = max_{t ∈ T} [H : H ∩ t⁻¹Ht].
-/

import Mathlib

open scoped Pointwise
open Set

namespace ConjugationCover

variable {G : Type*} [Group G]

/-! ## Section 1: Core Definitions -/

/-- The conjugate of subgroup H by g, giving gHg⁻¹. -/
def conjugateSubgroup (H : Subgroup G) (g : G) : Subgroup G :=
  H.map (MulAut.conj g).toMonoidHom

/-- The conjugation intersection H ∩ g⁻¹Hg. This measures how far g is from
normalizing H. When H is normal, this equals H itself. -/
def conjIntersection (H : Subgroup G) (g : G) : Subgroup G :=
  H ⊓ conjugateSubgroup H g⁻¹

/-- A set A is covered by left cosets of H indexed by T:  A ⊆ ⋃_{t ∈ T} tH. -/
def SetCoveredByCosets (A : Set G) (H : Subgroup G) (T : Finset G) : Prop :=
  A ⊆ ⋃ t ∈ (T : Set G), t • (H : Set G)

/-- The double coset HgH as a set: {h₁ * g * h₂ | h₁ h₂ ∈ H}. -/
def doubleCosetSet (H : Subgroup G) (g : G) : Set G :=
  (H : Set G) * ({g} * (H : Set G))

/-! ## Section 2: Conjugation and Normal Subgroups -/

/-
For a normal subgroup, the conjugate gHg⁻¹ equals H.
-/
theorem conjugateSubgroup_eq_of_normal (H : Subgroup G) (hN : H.Normal)
    (g : G) : conjugateSubgroup H g = H := by
  ext x;
  constructor;
  · rintro ⟨ y, hy, rfl ⟩;
    exact hN.conj_mem _ hy g;
  · exact fun hx => hx |> fun hx => ⟨ g⁻¹ * x * g, by simpa [ mul_assoc ] using hN.conj_mem _ hx g⁻¹, by simp +decide [ mul_assoc ] ⟩

/-
For a normal subgroup, the conjugation intersection H ∩ g⁻¹Hg equals H.
-/
theorem conjIntersection_eq_self_of_normal (H : Subgroup G) (hN : H.Normal)
    (g : G) : conjIntersection H g = H := by
  unfold conjIntersection;
  simp +decide [ conjugateSubgroup_eq_of_normal _ hN ]

/-- The conjugation intersection is always contained in H. -/
theorem conjIntersection_le (H : Subgroup G) (g : G) :
    conjIntersection H g ≤ H :=
  inf_le_left

/-
Conjugation by 1 gives back H.
-/
theorem conjugateSubgroup_one (H : Subgroup G) :
    conjugateSubgroup H 1 = H := by
  -- Unfold the definition of conjugateSubgroup.
  simp [conjugateSubgroup];
  convert Subgroup.map_id H

/-
The conjugation intersection at g = 1 is H itself.
-/
theorem conjIntersection_one (H : Subgroup G) :
    conjIntersection H 1 = H := by
  simp [conjIntersection, conjugateSubgroup];
  intro x hx; aesop;

/-! ## Section 3: Left Coset Algebra -/

/-
Membership in a left coset: x ∈ gH ↔ g⁻¹x ∈ H.
-/
theorem mem_left_coset_iff (H : Subgroup G) (g x : G) :
    x ∈ g • (H : Set G) ↔ g⁻¹ * x ∈ H := by
  simp +decide [ Set.mem_smul_set_iff_inv_smul_mem ]

/-
The product of two elements from left cosets lies in a predictable coset
when H is normal: if a ∈ g₁H and b ∈ g₂H, then a*b ∈ (g₁*g₂)H.

This is the fundamental algebraic identity underlying normal product covering:
a = g₁h₁, b = g₂h₂  ⟹  ab = g₁g₂(g₂⁻¹h₁g₂)h₂ ∈ g₁g₂·H.
-/
theorem normal_coset_mul_mem (H : Subgroup G) (hN : H.Normal)
    (g₁ g₂ a b : G) (ha : a ∈ g₁ • (H : Set G)) (hb : b ∈ g₂ • (H : Set G)) :
    a * b ∈ (g₁ * g₂) • (H : Set G) := by
  simp_all +decide [ Set.mem_smul_set_iff_inv_smul_mem ];
  simpa [ mul_assoc ] using H.mul_mem ( hN.conj_mem _ ha g₂⁻¹ ) hb

/-! ## Section 4: Product Covering for Normal Subgroups -/

/-
**Normal Product Covering Theorem**: If H is a normal subgroup and A is
covered by cosets indexed by T, then A·A is covered by cosets of the form (s*t)H
for s, t ∈ T. The covering set has at most |T|² elements.

This is the key structural result that makes covering bounds work cleanly
for normal subgroups, and motivates the conjecture for general subgroups.

**Proof sketch**: Take a₁a₂ ∈ A*A with a₁ ∈ s·H and a₂ ∈ t·H.
By `normal_coset_mul_mem`, a₁a₂ ∈ (s*t)·H, and s*t ∈ T*T.
-/
theorem normal_product_covering (H : Subgroup G) (hN : H.Normal)
    [DecidableEq G]
    (A : Set G) (T : Finset G) (hcover : SetCoveredByCosets A H T) :
    SetCoveredByCosets (A * A) H (T * T) := by
  intro x;
  simp +decide [ Set.mem_mul, Set.mem_iUnion ] at *;
  intro a ha b hb hab; rcases Set.mem_iUnion₂.1 ( hcover ha ) with ⟨ t, ht, ht' ⟩ ; rcases Set.mem_iUnion₂.1 ( hcover hb ) with ⟨ u, hu, hu' ⟩ ; use t, ht, u, hu; simp_all +decide [ Set.mem_smul_set_iff_inv_smul_mem ] ;
  simpa [ ← hab, mul_assoc ] using hN.conj_mem _ ht' u⁻¹ |> fun h => H.mul_mem h hu'

/-! ## Section 5: Double Coset Structure -/

/-
A left coset gH is contained in the double coset HgH.
-/
theorem left_coset_subset_double_coset (H : Subgroup G) (g : G) :
    g • (H : Set G) ⊆ doubleCosetSet H g := by
  simp +decide [ Set.subset_def, mem_left_coset_iff, doubleCosetSet ];
  exact fun x hx => ⟨ 1, H.one_mem, x, by simp +decide [ hx ], by simp +decide ⟩

/-
For a normal subgroup, the double coset HgH equals the single coset gH.
-/
theorem double_coset_eq_coset_of_normal (H : Subgroup G) (hN : H.Normal)
    (g : G) : doubleCosetSet H g = g • (H : Set G) := by
  refine' Set.Subset.antisymm _ _;
  · rintro x ⟨ h₁, hh₁, h₂, hh₂, rfl ⟩;
    simp_all +decide [ Set.mem_smul_set_iff_inv_smul_mem, mul_assoc, hN.mem_comm_iff ];
    exact H.mul_mem hh₁ hh₂;
  · exact left_coset_subset_double_coset H g

/-! ## Section 6: Covering Properties -/

/-- Covering is monotone: if A ⊆ B and B is covered, then A is covered. -/
theorem covering_monotone {A B : Set G} {H : Subgroup G} {T : Finset G}
    (hAB : A ⊆ B) (hcover : SetCoveredByCosets B H T) :
    SetCoveredByCosets A H T :=
  Set.Subset.trans hAB hcover

/-
A single coset gH is covered by the singleton {g}.
-/
theorem single_coset_covered (H : Subgroup G) (g : G) [DecidableEq G] :
    SetCoveredByCosets (g • (H : Set G)) H {g} := by
  simp [SetCoveredByCosets]

/-
The empty set is covered by the empty covering set.
-/
theorem empty_covered (H : Subgroup G) :
    SetCoveredByCosets ∅ H ∅ := by
  exact Set.empty_subset _

/-
If A is covered by T and B is covered by S, then A ∪ B is covered by T ∪ S.
-/
theorem union_covered {A B : Set G} {H : Subgroup G}
    {T S : Finset G} [DecidableEq G]
    (hA : SetCoveredByCosets A H T) (hB : SetCoveredByCosets B H S) :
    SetCoveredByCosets (A ∪ B) H (T ∪ S) := by
  intro x hx;
  cases' hx with hx hx <;> [ exact Set.mem_iUnion₂.2 ( by rcases Set.mem_iUnion₂.1 ( hA hx ) with ⟨ t, ht, hxt ⟩ ; exact ⟨ t, Finset.mem_union_left _ ht, hxt ⟩ ) ; exact Set.mem_iUnion₂.2 ( by rcases Set.mem_iUnion₂.1 ( hB hx ) with ⟨ t, ht, hxt ⟩ ; exact ⟨ t, Finset.mem_union_right _ ht, hxt ⟩ ) ]

/-! ## Section 7: Cross-Domain — Hecke Multiplicity & Number Theory -/

/-- The **Hecke multiplicity** of g with respect to H is the index
[H : H ∩ g⁻¹Hg], which equals the number of left H-cosets in the
double coset HgH.

In the theory of Hecke algebras and modular forms, this is the degree
of the Hecke operator T_g. The total weight of HgH in the Hecke algebra
is determined by this multiplicity, connecting group-theoretic covering
to the arithmetic of modular forms. -/
noncomputable def HeckeMultiplicity (H : Subgroup G) (g : G) : ℕ :=
  Nat.card (H ⧸ (conjIntersection H g).subgroupOf H)

/-
When H is normal, the Hecke multiplicity is 1:
every double coset HgH is a single left coset gH.
-/
theorem hecke_multiplicity_one_of_normal (H : Subgroup G) (hN : H.Normal) (g : G) :
    HeckeMultiplicity H g = 1 := by
  unfold HeckeMultiplicity;
  simp +decide [ conjIntersection_eq_self_of_normal H hN g ]

/-
The Hecke multiplicity at g = 1 is always 1.
-/
theorem hecke_multiplicity_one_at_identity (H : Subgroup G) :
    HeckeMultiplicity H 1 = 1 := by
  -- By definition of Hecke multiplicity, we have that HeckeMultiplicity H 1 = Nat.card (H ⧸ (conjIntersection H 1).subgroupOf H).
  unfold HeckeMultiplicity;
  simp +decide [ conjIntersection_one ]

/-! ## Section 8: The Conjecture and Special Cases -/

/-- **Maximal conjugation index** over a covering set T. -/
noncomputable def maxConjIndex (H : Subgroup G) (T : Finset G) : ℕ :=
  T.sup (fun t => HeckeMultiplicity H t)

/-- **Main Conjecture** (Conjugation-Indexed Product Cover):
For a finite group G, subgroup H, and set A covered by C left cosets (from T),
the product A·A can be covered by at most C² · L cosets, where
L = maxConjIndex H T.

This unifies the abelian case (L=1) and normal subgroup case (L=1) with
the general non-abelian case. -/
def ProductCoverConjecture : Prop :=
  ∀ (G : Type) [Group G] [Fintype G] [DecidableEq G]
    (H : Subgroup G) (A : Set G) (T : Finset G),
    SetCoveredByCosets A H T →
    ∃ (S : Finset G), SetCoveredByCosets (A * A) H S ∧
      S.card ≤ T.card ^ 2 * maxConjIndex H T

/-
The conjecture holds for the full group ⊤: everything is in one coset,
so C = 1 and C(A·A) = 1 ≤ 1·L.
-/
theorem conjecture_for_top [DecidableEq G]
    (A : Set G) (T : Finset G)
    (_hcover : SetCoveredByCosets A (⊤ : Subgroup G) T)
    (_hT : T.Nonempty) :
    ∃ (S : Finset G), SetCoveredByCosets (A * A) (⊤ : Subgroup G) S ∧
      S.card ≤ 1 := by
  -- For the full group, every element � is� in one coset, so C = 1 and C(A·A) = 1 ≤ 1·L.
  use {1}
  simp [SetCoveredByCosets]

end ConjugationCover