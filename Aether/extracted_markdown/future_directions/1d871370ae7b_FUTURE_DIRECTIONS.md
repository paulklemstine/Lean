# Future Directions

## Overview

This document outlines 5 concrete next theorems opened by the current work on tropical boundary rigidity, Gromov hyperbolicity, and certified min-plus linear algebra. Each direction includes an exact theorem statement, proposed Lean type signature, proof strategies, dependency map, and cross-domain payoff.

---

## Direction 1: Multi-Terminal Boundary Rigidity for SP Networks

### Theorem Statement
For k-terminal series-parallel networks (k ≥ 3), the boundary distance matrix—a k×k symmetric matrix of pairwise shortest-path distances between boundary vertices—is a complete invariant for SP-equivalence up to boundary-preserving isomorphism.

### Proposed Lean Type Signature

```lean
structure MultiTerminalSPNet (k : ℕ) where
  net : SPNetMulti k  -- inductive type for k-terminal SP networks
  boundary : Fin k    -- boundary vertices are Fin k

noncomputable def boundaryDistMatrix {k : ℕ} (N : MultiTerminalSPNet k) :
    Matrix (Fin k) (Fin k) ℝ := sorry

theorem multi_terminal_sp_boundary_rigid {k : ℕ}
    (N₁ N₂ : MultiTerminalSPNet k)
    (hSP₁ : IsSeriesParallel N₁) (hSP₂ : IsSeriesParallel N₂)
    (h : boundaryDistMatrix N₁ = boundaryDistMatrix N₂) :
    SPEquivMulti N₁ N₂ := sorry
```

### Proof Strategies

**Strategy A: Inductive decomposition with matrix invariants.** Define k-terminal SP networks inductively (series at a shared terminal, parallel between terminal pairs). Show the boundary distance matrix transforms predictably under each operation. Prove injectivity of the transformation on reduced normal forms.

**Strategy B: Tropical Schur complement.** Encode the full network as a weighted adjacency matrix, define a tropical Schur complement that eliminates interior vertices, and show this complement equals the boundary distance matrix. Then prove that for SP networks, the Schur complement determines the network up to equivalence.

### Dependency Map
- `Tropical/SeriesParallel.lean`: SPNet inductive type, spDist, SPEquiv
- `Tropical/Matrix.lean`: tropicalMatMul, tropicalMatMul_assoc
- `Tropical/Bridge.lean`: sp_eval_eq_dist, spToMatrix

### Cross-Domain Payoff
**Network tomography**: This would provide a mathematically certified reconstruction algorithm for multi-terminal networks—exactly the setting of internet routing diagnosis, where one measures round-trip times between multiple servers and wants to infer internal congestion.

---

## Direction 2: Sharp Hyperbolicity Bounds for Bounded-Treewidth Networks

### Theorem Statement
For a weighted graph G with treewidth at most t, the shortest-path metric on G is δ-hyperbolic with δ ≤ t · max_edge_weight(G) / 2. Moreover, this bound is tight: there exist graphs achieving δ = Ω(t · w_max).

### Proposed Lean Type Signature

```lean
def treewidth (G : SimpleGraph V) [Fintype V] : ℕ := sorry

theorem bounded_treewidth_hyperbolic
    {V : Type} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) (w : G.edgeSet → ℝ) (hw : ∀ e, 0 < w e)
    (t : ℕ) (ht : treewidth G ≤ t)
    (wmax : ℝ) (hwmax : ∀ e, w e ≤ wmax) :
    IsFourPointDeltaHyperbolic (shortestPathMetric G w) (t * wmax / 2) := sorry
```

### Proof Strategies

**Strategy A: Tree decomposition induction.** Use the tree decomposition of G. Show that the shortest path between two vertices passes through at most t bags, each introducing at most w_max additional distance. The four-point defect is bounded by the width times the maximum perturbation.

**Strategy B: Embedding into hyperbolic product.** Embed the metric into a product of t tree metrics (each 0-hyperbolic). Use the fact that products of δ-hyperbolic spaces have controlled hyperbolicity to derive the bound.

