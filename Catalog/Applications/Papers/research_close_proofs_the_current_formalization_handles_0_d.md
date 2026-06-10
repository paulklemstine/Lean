# A Formal Framework for Degree-Based Extremal Graph Theory: Mantel, Turán, and Constructive Triangle Removal

## Abstract

We present a self-contained, formally verified development of the core
results of degree-based extremal graph theory. The centerpiece is a
complete proof of **Mantel's theorem** — every triangle-free graph on `n`
vertices has at most `n²/4` edges — obtained through the classical degree
counting argument built on two reusable lemmas: a Cauchy–Schwarz *degree
energy* inequality and a triangle-free *disjoint neighborhood* bound. We
generalize the extremal construction by defining the **Turán graph**
`T(n, p)` via residue classes and proving it is `K_{p+1}`-free, the
defining property of the extremal example for Turán's theorem. We isolate
the **neighborhood clique-free lemma**, the inductive engine of Turán-type
arguments. On the algorithmic side, we prove a **greedy triangle removal**
theorem: every graph admits a triangle-free subgraph reachable by deleting
at most one edge per triangle, giving a verified upper bound on the edit
distance to triangle-freeness; we establish the basic metric properties of
this edit distance. Finally, we record auxiliary infrastructure including
the handshaking lemma and the monotonicity of the lower shadow, the latter
bridging toward extremal set theory and the Kruskal–Katona theorem. All
results are stated for simple graphs on a finite vertex type `Fin n` with
decidable adjacency.

**Keywords:** extremal graph theory, Mantel's theorem, Turán's theorem,
triangle-free graphs, Cauchy–Schwarz, degree sequence, clique-freeness,
edit distance, lower shadow, formal verification.

---

## 1. Introduction

Extremal graph theory studies the maximum (or minimum) value of a graph
parameter — typically the number of edges — over all graphs avoiding a
prescribed subgraph. The prototypical question, *how many edges can a
triangle-free graph on `n` vertices have?*, was answered by Mantel in
1907: at most `⌊n²/4⌋`. Turán generalized this in 1941 to forbidden
complete graphs `K_{p+1}` of any size, founding the modern field.

This paper develops these results in a uniform, machine-checked framework.
Our guiding design principle is **decomposition into reusable lemmas**: the
degree-energy inequality and the disjoint-neighborhood bound are proved
once as standalone statements and then composed to yield Mantel's theorem.
This mirrors mathematical best practice and makes the development a genuine
*library* rather than a single monolithic proof.

Throughout, `G` denotes a simple graph on the finite vertex type
`Fin n = {0, 1, …, n−1}`, adjacency is decidable, `deg(v)` is the degree
of `v`, `N(v)` its neighborhood (the finite set of neighbors), and `|E|`
the number of edges. We write `K_r` for the complete graph on `r`
vertices, and call `G` *`K_r`-free* (or `CliqueFree r`) if it contains no
set of `r` pairwise-adjacent vertices.

### 1.1 Summary of contributions

1. **Neighborhood clique-free lemma** (Theorem 3.1): the inductive tool
   reducing `K_r`-freeness to `K_{r-1}`-freeness on neighborhoods.
2. **Degree-energy Cauchy–Schwarz bound** (Theorem 4.1):
   `n·∑ deg(v)² ≥ (∑ deg(v))²`.
3. **Turán graph clique-freeness** (Theorem 5.1): `T(n,p)` is
   `K_{p+1}`-free.
4. **Mantel's theorem** (Theorem 6.1): triangle-free `⇒ 4|E| ≤ n²`.
5. **Greedy triangle removal** (Theorem 7.1): a constructive triangle-free
   subgraph with deletion count bounded by the triangle count, plus edit
   distance metric properties (Theorem 7.2).
6. **Auxiliary infrastructure** (Section 8): handshaking lemma,
   triangle-free disjoint neighborhoods and degree-sum bound, the
   degree-energy edge bound, and lower-shadow monotonicity.

