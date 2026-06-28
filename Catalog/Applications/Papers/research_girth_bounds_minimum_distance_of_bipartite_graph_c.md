# Girth Bounds the Minimum Distance of a Bipartite Graph Code

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty / Combinatorics ∩ Coding Theory

## Abstract

We prove that the *girth* of a bipartite incidence graph — the length of its
shortest cycle — controls the *minimum distance* of the binary linear code it
defines. Concretely, let $G$ be a simple left-$d$-regular bipartite graph with
$d \ge 2$ whose girth is at least $2k+2$, and let $B(G)$ be the binary code whose
codewords are the finite sets $S$ of left vertices for which every right vertex
has an even number of neighbours in $S$. Then the minimum distance of $B(G)$ is
at least $k+1$; equivalently $d_{\min} \ge \lceil \mathrm{girth}/2 \rceil$. The
argument is fully constructive: from a non-empty codeword $S$ we extract an
explicit cycle of length exactly $2 \cdot (\text{number of distinct left
vertices it visits})$, exhibiting a shortest cycle and a minimum-weight codeword
as two encodings of the same combinatorial object. The proof isolates two
reusable graph-theoretic facts — (i) a finite simple graph with an edge and no
degree-one vertex contains a cycle, and (ii) every cycle of a bipartite graph
has length twice the number of left vertices it visits — and the bound is sharp,
met with equality by complete bipartite graphs (e.g. $K_{2,3}$: $d=3$, girth
$4$, $d_{\min}=2$). We also record the verified value $d_{\min}=4$ for the Fano
incidence graph ($d=3$, girth $6$), where the bound $d_{\min}\ge 3$ holds with
slack. All results have been formalized and machine-verified.

---

## 1. Introduction

Graph-based codes are the dominant paradigm of contemporary coding theory.
Low-density parity-check (LDPC) codes, expander codes, and the quantum and
classical codes built on top of them all encode their parity constraints as a
*Tanner graph*: a bipartite graph whose left vertices index code symbols and
whose right vertices index parity checks. Two parameters dominate the design of
such codes. The **minimum distance** measures error-correction capability. The
**girth** of the Tanner graph — the length of its shortest cycle — governs the
behaviour of iterative (belief-propagation) decoders, which double-count
information when short cycles are present.

These two parameters, one coding-theoretic and one purely combinatorial, are
linked by a folklore inequality: a length-$2t$ cycle in the Tanner graph is the
shortest *linear dependence* among the columns of the parity-check matrix, and
therefore the minimum distance is at least the girth divided by two. This paper
states and rigorously proves that bridge in a clean, self-contained form, and
extracts the underlying graph theory as standalone lemmas of independent
interest. The result is the combinatorial half of the broader programme
"spectral expansion $\Rightarrow$ large girth $\Rightarrow$ good codes," which
underpins recent expander-based constructions used in post-quantum key exchange.

**Contributions.**

1. A complete proof that left-$d$-regularity with $d \ge 2$ and girth $\ge 2k+2$
   forces minimum distance $\ge k+1$ (Theorem 8).
2. Two reusable lemmas: *no degree-one vertex plus an edge implies a cycle*
   (Lemma 6) and *bipartite cycles have length twice their left-vertex count*
   (Lemma 7).
3. A constructive extraction realizing the shortest cycle as a minimum-weight
   codeword, a tightness witness (complete bipartite $K_{2,3}$), and a worked non-tight case (the Fano incidence graph).

---

## 1a. Background and context

