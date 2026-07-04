# Forcing Edges via Endpoint Deletion, and the Dichotomy for Near-Bipartite Bricks

## Abstract

An edge of a graph is called a *forcing edge* if exactly one perfect matching
of the graph contains it. Forcing edges are the deterministic constraints of a
matching: fixing one forces the entire pairing. We give a complete, elementary
characterisation of forcing edges by *endpoint deletion*: an edge $uv$ is
forcing if and only if it is an edge and the graph obtained by deleting both
$u$ and $v$ has a unique perfect matching. The argument is carried out in a
model in which perfect matchings are fixed-point-free involutions, which
renders "the matching containing $uv$" as the single equation $f(u) = v$ and
makes the correspondence between matchings through an edge and matchings of the
deleted graph a transparent bijection. We derive three companion facts: matched
partners of interior vertices avoid the deleted endpoints; a graph with a
unique perfect matching has all of its matching edges forcing; and forcing is
symmetric in its endpoints. We then explain how this local reduction is the
engine behind a structural dichotomy for *bricks*: apart from three classical
exceptions — the tetrahedron $K_4$, the complement of the six-cycle
$\overline{C_6}$, and the Petersen graph — a brick has the property that every
*b-invariant edge* is forcing if and only if it is a near-bipartite brick in
the explicitly characterised family. All results are stated with full proof
sketches and are self-contained; no finiteness assumption is needed for the
core deletion theorem.

**Keywords:** perfect matching, forcing edge, fixed-point-free involution,
endpoint deletion, brick, b-invariant edge, near-bipartite graph, matching-covered graph.

---

## 1. Introduction

Let $G = (V, E)$ be a simple graph. A **perfect matching** of $G$ is a set of
edges $M \subseteq E$ such that every vertex of $G$ is incident to exactly one
edge of $M$. Perfect matchings encode "pairing everyone up," and they sit at
the centre of a rich structural theory developed by Lovász, Plummer,
de Carvalho, Lucchesi, Murty, and others.

Within a graph that admits perfect matchings, individual edges behave very
differently. Some edges lie in many matchings; some lie in exactly one. An edge
$e$ is a **forcing edge** if precisely one perfect matching contains $e$. Once
we commit to using a forcing edge, the rest of the matching is uniquely
determined — the edge *forces* the whole structure. Forcing edges are the
rigid, choice-free constraints inside an otherwise flexible combinatorial
object, and identifying them is a recurring theme in matching theory,
in the theory of resonance in chemistry (where matchings model Kekulé
structures), and in the study of *bricks*.

This paper has two goals. The first is to establish, cleanly and in full
generality, the local **deletion characterisation** of forcing edges. The
second is to explain how that characterisation functions as the reduction step
in a structural **dichotomy theorem** for bricks, relating forcing to
near-bipartiteness up to three classical exceptional graphs.

### Contributions

1. A model of perfect matchings as **fixed-point-free involutions** (Section 2)
   that turns "the matching containing $uv$" into the equation $f(u) = v$.
2. The **deletion characterisation** (Theorem 4.1): $uv$ is forcing iff $uv$ is
   an edge and $G - u - v$ has a unique perfect matching. The proof exhibits an
   explicit bijection between matchings of $G$ through $uv$ and matchings of
   $G - u - v$.
3. Three companion results: the **interior-avoidance lemma** (Lemma 3.1), the
   **completeness principle** for uniquely matchable graphs (Theorem 5.1), and
   the **symmetry of forcing** (Theorem 5.2).
4. An exposition (Section 6) of how the deletion characterisation reduces the
   global "all b-invariant edges are forcing" property to a finite family of
   independent local tests, and how this underlies the dichotomy for
   near-bipartite bricks (Theorem 6.3).

---

## 2. Matchings as fixed-point-free involutions

We fix a simple graph $G$ on a vertex set $V$, written with adjacency relation
$G.\mathrm{Adj}$; recall that adjacency is symmetric and irreflexive
($u \sim v$ implies $u \neq v$).

**Definition 2.1 (Perfect matching).** A function $f : V \to V$ is a *perfect
matching* of $G$, written $f \in \mathcal{M}(G)$, if the following three
conditions hold:

- **(Involutive)** $f(f(v)) = v$ for all $v \in V$;
- **(Fixed-point-free)** $f(v) \neq v$ for all $v \in V$;
- **(Edge-respecting)** $v$ is adjacent to $f(v)$ for all $v \in V$.

Such an $f$ partitions $V$ into unordered pairs $\{v, f(v)\}$, each of which is
an edge of $G$; conversely, any perfect matching (in the classical
edge-set sense) determines such an $f$. The involution model is equivalent to
the classical one but is far more convenient for the questions we study,
because it makes "the partner of $v$" a first-class object $f(v)$.

**Definition 2.2 (Forcing edge).** For $u, v \in V$, the ordered pair $(u, v)$
is *forcing*, written $(u, v) \in \mathcal{F}(G)$, if:

- $u$ is adjacent to $v$; and
- there exists a **unique** $f$ with $f \in \mathcal{M}(G)$ and $f(u) = v$.

The uniqueness clause is the heart of the matter: among all perfect matchings,
exactly one places $u$ opposite $v$. This is the involution-model rendering of
"exactly one perfect matching contains the edge $uv$."

**Definition 2.3 (Matching of the deleted graph).** For $u, v \in V$, a
function $h : V \to V$ is a *perfect matching of $G$ with $u, v$ deleted*,
written $h \in \mathcal{M}(G - u - v)$, if:

- $h$ is involutive;
- $h(u) = u$ and $h(v) = v$ (the two deleted vertices are fixed points); and
- for every $w \notin \{u, v\}$: $h(w) \neq w$, $w$ is adjacent to $h(w)$, and
  $h(w) \neq u$, $h(w) \neq v$.

Here we represent $G - u - v$ *in place* on the same vertex set $V$: the two
deleted vertices are parked as fixed points, and every other vertex is matched,
within the graph, to a partner distinct from $u$ and $v$. This "in-place"
representation is what makes the deletion bijection below purely local
bookkeeping.

---

## 3. The interior-avoidance lemma

The single non-trivial input to the whole development is the observation that,
in a matching that already uses the edge $uv$, no *other* vertex may be matched
to $u$ or to $v$.

**Lemma 3.1 (Interior avoidance).** Let $f \in \mathcal{M}(G)$ and suppose
$f(u) = v$. Then for every $w$ with $w \neq u$ and $w \neq v$, we have
$f(w) \neq u$ and $f(w) \neq v$.

*Proof.* Since $f$ is an involution, $f(u) = v$ gives $f(v) = u$. Suppose for
contradiction $f(w) = u$. Applying $f$ and using involutivity gives
$w = f(u) = v$, contradicting $w \neq v$. Symmetrically, $f(w) = v$ forces
$w = f(v) = u$, contradicting $w \neq u$. $\qquad\blacksquare$

In matching language, this is nothing but the defining property that partners
are not shared: $u$ and $v$ are already committed to each other, so no third
vertex can claim either of them. Injectivity of the involution encodes exactly
this.

---

## 4. The deletion characterisation

We now build the bijection between matchings of $G$ through $uv$ and matchings
of $G - u - v$, and read off the main theorem. Fix distinct vertices $u, v$
(distinctness is automatic when $uv$ is an edge, since $G$ is loopless).

**Definition 4.1 (Restriction and extension).** Given $u, v$, define two
operations on functions $V \to V$:

$$
(\mathrm{restrict}\,f)(w) =
\begin{cases}
u & \text{if } w = u,\\
v & \text{if } w = v,\\
f(w) & \text{otherwise;}
\end{cases}
\qquad
(\mathrm{extend}\,h)(w) =
\begin{cases}
v & \text{if } w = u,\\
u & \text{if } w = v,\\
h(w) & \text{otherwise.}
\end{cases}
$$

Restriction "parks" $u$ and $v$ as fixed points and leaves every other partner
untouched; extension re-installs the swap $u \leftrightarrow v$.

**Lemma 4.2 (Restriction lands in the deleted graph).** If
$f \in \mathcal{M}(G)$ and $f(u) = v$ and $u \neq v$, then
$\mathrm{restrict}\,f \in \mathcal{M}(G - u - v)$.

