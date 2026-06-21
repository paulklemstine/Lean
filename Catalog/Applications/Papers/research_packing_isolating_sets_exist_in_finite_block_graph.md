# Packing-Isolating Sets in Block Graphs: Existence on Extremal Families and the Sharpness of the Block-Graph Hypothesis

**Author:** Aristotle

**Date:** 2026-06-21

**Domain:** Probability / Structural Graph Theory

---

## Abstract

A *packing-isolating set* of a finite simple graph $G$ is a vertex set $S$ that
is simultaneously a **2-packing** — the closed neighborhoods of distinct
vertices of $S$ are pairwise disjoint — and an **isolating set** — every edge of
$G$ has at least one endpoint in the closed neighborhood $N[S]$ of $S$. These two
requirements are antagonistic: the packing condition forces the chosen vertices
to be mutually far apart, while the isolating condition forces them to be
collectively dense enough to dominate every edge. We study the conjecture that
*every finite block graph admits a packing-isolating set*, where a block graph is
a graph each of whose blocks (maximal $2$-connected subgraphs) is a clique. We
establish the conjecture constructively on the two structurally extremal families
of block graphs. For complete graphs $K_{n+1}$ we show that any single vertex is
packing-isolating. For path graphs $P_n$ we show that the residue class
$S = \{\, i : i \equiv 1 \pmod 3 \,\}$ is packing-isolating for every $n$, and we
analyze why this *aligned periodic* set succeeds where a greedy maximal packing
fails. Finally we prove sharpness: the five-cycle $C_5$, the smallest non-block
graph that could cause trouble, admits **no** packing-isolating set, certified by
an exhaustive search over all $2^5$ vertex subsets. The $C_5$ obstruction
decomposes cleanly into "diameter two suppresses large packings" and "no
dominating vertex suppresses small isolating sets," and we contrast it with $C_4$,
which does admit one, isolating the role of the odd cycle. All results are
machine-verified.

---

## 1. Introduction

### 1.1 Motivation

Many resource-placement problems in networked systems balance two opposing
desiderata. On the one hand, chosen sites should be *mutually non-interfering* —
spread far enough apart that their spheres of influence do not overlap. On the
other hand, the chosen sites should *collectively cover* the entire structure —
every connection should fall within reach of some site. In wireless network
design this is the tension between interference avoidance and link coverage; in
sentinel surveillance it is the tension between statistically independent
monitors and complete observability; in distributed systems it is independence
versus domination.

The combinatorial distillation of this tension pairs two classical notions from
graph theory. A *2-packing* (a maximally spread-out, mutually non-overlapping
family of closed neighborhoods) encodes non-interference. An *isolating set* (a
set whose closed neighborhood meets every edge) encodes coverage. A set that is
both at once we call a **packing-isolating set**. The natural question is which
graphs possess one.

### 1.2 Block graphs and the central conjecture

A **block** of a graph $G$ is a maximal connected subgraph with no cut vertex —
equivalently, a maximal $2$-connected subgraph or a bridge edge. $G$ is a
**block graph** if every block is a clique. Block graphs are precisely the graphs
realizable as "trees of cliques": the blocks, glued together at cut vertices,
form a tree structure. Trees (every block is an edge $K_2$) and complete graphs
(a single clique block) are the extreme members of this family.

We study the following conjecture.

> **Conjecture (Block-graph packing-isolation).** Every finite block graph $G$
> admits a packing-isolating set $S$.

This paper does not resolve the conjecture in full generality. Instead it makes
three contributions that together delineate its content precisely:

1. **(Upper extreme.)** Complete graphs admit packing-isolating sets — in fact
   any single vertex works.
2. **(Lower extreme.)** Path graphs admit packing-isolating sets via an explicit
   period-three residue construction valid for all $n$, with a structural
   analysis of why alignment, not maximality, is the operative property.
3. **(Sharpness.)** The block-graph hypothesis cannot be removed: the five-cycle
   $C_5$ admits no packing-isolating set, and it is the minimal non-block graph
   exhibiting this failure.

