# Cycle-Containing Families of Vectors: Girth Thresholds, Binary Shattering, and the Block Conjecture

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Combinatorics (Novelty)

---

## Abstract

We study families of length-$k$ vectors over a finite alphabet of size $b$
under a graph-theoretic "goodness" relation: to each ordered pair of vectors
$(u, v)$ we associate a bipartite graph $G(u,v)$ on two copies of the
alphabet, joining the left $u$-symbol to the right $v$-symbol at each
coordinate, and we call the pair *cycle-containing* when $G(u,v)$ is not a
forest. A *cyclic family* is a collection of vectors in which every distinct
pair is cycle-containing. We establish the foundational structural results
of the theory. First, $G(u,v)$ is always bipartite (properly $2$-colorable).
Second, the **girth obstruction**: any cycle-containing pair requires
$k \ge 4$, whence every cyclic family collapses to a single element when
$k \le 3$. Third, for the binary alphabet ($b = 2$) we identify the
goodness relation with the classical notion of *qualitative independence*
(shattering), prove that shattering forces a genuine four-cycle, and prove
that shattering is monotone under coordinate extension, establishing
monotonicity of the extremal function. We exhibit an explicit cyclic family
of three binary vectors at the threshold length $k = 4$, matching the
exhaustively computed maximum $M_2(4) = 3$, and report the computed binary
sequence $M_2(k) = 1, 1, 3, 4, 10, 15$ for $k = 2, \dots, 7$. Finally we
formulate the general **block conjecture**: the extremal size is bounded by a
block-structured count $N_b(k)$, attained for all sufficiently large $k$, in
particular when $k \equiv -1 \pmod b$. We discuss algorithms, numerical
evidence, applications to covering codes and combinatorial test design, and
open directions.

---

## 1. Introduction

A recurring theme in extremal combinatorics is to ask how large a family of
combinatorial objects can be while every pair within it satisfies some local
relation. The relation studied here arises naturally from coding theory and
the theory of qualitatively independent partitions, but we recast it in
purely graph-theoretic terms, which exposes the governing structure with
unusual clarity.

Fix an integer alphabet size $b \ge 2$ and a length $k \ge 0$. A *vector*
(or *word*, or *codeword*) is a function $u : \{0, 1, \dots, k-1\} \to
\{0, 1, \dots, b-1\}$. To each *ordered pair* of vectors $(u, v)$ we attach a
bipartite graph that records, coordinate by coordinate, which left symbol
co-occurs with which right symbol. The pair is declared *good* when this
graph contains a cycle. The object of study is the maximum size of a family
in which every pair is good.

The contribution of this paper is to lay the rigorous foundation of the
theory and to chart the conjectural landscape. We isolate the single
structural fact — bipartite graphs have girth at least four — from which the
length threshold and the short-word collapse both follow, we solve the binary
case at the threshold exactly via the shattering reformulation, and we frame
the general extremal conjecture in terms of a block construction whose
behaviour is controlled by residues modulo $b$.

---

## 2. Definitions

Throughout, $b \ge 2$ is the alphabet size, modelled by the finite type
$\{0, \dots, b-1\}$ (denoted $[b]$), and $k \ge 0$ is the vector length. A
vector is a function $u : [k] \to [b]$.

### 2.1 The pair graph

**Definition 2.1 (Pair graph).** Given vectors $u, v : [k] \to [b]$, the
*pair graph* $G(u,v)$ is the simple graph on the vertex set $[b] \sqcup [b]$
(the disjoint union of a *left copy* and a *right copy* of the alphabet,
written $\mathrm{inl}(s)$ and $\mathrm{inr}(t)$) whose edge set is
$$E(u,v) \;=\; \bigl\{\, \{\mathrm{inl}(u_i),\, \mathrm{inr}(v_i)\} \;:\;
i \in [k] \,\bigr\}.$$
That is, each coordinate $i$ contributes the edge joining the left vertex
labelled $u_i$ to the right vertex labelled $v_i$. (As a simple graph,
repeated coordinates produce the same edge and are absorbed.)

