# Degree-4 Vertices in the Flip Graph of the Miura-ori: A Combinatorial Core

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Pythagorean (origami combinatorics / reconfiguration)

## Abstract

We isolate and rigorously establish the combinatorial core underlying the study
of *degree-4 vertices in the flip graph of the $m \times n$ Miura-ori*. The work
joins two classical strands. Locally, we treat a generic flat-foldable degree-4
origami vertex: encoding a mountain/valley (MV) assignment as a function
$a : \{0,1,2,3\} \to \{\text{mountain}, \text{valley}\}$, we adopt the
combinatorial characterization $a_0 \neq a_1 \wedge a_2 = a_3$ — the conclusion of
the big-little-big lemma together with Maekawa's parity constraint — as the
definition of a *generic valid* vertex. From this single definition we prove
Maekawa's three-and-one law (every generic valid vertex has $1$ or $3$ mountains)
and Hull's count (there are exactly $4$ generic valid assignments). Globally, we
formalize the *flip graph* of a configuration space with $d$ independent binary
degrees of freedom as the Boolean hypercube $Q_d$, whose vertices are bitstrings
$\{0,1\}^d$ and whose edges join configurations at Hamming distance $1$. We prove
that $Q_d$ is $d$-regular (every configuration has exactly $d$ neighbours),
specialize to the $4$-regularity of $Q_4$, count the edges as $d \cdot 2^{d-1}$,
and show that $Q_d$ is connected. The two strands meet in a single observation:
the "$4$" of a degree-4 origami vertex and the "$4$" of a degree-4 flip-graph node
both descend from a four-element index set, and $Q_4$ is the unique hypercube that
is simultaneously $4$-dimensional and $4$-regular. All results are
machine-checked. We close with five precise, falsifiable conjectures extending the
theory to the *coupled* regime of the genuine $m \times n$ Miura-ori, where shared
creases break the product structure.

## 1. Introduction

The Miura-ori is a flat-foldable tessellation of the plane by congruent
parallelograms, celebrated for its single-degree-of-freedom rigid deployment and
its negative Poisson's ratio. It has found application in deployable spacecraft
arrays, metamaterials, deployable shelters, and self-folding machines. Its
mathematical structure is governed by the local theory of flat-foldable vertices
and by the global combinatorics of valid mountain/valley (MV) assignments.

Two questions organize the subject. The *enumeration* question asks how many valid
MV assignments a given fold pattern admits. The *reconfiguration* question asks how
those assignments are related under local moves: which can be transformed into
which, and by how many steps. The natural object encoding the latter is a *flip
graph*, whose nodes are valid configurations and whose edges are validity-
preserving single moves.

This paper establishes the rigorous combinatorial *core* on which a theory of
degree-4 vertices in the Miura-ori flip graph can rest. We separate two
phenomena that the literature often conflates under the single word "degree":

1. the *local* degree of an origami vertex — the number of creases meeting at a
   point (here $4$), and
2. the *flip-graph* degree of a configuration — the number of single moves
   available from it.

We make each precise, prove the central facts about each, and exhibit the exact
sense in which the two notions of "$4$" coincide. The local results recover
Maekawa's theorem and Hull's count from one combinatorial definition; the global
results establish the regularity, edge count, and connectivity of the hypercube
flip graph $Q_d$.

Throughout, MV assignments are Boolean-valued (`true` $=$ mountain, `false` $=$
valley) and indexing is over $\mathrm{Fin}\,4 = \{0,1,2,3\}$ locally and
$\mathrm{Fin}\,d$ globally.

## 2. Definitions

**Definition 1 (MV assignment, `VertexMV`).**
A mountain/valley assignment at a degree-4 vertex is a function
$$a : \mathrm{Fin}\,4 \to \{0,1\}, \qquad a_i = 1 \iff \text{crease } i \text{ is a mountain}.$$
There are $2^4 = 16$ such functions in total.

