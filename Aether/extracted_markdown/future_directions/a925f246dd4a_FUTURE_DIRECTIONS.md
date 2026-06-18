# Future Research Directions

## Overview

This document charts concrete next steps building on the Algorithmic Certificate framework — a formally verified meta-theorem that unifies binary search, Dijkstra's algorithm, and the Number Theoretic Transform as instances of state machines with decreasing potentials. Each direction includes a precise theorem target, required definitions, proof strategies, and cross-domain connections.

---

## Direction 1: A* Search and Admissible Heuristics

### Theorem Target

```lean
theorem aStar_correct
    {V : Type} [Fintype V] [DecidableEq V]
    (w : V → V → WithTop ℕ) (h : V → ℕ) (src dst : V)
    (hadmissible : ∀ v, (h v : WithTop ℕ) ≤ shortestDist w src v)
    (hconsistent : ∀ u v, h u ≤ w u v + h v) :
    aStarDist w h src dst = shortestDist w src dst
```

### Required Definitions

- `AStarState V`: extends `DijkstraState V` with heuristic function
- `fScore : V → WithTop ℕ` where `f(v) = g(v) + h(v)`
- `aStarStep`: extract-min by f-score, relax neighbors
- Priority queue abstraction (or sorted list)

### Proof Strategies

1. **Extension of Dijkstra certificate**: Add heuristic to the state, prove that admissibility implies the settled-optimality invariant still holds. The key insight: if h is admissible, then extracting the minimum f-score vertex is equivalent to extracting the minimum g-score vertex among those that could be on an optimal path.

2. **Reduction to Dijkstra on modified weights**: Define w'(u,v) = w(u,v) - h(u) + h(v) (Johnson's technique). Show A* on (w, h) = Dijkstra on w'. Prove w' is nonneg from consistency.

### Cross-Domain Connection

A* with the entropy heuristic h(v) = remaining Shannon entropy connects to **information-directed search** in reinforcement learning and Bayesian optimization.

---

## Direction 2: Verified Fast Polynomial Multiplication

### Theorem Target

```lean
theorem ntt_polynomial_multiply_correct
    {R : Type} [CommRing R] [IsDomain R]
    (n : ℕ) (ω : R) (hω : IsPrimitiveRoot ω (2 * n))
    (a b : Fin n → R) :
    nttPolyMul ω a b = polyMul a b
```

where `nttPolyMul` uses forward NTT, pointwise multiply, inverse NTT, and `polyMul` is naive polynomial multiplication (not cyclic — linear convolution).

### Required Definitions

- `polyMul`: standard polynomial multiplication (degree n+m-2)
- `nttPolyMul`: pad to 2n, NTT, pointwise multiply, inverse NTT
- `invNTT`: inverse transform using ω⁻¹ and division by n
- Zero-padding and truncation operations

### Proof Strategies

1. **Direct from convolution theorem**: Pad inputs to length 2n with zeros. Cyclic convolution of zero-padded sequences equals linear convolution for the first n+m-1 terms. Apply the verified NTT convolution theorem, then the inverse NTT.

2. **Matrix factorization approach**: Express NTT as a Vandermonde matrix, prove the Vandermonde matrix is invertible when ω is primitive, and derive the inverse NTT. Then polynomial multiplication follows from the diagonal representation of circulant matrices.

### Cross-Domain Connection

This directly enables **verified lattice cryptography**: CRYSTALS-Kyber and CRYSTALS-Dilithium use NTT-based polynomial multiplication over Zq[X]/(X^n + 1). Proving multiplication correct is a prerequisite for verified post-quantum security.

---

## Direction 3: Information-Theoretic Lower Bounds

### Theorem Target

```lean
theorem comparison_search_lower_bound
    {n : ℕ} (hn : 1 < n)
    (A : ComparisonAlgorithm n) :
    A.worstCaseComparisons ≥ Nat.clog 2 n
```

### Required Definitions

- `ComparisonAlgorithm n`: a decision tree of depth d with n leaves
- `worstCaseComparisons`: maximum depth in the decision tree
- `clog 2 n`: ceiling of log₂(n) (already in Mathlib as `Nat.clog`)
- `DecisionTree`: binary tree modeling comparison-based algorithms

### Proof Strategies

1. **Counting argument**: A binary decision tree of depth d has at most 2^d leaves. To distinguish n elements, need 2^d ≥ n, hence d ≥ ⌈log₂ n⌉.

2. **Entropy argument**: Any comparison yields at most 1 bit of information. Identifying one of n equally likely elements requires log₂(n) bits. Use the verified `search_information_duality` theorem to bridge search depth and entropy.

### Cross-Domain Connection

