# Future Directions: Tropical Complexity Theory via Certified Semiring Spectra

## Overview

This document outlines the next breakthroughs opened by the tropical circuit lower bound framework. Each direction includes specific hypotheses, proof strategies, cross-domain connections, and estimated feasibility.

---

## Direction 1: Tropical Rank and Circuit Depth

### Hypothesis
Define the **tropical rank** of M as the minimum r such that M = A ⊗ B where A is n×r and B is r×n (in min-plus). Then: layered circuit depth ≥ tropical rank.

### Proof Strategy
1. Show that each layer of a layered decomposition contributes at most n to the tropical rank.
2. Prove tropical rank is subadditive under tropical multiplication.
3. Conclude: depth d implies tropical rank ≤ d × n.
4. Exhibit families with tropical rank Ω(n), giving depth Ω(1) (or better, Ω(n/log n) with refined analysis).

### Cross-Domain Connections
- **Communication complexity**: tropical rank relates to the nondeterministic communication complexity of the "shortest path" function.
- **Algebraic geometry**: tropical rank connects to the dimension of tropical varieties.

### Feasibility
**Medium-high.** The definitions are clean and the basic rank-depth inequality should be provable. Exhibiting families with large tropical rank is harder.

### Key Lemma to Formalize
```
def tropicalRank (M : Matrix (Fin n) (Fin m) ℕ) : ℕ := ...
theorem tropicalRank_le_depth_mul_n (h : HasLayeredRealization M d W) :
    tropicalRank M ≤ (d + 1) * n
```

---

## Direction 2: Min-Plus Communication Complexity

### Hypothesis
The min-plus communication complexity of computing the (i,j)-entry of M ⊗ N (where Alice holds row i of M and Bob holds column j of N) gives lower bounds on layered circuit depth.

### Proof Strategy
1. Define a two-party communication model where Alice holds the "left context" and Bob holds the "right context" of a layered circuit.
2. Show that d-layer circuits yield d-round communication protocols with message length ≤ n log W per round.
3. Use tropical permanent as a measure of communication hardness.

### Cross-Domain Connections
- **Information theory**: the communication cost of tropical product relates to conditional entropy of optimal paths.
- **Streaming algorithms**: one-pass streaming lower bounds for shortest path problems.

### Feasibility
**Medium.** The communication model is natural but connecting it to existing communication complexity techniques requires care.

---

## Direction 3: Tropical Adversary Methods for Branching Programs

### Hypothesis
Extend the spectral gap framework from layered circuits to branching programs (non-uniform computation models with adaptive state transitions).

### Proof Strategy
1. Model branching programs as sequences of state-dependent tropical matrices.
2. Define an adversary relation using tropical costs.
3. Show that any branching program computing a function with "high tropical adversary value" requires many states × depth.
4. Connect to the quantum adversary method via semidefinite relaxation of the tropical permanent.

### Cross-Domain Connections
- **Quantum computing**: the tropical adversary relates to the negative-weight quantum adversary method.
- **Game theory**: adversary arguments correspond to minimax strategies in zero-sum games over the tropical semiring.

### Feasibility
**Hard.** This requires significant new theory but would be a major breakthrough if achieved.

---

## Direction 4: Spectral-Gap Lower Bounds for Dynamic Programming Circuits

### Hypothesis
For DP circuits computing optimization problems (shortest path, edit distance, etc.), the tropical spectral gap of the transition matrix gives a lower bound on the number of DP stages.

### Proof Strategy
1. Define DP circuits formally as sequences of tropical matrix-vector multiplications.
2. Show that the minimum cycle mean λ_t(M) = lim_{k→∞} minDiag(tropPow M k) / (k+1) is well-defined.
3. Prove: if the target cost is B, then the number of DP stages is at least B / (λ_t(M) + ε) for any ε > 0.
4. Compute λ_t(M) for explicit DP formulations.

### Cross-Domain Connections
- **Control theory**: λ_t(M) is the max-plus eigenvalue, central in discrete event systems.
- **Statistical physics**: λ_t(M) is the zero-temperature free energy per step.

### Feasibility
**Medium.** The minimum cycle mean is well-studied in max-plus algebra. The main challenge is connecting it to specific DP problems.

### Key Definition to Formalize
```
noncomputable def tropicalSpectralValue (M : Matrix (Fin n) (Fin n) ℕ) : ℚ :=
  Finset.univ.inf' Finset.univ_nonempty
    (fun k : Fin n => (minDiag (tropPow M k) : ℚ) / (k.val + 1))
```

