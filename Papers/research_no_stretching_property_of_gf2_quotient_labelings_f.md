# The No-Stretching Property of GF(2) Quotient Labelings from Edge Partitions

**Author:** Aristotle
**Date:** 2026-07-02
**Domain:** Applications (metric graph theory, distance labeling, coding-theoretic sketches)

## Abstract

Given a connected graph $G$ whose edge set is partitioned into $t$ classes, we
associate to each class a generator of the elementary abelian $2$-group
$(\mathbb{Z}/2\mathbb{Z})^t$ and quotient by the *cycle-class parity space* $C$ —
the subspace of parity constraints forced by closed walks. The result is a vertex
labeling $\ell : V(G) \to Q$ into the finite abelian $2$-group
$Q = (\mathbb{Z}/2\mathbb{Z})^t / C$, of dimension $t - \operatorname{rank}(A)$
where $A$ is the cycle-class parity matrix. We prove that this labeling is
**distance non-increasing** — it never *stretches* distances — when the label space
is equipped with the metric of the Cayley graph $H$ of $Q$ on the class generators:
$$ d_H(\ell(u), \ell(v)) \le d_G(u, v) \quad \text{for all } u, v \in V(G). $$
The core of the argument is a general and elementary principle: any
*edge-contracting* vertex map (one that sends adjacent vertices to
adjacent-or-equal vertices) between graphs is distance non-increasing on the
connected components of the source. We isolate this principle, derive the
quotient-labeling theorem as a corollary, compute the quotient dimension, and
exhibit an explicit triangle showing that the *coordinate hypercube* with Hamming
distance is the *wrong* target — it reports a stretch — whereas the Cayley graph is
the correct one. The one-sided (never-over-estimating) nature of the labeling makes
it a certified lower-bound oracle for graph distance whose size is governed by the
corank $t - \operatorname{rank}(A)$ rather than by the number of vertices.

## 1. Introduction

Distance labeling schemes attach to each vertex of a graph a compact label so that
the distance between two vertices can be estimated — ideally computed — from their
labels alone. Such schemes underpin routing, reachability, and graph-similarity
search in large networks. A recurring theme is the tension between *exactness*
(labels reproduce the true distance, i.e. an isometric embedding) and *economy*
(labels are far smaller than a full distance table). Between these poles sits a
practically vital middle ground: labelings that are guaranteed to be wrong in only
*one direction*. A labeling whose induced distance never *exceeds* the true distance
certifies a lower bound; a labeling whose induced distance never *falls below* the
true distance certifies an upper bound. One-sided guarantees cannot be gamed by an
adversarial index and compose gracefully.

This paper studies a natural and cheap family of labelings built from parity. Color
the edges of a connected graph $G$ with $t$ colors — an arbitrary *edge partition*.
Assign each color a generator of the elementary abelian $2$-group. Label a vertex by
the XOR of the generators along any path from a fixed root; cycles guarantee this is
well-defined once we quotient by the parity constraints they impose. The output is a
labeling into a finite abelian $2$-group.

Our main contribution is a proof, from first principles, that this labeling has the
**No-Stretching Property**: it is distance non-increasing into the appropriate
target graph. We further show that identifying the *appropriate* target is not a
formality — the intuitive choice (the coordinate hypercube with Hamming distance)
fails, and the correct choice (the Cayley graph on the class generators) succeeds.
The failure is not marginal; a single triangle already exhibits a stretched edge
under the Hamming reading.

### Contributions

1. **A general contraction principle** (Section 3). Edge-contracting maps between
   graphs are distance non-increasing on connected sources. This is the discrete
   analogue of a $1$-Lipschitz map and the engine behind everything that follows.
2. **The No-Stretching Theorem for quotient labelings** (Section 5), in both an
   abstract "symmetric generating set" form and a concrete "edge-partition / class
   generator" form.
3. **The quotient dimension formula** (Section 4): the label space has dimension
   $t - \operatorname{rank}(A)$.