---

## 2. Preliminaries and definitions

We work with `SimpleGraph (Fin n)` and the following notions.

**Definition 2.1 (Degree and neighborhood).** For a vertex `v`, the
neighborhood `N(v)` is the finite set `{w : G.Adj v w}`, and the degree is
`deg(v) = |N(v)|`.

**Definition 2.2 (Clique-freeness).** `G` is `CliqueFree r` if there is no
finite set `s` of vertices with `|s| = r` such that every two distinct
elements of `s` are adjacent (`G.IsClique s`). A set `s` with `|s| = r`
that is a clique is an *`r`-clique* (`IsNClique r s`).

**Definition 2.3 (Edge count).** `|E|` is the cardinality of the edge
finset `G.edgeFinset`, the set of unordered adjacent pairs.

**Definition 2.4 (Turán graph).** For `n` vertices and `p ≥ 1` parts, the
Turán graph `T(n, p)` is the simple graph on `Fin n` in which distinct
vertices `x` and `y` are adjacent if and only if `x mod p ≠ y mod p`. The
`p` residue classes modulo `p` are the partition classes; the graph is
complete `p`-partite and as balanced as `n` and `p` allow.

**Definition 2.5 (Triangle count).** `triangleCount G` denotes the number
of triangles (3-cliques) in `G`; `orderedTriangleFinset G` is the finset
of ordered triples `(a, b, c)` with `a < b < c` forming a triangle, a
canonical enumerator of triangles used by the removal algorithm.

**Definition 2.6 (Edge edit distance).** For graphs `G, H` on a common
finite vertex type, `edgeEditDistance G H` is the size of the symmetric
difference of their edge sets — the number of edges that must be added or
removed to transform one into the other.

**Definition 2.7 (Degree energy).** The *degree energy* of `G` is
`∑_{v} deg(v)²`, the sum of squared degrees. It is the discrete analogue
of an `ℓ²` norm of the degree sequence and the quantity controlled by
Cauchy–Schwarz.

**Definition 2.8 (Lower shadow).** For a family `𝒜` of finite subsets of a
type `α`, the *lower shadow* `∂𝒜` is the family of all sets obtainable by
deleting a single element from a member of `𝒜`:
`∂𝒜 = ⋃_{A ∈ 𝒜} { A \ {a} : a ∈ A }`.

---

## 3. The neighborhood clique-free lemma

**Theorem 3.1 (Neighborhood clique-freeness).** Let `r ≥ 2` and let `G` be
`CliqueFree r`. Then for every vertex `v`, the neighborhood `N(v)`
contains no `(r−1)`-clique. Precisely: either `|N(v)| < r−1`, or every
subset `s ⊆ N(v)` with `|s| = r−1` fails to be a clique.

*Proof sketch.* Suppose for contradiction that some `s ⊆ N(v)` with
`|s| = r−1` is a clique. Consider `s' = {v} ∪ s`. Since `s ⊆ N(v)`, the
vertex `v` is adjacent to every element of `s`, and `v ∉ s` (a vertex is
not its own neighbor), so `|s'| = (r−1) + 1 = r`. The set `s'` is a clique:
any two distinct vertices of `s` are adjacent because `s` is a clique, and
`v` is adjacent to each element of `s` by construction. Thus `s'` is an
`r`-clique, contradicting `CliqueFree r`. ∎

This lemma is the inductive backbone of degree-based proofs of Turán's
theorem: to bound the size of a `K_r`-free graph, one bounds the size of
the `K_{r-1}`-free neighborhoods and recurses on `r`.

---

## 4. The degree-energy Cauchy–Schwarz bound

**Theorem 4.1 (Degree energy lower bound).** For any graph `G` on `Fin n`,
`n · ∑_{v} deg(v)² ≥ (∑_{v} deg(v))²`.