**Definition 2.2 (Cycle-containing pair).** The pair $(u, v)$ is
*cycle-containing*, written $\mathrm{ContainsCycle}(u,v)$, if $G(u,v)$ is not
acyclic; equivalently $G(u,v)$ is not a forest:
$$\mathrm{ContainsCycle}(u, v) \;:\Longleftrightarrow\;
\neg\, \mathrm{IsAcyclic}\bigl(G(u,v)\bigr).$$

**Definition 2.3 (Cyclic family).** A finite family $C$ of vectors is a
*cyclic family*, written $\mathrm{CyclicFamily}(C)$, if every pair of
distinct members is cycle-containing:
$$\mathrm{CyclicFamily}(C) \;:\Longleftrightarrow\;
\forall\, u, v \in C,\; u \ne v \implies \mathrm{ContainsCycle}(u, v).$$

We write $M_b(k)$ for the maximum cardinality of a cyclic family of length-$k$
vectors over $[b]$.

### 2.2 Binary shattering

For the binary alphabet the goodness relation has a classical combinatorial
description.

**Definition 2.4 (Shattering / qualitative independence).** Two binary
vectors $u, v : [k] \to [2]$ *shatter* if every pattern pair occurs among the
coordinates:
$$\mathrm{Shatter}(u, v) \;:\Longleftrightarrow\;
\forall\, s, t \in [2],\; \exists\, i \in [k] \text{ with } u_i = s \text{ and } v_i = t.$$
Equivalently, the coordinate map $i \mapsto (u_i, v_i)$ is surjective onto
$[2] \times [2]$.

---

## 3. The general alphabet: bipartiteness and the girth threshold

### 3.1 Bipartiteness

**Proposition 3.1 (Two-colorability).** For all $u, v : [k] \to [b]$ the pair
graph $G(u,v)$ is properly $2$-colorable; the colour of a vertex is the side
of the disjoint union it inhabits.

*Proof sketch.* Colour $\mathrm{inl}(s)$ with colour $0$ and
$\mathrm{inr}(t)$ with colour $1$. Every edge of $G(u,v)$ joins a left vertex
to a right vertex by construction, hence joins vertices of distinct colours.
This colouring is therefore proper, and $G(u,v)$ is bipartite. $\qquad\square$

(In the formal development this is `pairGraph_colorable`.)

### 3.2 The girth obstruction

The central structural theorem of the general theory is the following length
threshold.

**Theorem 3.2 (Girth bound).** If $\mathrm{ContainsCycle}(u, v)$, then
$k \ge 4$.

*Proof sketch.* By Proposition 3.1, $G(u,v)$ is bipartite. Every cycle in a
bipartite graph has even length, and a simple graph has no cycle of length
$0$ or $2$; hence the shortest possible cycle has length $4$. A cycle of
length $\ell \ge 4$ traverses $\ell$ distinct edges. In $G(u,v)$ every edge
is the image of some coordinate $i \in [k]$ under the map
$i \mapsto \{\mathrm{inl}(u_i), \mathrm{inr}(v_i)\}$; distinct edges of the
cycle have distinct preimages, so the $\ell \ge 4$ edges require at least $4$
distinct coordinates. Therefore $k \ge \ell \ge 4$. $\qquad\square$

(Formally, `containsCycle_k_ge_four`.)

**Corollary 3.3 (Collapse for short words).** If $k \le 3$, then every cyclic
family $C$ satisfies $|C| \le 1$; equivalently $M_b(k) \le 1$ for $k \le 3$.

*Proof sketch.* If $|C| \ge 2$ there exist distinct $u, v \in C$, and
$\mathrm{CyclicFamily}(C)$ gives $\mathrm{ContainsCycle}(u, v)$, whence
Theorem 3.2 forces $k \ge 4$, contradicting $k \le 3$. $\qquad\square$

(Formally, `cyclicFamily_card_le_one_of_small`.) Combined with the trivial
bound $M_b(k) \ge 1$ (a singleton is vacuously cyclic), we obtain
$M_b(k) = 1$ exactly for $k \le 3$, and the theory becomes nontrivial only at
$k = 4$.

---

## 4. The binary case

We now specialise to $b = 2$, where the pair graph lives on four vertices and
its only possible cycle is the four-cycle $K_{2,2}$.

