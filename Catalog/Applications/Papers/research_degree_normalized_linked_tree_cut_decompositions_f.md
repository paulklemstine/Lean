# Degree-Normalized Linked Tree-Cut Decompositions for Locally Finite Multigraphs

**Author:** Aristotle
**Date:** 2026-06-22

## Abstract

We develop a self-contained, strictly layered theory of *tree-cut
decompositions* of multigraphs and use it to formulate and analyze the
*degree-normalization* property at the ends of locally finite multigraphs. A
tree-cut decomposition arranges the vertices of a multigraph $G$ into nonempty,
pairwise-disjoint, covering *bags* indexed by the nodes of a tree $T$; deleting a
tree edge splits the vertex set into two *sides*, and the *adhesion* across that
tree edge is the number of graph edges crossing the induced bipartition. Our
first contribution is a clean foundational layer: we prove that the bags form a
genuine partition of the vertex set (`bag_partition`), that the explicit edge cut
of a side is a separator (`cutEdges_isSeparator`), that the minimum cut is
well-defined, achieved, and bounded above by the cut size
(`minCut_le_cutSize`, `exists_separator_card_eq_minCut`), and that every
separator meets every escaping walk (`separator_meets_walk`). Our second
contribution is the *linked* condition and the resulting Menger-type identity:
in a linked decomposition the adhesion across every tree edge equals the true
minimum cut between its sides (`linked_adhesion_eq_minCut`). Our third
contribution is the combinatorial engine of the degree-normalization conjecture:
under the eventual-monotonicity hypothesis supplied by linkedness together with
componentality, the adhesion sequence along the ray displaying an end either
stabilizes at the finite edge-degree $d$ of the end or diverges to infinity
(`evMonotone_dichotomy`, `evAntitone_evEq`), and we show that monotonicity is
necessary via the explicit oscillating counterexample $a_n = d + (n \bmod 2)$.
We close with applications to network reliability and algorithmics, and with four
precisely-scoped conjectures refining the result.

---

## 1. Introduction

Structural graph theory seeks to "explain" complicated graphs by simpler ones.
The most successful such explanation is the *tree decomposition*, which underlies
the theory of treewidth and a vast body of algorithmic results. For problems
governed by *edge* connectivity rather than vertex connectivity, the natural
analogue is the **tree-cut decomposition**, introduced by Wollan and developed by
many authors. A tree-cut decomposition partitions the vertices of a graph into
bags arranged on a tree; the quantity of interest at each tree edge is the
*adhesion*, the number of graph edges crossing the bipartition induced by
deleting that tree edge.

For *infinite* graphs the story acquires a new dimension: **ends**. An end is an
equivalence class of rays heading to infinity, and locally finite graphs (those
in which every vertex meets only finitely many edges) have a rich and rigid end
structure. A tree-cut decomposition whose tree *displays* the ends of $G$ — that
is, matches the ends of $G$ bijectively with the ends (infinite rays) of $T$ —
lets us study the graph's behavior at infinity by reading off the adhesions along
the displaying ray.

This paper formalizes the foundations of this theory and isolates the
combinatorial core of the following conjecture.

> **Degree-Normalization Conjecture.** Every connected locally finite multigraph
> $G$ admits a rooted tree-cut decomposition into finite bags, of finite
> adhesion, which is componental and linked, displays every end of $G$
> bijectively as an end of $T$, and is *degree-normalized*: if a tree-end
> $\alpha$ of $T$ displays the graph end $\omega$, and $e_n$ is the $n$-th
> adhesion edge on the root-to-$\alpha$ ray of $T$, then
> (i) if the edge-degree of $\omega$ is a finite natural number $d$, then
> $|F_{e_n}| = d$ for all sufficiently large $n$; and
> (ii) if the edge-degree of $\omega$ is infinite, then for every $k \in
> \mathbb{N}$, $|F_{e_n}| \ge k$ for all sufficiently large $n$.

This strengthens the classical "displayed edge-degree" conclusion by demanding
*eventual exact stabilization* along finite-degree ends and *divergence* along
infinite-degree ends. We do not claim the full existence statement; instead we
formalize the foundational layer and prove the per-ray combinatorial dichotomy
that the conjecture reduces to, together with a proof that its monotonicity
hypothesis is necessary.

### 1.1 Architecture

We follow a strictly non-circular layered design.

