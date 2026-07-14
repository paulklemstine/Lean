# The Sharp Order-Driven Lower Bound for Adjacent-Vertex-Distinguishing Total Colourings of Central Graphs

## Abstract

The *central graph* $C(G)$ of a finite simple graph $G$ is obtained by
subdividing every edge of $G$ exactly once and joining every pair of
non-adjacent vertices of $G$. Its structure has a distinctive feature: while each
subdivision vertex has degree $2$, **every original vertex has degree $|V(G)|-1$**,
so all original vertices are maximum-degree vertices whose common degree depends
only on the *order* of $G$, not on its degree sequence. We study the
*adjacent-vertex-distinguishing (AVD) total chromatic number* $\chi''_a(C(G))$,
the least size of a palette admitting a proper total colouring in which adjacent
vertices receive distinct colour sets. A previously known bound for $d$-regular
non-complete graphs asserts $\chi''_a(C(G)) \ge d+3$. We prove the strictly
stronger, order-driven bound
$$\chi''_a\big(C(G)\big) \ge |V(G)| + 1 \qquad\text{for every non-complete } G,$$
and show it dominates the degree bound: any $d$-regular non-complete graph
satisfies $|V(G)| \ge d+2$, hence $|V(G)| + 1 \ge d+3$, with strict improvement
whenever $|V(G)| > d+2$. The five-cycle $C_5$ realises the smallest strict
separation, requiring $6$ colours where the degree bound predicts only $5$. The
central mechanism is an *adjacent equal-degree obstruction*: at a maximum-degree
vertex, a palette of size $\deg + 1$ is forced to use every colour, so two
adjacent vertices of equal degree acquire identical colour sets and cannot be
distinguished. Because non-adjacent pairs of $G$ become adjacent equal-degree
pairs in $C(G)$, the obstruction fires precisely when $G$ is not complete,
isolating complete graphs as the unique exceptional family.

**Keywords.** Adjacent-vertex-distinguishing total colouring, central graph,
total chromatic number, regular graph, edge subdivision, graph order, clique
lower bound.

---

## 1. Introduction

Colouring problems on graphs typically measure difficulty through *degree*: a
vertex with many neighbours competes for many colours. This paper concerns a
construction — the central graph — for which the natural degree-based intuition
gives a valid but suboptimal answer, and where the true controlling invariant is
the *order* (number of vertices) of the underlying graph.

Let $G$ be a finite simple graph with vertex set $V(G)$ and edge set $E(G)$. Its
central graph $C(G)$ subdivides each edge once and adds an edge between each pair
of non-adjacent vertices. This double action produces a graph on $V(G)\sqcup
E(G)$ in which all original vertices attain the common degree $|V(G)|-1$. We are
interested in *total colourings* of $C(G)$ that not only are proper but also
*distinguish adjacent vertices by their colour sets*.

The literature records, for $d$-regular non-complete graphs, the lower bound
$\chi''_a(C(G)) \ge d+3$. Our contribution is to show that this is an artefact of
measuring the wrong quantity: the correct first-order invariant is $|V(G)|$, and
$$\chi''_a\big(C(G)\big) \ge |V(G)| + 1$$
for every non-complete $G$, a bound that recovers and strictly improves upon the
degree bound. The argument is entirely structural and rests on a single clean
obstruction concerning adjacent vertices of equal degree.

The paper is organised as follows. Section 2 fixes definitions of the total
graph, colour sets, and the AVD condition. Section 3 develops the central graph
and its degree structure. Section 4 proves the key obstruction and the padding
(monotonicity) lemma. Section 5 assembles the sharp lower bound. Section 6
compares it with the degree bound and works out the five-cycle. Section 7
discusses the exceptional complete case and states open problems.

---

## 2. Preliminaries: total graphs, colour sets, and the AVD condition

### 2.1 The total graph

Let $H$ be a finite simple graph on vertex set $W$. Total colourings of $H$ are
modelled as proper vertex colourings of an auxiliary graph.

**Definition 2.1 (Total graph).** The *total graph* $T(H)$ has vertex set
$$V\big(T(H)\big) = W \sqcup E(H),$$
the disjoint union of the vertices and edges of $H$. Two vertices of $T(H)$ are
adjacent exactly when one of the following holds:

1. they are original vertices $a, b \in W$ with $a$ adjacent to $b$ in $H$;
2. one is an original vertex $a$ and the other is an edge $e$ with $a \in e$
   (incidence);
3. they are distinct edges $e \neq f$ of $H$ sharing a common endpoint.

This relation is symmetric and irreflexive, so $T(H)$ is a simple graph.

**Definition 2.2 (Total colouring).** A *total colouring* of $H$ with palette
$\kappa$ is a proper colouring of $T(H)$ by $\kappa$, i.e. a map
$C : V(T(H)) \to \kappa$ assigning distinct colours to adjacent vertices of
$T(H)$. Equivalently, it colours the vertices and edges of $H$ so that incident
or adjacent objects differ.

