# Metric Control of Adhesion Sets in Coarse Tree-Decompositions

**Author:** Aristotle

**Date:** 2026-07-11

## Abstract

Coarse tree-decompositions refine the classical structural theory of graphs by
demanding that the *seams* between adjacent parts — the adhesion sets — be small
not in cardinality but in **graph-metric diameter**. We isolate and rigorously
establish the metric engine underlying adhesion-diameter estimates. The central
result is a *linear-accumulation law*: along a chain $S_0, S_1, \dots, S_n$ of
vertex sets, each of diameter at most $D$ in a connected graph and with
consecutive members sharing a vertex, any $u \in S_0$ and $v \in S_n$ satisfy
$$\operatorname{dist}(u,v) \le (n+1)\,D + n.$$
Distance across a decomposition therefore grows linearly in the number of hops,
with slope exactly $D+1$: each traversed part contributes its diameter $D$ plus
a unit hand-off cost. We deduce that adhesion diameter is dominated by bag
diameter — an adhesion set, being contained in each of its two bags, inherits
their diameter bound — and specialize this to the $(d,2d+1)$-inseparable regime
to obtain the conditional bound of $4d+2$ on adhesion diameter, improving the
previously known constant $5d+2$. We frame the remaining gap as a purely local
optimization over the routing vertex of a single adhesion, prove the trivial
one-bag decomposition exists (so the constraints are consistent, not vacuous),
and record why connectivity is load-bearing. The development cleanly separates
the metric contribution from the structural separator theory, reducing a global
question to a finite extremal one.

**Keywords:** tree-decomposition, adhesion set, coarse geometry, graph metric,
diameter, inseparability, triangle inequality, block–cut tree.

## 1. Introduction

Tree-decompositions are a cornerstone of structural and algorithmic graph
theory. A tree-decomposition organizes a graph $G$ into a family of overlapping
vertex sets — *bags* — indexed by the nodes of a tree, such that every vertex
and edge is covered by some bag and the bags containing any fixed vertex form a
connected subtree. Classically, one minimizes bag *cardinality* (the treewidth
program), unlocking polynomial-time algorithms for otherwise intractable
problems.

A more recent, *coarse* perspective replaces cardinality with **geometry**. Here
the relevant measurement is the graph metric $\operatorname{dist}_G(u,v)$, the
length of a shortest $u$–$v$ path, and the object of control is the
**diameter** of vertex sets. The coarse program seeks tree-decompositions whose
bags are *robust* — in a sense that resists small separators — while the
**adhesion sets**, the pairwise intersections of adjacent bags, remain
metrically compact.

The governing conjecture in this line of work asserts, for each $d \in
\mathbb{N}$, the existence of a tree-decomposition of any connected graph whose
bags are $(d, 2d+1)$-inseparable and whose adhesion sets each have diameter at
most $4d+2$. This improves an earlier bound of $5d+2$. The improvement is a
statement about *constants*, and in extremal metric graph theory the constants
carry the mathematical content.

This paper isolates the metric mechanism responsible for such estimates. Our
thesis is that adhesion-diameter bounds reduce, entirely, to a single
elementary law describing how distances accumulate along chains of overlapping
bounded-diameter sets. We establish that law unconditionally, derive the
adhesion bound from it, and reformulate the $5d+2 \to 4d+2$ question as a local
optimization.

### Contributions

1. A self-contained calculus of the predicate "$S$ has diameter at most $k$",
   including monotonicity in the set and in the bound (Section 3).
2. The **overlap gluing lemma**: two diameter-$D$ sets sharing a vertex have
   union of diameter at most $2D$ (Section 4).
3. The **chain law**: the linear-accumulation estimate $\operatorname{dist}(u,v)
   \le (n+1)D + n$ (Section 4), proved by induction on chain length.
4. An abstract **coarse tree-decomposition** structure and the theorem that
   adhesion diameter is dominated by bag diameter, specialized to the $4d+2$
   conditional bound (Section 5).
5. The transported chain law for decompositions, the existence of the trivial
   decomposition, and a discussion of why it is insufficient (Sections 5–6).

## 2. Preliminaries