**Definition 2 (mountain count, `mountains`).**
For an MV assignment $a$, the number of mountain creases is
$$\mathrm{mountains}(a) = \bigl|\{\, i \in \mathrm{Fin}\,4 : a_i = 1 \,\}\bigr|.$$

**Definition 3 (generic valid vertex, `GenericValid`).**
An MV assignment $a$ is *generic valid* if
$$\mathrm{GenericValid}(a) \;:\!\iff\; a_0 \neq a_1 \;\wedge\; a_2 = a_3.$$
This is the combinatorial signature of a generic flat-foldable degree-4 vertex
whose unique strictly-smallest sector angle lies between creases $0$ and $1$. The
big-little-big lemma forces the two creases bounding the smallest sector to
disagree ($a_0 \neq a_1$); Maekawa's parity constraint then forces the remaining
pair to agree ($a_2 = a_3$). Because the geometric derivation of big-little-big
falls outside the present formal scope, we take this characterization as a
definition and derive its combinatorial consequences from it.

**Definition 4 (flip graph / Boolean hypercube, `flipGraph`).**
For $d \in \mathbb{N}$, the *flip graph* $Q_d$ is the simple graph with vertex set
$\{0,1\}^d = (\mathrm{Fin}\,d \to \{0,1\})$ and adjacency
$$a \sim b \;:\!\iff\; \bigl|\{\, i \in \mathrm{Fin}\,d : a_i \neq b_i \,\}\bigr| = 1,$$
i.e. $a$ and $b$ are adjacent precisely when they differ in exactly one
coordinate. This is the $d$-dimensional Boolean hypercube under Hamming
adjacency. Symmetry of the relation is immediate from $\neq$ being symmetric, and
irreflexivity holds because $|\varnothing| = 0 \neq 1$.

## 3. Local theory: the degree-4 origami vertex

