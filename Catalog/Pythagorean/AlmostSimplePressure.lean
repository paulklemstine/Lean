/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Pressure Theory for Almost Simple Groups

This file develops a quantitative pressure calculus for subgroup families
in finite groups, motivated by the Liebeck–Shalev philosophy of random
generation in almost simple groups.

## Mathematical Overview

For a finite group G with a family F of subgroups, the **subgroup family pressure**
is defined as
  P(G, F) = ∑_{H ∈ F} 1 / [G:H]²
This measures the aggregate contribution of F to the failure probability of
random pair generation: if a random pair (x,y) fails to generate G, it must
lie in some maximal subgroup H, contributing ≈ 1/[G:H]² to the failure mass.

The **entropy–energy method** converts classification data about subgroup
families into explicit decay bounds:
- **Entropy** = log |F| measures how many subgroups exist
- **Energy** = log min_index measures how large their indices are
- When energy dominates entropy (in the sense a < 2b), pressure decays
  polynomially in |G|.

## Main Definitions

* `familyPressure` — The sum ∑_{H ∈ F} 1 / [G:H]² for a finite set of subgroups.
* `PressureAdmissible` — A family satisfying count bound |F| ≤ C|G|^a and
  index lower bound [G:H] ≥ |G|^b for all H ∈ F.
* `pressureExponent` — The decay exponent 2b - a when a < 2b.
* `modelPressure` — Pressure bound for rank-one models.

## Main Results

* `familyPressure_union_le` — (Theorem B) Pressure is subadditive under union.
* `familyPressure_le_card_div_sq` — Core entropy–energy inequality.
* `pressure_le_of_admissible` — (Theorem A) Polynomial pressure decay.
* `generationFailure_le_familyPressure` — (Theorem C) Generation failure bridge.

## Cross-Domain Connections

* **Statistical mechanics**: Pressure = partition function of failure events;
  subadditivity = free energy decomposition by species.
* **Cryptography**: Low pressure ⟹ high random generation probability ⟹
  certified group selection for black-box algorithms.
* **Large deviations**: Pressure decay is a large-deviation principle for the
  event that a random pair lands in a structured overgroup.
-/

import Mathlib

open scoped BigOperators
open Finset Real Classical

noncomputable section

/-! ## Core Definitions -/

/-- The **family pressure** of a finite set of subgroups F in a finite group G.
This is the sum ∑_{H ∈ F} 1 / [G:H]², which measures the aggregate
contribution of F to the failure probability of random pair generation. -/
def familyPressure {G : Type*} [Group G] [Fintype G]
    (F : Finset (Subgroup G)) : ℝ :=
  ∑ H ∈ F, (1 : ℝ) / ((H.index : ℕ) : ℝ) ^ 2

/-- A subgroup family is **pressure-admissible** with parameters (a, b, C) if:
1. C ≥ 0
2. The family has at most C · |G|^a subgroups (entropy bound)
3. Every subgroup in F has index at least |G|^b (energy bound) -/
structure PressureAdmissible {G : Type*} [Group G] [Fintype G]
    (F : Finset (Subgroup G)) (a b C : ℝ) : Prop where
  hC : 0 ≤ C
  hcount : (F.card : ℝ) ≤ C * (Fintype.card G : ℝ) ^ a
  hindex : ∀ H ∈ F, ((H.index : ℕ) : ℝ) ≥ (Fintype.card G : ℝ) ^ b

/-- The **pressure exponent** 2b - a. When positive, this gives the rate of
polynomial decay of pressure. -/
def pressureExponent (a b : ℝ) : ℝ := 2 * b - a

/-- A **rank-one pressure model** encoding combinatorial data of a family
of almost simple groups with known maximal subgroup classification. -/
structure RankOnePressureData where
  groupOrder : ℕ
  familyCard : ℕ
  minIndex : ℕ
  hOrder : 2 ≤ groupOrder
  hCard : 0 < familyCard
  hIndex : 2 ≤ minIndex

/-- Model pressure for rank-one data: |F| / D². -/
def modelPressure (D : RankOnePressureData) : ℝ :=
  (D.familyCard : ℝ) / ((D.minIndex : ℝ) ^ 2)

/-! ## Basic Properties -/

/-
Each summand in family pressure is nonneg.
-/
theorem familyPressure_nonneg {G : Type*} [Group G] [Fintype G]
    (F : Finset (Subgroup G)) :
    0 ≤ familyPressure F := by
  exact Finset.sum_nonneg fun H hH => by positivity;

