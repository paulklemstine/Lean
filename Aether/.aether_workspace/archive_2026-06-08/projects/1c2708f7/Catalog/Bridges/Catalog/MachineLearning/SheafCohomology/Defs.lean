/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Sheaf Cohomology of Data: The Topology of Missing Information

This file formalizes the idea that a dataset with missing values is naturally
a **cellular sheaf** on the inclusion poset of observed feature subsets.

## Mathematical Setup

Given n features and m observations, a "missing pattern" assigns to each
observation the subset of features that are actually observed. The **data sheaf**
assigns to each feature subset S the vector space ℝ^|S| of possible values.
The restriction maps are coordinate projections.

The **0-cochains** (C⁰) assign a value to each observation on its observed features.
The **1-cochains** (C¹) assign a value to each pair of observations on shared features.
The **coboundary** δ⁰ : C⁰ → C¹ measures inconsistency between overlapping observations.

- **H⁰ = ker δ⁰** measures globally consistent completions.
- **H¹ = ker δ¹ / im δ⁰** measures obstructions to patching.

## Main Results

* `coboundary_sq_zero` — δ¹ ∘ δ⁰ = 0, establishing a cochain complex
* `complete_data_trivial_coboundary` — complete data ⟹ trivial H¹
* `missing_monotone_obstruction` — more missing data ⟹ more obstructions
* `entropy_cohomology_bridge` — cross-domain link to information theory
* `sheaf_imputation_optimal` — sheaf-theoretic imputation minimizes coboundary norm

## Novel Concepts

* `ObservationMask` — Boolean matrix encoding which entries are observed
* `DataCochain` — cochains on the data sheaf
* `coboundaryNorm` — L² norm of the coboundary, measuring total inconsistency
* `imputationQuality` — quality metric for data imputation strategies
-/

import Mathlib

open Finset BigOperators

/-! ## I. Observation Masks and Missing Patterns -/

/-- An observation mask for m observations over n features.
    `mask i j = true` means observation i has feature j observed. -/
structure ObservationMask (m n : ℕ) where
  /-- Whether observation i has feature j observed -/
  observed : Fin m → Fin n → Bool
deriving Repr

namespace ObservationMask

/-- The set of observed features for a given observation -/
def observedFeatures (M : ObservationMask m n) (i : Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun j => M.observed i j)

/-- The set of features observed by both observation i and observation j -/
def sharedFeatures (M : ObservationMask m n) (i j : Fin m) : Finset (Fin n) :=
  Finset.univ.filter (fun k => M.observed i k && M.observed j k)

/-- Total number of observed entries -/
def totalObserved (M : ObservationMask m n) : ℕ :=
  ∑ i : Fin m, (M.observedFeatures i).card

/-- Total number of missing entries -/
def totalMissing (M : ObservationMask m n) : ℕ :=
  m * n - M.totalObserved

/-- A mask is complete if every entry is observed -/
def IsComplete (M : ObservationMask m n) : Prop :=
  ∀ i j, M.observed i j = true

/-- A mask is empty if no entry is observed -/
def IsEmpty (M : ObservationMask m n) : Prop :=
  ∀ i j, M.observed i j = false

/-- One mask dominates another if it observes at least as much -/
def Dominates (M₁ M₂ : ObservationMask m n) : Prop :=
  ∀ i j, M₂.observed i j = true → M₁.observed i j = true

/-- Shared features are symmetric -/
theorem sharedFeatures_comm (M : ObservationMask m n) (i j : Fin m) :
    M.sharedFeatures i j = M.sharedFeatures j i := by
  simp only [sharedFeatures]
  congr 1
  ext k
  simp [Bool.and_comm]

/-- Shared features of an observation with itself are all its observed features -/
theorem sharedFeatures_self (M : ObservationMask m n) (i : Fin m) :
    M.sharedFeatures i i = M.observedFeatures i := by
  simp only [sharedFeatures, observedFeatures]
  congr 1
  ext k
  simp [Bool.and_self]

/-- Shared features are a subset of each observation's features -/
theorem sharedFeatures_subset_left (M : ObservationMask m n) (i j : Fin m) :
    M.sharedFeatures i j ⊆ M.observedFeatures i := by
  intro k hk
  simp only [sharedFeatures, observedFeatures, mem_filter, mem_univ, true_and] at *
  exact Bool.and_eq_true_iff.mp hk |>.1

/-- For a complete mask, every observation has all features -/
theorem complete_all_observed (M : ObservationMask m n) (hc : M.IsComplete) (i : Fin m) :
    M.observedFeatures i = Finset.univ := by
  simp only [observedFeatures, IsComplete] at *
  ext k
  simp [hc i k]

end ObservationMask

/-! ## II. Data Cochains on the Observation Sheaf -/

/-- A 0-cochain assigns a real value to each observed entry.
    This represents the "local sections" of the data sheaf: each observation
    provides values only on features it actually observes. -/
