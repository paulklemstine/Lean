# Exact Lower Bounds for the AVD-Total Chromatic Number of Central Graphs of Regular Graphs

## Abstract

We study the adjacent-vertex-distinguishing total chromatic number,
$\chi''_a$, of the central graph $C(G)$ of a regular graph $G$. A total
colouring assigns colours to both the vertices and the edges of a graph so that
incident and adjacent objects receive distinct colours; it is
*adjacent-vertex-distinguishing* (AVD) when, in addition, any two adjacent
vertices have distinct *colour sets* (the colour of the vertex together with the
colours of its incident edges). The central graph $C(G)$ is obtained from $G$ by
subdividing every edge once and joining every pair of non-adjacent vertices.

For every $d$-regular graph $G$ with $d \ge 2$ that is not complete, we prove
the exact lower half of the guiding conjecture $\chi''_a(C(G)) = d + 3$: namely,
$\chi''_a(C(G)) \ge d + 3$. The argument rests on four ingredients: (i) a
counting bound showing $|V(G)| \ge d + 2$; (ii) the fact that every original
vertex of $C(G)$ has degree $|V(G)| - 1$, so any two adjacent original vertices
are maximum-degree neighbours; (iii) an *adjacent equal-degree obstruction*,
which forbids AVD-total colourings whose palette has exactly $\Delta + 1$
colours whenever two adjacent vertices share the maximum degree; and (iv) an
upward-closure lemma showing that admissible palette sizes form an up-set. We
also record the sharper, size-governed bound $\chi''_a(C(G)) \ge |V(G)| + 1$,
which reveals that the conjectured equality $\chi''_a(C(G)) = d + 3$ can only hold
in the extremal regime $|V(G)| = d + 2$ — precisely the cocktail-party graphs
$K_{d+2}$ minus a perfect matching — and fails, for example, on the central
graph of the five-cycle. We close with a slate of open problems, chief among
them the matching upper bound in the extremal case.

**Keywords.** total colouring; adjacent-vertex-distinguishing; central graph;
regular graph; chromatic number; cocktail-party graph.

---

## 1. Introduction

Colouring the elements of a graph — vertices, edges, or both — subject to
conflict constraints is a central theme of combinatorics with a long history and
broad applications to scheduling, frequency assignment, and resource allocation.
Among the many refinements of the classical vertex- and edge-colouring problems,
two enrichments concern us here.

The first is **total colouring**, in which vertices and edges are coloured
simultaneously and every pair of mutually incident or adjacent elements must
receive distinct colours. The minimum number of colours is the *total chromatic
number* $\chi''(G)$. The Total Colouring Conjecture posits
$\chi''(G) \le \Delta(G) + 2$; the trivial lower bound is $\chi''(G) \ge
\Delta(G) + 1$, since a vertex of degree $\Delta$ together with its incident
edges forms a clique of size $\Delta + 1$ in the associated *total graph*.

The second is the **adjacent-vertex-distinguishing** condition. To each vertex
$w$ we associate its *colour set* $C(w)$: the colour of $w$ together with the
colours of all edges incident to $w$. A total colouring is AVD if every pair of
adjacent vertices has *distinct* colour sets. The minimum number of colours over
all AVD-total colourings is the **AVD-total chromatic number** $\chi''_a(G)$. The
distinguishing requirement couples the local properness constraint with a global
identifiability constraint, and typically pushes the chromatic parameter above
the plain total chromatic number.

The graphs we colour are **central graphs**. The central graph $C(G)$ of a
simple graph $G$ is formed by (a) subdividing each edge of $G$ exactly once,
introducing one new *subdivision vertex* per edge, and (b) adding an edge
between every pair of vertices that are non-adjacent in $G$. Central graphs
concentrate a network's structure in an extreme way: every original vertex is
joined, in $C(G)$, to all vertices except itself, and therefore attains the
maximum degree $|V(G)| - 1$. This makes central graphs a natural and demanding
testbed for distinguishing colourings.

We restrict to **regular** input graphs. A graph is $d$-regular if every vertex
has degree exactly $d$. The guiding conjecture for this family asserts a
strikingly uniform value:

> **Conjecture.** For every $d$-regular graph $G$ with $d \ge 2$ that is not
> complete, $\chi''_a(C(G)) = d + 3$.

Our contribution is to establish the **lower half** of this conjecture exactly,
for all such $G$, and to determine precisely the regime in which the conjectured
equality can possibly hold.

### Summary of results

- **(Counting bound.)** A $d$-regular graph that is not complete has at least
  $d + 2$ vertices: $|V(G)| \ge d + 2$.
- **(Degree identity.)** In $C(G)$, every original vertex has degree
  $|V(G)| - 1$, and every subdivision vertex has degree $2$.
- **(No $(d+2)$-colouring.)** For $d$-regular non-complete $G$, the central graph
  $C(G)$ admits no AVD-total colouring with $d + 2$ colours.
- **(Upward closure.)** If $C(G)$ has an AVD-total colouring with $n$ colours,
  then it has one with any $m \ge n$ colours.
- **(Main lower bound.)** Every AVD-total colouring of $C(G)$ uses at least
  $d + 3$ colours; equivalently $\chi''_a(C(G)) \ge d + 3$.
- **(Sharper size bound.)** $\chi''_a(C(G)) \ge |V(G)| + 1$, whence the
  conjectured equality can hold only when $|V(G)| = d + 2$.
- **(Concrete instance.)** For the five-cycle $C_5$ ($d = 2$), any AVD-total
  colouring of $C(C_5)$ uses at least $5$ colours.

---

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph. We write $\Delta(G)$ for its
maximum degree and $\deg_G(v)$ for the degree of a vertex $v$.

### 2.1 The total graph and total colourings

**Definition 2.1 (Total graph).** The *total graph* $T(H)$ of a graph $H$ has
vertex set $V(H) \sqcup E(H)$ (the disjoint union of the vertices and the
edges of $H$). Two elements are adjacent in $T(H)$ when they are adjacent or
incident in $H$; concretely:

- two vertices $a, b$ are adjacent in $T(H)$ iff $ab \in E(H)$;
- a vertex $a$ and an edge $e$ are adjacent in $T(H)$ iff $a \in e$ (i.e. $a$ is
  an endpoint of $e$);
- two edges $e, f$ are adjacent in $T(H)$ iff $e \ne f$ and they share an
  endpoint.

**Definition 2.2 (Total colouring).** A *total colouring* of $H$ with palette
$\kappa$ is a proper vertex colouring of $T(H)$: a map assigning to each element
of $V(H) \sqcup E(H)$ a colour in $\kappa$ so that adjacent elements of $T(H)$
receive distinct colours.

**Definition 2.3 (Colour set).** Given a total colouring $C$ and a vertex $w$ of
$H$, the *colour set* of $w$ is
$$C(w) = \{\,\text{colour of } w\,\} \cup \{\,\text{colour of } e : e \text{ is incident to } w\,\}.$$
Equivalently, $C(w)$ is the set of colours appearing on the *star* at $w$,
consisting of $w$ itself and its incident edges.

**Definition 2.4 (AVD-total colouring).** A total colouring $C$ of $H$ is
*adjacent-vertex-distinguishing* (AVD) if for every edge $ab \in E(H)$ one has
$C(a) \ne C(b)$.

**Definition 2.5 (AVD-total chromatic number).** The *AVD-total chromatic
number* of $H$ is
$$\chi''_a(H) = \min\{\, n \in \mathbb{N} : H \text{ has an AVD-total colouring with } n \text{ colours}\,\},$$
taken to be $+\infty$ (or $\top$ in the extended naturals $\mathbb{N} \cup
\{\infty\}$) if no such colouring exists. As a formal infimum,
$\chi''_a(H) = \inf\{\, n : \exists\, \text{AVD-total colouring of } H
\text{ with palette } \{1,\dots,n\}\,\}$.

### 2.2 The star clique

