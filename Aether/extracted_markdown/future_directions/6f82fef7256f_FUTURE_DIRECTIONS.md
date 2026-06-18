# Future Directions: Tropical Factor Rank and Complexity Theory

## Overview

This document outlines breakthrough-level research directions opened by the formalization of tropical factor rank theory. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Factor Rank ↔ Boolean Rectangle Covering Number

### Hypothesis
For any tropical matrix M over WithTop ℤ, the factor rank of M equals the minimum number of combinatorial rectangles needed to cover supp(M) such that each rectangle R_k admits a consistent rank-1 assignment.

### Concrete Theorem Target
```
theorem factorRank_eq_weighted_rectangle_cover (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropFactorRank M = minWeightedRectangleCover (support M) M
```

### Proof Strategy
1. Define `WeightedRectangleCover`: a collection of rectangles R_k = S_k × T_k with weights (u_k, v_k) such that on each R_k, M(i,j) ≥ u_k(i) + v_k(j), and the pointwise minimum reconstructs M.
2. Show that any tropical decomposition induces a weighted rectangle cover (forward direction — already essentially proved).
3. Show that any weighted rectangle cover can be extended to a tropical decomposition (by setting entries outside the rectangle to ⊤).
4. The factor rank equals the minimum cover size.

### Cross-Domain Impact
- **Communication complexity**: Provides a tropical algebraic certificate for nondeterministic communication protocols.
- **Extension complexity**: Connects to the Yannakakis theorem relating extension complexity to nondeterministic communication complexity.

### Timeline
Immediate. The key lemmas are already established; this direction primarily requires careful definition engineering.

---

## Direction 2: Tropical Extension Complexity for Polytopes

### Hypothesis
The tropical factor rank of the slack matrix of a polytope P provides a lower bound on the extension complexity of P.

### Concrete Theorem Target
```
theorem extension_complexity_lower_bound (P : Polytope ℝ d) :
    extensionComplexity P ≥ tropFactorRank (tropicalSlackMatrix P)
```

### Proof Strategy
1. Define the tropical slack matrix: S^trop(i,j) = tropical evaluation of the j-th constraint at the i-th vertex.
2. Show that any extended formulation of P induces a tropical factorization of S^trop (via the logarithmic/tropical limit of the slack matrix factorization).
3. Apply the factor rank lower bound.

### Key Challenges
- Defining polytopes and extended formulations formally in Lean
- The tropical limit requires careful asymptotic analysis
- May need Maslov dequantization theory

### Cross-Domain Impact
- **Combinatorial optimization**: New lower bounds on LP formulation sizes
- **Proof complexity**: Connection to proof system lower bounds via feasible interpolation

### Timeline
Medium-term (6-12 months). Requires significant mathematical infrastructure in Lean.

---

## Direction 3: Factor Rank of Distance Matrices and Shortest-Path Kernels

### Hypothesis
For specific graph families, the factor rank of the all-pairs shortest path matrix can be determined exactly:
- **Path graph P_n**: factorRank(D_{P_n}) = 2
- **Cycle graph C_n**: factorRank(D_{C_n}) = ⌈n/2⌉
- **Complete graph K_n** (unit weights): factorRank(D_{K_n}) = n
- **Expander graphs**: factorRank(D_G) = Θ(n)

### Concrete Theorem Targets
```
theorem factorRank_path_distance (n : ℕ) (hn : 2 ≤ n) :
    tropFactorRank (pathDistanceMatrix n) = 2

theorem factorRank_complete_distance (n : ℕ) (hn : 1 ≤ n) :
    tropFactorRank (completeDistanceMatrix n) = n
```

### Proof Strategy
- **Path**: The distance matrix d(i,j) = |i-j| decomposes as min(i + (n-j), (n-i) + j) — two rank-1 summands.
- **Complete**: The unit-weight complete graph distance is I^trop + J (min of identity and all-ones). The identity component forces factor rank n.
- **Expander**: Use spectral expansion to show that the distance metric is "non-separable" in a precise tropical sense.

### Cross-Domain Impact
- **Metric geometry**: Factor rank as a measure of metric separability
- **Algorithm design**: Low factor rank enables faster approximate shortest paths
- **Network science**: Structural complexity of real-world networks

### Timeline
Short-term (3-6 months). Path and complete graph cases are immediate; expander case requires new techniques.

---

## Direction 4: Formal Bridge Between Tropical Factorization and Communication Protocols

