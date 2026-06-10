# A Verified Core for Extremal Graph Theory: Mantel, Turán, Degree Energy, and Greedy Triangle Removal

## Abstract

We present a self-contained, formally verified development of the foundational
theorems of extremal graph theory. Working with finite simple graphs on the
vertex set {0, 1, …, n−1}, we establish: (1) the **neighborhood clique-free
lemma**, the inductive engine behind degree-based proofs of Turán's theorem;
(2) a **Cauchy–Schwarz degree-energy inequality** stating that
n · ∑ deg(v)² ≥ (∑ deg(v))²; (3) the **clique-freeness of the Turán graph**
T(n, p), which is K_{p+1}-free; (4) **Mantel's theorem**, that every
triangle-free graph on n vertices satisfies 4|E| ≤ n²; (5) a constructive
**greedy triangle-removal certificate** showing that every graph is within edit
distance equal to its triangle count of some triangle-free graph; and (6) a
suite of supporting results — the handshaking identity, the disjoint-
neighborhood property of triangle-free graphs, the resulting per-edge degree
bound, the degree-energy upper bound, metric properties of edge edit distance,
and monotonicity of the lower shadow as a bridge into extremal set theory.
Together these results form a reusable, machine-checked toolkit whose
correctness rests only on the standard logical foundations. We give precise
statements, proof sketches faithful to the formal arguments, the underlying
algorithms, and a discussion of applications and future extensions.

## 1. Introduction

Extremal graph theory asks, for a fixed forbidden subgraph H, how many edges a
graph on n vertices may have while avoiding H. The prototypical result is
**Turán's theorem** (1941), which determines the exact maximum for H = K_{p+1}
and identifies the unique extremal graph. Its r = 2 special case, **Mantel's
theorem** (1907), is the assertion that a triangle-free graph has at most n²/4
edges.

These theorems are not merely historical landmarks; the techniques they
introduced — double counting, convexity/Cauchy–Schwarz on the degree sequence,
the inductive descent into vertex neighborhoods, and greedy editing — are
ubiquitous across combinatorics, theoretical computer science, and network
science. This paper formalizes a coherent core of this theory.

Throughout, the vertex type is `Fin n` (the integers 0, …, n−1) and graphs are
finite simple graphs with decidable adjacency. We write deg(v) for the degree
of vertex v, |E| for the number of edges, N(v) for the neighborhood of v, and
CliqueFree r for the absence of a clique on r vertices.

## 2. Definitions

We collect the central definitions used below. These are standard and are used
exactly as stated.

**Definition 2.1 (Degree and neighborhood).** For a vertex v, the neighborhood
N(v) is the set of vertices adjacent to v, and the degree deg(v) = |N(v)|.

**Definition 2.2 (Clique and clique-freeness).** A set S of vertices is a
*clique* if every two distinct vertices of S are adjacent. A graph is
*CliqueFree r* if it contains no clique on r vertices (no K_r). In particular
*CliqueFree 3* means *triangle-free*.

**Definition 2.3 (Edge count and degree energy).** |E| denotes the number of
edges. The *degree energy* of G is the quantity ∑_{v} deg(v)², the sum over all
vertices of the square of the degree.

**Definition 2.4 (Turán graph).** For 1 ≤ p, the *Turán graph* T(n, p) on
vertex set Fin n is the graph in which two distinct vertices x and y are
adjacent if and only if x mod p ≠ y mod p. Equivalently, the vertices are
partitioned into p classes by residue modulo p, and two vertices are joined
exactly when they lie in different classes. This is the complete p-partite
graph with the most balanced part sizes.

**Definition 2.5 (Triangle count and ordered triangles).** The
*ordered triangle finset* of G is the set of ordered triples (a, b, c) with
a < b < c that are pairwise adjacent. The *triangle count* triangleCount(G) is
the number of triangles in G (equivalently, the cardinality of the ordered
triangle finset).

**Definition 2.6 (Edge edit distance).** For graphs G and H on a common finite
vertex set, the *edge edit distance* edgeEditDistance(G, H) is the size of the
symmetric difference of their edge sets, i.e. the number of edges that must be
added to or removed from G to obtain H.

