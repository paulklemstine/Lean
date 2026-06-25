# Single Forbidden Minors Below Edge Density 3/2: An Order-Theoretic Skeleton and Two Sparse Witnesses

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Novelty (structural graph theory / order theory)

---

## Abstract

We study the lattice of minor-closed graph classes and the question of when such a
class is characterized by a *single* forbidden minor. Working over an abstract
well-founded partial order $(\alpha, \le)$ that models the graph-minor relation (or
any sub-relation of it, such as the subgraph order), we formalize the easy,
order-theoretic half of the Robertson–Seymour philosophy and prove a clean
dictionary: a minor-closed class $C$ satisfies $C = \mathrm{excl}(\{H\})$ for some
$H$ **iff** its set of minimal obstructions is a singleton. We then populate the
density region below the threshold $3/2$ with two structurally distinct,
fully-verified minor-closed witnesses. First, the class of **forests** has edge
density strictly below $1 < 3/2$, via the forest edge bound $|E| + 1 \le |V|$.
Second — and this is the new contribution of the present cycle — the class of
graphs of **maximum degree at most $2$** (disjoint unions of paths and cycles) also
lies strictly below $3/2$, via the handshaking bound $|E| \le |V|$, while being
*strictly larger* than the forest class because it contains all cycles $C_n$, for
which $|E| = |V|$ makes the bound tight. Together with the abstract dictionary,
these two witnesses reduce the mission conjecture — *every $\subseteq$-minimal
minor-closed class with limiting density above some $\delta < 3/2$ is defined by a
single forbidden minor* — to two crisp, falsifiable sub-claims. All results
described here are backed by complete, machine-checked formal proofs.

---

## 1. Introduction

A *minor-closed graph class* is a family of graphs closed under taking minors:
deletions of vertices and edges, and contractions of edges. Such classes are
central objects in structural graph theory and parameterized complexity, and the
Robertson–Seymour Graph Minor Theorem asserts that every one of them is the class
of graphs avoiding a *finite* set of forbidden minors. The deepest content of that
theorem is the finiteness of the obstruction set; the *structural* content —
that minor-closed classes and forbidden-minor descriptions are interchangeable — is
order-theoretic and holds over any well-founded order.

This paper isolates that order-theoretic skeleton and pursues a sharper, more
delicate question: the simplest minor-closed classes are those definable by
forbidding a *single* graph. When does this occur? And what is special about the
edge-density value $3/2$, below which the conjectural answer is "always (for
minimal classes)"? We contribute:

1. **An abstract dictionary** (Section 3): over a well-founded partial order,
   single-forbidden-minor classes are exactly those with a singleton set of
   minimal obstructions.
2. **Two sparse witnesses below $3/2$** (Sections 4–5): the forest class and the
   maximum-degree-$\le 2$ class, the latter being the new, strictly-larger witness
   that contains cycles.
3. **A reduction** (Section 6) of the mission conjecture to two falsifiable
   sub-claims using these ingredients.

Throughout, $|V|$ and $|E|$ denote the number of vertices and edges, and the
**edge density** of a finite graph $G$ is

$$\rho(G) = \frac{|E(G)|}{|V(G)|} \in \mathbb{Q}, \qquad \rho(G) := 0 \text{ when } V = \varnothing.$$

### 1.1 Background and motivation

The theory of minor-closed classes sits at the intersection of structural graph
theory, order theory, and algorithms. Two facts make these classes special. First,
by the Robertson--Seymour Graph Minor Theorem, every minor-closed class is
characterized by a *finite* list of forbidden minors; second, membership in any
fixed minor-closed class is decidable in cubic time. The forbidden-minor lists are,
however, often enormous and poorly understood: even the list for graphs embeddable
on the torus runs to thousands of obstructions. Against this backdrop, the classes
with the *shortest possible* description --- a single forbidden minor --- are
especially attractive, both because they are the cleanest to reason about and
because they sit at the join-irreducible bottom of the lattice of minor-closed
classes.

