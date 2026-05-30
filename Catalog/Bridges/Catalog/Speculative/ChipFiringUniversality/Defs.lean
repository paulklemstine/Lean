/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# p-adic Universality of Chip-Firing Critical Groups Under Graph Lifts — Definitions

This file develops the combinatorial and algebraic foundations for studying the
critical group (Jacobian/sandpile group) of a finite graph and its behavior under
covering maps (graph lifts).

## Main Definitions

* `graphLaplacianMat` — the combinatorial Laplacian matrix of a graph
* `reducedLaplacianMat` — reduced Laplacian (sink row/column deleted)
* `bettiOne` — first Betti number b₁ = |E| - |V| + 1
* `VoltageCovering` — n-sheeted covering via voltage assignments on edges
* `derivedGraph` — the lifted graph of a voltage covering
* `critGroupOrder` — |det(reduced Laplacian)| = Jacobian order
* `cohenLenstraWt` — Cohen-Lenstra weight for p-group distributions
* `laplacianQuadForm` — discrete Dirichlet energy

## References

* Baker, Norine (2007). Riemann–Roch and Abel–Jacobi theory on a finite graph.
* Wood (2017). The distribution of sandpile groups of random graphs.
-/

import Mathlib

open Finset BigOperators Matrix SimpleGraph

/-! ### Graph Laplacian Matrix -/

/-- The combinatorial graph Laplacian matrix L(G).
    Diagonal: `L(v,v) = deg(v)`. Off-diagonal: `L(v,w) = -1` if `v ~ w`, else `0`. -/
noncomputable def graphLaplacianMat {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : Matrix V V ℤ :=
  fun i j =>
    if i = j then (G.degree i : ℤ)
    else if G.Adj i j then -1
    else 0

/-- The reduced Laplacian matrix: remove row and column of the sink vertex `q`. -/
noncomputable def reducedLaplacianMat {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) :
    Matrix {v : V // v ≠ q} {v : V // v ≠ q} ℤ :=
  fun i j => graphLaplacianMat G i.val j.val

/-! ### First Betti Number -/

/-- The first Betti number (cycle rank) of a connected graph:
    `b₁(G) = |E| - |V| + 1`. -/
noncomputable def bettiOne {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-! ### Graph Coverings via Voltage Assignments -/

/-- An `n`-sheeted graph covering of a base graph `G` defined by voltage assignments.
    For each directed edge `(v,w)`, a permutation `σ(v,w)` of `Fin n` determines
    how sheets are connected: vertex `(v,i)` connects to `(w, σ(v,w)(i))`.

    This is the standard construction from topological graph theory (Gross-Tucker).
    When all voltages are the identity, the covering is the trivial n-fold cover. -/
structure VoltageCovering (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (n : ℕ) where
  /-- Voltage assignment on directed edges. -/
  voltage : V → V → Equiv.Perm (Fin n)
  /-- Non-edges carry trivial voltage. -/
  voltage_non_adj : ∀ v w, ¬G.Adj v w → voltage v w = Equiv.refl _
  /-- Consistency: reverse edge has inverse voltage. -/
  voltage_symm : ∀ v w, voltage w v = (voltage v w).symm

/-- The lifted (derived) graph from a voltage covering.
    Vertex set: `V × Fin n`. Adjacency: `(v,i) ~ (w,j)` iff `v ~ w` and `j = σ(v,w)(i)`. -/
def derivedGraph {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj] {n : ℕ}
    (cov : VoltageCovering V G n) : SimpleGraph (V × Fin n) where
  Adj p q := G.Adj p.1 q.1 ∧ q.2 = cov.voltage p.1 q.1 p.2
  symm := by
    rintro ⟨v, i⟩ ⟨w, j⟩ ⟨hadj, hj⟩
    refine ⟨G.symm hadj, ?_⟩
    rw [cov.voltage_symm, Equiv.eq_symm_apply]
    exact hj.symm
  loopless := ⟨fun ⟨v, _⟩ ⟨hadj, _⟩ => G.ne_of_adj hadj rfl⟩

instance derivedGraph_decidableAdj {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj] {n : ℕ}
    (cov : VoltageCovering V G n) : DecidableRel (derivedGraph cov).Adj :=
  fun _ _ => inferInstanceAs (Decidable (_ ∧ _))

/-! ### Critical Group Order -/

/-- The order of the critical group (Jacobian) = |det(reduced Laplacian)|.
    By Kirchhoff's Matrix-Tree Theorem, for a connected graph this equals
    the number of spanning trees. -/
noncomputable def critGroupOrder {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) : ℕ :=
  (reducedLaplacianMat G q).det.natAbs

/-- The p-adic valuation of the critical group order. -/
noncomputable def padicValCritGroup {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (p : ℕ) : ℕ :=
  padicValNat p (critGroupOrder G q)

/-- A "good prime" for G: a prime not dividing |Jac(G)|. -/
def IsGoodPrimeFor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (q : V) (p : ℕ) : Prop :=
  Nat.Prime p ∧ ¬(p ∣ critGroupOrder G q)

/-! ### Cohen-Lenstra Weights -/

/-- The Cohen-Lenstra weight for a p-group with `k` cyclic factors:
    `∏_{i=0}^{k-1} (1 - p^{-(i+1)})`. This weight appears in the conjectured
    distribution of class groups and sandpile groups.

    **Cross-domain connection**: This definition bridges tropical geometry
    (chip-firing / sandpile groups) with algebraic number theory
    (Cohen-Lenstra heuristics for ideal class groups). -/
noncomputable def cohenLenstraWt (p : ℕ) (k : ℕ) : ℝ :=
  ∏ i ∈ Finset.range k, (1 - (p : ℝ)⁻¹ ^ (i + 1))

/-! ### Laplacian Quadratic Form -/

/-- The Laplacian quadratic form Q(x) = ∑_{v~w} (x(v) - x(w))².
    Measures discrete Dirichlet energy — the graph-theoretic analogue
    of the Dirichlet integral in PDE theory. Always nonneg. -/
noncomputable def laplacianQuadForm {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (x : V → ℝ) : ℝ :=
  ∑ v : V, ∑ w : V, if G.Adj v w then (x v - x w) ^ 2 else 0