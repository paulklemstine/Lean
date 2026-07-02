# Non-embeddability of the Petersen Graph into Tropical Abelian Cayley Graphs

## Abstract

We prove that the Petersen graph admits no isometric embedding into any Cayley graph of an abelian group whose connection set is the *odd part* of an integer-valued tropical valuation. The argument factors into two logically independent components. The first is a purely metric obstruction, valid for any number of colors and any pair of graphs: an isometric map pulls back a proper $n$-coloring of the host to a proper $n$-coloring of the source. The second is a tropical bipartiteness certificate: for a Cayley graph whose generators are exactly the elements of odd valuation, the parity of the valuation is an additive character that properly two-colors the graph. Combining these with the classical fact that the Petersen graph is not bipartite — witnessed by an explicit five-cycle in its Kneser model $K(5,2)$ — yields non-embeddability across an entire valuation-defined family of hosts simultaneously. We give a concrete instance on the integer lattice $\mathbb{Z}^k$ with the coordinate-sum valuation, and we relate the construction to the min-plus (tropical) semiring, in which the valuation's values live and in which shortest-path distance is naturally expressed. We close with three conjectures delineating the boundary of the result: even-valuation hosts, a valuation-rank threshold, and a tropical distance-spectrum obstruction.

**Keywords:** Petersen graph, Kneser graph, isometric embedding, Cayley graph, tropical valuation, min-plus semiring, bipartite graph, graph coloring, partial cube.

---

## 1. Introduction

The Petersen graph is the canonical small counterexample of graph theory: $3$-regular, vertex-transitive, of girth $5$ and diameter $2$, and famously *not* a partial cube — that is, it does not embed isometrically into any hypercube. This paper generalizes the non-partial-cube phenomenon in an algebraic and tropical direction. Rather than restricting attention to hypercubes (Cayley graphs of $(\mathbb{Z}/2)^k$ with the standard generators), we consider a broad family of *tropical abelian Cayley graphs*, in which the generating set is produced by an integer-valued valuation on an abelian group, and we show that the Petersen graph is excluded from all of them at once.

The result rests on a clean dichotomy between metric and algebraic content. On the metric side, isometric embeddings are strong enough to transport proper colorings backward along the map; this is a statement about distances alone. On the algebraic side, the hosts we consider are bipartite for a structural reason: their edges are exactly the elements whose valuation is odd, and reducing the valuation modulo $2$ furnishes a proper two-coloring. The Petersen graph, being non-bipartite, cannot survive the transport, and non-embeddability follows.

### Contributions

- A general metric obstruction (Theorem 4.1) and its contrapositive embedding-exclusion form (Theorem 4.2), valid for all $n$ and all graphs.
- A self-contained proof that the Petersen graph is not two-colorable via an explicit odd cycle in the Kneser model $K(5,2)$ (Theorem 5.2).
- The definition of the *odd-valuation Cayley graph* of an abelian group and a proof that it is bipartite, certified by the parity of the valuation (Theorem 6.3).
- The main non-embeddability theorem (Theorem 7.1) and a concrete lattice instance (Corollary 7.2).
- A bridge to the min-plus semiring, situating the valuation's values in the tropical value group and recording the tropical combination rules (Section 8).
- Three conjectures mapping the boundary of the obstruction (Section 10).

---

## 2. Preliminaries and notation

All graphs are simple and undirected. For a graph $G$ we write $V(G)$ for its vertex set, $u \sim_G v$ (or $G.\mathrm{Adj}\,u\,v$) for adjacency, and $\operatorname{dist}_G(u,v)$ for the shortest-path distance, with $\operatorname{dist}_G(u,v) = 1$ iff $u \sim_G v$.

A **proper $n$-coloring** of $G$ is a function $c : V(G) \to \{1, \ldots, n\}$ with $c(u) \neq c(v)$ whenever $u \sim_G v$; $G$ is **$n$-colorable** if such a coloring exists. A graph is **bipartite** iff it is $2$-colorable. We use the classical characterization:

> **Fact 2.1 (Bipartiteness via closed walks).** A graph is $2$-colorable if and only if every closed walk has even length. Equivalently, it fails to be $2$-colorable iff it contains a closed walk of odd length.

A map $f : V(G) \to V(H)$ is an **isometric embedding** (or **isometry**) if
$$\operatorname{dist}_H\bigl(f(u), f(v)\bigr) = \operatorname{dist}_G(u,v) \quad \text{for all } u, v \in V(G).$$
(We do not separately require injectivity; distance preservation forces it, since distinct vertices at positive distance have distinct images.)

---

## 3. The tropical value algebra