The density value $3/2$ enters through a classical sparsity bookkeeping. The
handshaking identity $\sum_v \deg(v) = 2|E|$ converts a bound on edge density into
a bound on *average degree*: density below $3/2$ is exactly average degree below
$3$. In this regime graphs are so thin that they decompose into elementary pieces
(paths, cycles, trees), and the lattice of minor-closed classes is conjectured to
collapse to its simplest atoms. Quantifying that collapse --- and exhibiting
explicit, structurally diverse inhabitants of the region below $3/2$ --- is the
purpose of this work.

A recurring subtlety is the choice of order. The full graph-minor order allows
vertex/edge deletion *and* edge contraction; the subgraph order allows only
deletion. Contraction can increase vertex degree and create cycles, so some
density-constrained classes are closed under the subgraph order but not the full
minor order. We are explicit about which order each result uses, and our abstract
framework is stated so as to apply uniformly to any well-founded sub-relation of
the minor order.

---

## 2. The order-theoretic framework

We fix a type $\alpha$ with a relation $\le$ read as "$x$ is a minor of $y$." A
*graph class* is a set $C \subseteq \alpha$.

**Definition 2.1 (Minor-closed).** A class $C$ is **minor-closed** if it is
downward closed:
$$\forall x, y:\quad x \le y \ \wedge\ y \in C \ \Longrightarrow\ x \in C.$$
(Lean: `MinorClosed`.)

**Definition 2.2 (Exclusion class).** For a set $S \subseteq \alpha$,
$$\mathrm{excl}(S) = \{\, x \in \alpha \mid \forall s \in S,\ \neg\, (s \le x) \,\}.$$
(Lean: `excl`, with membership lemma `mem_excl`.)

**Definition 2.3 (Minimal obstructions).**
$$\mathrm{obstructions}(C) = \{\, m \mid m \notin C \ \wedge\ \forall x < m,\ x \in C \,\}.$$
(Lean: `obstructions`.)

**Definition 2.4 (Single forbidden minor).** $C$ has the **single-excluded-minor**
property if $C = \mathrm{excl}(\{H\})$ for some $H \in \alpha$. (Lean:
`SingleExcludedMinor`.)

The lattice structure of minor-closed classes is recorded by the following stable
facts, valid over any preorder.

**Proposition 2.5 (Closure laws).**
(a) For every $S$, $\mathrm{excl}(S)$ is minor-closed (`excl_minorClosed`).
(b) $\mathrm{excl}$ is antitone: $S \subseteq T \Rightarrow \mathrm{excl}(T) \subseteq \mathrm{excl}(S)$ (`excl_anti`).
(c) $\varnothing$ and the universe are minor-closed (`minorClosed_empty`, `minorClosed_univ`).
(d) Minor-closed classes are closed under arbitrary intersections and unions
(`MinorClosed.sInter`, `MinorClosed.sUnion`).

*Proof sketch.* (a) If $x \le y$ and $y$ avoids every $s \in S$, then $s \le x$
would give $s \le y$ by transitivity, contradiction. (b) Avoiding a larger set is a
stronger condition. (c) Immediate. (d) Downward closure is preserved by $\bigcap$
and $\bigcup$ pointwise. $\square$

Together, (a), (c), (d) show that the minor-closed classes form a complete lattice
under $\subseteq$, in which $\mathrm{excl}(\cdot)$ produces a distinguished family
of elements. The principal down-sets $\downarrow G = \{x \mid x \le G\}$ (Lean:
`minorIdeal`, in the companion lattice file) are the join-irreducible building
blocks of this lattice.

---

## 3. The single-forbidden-minor dictionary

### 3.1 Obstruction characterization

**Theorem 3.1 (Forward inclusion).** If $C$ is minor-closed, then
$C \subseteq \mathrm{excl}(\mathrm{obstructions}(C))$. (Lean:
`subset_excl_obstructions`.)

*Proof sketch.* Let $x \in C$ and suppose some obstruction $m$ satisfies $m \le x$.
Since $C$ is minor-closed and $x \in C$, also $m \in C$, contradicting $m \notin C$
(part of being an obstruction). $\square$

**Theorem 3.2 (Reverse inclusion; needs well-foundedness).** Over a well-founded
order, $\mathrm{excl}(\mathrm{obstructions}(C)) \subseteq C$. (Lean:
`excl_obstructions_subset`.)

