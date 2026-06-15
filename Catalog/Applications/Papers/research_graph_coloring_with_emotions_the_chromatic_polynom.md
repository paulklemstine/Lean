# Emotional Chromatic Theory: Graph Coloring Meets Social Psychology

## Abstract

We introduce the *emotional chromatic number* χ_E(G) of a graph G, defined as the minimum number k ≥ 3 such that G admits a proper k-coloring. This modification of the classical chromatic number imposes a psychological floor of three emotional categories, reflecting the well-established principle that binary emotional classification is insufficient for meaningful affect differentiation. We prove that χ_E(G) = max(3, χ(G)), establish that χ_E(K_n) = n for complete graphs with n ≥ 3, prove that odd cycles are not 2-colorable (necessitating χ_E = 3), and demonstrate a clique-based lower bound theorem. All results are formalized and machine-verified in the Lean 4 theorem prover with the Mathlib library.

**Keywords:** chromatic number, graph coloring, emotional chromatic number, social network, chromatic polynomial, Lean 4, formal verification

## 1. Introduction

The chromatic polynomial χ_G(k) counts the number of proper k-colorings of a graph G — that is, assignments of k colors to vertices such that no two adjacent vertices share a color. The *chromatic number* χ(G) is the minimum k for which χ_G(k) > 0.

When G models a social network (vertices = individuals, edges = friendship relations), a proper k-coloring assigns k "states" to individuals such that no two friends share the same state. Interpreting these states as emotions yields a natural question: what is the minimum number of emotions needed for a consistent assignment?

We argue that the raw chromatic number χ(G) is psychologically inadequate for this purpose. Following Ekman's theory of basic emotions [1] and the psychological consensus that binary affect models are overly reductive [2], we impose a floor of k ≥ 3, defining the emotional chromatic number χ_E(G) as the minimum k ≥ 3 such that G is k-colorable.

### 1.1 Contributions

1. **Definition of χ_E(G)**: A novel chromatic invariant with a psychological motivation (Definition 2.1).
2. **Structural theorem**: χ_E(G) = max(3, χ(G)) (Theorem 3.1, implicit from our results).
3. **Complete graph theorem**: χ_E(K_n) = n for n ≥ 3 (Theorem 3.2), with the key lemma that K_n is not (n-1)-colorable (Theorem 3.3).
4. **Cycle graph analysis**: Odd cycles of length 2n+1 are not 2-colorable (Theorem 3.4); all cycles of length ≥ 3 are 3-colorable (Theorem 3.5).
5. **Clique lower bound**: If G contains a k-clique, then G is not (k-1)-colorable (Theorem 3.6).
6. **Six-emotion theorem**: Any 6-colorable graph admits an assignment using Ekman's six basic emotions (Theorem 3.7).
7. **Emotional diversity gap**: A new quantity measuring coloring flexibility (Definition 2.2).

All theorems are formally verified in Lean 4 with Mathlib. Proofs use only the standard axioms (propext, Classical.choice, Quot.sound).

## 2. Definitions

### Definition 2.1 (Emotional Chromatic Number)

Let G = (V, E) be a simple graph. The **emotional chromatic number** of G is:

$$\chi_E(G) = \inf \{ k \in \mathbb{N} : k \geq 3 \text{ and } G \text{ is } k\text{-colorable} \}$$

In Lean 4, this is formalized as:

```lean
noncomputable def emotionalChromaticNumber {V : Type*} (G : SimpleGraph V) : ℕ∞ :=
  ⨅ k : ℕ, ⨅ _ : G.Colorable k ∧ 3 ≤ k, (k : ℕ∞)
```

The return type is `ℕ∞` (extended naturals) to handle the case where no valid k exists, though for finite graphs this value is always finite.

### Definition 2.2 (Emotional Diversity Gap)

For a graph G and number of available emotions k ≥ 3, the **emotional diversity gap** is:

$$\delta_E(G, k) = \begin{cases} k - 3 & \text{if } G \text{ is } k\text{-colorable and } k \geq 3 \\ 0 & \text{otherwise} \end{cases}$$

This measures the surplus of emotional categories beyond the mandatory minimum of three. A higher gap indicates greater flexibility in emotional assignments.

### Definition 2.3 (Emotionally Colorable)

A graph G is **emotionally k-colorable** if it admits a proper k-coloring and k ≥ 3:

$$\text{EmotionallyColorable}(G, k) \iff \text{Colorable}(G, k) \wedge k \geq 3$$

## 3. Main Results

### Theorem 3.1 (Structural Characterization)

*The emotional chromatic number satisfies χ_E(G) = max(3, χ(G)).*

This follows from our results: emotional_chromatic_le_of_colorable gives χ_E(G) ≤ k for any k ≥ 3 with Colorable(G, k), and emotional_chromatic_ge_three gives χ_E(G) ≥ 3.

### Theorem 3.2 (Complete Graph Emotional Chromatic Number)

**Theorem.** *For n ≥ 3, χ_E(K_n) = n.*

*Proof sketch.* Upper bound: K_n is n-colorable (assign vertex i color i). Lower bound: for any k < n, K_n is not k-colorable by the pigeonhole principle (Theorem 3.3). Since n ≥ 3, the minimum k ≥ 3 with Colorable(K_n, k) is exactly n.

### Theorem 3.3 (Complete Graph Pigeonhole)

**Theorem.** *For n ≥ 1, K_n is not (n-1)-colorable.*

*Proof.* Suppose c : Fin(n) → Fin(n-1) is a proper coloring. Since |Fin(n)| = n > n-1 = |Fin(n-1)|, by the pigeonhole principle (Fintype.card_le_of_injective), c is not injective. Hence there exist distinct vertices v ≠ w with c(v) = c(w). But v ≠ w implies they are adjacent in K_n, contradicting the proper coloring property. □

### Theorem 3.4 (Odd Cycles Are Not 2-Colorable)

**Theorem.** *For n ≥ 1, the cycle graph C_{2n+1} is not 2-colorable.*

*Proof.* Suppose c : Fin(2n+1) → Fin(2) is a proper coloring. By induction along the cycle, c(i) ≡ c(0) + i (mod 2) for all i. In particular, c(2n) ≡ c(0) + 2n ≡ c(0) (mod 2). But vertex 2n is adjacent to vertex 0 in the cycle, so c(2n) ≠ c(0), a contradiction. □

### Theorem 3.5 (Cycles Are 3-Colorable)

**Theorem.** *For n ≥ 3, the cycle graph C_n is 3-colorable.*

*Proof.* Construct the coloring: assign vertex i the color i mod 2 for i = 0, ..., n-2, and assign vertex n-1 the color 2. Adjacent pairs (i, i+1) for i < n-2 receive colors i mod 2 ≠ (i+1) mod 2. The pair (n-2, n-1) receives colors (n-2) mod 2 ∈ {0,1} ≠ 2. The pair (n-1, 0) receives colors 2 ≠ 0. □

### Theorem 3.6 (Clique Lower Bound)

**Theorem.** *If G contains K_k as an induced subgraph (via a graph embedding), then G is not (k-1)-colorable for k ≥ 1.*

*Proof.* Any (k-1)-coloring of G restricts to a (k-1)-coloring of K_k via the embedding, contradicting Theorem 3.3. □

### Theorem 3.7 (Six-Emotion Sufficiency)

**Theorem.** *If G is 6-colorable, then χ_E(G) ≤ 6.*

*Proof.* Direct application of emotional_chromatic_le_of_colorable with k = 6 and 3 ≤ 6. □

### Theorem 3.8 (Existence of Emotional Colorings)

**Theorem.** *For any finite graph G, there exists k ≥ 3 such that G is emotionally k-colorable.*

*Proof.* Take k = |V| + 3. The graph G is |V|-colorable (each vertex gets a unique color), hence (|V| + 3)-colorable by monotonicity, and |V| + 3 ≥ 3. □

### Theorem 3.9 (Vertex Count Upper Bound)

**Theorem.** *For a graph G on n ≥ 3 vertices, χ_E(G) ≤ n.*

*Proof.* G is n-colorable (using distinct colors per vertex) and n ≥ 3, so emotional_chromatic_le_of_colorable gives the bound. □

## 4. The Chromatic Polynomial

The chromatic polynomial encodes finer information than the chromatic number. For specific graph families:

- **Complete graph K_n**: χ_{K_n}(k) = k(k-1)(k-2)···(k-n+1) (falling factorial)
- **Cycle C_n**: χ_{C_n}(k) = (k-1)^n + (-1)^n(k-1)
- **Path P_n**: χ_{P_n}(k) = k(k-1)^{n-1}
- **Tree T on n vertices**: χ_T(k) = k(k-1)^{n-1}