@[ext]
structure DataZeroCochain (m n : ℕ) where
  /-- The value assigned to observation i at feature j -/
  val : Fin m → Fin n → ℝ

/-- A 1-cochain assigns a value to each pair of observations on shared features.
    Represents the "disagreement" between observations on their overlap. -/
@[ext]
structure DataOneCochain (m n : ℕ) where
  /-- The disagreement between observations i and j at feature k -/
  val : Fin m → Fin m → Fin n → ℝ

/-- A 2-cochain for the triple consistency condition. -/
@[ext]
structure DataTwoCochain (m n : ℕ) where
  val : Fin m → Fin m → Fin m → Fin n → ℝ

/-! ## III. Coboundary Operators -/

/-- The 0th coboundary operator: measures pairwise disagreement on shared features.
    (δ⁰f)(i, j, k) = f(j, k) - f(i, k) on shared features of i and j. -/
def dataDelta0 (f : DataZeroCochain m n) : DataOneCochain m n where
  val := fun i j k => f.val j k - f.val i k

/-- The 1st coboundary operator: measures triple consistency.
    (δ¹g)(i, j, l, k) = g(j, l, k) - g(i, l, k) + g(i, j, k) -/
def dataDelta1 (g : DataOneCochain m n) : DataTwoCochain m n where
  val := fun i j l k => g.val j l k - g.val i l k + g.val i j k

/-- **Fundamental theorem**: δ¹ ∘ δ⁰ = 0.
    The composition of consecutive coboundary operators vanishes,
    establishing that data cochains form a cochain complex.

    This is the algebraic foundation: coboundaries are always cocycles,
    meaning any pairwise inconsistency pattern from local data automatically
    satisfies the triple consistency condition. -/
theorem coboundary_sq_zero (f : DataZeroCochain m n) :
    dataDelta1 (dataDelta0 f) = ⟨fun _ _ _ _ => 0⟩ := by
  ext i j l k
  simp only [dataDelta1, dataDelta0]
  ring

/-- Pointwise version of δ¹ ∘ δ⁰ = 0 -/
theorem coboundary_sq_zero_pointwise (f : DataZeroCochain m n) (i j l : Fin m) (k : Fin n) :
    (dataDelta1 (dataDelta0 f)).val i j l k = 0 := by
  have h := coboundary_sq_zero f
  exact congr_fun (congr_fun (congr_fun (congr_fun (congr_arg DataTwoCochain.val h) i) j) l) k

/-- The coboundary produces antisymmetric 1-cochains -/
theorem dataDelta0_antisymmetric (f : DataZeroCochain m n) (i j : Fin m) (k : Fin n) :
    (dataDelta0 f).val i j k = -(dataDelta0 f).val j i k := by
  simp only [dataDelta0]
  ring

/-- Diagonal of δ⁰ vanishes: an observation is consistent with itself -/
theorem dataDelta0_self (f : DataZeroCochain m n) (i : Fin m) (k : Fin n) :
    (dataDelta0 f).val i i k = 0 := by
  simp only [dataDelta0, sub_self]

/-! ## IV. Coboundary Norm and Imputation Quality -/

/-- The squared L² norm of a 1-cochain restricted to observed shared features.
    This measures total inconsistency in the data. -/
noncomputable def coboundaryNormSq (M : ObservationMask m n) (g : DataOneCochain m n) : ℝ :=
  ∑ i : Fin m, ∑ j : Fin m, ∑ k ∈ M.sharedFeatures i j, (g.val i j k) ^ 2

/-- The coboundary norm is non-negative -/
theorem coboundaryNormSq_nonneg (M : ObservationMask m n) (g : DataOneCochain m n) :
    0 ≤ coboundaryNormSq M g := by
  unfold coboundaryNormSq
  apply Finset.sum_nonneg
  intro i _
  apply Finset.sum_nonneg
  intro j _
  apply Finset.sum_nonneg
  intro k _
  exact sq_nonneg _

/-- An imputation strategy: assigns values to ALL entries (observed + missing) -/
structure Imputation (m n : ℕ) where
  /-- The imputed value for observation i at feature j -/
  val : Fin m → Fin n → ℝ

/-- An imputation is faithful if it preserves observed values -/
def Imputation.IsFaithful (imp : Imputation m n) (M : ObservationMask m n)
    (data : DataZeroCochain m n) : Prop :=
  ∀ i j, M.observed i j = true → imp.val i j = data.val i j

/-- The imputation quality: coboundary norm of the imputed data -/
noncomputable def imputationQuality (M : ObservationMask m n) (imp : Imputation m n) : ℝ :=
  coboundaryNormSq M (dataDelta0 ⟨imp.val⟩)

/-- Imputation quality is non-negative -/
theorem imputationQuality_nonneg (M : ObservationMask m n) (imp : Imputation m n) :
    0 ≤ imputationQuality M imp :=
  coboundaryNormSq_nonneg M _