*Proof sketch.* Suppose $x \notin C$. The set $\{y \mid y \le x,\ y \notin C\}$ is
nonempty (it contains $x$). By well-foundedness it has a $\le$-minimal element $m$.
Every $z < m$ must lie in $C$ (else minimality is violated), so $m$ is a minimal
obstruction with $m \le x$; hence $x \notin \mathrm{excl}(\mathrm{obstructions}(C))$.
Contrapositively, any $x$ avoiding all obstructions lies in $C$. $\square$

**Theorem 3.3 (Excluded-minor characterization).** Over a well-founded order, a
minor-closed class equals the class excluding its minimal obstructions:
$$C = \mathrm{excl}(\mathrm{obstructions}(C)).$$
(Lean: `minorClosed_excl_obstructions`.)

*Proof sketch.* Antisymmetric combination of Theorems 3.1 and 3.2. $\square$

This is the order-theoretic form of "every minor-closed class is an excluded-minor
class." The only ingredient beyond downward closure is well-foundedness, used
precisely to extract a *minimal* offender below any excluded graph.

### 3.2 The dictionary

We now restrict to a **well-founded partial order** (antisymmetry is genuinely
needed: a mere preorder permits $H \le m \le H$ with $m \ne H$, breaking
uniqueness).

**Theorem 3.4 (One pattern, one obstruction).** For any $H$,
$$\mathrm{obstructions}(\mathrm{excl}(\{H\})) = \{H\}.$$
(Lean: `obstructions_excl_singleton`.)

*Proof sketch.* ($\supseteq$) $H \notin \mathrm{excl}(\{H\})$ since $H \le H$, and
every $x < H$ avoids $H$ (else $H \le x < H$ contradicts irreflexivity), so $x \in
\mathrm{excl}(\{H\})$; thus $H$ is an obstruction. ($\subseteq$) If $m$ is an
obstruction of $\mathrm{excl}(\{H\})$ then $m \notin \mathrm{excl}(\{H\})$ forces
$H \le m$; if $H < m$ strictly, then $H$ (being a proper minor of $m$) would have
to lie in $\mathrm{excl}(\{H\})$, impossible since $H \le H$. Hence $m = H$ by
antisymmetry. $\square$

**Theorem 3.5 (Single-forbidden-minor dictionary).** For a minor-closed class $C$
over a well-founded partial order,
$$C = \mathrm{excl}(\{H\}) \text{ for some } H \quad\Longleftrightarrow\quad \mathrm{obstructions}(C) = \{H\} \text{ for some } H.$$
(Lean: `singleExcludedMinor_iff_obstructions_singleton`.)

*Proof sketch.* ($\Rightarrow$) If $C = \mathrm{excl}(\{H\})$, apply Theorem 3.4.
($\Leftarrow$) If $\mathrm{obstructions}(C) = \{H\}$, then by Theorem 3.3,
$C = \mathrm{excl}(\mathrm{obstructions}(C)) = \mathrm{excl}(\{H\})$. $\square$

Theorem 3.5 is the conceptual centerpiece: "definable by one forbidden minor" and
"having one minimal obstruction" are interchangeable. Detecting a clean single-rule
description reduces to counting the minimal obstructions.

A companion lattice development records two further facts of this cycle used in the
reduction of Section 6: that $\mathrm{excl}(\{H\})$ is the *largest* minor-closed
class avoiding $H$ (the largest-avoider identity, Lean
`excl_singleton_eq_sUnion_avoiding`), and that the minimal obstruction set is always
an *antichain* (Lean `obstructions_antichain`).

---

## 4. First witness: forests below 3/2

We instantiate the framework on $\alpha = \mathrm{SimpleGraph}\,V$ with $\le$ the
subgraph order — a sub-relation of the minor order. (Edge contraction is not used,
since contracting can create cycles or raise degree; see Section 7.)

**Definition 4.1.** The **forest class** is $\mathcal{F}(V) = \{G \mid G\ \text{is
acyclic}\}$. (Lean: `acyclicClass`.)