For a vertex $w$ of $H$, the *star* at $w$ is the family consisting of $w$
together with all edges incident to $w$. In $T(H)$, these elements are pairwise
adjacent — $w$ is incident to each of its edges, and any two edges at $w$ share
the endpoint $w$ — so the star is a clique of size $\deg_H(w) + 1$.

**Lemma 2.6 (Star clique).** For every vertex $w$, the star at $w$ is a clique
of $T(H)$ with exactly $\deg_H(w) + 1$ vertices. Consequently, in any total
colouring the star at $w$ receives $\deg_H(w) + 1$ pairwise distinct colours, so
$|C(w)| = \deg_H(w) + 1$ and $\chi''(H) \ge \Delta(H) + 1$.

*Proof.* Pairwise adjacency is immediate from Definition 2.1. The star has one
"vertex element" and $\deg_H(w)$ "edge elements", so it has $\deg_H(w) + 1$
members. A proper colouring of a clique injects it into the palette, giving
distinct colours; hence $|C(w)| = \deg_H(w) + 1$. Taking $w$ of maximum degree
yields the classical bound. $\qquad\blacksquare$

### 2.3 The central graph

**Definition 2.7 (Central graph).** The *central graph* $C(G)$ of $G$ has vertex
set $V \sqcup E$. Its adjacencies are:

- an original vertex $u$ and an original vertex $w$ are adjacent iff $u \ne w$
  and $uw \notin E$ (they are *non-adjacent* in $G$);
- an original vertex $u$ and an edge $e$ are adjacent iff $u \in e$ (i.e. $u$ is
  an endpoint of $e$, so $e$ was subdivided at $u$);
- two edges $e, f$ (subdivision vertices) are never adjacent.

Thus $C(G)$ is $G$ with each edge subdivided once (the edge object $e$ becomes a
degree-$2$ vertex joined to its two former endpoints) and with the complement of
$G$ added on the original vertices.

**Lemma 2.8 (Degrees in $C(G)$).** In $C(G)$:

1. every subdivision vertex has degree $2$;
2. every original vertex $v$ has degree $|V| - 1$; equivalently
   $\deg_{C(G)}(v) + 1 = |V|$.

*Proof.* A subdivision vertex $e = uw$ is adjacent exactly to its two endpoints
$u, w$, giving degree $2$. For an original vertex $v$: it is adjacent to the
subdivision vertex of each of its $\deg_G(v)$ incident edges, and to each of the
$|V| - 1 - \deg_G(v)$ original vertices non-adjacent to it in $G$. The total is
$\deg_G(v) + (|V| - 1 - \deg_G(v)) = |V| - 1$. $\qquad\blacksquare$

The identity in Lemma 2.8(2) is the structural heart of the paper: **all**
original vertices of $C(G)$ share the single maximum degree $|V| - 1$, and any
pair of them that is adjacent in $C(G)$ (equivalently, non-adjacent in $G$) is a
pair of adjacent maximum-degree vertices.

---

## 3. Two colouring lemmas

We isolate the two general lemmas that drive the lower bound. Neither uses
regularity; both apply to arbitrary finite simple graphs.

### 3.1 The adjacent equal-degree obstruction

**Lemma 3.1 (Colour set saturation).** Let $C$ be a total colouring of $H$ with
a palette of size exactly $\deg_H(w) + 1$. Then $C(w)$ equals the whole palette.

*Proof.* By Lemma 2.6, $|C(w)| = \deg_H(w) + 1$, which equals the palette size;
a subset of the palette of full cardinality is the palette. $\qquad\blacksquare$

**Lemma 3.2 (Adjacent equal-degree obstruction).** Suppose $u$ and $v$ are
adjacent vertices of $H$ with $\deg_H(u) = \deg_H(v) = \Delta$. Then $H$ has no
AVD-total colouring with exactly $\Delta + 1$ colours.

*Proof.* Let $C$ be a total colouring with $\Delta + 1$ colours. By Lemma 3.1
applied to both $u$ and $v$, $C(u)$ and $C(v)$ are each the entire palette, so
$C(u) = C(v)$. Since $u$ and $v$ are adjacent, $C$ violates the AVD condition.
$\qquad\blacksquare$

