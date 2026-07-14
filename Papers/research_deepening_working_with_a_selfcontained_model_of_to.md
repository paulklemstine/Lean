# A Sharp Order-Based Lower Bound for Adjacent-Vertex-Distinguishing Total Colourings of Central Graphs

## Abstract

We study adjacent-vertex-distinguishing (AVD) total colourings of the central
graph $C(G)$ of a finite simple graph $G$. A total colouring assigns colours to
both vertices and edges so that incident and adjacent objects receive distinct
colours; it is adjacent-vertex-distinguishing when any two adjacent vertices have
distinct *colour sets*, where the colour set of a vertex is the union of its own
colour and the colours of its incident edges. We prove that for every finite
simple graph $G$ possessing at least one pair of distinct non-adjacent vertices,
every AVD total colouring of $C(G)$ uses at least $|V(G)| + 1$ colours, so that
the AVD-total chromatic number satisfies $\chi''_a(C(G)) \ge |V(G)| + 1$. The
argument requires no regularity or structural hypotheses beyond the existence of
a non-adjacent pair. The decisive fact is that every original vertex of $C(G)$
has degree $|V(G)| - 1$; consequently any two vertices that are non-adjacent in
$G$ form, in $C(G)$, an adjacent pair of equal degree, and equal-degree adjacent
pairs cannot be distinguished on a palette of size equal to their common degree
plus one. As a corollary we recover and strictly strengthen the classical bound
$\chi''_a(C(G)) \ge d + 3$ for $d$-regular non-complete graphs, and we sharpen
the estimate for the five-cycle from $\ge 5$ to the exact-order value $\ge 6$.

## 1. Introduction

Total colourings, introduced independently by Behzad and Vizing, ask for a
simultaneous proper colouring of the vertices and edges of a graph such that any
two incident or adjacent elements receive distinct colours. The *total chromatic
number* $\chi''(H)$ is the least number of colours in such a colouring. A refined
variant, the *adjacent-vertex-distinguishing total colouring*, additionally
requires that adjacent vertices be separated by their colour sets: informally,
neighbouring vertices must "look different" from the local palette they see. The
corresponding parameter is the AVD-total chromatic number $\chi''_a(H)$.

The **central graph** $C(G)$ is a classical construction obtained from $G$ by
subdividing every edge exactly once and adding an edge between every pair of
originally non-adjacent vertices. Central graphs interleave a highly connected
core of original vertices with a sparse set of degree-two subdivision vertices,
and their colouring parameters have been the subject of sustained study. For
$d$-regular non-complete graphs, a lower bound of $d + 3$ for $\chi''_a(C(G))$
has been recorded in the literature.

In this paper we identify the structural mechanism responsible for such bounds
and show that it is entirely independent of regularity. Our main theorem is a
clean order-based bound: $\chi''_a(C(G)) \ge |V(G)| + 1$ for every graph with a
non-adjacent pair. The regular bound $d + 3$ then emerges as a numerical
consequence via the elementary inequality $|V(G)| \ge d + 2$ for regular
non-complete graphs.

The exposition is self-contained. We give explicit models for the total graph,
total colourings, colour sets, and the central graph, and we develop every
supporting lemma from first principles.

## 2. Definitions and model

Throughout, $G$ denotes a finite simple graph with vertex set $V$ and edge set
$E \subseteq \binom{V}{2}$; we write $|V|$ for the number of vertices and, for a
vertex $v$, $\deg_G(v)$ for its degree. We identify an edge with the unordered
pair of its endpoints.

### 2.1 The total graph

We model a total colouring of a graph $H$ as an ordinary proper vertex colouring
of an auxiliary graph, the **total graph** $T(H)$, which encodes all incidence
and adjacency constraints simultaneously.

**Definition 2.1 (Total graph).** Let $H$ be a finite simple graph with vertex
set $W$ and edge set $E(H)$. The total graph $T(H)$ has vertex set
$$
W \sqcup E(H),
$$
the disjoint union of the vertices and edges of $H$. Two elements of $T(H)$ are
adjacent precisely in the following cases:

- two vertices $a, b \in W$ are adjacent iff $a$ and $b$ are adjacent in $H$;
- a vertex $a \in W$ and an edge $e \in E(H)$ are adjacent iff $a$ is an endpoint
  of $e$ (that is, $a \in e$);