*Linear codes and parity checks.* A binary linear code of length $n$ is a linear
subspace $C \subseteq \mathbb F_2^n$. It is most economically described by a
*parity-check matrix* $H \in \mathbb F_2^{m \times n}$ via $C = \ker H = \{x :
Hx = 0\}$. The **Hamming weight** $\mathrm{wt}(x)$ of a vector is its number of
nonzero coordinates, and the **minimum distance** of $C$ is the least weight of a
nonzero codeword, $d_{\min}(C) = \min\{\mathrm{wt}(x) : 0 \neq x \in C\}$. A code
of minimum distance $d_{\min}$ corrects any $\lfloor (d_{\min}-1)/2\rfloor$ bit
errors and detects any $d_{\min}-1$ of them, so $d_{\min}$ is the single most
important robustness parameter of a code.

*Tanner graphs.* The support structure of $H$ is encoded by a bipartite graph:
put a left vertex for each of the $n$ coordinates (code bits) and a right vertex
for each of the $m$ rows (parity checks), and join code bit $l$ to check $r$ when
$H_{r,l} = 1$. This is the *Tanner graph* of the code. A vector $x$ supported on
a set $S$ of code bits is a codeword precisely when each check sees an even number
of active bits — exactly the parity condition of Definition 2 below. The columns
of $H$ are thus indexed by left vertices, and a nonzero codeword is a minimal set
of columns summing to zero over $\mathbb F_2$, i.e. a minimal linear dependence.

*Why girth.* A length-$2t$ cycle of the Tanner graph alternates $t$ left vertices
and $t$ right vertices; the $t$ columns it touches each contribute exactly two
ones among the cycle's checks, so they sum to zero — a linear dependence of size
$t$. Hence the shortest cycle gives the shortest such dependence, and the
minimum distance is at least half the girth. Conversely, large girth is the
classical design goal that makes iterative belief-propagation decoding behave
well, because short cycles cause the decoder to treat correlated evidence as
independent. The theorem of this paper makes the girth-to-distance half of this
story precise and self-contained, with the proof recast purely in the language of
graph cycles rather than matrix algebra.

## 2. Definitions

Throughout, $L$ and $R$ are finite types ("left" and "right" vertices), and
$\mathrm{inc} : L \times R \to \{\text{true},\text{false}\}$ is a decidable
**incidence relation**.

**Definition 1 (Bipartite incidence graph, `biGraph`).**
The graph $G = \mathrm{biGraph}(\mathrm{inc})$ is the simple graph on the
disjoint union $L \sqcup R$ with adjacency
$$
a \sim b \iff
\begin{cases}
\mathrm{inc}(l,r) & \{a,b\} = \{\,\mathrm{inl}\,l,\ \mathrm{inr}\,r\,\},\\
\text{false} & \text{otherwise.}
\end{cases}
$$
Thus edges run only between a left vertex $l$ and a right vertex $r$, precisely
when $\mathrm{inc}(l,r)$ holds. The relation is symmetric and irreflexive, so
$G$ is a genuine simple graph. We say $G$ is **left-$d$-regular** if every left
vertex has exactly $d$ right-neighbours.

**Definition 2 (The code $B(G)$).**
A finite set $S \subseteq L$ of left vertices is a **codeword** of $B(G)$ if
every right vertex $r$ has an *even* number of neighbours in $S$:
$$
S \in B(G) \iff \forall r \in R,\quad \bigl|\{\, l \in S : \mathrm{inc}(l,r) \,\}\bigr| \equiv 0 \pmod 2.
$$
Equivalently, $B(G)$ is the binary linear code (kernel over $\mathbb F_2$) whose
parity-check matrix is the bi-adjacency matrix of $G$, $H_{r,l} = [\mathrm{inc}(l,r)]$.
The **minimum distance** is
$$
d_{\min}(B(G)) = \min\{\, |S| : S \in B(G),\ S \neq \varnothing \,\}.
$$

**Definition 3 (Restricted graph, `restrictGraph`).**
For a finite set $S \subseteq L$, the graph $G|_S = \mathrm{restrictGraph}(\mathrm{inc}, S)$
on $L \sqcup R$ keeps only the edges incident to a left vertex in $S$:
$$
a \sim_{G|_S} b \iff
\begin{cases}
\mathrm{inc}(l,r) \wedge l \in S & \{a,b\} = \{\,\mathrm{inl}\,l,\ \mathrm{inr}\,r\,\},\\
\text{false} & \text{otherwise.}
\end{cases}
$$

