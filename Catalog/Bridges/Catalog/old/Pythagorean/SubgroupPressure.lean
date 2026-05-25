/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Subgroup Pair Pressure and Phase Transitions in Random Generation

This file introduces the **subgroup pair pressure**, a partition-function-like
invariant for finite groups that controls the probability that two random
elements fail to generate the group.

## Main definitions

* `subgroupPairPressure` — For a finite group `G` and a family of subgroups
  `H : ι → Subgroup G`, the sum `∑ i, [G : H i]⁻²` over ℚ.
* `nongeneratingPairCount` — The number of pairs `(x, y) ∈ G²` such that
  `⟨x, y⟩ ≠ G`.

## Main results

* `nongeneratingPairProb_le_pressure` — The sieve bound: if every
  nongenerating pair lies in some member of the family, then the
  nongeneration probability is at most the pressure.
* `subgroupPairPressure_le_card_div_sq` — Upper bound: if every subgroup
  in the family has index ≥ D, then pressure ≤ |ι| / D².
* `subgroupPairPressure_ge_card_div_sq` — Lower bound: if every subgroup
  in the family has index ≤ d, then pressure ≥ |ι| / d².
* `subgroupPairPressure_prod` — Product factorization: for product families
  in `G × K`, pressure is multiplicative.
* `log_pressure_prod_eq_add` — Free energy additivity: log of pressure
  is additive for independent product families.

## Application keywords

random generation, permutation groups, wreath products, imprimitive subgroups,
subgroup sieve, phase transitions, statistical physics, partition function,
free energy, entropy-energy competition, probabilistic combinatorics,
O'Nan–Scott theory, subgroup growth, threshold phenomena.

-/

import Mathlib

open Finset BigOperators

/-! ## Core Definitions -/

/-- The **subgroup pair pressure** of a group `G` with respect to
a family of subgroups indexed by `ι`. This is the sum
`∑ i, [G : H i]⁻²`, where `[G : H i]` is the index of `H i` in `G`.

This is the finite-group analogue of a partition function: each subgroup
is a "defect state" with energy `2 log [G : H i]`, and the multiplicity
of subgroups contributes entropy. -/
noncomputable def subgroupPairPressure
    (G : Type*) [Group G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G) : ℚ :=
  ∑ i : ι, ((H i).index : ℚ)⁻¹ ^ 2

