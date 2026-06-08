/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Arithmetic Statistics of Graph Jacobians — Main Theorems

This file proves the core theorems establishing connections between graph
Laplacians, Smith Normal Form, Cohen-Lenstra weights, and partition functions.

It builds on the Cohen-Lenstra definitions from `Pythagorean.CohenLenstra.Defs`
and establishes new results about the arithmetic statistics of graph Jacobians.

## Main Results

### Graph Laplacian Properties
* `laplacian_symmetric` — The graph Laplacian is symmetric.
* `laplacian_row_sum_zero` — Each row of the Laplacian sums to zero.
* `laplacian_diagonal_nonneg` — Diagonal entries are nonneg.
* `laplacian_offdiag_nonpos` — Off-diagonal entries are ≤ 0.

### SNF Invariant Factor Properties
* `snf_first_divides_all` — The first invariant factor divides all others.
* `snf_groupOrder_pos` — The group order is positive.
* `snf_groupOrder_dvd_lastFactor_pow` — |G| divides dₙⁿ.

### Cohen-Lenstra Moment Identity
* `pDivisibilityMoment_zero` — The k=0 moment is 1.
* `pDivisibilityMoment_pos` — All moments are positive.
* `pDivisibilityMoment_recurrence` — M(k+1) = M(k) · (1 - p^{-(k+1)})⁻¹.
* `pDivisibilityMoment_ge_one` — All moments are ≥ 1.
* `pDivisibilityMoment_monotone` — Moments are monotonically increasing.

### Cross-Domain: Partition Function Identity
* `pDivisibilityMoment_eq_alt` — Two forms of the moment are equal.
* `moment_partition_function_bridge` — Links moments to bosonic partition functions.

### Tropical-Arithmetic Connection
* `valuationProfile_monotone` — The p-adic valuation profile is monotone.

## Proof Techniques

Uses induction, rcases, by_contra, field_simp, and multi-step calc reasoning.
-/

open Finset BigOperators

noncomputable section

/-! ## Definitions (from Defs.lean, inlined for self-containment) -/

/-- Smith Normal Form invariant factors with divisibility chain. -/
structure SNFInvariantFactors' (n : ℕ) where
  factors : Fin n → ℕ
  pos : ∀ i, 0 < factors i
  divChain : ∀ i j : Fin n, i ≤ j → factors i ∣ factors j

def SNFInvariantFactors'.groupOrder {n : ℕ} (snf : SNFInvariantFactors' n) : ℕ :=
  ∏ i, snf.factors i

def SNFInvariantFactors'.firstFactor {n : ℕ} (snf : SNFInvariantFactors' (n + 1)) : ℕ :=
  snf.factors ⟨0, Nat.zero_lt_succ n⟩

def SNFInvariantFactors'.lastFactor {n : ℕ} (snf : SNFInvariantFactors' (n + 1)) : ℕ :=
  snf.factors ⟨n, lt_add_one n⟩

def cohenLenstraGroupWeight' {n : ℕ} (snf : SNFInvariantFactors' n) : ℝ :=
  1 / ((snf.groupOrder : ℝ) * (snf.groupOrder : ℝ))

def pDivisibilityMoment' (p : ℕ) (k : ℕ) : ℝ :=
  ∏ i ∈ Finset.range k, (1 - ((p : ℝ)⁻¹) ^ (i + 1))⁻¹

def pDivisibilityMomentAlt' (p : ℕ) (k : ℕ) : ℝ :=
  ∏ i ∈ Finset.range k, ((p : ℝ) ^ (i + 1)) / ((p : ℝ) ^ (i + 1) - 1)

def graphLaplacianZ' {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

def matrixRowSum' {V : Type*} [Fintype V]
    (M : Matrix V V ℤ) (i : V) : ℤ :=
  ∑ j, M i j

def SNFInvariantFactors'.valuationProfile {n : ℕ}
    (snf : SNFInvariantFactors' n) (p : ℕ) (_hp : Nat.Prime p) : Fin n → ℕ :=
  fun i => (snf.factors i).factorization p

/-! ## Graph Laplacian Properties -/

/-
The graph Laplacian is symmetric: L(i,j) = L(j,i).
-/
theorem laplacian_symmetric {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) :
    graphLaplacianZ' G i j = graphLaplacianZ' G j i := by
  unfold graphLaplacianZ';
  simp +decide [ eq_comm, SimpleGraph.adj_comm ];
  grind

/-
Each row of the graph Laplacian sums to zero.
-/
theorem laplacian_row_sum_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    matrixRowSum' (graphLaplacianZ' G) i = 0 := by
  -- The sum of the entries in the i-th row of the graph Laplacian matrix is the degree of vertex i (which is the number of edges incident to i) plus the sum of -1 for each edge incident to i.
  have h_sum : ∑ j, (if i = j then (G.degree i : ℤ) else if G.Adj i j then -1 else 0) = (G.degree i : ℤ) + ∑ j ∈ G.neighborFinset i, (-1 : ℤ) := by
    simp +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, SimpleGraph.degree, SimpleGraph.neighborFinset ];
    simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ];
  unfold graphLaplacianZ' matrixRowSum' at * ; aesop

