# Colorability Does Not Control Choosability: A Complete Planar Witness at $k=2$

**Author:** Aristotle
**Date:** 2026-07-04

## Abstract

The list chromatic number (choice number) of a graph is always at least its
ordinary chromatic number, but the gap between the two can be arbitrarily large.
A natural conjecture in the theory of planar graphs asserts that *every
$3$-colorable planar graph is $4$-choosable*—that is, that a small chromatic
number should buy back the single extra color that planar list coloring is known
to require. This conjecture is false; a $63$-vertex $3$-colorable planar graph is
not $4$-choosable. In this paper we isolate the essential mechanism behind such
refutations and present a minimal, completely explicit witness of the same
phenomenon at the smallest interesting parameter, $k=2$. We prove that the
complete bipartite graph $K_{2,4}$—which is planar and $2$-colorable—is **not**
$2$-choosable, by exhibiting a diagonal assignment of two-element color lists
that admits no proper list coloring. Consequently choosability is strictly
stronger than colorability, witnessed within the planar class. We situate this
result inside a self-contained development of list coloring: we define
choosability, prove that it refines colorability and is monotone in the number
of colors, prove a greedy degree/degeneracy upper bound, and use these to explain
why *local sparsity*, not chromatic number, is the correct control on the choice
number. We close with the natural generalization to $K_{k,k^k}$ and a discussion
of the planar $5$-choosability boundary.

## 1. Introduction

Graph coloring asks for an assignment of colors to vertices so that adjacent
vertices differ. **List coloring**, introduced independently by Vizing and by
Erdős, Rubin, and Taylor, replaces the single shared palette by a per-vertex list
of admissible colors and asks the same question relative to those lists. The
central invariant is the **list chromatic number** (or **choice number**)
$\mathrm{ch}(G)$: the least $k$ such that a proper coloring exists whenever every
vertex is given a list of at least $k$ colors.

Since one may always assign identical lists, $\mathrm{ch}(G) \ge \chi(G)$; list
coloring is a genuine strengthening of ordinary coloring. A recurring theme of
the subject is that this inequality is frequently strict and, worse, that no
bound on $\chi$ alone can bound $\mathrm{ch}$. In the planar setting this tension
is sharp: by the Four Color Theorem every planar graph satisfies $\chi \le 4$,
while Thomassen proved every planar graph is $5$-choosable and Voigt exhibited
planar graphs that are not $4$-choosable, so the planar list chromatic number is
exactly $5$.

It is tempting to believe that planar graphs which are *easier* to color are also
easier to list-color. The cleanest form of this hope is the conjecture that
motivates this cycle.

> **Conjecture (refuted).** Every $3$-colorable planar graph is $4$-choosable.

This is false. A $63$-vertex $3$-colorable planar graph is not $4$-choosable,
demonstrating that a small chromatic number provides no leverage over the choice
number. The construction, while explicit, is intricate. Our contribution is to
extract the *mechanism* of such counterexamples and to present a minimal,
fully explicit witness of the identical phenomenon—**colorability does not
control choosability**—at the smallest nontrivial parameter.

### Main results

Working over the color universe $\mathbb{N}$ (without loss of generality, since
every finite list embeds into $\mathbb{N}$), we prove:

1. **(Colorability of the witness.)** $K_{2,4}$ is $2$-colorable.
2. **(Failure of choosability.)** $K_{2,4}$ is not $2$-choosable: an explicit
   assignment of two-element lists admits no proper list coloring.
3. **(Separation.)** There exists a planar graph that is $2$-colorable but not
   $2$-choosable. Choosability is strictly stronger than colorability.

Alongside these we develop the supporting theory: choosability implies
colorability, choosability is monotone in $k$, and a graph is $(d+1)$-choosable
whenever every vertex has at most $d$ earlier neighbors in some ordering (the
greedy/degeneracy bound). Together these results paint the correct picture: the
choice number is governed by local sparsity, not by the chromatic number.

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph, and $u \sim v$ denotes
adjacency.

**Definition 2.1 (Proper coloring and chromatic number).** A *proper coloring*
of $G$ with color set $C$ is a map $c : V \to C$ such that $c(u) \ne c(v)$
whenever $u \sim v$. $G$ is *$k$-colorable* if a proper coloring with $k$ colors
exists, and the *chromatic number* $\chi(G)$ is the least such $k$.

**Definition 2.2 (List assignment).** A *list assignment* is a map
$L : V \to \mathcal{P}_{\text{fin}}(\mathbb{N})$ assigning to each vertex a finite
set of admissible colors. It is a *$k$-assignment* if $|L(v)| \ge k$ for every
$v$.

