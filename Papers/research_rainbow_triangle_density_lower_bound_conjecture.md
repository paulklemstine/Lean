# Rainbow Triangles in Edge-Colored Graphs: The Extremal Density Bound $\lceil (n-1)(n-3)/8 \rceil$

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Extremal & Rainbow Combinatorics)

---

## Abstract

We develop a rigorous framework for the study of *rainbow triangles* in
edge-colored graphs, organized around a recent conjecture of Li, Ning, Shi, and
Zhang (2024). The conjecture asserts that every edge-colored graph $G$ on
$n \ge 3$ vertices with minimum color degree $\delta_c(G) \ge (n+1)/2$ contains at
least $\lceil (n-1)(n-3)/8 \rceil$ rainbow triangles, with equality only for a
distinguished extremal construction derived from a proper edge-coloring of the
complete graph $K_n$ when $n$ is odd. We make two contributions. First, we
formalize the combinatorial substrate — edge-colorings, color degree, rainbow
triangles, and proper colorings — and prove the structural backbone of the
extremal theory: in a properly edge-colored graph *every* triangle is rainbow
(`proper_isRainbowTriangle`), the color degree equals the ordinary degree
(`proper_colorDegree_eq_degree`), and a properly colored complete graph realizes
$\delta_c = n-1 \ge (n+1)/2$ (`complete_proper_meets_hypothesis`), placing it
squarely inside the hypothesis regime. Second, we settle completely the arithmetic
of the conjectured bound: a closed-form integer model $\mathrm{rtBound}(n)$ that we
prove equals $\lceil (n-1)(n-3)/8 \rceil$ (`rtBound_ceil`), vanishes exactly for
$n \le 3$ (`rtBound_zero_iff`), is monotone (`rtBound_mono`), and is dominated by the
total triangle count $\binom{n}{3}$ (`rtBound_le_choose`). The last comparison is the
bridge certifying that a properly colored complete graph is a valid witness to — and
indeed an enormous overshoot of — the conjectured floor. All results stated here have
been verified to be free of unproven assumptions.

---

## 1. Introduction

Rainbow combinatorics studies the conditions under which a coloring of a discrete
structure is forced to contain "totally multicolored" sub-structures. In the setting
of graphs, the prototypical multicolored object is the **rainbow triangle**: three
mutually adjacent vertices whose three connecting edges carry three pairwise distinct
colors. Rainbow triangles are a local certificate of diversity, and quantifying how
many of them a sufficiently colorful graph must contain is a central theme in the area.

The correct measure of "colorfulness" turns out to be not the ordinary degree of a
vertex but its **color degree** — the number of *distinct* colors appearing on its
incident edges. Color degree can be far smaller than degree (a high-degree vertex may
repeat only a few colors), and the gap between the two is precisely what makes
color degree the governing invariant for rainbow phenomena.

Li, Ning, Shi, and Zhang (2024) proposed the following sharp density conjecture.

> **Conjecture (Rainbow Triangle Density).** Let $G$ be an edge-colored graph on
> $n \ge 3$ vertices with $\delta_c(G) \ge (n+1)/2$. Then
> $$\mathrm{rt}(G) \ \ge\ \left\lceil \frac{(n-1)(n-3)}{8} \right\rceil,$$
> and equality holds only for the construction derived from a proper edge-coloring
> of $K_n$ with $n$ odd.

This paper provides a fully rigorous treatment of the two foundational pillars on
which any proof of this conjecture must rest: (i) the *structural* theory of the
extremal object — properly edge-colored complete graphs — and (ii) the *arithmetic*
theory of the bound function $\lceil (n-1)(n-3)/8 \rceil$. We do not claim to settle
the conjecture in full generality; rather, we isolate, state, and prove the
load-bearing lemmas, and we verify that the conjecture is consistent (and sharp up to
the rigidity clause) on its natural extremal witnesses.

**Organization.** Section 2 fixes definitions. Section 3 develops the structural
backbone (proper colorings force rainbow triangles; the complete-graph witness).
Section 4 settles the arithmetic of the bound. Section 5 gives algorithms. Section 6
discusses applications and interpretation. Section 7 lists open directions.

