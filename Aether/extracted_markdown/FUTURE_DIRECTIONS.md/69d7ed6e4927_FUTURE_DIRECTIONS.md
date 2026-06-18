# Future Directions

## Roadmap for Width-Bounded Tropical Complexity

This document outlines concrete next steps following the proof that tropical Φ is computable in O(L · w²) time for width-bounded layered circuits. Each direction includes a precise theorem target, significance assessment, proof strategy, and cross-domain connections.

---

## Direction 1: Bounded Treewidth Tropical Φ

### Theorem Target

```
theorem tropical_phi_bounded_treewidth
    (G : TropicalCircuit) (k : ℕ) (h : treewidth G ≤ k) :
    ∃ C : ℕ, computeTropicalPhi G ≤ C * (vertices G) * (states G) ^ (k + 1)
```

Generalize from layered circuits (pathwidth) to circuits with bounded treewidth. The polynomial dependence on vertex count should hold with exponential dependence only on the treewidth parameter.

### Why Breakthrough-Level

The layered (pathwidth) case is the first step, but most real-world networks are not strictly layered. Bounded treewidth captures a much larger class: sparse networks, networks with bounded feedback, hierarchical architectures. This would be the tropical analogue of Courcelle's theorem — a meta-theorem giving polynomial algorithms for all "treewidth-bounded tropical optimization" problems.

### Proof Strategy

1. Define tropical circuits over arbitrary DAGs with a tree decomposition.
2. For each bag in the tree decomposition, define a "boundary state" over the bag's vertices.
3. Show that DP over the tree decomposition computes tropical Φ by processing bags bottom-up.
4. Bound the work by (number of bags) × (states)^(bag size), which is polynomial when treewidth is bounded.

This mirrors the approach for CSPs on bounded-treewidth constraint graphs.

### Cross-Domain Connection

**Tensor network contraction.** In quantum computing and machine learning, tensor networks are contracted by finding good tree decompositions. Bounded treewidth ↔ bounded bond dimension ↔ efficient classical simulation. The tropical version would formalize the complexity of "tropical tensor networks" — a new computational model.

---

## Direction 2: Tropical Matrix Spectral Theory

### Theorem Target

```
theorem tropical_phi_spectral
    (M : Matrix (Fin w) (Fin w) ℝ) (L : ℕ) :
    tropicalPhi (replicate L M) = L * tropicalEigenvalue M + O(1)
```

For a circuit where all layers use the same transition matrix, tropical Φ should grow linearly with depth at a rate determined by the tropical eigenvalue (= minimum mean cycle weight) of the matrix.

### Why Breakthrough-Level

This connects tropical circuit complexity to tropical spectral theory — a deep area with connections to max-plus algebra, optimal control, and Perron-Frobenius theory. It would show that for stationary circuits, the "tropical growth rate" is a computable spectral invariant.

### Proof Strategy

1. Define tropical eigenvalue as `λ(M) = min_{cycle C} (weight(C) / length(C))`.
2. Show that the tropical matrix power `M^⊗L` satisfies `min_{i,j} (M^⊗L)_{i,j} = L · λ(M) + O(1)`.
3. Use the CSR (Critical graph, Saturation, Reduction) decomposition from max-plus algebra.
4. Connect to existing Mathlib theory of matrices and graph cycles.

### Cross-Domain Connection

**Ergodic theory and dynamical systems.** The tropical eigenvalue is the analogue of the Lyapunov exponent. The convergence `(1/L) · tropPhi → λ` is a tropical ergodic theorem. This opens connections to thermodynamic formalism and symbolic dynamics.

---

## Direction 3: Complexity Dichotomy

### Theorem Target

```
theorem tropical_phi_np_hard_unbounded_width :
    ∃ family : ℕ → TropicalCircuit,
      (∀ n, depth (family n) = poly n ∧ width (family n) = poly n) ∧
      computingTropicalPhi family is NP-hard
```

Or more precisely: show that computing tropical Φ for circuits where width grows polynomially with depth is NP-hard, by reduction from shortest path in general graphs or Hamiltonian path.

### Why Breakthrough-Level

This would complete a *parameterized complexity dichotomy*:
- Width bounded: polynomial time (our theorem)
- Width unbounded: NP-hard

Such dichotomies are the gold standard of parameterized complexity theory (analogous to the FPT vs W[1]-hard classification).

### Proof Strategy

1. Encode a general shortest-path problem as a tropical circuit with width equal to the number of vertices.
2. Show that if width is Ω(n), the resulting tropical Φ computation encodes an NP-hard problem.
3. For the lower bound direction, use the known NP-hardness of min-cost Hamiltonian path.

Alternative: show that computing tropical Φ for width-w circuits is W[1]-hard parameterized by w, or that the w² dependence cannot be improved to w^(2-ε) under ETH.