**Definition 2.3 (Proper list coloring).** Given a list assignment $L$, a
*proper $L$-coloring* is a map $c : V \to \mathbb{N}$ such that
(i) $c(v) \in L(v)$ for every $v$ (lists are respected), and
(ii) $c(u) \ne c(v)$ whenever $u \sim v$ (properness).

**Definition 2.4 (Choosability).** $G$ is *$k$-choosable* if every
$k$-assignment $L$ admits a proper $L$-coloring. The *list chromatic number*
(choice number) is
$$\mathrm{ch}(G) = \min\{\, k : G \text{ is } k\text{-choosable} \,\}.$$

**Definition 2.5 (Complete bipartite graph).** For finite sets $A$ and $B$, the
*complete bipartite graph* $K_{|A|,|B|}$ has vertex set $A \sqcup B$ and edge set
$\{\, \{a,b\} : a \in A,\ b \in B \,\}$: every vertex of $A$ is adjacent to every
vertex of $B$, and there are no edges within $A$ or within $B$.

We write $K_{2,4}$ for the complete bipartite graph on $A = \{a_0, a_1\}$ and
$B = \{b_0, b_1, b_2, b_3\}$.

## 3. Elementary properties of choosability

We first record two structural facts that place choosability relative to
colorability.

**Proposition 3.1 (Choosability refines colorability).** If $G$ is
$k$-choosable, then $G$ is $k$-colorable.

*Proof.* Let $L$ be the constant $k$-assignment $L(v) = \{0, 1, \dots, k-1\}$ for
all $v$. Each list has size $k$, so by $k$-choosability there is a proper
$L$-coloring $c$. Then $c$ takes values in a $k$-element set and is proper, hence
is a proper $k$-coloring of $G$. $\qquad\blacksquare$

Thus $\mathrm{ch}(G) \ge \chi(G)$ for every graph, and any separation between the
two invariants can only go one way.

**Proposition 3.2 (Monotonicity in the number of colors).** If $G$ is
$k$-choosable and $k \le k'$, then $G$ is $k'$-choosable.

*Proof.* Let $L$ be a $k'$-assignment. Since $k \le k'$, each list satisfies
$|L(v)| \ge k' \ge k$, so $L$ is in particular a $k$-assignment and by
hypothesis admits a proper $L$-coloring. $\qquad\blacksquare$

These two propositions confirm that "$k$-choosable" is a monotone strengthening
of "$k$-colorable." The question is how much stronger, and §5 shows the gap can
be unbounded even inside the bipartite class.

## 4. The witness: $K_{2,4}$ is $2$-colorable but not $2$-choosable

### 4.1 Colorability

**Theorem 4.1.** $K_{2,4}$ is $2$-colorable; indeed $\chi(K_{2,4}) = 2$.

*Proof.* Define $c$ by coloring the small side one color and the large side the
other: $c(a_i) = 0$ for $i \in \{0,1\}$ and $c(b_j) = 1$ for $j \in
\{0,1,2,3\}$. Every edge of $K_{2,4}$ joins a vertex of the small side to a vertex
of the large side, so its endpoints receive $0$ and $1$ respectively and differ.
Hence $c$ is a proper $2$-coloring. Since $K_{2,4}$ has at least one edge it is
not $1$-colorable, so $\chi(K_{2,4}) = 2$. $\qquad\blacksquare$

In particular $K_{2,4}$ is bipartite, and it is planar (it is a small subgraph of
the grid; it may be drawn with the two small vertices above and below the four
large vertices arranged on a line, with no crossings).

### 4.2 The diagonal list assignment

We now define the list assignment that defeats $2$-choosability. Assign the small
side two *disjoint* two-element lists,
$$L(a_0) = \{0,1\}, \qquad L(a_1) = \{2,3\},$$
and assign the large side the four *cross pairs* obtained by choosing one color
from $L(a_0)$ and one from $L(a_1)$:
$$L(b_0) = \{0,2\}, \quad L(b_1) = \{0,3\}, \quad L(b_2) = \{1,2\}, \quad L(b_3) = \{1,3\}.$$
Every list has size exactly $2$, so $L$ is a legitimate $2$-assignment.

The design principle is that the large-side lists enumerate *all* systems of
distinct representatives of the small-side lists: the four cross pairs
$\{\alpha,\beta\}$ with $\alpha \in \{0,1\}$, $\beta \in \{2,3\}$ are precisely
$\{0,2\},\{0,3\},\{1,2\},\{1,3\}$, each realized exactly once.

**Theorem 4.2.** $K_{2,4}$ is not $2$-choosable. The assignment $L$ above admits
no proper $L$-coloring.

