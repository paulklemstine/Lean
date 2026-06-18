# Future Directions: Tropical Inverse Theory

## Overview

This document outlines concrete next steps for extending the tropical series-parallel network theory established in this work. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Multi-Terminal Boundary Rigidity

### Goal
Extend the rigidity theory from 2-terminal SP networks to k-terminal networks (k ≥ 3), where the boundary observable is a k × k distance matrix rather than a single scalar.

### Hypothesis
For reduced k-terminal SP networks with positive weights, the boundary distance matrix D ∈ ℕ^(k×k) uniquely determines the SP decomposition tree (up to tropical equivalence).

### Proof Strategy
1. Define k-terminal SP expressions with labeled terminal sets.
2. Define `evalBoundaryDist : SPExpr_k → Matrix (Fin k) (Fin k) ℕ`.
3. Prove compositionality: how boundary matrices transform under series and parallel composition at shared terminals.
4. Define "reduced" forms that eliminate redundancies (associativity, commutativity, absorption).
5. Prove injectivity by structural induction:
   - **Series detection**: If the top-level operation is series at terminal t, then ∃ t such that D(i,j) = D(i,t) + D(t,j) for all i in the "left" block and j in the "right" block.
   - **Parallel detection**: If the top-level operation is parallel, then D = min(D₁, D₂) entrywise.
   - Show that these are distinguishable from the matrix pattern.

### Key Lemma
The "metric tree" structure of an SP expression is detectable from the boundary matrix: cut vertices induce additive decompositions, and parallel branches induce min decompositions.