/-
Pressure of the empty family is zero.
-/
theorem familyPressure_empty {G : Type*} [Group G] [Fintype G] :
    familyPressure (∅ : Finset (Subgroup G)) = 0 := by
  exact Finset.sum_empty

/-
Pressure is monotone under inclusion.
-/
theorem familyPressure_mono {G : Type*} [Group G] [Fintype G]
    {F₁ F₂ : Finset (Subgroup G)} (h : F₁ ⊆ F₂) :
    familyPressure F₁ ≤ familyPressure F₂ := by
  exact Finset.sum_le_sum_of_subset_of_nonneg h fun _ _ _ => by positivity;

/-! ## Theorem B: Pressure Subadditivity -/

/-
**Pressure subadditivity**: the pressure of a union of two families is at most
the sum of their individual pressures. This enables the thermodynamic
decomposition by Aschbacher class.
-/
theorem familyPressure_union_le {G : Type*} [Group G] [Fintype G]
    (F₁ F₂ : Finset (Subgroup G)) :
    familyPressure (F₁ ∪ F₂) ≤ familyPressure F₁ + familyPressure F₂ := by
  unfold familyPressure; rw [ ← Finset.sum_union_inter ] ; ring_nf; norm_num;
  exact Finset.sum_nonneg fun _ _ => by positivity;

/-
Pressure of a finset-indexed union is bounded by the sum of pressures.
-/
theorem familyPressure_biUnion_le {G : Type*} [Group G] [Fintype G]
    {ι : Type*} [DecidableEq (Subgroup G)]
    (s : Finset ι) (F : ι → Finset (Subgroup G)) :
    familyPressure (s.biUnion F) ≤ ∑ i ∈ s, familyPressure (F i) := by
  induction' s using Finset.induction with i s hi ih;
  · simp +decide [ familyPressure_empty ];
  · rw [ Finset.sum_insert hi ];
    convert le_trans _ ( add_le_add_left ih _ ) using 1;
    rw [ add_comm ];
    convert familyPressure_union_le ( s.biUnion F ) ( F i ) using 1;
    exact congr_arg _ ( by ext; aesop )

/-! ## Core Entropy–Energy Inequality -/

/-
**Entropy–energy inequality**: if every subgroup in F has index at least D,
then familyPressure F ≤ |F| / D².
-/
theorem familyPressure_le_card_div_sq {G : Type*} [Group G] [Fintype G]
    (F : Finset (Subgroup G)) (D : ℝ) (hD : 0 < D)
    (hindex : ∀ H ∈ F, ((H.index : ℕ) : ℝ) ≥ D) :
    familyPressure F ≤ (F.card : ℝ) / D ^ 2 := by
  have h_sum_le : ∀ H ∈ F, (1 / ((H.index : ℕ) : ℝ) ^ 2) ≤ (1 / D ^ 2) := by
    exact fun H hH => one_div_le_one_div_of_le ( by positivity ) ( pow_le_pow_left₀ hD.le ( hindex H hH ) 2 );
  convert Finset.sum_le_sum h_sum_le using 1 ; norm_num ; ring

/-! ## Theorem A: Polynomial Pressure Decay -/

/-
**Polynomial pressure decay**: if |F| ≤ C·|G|^a and every index ≥ |G|^b,
then familyPressure F ≤ C · |G|^(a - 2b).

The proof:
1. Apply entropy–energy inequality with D = |G|^b
2. Bound |F| / D² ≤ C·|G|^a / (|G|^b)²
3. Simplify using |G|^a / |G|^(2b) = |G|^(a-2b)
-/
theorem pressure_le_of_admissible {G : Type*} [Group G] [Fintype G]
    (F : Finset (Subgroup G)) (a b C : ℝ)
    (_ : 0 ≤ C)
    (_ : (1 : ℝ) ≤ (Fintype.card G : ℝ))
    (_ : 0 < b)
    (hcount : (F.card : ℝ) ≤ C * (Fintype.card G : ℝ) ^ a)
    (hindex : ∀ H ∈ F, ((H.index : ℕ) : ℝ) ≥ (Fintype.card G : ℝ) ^ b) :
    familyPressure F ≤ C * (Fintype.card G : ℝ) ^ (a - 2 * b) := by
  convert familyPressure_le_card_div_sq F ( Fintype.card G ^ b ) ( by positivity ) hindex |> le_trans <| ?_ using 1;
  convert div_le_div_of_nonneg_right hcount ( sq_nonneg _ ) using 1 ; rw [ Real.rpow_sub ( by positivity ), Real.rpow_mul ( by positivity ) ] ; norm_num ; ring;
  rw [ inv_pow, ← Real.rpow_natCast _ 2, ← Real.rpow_mul ( by positivity ), mul_comm ] ; norm_num;
  rw [ mul_comm, ← Real.rpow_natCast, ← Real.rpow_mul ( by positivity ) ] ; ring

