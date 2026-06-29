# A Counting-Theoretic Proof of the Parity Theorem for Eulerian Trails in Finite Multigraphs with Loops

## Abstract

We give a complete, self-contained development of the classical parity (degree)
theory of Eulerian trails in finite undirected multigraphs that may contain
loops and parallel edges. The entire theory is reduced to a single local
identity at each vertex,
$$\deg(v) + s(v) + e(v) = 2\,\mathrm{vis}(v),$$
where $\deg(v)$ is the degree of $v$ (with loops counted twice), $s(v)$ and
$e(v)$ are indicator quantities for $v$ being the start or end of the trail, and
$\mathrm{vis}(v)$ is the number of times the trail's underlying walk visits $v$.
The identity is established by elementary finite counting: by splitting the walk
either at its head or its tail, the visit count is expressed in two complementary
ways, and the degree is matched to consecutive-pair incidences through the edge
permutation that defines the trail. From this identity we deduce, with only
integer parity arithmetic, the three pillars of the classical theory: (i) any
vertex of odd degree must be the start or the end of the trail; (ii) at most two
vertices have odd degree; and (iii) if the trail is closed, every vertex has even
degree. The treatment makes explicit the role of loops, of edge orientation, and
of the bijective ("permutation") structure of an Eulerian trail, which are
precisely the subtleties that informal treatments tend to elide. All results are
phrased over finite index types and are constructive modulo classical logic.

**Keywords:** Eulerian trail, Eulerian circuit, degree, parity, handshaking,
multigraph, loop, graph theory, combinatorics.

**MSC 2020:** 05C45 (Eulerian and Hamiltonian graphs), 05C30 (enumeration in
graph theory), 05C76 (graph operations and constructions).

---

## 1. Introduction

The problem of the Seven Bridges of Königsberg, resolved by Euler in 1736, is
usually cited as the origin of graph theory. Euler's abstraction — discard the
geometry, retain only adjacency and the count of incident edges at each vertex —
yields a remarkably clean criterion for the existence of a walk that traverses
every edge exactly once. The *necessary* condition, which is the subject of the
present paper, is a statement purely about **degree parity**: in a graph admitting
an Eulerian trail, all but at most two vertices have even degree, and if the trail
is closed then *all* vertices have even degree.

While this result is elementary and ubiquitous, a fully rigorous treatment must
confront several details that casual expositions gloss over:

1. **Loops.** A loop contributes two edge-ends to a single vertex. The standard
   degree theory is only correct if loops are counted with multiplicity two; we
   build this into the definition and verify that the counting goes through.
2. **Parallel edges.** Multigraphs admit several distinct edges with identical
   endpoints; the trail must use *each* such edge exactly once. We encode this
   with a permutation of the edge set.
3. **Orientation.** In an undirected graph an edge may be traversed in either
   direction. The compatibility condition for a trail must therefore allow both
   orientations at each step, and the counting argument must be insensitive to
   the choice.

Our contribution is a development that isolates the combinatorial core of the
theory into one **local parity identity** and derives every classical consequence
from it by integer arithmetic. The identity is proved by three short counting
lemmas, each of which is a transparent reindexing of a finite sum. The result is
a treatment in which every step of the classical "handshake" argument is made
literal and auditable.

The paper is organized as follows. Section 2 fixes the combinatorial model.
Section 3 defines the relevant counting functionals. Section 4 proves the three
counting lemmas and assembles the local parity identity. Section 5 derives the
classical structure theorems. Section 6 records algorithmic consequences and
pseudocode. Section 7 discusses applications, and Section 8 lists open directions.

---

## 2. The combinatorial model

We work over finite index types throughout. Fix natural numbers $n_V$ (the number
of vertices) and $n_E$ (the number of edges). Vertices are indexed by
$\{0, 1, \dots, n_V - 1\}$ and edges by $\{0, 1, \dots, n_E - 1\}$.

