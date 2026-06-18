# Future Directions: Tropical Cryptanalysis and Idempotent Number Theory

## Overview

The theorems formalized in `Cryptography/TropicalSmoothnessScore.lean` establish the foundational bridge between smoothness detection in the quadratic sieve and tropical (min-plus) algebra. Specifically, we proved that **smoothness of a natural number over a factor base is exactly equivalent to vanishing of a tropical score defect**. This opens several concrete breakthrough research directions.

---

## Direction 1: Large-Prime Tropical Defect Theorem

### Target Theorem
For a factor base `P` and a natural number `n` with exactly one prime factor `q ∉ P`, the score defect satisfies:

```
scoreDefect P n = log q
```

More precisely: if `n = m · q` where `m` is P-smooth and `q` is prime with `q ∉ P`, then `scoreDefect P n = Real.log q`.

### Significance
In the quadratic sieve, "one-large-prime" relations are the most common partially smooth values encountered during sieving. Proving that the tropical defect exactly equals `log q` gives a precise tropical criterion for identifying one-large-prime relations: accept candidates with defect in the interval `(0, log B']` where `B'` is the large-prime bound. This transforms the large-prime variant of QS from a heuristic to a certified tropical filter.

### Proof Strategy
1. Use the multiplicative additivity of factorization: `v_p(m · q) = v_p(m) + v_p(q)`.
2. Since `m` is P-smooth, `scoreDefect P m = 0` (our Theorem C.2).
3. Since `q` is prime and `q ∉ P`, the only out-of-base contribution is `1 · log q = log q`.
4. Combine using `scoreDefect` linearity under multiplication (which follows from log multiplicativity).

### Cross-Domain Connection
This connects to **statistical mechanics**: one-large-prime relations are "low-energy excitations" above the ground state (exact smoothness). The defect `log q` is the excitation energy. This suggests importing large-deviation estimates from statistical physics to bound the density of near-smooth numbers.

---

## Direction 2: Tropical Sparse Relation Graph and Min-Plus Path Composition

### Target Theorem
Define a **relation graph** `G = (V, E)` where vertices are sieve positions and edges connect positions whose combined valuations produce a full relation (exponent vector with all even entries). Then:

```
theorem relation_merging_as_tropical_path
    (G : SimpleGraph (Fin R))
    (defect : Fin R → ℝ)
    (h_edge : ∀ {u v}, G.Adj u v → defect u + defect v = 0 ∨ (∃ q, defect u + defect v = 2 * log q)) :
    ∀ path in G, the total defect along the path can be computed
    by min-plus matrix power of the adjacency-defect matrix.
```

### Significance
Relation merging in the large-prime variant composes partial relations by matching shared large primes. This is structurally identical to **path composition in a weighted graph**, which is exactly what min-plus matrix multiplication computes. Our `minPlusMatMul_assoc` theorem already provides the algebraic foundation.

### Proof Strategy
1. Encode the relation graph with edge weights equal to shared large-prime defects.
2. Show that the (min-plus)^k power of the adjacency matrix computes optimal k-step relation chains.
3. Use `minPlusMatMul_assoc` to guarantee well-defined iterated composition.
4. Prove that zero-weight paths correspond to full relations.

### Cross-Domain Connection
This is the **shortest-path / APSP** interpretation of relation collection. It suggests that hardware-accelerated min-plus matrix multiplication (e.g., on tropical TPUs or FPGA min-plus units) could directly accelerate the relation-merging stage of sieve algorithms.

---

## Direction 3: Dickman–de Bruijn Function as Tropical Energy Distribution

### Target Theorem
The Dickman function `ρ(u)` governs the density of B-smooth numbers up to `x`, where `u = log x / log B`. Formalize:

```
theorem tropical_energy_distribution
    (x B : ℕ) (hB : 1 < B) (hx : B ≤ x) :
    let u := Real.log x / Real.log B
    -- The fraction of n ≤ x with scoreDefect {p | p.Prime ∧ p ≤ B} n = 0
    -- asymptotically equals ρ(u)
    ...
```

### Significance
This connects the tropical score defect to the analytic number theory of smooth number density. In our framework, "scoreDefect = 0" is the smooth condition, so the Dickman function describes the probability that a random number has vanishing tropical defect. This is a **partition function** in the statistical mechanics interpretation: `ρ(u)` is the fraction of the configuration space at zero energy.

### Proof Strategy
1. Define the Dickman function via its delay-differential equation: `ρ(u) = 1` for `0 ≤ u ≤ 1`, and `u · ρ'(u) = -ρ(u-1)` for `u > 1`.
2. Formalize the de Bruijn asymptotic: `Ψ(x, B) ~ x · ρ(log x / log B)`.
3. Relate `Ψ(x, B)` to the count of `n ≤ x` with `scoreDefect P n = 0` for `P = {primes ≤ B}`.