4. **A separating example** (Section 6): an explicit triangle whose quotient
   labeling does not stretch into the Cayley graph but *does* stretch into the
   coordinate hypercube, pinning down the correct target.
5. **Applications and structure theory** (Sections 7–8): one-sided distance
   oracles, corank as the isometry defect, and connections to partial cubes and
   median graphs.

## 2. Preliminaries and Definitions

Throughout, $G = (V, E)$ is a simple, connected, undirected graph. We write
$d_G(u,v)$ for the graph distance: the length (number of edges) of a shortest walk
from $u$ to $v$. A **walk** of length $n$ is a sequence of vertices
$w_0, w_1, \dots, w_n$ with $w_{k} w_{k+1} \in E$ for each $k$; the distance is the
minimum length over all walks joining the endpoints, which for a connected graph is
finite.

**Definition 2.1 (Edge partition).** An *edge partition into $t$ classes* is a
surjective map $c : E \to \{1, \dots, t\}$; the fiber $c^{-1}(i)$ is class $i$.
Equivalently, a coloring of the edges with $t$ colors, each used at least once.

**Definition 2.2 (Parity space and generators).** Let
$\mathbb{F}_2 = \mathbb{Z}/2\mathbb{Z}$. The *ambient parity space* is
$\mathbb{F}_2^t$ (functions $\{1,\dots,t\} \to \mathbb{F}_2$ under XOR). A choice of
*class generators* is a map $\mathrm{gen} : \{1,\dots,t\} \to Q$ into an abelian
$2$-group $Q$; in the canonical construction $Q$ is a quotient of $\mathbb{F}_2^t$
and $\mathrm{gen}\, i$ is the image of the $i$-th standard basis vector.

**Definition 2.3 (Cycle-class parity space).** For each closed walk in $G$, form the
vector in $\mathbb{F}_2^t$ whose $i$-th coordinate is the parity of the number of
class-$i$ edges traversed. The *cycle-class parity space* $C \le \mathbb{F}_2^t$ is
the span of these vectors; the *cycle-class parity matrix* $A$ is any matrix with
row space $C$, so $\operatorname{rank}(A) = \dim C$.

**Definition 2.4 (Quotient label space).** The *quotient label space* is
$Q = \mathbb{F}_2^t / C$, a finite $\mathbb{F}_2$-vector space, and the class
generators are the cosets $\mathrm{gen}\, i = e_i + C$.

**Definition 2.5 (Quotient labeling).** Fix a root $r \in V$. For $v \in V$, choose
any walk from $r$ to $v$ and let $\ell(v) \in Q$ be the sum (XOR) of the generators
$\mathrm{gen}\, c(e)$ over the edges $e$ of the walk. Because any two walks between
the same endpoints differ by a closed walk, whose class-parity lies in $C$ and hence
vanishes in $Q$, the label $\ell(v)$ is well-defined. By construction, if $uv \in E$
lies in class $i$ then $\ell(u) - \ell(v) = \mathrm{gen}\, i$.

**Definition 2.6 (Cayley graph).** For an additive group $Q$ and a generating set
$S \subseteq Q$ that is *symmetric* ($s \in S \Rightarrow -s \in S$), the *Cayley
graph* $\operatorname{Cay}(Q, S)$ has vertex set $Q$ and adjacency
$$ x \sim y \iff x \neq y \ \text{and}\ x - y \in S. $$
Symmetry of $S$ makes the relation symmetric; the $x \ne y$ clause makes it
loopless. Note that in a $2$-group every element is its own inverse, so *every*
subset is symmetric and the Cayley graph is automatically an undirected simple
graph. We write $H = \operatorname{Cay}(Q, \{\mathrm{gen}\, i\})$ for the target.

**Definition 2.7 (Edge-contracting map).** A vertex map
$\varphi : V(G) \to V(H)$ is *edge-contracting* if for every edge $uv \in E(G)$,
either $\varphi(u)\varphi(v) \in E(H)$ or $\varphi(u) = \varphi(v)$. Equivalently,
$\varphi$ sends adjacent vertices to adjacent-or-equal vertices.

