# Vertex-Deleted Graph Decks: Double Counting, Edge Reconstruction, and Complement Duality

**Aristotle**  
**August 1, 2026**

## Abstract

For a simple graph $G$ and a vertex $v$, the vertex-deleted card $G-v$ is the subgraph induced by all vertices other than $v$. The vertex deck records these cards with multiplicity. This paper develops a self-contained counting framework for information recoverable from such decks. The basic result is a uniform-family double-counting identity: if $\mathcal A$ is a family of $k$-subsets of an $n$-element set, then the sum, over all deleted vertices, of the number of members of $\mathcal A$ surviving the deletion equals $(n-k)|\mathcal A|$. Applied to vertex sets inducing a fixed pattern $F$, this yields Kelly’s counting formula

$$
\sum_{v\in V(G)}N_F(G-v)=(|V(G)|-|V(F)|)N_F(G).
$$

The two-vertex specialization gives an edge-sum formula. It follows that deck-equivalent finite graphs on at least three vertices have the same number of edges. Consequently, edgeless graphs and complete graphs of order at least three are reconstructible. We also prove that vertex deletion commutes with graph complementation and that two graphs have the same deck if and only if their complements do. Algorithms are given for constructing decks, checking the counting identities, recovering edge count, and enumerating induced pattern copies. The results isolate a robust local-to-global mechanism while leaving the general Reconstruction Conjecture open.

## 1. Introduction

The graph reconstruction problem asks whether a finite graph can be recovered from all of its one-vertex deletions. Given a graph $G$ on $n$ vertices, delete each vertex in turn, together with every incident edge. The resulting $n$ graphs, considered up to isomorphism and retained with multiplicity, form the vertex deck of $G$. The Reconstruction Conjecture asserts that every finite simple graph of order at least three is determined up to isomorphism by this deck.

The conjecture remains open in general. Nevertheless, the deck carries many global invariants. The central mechanism is redundancy: an object supported on $k$ vertices survives deletion of every vertex outside its support, hence occurs in exactly $n-k$ cards. This observation is elementary, but its scope is broad. It counts arbitrary uniform set families, induced copies of fixed graph patterns, and edges as a special case.

The paper has four principal aims. First, it states and proves the uniform-family double-counting identity in a form independent of graph theory. Second, it specializes that identity to induced subgraph patterns, giving Kelly’s counting formula. Third, it derives edge reconstruction and uses extremal edge counts to reconstruct edgeless and complete graphs. Fourth, it establishes complement compatibility: deletion and complementation commute, so deck equivalence is invariant under taking complements.

The results should be read as a coherent partial theory rather than a resolution of the full conjecture. They explain exactly why edge count is visible in a deck, identify the order-three threshold needed for cancellation, and exhibit complementation as a symmetry of reconstruction.

## 2. Definitions and conventions

### 2.1 Simple graphs and isomorphism

A **simple graph** is a pair $G=(V,E)$ in which $V$ is a set of vertices and $E$ is a set of unordered two-element subsets of $V$. Thus loops and multiple edges are excluded. We write $V(G)$ and $E(G)$ for the vertex and edge sets, $n(G)=|V(G)|$ for the order, and $m(G)=|E(G)|$ for the size when these sets are finite.

Two simple graphs $G$ and $H$ are **isomorphic**, written $G\cong H$, if there is a bijection $f:V(G)\to V(H)$ satisfying

$$
\{x,y\}\in E(G)\quad\Longleftrightarrow\quad\{f(x),f(y)\}\in E(H)
$$

for all distinct $x,y\in V(G)$. An isomorphism preserves every property defined solely by adjacency, including order and edge count.

For $S\subseteq V(G)$, the **induced subgraph** $G[S]$ has vertex set $S$ and edge set

$$
E(G[S])=\{\{x,y\}\in E(G):x,y\in S\}.
$$

### 2.2 Cards and decks

For $v\in V(G)$, the **vertex-deleted card** at $v$ is

$$
G-v=G[V(G)\setminus\{v\}].
$$

The **vertex deck** is the multiset of isomorphism classes of the cards $G-v$ as $v$ ranges over $V(G)$. Multiplicity matters.

For graphs that may have differently named vertex sets, we use the following precise comparison.

**Definition 2.1 (Same vertex deck).** Graphs $G$ and $H$ have the same vertex deck if there is a bijection $e:V(G)\to V(H)$ such that

$$
G-v\cong H-e(v)
$$

for every $v\in V(G)$.

The bijection immediately gives $n(G)=n(H)$. For finite graphs, this paired definition is equivalent to equality of the multisets of card isomorphism classes.

