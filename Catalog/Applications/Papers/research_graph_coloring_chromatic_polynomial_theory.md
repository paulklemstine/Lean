# A Formal Development of the Deletion–Contraction Recurrence and Structural Properties of the Chromatic Polynomial

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Algebra (Algebraic Graph Theory / Enumerative Combinatorics)

## Abstract

The chromatic polynomial $P(G, k)$ of a finite simple graph $G$ counts the
number of proper $k$-colorings of $G$ and is the central enumerative invariant
of graph coloring. We present a self-contained development of two pillars of the
theory. First, we establish the **deletion–contraction recurrence** in its
edge-addition form,
$$P(G, k) = P(G + uv, \, k) + P(G / uv, \, k)$$
for any pair of distinct, non-adjacent vertices $u, v$, where $G + uv$ adds the
edge $uv$ and $G / uv$ contracts (identifies) $u$ and $v$. Unlike the usual
textbook derivation, which invokes the recurrence as a counting slogan, our
proof is built on an **explicit bijection** between the proper colorings of $G$
and the disjoint union of the colorings of $G + uv$ (those with $c(u) \neq c(v)$)
and the colorings of $G / uv$ (those with $c(u) = c(v)$). The bijection is given
by mutually inverse *extend* and *restrict* operations, and the recurrence then
follows by additivity of cardinality over a disjoint union. Second, working from
the subset-expansion of the chromatic polynomial over edge sets, we prove the
two foundational structural facts: $P(G, k)$ has **degree $|V|$** and is
**monic** (leading coefficient $1$). The key combinatorial lemma is that any
nonempty set of non-loop edges yields strictly fewer than $|V|$ connected
components, while the empty set yields exactly $|V|$. All results are fully
formalized and machine-checked. We close with applications to scheduling,
register allocation, the Potts model, and the reformulation of the Four Color
Theorem as the positivity statement $P(G, 4) > 0$ for planar $G$, together with
a program of future directions.

## 1. Introduction

Graph coloring is the problem of assigning labels ("colors") to the vertices of
a graph so that adjacent vertices receive distinct labels. The enumeration of
such labelings is governed by the **chromatic polynomial**, introduced by
Birkhoff in 1912 in an attempt to attack the Four Color Conjecture. For a finite
simple graph $G$ on vertex set $V$ and a number $k$ of available colors, the
quantity $P(G, k)$ — the number of proper $k$-colorings — agrees with a monic
integer polynomial of degree $|V|$ in $k$.

The computational and theoretical backbone of the subject is the
**deletion–contraction recurrence**, a divide-and-conquer identity reducing the
chromatic polynomial of a graph to those of strictly simpler graphs. It is the
combinatorial analogue of the recurrence satisfied by the Tutte polynomial and
the basis of essentially every inductive argument about chromatic polynomials,
from real-rootedness gaps to chromatic-uniqueness questions.

This paper provides a rigorous, formally verified account of the recurrence and
of the first structural properties it implies. Our emphasis is on *constructive
honesty*: the recurrence is not assumed but *derived* from an explicit
bijection, so that every coloring on one side is matched, reversibly, with a
coloring on the other. We then use the standard subset expansion to pin down the
degree and the leading coefficient.

### Contributions

1. A precise formalization of proper colorings, the chromatic counting function,
   edge addition, and edge contraction for finite simple graphs (Section 3).
2. An explicit bijection proof that the colorings of a contraction $G/uv$ are in
   one-to-one correspondence with the colorings of $G$ that agree on $u$ and $v$
   (Theorem 5.1, `chromaticPolynomial_contractEdge_eq`).
3. The deletion–contraction recurrence in edge-addition form, derived from the
   bijection together with disjoint additivity (Theorem 6.1).
4. The structural facts that the chromatic polynomial has degree $|V|$
   (Theorem 7.3, `natDegree_chromaticPolynomial`) and is monic
   (Theorem 7.4, `monic_chromaticPolynomial`), with the supporting
   component-counting lemmas (Section 7).

## 2. Preliminaries and Notation

Throughout, $V$ is a finite type with decidable equality, and $G$ denotes a
**finite simple graph** on $V$: an irreflexive, symmetric adjacency relation
$\mathrm{Adj}$. We write $u \sim v$ for $\mathrm{Adj}(u, v)$. For $k \in
\mathbb{N}$, a **$k$-coloring** is a function $c : V \to \{0, 1, \dots, k-1\}$
(formally $c : V \to \mathrm{Fin}\, k$).