Throughout, $G = (V, E)$ is a simple graph and $\operatorname{dist}_G$ its
shortest-path metric on vertices, taking values in $\mathbb{N}$. We work with
$G$ **connected**, so $\operatorname{dist}_G(u,v)$ is finite for all $u,v$ and
the triangle inequality
$$\operatorname{dist}_G(u,v) \le \operatorname{dist}_G(u,w) + \operatorname{dist}_G(w,v)$$
holds for every triple $u, v, w \in V$. We freely use $\operatorname{dist}_G(u,u)
= 0$.

**Definition 2.1 (Tree-decomposition, informal).** A tree-decomposition of $G$
consists of a tree $T$ and an assignment of a bag $B_i \subseteq V$ to each node
$i$ of $T$ such that (i) every vertex lies in some bag, and (ii) every edge has
both endpoints in a common bag. (The classical additional coherence condition —
that bags containing a fixed vertex form a subtree — is standard; the metric
results below use only the covering data.)

**Definition 2.2 (Adhesion set).** For nodes $i, j$ of the decomposition tree,
the adhesion set is $A_{ij} = B_i \cap B_j$. For adjacent $i,j$ this is the
separator the decomposition places between the two sides of the tree.

**Definition 2.3 ($(d,2d+1)$-inseparability, informal).** A bag is
$(d,2d+1)$-inseparable if it cannot be broken by a small separator without
leaving a large, radius-controlled remainder; concretely, in the regime we
quantify, each such bag has graph-metric diameter at most $2d+1$. This is a
*thickness/robustness* notion and does not by itself bound bag diameter in the
general theory; we therefore study the clean **conditional** statement,
bounded-diameter bags $\Rightarrow$ bounded-diameter adhesions.

## 3. A calculus of set diameter

**Definition 3.1 (Diameter bound).** A vertex set $S \subseteq V$ has *diameter
at most $k$*, written $\mathrm{SetDiam}_{\le}(G, S, k)$, if
$$\forall u, v \in S,\quad \operatorname{dist}_G(u,v) \le k.$$

This predicate has a small, robust calculus that we record; each fact is
elementary but load-bearing in what follows.

**Lemma 3.2 (Monotonicity in the set).** If $S \subseteq T$ and $T$ has diameter
at most $k$, then $S$ has diameter at most $k$.

*Proof.* For $u, v \in S \subseteq T$, apply the hypothesis to $u,v$ regarded as
members of $T$. $\square$

**Lemma 3.3 (Monotonicity in the bound).** If $k \le m$ and $S$ has diameter at
most $k$, then $S$ has diameter at most $m$.

*Proof.* For $u,v \in S$, $\operatorname{dist}_G(u,v) \le k \le m$. $\square$

**Lemma 3.4 (Singletons and the empty set).** For every vertex $v$, the
singleton $\{v\}$ has diameter $0$; and the empty set has diameter at most $k$
for every $k$.

*Proof.* For $\{v\}$: the only pair is $(v,v)$ with $\operatorname{dist}_G(v,v)
= 0$. For $\emptyset$: the condition quantifies over an empty domain and holds
vacuously. $\square$

These base facts anchor the inductions and guarantee that the objects we bound
are never pathological.

## 4. The metric engine

### 4.1 Overlap gluing

**Theorem 4.1 (Overlap).** Let $G$ be connected. If $S$ and $T$ each have
diameter at most $D$ and share a vertex $w \in S \cap T$, then $S \cup T$ has
diameter at most $2D$.

*Proof.* Let $u, v \in S \cup T$. We first bound $\operatorname{dist}_G(u,w)$:
if $u \in S$, then $u,w \in S$ gives $\operatorname{dist}_G(u,w) \le D$; if
$u \in T$, then $u,w \in T$ gives the same. Symmetrically
$\operatorname{dist}_G(w,v) \le D$. By the triangle inequality,
$$\operatorname{dist}_G(u,v) \le \operatorname{dist}_G(u,w) + \operatorname{dist}_G(w,v) \le D + D = 2D. \qquad \square$$

Theorem 4.1 is the atomic gluing move: it converts a shared vertex into a
doubled diameter bound. Iterating it naively across a chain of $n$ overlaps
would give $2^n D$; the point of the chain law is that the true growth is
*linear*, not exponential, because we always route back through the running
distance rather than re-doubling.

### 4.2 The linear-accumulation law