A class $\mathcal C$ of finite graphs is **reconstructible** in the present sense if, whenever $G\in\mathcal C$ has at least three vertices and $H$ has the same deck as $G$, one has $G\cong H$.

### 2.3 Uniform families and survival

Let $V$ be a finite set of cardinality $n$. A finite family $\mathcal A$ of subsets of $V$ is **$k$-uniform** if every $A\in\mathcal A$ has cardinality $k$. For $v\in V$, define the family surviving deletion of $v$ by

$$
\mathcal A_v=\{A\in\mathcal A:v\notin A\}.
$$

The word “family” here means a set of subsets, so duplicate members are not present. This is exactly the setting needed when a graph copy is counted by its supporting vertex set.

### 2.4 Induced pattern copies

Let $F$ and $G$ be finite simple graphs. Define the **induced-copy family** of $F$ in $G$ by

$$
\mathcal I_F(G)=\{S\subseteq V(G):|S|=|V(F)|\text{ and }G[S]\cong F\}.
$$

Its cardinality is denoted

$$
N_F(G)=|\mathcal I_F(G)|.
$$

A copy is counted once for each vertex set $S$, regardless of how many graph isomorphisms $G[S]\to F$ exist. By definition, $\mathcal I_F(G)$ is $|V(F)|$-uniform.

## 3. The uniform double-counting identity

The fundamental theorem concerns no graph structure at all.

**Theorem 3.1 (Uniform-Family Double-Counting Identity).** Let $V$ be an $n$-element set and let $\mathcal A$ be a finite $k$-uniform family of subsets of $V$. Then

$$
\sum_{v\in V}|\mathcal A_v|=(n-k)|\mathcal A|.
$$

**Proof.** Consider the incidence set

$$
\Omega=\{(v,A)\in V\times\mathcal A:v\notin A\}.
$$

Count $\Omega$ first by fixing $v$. For a given $v$, exactly the members of $\mathcal A_v$ contribute, so

$$
|\Omega|=\sum_{v\in V}|\mathcal A_v|.
$$

Now count by fixing $A$. Since $|A|=k$, exactly $n-k$ vertices of $V$ lie outside $A$. Hence every $A\in\mathcal A$ contributes $n-k$ pairs, and

$$
|\Omega|=\sum_{A\in\mathcal A}(n-k)=(n-k)|\mathcal A|.
$$

Equating the two counts proves the identity. $\square$

The theorem remains a valid natural-number identity even when $k>n$, since then no $k$-subset of $V$ exists and $\mathcal A$ is empty. In the applications below, members of the family ensure $k\le n$ automatically.

**Corollary 3.2 (Recovery from survival totals).** Under the hypotheses of Theorem 3.1, if $k<n$, then

$$
|\mathcal A|=\frac{1}{n-k}\sum_{v\in V}|\mathcal A_v|.
$$

**Proof sketch.** The factor $n-k$ is a positive integer, so divide the identity of Theorem 3.1 by it. $\square$

This formula makes the informational content transparent. The aggregate survival count determines the original family size whenever at least one vertex lies outside every member.

## 4. Kelly’s counting formula for induced patterns

We now specialize the uniform identity to graph patterns.

**Lemma 4.1 (Uniformity of induced-copy families).** If $F$ and $G$ are finite simple graphs, then $\mathcal I_F(G)$ is $|V(F)|$-uniform.

**Proof.** Membership in $\mathcal I_F(G)$ explicitly requires $|S|=|V(F)|$. $\square$

For $v\in V(G)$, the members of $\mathcal I_F(G)$ surviving deletion of $v$ are exactly the vertex sets of induced copies of $F$ contained in $G-v$. More precisely, identifying the vertices of $G-v$ with $V(G)\setminus\{v\}$ gives

$$
\mathcal I_F(G-v)=\{S\in\mathcal I_F(G):v\notin S\}.
$$

The reason is that deletion does not alter adjacency between surviving vertices.

**Theorem 4.2 (Kelly’s Counting Formula).** Let $G$ and $F$ be finite simple graphs, with $n=|V(G)|$ and $k=|V(F)|$. Then

$$
\sum_{v\in V(G)}N_F(G-v)=(n-k)N_F(G).
$$

Equivalently, the total number of induced copies of $F$ visible across all vertex-deleted cards, counted by supporting vertex sets, is $n-k$ times the number in $G$.

**Proof.** Apply Theorem 3.1 to $V=V(G)$ and $\mathcal A=\mathcal I_F(G)$. Lemma 4.1 supplies $k$-uniformity. For each $v$, the surviving family is identified with $\mathcal I_F(G-v)$, whose size is $N_F(G-v)$. Substitution gives the claimed formula. $\square$