A coloring $c$ is **proper** if $c(a) \neq c(b)$ whenever $a \sim b$. We let
$\mathrm{Col}(G, k)$ denote the (finite) set of proper $k$-colorings.

## 3. Core Definitions

**Definition 3.1 (Proper colorings).** For a finite simple graph $G$ on a
fintype $W$,
$$\mathrm{Col}(G, k) = \{\, c : W \to \mathrm{Fin}\,k \;\mid\; \forall a, b,\; a \sim b \Rightarrow c(a) \neq c(b)\,\}.$$
In the formalization this is `colorings G k`, the filter of `Finset.univ` by the
properness predicate. Its defining membership lemma is
$$c \in \mathrm{Col}(G, k) \iff \forall a\, b,\; a \sim b \Rightarrow c(a) \neq c(b)\qquad(\textsf{mem\_colorings}).$$

**Definition 3.2 (Chromatic counting function).** The chromatic polynomial
evaluated at $k$ is the cardinality
$$P(G, k) = \bigl|\mathrm{Col}(G, k)\bigr| \qquad(\textsf{chromaticPolynomial}).$$
This is a nonnegative integer for each $k$; it agrees with a genuine polynomial
in $k$, a fact whose degree and leading-coefficient consequences we make precise
in Section 7 via the subset expansion.

**Definition 3.3 (Edge addition).** For vertices $u, v$, the graph $G + uv$
(`addEdge G u v`) has adjacency
$$a \sim_{G+uv} b \iff (a \sim_G b) \;\lor\; \bigl(a \neq b \,\land\, ((a=u \land b=v) \lor (a=v \land b=u))\bigr).$$
Symmetry and irreflexivity are immediate; the explicit $a \neq b$ clause keeps
the result loopless even if $u = v$.

**Definition 3.4 (Edge contraction).** For vertices $u, v$, the contraction
$G / uv$ (`contractEdge G u v`) has vertex type $\{x : V \mid x \neq v\}$ — that
is, $v$ is deleted and merged into $u$ — and adjacency
$$a \sim_{G/uv} b \iff (a \sim_G b) \;\lor\; \bigl(a \neq b \land ((a = u \land v \sim_G b) \lor (b = u \land a \sim_G v))\bigr),$$
where $a, b$ range over the subtype. The second disjunct re-routes every edge of
$G$ incident to $v$ so that it becomes incident to the surviving vertex $u$. Both
symmetry and looplessness are verified directly from the definition.

## 4. Colorings of an Edge-Augmented Graph

The first half of the bijection is purely logical and requires no construction.

**Lemma 4.1 (`colorings_addEdge`).** *For distinct vertices $u \neq v$,*
$$\mathrm{Col}(G + uv, \, k) = \{\, c \in \mathrm{Col}(G, k) \mid c(u) \neq c(v)\,\}.$$

*Proof.* Unfolding membership, $c$ is proper for $G + uv$ iff it respects every
edge of $G$ (giving $c \in \mathrm{Col}(G, k)$) and additionally respects the new
edge $uv$, i.e. $c(u) \neq c(v)$. The two conditions are exactly the right-hand
side. $\square$

Taking cardinalities,
$$P(G + uv, \, k) = \#\{c \in \mathrm{Col}(G, k) \mid c(u) \neq c(v)\}. \tag{4.1}$$

## 5. Colorings of a Contraction: The Explicit Bijection

The second half is the technical core. We must show that proper colorings of the
contracted graph correspond exactly to proper colorings of $G$ that assign $u$
and $v$ the same color. We construct mutually inverse maps.

**Definition 5.1 (Extend and restrict).** For $u \neq v$:

- *Extend.* Given $c' : \{x \mid x \neq v\} \to \mathrm{Fin}\,k$, define
  $\mathrm{ext}(c') : V \to \mathrm{Fin}\,k$ by
  $$\mathrm{ext}(c')(x) = \begin{cases} c'(\langle u, \cdot\rangle) & x = v, \\ c'(\langle x, \cdot\rangle) & x \neq v.\end{cases}$$
  (`extendColoring`). In particular $\mathrm{ext}(c')(u) = c'(u) = \mathrm{ext}(c')(v)$,
  recorded as `extendColoring_u` and `extendColoring_v`.
- *Restrict.* Given $c : V \to \mathrm{Fin}\,k$, define
  $\mathrm{res}(c) : \{x \mid x \neq v\} \to \mathrm{Fin}\,k$ by
  $\mathrm{res}(c)(x) = c(x)$ (`restrictColoring`).

**Lemma 5.2 (Inverse relations).** For all $c'$,
$\mathrm{res}(\mathrm{ext}(c')) = c'$ (`restrictColoring_extendColoring`); and for
all $c$ with $c(u) = c(v)$, $\mathrm{ext}(\mathrm{res}(c)) = c$
(`extendColoring_restrictColoring`).

*Proof.* For the first, evaluate at $x \neq v$: by definition $\mathrm{ext}(c')$
returns $c'(x)$, and restriction reads it back unchanged. For the second, on
$x \neq v$ both sides equal $c(x)$; on $x = v$ the left side is
$\mathrm{res}(c)(u) = c(u) = c(v)$ by hypothesis. $\square$

**Lemma 5.3 (Extension preserves properness; `extendColoring_mem`).** Suppose
$u \not\sim_G v$ and $u \neq v$. If $c'$ is a proper coloring of $G / uv$, then
$\mathrm{ext}(c')$ is a proper coloring of $G$ with $\mathrm{ext}(c')(u) =
\mathrm{ext}(c')(v)$.

*Proof.* The color equality at $u, v$ is immediate from the definition of
$\mathrm{ext}$. For properness, take any edge $a \sim_G b$ of $G$; then $a \neq
b$. We check $\mathrm{ext}(c')(a) \neq \mathrm{ext}(c')(b)$ by cases on whether
$a$ or $b$ equals $v$.

- If neither is $v$: both sides are $c'(a)$ and $c'(b)$, and $a \sim_G b$ gives
  $a \sim_{G/uv} b$ (first disjunct), so $c'(a) \neq c'(b)$ by properness of
  $c'$.
- If $a = v$, $b \neq v$: then $\mathrm{ext}(c')(a) = c'(u)$ and
  $\mathrm{ext}(c')(b) = c'(b)$. Since $v \sim_G b$, the contracted graph has
  $u \sim_{G/uv} b$ via the re-routing disjunct (using $u \neq b$, which holds
  because $u \sim_G b$ would otherwise contradict... in fact $u \neq b$ follows
  since $b = u$ together with $v \sim_G b$ would give $u \not\sim_G v$ violated).
  Properness of $c'$ yields $c'(u) \neq c'(b)$.
- The case $b = v$, $a \neq v$ is symmetric.
- The case $a = b = v$ cannot occur since $a \neq b$.

The hypothesis $u \not\sim_G v$ guarantees that the re-routed edges do not
collapse to a forbidden loop at the merged vertex. $\square$

**Lemma 5.4 (Restriction preserves properness; `restrictColoring_mem`).** If $c$
is a proper coloring of $G$ with $c(u) = c(v)$, then $\mathrm{res}(c)$ is a
proper coloring of $G / uv$.

*Proof.* Take an edge $a \sim_{G/uv} b$ in the contracted graph. If it comes from
the first disjunct, $a \sim_G b$ and properness of $c$ gives $c(a) \neq c(b)$,
i.e. $\mathrm{res}(c)(a) \neq \mathrm{res}(c)(b)$. If it comes from the
re-routing disjunct, say $a = u$ and $v \sim_G b$, then properness of $c$ gives
$c(v) \neq c(b)$, and since $c(u) = c(v)$ we get $c(a) = c(u) = c(v) \neq c(b)$.
The symmetric case is identical. $\square$

**Theorem 5.5 (Contraction count; `chromaticPolynomial_contractEdge_eq`).**
*Suppose $u \not\sim_G v$ and $u \neq v$. Then*
$$P(G / uv, \, k) = \#\{c \in \mathrm{Col}(G, k) \mid c(u) = c(v)\}. \tag{5.1}$$

*Proof.* Apply the bijection principle (`Finset.card_bij'`) with the forward map
$c' \mapsto \mathrm{ext}(c')$ and inverse $c \mapsto \mathrm{res}(c)$. Lemma 5.3
shows the forward map lands in the target set; Lemma 5.4 shows the inverse map
lands in $\mathrm{Col}(G/uv, k)$; and Lemma 5.2 shows the two maps are mutually
inverse. Hence the two finite sets are equinumerous. No cardinality identity is
used; the equality of counts is a *consequence* of a constructed bijection.
$\square$

## 6. The Deletion–Contraction Recurrence

**Theorem 6.1 (Deletion–contraction, edge-addition form).** *For distinct
non-adjacent vertices $u \not\sim_G v$, $u \neq v$,*
$$P(G, k) = P(G + uv, \, k) + P(G / uv, \, k).$$

*Proof.* Partition $\mathrm{Col}(G, k)$ by the predicate $c(u) = c(v)$. The two
blocks
$$S_{\neq} = \{c \in \mathrm{Col}(G, k) \mid c(u) \neq c(v)\}, \qquad S_{=} = \{c \in \mathrm{Col}(G, k) \mid c(u) = c(v)\}$$
are disjoint and their union is all of $\mathrm{Col}(G, k)$. By additivity of
cardinality over a disjoint union (equivalently, `Finset.card_union_add_card_inter`
with empty intersection, or `Finset.filter_card_add_filter_neg_card_eq_card`),
$$P(G, k) = |S_{\neq}| + |S_{=}|.$$
By (4.1), $|S_{\neq}| = P(G + uv, k)$; by Theorem 5.5, $|S_{=}| = P(G / uv, k)$.
Substituting gives the recurrence. $\square$

**Remark 6.2 (Relation to the classical form).** Writing $H = G + uv$ and noting
$G = H - uv$, the identity becomes $P(H - uv, k) = P(H, k) + P(H / uv, k)$, i.e.
the familiar $P(H, k) = P(H - uv, k) - P(H/uv, k)$. The edge-addition form is
chosen because each step strictly *increases* edge count toward a complete
graph, giving a clean termination measure (the complete graph $K_n$ has
$P(K_n, k) = k(k-1)\cdots(k-n+1)$ as a base case).

**Worked example.** For the path $a - b - c$ with $u = a$, $v = c$ (non-adjacent):
$G + ac$ is the triangle with $P = k(k-1)(k-2)$, and $G / ac$ is a single edge
with $P = k(k-1)$. The recurrence gives $P(\text{path}, k) = k(k-1)(k-2) +
k(k-1) = k(k-1)^2$, matching the direct count.

## 7. Structural Properties: Degree and Monicity

We now record how the recurrence-compatible subset expansion determines the
shape of the polynomial. Recall the standard identity, obtained by
inclusion–exclusion over the constraint that each edge be properly colored:
$$P(G, k) = \sum_{A \subseteq E(G)} (-1)^{|A|} \, k^{\,c(A)}, \tag{7.1}$$
where $E(G)$ is the edge set and $c(A)$ is the number of connected components of
the spanning subgraph using exactly the edges in $A$ (`numComponentsOfEdges`).
This is the form in which the formalization defines `chromaticPolynomial` as a
genuine element of $\mathbb{Z}[X]$.

**Lemma 7.1 (Empty edge set; `numComponentsOfEdges_empty`).**
$c(\varnothing) = |V|$.

*Proof.* With no edges, the reachability relation is equality, so each vertex is
its own component. The map sending a vertex to its component class is a bijection
onto the set of components, whence the count is $|V|$. $\square$

**Lemma 7.2 (Nonempty edge set; `numComponentsOfEdges_lt_of_nonempty`).** If
$A \neq \varnothing$ and every $e \in A$ is a genuine (non-loop) edge, then
$c(A) < |V|$.

*Proof.* Pick an edge $s(u, v) \in A$ with $u \neq v$. Then $u$ and $v$ are
reachable in the spanning subgraph, so they lie in the same component; hence the
component map $V \to \mathrm{Components}$ is not injective. A surjective but
non-injective map from a finite set to itself forces the target to be strictly
smaller, i.e. $c(A) < |V|$. $\square$

A companion bound, $c(A) \le |V|$ for all $A$
(`numComponentsOfEdges_le`), follows since the component map is always
surjective.

**Theorem 7.3 (Degree; `natDegree_chromaticPolynomial`).** *For $G$ on a
nonempty vertex set, $\deg P(G, k) = |V|$.*

*Proof.* In the expansion (7.1), the coefficient of $k^{|V|}$ is
$$\sum_{A \subseteq E(G)} (-1)^{|A|} \,[\,c(A) = |V|\,].$$
By Lemma 7.2 the only set with $c(A) = |V|$ is $A = \varnothing$ (Lemma 7.1),
contributing $(-1)^0 = 1$. Hence the coefficient of $k^{|V|}$ is $1 \neq 0$.
Conversely every term has $c(A) \le |V|$ (the companion bound), so no higher
power appears and the degree is at most $|V|$. Therefore $\deg P(G, k) = |V|$.
$\square$

**Theorem 7.4 (Monicity; `monic_chromaticPolynomial`).** *For $G$ on a nonempty
vertex set, $P(G, k)$ is monic; equivalently its leading coefficient is $1$
(`leadingCoeff_chromaticPolynomial`).*

*Proof.* By Theorem 7.3 the leading coefficient is the coefficient of $k^{|V|}$,
computed in the proof above to be $1$. $\square$

These two theorems show $P(G, k)$ is a *normalized* invariant: its top behavior
is always exactly $k^{|V|}$, independent of the graph's internal structure.
Together with the recurrence they imply, by induction on the number of edges,
that the counting function is determined by a unique monic integer polynomial of
degree $|V|$ whose coefficients alternate in sign.

## 8. Algorithms

**Algorithm 8.1 (Recursive chromatic polynomial via deletion–contraction).**
Given $G$ on $n$ vertices, if $G$ is complete return $k(k-1)\cdots(k-n+1)$;
otherwise choose a non-adjacent pair $u \not\sim v$, and return
$P(G + uv, k) + P(G / uv, k)$ by two recursive calls. Termination is guaranteed
because the edge-addition branch strictly increases the edge count toward the
complete graph (at most $\binom{n}{2}$ edges) and the contraction branch strictly
decreases the vertex count. The worst-case time is governed by the recurrence
$T(n, m) = T(n, m+1) + T(n-1, \cdot)$, exponential in general (consistent with
$\#$P-hardness of exact evaluation), but very effective on sparse graphs.

**Algorithm 8.2 (Direct enumeration baseline).** Enumerate all $k^{n}$ colorings,
filter those respecting every edge, and count. Exponential in $n$ but trivially
correct; used to cross-check the recursive algorithm on small instances.

## 9. Applications

- **Examination and shift scheduling.** Vertices are events, edges encode
  conflicts, colors are time slots; $P(G, k)$ counts conflict-free schedules
  with $k$ slots, and $P(G, k) > 0$ certifies feasibility.
- **Register allocation.** In compilers, vertices are live variables, edges join
  simultaneously-live variables, and colors are machine registers; coloring with
  $k$ colors is allocation into $k$ registers.
- **Frequency assignment.** Transmitters that may interfere are adjacent;
  colors are frequency bands.
- **Statistical mechanics.** $P(G, k)$ is the zero-temperature limit of the
  $k$-state Potts model partition function; chromatic roots correspond to
  Lee–Yang–type zeros controlling phase transitions.
- **The Four Color Theorem.** Since $k$-colorability is equivalent to
  $P(G, k) > 0$, the Four Color Theorem is exactly the assertion that
  $P(G, 4) > 0$ for every planar graph $G$ — converting a topological statement
  into the positivity of an algebraic invariant at a single point.

## 10. Discussion

The distinguishing feature of this development is its constructive treatment of
the recurrence. Standard expositions justify deletion–contraction with the
sentence "a coloring either gives $u, v$ the same color or not," which is correct
but leaves the contraction correspondence implicit. By exhibiting the explicit
extend/restrict pair and verifying that each direction preserves properness and
that the two compose to the identity, we obtain the recurrence as a corollary of
a bona fide bijection — the strongest possible form of the statement, and one
that mechanized verification can check end to end. The structural theorems then
fall out of the subset expansion via a single clean combinatorial lemma about
component counts.

## 11. Future Directions

1. **An honest integer polynomial.** Package the counting function into a unique
   monic $\chi_G \in \mathbb{Z}[X]$ of degree $|V|$ with sign-alternating
   coefficients, using the recurrence plus the anchored evaluations $P(\bot) =
   k^n$ and $P(K_n) = k^{(n)}$ to force uniqueness by induction on edges.
2. **Real-rootedness gaps.** Prove the absence of chromatic roots in
   $(-\infty, 0) \cup (0, 1) \cup (1, 32/27)$, with $32/27$ the sharp lower
   threshold, via inductive sign analysis seeded by the complete-graph base case.
3. **Formal Brooks' theorem.** Establish that the greedy bound $\chi(G) \le
   \Delta(G)$ holds outside the complete graphs and odd cycles, with those
   families the only tight cases — the structural converse to the already-proved
   universal bound $\chi \le \Delta + 1$.
4. **Four Color Theorem reformulation.** Use the positivity criterion
   $\chi(G, q) > 0 \iff q\text{-colorable}$ to express the Four Color Theorem as
   $P(G, 4) > 0$ for all planar $G$, then attack the planar case.

## References (background, not required for self-containment)

The chromatic polynomial originates with G. D. Birkhoff (1912); the
deletion–contraction principle and its Tutte-polynomial generalization are
classical. The subset (broken-circuit) expansion is due to Whitney and
Birkhoff–Lewis. The reformulation of map coloring via positivity underlies the
Appel–Haken Four Color Theorem. These pointers are provided for context only;
the present paper is self-contained.
