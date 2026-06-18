# Future Directions: Tropical Inverse Theory

## Overview

This document outlines breakthrough research opportunities opened by the formalization of boundary rigidity for series-parallel tropical networks. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Multi-Terminal Boundary Rigidity (k ≥ 3)

### Hypothesis
For reduced k-terminal SP networks with positive weights, the k×k boundary distance matrix uniquely determines the SP decomposition tree up to the natural equivalences.

### Why This Matters
Two-terminal rigidity is determined by a single scalar. The k-terminal case requires the full matrix, making the rigidity theorem genuinely structural: the combinatorial decomposition tree is recoverable from metric data.

### Proof Strategy
1. Define k-terminal SP expressions inductively, with series/parallel gluings along designated terminal subsets.
2. Show that series composition at a cut terminal t produces the additive factorization: D(i,j) = D(i,t) + D(t,j) for terminals on opposite sides.
3. Show that parallel composition produces entrywise min of boundary matrices.
4. Prove these factorization signatures are detectable: a series cut is identified by an additive decomposition through a boundary terminal; a parallel split by a min decomposition.
5. Use these detection lemmas to reconstruct the SP tree by induction on expression size.

### Key Challenge
The detection lemma requires showing that the factorization signatures are unambiguous for reduced expressions. This may require careful analysis of when additive and min decompositions can coincide.

### Cross-Domain Connections
- **Phylogenetics**: k-terminal tree metrics are the special case without parallel composition. The generalization to SP adds the ability to handle reticulate evolution.
- **Tropical Grassmannians**: boundary distance matrices of SP networks with k terminals form a subset of the tropical Grassmannian Gr(2, k).

### Estimated Difficulty
High. The combinatorial case analysis grows with k, and the detection lemmas require non-trivial metric geometry arguments.

---

## Direction 2: Stability and Condition Numbers for Tropical Reconstruction

### Hypothesis
The reconstruction map from boundary distance matrices to reduced SP expressions is Lipschitz with computable condition numbers that depend on the minimum weight and the SP tree structure.

### Why This Matters
Any real measurement involves noise. Stability bounds transform the rigidity theorem from a theoretical uniqueness result into a practically useful guarantee: small perturbations in measurements produce small changes in the reconstructed network.

### Proof Strategy
1. Define a metric on SP expressions (e.g., edit distance on expression trees, or Hausdorff distance on the associated weighted graphs).
2. Prove that effDist is Lipschitz as a function of atom weights (this is straightforward since effDist is composed of +, min).
3. Prove a Lipschitz lower bound: for reduced expressions, |effDist(e₁) - effDist(e₂)| ≥ some function of the expression distance.
4. For multi-terminal, bound the matrix norm of the difference of boundary matrices.

### Key Challenge
The Lipschitz lower bound (stability of the inverse) is the hard direction. It requires understanding how the minimum weight acts as a "gap" preventing nearby but distinct reduced expressions.

### Cross-Domain Connections
- **Numerical linear algebra**: condition numbers for tropical matrix factorization mirror those for classical matrix factorization.
- **Signal processing**: reconstruction stability is the analogue of restricted isometry properties (RIP) in compressed sensing.

### Estimated Difficulty
Medium. The Lipschitz upper bound is easy; the lower bound requires careful case analysis.

---

## Direction 3: Tropical Dirichlet-to-Neumann Maps for Directed Graphs

### Hypothesis
For weighted directed SP graphs, the tropical Dirichlet-to-Neumann map (boundary-to-boundary shortest-path transfer function) determines the reduced internal structure.

### Why This Matters
Real networks (communication, logistics, biological) are often directed. The undirected case studied here is the foundation, but the directed generalization opens applications to:
- Internet routing (asymmetric links)
- Supply chains (unidirectional flow)
- Neural circuits (directed synaptic connections)

### Proof Strategy
1. Define directed SP expressions with source/target polarity for each terminal.
2. The boundary distance matrix becomes asymmetric: D(i,j) ≠ D(j,i) in general.
3. Show that directed series adds distances (as before) but directed parallel takes min over directed paths.
4. The matrix carries more information (k² entries vs k(k-1)/2), potentially making rigidity easier to prove.

### Key Challenge
Defining "reduced" for directed networks requires handling one-way paths and reachability.

### Cross-Domain Connections
- **Optimal control**: directed SP networks model sequential decision processes with branching choices.
- **Tropical convexity**: directed boundary distances relate to tropical halfspaces and tropical convex sets.