/-! ## Theorem C: Generation Probability Bridge -/

/-
The number of pairs (x,y) in G × G both contained in subgroup H
equals |H|².
-/
theorem card_pairs_in_subgroup {G : Type*} [Group G] [Fintype G]
    (H : Subgroup G) :
    (Finset.univ.filter (fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H)).card =
    (Fintype.card H) ^ 2 := by
  have h_filter : (Finset.card (Finset.filter (fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H) (Finset.univ : Finset (G × G)))) = (Finset.card (Finset.filter (fun x : G => x ∈ H) (Finset.univ : Finset G))) ^ 2 := by
    rw [ sq, ← Finset.card_product ] ; congr ; ext ; aesop;
  simp_all +decide [ Fintype.card_subtype ]

/-
**Generation failure bound**: the number of pairs lying in some H ∈ F
is at most |G|² · familyPressure(F). This connects pressure to
random generation: P[random pair ∈ some H] ≤ pressure.
-/
theorem generationFailure_le_familyPressure {G : Type*} [Group G] [Fintype G]
    (F : Finset (Subgroup G))
    (_ : 0 < Fintype.card G) :
    ((Finset.univ.filter (fun p : G × G =>
      ∃ H ∈ F, p.1 ∈ H ∧ p.2 ∈ H)).card : ℝ) ≤
    (Fintype.card G : ℝ) ^ 2 * familyPressure F := by
  -- Applying the union bound, we have that the cardinality of the set of pairs lying in some H ∈ F is at most the sum of the cardinalities of the sets of pairs lying in each H ∈ F.
  have h_union_bound : ((Finset.univ.filter (fun p : G × G => ∃ H ∈ F, p.1 ∈ H ∧ p.2 ∈ H)).card : ℝ) ≤ ∑ H ∈ F, (Finset.univ.filter (fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H)).card := by
    refine' mod_cast le_trans ( Finset.card_le_card _ ) _;
    exact Finset.biUnion F fun H => Finset.filter ( fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H ) Finset.univ;
    · aesop_cat;
    · exact Finset.card_biUnion_le;
  -- By card_pairs_in_subgroup, each term in the sum is |H|^2.
  have h_card_pairs : ∀ H ∈ F, (Finset.univ.filter (fun p : G × G => p.1 ∈ H ∧ p.2 ∈ H)).card = (Fintype.card H : ℝ) ^ 2 := by
    intro H hH; rw [ sq, Fintype.card_subtype ] ; norm_cast;
    rw [ ← Finset.card_product ] ; congr ; ext ; aesop;
  -- By Subgroup.card_mul_index, we have |H| = |G| / [G:H].
  have h_card_H : ∀ H ∈ F, (Fintype.card H : ℝ) = (Fintype.card G : ℝ) / (H.index : ℝ) := by
    intro H hH; rw [ eq_div_iff ] <;> norm_cast <;> simp +decide [ Subgroup.index, Fintype.card_subtype ] ;
    have := Subgroup.card_eq_card_quotient_mul_card_subgroup H; simp_all +decide [ Fintype.card_subtype ] ;
    ring;
  simp_all +decide [ familyPressure ];
  exact h_union_bound.trans_eq ( by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun _ _ => by ring )

/-! ## Rank-One Model -/

/-- Model pressure equals familyCard / minIndex². -/
theorem modelPressure_eq (D : RankOnePressureData) :
    modelPressure D = (D.familyCard : ℝ) / ((D.minIndex : ℝ) ^ 2) := by
  rfl

/-
Model pressure is nonneg.
-/
theorem modelPressure_nonneg (D : RankOnePressureData) :
    0 ≤ modelPressure D := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( sq_nonneg _ )

end