**Definition 2.7 (Lower shadow).** For a family 𝒜 of finite subsets of a type
α, the *lower shadow* ∂𝒜 is the family of all sets obtained from a member of 𝒜
by deleting a single element: ∂𝒜 = ⋃_{A ∈ 𝒜} { A \ {x} : x ∈ A }.

## 3. Main Results

### 3.1 The neighborhood clique-free lemma

**Theorem 3.1 (Neighborhood clique-free).** Let r ≥ 2 and let G be K_r-free.
Then for every vertex v, either deg(v) < r − 1, or no (r−1)-subset of N(v) is a
clique. Equivalently, the subgraph induced on N(v) is K_{r-1}-free.

*Proof sketch.* Suppose, for contradiction, that some S ⊆ N(v) with |S| = r − 1
is a clique. Every element of S is adjacent to v, and v ∉ S because v is not
its own neighbor. Hence S ∪ {v} is a clique, and its cardinality is
(r − 1) + 1 = r. This is a K_r, contradicting K_r-freeness. ∎

This lemma is the inductive heart of degree-based proofs of Turán's theorem:
passing from G to the neighborhood of a maximum-degree vertex reduces the
forbidden clique size by one, enabling induction on r.

### 3.2 The Cauchy–Schwarz degree-energy inequality

**Theorem 3.2 (Degree energy lower bound).** For every graph G on n vertices,
n · ∑_{v} deg(v)² ≥ ( ∑_{v} deg(v) )².

*Proof sketch.* Apply the Cauchy–Schwarz inequality
(∑ u_i w_i)² ≤ (∑ u_i²)(∑ w_i²) with u_i ≡ 1 and w_i = deg(i), over the n
vertices. The left side becomes (∑ deg(v))²; the right side becomes
(∑ 1²)(∑ deg(v)²) = n · ∑ deg(v)². Casting from the reals back to the natural
numbers preserves the inequality since all quantities are non-negative
integers. ∎

This is reusable infrastructure: it is the convexity half of every
degree-based extremal argument and converts control of degree energy into
control of the edge count via handshaking.

### 3.3 The handshaking identity

**Theorem 3.3 (Handshaking).** For every graph G, 2 · |E| = ∑_{v} deg(v).

*Proof sketch.* Each edge {u, v} contributes exactly 1 to deg(u) and 1 to
deg(v), hence 2 to the degree sum; summing over edges yields the identity. This
is the standard double-counting of incidences. ∎

### 3.4 Clique-freeness of the Turán graph

**Theorem 3.4 (Turán graph is K_{p+1}-free).** For 1 ≤ p, the Turán graph
T(n, p) is CliqueFree (p + 1).

*Proof sketch.* Let t be any set of p + 1 vertices and suppose it is a clique.
Consider the map x ↦ x mod p sending each vertex to its residue class in
{0, …, p−1}, a set of size p. Since |t| = p + 1 > p, by the pigeonhole
principle two distinct vertices x, y ∈ t satisfy x mod p = y mod p. By the
definition of T(n, p), vertices with equal residues are non-adjacent. But x and
y both lie in the supposed clique t and must therefore be adjacent — a
contradiction. Hence no (p+1)-clique exists. ∎

Formally the pigeonhole step is realized by observing that the image of t under
the residue map has cardinality at most p (it sits inside {0, …, p−1}), while
injectivity of the map on t would force the image to have cardinality p + 1;
this contradiction yields the required collision.

### 3.5 Disjoint neighborhoods and the per-edge degree bound

**Theorem 3.5 (Disjoint neighborhoods).** If G is triangle-free and u, v are
adjacent, then N(u) ∩ N(v) = ∅.

*Proof sketch.* If some w lay in both N(u) and N(v), then u, v, w would be
pairwise adjacent (u–v by hypothesis, u–w and v–w by w ∈ N(u) ∩ N(v)), forming
a triangle {u, v, w}, contradicting triangle-freeness. ∎

**Theorem 3.6 (Per-edge degree bound).** If G is triangle-free and u, v are
adjacent, then deg(u) + deg(v) ≤ n.

*Proof sketch.* By Theorem 3.5 the neighborhoods N(u) and N(v) are disjoint, so
|N(u) ∪ N(v)| = |N(u)| + |N(v)| = deg(u) + deg(v). Since N(u) ∪ N(v) is a
subset of the n-element vertex set, this sum is at most n. ∎

### 3.6 The degree-energy upper bound for triangle-free graphs