### Estimated Difficulty
Medium-High. The directed case introduces asymmetry that complicates the algebraic structure.

---

## Direction 4: Certified Reconstruction Algorithms

### Hypothesis
The rigidity proof can be made constructive, yielding a certified algorithm that takes a boundary distance matrix as input and outputs the unique reduced SP expression, together with a machine-checked correctness certificate.

### Why This Matters
This transforms the existence theorem into a computational tool. The algorithm would be:
- **Correct by construction**: the output provably matches the input boundary data.
- **Certified**: the proof of correctness is machine-verified, not just tested.
- **Extractable**: the algorithm can be extracted from the formal proof as executable code.

### Proof Strategy
1. Make the canonical reduction constructive: instead of showing existence, compute the reduction.
2. For multi-terminal, implement the detection lemma as a decision procedure: given M, test for series cuts and parallel splits.
3. Use Lean 4's code generation to extract the algorithm to executable code.
4. Prove termination and correctness of the extracted algorithm.

### Key Challenge
The detection of series vs. parallel structure from the boundary matrix requires decidable arithmetic predicates (e.g., "does there exist a terminal t such that D factors additively through t?"). These need to be implemented as computable functions.

### Cross-Domain Connections
- **Formal methods**: certified algorithms for network analysis.
- **Reverse engineering**: automated inference of network topology from measurements.

### Estimated Difficulty
Medium. The algorithmic content is clear; the challenge is making everything computable in Lean.

---

## Direction 5: Categorical Equivalence of SP Syntax and Tropical Transfer Matrices

### Hypothesis
The category of SP expressions (morphisms = SP-equivalences) is equivalent, as a monoidal category, to a subcategory of tropical matrices (morphisms = tropical matrix equalities).

### Why This Matters
This would establish a categorical duality between:
- **Syntax**: the algebraic structure of SP decomposition trees
- **Semantics**: the tropical linear algebra of boundary distance matrices

Such a duality is the tropical analogue of the Curry-Howard-Lambek correspondence, connecting proofs (decomposition trees), programs (network computations), and categories (matrix algebras).

### Proof Strategy
1. Define the category SP_k of k-terminal SP expressions with composition as sequential glueing.
2. Define the functor F: SP_k → Mat_trop(k) sending each expression to its boundary distance matrix.
3. Prove F is faithful (the rigidity theorem).
4. Prove F is full on the image (every tropical matrix in the image is realizable by an SP expression).
5. Characterize the image: which tropical matrices arise as boundary distance matrices of SP networks?

### Key Challenge
Characterizing the image of F — which tropical matrices are "SP-realizable" — is likely the hardest step and connects to the theory of tropical convexity and realizability.

### Cross-Domain Connections
- **Category theory**: monoidal functors between algebraic and geometric categories.
- **Tropical algebraic geometry**: realizability of tropical objects by algebraic ones.
- **Quantum information**: parallels with the characterization of quantum channels as completely positive maps.

### Estimated Difficulty
High. The categorical framework is elegant but requires substantial infrastructure.

---

## Research Program Summary

| Direction | Impact | Difficulty | Dependencies |
|---|---|---|---|
| 1. Multi-terminal rigidity | Very High | High | Current work |
| 2. Stability bounds | High | Medium | Direction 1 |
| 3. Directed graphs | High | Medium-High | Current work |
| 4. Certified algorithms | Very High | Medium | Direction 1 |
| 5. Categorical equivalence | Very High | High | Directions 1, 4 |

### Recommended Priority
1. **Immediate**: Direction 1 (multi-terminal) — this is the natural next theorem and the key to all other directions.
2. **Near-term**: Directions 2 and 4 in parallel — stability and algorithms are independent and both high-impact.
3. **Medium-term**: Direction 3 (directed) — extends applicability.
4. **Long-term**: Direction 5 (categorical) — the deepest structural result, requiring all other directions as prerequisites.

### Team Structure
- **Theory team**: Directions 1, 5 — requires expertise in tropical geometry, combinatorics, category theory.
- **Algorithms team**: Direction 4 — requires expertise in formal methods, verified programming, algorithm design.
- **Applications team**: Directions 2, 3 — requires expertise in network science, optimization, signal processing.

Each team should iterate on hypotheses, run computational experiments to validate conjectures, and formalize results in Lean 4 upon confirmation.