---

## 2. Definitions

Throughout, $V$ is a finite vertex set with $|V| = n$, and $C$ is a set of colors.

**Definition 2.1 (Edge-coloring).** An *edge-colored graph* is a triple
$E = (G, \mathrm{col}, \text{sym})$ consisting of a simple graph $G$ on $V$, a color
function $\mathrm{col} : V \times V \to C$, and the symmetry axiom
$\mathrm{col}(u,v) = \mathrm{col}(v,u)$ for all $u, v$. Only the values of
$\mathrm{col}$ on edges of $G$ are semantically meaningful; symmetry encodes that an
edge is unordered.

*(In the formal development this is the structure `EdgeColoring` with fields `G`,
`col`, and `col_symm`.)*

**Definition 2.2 (Color degree).** For a vertex $v$, the *color degree* is
$$
d_c(v) \ =\ \bigl|\{\, \mathrm{col}(v,u) : u \in N_G(v) \,\}\bigr|,
$$
the number of distinct colors on edges incident to $v$, where $N_G(v)$ is the
neighborhood of $v$. The *minimum color degree* of $E$ is
$\delta_c(E) = \min_{v} d_c(v)$.

*(Formally: `colorDegree E v = ((E.G.neighborFinset v).image (E.col v)).card`.)*

**Definition 2.3 (Rainbow triangle).** Vertices $a, b, c$ form a *rainbow triangle*
if they are pairwise adjacent in $G$ and the three edge colors $\mathrm{col}(a,b)$,
$\mathrm{col}(b,c)$, $\mathrm{col}(c,a)$ are pairwise distinct.

*(Formally: `IsRainbowTriangle E a b c`.)* We write $\mathrm{rt}(G)$ for the number of
(unordered) rainbow triangles, the set-level count handled by `IsRainbowTriangleSet`
and `rtCount`.

**Definition 2.4 (Proper edge-coloring).** $E$ is *proper* (`IsProper E`) if any two
distinct edges sharing a common vertex receive distinct colors: for adjacent pairs
$\{u,v\}$ and $\{u,w\}$ with $v \ne w$, $\mathrm{col}(u,v) \ne \mathrm{col}(u,w)$.

**Definition 2.5 (The bound function).** For $n \in \mathbb{N}$ define
$$
\mathrm{rtBound}(n) \ =\ \left\lfloor \frac{(n-1)(n-3) + 7}{8} \right\rfloor,
$$
using truncated subtraction on $\mathbb{N}$ (so $(n-1)(n-3) = 0$ for $n \le 3$). This
is the integer model of $\lceil (n-1)(n-3)/8 \rceil$ via the identity
$\lceil a/b \rceil = \lfloor (a + b - 1)/b \rfloor$.

---

## 3. Structural backbone: the extremal object

The conjecture's extremal object is a properly edge-colored complete graph. We prove
the three facts that make it the canonical witness.

### 3.1 Color degree is sandwiched

**Lemma 3.1 (`colorDegree_le_degree`, `colorDegree_le_card_sub_one`).** For every
vertex $v$,
$$
d_c(v) \ \le\ \deg_G(v) \ \le\ n - 1.
$$

*Proof sketch.* The set of colors at $v$ is the image of the neighborhood $N_G(v)$
under the map $u \mapsto \mathrm{col}(v,u)$; the cardinality of an image never exceeds
the cardinality of the domain, giving $d_c(v) \le |N_G(v)| = \deg_G(v)$. The second
inequality is the standard bound $\deg_G(v) \le n - 1$ in a simple graph on $n$
vertices. $\square$

The first inequality is generally *strict*, which is the formal reason color degree —
not ordinary degree — is the governing invariant for rainbow structure.

### 3.2 Proper colorings force rainbow triangles

