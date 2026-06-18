# Future Directions: Arithmetic Product Spectral Theory

## Synthesis

The CRT Product Bottleneck Theorem establishes that coprime factorization of a modulus creates quantitative expansion obstructions in modular squaring dynamics. This opens a systematic program — **arithmetic product spectral theory** — connecting number-theoretic structure (factorization, CRT, idempotents) to dynamical mixing properties (conductance, spectral gaps, entropy decay).

The five directions below build directly on the proven bottleneck inequality h(ab) ≤ min(h(a), h(b)) and explore its extensions, converses, and implications. They form a coherent research arc: Direction 1 strengthens the inequality to equality, Direction 2 generalizes to higher-degree maps, Direction 3 connects conductance to spectral gaps, Direction 4 explores entropy-theoretic consequences, and Direction 5 asks whether the dynamical landscape can detect arithmetic structure.

All directions reference specific catalog theorems and are designed to be computationally testable.

---

## Direction 1: Exact Min Law for Basin Conductance

**Ambition**: grand_challenge

**Conjecture**: For all coprime a, b ≥ 2, basin conductance satisfies exact equality:
```
h(ab) = min(h(a), h(b))
```
That is, the normalization factor κ(a,b) in the bottleneck theorem is always exactly 1, and the product system achieves exactly the conductance of the weaker factor.

**Test**: Compute h(n) exactly for all coprime pairs (a, b) with 2 ≤ a ≤ b ≤ 25. Check whether h(ab) = min(h(a), h(b)) in every case. Any single counterexample refutes the conjecture. Requires exact enumeration of all 2^n subsets for n = ab up to ~625, feasible with optimized code.

**Impact**: If true, this would establish an exact product formula for a Cheeger constant — rare in spectral graph theory, where product inequalities are typically non-tight. It would mean CRT lifts are not just sufficient but *optimal* bottleneck sets, implying the worst cuts in the product always factor through CRT projections.

**Catalog References**: `Pythagorean/CRTBottleneck.lean`: `basinConductance_mul_le_min`, `sqConductance_crtLiftLeft`

**Proof Strategy**: For the reverse inequality h(ab) ≥ min(h(a), h(b)), one would need to show that every admissible cut S in ℤ/(ab)ℤ has h(S) ≥ min(h(a), h(b)). Approach: use the CRT decomposition to write S = ⋃_{s ∈ A} {s} × B_s, and show that the boundary contributions from each fiber aggregate to give h(S) ≥ some function of h(a) and h(b). The fiber structure may allow a conditioning argument.

**Domain Bridges**: Graph theory (product graph Cheeger constants), probability (product Markov chain mixing), information theory (tensorization of log-Sobolev inequalities)

**Lineage**: Direct extension of `basinConductance_mul_le_min`

---

## Direction 2: Higher-Degree Dynamical Bottleneck

**Ambition**: solid_extension

**Conjecture**: The product bottleneck inequality generalizes to the d-th power map x ↦ x^d mod n for any d ≥ 2. Define h_d(n) as the basin conductance of the d-th power map. Then for coprime a, b ≥ 2:
```
h_d(ab) ≤ min(h_d(a), h_d(b))
```

**Test**: Compute h_d(n) for d ∈ {2, 3, 4, 5} and all coprime pairs (a, b) with 2 ≤ a ≤ b ≤ 15. Verify the inequality holds. Compare the optimal normalization factor across different degrees.

**Impact**: Would establish that the CRT bottleneck principle is not specific to squaring but is a universal feature of power-map dynamics on modular arithmetic. This would unify the theory across the entire family of polynomial dynamical systems x ↦ x^d.

**Catalog References**: `Catalog/FINAL/Pythagorean/DynamicalSquaring.lean`: `crt_squaring_equivariant` (generalize to d-th powers)

**Proof Strategy**: The proof of the squaring case uses CRT equivariance: π_a(x²) = π_a(x)². This holds for any polynomial map because CRT is a ring homomorphism: π_a(x^d) = π_a(x)^d. The same lift construction and conductance preservation argument should work verbatim after replacing x² with x^d.

**Domain Bridges**: Algebraic dynamics, polynomial iteration theory, post-quantum cryptography (lattice-based systems use higher-degree maps)

**Lineage**: Direct generalization of `crt_sqMap_fst`, `sqConductance_crtLiftLeft`

---

## Direction 3: Spectral Gap from Conductance via Discrete Cheeger

**Ambition**: grand_challenge

**Conjecture**: The basin conductance h(n) controls the spectral gap λ₂ of the adjacency matrix of the squaring graph via a discrete Cheeger inequality:
```
h(n)² / 2 ≤ 1 - λ₂(n) ≤ 2 · h(n)
```
Combined with the product bottleneck theorem, this would give:
```
1 - λ₂(ab) ≤ 2 · min(h(a), h(b))
```
linking factorization directly to spectral gap deterioration.