Lemma 3.2 is the mechanism by which "two adjacent maximum-degree vertices" forces
$\chi''_a \ge \Delta + 2$.

### 3.2 Palette upward closure

**Lemma 3.3 (Upward closure).** Let $n \le m$. If $H$ has an AVD-total colouring
with $n$ colours, then it has an AVD-total colouring with $m$ colours.

*Proof.* Fix an order-preserving injection $\iota : \{1,\dots,n\}
\hookrightarrow \{1,\dots,m\}$ and post-compose the colouring $C$ with $\iota$ to
obtain $C' = \iota \circ C$. Since $\iota$ is injective, $C'$ is again proper
(adjacent elements had distinct colours, and injectivity preserves distinctness),
so $C'$ is a total colouring with $m$ colours. Moreover, for each vertex $w$ the
new colour set is the image $C'(w) = \iota(C(w))$; since $\iota$ is injective,
the induced map on subsets is injective, so $C(a) \ne C(b) \iff C'(a) \ne
C'(b)$. Hence $C'$ is AVD. $\qquad\blacksquare$

Lemma 3.3 says the set of admissible palette sizes is an up-set: it has no gaps,
and if size $k$ is impossible then every size $\le k$ is impossible.

---

## 4. Main results

We now specialise to a $d$-regular graph $G$ with $d \ge 2$ that is not complete.
Non-completeness means there exists a pair $a \ne b$ with $ab \notin E$.

### 4.1 The counting bound

**Theorem 4.1 (Vertex-count lower bound).** If $G$ is $d$-regular and not
complete, then $|V(G)| \ge d + 2$.

*Proof.* Choose non-adjacent $a \ne b$. Consider the set $S = \{a, b\} \cup
N_G(a)$, where $N_G(a)$ is the neighbourhood of $a$. The elements are distinct:
$a \notin N_G(a)$ (no loops); $b \notin N_G(a)$ (since $ab \notin E$); and
$a \ne b$. As $|N_G(a)| = \deg_G(a) = d$ by regularity, $|S| = d + 2$. Since
$S \subseteq V$, we conclude $|V| \ge |S| = d + 2$. $\qquad\blacksquare$

### 4.2 No AVD-total colouring with $d + 2$ colours

**Theorem 4.2 (No $(d+2)$-colouring).** If $G$ is $d$-regular and not complete,
then $C(G)$ admits no AVD-total colouring with $d + 2$ colours.

*Proof.* Suppose, for contradiction, that $C$ is such a colouring, with palette
of size $d + 2$. Pick non-adjacent $a \ne b$ in $G$, so that the original
vertices $a, b$ are adjacent in $C(G)$ (Definition 2.7). By Lemma 2.6 the star
at the original vertex $a$ is a clique of $T(C(G))$ of size $\deg_{C(G)}(a) + 1 =
|V|$ (using Lemma 2.8(2)); properness injects this clique into the palette, so
$|V| \le d + 2$. Combined with Theorem 4.1 this forces $|V| = d + 2$.

Now $\deg_{C(G)}(a) = \deg_{C(G)}(b) = |V| - 1 = d + 1$, and the palette has size
$d + 2 = (d + 1) + 1 = \deg_{C(G)}(a) + 1$. The vertices $a, b$ are adjacent
maximum-degree vertices, so Lemma 3.2 applies and $C$ cannot be AVD — a
contradiction. $\qquad\blacksquare$

### 4.3 The main lower bound

**Theorem 4.3 (Main lower bound).** If $G$ is $d$-regular ($d \ge 2$) and not
complete, then every AVD-total colouring of $C(G)$ uses at least $d + 3$ colours.
Equivalently,
$$\chi''_a\big(C(G)\big) \ge d + 3.$$

*Proof.* Suppose $C$ is an AVD-total colouring of $C(G)$ with $n$ colours and,
for contradiction, $n \le d + 2$. By Lemma 3.3 (upward closure) we may pad the
palette to obtain an AVD-total colouring with exactly $d + 2$ colours. This
contradicts Theorem 4.2. Hence $n \ge d + 3$. Taking the infimum over all
AVD-total colourings gives $\chi''_a(C(G)) \ge d + 3$. $\qquad\blacksquare$