*Proof sketch.* Apply the Cauchy–Schwarz inequality
`(∑_i u_i v_i)² ≤ (∑_i u_i²)(∑_i v_i²)` with `u_i = 1` and `v_i = deg(i)`,
both indexed over the `n` vertices. The left side becomes
`(∑ deg(v))²`; the right side becomes `(∑ 1²)(∑ deg(v)²) = n · ∑ deg(v)²`.
Rearranging gives the claim. (The proof is carried out over `ℝ` and the
result transferred back to `ℕ` by casting, since all quantities are
non-negative integers.) ∎

Equivalently, writing `2|E| = ∑ deg(v)` (the handshaking lemma, Theorem
8.1), this reads `∑ deg(v)² ≥ (2|E|)²/n = 4|E|²/n`: the degree energy is
minimized by the regular degree distribution and is bounded below by the
square of the average degree. This is the precise sense in which "spreading
degrees evenly is cheapest," and it is the analytic half of Mantel's
proof.

---

## 5. The Turán graph is clique-free

**Theorem 5.1 (Turán graph clique-freeness).** For all `n` and all
`p ≥ 1`, the Turán graph `T(n, p)` is `CliqueFree (p+1)`.

*Proof sketch.* Let `t` be any set of `p+1` vertices. Consider the map
`x ↦ x mod p`, sending each vertex to its residue class in
`{0, 1, …, p−1}`. The image lies in a set of size `p`, but `|t| = p+1`, so
by the pigeonhole principle the map is not injective on `t`: there exist
distinct `x, y ∈ t` with `x mod p = y mod p`. By Definition 2.4, vertices
with equal residues are *non-adjacent* in `T(n, p)`. Hence `t` contains a
non-adjacent pair and cannot be a clique. As `t` was arbitrary, `T(n, p)`
has no `(p+1)`-clique. ∎

Theorem 5.1 certifies that the Turán graph is a *valid* `K_{p+1}`-free
construction. The full Turán theorem asserts further that `T(n, p)`
*maximizes* edges among all such graphs; for `p = 2` this maximality is
exactly Mantel's theorem (Section 6), proved here in full.

---

## 6. Mantel's theorem

**Theorem 6.1 (Mantel).** If `G` on `Fin n` is triangle-free
(`CliqueFree 3`), then `4|E| ≤ n²`.

*Proof sketch.* The argument composes three ingredients.

1. **Local degree bound (Theorem 8.3).** For every edge `{u, v}`,
   `deg(u) + deg(v) ≤ n`. This holds because in a triangle-free graph the
   neighborhoods `N(u)` and `N(v)` of adjacent vertices are disjoint
   (Theorem 8.2: a common neighbor would complete a triangle), and both
   are subsets of the `n` vertices, so `|N(u)| + |N(v)| = |N(u) ∪ N(v)|
   ≤ n`.

2. **Summation identity.** Summing `deg(u) + deg(v) ≤ n` over all edges
   yields `∑_{\{u,v\} ∈ E}(deg(u)+deg(v)) ≤ n·|E|`. The left-hand side
   equals the degree energy `∑_v deg(v)²`, since each vertex `v` is the
   endpoint of `deg(v)` edges and contributes `deg(v)` to each. Hence
   `∑_v deg(v)² ≤ n·|E|` (this is Theorem 8.4).

3. **Cauchy–Schwarz and handshaking.** By Theorem 4.1 and the handshaking
   lemma `∑ deg(v) = 2|E|`,
   `(2|E|)² = (∑ deg(v))² ≤ n·∑ deg(v)² ≤ n·(n·|E|) = n²·|E|`.
   Therefore `4|E|² ≤ n²·|E|`, and dividing by `|E|` (the case `|E| = 0`
   being trivial) gives `4|E| ≤ n²`. ∎

Since `4|E| ≤ n²` is equivalent to `|E| ≤ n²/4`, and the bound is achieved
by the balanced complete bipartite graph `T(n, 2)` (Theorem 5.1 guarantees
it is triangle-free), Theorem 6.1 is sharp.

---

## 7. Constructive triangle removal