### Dependency Map
- `Tropical/Hyperbolicity.lean`: IsFourPointDeltaHyperbolic, hyperbolic_mono, zero_hyperbolic_of_ultrametric
- `Tropical/Matrix.lean`: tropicalMatMul (for distance computation)
- New file needed: `Tropical/Treewidth.lean` for treewidth definitions

### Cross-Domain Payoff
**Phylogenetics and machine learning**: Tree-like networks arise in evolutionary biology and hierarchical clustering. A certified hyperbolicity bound would provide guaranteed quality metrics for tree approximations used in computational biology.

---

## Direction 3: Certified Tropical Perron-Frobenius for Strongly Connected Digraphs

### Theorem Statement
For a strongly connected weighted digraph with n vertices and tropical adjacency matrix A, the tropical eigenvalue λ(A) = min over all cycles C of (weight(C) / |C|) exists and equals the minimum cycle mean. Moreover, there exists a tropical eigenvector v such that A ⊗ v = λ ⊙ v (i.e., min_j(A_{ij} + v_j) = λ + v_i for all i).

### Proposed Lean Type Signature

```lean
noncomputable def tropicalEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  ⨅ k ∈ Finset.range n, ⨅ i : Fin n, tropicalMatPow A (k+1) i i / (k+1)

theorem tropical_perron_frobenius {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hsc : StronglyConnected A) :
    ∃ v : Fin n → ℝ, ∀ i : Fin n,
      (⨅ j : Fin n, A i j + v j) = tropicalEigenvalue A + v i := sorry
```

### Proof Strategies

**Strategy A: Karp's algorithm approach.** Use Karp's theorem that the minimum cycle mean equals max_i min_k (d_n(i) - d_k(i)) / (n - k), where d_k(i) is the minimum weight of a k-step walk from source to i. This is computable and the correctness proof is inductive.

**Strategy B: Policy iteration.** Define a sequence of policy vectors and show convergence to the tropical eigenvector. The convergence proof uses the contraction property of the tropical Bellman operator.

### Dependency Map
- `Tropical/Matrix.lean`: tropicalMatMul, tropicalMatPow, tropicalMatMul_assoc
- `Tropical/Defs.lean`: tropical operations
- New file needed: `Tropical/Eigenvalue.lean`

### Cross-Domain Payoff
**Control theory and scheduling**: The tropical eigenvalue determines the throughput of a discrete-event system (e.g., manufacturing line, processor pipeline). A certified Perron-Frobenius theorem would enable formally verified performance guarantees for real-time systems.

---

## Direction 4: Tropical Schur Complement and Network Elimination

### Theorem Statement
For a weighted network with interior and boundary vertices, the tropical Schur complement of the adjacency matrix with respect to boundary vertices equals the boundary distance matrix. For SP networks, the elimination order does not affect the result (confluence).

### Proposed Lean Type Signature

```lean
noncomputable def tropicalSchurComplement {n m : ℕ}
    (A : Matrix (Fin (n+m)) (Fin (n+m)) ℝ)
    (boundary : Fin n → Fin (n+m))
    (interior : Fin m → Fin (n+m)) :
    Matrix (Fin n) (Fin n) ℝ := sorry

theorem schur_complement_eq_boundary_dist {n m : ℕ}
    (G : WeightedGraph (Fin (n+m)))
    (boundary : Fin n → Fin (n+m))
    (interior : Fin m → Fin (n+m)) :
    tropicalSchurComplement (adjMatrix G) boundary interior =
    boundaryDistMatrix G boundary := sorry

theorem sp_schur_complement_confluent
    (G : BoundaryNetwork)
    (hG : IsSeriesParallel G)
    (σ₁ σ₂ : ElimOrder G.interior) :
    tropicalEliminate G σ₁ = tropicalEliminate G σ₂ := sorry
```

### Proof Strategies