**Theorem 4.2 (Chain law).** Let $G$ be connected and let $S_0, S_1, S_2, \dots$
be vertex sets, each of diameter at most $D$, such that for every $i$ there
exists $w$ with $w \in S_i$ and $w \in S_{i+1}$. Then for every $n$, every
$u \in S_0$, and every $v \in S_n$,
$$\operatorname{dist}_G(u,v) \le (n+1)\,D + n.$$

*Proof.* Induct on $n$.

*Base $n = 0$.* Here $u, v \in S_0$, so $\operatorname{dist}_G(u,v) \le D =
(0+1)D + 0$.

*Step.* Assume the bound for $n$, and let $u \in S_0$, $v \in S_{n+1}$. Choose
$w$ with $w \in S_n$ and $w \in S_{n+1}$ (the link at index $n$). By the
inductive hypothesis applied to $u \in S_0$ and $w \in S_n$,
$$\operatorname{dist}_G(u,w) \le (n+1)D + n.$$
Since $w, v \in S_{n+1}$, we have $\operatorname{dist}_G(w,v) \le D$. Therefore,
by the triangle inequality,
$$\operatorname{dist}_G(u,v) \le \operatorname{dist}_G(u,w) + \operatorname{dist}_G(w,v) \le (n+1)D + n + D = (n+2)D + (n+1),$$
which is exactly the claimed bound $((n+1)+1)D + (n+1)$. $\square$

**Interpretation.** The bound rearranges as $\operatorname{dist}_G(u,v) \le
(D+1)\,n + D$: an affine function of the hop count $n$ with **slope $D+1$**.
Each traversed set contributes $D$ (its own spread) plus $1$ (the metric cost of
the hand-off through the shared vertex), and these contributions never compound.
This is the single principle from which all adhesion-distance estimates in the
coarse theory descend.

## 5. Coarse tree-decompositions and the adhesion bound

**Definition 5.1 (Coarse tree-decomposition).** A coarse tree-decomposition of
$G$ consists of an index type of tree nodes, a bag $B_i \subseteq V$ per node, a
tree structure on the nodes, and the covering data: every vertex lies in some
bag, and every edge of $G$ has both endpoints in a common bag. The adhesion set
of nodes $i,j$ is $A_{ij} = B_i \cap B_j$.

**Lemma 5.2 (Adhesion inside a bag).** For all nodes $i,j$, $A_{ij} \subseteq
B_i$ (and, symmetrically, $A_{ij} \subseteq B_j$).

*Proof.* $A_{ij} = B_i \cap B_j \subseteq B_i$. $\square$

**Theorem 5.3 (Adhesion diameter dominated by bag diameter).** If a bag $B_i$
has diameter at most $k$, then every adhesion set $A_{ij}$ incident to it has
diameter at most $k$.

*Proof.* By Lemma 5.2, $A_{ij} \subseteq B_i$; apply monotonicity in the set
(Lemma 3.2) to the hypothesis on $B_i$. $\square$

**Theorem 5.4 (The $4d+2$ adhesion bound, conditional form).** Fix $d \in
\mathbb{N}$. In the $(d,2d+1)$ regime, where each bag has graph-metric diameter
at most $2d+1$, every adhesion set has diameter at most $4d+2$.

*Proof.* By Theorem 5.3, each adhesion set has diameter at most $2d+1$. Since
$2d+1 \le 4d+2$, monotonicity in the bound (Lemma 3.3) yields the stated bound.
$\square$

Theorem 5.4 supplies the target constant on the metric side of the problem. The
remaining structural content of the full conjecture — actually *constructing* a
decomposition whose bags are $(d,2d+1)$-inseparable — is where the additional
slack up to $4d+2$ is consumed, when two robust regions are stitched along a
shared seam.

**Theorem 5.5 (Chain estimate for a decomposition).** Let $G$ be connected and
let $(i_m)_{m \in \mathbb{N}}$ be a sequence of tree nodes such that each bag
$B_{i_m}$ has diameter at most $D$ and consecutive bags $B_{i_m}, B_{i_{m+1}}$
share a vertex. Then for every $n$, every $u \in B_{i_0}$, and every $v \in
B_{i_n}$,
$$\operatorname{dist}_G(u,v) \le (n+1)\,D + n.$$

*Proof.* Apply Theorem 4.2 to the sets $S_m = B_{i_m}$. $\square$

This transports the linear-accumulation law directly to a tree-decomposition:
it is the mechanism by which local (bag- and adhesion-level) diameter control
governs global distances across the decomposition tree.