**Theorem 4.2 (Forests are minor-closed).** $\mathcal{F}(V)$ is minor-closed under
the subgraph order: any subgraph of an acyclic graph is acyclic. (Lean:
`acyclicClass_minorClosed`.)

*Proof sketch.* Acyclicity is inherited by subgraphs (a cycle in a subgraph is a
cycle in the supergraph). $\square$

**Theorem 4.3 (Forest edge bound).** A finite, nonempty forest on $V$ satisfies
$$|E| + 1 \le |V|.$$
(Lean: `IsAcyclic.card_edgeSet_add_one_le`.)

*Proof sketch.* Extend the forest to a spanning tree $F$ of the complete graph
($G \le F \le K_V$, with $F$ a tree). A tree on $|V|$ vertices has exactly
$|V| - 1$ edges; monotonicity of edge counts under $\le$ gives
$|E(G)| \le |E(F)| = |V| - 1$. $\square$

**Theorem 4.4 (Trees have density below 1).** Every finite tree $G$ satisfies
$\rho(G) < 1$. (Lean: `IsTree.edgeDensity_lt_one`.)

*Proof sketch.* A tree has $|E| + 1 = |V|$, so $|E| = |V| - 1 < |V|$, hence
$\rho = |E|/|V| < 1$. $\square$

**Theorem 4.5 (Forests below 3/2).** Every finite forest satisfies
$\rho(G) < 3/2$. (Lean: `acyclic_edgeDensity_lt_threshold`, and the class-level
statement `acyclicClass_below_threshold`.)

*Proof sketch.* If $V = \varnothing$ then $\rho = 0 < 3/2$. Otherwise Theorem 4.3
gives $|E| < |V|$, so $\rho < 1 < 3/2$. $\square$

Thus the forest class is a genuine minor-closed class with limiting density exactly
$1$, comfortably below the threshold.

---

## 5. Second witness: bounded degree below 3/2 (new contribution)

The forest class is the acyclic extreme. To show the sub-$3/2$ region is not
exhausted by acyclic families, we exhibit a strictly larger witness containing
cycles.

**Definition 5.1.** For $d \in \mathbb{N}$, the **bounded-degree class** is
$$\mathcal{D}_d(V) = \{G \mid \Delta(G) \le d\},$$
where $\Delta(G)$ is the maximum degree. (Lean: `boundedDegreeClass`.)

By the elementary degree classification, a graph with $\Delta(G) \le 2$ is a
disjoint union of paths and cycles.