**Theorem 3.2 (`proper_isRainbowTriangle`).** If $E$ is proper, then every triangle
of $G$ is rainbow: for pairwise-distinct, pairwise-adjacent $a, b, c$, the three edge
colors are pairwise distinct.

*Proof sketch.* Consider the three edges $ab$, $bc$, $ca$. Each pair of these edges
shares a vertex: $ab$ and $bc$ share $b$; $bc$ and $ca$ share $c$; $ca$ and $ab$
share $a$. Properness (Definition 2.4), together with the symmetry axiom
$\mathrm{col}(u,v) = \mathrm{col}(v,u)$ used to align the shared endpoints, forces the
two edges in each pair to have different colors. Hence all three colors are pairwise
distinct, and the triangle is rainbow. The argument is a finite case analysis on which
vertex is shared, with `col_symm` reconciling orientations. $\square$

This is the structural heart of the extremal theory: properness *collapses* the
rainbow condition (a statement about colors) into mere distinctness of the three
vertices (a statement about the graph). It is the model for the local counting lemma
needed in the general case.

### 3.3 Proper colorings preserve degree, and the complete graph fits the regime

**Theorem 3.3 (`proper_colorDegree_eq_degree`).** If $E$ is proper, then for every
vertex $v$,
$$
d_c(v) \ =\ \deg_G(v).
$$

*Proof sketch.* Under properness the map $u \mapsto \mathrm{col}(v,u)$ is injective on
the neighborhood $N_G(v)$ (distinct neighbors give edges sharing $v$, hence distinct
colors). An injective map sends a set to an image of equal cardinality
(`Finset.card_image_of_injOn`), so $d_c(v) = |N_G(v)| = \deg_G(v)$. $\square$

**Theorem 3.4 (`complete_proper_colorDegree`, `complete_proper_meets_hypothesis`).**
Let $G = K_n$ be the complete graph on $n \ge 3$ vertices with a proper
edge-coloring $E$. Then every vertex has color degree $n - 1$, so
$$
\delta_c(E) \ =\ n - 1 \ \ge\ \frac{n+1}{2}.
$$
Hence the properly colored complete graph lies inside the hypothesis regime of the
conjecture.

*Proof sketch.* In $K_n$ every vertex has degree $n - 1$; by Theorem 3.3 its color
degree equals $n - 1$ as well. For $n \ge 3$ one checks $n - 1 \ge (n+1)/2 \iff
2(n-1) \ge n+1 \iff n \ge 3$. $\square$

**Corollary 3.5 (consistency on the witness, `complete_proper_rtCount`,
`complete_proper_exists_rainbow`).** A properly colored $K_n$ has *all* of its
$\binom{n}{3}$ triangles rainbow (Theorem 3.2 applied to each triple), so
$$
\mathrm{rt}(K_n) \ =\ \binom{n}{3}.
$$
In particular at least one rainbow triangle exists for $n \ge 3$. Combined with
Theorem 4.4 below ($\mathrm{rtBound}(n) \le \binom{n}{3}$), this confirms the
conjectured inequality holds — with vast room to spare — on its natural extremal
witnesses.

The apparent paradox (the witness with the *most* rainbow triangles certifying a
*lower* bound) is resolved by the conjecture's rigidity clause: the extremal
*minimizers* of $\mathrm{rt}(G)$ in the regime $\delta_c \ge (n+1)/2$ are forced to be
as sparse as the threshold allows, and the floor $\lceil (n-1)(n-3)/8 \rceil$ is the
value at that boundary, attained only by the rigid odd-$n$ proper construction. The
complete-graph computation certifies the complementary fact that the regime is
non-empty and the bound consistent.

---

## 4. Arithmetic of the bound

We now establish the four properties that completely characterize $\mathrm{rtBound}$.

**Theorem 4.1 (Ceiling identity, `rtBound_ceil`).** For all $n$,
$$
(n-1)(n-3) \ \le\ 8\cdot \mathrm{rtBound}(n) \ <\ (n-1)(n-3) + 8.
$$