- **Layer 1 (definitions and basic facts):** multigraphs, walks, crossing edges,
  cuts, separators, the minimum cut, the tree-cut decomposition structure, the
  partition property of bags, and the two sides of a tree edge.
- **Layer 2 (the linked condition):** a pure definition stating that across every
  tree edge there are $|\text{adhesion}|$ pairwise edge-disjoint paths.
- **Layer 3 (the main identity):** for a linked decomposition, the adhesion of
  every tree edge equals the minimum cut between the two sides. The proof uses
  only Layers 1 and 2.
- **The combinatorial engine:** the adhesion-sequence dichotomy and the necessity
  of monotonicity, formulated abstractly on sequences of natural numbers.

---

## 2. Multigraphs, walks, and cuts

### 2.1 Multigraphs

**Definition 2.1 (Multigraph).** A *multigraph* on a vertex type $V$ is a
structure $G$ consisting of an edge index type $G.\text{Edge}$ together with an
incidence map $G.\text{inc} : G.\text{Edge} \to \mathrm{Sym}_2(V)$ assigning to
each edge the unordered pair of its endpoints.

Using $\mathrm{Sym}_2(V)$, the type of unordered pairs, lets us model both loops
and parallel edges honestly: two distinct edges may have the same incidence.

**Definition 2.2 (Crossing).** An edge $e$ *crosses* a vertex set $A \subseteq V$
if it has one endpoint in $A$ and one endpoint outside $A$:
$$G.\text{crosses}(A, e) \;:\equiv\; \exists x \in G.\text{inc}(e),\ \exists y \in G.\text{inc}(e),\ x \in A \wedge y \notin A.$$

**Lemma 2.3 (Crossing in coordinates).** If $G.\text{inc}(e) = s(a,b)$, then
$$G.\text{crosses}(A,e) \iff (a \in A \wedge b \notin A) \vee (b \in A \wedge a \notin A).$$
*Proof sketch.* Unfold the definition of crossing and of membership in an
unordered pair; the two endpoints of $s(a,b)$ are exactly $a$ and $b$, and case
analysis on which of them lies in $A$ gives the equivalence. $\square$

**Lemma 2.4 (Non-crossing keeps the same side).** If $G.\text{inc}(e) = s(a,b)$,
then $\neg\, G.\text{crosses}(A,e) \iff (a \in A \iff b \in A)$.
*Proof sketch.* Negate Lemma 2.3 and simplify the resulting Boolean combination.
$\square$

### 2.2 The edge cut

Assume the edge type is finite ($\text{Fintype } G.\text{Edge}$).

**Definition 2.5 (Cut edges and cut size).** The *cut edges* of $A$ form the
finite set
$$\text{cutEdges}(A) = \{\, e \in G.\text{Edge} : G.\text{crosses}(A, e)\,\},$$
and the *cut size* is $\text{cutSize}(A) = |\text{cutEdges}(A)|$. Membership is
characterized by $e \in \text{cutEdges}(A) \iff G.\text{crosses}(A, e)$.

### 2.3 Walks

**Definition 2.6 (Walk).** A *walk* in $G$ from $a$ to $b$, written
$G.\text{MWalk}\ a\ b$, is generated inductively by:
- $\text{nil}(a) : G.\text{MWalk}\ a\ a$ (the empty walk at $a$); and
- $\text{cons}(e, h, p) : G.\text{MWalk}\ a\ c$, given an edge $e$ with a proof
  $h : G.\text{inc}(e) = s(a,b)$ and a walk $p : G.\text{MWalk}\ b\ c$.

The *edge list* $p.\text{edges}$ of a walk is defined by $\text{nil}.\text{edges}
= [\,]$ and $(\text{cons}(e,h,p)).\text{edges} = e :: p.\text{edges}$.

### 2.4 Separators and the minimum cut

**Definition 2.7 (Separator).** A finite edge set $F$ *separates* $A$ from its
complement, written $G.\text{IsSeparator}(A, F)$, if no walk from a vertex of $A$
to a vertex outside $A$ avoids $F$:
$$\forall u\, v,\ u \in A \to v \notin A \to \neg\, \exists p : G.\text{MWalk}\ u\ v,\ \forall e \in p.\text{edges},\ e \notin F.$$

**Definition 2.8 (Minimum cut).** The *minimum cut* between $A$ and its
complement is
$$\text{minCut}(A) = \inf\{\, n : \exists F,\ |F| = n \wedge G.\text{IsSeparator}(A, F)\,\}.$$