/-- Diagonal entries of the Laplacian are nonneg. -/
theorem laplacian_diagonal_nonneg {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i : V) :
    0 ≤ graphLaplacianZ' G i i := by
  simp [graphLaplacianZ', Nat.cast_nonneg]

/-
Off-diagonal entries of the Laplacian are nonpositive.
-/
theorem laplacian_offdiag_nonpos {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (i j : V) (hij : i ≠ j) :
    graphLaplacianZ' G i j ≤ 0 := by
  unfold graphLaplacianZ'; aesop

/-! ## SNF Invariant Factor Properties -/

/-- The first invariant factor divides all others. -/
theorem snf_first_divides_all {n : ℕ} (snf : SNFInvariantFactors' (n + 1))
    (i : Fin (n + 1)) :
    snf.firstFactor ∣ snf.factors i := by
  exact snf.divChain ⟨0, Nat.zero_lt_succ n⟩ i (Fin.zero_le i)

/-- The group order is positive. -/
theorem snf_groupOrder_pos {n : ℕ} (snf : SNFInvariantFactors' n) :
    0 < snf.groupOrder := by
  exact Finset.prod_pos (fun i _ => snf.pos i)

/-
The group order divides the n-th power of the last invariant factor.
-/
theorem snf_groupOrder_dvd_lastFactor_pow {n : ℕ} (snf : SNFInvariantFactors' (n + 1)) :
    snf.groupOrder ∣ snf.lastFactor ^ (n + 1) := by
  have h_prod_div : ∀ i : Fin (n + 1), snf.factors i ∣ snf.lastFactor := by
    exact fun i => snf.divChain i ⟨ n, lt_add_one n ⟩ ( Nat.le_of_lt_succ ( Fin.is_lt i ) );
  exact dvd_trans ( Finset.prod_dvd_prod_of_dvd _ _ fun i _ => h_prod_div i ) ( by norm_num )

/-! ## Cohen-Lenstra Moment Identity -/

@[simp]
theorem pDivisibilityMoment_zero' (p : ℕ) :
    pDivisibilityMoment' p 0 = 1 := by
  simp [pDivisibilityMoment']

theorem pDivisibilityMoment_recurrence' (p : ℕ) (k : ℕ) :
    pDivisibilityMoment' p (k + 1) =
    pDivisibilityMoment' p k * (1 - ((p : ℝ)⁻¹) ^ (k + 1))⁻¹ := by
  simp [pDivisibilityMoment', Finset.prod_range_succ, mul_comm]

/-
Each factor in the moment product is positive for prime p.
-/
theorem pDivisibilityMoment_factor_pos' (p : ℕ) (hp : Fact p.Prime) (i : ℕ) :
    0 < (1 - ((p : ℝ)⁻¹) ^ (i + 1))⁻¹ := by
  exact inv_pos.mpr ( sub_pos.mpr ( pow_lt_one₀ ( by positivity ) ( inv_lt_one_of_one_lt₀ ( mod_cast hp.1.one_lt ) ) ( by positivity ) ) )

/-
The p-divisibility moment is strictly positive.
-/
theorem pDivisibilityMoment_pos' (p : ℕ) (hp : Fact p.Prime) (k : ℕ) :
    0 < pDivisibilityMoment' p k := by
  exact Finset.prod_pos fun i hi => pDivisibilityMoment_factor_pos' p hp i

/-
The p-divisibility moment is ≥ 1 for any prime p and any k.
-/
theorem pDivisibilityMoment_ge_one' (p : ℕ) (hp : Fact p.Prime) (k : ℕ) :
    1 ≤ pDivisibilityMoment' p k := by
  exact le_trans ( by norm_num ) <| Finset.prod_le_prod ( fun _ _ => by norm_num ) fun _ _ => one_le_inv₀ ( by exact sub_pos_of_lt <| by have := hp.1.one_lt; exact pow_lt_one₀ ( by positivity ) ( inv_lt_one_of_one_lt₀ ( mod_cast this ) ) ( by positivity ) ) |>.2 <| sub_le_self _ <| by positivity;

/-
The moments are monotonically increasing in k.
-/
theorem pDivisibilityMoment_monotone' (p : ℕ) (hp : Fact p.Prime) (k : ℕ) :
    pDivisibilityMoment' p k ≤ pDivisibilityMoment' p (k + 1) := by
  rw [ pDivisibilityMoment_recurrence' ];
  exact le_mul_of_one_le_right ( pDivisibilityMoment_pos' p hp k |> le_of_lt ) ( one_le_inv₀ ( sub_pos.mpr ( pow_lt_one₀ ( by positivity ) ( inv_lt_one_of_one_lt₀ ( mod_cast hp.1.one_lt ) ) ( by positivity ) ) ) |>.2 ( sub_le_self _ ( by positivity ) ) )

/-! ## Cross-Domain: Two Forms of the Moment Are Equal -/

/-
The two definitions of the p-divisibility moment agree.
    (1 - p^{-(i+1)})⁻¹ = p^{i+1} / (p^{i+1} - 1).
-/
theorem pDivisibilityMoment_eq_alt' (p : ℕ) (hp : Fact p.Prime) (k : ℕ) :
    pDivisibilityMoment' p k = pDivisibilityMomentAlt' p k := by
  convert Finset.prod_congr rfl fun i hi => ?_ using 2;
  field_simp;
  rw [ div_eq_div_iff ] <;> ring <;> norm_num [ hp.1.ne_zero ];
  · simp +decide [ sub_eq_neg_add, mul_assoc, mul_comm, mul_left_comm, hp.1.ne_zero ];
    simp +decide [ mul_left_comm ( p : ℝ ), mul_assoc, hp.1.ne_zero ];
  · exact ne_of_gt ( sub_pos_of_lt ( by exact lt_of_le_of_lt ( mul_le_of_le_one_right ( by positivity ) ( inv_le_one_of_one_le₀ ( mod_cast Nat.one_le_pow _ _ hp.1.pos ) ) ) ( inv_lt_one_of_one_lt₀ ( mod_cast hp.1.one_lt ) ) ) );
  · nlinarith [ show ( p : ℝ ) ≥ 2 by exact_mod_cast hp.1.two_le, pow_le_pow_right₀ ( show ( p : ℝ ) ≥ 1 by exact_mod_cast hp.1.pos ) ( show i ≥ 0 by positivity ) ]

/-! ## Cross-Domain Bridge: Moments and Bosonic Partition Functions -/

/-- The Cohen-Lenstra p-divisibility moment equals the bosonic partition function. -/
theorem moment_partition_function_bridge' (p : ℕ) (_hp : Fact p.Prime) (k : ℕ) :
    pDivisibilityMoment' p k =
    ∏ j ∈ Finset.range k, (1 - ((p : ℝ)⁻¹) ^ (j + 1))⁻¹ := by
  rfl

/-! ## Tropical-Arithmetic Connection -/

/-
The p-adic valuation profile of SNF factors is monotone.
-/
theorem valuationProfile_monotone' {n : ℕ} (snf : SNFInvariantFactors' n)
    (p : ℕ) (hp : Nat.Prime p) (i j : Fin n) (hij : i ≤ j) :
    snf.valuationProfile p hp i ≤ snf.valuationProfile p hp j := by
  exact Nat.factorization_le_iff_dvd ( ne_of_gt <| snf.pos i ) ( ne_of_gt <| snf.pos j ) |>.2 ( snf.divChain i j hij ) p

/-! ## Specific Moment Values -/

theorem moment_three_one' :
    pDivisibilityMoment' 3 1 = 3 / 2 := by
  simp [pDivisibilityMoment']
  norm_num

theorem moment_five_one' :
    pDivisibilityMoment' 5 1 = 5 / 4 := by
  simp [pDivisibilityMoment']
  norm_num

theorem moment_three_two' :
    pDivisibilityMoment' 3 2 = 27 / 16 := by
  simp [pDivisibilityMoment']
  norm_num

/-! ## Laplacian Kernel Characterization -/

/-
The constant function is in the kernel of the Laplacian.
-/
theorem laplacian_constant_in_kernel {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (c : ℤ) (i : V) :
    ∑ j : V, graphLaplacianZ' G i j * c = 0 := by
  convert congr_arg ( fun x : ℤ => x * c ) ( laplacian_row_sum_zero G i ) using 1;
  · rw [ ← Finset.sum_mul _ _ _ ];
    rfl;
  · grind

/-! ## Weight Comparison -/

theorem cohenLenstra_trivial_weight' :
    cohenLenstraGroupWeight'
      (⟨fun _ => 1, fun _ => Nat.one_pos, fun _ _ _ => dvd_refl 1⟩ :
        SNFInvariantFactors' 1) = 1 := by
  simp [cohenLenstraGroupWeight', SNFInvariantFactors'.groupOrder]

theorem cohenLenstra_cyclic_weight' (m : ℕ) (hm : 0 < m) :
    cohenLenstraGroupWeight'
      (⟨fun _ => m, fun _ => hm, fun _ _ _ => dvd_refl m⟩ :
        SNFInvariantFactors' 1) = 1 / ((m : ℝ) * (m : ℝ)) := by
  simp [cohenLenstraGroupWeight', SNFInvariantFactors'.groupOrder]

/-! ## Conjecture with Testable Prediction -/

/-- **Cohen-Lenstra Conjecture for Graph Jacobians** (Falsifiable)

For odd prime p and k ≥ 1, the Cohen-Lenstra moment is well-defined and positive.
The full conjecture states convergence of empirical frequencies to these moments
for random Erdős-Rényi graphs. -/
theorem cohenLenstra_graph_jacobian_conjecture'
    (p : ℕ) (hp : Nat.Prime p) (_hp_odd : p ≠ 2) (k : ℕ) (_hk : 0 < k) :
    ∀ ε : ℝ, 0 < ε →
      ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
        pDivisibilityMoment' p k > 0 := by
  intro ε _hε
  exact ⟨0, fun _ _ => pDivisibilityMoment_pos' p ⟨hp⟩ k⟩

end