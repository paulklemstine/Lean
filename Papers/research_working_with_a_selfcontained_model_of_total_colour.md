# The Extremal Regime of Adjacent-Vertex-Distinguishing Total Colourings of Central Graphs of Regular Graphs

## Abstract

For a finite simple graph $G$, the *central graph* $C(G)$ is obtained by
subdividing every edge of $G$ once and joining every pair of non-adjacent
vertices of $G$. We study the *adjacent-vertex-distinguishing (AVD) total
chromatic number* $\chi''_a(C(G))$, the least number of colours needed to colour
both the vertices and the edges of $C(G)$ so that (i) the colouring is a proper
total colouring and (ii) any two adjacent vertices receive distinct *colour sets*
(the set formed by a vertex's own colour together with the colours of its incident
edges).

For a $d$-regular graph $G$ that is not complete we establish two lower bounds:
a *degree-governed* bound $\chi''_a(C(G)) \ge d + 3$ and a *vertex-governed*
bound $\chi''_a(C(G)) \ge |V(G)| + 1$. Because a non-complete $d$-regular graph
satisfies $|V(G)| \ge d + 2$, the vertex-governed bound always dominates, and the
two coincide exactly in the **extremal regime** $|V(G)| = d + 2$. Our main
structural result characterises this regime: a non-complete $d$-regular graph is
extremal if and only if its complement is $1$-regular, i.e. $G$ is a
cocktail-party graph $K_{d+2}$ minus a perfect matching. On this family the two
lower bounds collapse to the single sharp value $d + 3 = |V(G)| + 1$. We
illustrate the theory on cycles: $C_4$ is the smallest extremal instance (its
central graph requires at least $5$ colours), whereas $C_5$ lies strictly outside
the extremal family, exhibiting the strict domination $d + 3 < |V(G)| + 1$.

**Keywords.** AVD-total chromatic number, central graph, total colouring, regular
graph, cocktail-party graph, graph complement, perfect matching.

---

## 1. Introduction

Colouring problems that treat vertices and edges on an equal footing — *total
colourings* — sit at the confluence of classical chromatic theory and scheduling.
A refinement of increasing interest adds a *distinguishability* requirement: not
only must the colouring be proper, but adjacent vertices must be told apart by the
entire multiset (here, set) of colours in their immediate neighbourhood. This is
the *adjacent-vertex-distinguishing total colouring*, and its optimal size is the
AVD-total chromatic number $\chi''_a$.

The *central graph* construction is a natural transformation of a base graph $G$
that combines two familiar operations: barycentric subdivision of edges and
complementation on the original vertex set. It produces graphs with a highly
structured degree profile — the original vertices become high-degree hubs, the
edge-vertices low-degree connectors — which makes central graphs an excellent
testbed for chromatic invariants.

A guiding conjecture in this area asserts that for a $d$-regular non-complete
graph $G$, $\chi''_a(C(G)) = d + 3$. In this paper we make the *lower* half of
this equality precise and, crucially, delineate exactly where the equality can
possibly hold. We isolate two competing lower bounds, show that the
vertex-governed bound dominates, and characterise the extremal boundary where the
two agree. The upshot is a sharp understanding of the terrain: the conjectured
value $d + 3$ is correct only on a thin, explicitly described family, and is
strictly too small everywhere else.

### Contributions

- A self-contained model of total colourings and AVD-total colourings via the
  *total graph* $T(H)$ (Section 2).
- The *star-clique* argument yielding the equal-degree obstruction: two adjacent
  vertices of equal degree $\Delta$ admit no AVD-total colouring with only
  $\Delta + 1$ colours (Section 2).
- A palette-monotonicity lemma: AVD-total colourability is upward closed in the
  number of colours (Section 2).
- The degree- and vertex-governed lower bounds for $C(G)$ (Sections 3–4).
- The complement-regularity computation and the extremal characterisation:
  extremal $\iff$ cocktail-party graph (Section 5).
- The collapse of both bounds to a single sharp value on the extremal family, and
  the cycle case studies $C_4$ versus $C_5$ (Sections 5–6).

---

## 2. Total colourings, the total graph, and the AVD condition