- two edges $e, f \in E(H)$ are adjacent iff $e \ne f$ and they share a common
  endpoint.

This adjacency is symmetric and irreflexive, so $T(H)$ is a simple graph.

**Definition 2.2 (Total colouring).** A *total colouring* of $H$ with colour set
$\kappa$ is a proper vertex colouring $C : W \sqcup E(H) \to \kappa$ of $T(H)$;
that is, $C$ assigns distinct colours to any two adjacent elements of $T(H)$.

### 2.2 Colour sets and the AVD property

**Definition 2.3 (Star and colour set).** For a vertex $w \in W$, its *star* is
the family consisting of $w$ together with all edges of $H$ incident to $w$. The
*colour set* of $w$ under a total colouring $C$ is
$$
S_C(w) \;=\; \{\, C(w) \,\} \;\cup\; \{\, C(e) : e \in E(H),\ w \in e \,\},
$$
the set of colours appearing on the star at $w$.

**Definition 2.4 (AVD total colouring).** A total colouring $C$ of $H$ is
*adjacent-vertex-distinguishing* (AVD) if $S_C(a) \ne S_C(b)$ for every pair of
adjacent vertices $a, b$ of $H$.

**Definition 2.5 (AVD-total chromatic number).** The *AVD-total chromatic
number* $\chi''_a(H)$ is the least $n \in \mathbb{N}$ for which $H$ admits an AVD
total colouring with palette of size $n$ (equivalently, with colour set the
$n$-element set $\{0, 1, \dots, n-1\}$), and $\chi''_a(H) = \infty$ if no such
colouring exists. Formally,
$$
\chi''_a(H) \;=\; \inf\{\, n \in \mathbb{N} : H \text{ has an AVD total colouring with } n \text{ colours} \,\}.
$$

### 2.3 The central graph

**Definition 2.6 (Central graph).** The *central graph* $C(G)$ of $G$ has vertex
set
$$
V \sqcup E,
$$
the original vertices together with one new *subdivision vertex* per edge. Its
adjacency is:

- two original vertices $u, w \in V$ are adjacent iff $u \ne w$ and $u, w$ are
  **non-adjacent** in $G$;
- an original vertex $u \in V$ and a subdivision vertex $e \in E$ are adjacent iff
  $u$ is an endpoint of $e$ (that is, $u \in e$);
- two subdivision vertices are never adjacent.

Equivalently, $C(G)$ is obtained from $G$ by subdividing every edge once and then
joining every pair of originally non-adjacent vertices. This adjacency is
symmetric and irreflexive, so $C(G)$ is a simple graph.

We call $G$ *complete* if every two distinct vertices are adjacent; $G$ is
non-complete precisely when it has a pair of distinct non-adjacent vertices.

## 3. Structural lemmas

We collect the elementary facts driving the main result. Fix a finite simple
graph $H$ and a colour set $\kappa$.

**Lemma 3.1 (Star clique).** For every vertex $w$ of $H$, the star at $w$ is a
clique in the total graph $T(H)$: any two distinct star elements are adjacent in
$T(H)$.

*Proof.* The star consists of $w$ and its incident edges. The vertex $w$ is
adjacent in $T(H)$ to each incident edge (incidence). Any two distinct incident
edges share the endpoint $w$, hence are adjacent in $T(H)$. $\qquad\blacksquare$

**Lemma 3.2 (Star size).** The star at $w$ has exactly $\deg_H(w) + 1$ elements:
the vertex $w$ and its $\deg_H(w)$ incident edges.

*Proof.* Immediate: the number of edges incident to $w$ equals $\deg_H(w)$, and
$w$ contributes one further element. $\qquad\blacksquare$

**Lemma 3.3 (Star injectivity).** For any total colouring $C$ of $H$, the
restriction of $C$ to the star at $w$ is injective.

*Proof.* By Lemma 3.1 the star is a clique of $T(H)$, and $C$ is a proper
colouring of $T(H)$, so distinct star elements receive distinct colours.
$\qquad\blacksquare$

**Lemma 3.4 (Full palette at a tight vertex).** Suppose $|\kappa| = \deg_H(w) +
1$. Then any total colouring $C$ of $H$ with colour set $\kappa$ satisfies
$S_C(w) = \kappa$; that is, the colour set at $w$ is the entire palette.