We turn from existence bounds to an algorithm with a verified cost
guarantee.

**Theorem 7.1 (Greedy triangle removal).** For every graph `G` on `Fin n`
there exists a triangle-free graph `H` (with decidable adjacency) such
that `H` is obtained from `G` by deleting edges and
`|E(G)| − |E(H)| ≤ triangleCount G`.

*Proof sketch.* Enumerate the triangles of `G` via
`orderedTriangleFinset G`. For each triangle `(a, b, c)` choose one of its
three edges — say via a choice function `f` selecting an edge in
`{ {a,b}, {a,c}, {b,c} } ∩ E(G)`. Let `E'` be the set of chosen edges;
then `|E'| ≤ triangleCount G`, since at most one edge is chosen per
triangle. Define `H` to be `G` with the edge set `E(G) \ E'`. Every
triangle of `G` has at least one of its three edges in `E'`, hence at
least one edge missing in `H`, so `H` is triangle-free. The number of
deleted edges is `|E(G)| − |E(H)| ≤ |E'| ≤ triangleCount G`. ∎

The theorem yields an explicit certificate that the edit distance from any
graph to the nearest triangle-free graph is at most its triangle count — a
quantitative, constructive complement to the existential bound of Mantel's
theorem.

**Theorem 7.2 (Edit distance is a pseudometric germ).** For graphs `G, H`
on a common finite vertex type:
(i) `edgeEditDistance G H = edgeEditDistance H G` (symmetry);
(ii) `edgeEditDistance G G = 0` (reflexivity / identity of indiscernibles
in the trivial direction).

*Proof sketch.* Both follow directly from Definition 2.6: the symmetric
difference of edge sets is symmetric in its two arguments, and the
symmetric difference of a set with itself is empty. ∎

---

## 8. Auxiliary infrastructure

These lemmas are proved as standalone, reusable components.

**Theorem 8.1 (Handshaking lemma).** For any `G` on `Fin n`,
`2|E| = ∑_v deg(v)`. *Proof.* Each edge contributes exactly `2` to the
degree sum, once for each endpoint; this is the standard double-counting
of incidences, available as `sum_degrees_eq_twice_card_edges`. ∎

**Theorem 8.2 (Disjoint neighborhoods).** If `G` is triangle-free and
`u, v` are adjacent, then `N(u) ∩ N(v) = ∅`. *Proof.* A common neighbor
`w ∈ N(u) ∩ N(v)` would make `{u, v, w}` a 3-clique (all three pairs
adjacent), contradicting `CliqueFree 3`. ∎

**Theorem 8.3 (Triangle-free degree-sum bound).** If `G` is triangle-free
and `u, v` are adjacent, then `deg(u) + deg(v) ≤ n`. *Proof.* By Theorem
8.2 the neighborhoods are disjoint, so `deg(u) + deg(v) = |N(u) ∪ N(v)|
≤ |Fin n| = n`. ∎

**Theorem 8.4 (Degree energy controls edges, triangle-free case).** If `G`
is triangle-free then `∑_v deg(v)² ≤ n·|E|`. *Proof.* Rewrite
`∑_v deg(v)²` as `∑_u ∑_{v ∈ N(u)} deg(v)` (which equals
`∑_u ∑_{v ∈ N(u)} deg(u)` after a symmetry/reindexing of the adjacency
relation), then dominate `deg(u) + deg(v) ≤ n` over each edge and combine
with the handshaking lemma. ∎

This is the cross-domain bridge: it expresses the *energy* quantity
`∑ deg(v)²` in terms of the *combinatorial* edge count under the
triangle-free constraint, and together with Theorem 4.1 it furnishes an
alternative, modular route to Mantel.

**Theorem 8.5 (Lower shadow monotonicity).** For families `𝒜 ⊆ ℬ` of
finite subsets of `α`, the lower shadows satisfy `∂𝒜 ⊆ ∂ℬ`. *Proof.* The
shadow is a `biUnion` over the family; enlarging the index family from `𝒜`
to `ℬ` can only enlarge the union. ∎

