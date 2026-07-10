# The Chromatic Polynomial of the Friendship Graph: A Bijective Count of Emotional Assignments

## Abstract

We give a complete, closed-form determination of the chromatic counting function
of the friendship (windmill) graph $F_n$ — the graph consisting of $n$ triangles
sharing a single common vertex. We prove that the number of proper $q$-colorings
of $F_n$ is
$$P(F_n, q) = q \cdot \big((q-1)(q-2)\big)^n,$$
via an explicit structural bijection between proper colorings and the data of a
center color together with, for each triangle, an ordered admissible pair of
outer colors. Specializing to the six *basic emotions* of psychology yields
$P(F_n, 6) = 6 \cdot 20^n$, resolving the "graph coloring with emotions"
conjecture. We deduce that the chromatic number of $F_n$ is exactly $3$ for
$n \ge 1$, that two colors never suffice while three (and, a fortiori, six)
always do, and that the counting function detects colorability. Finally, we
connect the quantitative formula to a qualitative invariant — the *emotional
chromatic number*, the least admissible palette of size at least three — showing
it equals $3$ for every $n$, lies within the window $[3, 6]$, and coincides with
the ordinary chromatic number for nonempty networks, where the number of minimal
emotional configurations is $P(F_n, 3) = 3 \cdot 2^n$.

## 1. Introduction

Graph coloring is the study of assigning labels ("colors") to the vertices of a
graph so that no two adjacent vertices receive the same label. When the labels
are interpreted as *emotions* and the edges as *friendships*, a proper coloring
becomes an assignment of moods to people in which no two friends ever feel the
same thing. The number of such assignments, given a palette of $q$ colors, is
the value $P(G, q)$ of the **chromatic polynomial** of the underlying graph $G$.

For general graphs the chromatic polynomial is computationally intractable, but
for highly structured families it admits clean closed forms. This paper treats
one such family: the **friendship graph** (equivalently the **windmill** or
**Dutch windmill** graph) $F_n$, formed by gluing $n$ triangles at a single
shared vertex. Its high symmetry and its "hub-and-spokes" structure make it an
ideal testbed for the decomposition philosophy of chromatic enumeration.

Our contributions are:

1. A closed-form evaluation $P(F_n, q) = q \cdot ((q-1)(q-2))^n$, proved by an
   explicit bijection rather than by recurrence (Section 4).
2. The specialization to six emotions, $P(F_n, 6) = 6 \cdot 20^n$ (Section 5).
3. A complete colorability analysis: chromatic number $3$ for $n \ge 1$,
   two colors insufficient, three sufficient (Section 5).
4. A bridge to the *emotional chromatic number* invariant, pinning it at $3$
   inside the six-emotion window and relating it to the ordinary chromatic
   number (Section 6).

## 2. Definitions

Throughout, a **graph** $G = (V, E)$ is simple (no loops, no multiple edges) and
undirected. Two vertices joined by an edge are **adjacent**. We write
$x \sim y$ for adjacency.

**Definition 2.1 (Proper coloring).** For a positive integer $q$, a *proper
$q$-coloring* of $G$ is a function $c : V \to \{1, \dots, q\}$ such that
$c(x) \ne c(y)$ whenever $x \sim y$.

**Definition 2.2 (Chromatic counting function).** The *chromatic counting
function* $P(G, q)$ is the number of proper $q$-colorings of $G$. For finite $G$
this is a polynomial in $q$, the *chromatic polynomial*.

**Definition 2.3 (Chromatic number).** The *chromatic number* $\chi(G)$ is the
least $q$ for which a proper $q$-coloring exists; equivalently, the least $q$
with $P(G, q) > 0$.

**Definition 2.4 (Friendship graph $F_n$).** Fix $n \ge 0$. The vertex set of
$F_n$ is
$$V_n = \{ \star \} \cup \{ (i, 0), (i, 1) : i \in \{1, \dots, n\} \},$$
where $\star$ is the **center** and, for each $i$, the pair $(i, 0), (i, 1)$ are
the two **outer** vertices of *triangle $i$*. The adjacency is:

- $\star \sim (i, b)$ for every triangle $i$ and every $b \in \{0, 1\}$ (the
  center is a friend of everyone);
- $(i, 0) \sim (i, 1)$ for every triangle $i$ (the two outer members of a
  triangle are friends);