---

## Direction 5: Tropical Complexity Class Separations in Restricted Models

### Hypothesis
Define tropical complexity classes:
- **TROP-NC^k**: functions computable by polynomial-size layered tropical circuits of depth O(log^k n).
- **TROP-P**: functions computable by polynomial-size tropical circuits of polynomial depth.
- **TROP-PERM**: the class of functions reducible to tropical permanent computation.

Then: TROP-NC^1 ⊊ TROP-P ⊊ TROP-PERM.

### Proof Strategy
1. Use the tropical permanent lower bound to separate TROP-NC^1 from TROP-P: exhibit a family in TROP-P \ TROP-NC^1 using the permanent obstruction.
2. Use the counterexample to minDiag subadditivity as evidence that naive spectral methods don't extend to full class separation.
3. Develop new invariants (tropical Barrington theorem? tropical polynomial method?) for the TROP-P vs TROP-PERM separation.

### Cross-Domain Connections
- **Algebraic complexity theory**: GCT-style approach in the tropical setting.
- **Combinatorial optimization**: TROP-PERM captures the assignment problem.

### Feasibility
**Hard.** But the restricted model makes it more tractable than general class separation.

---

## Direction 6: Tropical Permanent Families with Super-Linear Growth

### Hypothesis
Construct explicit families of n×n matrices M_n with tropPerm(M_n) = Ω(n²), proving that layered circuits with constant weight cap need depth Ω(n).

### Proof Strategy
1. Use Hadamard-like constructions: M_n(i,j) = Hamming distance between binary representations of i and j.
2. Show that any permutation σ has ∑_i Hamming(i, σ(i)) ≥ Ω(n²) by counting bit disagreements.
3. This gives tropPerm = Ω(n²), hence depth ≥ Ω(n) with unit weights.

### Feasibility
**High.** Hamming distance matrices are well-understood and the permanent bound should be calculable.

### Explicit Construction
For n = 2^m, define M(i,j) = popcount(i XOR j). Then:
- Every permutation moves at least Ω(n) elements by Ω(m) positions each.
- Total: tropPerm ≥ Ω(n × m) = Ω(n log n).

---

## Direction 7: Energy Barriers and Tropical Complexity

### Hypothesis
Interpret tropical circuit depth as a thermodynamic computation time. The spectral gap becomes an energy barrier, and depth lower bounds become thermodynamic speed limits.

### Proof Strategy
1. Define a Gibbs-like ensemble over walks, with inverse temperature β.
2. At β → ∞, the partition function becomes the tropical matrix entry.
3. Show that free-energy barriers (spectral gaps) persist at all temperatures.
4. Use phase-transition analysis to identify "computational hardness temperatures."

### Cross-Domain Connections
- **Statistical physics**: Landauer's principle and the thermodynamics of computation.
- **Random matrix theory**: universality of tropical spectral gaps.
- **Machine learning**: ReLU networks are piecewise-linear, hence tropical.

### Feasibility
**Speculative but high-impact.** The physics connection is genuine and could attract interdisciplinary interest.

---

## Prioritized Research Plan

| Priority | Direction | Estimated Time | Dependencies |
|----------|-----------|----------------|--------------|
| 1        | Dir 6 (Super-linear permanent) | 2-4 weeks | None |
| 2        | Dir 1 (Tropical rank) | 3-6 weeks | None |
| 3        | Dir 4 (DP spectral gap) | 4-8 weeks | Dir 1 partial |
| 4        | Dir 2 (Communication) | 6-10 weeks | Dir 1 |
| 5        | Dir 5 (Class separation) | 8-16 weeks | Dir 1, Dir 6 |
| 6        | Dir 3 (Adversary methods) | 12-20 weeks | Dir 2, Dir 4 |
| 7        | Dir 7 (Energy barriers) | 8-16 weeks | Dir 4 |

## Team Directive

Each direction should be pursued by a team that:
1. **States precise conjectures** as formal theorem signatures.
2. **Validates computationally** with Python experiments on matrices up to n=20.
3. **Builds proof skeletons** in Lean with sorry'd lemmas.
4. **Proves bottom-up**, starting with the simplest helper lemmas.
5. **Documents counterexamples** as carefully as positive results.
6. **Reports monthly** with: theorems proved, counterexamples found, revised conjectures, and updated feasibility assessments.

The counterexample to minDiag subadditivity demonstrates that intuition can mislead in tropical algebra. Every conjecture should be stress-tested computationally before proof investment.