This would establish the **information-theoretic optimality of binary search**: the upper bound (from `binarySearch_steps_pow2`) matches the lower bound, proving that binary search is optimal among comparison-based algorithms. This extends to sorting lower bounds (Ω(n log n)) via the same entropy argument.

---

## Direction 4: Tropical Shortest-Path Closure

### Theorem Target

```lean
theorem shortestPath_eq_tropicalClosure
    {n : ℕ}
    (W : Matrix (Fin n) (Fin n) (WithTop ℕ)) :
    shortestPathMatrix W = tropicalKleeneStar W
```

where `tropicalKleeneStar W = I ⊕ W ⊕ W² ⊕ ... ⊕ W^(n-1)` in the tropical semiring (min, +).

### Required Definitions

- `TropicalSemiring`: `(WithTop ℕ, min, +, ⊤, 0)` — formalize as a semiring
- `tropicalMatMul`: matrix multiplication in the tropical semiring
- `tropicalPow`: matrix power in the tropical semiring
- `tropicalKleeneStar`: `⨁_{k=0}^{n-1} W^k`
- `shortestPathMatrix W i j`: shortest path distance from i to j

### Proof Strategies

1. **Direct induction on path length**: W^k[i,j] gives the shortest path from i to j using at most k edges. Since shortest simple paths have at most n-1 edges, the Kleene star stabilizes at W^(n-1).

2. **Floyd-Warshall as tropical Gaussian elimination**: Formalize Floyd-Warshall as Gaussian elimination in the tropical semiring. The correctness of Gaussian elimination in semirings gives the Kleene star formula.

### Cross-Domain Connection

This bridges **algorithm verification** and **tropical geometry**. Tropical Kleene stars appear in:
- Dynamic programming (all semiring shortest paths)
- Regular expression matching (path algebras)
- Algebraic graph theory
- Economic equilibrium (min-cost flow as tropical linear programming)

---

## Direction 5: Amortized Analysis via Potential Functions

### Theorem Target

```lean
theorem amortized_complexity_bound
    {State Spec : Type*}
    (A : AmortizedCertificate State Spec)
    (init : State)
    (hInv : A.invariant init)
    (hAmort : ∀ s, A.invariant s → ¬A.terminal s →
        A.actualCost s + A.potential (A.step s) ≤ A.amortizedBound + A.potential s) :
    ∀ T, totalCost A init T ≤ T * A.amortizedBound + A.potential init
```

### Required Definitions

- `AmortizedCertificate`: extends AlgorithmicCertificate with `actualCost` and `amortizedBound`
- `totalCost`: sum of actual costs over T steps
- Instances: dynamic array (amortized O(1) insert), splay tree (amortized O(log n))

### Proof Strategies

1. **Telescoping sum**: The amortized inequality telescopes: Σ actualCost(i) = Σ (amortizedBound - Δpotential(i)) = T·amortizedBound - (potential(final) - potential(init)) ≤ T·amortizedBound + potential(init).

2. **Reduction to base framework**: Show that the amortized certificate with potential Φ and bound B can be converted to a standard AlgorithmicCertificate with potential = B·T_remaining + Φ, giving the same termination and correctness guarantees.

### Cross-Domain Connection

Amortized analysis via potentials connects to **thermodynamic computing**: the potential function is analogous to free energy, actual cost to work, and the amortized bound to the equilibrium cost. Landauer's principle (energy cost of erasing a bit) is a physical instance of amortized analysis.

---

## Implementation Roadmap

### Phase 1 (Immediate, 1-2 weeks)
- Direction 3: Comparison lower bounds (direct counting argument, minimal new infrastructure)
- Direction 5: Amortized analysis (extends existing framework naturally)

### Phase 2 (Short-term, 2-4 weeks)
- Direction 2: Verified polynomial multiplication (builds on existing NTT)
- Direction 4: Tropical closure (builds on existing catalog `tropical_and_bound`)

### Phase 3 (Medium-term, 1-2 months)
- Direction 1: A* search (requires priority queue formalization)
- Integration with Mathlib's graph theory library for production-quality Dijkstra

### Phase 4 (Long-term, 3-6 months)
- General semiring dynamic programming framework
- Verified matroid optimization (greedy algorithms)
- Connection to verified cryptographic implementations

---

## Research Team Directive

Each direction should be pursued by a sub-team following this workflow:

1. **Hypothesis formation**: State the target theorem precisely in Lean
2. **Skeleton construction**: Write definitions and `sorry`-d helper lemmas
3. **Validation**: Test with `#eval` and computational experiments
4. **Proof construction**: Prove helpers bottom-up, then main theorem
5. **Integration**: Instantiate the AlgorithmicCertificate framework
6. **Documentation**: Write docstrings and add to the research paper

Cross-domain connections should be validated by constructing explicit bridges (morphisms, embeddings, or reductions) rather than relying on informal analogy.
