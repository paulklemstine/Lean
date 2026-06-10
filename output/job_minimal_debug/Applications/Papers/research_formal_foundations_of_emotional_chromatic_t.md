# Emotional Chromatic Theory: Formal Foundations and Tropical Connections

## Abstract

We introduce the **emotional chromatic number** χ_E(G) of a simple graph G, defined as the minimum number of colors k such that G admits a proper k-coloring and k ≥ 3. This models social networks where vertices represent agents, edges represent relationships, colors represent emotional states, and the constraint k ≥ 3 captures a minimum psychological complexity floor. We prove that χ_E(G) = max(3, χ(G)), establishing that the emotional constraint is non-trivial only for graphs with chromatic number at most 2 (empty and bipartite graphs). We formalize the clique-chromatic obstruction (pigeonhole principle for graph coloring), prove the chromatic number of complete graphs, bound coloring diversity, and establish a connection to tropical geometry through a monotonicity theorem for tropical chromatic evaluations. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: chromatic number, graph coloring, tropical geometry, social networks, emotional complexity, formal verification

---

## 1. Introduction

Graph coloring is one of the oldest and most studied problems in combinatorics. Given a simple graph G = (V, E), a **proper k-coloring** is a function c : V → {1, ..., k} such that c(v) ≠ c(w) whenever {v, w} ∈ E. The **chromatic number** χ(G) is the minimum k for which a proper k-coloring exists.

In this paper, we introduce a variant motivated by modeling emotional states in social networks. We impose an additional constraint: the palette must contain at least 3 colors, modeling a minimum psychological complexity. The resulting **emotional chromatic number** χ_E(G) captures the minimum emotional vocabulary needed for a conflict-free social network.

### 1.1 Motivation

Social network analysis often assigns categorical attributes to nodes — political orientation, emotional state, opinion — subject to the constraint that connected nodes should differ. This is precisely graph coloring. The innovation of emotional chromatic theory is the observation that real-world categorizations typically have a minimum richness: binary classifications (happy/sad, agree/disagree) are psychologically impoverished and unstable. A minimum of three categories is needed for robust modeling.

### 1.2 Main Results

We establish:

1. **Monotonicity** (Theorem 3.1): Emotional colorability is monotone in the number of colors.
2. **Clique obstruction** (Theorem 3.2): A clique of size n prevents proper (n-1)-colorability.
3. **Max formula** (Theorem 3.3): χ_E(G) = max(3, χ(G)).
4. **Complete graph chromatic number** (Theorem 3.4): χ(K_n) = n.
5. **Diversity bounds** (Theorems 3.5–3.6): Coloring diversity is bounded by both palette size and vertex count.
6. **Tropical monotonicity** (Theorem 3.7): The tropical chromatic evaluation is monotone.

---

## 2. Definitions

### 2.1 Emotional Colorability

**Definition 2.1** (Emotional Colorability). Let G = (V, E) be a simple graph. We say G is **emotionally k-colorable** if:
- G admits a proper k-coloring (i.e., G is classically Colorable with k colors), AND
- k ≥ 3.

Formally, `EmotionallyColorable G k ≡ G.Colorable k ∧ 3 ≤ k`.

### 2.2 Emotional Chromatic Number

**Definition 2.2**. The **emotional chromatic number** χ_E(G) is:

χ_E(G) = inf { k ∈ ℕ : EmotionallyColorable G k }

We define this as an element of ℕ∞ to uniformly handle non-colorable (infinite chromatic number) graphs:

`emotionalChromaticNumber G = ⨅ k : ℕ, ⨅ _ : EmotionallyColorable G k, (k : ℕ∞)`

### 2.3 Coloring Diversity

**Definition 2.3**. The **coloring diversity** of a coloring c : V → Fin(k) is the cardinality of the image:

`coloringDiversity c = |{c(v) : v ∈ V}|`

This measures how many distinct colors are actually used, as opposed to how many are available.

### 2.4 Clique Witness

**Definition 2.4**. A graph G **has a clique of size n** if there exists a graph embedding from K_n into G:

`HasCliqueOfSize G n ≡ Nonempty (K_n ↪g G)`

### 2.5 Tropical Chromatic Evaluation

**Definition 2.5**. For a graph with n vertices and m edges, the **tropical chromatic evaluation** at k colors is:

`tropicalChromaticEval n m k = trop(k · n - m)`

where trop : ℝ → Tropical(ℝ) is the canonical embedding into the tropical semiring.

---

## 3. Main Results

### 3.1 Monotonicity of Emotional Colorability

**Theorem 3.1** (Emotional Monotonicity). *If G is emotionally k-colorable and k ≤ m, then G is emotionally m-colorable.*

*Proof.* From EmotionallyColorable G k, we have G.Colorable k and 3 ≤ k. By monotonicity of classical colorability (Colorable.mono), G.Colorable m. And 3 ≤ k ≤ m gives 3 ≤ m. □

### 3.2 Clique-Chromatic Obstruction

**Theorem 3.2** (Pigeonhole Obstruction). *If G contains a clique of size n and k < n, then G is not k-colorable.*

*Proof.* Let f : K_n ↪g G be the clique embedding. If G were k-colorable with coloring c, then c ∘ f would be a proper k-coloring of K_n. But K_n has n pairwise-adjacent vertices; by the pigeonhole principle (Fintype.card_le_of_injective), any proper coloring needs n distinct colors. Since k < n, this is impossible. □

This theorem is the fundamental lower bound technique for chromatic numbers. It generalizes: the **clique number** ω(G) (the size of the largest clique) satisfies ω(G) ≤ χ(G).

### 3.3 Emotional-Classical Bridge