### Cross-Domain Connection

**Circuit complexity.** The width parameter in our model is analogous to circuit width/size in Boolean complexity. A tight characterization would connect tropical complexity to classical circuit lower bounds and the P vs NP question.

---

## Direction 4: Tropical Information Processing Inequalities

### Theorem Target

```
theorem tropical_data_processing_inequality
    (step1 : Fin L₁ → Fin w → Fin w → ℝ)
    (step2 : Fin L₂ → Fin w → Fin w → ℝ) :
    tropicalPhi (compose step1 step2) ≥
      tropicalPhi step1 + tropicalPhi step2 - correction_term w
```

A tropical analogue of the data processing inequality: composing circuits cannot decrease tropical Φ by more than a bounded amount depending on the interface width.

### Why Breakthrough-Level

This would establish *tropical information theory* as a mathematical discipline. The data processing inequality is the cornerstone of Shannon's information theory. A tropical version would provide:
- Bounds on how tropical invariants compose under concatenation
- Tropical analogues of mutual information and channel capacity
- A theory of "tropical communication" through bounded-width interfaces

### Proof Strategy

1. Define tropical mutual information via the gap between independent and joint optimization.
2. Show that the interface between two sub-circuits acts as a "bottleneck" of width w.
3. Prove that the bottleneck limits the reduction in tropical Φ from joint optimization.
4. The correction term should be O(w · max_cost) where max_cost is the maximum single-step cost.

### Cross-Domain Connection

**Coding theory.** Tropical codes (linear codes over the tropical semiring) are an emerging topic. Tropical information inequalities would provide capacity bounds for these codes, connecting to the theory of lattice codes and network coding.

---

## Direction 5: Tensor Network Bridge

### Theorem Target

```
theorem tropical_phi_equals_tensor_contraction
    (T : TropicalTensorNetwork w L) :
    tropicalPhi (circuitOf T) = tropicalContraction T
```

and

```
theorem tropical_contraction_bounded_bond_dim
    (T : TropicalTensorNetwork w L) (h : bondDim T ≤ w) :
    tropicalContractionWork T ≤ L * w ^ 3
```

### Why Breakthrough-Level

This would establish a formal bridge between tropical geometry and tensor networks — two of the most active areas in mathematical physics and machine learning. Tensor networks (MPS, PEPS, MERA) are the state of the art for quantum simulation and are increasingly used in machine learning. Showing that their tropical (zero-temperature) limit corresponds exactly to tropical Φ would:

1. Import decades of tensor network algorithms into tropical geometry
2. Provide tropical proofs of tensor network complexity bounds
3. Suggest new quantum-inspired algorithms for tropical optimization

### Proof Strategy

1. Define tropical tensors: arrays with values in (ℝ, min, +).
2. Define tropical contraction: replace sum with min, product with addition.
3. Show that a layered tropical circuit is a special case of a matrix product state (MPS) in the tropical semiring.
4. Prove that contraction of a tropical MPS with bond dimension w takes O(L · w³) operations.
5. Relate to our O(L · w²) bound by showing the vector (vs matrix) variant saves a factor of w.

### Cross-Domain Connection

**Quantum computing.** Classical simulation of quantum circuits with bounded entanglement is a major research frontier. The tropical limit provides a simplified model where the complexity landscape can be fully characterized, potentially guiding the quantum case.

---

## Implementation Priorities

### Phase 1 (Immediate, 1-3 months)
- Direction 2 (Tropical spectral theory): Most self-contained, builds directly on current definitions
- Direction 3 (Complexity dichotomy, lower bound direction): Reduction construction is concrete

### Phase 2 (Medium-term, 3-6 months)
- Direction 1 (Bounded treewidth): Requires significant infrastructure (tree decompositions in Lean/Mathlib)
- Direction 4 (Information inequalities): Requires developing tropical information-theoretic foundations

### Phase 3 (Long-term, 6-12 months)
- Direction 5 (Tensor networks): Requires formalizing tensor network theory from scratch

### Team Structure

Each direction benefits from different expertise:
- **Direction 1:** Graph algorithms + formal methods
- **Direction 2:** Tropical algebra + spectral theory
- **Direction 3:** Computational complexity + reductions
- **Direction 4:** Information theory + tropical geometry
- **Direction 5:** Quantum computing + tensor networks + formalization

Cross-pollination between teams is essential: the tensor network team needs the spectral results; the dichotomy team needs the treewidth framework; everyone benefits from the information inequalities.

---

## Evaluation Metrics

For each direction, success is measured by:
1. **Formal theorem:** Machine-verified statement and proof
2. **Computational validation:** Python implementation demonstrating the theorem
3. **Publication readiness:** Self-contained paper with related work, applications, and future extensions
4. **Cross-domain impact:** At least one concrete application in a domain outside tropical geometry