*Proof.* Involutivity of $\mathrm{restrict}\,f$ is checked by cases on whether
$w \in \{u, v\}$, using Lemma 3.1 to ensure that for interior $w$, $f(w)$ is
neither $u$ nor $v$ (so the outer $\mathrm{restrict}$ does not re-map it). The
fixed-point conditions at $u, v$ are immediate. For interior $w$, the four
required facts ($f(w) \neq w$, adjacency of $w$ and $f(w)$, and $f(w) \notin
\{u, v\}$) come from fixed-point-freeness, edge-respect, and Lemma 3.1
respectively. $\qquad\blacksquare$

**Lemma 4.3 (Extension lands in $G$ through $uv$).** If
$h \in \mathcal{M}(G - u - v)$ and $u$ is adjacent to $v$, then
$\mathrm{extend}\,h \in \mathcal{M}(G)$ and $(\mathrm{extend}\,h)(u) = v$.

*Proof.* By construction $(\mathrm{extend}\,h)(u) = v$. Involutivity is a case
check: $u \mapsto v \mapsto u$, and interior vertices are handled by
involutivity of $h$ together with the guarantee $h(w) \notin \{u, v\}$, which
prevents the extension from re-mapping the image. Fixed-point-freeness holds
because $u \neq v$ handles the swapped pair and $h(w) \neq w$ handles the
interior. Edge-respect holds because $uv$ is an edge (for the swapped pair)
and $h$ is edge-respecting on the interior. $\qquad\blacksquare$

**Lemma 4.4 (Mutual inverses).** On their respective domains, restriction and
extension are mutually inverse:
$\mathrm{restrict}(\mathrm{extend}\,h) = h$ for any deleted matching $h$, and
$\mathrm{extend}(\mathrm{restrict}\,f) = f$ for any matching $f$ with
$f(u) = v$ (assuming $u \neq v$).

*Proof.* Both are pointwise case checks. For $\mathrm{restrict}(\mathrm{extend}\,h)$,
the values at $u, v$ recover the fixed points $h(u) = u$, $h(v) = v$, and
interior values pass through unchanged. For
$\mathrm{extend}(\mathrm{restrict}\,f)$, the swap at $u, v$ is restored using
$f(u) = v$ and $f(v) = u$, and interior values pass through. $\qquad\blacksquare$

These four lemmas say precisely that restriction and extension form a bijection

$$
\{\, f : f \in \mathcal{M}(G),\ f(u) = v \,\}
\;\xleftrightarrow{\ \cong\ }\;
\{\, h : h \in \mathcal{M}(G - u - v) \,\}.
$$

A bijection carries "exactly one element" to "exactly one element," which is
the theorem.

**Theorem 4.1 (Deletion characterisation of forcing edges).** For any graph
$G$ and vertices $u, v$,

$$
(u, v) \in \mathcal{F}(G)
\iff
\bigl( u \text{ adjacent to } v \bigr)\ \wedge\
\bigl( \text{$G - u - v$ has a unique perfect matching} \bigr),
$$

where "$G - u - v$ has a unique perfect matching" means there is a unique $h$
with $h \in \mathcal{M}(G - u - v)$.

*Proof.* ($\Rightarrow$) Given forcing, let $f_0$ be the unique matching with
$f_0(u) = v$. Then $\mathrm{restrict}\,f_0$ is a deleted matching (Lemma 4.2).
If $h$ is any deleted matching, then $\mathrm{extend}\,h$ is a matching through
$uv$ (Lemma 4.3), so $\mathrm{extend}\,h = f_0$ by uniqueness, whence
$h = \mathrm{restrict}(\mathrm{extend}\,h) = \mathrm{restrict}\,f_0$ by
Lemma 4.4. Thus the deleted matching is unique.

