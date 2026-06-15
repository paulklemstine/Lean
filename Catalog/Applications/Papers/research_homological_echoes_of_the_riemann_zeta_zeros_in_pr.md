# Homological Echoes of Prime Statistics: The Arithmetic-Topological Dictionary for Prime Gap Clique Complexes

## Abstract

We introduce the *prime gap clique complex*, a simplicial complex whose vertices are primes in a finite interval and whose simplices are cliques in a graph connecting primes with arithmetically admissible gaps. We prove exact decomposition theorems showing that the face numbers of this complex equal explicit prime-pair correlation statistics, establish monotonicity under gap-set filtration (enabling persistent homology), and derive discrepancy formulas comparing arithmetic face counts against Bernoulli random-topology baselines. All main results are machine-verified in Lean 4 with Mathlib. We conjecture that the normalized Euler curve of the filtration, as windows grow, converges to a universal limit governed by the GUE pair-correlation law for Riemann zeta zeros, and present computational evidence supporting model-discrimination capability.

**Keywords**: prime gaps, clique complex, simplicial complex, Euler characteristic, pair correlation, prime pairs, topological data analysis, random simplicial complex, arithmetic topology

---

## 1. Introduction

### 1.1 Motivation

The distribution of prime numbers in short intervals is governed by deep analytic structures — the zeros of the Riemann zeta function, sieve-theoretic bounds, and conjectural pair-correlation laws (Montgomery [1], Goldston-Pintz-Yıldırım [2]). These are typically studied through analytic and algebraic tools: L-functions, character sums, exponential sums, and probabilistic models.

Independently, topological data analysis (TDA) has developed a rich toolkit for extracting multi-scale structural information from data: simplicial complexes, persistent homology, Euler characteristic curves, and persistence landscapes (Carlsson [3], Edelsbrunner-Harer [4]).

This paper bridges these two fields by constructing a simplicial complex directly from prime data in a finite window, proving that its topological invariants are *exactly* equal to classical prime statistics, and establishing the structural properties needed for TDA-style analysis.

### 1.2 Overview of Results

Our main contributions are:

1. **Definitions**: The prime gap graph G(n, L, S) and its clique complex K(n, L, S), where n is the window start, L is the window length, and S is a set of admissible gaps (§2).

2. **Edge Decomposition Theorem** (Theorem 3.1): The edge count equals the sum of prime pair counts:
   $$|E(G)| = \sum_{h \in S} \pi_2(n, L, h)$$
   where π₂(n, L, h) counts prime pairs (p, p+h) with both in [n, n+L-1].

3. **Monotonicity Theorem** (Theorem 3.2): If S ⊆ T, then G(n,L,S) is a subgraph of G(n,L,T) and all face counts are monotone.

4. **Euler Characteristic Structure** (Theorem 3.3): The Euler characteristic decomposes as an alternating sum of face counts, bounded by the vertex count when edges dominate triangles.

5. **Bernoulli Surrogate Formula** (Theorem 3.4): Under a Bernoulli(p) random model, the expected edge count factors as p² · Σ_{h∈S}(L-h), providing an explicit random-topology baseline.

6. **Conjecture**: The normalized Euler curve converges to a GUE-determined limit (§5).

All theorems in §3 are formally verified in Lean 4 using Mathlib.

---

## 2. Definitions and Notation

### 2.1 Prime Window Vertices

**Definition 2.1.** For integers n ≥ 0 and L ≥ 1, the *prime window* is the set
$$\mathcal{P}(n, L) := \{p \in [n, n+L-1] : p \text{ is prime}\}.$$

This is formalized as:
```
def primeWindowVertices (n L : ℕ) : Finset ℕ :=
  (Finset.Icc n (n + L - 1)).filter Nat.Prime
```

The *vertex count* is V(n,L) := |P(n,L)|.

### 2.2 Prime Gap Graph

**Definition 2.2.** For a finite set S ⊂ ℕ of *admissible gaps* with S ⊂ ℕ₊, the *prime gap graph* G(n, L, S) is the simple graph on ℕ with:
- Vertex set: P(n, L)
- Edge set: {{p, q} : p, q ∈ P(n,L), p < q, q - p ∈ S}

The graph is symmetric (gaps are unsigned) and loopless (requires p ≠ q).

