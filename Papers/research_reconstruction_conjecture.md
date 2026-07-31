# Survival Multiplicities in Vertex-Deleted Graph Decks

**Aristotle**  
**July 31, 2026**

## Abstract

For a finite simple graph, its vertex deck is the multiset of induced subgraphs obtained by deleting one vertex at a time, with cards considered up to isomorphism. The Reconstruction Conjecture asserts that every finite simple graph of order at least three is determined up to isomorphism by this deck. The conjecture is open in general. This paper develops a self-contained counting framework for information visible across the deck. We prove a uniform-family double-counting identity, derive Kelly’s counting lemma for induced subgraphs, specialize it to an exact edge-sum identity, and show that edge count is reconstructible from any deck of order at least three. As consequences, edgeless and complete graphs of order at least three are reconstructible. We also describe direct algorithms for constructing cards, counting surviving induced patterns, and recovering edge counts, with complexity bounds and worked examples. The results isolate a general visibility principle: a feature supported on exactly $k$ vertices survives in exactly $n-k$ one-vertex-deleted observations.

## 1. Introduction

A graph may be observed indirectly through a collection of damaged copies. Given a finite simple graph $G$, delete each vertex in turn, together with all incident edges. Forget the names of the remaining vertices and retain the resulting collection of isomorphism types. The central question is whether this collection determines $G$.

The **Reconstruction Conjecture** states that every finite simple graph with at least three vertices is determined up to isomorphism by its vertex deck. This paper does not claim a proof of that conjecture. Instead, it establishes the counting core that explains why many numerical invariants can be read from a deck and proves reconstruction at the two extremal edge densities.

The central mechanism is double counting. If an object uses $k$ vertices of an $n$-vertex ambient set, then it survives deletion of exactly those $n-k$ vertices outside its support. Summed over all deletion cards, every such object is therefore counted with multiplicity $n-k$. Applied to induced copies of a fixed graph $F$, this gives Kelly’s counting lemma. Applied to a single edge, it shows that the sum of all card-edge counts is $(n-2)$ times the original number of edges.

The restriction $n\ge3$ is essential for edge recovery by this equation: only then is $n-2$ positive and cancellable. It also reflects the natural threshold in the Reconstruction Conjecture. For a two-vertex graph, every vertex-deleted card is a one-vertex graph, whether the original pair was adjacent or not; reconstruction fails.

The paper proceeds from definitions to general counting, then to graph-specific consequences. Algorithms and examples make the identities directly testable. The final sections discuss limitations, applications, and routes toward stronger reconstruction results.

## 2. Finite graphs, cards, and decks

### 2.1 Finite simple graphs

A **finite simple graph** is a pair $G=(V,E)$ where $V$ is a finite set and

$$
E\subseteq \bigl\{\{x,y\}:x,y\in V,\ x\ne y\bigr\}.
$$

Thus edges are unordered pairs of distinct vertices; loops and parallel edges are excluded. The **order** of $G$ is $|V|$, and its **size** is $|E|$.

Two finite simple graphs $G=(V,E)$ and $H=(W,D)$ are **isomorphic**, written $G\cong H$, if there is a bijection $\varphi:V\to W$ such that

$$
\{x,y\}\in E \quad\Longleftrightarrow\quad \{\varphi(x),\varphi(y)\}\in D
$$

for all distinct $x,y\in V$. Isomorphism preserves all graph properties that do not depend on vertex names, including order and edge count.

### 2.2 Induced subgraphs and vertex cards

For $S\subseteq V$, the **induced subgraph** $G[S]$ has vertex set $S$ and includes precisely those edges of $G$ whose two endpoints lie in $S$:

$$
E(G[S])=\bigl\{\{x,y\}\in E(G):x,y\in S\bigr\}.
$$

For $v\in V$, the **vertex-deleted card at $v$** is

$$
G-v:=G[V\setminus\{v\}].
$$

The **vertex deck** of $G$ is the multiset

$$
\mathcal D(G)=\bigl\{[G-v]:v\in V\bigr\},
$$

where $[G-v]$ denotes the isomorphism class of the card and multiplicities are retained. Repeated cards matter: a symmetric graph may yield the same isomorphism type many times.

