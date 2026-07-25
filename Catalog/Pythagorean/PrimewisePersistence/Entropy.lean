/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Shannon Entropy for Barcode Distributions

This file establishes the information-theoretic foundations for primewise
persistent homology. The central result is entropy monotonicity under
refinement: when a barcode distribution is refined (each bar split into
sub-bars preserving total mass), the Shannon entropy does not decrease.

## Main Definitions

* `PrimewisePersistence.IsProbDist` - valid probability distribution on `Fin n`
* `PrimewisePersistence.shannonEntropy` - Shannon entropy H(p) = -∑ pᵢ log pᵢ
* `PrimewisePersistence.coarsen` - coarsening of a distribution via a partition map

## Main Results

* `PrimewisePersistence.prob_le_one` - each probability ≤ 1
* `PrimewisePersistence.mul_log_nonpos_of_mem_Icc` - x log x ≤ 0 for x ∈ [0,1]
* `PrimewisePersistence.shannonEntropy_nonneg` - H(p) ≥ 0 for any probability distribution
* `PrimewisePersistence.sum_mul_log_le_totalMul_log_total` -
    ∑ xᵢ log xᵢ ≤ (∑ xᵢ) log(∑ xᵢ) for nonneg xᵢ
* `PrimewisePersistence.entropy_monotone_coarsening` -
    H(coarsen f q) ≤ H(q) when f is surjective

## Mathematical Context

Barcode entropy measures the information-theoretic complexity of a
persistence barcode. The monotonicity theorem establishes that finer
arithmetic filtrations always produce richer persistence profiles,
providing a robust invariant for large-scale experiments.
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

namespace PrimewisePersistence

/-! ## Probability Distributions -/

/-- A valid probability distribution on `Fin n`: all entries nonneg and sum to 1. -/
structure IsProbDist {n : ℕ} (p : Fin n → ℝ) : Prop where
  nonneg : ∀ i, 0 ≤ p i
  sum_one : ∑ i, p i = 1

/-
Each probability in a valid distribution is at most 1.
-/
theorem prob_le_one {n : ℕ} {p : Fin n → ℝ} (hp : IsProbDist p) (i : Fin n) :
    p i ≤ 1 := by
  exact le_trans ( Finset.single_le_sum ( fun a _ => hp.nonneg a ) ( Finset.mem_univ i ) ) hp.sum_one.le

/-! ## Shannon Entropy -/

/-- Shannon entropy of a distribution on `Fin n`, using the convention 0 log 0 = 0. -/
def shannonEntropy (n : ℕ) (p : Fin n → ℝ) : ℝ :=
  -∑ i : Fin n, p i * Real.log (p i)

/-
For x ∈ [0,1], x * log(x) ≤ 0.
This is the pointwise ingredient for entropy nonnegativity.
-/
theorem mul_log_nonpos_of_mem_Icc {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    x * Real.log x ≤ 0 := by
  exact mul_nonpos_of_nonneg_of_nonpos hx0 ( Real.log_nonpos hx0 hx1 )

/-
**Shannon entropy is nonnegative** for any probability distribution.
This is the foundational inequality of information theory.
-/
theorem shannonEntropy_nonneg {n : ℕ} {p : Fin n → ℝ} (hp : IsProbDist p) :
    0 ≤ shannonEntropy n p := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun i _ => mul_log_nonpos_of_mem_Icc ( hp.nonneg i ) ( prob_le_one hp i ) )

/-! ## Entropy Monotonicity Under Refinement -/

/-- Coarsening a distribution: given `f : Fin m → Fin n` and `q : Fin m → ℝ`,
the coarsened distribution assigns to each `j : Fin n` the sum of `q i` over
all `i` mapping to `j`. -/
def coarsen {m n : ℕ} (f : Fin m → Fin n) (q : Fin m → ℝ) : Fin n → ℝ :=
  fun j => ∑ i ∈ Finset.univ.filter (fun i => f i = j), q i