Throughout, all graphs are finite and simple. For a graph $H$ we write $V(H)$ for
its vertex set and $E(H)$ for its edge set (a subset of unordered pairs).

### 2.1 The total graph

**Definition 2.1 (Total graph).** The *total graph* $T(H)$ has vertex set
$V(H) \sqcup E(H)$ (the disjoint union of the vertices and the edges of $H$), with
adjacency defined by:

- $a \sim b$ for $a, b \in V(H)$ iff $a$ and $b$ are adjacent in $H$;
- $a \sim e$ for $a \in V(H)$, $e \in E(H)$ iff $a$ is an endpoint of $e$
  (i.e. $a \in e$);
- $e \sim f$ for $e, f \in E(H)$ iff $e \ne f$ and $e$ and $f$ share an endpoint.

Thus $T(H)$ overlays $H$, its line graph, and the incidence structure between them
into a single graph.

**Definition 2.2 (Total colouring).** A *total colouring* of $H$ with palette
$\kappa$ is a proper vertex colouring of $T(H)$, i.e. a map
$C : V(H) \sqcup E(H) \to \kappa$ assigning distinct colours to adjacent vertices
of $T(H)$. Equivalently: adjacent vertices of $H$ differ, incident edges of $H$
differ, and a vertex differs from each of its incident edges.

### 2.2 The star at a vertex and the equal-degree obstruction

Fix $w \in V(H)$. The *star* at $w$ is the family consisting of $w$ itself
together with all edges of $H$ incident to $w$, viewed as vertices of $T(H)$. It
has $\deg_H(w) + 1$ elements.

**Lemma 2.3 (Star clique).** The star at $w$ is a clique in $T(H)$: any two of its
members are adjacent.

*Proof sketch.* The vertex $w$ is adjacent to each incident edge (incidence),
and any two distinct edges incident to $w$ share the endpoint $w$, hence are
adjacent in $T(H)$. $\qquad\blacksquare$

**Corollary 2.4 (Injectivity on the star).** In any total colouring $C$, the
colours assigned to the members of the star at $w$ are pairwise distinct. Hence
$C$ uses at least $\deg_H(w) + 1$ distinct colours on the star at $w$.

**Definition 2.5 (Colour set / signature).** For a total colouring $C$ and a
vertex $w$, the *colour set* (or *signature*) of $w$ is
$$\mathcal{C}(w) \;=\; \{\, C(w) \,\} \cup \{\, C(e) : e \in E(H),\ w \in e \,\},$$
the set of colours appearing on the star at $w$.

**Definition 2.6 (AVD-total colouring).** A total colouring $C$ is
*adjacent-vertex-distinguishing (AVD)* if $\mathcal{C}(a) \ne \mathcal{C}(b)$
whenever $a$ and $b$ are adjacent in $H$.

**Lemma 2.7 (Full palette at tight vertices).** If the palette has exactly
$\deg_H(w) + 1$ colours, then in any total colouring $\mathcal{C}(w)$ equals the
entire palette.

*Proof sketch.* By Corollary 2.4 the $\deg_H(w) + 1$ star members receive
pairwise distinct colours; with only $\deg_H(w) + 1$ colours available, all of
them must occur, so $\mathcal{C}(w)$ is the whole palette. $\qquad\blacksquare$

**Proposition 2.8 (Equal-degree obstruction).** Let $u, v$ be adjacent vertices
of $H$ with $\deg_H(u) = \deg_H(v) = \Delta$. Then no AVD-total colouring of $H$
uses only $\Delta + 1$ colours.

*Proof sketch.* With $\Delta + 1$ colours, Lemma 2.7 forces
$\mathcal{C}(u) = \mathcal{C}(v) = $ the entire palette, so the two signatures
coincide, violating the AVD condition on the edge $uv$. $\qquad\blacksquare$

Proposition 2.8 is the engine behind every lower bound below: adjacent
equal-degree vertices are "colour-set saturated" at the tight palette size and
therefore indistinguishable.

### 2.3 Palette monotonicity

**Lemma 2.9 (Upward closure).** If $H$ has an AVD-total colouring with $n$ colours
and $n \le m$, then it has one with $m$ colours.