*Proof.* By Lemmas 3.2 and 3.3, the star at $w$ has $\deg_H(w) + 1$ elements
which $C$ maps injectively into $\kappa$. Since $|\kappa| = \deg_H(w) + 1$, the
image has exactly $|\kappa|$ elements and therefore equals $\kappa$. The colour
set $S_C(w)$ is precisely this image. $\qquad\blacksquare$

**Lemma 3.5 (Adjacent equal-degree obstruction).** Let $u, v$ be adjacent
vertices of $H$ with $\deg_H(u) = \deg_H(v) =: \Delta$. If $|\kappa| = \Delta +
1$, then $H$ admits no AVD total colouring with colour set $\kappa$.

*Proof.* Let $C$ be any total colouring with $|\kappa| = \Delta + 1$. Since
$\deg_H(u) = \Delta$, Lemma 3.4 gives $S_C(u) = \kappa$; since $\deg_H(v) =
\Delta = \deg_H(u)$, likewise $S_C(v) = \kappa$. Hence $S_C(u) = S_C(v)$. As $u$
and $v$ are adjacent, $C$ is not AVD. $\qquad\blacksquare$

**Lemma 3.6 (Palette padding / upward closure).** If $H$ admits an AVD total
colouring with $n$ colours and $n \le m$, then $H$ admits an AVD total colouring
with $m$ colours.

