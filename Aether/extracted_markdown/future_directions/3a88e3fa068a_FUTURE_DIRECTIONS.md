# Future Directions: Hyperbolic Number Theory

## Synthesis

This research cycle established the algebraic foundations of arithmetic on the Poincaré disk, proving 30+ theorems connecting SL₂(ℤ) trace arithmetic to Chebyshev polynomials, Markov number theory, and tropical geometry. The most promising cross-domain connection is the **Gromov product ↔ tropical semiring bridge** (Theorem `gromov_product_ultrametric`), which suggests that the spectral theory of hyperbolic lattices can be "tropicalized" — replacing analytic objects with combinatorial ones while preserving essential structure.

The cycle's results fall into three interconnected layers: (1) the group-theoretic layer (`MobiusMap` structure with full group axioms), (2) the geometric layer (`DiskPoint` with pseudo-hyperbolic distance properties), and (3) the number-theoretic layer (trace sequences, Markov divisibility, primitive trace density). These layers connect to existing Catalog infrastructure: the Markov theory extends `Catalog/Algebra/Berggren.lean` (Pythagorean triples share the same tree structure), the tropical bridge extends `Catalog/Tropical/Hyperbolicity.lean`, and the trace arithmetic connects to `Catalog/MachineLearning/HyperbolicNumberTheory/PoincareDisk.lean`.

The highest breakthrough potential lies in **Direction 1** (Tropical Selberg Zeta), because it could provide a combinatorial proof of spectral gap results that currently require heavy analytic machinery. The formal verification of the Gromov ultrametric inequality provides the first rigorously verified step toward this goal.

---

### Direction 1: Tropical Selberg Zeta Function

**Conjecture**: The Selberg zeta function Z(s) = ∏_p ∏_{k≥0} (1 − N(p)^{−(s+k)}) for PSL₂(ℤ), when "tropicalized" by replacing multiplication with min and addition with ordinary addition, yields a tropical polynomial whose roots correspond to the eigenvalues of the hyperbolic Laplacian on the modular surface.

**Test**: Compute the first 10 primitive hyperbolic conjugacy classes of PSL₂(ℤ) (classified by trace t ≥ 3), compute the tropical Selberg zeta for s ∈ [0, 5], and compare the tropical roots to the known spectrum {1/4 + r_n² : r_n are the Maaß form eigenvalues}. If the tropical roots approximate the spectral values to within 10%, the conjecture is supported.

**Impact**: If true, this would provide a combinatorial framework for spectral geometry, potentially simplifying proofs of spectral gap theorems. If false, the failure mode reveals which aspects of the Selberg theory are inherently analytic and cannot be tropicalized.

**Catalog References**: `Catalog/Tropical/Hyperbolicity.lean`, `Catalog/MachineLearning/HyperbolicNumberTheory/PoincareDisk.lean`, `Speculative/HyperbolicNumberTheory/Foundations.lean` (theorem `gromov_product_ultrametric`)

**Proof Strategy**: (1) Formalize primitive hyperbolic conjugacy classes using the trace classification. (2) Define the tropical Selberg product as a min-plus convolution. (3) Prove that the tropical Euler product converges. (4) Compare roots numerically. Key lemmas needed: classification of primitive elements by trace, norm computation N(p) = ((t + √(t²−4))/2)².

**Domain Bridges**: NumberTheory <-> Tropical, Geometry <-> Spectral

**Lineage**: Builds on `traceSeq_mod`, `fundamentalDisc_pos`, and the tropical algebra theorems from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Markov Uniqueness via Trace Rigidity

**Conjecture**: The Markov uniqueness conjecture — that the largest element of a Markov triple uniquely determines the triple — can be proved by showing that the SL₂(ℤ) conjugacy class associated to a Markov number z is determined by the geodesic length log((z + √(z²−4))/2), using trace rigidity (Theorem `trace_conjugate`).

**Test**: Verify computationally for all Markov numbers z ≤ 10⁶ that no two distinct Markov triples share the same maximum element. Then attempt to formalize the uniqueness for z ≤ 100 using the Vieta tree structure.