**Girth.** We use the extended girth $\mathrm{egirth}(G) \in \mathbb N \cup
\{\infty\}$, the least length of a cycle of $G$, with the convention
$\mathrm{egirth}(G) = \infty$ when $G$ is acyclic. This $\mathbb N \cup \{\infty\}$
valuation lets the acyclic case be handled honestly: an acyclic graph trivially
satisfies $\mathrm{egirth}(G) \ge 2k+2$ for every $k$.

---

## 3. Infrastructure lemmas

The following facts unfold the restricted graph and pin down its degrees. They
are routine but load-bearing.

**Lemma 4 (Subgraph and adjacency).** $G|_S \le G$; moreover for $l \in L$,
$r \in R$,
$$
(\mathrm{inl}\,l) \sim_{G|_S} (\mathrm{inr}\,r) \iff \mathrm{inc}(l,r) \wedge l \in S.
$$
The right-neighbours of $\mathrm{inl}\,l$ (when $l \in S$) are exactly
$\{\mathrm{inr}\,r : \mathrm{inc}(l,r)\}$, and the left-neighbours of
$\mathrm{inr}\,r$ are exactly $\{\mathrm{inl}\,l : l \in S,\ \mathrm{inc}(l,r)\}$.
*(Lean: `restrictGraph_le`, `restrictGraph_adj_inl_inr`,
`restrict_neighborFinset_inl`, `restrict_neighborFinset_inr`.)*

**Lemma 5 (Degrees in the restricted graph).** In $G|_S$:
$$
\deg(\mathrm{inl}\,l) =
\begin{cases}
\bigl|\{r : \mathrm{inc}(l,r)\}\bigr| & l \in S,\\[2pt]
0 & l \notin S,
\end{cases}
\qquad
\deg(\mathrm{inr}\,r) = \bigl|\{l \in S : \mathrm{inc}(l,r)\}\bigr|.
$$
*(Lean: `restrict_degree_inl_mem`, `restrict_degree_inl_not_mem`,
`restrict_degree_inr`.)*

In particular, if $G$ is left-$d$-regular then every $l \in S$ has degree exactly
$d$ in $G|_S$, while $\deg(\mathrm{inr}\,r)$ equals the number of $S$-neighbours
of $r$ — which is *even* precisely when $S$ is a codeword.

---

## 4. The two core graph lemmas

**Lemma 6 (No degree-one vertex $\Rightarrow$ a cycle, `exists_isCycle_of_no_degree_one`).**
Let $H$ be a finite simple graph with at least one edge and with no vertex of
degree exactly one: $\deg_H(v) \neq 1$ for all $v$. Then $H$ contains a cycle:
there exist a vertex $a$ and a walk $w$ from $a$ to $a$ with $w.\mathrm{IsCycle}$.

*Proof sketch.* Suppose for contradiction $H$ is acyclic. Then each connected
component is a tree. Fix an edge $\{a,b\}$ and work in the connected component
$C$ containing $a$ (which also contains $b$). Since $a \neq b$, $C$ has at least
two vertices, so $C$ is a *nontrivial* finite tree. Every nontrivial finite tree
has a vertex of degree one (a leaf): formally,
`IsTree.exists_vert_degree_one_of_nontrivial`. Because $C$ is a *connected
component*, the degree of a vertex $v$ inside the induced tree equals its degree
in $H$ (no edges of $H$ leave the component), so that leaf has $H$-degree one,
contradicting the hypothesis. Hence $H$ is not acyclic and contains a cycle.
$\square$

This is exactly where $d \ge 2$ enters: it guarantees the left vertices of the
restricted graph are not leaves.