**Theorem 3.7 (Degree energy bounded by n|E|).** If G is triangle-free, then
∑_{v} deg(v)² ≤ n · |E|.

*Proof sketch.* Sum the per-edge bound of Theorem 3.6 over all (ordered)
adjacent pairs. Writing the double sum ∑_u ∑_{v ∈ N(u)} (deg(u) + deg(v)), the
right-hand side is bounded by ∑_u ∑_{v ∈ N(u)} n = n · ∑_u deg(u) = n · 2|E|.
The left-hand side splits as ∑_u ∑_{v ∈ N(u)} deg(u) + ∑_u ∑_{v ∈ N(u)} deg(v).
The first term equals ∑_u deg(u)·deg(u) = ∑_u deg(u)². By symmetry of
adjacency, swapping the order of summation shows the second term equals the
first. Hence the double sum equals 2 ∑_u deg(u)², giving
2 ∑_u deg(u)² ≤ 2n|E|, i.e. ∑_u deg(u)² ≤ n|E|. ∎

This is the analytic bridge theorem: it shows that triangle-freeness directly
*caps* the degree energy, an energy-style functional, in terms of the edge
count.

### 3.7 Mantel's theorem

**Theorem 3.8 (Mantel).** If G is triangle-free on n vertices, then
4 · |E| ≤ n².

*Proof sketch.* Combine the two halves of the scissors. From Theorem 3.2 and
Theorem 3.3,
(2|E|)² = (∑ deg(v))² ≤ n · ∑ deg(v)².
From Theorem 3.7, ∑ deg(v)² ≤ n · |E|. Substituting,
4|E|² = (2|E|)² ≤ n · (n · |E|) = n² · |E|.
If |E| = 0 the conclusion is trivial; otherwise divide by |E| to obtain
4|E| ≤ n². ∎

The bound is tight: the balanced complete bipartite graph K_{⌊n/2⌋, ⌈n/2⌉} is
triangle-free and attains ⌊n²/4⌋ edges, which equals the integer floor of the
bound. Mantel's theorem is precisely the p = 2 instance of Turán's theorem,
with T(n, 2) being this extremal graph.

### 3.8 Greedy triangle removal

**Theorem 3.9 (Greedy triangle-removal certificate).** For every graph G on n
vertices there exists a triangle-free graph H, obtained from G by deleting
edges, such that |E(G)| − |E(H)| ≤ triangleCount(G).