/-- The number of pairs `(x, y) ∈ G²` that do not generate `G`. -/
noncomputable def nongeneratingPairCount
    (G : Type*) [Group G] [Fintype G] : ℕ :=
  Nat.card { p : G × G // Subgroup.closure ({p.1, p.2} : Set G) ≠ ⊤ }

/-- The probability that two uniformly random elements of `G` fail to
generate `G`, as a rational number. -/
noncomputable def nongeneratingPairProb
    (G : Type*) [Group G] [Fintype G] : ℚ :=
  (nongeneratingPairCount G : ℚ) / (Fintype.card G : ℚ) ^ 2

/-! ## Theorem 1: Pressure bound for nongeneration (Sieve Inequality)

The key idea: if every nongenerating pair `(x,y)` lies in some `H i`,
then by union bound, the count of nongenerating pairs is at most
`∑ i, |H i|²`. Dividing by `|G|²` and using `|H|/|G| = [G:H]⁻¹`
gives `P(nongen) ≤ ∑ [G:H i]⁻²`.
-/

/-
**Key identity**: `(|H| / |G|)² = [G : H]⁻²` for a subgroup `H` of
a finite group `G`. This connects the cardinality-based and index-based
formulations of pressure.
-/
theorem card_sq_div_eq_index_inv_sq
    (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) (hG : (Fintype.card G : ℚ) ≠ 0) :
    (Nat.card H : ℚ) ^ 2 / (Fintype.card G : ℚ) ^ 2 =
      ((H.index : ℚ)⁻¹) ^ 2 := by
        -- From Subgroup.index_mul_card: H.index * Nat.card H = Nat.card G. So Nat.card H = Nat.card G / H.index.
        have h_index_mul_card : (H.index : ℚ) * (Nat.card H : ℚ) = (Fintype.card G : ℚ) := by
          rw_mod_cast [ Subgroup.index_mul_card ];
          rw [ Nat.card_eq_fintype_card ];
        grind

/-
The number of pairs in a subgroup equals the square of its cardinality.
-/
theorem natCard_subgroupPairs (G : Type*) [Group G] [Fintype G]
    (H : Subgroup G) :
    Nat.card { p : G × G // p.1 ∈ H ∧ p.2 ∈ H } = (Nat.card H) ^ 2 := by
      rw [ sq, Nat.card_congr ];
      convert Nat.card_prod _ _;
      exact ⟨ fun p => ⟨ ⟨ p.val.1, p.prop.1 ⟩, ⟨ p.val.2, p.prop.2 ⟩ ⟩, fun p => ⟨ ( p.1.val, p.2.val ), p.1.2, p.2.2 ⟩, fun p => rfl, fun p => rfl ⟩

/-
Union bound: if a set of pairs is covered by a family of pair-sets,
the cardinality of the original set is at most the sum.
-/
theorem nongeneratingPairCount_le_sum_card
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (hcover : ∀ x y : G, Subgroup.closure ({x, y} : Set G) ≠ ⊤ →
      ∃ i, x ∈ H i ∧ y ∈ H i) :
    (nongeneratingPairCount G : ℚ) ≤
      ∑ i : ι, ((Nat.card (H i) : ℚ)) ^ 2 := by
        norm_cast;
        -- The set of nongenerating pairs is contained in ⋃ i, {p : G × G | p.1 ∈ H i ∧ p.2 ∈ H i} by the covering hypothesis hcover.
        have h_subset : {p : G × G | Subgroup.closure {p.1, p.2} ≠ ⊤} ⊆ ⋃ i, {p : G × G | p.1 ∈ H i ∧ p.2 ∈ H i} := by
          exact fun p hp => by obtain ⟨ i, hi ⟩ := hcover p.1 p.2 hp; exact Set.mem_iUnion.2 ⟨ i, hi ⟩ ;
        convert Nat.card_le_card_of_injective _ _;
        rotate_left;
        exact Σ i, { p : G × G // p.1 ∈ H i ∧ p.2 ∈ H i };
        exact inferInstance;
        exact fun p => ⟨ Classical.choose ( Set.mem_iUnion.mp ( h_subset p.2 ) ), ⟨ p.val, Classical.choose_spec ( Set.mem_iUnion.mp ( h_subset p.2 ) ) ⟩ ⟩;
        · intro p q h_eq;
          grind;
        · simp +decide [ Nat.card_sigma, natCard_subgroupPairs ]

/-
**Pressure bound for nongeneration (Sieve Inequality)**:
if every nongenerating pair `(x, y)` lies in some member `H i` of
the family, then the nongeneration probability is bounded by the
subgroup pair pressure. This is the bridge from group theory to
statistical mechanics.
-/
theorem nongeneratingPairProb_le_pressure
    (G : Type*) [Group G] [Fintype G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (hcover : ∀ x y : G, Subgroup.closure ({x, y} : Set G) ≠ ⊤ →
      ∃ i, x ∈ H i ∧ y ∈ H i) :
    nongeneratingPairProb G ≤ subgroupPairPressure G ι H := by
      convert div_le_div_of_nonneg_right ( nongeneratingPairCount_le_sum_card G ι H hcover ) ( sq_nonneg ( Fintype.card G : ℚ ) ) using 1;
      convert Finset.sum_div _ _ _ using 2;
      rw [ Finset.sum_div ];
      convert rfl;
      convert Finset.sum_congr rfl fun i _ => ?_;
      convert card_sq_div_eq_index_inv_sq G ( H i ) _ using 1;
      · exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero;
      · rw [ Finset.sum_div _ _ _ ]

/-! ## Theorem 2: Entropy-Energy Bounds -/

/-
**Upper bound by maximum entropy**: if every subgroup in the family
has index at least `D`, then the pressure is at most `|ι| / D²`.
This says sparse, high-index subgroups are negligible obstructions.
-/
theorem subgroupPairPressure_le_card_div_sq
    (G : Type*) [Group G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (D : ℕ) (_hD : 0 < D)
    (hindex : ∀ i, D ≤ (H i).index) :
    subgroupPairPressure G ι H ≤ (Fintype.card ι : ℚ) / (D : ℚ) ^ 2 := by
      convert Finset.sum_le_sum fun i _ => pow_le_pow_left₀ ( by positivity ) ( inv_anti₀ ( by positivity ) ( show ( H i |> Subgroup.index : ℚ ) ≥ D by exact_mod_cast hindex i ) ) 2 using 1 ; norm_num [ subgroupPairPressure ] ; ring;

/-
**Lower bound by minimum energy**: if every subgroup in the family
has index at most `d`, then the pressure is at least `|ι| / d²`.
This says many moderate-index subgroups force nongeneration.
-/
theorem subgroupPairPressure_ge_card_div_sq
    (G : Type*) [Group G]
    (ι : Type*) [Fintype ι]
    (H : ι → Subgroup G)
    (d : ℕ) (_hd : 0 < d)
    (hindex : ∀ i, (H i).index ≤ d)
    (hpos : ∀ i, 0 < (H i).index) :
    (Fintype.card ι : ℚ) / (d : ℚ) ^ 2 ≤ subgroupPairPressure G ι H := by
      convert Finset.sum_le_sum fun i _ => ?_;
      rotate_left;
      use fun i => 1 / ( d : ℚ ) ^ 2;
      · infer_instance;
      · simpa using inv_anti₀ ( sq_pos_of_pos ( Nat.cast_pos.mpr ( hpos i ) ) ) ( pow_le_pow_left₀ ( Nat.cast_nonneg _ ) ( Nat.cast_le.mpr ( hindex i ) ) 2 );
      · simp +decide [ div_eq_mul_inv ]

/-! ## Theorem 3: Product-Family Factorization -/

/-
**Product factorization of pressure**: for product families
`H i × L j` in `G × K`, the pressure factorizes as a product:
```
pressure(G × K, H × L) = pressure(G, H) · pressure(K, L).
```
This is the exact multiplicative law expected of a partition function
and gives a rigorous mechanism for sharp transitions in iterated
product or block-structured families.
-/
theorem subgroupPairPressure_prod
    (G K : Type*) [Group G] [Group K]
    (ι κ : Type*) [Fintype ι] [Fintype κ]
    (H : ι → Subgroup G) (L : κ → Subgroup K) :
    subgroupPairPressure (G × K) (ι × κ)
      (fun p => (H p.1).prod (L p.2)) =
    subgroupPairPressure G ι H * subgroupPairPressure K κ L := by
      unfold subgroupPairPressure;
      simp +decide [ Finset.sum_mul, Subgroup.index_prod ];
      simp +decide only [mul_comm, mul_pow, Finset.mul_sum _ _ _];
      rw [ ← Finset.sum_product' ] ; simp +decide ;

/-! ## Theorem 5: Free Energy Additivity (Cross-Domain) -/

/-
**Free energy additivity**: the negative log of the pressure is additive
for independent product families. This connects the subgroup sieve to
statistical mechanics: independent defect systems have additive free energy.

In thermodynamic language, `F = -log Z` where `Z` is the partition function
(pressure). The additivity `F(G×K) = F(G) + F(K)` is the hallmark of
independent systems.
-/
theorem log_pressure_prod_eq_add
    (G K : Type*) [Group G] [Group K]
    (ι κ : Type*) [Fintype ι] [Fintype κ]
    (H : ι → Subgroup G) (L : κ → Subgroup K)
    (hH : 0 < subgroupPairPressure G ι H)
    (hL : 0 < subgroupPairPressure K κ L) :
    Real.log (subgroupPairPressure (G × K) (ι × κ)
      (fun p => (H p.1).prod (L p.2)) : ℝ) =
    Real.log (subgroupPairPressure G ι H : ℝ) +
    Real.log (subgroupPairPressure K κ L : ℝ) := by
      convert Real.log_mul ( by positivity : ( subgroupPairPressure G ι H : ℝ ) ≠ 0 ) ( by positivity : ( subgroupPairPressure K κ L : ℝ ) ≠ 0 ) using 1;
      convert congr_arg _ ( Rat.cast_inj.mpr ( subgroupPairPressure_prod G K ι κ H L ) ) using 1;
      · norm_num [ Rat.cast_mul ];
      · infer_instance

/-! ## Conjecture: Structural Phase Transition for Imprimitive Families

**Conjecture**: Let `W(k,m) = S_k ≀ S_m` in product action, and let
`I(k,m)` be the family of maximal imprimitive subgroups. There exists
a critical window for the ratio `ρ = k/m` such that:

1. If `ρ → ∞` (k grows, m fixed), then `P(⟨x,y⟩ = W) = 1 - O(k⁻¹)`.
2. If `ρ → 0` (m grows, k fixed), then `P(⟨x,y⟩ = W) ≤ exp(-cm)`.
3. The transition is governed by the sign of the effective free energy
   `Φ(k,m) = log |I(k,m)| - 2 log(min-index in I(k,m))`.

This is falsifiable: compute subgroup data for `km ≤ 12` and compare
with the pressure/free-energy statistic. -/