The **min-plus** (tropical) semiring is the set $\overline{\mathbb{Z}} = \mathbb{Z} \cup \{+\infty\}$ equipped with tropical addition $x \oplus y = \min(x,y)$ and tropical multiplication $x \odot y = x + y$, with additive identity $+\infty$ and multiplicative identity $0$. Its central structural feature is **idempotency**: $x \oplus x = x$ for all $x$. More abstractly, a linearly ordered idempotent commutative additive monoid $R$ — one in which $a + a = a$ and the order satisfies $a \le b \iff a + b = b$ — has the property that its addition *is* a lattice operation,
$$a + b = \max(a, b),$$
which specializes, under the appropriate orientation of the order, to the min or max of the tropical semirings. This is the algebra in which our valuations take values, and it is the natural setting for shortest-path distance: a walk's length is a tropical *product* (ordinary sum) of edge weights, and the distance between two vertices is the tropical *sum* (extremal choice) over all walks.

Throughout, the value group of the valuation is $\mathbb{Z}$, embedded in the min-plus value structure $\overline{\mathbb{Z}}$.

---

## 4. The metric obstruction

The first pillar is independent of all algebra; it concerns distances and colorings only.

> **Theorem 4.1 (Coloring pullback under isometry).** Let $G$ and $H$ be graphs and $f : V(G) \to V(H)$ an isometric embedding, i.e. $\operatorname{dist}_H(f(u), f(v)) = \operatorname{dist}_G(u,v)$ for all $u, v$. If $H$ is $n$-colorable, then $G$ is $n$-colorable.

**Proof.** Let $c : V(H) \to \{1,\dots,n\}$ be a proper coloring of $H$. Define $c' := c \circ f$ on $V(G)$. Suppose $u \sim_G v$. Then $\operatorname{dist}_G(u,v) = 1$, and by the isometry hypothesis $\operatorname{dist}_H(f(u),f(v)) = 1$, so $f(u) \sim_H f(v)$. Since $c$ is proper, $c(f(u)) \neq c(f(v))$, i.e. $c'(u) \neq c'(v)$. Hence $c'$ is a proper $n$-coloring of $G$. $\qquad\blacksquare$

The isometry hypothesis is used **exactly once**, to convert a $G$-edge into an $H$-edge. It is load-bearing: for a general (non-isometric) map, a triangle could be crushed onto a single edge, destroying the pullback. Taking contrapositives:

> **Theorem 4.2 (Embedding exclusion).** If $G$ is not $n$-colorable and $H$ is $n$-colorable, then there is no isometric embedding $f : V(G) \to V(H)$; that is, no map $f$ satisfies $\operatorname{dist}_H(f(u),f(v)) = \operatorname{dist}_G(u,v)$ for all $u,v$.

We will apply Theorem 4.2 with $n = 2$.

---

## 5. The Petersen graph and its non-bipartiteness

We model the Petersen graph as the **Kneser graph $K(5,2)$**.

> **Definition 5.1 (Petersen graph).** The vertex set is $V = \{\, s \subseteq \{0,1,2,3,4\} : |s| = 2 \,\}$, the ten two-element subsets of a five-element set. Two vertices $s, t$ are adjacent iff $s \cap t = \varnothing$ (the underlying subsets are disjoint).

This graph is $3$-regular on $10$ vertices; each two-set is disjoint from exactly $\binom{3}{2} = 3$ others. It has girth $5$ and diameter $2$.

> **Theorem 5.2 (Petersen is not two-colorable).** The Petersen graph is not $2$-colorable.

**Proof.** By Fact 2.1 it suffices to exhibit an odd closed walk. Consider the sequence of two-sets
$$\{0,1\} \to \{2,3\} \to \{4,0\} \to \{1,2\} \to \{3,4\} \to \{0,1\}.$$
Each consecutive pair is disjoint — $\{0,1\}\cap\{2,3\}=\varnothing$, $\{2,3\}\cap\{4,0\}=\varnothing$, $\{4,0\}\cap\{1,2\}=\varnothing$, $\{1,2\}\cap\{3,4\}=\varnothing$, $\{3,4\}\cap\{0,1\}=\varnothing$ — so each step is an edge, and the walk closes after five steps. Since $5$ is odd, the graph contains an odd closed walk and hence is not $2$-colorable. $\qquad\blacksquare$

---

## 6. Tropical abelian Cayley graphs

Let $A$ be an additively written abelian group.