/-
Coarsening a probability distribution yields a probability distribution.
-/
theorem coarsen_isProbDist {m n : ℕ} {f : Fin m → Fin n}
    (_hf : Function.Surjective f) {q : Fin m → ℝ} (hq : IsProbDist q) :
    IsProbDist (coarsen f q) := by
  constructor;
  · exact fun i => Finset.sum_nonneg fun _ _ => hq.nonneg _;
  · convert hq.sum_one using 1;
    unfold coarsen; rw [ Finset.sum_fiberwise_of_maps_to ] ; aesop;

/-
**Key lemma for entropy monotonicity.**
For nonnegative reals xᵢ with total sum S,
∑ xᵢ · log(xᵢ) ≤ S · log(S).
This follows from Shannon entropy nonnegativity applied to the
normalized distribution xᵢ/S.
-/
theorem sum_mul_log_le_totalMul_log_total {ι : Type*} [Fintype ι]
    (x : ι → ℝ) (hx : ∀ i, 0 ≤ x i) :
    ∑ i, x i * Real.log (x i) ≤ (∑ i, x i) * Real.log (∑ i, x i) := by
  -- By definition of summation, we can write $\sum_{i} x_{i} \log(x_{i})$ as $\sum_{i \in \text{supp}(x)} x_{i} \log(x_{i})$.
  have h_sum_def : ∑ i, x i * Real.log (x i) = ∑ i ∈ Finset.univ.filter (fun i => x i ≠ 0), x i * Real.log (x i) := by
    rw [ Finset.sum_filter_of_ne ] ; aesop;
  -- Applying the inequality $ �x� \log x \leq x \log S$ for each $x_i$ in the support of $x$ where $S = \sum_{i} x_i$.
  have h_ineq : ∀ i ∈ Finset.univ.filter (fun i => x i ≠ 0), x i * Real.log (x i) ≤ x i * Real.log (∑ j, x j) := by
    exact fun i hi => mul_le_mul_of_nonneg_left ( Real.log_le_log ( lt_of_le_of_ne ( hx i ) ( Ne.symm ( by simpa using hi ) ) ) ( Finset.single_le_sum ( fun i _ => hx i ) ( Finset.mem_univ i ) ) ) ( hx i );
  convert Finset.sum_le_sum h_ineq using 1 ; simp +decide [ Finset.sum_mul _ _ _, Finset.sum_filter_of_ne ];
  rw [ Finset.sum_filter_of_ne ] ; aesop

/-
**Entropy monotonicity under coarsening.**
If `q` is a probability distribution on `Fin m` and `f : Fin m → Fin n` is surjective,
then the coarsened distribution `coarsen f q` has entropy at most that of `q`.
Equivalently, refinement never decreases entropy.

This is the information-theoretic backbone of the primewise persistence program:
finer arithmetic filtrations produce more complex (higher-entropy) barcode profiles.
-/
theorem entropy_monotone_coarsening {m n : ℕ} {f : Fin m → Fin n}
    (_hf : Function.Surjective f) {q : Fin m → ℝ} (hq : IsProbDist q) :
    shannonEntropy n (coarsen f q) ≤ shannonEntropy m q := by
  -- Apply the key lemma to each fiber: ∑_{i: f(i)=j} q_i * log(q_i) ≤ P_j * log(P_j).
  have h_fiber : ∀ j, ∑ i ∈ Finset.univ.filter (fun i => f i = j), q i * Real.log (q i) ≤ (coarsen f q j) * Real.log (coarsen f q j) := by
    intro j
    have := sum_mul_log_le_totalMul_log_total (fun i => if f i = j then q i else 0) (fun i => by
      exact by by_cases hi : f i = j <;> simp +decide [ hi, hq.nonneg ] ;);
    simp_all +decide [ coarsen ];
    simpa [ Finset.sum_ite ] using this;
  convert neg_le_neg ( Finset.sum_le_sum fun j _ => h_fiber j ) using 1;
  exact congrArg Neg.neg ( by rw [ Finset.sum_fiberwise_of_maps_to ( fun i _ => Finset.mem_univ _ ) ] )

end PrimewisePersistence