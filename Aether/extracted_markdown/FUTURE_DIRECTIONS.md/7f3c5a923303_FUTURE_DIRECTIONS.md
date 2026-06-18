# Future Directions: Tropical Spectral Rigidity

## Overview

The Tropical Cycle-Mean Rigidity Theorem establishes the foundational equivalence between cycle-mean equality and coboundary decomposition. This opens at least five major research directions, each with specific theorem targets, proof strategies, and cross-domain applications.

---

## Direction 1: Tropical Spectral Gap Theorem

### Goal
Prove a quantitative bound linking **cycle-mean dispersion** (the spread of cycle means) to the **minimum width** of tropical eigenvectors.

### Precise Conjecture

**Definition:** The *cycle-mean dispersion* of A is:

δ(A) = max{cycleMean(A, c)} − min{cycleMean(A, c)}

over all directed cycles c.

**Definition:** The *minimum eigenvector width* is:

w*(A) = inf{width(x) : ∃λ, TropEigenpair(A, λ, x)}

**Conjecture:** For an irreducible n×n matrix A:

w*(A) ≤ (n − 1) · δ(A)

And there exist matrices achieving equality.

### Proof Strategy
1. Normalize so the max cycle mean is 0 (subtract the tropical eigenvalue).
2. Use the potential construction p(i) = max-weight path from a base vertex.
3. Bound width(p) by (n−1) times the maximum cycle-mean deviation.
4. The bound should follow from telescoping path-weight estimates.

### Cross-Domain Impact
- **Control theory:** Quantitative synchronization guarantees for discrete event systems.
- **Game theory:** Bounds on the advantage of optimal vs. suboptimal strategies in mean-payoff games.
- **Machine learning:** Robustness certificates for tropical neural network representations.

### Formalization Target
```
theorem tropical_spectral_gap (A : Fin n → Fin n → ℝ)
  (hn : 0 < n) (hirr : StronglyConnected A) :
  minEigenvectorWidth A ≤ (n - 1) * cycleMeanDispersion A
```

---

## Direction 2: Projective Dynamics Convergence

### Goal
Prove that the **normalized tropical power iteration** converges to a unique projective fixed point if and only if the cycle means are equal.

### Setup
Define the normalized iteration:

x_{k+1} = A ⊙ x_k − (max_i (A ⊙ x_k)_i) · **1**

This projects the tropical matrix action onto the hyperplane {x : max x = 0}.

### Precise Conjecture

**Theorem Target:** For an irreducible A:

(x_k converges for all initial x_0) ↔ AllCycleMeansEqual(A)

### Proof Strategy
1. **Forward (← direction):** Under the coboundary condition, the unique projective eigenvector p attracts all orbits. Use the contraction mapping principle in the Hilbert projective metric.
2. **Backward (→ direction):** If cycle means differ, exhibit two initial vectors that converge to different limit cycles, preventing convergence.

### Cross-Domain Impact
- **Dynamical systems:** Complete characterization of mode-locking in tropical dynamics.
- **Consensus algorithms:** Conditions for distributed agreement in max-plus networks.
- **Scheduling:** Steady-state behavior of periodic production systems.

### Formalization Target
```
theorem trop_power_iteration_converges_iff (A : Fin n → Fin n → ℝ)
  (hirr : StronglyConnected A) :
  ConvergesProjectively (tropPowerIteration A) ↔ AllCycleMeansEqual A
```

---

## Direction 3: Graph Cohomology Library for Finite Digraphs

### Goal
Build a reusable Lean 4 library for **discrete cohomology on finite directed graphs**, applicable far beyond tropical algebra.

### Components to Formalize

1. **Cochain complex:** Define the space of k-cochains on a finite digraph (vertex functions, edge functions, face functions).
2. **Coboundary operator:** δ₀ : C⁰ → C¹ maps vertex functions to edge functions via (δ₀f)(i→j) = f(j) − f(i).
3. **Exactness:** Prove ker(δ₁) = im(δ₀) for connected graphs (first cohomology vanishes).
4. **Integration:** Define the integral of a 1-cochain around a cycle and prove it equals zero iff the cochain is exact.

### Connection to This Work
The cycle-mean rigidity theorem becomes: "The reduced edge-weight 1-cochain A(i,j) − μ is exact iff it integrates to zero around every cycle."

### Cross-Domain Impact
- **Algebraic topology:** Concrete computational entry point to cohomology.
- **Electrical networks:** Kirchhoff's voltage law as cohomological exactness.
- **Persistent homology:** Bridge to topological data analysis.

### Formalization Target
```
theorem first_cohomology_vanishes (G : FinDigraph)
  (hconn : StronglyConnected G) (f : Edge G → ℝ) :
  (∀ c : Cycle G, cycleIntegral f c = 0) ↔ ∃ p : Vertex G → ℝ, f = coboundary p
```