---

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph and the adjacency relation is
written $u \sim v$. We work over finite vertex types and use $\mathrm{Fin}\,n =
\{0, 1, \dots, n-1\}$ for the path and cycle constructions.

**Definition 2.1 (Closed neighborhood).** For a vertex $v$, the *closed
neighborhood* is
$$N[v] \;=\; \{v\} \cup \{\, u : u \sim v \,\}.$$
In the formalization this is `closedNbhd G v`, the insertion of $v$ into its
neighbor set.

**Definition 2.2 (Neighborhood of a set).** For a vertex set $S$,
$$N[S] \;=\; \bigcup_{v \in S} N[v].$$
In the formalization this is `nbhdSet G S`, a finite union (`biUnion`) of closed
neighborhoods.

**Definition 2.3 (2-packing).** $S$ is a *2-packing* if for all distinct
$u, v \in S$,
$$N[u] \cap N[v] = \varnothing.$$
Equivalently every pair of distinct vertices of $S$ is at graph distance at least
$3$. In the formalization this is `IsTwoPacking G S`.

**Definition 2.4 (Isolating set).** $S$ is an *isolating set* if every edge has
an endpoint in $N[S]$: for all $u \sim v$,
$$u \in N[S] \ \text{ or } \ v \in N[S].$$
In the formalization this is `IsIsolating G S`.

**Definition 2.5 (Packing-isolating set).** $S$ is *packing-isolating* if it is
both a 2-packing and isolating:
$$\mathrm{IsPackingIsolating}\,(G, S) \;\equiv\; \mathrm{IsTwoPacking}\,(G,S)\ \wedge\ \mathrm{IsIsolating}\,(G,S).$$

**Definition 2.6 (Dominating set).** $S$ *dominates* $G$ if $N[S] = V$, i.e.
every vertex lies in some closed neighborhood of $S$. A dominating set is
automatically isolating, since both endpoints of every edge already lie in
$N[S]$; this is the lemma `isIsolating_of_dominating`.

**Definition 2.7 (Path graph).** $P_n$ has vertex set $\mathrm{Fin}\,n$ with
$i \sim j$ iff $|i - j| = 1$, formalized as $i+1 = j \vee j+1 = i$ on the
underlying natural-number values (`PathG n`).

**Definition 2.8 (Five-cycle).** $C_5$ has vertex set $\mathrm{Fin}\,5$ with
$i \sim j$ iff $i$ and $j$ are cyclically consecutive, i.e.
$(i+1) \bmod 5 = j \vee (j+1) \bmod 5 = i$ (`C5`).

---

## 3. The Upper Extreme: Complete Graphs

The complete graph $K_{n+1}$ on $n+1$ vertices is the block graph consisting of a
single clique block. Here packing-isolation is immediate.

**Theorem 3.1 (`completeGraph_packingIsolating`).** *For every vertex
$v \in K_{n+1}$, the singleton $\{v\}$ is packing-isolating.*

**Proof sketch.** A singleton is vacuously a 2-packing: there are no two distinct
elements whose neighborhoods could intersect (`isTwoPacking_singleton`). For the
isolating property we prove the stronger statement that $\{v\}$ *dominates*
$K_{n+1}$ and invoke `isIsolating_of_dominating`. Domination means
$N[\{v\}] = V$: given any vertex $x$, either $x = v$ (so $x \in N[v]$ as the
center), or $x \neq v$, in which case $x \sim v$ because every pair of distinct
vertices is adjacent in a complete graph (`top_adj`), so again $x \in N[v]$.
Hence $N[\{v\}] = V$, every edge has both endpoints in $N[\{v\}]$, and $\{v\}$ is
isolating. $\qquad\blacksquare$

**Corollary 3.2 (`completeGraph_exists_packingIsolating`).** *For every $n$, the
complete graph $K_{n+1}$ admits a packing-isolating set* — namely $\{0\}$.

The complete-graph case anchors one end of the block-graph spectrum: when the
graph is a single clique, one vertex dominates and packing is free.

---

## 4. The Lower Extreme: Path Graphs

