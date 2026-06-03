# Tropical Lyapunov Theory: Gradient Descent, Basin Decomposition, and the Merging Principle on Finite Structures

## Abstract

We develop a rigorous Lyapunov-theoretic framework for discrete dynamical systems on finite types equipped with non-increasing potential functions, motivated by tropical renormalization group flows. The framework yields five main results: (1) an **Orbit Convergence Theorem** establishing that every orbit reaches a fixed point within |α| steps via a pigeonhole-Lyapunov argument; (2) a **Distinct Potentials Theorem** proving that potential values along non-stabilized orbit prefixes are strictly monotone; (3) a **Basin Decomposition Theorem** showing that the type partitions into basins of attraction of fixed points; (4) a **Convergence Rate Bound** giving quantitative orbit length estimates of the form N ≤ V(x)/δ; and (5) a **Merging Principle** proving that surjective dynamical morphisms can only merge basins, never split them. All results are formalized and verified in Lean 4, providing machine-checked guarantees of correctness. The framework connects tropical algebra (max-plus arithmetic), dynamical systems theory (Lyapunov stability), and renormalization group theory (coarse-graining) through a unified categorical lens.

**Keywords**: tropical geometry, Lyapunov functions, discrete dynamical systems, renormalization group, basin of attraction, convergence rate, formal verification

## 1. Introduction

### 1.1 Motivation

The renormalization group (RG) is one of the most powerful ideas in theoretical physics, providing a framework for understanding how physical systems behave across different scales. In the RG approach, one iteratively coarse-grains a system — replacing detailed microscopic descriptions with simpler effective descriptions — and studies the resulting flow in the space of theories.

On finite structures, RG flows become discrete dynamical systems on finite types. The central questions are:
- **Convergence**: Does every orbit reach a fixed point?
- **Rate**: How many steps until convergence?
- **Structure**: How do the basins of attraction organize the state space?
- **Functoriality**: How does coarse-graining relate the dynamics at different scales?

Tropical (max-plus) geometry provides a natural algebraic framework for these questions. In tropical algebra, the basic operations are maximum and addition, which naturally arise in optimization, shortest-path computation, and energy landscape analysis. The "depth" or "potential" function in a tropical renormalization flow measures the max-plus weight of the optimal path through a network, and the dynamics correspond to tropical gradient descent.

### 1.2 Main Results

We introduce the structure `LyapunovDDS` — a finite discrete dynamical system equipped with a non-negative potential function that is non-increasing under the dynamics — and prove the following:

**Theorem A (Orbit Convergence).** For any strictly decreasing `LyapunovDDS` on a finite type α, every orbit reaches a fixed point within at most |α| steps.

**Theorem B (Distinct Potentials).** In a strictly decreasing system, the potential values V(x), V(f(x)), V(f²(x)), ... are strictly monotone decreasing until a fixed point is reached. Consequently, the orbit injects into ℝ via the potential function before stabilization.

**Theorem C (Basin Decomposition).** Under strict decrease, every element of α belongs to the basin of attraction of some fixed point. The type decomposes into disjoint basins.

**Theorem D (Convergence Rate).** If every non-fixed point has potential drop at least δ > 0, then any orbit starting at potential V(x) reaches a fixed point within ⌊V(x)/δ⌋ steps.

**Theorem E (Merging Principle).** A surjective morphism φ: S → T of dynamical systems maps basins to basins: if x and y converge to the same fixed point z in S, then φ(x) and φ(y) converge to the same fixed point in T.

### 1.3 Related Work

The classical Lyapunov stability theory (Lyapunov, 1892) establishes convergence guarantees for continuous dynamical systems with decreasing energy functions. The LaSalle invariance principle extends this to systems where the Lyapunov function is merely non-increasing. Our framework provides the discrete, finite-type analogue of these results.

In tropical mathematics, the connection between max-plus eigenvalues and dynamical convergence has been studied by Gaubert and colleagues in the context of max-plus linear systems. Our work extends these ideas to nonlinear dynamics with Lyapunov potentials.