---

## Direction 4: Sparse Matrix Extension

### Goal
Extend all results to matrices with **−∞ entries** (edges absent from the support graph).

### Challenges
1. The current formalization works over ℝ (all edges present). With −∞ entries, one must work with `WithBot ℝ` or `EReal`, introducing coercion complexities.
2. The coboundary decomposition must be restricted to the support graph.
3. Cycle means only involve edges present in the support graph.
4. Irreducibility (strong connectivity of the support graph) becomes essential.

### Precise Target
```
theorem cycle_mean_rigidity_sparse (A : Fin n → Fin n → WithBot ℝ)
  (hirr : StronglyConnected (supportGraph A)) :
  AllCycleMeansEqual A ↔ CohomologousToConstOnSupport A
```

### Proof Strategy
1. Define `supportGraph A` as the digraph of edges where A(i,j) ≠ −∞.
2. Restrict cycles and cycle means to the support graph.
3. The coboundary construction works the same way on the support graph (using paths instead of arbitrary pairs).
4. Strong connectivity ensures path existence for the potential construction.

### Cross-Domain Impact
- **Network optimization:** Real networks are sparse; the full-matrix theory is insufficient.
- **Mean-payoff games:** Games are played on sparse graphs.
- **Tropical geometry:** The natural setting for tropical varieties involves sparse polynomials.

---

## Direction 5: Tropical Zeta Functions

### Goal
Define a **tropical zeta function** encoding cycle-mean data and prove its behavior collapses in the spectrally flat regime.

### Definition

For a matrix A with maximum cycle mean λ*, define:

Z_A(s) = ∑_{c : Cycle(A)} exp(−s · |c| · (λ* − cycleMean(A, c)))

where |c| is the length of cycle c. This is a formal Dirichlet-style series weighted by the deviation of each cycle mean from the maximum.

### Key Properties

1. When AllCycleMeansEqual(A), every term has exponent 0, so Z_A(s) counts cycles: Z_A(s) = #{cycles}, independent of s.
2. When cycle means vary, Z_A(s) → #{critical cycles} as s → ∞ (only max-mean cycles survive).
3. The "spectral gap" δ = λ* − second-largest cycle mean controls the rate of convergence.

### Precise Target
```
theorem tropical_zeta_collapse (A : Fin n → Fin n → ℝ) :
  AllCycleMeansEqual A ↔ ∀ s, tropicalZeta A s = tropicalZeta A 0
```

### Cross-Domain Impact
- **Number theory:** Echoes of the connection between prime cycles and the Riemann zeta function (via the Ihara zeta function for graphs).
- **Dynamical systems:** Ruelle zeta functions for symbolic dynamics.
- **Statistical mechanics:** Partition functions in tropical thermodynamics.

### Speculative Extension
Define a **tropical L-function** by weighting cycles with characters of the fundamental group. The equal-cycle-mean condition becomes analogous to the "trivial zeros" of the L-function. This is highly speculative but could provide a new angle on spectral phenomena in number theory.

---

## Priority Ordering

| Direction | Difficulty | Impact | Dependencies |
|---|---|---|---|
| 1. Spectral Gap | Medium | High | Current work |
| 4. Sparse Extension | Medium | High | Current work |
| 2. Projective Dynamics | Hard | Very High | Direction 1 |
| 3. Graph Cohomology | Medium | Medium (infrastructure) | None |
| 5. Tropical Zeta | Hard | Speculative/Very High | Directions 1, 4 |

**Recommended first step:** Direction 1 (Spectral Gap) is the most natural continuation and the most likely to yield a publishable result quickly. It directly quantifies the qualitative rigidity theorem.

**Recommended second step:** Direction 4 (Sparse Extension) unlocks real-world applicability.

---

## Team Organization

Each direction benefits from a different skill mix:

- **Directions 1, 4:** Classical combinatorial optimization + Lean formalization
- **Direction 2:** Dynamical systems + metric geometry + Lean
- **Direction 3:** Algebraic topology + library design + Lean
- **Direction 5:** Number theory + analysis + Lean (research phase)

Cross-team synergies: Directions 1 and 2 share the spectral gap machinery. Directions 3 and 4 share the graph infrastructure. Direction 5 builds on all others.

---

## Timeline Estimate

- **Month 1-2:** Direction 1 (spectral gap) + Direction 3 (cohomology infrastructure)
- **Month 2-4:** Direction 4 (sparse extension) using Direction 3 infrastructure
- **Month 4-6:** Direction 2 (dynamics convergence)
- **Month 6-12:** Direction 5 (zeta functions, exploratory)

This timeline assumes a team of 2-3 researchers with Lean expertise.