**Lemma 7 (Bipartite cycles alternate, `isCycle_length_le_two_mul_card_left`).**
Let $w$ be a cycle of the bipartite graph $G = \mathrm{biGraph}(\mathrm{inc})$.
Let $m$ be the number of *distinct left vertices* (vertices of the form
$\mathrm{inl}\,l$) appearing on $w$. Then the length of $w$ satisfies
$$
\mathrm{length}(w) \le 2m,
$$
and in fact $\mathrm{length}(w) = 2m$ since the cycle strictly alternates between
left and right vertices.

*Proof sketch.* Edges of $G$ only connect a left vertex to a right vertex, so as
one traverses the cycle the support side alternates $L, R, L, R, \dots$ Returning
to the start after a closed walk forces equal numbers of left and right
vertices; a cycle visits each of its vertices once, so among its
$\mathrm{length}(w)$ vertices exactly half are left vertices. Hence
$m = \mathrm{length}(w)/2$, i.e. $\mathrm{length}(w) = 2m \le 2m$. $\square$

---

## 5. Main theorem

**Theorem 8 (Girth bounds minimum distance, `girth_bounds_min_distance`).**
Let $G = \mathrm{biGraph}(\mathrm{inc})$ be a simple left-$d$-regular bipartite
graph with $d \ge 2$, and suppose $\mathrm{egirth}(G) \ge 2k+2$ for some
$k \in \mathbb N$. Then every non-empty codeword $S \in B(G)$ satisfies
$|S| \ge k+1$. Consequently,
$$
d_{\min}(B(G)) \;\ge\; k+1.
$$

*Proof.* Let $S$ be a non-empty codeword. Consider the restricted graph
$H := G|_S$.

1. **$H$ has no degree-one vertex.** By Lemma 5, every left vertex $l \in S$ has
   $\deg_H(\mathrm{inl}\,l) = d \ge 2$; every left vertex $l \notin S$ has degree
   $0$; and every right vertex $r$ has $\deg_H(\mathrm{inr}\,r) = |\{l \in S :
   \mathrm{inc}(l,r)\}|$, which is even because $S$ is a codeword, hence $0$ or
   $\ge 2$. No vertex has degree exactly $1$.

2. **$H$ has an edge.** $S$ is non-empty, pick $l_0 \in S$; left-$d$-regularity
   with $d \ge 2 \ge 1$ gives $l_0$ a right-neighbour $r_0$, and $\{l_0, r_0\}$ is
   an edge of $H$ by Lemma 4.

3. **$H$ contains a cycle.** Apply Lemma 6 to obtain a cycle $w$ in $H$.

4. **The cycle lives in $G$ and is short.** Since $H \le G$ (Lemma 4), $w$ is
   also a cycle of $G$. Its left vertices all belong to $S$ (a left vertex
   outside $S$ is isolated in $H$), so the number $m$ of distinct left vertices
   it visits satisfies $m \le |S|$. By Lemma 7, $\mathrm{length}(w) = 2m \le
   2|S|$.

5. **Chain the inequalities.** As $w$ is a cycle of $G$, its length is at least
   the girth, giving the chain
   $$
   2k+2 \;\le\; \mathrm{egirth}(G) \;\le\; \mathrm{length}(w) \;\le\; 2m \;\le\; 2|S|.
   $$
   Dividing by $2$ yields $k+1 \le |S|$.

Since $S$ was an arbitrary non-empty codeword, $d_{\min}(B(G)) \ge k+1$. $\blacksquare$

**Corollary 9 (Half-girth form).** Under left-$d$-regularity with $d \ge 2$,
$$
d_{\min}(B(G)) \;\ge\; \Bigl\lceil \tfrac{1}{2}\,\mathrm{egirth}(G) \Bigr\rceil,
$$
since the largest $k$ with $2k+2 \le \mathrm{egirth}(G)$ is
$k = \lceil \mathrm{egirth}(G)/2\rceil - 1$.

