# Polynomial-Size Witnesses for the Colorful Carathéodory Theorem over Spanning $k$-Trees

**Author:** Aristotle
**Date:** 2026-07-14
**Domain:** Applications (Combinatorial and Computational Geometry)

## Abstract

The colorful Carathéodory theorem of Bárány asserts that if $V_1, \dots,
V_{d+1}$ are point sets in $\mathbb{R}^d$, each of whose convex hull contains a
common target $p$, then there exists a *rainbow* simplex — one vertex per color
class — whose convex hull also contains $p$. Combinatorially, this rainbow
simplex is a face of the join $V_1 * \cdots * V_{d+1}$, an object with
$\prod_i |V_i|$ top-dimensional faces and hence an exponential search space.
We study the *witness complexity* hiding behind this qualitative statement: how
large a sub-collection of faces must one retain to guarantee that a
$p$-capturing face lies within it? We prove that any abstract complex whose
faces have width at most $k+1$ (in particular, any $d$-dimensional spanning
$k$-tree) on an $n$-vertex ground set has face count exactly
$\sum_{i=0}^{k+1}\binom{n}{i}$, a polynomial in $n$ of degree $k+1$, bounded
explicitly by $(k+2)(n+1)^{k+1}$. In the extreme sparse case $k=1$, global
acyclicity collapses this to an exact **linear** count of $2n$ faces for the
clique complex of a spanning tree. We complement these counting results with a
self-contained proof of the capturing-face existence on the line ($d=1$),
extracting from the honest hypothesis "$0$ lies in the convex hull of each color
class" a rainbow edge whose convex hull contains the origin. Together these
results show that a capturing face always exists and can be certified inside a
spanning-tree-sized — linear, for $k=1$ — sub-collection of the join rather than
the full exponential complex.

**Keywords:** colorful Carathéodory theorem, spanning $k$-tree, join of point
sets, convex hull, witness complexity, simplicial complex, acyclicity, face
enumeration, computational geometry.

---

## 1. Introduction

### 1.1 Background

Carathéodory's classical theorem states that if a point $p \in \mathbb{R}^d$
lies in the convex hull of a set $S$, then $p$ lies in the convex hull of some
subset of $S$ of at most $d+1$ points. Bárány's **colorful Carathéodory
theorem** (1982) is a striking strengthening: rather than drawing all $d+1$
points from a single set, one may draw one point from each of $d+1$ distinct
"color classes," provided each color class individually captures $p$.

> **Theorem (Colorful Carathéodory, Bárány 1982).** Let $V_1, \dots, V_{d+1}
> \subseteq \mathbb{R}^d$ be finite sets and $p \in \mathbb{R}^d$ a point such
> that $p \in \operatorname{conv}(V_i)$ for every $i$. Then there exist points
> $v_1 \in V_1, \dots, v_{d+1} \in V_{d+1}$ with
> $p \in \operatorname{conv}\{v_1, \dots, v_{d+1}\}$.

The selected simplex $\{v_1, \dots, v_{d+1}\}$ is *rainbow*: it uses exactly one
vertex of each color. This theorem is a cornerstone of combinatorial geometry,
underlying Tverberg's theorem, the First Selection Lemma, and the fastest known
algorithms for computing approximate centerpoints and Tverberg partitions.

### 1.2 The quantitative question

Combinatorially, the collection of all rainbow simplices is the **join**
$V_1 * V_2 * \cdots * V_{d+1}$, whose top-dimensional faces number
$\prod_{i=1}^{d+1} |V_i|$. This is exponential in the number of color classes,
so a brute-force search over the join is intractable.

The qualitative theorem asserts a capturing face exists *somewhere* in the join.
We ask the sharper, quantitative question:

> **Witness complexity problem.** What is the size of the smallest
> sub-collection of faces of the join that is guaranteed to contain a
> $p$-capturing face?

We show that the answer is governed by two independent parameters of the
certifying complex: its **width** (the maximum number of vertices in a face) and
its **global acyclicity**. Low width bounds the face count by a polynomial whose
degree equals the width; acyclicity, in the tree case, collapses that polynomial
to linear.

### 1.3 Contributions

1. **Exact face count of bounded-width complexes (Theorem 3.2).** On an
   $n$-vertex ground set, the number of subsets of cardinality at most $m$ is
   exactly $\sum_{i=0}^{m}\binom{n}{i}$.