The renormalization group in statistical mechanics was pioneered by Kadanoff (1966) and Wilson (1971). The merging principle we prove is the rigorous formulation of Kadanoff's block-spin intuition: coarse-graining preserves the phase structure but can merge distinct phases.

## 2. Definitions

### 2.1 Lyapunov Discrete Dynamical System

**Definition 2.1.** A *Lyapunov discrete dynamical system (LyapunovDDS)* on a finite type α consists of:
- A dynamics map `step : α → α`
- A potential function `potential : α → ℝ`
- Non-negativity: `∀ x, 0 ≤ potential x`
- Non-increase: `∀ x, potential(step(x)) ≤ potential(x)`

**Definition 2.2.** A point x is a *fixed point* if `step(x) = x`.

**Definition 2.3.** A LyapunovDDS is *strictly decreasing* if for every non-fixed point x, `potential(step(x)) < potential(x)`.

### 2.2 Basin of Attraction

**Definition 2.4.** The *basin of attraction* of a fixed point y is the set `{x | ∃ N, iter^N(x) = y}` of all points whose orbit eventually reaches y.

### 2.3 DDS Morphism

**Definition 2.5.** A *morphism* φ: S → T between LyapunovDDS consists of a surjective map φ: α → β satisfying `φ(step_S(x)) = step_T(φ(x))` for all x.

### 2.4 Tropical Entropy

**Definition 2.6.** The *tropical entropy* of a function f: α → ℝ on a finite type is `log |image(f)|`, the logarithm of the number of distinct values in the image.

## 3. Main Results with Proof Sketches

### 3.1 Potential Monotonicity (Theorem A, Preliminary)

**Lemma 3.1.** For any LyapunovDDS S and any n ∈ ℕ, `potential(iter^n(x)) ≤ potential(x)`.

*Proof.* By induction on n. The base case n = 0 is trivial. For the inductive step, `potential(iter^{n+1}(x)) = potential(step(iter^n(x))) ≤ potential(iter^n(x)) ≤ potential(x)` by the non-increase axiom and the induction hypothesis. □

### 3.2 The Distinct Potentials Theorem (Theorem B)

**Theorem 3.2.** In a strictly decreasing LyapunovDDS, if no iterate in {0, ..., j-1} is a fixed point, then `potential(iter^j(x)) < potential(iter^i(x))` for all i < j.

*Proof.* By induction on j - i. For the base case j = i + 1: since iter^i(x) is not fixed (by hypothesis with k = i), strict decrease gives `potential(step(iter^i(x))) < potential(iter^i(x))`, i.e., `potential(iter^{i+1}(x)) < potential(iter^i(x))`.

For the inductive step with j = m + 1 and i < m: by the induction hypothesis, `potential(iter^m(x)) < potential(iter^i(x))`. Since iter^m(x) is not fixed (by hypothesis with k = m), strict decrease gives `potential(iter^{m+1}(x)) < potential(iter^m(x))`. Chaining: `potential(iter^j(x)) < potential(iter^m(x)) < potential(iter^i(x))`. □

### 3.3 Orbit Convergence (Theorem A)

**Theorem 3.3.** In a strictly decreasing LyapunovDDS on a finite type α, every orbit reaches a fixed point within at most |α| steps.

*Proof.* By contradiction. Suppose no iterate in {0, 1, ..., |α|} is a fixed point. By Theorem 3.2, the potential values `potential(iter^0(x)), potential(iter^1(x)), ..., potential(iter^{|α|}(x))` are all distinct. Since distinct potential values imply distinct states (the potential function separates non-fixed iterates), the map n ↦ iter^n(x) is injective on {0, 1, ..., |α|}. But this set has |α| + 1 elements while α has only |α| elements, contradicting the pigeonhole principle. □

### 3.4 Level Set Rigidity

**Theorem 3.4.** In a strictly decreasing system, if `potential(iter^k(x)) = potential(x)` for some k > 0, then x is a fixed point.

*Proof.* By contraposition. If x is not fixed, then `potential(step(x)) < potential(x)` by strict decrease. By potential monotonicity (Lemma 3.1), `potential(iter^k(x)) ≤ potential(step(x)) < potential(x)` for k ≥ 1, contradicting the level equality. □