- no other pairs are adjacent.

Thus $F_n$ consists of $n$ triangles $\{\star, (i,0), (i,1)\}$ sharing the common
vertex $\star$. It has $2n + 1$ vertices and $3n$ edges. The degenerate case
$F_0$ is a single isolated vertex.

**Remark 2.5.** $F_n$ is the *windmill* graph $Wd(3, n)$. More generally,
$Wd(m, n)$ glues $n$ copies of the complete graph $K_m$ at a common vertex;
$F_n = Wd(3, n)$ is the triangular case.

## 3. Counting a single triangle

The engine of the main theorem is the count of admissible colorings of one
triangle once the center's color is fixed. We isolate it here.

**Lemma 3.1 (Fiber count).** Fix $q$ colors, a center color $z$, and one outer
color $a \ne z$. The number of colors $b$ with $b \ne z$ and $b \ne a$ is
exactly $q - 2$.

*Proof.* The colors to be excluded are precisely $z$ and $a$, which are distinct
because $a \ne z$. Removing two distinct elements from a set of size $q$ leaves
$q - 2$. $\qquad\blacksquare$

**Lemma 3.2 (Per-triangle count).** Fix $q$ colors and a center color $z$. The
number of ordered pairs $(a, b)$ of colors with $a \ne z$, $b \ne z$, and
$a \ne b$ is exactly $(q-1)(q-2)$.

*Proof.* Partition the set of admissible pairs by their first coordinate $a$.
The first coordinate ranges over the $q - 1$ colors different from $z$. For each
such $a$, Lemma 3.1 gives $q - 2$ choices for $b$. As the count $q - 2$ is
independent of the chosen $a$, summing over the $q - 1$ values of $a$ yields
$(q-1)(q-2)$. Formally, the admissible-pair set is in bijection with the
dependent sum $\sum_{a \ne z} \{ b : b \ne z, b \ne a \}$, whose cardinality is
$(q-1)\cdot(q-2)$. $\qquad\blacksquare$

## 4. The structural bijection and the closed form

The key structural fact is that a proper coloring of $F_n$ carries exactly the
same information as a center color plus one admissible outer pair per triangle.

**Theorem 4.1 (Coloring bijection).** For all $n$ and $q$, there is an explicit
bijection
$$\big\{ \text{proper } q\text{-colorings of } F_n \big\} \;\longleftrightarrow\;
\coprod_{z \in \{1,\dots,q\}} \; \prod_{i=1}^{n} \big\{ (a, b) : a \ne z,\; b \ne z,\; a \ne b \big\}.$$

*Proof.* Define the forward map $\Phi$ by sending a proper coloring $c$ to the
pair whose first component is the center color $c(\star)$ and whose second
component is the function $i \mapsto (c(i,0), c(i,1))$. Each recorded pair is
admissible: $c(i,0) \ne c(\star)$ and $c(i,1) \ne c(\star)$ because both outer
vertices are adjacent to the center, and $c(i,0) \ne c(i,1)$ because the two
outer vertices are adjacent to each other.

Define the inverse map $\Psi$ by sending $(z, (a_i, b_i)_{i})$ to the coloring
that paints $\star$ with $z$, paints $(i, 0)$ with $a_i$, and paints $(i, 1)$
with $b_i$. This is a proper coloring: the only adjacencies in $F_n$ are
center–outer and the two outer vertices within a common triangle, and the
admissibility conditions $a_i \ne z$, $b_i \ne z$, $a_i \ne b_i$ are exactly what
those adjacencies require. There are no cross-triangle edges to check.

The maps $\Phi$ and $\Psi$ are mutually inverse: $\Psi$ reconstructs a coloring
from the values it reads off, and $\Phi$ reads back exactly the components fed
into $\Psi$. Hence $\Phi$ is a bijection. $\qquad\blacksquare$

**Theorem 4.2 (Chromatic polynomial of the friendship graph).** For all $n \ge 0$
and all $q$,
$$P(F_n, q) = q \cdot \big((q-1)(q-2)\big)^n.$$

