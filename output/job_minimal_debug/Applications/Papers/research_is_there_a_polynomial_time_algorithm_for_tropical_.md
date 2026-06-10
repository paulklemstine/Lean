# Polynomial-Time Tropical Φ via Width-Bounded Dynamic Programming

## Abstract

We formalize a layered tropical circuit model with *L* layers and width *w*, and prove that the tropical Φ invariant — the minimum-cost path through the circuit — is exactly computable by Bellman dynamic programming in *O(L · w²)* arithmetic operations. This replaces the brute-force enumeration of *w^(L+1)* trajectories with a polynomial-time algorithm when width is fixed. We prove three main results: (1) **Correctness** — the DP algorithm computes the exact minimum, not an approximation; (2) **Complexity** — the work bound is *L · w² + w*; and (3) **Asymptotic separation** — for any fixed width, the DP work is eventually less than 2^L, establishing an exponential gap. All results are machine-verified. We discuss applications to shortest paths in layered graphs, Viterbi decoding, transfer matrices in statistical mechanics, and neural network robustness certification.

**Keywords:** tropical geometry, min-plus algebra, dynamic programming, Bellman equation, parameterized complexity, layered graphs, transfer matrix, width-bounded computation.

---

## 1. Introduction

### 1.1 Motivation

Tropical geometry, built on the min-plus semiring (ℝ ∪ {∞}, min, +), has emerged as a fundamental framework connecting optimization, algebraic geometry, and combinatorics. A central computational challenge is evaluating *tropical invariants* of structured systems — quantities defined as extrema over exponentially many configurations.

The *tropical Φ invariant* of a layered circuit is the minimum total cost over all state trajectories through the system. Naive computation requires enumerating all trajectories, yielding exponential complexity in the depth. Prior work has established that the configuration spaces of such circuits grow exponentially (region count bounds) and even doubly exponentially in certain parameter regimes.

The key insight of this paper is that *width* — the number of states per layer — is the correct structural parameter controlling tropical computational complexity. When width is bounded, the Bellman principle collapses the exponential trajectory space into a polynomial dynamic programming computation.

### 1.2 Contributions

1. **Model formalization.** We define a clean finite combinatorial model of layered tropical circuits parameterized by depth *L* and width *w*, with transition costs in ℝ.

2. **Correctness theorem.** We prove that the Bellman DP exactly computes tropical Φ (Theorem 2).

3. **Work bound.** We prove the DP uses at most *L · w² + w* arithmetic operations (Theorem 3).

4. **Asymptotic separation.** We prove that for any fixed *w*, the DP work is eventually less than 2^L (Theorem 4).

5. **Machine verification.** All results are formalized and verified, ensuring logical soundness.

### 1.3 Related Work

**Tropical geometry.** The tropical semiring was introduced by Simon [1988] and systematically developed by Mikhalkin, Sturmfels, and others. Tropical methods have found applications in optimization, auction theory, phylogenetics, and neural network analysis [Alfons et al., Zhang et al.].

**Dynamic programming.** The Bellman equation [Bellman, 1957] is the foundation of DP-based optimization. Our work applies this classical principle in the specific context of tropical circuit evaluation.

**Bounded treewidth.** Courcelle's theorem [1990] and its algorithmic consequences show that MSO-definable problems are polynomial on bounded-treewidth graphs. Our width parameter is analogous to pathwidth, and our layered structure corresponds to path decompositions.

**Transfer matrices.** In statistical mechanics, the transfer matrix method [Baxter, 1982] evaluates partition functions of quasi-1D systems in polynomial time. Our DP recurrence is the zero-temperature (tropical) limit of this method.

**Viterbi algorithm.** The Viterbi algorithm [1967] for hidden Markov models is a special case of min-plus DP on layered systems. Our theorem provides a complexity-theoretic context for its efficiency.

---

## 2. Model: Layered Tropical Circuits

### 2.1 Definitions

**Definition 1** (Layered Tropical Circuit). A *layered tropical circuit* consists of:
- A depth parameter *L* ∈ ℕ (number of layers/transitions)
- A width parameter *w* ∈ ℕ₊ (number of states per layer)
- A cost function *step* : {0, ..., L-1} × {0, ..., w-1} × {0, ..., w-1} → ℝ