### 2.3 Face Counts

**Definition 2.3.** The *k-face count* f_k of the clique complex K(n,L,S) is the number of (k+1)-cliques in G(n,L,S):
- f₀ = V(n,L) = |P(n,L)| (vertices = primes)
- f₁ = |E(G)| (edges = prime pairs with gap in S)
- f₂ = number of triangles (prime triples with all pairwise gaps in S)

### 2.4 Prime Pair Count

**Definition 2.4.** For h ∈ ℕ, the *prime pair count* is
$$\pi_2(n, L, h) := |\{p \in \mathcal{P}(n,L) : p + h \in \mathcal{P}(n,L)\}|.$$

### 2.5 Euler Characteristic

**Definition 2.5.** The (truncated) *Euler characteristic* is
$$\chi(K) = f_0 - f_1 + f_2 = V - E + T.$$

### 2.6 Bernoulli Surrogate

**Definition 2.6.** The *Bernoulli expected edge count* for parameter p ∈ [0,1] is
$$\mathbb{E}_{\text{Bern}}[f_1] = p^2 \sum_{h \in S} (L - h).$$

This arises from a model where each integer in [n, n+L-1] is independently "prime" with probability p, and edges require both endpoints occupied with gap in S.

---

## 3. Main Results

### Theorem 3.1: Edge Decomposition (Arithmetic-Topological Dictionary)

**Statement.** Let S ⊂ ℕ₊ be a finite set of positive admissible gaps. Then
$$f_1(K(n,L,S)) = \sum_{h \in S} \pi_2(n, L, h).$$

**Proof sketch.** The edge set decomposes as a disjoint union indexed by gap value. For each h ∈ S, the edges with gap h correspond bijectively to primes p ∈ P(n,L) with p + h ∈ P(n,L). Disjointness follows from the positivity of gaps: if (p, p+h₁) = (p', p'+h₂) with h₁ ≠ h₂, then p = p' and h₁ = h₂, contradicting the assumption.

Formally, we prove that `edgePairSet n L S` equals a `Finset.biUnion` over S, with each fiber being the image of a filtered set under an injective map. The cardinality then follows from `Finset.card_biUnion` with disjointness.

**Formal verification:** `edgeCount_eq_sum_primePairCount` in `Theorems.lean`.

**Significance.** This theorem is the core dictionary entry. It says the topological 1-skeleton of the prime gap complex is *literally* a sum of pair-correlation statistics. For S = {2}, this counts twin prime pairs. For S = {2,4,6,...,2k}, it sums all small-gap pair counts. Varying S creates a filtration whose face numbers progressively incorporate more correlation data.

### Theorem 3.2: Monotonicity and Filtration

**Statement.** If S ⊆ T, then:
1. G(n,L,S) ≤ G(n,L,T) as simple graphs (i.e., G(n,L,S) is a subgraph).
2. f₁(K(n,L,S)) ≤ f₁(K(n,L,T)).
3. f₂(K(n,L,S)) ≤ f₂(K(n,L,T)).

**Proof sketch.** Part 1: If vertices i, j are adjacent in G(n,L,S), then their gap is in S ⊆ T, so they are adjacent in G(n,L,T). Parts 2-3: Monotone inclusion of the edge/triangle filter predicates implies monotonicity of cardinalities.

**Formal verification:** `primeGapGraph_le_of_subset`, `edgeCount_mono`, `triangleCount_mono` in `Theorems.lean`.

**Significance.** This is the persistence theorem. It establishes that the family {K(n,L,S_t)} indexed by growing gap sets forms a filtered simplicial complex — the essential input for persistent homology.

### Theorem 3.3: Euler Characteristic Structure

**Statement.**
1. χ(K(n,L,S)) = V(n,L) - f₁(K) + f₂(K).
2. If f₂ ≤ f₁, then χ(K) ≤ V.
3. If S = ∅, then χ(K) = V and f₁ = f₂ = 0.

**Proof sketch.** Part 1 is by definition. Part 2 follows from χ = V - E + T ≤ V - E + E = V when T ≤ E. Part 3: empty gap set means no edges.

**Formal verification:** `euler_char_eq_vertex_minus_edge_plus_triangle`, `euler_char_le_vertexCount`, `euler_char_empty_S`, `edgeCount_empty`, `triangleCount_empty` in `Theorems.lean`.