## 3. The Contraction Principle

The technical heart of the paper is an elementary but sharp statement about
edge-contracting maps. It requires no algebra whatsoever — only walks.

**Lemma 3.1 (Walk contraction).** Let $\varphi : V(G) \to V(H)$ be edge-contracting.
Then for any walk $p$ in $G$ from $u$ to $v$, there is a walk $q$ in $H$ from
$\varphi(u)$ to $\varphi(v)$ with $\operatorname{length}(q) \le
\operatorname{length}(p)$.

*Proof.* Induct on the walk $p$. If $p$ is the empty walk at $u$, take $q$ to be the
empty walk at $\varphi(u)$; lengths are both $0$. Otherwise $p$ begins with an edge
$ab$ followed by a walk $p'$ from $b$ to $v$; by induction there is a walk $q'$ in
$H$ from $\varphi(b)$ to $\varphi(v)$ with $\operatorname{length}(q') \le
\operatorname{length}(p')$. Because $\varphi$ is edge-contracting, either
$\varphi(a)\varphi(b) \in E(H)$ or $\varphi(a) = \varphi(b)$.

- If $\varphi(a)\varphi(b)$ is an edge, prepend it to $q'$ to obtain a walk $q$ from
  $\varphi(a) = \varphi(u)$ to $\varphi(v)$ with length
  $\operatorname{length}(q') + 1 \le \operatorname{length}(p') + 1 =
  \operatorname{length}(p)$.
- If $\varphi(a) = \varphi(b)$, then $q'$ already starts at $\varphi(a) =
  \varphi(u)$; take $q = q'$, whose length is $\operatorname{length}(q') \le
  \operatorname{length}(p') \le \operatorname{length}(p)$.

In both cases the constructed walk has length at most that of $p$. $\qquad\blacksquare$

**Theorem 3.2 (Contraction principle).** Let $G$ be connected and
$\varphi : V(G) \to V(H)$ edge-contracting. Then for all $u, v \in V(G)$,
$$ d_H(\varphi(u), \varphi(v)) \le d_G(u, v). $$

*Proof.* Since $G$ is connected there is a walk $p$ from $u$ to $v$ of length exactly
$d_G(u,v)$. By Lemma 3.1 there is a walk $q$ in $H$ from $\varphi(u)$ to
$\varphi(v)$ with $\operatorname{length}(q) \le \operatorname{length}(p)$. The
distance $d_H(\varphi(u),\varphi(v))$ is the minimum walk length between those
endpoints, hence at most $\operatorname{length}(q)$. Chaining,
$$ d_H(\varphi(u),\varphi(v)) \le \operatorname{length}(q) \le
\operatorname{length}(p) = d_G(u,v). \qquad\blacksquare $$

Theorem 3.2 is the discrete analogue of the fact that a $1$-Lipschitz map does not
increase distance. The map may of course *decrease* distance — collapsing edges
creates shortcuts — but never increase it. This asymmetry is the whole point.

## 4. The Quotient Dimension

Before applying the contraction principle we record the size of the label space.

**Theorem 4.1 (Quotient dimension).** For the quotient label space
$Q = \mathbb{F}_2^t / C$,
$$ \dim_{\mathbb{F}_2} Q = t - \operatorname{rank}(A), $$
where $\operatorname{rank}(A) = \dim_{\mathbb{F}_2} C$.

*Proof.* For a subspace $C$ of a finite-dimensional space the dimensions satisfy
$\dim(\mathbb{F}_2^t/C) + \dim C = \dim \mathbb{F}_2^t = t$. Since $\dim C =
\operatorname{rank}(A)$, rearranging gives $\dim Q = t - \operatorname{rank}(A)$.
$\qquad\blacksquare$

Thus every independent cycle constraint folds away one coordinate. A partition whose
cycles impose no constraints (e.g. any partition of a tree, where there are no
cycles) yields $\dim Q = t$; a partition with many independent constrained cycles
yields a much smaller, more compressed label. The **corank** $t -
\operatorname{rank}(A) = \dim Q$ measures the storage cost of the sketch, and, as we
discuss in Section 8, controls its isometry defect.

## 5. The No-Stretching Theorem

We now combine the contraction principle with the algebra of the Cayley target. We
give the abstract form first, then specialize.

**Theorem 5.1 (No-stretching, symmetric-set form).** Let $G$ be connected, $Q$ an
additive group, $S \subseteq Q$ symmetric, and $H = \operatorname{Cay}(Q, S)$.
Suppose $\ell : V(G) \to Q$ is *compatible with $S$*: for every edge $uv \in E(G)$,
either $\ell(u) = \ell(v)$ or $\ell(u) - \ell(v) \in S$. Then for all $u,v \in V(G)$,
$$ d_H(\ell(u), \ell(v)) \le d_G(u, v). $$

*Proof.* We show $\ell$ is edge-contracting into $H$ and invoke Theorem 3.2. Take an
edge $uv$ of $G$. By compatibility, $\ell(u) = \ell(v)$ or $\ell(u) - \ell(v) \in
S$. In the first case $\ell(u) = \ell(v)$, so the images are equal. In the second
case, distinguish whether $\ell(u) = \ell(v)$: if so, the images are equal; if not,
then $\ell(u) \ne \ell(v)$ and $\ell(u) - \ell(v) \in S$, which is exactly adjacency
in $H$. Either way the images are adjacent-or-equal, so $\ell$ is edge-contracting.
Theorem 3.2 finishes the proof. $\qquad\blacksquare$

**Theorem 5.2 (No-stretching, edge-partition form).** Let $G$ be connected with an
edge partition into $t$ classes, $Q$ an abelian group, and class generators
$\mathrm{gen} : \{1,\dots,t\} \to Q$ with the symmetry property $-\mathrm{gen}\, i
\in \{\mathrm{gen}\, 1, \dots, \mathrm{gen}\, t\}$ for each $i$. Let $\ell : V(G)
\to Q$ satisfy, on every edge, $\ell(u) - \ell(v) = \mathrm{gen}\, i$ for some class
$i$. Then, writing $H$ for the Cayley graph on the generating set
$S = \{\mathrm{gen}\, 1, \dots, \mathrm{gen}\, t\}$,
$$ d_H(\ell(u), \ell(v)) \le d_G(u, v) \quad \text{for all } u, v \in V(G). $$

*Proof.* The symmetry hypothesis makes $S = \{\mathrm{gen}\, i\}$ a symmetric
generating set, so $H = \operatorname{Cay}(Q, S)$ is defined. For any edge $uv$ there
is a class $i$ with $\ell(u) - \ell(v) = \mathrm{gen}\, i \in S$, so $\ell$ is
compatible with $S$. Apply Theorem 5.1. $\qquad\blacksquare$

In a $2$-group the symmetry hypothesis is automatic, since $-\mathrm{gen}\, i =
\mathrm{gen}\, i$. Applied to the canonical construction of Definition 2.5, Theorem
5.2 yields the headline statement:

> **The GF(2) quotient labeling from any edge partition of a connected graph is
> distance non-increasing into the Cayley graph of the quotient on the class
> generators.**

## 6. The Correct Target: A Separating Triangle

Why the Cayley graph rather than the coordinate hypercube? Because they genuinely
disagree, and only the Cayley graph supports the theorem. We make the disagreement
concrete on the smallest nontrivial example.

**Setup.** Let $G = K_3$, the triangle on vertices $\{0,1,2\}$, with each of the
three edges in its own class ($t = 3$). Traversing the triangle is a closed walk
using all three classes once, forcing the single parity constraint $(1,1,1) \in C$;
one checks $C = \langle(1,1,1)\rangle$ has dimension $1$. By Theorem 4.1, $\dim Q =
3 - 1 = 2$, so $Q \cong \mathbb{F}_2^2$. Concretely the class generators and vertex
labels are
$$
\mathrm{gen}\, 0 = (1,0), \quad \mathrm{gen}\, 1 = (0,1), \quad \mathrm{gen}\, 2 =
(1,1),
$$
$$
\ell(0) = (0,0), \quad \ell(1) = (1,0), \quad \ell(2) = (1,1).
$$
(These satisfy $\ell(0)-\ell(1) = (1,0) = \mathrm{gen}\, 0$, $\ell(1)-\ell(2) =
(0,1) = \mathrm{gen}\, 1$, $\ell(0)-\ell(2) = (1,1) = \mathrm{gen}\, 2$, matching the
three class assignments.)

**Cayley reading (correct).** In $H = \operatorname{Cay}(\mathbb{F}_2^2,
\{(1,0),(0,1),(1,1)\})$, all three nonzero vectors are generators, so *every* pair
of distinct labels is adjacent — $H$ is itself a triangle $K_4$ minus nothing on the
three occupied vertices, and in particular $d_H(\ell(0), \ell(2)) = 1$. Since the
graph edge $\{0,2\}$ has $d_G(0,2) = 1$, the labeling matches exactly: no stretch.
Theorem 5.2 guarantees $d_H(\ell(u),\ell(v)) \le d_G(u,v)$ for all pairs, as one may
verify directly (indeed here equality holds on every pair).

**Hamming reading (incorrect).** Now measure the same labels in the coordinate
hypercube $\mathbb{Q}_2$ (the $2$-cube), where $x \sim y$ iff $x$ and $y$ differ in
exactly one coordinate. Then $\ell(0) = (0,0)$ and $\ell(2) = (1,1)$ differ in *two*
coordinates, so their Hamming distance is $2$. But $d_G(0,2) = 1$. The labeling
therefore *stretches* the edge $\{0,2\}$ from distance $1$ to distance $2$:
$$ d_{\mathbb{Q}_2}(\ell(0), \ell(2)) = 2 > 1 = d_G(0,2). $$

**Moral.** The generator $\mathrm{gen}\, 2 = (1,1)$ is a *single* class token, hence
a single Cayley step, even though it flips two coordinates. Hamming distance
double-counts precisely the coordinate that the cycle folded. The Cayley graph is
the geometry in which "one class token" always means "one step," and it is the only
target for which the No-Stretching Theorem holds in general. This example pins down
the correct formulation and shows the theorem is not vacuous: the naive alternative
provably fails.

## 7. Algorithms

The constructions above are effective. We summarize the two central procedures.

**Algorithm A — Quotient labeling from an edge partition.** Given $G$, a spanning
tree $T$, and an edge coloring $c$, compute the vertex labels and the cycle-class
parity space.

1. Root the spanning tree $T$ at $r$; set $\ell(r) = 0$.
2. Traverse $T$ (BFS/DFS). For a tree edge $uv$ of class $i$ discovered from $u$ to
   $v$, set $\ell(v) = \ell(u) + e_i$ in $\mathbb{F}_2^t$.
3. For each non-tree edge $uv$ of class $i$, the fundamental cycle contributes the
   parity vector $\ell(u) + \ell(v) + e_i$ (all in $\mathbb{F}_2^t$); collect these
   as the rows of $A$.
4. Reduce $A$ to row echelon form over $\mathbb{F}_2$ to obtain $\operatorname{rank}
   (A) = \dim C$; the labels in the quotient are $\ell(v) + C$, and $\dim Q =
   t - \operatorname{rank}(A)$.

Steps 1–3 are linear in $|V| + |E|$; step 4 is a Gaussian elimination over
$\mathbb{F}_2$ costing $O(m \cdot t / w)$ machine words for $m$ non-tree edges and
word size $w$ using bitset rows. The output certifies, via Theorem 5.2, a lower
bound $d_H(\ell(u),\ell(v)) \le d_G(u,v)$.

**Algorithm B — Cayley lower bound.** Given labels $\ell(u), \ell(v)$ and the
generating set $S = \{\mathrm{gen}\, i\}$, compute $d_H(\ell(u),\ell(v))$, the
minimum number of tokens (with repetition) summing to $\ell(u) - \ell(v)$ in $Q$.
This is a shortest-word / covering-radius computation in the abelian group; for small
$\dim Q$ it is a BFS on the (small) Cayley graph, and the returned value is a
certified lower bound on $d_G(u,v)$.

## 8. Applications and Structural Consequences

**One-sided distance oracles.** By Theorem 5.2, $d_H \circ (\ell \times \ell)$ never
over-estimates $d_G$. Stored as $\dim Q = t - \operatorname{rank}(A)$ bits per
vertex, it is a *certified lower-bound oracle*: any reported bound is valid, and
validity is independent of the number of vertices. Because non-expansion is preserved
under pointwise maxima, a family $\{\ell_k\}$ of such labelings (different colorings,
different quotients) yields the stronger certificate $\max_k d_{H_k}(\ell_k(u),
\ell_k(v)) \le d_G(u,v)$, still one-sided and still uncheatable by an adversarial
index.

**Corank as isometry defect.** The labeling contracts a distance exactly when a
shortest $G$-path maps to a shorter $H$-walk, which happens only when a cycle folds
two token-steps into one (as in the triangle). Consequently the labeling is an
isometry — never contracting — precisely when the cycle-class parity space is
trivial on the relevant subspaces; each independent nonzero cycle contributes one
folded coordinate. The corank $t - \operatorname{rank}(A)$ thus interpolates between
a lossless embedding (small rank) and a heavily compressed one-sided sketch (large
rank).

**Partial cubes and median graphs.** Graphs admitting an isometric embedding into a
coordinate hypercube are the *partial cubes*, a class containing the median graphs
that model solution spaces, phylogenetic structures, and concept lattices. The
edge-partition/quotient construction is a lens on this theory: the finest partition
for which every quotient labeling is isometric is conjectured to characterize the
partial cubes, with the median graphs as fixed points of the refinement.

## 9. Discussion

The result decomposes cleanly into a purely combinatorial core (Theorem 3.2,
contraction) and a purely algebraic wrapper (the Cayley target and the quotient
dimension). This separation is deliberate and portable. The contraction principle
applies to *any* edge-contracting map — graph minors, homomorphisms that may
collapse edges, and colorings alike — and immediately generalizes the classical
hypercube no-stretch statement from the coordinate hypercube to an arbitrary Cayley
graph of an abelian $2$-group (and, mutatis mutandis, of any group with a symmetric
generating set). The triangle of Section 6 is not a curiosity but a diagnostic: it
locates exactly where the coordinate-hypercube intuition breaks and certifies that
the Cayley formulation is the right one.

## 10. Future Work

Three directions stand out. First, quantifying the isometry defect: proving that the
maximum coordinate-hypercube stretch is a monotone function of $\operatorname{rank}
(A)$, with isometry iff the rank vanishes on every induced even-cycle subspace.
Second, scaling one-sided certification: bounding the multiplicative lower-bound
quality achievable by a family of small-Cayley labelings using space independent of
$|V|$. Third, the fixed-point theory: proving that iterating the construction with
the finest isometric partition converges to the partial cubes, with median graphs as
fixed points. Each is a concrete step from a clean structural principle toward
deployable, verifiable distance sketches.

## References (selected, standard)

- D. Ž. Djoković, *Distance-preserving subgraphs of hypercubes*, J. Combin. Theory
  Ser. B, 1973 (partial cubes).
- H.-J. Bandelt and V. Chepoi, *Metric graph theory and geometry: a survey*
  (median graphs and partial cubes).
- C. Gavoille, D. Peleg, S. Pérennes, R. Raz, *Distance labeling in graphs*, J.
  Algorithms, 2004 (distance labeling schemes).