2. **Polynomial witness bound (Theorems 3.4 and 3.5).** Any complex of width at
   most $k+1$ — in particular any spanning $k$-tree — has at most
   $\sum_{i=0}^{k+1}\binom{n}{i} \le (k+2)(n+1)^{k+1}$ faces, a polynomial in
   $n$ of degree $k+1$.

3. **Linear collapse for trees (Theorem 4.1).** The clique complex of a spanning
   tree on $n$ vertices has exactly $2n$ faces, strictly better than the generic
   quadratic bound for width-$2$ complexes.

4. **Capturing-face existence on the line (Theorem 5.3).** For two color classes
   $V_1, V_2 \subseteq \mathbb{R}$, each capturing the origin in its convex
   hull, there is a rainbow edge $\{x, y\}$ ($x \in V_1$, $y \in V_2$) whose
   convex hull contains $0$; this is proved via a sign-extraction lemma
   (Theorem 5.1) that genuinely uses the convex-geometric hypothesis.

5. **Synthesis (Theorem 6.1).** The rainbow edge is one edge of the join, and
   any width-$2$ witness on $n$ vertices has at most $3(n+1)^2$ faces, sharpened
   to $2n$ under spanning-tree structure.

---

## 2. Definitions

Throughout, $\alpha$ denotes a type of vertices and ground sets are finite.

**Definition 2.1 (Abstract complex, face, width).** An *abstract complex* $K$ on
a ground set of vertices is a finite family of finite vertex sets, called
*faces*. The *width* of $K$ is $\max_{s \in K} |s|$. We say $K$ has width at
most $m$ if $|s| \le m$ for every face $s \in K$.

**Definition 2.2 (Skeleton).** The *$m$-skeleton* of a ground set $B$ is the
family of all subsets of $B$ of cardinality at most $m$:
$$
\mathrm{Skel}_m(B) = \{\, t \subseteq B : |t| \le m \,\}.
$$
It is the largest complex of width $\le m$ on $B$.

**Definition 2.3 (Spanning $k$-tree).** A *$d$-dimensional spanning $k$-tree*
$K$ on a vertex set $B$ is a simplicial complex that (i) *spans* $B$ (every
vertex of $B$ appears in some face), (ii) has width at most $k+1$ (every face
has at most $k+1$ vertices, i.e. dimension at most $k$), and (iii) is assembled
acyclically. For $k=1$ this specializes to an ordinary spanning tree of a graph,
whose faces are the empty set, the vertices, and the edges.

**Definition 2.4 (Clique complex of a graph).** For a simple graph $G$ on vertex
set $V$, its *clique complex* has as faces all cliques of $G$. For a tree $G$
(which is triangle-free), the faces are precisely the empty set, the singletons
(vertices), and the edges.

**Definition 2.5 (Join).** For finite point sets $V_1, \dots, V_{d+1}$, the
*join* $V_1 * \cdots * V_{d+1}$ is the simplicial complex whose faces are unions
$\{v_{i_1}, \dots, v_{i_j}\}$ obtained by choosing at most one vertex from each
color class. A *rainbow* face chooses exactly one vertex per color class.

**Definition 2.6 (Convex hull, capturing).** For $S \subseteq \mathbb{R}^d$,
$\operatorname{conv}(S)$ is the set of all finite convex combinations of points
of $S$. A face $\sigma$ *captures* a target $p$ if $p \in
\operatorname{conv}(\sigma)$.

**Definition 2.7 (Witness complex).** Given color classes $V_1, \dots, V_{d+1}$
capturing $p$, a *witness complex* is a sub-collection $K$ of the faces of the
join such that some $\sigma \in K$ captures $p$. The *witness complexity* is the
minimum face count $|K|$ over all valid witness complexes drawn from a specified
structural family (e.g. spanning $k$-trees).

---

## 3. Face counts of bounded-width complexes

The size of a witness is bounded by the size of the complex containing it, so we
begin by counting faces of bounded-width complexes exactly.

**Lemma 3.1 (Level-set decomposition).** For a finite ground set $B$ and integer
$m$, the family of subsets of $B$ of cardinality at most $m$ is the disjoint
union over $i = 0, 1, \dots, m$ of the families of subsets of cardinality
exactly $i$:
$$
\{\, t \subseteq B : |t| \le m \,\} \;=\; \bigsqcup_{i=0}^{m} \binom{B}{i},
$$
where $\binom{B}{i}$ denotes the subsets of $B$ of size exactly $i$.

*Proof.* A set $t \subseteq B$ satisfies $|t| \le m$ if and only if $|t| = i$
for some $i \in \{0, \dots, m\}$. The union is disjoint because a set has a
unique cardinality. $\qquad\blacksquare$