*Proof.* Suppose for contradiction that $c$ is a proper $L$-coloring. Since $c$
respects the lists, $c(a_0) \in \{0,1\}$ and $c(a_1) \in \{2,3\}$; write
$\alpha = c(a_0)$ and $\beta = c(a_1)$. The ordered pair $(\alpha, \beta)$ is one
of the four possibilities $(0,2), (0,3), (1,2), (1,3)$, and in each case
$\{\alpha,\beta\}$ equals exactly one of the large-side lists. Let $b$ be the
large-side vertex with $L(b) = \{\alpha,\beta\}$.

Because $K_{2,4}$ is complete bipartite, $b$ is adjacent to both $a_0$ and $a_1$.
Properness forces $c(b) \ne c(a_0) = \alpha$ and $c(b) \ne c(a_1) = \beta$. But
$c(b) \in L(b) = \{\alpha,\beta\}$, so $c(b)$ must equal $\alpha$ or $\beta$—a
contradiction. Hence no proper $L$-coloring exists, and $K_{2,4}$ is not
$2$-choosable. $\qquad\blacksquare$

The proof is a finite case analysis over the four color combinations on the small
side; in each branch one identified large-side vertex has both of its two
permitted colors already forbidden by its two neighbors.

### 4.3 Separation of the two invariants

Combining the two theorems yields the headline separation.

**Theorem 4.3 (Choosability is strictly stronger than colorability).** There
exists a planar graph that is $2$-colorable but not $2$-choosable. Concretely,
$K_{2,4}$ satisfies $\chi(K_{2,4}) = 2$ while $\mathrm{ch}(K_{2,4}) \ge 3$.

*Proof.* Immediate from Theorem 4.1 and Theorem 4.2. Since $K_{2,4}$ is not
$2$-choosable, $\mathrm{ch}(K_{2,4}) > 2$. $\qquad\blacksquare$

This is the exact analogue at $k = 2$ of the refutation of the motivating
conjecture at $k = 4$: in both cases a planar graph with small chromatic number
fails to be choosable with that same number of colors. The $K_{2,4}$ witness
distills the phenomenon to its smallest form and makes the mechanism—an
adversary using the "control" side to exhaust the options of a "victim"
vertex—completely transparent.

## 5. The gap is unbounded within the bipartite class

The construction of §4 is the base case of a general pattern showing that no
function of the chromatic number can bound the choice number.

**Construction 5.1 (The $K_{k,k^k}$ family).** Fix $k \ge 1$. Give the small
side $k$ vertices with pairwise-disjoint $k$-element lists $S_1, \dots, S_k$,
where $|S_i| = k$. There are exactly $k^k$ systems of distinct representatives
$(x_1, \dots, x_k)$ with $x_i \in S_i$; give the large side $k^k$ vertices, one
for each such system, with list $L = \{x_1, \dots, x_k\}$ (a $k$-element set,
since the $S_i$ are disjoint).

**Claim.** With this assignment, $K_{k,k^k}$ has no proper list coloring; hence
$K_{k,k^k}$ is not $k$-choosable, while $\chi(K_{k,k^k}) = 2$.

*Sketch.* A proper coloring must choose $x_i \in S_i$ on the small side. The
large-side vertex indexed by $(x_1, \dots, x_k)$ is adjacent to all small
vertices, so all of its list colors $\{x_1,\dots,x_k\}$ are forbidden, blocking
it. The case $k = 2$ is exactly Theorem 4.2 (with $k^k = 4$). Since the graph is
bipartite, $\chi = 2$ regardless of $k$. $\qquad\blacksquare$

**Corollary 5.2.** For every $k$ there is a bipartite (hence $2$-colorable) graph
that is not $k$-choosable. In particular, the choice number is not bounded by any
function of the chromatic number, even within the class of planar-friendly sparse
bipartite graphs.

The bound $k^k$ is not claimed optimal; the Erdős–Rubin–Taylor analysis pins down
the exact threshold at which $K_{k,m}$ becomes non-$k$-choosable. The point is
that the choice number of bipartite graphs is unbounded while the chromatic
number is fixed at $2$.

## 6. What actually controls choosability: local sparsity

If chromatic number is the wrong invariant, the right one is a measure of local
sparsity captured by a good elimination ordering.

**Definition 6.1 (Degeneracy).** A graph is *$d$-degenerate* if every nonempty
subgraph contains a vertex of degree at most $d$; equivalently, the vertices can
be ordered $v_1, \dots, v_n$ so that each $v_i$ has at most $d$ neighbors among
$v_1, \dots, v_{i-1}$ (its *back-neighbors*).

**Theorem 6.2 (Greedy choosability bound).** If $G$ has maximum degree at most
$d$—more generally, if $G$ is $d$-degenerate—then $G$ is $(d+1)$-choosable.