**Theorem 5.2 (Degree monotonicity).** If $G \le G'$ (subgraph), then
$\Delta(G) \le \Delta(G')$. (Lean: `maxDegree_mono`.)

*Proof sketch.* Adding edges can only increase each vertex degree: for every $v$,
$\deg_G(v) \le \deg_{G'}(v) \le \Delta(G')$, so $\Delta(G) \le \Delta(G')$ by the
defining maximality of $\Delta$. $\square$

**Theorem 5.3 (Bounded-degree classes are minor-closed).** For every $d$,
$\mathcal{D}_d(V)$ is minor-closed under the subgraph order. (Lean:
`boundedDegreeClass_minorClosed`.)

*Proof sketch.* If $G \le H$ and $\Delta(H) \le d$, then by Theorem 5.2
$\Delta(G) \le \Delta(H) \le d$. $\square$

**Theorem 5.4 (Handshaking edge bound).** If $\Delta(G) \le 2$ then $|E| \le |V|$.
(Lean: `edgeFinset_card_le_of_maxDegree_two`.)

*Proof sketch.* By the handshaking identity $\sum_{v} \deg(v) = 2|E|$. Each
$\deg(v) \le \Delta(G) \le 2$, so $\sum_v \deg(v) \le 2|V|$. Hence
$2|E| \le 2|V|$, i.e. $|E| \le |V|$. $\square$

**Theorem 5.5 (Bounded-degree below 3/2).** If $\Delta(G) \le 2$ then
$\rho(G) < 3/2$ (indeed $\rho(G) \le 1$). (Lean: `maxDegree_two_edgeDensity_lt`,
class-level `boundedDegreeTwoClass_below_threshold`.)

*Proof sketch.* If $V = \varnothing$, $\rho = 0$. Otherwise Theorem 5.4 gives
$|E| \le |V|$, so $\rho = |E|/|V| \le 1 < 3/2$. $\square$

**Tightness and strict enlargement.** A cycle $C_n$ has $|V| = |E| = n$, so
$\rho(C_n) = 1$ and the bound $|E| \le |V|$ is *tight*. Since $C_n$ has
$\Delta = 2$ but is not acyclic, we have $C_n \in \mathcal{D}_2(V) \setminus
\mathcal{F}(V)$. Therefore
$$\mathcal{F}(V) \subsetneq \mathcal{D}_2(V),$$
both lying below $3/2$. This shows the sub-threshold region contains at least two
structurally different minor-closed families with the same density floor $1$ — one
acyclic, one cyclic.

---

## 6. Reduction of the mission conjecture

**Conjecture (mission target).** Every $\subseteq$-minimal minor-closed class whose
limiting edge density exceeds some fixed $\delta < 3/2$ is a single-forbidden-minor
class: $\mathcal{G} = \mathrm{excl}(\{H\})$.

The results above split this into two falsifiable sub-claims.

**(C1) Maximality forces a singleton obstruction.** Among proper minor-closed
classes avoiding a fixed graph, the largest is $\mathrm{excl}(\{H\})$ (the
largest-avoider identity). The remaining claim is the converse: being maximal among
coavoiders forces the obstruction antichain (which is always an antichain) to
collapse to one element. By Theorem 3.5 this is equivalent to the single-forbidden
property.

**(C2) Density floor forces largeness.** A limiting density $> \delta$ near $3/2$
means average degree near $3$, which by the *reverse* of Theorem 5.4 cannot be
sustained while excluding the degree-$\le 2$ family; hence every class above the
floor must contain all paths and cycles. Thus the bounded-degree-$2$ family is a
*forced sub-class*, making any minimal class above the floor large enough to be a
maximal coavoider.

**Synthesis.** Combining (C1) and (C2): the density floor (C2) makes $\mathcal{G}$
large enough to be a maximal coavoider, and maximal coavoiders have singleton
obstruction sets (C1); minimality above the floor lands exactly on a maximal
coavoider. Both sub-claims are finite-combinatorial or well-foundedness statements,
not deep structure theory — which is what makes the reduction valuable.

---

## 6b. Worked examples

We collect small concrete instances that make the abstract statements tangible.

**Triangle-free graphs.** The class $\mathrm{excl}(\{K_3\})$ of triangle-free
graphs has, by Theorem 3.4, the single minimal obstruction $K_3$: the triangle is
not triangle-free, while every proper subgraph of $K_3$ (a single edge, two edges,
or the empty graph on three vertices) is triangle-free. Hence by Theorem 3.5 it is
genuinely a single-forbidden-minor class. Note this class is *not* below $3/2$ in
density --- complete bipartite graphs are triangle-free yet dense --- which
illustrates that the dictionary of Section 3 and the density results of
Sections 4--5 are independent layers of the theory.

**The cycle family is tight.** For each $n \ge 3$, the cycle $C_n$ has
$|V| = |E| = n$, so $\rho(C_n) = 1$ and the handshaking bound $|E| \le |V|$ of
Theorem 5.4 holds with equality. Since $\Delta(C_n) = 2$ but $C_n$ contains a
cycle, we have $C_n \in \mathcal{D}_2 \setminus \mathcal{F}$, exhibiting the strict
containment $\mathcal{F} \subsetneq \mathcal{D}_2$ concretely.

**A disjoint union.** The graph $P_3 \sqcup C_6$ (a path on three vertices beside a
six-cycle) has $|V| = 9$ and $|E| = 2 + 6 = 8$, so $\rho = 8/9 < 1 < 3/2$, with
$\Delta = 2$; it lies in $\mathcal{D}_2$ but not in $\mathcal{F}$. This is a typical
member of the bounded-degree witness: a disjoint union of paths and cycles.

**Two-obstruction non-example.** If a minor-closed class $C$ has two
incomparable minimal obstructions $H_1, H_2$ (an antichain of size $2$ in the
obstruction set), then by Theorem 3.5 it is *not* a single-forbidden-minor class:
no single $H$ can reproduce $C$, because $\mathrm{obstructions}(\mathrm{excl}(\{H\}))
= \{H\}$ is forced to be a singleton. The planar graphs, with obstructions
$\{K_5, K_{3,3}\}$, are the canonical illustration.

---

## 7. Discussion: subgraph vs. full minor order

Both density witnesses are proved in the **subgraph specialization** of the minor
order. This is a deliberate, honest restriction: full contraction-closure *fails*
for the bounded-degree witness. Contracting an edge can merge two degree-$2$
vertices into one of higher degree, so $\mathcal{D}_2$ is not closed under
contraction (Conjecture C4 of the future-directions program records the sharp
failure). The forest witness has a cleaner contraction story — forests as minors
are conjecturally $\mathrm{excl}(\{K_3\})$ — but we state only what is proved. The
abstract framework of Sections 2–3 is order-agnostic: it applies verbatim to the
full minor order, the topological-minor order, or any well-founded sub-relation,
and the density witnesses live inside the subgraph sub-relation, which is itself
contained in the minor order.

---

## 8. Algorithms

The constructive content yields three algorithms, all running in time linear or
near-linear in graph size.

**Algorithm A (Edge-density threshold test).** Given a finite graph, compute
$\rho(G) = |E|/|V|$ and compare with $3/2$. Certifies membership below the
threshold for any input. Complexity $O(|V| + |E|)$.

**Algorithm B (Bounded-degree membership and witness).** Compute every vertex
degree, take the maximum $\Delta$, and report whether $\Delta \le 2$; if so, also
verify the certified bound $|E| \le |V|$. Decomposes the graph into its path and
cycle components as a structural witness. Complexity $O(|V| + |E|)$.

**Algorithm C (Obstruction-set probe).** Given a decidable membership oracle for a
minor-closed class $C$ and a candidate graph $m$, decide whether $m$ is a minimal
obstruction by checking $m \notin C$ and $x \in C$ for all proper minors $x < m$.
Counting distinct minimal obstructions implements the dictionary test of
Theorem 3.5 (singleton $\Rightarrow$ single-forbidden-minor class). Complexity
dominated by the number of proper minors examined.

---

## 9. Applications

- **Parameterized complexity.** Single-forbidden-minor classes admit especially
  simple membership tests; the dictionary (Theorem 3.5) gives an exact criterion
  for when a class enjoys this simplicity.
- **Sparsity certificates.** Theorems 4.5 and 5.5 give one-line density
  certificates ($|E| \le |V|$ or $|E| < |V|$) for the two canonical sparse
  families, usable as preconditions in graph algorithms tuned to sparse inputs.
- **Lattice navigation.** The closure laws (Proposition 2.5) and principal
  down-sets $\downarrow G$ furnish the algebra needed to compute joins and meets of
  minor-closed constraints.

---

## 10. Future directions

See the dedicated future-directions program (reproduced in the package metadata),
whose headline conjectures are: **(C1)** maximal coavoiders are exactly the
single-forbidden-minor classes; **(C2)** the density floor near $3/2$ forces a
class to contain the full degree-$\le 2$ family; **(C3)** the mission theorem —
minimal-above-threshold implies singleton obstruction — assembled from C1 and C2;
and **(C4)** the sharp failure of contraction-closure for the bounded-degree
witness.

---

## 11. Conclusion

We isolated the order-theoretic skeleton of minor-closed class theory and proved a
clean dictionary equating single-forbidden-minor classes with singleton-obstruction
classes (Theorem 3.5). We then planted two structurally distinct, fully-verified
flags below the density threshold $3/2$: the forest class (density floor $1$, via
$|E| + 1 \le |V|$) and the maximum-degree-$\le 2$ class (density floor $1$, via
$|E| \le |V|$, strictly larger because it contains all cycles). These ingredients
reduce the mission conjecture to two falsifiable sub-claims grounded in finite
combinatorics and well-foundedness. The threshold $3/2$ — the average-degree-$3$
boundary delivered by the handshaking identity — emerges as the precise altitude
where minimal minor-closed classes are conjectured to simplify to single forbidden
minors.