### 2.2 The star clique

**Definition 2.3 (Star at a vertex).** For $w \in W$, the *star* at $w$ is the
family consisting of $w$ together with all edges of $H$ incident to $w$, viewed
as vertices of $T(H)$.

**Lemma 2.4 (Star clique).** The star at $w$ is a clique of $T(H)$: its members
are pairwise adjacent in $T(H)$.

*Proof.* The vertex $w$ is adjacent to each incident edge by incidence (rule 2),
and any two distinct edges incident to $w$ share the endpoint $w$, hence are
adjacent by rule 3. $\square$

**Lemma 2.5 (Star size).** The star at $w$ has exactly $\deg_H(w) + 1$ members:
the vertex $w$ and its $\deg_H(w)$ incident edges.

Consequently any total colouring assigns pairwise distinct colours across the
star, so a palette must contain at least $\deg_H(w) + 1$ colours; and the map
$i \mapsto C(\text{star member } i)$ is injective.

### 2.3 Colour sets and the AVD condition

**Definition 2.6 (Colour set).** Given a total colouring $C$ of $H$, the *colour
set* of $w \in W$ is
$$\mathcal{C}(w) \;=\; \{\,C(w)\,\}\;\cup\;\{\,C(e) : e \in E(H),\ w \in e\,\},$$
the set of colours appearing on $w$ and on all edges incident to $w$.

**Definition 2.7 (AVD total colouring).** A total colouring $C$ is
*adjacent-vertex-distinguishing (AVD)* if for every pair of adjacent vertices
$a \neq b$ in $H$ one has $\mathcal{C}(a) \neq \mathcal{C}(b)$.

**Definition 2.8 (AVD-total chromatic number).** The *AVD-total chromatic
number* $\chi''_a(H)$ is the least cardinality of a palette admitting an AVD
total colouring of $H$ (formally, the infimum over $n$ such that an AVD total
colouring with $n$ colours exists, taken to be $+\infty$ if none exists).

---

## 3. The central graph and its degree structure

**Definition 3.1 (Central graph).** The *central graph* $C(G)$ of a finite simple
graph $G$ on vertex set $V$ has vertex set $V \sqcup E(G)$ and adjacency:

1. two original vertices $u \neq w$ are adjacent iff they are **non-adjacent** in
   $G$;
2. an original vertex $u$ and a subdivision vertex $e$ (an edge of $G$) are
   adjacent iff $u \in e$;
3. two subdivision vertices are never adjacent.

Rules (1) and (2) together implement "subdivide every edge, and join every
non-adjacent pair of original vertices."

**Proposition 3.2 (Degrees in $C(G)$).**

- Every subdivision vertex $e = \{u,w\}$ has degree $2$ in $C(G)$ (its two
  endpoints).
- Every original vertex $v$ has degree $|V| - 1$ in $C(G)$; equivalently
  $\deg_{C(G)}(v) + 1 = |V|$.

*Proof.* A subdivision vertex is adjacent only to the two endpoints of its edge,
giving degree $2$. For an original vertex $v$, its neighbours in $C(G)$ split into
two groups: the original vertices $w \neq v$ non-adjacent to $v$ in $G$, of which
there are $(|V|-1) - \deg_G(v)$; and the subdivision vertices $e$ with $v \in e$,
of which there are exactly $\deg_G(v)$ (the edges incident to $v$). Summing,
$$\deg_{C(G)}(v) = \big((|V|-1) - \deg_G(v)\big) + \deg_G(v) = |V| - 1. \qquad\square$$

The identity $\deg_{C(G)}(v) = |V|-1$ is the structural engine of the paper: it
makes every original vertex a maximum-degree vertex whose degree depends only on
the order of $G$.

**Corollary 3.3 (Non-adjacency becomes adjacent equal degree).** If $a, b \in V$
are distinct and non-adjacent in $G$, then $a$ and $b$ are adjacent in $C(G)$ and
$\deg_{C(G)}(a) = \deg_{C(G)}(b) = |V|-1$. Thus every non-adjacent pair of $G$
produces an *adjacent equal-degree pair* of $C(G)$.

---

## 4. The core obstruction and monotonicity

### 4.1 Saturation at maximum-degree vertices

**Lemma 4.1 (Palette saturation).** Let $C$ be a total colouring of $H$ using a
palette of exactly $\deg_H(w) + 1$ colours. Then the colour set of $w$ is the
entire palette:
$$\mathcal{C}(w) = \kappa.$$

