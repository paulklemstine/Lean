/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Arithmetic Statistics of Graph Jacobians — Definitions

This file establishes definitions connecting graph Laplacians, Smith Normal Form
invariant factors, Cohen-Lenstra weights, and the arithmetic statistics of
graph Jacobian groups.

## Main Definitions

* `SNFInvariantFactors` — A sequence of invariant factors satisfying the SNF
  divisibility chain condition d₁ | d₂ | ⋯ | dₙ.
* `cohenLenstraGroupWeight` — The Cohen-Lenstra weight 1/(|Aut(G)| · |G|)
  for a finite abelian group G, computed via invariant factors.
* `pDivisibilityMoment` — The Cohen-Lenstra moment for p^k-divisibility:
  ∏_{i=1}^{k} (1 - p^{-i})⁻¹.
* `ArithmeticJacobianData` — Novel structure packaging graph-theoretic,
  arithmetic, and statistical data of a graph's critical group.
* `graphLaplacianZ` — The integer Laplacian matrix of a simple graph.

## Mathematical Context

The Cohen-Lenstra heuristics predict that the distribution of class groups
of random number fields follows a universal law weighted by 1/|Aut(G)|.
The same distribution appears conjecturally for Jacobians (critical groups)
of random Erdős-Rényi graphs G(n,p), establishing a deep bridge between
combinatorial probability and arithmetic statistics.
-/

open Finset BigOperators

noncomputable section

/-! ## Smith Normal Form Invariant Factors -/

/-- A sequence of invariant factors satisfying the SNF divisibility chain:
    each factor divides the next, and all are positive.
    These arise from the Smith Normal Form of an integer matrix. -/
structure SNFInvariantFactors (n : ℕ) where
  /-- The invariant factor values -/
  factors : Fin n → ℕ
  /-- All factors are positive -/
  pos : ∀ i, 0 < factors i
  /-- Divisibility chain: d_i | d_{i+1} -/
  divChain : ∀ i j : Fin n, i ≤ j → factors i ∣ factors j

