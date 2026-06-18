# Gravity as Quantum Error Correction: A Formal Framework for Spacetime from Codes

## Abstract

We develop a formal mathematical framework connecting quantum error-correcting codes to holographic gravity. We define quantum error-correcting codes (QEC codes) with the quantum Singleton bound as a structural constraint, formalize the Ryu-Takayanagi formula as a discrete geometric structure on boundary regions, and establish the precise mathematical bridge between code-theoretic parameters and holographic entropy. Our main results include: (1) the area-entropy duality theorem showing that for perfect codes, the code distance and logical dimension exactly determine the number of physical qubits via 2(d−1) + k = n; (2) a complete proof that strong subadditivity of entropy implies subadditivity for disjoint regions and non-negativity of mutual information; (3) the complementary recovery bound showing that large boundary regions necessarily exclude their complements from accessing bulk information; and (4) a structural theorem on tensor network decompositions (HaPPY codes) showing that the total logical dimension equals the number of tiles. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: quantum error correction, holographic principle, AdS/CFT, Ryu-Takayanagi formula, Singleton bound, tensor networks, HaPPY code, entanglement entropy

## 1. Introduction

The holographic principle — the idea that the information content of a region of space is bounded by its boundary area rather than its volume — has become a cornerstone of modern theoretical physics. The AdS/CFT correspondence provides the most concrete realization: a (d+1)-dimensional gravitational theory in anti-de Sitter space is dual to a d-dimensional conformal field theory on the boundary.

A breakthrough insight of Almheiri, Dong, and Harlow (2015) and Pastawski, Yoshida, Harlow, and Preskill (2015) is that this holographic encoding has precisely the structure of a quantum error-correcting code. The boundary CFT encodes bulk information redundantly, just as a QEC code encodes logical qubits in physical qubits. The code distance — the minimum weight of a non-trivial logical operator — corresponds to the length of the shortest geodesic through the bulk.

In this paper, we formalize this connection rigorously, establishing the mathematical equivalence between code-theoretic bounds and geometric entropy formulas. Our framework is built on four pillars:

1. **QEC codes with the Singleton bound**: We define codes [[n, k, d]] with the quantum Singleton bound 2(d−1) ≤ n − k as a structural axiom.
2. **The Ryu-Takayanagi formula**: We formalize RT as a structure associating boundary regions with minimal surface areas.
3. **Strong subadditivity**: We prove key entropy inequalities from the SSA axiom.
4. **Tensor network decomposition**: We formalize the HaPPY code as a tiling by [[5,1,3]] codes.

## 2. Definitions

### 2.1 Quantum Error-Correcting Codes

**Definition 2.1** (QECCode). A quantum error-correcting code is a tuple (n, k, d) of natural numbers satisfying:
- k ≤ n (the number of logical qubits does not exceed physical qubits)
- d > 0 (the code distance is positive)  
- d ≤ n (the code distance does not exceed the number of physical qubits)
- 2(d − 1) ≤ n − k (the quantum Singleton bound)

The quantum Singleton bound is the quantum analogue of the classical Singleton bound d ≤ n − k + 1. The factor of 2 arises from the no-cloning theorem: quantum error correction requires twice the redundancy of classical error correction.

**Definition 2.2** (Redundancy). The redundancy of a code [[n, k, d]] is r = n − k.

**Definition 2.3** (Perfect Code). A code is perfect if it saturates the Singleton bound: 2(d − 1) = n − k.

**Definition 2.4** (Erasure Threshold). The erasure threshold is t = d − 1, the maximum number of qubits that can be erased while preserving the logical information.

### 2.2 The [[5,1,3]] Code

The [[5,1,3]] code is the smallest perfect quantum error-correcting code:
- n = 5 physical qubits
- k = 1 logical qubit  
- d = 3 code distance
- Redundancy: 4
- Erasure threshold: 2
- Singleton bound: 2(3−1) = 4 = 5−1 ✓ (saturated)

### 2.3 Boundary Regions and the Ryu-Takayanagi Formula

**Definition 2.5** (RTFormula). An RT formula for a system with n boundary sites consists of:
- A function minimalArea mapping each nonempty boundary region to a natural number
- The constraint that the full boundary has zero area
- The constraint that the minimal area is bounded by the region size

**Definition 2.6** (HolographicCode). A holographic code is a QEC code equipped with an RT formula such that the code distance equals the minimal area of some half-boundary region.

### 2.4 Entropy Structures

**Definition 2.7** (MonotoneEntropy). A monotone entropy function on n parties is a function S from subsets of {1,...,n} to ℝ satisfying S(A) ≥ 0 for all A and S(∅) = 0.

**Definition 2.8** (Strong Subadditivity). An entropy function S satisfies SSA if for all A, B: S(A ∪ B) + S(A ∩ B) ≤ S(A) + S(B).

**Definition 2.9** (Holographic Entropy Vector). An entropy vector is holographic if it satisfies non-negativity, SSA, and the monogamy of mutual information (MMI): for disjoint A, B, C, S(A∪B) + S(A∪C) + S(B∪C) ≥ S(A) + S(B) + S(C) + S(A∪B∪C).