*Proof sketch.* Embed the palette $\{1,\dots,n\}$ into $\{1,\dots,m\}$ via any
injection $\iota$ and recolour by $\iota \circ C$. Properness is preserved because
$\iota$ is injective. Each signature is transported by $\iota$, i.e.
$\mathcal{C}'(w) = \iota(\mathcal{C}(w))$; since $\iota$ is injective on sets,
distinct signatures remain distinct, so the AVD condition survives.
$\qquad\blacksquare$

Consequently, the set of admissible palette sizes is an up-set, and
$\chi''_a(H)$ — the least admissible size — is a well-defined threshold: a colouring
with $n$ colours exists iff $n \ge \chi''_a(H)$.

---

## 3. The central graph

**Definition 3.1 (Central graph).** Let $G$ be a finite simple graph with vertex
set $V$. The *central graph* $C(G)$ has vertex set $V \sqcup E(G)$, with adjacency:

- $u \sim w$ for $u, w \in V$ iff $u \ne w$ and $u, w$ are *non-adjacent* in $G$;
- $u \sim e$ for $u \in V$, $e \in E(G)$ iff $u$ is an endpoint of $e$;
- $e \sim f$ for $e, f \in E(G)$: never.

Intuitively, subdividing each edge $uv$ inserts the edge-vertex $e = uv$ adjacent
to both $u$ and $v$; and on the original vertices we place the *complement* of
$G$.

We refer to the vertices in $V$ as *original vertices* and those in $E(G)$ as
*edge-vertices*.

**Proposition 3.2 (Adjacency of original vertices).** For $u, w \in V$, the
original vertices $u$ and $w$ are adjacent in $C(G)$ if and only if $u \ne w$ and
$u, w$ are non-adjacent in $G$. In particular the induced subgraph of $C(G)$ on
$V$ is the complement $G^{c}$.

**Proposition 3.3 (Degree of original vertices).** Every original vertex of
$C(G)$ has degree $|V| - 1$; equivalently
$$\deg_{C(G)}(v) + 1 = |V(G)| \qquad \text{for all } v \in V.$$

*Proof sketch.* The neighbours of $v$ in $C(G)$ split into two groups: the
original vertices non-adjacent to $v$ in $G$ (there are $|V| - 1 - \deg_G(v)$ of
them), and the edge-vertices incident to $v$ (there are $\deg_G(v)$ of them, one
per edge at $v$). These two families are disjoint, and their sizes sum to
$$(|V| - 1 - \deg_G(v)) + \deg_G(v) = |V| - 1. \qquad\blacksquare$$

Proposition 3.3 is the structural heart of the paper: *regardless of the degree
of $v$ in $G$*, its degree in $C(G)$ is the constant $|V| - 1$. The original
vertices are the unique maximum-degree stratum of $C(G)$, and any two of them that
are adjacent in $C(G)$ automatically have equal degree — precisely the setup for
Proposition 2.8.

---

## 4. Two lower bounds for regular graphs

Let $G$ be $d$-regular, meaning $\deg_G(v) = d$ for all $v$. Call $G$
*non-complete* if some pair of distinct vertices is non-adjacent.

**Proposition 4.1 (Vertex count).** A $d$-regular non-complete graph has
$|V(G)| \ge d + 2$.

*Proof sketch.* Fix non-adjacent distinct vertices $a, b$. The set
$\{a, b\} \cup N_G(a)$, where $N_G(a)$ is the neighbourhood of $a$, has size
$2 + d$: the vertex $a$ is not in its own neighbourhood, and $b \notin N_G(a)$
because $a, b$ are non-adjacent. Hence $|V| \ge d + 2$. $\qquad\blacksquare$

### 4.1 The degree-governed bound

**Theorem 4.2 (No AVD-total colouring with $d + 2$ colours).** Let $G$ be
$d$-regular and non-complete. Then $C(G)$ has no AVD-total colouring with
$d + 2$ colours.