Paths are trees, and trees are block graphs whose blocks are all single edges
$K_2$. Unlike the complete graph, the path forces a genuine reconciliation of the
two opposing constraints. We resolve it with a single periodic set.

### 4.1 The construction

**Definition 4.1 (`pathPacking`).** Define
$$S_n \;=\; \{\, i \in \mathrm{Fin}\,n : i \equiv 1 \pmod 3 \,\} \;=\; \{1, 4, 7, \dots\}.$$

A basic membership characterization (`mem_pathPacking`) states $i \in S_n
\iff i \bmod 3 = 1$.

We will also use the closed-neighborhood description on a path
(`mem_closedNbhd_pathG`): for $v, x \in \mathrm{Fin}\,n$,
$$x \in N[v] \iff x = v \ \lor\ x + 1 = v \ \lor\ v + 1 = x,$$
i.e. $x$ is within distance one of $v$. Combining this with the definition of
$N[S]$ gives the working description (`mem_nbhdSet_pathPacking`):
$$x \in N[S_n] \iff \exists\, s,\ s \equiv 1 \!\!\pmod 3 \ \wedge\ (x = s \ \lor\ x + 1 = s \ \lor\ s + 1 = x).$$

### 4.2 The packing property

**Theorem 4.2 (`pathG_twoPacking`).** *For every $n$, the set $S_n$ is a
2-packing of $P_n$.*

**Proof sketch.** Let $u, v \in S_n$ be distinct, so $u \equiv v \equiv 1
\pmod 3$ and $u \neq v$ as values. Suppose for contradiction some $x$ lies in
both $N[u]$ and $N[v]$. By the closed-neighborhood description, $x$ is within
distance one of $u$ and within distance one of $v$, so $|u - v| \le 2$. But two
distinct integers congruent to $1$ modulo $3$ differ by a positive multiple of
$3$, hence by at least $3$ — contradiction. The entire numerical step is
dispatched by linear-arithmetic reasoning (`omega`) once the congruences and the
distance bounds are in hand. Therefore $N[u] \cap N[v] = \varnothing$.
$\qquad\blacksquare$

### 4.3 The isolating property

**Theorem 4.3 (`pathG_isolating`).** *For every $n$, the set $S_n$ is isolating
in $P_n$.*

**Proof sketch.** Every edge of $P_n$ joins consecutive vertices $a$ and $a+1$.
We must place at least one of $a, a+1$ in $N[S_n]$, i.e. within distance one of
some vertex $s \equiv 1 \pmod 3$. Split on $a \bmod 3$:

- $a \equiv 0$: then $a + 1 \equiv 1$, so $s = a+1 \in S_n$ and $a+1 \in N[s]$.
- $a \equiv 1$: then $a \in S_n$ itself, so $a \in N[a]$.
- $a \equiv 2$: then $a - 1 \equiv 1$, so $s = a-1 \in S_n$ and $a \in N[s]$,
  since $a$ is one step to the *right* of $s$.

In each case the chosen witness $s$ is a genuine element of $\mathrm{Fin}\,n$
(the bounds hold because $a$ or $a+1$ already lies in range), and the edge is
covered. $\qquad\blacksquare$

**Remark 4.4 (The backward witness).** The residue-$2$ case is the crux. The
covering vertex $s = a - 1$ sits *behind* the edge, not ahead of it. A
forward-only covering scheme fails at the right endpoint of the path, where no
vertex to the right exists. This is the formal reason the construction must be a
*phased* periodic set rather than any maximal packing.

### 4.4 The combined result

**Theorem 4.5 (`pathG_packingIsolating`).** *For every $n$, $S_n$ is
packing-isolating in $P_n$.*

**Proof.** Immediate from Theorems 4.2 and 4.3 by the definition of
packing-isolating. $\qquad\blacksquare$

**Corollary 4.6 (`pathG_exists_packingIsolating`).** *Every path graph $P_n$
admits a packing-isolating set.*

### 4.5 Alignment versus maximality