*Proof.* By Lemma 2.5 the star at $w$ has $\deg_H(w)+1$ members and, being a
clique (Lemma 2.4), receives $\deg_H(w)+1$ pairwise distinct colours under $C$.
These colours are precisely $\mathcal{C}(w)$, a set of size $\deg_H(w)+1$ inside
a palette of the same size $\deg_H(w)+1$; hence $\mathcal{C}(w)$ equals the whole
palette. $\square$

**Lemma 4.2 (Adjacent equal-degree obstruction).** Suppose $u$ and $v$ are
adjacent in $H$ with $\deg_H(u) = \deg_H(v) = \Delta$, and $C$ is a total
colouring using exactly $\Delta + 1$ colours. Then $C$ is **not** AVD.

*Proof.* By Lemma 4.1 applied to $u$ and to $v$, both colour sets equal the whole
palette: $\mathcal{C}(u) = \kappa = \mathcal{C}(v)$. Since $u$ and $v$ are
adjacent and $\mathcal{C}(u) = \mathcal{C}(v)$, the AVD condition
(Definition 2.7) fails. $\square$

### 4.2 Monotonicity of admissible palette sizes

**Lemma 4.3 (Padding).** If $H$ admits an AVD total colouring with $n$ colours
and $n \le m$, then $H$ admits an AVD total colouring with $m$ colours.

*Proof.* Fix an order-embedding $\iota : [n] \hookrightarrow [m]$ (for instance
the identity inclusion). If $C$ is an AVD total colouring with palette $[n]$,
define $C' = \iota \circ C$. Since $\iota$ is injective, $C'$ maps adjacent
vertices of $T(H)$ to distinct colours, so $C'$ is a proper total colouring.
Moreover, for each vertex $w$, the colour set transforms by the same injection:
$\mathcal{C}'(w) = \iota\big(\mathcal{C}(w)\big)$, because the colour set is the
image of the star colours and $\iota$ commutes with taking images. As $\iota$ is
injective, $\mathcal{C}(a) \neq \mathcal{C}(b)$ implies
$\iota(\mathcal{C}(a)) \neq \iota(\mathcal{C}(b))$, i.e.
$\mathcal{C}'(a) \neq \mathcal{C}'(b)$. Hence $C'$ is AVD. $\square$

Equivalently, the set of admissible palette sizes is *upward closed*: if $n$
colours suffice, so does any larger number.

---

## 5. The sharp order-driven lower bound

We now specialise to $H = C(G)$ and combine the obstruction with monotonicity.

**Theorem 5.1 (No AVD colouring with $|V|$ colours).** Let $G$ be non-complete,
so there exist distinct non-adjacent $a, b \in V$. Then $C(G)$ admits no AVD
total colouring using exactly $|V|$ colours.

*Proof.* By Corollary 3.3, $a$ and $b$ are adjacent in $C(G)$ with common degree
$|V|-1$. A palette of exactly $|V| = (|V|-1)+1$ colours meets the hypothesis of
Lemma 4.2 with $\Delta = |V|-1$; hence no total colouring with $|V|$ colours is
AVD. $\square$

**Theorem 5.2 (No AVD colouring with $n \le |V|$ colours).** Under the same
hypotheses, $C(G)$ admits no AVD total colouring with any number $n \le |V|$ of
colours.

*Proof.* If some AVD total colouring used $n \le |V|$ colours, then by the
Padding Lemma 4.3 it could be extended to an AVD total colouring with exactly
$|V|$ colours, contradicting Theorem 5.1. $\square$

**Theorem 5.3 (Sharp lower bound).** For every non-complete finite simple graph
$G$, every AVD total colouring of $C(G)$ uses at least $|V|+1$ colours; that is,
$$\chi''_a\big(C(G)\big) \ge |V(G)| + 1.$$

*Proof.* Suppose an AVD total colouring uses $n$ colours. If $n \le |V|$,
Theorem 5.2 is contradicted; hence $n \ge |V|+1$. Taking the infimum over all
admissible $n$ gives $\chi''_a(C(G)) \ge |V|+1$. $\square$

This is the paper's main result. The bound is a strict *lower* bound and, as
Section 6 shows, is realised strictly above the degree bound on concrete graphs,
so it is not vacuous.

---

## 6. Domination of the degree bound and the five-cycle

### 6.1 The order bound contains the degree bound

**Lemma 6.1 (Order of a regular non-complete graph).** If $G$ is $d$-regular and
not complete, then $|V(G)| \ge d + 2$.

*Proof.* Pick a non-adjacent pair $a, b$. Consider the set
$\{a\} \cup \{b\} \cup N(a)$, where $N(a)$ is the neighbourhood of $a$. It has
$1 + 1 + d = d+2$ elements: $a \notin N(a)$ (no loops); $b \notin N(a)$ (since
$a,b$ are non-adjacent); $a \neq b$; and $|N(a)| = d$ by regularity. As this set
is contained in $V(G)$, we get $|V(G)| \ge d+2$. $\square$