Theorem 8.5 is the first step toward the Kruskal–Katona theorem, which
sharply bounds the size of `∂𝒜` in terms of `|𝒜|` and is the extremal
set-theoretic counterpart of Turán-type edge bounds.

---

## 9. Algorithms

**Algorithm 9.1 (Greedy triangle removal).** Realizing Theorem 7.1:

```
Input:  graph G on n vertices
Output: triangle-free subgraph H, with ≤ triangleCount(G) edges removed
H ← G
for each triangle (a, b, c) in orderedTriangleFinset(G):
    if (a,b,c) is still a triangle in H:        # all 3 edges present
        remove any one of edges {a,b}, {a,c}, {b,c} from H
return H
```

Correctness: every original triangle loses an edge, so `H` is
triangle-free; at most one removal per triangle bounds the cost.

**Algorithm 9.2 (Turán construction `T(n, p)`).** Realizing Definition
2.4 / Theorem 5.1: place vertex `i` in class `i mod p`; join `i, j` iff
`i mod p ≠ j mod p`. Produces a `K_{p+1}`-free graph with the maximum
edge count for Turán's theorem.

**Algorithm 9.3 (Mantel certificate / edge-budget check).** Given `n`,
report the maximum admissible triangle-free edge count `⌊n²/4⌋`; given a
specific edge count `m`, certify that `m > ⌊n²/4⌋` forces a triangle
(Theorem 6.1).

---

## 10. Applications

- **Network design.** The balanced complete `p`-partite construction
  underlies dense networks that avoid small cliques, relevant to
  interconnection topologies and conflict-free scheduling.
- **Community detection and clustering.** Triangle counts and triangle
  removal are primitives in social/biological network analysis; Theorem
  7.1 bounds the cost of "de-triangulating" a network.
- **Coding theory.** Turán-type extremal constructions connect to
  constant-weight codes and combinatorial designs.
- **Property testing.** The triangle-removal perspective underlies
  algorithms that test whether a graph is far from triangle-free.

---

## 11. Discussion and future work

The development is deliberately modular: Mantel's theorem is assembled from
the degree-energy bound (Theorem 4.1) and the triangle-free degree bound
(Theorems 8.2–8.4), each independently reusable. Natural extensions:

1. **Full Turán optimality.** Extend Theorem 5.1 (clique-freeness) to the
   complete Turán theorem: that `T(n, p)` *maximizes* edges among all
   `K_{p+1}`-free graphs, via the neighborhood lemma (Theorem 3.1) and
   induction on `p`.
2. **Sharp Mantel with floor.** Upgrade `4|E| ≤ n²` to the exact
   `|E| ≤ ⌊n²/4⌋` and characterize equality (the balanced bipartite
   graph) uniquely.
3. **Kruskal–Katona.** Build on lower-shadow monotonicity (Theorem 8.5)
   toward the full shadow-size bound, linking graph and set extremal
   theory.
4. **Stability.** Quantitative stability results: graphs with nearly
   extremal edge counts are structurally close to the Turán graph.
5. **Removal lemma.** Strengthen Theorem 7.1 toward the celebrated triangle
   removal lemma, which states that a graph with few triangles can be made
   triangle-free by deleting few edges (a `o(n²)` bound).

---

## 12. Conclusion

We have formalized a coherent slice of degree-based extremal graph theory:
the neighborhood clique-free lemma, the Cauchy–Schwarz degree-energy
inequality, the clique-freeness of the Turán graph, a full proof of
Mantel's theorem, a constructive triangle-removal algorithm with a verified
cost bound, and a set of auxiliary lemmas (handshaking, disjoint
neighborhoods, degree-energy edge bound, lower-shadow monotonicity). The
results are organized as a reusable library whose components compose
cleanly, and they chart a clear path toward the full Turán and
Kruskal–Katona theorems.