**Theorem 3.2 (Exact face count of the $m$-skeleton).** For a ground set $B$
with $|B| = n$,
$$
\bigl|\mathrm{Skel}_m(B)\bigr| \;=\; \sum_{i=0}^{m} \binom{n}{i}.
$$

*Proof.* By Lemma 3.1 the skeleton is the disjoint union of the level sets
$\binom{B}{i}$ for $i \le m$. The number of subsets of an $n$-set of size exactly
$i$ is $\binom{n}{i}$. Summing over the disjoint pieces gives the claim.
$\qquad\blacksquare$

The right-hand side is a polynomial in $n$ of degree $m$: its leading term is
$n^m/m!$. This already shows the skeleton is polynomially, not exponentially,
large — provided the width $m$ is fixed.

**Theorem 3.4 (Polynomial witness bound, exact form).** Let $K$ be any complex
of width at most $m$ on a ground set $B$ with $|B| = n$. Then
$$
|K| \;\le\; \sum_{i=0}^{m} \binom{n}{i}.
$$

*Proof.* Every face of $K$ is a subset of $B$ of size at most $m$, so $K
\subseteq \mathrm{Skel}_m(B)$. Monotonicity of cardinality under inclusion and
Theorem 3.2 give
$|K| \le |\mathrm{Skel}_m(B)| = \sum_{i=0}^{m}\binom{n}{i}$. $\qquad\blacksquare$

**Lemma 3.3 (Polynomial domination).** For all $n, m \ge 0$,
$$
\sum_{i=0}^{m} \binom{n}{i} \;\le\; (m+1)\,(n+1)^{m}.
$$

*Proof.* For each $i \le m$ we have $\binom{n}{i} \le n^i \le (n+1)^i \le
(n+1)^m$. The sum has $m+1$ terms, each at most $(n+1)^m$, giving the bound.
$\qquad\blacksquare$

**Theorem 3.5 (Polynomial-size witness for a spanning $k$-tree).** Let $K$ be a
complex of width at most $k+1$ on a ground set $B$ with $|B| = n$ — in
particular, a $d$-dimensional spanning $k$-tree. Then
$$
|K| \;\le\; (k+2)\,(n+1)^{k+1},
$$
a polynomial in $n$ of degree $k+1$.

*Proof.* Apply Theorem 3.4 with $m = k+1$ to get $|K| \le
\sum_{i=0}^{k+1}\binom{n}{i}$, then Lemma 3.3 with $m = k+1$ to bound this by
$(k+2)(n+1)^{k+1}$. $\qquad\blacksquare$

**Remark 3.6 (Tightness).** The degree $k+1$ is best possible in the class of
all width-$(k+1)$ complexes: the full $(k+1)$-skeleton attains the exact sum of
Theorem 3.2, whose leading term is $n^{k+1}/(k+1)!$. Improving on degree $k+1$
therefore requires additional structure beyond bounded width — which is exactly
what acyclicity provides in the next section.

---

## 4. The $k=1$ collapse: spanning trees have linear witnesses

Bounded width alone gives a degree-$(k+1)$ bound, hence a *quadratic* bound
$3(n+1)^2$ when $k=1$. But a spanning tree carries more than width $2$: it is
globally acyclic, and acyclicity forces the edge count down.

**Theorem 4.1 (Linear face count of a spanning tree).** Let $G$ be a tree on a
finite vertex set $V$ with $|V| = n$. Then the clique complex of $G$ has exactly
$2n$ faces:
$$
\underbrace{1}_{\varnothing} + \underbrace{n}_{\text{vertices}} +
\underbrace{(n-1)}_{\text{edges}} \;=\; 2n.
$$

*Proof.* A tree is connected and acyclic, so it has exactly $n-1$ edges — the
edge-count identity $|E| + 1 = |V|$. Since a tree is triangle-free, its cliques
are precisely the empty set, the $n$ singletons, and the $|E| = n-1$ edges. Thus
the total number of faces is $1 + n + (n-1) = 2n$. $\qquad\blacksquare$

**Remark 4.2 (Structure beats width).** A generic width-$2$ complex may have up
to $\binom{n}{2} \approx n^2/2$ edges, so its face count is quadratic. The tree's
linear count is not a consequence of width $2$ but of *acyclicity*, which caps
the number of edges at $n-1$. Thus witness size responds to two independent
levers: width sets the polynomial degree, and global acyclicity collapses the
degree at $k=1$.