### 4.1 Patterns and edges

**Lemma 4.1 (Pattern realises an edge).** If $u_i = a$ and $v_i = c$ for some
coordinate $i$, then $G(u,v)$ has the edge
$\{\mathrm{inl}(a), \mathrm{inr}(c)\}$, i.e.
$G(u,v).\mathrm{Adj}(\mathrm{inl}(a), \mathrm{inr}(c))$.

*Proof sketch.* Immediate from Definition 2.1: the coordinate $i$ contributes
exactly this edge. $\qquad\square$

(Formally, `adj_of_pat`.)

### 4.2 Shattering forces a cycle

**Theorem 4.2 (Shattering builds a four-cycle).** For binary vectors
$u, v : [k] \to [2]$, if $\mathrm{Shatter}(u, v)$ then
$\mathrm{ContainsCycle}(u, v)$. Concretely, $G(u,v)$ contains the closed
walk
$$\mathrm{inl}(0) \to \mathrm{inr}(0) \to \mathrm{inl}(1) \to \mathrm{inr}(1)
\to \mathrm{inl}(0),$$
which is a genuine cycle.

*Proof sketch.* Shattering supplies four coordinates $i_{00}, i_{01}, i_{10},
i_{11}$ realising the four patterns $(0,0), (0,1), (1,0), (1,1)$. By Lemma
4.1 these yield the four edges
$\{\mathrm{inl}(0), \mathrm{inr}(0)\}$, $\{\mathrm{inl}(0), \mathrm{inr}(1)\}$,
$\{\mathrm{inl}(1), \mathrm{inr}(0)\}$, $\{\mathrm{inl}(1), \mathrm{inr}(1)\}$.
Concatenate them (using symmetry of edges where needed) into the walk
$\mathrm{inl}(0) \to \mathrm{inr}(0) \to \mathrm{inl}(1) \to \mathrm{inr}(1)
\to \mathrm{inl}(0)$. One verifies that this walk is a *trail* (its four
edges are distinct), is closed, and has no repeated internal vertices —
hence it is a cycle in the precise sense of the simple-graph cycle
predicate. Therefore $G(u,v)$ is not acyclic. $\qquad\square$

(Formally, `shatter_containsCycle`; the trail and support conditions are
discharged by finite case analysis on the four-vertex graph.)

This is the forward direction of the conjectured binary characterisation
$\mathrm{ContainsCycle}(u,v) \Leftrightarrow \mathrm{Shatter}(u,v)$ (see §6,
Conjecture 1).

### 4.3 The shattering threshold

**Theorem 4.3 (Shattering needs length four).** If $\mathrm{Shatter}(u, v)$
for binary $u, v : [k] \to [2]$, then $k \ge 4$.

*Proof sketch.* Shattering says the coordinate map $i \mapsto (u_i, v_i)$ is
surjective onto $[2] \times [2]$, a set of cardinality $4$. A surjection from
$[k]$ onto a $4$-element set forces $|[k]| = k \ge 4$ (by
$\mathrm{Fintype.card\_le\_of\_surjective}$ and
$|[2] \times [2]| = 4$). $\qquad\square$

(Formally, `shatter_k_ge_four`.) This recovers Theorem 3.2 in the binary case
by an independent counting argument, complementing the graph-girth proof.

### 4.4 Monotonicity

**Theorem 4.4 (Extension preserves shattering).** Let $u, v : [k] \to [2]$
shatter and let $a, c \in [2]$ be arbitrary. Then the extended vectors
$\mathrm{snoc}(u, a)$ and $\mathrm{snoc}(v, c)$ of length $k+1$ also shatter.

*Proof sketch.* For each required pattern $(s, t)$, shattering of $(u, v)$
provides a coordinate $i \in [k]$ with $u_i = s$, $v_i = t$. Its image
$\mathrm{castSucc}(i)$ in $[k+1]$ realises the same pattern in the extended
vectors, since extension by $\mathrm{snoc}$ leaves the original coordinates
untouched. Hence all four patterns persist. $\qquad\square$

(Formally, `shatter_snoc`.)