**Theorem 1 (Maekawa's law, combinatorial form, `mountains_of_genericValid`).**
For every generic valid MV assignment $a$,
$$\mathrm{mountains}(a) = 1 \quad\text{or}\quad \mathrm{mountains}(a) = 3.$$

*Proof sketch.* From $\mathrm{GenericValid}(a)$ we have $a_0 \neq a_1$ and
$a_2 = a_3$. The disagreeing pair $\{a_0, a_1\}$ contributes exactly one mountain
(one is mountain, the other valley). The agreeing pair $\{a_2, a_3\}$ contributes
either zero or two mountains (both valley or both mountain). Hence the total is
$1 + 0 = 1$ or $1 + 2 = 3$. A finite case analysis over the $16$ assignments,
restricted by the two hypotheses, confirms the disjunction; formally this is a
decidable check (`fin_cases` followed by `decide`). $\square$

This is exactly Maekawa's theorem specialized to degree $4$: the mountain count
differs from the valley count by $\pm 2$, leaving only the $3{:}1$ and $1{:}3$
splits and excluding the balanced $2{:}2$ split.

**Theorem 2 (Hull's count, `card_genericValid`).**
The number of generic valid MV assignments is exactly
$$\bigl|\{\, a \in \{0,1\}^4 : \mathrm{GenericValid}(a) \,\}\bigr| = 4.$$

*Proof sketch.* The condition factorizes over two disjoint coordinate pairs. The
constraint $a_0 \neq a_1$ has $2$ solutions $\{(0,1),(1,0)\}$; the constraint
$a_2 = a_3$ has $2$ solutions $\{(0,0),(1,1)\}$. Since the pairs are independent,
the count is $2 \times 2 = 4$. Formally, the predicate is decidable over the
finite type $\{0,1\}^4$, and the cardinality is verified by exhaustive evaluation
(`decide`). $\square$

The four generic valid assignments, written as $(a_0 a_1 a_2 a_3)$, are precisely
$$0100,\quad 1011,\quad 0111,\quad 1000$$
— equivalently, the two "single-valley" patterns and the two "single-mountain"
patterns consistent with $a_0 \neq a_1$, $a_2 = a_3$. (Explicitly: $a_0a_1 \in
\{01,10\}$ paired with $a_2a_3 \in \{00,11\}$.)

## 4. Global theory: the hypercube flip graph

**Lemma 1 (single-flip adjacency, `flipGraph_adj_iff`).**
For all $a, b \in \{0,1\}^d$,
$$a \sim_{Q_d} b \;\iff\; \exists\, i \in \mathrm{Fin}\,d,\ b = a^{\oplus i},$$
where $a^{\oplus i}$ denotes $a$ with coordinate $i$ toggled (formally
$\mathrm{update}\,a\,i\,(\neg a_i)$).

*Proof sketch.* ($\Rightarrow$) If the disagreement set has cardinality $1$, it is
a singleton $\{i\}$; then $b$ agrees with $a$ off $i$ and differs at $i$, so
$b = a^{\oplus i}$. ($\Leftarrow$) Toggling coordinate $i$ produces exactly one
disagreement, so the disagreement set is $\{i\}$, of cardinality $1$. $\square$

**Theorem 3 (regularity of the hypercube, `flipGraph_degree`).**
For every $d \in \mathbb{N}$ and every configuration $a \in \{0,1\}^d$,
$$\deg_{Q_d}(a) = d.$$

*Proof sketch.* By Lemma 1, the neighbourhood of $a$ is the image of the map
$i \mapsto a^{\oplus i}$ from $\mathrm{Fin}\,d$. This map is injective: distinct
coordinates $i \neq j$ yield configurations differing at $i$ (one toggled, one
not), so $a^{\oplus i} \neq a^{\oplus j}$. An injective image of a $d$-element set
has $d$ elements, so the neighbour set has cardinality $d$. $\square$

**Corollary 1 (degree-4 nodes, `flipGraph_degree_four`).**
Every vertex of $Q_4$ has degree exactly $4$:
$$\deg_{Q_4}(a) = 4 \qquad \text{for all } a \in \{0,1\}^4.$$

This is the precise sense in which "degree-4 vertices in the flip graph" occur
exactly in the $d = 4$ regime: $Q_4$ is the *unique* hypercube that is
simultaneously $4$-dimensional and $4$-regular. The same four-element index set
($\mathrm{Fin}\,4$) that supplies the four creases of a degree-4 origami vertex
supplies the four coordinates whose toggles are the four neighbours of every node
of $Q_4$.

**Theorem 4 (edge count, `flipGraph_card_edges`).**
The number of edges of $Q_d$ satisfies
$$2 \cdot |E(Q_d)| = d \cdot 2^d, \qquad\text{equivalently}\qquad |E(Q_d)| = d \cdot 2^{d-1}.$$

*Proof sketch.* By the handshake lemma, $\sum_{a} \deg_{Q_d}(a) = 2\,|E(Q_d)|$.
By Theorem 3 every degree equals $d$, and there are $|\{0,1\}^d| = 2^d$ vertices,
so the left side is $d \cdot 2^d$. Rearranging gives the claim. For $d = 4$ this
yields $|E(Q_4)| = 4 \cdot 2^3 = 32$. $\square$

**Theorem 5 (connectivity / mixing, `flipGraph_connected`).**
For every $d \in \mathbb{N}$, the flip graph $Q_d$ is connected.

*Proof sketch.* It suffices to show every configuration is reachable from the
constant configuration $\mathbf{1}$ (all coordinates $1$). Induct on the number
$k$ of coordinates where $w$ equals $0$. If $k = 0$ then $w = \mathbf{1}$ and we
are done by reflexivity. If $k > 0$, pick a coordinate $i$ with $w_i = 0$; the
configuration $w' = w^{\oplus i}$ has one fewer zero, hence is reachable from
$\mathbf{1}$ by the inductive hypothesis, and $w' \sim w$ by Lemma 1. Composing
reachabilities, $w$ is reachable from $\mathbf{1}$. Since every vertex reaches the
common base point, the graph is connected. $\square$

Theorem 5 is a Cereceda-style *mixing* statement: the configuration space is fully
navigable by single flips, with no isolated islands. The same induction shows the
diameter of $Q_d$ is exactly $d$ (the maximum Hamming distance), realized by
antipodal pairs.

## 5. Synthesis: two fours, one index set

The local and global theories meet at the integer $4$.

- *Local.* A degree-4 vertex has four creases ($\mathrm{Fin}\,4$). After
  big-little-big and Maekawa (Theorem 1), it admits exactly $4$ flat-foldings
  (Theorem 2).
- *Global.* The flip graph of $4$ independent binary degrees of freedom is $Q_4$,
  in which every node has exactly $4$ neighbours (Corollary 1), with $16$ nodes and
  $32$ edges (Theorem 4), all mutually reachable (Theorem 5).

Both fours descend from the same four-element index set, and $Q_4$ is the unique
hypercube whose dimension equals its regularity. This is the conceptual payload of
the core: the title phenomenon ("degree-4 vertices in the flip graph") is, in the
independent-vertex idealization, a structural identity rather than a coincidence.

## 6. Algorithms

We summarize the constructive content as algorithms operating on bitstrings.

**Algorithm A (Generic-valid enumeration and Maekawa verification).**
*Input:* none (the index set is fixed at size $4$).
*Output:* the list of generic valid assignments, with the verified property that
each has mountain count $1$ or $3$.
*Method:* enumerate all $16$ functions $\{0,1\}^4$; filter those with
$a_0 \neq a_1$ and $a_2 = a_3$; assert the filtered list has length $4$ (Theorem 2)
and that every element has $\mathrm{mountains} \in \{1,3\}$ (Theorem 1).
*Complexity:* $O(2^4) = O(16)$ evaluations; $O(d \cdot 2^d)$ in general $d$.

**Algorithm B (Hypercube neighbourhood and degree).**
*Input:* a configuration $a \in \{0,1\}^d$.
*Output:* its $d$ neighbours and the verified degree $d$.
*Method:* for each coordinate $i$, emit $a^{\oplus i}$; the resulting set has size
$d$ by injectivity (Theorem 3).
*Complexity:* $O(d^2)$ to build all neighbours explicitly (each of $d$ neighbours
is a length-$d$ string); $O(d)$ to report the degree.

**Algorithm C (Shortest flip path / connectivity witness).**
*Input:* configurations $a, b \in \{0,1\}^d$.
*Output:* a shortest sequence of single flips transforming $a$ into $b$.
*Method:* compute the disagreement set $D = \{ i : a_i \neq b_i \}$; toggle the
coordinates of $D$ one at a time. The path length is $|D|$, the Hamming distance,
which is optimal; existence proves connectivity (Theorem 5).
*Complexity:* $O(d)$ time and path length at most $d$ (Theorem 5 diameter bound).

## 7. Applications

The Boolean hypercube $Q_d$ is foundational across mathematics and computer
science, and the present results give it an origami interpretation.

- **Deployable-structure design.** The enumeration and connectivity results
  describe, for the idealized independent-vertex model, both how many flat states
  exist and how to morph between them by local moves — the two questions a
  designer of a reconfigurable folded surface must answer.
- **Reconfiguration and mixing.** Theorem 5 places origami flip graphs in the
  Cereceda tradition of reconfiguration/mixing results, where the goal is to show
  a configuration space is connected under local moves and to bound the number of
  moves required.
- **Coding theory and Boolean analysis.** Recognizing the flip graph as $Q_d$
  imports the rich theory of the hypercube: Hamming distance, error-correcting
  codes, and isoperimetry on $\{0,1\}^d$.

## 8. Discussion

The deliberate modelling choice here is to *idealize* the Miura-ori vertices as
independent. Real Miura-ori vertices share creases: each interior crease is
incident to two vertices, so a move at one vertex perturbs its neighbours. This
coupling breaks the clean product structure $\{0,1\}^d$ and replaces the perfect
hypercube by a constrained subgraph of it. The value of the core proved here is
twofold. First, it pins down precisely *why* the number four governs the local
story (four creases, four foldings) and the idealized global story (four
neighbours), establishing a proven anchor. Second, it supplies the exact baseline
— regularity, edge count, connectivity, diameter — against which the coupled
$m \times n$ theory must be measured, and frames the central conjecture that the
count of "most rigid" degree-4 nodes in the coupled flip graph is $(m-1)(n-1)$,
one per interior grid vertex.

## 9. Future directions

Five precise, falsifiable conjectures extend the theory to the coupled regime of
the genuine $m \times n$ Miura-ori, where shared creases break the product
structure. Each is stated so it can be tested by a finite enumeration before any
proof attempt.

**Conjecture 1 (degree-4 vertices are non-generic in the coupled flip graph).**
Model the $m \times n$ Miura-ori flip graph $F(m,n)$ with nodes = globally valid MV
assignments and edges = single *vertex flips* (negate all four creases at one
interior vertex) that preserve global validity. For $m, n \ge 3$, $F(m,n)$ is *not*
regular, and the set of degree-4 nodes is non-empty and forms a proper,
identifiable subset characterized by a local boundary pattern (exactly $4$ interior
vertices are independently flippable). *Falsifiable:* enumerate $F(3,3)$ and check
whether any node has degree exactly $4$.

**Conjecture 2 (hypercube-subgraph dichotomy).**
The coupled flip graph $F(m,n)$ embeds as an isometric subgraph of a hypercube
$Q_N$ (a *partial cube*), where $N$ is the number of interior vertices. $F(m,n)$ is
always a partial cube, and its isometric dimension equals the number of "free"
creases. This would make every flip-graph distance equal a Hamming distance and
force $F(m,n)$ to be bipartite.

**Conjecture 3 (connectivity / mixing of the coupled space).**
Generalizing Theorem 5, for all $m, n \ge 1$ the coupled flip graph $F(m,n)$ is
connected — any valid MV assignment can be transformed into any other by a sequence
of validity-preserving vertex flips. Quantitative refinement: its diameter is
$\Theta(mn)$.

**Conjecture 4 (exact regular-degree spectrum).**
Let $\delta(m,n)$ be the multiset of vertex degrees of $F(m,n)$. Then
$\min \delta(m,n) = 4$ for all $m, n \ge 2$ — every valid configuration has at
least $4$ independently flippable interior vertices — with equality achieved
exactly at the "all-mountain-frame" configurations. This pins the title
phenomenon: degree-4 nodes are the minimum-degree (most rigid) configurations.

**Conjecture 5 (counting via the flip graph).**
Let $C(m,n) = |V(F(m,n))|$ be the Ginepro–Hull MV-assignment count. Then $C(m,n)$
satisfies a linear transfer-matrix recurrence in $n$ (for fixed $m$) whose
characteristic polynomial controls the asymptotic growth rate of the number of
flat-foldings.

## 10. Conclusion

We have established a fully machine-checked combinatorial core for the study of
degree-4 vertices in the Miura-ori flip graph: Maekawa's three-and-one law
(`mountains_of_genericValid`) and Hull's count of four flat-foldings
(`card_genericValid`) on the local side; and the $d$-regularity
(`flipGraph_degree`), the four-neighbour specialization
(`flipGraph_degree_four`), the $d \cdot 2^{d-1}$ edge count
(`flipGraph_card_edges`), and connectivity (`flipGraph_connected`) of the
hypercube flip graph $Q_d$ on the global side. The unifying observation is that the
two appearances of the integer $4$ share a single four-element index set, with
$Q_4$ the unique simultaneously $4$-dimensional and $4$-regular hypercube. The
coupled $m \times n$ theory, with its conjectured $(m-1)(n-1)$ degree-4 nodes,
remains the open frontier.