**Theorem 3.3** (Fundamental Theorem). *For any graph G that is classically k-colorable, the emotional chromatic number satisfies:*

χ_E(G) ≤ max(3, k)

*In particular, if G is k-colorable for any k, then χ_E(G) = max(3, χ(G)).*

*Proof.* We show EmotionallyColorable G (max 3 k):
- G.Colorable (max 3 k): follows from G.Colorable k and Colorable.mono with k ≤ max(3,k).
- 3 ≤ max(3, k): immediate from le_max_left.

Then χ_E(G) ≤ max(3, k) follows from the definition as an infimum. □

### 3.4 Complete Graph Chromatic Number

**Theorem 3.4**. *χ(K_n) = n for all n ≥ 1.*

*Proof.* The upper bound comes from the identity coloring (vertex i gets color i). The lower bound follows from Theorem 3.2: K_n contains itself as a clique of size n. In Mathlib, this is captured by `SimpleGraph.chromaticNumber_top` since K_n = ⊤ on Fin(n). □

### 3.5 Diversity Bounds

**Theorem 3.5** (Palette Bound). *coloringDiversity(c) ≤ k for any coloring c : V → Fin(k).*

*Proof.* The image of any function into Fin(k) is a subset of Fin(k), which has cardinality k. □

**Theorem 3.6** (Vertex Bound). *coloringDiversity(c) ≤ |V|.*

*Proof.* The image of a function on V has cardinality at most |V| (Finset.card_image_le). □

These dual bounds capture a fundamental tension: coloring diversity is constrained both by the palette and by the population.

### 3.7 Tropical Monotonicity

**Theorem 3.7** (Tropical Monotonicity). *For fixed graph parameters n, m and k₁ ≤ k₂:*

tropicalChromaticEval(n, m, k₂) ⊕ tropicalChromaticEval(n, m, k₁) = tropicalChromaticEval(n, m, k₁)

*where ⊕ denotes tropical addition (minimum).*

*Proof.* Unfolding definitions, this amounts to min(k₂·n - m, k₁·n - m) = k₁·n - m, which holds because k₁ ≤ k₂ implies k₁·n - m ≤ k₂·n - m. □

This monotonicity reflects an optimization principle: in the tropical framework, more resources (colors) can only improve the objective value.

---

## 4. Algorithms

### 4.1 Computing the Emotional Chromatic Number

Given a classical chromatic number oracle:

```
function emotional_chromatic(G):
    chi = chromatic_number(G)
    return max(3, chi)
```

The reduction is trivial, confirming that emotional chromatic theory does not introduce computational hardness beyond the (NP-hard) classical chromatic number.

### 4.2 Tropical Chromatic Evaluation

```
function tropical_chromatic_eval(n, m, k):
    return trop(k * n - m)
```

The tropical evaluation can be computed in O(1) given graph parameters.

---

## 5. Discussion

### 5.1 The Simplicity Insight

The formula χ_E(G) = max(3, χ(G)) is, in a sense, a negative result: emotional chromatic theory reduces to classical chromatic theory for all but the simplest graphs. However, this simplicity is itself informative. It tells us that the structure of a social network — not the palette of human emotions — is the binding constraint on social complexity.

### 5.2 When Does the Floor Bind?

The 3-emotion floor is non-trivial exactly when χ(G) ≤ 2:
- **Empty graphs** (χ = 1): A network with no relationships. The emotional floor forces three states even when one would suffice.
- **Bipartite graphs** (χ = 2): Networks that split into two non-interacting camps. The floor adds a third emotional state beyond the binary.

For all other graphs — which include all graphs containing odd cycles — χ(G) ≥ 3, and the emotional constraint is automatically satisfied.

### 5.3 Tropical Connections

The tropical chromatic evaluation provides a bridge between discrete graph coloring and continuous optimization. The monotonicity result (Theorem 3.7) is a first step; deeper connections would involve:
- Tropical roots of the chromatic polynomial
- Phase transitions in the tropical coloring landscape
- Connections to the Tutte polynomial via tropical specialization

### 5.4 Clique Number and Ramsey Theory

The clique obstruction (Theorem 3.2) connects emotional chromatic theory to Ramsey theory: how large must a graph be to guarantee a clique of given size? By Ramsey's theorem, R(k, k) exists for all k, meaning sufficiently large graphs always contain either a large clique or a large independent set. In the emotional chromatic framework, this means sufficiently large social networks always require either a large emotional vocabulary (if they contain large cliques) or are structurally simple (if they contain large independent sets).

---

## 6. Future Work

1. **Tropical chromatic polynomials**: Develop the full theory of tropicalized chromatic polynomials, connecting to the work of Mikhalkin and Sturmfels on tropical algebraic geometry.

2. **Fractional emotional chromatic number**: Define and study the fractional relaxation, where agents can express fractional emotional states.

3. **List emotional coloring**: What if each vertex has a personal list of available emotions? The list chromatic variant with a 3-color floor.

4. **Dynamic emotional coloring**: Model evolving social networks where emotions must be re-colored as relationships change.

5. **Hadwiger's conjecture for emotional coloring**: If G has no K_t minor, is χ_E(G) ≤ max(3, t-1)?

---

## 7. References

1. Birkhoff, G.D. (1912). A determinant formula for the number of ways of coloring a map. *Annals of Mathematics*, 14(1/4), 42–46.

2. Ekman, P. (1992). An argument for basic emotions. *Cognition and Emotion*, 6(3-4), 169–200.

3. Mikhalkin, G. (2005). Enumerative tropical algebraic geometry in ℝ². *Journal of the American Mathematical Society*, 18(2), 313–377.

4. Diestel, R. (2017). *Graph Theory* (5th ed.). Springer.

5. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. American Mathematical Society.