The quantity *step(ℓ, s, t)* represents the tropical cost of transitioning from state *s* to state *t* at layer *ℓ*.

**Definition 2** (Trajectory). A *trajectory* is a function *q* : {0, ..., L} → {0, ..., w-1} assigning a state to each layer boundary.

**Definition 3** (Path Cost). The *path cost* of a trajectory *q* is:

$$\text{PathCost}(q) = \sum_{\ell=0}^{L-1} \text{step}(\ell, q(\ell), q(\ell+1))$$

**Definition 4** (Tropical Φ). The *tropical Φ* of the circuit is:

$$\Phi = \min_{q} \text{PathCost}(q)$$

where the minimum is over all *w^(L+1)* trajectories.

### 2.2 Formal Encoding

In our formalization, states are elements of `Fin w`, layers are indexed by `Fin L`, and trajectory is a function `Fin (L+1) → Fin w`. The tropical Φ is defined via `Finset.inf'` over the finite, nonempty set of all trajectories:

```
def tropicalPhi {L w : ℕ} [NeZero w]
    (step : Fin L → Fin w → Fin w → ℝ) : ℝ :=
  Finset.inf' Finset.univ Finset.univ_nonempty
    (fun q : Fin (L + 1) → Fin w => PathCost step q)
```

---

## 3. The Bellman DP Algorithm

### 3.1 Algorithm Description

The DP table *V* is computed by backward induction:

**Base case:** *V(0, s) = 0* for all states *s*. (With 0 remaining layers, the cost-to-go is zero.)

**Recursive case:** For *n + 1* remaining layers:

$$V(n+1, s) = \min_{t \in \{0,\ldots,w-1\}} \left[ \text{step}(L-(n+1), s, t) + V(n, t) \right]$$

**Final answer:**

$$\text{computePhiDP} = \min_{s \in \{0,\ldots,w-1\}} V(L, s)$$

### 3.2 Pseudocode

```
Algorithm: BellmanTropicalDP(step, L, w)
Input: Cost function step[0..L-1][0..w-1][0..w-1], depth L, width w
Output: tropicalΦ

1. Initialize V[s] ← 0 for all s ∈ {0, ..., w-1}
2. For ℓ = L-1 down to 0:
3.     For each s ∈ {0, ..., w-1}:
4.         V_new[s] ← min_{t ∈ {0,...,w-1}} (step[ℓ][s][t] + V[t])
5.     V ← V_new
6. Return min_{s} V[s]
```

### 3.3 Complexity Analysis

- **Time:** Lines 2-5 iterate over *L* layers, *w* source states, and *w* target states: *L · w²* operations. Line 6 adds *w* comparisons. Total: *L · w² + w*.
- **Space:** *O(w)* with the space-efficient version (two vectors of size *w*), or *O(L · w)* for the full table.

---

## 4. Main Results

### 4.1 Theorem 1: Upper Bound (dpTable_le_pathCost)

**Theorem 1.** For any trajectory *q*, the DP value at *q(0)* is at most PathCost(*q*):

$$V(L, q(0)) \leq \text{PathCost}(q)$$

*Proof sketch.* By induction on the number of remaining layers *n*. At each step, the DP minimizes over all next states, so it is at most the value achieved by the specific next state chosen by *q*. The inductive hypothesis bounds the suffix cost.

The formal proof constructs a stronger inductive statement: for all *n ≤ L* and all trajectories *q*,

$$V(n, q(L-n)) \leq \sum_{i=0}^{n-1} \text{step}(L-n+i, q(L-n+i), q(L-n+i+1))$$

and specializes to *n = L*.

### 4.2 Theorem 2: Achievability (exists_traj_eq_dpTable)

**Theorem 2.** For any initial state *s*, there exists a trajectory *q* with *q(0) = s* and PathCost(*q*) = *V(L, s)*.