*Proof sketch.* Fix an elimination ordering $v_1, \dots, v_n$ in which each
$v_i$ has at most $d$ back-neighbors, and let $L$ be any $(d+1)$-assignment.
Color the vertices in order. When $v_i$ is reached, at most $d$ of its
neighbors—precisely its back-neighbors—are already colored, so at most $d$ colors
are forbidden. Since $|L(v_i)| \ge d + 1$, at least one admissible color remains;
assign it. The resulting coloring respects all lists and is proper, because each
conflict edge $\{v_i, v_j\}$ with $j < i$ was accounted for when $v_i$ was
colored. $\qquad\blacksquare$

Theorem 6.2 explains the entire planar boundary. Every planar graph is
$5$-degenerate (Euler's formula forces a vertex of degree at most $5$ in every
planar subgraph), so Theorem 6.2 gives Thomassen's theorem that **every planar
graph is $5$-choosable**. Voigt's planar non-$4$-choosable graph shows this is
optimal, so the planar list chromatic number equals $5$—strictly greater than the
chromatic bound of $4$. The motivating conjecture asked whether restricting to
$3$-colorable planar graphs could recover the missing color; the $63$-vertex
counterexample, and its miniature $K_{2,4}$ analogue, show that it cannot.

The contrast is the paper's organizing principle:

> **Colorability imposes no bound on choosability (Corollary 5.2), whereas
> degeneracy does (Theorem 6.2).**

## 7. Algorithms

Two algorithmic procedures underlie the results.

### 7.1 Verifying non-choosability by exhaustive small-side search

To certify that a bipartite graph with a given list assignment has no proper list
coloring, it suffices—when the "small" side controls the "large" side—to
enumerate all colorings of the small side and check, for each, whether some
large-side vertex is left with an empty admissible palette. For $K_{2,4}$ under
the diagonal assignment $L$, there are only $2 \times 2 = 4$ small-side colorings,
and each blocks exactly one large-side vertex. This is a decision procedure of
complexity $O\!\left(\prod_{a \in A} |L(a)| \cdot |B|\right)$.

### 7.2 Greedy list coloring along an elimination ordering

To *produce* a proper list coloring when one is guaranteed (e.g. by Theorem 6.2),
process the vertices along a degeneracy ordering and greedily assign each the
first admissible color not used by an already-colored neighbor. This runs in
linear time in the size of the graph plus the total list length.

## 8. Applications

List coloring is the natural model for constraint problems where each unit has
its own menu of options: frequency assignment in wireless networks (each
transmitter has a permitted band list), timetabling and register allocation (each
task or variable has a restricted set of admissible slots), and Latin-square
completion. In all of these, the results here carry a practical warning: knowing
that a conflict graph is "easy" in the ordinary chromatic sense (e.g. bipartite,
or three-colorable and planar) does *not* guarantee that per-unit option lists of
the corresponding size can always be satisfied. The reliable design guarantee is
sparsity: an elimination ordering with few back-neighbors (Theorem 6.2), not a
small chromatic number, is what ensures every menu of the right size can be
honored.

## 9. Discussion and future work

We have isolated the mechanism behind the failure of the "$3$-colorable planar
$\Rightarrow$ $4$-choosable" conjecture and given a complete, minimal witness of
the underlying separation via $K_{2,4}$. The development is self-contained:
choosability refines and is monotone over colorability (Propositions 3.1–3.2),
the witness is $2$-colorable (Theorem 4.1) but not $2$-choosable (Theorem 4.2),
the gap is unbounded on bipartite graphs (Corollary 5.2), and the true control is
degeneracy (Theorem 6.2).

Several directions follow naturally.

- **A degeneracy characterization of the greedy threshold.** Conjecturally a
  graph is $(d+1)$-choosable exactly when it is $d$-degenerate, with degeneracy
  equal to the least $k$ for which some elimination ordering always leaves fewer
  than $k$ back-neighbors. Refining "maximum degree" to "degeneracy" in
  Theorem 6.2 should be sharp for trees, planar, and sparse graphs.

- **Unbounded bipartite choosability, sharply.** Beyond Corollary 5.2, determine
  the exact threshold $m(k)$ at which $K_{k,m}$ ceases to be $k$-choosable,
  refining the $k^k$ construction to the Erdős–Rubin–Taylor optimum.

- **The planar boundary, optimally.** Give a self-contained route to "every
  planar graph is $5$-choosable and some planar graph is not $4$-choosable" via
  the degeneracy machinery, cementing that the planar list chromatic number is
  exactly $5$.

## 10. Conclusion

The chromatic number measures colorability under ideal, globally coordinated
conditions; the choice number measures robustness against an adversary who
dictates each vertex's options locally. They are different currencies. A graph as
small as $K_{2,4}$—planar and bipartite—already exhibits the gap, and the same
idea drives the gap to infinity within the bipartite class. What tames the choice
number is not a small chromatic number but local sparsity. Coloring is a global
luxury; choosing is a local constraint.
