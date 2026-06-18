# Future Directions: Tropical Algorithmics for Arithmetic Complexity

## Overview

The formalization of smoothness as a tropical zero-energy condition opens a new field: **idempotent algorithmics for arithmetic complexity**. The certified equivalence between B-smoothness and tropical cost vanishing, combined with the multiplicative-to-additive transfer theorem, provides the foundational infrastructure for the following research programs.

---

## Direction 1: Tropical Number Field Sieve Filtering as Min-Plus Hypergraph Elimination

### Hypothesis
The NFS relation-filtering stage — which removes singletons and optimizes the relation matrix before linear algebra — can be reformulated as a min-plus hypergraph elimination problem on a tropical cost hypergraph.

### Key Insight
In the NFS, each relation involves multiple prime ideals (both rational and algebraic). Filtering decisions (keep/discard a relation) are currently made by greedy heuristics (e.g., Cavallar's merge algorithm). Our `smoothCost` additivity theorem (`smoothCost_mul_of_pos`) extends to norm-based smoothness over number field factor bases. The filtering problem becomes: find a minimum-cost subhypergraph that remains connected (ensures full rank). This is a tropical shortest-hypergraph-path problem.

### Proof Strategy
1. Define `nfsSmoothCost` over algebraic factor bases using ideal-adic valuations.
2. Prove an analogue of `smoothCost_mul_of_pos` for norm-based valuations in number fields.
3. Model the relation matrix as a min-plus hypergraph incidence matrix.
4. Prove that optimal filtering corresponds to a tropical matroid intersection problem.
5. Derive certified complexity bounds for NFS filtering via tropical matroid theory.

### Cross-Domain Connections
- **Combinatorial optimization**: Tropical matroid intersection is connected to valuated matroid theory (Murota, Dress–Wenzel).
- **Coding theory**: NFS filtering is structurally analogous to LDPC code thinning — both seek sparse substructures preserving rank.
- **Formal methods**: A certified NFS filter could provide verifiable preprocessing for cryptanalytic computations.

---

## Direction 2: Tropical Large-Sieve Inequality for Smoothness Scoring Distributions

### Hypothesis
The classical large-sieve inequality, which bounds the concentration of integer sequences in arithmetic progressions, has a tropical analogue that bounds the distribution of `smoothCost` values across sieving intervals.

### Key Insight
The large sieve gives: for a set S of integers in [1,N] and a set of moduli Q, the weighted sum $\sum_{q \le Q} \sum_{a \bmod q}^{*} |S_a|^2$ is bounded by $(N + Q^2)|S|$. In the tropical setting, replace $|S_a|^2$ by $\min_{n \in S_a} \text{smoothCost}(P, n)$. The tropical large-sieve should bound the *distribution of smooth-cost minima* across residue classes, giving certified estimates of how many low-cost candidates the sieve interval contains.

### Proof Strategy
1. State a tropical large-sieve inequality: $\sum_{p \in P} \min_{x \in [M, M+R], p | Q_N(x)} \text{smoothCost}(P, Q_N(x)) \le f(R, B)$.
2. Use `smoothCost_mono_factorBase` to establish monotonicity under base enlargement.
3. Prove concentration bounds using the multiplicative additivity theorem.
4. Connect to Gallagher's larger-sieve and Selberg's sieve via tropical cost dualization.

### Cross-Domain Connections
- **Analytic number theory**: This would be the first formal tropical analogue of a classical sieve inequality.
- **Probability theory**: Tropical probability (Maslov dequantization of probability) provides a natural framework.
- **Cryptography**: Certified smoothness-distribution bounds directly inform security estimates for factoring algorithms.

---

## Direction 3: Certified Equivalence Between Belief Propagation and Tropical Relation Scoring

### Hypothesis
The belief propagation (BP) algorithm on the factor graph of QS relations is equivalent to iterated tropical matrix-vector multiplication on the cost matrix.

### Key Insight
BP on a factor graph computes marginal probabilities by message passing. In the "zero-temperature" (max-product) limit, BP becomes min-sum BP, which is exactly min-plus matrix-vector multiplication. Our `tropicalMatVec_mono` theorem from the companion file provides the monotonicity needed for convergence analysis. The connection: each BP message from prime node p to candidate node x is exactly the `smoothCost` contribution of p to x.

### Proof Strategy
1. Define the QS factor graph: variable nodes = sieve candidates, factor nodes = primes.
2. Define min-sum BP messages as tropical matrix-vector products.
3. Prove that BP fixed points correspond to smoothCost minima using idempotency (`tropical_add_idempotent`).
4. Use the no-go theorem (`idempotent_semiring_with_inverses_trivial`) to delineate where BP cannot replace exact linear algebra.
5. Derive certified convergence rates for min-sum BP on tree-structured subgraphs of the QS factor graph.

### Cross-Domain Connections
- **Machine learning**: BP is fundamental to probabilistic graphical models; a tropical-arithmetic bridge connects ML inference to cryptanalysis.
- **Coding theory**: LDPC decoding uses BP; tropical QS scoring is structurally analogous to syndrome decoding.
- **Statistical physics**: Zero-temperature BP is the cavity method; this connects factoring to spin-glass theory.

---

## Direction 4: Min-Plus Formulations of Lattice Sieve Collision Search

### Hypothesis
Lattice sieve algorithms (e.g., GaussSieve, HashSieve, BDGL) for finding short lattice vectors can be reformulated as tropical shortest-path problems on a collision graph.

### Key Insight
In a lattice sieve, we maintain a list L of lattice vectors and seek pairs (v, w) with ||v ± w|| < ||v||. This is a collision search. Define a tropical cost on lattice vectors: `latticeCost(v) = ||v||²` (or a suitable norm). Then the sieve reduction `v ← v - w` has tropical cost `latticeCost(v-w) = latticeCost(v) ⊕_trop latticeCost(w)` in a suitable tropical metric. The sieve terminates when the tropical cost reaches a global minimum.

### Proof Strategy
1. Define `latticeSmoothCost` analogous to `smoothCost` but for lattice basis decompositions.
2. Prove a lattice analogue of `smoothCost_mul_of_pos`: cost additivity under basis composition.
3. Model sieve reductions as edges in a tropical graph with min-plus weights.
4. Prove that the sieve algorithm computes a tropical shortest path from the input basis to a reduced basis.
5. Transfer complexity bounds from tropical graph algorithms to lattice sieve bounds.

### Cross-Domain Connections
- **Post-quantum cryptography**: Lattice problems (SVP, CVP) underlie schemes like Kyber and Dilithium.
- **Optimization**: Lattice reduction is connected to integer programming and Lenstra's algorithm.
- **Tropical geometry**: Lattice polytopes are fundamental objects in tropical geometry; this connects sieving to tropical intersection theory.

---

## Direction 5: Tropical Entropy of Smooth-Number Distributions

### Hypothesis
The distribution of B-smooth numbers up to N has a natural tropical entropy that quantifies the "information content" of the factor base, and this entropy governs the asymptotic efficiency of sieve algorithms.

### Key Insight
Define the tropical entropy of the smooth-number distribution as: $H_{\text{trop}}(P, N) = \bigoplus_{n \le N} \text{smoothCost}(P, n)$ where $\bigoplus$ is tropical addition (min). This is the minimum smoothCost over [1, N]. More informatively, define a tropical probability: $\pi_{\text{trop}}(n) = \text{smoothCost}(P, n) \ominus H_{\text{trop}}(P, N)$ (tropical normalization). The tropical entropy rate $H_{\text{trop}}(P, N) / N$ should converge to a limit related to $\log \Psi(N, B)$ (the smooth-number counting function).

### Proof Strategy
1. Define tropical entropy functionals using `smoothCost` and the infimum operation.
2. Prove monotonicity: `H_trop(P, N) ≤ H_trop(P, N+1)` (more candidates can only decrease the minimum).
3. Connect tropical entropy to classical smooth-number counts via Dickman's function.
4. Prove that the optimal factor-base size B minimizing $H_{\text{trop}}(P_B, N) + B$ recovers the classical QS parameter choice $B = \exp(\sqrt{\log N \log \log N})$.
5. Extend to tropical Rényi entropies for finer distributional analysis.

### Cross-Domain Connections
- **Information theory**: Tropical entropy (Maslov's idempotent measure theory) provides a deformation of Shannon entropy.
- **Statistical mechanics**: Tropical entropy corresponds to free energy at zero temperature.
- **Cryptography**: Entropy of smooth-number distributions directly governs the security margin of RSA against QS/NFS attacks.
- **Analytic number theory**: Connecting tropical entropy to Dickman's ρ function would provide a new perspective on smooth-number asymptotics.

---

## Overarching Vision

These five directions collectively establish **tropical analytic number theory** as a formal discipline:

| Classical Concept | Tropical Analogue | Formal Status |
|---|---|---|
| B-smoothness | Zero tropical cost | ✅ Proved |
| Valuation additivity | Cost additivity under multiplication | ✅ Proved |
| Factor base enlargement | Cost monotonicity | ✅ Proved |
| Sieve scoring | Tropical matrix-vector product | ✅ Proved (companion file) |
| NFS filtering | Tropical hypergraph elimination | 🔮 Direction 1 |
| Large sieve inequality | Tropical cost distribution bound | 🔮 Direction 2 |
| Belief propagation | Tropical fixed-point iteration | 🔮 Direction 3 |
| Lattice sieve | Tropical shortest path | 🔮 Direction 4 |
| Smooth-number counting | Tropical entropy | 🔮 Direction 5 |

The certified infrastructure in this project — particularly `smoothCost_eq_zero_iff_BSmooth`, `smoothCost_mul_of_pos`, and `smoothCost_mono_factorBase` — serves as the reusable foundation for all five directions.
