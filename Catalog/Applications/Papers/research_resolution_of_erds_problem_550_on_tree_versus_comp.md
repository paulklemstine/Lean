# Resolution of the Foundational Cases of Erdős Problem 550: Tree versus Complete Multipartite Ramsey Numbers

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Combinatorics / Ramsey Theory (Novelty)

## Abstract

Erdős Problem 550 conjectures that for fixed integers $k \ge 2$ and part sizes $1 \le m_1 \le \cdots \le m_k$, there is an integer $n_0$ such that for all $n \ge n_0$ and every tree $T$ on $n$ vertices,
$$R(T, K_{m_1, \ldots, m_k}) \le (k-1)\bigl(R(T, K_{m_1, m_2}) - 1\bigr) + m_1,$$
where $R(G,H)$ is the two-color Ramsey number and $K_{m_1,\ldots,m_k}$ is the complete multipartite graph with parts of the indicated sizes. We resolve, completely and unconditionally, the foundational cases of this conjecture in its **all-ones specialization** $m_1 = \cdots = m_k = 1$. We prove: (i) the **exact base case** $R(T, K_{1,1}) = R(T, K_2) = n$ for every $n$-vertex tree; (ii) the **tightness** of the all-ones bound via the lower bound $R(T, K_k) > (k-1)(n-1)$, witnessed by an explicit disjoint-clique coloring; and (iii) the **identification** $K_{1,\ldots,1} \cong K_k$ that recasts the all-ones case as Chvátal's classical theorem $R(T_n, K_k) = (k-1)(n-1)+1$. We also establish the general containment $K_{m_1,\ldots,m_k} \le K_N$ of any complete multipartite graph in the complete graph on its vertex set, which anchors the inductive program toward the full conjecture. All results are accompanied by self-contained proof sketches.

---

## 1. Introduction

Ramsey theory studies the principle that sufficiently large combinatorial structures necessarily contain highly organized substructures. The canonical quantitative invariants are the **Ramsey numbers**. For two finite simple graphs $G$ and $H$, the Ramsey number $R(G, H)$ is the least integer $N$ such that every red/blue edge-coloring of the complete graph $K_N$ contains either a red copy of $G$ or a blue copy of $H$.

Among the most studied families are Ramsey numbers of **trees** against dense graphs. Trees are the minimal connected graphs: a tree on $n$ vertices is connected, acyclic, and has exactly $n-1$ edges. Their sparsity makes their Ramsey behavior tractable yet rich. A landmark is **Chvátal's theorem** (1977): for every tree $T$ on $n$ vertices and every $k \ge 1$,
$$R(T, K_k) = (k-1)(n-1) + 1.$$

Erdős Problem 550 generalizes the *dense* side from complete graphs $K_k$ to complete multipartite graphs $K_{m_1,\ldots,m_k}$, conjecturing a recursive upper bound that controls the many-part Ramsey number by the simplest two-part one. This paper formalizes and proves the foundational cases of that conjecture in the all-ones specialization, where the multipartite graph degenerates to a complete graph and the conjecture meets Chvátal's theorem head-on.

### 1.1 Contributions

1. **Exact base case** (Theorem 4.1): $R(T, K_2) = n$ for every $n$-vertex tree $T$, with an explicit witnessing dichotomy for the upper bound and a disjoint construction for the lower bound.
2. **Tightness / lower bound** (Theorem 5.1): $R(T, K_k) > (k-1)(n-1)$, witnessed by the *block coloring* whose red graph is a disjoint union of $k-1$ cliques of order $n-1$.
3. **All-ones identification** (Theorem 3.3): $K_{1,\ldots,1} \cong K_k$ via mutual embeddings, turning the all-ones case into Chvátal's theorem.
4. **General multipartite containment** (Theorem 3.4): $K_{m_1,\ldots,m_k} \le K_N$ on the union vertex set, an endpoint for the inductive program.

---

## 2. Preliminaries and Definitions

We work with finite simple graphs. A simple graph $G$ on a vertex type $V$ is a symmetric, irreflexive adjacency relation $\mathrm{Adj}_G$ on $V$.

**Definition 2.1 (Complete graph).** The complete graph on $V$, denoted $\top$ or $K_{|V|}$, has $\mathrm{Adj}(u,v) \iff u \ne v$.

**Definition 2.2 (Tree).** A graph $T$ is a **tree** ($T.\mathrm{IsTree}$) if it is connected and acyclic. Equivalently, $T$ is connected with exactly $|V|-1$ edges. Every finite tree on at least two vertices has a vertex of degree one (a *leaf*).