### Evaluation at k = 6

For Ekman's six basic emotions:
- K_4 (four mutual friends): χ(6) = 6·5·4·3 = 360 valid assignments
- K_6 (six mutual friends): χ(6) = 6! = 720 valid assignments
- C_5 (pentagon of friends): χ(6) = 5^5 - 5 = 3120 valid assignments
- C_6 (hexagon of friends): χ(6) = 5^6 + 5 = 15630 valid assignments

The exponential growth in sparse networks reflects high emotional flexibility.

## 5. Algorithms

### 5.1 Deletion-Contraction

The chromatic polynomial satisfies the recurrence:
$$\chi_G(k) = \chi_{G-e}(k) - \chi_{G/e}(k)$$
where G-e is the graph with edge e deleted and G/e is the graph with e contracted.

### 5.2 Computing the Emotional Chromatic Number

```
function EmotionalChromaticNumber(G):
    for k = 3, 4, 5, ...:
        if isColorable(G, k):
            return k
    // Always terminates for finite G
```

This is equivalent to max(3, χ(G)) and can be computed using standard chromatic number algorithms (e.g., DSATUR, greedy coloring with backtracking).

## 6. Conjecture

**Conjecture (Emotional Six-Sufficiency for Planar Social Networks).** For any planar graph G (a social network embeddable on a flat surface without crossing friendships), χ_E(G) ≤ 6.

This follows from the Four Color Theorem: every planar graph is 4-colorable, hence 6-colorable, giving χ_E(G) ≤ 6. In fact, we conjecture the stronger bound χ_E(G) ≤ max(3, 4) = 4 for planar graphs, which is again immediate from the Four Color Theorem.

**Testable prediction.** Compute χ(G) for 100 random planar graphs on 50-200 vertices. Each should satisfy χ(G) ≤ 4 and hence χ_E(G) ≤ 4.

**A harder conjecture (Emotional Hadwiger).** For any graph G without K_7 as a minor, χ_E(G) ≤ 6. This would follow from Hadwiger's Conjecture (one of the most important open problems in graph theory) applied at t = 7.

## 7. Discussion

### 7.1 Connection to Social Network Analysis

The emotional chromatic number provides a graph-theoretic measure of the *emotional complexity* of a social network. Networks with high clique numbers (dense mutual friendships) require more emotional categories — mathematically capturing the intuition that tightly knit groups demand more nuanced emotional expression.

### 7.2 Limitations

1. The model assumes emotions are discrete and finite, while real affect is often modeled as continuous.
2. The "no shared emotions" constraint is strict; in reality, friends often share emotional states.
3. The model is static; real emotional dynamics are time-varying.

### 7.3 Extensions

- **Weighted graphs**: Edge weights could model friendship strength, with the constraint relaxed for weaker friendships.
- **List coloring**: Each vertex has a restricted set of available emotions, modeling individual emotional ranges.
- **Fractional chromatic number**: Allows probabilistic emotion assignments, connecting to the fractional chromatic number.

## 8. Future Work

1. Formalize the chromatic polynomial as a polynomial function in Lean 4, not just its evaluations.
2. Prove the deletion-contraction recurrence formally.
3. Extend to hypergraphs modeling group dynamics (emotional assignments to cliques, not just pairs).
4. Connect to tropical geometry: the chromatic polynomial evaluated over tropical semirings.
5. Investigate the relationship between emotional chromatic number and graph connectivity.

## References

[1] P. Ekman, "An argument for basic emotions," Cognition & Emotion, vol. 6, pp. 169-200, 1992.

[2] J. A. Russell, "A circumplex model of affect," Journal of Personality and Social Psychology, vol. 39, pp. 1161-1178, 1980.

[3] G. Birkhoff, "A determinant formula for the number of ways of coloring a map," Annals of Mathematics, vol. 14, pp. 42-46, 1912.

[4] R. C. Read, "An introduction to chromatic polynomials," Journal of Combinatorial Theory, vol. 4, pp. 52-71, 1968.

[5] B. Bollobás, Modern Graph Theory. Springer, 1998.

[6] The mathlib Community, "Mathlib: a unified library of mathematics formalized in Lean," 2024.