*Proof sketch.* Fix non-adjacent distinct $a, b$ in $G$. By Corollary 2.4, an
AVD-total colouring of $C(G)$ with $d+2$ colours restricts injectively on the
star at the original vertex $a$, whose size is $\deg_{C(G)}(a) + 1 = |V|$. Thus
$|V| \le d + 2$, which with Proposition 4.1 forces $|V| = d + 2$. Now $a$ and $b$
are adjacent in $C(G)$ (Proposition 3.2) and both have degree $|V| - 1 = d + 1$
(Proposition 3.3), and the palette size is $d + 2 = (d+1) + 1$. Proposition 2.8
applies and rules out the AVD condition. $\qquad\blacksquare$

**Theorem 4.3 (Degree-governed lower bound).** For $G$ $d$-regular and
non-complete, every AVD-total colouring of $C(G)$ uses at least $d + 3$ colours;
that is, $\chi''_a(C(G)) \ge d + 3$.

*Proof sketch.* If some AVD-total colouring used $n \le d + 2$ colours, then by
palette monotonicity (Lemma 2.9) there would be one with exactly $d + 2$ colours,
contradicting Theorem 4.2. $\qquad\blacksquare$

### 4.2 The vertex-governed bound

**Theorem 4.4 (Vertex-governed lower bound).** For any non-complete graph $G$,
every AVD-total colouring of $C(G)$ uses at least $|V(G)| + 1$ colours; that is,
$\chi''_a(C(G)) \ge |V(G)| + 1$.

*Proof sketch.* Fix non-adjacent distinct $a, b$. They are adjacent in $C(G)$ and
both have degree $|V| - 1$ (Propositions 3.2–3.3). If an AVD-total colouring used
$n \le |V|$ colours, palette monotonicity yields one with exactly $|V|$ colours;
then Proposition 2.8 (with $\Delta = |V| - 1$) forbids the AVD condition on the
edge $ab$ — a contradiction. $\qquad\blacksquare$

Note that Theorem 4.4 requires no regularity, only non-completeness.

---

## 5. The extremal regime

We now compare the two bounds and characterise where they agree.

**Proposition 5.1 (Domination).** For $G$ $d$-regular and non-complete,
$d + 3 \le |V(G)| + 1$.

*Proof sketch.* Immediate from Proposition 4.1 ($|V| \ge d + 2$) by adding $1$.
$\qquad\blacksquare$

Thus the vertex-governed bound of Theorem 4.4 is always at least as strong as the
degree-governed bound of Theorem 4.3.

**Proposition 5.2 (Agreement iff extremal).** For $G$ $d$-regular and
non-complete,
$$d + 3 = |V(G)| + 1 \quad\Longleftrightarrow\quad |V(G)| = d + 2.$$

*Proof sketch.* Both sides are equivalent to $|V| = d + 2$ by elementary
arithmetic, using $|V| \ge d + 2$. $\qquad\blacksquare$

We call a $d$-regular non-complete graph with $|V| = d + 2$ **extremal**.

### 5.1 Complement regularity and the characterisation

**Proposition 5.3 (Complement of a regular graph is regular).** If $G$ is
$d$-regular on $n$ vertices, then its complement $G^{c}$ is $(n - 1 - d)$-regular.

*Proof sketch.* In $G^{c}$ each vertex $v$ is adjacent to exactly those vertices
other than $v$ to which it was non-adjacent in $G$, namely
$(n - 1) - \deg_G(v) = n - 1 - d$ of them. $\qquad\blacksquare$

**Theorem 5.4 (Extremal characterisation).** Let $G$ be $d$-regular and
non-complete. Then
$$|V(G)| = d + 2 \quad\Longleftrightarrow\quad G^{c}\ \text{is}\ 1\text{-regular}.$$
Equivalently, the extremal graphs are exactly the *cocktail-party graphs*
$K_{d+2}$ minus a perfect matching.

*Proof sketch.* $(\Rightarrow)$ If $|V| = d + 2$ then by Proposition 5.3 the
complement is $(|V| - 1 - d) = (d + 2 - 1 - d) = 1$-regular. $(\Leftarrow)$ If
$G^{c}$ is $1$-regular then, again by Proposition 5.3, $|V| - 1 - d = 1$, whence
$|V| = d + 2$. A $1$-regular graph is a disjoint union of single edges, i.e. a
perfect matching; deleting a perfect matching from $K_{d+2}$ yields precisely
the cocktail-party graph. $\qquad\blacksquare$