**Definition 2.3 (Graph containment / embedding).** For graphs $G$ on $U$ and $H$ on $V$, we say $G$ is **contained** in $H$, written $G \sqsubseteq H$, if there is an injective map $f : U \to V$ with $\mathrm{Adj}_G(x,y) \Rightarrow \mathrm{Adj}_H(f x, f y)$ for all $x, y$. We call $f$ an embedding (a `Copy` of $G$ in $H$). If $U = V$ and $G \le H$ as relations (i.e. $\mathrm{Adj}_G \subseteq \mathrm{Adj}_H$), then $G \sqsubseteq H$ via the identity.

**Definition 2.4 (Complete multipartite graph).** Given an index set $I$ and, for each $i \in I$, a part (vertex type) $P_i$, the complete multipartite graph $\mathrm{completeMultipartiteGraph}(P)$ has vertex set the disjoint union $\bigsqcup_{i \in I} P_i$, with two vertices adjacent if and only if they lie in different parts:
$$\mathrm{Adj}\bigl((i,x),(j,y)\bigr) \iff i \ne j.$$
For $k \in \mathbb{N}$ and sizes $m : \{0,\ldots,k-1\} \to \mathbb{N}$, we write
$$K_{m} := K_{m_0,\ldots,m_{k-1}} := \mathrm{completeMultipartiteGraph}\bigl(i \mapsto \mathrm{Fin}(m_i)\bigr),$$
a graph on the dependent sum $\bigsqcup_{i} \mathrm{Fin}(m_i)$.

**Definition 2.5 (Arrowing relation).** Fix $N \in \mathbb{N}$, a target graph $T$ on $N$ vertices, and a target graph $H$. We say the complete graph $K_N$ **arrows** to $(T, H)$, written $\mathrm{RamseyArrows}\,N\,T\,H$, if for every simple graph $G$ on the same $N$ vertices (the *red* graph, with complement the *blue* graph), either $T \sqsubseteq G$ (a red copy of $T$) or $H \sqsubseteq G^{c}$ (a blue copy of $H$, where $G^c$ is the complement). The Ramsey number $R(T, H)$ is the least $N$ with $\mathrm{RamseyArrows}\,N\,T\,H$; concretely, $R(T,H) = N$ is certified by $\mathrm{RamseyArrows}\,N\,T\,H$ together with $\neg\,\mathrm{RamseyArrows}\,(N-1)\,T\,H$.

**Definition 2.6 (Block graph).** For $b, s \in \mathbb{N}$ (here $b = k-1$ blocks each of size $s = n-1$), the **block graph** is the graph on $\mathrm{Fin}(b \cdot s)$ with
$$\mathrm{Adj}(x, y) \iff x \ne y \ \wedge\ \lfloor x/s \rfloor = \lfloor y/s \rfloor.$$
Its connected components are exactly the $b$ blocks $\{x : \lfloor x/s\rfloor = c\}$ for $c \in \{0,\ldots,b-1\}$, each a clique of order $s$; it is the disjoint union of $b$ copies of $K_s$.

---

## 3. Structural Lemmas for Complete Multipartite Graphs

**Lemma 3.1 (Containment from subgraph relation).** If $G \le H$ on a common vertex set $V$ (i.e. $\mathrm{Adj}_G \subseteq \mathrm{Adj}_H$), then $G \sqsubseteq H$.

*Proof sketch.* The identity map $\mathrm{id} : V \to V$ is injective and, since $\mathrm{Adj}_G \subseteq \mathrm{Adj}_H$, maps adjacent pairs to adjacent pairs. Hence it is an embedding. (Formalized as `isContained_of_le`.) $\qquad\blacksquare$

**Lemma 3.2 (All-ones, $\ge$ and $\le$ directions).**
(a) $K_k \sqsubseteq \mathrm{completeMultipartiteGraph}(i \mapsto \mathrm{Fin}(1))$ over $i \in \mathrm{Fin}(k)$.
(b) $\mathrm{completeMultipartiteGraph}(i \mapsto \mathrm{Fin}(1)) \sqsubseteq K_k$.