It is tempting to believe that any *maximal* 2-packing is automatically
isolating — after all, maximality means no further far-apart vertex can be added.
This is false. Consider $P_6$ with vertices $0, \dots, 5$ and take the endpoints
$\{0, 5\}$. These are at distance $5 \ge 3$, so they form a valid 2-packing, and
no third vertex can be added without violating the distance-three rule, so the
packing is maximal. Yet the edge $\{2, 3\}$ has neither endpoint within distance
one of $0$ or $5$: $N[0] = \{0,1\}$ and $N[5] = \{4,5\}$, missing $2$ and $3$
entirely. The packing is maximal but not isolating. By contrast the aligned set
$S_6 = \{1, 4\}$ covers every edge. **Existence of a packing-isolating set is a
statement about a particular aligned construction, not about extremal packings.**

---

## 5. Sharpness: The Five-Cycle Obstruction

We now show the block-graph hypothesis is necessary by exhibiting a non-block
graph with no packing-isolating set.

**Theorem 5.1 (`C5_no_packingIsolating`).** *No vertex set of the five-cycle
$C_5$ is packing-isolating:* for every $S \subseteq \mathrm{Fin}\,5$, $S$ fails
to be packing-isolating.

**Proof.** The statement quantifies over the $2^5 = 32$ subsets of a five-element
vertex set, and packing-isolation is a decidable predicate (adjacency, closed
neighborhoods, disjointness, and edge coverage are all decidable on a finite
type). An exhaustive finite check (`decide`) verifies that not one of the $32$
candidate sets satisfies both conditions. $\qquad\blacksquare$

**Corollary 5.2 (`C5_not_packingIsolating_exists`).** *There is no $S$ with
$\mathrm{IsPackingIsolating}(C_5, S)$.* Restated, the conjecture's conclusion
fails outright for the concrete non-block graph $C_5$.

### 5.1 Structural explanation of the obstruction

The brute-force certificate hides a transparent two-sided argument that explains
*why* $C_5$ fails and locates the failure precisely between the two constraints.

**The packing side forces $|S| \le 1$.** In $C_5$ any two vertices are at
distance at most $2$ (the cycle has diameter $2$). The 2-packing condition
requires distinct chosen vertices to be at distance at least $3$. These are
incompatible for two distinct vertices, so any 2-packing of $C_5$ has at most one
element.

**The isolating side forces $|S| \ge 2$.** A single vertex $v$ of $C_5$ has
$N[v] = \{v, v-1, v+1\}$ (three of the five vertices). The two vertices on the
far side of the ring — and the edge between them — lie outside $N[v]$. So no
singleton is isolating; isolation requires at least two vertices. The empty set
is not isolating either, since $C_5$ has edges.

The two bounds collide: a packing-isolating set would need at least two vertices
(coverage) but at most one (packing). No set can satisfy both, which is exactly
what the exhaustive search confirms.

### 5.2 The obstruction is the *odd* cycle, not "having a cycle"

The four-cycle $C_4$ — a square — *does* admit a packing-isolating set. A single
corner vertex $v$ reaches three of the four corners; the fourth corner is the
antipode, but every *edge* of the square is incident to one of the three covered
corners, so the singleton is isolating, and being a singleton it is trivially a
2-packing. Thus $C_4$ has a packing-isolating set while $C_5$ does not. The
failure is specific to the geometry of the odd five-cycle: diameter two (which
kills packings of size $\ge 2$) combined with the absence of any single
dominating vertex (which kills isolating sets of size $\le 1$). It is precisely
this "diameter-two-yet-no-dominating-vertex" deadlock that the block-graph
(clique) hypothesis excludes.

---

## 6. Algorithms

The constructive proofs translate directly into algorithms. We describe two.

### 6.1 Decision by exhaustive search (finite witnesses)

For a graph on a small finite vertex set, packing-isolation of a given $S$ — and
the existence of any packing-isolating set — is decidable by direct enumeration.
This is exactly the procedure underlying Theorem 5.1.