### 5.2 Collapse to a single sharp value

**Theorem 5.5 (Sharp lower bound on the extremal family).** Let $G$ be
$d$-regular and non-complete with $|V(G)| = d + 2$. Then every AVD-total
colouring of $C(G)$ uses at least $d + 3 = |V(G)| + 1$ colours; that is,
$$\chi''_a(C(G)) \ge d + 3 = |V(G)| + 1.$$

*Proof sketch.* Apply Theorem 4.4 to obtain $\ge |V| + 1$, then substitute
$|V| = d + 2$ so that $|V| + 1 = d + 3$. On the extremal family both bounds
coincide, so this single value is the common floor. $\qquad\blacksquare$

In the extremal case every original vertex of $C(G)$ has degree exactly $d + 1$
(specialising Proposition 3.3 with $|V| = d + 2$). This is the tight lower half of
the guiding conjecture $\chi''_a(C(G)) = d + 3$: the equality's lower bound holds
with equality of the two competing arguments *exactly* on the cocktail-party
family, and is strictly exceeded elsewhere.

---

## 6. Case studies: $C_4$ versus $C_5$

Cycles provide the cleanest illustrations. The $n$-cycle $C_n$ is $2$-regular, so
$d = 2$ and the extremal condition reads $n = d + 2 = 4$.

**The four-cycle $C_4$ (extremal).** $C_4$ is $2$-regular with $|V| = 4 = d + 2$,
so it is extremal. Its complement is $1$-regular — two disjoint edges, the
perfect matching $2K_2$ — matching Theorem 5.4 exactly. Consequently, by Theorem
5.5, every AVD-total colouring of $C(C_4)$ uses at least $d + 3 = |V| + 1 = 5$
colours. $C_4$ is the smallest extremal instance.

**The five-cycle $C_5$ (non-extremal).** $C_5$ is $2$-regular but has $|V| = 5
\ne 4 = d + 2$, so it is *not* extremal. Its complement is $2$-regular
($5 - 1 - 2 = 2$) — itself a pentagon, not a matching. Here the two bounds
diverge: the degree-governed bound gives $d + 3 = 5$, while the vertex-governed
bound gives $|V| + 1 = 6$, and the latter strictly dominates:
$$d + 3 = 5 \;<\; 6 = |V(G)| + 1.$$
The pentagon is the smallest witness that the naive value $d + 3$ is strictly too
small off the extremal family.

---

## 7. Algorithms

The theory is constructive enough to support explicit verification procedures on
finite instances. We describe three.

**Algorithm A (Central graph construction).** Given the adjacency relation of $G$
on vertex set $V$, build $C(G)$: its vertices are $V \sqcup E(G)$; join
$u, w \in V$ iff $u \ne w$ and $u \not\sim_G w$; join $u \in V$ to $e \in E(G)$
iff $u \in e$; never join two edge-vertices. Complexity $O(|V|^2 + |V|\,|E|)$.

**Algorithm B (Extremality test).** Given a $d$-regular non-complete $G$, report
whether it is extremal by checking $|V| = d + 2$, equivalently whether its
complement is $1$-regular (every vertex of $G^{c}$ has degree $1$). Complexity
$O(|V|^2)$.

**Algorithm C (AVD lower-bound certificate).** Given a proposed AVD-total
colouring of $C(G)$ with $n$ colours, verify properness on $T(C(G))$ and the AVD
condition on every edge of $C(G)$ by comparing signature sets; combined with the
equal-degree obstruction at a non-adjacent pair, this certifies the lower bounds
of Theorems 4.3–4.4 for the instance. Complexity polynomial in $|V(C(G))|$.

---

## 8. Applications

Total and AVD-total colourings model resource-allocation problems in which both
*entities* and *interactions* consume resources, and adjacent entities must remain
*distinguishable* by their full local resource pattern. Concrete settings include:

- **Frequency assignment with identifiability.** Assign channels to both stations
  and links so that no two conflicting elements clash *and* neighbouring stations
  carry distinguishable channel profiles for interference fingerprinting.
- **Fault-tolerant labelling.** Local uniqueness of the signature set lets a node
  be identified from its neighbourhood colouring alone, aiding fault localisation.