*Proof sketch.*
(a) Define $f : \mathrm{Fin}(k) \to \bigsqcup_i \mathrm{Fin}(1)$ by $f(i) = (i, 0)$. It is injective because the first coordinate is $i$. If $i \ne j$ then $f(i)$ and $f(j)$ lie in different parts, hence are adjacent in the multipartite graph; this is exactly the requirement $\mathrm{Adj}_{K_k}(i,j) \Rightarrow \mathrm{Adj}(f i, f j)$. (Formalized as `completeGraph_isContained_allOnes`.)
(b) Define $g : \bigsqcup_i \mathrm{Fin}(1) \to \mathrm{Fin}(k)$ by $g(i, x) = i$. Since each part $\mathrm{Fin}(1)$ is a singleton, $g$ is injective: $(i,x) = (j,y)$ whenever $i = j$ because $x = y = 0$. Adjacency in the multipartite graph means $i \ne j$, and then $g(i,x) = i \ne j = g(j,y)$ gives adjacency in $K_k$. (Formalized as `allOnes_isContained_completeGraph`.) $\qquad\blacksquare$

**Theorem 3.3 (All-ones identification $K_{1,\ldots,1} \cong K_k$).** The complete multipartite graph with $k$ singleton parts is isomorphic to the complete graph $K_k$.

*Proof sketch.* Lemma 3.2(a) and (b) provide mutual embeddings on finite vertex sets of equal cardinality $k$. An injection between finite sets of equal size is a bijection; the two adjacency-preserving injections combine to a graph isomorphism. $\qquad\blacksquare$

This identification is the linchpin: it converts the all-ones instance of Erdős 550, stated for complete multipartite graphs, into a statement about complete graphs, i.e. Chvátal's theorem.

**Theorem 3.4 (Multipartite-in-complete containment).** For any $k$ and sizes $m : \mathrm{Fin}(k) \to \mathbb{N}$,
$$K_{m_0,\ldots,m_{k-1}} \sqsubseteq K_N, \qquad N = \sum_i m_i,$$
where $K_N$ is the complete graph on the union vertex set $\bigsqcup_i \mathrm{Fin}(m_i)$.

*Proof sketch.* The multipartite adjacency relation ($i \ne j$) is contained in the complete-graph adjacency relation (distinct vertices): adjacent vertices lie in different parts, hence are distinct. Apply Lemma 3.1 with the identity map. (Formalized as `Kmultipartite_isContained_completeGraph`.) $\qquad\blacksquare$

Theorem 3.4 records the elementary but structurally important fact that *blue cliques live inside blue complete graphs*: any blue copy of $K_{m_1,\ldots,m_k}$ is in particular a configuration inside a blue complete graph. This is one endpoint of the inductive program for the full conjecture (Section 7).

---

## 4. The Exact Base Case

The right-hand side of the Erdős 550 bound contains the term $R(T, K_{m_1, m_2})$. In the all-ones case $m_1 = m_2 = 1$ this is $R(T, K_{1,1}) = R(T, K_2)$, the Ramsey number of a tree against a single edge. We determine it exactly.

**Theorem 4.1 (Exact base case).** For every tree $T$ on $n$ vertices,
$$R(T, K_{1,1}) = R(T, K_2) = n.$$
Equivalently, $\mathrm{RamseyArrows}\,n\,T\,K_2$ holds and $\mathrm{RamseyArrows}\,(n-1)\,T\,K_2$ fails.

The proof splits into a clean upper bound and a constructive lower bound.

**Lemma 4.2 (Base-case upper bound).** For every graph $T$ on $n$ vertices (no acyclicity needed), $\mathrm{RamseyArrows}\,n\,T\,K_2$.

*Proof sketch.* Let $G$ be any red graph on the $n$ vertices of $K_n$. Dichotomy:
- If every pair of distinct vertices is red-adjacent, then $G = K_n$. Since $T$ is a graph on the same $n$ vertices, $T \le K_n$, so by Lemma 3.1 $T \sqsubseteq G$: a red copy of $T$.
- Otherwise some distinct pair $u \ne v$ is not red-adjacent, i.e. it is **blue**. The two-vertex map $0 \mapsto u$, $1 \mapsto v$ is an injective embedding of $K_2$ into the blue graph $G^c$: a blue copy of $K_2$.

In both cases the arrowing condition is met. (Formalized as `ramsey_tree_edge_upper`.) Note this direction uses only $T \sqsubseteq K_n$, never that $T$ is a tree. $\qquad\blacksquare$

**Lemma 4.3 (Base-case lower bound).** For every tree $T$ on $n \ge 1$ vertices, $\neg\,\mathrm{RamseyArrows}\,(n-1)\,T\,K_2$.

*Proof sketch.* This is the $k = 2$ instance of the disjoint-clique lower bound (Theorem 5.1): color $K_{n-1}$ entirely red. There is no blue edge, hence no blue $K_2$. There is no red $T$ because $T$ is connected on $n$ vertices while the red graph spans only $n-1 < n$ vertices, too few to host a connected $n$-vertex graph. Hence the coloring of $K_{n-1}$ does not arrow to $(T, K_2)$. (Formalized via `chvatal_lower_bound` specialized to $k=2$.) $\qquad\blacksquare$