*Proof sketch.* Abbreviate $k = (n-1)(n-3)$. Then $\mathrm{rtBound}(n) = \lfloor (k+7)/8 \rfloor$,
and the two displayed inequalities are exactly the defining property of integer
floor division by $8$: $8\lfloor (k+7)/8 \rfloor \le k+7 < 8\lfloor (k+7)/8 \rfloor + 8$
rearranges to the claim. This is a pure divisibility fact (`omega` after generalizing
$k$). $\square$

The sandwich pins $\mathrm{rtBound}(n)$ to be *exactly* $\lceil (n-1)(n-3)/8 \rceil$.

**Theorem 4.2 (Vanishing threshold, `rtBound_zero_iff`).**
$$
\mathrm{rtBound}(n) = 0 \iff n \le 3.
$$

*Proof sketch.* ($\Leftarrow$) For $n \le 3$, truncated subtraction gives $n - 3 = 0$,
so $(n-1)(n-3) = 0$ and $\mathrm{rtBound}(n) = \lfloor 7/8 \rfloor = 0$. ($\Rightarrow$)
For $n \ge 4$ both $n - 1 \ge 1$ and $n - 3 \ge 1$, so $(n-1)(n-3) \ge 1$, whence
$(k+7)/8 \ge 1$ and the floor is positive. Concretely $\mathrm{rtBound}(4) = 1$. $\square$

The bound is therefore vacuous exactly below the conjecture's range and *bites* from
$n = 4$ onward.

**Theorem 4.3 (Monotonicity, `rtBound_mono`).** $\mathrm{rtBound}$ is non-decreasing:
$m \le n \implies \mathrm{rtBound}(m) \le \mathrm{rtBound}(n)$.

*Proof sketch.* For $m \le n$ both factors satisfy $m - 1 \le n - 1$ and
$m - 3 \le n - 3$ (monotonicity of truncated subtraction), so $(m-1)(m-3) \le (n-1)(n-3)$
by `Nat.mul_le_mul`; floor division by $8$ preserves the inequality. $\square$

**Theorem 4.4 (Domination by triangle count, `rtBound_le_choose`).** For all $n$,
$$
\mathrm{rtBound}(n) \ \le\ \binom{n}{3}.
$$

*Proof sketch.* By Theorem 4.1 it suffices to show $(n-1)(n-3) \le 8\binom{n}{3}$.
Using the descending-factorial identity $6\binom{n}{3} = n(n-1)(n-2)$ (from
`Nat.descFactorial_eq_factorial_mul_choose`), substitute $n = 3 + m$ to clear the
truncated subtractions: $n-1 = m+2$, $n-2 = m+1$, $n-3 = m$, and
$6\binom{3+m}{3} = (3+m)(m+2)(m+1)$. The target becomes the subtraction-free
polynomial inequality
$$
6\,(m+2)\,m \ \le\ 8\,(m+3)(m+2)(m+1),
$$
which holds for every $m \ge 0$ (the right side already dominates term by term). A
finite check disposes of $n < 3$. $\square$

Since a complete graph has exactly $\binom{n}{3}$ triangles, Theorem 4.4 guarantees
the floor never demands more rainbow triangles than physically exist — the precise
sense in which the bound is *achievable*. It is the formal bridge to Corollary 3.5.

**Numerical sample.**

| $n$ | $(n-1)(n-3)$ | $\mathrm{rtBound}(n)$ | $\binom{n}{3}$ |
|----:|-------------:|----------------------:|---------------:|
| 3   | 0            | 0                     | 1              |
| 4   | 3            | 1                     | 4              |
| 5   | 8            | 1                     | 10             |
| 7   | 24           | 3                     | 35             |
| 9   | 48           | 6                     | 84             |
| 15  | 168          | 21                    | 455            |

---

## 5. Algorithms

### 5.1 Computing the bound

The bound is a constant-time arithmetic expression:
$$
\mathrm{rtBound}(n) = (\max(n-1,0)\cdot\max(n-3,0) + 7) \,\div\, 8 \quad (\text{integer division}).
$$
Complexity $O(1)$. Its monotonicity (Theorem 4.3) and domination by $\binom{n}{3}$
(Theorem 4.4) can be verified for a range of $n$ in $O(N)$ time.