Theorem 4.3 is exactly the lower half of the guiding conjecture $\chi''_a(C(G)) =
d + 3$.

### 4.4 A concrete instance: the five-cycle

**Theorem 4.4 ($C_5$).** The five-cycle $C_5$ is $2$-regular and not complete,
and any AVD-total colouring of $C(C_5)$ uses at least $5$ colours.

*Proof.* Each vertex of $C_5$ has degree $2$, so $C_5$ is $2$-regular; and the
two vertices at distance two are non-adjacent, so $C_5$ is not complete. Applying
Theorem 4.3 with $d = 2$ gives the bound $d + 3 = 5$. $\qquad\blacksquare$

---

## 5. Sharpness, and the limits of the conjecture

The bound of Theorem 4.3 is only *half* of the story, and the other half is a
cautionary one. There is a strictly sharper lower bound that comes from the same
degree identity.

**Theorem 5.1 (Size-governed bound).** For any graph $G$ that is not complete,
$$\chi''_a\big(C(G)\big) \ge |V(G)| + 1.$$

*Proof.* Pick non-adjacent $a \ne b$; then $a, b$ are adjacent in $C(G)$ and,
by Lemma 2.8(2), both have degree $|V| - 1 = \Delta(C(G))$. They are adjacent
maximum-degree vertices, so by Lemma 3.2 no AVD-total colouring uses only
$\Delta(C(G)) + 1 = |V|$ colours; hence at least $|V| + 1$ are required.
$\qquad\blacksquare$

Now compare Theorems 4.3 and 5.1. Theorem 4.1 gives $|V| \ge d + 2$, so
$$|V| + 1 \ge d + 3.$$
The size-governed bound of Theorem 5.1 is therefore *always at least as strong*
as the degree bound of Theorem 4.3, and is *strictly stronger* precisely when
$|V| > d + 2$.

**Corollary 5.2 (Where the conjecture can hold).** For a $d$-regular non-complete
graph $G$, the conjectured equality $\chi''_a(C(G)) = d + 3$ can hold only if
$|V(G)| = d + 2$. Equivalently, the complement of $G$ must be $1$-regular — a
perfect matching — so that $G$ is the cocktail-party graph $K_{d+2}$ minus a
perfect matching.

*Proof.* If $|V| > d + 2$, then $\chi''_a(C(G)) \ge |V| + 1 \ge d + 4 > d + 3$,
contradicting the equality. Hence $|V| = d + 2$. A $d$-regular graph on $d + 2$
vertices has every vertex non-adjacent to exactly $|V| - 1 - d = 1$ other
vertex, so the complement is $1$-regular, i.e. a perfect matching. $\qquad\blacksquare$

**Example 5.3 (The five-cycle, revisited).** For $C_5$ we have $d = 2$ and
$|V| = 5 > 4 = d + 2$. Theorem 5.1 gives $\chi''_a(C(C_5)) \ge 6$, strictly
above the value $5 = d + 3$ predicted by the naïve conjecture. Thus the equality
$\chi''_a(C(G)) = d + 3$ genuinely fails on $C_5$, and the degree bound of
Theorem 4.4, while correct, is not tight for this graph.

The upshot: the elegant formula $\chi''_a(C(G)) = d + 3$ is an *extremal*
statement, meaningful only for cocktail-party graphs, and any general theory
must be phrased in terms of $|V|$ rather than $d$ alone.

---

## 6. Algorithms

We describe the constructive procedures underlying the results; their Python
realisations appear in the accompanying demonstration code.

### 6.1 Building the central graph