*Proof.* By Theorem 4.1, $P(F_n, q)$ equals the cardinality of the disjoint
union on the right-hand side. That cardinality is a sum over the $q$ choices of
center color $z$; for each fixed $z$, the product over the $n$ triangles of the
per-triangle admissible-pair sets has cardinality $\big((q-1)(q-2)\big)^n$ by
Lemma 3.2 (the per-triangle count is independent of $z$). Summing the constant
$\big((q-1)(q-2)\big)^n$ over the $q$ values of $z$ gives
$q \cdot \big((q-1)(q-2)\big)^n$. $\qquad\blacksquare$

**Remark 4.3.** The bijective proof is more informative than the deletion–
contraction recurrence: it exhibits *which* colorings are being counted, and it
generalizes verbatim to windmills built from larger cliques (Section 7).

## 5. Emotions, colorability, and the chromatic number

**Corollary 5.1 (Six basic emotions).** With the palette of six basic emotions,
$$P(F_n, 6) = 6 \cdot 20^n.$$

*Proof.* Set $q = 6$ in Theorem 4.2: $(6-1)(6-2) = 5 \cdot 4 = 20$. $\qquad\blacksquare$

This resolves the original "graph coloring with emotions" conjecture: the number
of ways to assign six basic emotions to the members of a friendship network so
that no two friends coincide is $6 \cdot 20^n$.

**Corollary 5.2 (Colorability detection).** $F_n$ admits a proper $q$-coloring
if and only if $P(F_n, q) > 0$.

*Proof.* Immediate from the definition of the counting function: a positive count
means at least one coloring exists, and conversely. $\qquad\blacksquare$

**Corollary 5.3 (Three emotions suffice).** For every $n$ and every $q \ge 3$,
$P(F_n, q) > 0$; in particular $P(F_n, 3) = 3 \cdot 2^n > 0$ and
$P(F_n, 6) = 6 \cdot 20^n > 0$.

*Proof.* For $q \ge 3$ each factor $q$, $q-1$, $q-2$ is positive, hence so is the
product in Theorem 4.2. $\qquad\blacksquare$

**Corollary 5.4 (Two emotions never suffice).** For $n \ge 1$,
$P(F_n, 2) = 0$; no proper $2$-coloring exists.

*Proof.* Set $q = 2$ in Theorem 4.2: the factor $(q-2) = 0$, so the product
vanishes for $n \ge 1$. Structurally, each triangle is a clique on three
vertices, which cannot be properly $2$-colored. $\qquad\blacksquare$

**Theorem 5.5 (Chromatic number).** For $n \ge 1$, $\chi(F_n) = 3$.

*Proof.* By Corollary 5.4, no coloring exists with $q \le 2$, so $\chi(F_n) \ge
3$. By Corollary 5.3, a proper $3$-coloring exists, so $\chi(F_n) \le 3$. Hence
$\chi(F_n) = 3$. $\qquad\blacksquare$

## 6. The emotional chromatic number

We now connect the closed form to a qualitative invariant motivated by the
emotions interpretation. A psychologically meaningful palette should offer at
least three emotions (enough to resolve any single conflict) and, in the basic
model, at most six. This suggests restricting attention to palettes of size at
least three.

**Definition 6.1 (Emotional chromatic number).** The *emotional chromatic
number* of a graph $G$ is the least integer $k \ge 3$ such that $G$ admits a
proper $k$-coloring. (The floor of $3$ encodes the modeling assumption that a
usable emotional palette must contain at least three options.)

**Theorem 6.2 (Emotional number of the friendship graph).** For every $n$, the
emotional chromatic number of $F_n$ equals $3$.

*Proof.* By Corollary 5.3, $F_n$ is properly $3$-colorable, so the least
admissible $k \ge 3$ is $k = 3$ itself. $\qquad\blacksquare$

**Corollary 6.3 (Six-emotion window).** For every $n$, the emotional chromatic
number of $F_n$ satisfies $3 \le k \le 6$.

*Proof.* By Theorem 6.2 the value is exactly $3$, which lies in $[3, 6]$.
$\qquad\blacksquare$

**Corollary 6.4 (Count at the emotional floor).** The number of proper colorings
of $F_n$ using exactly the emotional-chromatic-number palette is
$$P\big(F_n, 3\big) = 3 \cdot 2^n.$$

*Proof.* Substitute the value $3$ from Theorem 6.2 into Theorem 4.2:
$3 \cdot ((3-1)(3-2))^n = 3 \cdot (2 \cdot 1)^n = 3 \cdot 2^n$. $\qquad\blacksquare$