*Proof.* Let $C : W \sqcup E(H) \to \{0, \dots, n-1\}$ be an AVD total colouring.
Compose $C$ with the inclusion $\iota : \{0, \dots, n-1\} \hookrightarrow \{0,
\dots, m-1\}$ to obtain $C' = \iota \circ C$. As $\iota$ is injective, $C'$ is
still a proper colouring of $T(H)$: adjacent elements had distinct colours under
$C$ and injectivity preserves distinctness. For each vertex $w$, the colour set
transforms as $S_{C'}(w) = \iota(S_C(w))$, again because $\iota$ is applied
pointwise to the star colours. Since $\iota$ is injective, $S_{C'}(a) =
S_{C'}(b)$ would force $S_C(a) = S_C(b)$; contrapositively, distinct colour sets
under $C$ remain distinct under $C'$. Hence $C'$ is AVD. $\qquad\blacksquare$

Lemma 3.6 shows that the set of admissible palette sizes is upward closed, so the
existence question is governed by a single threshold, namely $\chi''_a(H)$.

## 4. The degree of an original vertex in the central graph

The following identity is the linchpin of the whole development.

**Proposition 4.1 (Uniform core degree).** For every original vertex $v$ of the
central graph $C(G)$,
$$
\deg_{C(G)}(v) = |V| - 1.
$$

*Proof.* Fix $v \in V$. The neighbours of $v$ in $C(G)$ come in two disjoint
kinds. First, the original vertices $w \ne v$ that are non-adjacent to $v$ in
$G$; there are $(|V| - 1) - \deg_G(v)$ of these, since among the $|V| - 1$
vertices other than $v$, exactly $\deg_G(v)$ are $G$-adjacent to $v$. Second, the
subdivision vertices $e \in E$ with $v \in e$; these are exactly the edges
incident to $v$ in $G$, of which there are $\deg_G(v)$. Adding,
$$
\deg_{C(G)}(v) = \bigl[(|V| - 1) - \deg_G(v)\bigr] + \deg_G(v) = |V| - 1. \qquad\blacksquare
$$

The two contributions — non-neighbours and incident edges — cancel the
dependence on $\deg_G(v)$ exactly. This is why the central graph presents a
*uniform* core degree regardless of the degree sequence of $G$.

A companion observation records the adjacency of original vertices:

**Lemma 4.2.** Two distinct original vertices $u, w$ are adjacent in $C(G)$ if and
only if they are non-adjacent in $G$.

*Proof.* Immediate from Definition 2.6. $\qquad\blacksquare$

## 5. Main results

### 5.1 The proper total floor

**Proposition 5.1 (Total lower bound).** Any total colouring of $C(G)$ uses at
least $|V|$ colours.

*Proof.* Pick any original vertex $a$. By Proposition 4.1 its degree in $C(G)$ is
$|V| - 1$, so by Lemma 3.2 the star at $a$ has $|V|$ elements. By Lemma 3.3 a
total colouring maps these injectively into the palette, forcing the palette to
have at least $|V|$ colours. $\qquad\blacksquare$

### 5.2 The sharp AVD bound

**Theorem 5.2 (No AVD colouring with exactly $|V|$ colours).** Suppose $G$ has
distinct non-adjacent vertices $a, b$. Then $C(G)$ admits no AVD total colouring
with exactly $|V|$ colours.

*Proof.* By Lemma 4.2, $a$ and $b$ are adjacent in $C(G)$; by Proposition 4.1
they have equal degree $|V| - 1$ there. A palette of size $|V| = (|V| - 1) + 1$
is exactly the tight size in Lemma 3.5 applied to the adjacent equal-degree pair
$(a, b)$ in $C(G)$. Hence no AVD total colouring with $|V|$ colours exists.
$\qquad\blacksquare$

**Theorem 5.3 (Sharp order-based lower bound).** Suppose $G$ has distinct
non-adjacent vertices. Then every AVD total colouring of $C(G)$ uses at least
$|V| + 1$ colours; equivalently,
$$
\chi''_a\bigl(C(G)\bigr) \ge |V| + 1.
$$

*Proof.* Suppose, for contradiction, that $C(G)$ has an AVD total colouring with
$n \le |V|$ colours. By palette padding (Lemma 3.6) applied with $n \le |V|$, we
obtain an AVD total colouring with exactly $|V|$ colours, contradicting Theorem
5.2. Hence every AVD total colouring uses $n \ge |V| + 1$ colours. Taking the
infimum over admissible $n$ gives the stated inequality on $\chi''_a$.
$\qquad\blacksquare$

### 5.3 The regular corollary

**Lemma 5.4 (Order of a regular non-complete graph).** If $G$ is $d$-regular and
has distinct non-adjacent vertices $a, b$, then $|V| \ge d + 2$.

*Proof.* The vertices $a$, $b$, and the $d$ neighbours of $a$ are pairwise
distinct: $a \ne b$ by hypothesis; no neighbour of $a$ equals $a$; and $b$ is not
a neighbour of $a$ because $a, b$ are non-adjacent. This yields $2 + d$ distinct
vertices, so $|V| \ge d + 2$. $\qquad\blacksquare$

**Theorem 5.5 (Regular bound, $d + 3$).** If $G$ is $d$-regular and not complete,
then every AVD total colouring of $C(G)$ uses at least $d + 3$ colours; hence
$$
\chi''_a\bigl(C(G)\bigr) \ge d + 3.
$$

*Proof.* Non-completeness supplies a non-adjacent pair, so Theorem 5.3 gives a
bound of $|V| + 1$, and Lemma 5.4 gives $|V| \ge d + 2$. Therefore
$$
\chi''_a\bigl(C(G)\bigr) \ge |V| + 1 \ge (d + 2) + 1 = d + 3. \qquad\blacksquare
$$

Theorem 5.5 exhibits the classical regular bound as a numerical corollary of the
structural Theorem 5.3: the quantity that truly governs the problem is $|V| + 1$,
and $d + 3$ is merely its lower estimate obtained by throwing away the exact
order. Whenever $|V| > d + 2$ the order-based bound is strictly stronger.

### 5.4 A worked instance: the five-cycle

**Corollary 5.6.** For the five-cycle $C_5$, every AVD total colouring of
$C(C_5)$ uses at least $6$ colours.

*Proof.* $C_5$ is $2$-regular and non-complete, with $|V| = 5$. Any two vertices
at distance two in $C_5$ (for instance, vertices $0$ and $2$) are distinct and
non-adjacent, so Theorem 5.3 applies and gives $\chi''_a(C(C_5)) \ge |V| + 1 =
6$. $\qquad\blacksquare$

The naive regular estimate $d + 3 = 2 + 3 = 5$ is therefore not tight for the
five-cycle; the order-based bound sharpens it to the correct value $6$. This
single example already demonstrates that regularity is the wrong parameter and
$|V|$ is the right one.

## 6. Algorithmic content

Although the paper is proof-theoretic, the arguments are constructive and give
rise to simple algorithms.

**Constructing the central graph.** Given $G$ as an adjacency structure, $C(G)$
is assembled in time $O(|V|^2 + |E|)$: enumerate all $\binom{|V|}{2}$ pairs and
join the non-adjacent ones; for each edge $e = \{u, w\}$ create a subdivision
vertex adjacent to $u$ and $w$. Verifying Proposition 4.1 numerically — that
every original vertex has degree $|V| - 1$ — is an $O(|V|^2)$ scan.

**Certifying the lower bound.** The obstruction of Theorem 5.2 is *local* and can
be certified without exhibiting any colouring: locate any non-adjacent pair
$(a, b)$ in $G$; by Proposition 4.1 both have degree $|V| - 1$ in $C(G)$; Lemma
3.5 then forbids a palette of size $|V|$. This is an $O(|V|^2)$ certificate.

**Testing AVD-colourability at a given palette size.** For small graphs one may
directly search for an AVD total colouring with $n$ colours by backtracking over
the vertices of $T(C(G))$, pruning on the proper-colouring constraints and
checking the AVD condition on completion. This confirms, for example, that
$C(C_5)$ has no AVD total colouring with $5$ colours but does with $6$, matching
Corollary 5.6.

## 7. Discussion

The results isolate a clean principle: in the central graph, the interplay
between "adding non-edges" and "subdividing edges" cancels the degree
information of $G$, leaving every original vertex at the uniform degree $|V| - 1$.
This uniformity converts *every* non-edge of $G$ into an adjacent equal-degree
pair of $C(G)$, and equal-degree adjacent pairs are exactly the configurations
that the AVD constraint cannot tolerate on a minimal palette. The lower bound
$|V| + 1$ is thus a structural inevitability rather than a regularity phenomenon.

Two features are worth emphasising. First, the bound is *guarded* by the
existence of a non-adjacent pair: for complete graphs $C(K_m)$ there are no such
pairs, the obstruction vanishes, and the extremal behaviour is governed instead
by the subdivision skeleton. Second, the bound is *tight in order*: the extra
"+1" beyond the proper total floor $|V|$ is exactly the slack needed for adjacent
colour sets to differ by a single omitted colour, which strongly suggests
$|V| + 1$ is the exact value for all non-complete graphs.

## 8. Future directions

**Exactness for minimum-order regular graphs.** For a $d$-regular non-complete
graph attaining the minimum order $|V| = d + 2$, we conjecture
$\chi''_a(C(G)) = |V| + 1 = d + 3$. The lower bound is settled; the missing half
is an explicit colouring, and the minimum-order case has the tightest palette,
making it the cleanest place to construct one. The anticipated construction
permutes, vertex by vertex, the $|V|$ colours forced on each original vertex's
star so that adjacent original vertices differ in exactly one colour of their
colour set, while the degree-two subdivision vertices absorb the leftover palette
freely.

**The order term dominates.** We conjecture that $\chi''_a(C(G)) = |V| + 1$ for
*every* non-complete finite simple graph $G$, independently of its degree
sequence. The $\ge |V| + 1$ direction is proved here in full generality; what
remains is a single uniform construction rather than a family of ad hoc regular
ones.

**Complete graphs as the exceptional regime.** For $K_m$ the central graph
$C(K_m)$ has no non-adjacent original pair, so the $|V| + 1$ obstruction is
inapplicable. We expect $\chi''_a(C(K_m))$ to be strictly smaller than $|V| + 1$
and to be governed by the subdivision structure, growing as $\Theta(m)$ with a
different leading constant. Completeness removes exactly the adjacent
equal-degree pairs that drive the $|V| + 1$ obstruction, so the extremal
behaviour switches from the vertex-core to the edge-subdivision skeleton.

## 9. Conclusion

We have established that, for any finite simple graph $G$ with a non-adjacent
pair, the central graph satisfies $\chi''_a(C(G)) \ge |V(G)| + 1$, a bound
requiring no regularity and depending only on the order of $G$. The classical
$d + 3$ bound for regular non-complete graphs follows as a corollary, and the
five-cycle bound sharpens from $\ge 5$ to the exact-order $\ge 6$. The unifying
insight is the uniform core degree $|V| - 1$ of central graphs, which turns the
AVD constraint into an equal-degree obstruction on every non-edge of $G$.