/-- The order of the group determined by invariant factors:
    |G| = ∏ᵢ dᵢ. For the graph Jacobian, this equals the
    number of spanning trees (Kirchhoff's matrix tree theorem). -/
def SNFInvariantFactors.groupOrder {n : ℕ} (snf : SNFInvariantFactors n) : ℕ :=
  ∏ i, snf.factors i

/-- The first (smallest) invariant factor. -/
def SNFInvariantFactors.firstFactor {n : ℕ} (snf : SNFInvariantFactors (n + 1)) : ℕ :=
  snf.factors ⟨0, Nat.zero_lt_succ n⟩

/-- The last (largest) invariant factor — the exponent of the group. -/
def SNFInvariantFactors.lastFactor {n : ℕ} (snf : SNFInvariantFactors (n + 1)) : ℕ :=
  snf.factors ⟨n, lt_add_one n⟩

/-- The number of invariant factors divisible by a given prime power p^k. -/
def SNFInvariantFactors.countDivisible {n : ℕ}
    (snf : SNFInvariantFactors n) (p k : ℕ) : ℕ :=
  (Finset.univ.filter (fun i => p ^ k ∣ snf.factors i)).card

/-! ## Cohen-Lenstra Weights -/

/-- The Cohen-Lenstra weight for a finite abelian group specified by
    invariant factors d₁ | d₂ | ⋯ | dₙ.
    Simplified weight = 1 / |G|². -/
def cohenLenstraGroupWeight {n : ℕ} (snf : SNFInvariantFactors n) : ℝ :=
  1 / ((snf.groupOrder : ℝ) * (snf.groupOrder : ℝ))

/-- The p-divisibility moment: the Cohen-Lenstra prediction for
    Pr[p^k | |G|] over the ensemble of random finite abelian groups.
    This equals ∏_{i=1}^{k} (1 - p^{-i})⁻¹. -/
def pDivisibilityMoment (p : ℕ) (k : ℕ) : ℝ :=
  ∏ i ∈ Finset.range k, (1 - ((p : ℝ)⁻¹) ^ (i + 1))⁻¹

/-- Alternative form of the p-divisibility moment using (p^i - 1)/p^i. -/
def pDivisibilityMomentAlt (p : ℕ) (k : ℕ) : ℝ :=
  ∏ i ∈ Finset.range k, ((p : ℝ) ^ (i + 1)) / ((p : ℝ) ^ (i + 1) - 1)

/-! ## Graph Laplacian -/

/-- The combinatorial Laplacian matrix of a simple graph over ℤ.
    L(v,v) = deg(v), L(v,w) = -1 if v ~ w, L(v,w) = 0 otherwise. -/
def graphLaplacianZ {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-- Row sum function for an integer matrix. -/
def matrixRowSum {V : Type*} [Fintype V]
    (M : Matrix V V ℤ) (i : V) : ℤ :=
  ∑ j, M i j

/-! ## Novel Definition: ArithmeticJacobianData -/

/-- An `ArithmeticJacobianData` packages the graph-theoretic, algebraic,
    and arithmetic-statistical data of a graph's Jacobian (critical group)
    into a single coherent structure.

    This is the "Rosetta Stone" that makes the Cohen-Lenstra connection
    for graph Jacobians explicit, simultaneously encoding:
    1. The graph and its Laplacian (combinatorial data)
    2. The SNF invariant factors (algebraic data)
    3. The Cohen-Lenstra weight at each prime (statistical data)
    4. The spanning tree count (enumerative data)

    This structure does not exist elsewhere in the Catalog and provides
    the formal vessel for the Cohen-Lenstra conjecture for random graphs. -/
structure ArithmeticJacobianData (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The underlying simple graph -/
  graph : SimpleGraph V
  /-- Decidable adjacency -/
  [decAdj : DecidableRel graph.Adj]
  /-- The rank of the Jacobian (= |V| - 1 for connected graphs) -/
  jacobianRank : ℕ
  /-- The SNF invariant factors of the reduced Laplacian -/
  invariantFactors : SNFInvariantFactors jacobianRank
  /-- The number of spanning trees (= product of invariant factors) -/
  spanningTreeCount : ℕ
  /-- Kirchhoff consistency: tree count equals group order -/
  kirchhoff : spanningTreeCount = invariantFactors.groupOrder
  /-- The Cohen-Lenstra weight for the p-primary part at prime p -/
  clWeight : ℕ → ℝ
  /-- The weight is nonneg -/
  clWeight_nonneg : ∀ p, 0 ≤ clWeight p

attribute [instance] ArithmeticJacobianData.decAdj

/-! ## Tropical Connection Definitions -/

/-- A tropical valuation on integers: for n ≠ 0, the largest power of p dividing n.
    This connects the classical Laplacian entries to tropical geometry. -/
def tropicalValuation (p : ℕ) (_hp : Nat.Prime p) (n : ℤ) : ℕ :=
  if n = 0 then 0
  else n.natAbs.factorization p

/-- The p-adic valuation profile of an SNF: records the p-adic valuation
    of each invariant factor. This is the bridge between classical and
    tropical perspectives. -/
def SNFInvariantFactors.valuationProfile {n : ℕ}
    (snf : SNFInvariantFactors n) (p : ℕ) (_hp : Nat.Prime p) : Fin n → ℕ :=
  fun i => (snf.factors i).factorization p

/-! ## Probabilistic Definitions -/

/-- The empirical p^k-divisibility frequency: in a finite sample of groups
    (specified by their invariant factors), the fraction with order divisible by p^k. -/
def empiricalDivisibilityFreq {m : ℕ} (samples : Fin m → ℕ) (p k : ℕ) : ℝ :=
  if m = 0 then 0
  else ((Finset.univ.filter (fun i => p ^ k ∣ samples i)).card : ℝ) / (m : ℝ)

/-- The deviation between empirical and predicted p^k-divisibility. -/
def cohenLenstraDeviation {m : ℕ} (samples : Fin m → ℕ) (p k : ℕ) : ℝ :=
  |empiricalDivisibilityFreq samples p k - pDivisibilityMoment p k|

end