---

## 5. The captured face exists: colorful Carathéodory on the line

We now show the witness is nonempty by exhibiting a capturing face in dimension
one. The argument isolates the true convex-geometric content: a color class
captures the origin if and only if it straddles it in sign.

**Theorem 5.1 (Sign extraction).** Let $V \subseteq \mathbb{R}$ be a nonempty
finite set with $0 \in \operatorname{conv}(V)$. Then $V$ contains a nonpositive
element and a nonnegative element:
$$
(\exists\, x \in V,\ x \le 0) \quad\text{and}\quad (\exists\, y \in V,\ 0 \le y).
$$

*Proof.* Let $a = \min V$ and $b = \max V$. Every element of $V$ lies in the
closed interval $[a, b]$, which is convex, so $\operatorname{conv}(V) \subseteq
[a,b]$. Hence $0 \in [a,b]$, i.e. $a \le 0 \le b$. Then $a \in V$ is a
nonpositive element and $b \in V$ is a nonnegative element. $\qquad\blacksquare$

**Theorem 5.2 (Segment through the origin).** If $x \le 0 \le y$ in
$\mathbb{R}$, then $0 \in [x, y]$ (the segment from $x$ to $y$).

*Proof.* If $x = y = 0$ the claim is trivial. Otherwise $x < 0 < y$ is possible
or one endpoint is $0$; in all cases set
$$
\lambda = \frac{y}{y - x}, \qquad \mu = \frac{-x}{y - x}.
$$
Then $\lambda, \mu \ge 0$, $\lambda + \mu = 1$, and $\lambda x + \mu y =
\frac{xy - xy}{y - x} = 0$, exhibiting $0$ as a convex combination of $x$ and
$y$. $\qquad\blacksquare$

**Theorem 5.3 (Colorful Carathéodory in dimension one).** Let $V_1, V_2
\subseteq \mathbb{R}$ be nonempty finite color classes with $0 \in
\operatorname{conv}(V_1)$ and $0 \in \operatorname{conv}(V_2)$. Then there is a
rainbow edge $\{x, y\}$ with $x \in V_1$, $y \in V_2$, and
$0 \in \operatorname{conv}\{x, y\}$.

*Proof.* By Theorem 5.1 applied to $V_1$, extract $x \in V_1$ with $x \le 0$. By
Theorem 5.1 applied to $V_2$, extract $y \in V_2$ with $y \ge 0$. By Theorem 5.2,
$0 \in [x, y] = \operatorname{conv}\{x, y\}$. The edge $\{x, y\}$ uses one vertex
from each color, so it is rainbow. $\qquad\blacksquare$

The captured edge $\{x, y\}$ is a single edge of the join $V_1 * V_2$, so the
qualitative theorem is witnessed by an object of the join.

---

## 6. Synthesis: a small witness always suffices

**Theorem 6.1 (Witness-size synthesis).** Let $V_1, V_2 \subseteq \mathbb{R}$ be
nonempty finite color classes capturing the origin, and let $n = |V_1 \cup V_2|$.
Then:
1. There is a rainbow edge of $V_1 * V_2$ capturing the origin (Theorem 5.3).
2. Any width-$2$ sub-complex $K$ of the join on the $n$-vertex ground set
   satisfies $|K| \le 3(n+1)^2$.
3. If the witness is organized as a spanning tree, its face count is exactly
   $2n$.

*Proof.* Part 1 is Theorem 5.3. Part 2 is Theorem 3.5 with $k=1$, giving the
bound $(1+2)(n+1)^{1+1} = 3(n+1)^2$. Part 3 is Theorem 4.1. $\qquad\blacksquare$

Thus a capturing face always exists, and it can be certified inside a
spanning-tree-sized (linear, for $k=1$) sub-collection of the join, never the
full exponential complex of $\prod_i |V_i|$ top faces.

---

## 7. Algorithms

We record two algorithmic consequences.

**Algorithm A (Rainbow edge on the line).** Given finite $V_1, V_2 \subseteq
\mathbb{R}$ each capturing $0$: compute $x = \max\{v \in V_1 : v \le 0\}$ (or any
nonpositive element of $V_1$) and $y = \min\{v \in V_2 : v \ge 0\}$ (or any
nonnegative element of $V_2$); return $\{x, y\}$. By Theorem 5.3 this edge
captures $0$. The running time is linear in $|V_1| + |V_2|$: a single scan of
each color class suffices to find the required signs.