*Proof sketch.* By induction on *n* (remaining layers). At each step, the DP minimum over the finite nonempty set `Fin w` is achieved by some state *t₀*. The trajectory is constructed by prepending *s* to the optimal suffix trajectory from *t₀* obtained by the inductive hypothesis. The formal proof uses `Fin.cons` to build the trajectory and `Finset.exists_min_image` to extract the minimizer.

### 4.3 Theorem 3: Global Correctness (computePhiDP_correct)

**Theorem 3.** computePhiDP = tropicalPhi.

*Proof.* By antisymmetry:
- *computePhiDP ≤ tropicalPhi*: For any trajectory *q*, computePhiDP ≤ V(L, q(0)) ≤ PathCost(q) by Theorem 1. Taking the infimum over *q* gives computePhiDP ≤ tropicalPhi.
- *tropicalPhi ≤ computePhiDP*: For any initial state *s*, by Theorem 2, there exists *q* with PathCost(q) = V(L, s). So tropicalPhi ≤ PathCost(q) = V(L, s). Taking the infimum over *s* gives tropicalPhi ≤ computePhiDP. □

### 4.4 Theorem 4: Work Bound (dpWork_eq)

**Theorem 4.** The DP algorithm performs exactly *L · w² + w* arithmetic operations.

This is immediate from the algorithm structure: *L* layers × *w* sources × *w* targets + *w* for the final minimization.

### 4.5 Theorem 5: Asymptotic Separation (dp_beats_enumeration)

**Theorem 5.** For any fixed width *w*, there exists *N₀* such that for all *L ≥ N₀*:

$$L \cdot w^2 + w < 2^L$$

*Proof sketch.* The function *f(L) = (L · w² + w) / 2^L* tends to 0 as *L → ∞*, since the exponential denominator dominates the polynomial numerator. By the definition of limits, eventually *f(L) < 1*, which gives the desired inequality.

The formal proof uses the filter-based theory of limits, showing that *L/2^L → 0* and deriving the result for the polynomial numerator.

---

## 5. Applications

### 5.1 Shortest Path in Layered DAGs

A layered directed acyclic graph with *L* layers and *w* vertices per layer is a layered tropical circuit where *step(ℓ, s, t)* is the edge weight from vertex *s* in layer *ℓ* to vertex *t* in layer *ℓ+1*. Tropical Φ is the shortest path length. Our theorem recovers the classical shortest-path DP with the precise complexity *L · w² + w*.

**Worked example.** A 5-zone transportation network with 4 intersections per zone. Brute force: 4⁶ = 4,096 paths. DP: 5 × 16 + 4 = 84 operations. Speedup: 49×.

### 5.2 Viterbi Decoding

A hidden Markov model with *w* hidden states and *L* observations defines a layered tropical circuit where *step(ℓ, s, t) = -log P(transition s→t) - log P(observation ℓ+1 | state t)*. Tropical Φ is the negative log-likelihood of the most likely state sequence — the Viterbi path.

**Worked example.** An HMM with 3 states and 10 observations: DP uses 3 × 9 + 3 = 93 operations vs 3¹¹ = 177,147 brute-force evaluations.

### 5.3 Transfer Matrices in Statistical Mechanics

A 1D spin chain with *w* spin states per site and *L* sites has partition function dominated (at zero temperature) by the ground-state configuration. The ground-state energy is tropical Φ of the interaction circuit.

**Worked example.** A 20-site chain with 4 spin states: DP uses 20 × 16 + 4 = 324 operations vs 4²¹ ≈ 4.4 × 10¹² brute-force configurations. Speedup: > 10¹⁰.

### 5.4 Neural Network Analysis

A ReLU network with *w* neurons per layer and *L* layers defines a piecewise-linear function whose activation patterns correspond to trajectories through a tropical circuit. When the width is bounded, exact analysis of the network's tropical geometry (number of linear regions, robustness margins) becomes tractable.

---

## 6. Computational Experiments

### 6.1 Correctness Verification

We verify computePhiDP_correct computationally on random circuits:

| L  | w  | φ_bruteforce | φ_DP       | Match | BF ops    | DP ops |
|----|----|-------------|------------|-------|-----------|--------|
| 3  | 2  | 3.929196    | 3.929196   | ✓     | 16        | 14     |
| 4  | 3  | 3.875771    | 3.875771   | ✓     | 243       | 39     |
| 5  | 2  | 5.055633    | 5.055633   | ✓     | 64        | 22     |
| 6  | 2  | 7.539455    | 7.539455   | ✓     | 128       | 26     |

### 6.2 Timing Comparison (w = 3)

| L  | BF time (s) | DP time (s) | Speedup     |
|----|-------------|-------------|-------------|
| 3  | 0.00006     | 0.00001     | 5×          |
| 7  | 0.008       | 0.00003     | 290×        |
| 11 | 0.981       | 0.00004     | 22,742×     |
| 13 | 10.13       | 0.00005     | 200,460×    |

### 6.3 Crossover Points

| Width w | Crossover L₀ (DP < 2^L) |
|---------|-------------------------|
| 1       | 2                       |
| 2       | 5                       |
| 3       | 6                       |
| 5       | 8                       |
| 10      | 10                      |
| 50      | 16                      |

The crossover point grows logarithmically in *w*, confirming that the exponential separation is robust.

---

## 7. Discussion

### 7.1 The Width Parameter as Structural Invariant

Our main contribution is identifying width as the correct parameter controlling tropical computational complexity. This is analogous to treewidth in graph algorithms, bond dimension in tensor networks, and pathwidth in circuit complexity.

The width-bounded regime is not a degenerate special case. Many practical systems — neural networks with fixed architecture, finite-state machines, spin chains, HMMs — have bounded width. The theorem shows that their tropical invariants are tractable.

### 7.2 Connection to Tropical Matrix Algebra

The DP recurrence can be interpreted as iterated tropical (min-plus) matrix-vector multiplication. Define the tropical matrix *M_ℓ* by *(M_ℓ)_{s,t} = step(ℓ, s, t)*. Then the DP vector after processing layers *ℓ, ℓ+1, ..., L-1* is:

$$V = M_\ell \otimes M_{\ell+1} \otimes \cdots \otimes M_{L-1} \otimes \mathbf{0}$$

where ⊗ denotes tropical matrix multiplication and **0** is the zero vector. This connects our result to the rich theory of min-plus linear algebra, including tropical eigenvalues, tropical convexity, and the tropical semiring.

### 7.3 Limitations

1. **Fixed width.** The polynomial bound *L · w² + w* is polynomial in *L* for fixed *w*, but the constant depends quadratically on *w*. For *w* growing with *L*, the bound can become exponential.

2. **Layered structure.** The current theorem requires a strictly layered circuit. General directed graphs would require bounded treewidth decompositions.

3. **Arithmetic model.** The work bound counts arithmetic operations, not bit operations. For arbitrary real-valued costs, exact computation may require unbounded precision.

---

## 8. Future Work

1. **Bounded treewidth generalization.** Extend from layered (pathwidth) to bounded-treewidth circuits.

2. **Tropical matrix spectral theory.** Formalize the connection between tropical Φ and tropical eigenvalues of the circuit's transition matrices.

3. **Complexity dichotomy.** Prove that computing tropical Φ is NP-hard when width is unbounded, completing a parameterized complexity classification.

4. **Approximate tropical Φ.** Develop FPTAS-style approximation schemes for circuits of moderate width.

5. **Tropical information inequalities.** Establish data-processing and monotonicity inequalities for tropical functionals.

---

## References

1. Bellman, R. (1957). *Dynamic Programming*. Princeton University Press.
2. Simon, I. (1988). Recognizable sets with multiplicities in the tropical semiring. *MFCS*.
3. Viterbi, A. (1967). Error bounds for convolutional codes and an asymptotically optimum decoding algorithm. *IEEE Trans. Inform. Theory*.
4. Courcelle, B. (1990). The monadic second-order logic of graphs I. *Inform. Comput.*
5. Baxter, R. J. (1982). *Exactly Solved Models in Statistical Mechanics*. Academic Press.
6. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
7. Zhang, L., et al. (2018). Tropical geometry of deep neural networks. *ICML*.