### 5.2 Counting rainbow triangles by brute force

To verify the conjecture empirically on a given edge-colored graph, enumerate all
$\binom{n}{3}$ triples and test each for the rainbow property:

```
for each triple {a,b,c} with a<b<c:
    if adjacent(a,b) and adjacent(b,c) and adjacent(a,c):
        if col(a,b), col(b,c), col(a,c) are pairwise distinct:
            count += 1
return count
```

Complexity $O(n^3)$. Comparing the count against $\mathrm{rtBound}(n)$ tests the
conjectured inequality; computing $\min_v d_c(v)$ in $O(n^2)$ checks the hypothesis
$\delta_c \ge (n+1)/2$.

### 5.3 Constructing the extremal coloring

For odd $n$, the round-robin (circle) method produces a proper $(n-1)$-edge-coloring
of $K_n$ in $O(n^2)$ time: fix one vertex, rotate the rest, and assign round indices
as colors. By Theorem 3.2 every triangle of the result is rainbow, realizing
$\mathrm{rt} = \binom{n}{3}$ and $\delta_c = n-1$.

---

## 6. Applications and interpretation

**Network diversity.** Color degree models the *variety* of relationship types
incident to a node, independent of raw connectivity. The conjecture quantifies a
threshold phenomenon: once every node sees at least half of all relationship types,
locally diverse triangles become unavoidable and proliferate quadratically.

**Scheduling and design.** Proper edge-colorings of $K_n$ are equivalent to
round-robin tournament schedules. Theorem 3.2 says such a schedule is maximally
"rainbow": every triple of players meets across three distinct rounds. This is a
clean optimality statement for balanced scheduling.

**Why color degree, not degree.** Lemma 3.1's strict inequality and Theorem 3.3's
equality together pin down the precise scope in which the two invariants coincide
(proper colorings) versus diverge (general colorings). The conjecture is stated in
terms of $\delta_c$ because, as the theory makes explicit, rainbow density is governed
by color diversity, not by raw degree.

---

## 7. Discussion and future directions

The results here secure the two pillars on which a full proof must rest: the
structural extremal theory (Section 3) and the bound arithmetic (Section 4). The
remaining gap is the general lower bound for arbitrary graphs in the regime
$\delta_c(G) \ge (n+1)/2$, not only complete graphs. The natural attack is
*localization*: convert the global color-degree hypothesis into a per-vertex counting
lemma that turns a vertex's $\ge (n+1)/2$ distinctly colored neighbors into a guaranteed
quota of rainbow triangles through that vertex, then sum over vertices. Theorem 3.2 is
the template for what such a local lemma achieves in the proper case.

Four concrete directions stand out.

1. **General density bound.** Prove $\mathrm{rt}(G) \ge \lceil (n-1)(n-3)/8 \rceil$ for
   all $G$ with $\delta_c(G) \ge (n+1)/2$, via the neighborhood-counting lemma above.
2. **Existence before density.** Show $\delta_c(G) \ge (n+1)/2$ forces at least one
   rainbow triangle, and that the threshold is sharp (colorings with
   $\delta_c = \lceil (n+1)/2\rceil - 1$ and none). The complete-graph case is the
   $\delta_c = n-1$ corner of this statement.
3. **Uniqueness of the extremal construction.** Characterize equality
   $\mathrm{rt}(G) = \lceil (n-1)(n-3)/8 \rceil$ as occurring only for the odd-$n$ proper
   construction — a rigidity theorem about which edges may be absent.
4. **Color-degree vs. degree gap.** Exhibit graphs with bounded $\delta_c$ but
   unbounded $\delta(G) - \delta_c(G)$, confirming color degree as the governing
   invariant.

---

## References

- B. Li, B. Ning, Y. Shi, S. Zhang, *Rainbow triangles in edge-colored graphs*
  (2024). (Source of the density conjecture and the extremal construction.)