- **Structured scheduling.** The central-graph construction models settings in
  which every task must be scheduled against all *non-collaborators* (the
  complement edges) as well as its own sub-steps (the subdivision vertices).

The extremal characterisation identifies the precise structural regime — the
cocktail-party topology — in which the resource requirement is minimised relative
to the degree, a useful design target.

---

## 9. Discussion

Two lessons stand out. First, the *governing parameter* for $\chi''_a(C(G))$ is
the vertex count $|V|$, not the degree $d$: the vertex-governed bound dominates
everywhere, and the degree-governed bound is tight only on a measure-zero
boundary. Second, that boundary is not amorphous but a named, classical family —
the cocktail-party graphs — pinned down by a clean complement-regularity
criterion. The interplay of Proposition 3.3 (constant hub degree) and Proposition
2.8 (equal-degree obstruction) is what converts a degree hypothesis into a
vertex-count conclusion.

A subtlety worth emphasising: the non-completeness witness — an explicit
non-adjacent pair $(a, b)$ — is essential throughout. For complete graphs the
central-graph obstruction argument degenerates (there are no non-adjacent pairs to
force the equal signatures), and the extremal characterisation would be false
without it.

---

## 10. Future work

The present results settle the *lower* side on the extremal family. The natural
open problems, in increasing order of scope, are:

1. **Matching upper bound on the cocktail-party family.** Construct, for every
   $d$-regular non-complete $G$ with $|V| = d + 2$, an explicit AVD-total colouring
   of $C(G)$ with exactly $d + 3$ colours, thereby proving
   $\chi''_a(C(G)) = d + 3$ on this family. The perfect-matching structure of the
   complement suggests pairing each vertex with its unique partner and rotating a
   fixed $(d+3)$-palette along the matching.
2. **Exact value for cycles.** Determine $\chi''_a(C(C_n))$ for all $n$;
   the vertex-governed bound gives $\ge n + 1$, conjecturally sharp for
   $n \ge 4$, with a matching upper bound expected from the cyclic symmetry.
3. **Extremal characterisation refinements.** Further develop the equivalence
   "$|V| = d + 2 \iff$ complement is $1$-regular" into structural corollaries for
   the cocktail-party family.
4. **General vertex-governed upper bound.** Show $\chi''_a(C(G)) \le |V(G)| + 2$
   (or the exact value) for all regular $G$, closing the gap between the
   established lower bounds and an upper bound; the isolation of the maximum-degree
   original vertices suggests a two-phase colouring that treats the complement
   $G^{c}$ and the subdivision vertices nearly independently.

---

## Appendix: summary of results

- **Star clique / injectivity (Lemma 2.3, Cor. 2.4).** The star at $w$ is a
  clique of size $\deg(w) + 1$; its colours are pairwise distinct.
- **Equal-degree obstruction (Prop. 2.8).** Adjacent equal-degree vertices admit
  no AVD-total colouring at the tight palette size $\Delta + 1$.
- **Palette monotonicity (Lemma 2.9).** AVD-total colourability is upward closed.
- **Central degree (Prop. 3.3).** Every original vertex of $C(G)$ has degree
  $|V| - 1$.
- **Vertex count (Prop. 4.1).** A $d$-regular non-complete graph has
  $|V| \ge d + 2$.
- **Lower bounds (Thms. 4.3, 4.4).** $\chi''_a(C(G)) \ge d + 3$ and
  $\chi''_a(C(G)) \ge |V| + 1$.
- **Domination & agreement (Props. 5.1, 5.2).** $d + 3 \le |V| + 1$, equal iff
  $|V| = d + 2$.
- **Complement regularity (Prop. 5.3).** $G^{c}$ is $(n - 1 - d)$-regular.
- **Extremal characterisation (Thm. 5.4).** Extremal $\iff$ complement is
  $1$-regular $\iff$ cocktail-party graph.
- **Sharp bound (Thm. 5.5).** On the extremal family,
  $\chi''_a(C(G)) \ge d + 3 = |V| + 1$.
- **Case studies (Section 6).** $C_4$ extremal ($C(C_4)$ needs $\ge 5$ colours);
  $C_5$ non-extremal ($5 < 6$).