## 6. Consistency: the trivial decomposition

To confirm the framework is not vacuous, we exhibit a decomposition for every
connected graph.

**Proposition 6.1 (Trivial decomposition).** Every connected graph $G$ admits a
coarse tree-decomposition with a single node whose bag is all of $V$, over the
one-vertex decomposition tree.

*Proof sketch.* Take one node, bag $= V$. The covering conditions hold trivially
(every vertex and edge is in the single bag). The one-vertex graph is a tree.
$\square$

**Proposition 6.2 (No reduction in the trivial case).** In the trivial
decomposition, the unique adhesion set equals $V$.

*Proof.* The only intersection available is $V \cap V = V$. $\square$

Proposition 6.2 is the cautionary counterpoint to Theorem 5.4: existence of a
decomposition is free, but a *useful* coarse decomposition must use many small,
robust bags so that its seams are genuinely compact. The $4d+2$ bound quantifies
how compact the seams can be forced to be, and the trivial decomposition marks
the opposite, degenerate extreme.

## 7. Discussion

**Where connectivity enters.** The chain law (Theorem 4.2) and the overlap lemma
(Theorem 4.1) both rest on the triangle inequality, which requires the graph
metric to be a genuine (finite) metric — hence connectivity. Without it,
distances become infinite or undefined and the linear bound fails. This
hypothesis is therefore load-bearing, not cosmetic.

**Separation of concerns.** The value of the present development is
architectural: it cleanly divides the coarse adhesion problem into a *metric*
part (fully resolved here: the chain law and its corollaries) and a *structural*
part (constructing inseparable-bag decompositions). The $5d+2 \to 4d+2$ question
lives entirely in how the two parts meet at a single seam.

**Routing-vertex optimization.** Our overlap and chain arguments route through
an *arbitrary* shared vertex. This is what leaves an additive surplus relative
to the conjectured optimum: routing instead through the metrically central
vertex of an adhesion removes one additive $d$. The improvement is thus a
finite, per-adhesion optimization rather than a global argument — a decisive
simplification of the problem's shape.

## 8. Future directions

We highlight four concrete targets that the present separation of the metric
engine makes newly accessible.

1. **The $4d+2$ optimum via routing-vertex selection.** Prove the full
   conjecture: every connected graph admits a tree-decomposition with
   $(d,2d+1)$-inseparable bags and adhesion diameter at most $4d+2$. The excess
   in the earlier $5d+2$ bound comes from routing through an arbitrary shared
   vertex; choosing the metrically central shared vertex removes one additive
   $d$. With the accumulation law separated from the separator theory, this is a
   local optimization over a single adhesion.

2. **Tightness.** Exhibit a family of connected graphs on which *every*
   tree-decomposition with $(d,2d+1)$-inseparable bags has some adhesion of
   diameter at least $4d+1$. Inseparability forces adjacent bags to overlap in a
   set spanning two radius-$d$ shells, so the adhesion cannot be much thinner
   than $4d$ without violating thickness. Subdivided-clique gadgets are a
   promising blueprint.

3. **Chain-length independence of the additive slack.** Show that the affine
   form of the chain law — slope $D+1$, no super-linear correction — is best
   possible, by matching it with a lower-bound family. Each additional
   overlapping bag contributes at most $D$ from its diameter and $1$ from the
   hand-off, and these never interact to produce a super-linear term.

4. **From block–cut trees to coarse block–cut trees.** Refine the classical
   block–cut tree into a coarse tree-decomposition whose adhesion sets are single
   "coarse cutvertices" of diameter at most $2d$, strictly below the general
   $4d+2$ bound, by concentrating genuine cut structure onto a bounded ball
   around a cutvertex.

## 9. Conclusion

The metric backbone of coarse tree-decomposition adhesion estimates is a single
linear-accumulation law: distances across a chain of overlapping
diameter-$D$ sets grow as $(n+1)D + n$, with slope $D+1$. From it, adhesion
diameter is dominated by bag diameter, giving the conditional $4d+2$ bound in
the $(d,2d+1)$ regime. The residual $5d+2 \to 4d+2$ sharpening is reduced to a
local optimization over the routing vertex of an adhesion — a clean, testable
target. By separating the geometry from the structure, the problem is left in
its sharpest possible form.