**Impact**: The Markov uniqueness conjecture has been open for over 100 years. Even a partial formal result (e.g., uniqueness for z ≤ 1000) would be significant. If the trace rigidity approach fails, it would constrain which algebraic methods can work.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Foundations.lean` (theorems `vieta_preserves_markov`, `markov_divisibility`, `markov_vieta_partner_pos`), `Catalog/Algebra/Berggren.lean`

**Proof Strategy**: (1) Formalize the Markov tree as a binary tree with Vieta involutions. (2) Prove that distinct branches produce distinct maximum elements, by induction on tree depth. (3) Use `markov_vieta_bound` to control growth. (4) Apply `markov_divisibility` to eliminate collisions. Key difficulty: showing the Vieta involution is injective on the relevant domain.

**Domain Bridges**: Algebra <-> Geometry, NumberTheory <-> Combinatorics

**Lineage**: Builds on the Markov triple theorems from this cycle and the Berggren tree structure in the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Chebyshev-Fibonacci Bridge via Trace Sequences

**Conjecture**: The trace sequence traceSeq(3, n) = {2, 3, 7, 18, 47, 123, ...} satisfies gcd(traceSeq(3, m), traceSeq(3, n)) = traceSeq(3, gcd(m, n)), analogous to the classical identity gcd(F_m, F_n) = F_{gcd(m,n)} for Fibonacci numbers.

**Test**: Verify computationally for all m, n ≤ 100. Then prove the identity by formalizing the divisibility property traceSeq(t, m) | traceSeq(t, mn) − 2 and adapting the Fibonacci GCD proof.

**Impact**: This would establish a complete analogy between Fibonacci numbers and trace sequences, opening the door to "hyperbolic Fibonacci" identities. The result would also give new divisibility tests for Markov-related sequences.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Foundations.lean` (theorems `traceSeq_mod`, `traceSeq_even_of_even`, `trace_pow_recurrence`)

**Proof Strategy**: (1) Prove traceSeq(t, m) | traceSeq(t, km) for all k, by induction using `traceSeq_mod`. (2) Prove the GCD identity by strong induction on max(m,n), reducing via the Euclidean algorithm. (3) Handle the base case using `traceSeq_mod`. Key lemma: "if (t−2) | (traceSeq(t,n) − 2), then traceSeq(s, 1) | traceSeq(s, n)" where s = traceSeq(t, m).

**Domain Bridges**: NumberTheory <-> Algebra, Combinatorics <-> Geometry

**Lineage**: Directly extends `traceSeq_mod` and `traceSeq_even_of_even`.

**Ambition**: extension

---

### Direction 4: Hyperbolic Lattice Counting via Euler Totients

**Conjecture**: The number of SL₂(ℤ) elements with |trace| ≤ T and coprime entries (a, c) is asymptotic to (3/π²) · T³, with the leading constant 3/π² = 3·(1 − 1/4)(1 − 1/9)(1 − 1/25)··· arising from the Euler product for 1/ζ(2).

**Test**: Count elements by brute force for T ≤ 50 and compare to the asymptotic formula. Verify that the ratio converges to 3/π² ≈ 0.3040.

**Impact**: This would establish the hyperbolic analog of the Gauss circle problem, connecting lattice point counting to the Riemann zeta function. The Euler totient sum theorem (`eulerTotientSum_ge`) provides the formal lower bound needed as a first step.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Foundations.lean` (theorems `eulerTotientSum_ge`, `trace_realized`, `congruence_subgroup_index_div6`)

**Proof Strategy**: (1) Formalize the count of SL₂(ℤ) elements with trace t as a sum of Euler totients. (2) Use the Euler totient sum asymptotic (Mertens' theorem) to derive the T³ growth. (3) Identify the leading constant via the Euler product. Key prerequisite: formalizing ∑_{n≤N} φ(n) ~ 3N²/π².

**Domain Bridges**: NumberTheory <-> Geometry, Algebra <-> Analysis

**Lineage**: Builds on `eulerTotientSum_ge` and `congruence_subgroup_index_div6`.

**Ambition**: extension

---

### Direction 5: Machine Learning on Hyperbolic Integers

**Conjecture**: A neural network operating in hyperbolic space (using the pseudo-hyperbolic distance `pseudoHypDistSq` as its metric) can learn the Markov tree structure more efficiently than a Euclidean network, requiring O(log N) parameters to represent N Markov triples versus O(N) for flat embeddings.

**Test**: Implement a hyperbolic graph neural network using the formally verified distance function, embed the first 1000 Markov triples, and measure distortion (the ratio of embedding distance to true graph distance). Compare to a Euclidean embedding with the same number of parameters.

**Impact**: This would demonstrate a practical application of hyperbolic number theory to machine learning, and provide a formally verified distance metric for hyperbolic neural networks. The `pseudoHypDistSq_lt_one` and `pseudoHypDistSq_symm` theorems guarantee the metric properties needed for optimization convergence.

**Catalog References**: `Speculative/HyperbolicNumberTheory/Foundations.lean` (theorems `pseudoHypDistSq_symm`, `pseudoHypDistSq_lt_one`, `pseudoHypDistSq_nonneg`), `Catalog/MachineLearning/HyperbolicNumberTheory/PoincareDisk.lean`

**Proof Strategy**: (1) Prove that the pseudo-hyperbolic distance satisfies the triangle inequality (requires arctanh monotonicity). (2) Formalize the hyperbolic embedding of trees. (3) Bound the distortion using Gromov hyperbolicity. Key gap: the triangle inequality for the full hyperbolic distance requires analytic tools (arctanh) not yet formalized in this framework.

**Domain Bridges**: MachineLearning <-> Geometry, Algebra <-> MachineLearning

**Lineage**: Bridges between `MachineLearning` and `Geometry` Catalog domains.

**Ambition**: extension