### Cross-Domain Connections
- **Phylogenetics**: Tree reconstruction from distance matrices (Buneman's four-point condition). SP networks generalize trees by allowing parallel branches.
- **Metric geometry**: Tight-span / injective envelope theory. The boundary distance matrix of an SP network should have a tight span with a specific combinatorial structure.

---

## Direction 2: Stability and Condition Numbers

### Goal
Prove quantitative stability bounds for boundary-to-structure reconstruction: if boundary distances are perturbed by ε, how much can the reconstructed network differ?

### Hypothesis
The map `SPExpr → boundaryDist` is Lipschitz with respect to appropriate metrics on both sides. The inverse map (reconstruction) has a computable condition number that depends on the network's "spectral gap" — the minimum difference between distinct path weights.

### Proof Strategy
1. Define metrics on SP expressions (edit distance on trees, or weight perturbation distance).
2. Prove Lipschitz continuity: `‖boundaryDist(E₁) - boundaryDist(E₂)‖ ≤ L · d(E₁, E₂)`.
3. Prove inverse stability: if `‖D₁ - D₂‖ < ε` and E₁, E₂ are the unique reduced expressions with `eval(Eᵢ) = Dᵢ`, then `d(E₁, E₂) ≤ f(ε)`.
4. The key parameter is the "tropical spectral gap": `gap(E) = min{|w₁ - w₂| : w₁, w₂ are distinct path weights}`.

### Key Lemma
For the 2-terminal case: if E has effective distance d and the nearest alternative effective distance is d + gap, then any perturbation less than gap/2 preserves the reconstruction.

### Cross-Domain Connections
- **Numerical analysis**: Condition numbers for tropical eigenvalue problems.
- **Machine learning**: Robustness of tropical network architectures to weight perturbations.
- **Signal processing**: Noise tolerance in network tomography.

---

## Direction 3: Tropical Calderón Problem

### Goal
Develop the full tropical analogue of the Calderón inverse problem: given the "tropical Dirichlet-to-Neumann map" (boundary distance matrix) of a weighted graph, recover the graph structure.

### Hypothesis
For circular planar graphs (the class studied by Curtis-Ingerman-Morrow in the classical setting), the tropical boundary distance matrix determines the graph up to tropical equivalence.

### Proof Strategy
1. Define the tropical Dirichlet-to-Neumann (DtN) map as the boundary distance matrix.
2. Prove tropical analogues of classical results:
   - **Layer stripping**: Recover the outermost edges of a circular planar graph from the DtN map.
   - **Schur complement reduction**: After removing outer edges, the remaining DtN map determines the interior.
3. Use the SP theory as the base case: every circular planar graph decomposes into SP blocks.

### Key Lemma
Tropical layer stripping: the weight of a boundary edge (i, j) equals D(i, j) if and only if D(i, j) < min_k≠i,j [D(i, k) + D(k, j)].

### Cross-Domain Connections
- **Inverse problems**: Full tropical analogue of electrical impedance tomography.
- **Tropical geometry**: Tropical Jacobians and tropical Abel-Jacobi maps for graphs.
- **Quantum gravity**: AdS/CFT boundary-to-bulk reconstruction in tropical models.

---

## Direction 4: Categorical SP Decomposition

### Goal
Establish a categorical equivalence between SP network syntax (free algebra on series/parallel) and a category of tropical transfer matrices.

### Hypothesis
The category of k-terminal SP networks (morphisms = SP expressions between terminal configurations) is equivalent to a subcategory of tropical matrices satisfying specific rank and sign conditions.

### Proof Strategy
1. Define a category SP_k with objects = finite terminal sets and morphisms = SP network expressions.
2. Define a functor F : SP_k → TropMat_k sending each SP expression to its boundary distance matrix.
3. Prove F is faithful (injectivity = rigidity theorem).
4. Characterize the essential image: which tropical matrices arise as boundary distances of SP networks?
5. Prove F is full on the essential image: every tropical-matrix morphism in the image comes from an SP morphism.

### Key Lemma
A k×k tropical matrix D arises as the boundary distance matrix of a 2-terminal SP network if and only if it satisfies the "SP four-point condition": a tropical analogue of the tree metric condition.

### Cross-Domain Connections
- **Category theory**: Operadic structures on SP compositions.
- **Tropical linear algebra**: Tropical rank and tropical determinant theories.
- **Circuit complexity**: SP formulas as tropical circuit formulas; the functor F measures "tropical formula complexity."

---

## Direction 5: Algorithm Extraction and Certified Reconstruction

### Goal
Extract certified reconstruction algorithms from the rigidity proofs: given a boundary distance matrix, produce the unique reduced SP expression that realizes it, with a formal certificate of correctness.

### Hypothesis
The reconstruction algorithm has polynomial time complexity for k-terminal SP networks when k is fixed, and the certificate can be checked in linear time.

### Proof Strategy
1. Implement reconstruction as a Lean function with a proof of correctness.
2. The algorithm:
   - Test for series decomposition: find a cut terminal t such that D(i,j) = D(i,t) + D(t,j).
   - Test for parallel decomposition: find a min decomposition D = min(D₁, D₂).
   - Recurse on sub-problems.
3. Prove termination via a well-founded order on matrix size.
4. Extract executable code via Lean's code generation.

### Complexity Analysis
- For 2-terminal: O(1) (the effective distance is the single observable).
- For k-terminal: O(k³) per decomposition step, O(n · k³) total where n is the number of internal edges.

### Cross-Domain Connections
- **Verified software**: Certified graph algorithms with formal correctness proofs.
- **Compilers**: SP decomposition as a certified program transformation.
- **Network monitoring**: Real-time network structure inference from latency measurements.

---

## Direction 6: Tropical Neural Network Interpretability

### Goal
Apply SP network rigidity to the interpretability of neural networks with ReLU activations, which compute piecewise-linear (tropical rational) functions.

### Hypothesis
For feed-forward ReLU networks with SP connectivity (no skip connections), the input-output function determines the network architecture, providing a theoretical foundation for "tropical X-ray" interpretability methods.

### Proof Strategy
1. Formalize the connection between ReLU networks and tropical rational functions.
2. Show that SP-structured ReLU networks compute tropical polynomials with specific factorization properties.
3. Apply the SP rigidity theorem to conclude that the tropical polynomial determines the architecture.
4. Handle the "tropical" extension: max-plus vs. min-plus, and the role of biases.

### Cross-Domain Connections
- **Explainable AI**: Architecture recovery from input-output behavior.
- **Neural architecture search**: Tropical invariants as architecture descriptors.
- **Adversarial robustness**: Tropical geometry of decision boundaries.

---

## Priority Ranking

1. **Direction 1** (Multi-terminal rigidity) — Highest impact, most natural extension
2. **Direction 5** (Algorithm extraction) — Most practically useful
3. **Direction 2** (Stability bounds) — Essential for applications
4. **Direction 3** (Tropical Calderón) — Deepest mathematically
5. **Direction 4** (Categorical structure) — Most theoretically elegant
6. **Direction 6** (Neural interpretability) — Highest applied impact, most speculative

---

## Implementation Notes

Each direction can be pursued independently, building on the existing Lean formalization. The key shared infrastructure is:
- SP expression type and evaluation functions
- Tropical semiring operations on WithTop ℕ
- Tropical elimination / Schur complement machinery
- Path weight multiset characterization

All of this is already in place. New directions mainly require extending the terminal structure (Direction 1), adding metric analysis (Direction 2), or connecting to new mathematical domains (Directions 3-6).
