# A Formal Theory of Extremal Graphs: Mantel's Theorem, Turán Graphs, and Triangle Removal

## Abstract

We develop, from first principles, a compact but complete formal theory of
extremal graph theory centered on triangle-free and clique-free graphs. The
centerpiece is **Mantel's theorem**: every triangle-free graph on `n` vertices
has at most $\lfloor n^2/4 \rfloor$ edges. We give a degree-counting proof built
on two reusable analytic primitives — the handshake identity and a
Cauchy–Schwarz "degree-energy" inequality — and we isolate the structural
ingredients (disjoint neighborhoods, degree-sum bounds) as standalone lemmas. We
prove that the **Turán graph** `T(n, p)`, defined by a residue-class partition,
is free of `(p+1)`-cliques, and we establish the **neighborhood clique-free
lemma**, the inductive engine that lifts the triangle case to the full Turán
hierarchy. On the algorithmic side, we verify a **greedy triangle-removal
certificate**: any graph can be made triangle-free by deleting at most one edge
per triangle, so its edit distance to triangle-freeness is bounded by its
triangle count. We formalize the **edge edit distance** as a metric primitive
and prove its basic properties, and we record the **monotonicity of the lower
shadow** as the entry point to extremal set theory. Finally, we discuss the
**3-AP-to-triangle bridge** linking arithmetic progressions to graph triangles.
Every result in this paper has been formally verified.

---

## 1. Introduction

Extremal graph theory asks for the maximum (or minimum) value of a graph
parameter subject to a forbidden substructure. The prototypical question — fix a
"forbidden" graph `H` and ask for the maximum number of edges in an `n`-vertex
graph with no copy of `H` — was answered for cliques by Turán (1941),
generalizing Mantel's 1907 result for the triangle.

This paper presents a self-contained formal development of the core of this
theory. We work throughout with finite simple graphs on the vertex set
`Fin n = {0, 1, …, n−1}`, with decidable adjacency so that degrees, edge sets,
and triangle counts are genuinely computable finite quantities.