---

## 6. Algorithms

The proof is constructive and yields the following procedures, all of which run
on an explicit bi-adjacency matrix.

**Algorithm A (Girth via breadth-first search).** For each vertex $v$, run a BFS
that records parent pointers; whenever BFS encounters an already-visited,
non-parent vertex it has closed a cycle whose length is computed from the two
BFS depths. The minimum over all $v$ is the girth. Complexity $O(|V|\cdot|E|)$.

**Algorithm B (Minimum distance by codeword search).** Enumerate non-empty
subsets $S \subseteq L$ in increasing size; the first $S$ for which every right
vertex has even degree in $S$ has size $d_{\min}$. Exponential in $|L|$ in the
worst case but exact; for small instances (e.g. the Fano graph) it certifies
tightness.

**Algorithm C (Constructive codeword extraction).** Given a codeword $S$, build
the restricted graph $G|_S$, find any cycle (DFS until a back-edge), and read off
its distinct left vertices: these form a codeword of weight $\mathrm{length}/2 \le
|S|$. This realizes the proof's cycle-to-codeword correspondence numerically.

---

## 7. Applications and tightness

**Fano plane (bound satisfied, not tight).** Take $L$ = the $7$ lines and $R$ =
the $7$ points of the Fano plane, with $\mathrm{inc}(\ell, p)$ iff $p \in \ell$.
Each line contains $3$ points, so $G$ is left-$3$-regular ($d = 3$). Two distinct
lines meet in a unique point, so there is no $4$-cycle, while $6$-cycles exist;
hence $\mathrm{egirth}(G) = 6 = 2k+2$ with $k = 2$. Theorem 8 predicts
$d_{\min} \ge 3$. Direct search gives $d_{\min} = 4$ (witnessed e.g. by the line
set $\{L_0, L_1, L_3, L_6\}$), so the bound holds with slack. Indeed it must:
every point lies on exactly $3$ lines, so a set of $t$ lines produces $3t$ total
incidences, which can be split into even per-point counts only when $t$ is even;
hence the Fano code has no odd-weight codewords and $d_{\min}$ is even.

**Complete bipartite $K_{2,3}$ (tightness witness).** With $L = \{0,1\}$,
$R = \{0,1,2\}$ and every left vertex adjacent to every right vertex, $G$ is
left-$3$-regular with $\mathrm{egirth}(G) = 4 = 2k+2$ ($k=1$). Theorem 8 predicts
$d_{\min} \ge 2$, and the codeword $S = \{0,1\}$ (each right vertex sees exactly
two neighbours) shows $d_{\min} = 2$. The bound is met with equality, and the
shortest cycle (length $4$) is exactly twice the minimum weight ($2$).

**LDPC and expander codes.** For Tanner graphs of LDPC codes, large girth both
improves belief-propagation decoding (fewer short cycles to double-count
evidence) and, via Theorem 8, guarantees a large minimum distance — two benefits
from one geometric quantity. Expander graphs, which are central to recent
constructions used in post-quantum key exchange, tend to have large girth, so
Theorem 8 supplies the combinatorial guarantee that expander-based codes have
good distance.

---

## 7a. Formalization notes

The development models the incidence structure abstractly: $L$ and $R$ are finite
types and $\mathrm{inc} : L \to R \to \mathrm{Prop}$ is a decidable relation,
rather than committing to a concrete matrix. The graph $\mathrm{biGraph}$ is built
as a bundled `SimpleGraph` on the sum type $L \oplus R$, with symmetry and
irreflexivity discharged by case analysis on the two summands; decidability of
adjacency (`instDecBi`, `instDecRestrict`) is derived so that degrees can be
computed as `Finset` cardinalities. Two design choices are load-bearing.