### Hypothesis
There is a formal isomorphism between:
1. Tropical decompositions of rank r for a matrix M
2. Nondeterministic communication protocols of cost log(r) for the support relation of M

### Concrete Theorem Target
```
theorem tropical_decomp_iff_comm_protocol (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) (r : ℕ) :
    TropDecomp r M ↔ ∃ (P : CommProtocol (Fin m) (Fin n) (Fin r)),
      P.accepts = support M ∧ P.isConsistent M
```

### Proof Strategy
1. Define a `CommProtocol` type: Alice has i, Bob has j, they exchange a message k ∈ Fin r.
2. A protocol "accepts" (i,j) if ∃ k, Alice accepts on (i,k) and Bob accepts on (k,j).
3. Show: tropical decomposition ⟹ protocol (k-th summand = k-th message).
4. Show: protocol ⟹ tropical decomposition (each message defines a rectangle).
5. Consistency means the reconstructed values match M.

### Cross-Domain Impact
- **Complexity theory**: Formalized connection between algebraic and combinatorial complexity
- **Proof assistants**: First formal communication complexity library in Lean
- **Information theory**: Tropical decomposition as information compression

### Timeline
Medium-term (6-12 months). Requires building communication complexity infrastructure from scratch.

---

## Direction 5: Search for Matrices with Polynomial Tropical Rank but Exponential Factor Rank

### Hypothesis
There exist explicit n×n tropical matrices M_n with:
- Tropical rank (Develin–Santos–Sturmfels) = O(log n)
- Factor rank = Ω(n)

### Candidate Construction
Consider the n×n matrix M where M(i,j) = Hamming weight of (i XOR j) (interpreting i,j as binary strings). This matrix has low tropical rank (related to the Hamming distance structure) but potentially high factor rank (the support has exponentially many distinct row patterns).

### Proof Strategy
1. **Upper bound on tropical rank**: Show that the Hamming distance matrix has tropical rank O(log n) by constructing O(log n) tropical minors that determine the matrix.
2. **Lower bound on factor rank**: Use the rectangle covering argument. The support of the Hamming distance matrix (entries ≤ threshold t) may require exponentially many rectangles.
3. **Alternative**: Use the Boolean complement — the matrix M'(i,j) = 1 if Hamming(i,j) > t, 0 otherwise — and relate its tropical factor rank to known communication complexity lower bounds for the Greater-Than-Threshold function.

### Cross-Domain Impact
- **Complexity theory**: Exponential separation between intrinsic dimension and decomposition complexity
- **Coding theory**: Connection between error-correcting codes and tropical factorizations
- **Quantum computing**: Potential quantum speedups for tropical decomposition

### Timeline
Long-term (12-24 months). Requires new lower bound techniques and potentially connections to circuit complexity.

---

## Research Program: Formal Complexity Theory of Tropical Representations

### Vision
Build a comprehensive formal library connecting:
- Tropical factor rank ↔ Extension complexity
- Rectangle covering ↔ Communication complexity
- Tropical spectral theory ↔ Dynamic programming
- Tropical Plücker relations ↔ Algebraic complexity

### Milestones
1. **Q1**: Complete Directions 1 and 3 (rectangle covering equivalence, simple graph distance matrices)
2. **Q2**: Begin Direction 4 (communication protocols), prove exponential separation for one explicit family
3. **Q3-Q4**: Direction 2 (polytope extension complexity), connect to Yannakakis theorem
4. **Year 2**: Direction 5 (polynomial vs exponential separation), connect to circuit complexity

### Infrastructure Needs
- Formal communication complexity library in Lean 4
- Tropical polytope definitions and basic theory
- Graph distance matrix constructions
- Connection to existing Mathlib graph theory

### Team Structure
- **Theory lead**: Tropical algebra and rank separation
- **Formalization lead**: Lean 4 proof engineering
- **Algorithms lead**: Computational experiments and conjectures
- **Applications lead**: Connections to optimization and CS

---

## Specific Next Theorems to Formalize

1. `factorRank_ge_support_antichain_size` — factor rank is at least the maximum antichain in the incompatibility graph of the support
2. `factorRank_le_numRows` — symmetric upper bound (already in existing library, adapt)
3. `factorRank_tropId_transpose_eq` — factor rank of transpose equals factor rank (for identity, trivial; general case interesting)
4. `factorRank_direct_sum` — factor rank of block diagonal is sum of component ranks
5. `factorRank_submatrix_le` — factor rank of a submatrix is at most factor rank of the parent

Each of these is independently valuable and contributes to the broader program.