*Proof sketch.* For each ordered triangle (a, b, c) of G, designate one of its
three edges as a "hit" edge (chosen, e.g., by a choice function over the
triangle's three edges, each of which is genuinely an edge of G). Let E′ be the
set of all designated edges; by construction |E′| ≤ triangleCount(G), since the
map from triangles to designated edges has image of size at most the number of
triangles. Define H = G with the edge set E(G) \ E′. Then:

- *H is triangle-free.* Any triangle of H is in particular a set of three
  pairwise-adjacent vertices in G, hence (in some ordering) an ordered triangle
  of G; but that triangle had a designated edge in E′, which was removed from H.
  So the three vertices cannot be pairwise adjacent in H — contradiction.
- *The edit cost is bounded.* The number of deleted edges is at most
  |E′| ≤ triangleCount(G), so |E(G)| − |E(H)| ≤ triangleCount(G). ∎

This is a *constructive* certificate: it not only asserts that a nearby
triangle-free graph exists, but bounds the distance to it by an efficiently
computable quantity (the triangle count). The underlying iterative algorithm —
repeatedly pick a triangle and delete one of its edges — is given in Section 4.

### 3.9 Edge edit distance is a pseudmetric on graphs

**Theorem 3.10 (Symmetry).** edgeEditDistance(G, H) = edgeEditDistance(H, G).

**Theorem 3.11 (Identity of indiscernibles, reflexive case).**
edgeEditDistance(G, G) = 0.

*Proof sketch.* Both follow directly from the definition as the cardinality of
the symmetric difference of edge sets: the symmetric difference is symmetric in
its arguments, and a set's symmetric difference with itself is empty. ∎

These confirm that edge edit distance behaves as a genuine distance, justifying
its use to quantify the "closeness to triangle-freeness" of Theorem 3.9.

### 3.10 A bridge to extremal set theory: shadow monotonicity

**Theorem 3.12 (Lower shadow monotonicity).** If 𝒜 ⊆ ℬ are families of finite
sets, then ∂𝒜 ⊆ ∂ℬ.

*Proof sketch.* The lower shadow is an indexed union over the family:
∂𝒜 = ⋃_{A ∈ 𝒜}(deletions of A). Enlarging the index set 𝒜 to ℬ can only add
terms to the union, so the union grows monotonically. ∎

The lower shadow is the central object of the Kruskal–Katona theorem, the
extremal-set-theory analogue of Turán's theorem. Monotonicity is the basic
structural lemma underpinning shadow arguments and links the graph-theoretic
development above to the broader landscape of extremal combinatorics.

## 3.11 A worked example

To make the scissors argument concrete, take n = 6 and the balanced complete
bipartite graph G = K_{3,3} with parts {0, 1, 2} and {3, 4, 5}. Every vertex
has degree 3, so the degree sequence is (3, 3, 3, 3, 3, 3), the edge count is
|E| = 9, and the degree energy is ∑ deg(v)² = 6 · 9 = 54.

- *Handshaking (3.3):* ∑ deg(v) = 18 = 2 · 9 = 2|E|. ✓
- *Cauchy–Schwarz (3.2):* n · ∑ deg² = 6 · 54 = 324 ≥ 18² = 324 = (∑ deg)².
  Here equality holds because the degree sequence is constant — Cauchy–Schwarz
  is tight exactly when all degrees are equal, which is the hallmark of the
  balanced extremizer. ✓
- *Disjoint neighborhoods (3.5):* the edge {0, 3} has N(0) = {3, 4, 5} and
  N(3) = {0, 1, 2}, which are indeed disjoint. ✓
- *Per-edge degree bound (3.6):* deg(0) + deg(3) = 3 + 3 = 6 = n. The bound is
  met with equality on every edge. ✓
- *Degree-energy bound (3.7):* ∑ deg² = 54 = 6 · 9 = n|E|, again tight. ✓
- *Mantel (3.8):* 4|E| = 36 = 6² = n². The graph K_{3,3} sits exactly on the
  Mantel ceiling, ⌊36/4⌋ = 9 edges. ✓

That every inequality in the chain is simultaneously tight for K_{⌊n/2⌋,⌈n/2⌉}
is precisely why the balanced complete bipartite graph is the unique
extremizer: any deviation from constant degrees loses ground at the
Cauchy–Schwarz step, and any triangle would break the per-edge bound.

## 4. Algorithms

**Algorithm A (Greedy triangle removal).** Realizing Theorem 3.9.

```
Input: graph G on n vertices
Output: triangle-free subgraph H, with |E(G)| - |E(H)| ≤ #triangles(G)
H ← G
while H contains a triangle (a, b, c):
    delete any one edge of {a-b, b-c, a-c} from H
return H
```

Each iteration strictly decreases the triangle count (the chosen triangle is
destroyed, and no new triangle is created by an edge *deletion*), so the loop
terminates after at most #triangles(G) deletions. Hence the number of removed
edges is at most #triangles(G), matching the certificate.

**Algorithm B (Turán graph construction).** Realizing Definition 2.4.

```
Input: n, p ≥ 1
Output: adjacency oracle for T(n, p)
adjacent(x, y) := (x ≠ y) and (x mod p ≠ y mod p)
```

This produces the balanced complete p-partite graph; classes are residue
classes modulo p, of sizes ⌈n/p⌉ or ⌊n/p⌋.

**Algorithm C (Mantel certificate checker).** Given a graph claimed to be
triangle-free, verify 4|E| ≤ n² by counting edges; and conversely, given an
edge count exceeding ⌊n²/4⌋, the contrapositive of Theorem 3.8 guarantees a
triangle exists (a Ramsey-style existence certificate).

## 5. Applications

- **Property testing.** Theorem 3.9 bounds the edit distance of any graph to
  triangle-freeness by its triangle count, a template for the removal lemmas at
  the heart of sublinear-time graph property testers.
- **Network science.** Degree energy ∑ deg(v)² measures degree concentration
  ("hubbiness"); Theorems 3.2 and 3.7 relate it to edge count and to the
  presence of triangles (clustering), quantities central to the analysis of
  social and biological networks.
- **Coding theory and combinatorial designs.** Turán-type bounds limit the
  density of structures avoiding small configurations, directly informing
  constructions of codes and designs.
- **Extremal set theory.** Theorem 3.12 is a foundational lemma for
  Kruskal–Katona shadow arguments, which bound intersecting families and
  underpin results from the Erdős–Ko–Rado theorem onward.

## 5.5 Related work and context

Mantel's theorem (1907) is the historical seed of the field; Turán's 1941
generalization to arbitrary forbidden cliques inaugurated extremal graph theory
as a discipline and motivated the Erdős–Stone–Simonovits theorem, which extends
the edge-density question to arbitrary forbidden subgraphs via the chromatic
number. The degree-energy / Cauchy–Schwarz route to Mantel's theorem presented
here is one of several classical proofs (others use the Motzkin–Straus quadratic
optimization, Zykov symmetrization, or a direct max-degree induction); we chose
the energy route because its constituent lemmas — handshaking, the convexity
inequality, the disjoint-neighborhood property — are independently reusable and
compose cleanly. The greedy triangle-removal certificate is the elementary,
constructive ancestor of the celebrated triangle removal lemma of Ruzsa and
Szemerédi, which underlies property-testing algorithms and Roth's theorem on
arithmetic progressions; our version trades the removal lemma's strong
guarantee (a few edges suffice) for a fully constructive, easily verified bound
(at most one edge per triangle). The lower-shadow lemma sits at the entrance of
extremal set theory, whose flagship result is the Kruskal–Katona theorem.

## 6. Discussion

The development is deliberately organized around *reusable* lemmas rather than
monolithic proofs. The Cauchy–Schwarz degree-energy inequality (3.2), the
handshaking identity (3.3), the disjoint-neighborhood property (3.5), and the
per-edge degree bound (3.6) are each independently useful, and Mantel's theorem
(3.8) is assembled from them in a few lines. This modularity mirrors the
mathematical reality that the "energy + double counting + convexity" pattern
recurs throughout extremal combinatorics, and it makes the toolkit a convenient
foundation for further verified work.

A notable feature is the explicit *constructivity* of the greedy removal
certificate (3.9): the existence of a nearby triangle-free graph is witnessed
by a concrete edge-deletion set whose size is bounded by an efficiently
computable parameter. This is the formal shadow of the algorithmic removal
lemmas that drive modern combinatorial algorithms.

## 7. Future Directions

Several natural extensions present themselves:

1. **The full Turán theorem.** Theorem 3.1 supplies the inductive step;
   combining it with the degree-energy machinery (3.2, 3.3) along the lines of
   the Motzkin–Straus or the degree-majorization argument would yield the exact
   bound |E| ≤ (1 − 1/p)·n²/2 for K_{p+1}-free graphs, with the Turán graph
   T(n, p) (Theorem 3.4) as the unique extremizer.

2. **Stability.** Beyond the extremal value, prove that any triangle-free graph
   with close to n²/4 edges is *structurally close* to the balanced complete
   bipartite graph (an Erdős–Simonovits stability statement), quantified in the
   edge-edit-distance metric of Theorems 3.10–3.11.

3. **Supersaturation.** Strengthen the contrapositive of Mantel's theorem from
   "more than n²/4 edges forces a triangle" to "forces many triangles,"
   quantifying triangleCount(G) as a function of the edge surplus.

4. **Kruskal–Katona.** Build on shadow monotonicity (3.12) toward the full
   Kruskal–Katona theorem, the sharp lower bound on shadow size, and its
   consequences (Erdős–Ko–Rado).

5. **Spectral bridges.** Relate the combinatorial degree energy to spectral
   quantities (the sum of squared adjacency eigenvalues equals twice the edge
   count; higher moments count closed walks), connecting these bounds to
   expansion and mixing-time results.

## 8. Conclusion

We have given a faithful, machine-checked account of the foundational
theorems of extremal graph theory: the neighborhood clique-free lemma, the
Cauchy–Schwarz degree-energy inequality, the clique-freeness of the Turán
graph, Mantel's theorem, a constructive greedy triangle-removal certificate,
and supporting metric and shadow lemmas. The results are stated and proved at a
level of rigor that admits no gaps, and they are organized as a modular toolkit
ready to support the deeper theorems — full Turán, stability, supersaturation,
and Kruskal–Katona — sketched among the future directions.