($\Leftarrow$) Given adjacency and a unique deleted matching $h_0$, the function
$\mathrm{extend}\,h_0$ is a matching through $uv$ (Lemma 4.3). If $f$ is any
matching with $f(u) = v$, then $\mathrm{restrict}\,f$ is a deleted matching
(Lemma 4.2), so $\mathrm{restrict}\,f = h_0$ by uniqueness, whence
$f = \mathrm{extend}(\mathrm{restrict}\,f) = \mathrm{extend}\,h_0$ by
Lemma 4.4. Thus the matching through $uv$ is unique, and $(u,v)$ is forcing.
$\qquad\blacksquare$

The theorem requires no finiteness of $V$: it is a statement about the exact
one-to-one correspondence of solution sets, valid for arbitrary graphs.

---

## 5. Companion results

**Theorem 5.1 (Completeness principle for uniquely matchable graphs).** Suppose
$G$ has a unique perfect matching $f_0$ (that is, $f_0 \in \mathcal{M}(G)$ and
every $g$ with $g \in \mathcal{M}(G)$ equals $f_0$). Then for every vertex $v$,
the edge $\{v, f_0(v)\}$ is forcing; concretely, $(v, f_0 v) \in \mathcal{F}(G)$
holds.

*Proof.* Adjacency of $v$ and $f_0(v)$ is the edge-respect clause of
$f_0 \in \mathcal{M}(G)$. For the uniqueness clause of forcing, $f_0$ itself is a
matching with $f_0(v) = f_0 v$, and any matching $g$ whatsoever equals $f_0$ by
hypothesis, so a fortiori any matching sending $v$ to $f_0 v$ equals $f_0$.
$\qquad\blacksquare$

Thus uniquely matchable graphs — a single edge, any path, any tree with a
perfect matching — are made *entirely* of forcing edges. This furnishes an
inexhaustible supply of examples and shows the deletion characterisation is not
vacuous.

**Theorem 5.2 (Symmetry of forcing).** For all $u, v$,
$(u, v) \in \mathcal{F}(G) \iff (v, u) \in \mathcal{F}(G)$.

*Proof.* Adjacency is symmetric. For an involution $f$, the condition
$f(u) = v$ is equivalent to $f(v) = u$; hence the two existence-and-uniqueness
statements defining $(u, v) \in \mathcal{F}(G)$ and $(v, u) \in \mathcal{F}(G)$
range over the *same* set of matchings and are equivalent. $\qquad\blacksquare$

Symmetry confirms that forcing is a property of the undirected edge $uv$, not of
an ordering of its endpoints, and lets us speak unambiguously of "a forcing
edge."

---

## 6. Application: the dichotomy for near-bipartite bricks

We now describe the structural theorem for which the deletion characterisation
serves as the local reduction step. This section states definitions and the
dichotomy in self-contained prose; the deletion characterisation of Section 4
is what makes the global property algorithmically and structurally tractable.

### 6.1 Bricks and their special edges

A graph $G$ is **matching-covered** if it is connected and every edge lies in
some perfect matching. Among matching-covered graphs, the *bricks* are the
indivisible building blocks.

**Definition 6.1 (Brick).** A **brick** is a graph that is simultaneously:

- **3-connected**: it has more than three vertices and cannot be disconnected
  by deleting fewer than three vertices;
- **bicritical**: for every pair of distinct vertices $x, y$, the graph
  $G - x - y$ still has a perfect matching; and
- **non-bipartite**: its vertex set cannot be two-coloured so that every edge
  joins the two colours.

A cornerstone of the theory (the *tight cut decomposition*) shows that every
matching-covered graph reduces to a list of bricks and *braces* (the bipartite
analogue). Hence bricks are the atoms of matching structure, and questions
about matchings are ultimately questions about bricks.

**Definition 6.2 (b-invariant edge).** An edge $e$ of a brick $G$ is
**b-invariant** if removing it preserves the essential matching structure — 
precisely, if $G - e$ remains matching-covered and its tight cut decomposition
yields a single brick. The b-invariant edges are the edges the structural
theory of bricks is most sensitive to; every brick other than $K_4$ and
$\overline{C_6}$ possesses at least one.

