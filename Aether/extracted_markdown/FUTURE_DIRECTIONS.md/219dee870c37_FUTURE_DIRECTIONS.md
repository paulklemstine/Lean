# Future Directions: Tropical Cycle-Mean Rigidity and Beyond

## Overview

The Tropical Cycle-Mean Rigidity Theorem (`AllCycleMeansEqual ⟺ CohomologousToConst`) opens five concrete research programs, each building on the formalized foundation. These are ordered from most immediately actionable to most speculative.

---

## Direction 1: Tropical Spectral Gap via Cycle-Mean Dispersion

### Hypothesis
The *cycle-mean dispersion* δ(A) = max(cycleMean) − min(cycleMean) controls the minimal width of tropical eigenvectors, providing a quantitative spectral gap theory.

### Precise Conjecture

```
theorem tropical_spectral_gap
  (A : Fin n → Fin n → ℝ) (hn : 0 < n)
  (hirr : StronglyConnected (supportGraph A)) :
  ∀ x λ, TropEigenpair A λ x →
    vecWidth x ≥ C(n) * cycleMeanDispersion A
```

where C(n) is an explicit constant depending on the matrix dimension.

### Proof Strategy
1. Define `cycleMeanDispersion A = max cycleMean − min cycleMean` over all elementary cycles.
2. Show that if dispersion > 0, no width-zero eigenvector exists (by the contrapositive of the rigidity theorem applied to perturbation analysis).
3. Quantify the lower bound using the Collatz–Wielandt variational principle: the min-max characterization of the eigenvalue constrains eigenvector coordinates through cycle inequalities.
4. The key step is showing that a cycle with non-maximal mean forces at least one eigenvector coordinate to deviate from the average by an amount proportional to the mean deficit.

### Cross-Domain Impact
- **Optimization:** The spectral gap controls convergence rates of tropical power iteration.
- **Scheduling:** Quantifies how far a production system is from perfect synchronization.
- **Control theory:** Provides stability margins for max-plus linear systems.

### Estimated Complexity
Medium. The bound likely follows from existing Collatz–Wielandt machinery combined with careful combinatorial estimates. Formalization builds directly on the current infrastructure.

---

## Direction 2: Mean-Payoff Game Degeneracy Characterization

### Hypothesis
The coboundary condition provides a polynomial-time certificate for mean-payoff game degeneracy, where all strategies yield the same asymptotic payoff.

### Precise Target

```
theorem mean_payoff_game_degenerate_iff
  (G : WeightedDigraph) (hsc : StronglyConnected G) :
  (∀ σ τ : Strategy, meanPayoff G σ τ = val(G)) ↔
  AllCycleMeansEqual (adjacencyMatrix G)
```

### Proof Strategy
1. Formalize mean-payoff games with positional strategies.
2. Show the value equals the max cycle mean (Ehrenfeucht–Mycielski, 1979).
3. Degeneracy (all strategies equal) ⟺ max cycle mean = min cycle mean ⟺ AllCycleMeansEqual.
4. Use the coboundary form to construct explicit optimal strategies: p provides the bias function.

### Implementation
- Formalize `WeightedDigraph`, `Strategy`, `meanPayoff` in Lean.
- Connect to the Collatz–Wielandt theorem already in the project.
- Prove the equivalence using the rigidity theorem.

### Applications
- **Verification of game solvers:** The coboundary test provides an O(n²) certificate for degeneracy.
- **Algorithm design:** The potential recovery algorithm gives optimal strategies directly.

### Estimated Complexity
Medium-High. Requires game-theoretic infrastructure but the core algebraic argument is in place.

---

## Direction 3: Sparse Support Graph Extension

### Hypothesis
The rigidity theorem extends to sparse matrices (with −∞ entries) when restricted to cycles in the support graph.

### Precise Target

```
theorem sparse_rigidity
  (A : Fin n → Fin n → WithBot ℝ) (hn : 0 < n)
  (hirr : StronglyConnected (supportGraph A)) :
  AllCycleMeansEqualOnSupport A ↔ CohomologousToConstOnSupport A
```

### Proof Strategy
1. Define `supportGraph A` as the digraph where edge (i,j) exists iff A(i,j) ≠ ⊥.
2. Restrict cycle and coboundary conditions to edges in the support graph.
3. The telescoping direction (⟸) is identical.
4. The converse (⟹) requires strong connectivity: fix a base vertex, define potential via shortest paths in the support graph, and use the cycle condition for path independence.
5. The key difference from the dense case: the cocycle argument uses paths in G rather than arbitrary 3-cycles, requiring a spanning tree argument.

### Additional Results
- Show that the eigenvector from the coboundary form is unique up to additive constant when the critical graph equals the support graph.
- Prove projectivity: the width of the eigenvector equals the diameter of the potential function on the support graph.

### Estimated Complexity
Medium. The mathematical argument is straightforward; the formalization requires graph infrastructure (walks, paths, spanning trees in directed graphs).

---

## Direction 4: Discrete Hodge Decomposition for Weighted Digraphs