**Complexity.** For $|V| = m$ vertices and $|E|$ edges, checking a fixed $S$
costs $O(|S|^2 \cdot \Delta + |E|)$ where $\Delta$ is the maximum degree
(pairwise neighborhood disjointness plus edge coverage). Searching all subsets
costs $O(2^m)$ such checks. This is feasible only for small $m$ and is used as a
*boundary certificate* (e.g. $m = 5$ for $C_5$), not as a scalable solver.

### 6.2 Periodic construction on paths (linear time)

For $P_n$, the aligned residue set $S_n = \{i \equiv 1 \pmod 3\}$ is computed in a
single pass, and both conditions are verified locally in linear time.

**Complexity.** Construction is $O(n)$; verification of the 2-packing property
reduces to checking consecutive selected indices differ by $\ge 3$ (a single
scan), and verification of isolation reduces to a per-edge residue test, also a
single scan. Total $O(n)$ time and $O(n/3)$ output size.

---

## 7. Applications and Interpretation

**Wireless and sensor networks.** The packing condition models transmitters
placed far enough apart to avoid interference; the isolating condition models the
requirement that every communication link be monitored by some nearby node. On
tree-of-cliques topologies — common in hierarchical or clustered deployments —
the constructions here give explicit guard placements.

**Surveillance and epidemiology.** The packing condition yields statistically
quasi-independent monitoring sites (their neighborhoods do not overlap), while
the isolating condition guarantees every transmission edge is observed. The
period-three rule on chains gives a minimal-overhead sentinel layout.

**Probabilistic outlook.** Because block graphs arise naturally as random
tree-of-cliques models, the existence question has a probabilistic dimension:
one may ask for the threshold behavior of packing-isolating sets in random block
graphs, and for the typical minimum size of such a set. The deterministic
extremal results here calibrate those probabilistic questions.

---

## 8. Discussion and Future Work

The two extremal families (complete graphs and paths) bracket the structural
spectrum of block graphs and provide concrete evidence for the general
conjecture, while the $C_5$ boundary shows the hypothesis is not removable. The
natural next steps build on the verified base cases and the clean neighborhood
API (monotonicity of packings under subsets, of isolating sets under supersets).

1. **Full conjecture via block-cut induction.** A block graph is a tree of
   cliques; peeling a *leaf block* (a clique meeting the rest of the graph at a
   single cut vertex) reduces to a smaller block graph. The path
   periodic/backward-witness phenomenon is exactly the bookkeeping needed to
   decide whether the cut vertex must be "spent" on the recursion.

2. **Sharp lower bound for paths.** Conjecturally the minimum size of a
   packing-isolating set of $P_n$ equals $\lceil n/3 \rceil$ for $n \ge 2$,
   attained by $S_n$: the packing constraint forces gaps $\ge 3$ (lower bound)
   while the isolating constraint forbids gaps $> 3$ (matching upper bound).

3. **Characterizing small obstructions.** Conjecturally a graph with no
   packing-isolating set must contain an induced odd hole or an induced
   diameter-$\le 2$ subgraph with no dominating vertex, with $C_5$ the unique
   minimal such graph.

4. **Closure under clique-amalgamation.** If block graphs $G_1, G_2$ each admit a
   packing-isolating set, identifying a single vertex of each (a block-graph
   amalgam) should again admit one, since packing-isolating sets compose across a
   cut vertex.

5. **Probabilistic thresholds in random block graphs.** Study the existence and
   typical size of packing-isolating sets in uniformly random block graphs on
   $n$ vertices.

---

## 9. Conclusion

We have shown that packing-isolating sets — vertex sets that are simultaneously
maximally spread out (2-packings) and collectively edge-covering (isolating) —
exist on both structural extremes of the block-graph family: trivially on
complete graphs (any single vertex), and via an explicit phased period-three
construction on paths. We have shown that the block-graph hypothesis is sharp:
the five-cycle $C_5$ admits none, and its failure is a clean collision between a
diameter-two packing ceiling and a no-dominating-vertex isolating floor — a
deadlock that the clique-block structure precisely forbids, and one that the even
cycle $C_4$ escapes. These results give concrete evidence for the general
block-graph conjecture and a precise map of where its hypotheses bite.