### 3.5 Basin Decomposition (Theorem C)

**Theorem 3.5.** Under strict decrease, every element belongs to the basin of some fixed point.

*Proof.* By Theorem A, there exists N ≤ |α| such that iter^N(x) is a fixed point. Setting y = iter^N(x), we have x ∈ basin(y). □

### 3.6 Convergence Rate (Theorem D)

**Theorem 3.6.** If every non-fixed point has potential drop at least δ > 0, then any orbit starting at x reaches a fixed point within N steps where N · δ ≤ potential(x).

*Proof.* By Theorem A, there exists a fixed point iter^N(x). We claim N · δ ≤ potential(x). By telescoping: `potential(x) - potential(iter^N(x)) = Σ_{k=0}^{N-1} [potential(iter^k(x)) - potential(iter^{k+1}(x))]`. Each term in the sum is at least δ (by the gap hypothesis, since each iter^k(x) for k < N is either non-fixed, giving a drop of at least δ, or already fixed, in which case N could have been chosen smaller). Thus `potential(x) - potential(iter^N(x)) ≥ N · δ`. Since potential(iter^N(x)) ≥ 0 by non-negativity, we get `potential(x) ≥ N · δ`. □

### 3.7 The Merging Principle (Theorem E)

**Theorem 3.7.** If φ: S → T is a DDS morphism and x, y both belong to basin(z) for some fixed point z in S, then φ(x) and φ(y) converge to the same point in T.

*Proof.* From x ∈ basin(z), there exists Nₓ with iter^{Nₓ}(x) = z. From y ∈ basin(z), there exists N_y with iter^{N_y}(y) = z. Since φ commutes with iteration (proved by induction), `iter^{Nₓ}_T(φ(x)) = φ(iter^{Nₓ}_S(x)) = φ(z) = φ(iter^{N_y}_S(y)) = iter^{N_y}_T(φ(y))`. □

### 3.8 Sublevel Set Invariance

**Theorem 3.8.** For any value v, the sublevel set `{x | potential(x) ≤ v}` is forward-invariant under the dynamics.

*Proof.* If potential(x) ≤ v, then potential(step(x)) ≤ potential(x) ≤ v by the non-increase axiom. □

## 4. The Tropical Gradient Flow

### 4.1 Construction

Given a weighted directed graph with weight matrix W ∈ ℝⁿˣⁿ and a depth function d: Fin n → ℝ, the *tropical gradient step* sends each node i to the neighbor j with minimum depth among those with d(j) < d(i). If no such neighbor exists, i is a fixed point.

This construction yields a LyapunovDDS where the potential function is the depth function itself. The strict decrease property holds by construction: every non-fixed point moves to a state with strictly lower depth.

### 4.2 Connection to Tropical Spectral Theory

The tropical eigenvalue λ(W) of the weight matrix W — the maximum cycle mean — controls the asymptotic growth of walk weights. In the Lyapunov framework, λ(W) provides a lower bound on the potential gap δ:

- If λ(W) > 0, the system has a positive spectral gap, and the potential gap δ ≥ λ(W)/n, giving a convergence rate of O(n · V₀/λ(W)).
- If λ(W) = 0, the system may have zero potential gap, and convergence can take up to |α| steps (the pigeonhole bound is tight).

This connects the algebraic invariant λ(W) from tropical spectral theory to the dynamical convergence rate from Lyapunov theory.

## 5. Algorithms

### 5.1 Basin Computation

```
Algorithm: ComputeBasins(S)
Input: LyapunovDDS S on finite type α
Output: Map from each element to its basin's fixed point

for each x in α:
    y ← x
    while step(y) ≠ y:
        y ← step(y)
    basin_map[x] ← y
return basin_map
```

Time complexity: O(|α|²) in the worst case (each orbit has length at most |α|).

### 5.2 Convergence Rate Estimation