> **Definition 6.1 (Cayley graph).** Given a symmetric connection set $S \subseteq A$ with $-s \in S$ for all $s \in S$ and $0 \notin S$, the **Cayley graph** $\mathrm{Cay}(A, S)$ has vertex set $A$ and adjacency $g \sim h \iff h - g \in S$. Symmetry of $S$ makes the relation symmetric ($g \sim h \Rightarrow h \sim g$ because $-(h-g) = g - h \in S$), and $0 \notin S$ makes it loopless.

> **Definition 6.2 (Tropical valuation and odd-valuation Cayley graph).** A **tropical valuation** on $A$ is a group homomorphism $v : A \to \mathbb{Z}$, so that $v(a+b) = v(a) + v(b)$, $v(0) = 0$, and $v(-a) = -v(a)$. Its **odd part** is
> $$S_v := \{\, a \in A : v(a) \text{ is odd} \,\}.$$
> The **odd-valuation Cayley graph** is $\mathrm{Cay}(A, S_v)$.

The set $S_v$ is a legitimate connection set: it is symmetric because $v(-a) = -v(a)$ has the same parity as $v(a)$, and $0 \notin S_v$ because $v(0) = 0$ is even.

> **Theorem 6.3 (Tropical bipartiteness certificate).** The odd-valuation Cayley graph $\mathrm{Cay}(A, S_v)$ is $2$-colorable. Explicitly, the parity map
> $$\chi : A \to \mathbb{Z}/2, \qquad \chi(g) = v(g) \bmod 2,$$
> is a proper two-coloring, and it is an additive character: $\chi(g + h) = \chi(g) + \chi(h)$.

**Proof.** That $\chi$ is a homomorphism to $\mathbb{Z}/2$ is immediate from $v(g+h) = v(g)+v(h)$ and reduction mod $2$. For properness, suppose $g \sim h$ in $\mathrm{Cay}(A, S_v)$. Then $h - g \in S_v$, i.e. $v(h-g)$ is odd. But $v(h-g) = v(h) - v(g)$, so $v(h)$ and $v(g)$ have opposite parities, giving $\chi(h) \neq \chi(g)$. Thus adjacent vertices receive distinct colors and $\chi$ is proper. $\qquad\blacksquare$

The parity of the valuation plays two roles simultaneously: it *defines* the edge set (via oddness of $v$) and it *certifies* the two-coloring (via the character $\chi$). This is the precise point at which the tropical valuation controls the geometry.

---

## 7. Main theorem

> **Theorem 7.1 (Non-embeddability).** The Petersen graph admits no isometric embedding into any odd-valuation Cayley graph $\mathrm{Cay}(A, S_v)$, for any abelian group $A$ and any tropical valuation $v : A \to \mathbb{Z}$. That is, there is no map $f$ from the vertices of the Petersen graph to $A$ with
> $$\operatorname{dist}_{\mathrm{Cay}(A,S_v)}(f(u), f(v)) = \operatorname{dist}_{\mathrm{Petersen}}(u,v) \quad \text{for all } u,v.$$

**Proof.** By Theorem 6.3, $\mathrm{Cay}(A, S_v)$ is $2$-colorable. By Theorem 5.2, the Petersen graph is not $2$-colorable. Theorem 4.2 with $n = 2$ then rules out any isometric embedding of the Petersen graph into $\mathrm{Cay}(A, S_v)$. $\qquad\blacksquare$

> **Corollary 7.2 (Integer-lattice instance).** Take $A = \mathbb{Z}^k$ and the coordinate-sum valuation $v(x_1,\dots,x_k) = \sum_i x_i$. Then $S_v$ consists of all integer vectors with odd coordinate sum, and $\mathrm{Cay}(\mathbb{Z}^k, S_v)$ is the bipartite integer lattice two-colored by the parity of the coordinate sum. The Petersen graph does not embed isometrically into it, in any dimension $k$.

**Proof.** The coordinate sum is a group homomorphism $\mathbb{Z}^k \to \mathbb{Z}$, hence a tropical valuation; apply Theorem 7.1. $\qquad\blacksquare$

Because $A$ and $v$ range over all abelian groups and all integer-valued valuations, Theorem 7.1 excludes an infinite, valuation-parametrized family of hosts in a single statement.

---

## 8. The min-plus bridge

We record how the valuation interfaces with the tropical semiring, situating the integer values inside the min-plus value structure $\overline{\mathbb{Z}}$.

> **Definition 8.1 (Tropical value of a valuation).** For a valuation $v : A \to \mathbb{Z}$, define its **tropical value** $\widetilde{v}(a) \in \overline{\mathbb{Z}}$ to be $v(a)$ regarded as an element of the min-plus value structure.