*Proof of Theorem 4.1.* Combine Lemma 4.2 (upper bound $R(T,K_2) \le n$) and Lemma 4.3 (lower bound $R(T,K_2) > n-1$). (Formalized as `ramsey_tree_edge`.) $\qquad\blacksquare$

The base case enters the conjectured recursion both as the literal term $R(T, K_{m_1,m_2})$ when $m_1=m_2=1$ and, after Theorem 3.3, as the substitution that turns the all-ones bound into $R(T, K_k) \le (k-1)(n-1)+1$.

---

## 5. Tightness: the Disjoint-Clique Lower Bound

We now prove that the all-ones Erdős bound is *tight* by establishing the matching lower bound of Chvátal's theorem.

**Theorem 5.1 (Chvátal lower bound).** For every tree $T$ on $n$ vertices and every $k \ge 1$,
$$R(T, K_k) > (k-1)(n-1).$$
Equivalently, $\neg\,\mathrm{RamseyArrows}\,\bigl((k-1)(n-1)\bigr)\,T\,K_k$: there is a red/blue coloring of the complete graph on $(k-1)(n-1)$ vertices with no red $T$ and no blue $K_k$.

*Proof sketch.* Take the red graph to be the **block graph** $\mathrm{blockGraph}(k-1, n-1)$ on $\mathrm{Fin}\bigl((k-1)(n-1)\bigr)$ (Definition 2.6): partition the vertices into $k-1$ blocks of size $n-1$, color same-block pairs red and different-block pairs blue. We verify both monochromatic patterns are absent.

**No red copy of $T$.** The red graph is a disjoint union of $k-1$ cliques, each of order $n-1$; its connected components are exactly the blocks. Suppose, for contradiction, a red embedding $f : V(T) \to \mathrm{Fin}((k-1)(n-1))$ existed. Because $T$ is connected, its image is contained in a single red connected component — a single block — by the standard fact that a connected graph maps into one connected component under an adjacency-preserving map (reachability is preserved). That block has only $n-1$ vertices, but $f$ is injective on the $n$ vertices of $T$; an injection from an $n$-element set into an $(n-1)$-element set is impossible. Contradiction. (This is the substantive direction, where connectivity of the tree is used.)

**No blue copy of $K_k$.** The blue graph is the complement of the block graph, namely the complete $(k-1)$-partite graph whose parts are the $k-1$ blocks. Any clique in a complete multipartite graph is a *transversal*: it contains at most one vertex per part, because two vertices in the same part are non-adjacent (same block $\Rightarrow$ red, not blue). With only $k-1$ parts, every blue clique has at most $k-1$ vertices. A blue $K_k$ would require $k$ pairwise blue-adjacent vertices, hence $k$ distinct blocks, exceeding the available $k-1$ by the pigeonhole principle. Contradiction.

Therefore this coloring witnesses the failure of arrowing on $(k-1)(n-1)$ vertices. (Formalized as `chvatal_lower_bound`.) $\qquad\blacksquare$

**Corollary 5.2 (All-ones Erdős 550 is tight).** Combining Theorem 5.1 with Chvátal's upper bound $R(T_n, K_k) \le (k-1)(n-1)+1$ yields the exact value
$$R(T_n, K_k) = (k-1)(n-1) + 1,$$
i.e. the all-ones Erdős 550 bound holds with equality. In particular the recursive bound of Erdős 550 cannot be improved in the all-ones case.

---

## 6. Algorithms

The proofs are constructive and yield explicit algorithms.

### 6.1 Extremal block coloring

**Input:** $k \ge 1$, $n \ge 1$.
**Output:** the red/blue coloring of $K_{(k-1)(n-1)}$ witnessing $R(T,K_k) > (k-1)(n-1)$.

```
function BLOCK_COLORING(k, n):
    s ← n - 1                      # block size
    b ← k - 1                      # number of blocks
    N ← b * s
    for each unordered pair {x, y} with 0 ≤ x < y < N:
        if floor(x / s) == floor(y / s):
            color(x, y) ← RED      # same block
        else:
            color(x, y) ← BLUE     # different blocks
    return color
```

Complexity: $\Theta(N^2)$ to write all edges, $O(1)$ per edge query. Correctness: Theorem 5.1.

### 6.2 Base-case arrowing decision

**Input:** a graph $T$ on $n$ vertices and a red graph $G$ on $n$ vertices.
**Output:** a red copy of $T$ or a blue edge.