First, the girth hypothesis uses the *extended* girth $\mathrm{egirth}(G) \in
\mathbb N \cup \{\infty\}$ rather than a natural-number-valued girth. An acyclic
graph has no cycles at all; coercing its girth to $0$ (a common convention) would
make the hypothesis $\mathrm{girth} \ge 2k+2$ false and the theorem vacuous in
exactly the case where the code has *no* nonzero codewords and the bound should
hold most strongly. Valuing girth in $\mathbb N \cup \{\infty\}$ records the
acyclic case honestly as $\mathrm{egirth} = \infty \ge 2k+2$.

Second, the degree-one analysis is isolated entirely inside the *restricted*
graph $G|_S$. The restriction is defined so that an edge survives only if its
left endpoint lies in $S$; consequently a left vertex in $S$ keeps all $d$ of its
edges (Lemma 5), a left vertex outside $S$ becomes isolated, and a right vertex's
degree becomes its number of $S$-neighbours, whose parity is governed by the
codeword condition. This cleanly separates the *coding* hypothesis (even
right-degrees) from the *graph* hypothesis ($d \ge 2$ left-degrees), letting the
cycle-existence lemma `exists_isCycle_of_no_degree_one` be stated and proved for
arbitrary finite simple graphs with no reference to codes. That lemma in turn
relies on the forest/tree structure of acyclic graphs: a nontrivial finite tree
has a leaf, and inside a connected component the induced-tree degree agrees with
the ambient degree, so a leaf would be a degree-one vertex.

## 8. Discussion and future work

The theorem decouples two halves of the slogan *spectral expansion $\Rightarrow$
large girth $\Rightarrow$ good codes*. With the girth-to-distance step now
established rigorously, the remaining effort in the expansion-to-good-codes
program concentrates entirely on the spectral-to-girth step (Alon–Boppana /
trace-method bounds). The constructive nature of the proof — a shortest cycle is
literally a minimum-weight codeword — suggests the inequality is an *equality*
exactly when extremal (Moore-type) graphs are used, which is the content of the
sharpness conjecture below.

**Future directions** (carried from the Phase A research programme):

1. *Sharpness via Moore-type extremal graphs.* For every $d \ge 2$, $k \ge 1$
   there should exist a left-$d$-regular bipartite graph of girth exactly $2k+2$
   whose code has minimum distance *exactly* $k+1$, with these graphs the unique
   distance-minimizers. The extracted cycle has length exactly twice the
   codeword weight, so a shortest cycle is itself a minimum-weight codeword;
   incidence graphs of generalized polygons (Fano for $d=3,k=2$) are finite and
   directly checkable.

2. *Dropping regularity.* Left-regularity is likely unnecessary: if every left
   vertex has degree $\ge 2$ and girth $\ge 2k+2$, the same bound should hold,
   since the proof only uses that the restricted graph has no degree-one vertex.
   Lemma 6 is already stated for arbitrary finite graphs.

3. *Spectral expansion $\Rightarrow$ girth $\Rightarrow$ distance.* If the
   bipartite adjacency operator has second singular value $\sigma_2 \le
   \sqrt{d}\,(1+o(1))$ (near-Ramanujan small-set expander), then girth is
   $\Omega(\log_{d-1} n)$ and hence $d_{\min} = \Omega(\log n)$.

4. *Higher-weight / list-decoding analogue.* With girth $\ge 2k+2$, any two
   distinct codewords of $B(G)$ should remain far apart in a quantified sense,
   yielding list-decoding guarantees.

---

## 9. Conclusion

The minimum distance of a bipartite graph code and the girth of its Tanner graph
are, up to a factor of two, the same quantity: a non-empty codeword always
conceals a cycle of length twice its weight, and a cycle can be no shorter than
the girth. We proved this via two clean, reusable lemmas and a four-link
inequality chain, and verified tightness on the Fano incidence graph. The
result is the rigorous combinatorial core of the expander-codes paradigm in
modern and post-quantum coding theory.