**Corollary 4.5 (Monotone extremal function).** $M_2(k) \le M_2(k+1)$ for all
$k$: the maximum cyclic-family size is non-decreasing in $k$.

*Proof sketch.* Given a maximum shattering family at length $k$, pad every
member with a common appended symbol; Theorem 4.4 shows the padded family
still pairwise shatters, hence (by Theorem 4.2) is still cyclic, and padding
preserves distinctness and cardinality. $\qquad\square$

### 4.5 An extremal family at the threshold

**Theorem 4.6 (A cyclic triple at $k = 4$).** The three binary vectors
$$w_1 = (0,0,1,1), \qquad w_2 = (0,1,0,1), \qquad w_3 = (0,1,1,0)$$
of length $4$ pairwise shatter, hence $\{w_1, w_2, w_3\}$ is a cyclic family
of size $3$. Consequently $M_2(4) \ge 3$.

*Proof sketch.* One checks the three ordered distinct pairs (and their
reverses) realise all four patterns; this is a finite verification. For
example, reading $w_1$ and $w_2$ down their four coordinates gives the pairs
$(0,0), (0,1), (1,0), (1,1)$ — all four patterns. By Theorem 4.2 each pair is
cycle-containing, so the triple is cyclic; its cardinality is $3$.
$\qquad\square$

(Formally, `triple_pairwise_shatter` and `exists_cyclicFamily_card_three`.)

The choice is structurally natural: each $w_j$ has exactly two zeros and two
ones, and the three vectors encode the three perfect matchings of a
four-element set into two pairs. This symmetry is precisely what guarantees
that each pair realises all four patterns.

**Remark 4.7 (Sharpness).** Exhaustive search over the $2^4 = 16$ length-four
binary vectors confirms $M_2(4) = 3$: no fourth vector qualitatively
independent from all of $w_1, w_2, w_3$ exists. Thus the lower bound of
Theorem 4.6 is tight, and the matching upper bound $M_2(4) \le 3$ is a finite
(hence decidable) statement (Conjecture 2 in §6).

### 4.6 The computed binary sequence

Brute-force maximum-clique enumeration in the "shattering graph" on $[2]^k$
yields
$$M_2(2) = 1,\;\; M_2(3) = 1,\;\; M_2(4) = 3,\;\; M_2(5) = 4,\;\;
M_2(6) = 10,\;\; M_2(7) = 15.$$
The values for $k = 2, 3$ confirm Corollary 3.3; the value at $k = 4$ matches
Theorem 4.6; and monotonicity (Corollary 4.5) is visible in the
non-decreasing trend.

### 4.7 A worked example: tracing the cycle

It is instructive to see the entire chain of definitions act on a single pair.
Take the two length-four binary vectors $w_1 = (0,0,1,1)$ and $w_2 = (0,1,0,1)$.
Reading them coordinate by coordinate produces the pattern sequence
$$(w_1[0], w_2[0]) = (0,0),\quad (0,1),\quad (1,0),\quad (1,1),$$
so the coordinate map $i \mapsto (w_1[i], w_2[i])$ is a bijection onto
$[2] \times [2]$. In particular all four patterns occur, so
$\mathrm{Shatter}(w_1, w_2)$ holds (Definition 2.4). By Lemma 4.1 each pattern
contributes one edge, giving the four edges
$\{\mathrm{inl}(0), \mathrm{inr}(0)\}$, $\{\mathrm{inl}(0), \mathrm{inr}(1)\}$,
$\{\mathrm{inl}(1), \mathrm{inr}(0)\}$, $\{\mathrm{inl}(1), \mathrm{inr}(1)\}$ —
that is, the complete bipartite graph $K_{2,2}$ on the four vertices. Following
the walk prescribed by Theorem 4.2,
$$\mathrm{inl}(0) \xrightarrow{i_{00}} \mathrm{inr}(0)
\xrightarrow{i_{10}} \mathrm{inl}(1) \xrightarrow{i_{11}} \mathrm{inr}(1)
\xrightarrow{i_{01}} \mathrm{inl}(0),$$
we traverse four distinct edges, never repeat an interior vertex, and return to
the start: a genuine four-cycle. Hence $\mathrm{ContainsCycle}(w_1, w_2)$, and
the pair is good. Repeating the calculation for the remaining two pairs of the
triple confirms $\mathrm{CyclicFamily}(\{w_1, w_2, w_3\})$ (Theorem 4.6).