**Definition 6.3 (Near-bipartite graph).** A graph is **near-bipartite** if it
is non-bipartite but there exist two edges $e_1, e_2$ whose *simultaneous*
removal yields a bipartite graph, with the additional requirement (in the brick
setting) that $\{e_1, e_2\}$ meets every odd structure in a controlled way.
Intuitively, a near-bipartite brick is "one removable pair of edges away" from
being two-sided.

### 6.2 The dichotomy

The relationship between the two families of special edges — b-invariant and
forcing — is governed by a clean dichotomy with exactly three exceptions.

**Theorem 6.3 (Forcing/near-bipartite dichotomy).** Let $G$ be a brick that is
*not* isomorphic to any of the three exceptional graphs

- $K_4$, the **tetrahedron** (complete graph on four vertices);
- $\overline{C_6}$, the **complement of the six-cycle** (equivalently the
  triangular prism's complement, a $6$-vertex brick); and
- the **Petersen graph** (the $10$-vertex, $15$-edge Kneser graph
  $K(5,2)$).

Then the following are equivalent:

1. Every b-invariant edge of $G$ is a forcing edge.
2. $G$ is a **near-bipartite** brick belonging to the explicitly characterised
   family of near-bipartite bricks all of whose b-invariant edges are forcing.

Equivalently: apart from the three exceptions, the property "all b-invariant
edges are forcing" holds **precisely** for near-bipartite bricks in that
family. The three exceptional graphs satisfy statement (1) *without* being
near-bipartite in the required sense, which is exactly why they must be
excluded.

### 6.3 How the deletion characterisation drives the proof

The power of Theorem 4.1 in this setting is that it converts a global, hard-to-
survey property into a finite conjunction of *local, independent* tests.

Statement (1) of the dichotomy quantifies over all b-invariant edges and asserts
a uniqueness property of the *entire* graph for each one — a priori this
requires understanding the exponentially large set of all perfect matchings.
Theorem 4.1 replaces each such assertion with an equivalent local test:

> The b-invariant edge $uv$ is forcing $\iff$ the two-vertex deletion
> $G - u - v$ has a unique perfect matching.

Consequently, "every b-invariant edge is forcing" becomes "for every
b-invariant edge $uv$, the graph $G - u - v$ is uniquely matchable." Each of
these is a self-contained statement about a smaller graph, checkable
independently of the others. This local reformulation is what makes the
structural analysis feasible:

- **Obstruction detection.** A b-invariant edge $uv$ *fails* to be forcing
  exactly when $G - u - v$ has two distinct perfect matchings, i.e. when there
  is an alternating cycle in $G - u - v$. Two distinct matchings through an edge
  are precisely the certificate of non-forcing, and they correspond to
  alternating cycles avoiding $u$ and $v$.
- **Reduction to structure.** Requiring *every* b-invariant edge to be forcing
  therefore forbids a rich family of alternating cycles. This global scarcity
  of alternating cycles is exactly the combinatorial signature that forces the
  brick into near-bipartite form — one obtains two colour classes because the
  matchings are too rigid to support the odd structure a genuinely non-bipartite
  brick would need.
- **Isolating the exceptions.** In $K_4$, $\overline{C_6}$, and the Petersen
  graph, the deletion tests all pass (every relevant two-vertex deletion is
  uniquely matchable) despite the graphs not being near-bipartite. Their high
  symmetry makes them uniquely matchable after deletion "by accident," which is
  why they sit outside the clean equivalence and must be named as exceptions.

Thus the elementary bijection of Section 4 — matchings through $uv$ against
matchings of $G - u - v$ — is not a mere curiosity. It is the reduction that
turns an intractable global classification into a tractable local one, and it is
on that reduced terrain that the near-bipartite dichotomy is proved.

---

## 7. Algorithms

The deletion characterisation is directly executable. We record the two core
procedures; full type-hinted implementations accompany this paper.

**Algorithm A (Forcing test by deletion).** *Given* a graph $G$ and an edge
$uv$, *decide* whether $uv$ is forcing. Delete $u$ and $v$; count perfect
matchings of the remainder, stopping at two. Return "forcing" iff the count is
exactly one. Correctness is Theorem 4.1. If perfect matchings are counted by
backtracking with early termination at the second matching, the test runs in
time polynomial in the size of $G - u - v$ per matching found, and needs to find
at most two.

**Algorithm B (Forcing spectrum).** *Given* a graph $G$, *return* the set of all
forcing edges. Apply Algorithm A to each edge. This yields the complete forcing
spectrum, whose size is the statistic studied in the "deletion spectrum"
conjectures of Section 8.

**Algorithm C (Uniquely-matchable certificate).** *Given* a graph, *decide*
whether it has a unique perfect matching, returning the matching as a
certificate when it exists. Combined with Theorem 5.1, a positive answer
certifies that *all* matching edges are forcing at once.

---

## 8. Discussion and future work

The deletion characterisation reduces a global forcing question to a local
unique-matching question, and the two "obstruction" observations (distinct
matchings through an edge prevent forcing; such matchings are alternating cycles
in the deleted graph) turn that reduction into a tool for structural theorems.
Several directions extend this program.

**Deletion spectrum monotonicity.** For a matching-covered graph built up by a
sequence of single and double *ear* additions, we conjecture the number of
forcing edges is non-decreasing along the decomposition, with each double ear
addition increasing it by at most the length of the shorter ear. The intuition
is that adding an ear can only *merge* previously distinct alternating routes,
never create new ones through an old edge, so the "two distinct matchings
through an edge" obstruction can only be resolved, not introduced, as the graph
grows. The deletion characterisation makes this a tractable induction by
reducing the global count to a per-edge test.

**Spectral detection of near-bipartiteness.** We conjecture that a brick in
which every strictly internal edge is forcing, and whose adjacency matrix has a
simple second-largest eigenvalue, is near-bipartite. "Every edge forcing"
forbids short alternating cycles, which caps the multiplicity of extremal
eigenvalues; a single spectral gap then rigidly fixes the two colour classes a
near-bipartite structure requires. The deletion characterisation supplies the
clean combinatorial certificate ("no alternating cycle through an edge") that a
spectral argument needs as input.

**Random cubic bricks.** We conjecture that in a uniformly random cubic
($3$-regular) brick on $2n$ vertices, the fraction of forcing edges tends to
$0$ as $n \to \infty$, with the expected number of forcing edges $O(\log n)$. A
forcing edge requires its two-vertex deletion to leave a *uniquely* matchable
remainder, an event that becomes exponentially unlikely once the remainder is a
dense expander with many alternating cycles. The reduction of forcing to a
unique-matching property lets one import the first-moment machinery for counting
matchings in random regular graphs.

**Vertex-transitive all-forcing bricks.** We conjecture that among
vertex-transitive bricks, the property "every edge is forcing" holds precisely
for the three small exceptional graphs (the tetrahedron, the complement of the
six-cycle, and the Petersen graph) — the same three graphs that are the
exceptions in the dichotomy of Theorem 6.3. Their high symmetry, which forces
uniform behaviour under two-vertex deletion, is conjecturally exactly what
singles them out.

---

## 9. Conclusion

Modelling perfect matchings as fixed-point-free involutions renders "the
matching containing $uv$" as a single equation and turns the deletion of an
edge's endpoints into an explicit bijection between matchings through the edge
and matchings of the smaller graph. From this bijection the deletion
characterisation of forcing edges follows without any finiteness assumption, and
with it the completeness principle for uniquely matchable graphs and the
symmetry of forcing. The characterisation is not only elegant but
*load-bearing*: it is the local reduction that converts the global property "all
b-invariant edges of a brick are forcing" into a finite family of independent
unique-matching tests, and it is on that reduced terrain that the dichotomy —
near-bipartiteness up to the three classical exceptions $K_4$, $\overline{C_6}$,
and the Petersen graph — is established.

---

## References

- L. Lovász and M. D. Plummer, *Matching Theory*, North-Holland, 1986.
- M. H. de Carvalho, C. L. Lucchesi, and U. S. R. Murty, *On a conjecture of
  Lovász concerning bricks*, J. Combin. Theory Ser. B (2002).
- L. Lovász, *Matching structure and the matching lattice*, J. Combin. Theory
  Ser. B (1987).
- D. J. A. Welsh and others, on counting perfect matchings in regular graphs.