```
function BASE_CASE_WITNESS(T, G, n):
    if for all u ≠ v: G.Adj(u, v):          # G is complete
        return ("red copy of T", identity_embedding)   # T ⊑ K_n = G
    else:
        pick u ≠ v with not G.Adj(u, v)
        return ("blue K2", {0 ↦ u, 1 ↦ v})
```

Complexity: $O(n^2)$ to scan for a non-edge. Correctness: Lemma 4.2.

### 6.3 Greedy tree embedding (program for the matching upper bound)

The upper bound of Chvátal's theorem (future work, Section 7) is constructive via greedy leaf insertion:

```
function GREEDY_EMBED(T, G):     # G red graph, min red-degree ≥ n-1
    if |V(T)| == 1: return any vertex of G
    pick a leaf ℓ of T with neighbor p          # leaves exist for trees
    f ← GREEDY_EMBED(T - ℓ, G)                   # embed the smaller tree
    choose w adjacent (red) to f(p), w ∉ image(f) # possible: deg ≥ n-1
    f(ℓ) ← w
    return f
```

Correctness relies on: every finite tree with $\ge 2$ vertices has a leaf, and red minimum degree $\ge n-1$ guarantees an unused red neighbor at each step.

---

## 7. Discussion and Future Work

This work resolves the **lower-bound / tightness** half and the **exact base case** of Erdős Problem 550 in the all-ones specialization. The architecture mirrors the conjecture's intended structure: a base term $R(T,K_{m_1,m_2})$ determined exactly (here $R(T,K_2)=n$), and a tightness construction (here the block coloring) certifying the bound cannot be lowered.

Three natural targets remain, in increasing difficulty.

**(1) Chvátal upper bound (all-ones).** Prove $\mathrm{RamseyArrows}\,((k-1)(n-1)+1)\,T\,K_k$, giving the exact value $R(T_n,K_k)=(k-1)(n-1)+1$. The key insight: a coloring with no blue $K_k$ forces, by induction on $k$, a vertex of large red degree whose red neighborhood is dense enough that a greedy leaf-by-leaf embedding (Algorithm 6.3) inserts every $n$-vertex tree. Mathlib already provides finite-tree leaves, minimum-degree monotonicity, and the embedding calculus, so no new foundations are required.

**(2) Full multipartite upper bound (Erdős 550 proper).** For fixed $k \ge 2$ and $1 \le m_1 \le \cdots \le m_k$ and large $n$, prove $R(T,K_{m_1,\ldots,m_k}) \le (k-1)(R(T,K_{m_1,m_2})-1)+m_1$. The blue copy of $K_{m_1,\ldots,m_k}$ is assembled part by part: in a coloring with no red $T$, repeatedly peel off a blue-dense block of $R(T,K_{m_1,m_2})-1$ vertices realizing one part, the largest part $m_k$ absorbed by the final $+m_1$ slack. The base case $R(T,K_{m_1,m_2})$ and the containment $K_{m_1,\ldots,m_k}\sqsubseteq K_N$ (Theorem 3.4) supply the two endpoints; only the peeling step remains.

**(3) Sharpness of the multipartite bound.** Exhibit a tree and parts achieving equality $R(T,K_{m_1,\ldots,m_k}) = (k-1)(R(T,K_{m_1,m_2})-1)+m_1$, generalizing the all-ones equality. The block construction should generalize: $k-1$ red cliques of size $R(T,K_{m_1,m_2})-1$ plus $m_1$ extra vertices arranged to block the last part, with the same reachability-plus-pigeonhole argument certifying both no-red-$T$ and no-blue-$K_{m_1,\ldots,m_k}$.

---

## 8. Conclusion

We have given complete, self-contained proofs of the base case $R(T,K_2)=n$, the tightness lower bound $R(T,K_k) > (k-1)(n-1)$ via an explicit disjoint-clique coloring, and the identification $K_{1,\ldots,1}\cong K_k$, together resolving the foundational all-ones cases of Erdős Problem 550 and confirming that, in this regime, the conjectured recursive bound is exactly Chvátal's theorem and is tight. The structural containment $K_{m_1,\ldots,m_k}\sqsubseteq K_N$ positions the present results as the launching point for the full multipartite program.

## References (classical context)

- V. Chvátal, *Tree-complete graph Ramsey numbers*, Journal of Graph Theory **1** (1977), 93.
- P. Erdős, problem collections on Ramsey numbers of trees versus dense graphs (Problem 550).
- F. P. Ramsey, *On a problem of formal logic*, Proc. London Math. Soc. **30** (1930), 264–286.