For explicit comparison, say that $G$ and $H$ have the **same paired deck** if there is a bijection $\psi:V(G)\to V(H)$ such that

$$
G-v\cong H-\psi(v)
$$

for every $v\in V(G)$. For finite decks this expresses equality of the multisets of card isomorphism types together with a choice of matching. In particular, graphs with the same paired deck have equal order.

A graph $G$ of order at least three is **reconstructible** if every graph $H$ with the same vertex deck is isomorphic to $G$.

### 2.3 Uniform families and survival

Let $V$ be a finite set of size $n$. A family $\mathcal A$ of subsets of $V$ is **$k$-uniform** if every member has cardinality $k$:

$$
S\in\mathcal A\quad\Longrightarrow\quad |S|=k.
$$

For each $v\in V$, define the surviving subfamily

$$
\mathcal A_v=\{S\in\mathcal A:v\notin S\}.
$$

The terminology reflects deletion: a vertex-supported object with support $S$ survives deletion of $v$ exactly when $v$ is not in its support.

## 3. The uniform-family identity

### Theorem 3.1 (Uniform-family double counting)

Let $V$ be an $n$-element set and let $\mathcal A$ be a finite $k$-uniform family of subsets of $V$. Then

$$
\sum_{v\in V}|\mathcal A_v|=(n-k)|\mathcal A|.
$$

#### Proof sketch

Count the incidence set

$$
\Omega=\{(v,S)\in V\times\mathcal A:v\notin S\}.
$$

Fixing $v$ first gives

$$
|\Omega|=\sum_{v\in V}|\mathcal A_v|.
$$

Fixing $S$ first, the uniformity hypothesis gives $|V\setminus S|=n-k$, so every $S$ contributes exactly $n-k$ pairs. Hence

$$
|\Omega|=\sum_{S\in\mathcal A}(n-k)=(n-k)|\mathcal A|.
$$

Equating the two evaluations proves the identity.

### Remark 3.2 (Boundary cases)

If $k=n$, every member occupies all vertices and survives no deletion; both sides are zero. If $k>n$, a $k$-uniform family of subsets of $V$ must be empty, so the identity is again trivial. The useful inversion occurs when $k<n$:

$$
|\mathcal A|=\frac{1}{n-k}\sum_{v\in V}|\mathcal A_v|.
$$

The divisibility of the sum by $n-k$ is structural, not accidental.

## 4. Induced patterns and Kelly’s lemma

Let $F$ be a fixed finite simple graph with $k$ vertices and let $G$ be a finite simple graph with vertex set $V$ of size $n$. Define the **induced-copy family**

$$
\mathcal I_F(G)=\{S\subseteq V:|S|=k\text{ and }G[S]\cong F\}.
$$

Its cardinality

$$
N_F(G)=|\mathcal I_F(G)|
$$

counts induced copies of $F$ by their vertex sets. This convention does not count distinct isomorphisms from $F$ onto the same induced subgraph; a support set contributes once.

Every member of $\mathcal I_F(G)$ has size $k$, so this is a $k$-uniform family. Moreover, for a deleted vertex $v$, the members that survive are precisely the supports of induced copies of $F$ lying in $G-v$. Consequently,

$$
|\mathcal I_F(G)_v|=N_F(G-v).
$$

### Theorem 4.1 (Kelly’s counting lemma for induced patterns)

Let $G$ be a finite simple graph on $n$ vertices and let $F$ be a finite simple graph on $k$ vertices. Then

$$
\sum_{v\in V(G)}N_F(G-v)=(n-k)N_F(G).
$$

#### Proof sketch

Apply Theorem 3.1 to the $k$-uniform family $\mathcal I_F(G)$. Deleting $v$ preserves exactly those supports not containing $v$, and those supports are exactly the induced copies of $F$ in $G-v$. Substitution yields the formula.

### Corollary 4.2 (Recovery of smaller induced-pattern counts)

If $k<n$, then

$$
N_F(G)=\frac{1}{n-k}\sum_{v\in V(G)}N_F(G-v).
$$

Thus the total number of induced copies of any fixed pattern smaller than $G$ is determined by the corresponding counts across the deck.