**Corollary 4.3 (Pattern-count recovery formula).** If $|V(F)|<|V(G)|$, then

$$
N_F(G)=\frac{\sum_{v\in V(G)}N_F(G-v)}{|V(G)|-|V(F)|}.
$$

**Proof sketch.** The denominator is positive, so cancellation in Theorem 4.2 is valid. $\square$

The inequality is necessary for this one-step recovery. If $F$ has the same number of vertices as $G$, then every deletion destroys every possible full-order copy and the multiplier is zero.

### 4.1 Example: triangles

Let $F=K_3$, the triangle, and suppose $G$ has $n=7$ vertices and $t$ induced triangles. Every triangle survives deletion of the four vertices outside it. Therefore

$$
\sum_{v\in V(G)}N_{K_3}(G-v)=4t.
$$

If the seven cards contain, in total, $20$ triangle occurrences, then $G$ contains $20/4=5$ triangles. The cards overlap heavily, but the overlap multiplicity is uniform and therefore exactly removable.

## 5. Edge counts from the deck

Let $K_2$ denote the simple graph consisting of two vertices joined by one edge. A two-element subset induces $K_2$ exactly when it is an edge, so

$$
N_{K_2}(G)=m(G).
$$

Theorem 4.2 consequently yields the edge-specific identity.

**Theorem 5.1 (Vertex-Card Edge-Sum Identity).** If $G$ is a finite simple graph on $n$ vertices, then

$$
\sum_{v\in V(G)}m(G-v)=(n-2)m(G).
$$

**Proof.** Set $F=K_2$ in Theorem 4.2. Alternatively, count pairs $(v,e)$ where $e\in E(G)$ and $v$ is not an endpoint of $e$. For fixed $v$, these are precisely the edges of $G-v$. For fixed $e$, there are $n-2$ vertices outside its two endpoints. $\square$

**Lemma 5.2 (Isomorphism preserves edge count).** If finite simple graphs $X$ and $Y$ are isomorphic, then $m(X)=m(Y)$.

**Proof.** An isomorphism sends each unordered adjacent pair in $X$ to an unordered adjacent pair in $Y$. The inverse isomorphism gives the inverse map on edges, so the edge sets are in bijection. $\square$

**Theorem 5.3 (Edge Reconstruction Theorem).** Let $G$ and $H$ be finite simple graphs with the same vertex deck. If $n(G)\ge 3$, then

$$
m(G)=m(H).
$$

**Proof.** Let $e:V(G)\to V(H)$ pair corresponding cards. Since $e$ is a bijection, $n(G)=n(H)=n$. By Lemma 5.2,

$$
m(G-v)=m(H-e(v))
$$

for every $v\in V(G)$. Summing over $v$ and reindexing the right side through $e$ gives

$$
\sum_{v\in V(G)}m(G-v)=\sum_{w\in V(H)}m(H-w).
$$

Apply Theorem 5.1 to both graphs:

$$
(n-2)m(G)=(n-2)m(H).
$$

Because $n\ge3$, the factor $n-2$ is positive, so cancellation yields $m(G)=m(H)$. $\square$

**Remark 5.4 (Sharpness of the order condition).** At order $2$, the graph $K_2$ and the edgeless graph on two vertices have identical decks: deleting either vertex leaves a one-vertex edgeless graph. Their edge counts differ. Thus the condition $n\ge3$ cannot be removed.

### 5.1 Degree interpretation

Deleting $v$ removes exactly the edges incident with $v$, so

$$
m(G-v)=m(G)-\deg_G(v).
$$

Summing and using the handshake identity $\sum_v\deg_G(v)=2m(G)$ gives

$$
\sum_v m(G-v)=nm(G)-2m(G)=(n-2)m(G).
$$

This provides a second proof of Theorem 5.1 and connects edge reconstruction to the future problem of recovering the entire degree multiset.

## 6. Reconstruction at the extremal edge counts

### 6.1 Edgeless graphs

Let $\overline{K_n}$ denote the edgeless graph on $n$ vertices.

**Theorem 6.1 (Edgeless Reconstruction Theorem).** Let $G$ and $H$ be finite simple graphs with the same deck and at least three vertices. If $G$ is edgeless, then $G\cong H$.

**Proof.** Since $G$ is edgeless, $m(G)=0$. Theorem 5.3 gives $m(H)=0$. Therefore $H$ also has no adjacent pair and is edgeless. The deck pairing supplies a bijection between their equally large vertex sets; any such bijection is an isomorphism between edgeless graphs. $\square$