Given the adjacency relation of $G$ on $n$ vertices, construct $C(G)$ as follows.
Its vertices are the $n$ original vertices together with one subdivision vertex
per edge of $G$. Add, for each edge $uw$ of $G$, the two edges $u$–$s_{uw}$ and
$s_{uw}$–$w$ (where $s_{uw}$ is the corresponding subdivision vertex); and add,
for each non-adjacent pair $u \ne w$ of original vertices, the edge $uw$. The
procedure runs in $O(n^2)$ time (dominated by scanning all pairs for the
complement edges). One verifies directly that original vertices attain degree
$n - 1$ and subdivision vertices degree $2$.

### 6.2 Computing the certified lower bound

Given a regular graph $G$ of degree $d$ that is not complete, the best certified
lower bound our theory provides is
$$\text{LB}(G) = \max\big(d + 3,\; |V(G)| + 1\big) = |V(G)| + 1,$$
the equality holding because $|V| \ge d + 2$ implies $|V| + 1 \ge d + 3$. The
procedure reads off $d$ and $|V|$ and returns this value in $O(1)$ time after
$O(n^2)$ preprocessing to confirm regularity and non-completeness.

### 6.3 Verifying an AVD-total colouring

Given a proposed colouring of the vertices and edges of a graph $H$, verification
proceeds in two passes. First, *properness*: check that no two adjacent or
incident elements of $H$ share a colour. Second, *distinguishing*: for each
vertex $w$ compute its colour set $C(w)$, then check that $C(a) \ne C(b)$ for
every edge $ab$. Both passes are $O(|V(H)| + |E(H)|)$ up to the cost of set
operations, making verification efficient even where searching for a colouring
is not.

---

## 7. Applications and interpretation

Total colourings model conflict-free labelling problems in which both the
"objects" (vertices) and their "interactions" (edges) must be assigned resources
— time-slots, frequencies, channels — with no two conflicting items sharing a
resource. The adjacent-vertex-distinguishing refinement adds *local
identifiability*: neighbouring objects must present different resource
signatures, a natural requirement when a node must be able to certify that it is
not a duplicate of an adjacent node from the resources it and its links use.

Central graphs are an extremal stress test for such labelling. Because every
original vertex becomes maximum-degree, the distinguishing constraint bites as
hard as possible: adjacent maximum-degree vertices are exactly the configuration
that Lemma 3.2 shows to be obstructive. Our results quantify precisely how many
resources this extremal regime demands, and Corollary 5.2 identifies the unique
family — cocktail-party graphs — where the demand is as small as the naïve
formula predicts.

---

## 8. Discussion and future work

The results settle the lower half of the guiding conjecture and, more
informatively, expose that the conjectured equality is an extremal phenomenon.
The following directions remain.

1. **Matching upper bound in the extremal case.** For $|V| = d + 2$ (cocktail-party
   graphs $K_{d+2}$ minus a perfect matching), construct an explicit AVD-total
   colouring of $C(G)$ with $d + 3$ colours, thereby proving
   $\chi''_a(C(G)) = d + 3$ there.

2. **Exact value for cycles.** Determine $\chi''_a(C(C_n))$ as a function of $n$.
   The present results give $\ge n + 1$ (via the size-governed bound) and
   $\ge 5$ (via the degree bound); the exact value awaits a matching
   construction.

3. **Characterisation of the extremal graphs.** Formalise the equivalence:
   for a $d$-regular graph, $|V| = d + 2$ if and only if the complement is
   $1$-regular (a perfect matching).

4. **General upper bound.** Establish $\chi''_a(C(G)) \le |V(G)| + 2$ — or the
   exact value — for arbitrary regular $G$, closing the gap with the lower
   bounds proved here.

---

## 9. Conclusion

For every non-complete $d$-regular graph with $d \ge 2$, we proved
$\chi''_a(C(G)) \ge d + 3$, the exact lower half of the conjectured equality,
through a counting bound, a degree identity, an adjacent equal-degree
obstruction, and a palette upward-closure lemma. We further proved the sharper
bound $\chi''_a(C(G)) \ge |V(G)| + 1$, which shows the conjectured equality is
confined to the extremal cocktail-party family $|V| = d + 2$ and fails already on
the five-cycle. The path forward is the complementary upper bound, which — in the
extremal regime — would convert our inequality into the exact value $d + 3$.