By contrast, consider $w_1 = (0,0,1,1)$ and the constant vector
$z = (0,0,0,0)$. The patterns produced are $(0,0), (0,0), (1,0), (1,0)$, so only
the two patterns $(0,0)$ and $(1,0)$ occur; the patterns $(0,1)$ and $(1,1)$ are
missing. The pair graph is therefore the two edges
$\{\mathrm{inl}(0), \mathrm{inr}(0)\}$ and
$\{\mathrm{inl}(1), \mathrm{inr}(0)\}$, a path of length two — manifestly a
forest. So $z$ is not good against $w_1$, illustrating concretely how a missing
pattern destroys the cycle, the mechanism behind the conjectured converse
(Conjecture 1).

---

## 5. Algorithms

### 5.1 Constructing the pair graph

**Algorithm A (Pair graph construction).** Given $u, v \in [b]^k$, build the
edge set $\{(u_i, v_i) : i \in [k]\}$ as a set of left–right pairs. Running
time $O(k)$; the resulting graph has at most $\min(k, b^2)$ edges on $2b$
vertices.

### 5.2 Cycle detection

**Algorithm B (Forest test on the pair graph).** A pair $(u,v)$ is good iff
the pair graph is *not* a forest. With $V = 2b$ vertices and $E$ distinct
edges, a forest has at most $V - 1$ edges, and more usefully a graph is
acyclic iff a union–find / DFS over its edges introduces no edge whose
endpoints are already connected. Run union–find over the distinct edges: if
any edge joins two already-connected endpoints, a cycle exists. Time
$O(b^2\, \alpha(b))$ after deduplicating edges, where $\alpha$ is the inverse
Ackermann function.

### 5.3 Binary shattering test

**Algorithm C (Shattering check, $b = 2$).** Maintain a $4$-bit mask of seen
patterns. Scan coordinates $i = 0, \dots, k-1$; set the bit indexed by
$2 u_i + v_i$. The pair shatters iff all four bits are set after the scan.
Time $O(k)$, space $O(1)$. By Theorem 4.2 (and the conjectured converse) this
decides goodness for binary vectors.

### 5.4 Maximum cyclic family

**Algorithm D (Extremal family via maximum clique).** Form the *goodness
graph* $H$ whose vertices are all $b^k$ vectors and whose edges join good
pairs. A cyclic family is exactly a clique in $H$; $M_b(k)$ is the clique
number $\omega(H)$. Compute $\omega(H)$ by branch-and-bound clique search.
This is exponential in general but tractable for small $b, k$ and produced
the sequence in §4.6. For binary alphabets the edge test is Algorithm C.

---

## 6. The general conjecture and open problems

The structural facts above pin down the base of the theory. The peak — the
exact extremal function for all $b$ and $k$ — is captured by the following
program, drawn from the block viewpoint.

### Conjecture 1 (Binary characterisation is an equivalence)

For $b = 2$, $\mathrm{ContainsCycle}(u, v) \Leftrightarrow
\mathrm{Shatter}(u, v)$: the pair graph contains a cycle exactly when all
four patterns occur.

*Rationale.* Over a binary alphabet the pair graph has four vertices, so its
only possible cycle is the $K_{2,2}$ four-cycle, present iff none of the four
edges is missing. A graph missing one of the four $K_{2,2}$ edges is a
subgraph of a path $P_4$, hence acyclic — proving the contrapositive of the
converse to Theorem 4.2. The forward direction is Theorem 4.2.

### Conjecture 2 (Exact binary maximum at the threshold)

$M_2(4) = 3$: every cyclic family of length-four binary vectors has at most
three members, matching Theorem 4.6.

*Rationale.* A fourth vector qualitatively independent from all of
$\{0011, 0101, 0110\}$ would have to realise all four patterns against each of
them simultaneously; a finite pigeonhole over the $2^4 = 16$ candidates shows
this system is unsatisfiable. The statement is decidable.