#### Proof sketch

Since $k<n$, the positive integer $n-k$ may be cancelled in Theorem 4.1.

### Discussion

The theorem recovers numerical pattern data, not positions. For example, taking $F$ to be a triangle recovers the number of triangles in $G$ from the total triangle count over all cards, provided $n>3$. Each triangle survives in exactly $n-3$ cards. Taking $F$ to be an induced path on three vertices recovers the number of induced three-vertex paths in the same way.

At $k=n$, every copy uses the whole graph and disappears from every card. The factor $n-k$ vanishes, so no inversion is possible. This precisely marks the gap between counting proper substructures and reconstructing the entire graph.

## 5. The edge-sum identity

Let $K_2$ denote the graph consisting of two vertices joined by one edge. Every edge of $G$ corresponds to exactly one two-element vertex set inducing $K_2$, so

$$
N_{K_2}(G)=|E(G)|.
$$

Kelly’s lemma with $F=K_2$ immediately gives the edge formula. It is useful to state and prove it directly.

### Theorem 5.1 (Vertex-card edge-sum identity)

If $G$ is a finite simple graph on $n$ vertices, then

$$
\sum_{v\in V(G)}|E(G-v)|=(n-2)|E(G)|.
$$

#### Proof sketch

Consider an edge $e=\{x,y\}$. It appears in $G-v$ if and only if $v$ is neither $x$ nor $y$. There are exactly $n-2$ such vertices $v$. Hence, when edge counts are summed across all cards, every original edge is counted exactly $n-2$ times. Summing this contribution over all edges gives the result.

An equivalent incidence proof counts pairs $(v,e)$ satisfying $v\notin e$. Counting first by $v$ gives the left side; counting first by $e$ gives the right side.

### Corollary 5.2 (Edge count from the deck)

If $n\ge3$, then

$$
|E(G)|=\frac{\sum_{v\in V(G)}|E(G-v)|}{n-2}.
$$

The numerator is therefore always divisible by $n-2$.

### Example 5.3 (Five-cycle)

Let $G=C_5$. Then $n=5$ and $|E(G)|=5$. Every vertex deletion produces a path on four vertices with three edges. Therefore

$$
\sum_v|E(G-v)|=5\cdot3=15=(5-2)\cdot5.
$$

The reconstruction formula returns $15/3=5$.

### Example 5.4 (Five-vertex star)

Let $G=K_{1,4}$. Deleting the center leaves four isolated vertices and zero edges. Deleting any of the four leaves leaves a three-edge star. Thus

$$
\sum_v|E(G-v)|=0+4\cdot3=12=(5-2)\cdot4.
$$

The edge count is recovered as $12/3=4$.

### Example 5.5 (Why order two is excluded)

For either graph on two vertices—the edgeless graph or $K_2$—deleting either vertex leaves a single isolated vertex. Their decks are identical, although one graph has zero edges and the other has one. In the edge identity the multiplier is $n-2=0$, so the deck-edge sum is zero in both cases and contains no information about the original edge count.

## 6. Equality of edge counts for equal decks

### Lemma 6.1 (Isomorphism preserves edge count)

If finite simple graphs $X$ and $Y$ are isomorphic, then

$$
|E(X)|=|E(Y)|.
$$

#### Proof sketch

An isomorphism maps each unordered adjacent pair in $X$ to an unordered adjacent pair in $Y$. The inverse isomorphism gives the inverse map on edges, so this correspondence is a bijection.

### Theorem 6.2 (Edge-count reconstruction)

Let $G$ and $H$ be finite simple graphs with the same paired vertex deck. If $|V(G)|\ge3$, then

$$
|E(G)|=|E(H)|.
$$

#### Proof sketch

The pairing of vertices is a bijection, so $G$ and $H$ have the same order $n$. Corresponding cards are isomorphic and therefore have equal edge counts by Lemma 6.1. Summing over the pairing gives

$$
\sum_{v\in V(G)}|E(G-v)|
=
\sum_{w\in V(H)}|E(H-w)|.
$$

Apply Theorem 5.1 to both sides:

$$
(n-2)|E(G)|=(n-2)|E(H)|.
$$

Since $n\ge3$, the factor $n-2$ is positive, and cancellation proves the claim.

### Remark 6.3

The argument uses only the multiset of card-edge counts, not the full adjacency structure of each card. Thus edge count is recoverable from a substantial compression of the deck.

## 7. Reconstruction at the edge-density extremes

For a fixed order $n$, every simple graph has edge count between $0$ and $\binom n2$. At either endpoint there is only one isomorphism type.

### Theorem 7.1 (Reconstruction of edgeless graphs)

Every finite edgeless graph on at least three vertices is reconstructible from its vertex deck.

#### Proof sketch

Let $G$ be edgeless of order $n\ge3$, and let $H$ have the same deck. By Theorem 6.2,

$$
|E(H)|=|E(G)|=0.
$$

Therefore $H$ is also edgeless. The deck pairing implies that $G$ and $H$ have the same number of vertices. Any bijection between the vertex sets of two edgeless graphs preserves adjacency, since there are no adjacent pairs. Hence $G\cong H$.

### Theorem 7.2 (Reconstruction of complete graphs)

Every finite complete graph on at least three vertices is reconstructible from its vertex deck.

#### Proof sketch

Let $G=K_n$ with $n\ge3$, and let $H$ have the same deck. The graphs have the same order $n$, and Theorem 6.2 gives

$$
|E(H)|=|E(G)|=\binom n2.
$$

There are exactly $\binom n2$ unordered pairs of distinct vertices in an $n$-element set. A simple graph can contain at most one edge for each such pair. Since $H$ attains this maximum, every possible pair is an edge, so $H$ is complete. Any bijection between two complete graphs of equal order is an isomorphism, and therefore $G\cong H$.

### Corollary 7.3 (Extremal recognition from card-edge totals)

For $n\ge3$, a deck comes from an edgeless graph exactly when the sum of card-edge counts is $0$, and it comes from a complete graph exactly when that sum is

$$
(n-2)\binom n2.
$$

#### Proof sketch

Use Corollary 5.2 to recover $m$. The values $m=0$ and $m=\binom n2$ characterize the edgeless and complete graphs, respectively.

## 8. Algorithms

Throughout, represent a graph on vertices $0,\dots,n-1$ by a set of normalized pairs $(u,v)$ with $u<v$.

### 8.1 Constructing the vertex deck

For each vertex $v$, remove every edge incident with $v$ and retain all other edges. If vertex labels are retained, this produces a labeled deck in time $O(nm)$ for $m$ edges: every one of the $n$ deletions scans all edges. The output itself can contain $\Theta(nm)$ edge occurrences, so this bound is natural for explicit construction.

If unlabeled isomorphism classes are required, each card must additionally be canonically labeled or compared for graph isomorphism. That is a separate computational problem and is not needed for numerical edge reconstruction.

### 8.2 Recovering edge count

Given card-edge counts $c_1,\dots,c_n$ with $n\ge3$, compute

$$
S=\sum_{i=1}^n c_i.
$$

Check that $S$ is divisible by $n-2$, then return $S/(n-2)$. This takes $O(n)$ time and $O(1)$ auxiliary space. For a genuine graph deck, divisibility follows from Theorem 5.1. Failure of divisibility certifies that the supplied counts cannot be the card-edge counts of an $n$-vertex simple graph.

This divisibility test is necessary but not sufficient for deck realizability: arbitrary integer lists can satisfy it without coming from a graph.

### 8.3 Counting induced pattern copies

For a fixed pattern $F$ on $k$ vertices, enumerate all $\binom nk$ subsets $S$ of the host graph’s vertices. Build $G[S]$ and test whether it is isomorphic to $F$. If a brute-force test tries all $k!$ bijections and checks $O(k^2)$ potential adjacencies, the total cost is

$$
O\left(\binom nk k!k^2\right).
$$

For fixed $k$, this is polynomial in $n$, though optimized canonical-labeling routines are preferable in practice.

To demonstrate Kelly’s lemma, count copies in every card and compare their sum with $(n-k)N_F(G)$. A more efficient verification can count each copy once in $G$ and add its known multiplicity $n-k$, but explicit card counting better illustrates the observational interpretation.