**Definition 2.1 (Multigraph).** A *finite undirected multigraph with loops* on
$n_V$ vertices and $n_E$ edges is a pair of endpoint maps
$$G = (\mathrm{endpt}_1, \mathrm{endpt}_2), \qquad
\mathrm{endpt}_1, \mathrm{endpt}_2 : \{0,\dots,n_E-1\} \to \{0,\dots,n_V-1\}.$$
For an edge $e$, its two endpoints are $\mathrm{endpt}_1(e)$ and
$\mathrm{endpt}_2(e)$. The edge $e$ is a **loop** if
$\mathrm{endpt}_1(e) = \mathrm{endpt}_2(e)$.

This model permits parallel edges (distinct $e, e'$ with the same endpoint pair)
and loops, and it treats edges as undirected by symmetrizing in the trail
condition below.

**Definition 2.2 (Degree).** The *degree* of a vertex $v$ is the number of
edge-endpoint incidences equal to $v$, summed over both endpoint slots:
$$\deg_G(v) \;=\; \bigl|\{\,e : \mathrm{endpt}_1(e) = v\,\}\bigr|
\;+\; \bigl|\{\,e : \mathrm{endpt}_2(e) = v\,\}\bigr|.$$
A loop at $v$ satisfies $\mathrm{endpt}_1(e) = \mathrm{endpt}_2(e) = v$ and is
therefore counted in **both** terms, contributing $2$ to $\deg_G(v)$. This is the
unique convention under which the handshaking identity below is valid.

**Definition 2.3 (Eulerian trail).** An *Eulerian trail* on $G$ is a triple
$T = (\mathrm{verts}, \pi, \mathrm{adj})$ consisting of:

- a **walk** $\mathrm{verts} : \{0, 1, \dots, n_E\} \to \{0,\dots,n_V-1\}$, a
  sequence of $n_E + 1$ vertices;
- an **edge ordering** $\pi$, a *permutation* of the edge set $\{0,\dots,n_E-1\}$
  (so each edge is used exactly once);
- an **adjacency condition** $\mathrm{adj}$: for every step
  $i \in \{0,\dots,n_E-1\}$, the edge $\pi(i)$ joins $\mathrm{verts}(i)$ to
  $\mathrm{verts}(i+1)$ in one of the two orientations, i.e.
  $$\bigl(\mathrm{endpt}_1(\pi(i)) = \mathrm{verts}(i) \wedge
        \mathrm{endpt}_2(\pi(i)) = \mathrm{verts}(i{+}1)\bigr)$$
  $$\vee\;\bigl(\mathrm{endpt}_1(\pi(i)) = \mathrm{verts}(i{+}1) \wedge
        \mathrm{endpt}_2(\pi(i)) = \mathrm{verts}(i)\bigr).$$

The requirement that $\pi$ be a *permutation* (a bijection of the edge set) is the
formal content of "traverses every edge exactly once." The disjunction in
$\mathrm{adj}$ encodes undirectedness: an edge may be crossed from either
endpoint.

**Definition 2.4 (Start, end, closed).** The **start** of $T$ is
$\mathrm{start}(T) = \mathrm{verts}(0)$ and the **end** is
$\mathrm{last}(T) = \mathrm{verts}(n_E)$. The trail is **closed** if
$\mathrm{start}(T) = \mathrm{last}(T)$.

---

## 3. Counting functionals

Fix an Eulerian trail $T$ on $G$ and a vertex $v$. We introduce five
nonnegative-integer functionals, each an indicator sum over a finite index set.
Throughout, $[\,P\,]$ denotes the Iverson bracket, equal to $1$ when $P$ holds and
$0$ otherwise.

**Definition 3.1.**
$$
\begin{aligned}
\text{visit count:} &\quad \mathrm{vis}(v) = \sum_{j=0}^{n_E} [\,\mathrm{verts}(j) = v\,], \\
\text{start indicator:} &\quad s(v) = [\,\mathrm{verts}(0) = v\,], \\
\text{end indicator:} &\quad e(v) = [\,\mathrm{verts}(n_E) = v\,], \\
\text{head-incidence count:} &\quad c(v) = \sum_{i=0}^{n_E-1} [\,\mathrm{verts}(i) = v\,], \\
\text{tail-incidence count:} &\quad d(v) = \sum_{i=0}^{n_E-1} [\,\mathrm{verts}(i+1) = v\,].
\end{aligned}
$$
Here $c(v)$ counts steps whose **first** (earlier) endpoint is $v$, and $d(v)$
counts steps whose **second** (later) endpoint is $v$. The visit count ranges over
all $n_E + 1$ walk positions; $c$ and $d$ range over the $n_E$ steps.

These five quantities are linked by two elementary decompositions and one
structural lemma, proved next.

---

## 4. The local parity identity

**Lemma 4.1 (Split at the tail).** For every vertex $v$,
$$\mathrm{vis}(v) = c(v) + e(v).$$

*Proof sketch.* The sum defining $\mathrm{vis}(v)$ runs over positions
$0, 1, \dots, n_E$. Separate the last position $n_E$ from the rest:
$$\sum_{j=0}^{n_E} [\,\mathrm{verts}(j) = v\,]
= \sum_{j=0}^{n_E - 1} [\,\mathrm{verts}(j) = v\,] + [\,\mathrm{verts}(n_E) = v\,].$$
The first summand is exactly $c(v)$ (the first endpoints of all $n_E$ steps are
the positions $0, \dots, n_E - 1$), and the second is $e(v)$. This is the
"sum over `castSucc` plus the last term" decomposition of a sum over an index set
of size $n_E + 1$. $\qquad\blacksquare$

**Lemma 4.2 (Split at the head).** For every vertex $v$,
$$\mathrm{vis}(v) = s(v) + d(v).$$

*Proof sketch.* Separate the first position $0$ from the rest:
$$\sum_{j=0}^{n_E} [\,\mathrm{verts}(j) = v\,]
= [\,\mathrm{verts}(0) = v\,] + \sum_{j=1}^{n_E} [\,\mathrm{verts}(j) = v\,].$$
The first summand is $s(v)$. Reindexing the remaining sum by $j = i + 1$ for
$i = 0, \dots, n_E - 1$ shows it equals $d(v)$, the count of second endpoints. This
is the "first term plus sum over `succ`" decomposition. $\qquad\blacksquare$

**Lemma 4.3 (Degree equals incidence count).** For every vertex $v$,
$$\deg_G(v) = c(v) + d(v).$$

*Proof sketch.* This is the only step that uses the trail structure. Write the
degree as a sum over edges,
$$\deg_G(v) = \sum_{e} [\,\mathrm{endpt}_1(e) = v\,] + \sum_{e} [\,\mathrm{endpt}_2(e) = v\,].$$
Because $\pi$ is a permutation of the edge set, we may reindex each sum by
$e = \pi(i)$ without changing its value (a bijective change of variables on a
finite sum):
$$\deg_G(v) = \sum_{i} \Bigl([\,\mathrm{endpt}_1(\pi(i)) = v\,] + [\,\mathrm{endpt}_2(\pi(i)) = v\,]\Bigr).$$
Now apply the adjacency condition $\mathrm{adj}(i)$ pointwise. In either
orientation, the *unordered* pair of endpoints of $\pi(i)$ equals the pair
$\{\mathrm{verts}(i), \mathrm{verts}(i+1)\}$; hence
$$[\,\mathrm{endpt}_1(\pi(i)) = v\,] + [\,\mathrm{endpt}_2(\pi(i)) = v\,]
= [\,\mathrm{verts}(i) = v\,] + [\,\mathrm{verts}(i+1) = v\,].$$
Summing over $i$ gives $c(v) + d(v)$. The orientation disjunction is absorbed
because addition of the two brackets is symmetric in the endpoints. $\qquad\blacksquare$

**Theorem 4.4 (Local parity identity).** For every vertex $v$ of an Eulerian
trail $T$,
$$\boxed{\;\deg_G(v) + s(v) + e(v) = 2\,\mathrm{vis}(v).\;}$$

*Proof.* Add Lemmas 4.1 and 4.2:
$$2\,\mathrm{vis}(v) = (c(v) + e(v)) + (s(v) + d(v)) = (c(v) + d(v)) + s(v) + e(v).$$
By Lemma 4.3, $c(v) + d(v) = \deg_G(v)$. Substituting yields the identity. The
final step is pure integer arithmetic. $\qquad\blacksquare$

**Remark 4.5.** Theorem 4.4 is a strict, exact equation — not an inequality or an
asymptotic statement. Every loop, every parallel edge, and every orientation
choice is accounted for with no correction terms beyond the two endpoint
indicators. The right-hand side is manifestly even, which is the source of all
parity consequences below.

---

## 5. Classical structure theorems

**Theorem 5.1 (Odd degree forces an endpoint).** If $\deg_G(v)$ is odd, then
$v = \mathrm{start}(T)$ or $v = \mathrm{last}(T)$.

*Proof.* By Theorem 4.4, $\deg_G(v) + s(v) + e(v) = 2\,\mathrm{vis}(v)$ is even.
If $\deg_G(v)$ is odd, then $s(v) + e(v)$ must be odd, so exactly one of the
indicators $s(v), e(v)$ equals $1$. In particular at least one is $1$, i.e.
$\mathrm{verts}(0) = v$ or $\mathrm{verts}(n_E) = v$, which says $v$ is the start
or the end. $\qquad\blacksquare$

**Theorem 5.2 (At most two odd-degree vertices).** The set
$\{v : \deg_G(v)\text{ is odd}\}$ has at most two elements.

*Proof.* By Theorem 5.1, every odd-degree vertex lies in the two-element set
$\{\mathrm{start}(T), \mathrm{last}(T)\}$ (which has one element if the trail is
closed). The cardinality of a subset of a set of size at most $2$ is at most $2$.
$\qquad\blacksquare$

**Theorem 5.3 (Closed trails have all-even degree).** If $T$ is closed
($\mathrm{start}(T) = \mathrm{last}(T)$), then $\deg_G(v)$ is even for every
vertex $v$.

*Proof.* Fix $v$ and consider the indicators $s(v), e(v)$. Because
$\mathrm{verts}(0) = \mathrm{verts}(n_E)$, the conditions
"$\mathrm{verts}(0) = v$" and "$\mathrm{verts}(n_E) = v$" are equivalent, so
$s(v) = e(v)$ and hence $s(v) + e(v) \in \{0, 2\}$ is even. By Theorem 4.4,
$\deg_G(v) = 2\,\mathrm{vis}(v) - s(v) - e(v)$ is a difference of even numbers,
hence even. $\qquad\blacksquare$

**Corollary 5.4 (Euler's necessary criterion).** A finite multigraph with loops
admits an Eulerian trail only if it has at most two vertices of odd degree, and
admits a *closed* Eulerian trail only if it has no vertex of odd degree. In
particular, the Seven Bridges of Königsberg graph — whose four landmasses all
have odd degree — admits no Eulerian trail of any kind.

*Proof.* Immediate from Theorems 5.2 and 5.3. The Königsberg multigraph has four
odd-degree vertices, exceeding the maximum of two. $\qquad\blacksquare$

**Remark 5.5 (On the role of the trail).** Theorems 5.1–5.3 are statements about
the degree sequence of $G$, but their proofs *consume a trail $T$ as a witness*.
The hypotheses are not vacuous: the existence of $T$ is exactly what licenses the
permutation reindexing in Lemma 4.3 and the walk decompositions in Lemmas
4.1–4.2. Without a trail there is no parity constraint at all (an arbitrary
multigraph can have any number of odd-degree vertices).

---

## 6. Algorithmic consequences

The theory above is not merely descriptive; it is the foundation of every
practical algorithm for one-stroke traversal. We record the relevant procedures.

**6.1 Degree and parity audit.** Given endpoint arrays, computing all degrees and
the set of odd-degree vertices takes $O(n_E + n_V)$ time by a single pass that
increments two counters per edge (counting loops twice automatically, since both
endpoint slots equal the loop's vertex). By Theorem 5.2, if more than two odd
vertices are found, no Eulerian trail exists and one may halt immediately.

**6.2 Hierholzer's algorithm.** When the parity test passes (and the graph is
connected on its non-isolated vertices), an actual Eulerian trail can be
constructed in $O(n_E)$ time by Hierholzer's method: greedily extend a trail until
it gets stuck (necessarily at the start vertex, by the parity identity applied
locally), then splice in detours from any visited vertex with unused incident
edges. The parity identity is the invariant that guarantees the greedy walk can
only get stuck at an endpoint, which is what makes the splicing terminate.

**6.3 Chinese Postman reduction.** If a graph fails the closed-trail test (it has
$2k > 0$ odd vertices — always an even number, by a global handshake), the minimum
extra traversal to make all degrees even is obtained by computing a
minimum-weight perfect matching on the odd-degree vertices and duplicating the
matched shortest paths. Theorem 5.2 localizes the "defect" exactly to the odd
vertices, which is what reduces an optimization over walks to a matching problem.

Pseudocode for the audit and parity certificate:

```
function EULERIAN_PARITY_AUDIT(endpt1[0..E-1], endpt2[0..E-1], V):
    deg <- array of V zeros
    for e in 0..E-1:
        deg[endpt1[e]] <- deg[endpt1[e]] + 1
        deg[endpt2[e]] <- deg[endpt2[e]] + 1   # loop hits same index twice
    odd <- { v : deg[v] is odd }
    if |odd| = 0:  return ("closed trail possible", odd)
    if |odd| = 2:  return ("open trail possible, endpoints = odd", odd)
    return ("no Eulerian trail", odd)
```

---

## 7. Applications

**Genome assembly.** De Bruijn graph approaches to shotgun sequencing reduce
reconstruction to finding an Eulerian trail through a graph of $k$-mer overlaps.
The parity criterion governs feasibility and informs error correction when the
observed degree sequence violates the at-most-two-odd-vertices rule.

**Route inspection (Chinese Postman).** Street-sweeping, snow-plowing, meter
reading, and network link testing all seek a least-cost closed walk covering every
edge. The even-degree characterization of closed trails (Theorem 5.3) is the
optimality boundary: zero added cost iff all degrees are even.

**Fabrication toolpaths.** Plotting, laser cutting, and certain additive
manufacturing passes minimize wasted travel by approximating Eulerian traversals
of the geometry's edge graph.

**Pedagogy and puzzles.** "Draw this figure without lifting your pen" is exactly
the open-Eulerian-trail problem; the parity theorem gives the instant yes/no test.

---

## 8. Discussion and future directions

The development isolates a single load-bearing identity (Theorem 4.4) from which
the entire necessary theory follows by arithmetic. Three directions extend the
work naturally.

**D1 — Sufficiency and connectivity.** We have formalized the *necessary*
parity conditions. The converse — that a connected multigraph with at most two
odd-degree vertices *does* admit an Eulerian trail — requires a constructive
argument (e.g. a formal Hierholzer correctness proof) plus a precise notion of
connectivity on the non-isolated vertices. Pairing the present parity certificate
with such a construction would yield a full iff-characterization.

**D2 — Global handshake corollary.** The local identity summed over all vertices
yields $\sum_v \deg_G(v) = 2 n_E$, whence the number of odd-degree vertices is
always even. Formalizing this global handshaking lemma as an independent corollary
and connecting it to Theorem 5.2 would round out the parity package.

**D3 — Directed Eulerian trails.** Replacing the orientation disjunction in
Definition 2.3 with a fixed orientation yields the directed theory, where the
relevant invariant is in-degree minus out-degree. The same head/tail splitting
lemmas apply with signed counts, suggesting a unified treatment of the directed
and undirected parity identities.

**D4 — Weighted and labeled refinements.** Carrying edge labels or weights through
the counting functionals would let the identity serve as a bookkeeping backbone
for the Chinese Postman matching reduction, formalizing the localization of
traversal defect to odd-degree vertices.

**D5 — Multiplicity-aware loop calculus.** The "loops count twice" convention is
the linchpin. A refinement that tracks loops as a separate additive term
$2 \cdot \mathrm{loops}(v)$ in the degree would make the contribution of self-edges
fully explicit and ease generalizations to hypergraph incidence structures.

---

## 9. Conclusion

The parity theory of Eulerian trails, properly formalized over finite multigraphs
with loops, rests on one exact local identity:
$\deg(v) + s(v) + e(v) = 2\,\mathrm{vis}(v)$. Its proof is honest finite
counting — two walk decompositions and one permutation reindexing — and from it
the classical structure theorems (odd vertices are endpoints; at most two odd
vertices; closed trails are all-even) follow by integer parity alone. Nearly three
centuries after Königsberg, the necessary criterion is not only known but reduced
to its irreducible combinatorial atom.