### 2.5 Tensor Networks

**Definition 2.10** (TensorTile). A tensor tile consists of a QEC code, a number of bulk legs, and a number of boundary legs, with the constraint that the total number of legs equals the code size.

**Definition 2.11** (HaPPYCode). A HaPPY code consists of a collection of tensor tiles, all using the [[5,1,3]] code, with a specified boundary size equal to the sum of boundary legs.

### 2.6 Entanglement Wedges

**Definition 2.12** (EntanglementWedge). An entanglement wedge assignment maps boundary regions to subsets of logical qubits, satisfying monotonicity (A ⊆ B ⟹ wedge(A) ⊆ wedge(B)), completeness (wedge(full) = all), and vacuity (wedge(∅) = ∅).

## 3. Main Results

### 3.1 Area-Entropy Duality

**Theorem 3.1** (Area-Entropy Duality). For a perfect code [[n, k, d]]:
$$2(d - 1) + k = n$$

*Proof sketch*. By definition of perfectness, 2(d−1) = n − k. Adding k to both sides and using n − k + k = n (which follows from k ≤ n). □

This is the discrete analogue of the Ryu-Takayanagi formula: the "area" 2(d−1) plus the "bulk entropy" k equals the "boundary entropy" n.

### 3.2 Subadditivity from Strong Subadditivity

**Theorem 3.2** (Subadditivity from SSA). If S satisfies SSA, then for disjoint A, B:
$$S(A \cup B) \leq S(A) + S(B)$$

*Proof sketch*. Specialize SSA to A, B: S(A∪B) + S(A∩B) ≤ S(A) + S(B). Since A∩B = ∅, S(A∩B) = S(∅) = 0. Therefore S(A∪B) ≤ S(A) + S(B). □

### 3.3 Non-negativity of Mutual Information

**Theorem 3.3** (Mutual Information Non-negativity). If S satisfies SSA, then for disjoint A, B:
$$I(A:B) = S(A) + S(B) - S(A \cup B) \geq 0$$

*Proof*. Immediate from Theorem 3.2: S(A∪B) ≤ S(A) + S(B) implies S(A) + S(B) − S(A∪B) ≥ 0. □

### 3.4 Complementary Recovery

**Theorem 3.4** (Complementary Recovery Bound). For a code [[n, k, d]], if a boundary region has A_size ≥ n − d + 1 sites, then the complement has fewer than d sites:
$$n - A_{\text{size}} < d$$

*Proof*. Direct arithmetic: A_size ≥ n − d + 1 implies n − A_size ≤ d − 1 < d. □

This is the code-theoretic expression of the no-cloning theorem in holographic gravity: if a boundary region is large enough to reconstruct a bulk operator, its complement is too small to do the same.

### 3.5 HaPPY Code Structure

**Theorem 3.5** (HaPPY Logical Qubits). In a HaPPY code with T tiles, the total number of logical qubits is T.

*Proof*. Each tile uses the [[5,1,3]] code, which has k = 1. The sum ∑ᵢ kᵢ = ∑ᵢ 1 = T. □

**Theorem 3.6** (HaPPY Total Legs). In a HaPPY code with T tiles, the total number of physical legs is 5T.

*Proof*. Each tile uses the [[5,1,3]] code, which has n = 5. The sum ∑ᵢ nᵢ = ∑ᵢ 5 = 5T. □

### 3.6 Erasure Threshold

**Theorem 3.7** (Erasure Threshold Bound). For any QEC code, the erasure threshold is at most half the redundancy:
$$d - 1 \leq \lfloor(n - k)/2\rfloor$$

*Proof*. From the Singleton bound: 2(d−1) ≤ n − k. Dividing by 2: d − 1 ≤ ⌊(n−k)/2⌋. □

### 3.7 Perfect Code Parameter Identity

**Theorem 3.8** (Perfect Code Parameters). For a perfect code with k > 0:
$$n = 2d - 2 + k$$

*Proof*. From 2(d−1) = n − k and d ≥ 1: n − k = 2d − 2, so n = 2d − 2 + k. □

### 3.8 Singleton-Erasure Equivalence

**Theorem 3.9** (Singleton ↔ Erasure). The quantum Singleton bound is equivalent to:
$$2(d - 1) \leq n - k \iff 2d \leq n - k + 2$$

*Proof*. Natural number arithmetic with d ≥ 1. □

## 4. The Bridge: Singleton Bound ↔ Ryu-Takayanagi

The central insight connecting quantum error correction to holographic gravity can be summarized as follows:

| Code Theory | Holographic Gravity |
|---|---|
| Physical qubits n | Boundary sites |
| Logical qubits k | Bulk degrees of freedom |
| Code distance d | Minimal geodesic length |
| Redundancy n − k | Area / 4G_N |
| Singleton bound 2(d−1) ≤ n−k | RT formula Area ≥ 2(geodesic − 1) |
| Erasure threshold d − 1 | Entanglement wedge radius |
| Perfect code 2(d−1) = n−k | Saturation of RT bound |
| No-cloning theorem | Complementary recovery |