**Test**: For n ≤ 30, compute both h(n) and the eigenvalues of the adjacency matrix of the squaring graph. Verify the Cheeger-type bounds. Plot λ₂(n) vs h(n) to check tightness.

**Impact**: Would provide the first rigorous spectral gap bound for modular squaring dynamics, connecting arithmetic factorization to the convergence rate of associated random walks. This is the bridge from combinatorial conductance to operator-theoretic spectral theory.

**Catalog References**: `Catalog/Pythagorean/SpectralGap.lean`: `arithmetic_fragmentation_theorem`; `Pythagorean/CRTBottleneck.lean`: `basinConductance_mul_le_min`

**Proof Strategy**: The discrete Cheeger inequality for general graphs is well-known. The challenge is applying it to the squaring graph, which is directed (each vertex has out-degree 1) and possibly non-regular. One may need to symmetrize the graph or work with the Laplacian of the associated undirected graph.

**Domain Bridges**: Spectral graph theory, Markov chain mixing, expander graph theory, quantum computing (quantum walks on arithmetic graphs)

**Lineage**: Extension of `sqConductance'_le_one`, `basinConductance_nonneg`

---

## Direction 4: Entropy Contraction and Mixing Time Bounds

**Ambition**: solid_extension

**Conjecture**: The squaring map on ℤ/nℤ satisfies an entropy contraction inequality:
```
H(f^{(k)}(X)) ≤ (1 - h(n)) · H(f^{(k-1)}(X))
```
where H denotes Shannon entropy of the distribution of iterated squaring. The product bottleneck then implies:
```
Mixing time of squaring mod ab ≥ max(mixing time mod a, mixing time mod b)
```

**Test**: For n ≤ 20, start with uniform distribution on ℤ/nℤ and iterate the squaring map. Track the entropy evolution. Verify that the entropy decay rate is bounded by h(n). Compare decay rates for primes vs. composites.

**Impact**: Would connect arithmetic dynamics to information theory, showing that factorization creates information-theoretic barriers to equilibration. This is the arithmetic analogue of the slowest-mode-dominates principle in statistical physics.

**Catalog References**: `Pythagorean/CRTBottleneck.lean`: `basinConductance_mul_le_min`, `sqBasin'_disjoint`

**Proof Strategy**: Use the standard relationship between conductance and entropy decay for deterministic dynamics. The key subtlety is that squaring is deterministic (not a stochastic process), so the entropy analysis must be adapted to track the evolution of probability measures under a deterministic map.

**Domain Bridges**: Information theory, statistical mechanics, ergodic theory, data compression

**Lineage**: Novel direction building on conductance bounds

---

## Direction 5: Compositeness Detection via Dynamical Invariants

**Ambition**: solid_extension

**Conjecture**: For n ≥ 3, the following are equivalent:
1. n is a prime power
2. Basin conductance h(n) > 0 or n = p^k with p ≡ 3 (mod 4) and k = 1
3. The squaring graph on ℤ/nℤ has at most 2 connected components in its functional graph

More specifically: h(n) = 0 if and only if n has ≥ 2 distinct prime factors and n ≥ 6.

**Test**: Compute h(n) for all n ≤ 200. Classify: (a) primes p: what is h(p)? (b) prime powers p^k: what is h(p^k)? (c) composites with ω(n) ≥ 2: is h(n) = 0 always? Search for the smallest n with ω(n) ≥ 2 and h(n) > 0.

**Impact**: Would provide a new characterization of prime powers via dynamical expansion, establishing that the Cheeger constant of the squaring graph is a primality/prime-power invariant. This would be a surprising bridge between number theory and combinatorial graph theory.

**Catalog References**: `Catalog/FINAL/Pythagorean/DynamicalSquaring.lean`: `nontrivial_idempotent_iff_multiple_prime_factors`; `Pythagorean/CRTBottleneck.lean`: `arithmetic_fragmentation_bottleneck`

**Proof Strategy**: For the direction "ω(n) ≥ 2 implies h(n) = 0": use the fact that distinct idempotents have disjoint basins. Each basin is a closed set (conductance 0 from the basin's perspective). So the basin itself is an admissible cut with h = 0 if it's a proper nonempty subset, which it is when ω(n) ≥ 2.

**Domain Bridges**: Computational number theory, primality testing, algebraic graph theory

**Lineage**: Extension of `arithmetic_fragmentation_bottleneck`, `nontrivial_idempotent_iff_multiple_prime_factors`