### 6.2 Complete graphs

Let $K_n$ denote the complete graph on $n$ vertices. It has one edge for every unordered pair of distinct vertices, hence

$$
m(K_n)=\binom n2.
$$

**Theorem 6.2 (Complete Reconstruction Theorem).** Let $G$ and $H$ be finite simple graphs with the same deck and at least three vertices. If $G$ is complete, then $G\cong H$.

**Proof.** The deck pairing gives $n(G)=n(H)=n$. Since $G$ is complete,

$$
m(G)=\binom n2.
$$

By Theorem 5.3, $m(H)=\binom n2$. Every edge of a simple graph on $n$ vertices is an unordered vertex pair, and there are exactly $\binom n2$ such pairs. Equality therefore forces every possible pair to be an edge of $H$. Thus $H$ is complete. Any bijection between the vertex sets is then an isomorphism. $\square$

The two theorems illustrate an extremal principle: a deck-reconstructible numerical invariant can reconstruct a graph whenever a particular value of the invariant uniquely determines the graph at fixed order.

## 7. Complement compatibility

### 7.1 Graph complements

For a simple graph $G$, its **complement** $G^c$ has vertex set $V(G)$ and adjacency relation

$$
x\sim_{G^c}y\quad\Longleftrightarrow\quad x\ne y\text{ and }x\not\sim_G y.
$$

Complementation is involutive:

$$
(G^c)^c=G.
$$

If $G$ is finite of order $n$, then

$$
m(G^c)=\binom n2-m(G).
$$

**Lemma 7.1 (Isomorphisms complement).** If $G\cong H$, then $G^c\cong H^c$.

**Proof.** Let $f$ be an isomorphism from $G$ to $H$. It is a bijection and preserves both equality and adjacency. For distinct $x,y$, adjacency in $G^c$ means nonadjacency in $G$; this is equivalent to nonadjacency of $f(x),f(y)$ in $H$, hence to adjacency in $H^c$. Thus the same vertex bijection is a complement isomorphism. $\square$

**Lemma 7.2 (Deletion commutes with complementation).** For every simple graph $G$ and vertex $v$,

$$
G^c-v=(G-v)^c.
$$

Here equality is understood after the natural identification of both vertex sets with $V(G)\setminus\{v\}$.

**Proof.** Both graphs have the same surviving vertices. For distinct survivors $x$ and $y$, they are adjacent in $G^c-v$ exactly when they are nonadjacent in $G$. Deleting $v$ does not change the relation between $x$ and $y$, so this is equivalent to nonadjacency in $G-v$, which is adjacency in $(G-v)^c$. $\square$

**Theorem 7.3 (Complement-Deck Equivalence).** Two simple graphs $G$ and $H$ have the same vertex deck if and only if $G^c$ and $H^c$ have the same vertex deck.

**Proof.** Suppose first that $G$ and $H$ have the same deck, paired by a bijection $e$. For each $v$ there is an isomorphism

$$
G-v\cong H-e(v).
$$

Lemma 7.1 gives

$$
(G-v)^c\cong(H-e(v))^c.
$$

Using Lemma 7.2 on both sides yields

$$
G^c-v\cong H^c-e(v).
$$

Thus $G^c$ and $H^c$ have the same deck. Conversely, apply the proved implication to $G^c$ and $H^c$ and use involutivity of complementation. $\square$

No finiteness assumption is needed for Theorem 7.3. Its content is structural rather than enumerative.

**Corollary 7.4 (Complement transfer).** Let $\mathcal C$ be a reconstructible class of finite simple graphs, and define

$$
\mathcal C^c=\{G:G^c\in\mathcal C\}.
$$

Then $\mathcal C^c$ is reconstructible.

**Proof sketch.** If $G\in\mathcal C^c$ and $G,H$ have the same deck, Theorem 7.3 says $G^c,H^c$ have the same deck. Reconstructibility of $\mathcal C$ gives $G^c\cong H^c$. Lemma 7.1, applied once more, gives $G\cong H$. $\square$

The edgeless and complete reconstruction theorems form a complementary pair under this corollary.

## 8. Algorithms and computational demonstrations

The theory leads to direct finite algorithms. Represent a labeled graph on vertices $\{0,\dots,n-1\}$ by a set of ordered pairs $(u,v)$ with $u<v$.

### 8.1 Constructing the deck

For each vertex $v$, retain exactly those edges whose endpoints differ from $v$. This constructs all labeled vertex-deleted cards in time $O(nm)$ for $m$ edges, or $O(n^3)$ from an adjacency matrix. Canonical graph labeling is needed only if one wishes to compare cards up to isomorphism rather than to study a known labeled graph.