**Theorem 6.5 (Agreement with the chromatic number).** For $n \ge 1$, the
emotional chromatic number of $F_n$ equals its ordinary chromatic number; both
are $3$.

*Proof.* Theorem 6.2 gives emotional chromatic number $3$; Theorem 5.5 gives
$\chi(F_n) = 3$. For $n \ge 1$ they coincide. (For $n = 0$ they differ: the lone
center has $\chi(F_0) = 1$, while the emotional floor keeps the emotional
chromatic number at $3$, so the nonemptiness hypothesis is genuinely needed.)
$\qquad\blacksquare$

## 7. Generalizations

The bijective argument of Section 4 depends only on two features of $F_n$: the
triangles are pairwise vertex-disjoint apart from the shared center, and each
triangle is a clique. Both persist when triangles are replaced by larger cliques.

**Generalized windmill $Wd(m, n)$.** Glue $n$ copies of the complete graph $K_m$
at a single common vertex. The same decomposition — center color, then an
independent admissible tuple per clique — yields
$$P\big(Wd(m, n), q\big) = q \cdot \big((q-1)(q-2)\cdots(q-m+1)\big)^n
= q \cdot \big((q-1)^{\underline{\,m-1\,}}\big)^n,$$
where $(q-1)^{\underline{\,m-1\,}}$ denotes the falling factorial
$(q-1)(q-2)\cdots(q-m+1)$, the number of ways to properly color the $m-1$
non-center vertices of one clique given the center. The friendship graph is the
case $m = 3$. The chromatic number of $Wd(m, n)$ for $n \ge 1$ is $m$.

The same "shared-hub decouples the spokes" principle applies to book graphs,
fan graphs, and gear graphs, each yielding a product-form chromatic polynomial.

## 8. Applications and discussion

Chromatic polynomials are not merely combinatorial curiosities. The value
$P(G, q)$ is, up to normalization, the zero-temperature partition function of the
$q$-state antiferromagnetic Potts model on $G$, so closed forms translate
directly into exact free-energy computations for windmill-shaped interaction
networks. In computer science, vertex coloring models register allocation
(colors are CPU registers, edges are simultaneously-live variables) and
scheduling (colors are time slots, edges are conflicts); the count $P(G, q)$
measures the number of conflict-free schedules and its positivity certifies
feasibility. In wireless communication, coloring models interference-free
frequency assignment.

The friendship graph, while stylized, captures the ubiquitous "hub-and-spokes"
motif — a coordinator interacting with many otherwise-independent pairs or
groups. The closed form quantifies exactly how a single shared constraint (the
hub) multiplies through independent local constraints (the spokes). The emotions
framing renders the mathematics vivid without altering its content: it is a faithful
retelling of proper coloring, chromatic polynomials, and chromatic numbers.

## 9. Future directions

- **Generalized windmills $Wd(m, n)$.** Establish the falling-factorial formula
  $P = q \cdot \big((q-1)^{\underline{m-1}}\big)^n$ in full generality, with the
  friendship graph as the $m = 3$ instance.
- **Book, fan, and gear graphs.** Other single-common-vertex gluings with clean
  product forms.
- **Deletion–contraction cross-check.** Rederive the closed form from the
  deletion–contraction recurrence by deleting and contracting one triangle edge,
  and prove the two derivations agree, tightening the bridge between the
  bijective and algebraic viewpoints.
- **Polynomiality and roots.** Lift the counting function to a genuine integer
  polynomial and show its integer roots are exactly $\{0, 1, 2\}$, matching the
  emotional floor of $3$.
- **Coefficient combinatorics.** Expand $q \cdot ((q-1)(q-2))^n$ and connect its
  alternating-sign coefficients to the broken-circuit interpretation for this
  graph family.

## 10. Conclusion

We have determined the chromatic polynomial of the friendship graph in closed
form, $P(F_n, q) = q \cdot ((q-1)(q-2))^n$, by an explicit and transparent
bijection. The formula immediately yields the six-emotion count $6 \cdot 20^n$,
the chromatic number $3$, the impossibility of two-coloring, and a clean account
of the emotional chromatic number, which sits at the floor of the six-emotion
window for every friendship network. The method — decompose a graph at a shared
hub and multiply the independent local counts — is a small but sharp instance of
a broadly useful enumeration principle.