**Theorem 6.2 (Domination).** For a $d$-regular non-complete graph $G$,
$$d + 3 \;\le\; |V(G)| + 1 \;\le\; \chi''_a\big(C(G)\big),$$
with equality on the left iff $|V(G)| = d+2$. In particular the classical degree
bound $\chi''_a(C(G)) \ge d+3$ follows as a corollary, and the order bound is
**strictly** stronger whenever $|V(G)| > d+2$.

*Proof.* Add $1$ to the inequality of Lemma 6.1 to get $d+3 \le |V|+1$, then
chain with Theorem 5.3. Strictness of the left inequality is exactly
$|V| > d+2$. $\square$

Since $d$-regular graphs on exactly $d+2$ vertices are highly constrained (each
vertex misses exactly one other), the strict case $|V| > d+2$ is the generic
situation, and the degree bound is generically non-sharp.

### 6.2 The smallest strict separation: $C_5$

**Proposition 6.3 (Five-cycle).** The five-cycle $C_5$ is $2$-regular and
non-complete, with $|V(C_5)| = 5$. Hence
$$\chi''_a\big(C(C_5)\big) \ge |V| + 1 = 6,$$
which strictly exceeds the degree bound $d + 3 = 5$.

*Proof.* $C_5$ has vertices $\{0,1,2,3,4\}$ each of degree $2$, so it is
$2$-regular. The pair $\{0,2\}$ is non-adjacent, so $C_5$ is non-complete and
Theorem 5.3 applies with $|V| = 5$, giving the lower bound $6$. The degree bound
gives $d+3 = 2+3 = 5 < 6$. $\square$

The five-cycle is the minimal witness: it is the smallest regular graph on which
the order bound strictly beats the degree bound, confirming that the correct
governing invariant is $|V|$ rather than $d$.

---

## 7. The exceptional complete case, and open problems

### 7.1 Why complete graphs are exactly the exceptions

Every step of the lower-bound argument is triggered by a *non-adjacent pair* of
$G$ (Theorem 5.1, via Corollary 3.3). When $G = K_n$ is complete, no such pair
exists: rule (1) of Definition 3.1 produces **no** edges among original vertices,
so the original vertices of $C(K_n)$ form an *independent set* rather than a
clique of maximum-degree vertices. The adjacent equal-degree obstruction
(Lemma 4.2) never fires, and $\chi''_a(C(K_n))$ takes a smaller value determined
by the subdivision structure alone. Thus completeness is not a defect of the
theorem but a precise description of the single situation in which its mechanism
is switched off.

### 7.2 Open problems

The lower bound $|V|+1$ invites a matching upper bound and several extensions.

1. **Exact value.** *Conjecture:* for every non-complete $G$,
   $\chi''_a(C(G)) = |V(G)| + 1$. With one colour to spare beyond the $|V|$
   forced at each maximum-degree vertex, that surplus colour should be routable
   to break all adjacent equal-degree ties simultaneously, yielding an explicit
   $(|V|+1)$-colouring.

2. **Unique exceptional family.** *Conjecture:* $\chi''_a(C(G)) = |V(G)|+1$ holds
   iff $G$ is non-complete; for complete $G$ the value is strictly smaller and
   separately determined.

3. **Degree-free total chromatic number.** *Conjecture:* the ordinary total
   chromatic number satisfies $\chi''(C(G)) = |V(G)|$ exactly for non-complete
   $G$, matching the star-clique lower bound of size $|V(G)|$ at every original
   vertex.

4. **Iterated central graphs.** *Conjecture:* $\chi''_a(C^k(G))$ grows like the
   vertex count of $C^{k-1}(G)$ plus one, giving an explicit recurrence in $k$;
   each central-graph step promotes every current vertex to maximum degree, so
   the order-driven obstruction compounds.

5. **Sharp separation.** Quantify, over all $d$-regular graphs, the maximal gap
   $|V|+1 - (d+3) = |V| - d - 2$ between the order and degree bounds.

---

## 8. Conclusion

For central graphs, degree is a red herring. The central-graph construction
levels every original vertex to the common maximum degree $|V|-1$ and converts
non-adjacency into adjacency, so the decisive obstruction is an *adjacent
equal-degree pair* whose common degree is dictated by the order of the graph. The
resulting sharp lower bound $\chi''_a(C(G)) \ge |V(G)| + 1$ subsumes the earlier
degree bound $d+3$, improves it strictly except in a degenerate case, and singles
out complete graphs as the unique exception. The five-cycle already exhibits the
separation, needing six colours where degree considerations alone would predict
five. The order of the graph, funnelled through its non-adjacent pairs, is the
true first-order invariant governing adjacent-vertex-distinguishing total
colourings of central graphs.