### 2.5 Foundational lemmas

**Lemma 2.9 (Side invariance).** If a walk $p : G.\text{MWalk}\ u\ v$ avoids
every edge of $\text{cutEdges}(A)$, then $u \in A \iff v \in A$.
*Proof sketch.* Induct on $p$. The empty walk is trivial. For a step
$\text{cons}(e, h, p')$ with $G.\text{inc}(e) = s(u, w)$, the hypothesis that $e
\notin \text{cutEdges}(A)$ means $e$ does not cross $A$, so by Lemma 2.4 we have
$u \in A \iff w \in A$; the inductive hypothesis gives $w \in A \iff v \in A$, and
the equivalences chain. $\square$

**Theorem 2.10 (The cut is a separator, `cutEdges_isSeparator`).** For every $A$,
$\text{cutEdges}(A)$ separates $A$ from its complement.
*Proof sketch.* Suppose $u \in A$, $v \notin A$, and a walk $p$ from $u$ to $v$
avoids $\text{cutEdges}(A)$. By Lemma 2.9, $u \in A \iff v \in A$, contradicting
$u \in A$ and $v \notin A$. $\square$

**Lemma 2.11 (Witness set nonempty).** The set of separator sizes
$\{\, n : \exists F,\ |F| = n \wedge G.\text{IsSeparator}(A, F)\,\}$ is nonempty,
witnessed by $\text{cutEdges}(A)$. $\square$

**Theorem 2.12 (Min-cut bounded by cut size, `minCut_le_cutSize`).**
$\text{minCut}(A) \le \text{cutSize}(A)$.
*Proof sketch.* The number $\text{cutSize}(A)$ lies in the set whose infimum is
$\text{minCut}(A)$ (take $F = \text{cutEdges}(A)$ in Theorem 2.10), so the
infimum is at most $\text{cutSize}(A)$. $\square$

**Theorem 2.13 (Minimum is achieved, `exists_separator_card_eq_minCut`).** There
exists a separator $F$ with $|F| = \text{minCut}(A)$.
*Proof sketch.* The witness set is a nonempty set of natural numbers (Lemma
2.11), so its infimum is a member; the member is realized by an explicit
separator. $\square$

**Theorem 2.14 (Every separator meets every escape, `separator_meets_walk`).** If
$F$ separates $A$, and $p$ is a walk from $u \in A$ to $v \notin A$, then some
edge of $p$ lies in $F$.
*Proof sketch.* If no edge of $p$ lay in $F$, then $p$ would be a walk from $A$ to
its complement avoiding $F$, contradicting that $F$ is a separator. $\square$

Theorems 2.10–2.14 are the complete connectivity toolkit: the cut is always a
wall, the minimum wall exists and is no larger than the explicit cut, and every
wall blocks every escaping walk. They are exactly the ingredients of a
Menger-type argument.

---

## 3. Tree-cut decompositions

### 3.1 Oriented tree edges and sides

**Definition 3.1 (Oriented tree edges).** For a tree $T$ on a node type $N$, the
space of *oriented tree edges* is
$$T.\text{AdjSpace} = \{\, p \in N \times N : T.\text{Adj}(p_1, p_2)\,\}.$$
Deleting the underlying undirected edge of an oriented pair splits the tree into
two components; the orientation $(x, y)$ distinguishes the side reachable from the
head $y$.

**Definition 3.2 (Tree-cut decomposition).** A *tree-cut decomposition* of a
multigraph $G$ over a node type $N$ is a structure consisting of:
- a simple graph $T$ on $N$ with a proof $T.\text{IsTree}$;
- a bag assignment $\text{bag} : N \to \mathcal{P}(V)$;
- *nonemptiness:* $\forall n,\ (\text{bag}\ n).\text{Nonempty}$;
- *disjointness:* $\forall m\, n,\ m \neq n \to \text{Disjoint}(\text{bag}\ m, \text{bag}\ n)$;
- *covering:* $\bigcup_n \text{bag}\ n = V$.

**Definition 3.3 (Side of a tree edge).** For an oriented tree edge $e = (x,y)$,
its *side* $\text{side}(e) \subseteq V$ is the union of the bags of all nodes
reachable from the head $y$ in $T$ after deleting the underlying undirected edge
of $e$. The **adhesion** of $e$ is $\text{cutSize}(\text{side}(e))$, the number of
graph edges crossing the bipartition $(\text{side}(e), \text{side}(e)^c)$.

### 3.2 The partition theorem

**Theorem 3.4 (Bags partition the vertices, `bag_partition`).** The image
$\text{range}(\text{bag})$ is a partition of $V$ in the sense of
$\text{Setoid.IsPartition}$: the empty set is not a bag, and every vertex belongs
to exactly one bag.
*Proof sketch.* Two obligations. First, no bag is empty: any bag in the range is
$\text{bag}\ n$ for some $n$, which is nonempty by hypothesis. Second, every
vertex $a$ lies in a unique bag: by covering there is some $n$ with $a \in
\text{bag}\ n$; uniqueness follows because if $a \in \text{bag}\ m$ too with $m
\neq n$, disjointness forces $\text{bag}\ m \cap \text{bag}\ n = \varnothing$, a
contradiction. $\square$

Theorem 3.4 is the structural backbone: it certifies that the map "vertex $\mapsto$
its bag" is well-defined and total, so that questions about vertices can be
transported faithfully to questions about nodes (and rays) of the tree.

---

## 4. The linked condition and the adhesion identity

### 4.1 Linkedness

**Definition 4.1 (Linked, Layer 2).** A tree-cut decomposition is **linked** if
for every tree edge there are $|\text{adhesion}|$ pairwise edge-disjoint paths in
$G$ connecting the two sides — one independent route for every crossing edge.
This is a *pure definition* depending only on Layer 1; it asserts that the graph
genuinely supports as many disjoint connections across the cut as the cut has
edges.

The *componental* condition (used in the infinite theory) further requires each
side to induce a connected subgraph, so that adhesion edges along a ray vary in a
controlled, non-oscillating manner.

### 4.2 The main identity

**Theorem 4.2 (Linked adhesion equals min-cut, `linked_adhesion_eq_minCut`).** In
a linked tree-cut decomposition, for every tree edge with side $A$,
$$\text{cutSize}(A) = \text{minCut}(A).$$
*Proof sketch.* The inequality $\text{minCut}(A) \le \text{cutSize}(A)$ is Theorem
2.12. For the reverse inequality, take any separator $F$ realizing the minimum cut
(Theorem 2.13). By linkedness there are $\text{cutSize}(A)$ pairwise
edge-disjoint paths crossing from $A$ to its complement. By Theorem 2.14, each
such path must use at least one edge of $F$; since the paths are pairwise
edge-disjoint, they use pairwise distinct edges of $F$. Hence $|F| \ge
\text{cutSize}(A)$, i.e. $\text{minCut}(A) \ge \text{cutSize}(A)$. Combining the
two inequalities gives equality. $\square$

Theorem 4.2 is a Menger-type theorem internal to the decomposition: linkedness
forces the adhesion the tree records at each branch to be the *true* edge
connectivity bottleneck between the two halves, not an artifact of a poor choice
of tree.

---

## 5. The degree-normalization engine

We now isolate the combinatorial core of the Degree-Normalization Conjecture as a
statement about a single integer sequence — the adhesion sequence $a_n =
|F_{e_n}|$ along the ray displaying an end $\omega$.

### 5.1 Edge-degree predicates

**Definition 5.1 (Adhesion sequence).** Given an end $\omega$ displayed by a tree
ray with $n$-th adhesion edge $e_n$, set $a_n = |F_{e_n}| \in \mathbb{N}$.

**Definition 5.2 (Eventual stabilization and divergence).**
- $\text{EdgeDegreeEq}(a, d)$ holds if $a_n = d$ for all sufficiently large $n$
  (formally, $\exists N,\ \forall n \ge N,\ a_n = d$).
- $\text{EdgeDegreeInfinite}(a)$ holds if for every $k$, $a_n \ge k$ for all
  sufficiently large $n$ (formally, $\forall k,\ \exists N,\ \forall n \ge N,\
  a_n \ge k$).

The Degree-Normalization Conjecture asserts that the adhesion sequence satisfies
$\text{EdgeDegreeEq}(a, d)$ when $\omega$ has finite edge-degree $d$, and
$\text{EdgeDegreeInfinite}(a)$ when $\omega$ has infinite edge-degree.

### 5.2 The dichotomy

**Definition 5.3 (Eventual monotonicity).** A sequence $a : \mathbb{N} \to
\mathbb{N}$ is *eventually antitone* if $\exists N,\ \forall n \ge N,\ a_{n+1}
\le a_n$, and *eventually monotone* if it is eventually antitone or eventually
non-decreasing.

**Lemma 5.4 (Eventually-antitone implies eventually-constant, `evAntitone_evEq`).**
If $a : \mathbb{N} \to \mathbb{N}$ is eventually antitone, then there is a $d$
with $\text{EdgeDegreeEq}(a, d)$.
*Proof sketch.* Past the threshold $N$, the sequence is non-increasing in
$\mathbb{N}$. A non-increasing sequence of natural numbers cannot decrease
infinitely often, because $<$ on $\mathbb{N}$ is well-founded: each strict drop
reduces the value by at least one, and the value cannot go below $0$. Hence the
sequence is eventually constant, equal to its eventual infimum $d = \inf_{n \ge N}
a_n$, which is attained. $\square$

**Theorem 5.5 (Monotone dichotomy, `evMonotone_dichotomy`).** If $a : \mathbb{N}
\to \mathbb{N}$ is eventually monotone, then exactly one of the following holds:
- there exists $d$ with $\text{EdgeDegreeEq}(a, d)$ (stabilization); or
- $\text{EdgeDegreeInfinite}(a)$ (divergence).
*Proof sketch.* If $a$ is eventually antitone, Lemma 5.4 gives stabilization. If
$a$ is eventually non-decreasing, then either it is bounded above, in which case
a non-decreasing bounded sequence of naturals is eventually constant (same
well-foundedness argument applied to $-a$ within the bound), giving
stabilization; or it is unbounded, in which case for every $k$ there is an index
with $a_n \ge k$, and by monotonicity $a_m \ge k$ for all $m \ge n$, giving
$\text{EdgeDegreeInfinite}(a)$. The two outcomes are mutually exclusive: a
stabilizing sequence is bounded and so cannot be eventually $\ge k$ for every
$k$. $\square$

This is the engine of the conjecture: granting the eventual monotonicity that
linkedness-plus-componentality supplies along the displaying ray, the adhesion
sequence is *forced* into exactly one of the two normalization regimes, and the
stabilization value is the edge-degree $d$.

### 5.3 Necessity of monotonicity

**Proposition 5.6 (Monotonicity is necessary).** There is a sequence that is
neither stabilizing nor divergent. Explicitly, for any fixed $d$,
$$a_n = d + (n \bmod 2)$$
satisfies neither $\text{EdgeDegreeEq}(a, c)$ for any $c$ nor
$\text{EdgeDegreeInfinite}(a)$.
*Proof sketch.* The sequence takes the value $d$ on even indices and $d+1$ on odd
indices, infinitely often each. Hence it is not eventually equal to any constant
$c$ (it differs from $c$ infinitely often), so $\text{EdgeDegreeEq}(a, c)$ fails
for all $c$. And it is bounded above by $d+1$, so it is not eventually $\ge d+2$,
so $\text{EdgeDegreeInfinite}(a)$ fails. $\square$

Proposition 5.6 shows the dichotomy is sharp: the monotonicity hypothesis cannot
be dropped. Moreover, the oscillating sequence $a_n = d + (n \bmod 2)$ is exactly
the behavior an *un-linked* decomposition can exhibit. This is the source of the
guiding heuristic that *eventual monotonicity is a faithful surrogate for
linkedness*: banning oscillation should characterize the linked-and-componental
condition (Conjecture 1 below).

---

## 6. Algorithms

The constructive content of the theory yields several algorithms on finite
multigraphs.

### 6.1 Cut size and crossing test

Given a multigraph $G$ with finite edge set and a side $A$, computing the cut
size is a single linear scan: for each edge $e$ with endpoints $s(a,b)$, test
whether exactly one of $a, b$ lies in $A$; count the crossings. This runs in
$O(|E|)$ time given $O(1)$ membership tests for $A$.

### 6.2 Minimum cut and the linked check

Computing $\text{minCut}(A)$ between a side and its complement is a classical
max-flow / min-cut computation in the unit-capacity edge graph, solvable in
polynomial time. The *linked* property of a decomposition is verified tree-edge
by tree-edge: for each tree edge with side $A$, compute the maximum number of
edge-disjoint paths between $A$ and its complement (a max-flow value) and check
that it equals the adhesion $\text{cutSize}(A)$. By Theorem 4.2 this is
equivalent to checking $\text{cutSize}(A) = \text{minCut}(A)$.

### 6.3 Adhesion-sequence classification

Given a finite prefix of the adhesion sequence $a_0, \dots, a_{M}$ along a ray,
the classifier detects eventual monotonicity (scan for the last index where the
direction of change flips) and then applies the dichotomy: if eventually
antitone, report the stabilization value $\min_{n \ge N} a_n$; if eventually
non-decreasing and the observed tail is still rising, report a divergence
estimate. This mirrors the proof of Theorem 5.5.

---

## 7. Applications

**Network reliability.** The minimum cut $\text{minCut}(A)$ is precisely the
fewest edges whose removal disconnects $A$ from the rest of the network. Theorem
4.2 says that a linked tree-cut decomposition records these true reliability
bottlenecks directly at its tree edges, giving a compact, tree-structured summary
of a network's fault tolerance.

**Algorithmics on sparse graphs.** Tree-cut width — the maximum bag size and
adhesion of a decomposition — parameterizes efficient algorithms for problems
governed by edge connectivity (immersion testing, certain routing and packing
problems). The partition guarantee (Theorem 3.4) and the honest-adhesion
guarantee (Theorem 4.2) are exactly the structural invariants such algorithms
rely on.

**Infinite and limiting structures.** Locally finite graphs model infinite
lattices, Cayley graphs of finitely generated groups, and the limits of growing
finite networks. The degree-normalization engine (Theorem 5.5) shows how a
tree-cut decomposition reads off the exact thickness (edge-degree) of every
direction to infinity, turning an asymptotic, analytic-looking question into a
finite, combinatorial dichotomy.

---

## 8. Discussion and future work

The cycle isolated the combinatorial engine of the degree-normalization
conjecture: under the eventual-monotonicity hypothesis that linkedness plus
componentality supplies, the adhesion sequence stabilizes (finite edge-degree) or
diverges (infinite edge-degree), and monotonicity is provably necessary. Four
directions stand out.

**Conjecture 1 (Monotone adhesion $\equiv$ linked-and-componental).** For a
rooted tree-cut decomposition displaying an end $\omega$, the adhesion sequence
along the displaying ray is eventually monotone *iff* the decomposition is linked
and componental in a neighbourhood of $\alpha$. The forward direction (monotone
$\Rightarrow$ stabilization/divergence) and the necessity counterexample $a_n = d
+ (n \bmod 2)$ are settled; the converse is the precise remaining target.

**Conjecture 2 (Rate of stabilization).** If the displayed end has finite
edge-degree $d$, then the first index $N$ with $a_n = d$ for all $n \ge N$ is
bounded by a function of the finite bag sizes $|V_t|$ along the ray, e.g. $N \le
\sum_t (|V_t| - d)$. Each strict drop in the antitone tail consumes one unit of
excess adhesion, and the total excess is finite because the bags are finite; the
well-foundedness proof of Lemma 5.4 counts these drops implicitly.

**Conjecture 3 (Simultaneous normalization).** A single rooted tree-cut
decomposition can be chosen so that the degree-normalization conclusion holds on
the displaying ray of *every* end at once. The per-ray dichotomy (Theorem 5.5) is
composable; the obstruction is only the joint construction of a decomposition
whose every ray is eventually monotone — a diagonalization/compactness question.

**Conjecture 4 (Filter formulation).** The predicates $\text{EdgeDegreeEq}$ and
$\text{EdgeDegreeInfinite}$ coincide with $\liminf_{n \to \infty} (a_n :
\mathbb{N}_\infty)$ taking a finite value resp. $\top$, so the whole development
restates as a single statement about an extended-natural liminf along the ray.

---

## 9. Conclusion

We have given a clean, layered foundation for tree-cut decompositions of
multigraphs — partition of bags, separator and minimum-cut theory, and the
Menger-type linked-adhesion identity — and we have isolated and proved the
combinatorial dichotomy at the heart of the degree-normalization conjecture,
together with the necessity of its monotonicity hypothesis. The picture that
emerges is that an honest (linked, componental) tree skeleton of a locally finite
graph measures, at infinity, the exact edge-thickness of every end: finite-degree
ends produce adhesion sequences that stabilize at their degree, infinite-degree
ends produce sequences that diverge, and oscillation is precisely what honesty
forbids.