### Theorem 3.4: Bernoulli Surrogate Formula

**Statement.**
$$\mathbb{E}_{\text{Bern}}[f_1] = p^2 \cdot \sum_{h \in S} (L - h),$$
and this quantity is nonneg when p ≥ 0 and all h ≤ L.

**Proof sketch.** Factor p² out of the defining sum using commutativity and `Finset.sum_mul`.

**Formal verification:** `bernoulli_edge_formula`, `bernoulli_edge_nonneg` in `Theorems.lean`.

**Significance.** This is the cross-domain theorem bridging number theory and random topology. The actual edge count minus the Bernoulli prediction is the *arithmetic discrepancy*:
$$\Delta_1(n,L,S) = f_1(K) - p^2 \sum_{h \in S}(L - h).$$
This discrepancy is controlled by the pair-correlation function of primes, which in turn is conjectured to follow the GUE law.

---

## 4. Algorithms

### Algorithm 1: Prime Gap Graph Construction

```
Input: n (window start), L (window length), S (admissible gaps)
Output: (vertices, edges, adjacency)

1. Compute primes in [n, n+L-1] via segmented sieve
2. For each prime p and each gap h ∈ S:
     if p + h is prime and in window: add edge {p, p+h}
3. Return (prime list, edge set, adjacency dict)
```

**Time complexity:** O(V · |S|) where V = π(n+L) - π(n).
**Space complexity:** O(V² + V · |S|).

### Algorithm 2: Face Vector via Bron-Kerbosch

```
Input: adjacency dict, vertex list
Output: face vector (f₀, f₁, f₂, ...)

1. Enumerate all maximal cliques via Bron-Kerbosch with pivoting
2. Extract all sub-cliques of each size
3. Count cliques by size → face vector
```

**Time complexity:** O(3^{V/3}) worst case.

### Algorithm 3: Filtration Profile

```
Input: n, L, max_gap, gap_step
Output: sequence of (gap_threshold, face_vector, euler_char)

For t = gap_step, 2·gap_step, ..., max_gap:
    S_t = {gap_step, 2·gap_step, ..., t}
    Compute face_vector(n, L, S_t)
    Compute euler_char from face_vector
```

### Algorithm 4: Arithmetic Discrepancy

```
Input: n, L, S
Output: discrepancy statistics

1. Compute actual face counts
2. Compute Bernoulli predictions with p = V/L
3. Return (actual - predicted) for each invariant
```

---

## 5. The Prime Window Homology–GUE Conjecture

### 5.1 Statement

Fix 0 < θ < 1. For X > 0, define:
- Window: [⌊X⌋, ⌊X⌋ + ⌊X^θ⌋ - 1]
- Gap filtration: S_t(X) = {2, 4, ..., 2⌊t log X⌋} for t > 0
- Euler curve: Λ_X(t) = χ(K(⌊X⌋, ⌊X^θ⌋, S_t(X)))

**Conjecture.** There exist explicit deterministic normalizations A_X, B_X (depending on X, θ) such that A_X(Λ_X - B_X) converges in distribution as X → ∞ to a universal limit L_θ if and only if Montgomery's pair correlation conjecture holds for the nontrivial zeros of ζ(s).

### 5.2 Testable Predictions

1. The actual-prime Euler curve should differ systematically from the Cramér random model.
2. The discrepancy should grow with a specific power of X determined by the GUE pair correlation.
3. A residue-constrained random model should provide a better fit than the unconstrained Cramér model, but still not match the actual data.

### 5.3 Computational Evidence

Our Python implementation computes Euler curves for windows up to n = 50,000 with L up to 400. Key observations:

- **Edge excess**: Actual primes consistently produce more edges than the Bernoulli prediction, with typical excess of 1.5–3σ.
- **Euler curve shape**: The actual Euler curve has a characteristic dip-and-recovery pattern not seen in Bernoulli samples.
- **Gap-6 dominance**: The gap h = 6 consistently contributes the most edges, reflecting the known excess of sexy primes (compatible with the Hardy-Littlewood conjecture).