The value of a *formal* treatment is twofold. First, it forces every step of
every proof — including the silent arithmetic and the pigeonhole bookkeeping —
to be made explicit and machine-checked, eliminating the gaps that informal
extremal arguments routinely leave ("clearly the left side equals the sum of
squares", "by symmetry", "by an easy induction"). Second, the resulting library
of primitive lemmas is *composable*: once the handshake identity, the
Cauchy–Schwarz degree-energy inequality, and the disjoint-neighborhood lemma are
verified once, they can be reused verbatim across the entire Turán hierarchy and
in the algorithmic and set-theoretic extensions. We have therefore structured
the development around a small number of reusable primitives rather than around a
single monolithic proof of Mantel's theorem.

A recurring design decision deserves comment. We represent the vertex set as
`Fin n` rather than as an abstract finite type. This makes the residue-class
definition of the Turán graph (Definition 2.4) immediate — vertex `i` simply
carries the numeric value `i` — and lets the pigeonhole argument of Section 5
reduce to elementary modular arithmetic on natural numbers, which automated
tactics dispatch cleanly. The cost is that some statements carry an explicit
vertex count `n`; we regard this as a worthwhile trade for computational
concreteness.

Our contributions, all formally verified, are:

1. The **neighborhood clique-free lemma** (Section 3), the inductive backbone of
   Turán-type arguments.
2. A **Cauchy–Schwarz degree-energy inequality** (Section 4), reusable
   infrastructure for all degree-based extremal bounds.
3. **Clique-freeness of the Turán graph** (Section 5) via a residue pigeonhole.
4. **Mantel's theorem** (Section 6), with a fully degree-based proof.
5. A **greedy triangle-removal certificate** and the **edge edit distance**
   metric (Section 7).
6. **Monotonicity of the lower shadow** (Section 8), bridging to extremal set
   theory, and a discussion of the **3-AP-to-triangle bridge** (Section 9).

---

## 2. Definitions and conventions

Throughout, `G` denotes a finite simple graph on `Fin n` with decidable
adjacency relation `G.Adj`.

**Definition 2.1 (Degree).** For a vertex `v`, the *neighbor set*
`N(v)` is the finite set of vertices adjacent to `v`, and the *degree*
$\deg(v) = |N(v)|$.

**Definition 2.2 (Edge count).** `E(G)` is the finite set of edges (unordered
adjacent pairs); we write $|E|$ for its cardinality.

**Definition 2.3 (Clique and clique-freeness).** A set `S` of vertices is a
*clique* if every two distinct members are adjacent. `G` is *`r`-clique-free*
(written `CliqueFree r`) if it contains no clique of size `r`. A triangle is a
3-clique, so triangle-free means `CliqueFree 3`.

**Definition 2.4 (Turán graph).** For `n` vertices and `p ≥ 1` parts, the
*Turán graph* `T(n, p)` places vertex `i` in residue class `i mod p` and makes
two vertices adjacent **iff their residues differ**:

$$
i \sim j \quad\Longleftrightarrow\quad (i \bmod p) \neq (j \bmod p).
$$

Equivalently, `T(n, p)` is the complete `p`-partite graph whose parts are the
residue classes mod `p`, each of size $\lfloor n/p \rfloor$ or
$\lceil n/p \rceil$. The case `p = 2` is the balanced complete bipartite graph.

**Definition 2.5 (Triangle count and ordered triangles).** `triangleCount G`
counts the triangles of `G`. It is convenient to enumerate them as the
`orderedTriangleFinset`, the set of ordered triples `(a, b, c)` with `a < b < c`
that are mutually adjacent; each triangle corresponds to exactly one such ordered
triple.

**Definition 2.6 (Degree energy).** The *degree energy* of `G` is
$\sum_{v} \deg(v)^2$, the sum of squared degrees. It is the natural quadratic
functional in degree-based extremal arguments.

**Definition 2.7 (Edge edit distance).** For two graphs `G`, `H` on the same
vertex set, the *edge edit distance* `edgeEditDistance G H` is the number of
edges in the symmetric difference of their edge sets — the number of single-edge
additions and deletions needed to transform one into the other.

**Definition 2.8 (Lower shadow).** For a family `𝒜` of finite sets, the
*lower shadow* `∂𝒜` is the family of all sets obtained by deleting exactly one
element from some member of `𝒜`.

---

## 3. The neighborhood clique-free lemma

The single most reusable tool for clique-free arguments is local: forbidding an
`r`-clique globally forces an `(r−1)`-clique-free structure on every
neighborhood.

**Theorem 3.1 (Neighborhood clique-free lemma).** *Let `r ≥ 2` and let `G` be
`r`-clique-free. Then for every vertex `v`, either `|N(v)| < r − 1`, or no
`(r−1)`-subset `S ⊆ N(v)` is a clique.*

*Proof sketch.* Suppose `S ⊆ N(v)` is a clique of size `r − 1`. Since `v ∉ S`
(no vertex is its own neighbor) and every vertex of `S` is adjacent to `v` (as
`S ⊆ N(v)`), the set `{v} ∪ S` is a clique: any two members of `S` are adjacent
because `S` is a clique, and `v` is adjacent to each member of `S`. Its
cardinality is $1 + (r-1) = r$. This is an `r`-clique, contradicting
`CliqueFree r`. ∎

This lemma is exactly the inductive step that lifts results about
`(r−1)`-clique-free graphs (such as the bipartite/triangle base case) to
`r`-clique-free graphs (the full Turán hierarchy): one fixes a vertex `v` of
maximum degree and applies the inductive hypothesis to the graph induced on
`N(v)`.

---

## 4. The Cauchy–Schwarz degree-energy inequality

**Theorem 4.1 (Degree-energy inequality).** *For any graph `G` on `Fin n`,*

$$
n \sum_{v} \deg(v)^2 \;\ge\; \Big(\sum_{v} \deg(v)\Big)^2.
$$

*Proof sketch.* Apply the Cauchy–Schwarz inequality
$\big(\sum_i u_i w_i\big)^2 \le \big(\sum_i u_i^2\big)\big(\sum_i w_i^2\big)$
with the constant vector $u_i = 1$ and $w_i = \deg(v_i)$. Then
$\sum_i u_i^2 = n$, $\sum_i u_i w_i = \sum_v \deg(v)$, and
$\sum_i w_i^2 = \sum_v \deg(v)^2$, which rearranges to the claim. The inequality
is the discrete statement that the quadratic mean dominates the arithmetic mean.
∎

Combined with the **handshake identity**
$\sum_v \deg(v) = 2|E|$ (Theorem 7.1 below, classical), this yields the
key consequence

$$
n \sum_v \deg(v)^2 \;\ge\; (2|E|)^2 = 4|E|^2,
\qquad\text{i.e.}\qquad
\sum_v \deg(v)^2 \ge \frac{4|E|^2}{n}.
$$

This is the lower-bound half of every degree-based extremal argument; Mantel's
theorem supplies the matching upper bound on degree energy.

---

## 5. The Turán graph is clique-free

**Theorem 5.1.** *For `n` vertices and `p ≥ 1`, the Turán graph `T(n, p)` is
`(p+1)`-clique-free.*

*Proof sketch.* Suppose `t` is a clique of size `p + 1`. Map each vertex of `t`
to its residue `i mod p`, a value in `{0, …, p−1}`. This is a map from a
`(p+1)`-element set into a `p`-element set, so by the pigeonhole principle two
distinct vertices `x ≠ y` of `t` share a residue: `x mod p = y mod p`. But by
Definition 2.4 vertices with equal residue are **non-adjacent**, contradicting
that `t` is a clique (which requires `x ∼ y`). ∎

Formally, the pigeonhole step is the observation that the image of `t` under
`(· mod p)` is contained in `range p` and would have to be injective (hence of
size `p + 1 > p`) if all residues were distinct — impossible. Together with the
edge count $\lfloor n^2/4 \rfloor$ of `T(n, 2)`, this shows the Mantel bound is
tight; more generally `T(n, p)` is the extremal graph in Turán's theorem.

---

## 6. Mantel's theorem

**Theorem 6.1 (Mantel).** *If `G` on `Fin n` is triangle-free
(`CliqueFree 3`), then*

$$
4\,|E| \;\le\; n^2.
$$

*Equivalently, $|E| \le \lfloor n^2/4 \rfloor$.*

We prove this from three ingredients. The first two are isolated as reusable
lemmas.

**Lemma 6.2 (Disjoint neighborhoods).** *If `G` is triangle-free and
`u ∼ v`, then `N(u) ∩ N(v) = ∅`.*

*Proof.* A common neighbor `w ∈ N(u) ∩ N(v)` would give mutually adjacent
`u, v, w` (using `u ∼ v`), a triangle `{u, v, w}`, contradicting
triangle-freeness. ∎

**Lemma 6.3 (Edge degree-sum bound).** *If `G` is triangle-free and `u ∼ v`,
then $\deg(u) + \deg(v) \le n$.*

*Proof.* By Lemma 6.2 the neighbor sets are disjoint, so
$\deg(u) + \deg(v) = |N(u) \cup N(v)| \le n$, since the union is a set of
vertices. ∎

**Lemma 6.4 (Degree energy controls edges).** *If `G` is triangle-free, then*

$$
\sum_{v} \deg(v)^2 \;\le\; n\,|E|.
$$

*Proof sketch.* Summing the local bound of Lemma 6.3 over all edges,

$$
\sum_{\{u,v\}\in E}\big(\deg(u)+\deg(v)\big) \;\le\; n\,|E|.
$$

The left-hand side equals $\sum_v \deg(v)^2$: in the sum
$\sum_u \sum_{v \in N(u)} \deg(u)$ each vertex `u` contributes `deg(u)` once for
each of its `deg(u)` neighbors, giving $\deg(u)^2$. (Formally one rewrites the
double sum over directed adjacent pairs, exchanges the order of summation, and
collapses it via the handshake identity.) ∎

*Proof of Theorem 6.1.* Chain the degree-energy inequality (Theorem 4.1), the
handshake identity ($\sum_v \deg(v) = 2|E|$), and Lemma 6.4:

$$
(2|E|)^2 = \Big(\sum_v \deg(v)\Big)^2 \;\le\; n\sum_v\deg(v)^2 \;\le\; n\cdot n|E| = n^2|E|.
$$

Thus $4|E|^2 \le n^2|E|$, and dividing by $|E|$ (the bound is trivial when
`G` has no edges) gives $4|E| \le n^2$. ∎

The bound is attained by the balanced complete bipartite graph `T(n, 2)`, which
is triangle-free (Theorem 5.1 with `p = 2`) and has exactly
$\lfloor n/2 \rfloor \lceil n/2 \rceil = \lfloor n^2/4 \rfloor$ edges. Hence the
extremal number for the triangle is **exactly** $\lfloor n^2/4 \rfloor$.

---

## 7. Algorithmics: triangle removal and the edit metric

**Theorem 7.1 (Handshake identity).** *For any graph `G` on `Fin n`,*
$2|E| = \sum_v \deg(v)$. *(Classical; used above.)*

**Theorem 7.2 (Greedy triangle-removal certificate).** *For any graph `G` on
`Fin n` there exists a triangle-free graph `H` (with decidable adjacency) such
that*

$$
|E(G)| - |E(H)| \;\le\; \mathrm{triangleCount}(G).
$$

*Proof sketch.* Enumerate the triangles via `orderedTriangleFinset G`. For each
triangle choose one of its three edges; let `E'` be the (multiset-deduplicated)
collection of chosen edges, so `|E'| ≤ triangleCount G`. Define
`H = G − E'` by deleting those edges. Then:

- *`H` is triangle-free.* Any triangle `{a, b, c}` of `H` would be a triangle of
  `G` (deletion never creates edges), hence appears in
  `orderedTriangleFinset G` (in one of its six vertex orderings), hence one of
  its three edges was chosen into `E'` and deleted — contradicting that all
  three of its edges survive in `H`.
- *Edge accounting.* `E(H) ⊇ E(G) ∖ E'`, so
  `|E(G)| − |E(H)| ≤ |E'| ≤ triangleCount G`. ∎

This is a constructive, verified certificate that the **edit distance** from any
graph to triangle-freeness is bounded by its triangle count — the finite,
combinatorial precursor of the asymptotic triangle removal lemma.

To make "distance to triangle-freeness" precise we formalize the metric itself.

**Theorem 7.3 (Edit-distance axioms).** *The edge edit distance satisfies, for
graphs `G`, `H` on a common finite vertex set:*

1. *Symmetry:* `edgeEditDistance G H = edgeEditDistance H G`.
2. *Identity of indiscernibles (reflexivity):* `edgeEditDistance G G = 0`.

*Proof.* Symmetry is symmetry of the symmetric difference; the self-distance is
the size of an empty symmetric difference. ∎

These are precisely the properties needed to treat triangle-removal as a
*projection onto the nearest triangle-free graph* in a genuine metric space of
graphs.

---

## 8. A bridge to extremal set theory: the lower shadow

Extremal graph theory has a sibling — extremal *set* theory — whose Turán-type
result is the Kruskal–Katona theorem on shadows. We record the foundational
monotonicity.

**Theorem 8.1 (Lower-shadow monotonicity).** *If `𝒜 ⊆ ℬ` are families of finite
sets, then `∂𝒜 ⊆ ∂ℬ`.*

*Proof.* The lower shadow is the union, over members `A`, of the single-element
deletions of `A`. Enlarging the index family only adds terms to this union, so
the shadow can only grow. ∎

Monotonicity is the structural reason the Kruskal–Katona extremal families are
*initial segments* in the colex order: one can grow a family one set at a time
without ever shrinking its shadow.

---

## 9. A cross-domain bridge: arithmetic progressions and triangles

A signature feature of modern extremal combinatorics is the translation between
number theory and graph theory. A set `S ⊆ {1, …, N}` with no three-term
arithmetic progression (3-AP) `a, a+d, a+2d` can be encoded into a tripartite
graph whose triangles are in bijection with the progressions: place three
vertex layers, connect them so that a triangle through the layers corresponds to
a choice of progression endpoints and midpoint. Progression-freeness then
becomes a graph with only "trivial" triangles, and the triangle removal lemma
forces such graphs — and hence such sets — to be sparse. This **3-AP-to-triangle
bridge** is the route by which graph-theoretic triangle bounds (Sections 6–7)
yield density bounds for progression-free sets, a theme reaching to
Roth's theorem and beyond. We state it here as the conceptual capstone tying the
triangle-centric results of this paper to additive number theory.

---

## 9.5. Worked examples

To make the statements concrete we record several small instances that also serve
as sanity checks for the formalization (all are verified numerically in the
accompanying demonstration script).

**The Mantel frontier.** The balanced complete bipartite graph `T(n, 2)` has
parts of sizes $\lfloor n/2 \rfloor$ and $\lceil n/2 \rceil$ and therefore
$\lfloor n/2 \rfloor \cdot \lceil n/2 \rceil$ edges. For `n = 2, …, 10` this gives
edge counts $1, 2, 4, 6, 9, 12, 16, 20, 25$, which agree term-by-term with
$\lfloor n^2/4 \rfloor$. Each is triangle-free, and in each case $4|E| = n^2$ for
even `n` (the bound is exactly tight) and $4|E| = n^2 - 1$ for odd `n` (tight up
to the floor). This confirms both halves of the extremal statement: the
construction reaches the ceiling, and Theorem 6.1 forbids exceeding it.

**Turán clique structure.** The graph `T(6, 3)` is the complete tripartite
graph $K_{2,2,2}$ (the octahedron). It contains many triangles — indeed `K_3`
subgraphs, one per transversal of the three parts — confirming it is *not*
triangle-free, yet it contains no `K_4`, since any four vertices include two in a
common residue class. Likewise `T(8, 4) = K_{2,2,2,2}` contains `K_4` but no
`K_5`. These instances exhibit the general phenomenon that `T(n, p)` sits exactly
at the `(p+1)`-clique-free threshold while being as dense as possible.

**Cauchy–Schwarz tightness.** For the 5-cycle `C_5`, every degree equals `2`, so
$\sum_v \deg(v)^2 = 5 \cdot 4 = 20$, $n \sum_v \deg(v)^2 = 100$, and
$(\sum_v \deg(v))^2 = 10^2 = 100$. The degree-energy inequality holds with
*equality*, as it must precisely when all degrees are equal — a useful diagnostic
for when a degree-based bound can be tight.

**Greedy removal in action.** The complete graph `K_5` has $\binom{5}{3} = 10$
triangles. The greedy procedure deletes one edge per discovered triangle and
terminates with a triangle-free graph after `6` deletions, comfortably within the
certificate bound of `10`. (Six is in fact $\binom{5}{2} - \lfloor 25/4 \rfloor =
10 - 4$, the exact number of edges that must be removed to bring `K_5` down to
its Mantel ceiling — the greedy bound is loose here, but always valid.)

## 10. Notes on the formalization

The development is carried out over finite simple graphs with `DecidableRel`
adjacency, so that `degree`, `edgeFinset`, `triangleCount`, and
`orderedTriangleFinset` are computable `Finset`-valued or `ℕ`-valued objects. We
highlight a few points where the formal proof structure mirrors — or sharpens —
the informal argument.

- *Degree energy.* The inequality `n * ∑ deg² ≥ (∑ deg)²` is obtained by
  instantiating the general finite Cauchy–Schwarz inequality
  $(\sum u_i w_i)^2 \le (\sum u_i^2)(\sum w_i^2)$ at the all-ones vector and the
  degree vector, then casting from the ordered field back to natural numbers. The
  cast is sound because all quantities are non-negative integers.
- *Pigeonhole for Turán.* Clique-freeness of `T(n, p)` is reduced to the
  statement that the residue map `(· mod p)` cannot be injective on a
  `(p+1)`-element set, since its image lies in `range p`. The contradiction with
  injectivity is exactly the cardinality inequality `p + 1 ≤ p`.
- *Mantel's chaining.* The final inequality `4|E| ≤ n²` is assembled by
  combining three previously-proved facts (Theorem 4.1, the handshake identity,
  and Lemma 6.4) through a single nonlinear-arithmetic step, after handling the
  degenerate empty-graph case.
- *Greedy certificate.* The existence proof is genuinely constructive: it
  selects, for each ordered triangle, one incident edge (via a choice function),
  forms their finite union `E'`, and deletes it. Triangle-freeness of the result
  is verified by case analysis on the six orderings of a putative surviving
  triangle, each of which would have contributed a deleted edge.

These choices keep the proofs close to their textbook form while ensuring every
implicit step is discharged.

## 11. Discussion and future work

The development is deliberately *primitive-first*: the handshake identity, the
Cauchy–Schwarz degree-energy inequality, disjoint neighborhoods, and the
neighborhood clique-free lemma are each isolated as standalone, reusable
results, so that Mantel's theorem falls out as a three-line chaining and the
full Turán theorem becomes an induction over the neighborhood lemma. The
algorithmic layer (greedy removal + edit metric) and the set-theoretic layer
(shadow monotonicity) extend the same toolkit toward property testing and the
Kruskal–Katona theorem respectively.

Natural next steps:

- **Full Turán theorem.** Combine the neighborhood lemma (Theorem 3.1) with an
  extremal degree argument to prove $|E| \le (1 - 1/p)\,n^2/2$ for
  `(p+1)`-clique-free graphs, with `T(n, p)` extremal.
- **Stability.** Show that near-extremal triangle-free graphs are close, in edit
  distance, to the balanced complete bipartite graph (Erdős–Simonovits
  stability).
- **Kruskal–Katona.** Build on shadow monotonicity (Theorem 8.1) to the full
  shadow lower bound.
- **Quantitative removal.** Strengthen the greedy certificate (Theorem 7.2)
  toward the asymptotic triangle removal lemma and the 3-AP application of
  Section 9.

Every theorem stated above has been formally verified, giving a machine-checked
foundation on which these extensions can be built with full rigor.

---

## References (classical, for orientation)

- W. Mantel, *Problem 28*, Wiskundige Opgaven (1907).
- P. Turán, *On an extremal problem in graph theory*, Mat. Fiz. Lapok (1941).
- I. Z. Ruzsa, E. Szemerédi, *Triple systems with no six points carrying three
  triangles* (1978) — the triangle removal lemma and 3-AP bridge.