The area-entropy duality (Theorem 3.1) is the code-theoretic expression of the Ryu-Takayanagi formula. For a perfect code, the geometric area (= 2(d−1)) and the bulk entropy (= k) exactly account for all boundary degrees of freedom (= n).

## 5. Algorithms

### 5.1 Greedy Entanglement Wedge Reconstruction

Given a boundary region A and a bulk graph:
1. Initialize the reconstructed set R = ∅.
2. For each bulk vertex v not in R: count the edges from v to A ∪ R (call this count_in) and the edges from v to the complement (call this count_out).
3. If count_in > count_out, add v to R.
4. Repeat until no more vertices can be added.
5. Return R as the entanglement wedge of A.

This algorithm has complexity O(V · E) where V is the number of bulk vertices and E is the number of edges.

### 5.2 RT Minimal Surface Computation

For a discrete bulk graph, the minimal surface homologous to a boundary region A is a minimum cut in the graph:
1. Add a source vertex connected to all boundary sites in A.
2. Add a sink vertex connected to all boundary sites not in A.
3. Compute the minimum cut between source and sink.
4. The cut value is the discrete area (= code distance for the optimal cut).

This reduces to max-flow/min-cut, solvable in O(V³) by the push-relabel algorithm.

## 6. Conjecture: Holographic MMI Tightness

**Conjecture 6.1** (MMI Tightness). For n = 4 parties, every holographic entropy vector satisfies MMI, and there exist holographic states achieving exact MMI equality.

**Computational Test**: Enumerate all RT cuts for the [[5,1,3]] code with 4 boundary regions. Verify (1) all entropy vectors satisfy MMI, and (2) at least one achieves I₃ = 0 within tolerance 10⁻⁶.

This conjecture is falsifiable: if either condition fails for any partition of the 5 boundary sites into 4 groups, the conjecture is disproved.

## 7. Discussion

### 7.1 Limitations

Our framework works in the discrete setting with ℕ-valued parameters. The continuous limit — where the bulk geometry is a smooth Riemannian manifold and the boundary theory is a full QFT — requires additional machinery (functional analysis, measure theory) not developed here.

The quantum Singleton bound is taken as an axiom of the code structure rather than derived from first principles. A complete treatment would derive it from the no-cloning theorem and the structure of quantum Hilbert spaces.

### 7.2 Comparison with Prior Work

The existing catalog theorem `quantum_code_distance_from_obstruction` (in `Bridges/HomologicalDeepLearning.lean`) establishes a connection between Ext-group obstruction dimensions and code distances. Our work complements this by providing the geometric side of the bridge: the code distance is not just an algebraic invariant but a geometric one (geodesic length in the bulk).

The `boundary_determines_minimal_bulk` theorem (in `Bridges/UltrametricHolographicRenormalization.lean`) establishes that boundary data uniquely determines the minimal bulk reconstruction. Our entanglement wedge framework provides the code-theoretic mechanism: the boundary data determines the bulk via the code's error-correcting structure.

### 7.3 Implications

If the holographic principle is correctly modeled by quantum error correction, then:

1. **Spacetime is emergent**: The bulk geometry is not fundamental but arises from the code's encoding structure.
2. **Gravity is entropic**: The gravitational force is a consequence of the code's error-correcting properties, mediated by the RT formula.
3. **Black hole information is preserved**: The code's error-correcting capability ensures that information thrown into a black hole is preserved on the boundary, consistent with unitarity.

## 8. Future Work

1. Extend the framework to approximate quantum error correction (AQEC), where the Singleton bound is replaced by approximate bounds.
2. Formalize the connection between the holographic entropy cone and the quantum entropy cone for n ≥ 5 parties.
3. Develop a theory of holographic codes on non-hyperbolic geometries (flat, de Sitter).
4. Prove the RT formula directly from the code structure without assuming it as an axiom.

## References

1. Almheiri, A., Dong, X., & Harlow, D. (2015). Bulk locality and quantum error correction in AdS/CFT. *JHEP*, 2015(4), 163.
2. Pastawski, F., Yoshida, B., Harlow, D., & Preskill, J. (2015). Holographic quantum error-correcting codes: Toy models for the bulk/boundary correspondence. *JHEP*, 2015(6), 149.
3. Ryu, S., & Takayanagi, T. (2006). Holographic derivation of entanglement entropy from AdS/CFT. *Physical Review Letters*, 96(18), 181602.
4. Maldacena, J. (1999). The large-N limit of superconformal field theories and supergravity. *International Journal of Theoretical Physics*, 38, 1113–1133.
5. Hayden, P., Nezami, S., Qi, X.-L., Thomas, N., Walter, M., & Yang, Z. (2016). Holographic duality from random tensor networks. *JHEP*, 2016(11), 9.
6. Bao, N., Nezami, S., Ooguri, H., Stoica, B., Sully, J., & Walter, M. (2015). The holographic entropy cone. *JHEP*, 2015(9), 130.