> **Proposition 8.2 (Tropical combination rules).** In the idempotent min-plus algebra, the tropical values satisfy, for all $a$,
> $$\widetilde{v}(a) \oplus \widetilde{v}(a) = \widetilde{v}(a) \qquad (\text{idempotency}),$$
> and, for the underlying lattice operation induced by the order,
> $$\widetilde{v}(a) \oplus \widetilde{v}(b) = \operatorname{ext}\bigl(\widetilde{v}(a), \widetilde{v}(b)\bigr),$$
> where $\operatorname{ext}$ is the extremal (min/max) operation of the semiring.

**Proof.** Idempotency is the defining property $x \oplus x = x$ of the min-plus semiring, applied to $x = \widetilde{v}(a)$. The lattice identity is the general fact that in a linearly ordered idempotent commutative monoid, addition coincides with the order-extremal operation, $a + b = \max(a,b)$ (equivalently $\min$ under the reversed orientation). $\qquad\blacksquare$

These identities are what make shortest-path distance in the host a genuinely tropical quantity: it is computed by iterated $\oplus$/$\odot$ operations over the value structure in which $v$ lands. The bipartiteness certificate of Section 6 is then the reduction of this integer-valued tropical data modulo $2$.

---

## 9. Algorithmic content

The proof is constructive and yields three algorithms of independent interest.

**(A) Pullback coloring.** Given an isometric embedding $f$ and a proper coloring $c$ of the host, the composite $c \circ f$ is a proper coloring of the source; computing it is a single pass over the source vertices (Theorem 4.1).

**(B) Odd-cycle certificate.** Non-two-colorability of a graph is certified by producing an odd closed walk; for the Petersen graph the explicit pentagon of Theorem 5.2 is such a certificate, verifiable in linear time in the walk length.

**(C) Valuation two-coloring.** For any odd-valuation Cayley host, the map $g \mapsto v(g) \bmod 2$ two-colors it; evaluating it costs one valuation computation per vertex (Theorem 6.3).

Chaining (B) and (C) through the contrapositive (Theorem 4.2) gives a decision procedure that, for any candidate embedding target of odd-valuation type, immediately reports non-embeddability of any non-bipartite source, with the odd cycle as a human-checkable witness.

---

## 10. Discussion and future directions

The obstruction cleanly separates into a **valuation-free metric core** (Theorem 4.1, valid for any number of colors) and a **one-parameter certificate** (the parity of the valuation, Theorem 6.3). The tropical content is confined to the certificate: a single $\mathbb{Z}/2$-valued reduction of the valuation replaces the ad-hoc group character used in classical hypercube arguments. What the argument does *not* cover is precisely the case where the certificate degenerates — when every generator has even valuation — and this boundary motivates the following conjectures.

**Conjecture 1 (Even-valuation hosts).** There exists an abelian group $A$, a valuation $v$ all of whose generators have *even* value, and an isometric embedding of the Petersen graph into the associated Cayley graph. The key point is that the parity certificate is the only place oddness is used; with all generators even the host may contain its own odd closed walks, removing the coloring obstruction and potentially opening room for a genuine isometric copy of an odd-girth graph.

**Conjecture 2 (Valuation-rank threshold).** For every abelian group with a valuation whose value group has rank one, no odd-girth graph embeds isometrically into the odd-valuation Cayley graph; but there is a rank-two valued group into which the Petersen graph does embed isometrically. A rank-one valuation forces a global linear order on generator lengths, propagating a parity obstruction along every closed walk, whereas incomparable lengths in higher rank can cancel the length parity a single odd walk would otherwise force.

**Conjecture 3 (Tropical distance spectrum).** The multiset of pairwise tropical (min-plus) path lengths realizable inside any odd-valuation Cayley graph omits at least one distance value the Petersen metric requires; consequently the omission itself, not merely bipartiteness, is the true obstruction, and it persists for a positive-density family of non-bipartite hosts. Since shortest-path distance is intrinsically a min-plus computation, an embedding must reproduce an entire tropical distance spectrum, and the Petersen spectrum (diameter two, girth five) is over-determined relative to what valuation-graded hosts can supply.

---

## 11. Conclusion

We have shown that the metric rigidity underlying "the Petersen graph is not a partial cube" survives a change of the distance-generating algebra: replacing the classical $\mathbb{Z}/2$-character bipartiteness certificate by a tropical valuation rules out an entire valuation-defined family of Cayley hosts at once. The proof isolates a general metric obstruction from a tropical parity certificate, making transparent both why the exclusion holds and exactly where its boundary lies. The even-valuation case, the role of valuation rank, and the full tropical distance spectrum remain fertile ground for further study.