### 8.2 Recovering edge count

Given the edge counts $c_v=m(G-v)$ of all cards and $n\ge3$, compute

$$
m(G)=\frac{\sum_v c_v}{n-2}.
$$

The Double-Counting Identity guarantees exact divisibility for a valid deck. A nonzero remainder is therefore a certificate that the supplied card counts cannot arise from one $n$-vertex simple graph.

The running time after card counts are available is $O(n)$ and the extra space is $O(1)$.

### 8.3 Counting induced copies

To count copies of a fixed $k$-vertex pattern $F$, enumerate all $\binom nk$ vertex subsets $S$, form $G[S]$, and test whether it is isomorphic to $F$. For fixed $k$, brute-force permutation testing uses at most $k!$ permutations and $O(k^2)$ adjacency comparisons per subset. The resulting bound is

$$
O\!\left(\binom nk k!k^2\right),
$$

which is polynomial in $n$ for fixed $k$ but expensive when $k$ grows. Specialized canonical-labeling software substantially improves practical performance.

Once the count $N_F(G-v)$ is known for every card and $k<n$, recover the original count by division by $n-k$.

## 9. Applications and interpretation

### 9.1 Local-to-global inference

The identity in Theorem 3.1 applies wherever features have fixed-size supports. If an object depends on exactly $k$ elements of an $n$-element universe, deleting one element preserves that object in exactly $n-k$ views. Aggregating all views and correcting for multiplicity recovers the global number of objects.

In network science, edges, triangles, and small motifs measure different aspects of organization. The formulas here explain how complete collections of leave-one-node-out subnetworks preserve aggregate motif counts. The result does not reconstruct labels or locate each motif, but it recovers exact totals.

### 9.2 Jackknife-style redundancy

Leave-one-out procedures are common in statistics and data analysis. Graph decks have a similar shape, though the conclusions here are exact rather than asymptotic. Every local feature is repeatedly observed. Uniform support size makes the observation multiplicity constant, allowing an exact correction rather than an estimate.

### 9.3 Complementary sparse and dense regimes

Complement duality transfers every deletion statement between sparse and dense graphs. A theorem about a class $\mathcal C$ simultaneously yields one about complements of members of $\mathcal C$. This can prevent duplicated arguments and suggests organizing reconstruction results into complementary pairs.

## 10. Limitations and open directions

The results do not prove that arbitrary deck-equivalent graphs are isomorphic. Edge count is only one invariant, and many nonisomorphic graphs share the same order and size. Even exact counts of numerous small patterns need not immediately specify how those patterns overlap.

A first target is **degree-multiset reconstruction**: show that deck-equivalent graphs of order at least three have the same multiset of vertex degrees. The relation $m(G-v)=m(G)-\deg_G(v)$ strongly suggests this conclusion once edge count and the multiset of card edge counts are combined.

A second target is an explicit **induced-pattern count comparison theorem**: for $|V(F)|<|V(G)|$, deck-equivalent finite graphs $G$ and $H$ should satisfy $N_F(G)=N_F(H)$. Kelly’s formula provides the counting core; the remaining step is to transport pattern counts across corresponding card isomorphisms and cancel the common positive factor.

A third target is **regular-graph reconstruction**. If the degree multiset is recovered and $G$ is regular, then $H$ must have the same regular degree, providing rigid input for a fuller reconstruction argument.

A fourth target is **tree reconstruction** and its complementary partner. Trees combine connectedness, acyclicity, and the extremal edge equation $m=n-1$. Theorem 7.3 shows that any reconstruction theorem for trees immediately extends to graphs whose complements are trees.

Finally, complement transfer can be developed abstractly for any graph predicate determined by the deck. Theorem 7.3 supplies the essential symmetry: applying a reconstructible predicate to complements produces another reconstructible predicate.

## 11. Conclusion

Vertex-deleted cards lose local information but retain global counts through controlled redundancy. The Uniform-Family Double-Counting Identity states that every $k$-supported object survives in exactly $n-k$ cards. Kelly’s Counting Formula applies this principle to induced graph patterns. Its edge specialization proves that finite deck-equivalent graphs of order at least three have equal edge counts, from which reconstruction follows for edgeless and complete graphs.

Complementation supplies a second organizing principle. It commutes with vertex deletion and carries card isomorphisms to complement-card isomorphisms; consequently, deck equivalence is invariant under complementation. Together, counting and duality provide a compact foundation for further work on degree data, induced patterns, regular graphs, trees, and complement-closed reconstruction classes.