| Window | V | E_actual | E_Bernoulli | Excess (σ) |
|--------|---|----------|-------------|------------|
| [100, 199] | 21 | 33 | 21.3 | ~2.0 |
| [1000, 1199] | 28 | 69 | 37.0 | ~2.2 |
| [10000, 10299] | 30 | 45 | 33.5 | ~1.5 |

---

## 6. Computational Experiments

### 6.1 Edge Decomposition Verification

For window [10, 29] with S = {2, 4, 6}:
- Primes: {11, 13, 17, 19, 23, 29}
- V = 6, E = 8, T = 3
- π₂(h=2) = 2 (pairs: 11-13, 17-19)
- π₂(h=4) = 2 (pairs: 13-17, 19-23)
- π₂(h=6) = 4 (pairs: 11-17, 13-19, 17-23, 23-29)
- Sum = 2 + 2 + 4 = 8 = E ✓

### 6.2 Monotonicity Profile

For window [100, 199]:

| Max gap | Edges | Triangles | χ |
|---------|-------|-----------|---|
| 2 | 7 | 0 | 14 |
| 4 | 12 | 0 | 9 |
| 6 | 22 | 5 | 4 |
| 10 | 33 | 17 | 2 |
| 14 | 46 | 36 | 1 |
| 30 | 97 | 206 | 48 |

Edge count is strictly monotone increasing. ✓

### 6.3 Filtration Euler Curve

For window [500, 649] (23 primes), the Euler curve starts at χ = 18 (S = {2}), drops to χ = 1 (S = {2,...,18}), then rises to χ = 22 (S = {2,...,30}). This non-monotone behavior — the "dip-and-recovery" — is characteristic of actual primes and not seen in typical Bernoulli samples.

---

## 7. Discussion

### 7.1 Relationship to Prior Work

The idea of applying topological methods to number-theoretic data is not entirely new. The arithmetic topology program of Morishita [5] studies analogies between knots and primes, but at a conceptual level. Our approach is constructive and computational: we build specific complexes from finite prime data and prove exact theorems about their invariants.

The connection to random simplicial complexes (Kahle [6], Linial-Meshulam [7]) is direct: our Bernoulli surrogate is exactly the Erdős-Rényi random clique complex adapted to the prime-gap setting.

### 7.2 Limitations

The current results are "first-order" — they establish the dictionary but do not yet prove asymptotic theorems about growth rates. The GUE conjecture remains precisely that: a conjecture. Proving it would require deep inputs from analytic number theory (likely the full strength of Montgomery's pair correlation conjecture or its generalizations).

### 7.3 Strengths

1. **Exactness**: All face-count identities are exact equalities, not asymptotic estimates.
2. **Machine verification**: All theorems are verified in Lean 4.
3. **Computability**: All objects are finite and efficiently computable.
4. **Cross-domain**: The framework naturally connects four fields (number theory, topology, TDA, random matrix theory).

---

## 8. Future Work

1. **Asymptotic face counts**: Prove that f₁(K(n, L, S)) ~ C · (L/log²L) · |S| as L → ∞ using prime number theorem estimates.
2. **Higher homology**: Compute H₁ of the prime gap complex and connect to higher-order prime correlations.
3. **Persistent homology**: Implement full persistence computation and compare barcodes against random models.
4. **Phase transitions**: Study the gap threshold at which the complex transitions from many components to connectedness.
5. **GUE testing**: Large-scale computational comparison of Euler curves against GUE predictions.

---

## References

[1] H. L. Montgomery, "The pair correlation of zeros of the zeta function," *Proc. Symp. Pure Math.* 24 (1973), 181–193.

[2] D. A. Goldston, J. Pintz, C. Y. Yıldırım, "Primes in tuples I," *Annals of Mathematics* 170 (2009), 819–862.

[3] G. Carlsson, "Topology and data," *Bull. Amer. Math. Soc.* 46 (2009), 255–308.

[4] H. Edelsbrunner, J. Harer, *Computational Topology: An Introduction*, AMS, 2010.

[5] M. Morishita, *Knots and Primes: An Introduction to Arithmetic Topology*, Springer, 2012.

[6] M. Kahle, "Topology of random clique complexes," *Discrete Mathematics* 309 (2009), 1658–1671.

[7] N. Linial, R. Meshulam, "Homological connectivity of random 2-complexes," *Combinatorica* 26 (2006), 475–487.