This is a major undertaking but would constitute the first formal verification of a key analytic number theory result used in cryptographic complexity estimates.

### Cross-Domain Connection
The Dickman function appears in random combinatorial structures (e.g., longest cycle in random permutations), connecting tropical cryptanalysis to probabilistic combinatorics.

---

## Direction 4: Min-Sum Belief Propagation for Relation Collection

### Target Theorem
```
theorem belief_propagation_sieve_equivalence
    (factor_graph : BipartiteGraph)
    (messages : factor_graph.Edges → ℝ)
    (h_update : ∀ e, messages e = min-plus aggregation of neighboring messages) :
    fixed_point messages → ∀ i, messages.marginal i = scoreDefect P (Q i)
```

### Significance
The sieve accumulates local prime evidence across positions. This is structurally identical to **message passing on a factor graph**:
- **Variable nodes** = sieve positions
- **Factor nodes** = primes in the factor base
- **Messages** = log-weighted valuation contributions
- **Convergence** = score accumulation

The min-sum algorithm (tropical version of belief propagation) on this factor graph computes the same scores as the tropical sieve. This opens a bridge to **coding theory**: relation collection becomes analogous to LDPC decoding, and techniques from iterative decoding (scheduling, damping, decimation) could accelerate sieve algorithms.

### Proof Strategy
1. Define the factor graph for a sieve instance.
2. Show that one round of min-sum message passing computes the per-prime valuation contributions.
3. Prove that after convergence, the beliefs at variable nodes equal `tropicalScoreR P (Q i)`.
4. Use our `scoreDefect_eq_zero_iff_smooth` to conclude that zero-belief positions are exactly the smooth values.

### Cross-Domain Connection
This directly connects to **turbo codes, LDPC codes, and polar codes**. If sieving is decoding, then perhaps decoding techniques can be adapted for factoring — and conversely, cryptanalytic insights might improve decoder design.

---

## Direction 5: Tropical Number Field Sieve Shadow

### Target Theorem
Extend the valuation-score framework from `ℤ` to algebraic number fields:

```
theorem nfs_tropical_score_defect
    (K : NumberField) (P : Finset (Ideal (𝒪 K)))
    (α : 𝒪 K) (hα : α ≠ 0) :
    scoreDefect_NF K P α = 0 ↔ ∀ 𝔭, 𝔭.IsPrime → 𝔭 ∣ Ideal.span {α} → 𝔭 ∈ P
```

where `scoreDefect_NF` is defined using ideal valuations and norms:

```
def scoreDefect_NF (K : NumberField) (P : Finset (Ideal (𝒪 K))) (α : 𝒪 K) : ℝ :=
  Real.log (Algebra.norm ℤ α) - ∑ 𝔭 ∈ P, (𝔭.valuation α : ℝ) * Real.log (Ideal.absNorm 𝔭)
```

### Significance
The Number Field Sieve (NFS) is the fastest known algorithm for factoring large integers, and its relation-collection stage involves smoothness testing in number fields. Extending our tropical framework to number fields would provide a unified tropical foundation for all sieve-based factoring algorithms, and potentially reveal structural connections between QS and NFS that are invisible in the classical formulation.

### Proof Strategy
1. Define ideal-theoretic analogues of `tropicalScoreR` and `scoreDefect` using ideal valuations.
2. Prove the number field analogue of `scoreDefect_eq_zero_iff_smooth` using unique factorization of ideals.
3. Show that the rational integer case is recovered when `K = ℚ`.

### Cross-Domain Connection
This connects tropical cryptanalysis to **arithmetic geometry** and **algebraic number theory**. The tropical score defect in a number field can be interpreted as a distance function on the Arakelov divisor group, connecting to height theory and Diophantine geometry.

---

## Implementation Roadmap

| Priority | Direction | Estimated Effort | Dependencies |
|----------|-----------|-----------------|--------------|
| 1 | Large-prime defect (Dir. 1) | 1-2 weeks | Current theorems |
| 2 | Relation graph (Dir. 2) | 2-3 weeks | `minPlusMatMul_assoc` |
| 3 | Belief propagation (Dir. 4) | 3-4 weeks | Dir. 1, factor graph formalization |
| 4 | Dickman function (Dir. 3) | 4-8 weeks | Analysis formalization in Mathlib |
| 5 | NFS extension (Dir. 5) | 6-12 weeks | Number field machinery in Mathlib |

Each direction builds on the core theorems established in this work: the score defect characterization of smoothness, min-plus matrix associativity, and the idempotent boundary theorem.