### Hypothesis
Every weight matrix A can be uniquely decomposed into exact (coboundary), co-exact, and harmonic components, with the coboundary component determined by cycle means.

### Precise Target

```
theorem tropical_hodge_decomposition
  (A : Fin n → Fin n → ℝ) (hn : 0 < n) :
  ∃! (A_exact A_harm : Fin n → Fin n → ℝ),
    A = A_exact + A_harm ∧
    CohomologousToConst A_exact ∧
    MinimalCycleDeviation A_harm
```

### Proof Strategy
1. Define the space of 1-cochains on Kₙ (the complete directed graph) as Fin n → Fin n → ℝ.
2. Define the coboundary operator δ : (Fin n → ℝ) → (Fin n → Fin n → ℝ) by (δp)(i,j) = p(i) − p(j).
3. Show im(δ) is a subspace; define the orthogonal complement as the "harmonic" space.
4. The Hodge decomposition is the orthogonal projection onto im(δ).
5. The cycle-mean rigidity theorem guarantees A is in im(δ) iff AllCycleMeansEqual.

### Formalization Plan
- Build a Lean library for finite-dimensional cochains on digraphs.
- Define the coboundary operator and prove it is linear.
- Construct the orthogonal decomposition using Finset sums over inner products.
- Prove the uniqueness of the decomposition.

### Applications
- **Network analysis:** The harmonic component measures intrinsic "curvature" or asymmetry.
- **Machine learning:** Hodge decomposition of pairwise comparison matrices (ranking).
- **Physics:** Discrete gauge field theory on finite graphs.

### Estimated Complexity
High. Requires linear algebra infrastructure and careful formalization of orthogonal projections in finite dimensions.

---

## Direction 5: Tropical Zeta Function and Spectral Collapse

### Hypothesis
A tropical analogue of the Ihara zeta function, weighted by cycle-mean deviations, exhibits a collapse (pole coalescence) precisely when AllCycleMeansEqual.

### Precise Target

Define the tropical zeta function:
```
Z_A(s) = Π_{[c] primitive} (1 − e^{(cycleMean(A,c) − λ*) · |c| · s})^{-1}
```
where the product is over conjugacy classes of primitive cycles, λ* is the max cycle mean, and |c| is the cycle length.

**Conjecture:**
```
Z_A has a single pole at s = 0 ⟺ AllCycleMeansEqual(A)
```

### Proof Strategy
1. When AllCycleMeansEqual, all factors have cycleMean = λ*, so all exponents are zero, and Z_A(s) = Π(1 − 1)^{-1} — the product diverges uniformly, giving a single pole.
2. When cycle means differ, the factors decay at different rates, producing poles at distinct locations.
3. The rigorous formulation requires careful treatment of the infinite product (or restriction to primitive cycles up to length n, giving a finite product).

### Connections
- **Number theory:** The Ihara zeta function of a graph is the analogue of the Riemann zeta function. The tropical version replaces multiplicative weights with additive (max-plus) weights.
- **Dynamical systems:** The zeta function encodes periodic orbit statistics. Spectral collapse corresponds to all orbits having the same Lyapunov exponent.
- **Statistical mechanics:** The partition function interpretation connects to tropical free energy.

### Estimated Complexity
Very High. Requires formal analysis of infinite products, convergence, and pole structure. Best approached as a long-term program.

---

## Research Infrastructure Recommendations

### Lean Libraries to Build
1. **Directed graph walks and cycles** (List-based, with strong connectivity).
2. **Discrete cochains and coboundary operators** (for Hodge decomposition).
3. **Max-plus matrix powers and convergence** (for projective dynamics).
4. **Mean-payoff game formalization** (strategies, payoffs, values).

### Computational Tools to Develop
1. **Coboundary residual visualizer:** Interactive tool showing how perturbations break cycle-mean equality.
2. **Tropical eigenvector animator:** Visualize tropical power iteration converging to the eigenvector.
3. **Cycle-mean explorer:** Enumerate cycles and display their means, highlighting critical cycles.

### Cross-Domain Collaborations
1. **Optimization/OR:** Apply to real scheduling datasets.
2. **Game theory:** Connect to algorithmic mean-payoff game solvers.
3. **Algebraic geometry:** Relate to tropical curves and divisors.
4. **Music information retrieval:** Apply voice-leading analysis to real musical scores.

---

## Priority Ranking

| Direction | Impact | Feasibility | Priority |
|-----------|--------|-------------|----------|
| 1. Spectral Gap | High | Medium | ★★★★★ |
| 3. Sparse Extension | High | Medium | ★★★★★ |
| 2. Mean-Payoff Games | High | Medium-High | ★★★★ |
| 4. Hodge Decomposition | Very High | High | ★★★ |
| 5. Tropical Zeta | Revolutionary | Very High | ★★ |

Direction 1 and 3 should be pursued immediately as they build most directly on the current formalization. Direction 2 has high application value. Directions 4 and 5 are longer-term but potentially transformative.