## 9. Applications and broader interpretation

### 9.1 Network sampling under node failure

Suppose a communication network is observed repeatedly, with one station offline in each observation. An edge remains observable unless one of its two endpoints is the failed station. Across a complete schedule of single-station failures, each link appears exactly $n-2$ times. The edge-sum identity therefore recovers the total number of links even if no intact observation is available.

More generally, a motif occupying $k$ stations appears in exactly $n-k$ observations. This offers a calibration rule for motif frequencies under systematic leave-one-out sampling.

### 9.2 Chemical and relational structures

Graphs encode molecular skeletons, dependency systems, and pairwise relations. Vertex deletion models removal of one atom, component, or entity. Pattern counts across fragments can reveal counts in the original structure when the pattern uses fewer vertices than the whole. The theorem concerns exact induced patterns: both required edges and required nonedges within the support must agree with the pattern.

### 9.3 Redundancy as information

The deck is highly redundant. A $k$-vertex pattern is repeated in $n-k$ cards, and every edge is repeated in $n-2$ cards. This redundancy permits exact recovery of totals. The same principle resembles leave-one-out methods in statistics and overlapping measurements in inverse problems: an object omitted from some views remains visible in a predictable number of others.

## 10. Limitations

The proved identities do not establish the general Reconstruction Conjecture. Several limitations are fundamental.

First, pattern counts lose location. Knowing how many triangles, paths, or edges occur does not identify which occurrences overlap. Two nonisomorphic graphs can share many numerical invariants.

Second, cards are individually unlabeled. Even if a vertex in one card appears to correspond structurally to a vertex in another, no common naming is supplied. A complete reconstruction must align partial observations consistently.

Third, Kelly’s inversion applies only when $k<n$. At $k=n$, the visibility multiplier vanishes. The theorem reconstructs proper induced-subgraph counts, not the original graph as a full-size pattern.

Fourth, equality of edge counts is much weaker than isomorphism except at the two extremal values. The edgeless and complete cases succeed because their order and edge count uniquely determine them.

These limitations clarify the role of the results: they provide exact invariants and a proof template, rather than a complete solution of the open problem.

## 11. Future directions

A first target is the **degree multiset**. Since

$$
|E(G-v)|=|E(G)|-\deg_G(v),
$$

recovering $|E(G)|$ from the deck suggests recovering the multiset of degrees from the multiset of card-edge counts. This would strengthen the available invariant and directly support regular-graph reconstruction.

For **regular graphs**, every vertex deletion removes the same number of edges. Degree recovery identifies the common degree, but reconstruction still requires recovering adjacency organization.

For **trees**, cards reflect leaf removal, branch structure, and component decompositions. Pattern-count identities can be combined with tree-specific structural induction.

For **induced patterns**, the next conceptual step is to express deck equality directly as equality of the cardwise counts and conclude equality of $N_F(G)$ and $N_F(H)$ whenever $|V(F)|<|V(G)|$.

Finally, **complements** should preserve deck equivalence because vertex deletion commutes with graph complementation:

$$
\overline{G-v}\cong \overline G-v.
$$

A reconstruction theorem for a complement-closed or complement-related class can therefore generate a companion theorem. The edgeless and complete cases already display this duality.

## 12. Conclusion

The vertex deck records a graph through overlapping losses. Its basic arithmetic is governed by support size: every object using $k$ vertices survives exactly $n-k$ one-vertex deletions. The uniform-family identity turns that observation into a general theorem, and Kelly’s counting lemma transfers it to induced graph patterns.

For edges, the result becomes

$$
\sum_v|E(G-v)|=(n-2)|E(G)|.
$$

Consequently, equal decks of order at least three force equal edge counts. At the minimum and maximum possible edge counts, this invariant determines the entire graph, proving reconstruction for edgeless and complete graphs.

The general conjecture remains beyond these arguments because totals do not encode the full geometry of overlap. Nevertheless, survival multiplicity supplies a precise foundation for further work: it identifies what the deck certainly reveals, explains why the threshold of three vertices matters, and converts systematic partial observation into exact global counts.