**Strategy A: Vertex elimination.** Define elimination of a single interior vertex v as replacing all pairs (u, w) of neighbors by the edge with weight min(d(u,v) + d(v,w), d(u,w)). Show this preserves boundary distances. Then show order-independence for SP networks by structural induction.

**Strategy B: Matrix factorization.** Express the tropical Schur complement as a tropical matrix expression and use associativity to show order-independence algebraically.

### Dependency Map
- `Tropical/Matrix.lean`: tropicalMatMul, tropicalMatMul_assoc, tropicalMatMul_mono
- `Tropical/SeriesParallel.lean`: SPNet, spDist
- `Tropical/Bridge.lean`: spToMatrix, spMatrix_product_eq_parallel
- New file needed: `Tropical/SchurComplement.lean`

### Cross-Domain Payoff
**Circuit simulation**: Tropical Schur complements are the tropical analogue of Gaussian elimination. A confluence theorem would certify that circuit simulation via node elimination gives the same result regardless of elimination order—critical for formal verification of EDA tools.

---

## Direction 5: Hyperbolicity Bounds for Tropical Neural Network Decision Regions

### Theorem Statement
For a ReLU neural network with L layers and width W, the tropical representation of its decision boundary adjacency graph has Gromov hyperbolicity δ ≤ L · max_weight / 2, where max_weight is the maximum entry of the weight matrices.

### Proposed Lean Type Signature

```lean
structure ReLUNetwork where
  layers : ℕ
  widths : Fin (layers + 1) → ℕ
  weights : (l : Fin layers) → Matrix (Fin (widths l.succ)) (Fin (widths l)) ℝ
  biases : (l : Fin layers) → Fin (widths l.succ) → ℝ

noncomputable def decisionRegionAdjacency (N : ReLUNetwork) :
    Matrix (Fin (numRegions N)) (Fin (numRegions N)) ℝ := sorry

theorem relu_decision_hyperbolic (N : ReLUNetwork)
    (wmax : ℝ) (hw : ∀ l i j, |N.weights l i j| ≤ wmax) :
    IsFourPointDeltaHyperbolic
      (shortestPathMetric (decisionRegionAdjacency N))
      (N.layers * wmax / 2) := sorry
```

### Proof Strategies

**Strategy A: Layer-by-layer induction.** Each ReLU layer corresponds to a tropical map. Show that each layer increases the hyperbolicity defect by at most max_weight / 2, using the Lipschitz property of tropical maps.

**Strategy B: Tropical polynomial degree bound.** The decision function is a tropical rational map of degree at most the product of layer widths. Use a degree-hyperbolicity relationship for tropical polynomials.

### Dependency Map
- `Tropical/Hyperbolicity.lean`: IsFourPointDeltaHyperbolic, hyperbolic_mono, hyperbolic_of_bounded_diam
- `Tropical/Defs.lean`: tropicalMul_mono_left, tropicalAdd_mono_left
- `Tropical/Matrix.lean`: tropicalMatMul_mono
- New files needed: `Tropical/NeuralNetwork.lean`, `Tropical/DecisionRegion.lean`

### Cross-Domain Payoff
**Adversarial robustness in machine learning**: If the decision region adjacency graph is δ-hyperbolic with small δ, then adversarial perturbations must traverse a tree-like structure—which constrains the complexity of adversarial attacks. This could lead to certified robustness bounds for neural networks based purely on architectural parameters.

---

## Implementation Roadmap

### Phase 1 (Months 1-2)
- Implement multi-terminal SP networks (Direction 1)
- Define treewidth and tree decompositions (Direction 2)
- Prove tropical Schur complement basics (Direction 4)

### Phase 2 (Months 2-4)
- Prove multi-terminal boundary rigidity for k=3
- Prove hyperbolicity bounds for series-parallel with depth
- Implement tropical eigenvalue computation

### Phase 3 (Months 4-6)
- Generalize to bounded treewidth
- Complete tropical Perron-Frobenius
- Connect to neural network decision regions

### Ongoing
- Maintain and extend the certified tropical linear algebra library
- Generate computational experiments validating conjectures
- Write papers for each completed direction