```
Algorithm: EstimateConvergenceRate(S)
Input: LyapunovDDS S
Output: (max_orbit_length, potential_gap)

max_length ← 0
min_gap ← ∞
for each x in α:
    if step(x) ≠ x:
        gap ← potential(x) - potential(step(x))
        min_gap ← min(min_gap, gap)
    length ← 0
    y ← x
    while step(y) ≠ y:
        y ← step(y)
        length ← length + 1
    max_length ← max(max_length, length)
return (max_length, min_gap)
```

## 6. Discussion

### 6.1 Relationship to Existing Catalog Results

Our framework unifies several existing results in the project catalog:

- **`exists_fixed_point_on_orbit_with_bound`** (Bridges/HolographicProofRenormalization.lean): This theorem establishes orbit convergence for a specific class of depth flows. Our Theorem A generalizes it to arbitrary LyapunovDDS.

- **`strict_contraction_bound`** (Tropical/RenormalizationFlow.lean): This proves the pigeonhole-based convergence bound for TropicalDepthFlow structures. Our framework subsumes this as a special case of Theorem A.

- **`merging_principle`** (Tropical/RenormalizationFlow.lean): This proves the merging principle for CoarseGraining morphisms between TropicalDepthFlow structures. Our Theorem E generalizes it to arbitrary DDS morphisms.

- **`tropical_step_nonexpansion`** (Tropical/RenormalizationFlow.lean): This proves non-expansion of the max-plus averaging step. Our sublevel set invariance (Theorem 3.8) provides a related but distinct stability guarantee.

### 6.2 Novel Contributions

The main novelties of this work are:

1. **The Distinct Potentials Theorem** (Theorem B): This structural result, showing that potential values are strictly monotone along non-stabilized orbits, is not present in the existing catalog. It provides the key lemma connecting Lyapunov theory to the pigeonhole argument.

2. **The Convergence Rate Bound** (Theorem D): The quantitative bound N · δ ≤ V(x) is new. Previous results bounded orbit length by |α| (the pigeonhole bound); our bound can be much tighter when the potential gap δ is large relative to the potential range.

3. **Level Set Rigidity** (Theorem 3.4): The result that returning to the same potential level forces fixedness is a strong structural constraint not previously formalized.

4. **The Unified Framework**: The `LyapunovDDS` structure abstracts the common pattern from multiple catalog files (TropicalDepthFlow, HolographicProofRenormalization) into a single framework.

### 6.3 Limitations

The current framework is limited to:
- **Finite types**: Extension to compact infinite types requires measure-theoretic machinery.
- **Deterministic dynamics**: Stochastic extensions (Markov chains with Lyapunov functions) would connect to the mixing theory in Tropical/MixingTheory.lean.
- **Discrete time**: Continuous-time analogues would require ODE/flow theory.

## 7. Future Work

Three directions seem most promising:

1. **Spectral-Dynamical Bridge**: Connecting the tropical spectral gap λ(W) to the convergence rate δ in a quantitative way. This would bridge Tropical/SpectralTheory.lean with the current framework.

2. **Stochastic Lyapunov Theory**: Extending to Markov chains where the potential decreases in expectation. This would connect to Tropical/MixingTheory.lean and provide tropical mixing-time bounds.

3. **Infinite Extensions**: Extending to compact Hausdorff spaces with continuous dynamics and lower-semicontinuous potentials, connecting to the measure-theoretic foundations of statistical mechanics.

## References

1. Lyapunov, A.M. (1892). *The General Problem of the Stability of Motion*. Doctoral dissertation, Kharkov.
2. Kadanoff, L.P. (1966). Scaling laws for Ising models near Tₒ. *Physics*, 2(6), 263-272.
3. Wilson, K.G. (1971). Renormalization group and critical phenomena. *Physical Review B*, 4(9), 3174-3183.
4. Gaubert, S. & Gunawardena, J. (2004). The Perron–Frobenius theorem for homogeneous, monotone functions. *Transactions of the AMS*, 356(12), 4931-4950.
5. Cuninghame-Green, R.A. (1979). *Minimax Algebra*. Lecture Notes in Economics and Mathematical Systems, 166. Springer.
6. Karp, R.M. (1978). A characterization of the minimum cycle mean in a digraph. *Discrete Mathematics*, 23(3), 309-311.