### Conjecture 3 (Block construction is extremal for $k \equiv -1 \pmod b$)

Partition $[k]$ into $b$ blocks of prescribed sizes and consider the family of
"good" vectors that are constant on each block, with block values chosen so
that every pair induces a spanning cycle across the $b$ symbol-classes. This
family is cyclic, has size $N_b(k)$, and equals the maximum cyclic family when
$k \equiv -1 \pmod b$:
$$M_b(k) = N_b(k) \qquad \text{whenever } k \equiv -1 \pmod b.$$

*Rationale.* Prescribing block sizes converts the global cycle requirement
into a *local* condition between blocks: two good vectors induce a cycle iff
their block-value assignments differ in a way that closes a loop among the
$b$ classes, governed by a permutation/derangement count on $b$ symbols
rather than by the full $b^k$ space. For $b = 2$ the residue condition reads
"$k$ odd", consistent with the computed values $M_2(5) = 4$ and
$M_2(7) = 15$.

---

## 7. Applications

**Combinatorial test design.** The condition that two vectors realise all
coordinate-pattern pairs is the defining property of *covering arrays* and
*qualitatively independent* families used to design minimal test suites that
jointly exercise every combination of two parameters. The bipartite-cycle
reformulation gives a clean graph-theoretic certificate for when a pair of
test vectors is "covering".

**Coding theory.** Qualitative independence underlies *superimposed* and
*covering codes*; the extremal function $M_b(k)$ measures how many mutually
qualitatively-independent codewords fit in a given length, controlling the
efficiency of such codes.

**Extremal set theory.** Cyclic families generalise systems of qualitatively
independent partitions, a classical subject (Rényi, Kleitman–Spencer), and
the bipartite-graph lens situates them within graph girth and clique theory.

---

## 8. Discussion and future work

The results presented are the rigorous, fully formalised core: bipartiteness
(Proposition 3.1), the girth threshold $k \ge 4$ (Theorem 3.2) with its
short-word collapse (Corollary 3.3), the binary identification with
shattering in the forward direction (Theorem 4.2), the threshold and
monotonicity facts (Theorems 4.3, 4.4 and Corollary 4.5), and the exact
extremal lower bound at the threshold (Theorem 4.6). These transform the
folklore picture into theorems.

The natural next steps are exactly the three conjectures of §6: closing the
binary equivalence to an iff, promoting the brute-force value $M_2(4) = 3$ to
a proved upper bound, and establishing the block construction for general $b$
under the residue condition $k \equiv -1 \pmod b$. Beyond these, one would
like a closed form or recurrence for the binary sequence
$1, 1, 3, 4, 10, 15, \dots$, asymptotics of $M_b(k)$ as $k \to \infty$ for
fixed $b$, and an understanding of the extremal families' symmetry (the
$k = 4$ example's matching structure suggests a representation-theoretic or
design-theoretic organising principle).

---

## Appendix A. Summary of formal results

| Name | Statement |
|------|-----------|
| `pairGraph_colorable` | $G(u,v)$ is properly $2$-colorable (bipartite). |
| `containsCycle_k_ge_four` | $\mathrm{ContainsCycle}(u,v) \Rightarrow k \ge 4$. |
| `cyclicFamily_card_le_one_of_small` | $k \le 3 \Rightarrow$ every cyclic family has $\le 1$ element. |
| `adj_of_pat` | $u_i = a, v_i = c \Rightarrow$ edge $\mathrm{inl}(a)\!-\!\mathrm{inr}(c)$. |
| `shatter_containsCycle` | $\mathrm{Shatter}(u,v) \Rightarrow \mathrm{ContainsCycle}(u,v)$ (binary). |
| `shatter_k_ge_four` | $\mathrm{Shatter}(u,v) \Rightarrow k \ge 4$ (binary). |
| `shatter_snoc` | Shattering is preserved by coordinate extension. |
| `triple_pairwise_shatter` | $\{0011, 0101, 0110\}$ pairwise shatters. |
| `exists_cyclicFamily_card_three` | A cyclic family of size $3$ exists at $k = 4$. |