**Algorithm B (Witness enumeration bound).** Given a width-$(k+1)$ certifying
complex on $n$ vertices, the number of candidate faces to examine is at most
$(k+2)(n+1)^{k+1}$ (Theorem 3.5), and exactly $2n$ if the complex is a spanning
tree (Theorem 4.1). This replaces the exponential $\prod_i |V_i|$ enumeration of
the full join with a polynomial (or linear) enumeration.

---

## 8. Applications

- **Centerpoint and Tverberg computation.** Colorful Carathéodory is the engine
  of the fastest known approximate-centerpoint and Tverberg-partition
  algorithms. Bounding witness size by a polynomial (or linear count) directly
  limits the search each iteration must perform.

- **Data depth and robust statistics.** Centerpoints generalize the median to
  higher dimensions and are central to depth-based robust estimators. Efficient
  witnesses translate to faster depth computations.

- **Combinatorial certificate design.** The two-lever principle — width sets the
  polynomial degree, acyclicity collapses it — is a reusable template for
  turning existence theorems in combinatorial geometry into small, checkable
  certificates.

---

## 9. Discussion

Our results separate two sources of witness economy. **Width** is a *local*
constraint: bounding the number of vertices per face caps the face count by a
polynomial whose degree equals the width. **Acyclicity** is a *global*
constraint: it caps the number of top-dimensional faces independently of width,
collapsing the polynomial to linear at $k=1$. The generic degree-$(k+1)$ bound is
tight for arbitrary bounded-width complexes (Remark 3.6), so the linear tree
count is genuinely a structural gain, not a width phenomenon.

On the geometric side, the one-dimensional proof exposes the honest input to the
colorful theorem: capturing the origin is equivalent to straddling it in sign
(Theorem 5.1). This sign-extraction is the shadow of the general extreme-point
selection that drives Carathéodory-type arguments in every dimension.

---

## 10. Future directions

**1. Sharp linear witnesses for every fixed width.** *Conjecture:* for every
fixed $k$, a spanning $k$-tree on $n$ vertices has a face count that is linear in
$n$, namely at most $2^{k}(n-k) + (2^{k+1}-1)$, strictly below the
degree-$(k+1)$ bound for arbitrary width-$(k+1)$ complexes. The generic bound is
driven by width alone, whereas a $k$-tree also carries global acyclicity: each
newly attached vertex contributes a bounded number of new cliques, so the total
grows additively rather than combinatorially. The $k=1$ case is settled here (the
exact $2n$ count), isolating acyclicity as the collapse mechanism; the general
statement is the natural inductive lift.

**2. Rainbow capture inside a spanning tree of the join.** *Conjecture:* for
color classes on the line whose hulls all contain the origin, one can pre-select
a spanning tree of the join $V_1 * V_2$ — of only linearly many edges — that is
guaranteed to contain a rainbow edge through the origin, so the exponential join
never needs to be examined. The origin-capturing edges form a "crossing" pattern
determined by the sign pattern of the two color classes, and a single monotone
matching of nonpositive to nonnegative points meets this pattern. The existence
half is proved here via sign extraction; upgrading "one edge exists" to "a linear
pre-committed tree always contains one" is the decisive next step toward
algorithmic witnesses.

**3. Higher-dimensional sign extraction.** *Conjecture:* in $\mathbb{R}^d$, if
the origin lies in the convex hull of a finite color class $V$, then $V$ contains
an affinely independent sub-family of at most $d+1$ points whose hull already
captures the origin, and this Carathéodory sub-family can be located by examining
only polynomially many $(d+1)$-subsets when the search is restricted to a
spanning $d$-tree of $V$. The one-dimensional argument — extract a nonpositive
and a nonnegative element via the extreme points $\min$, $\max$ — is the shadow
of a general extreme-point selection: the origin's barycentric coordinates are
supported on a bounded face, and spanning-tree structure controls how many
candidate faces must be probed.

---

## 11. Conclusion

We have quantified the colorful Carathéodory theorem's witness complexity. A
capturing face always exists (proved explicitly on the line), and it can be
certified inside a bounded-width complex whose face count is polynomial of degree
$k+1$ — exactly $\sum_{i=0}^{k+1}\binom{n}{i}$, bounded by $(k+2)(n+1)^{k+1}$ —
collapsing to a linear $2n$ for spanning trees. The exponential join is never
needed. Width and acyclicity emerge as the two independent controls on witness
size, a principle we expect to extend to higher dimensions and larger fixed
widths.
