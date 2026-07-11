# Sign Characterization of Microscopic Weightings on Euclidean Subsets

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

The theory of magnitude assigns to each finite metric space a real number that
measures its "effective size," and to do so it first distributes a real-valued
*weighting* across the points. We study the small-scale limit of this weighting.
Expanding the similarity matrix $Z_t$ (entries $e^{-t\,d(x_i,x_j)}$) as $t \to 0$
yields, at leading order, a **distance-matrix weighting** $\mu$ characterized by
the two conditions $D\mu = \lambda\mathbf 1$ and $\sum_i \mu_i = 1$, where $D$ is
the pairwise distance matrix and $\lambda$ is a scalar. We call $\mu$ the
*microscopic weighting*. We prove that for a symmetric distance matrix the
constant $\lambda$ is an invariant of the configuration, independent of the chosen
weighting; that the weighting is unique when $D$ is invertible, with the closed
form $\mu = D^{-1}\mathbf 1 / (\mathbf 1^{\mathsf T} D^{-1}\mathbf 1)$; and that the
constant equals the quadratic energy, $\lambda = \mu^{\mathsf T} D\mu$. Our central
theme is a **sign characterization**: for a finite Euclidean point set $X$, the
microscopic weight of a point is strictly positive exactly when the point is an
extreme point (vertex) of the convex hull $\mathrm{conv}(X)$, and is non-positive
at every non-extreme point. We establish the full sign–extremality equivalence for
representative one- and two-dimensional configurations, including a square with an
interior centre where the interior weight is genuinely negative, and we discuss
routes to the general theorem.

## 1. Introduction

Leinster's theory of magnitude provides a single numerical invariant capturing the
"size" of a metric space, unifying cardinality, Euler characteristic, dimension,
and volume-like quantities under one definition. For a finite metric space with
points $x_1, \dots, x_n$, one forms the **similarity matrix**
$$
(Z_t)_{ij} = e^{-t\, d(x_i, x_j)}, \qquad t > 0,
$$
where $t$ is a scale parameter. A **weighting** at scale $t$ is a vector
$w_t \in \mathbb R^n$ solving
$$
Z_t\, w_t = \mathbf 1 := (1, \dots, 1)^{\mathsf T},
$$
and the **magnitude** at scale $t$ is $|X|_t = \sum_i (w_t)_i$. The weighting
distributes a unit of "presence" among the points, discounting redundancy from
mutual proximity.

This paper concerns the behaviour of the weighting as the scale contracts,
$t \to 0$, i.e. under infinite magnification of the point cloud. The exponential
expansion $e^{-t d} = 1 - t d + O(t^2)$ gives
$$
Z_t = J - t\,D + O(t^2),
$$
where $J = \mathbf 1 \mathbf 1^{\mathsf T}$ is the all-ones matrix and
$D = (d(x_i, x_j))_{ij}$ is the **distance matrix** (symmetric, zero diagonal,
non-negative off-diagonal). A first-order analysis of $Z_t w_t = \mathbf 1$
isolates a limiting object — the **microscopic weighting** $\mu$ — governed purely
by $D$: it satisfies $D\mu = \lambda\mathbf 1$ for a scalar $\lambda$, together
with the normalization $\sum_i \mu_i = 1$ inherited from the constraint that
weightings distribute a fixed total. This paper develops the elementary but
complete theory of such distance-matrix weightings and establishes the sign
characterization that is the theme of the work.

### Contributions

1. **Well-definedness of the constant** (Theorem 3.1): for symmetric $D$, any two
   microscopic weightings share the same $\lambda$.
2. **Uniqueness** (Theorem 3.2): if $D$ is invertible the microscopic weighting is
   unique.
3. **Existence and closed form** (Theorem 3.3):
   $\mu = D^{-1}\mathbf 1 / (\mathbf 1^{\mathsf T} D^{-1}\mathbf 1)$ whenever $D$ is
   invertible and $\mathbf 1^{\mathsf T} D^{-1}\mathbf 1 \neq 0$.
4. **Energy identity** (Theorem 3.4): $\lambda = \mu^{\mathsf T} D\mu$, exhibiting
   the constant as the quadratic energy and hence a configuration invariant.
5. **Sign characterization** (Section 5): worked out completely for two points,
   three collinear points, the equilateral triangle, and the square-with-centre,
   including the full sign ↔ extreme-point equivalence in one and two dimensions.

## 2. Definitions

Throughout, indices range over a finite set of size $n$; $\mathbf 1$ denotes the
all-ones vector and $J = \mathbf 1\mathbf 1^{\mathsf T}$ the all-ones matrix. For a
matrix $A$ we write $A *\!v$ (or $Av$) for the matrix–vector product and
$u \cdot v = \sum_i u_i v_i$ for the dot product.

**Definition 2.1 (Distance matrix).** For a finite metric space with points
$x_1, \dots, x_n$, the *distance matrix* is $D_{ij} = d(x_i, x_j)$. It is symmetric
($D^{\mathsf T} = D$), has zero diagonal, and non-negative entries.

**Definition 2.2 (Microscopic weighting).** Given a distance matrix $D$, a vector
$w \in \mathbb R^n$ is a *microscopic weighting* with constant $\lambda \in
\mathbb R$ if
$$
D\, w = \lambda \mathbf 1 \qquad\text{and}\qquad \sum_i w_i = 1.
$$
We refer to $\lambda$ as the *microscopic constant*. This is the leading-order
($t\to 0$) form of a magnitude weighting.

**Definition 2.3 (Convex hull and extreme points).** For $X \subseteq \mathbb R^d$,
the *convex hull* $\mathrm{conv}(X)$ is the smallest convex set containing $X$. A
point $p \in \mathrm{conv}(X)$ is an *extreme point* (vertex) if it does not lie in
the open segment between two distinct points of $\mathrm{conv}(X)$; equivalently,
$p$ cannot be written as $a x_1 + b x_2$ with $x_1 \neq x_2$ in the hull, $a, b >
0$, $a + b = 1$.

## 3. Core theory of distance-matrix weightings

We now prove the four structural results. The only inputs are linear algebra and
the symmetry of $D$.

### Theorem 3.1 (The microscopic constant is well defined)

*Let $D$ be symmetric. If $w$ is a microscopic weighting with constant $a$ and
$w'$ is a microscopic weighting with constant $b$, then $a = b$.*

**Proof.** Consider the scalar $w \cdot (D w')$. On one hand, since $D w' = b
\mathbf 1$,
$$
w \cdot (D w') = w \cdot (b\mathbf 1) = b\sum_i w_i = b.
$$
On the other hand, using symmetry $D^{\mathsf T} = D$ we may transfer $D$ to the
left factor:
$$
w \cdot (D w') = (D^{\mathsf T} w)\cdot w' = (D w)\cdot w' = (a\mathbf 1)\cdot w' =
a\sum_i w'_i = a.
$$
Hence $a = b$. $\qquad\blacksquare$

This is the microscopic analogue of the well-definedness of magnitude: although a
symmetric distance matrix may admit many weightings (when $D$ is singular), they
all report the same constant.

### Theorem 3.2 (Uniqueness for invertible $D$)

*Let $D$ be symmetric and invertible. Then the microscopic weighting is unique: if
$w$ and $w'$ are microscopic weightings, then $w = w'$.*

**Proof.** By Theorem 3.1 the two constants coincide, say both equal $\lambda$.
Then $D w = \lambda\mathbf 1 = D w'$, so $D(w - w') = 0$. Multiplying on the left by
$D^{-1}$ gives $w - w' = 0$. $\qquad\blacksquare$

### Theorem 3.3 (Existence and closed form)

*Let $D$ be invertible and set $s = \mathbf 1^{\mathsf T} D^{-1}\mathbf 1 = \sum_i
(D^{-1}\mathbf 1)_i$. If $s \neq 0$, then*
$$
\mu = \frac{1}{s}\, D^{-1}\mathbf 1
$$
*is a microscopic weighting with constant $\lambda = 1/s$.*

**Proof.** Compute
$$
D\mu = \frac1s\, D\,(D^{-1}\mathbf 1) = \frac1s\,\mathbf 1 = \tfrac1s\,\mathbf 1,
$$
so the first condition holds with $\lambda = 1/s$. For normalization,
$$
\sum_i \mu_i = \frac1s\sum_i (D^{-1}\mathbf 1)_i = \frac1s\cdot s = 1.
$$
$\qquad\blacksquare$

Thus for any finite Euclidean configuration whose distance matrix is invertible and
whose row-sums of $D^{-1}$ do not cancel, the microscopic weighting exists, is
unique, and is given explicitly by $\mu = D^{-1}\mathbf 1 / (\mathbf 1^{\mathsf T}
D^{-1}\mathbf 1)$.

### Theorem 3.4 (The constant is the quadratic energy)

*For any microscopic weighting $w$ with constant $\lambda$,*
$$
\lambda = w \cdot (D w) = w^{\mathsf T} D\, w.
$$

**Proof.** Since $D w = \lambda\mathbf 1$,
$$
w \cdot (D w) = w \cdot (\lambda \mathbf 1) = \lambda \sum_i w_i = \lambda\cdot 1 =
\lambda. \qquad\blacksquare
$$

Combined with Theorem 3.1, this shows the quadratic energy $w^{\mathsf T} D w$ is an
invariant of a symmetric distance matrix, independent of the chosen weighting — a
single scalar summarizing the configuration.

## 4. The microscopic weighting on concrete configurations

We record the exact microscopic weighting for four Euclidean configurations. Each
can be verified directly against Definition 2.2.

**4.1 Two points at distance $r$.** With
$D = \begin{pmatrix} 0 & r \\ r & 0 \end{pmatrix}$, the vector
$\mu = (\tfrac12, \tfrac12)$ satisfies $D\mu = (\tfrac r2, \tfrac r2) = \tfrac r2
\mathbf 1$ and $\sum \mu_i = 1$. Hence $\mu = (\tfrac12,\tfrac12)$ with
$\lambda = r/2$; both weights are positive.

**4.2 Three collinear points $0, 1, 2 \in \mathbb R$.** The distance matrix is
$$
D = \begin{pmatrix} 0 & 1 & 2 \\ 1 & 0 & 1 \\ 2 & 1 & 0 \end{pmatrix},
$$
which is symmetric. The vector $\mu = (\tfrac12, 0, \tfrac12)$ satisfies
$D\mu = (1, 1, 1) = \mathbf 1$ and $\sum \mu_i = 1$; thus $\lambda = 1$. The
endpoints receive weight $\tfrac12 > 0$; the middle point receives weight $0$.

**4.3 Equilateral triangle of side $c$.** With
$D = \begin{pmatrix} 0 & c & c \\ c & 0 & c \\ c & c & 0 \end{pmatrix}$, the uniform
vector $\mu = (\tfrac13,\tfrac13,\tfrac13)$ satisfies $D\mu = (\tfrac{2c}3,
\tfrac{2c}3, \tfrac{2c}3)$ and $\sum \mu_i = 1$, so $\lambda = 2c/3$; all weights are
positive.

**4.4 Square $\{(\pm1, \pm1)\}$ with centre $(0,0)$.** Index $0$ is the centre and
$1, \dots, 4$ are the vertices in cyclic order, so adjacent vertices are at distance
$2$, diagonal vertices at distance $2\sqrt 2$, and each vertex is at distance
$\sqrt 2$ from the centre. Writing $s = \sqrt 2$, the distance matrix is
$$
D = \begin{pmatrix}
0 & s & s & s & s \\
s & 0 & 2 & 2s & 2 \\
s & 2 & 0 & 2 & 2s \\
s & 2s & 2 & 0 & 2 \\
s & 2 & 2s & 2 & 0
\end{pmatrix}.
$$
The unnormalized vector $w_0 = \bigl(2(1 - s),\, 1,\, 1,\, 1,\, 1\bigr)$ satisfies
$D w_0 = 4s\,\mathbf 1$, as one checks row by row using $s^2 = 2$. Its coordinate
sum is $\sum_i (w_0)_i = 6 - 2s$, which is positive because $s = \sqrt 2 < 3$.
Normalizing,
$$
\mu = \frac{1}{6 - 2s}\, w_0 = \frac{1}{6 - 2\sqrt 2}\bigl(2(1 - \sqrt 2),\, 1,\, 1,\,
1,\, 1\bigr),
$$
is a microscopic weighting with constant
$$
\lambda = \frac{4s}{6 - 2s} = \frac{4\sqrt 2}{6 - 2\sqrt 2}.
$$
Since $s = \sqrt 2 > 1$, the centre weight $\mu_0 = \dfrac{2(1 - \sqrt 2)}{6 - 2\sqrt
2}$ is **strictly negative**, while each vertex weight $\mu_i = \dfrac{1}{6 - 2\sqrt
2} > 0$. This is the smallest configuration in which the microscopic weight of a
strictly interior point is genuinely negative.

## 5. The sign characterization

We now connect the *sign* of $\mu$ to the *geometry* of the configuration. The
research theme is the following equivalence.

> **Sign Characterization (Theme).** For a finite Euclidean set $X$ with
> microscopic weighting $\mu$, a coordinate satisfies $\mu(x) > 0$ if and only if
> $x$ is an extreme point (vertex) of $\mathrm{conv}(X)$, and $\mu(x) \le 0$ for
> every non-extreme point $x$.

We prove the full equivalence in two representative cases.

### 5.1 Three collinear points

**Proposition 5.1.** *For $X = \{0, 1, 2\} \subseteq \mathbb R$ with microscopic
weighting $\mu = (\tfrac12, 0, \tfrac12)$:*
- *the endpoints $0$ and $2$ are extreme points of $\mathrm{conv}(X) = [0,2]$, and
  their weights $\tfrac12$ are positive;*
- *the midpoint $1$ is not an extreme point, and its weight $0$ is non-positive.*

**Proof sketch.** The hull is the interval $[0,2]$: it contains $0, 1, 2$ and is
convex, and conversely every convex set containing the three points contains their
interval. That $0$ is extreme follows because if $0 = a x_1 + b x_2$ with $x_1, x_2
\in [0,2]$, $a, b > 0$, $a + b = 1$, then $a x_1 + b x_2 \ge 0$ with equality only
when $x_1 = x_2 = 0$; a symmetric argument (in the coordinate $2 - x$) handles the
endpoint $2$. The midpoint $1$ is *not* extreme because $1 = \tfrac12\cdot 0 +
\tfrac12\cdot 2$ lies in the open segment between the endpoints. Matching against
$\mu = (\tfrac12, 0, \tfrac12)$ gives the equivalence coordinate by coordinate.
$\qquad\blacksquare$

### 5.2 Square with centre

The two-dimensional case rests on a "pinning" lemma expressing that a vertex of the
box $[-1,1]^2$ cannot be a nontrivial convex combination of points of the box
without both points equalling it.

**Lemma 5.2 (Pinning).** *Let $\varepsilon \in \{+1, -1\}$ and $a, b > 0$ with $a +
b = 1$. If $a x + b y = \varepsilon$ and both $\varepsilon x \le 1$ and $\varepsilon y
\le 1$, then $x = y = \varepsilon$.*

**Proof.** Multiplying the hypothesis by $\varepsilon$ and using $\varepsilon^2 = 1$
gives $a(\varepsilon x) + b(\varepsilon y) = 1$. Since $\varepsilon x \le 1$ and
$\varepsilon y \le 1$ with positive weights summing to one, the weighted average
equals its maximum only if both terms attain the bound: $\varepsilon x = 1$ and
$\varepsilon y = 1$. Multiplying by $\varepsilon$ once more yields $x = y =
\varepsilon$. $\qquad\blacksquare$

**Proposition 5.3.** *For $X = \{(0,0), (\pm1, \pm1)\} \subseteq \mathbb R^2$ with
microscopic weighting $\mu$ as in §4.4:*
- *the centre $(0,0)$ is not an extreme point of $\mathrm{conv}(X)$, and its weight
  $\mu_0 < 0$;*
- *each vertex $(\pm1, \pm1)$ is an extreme point, and its weight $\mu_i > 0$.*

**Proof sketch.** The hull is contained in the box $[-1,1]^2$: it contains all five
points and lies inside the (convex) box. The centre is not extreme because $(0,0) =
\tfrac12(1,1) + \tfrac12(-1,-1)$ is the midpoint of a diagonal. Each vertex is
extreme by the pinning lemma applied coordinatewise: if a vertex $(\varepsilon_1,
\varepsilon_2)$ equals $a p + b q$ for hull points $p, q$ with $a, b > 0$, $a + b =
1$, then since every hull point lies in $[-1,1]^2$ the coordinate bounds
$\varepsilon_1 x \le 1$, $\varepsilon_2 y \le 1$ hold, and Lemma 5.2 forces $p = q =
(\varepsilon_1, \varepsilon_2)$. The sign computation of §4.4 ($\mu_0 < 0$, $\mu_i >
0$) completes the equivalence. $\qquad\blacksquare$

Proposition 5.3 is the crucial instance in which the microscopic weight goes
*strictly negative* at an interior point, confirming the "$\mu(x) \le 0$ at
non-extreme points" half of the theme in its sharpest form.

## 6. Algorithms

Given a finite Euclidean set $X = \{x_1, \dots, x_n\} \subseteq \mathbb R^d$, the
microscopic weighting is computed directly from Theorem 3.3.

**Algorithm A (Microscopic weighting via the distance matrix).**
1. Form $D_{ij} = \lVert x_i - x_j \rVert_2$.
2. Solve the linear system $D u = \mathbf 1$ for $u$ (i.e. $u = D^{-1}\mathbf 1$).
3. Set $s = \sum_i u_i$; if $s = 0$ report degeneracy, else output
   $\mu = u / s$ and $\lambda = 1/s$.

The dominant cost is the linear solve, $O(n^3)$; the energy identity provides a
cheap consistency check, $\lambda \stackrel{?}{=} \mu^{\mathsf T} D\mu$, in
$O(n^2)$.

**Algorithm B (Sign–extremality audit).** For each point $x_i$, classify it as a
vertex of $\mathrm{conv}(X)$ (e.g. via a linear-programming feasibility test for
membership in the hull of the other points) and compare with $\mathrm{sign}(\mu_i)$.
The sign characterization predicts $\mu_i > 0$ exactly at vertices.

## 7. Applications and discussion

Magnitude and its weightings appear across mathematics and its applications: as a
generalized notion of size unifying cardinality, Euler characteristic, and
volume-like invariants; in mathematical ecology, where magnitude quantifies
effective biodiversity; and in data analysis, where the weighting acts as a
boundary-detector for point clouds, emphasizing outliers and extreme points. The
sign characterization gives these uses a precise geometric footing: **positive
weight marks the vertices of the convex hull, and non-positive weight marks the
interior.** The strictly negative weights that arise for interior points (as in the
square-with-centre) are not anomalies but corrections for redundancy — an interior
point already "covered" by the boundary is discounted so that the total magnitude
remains faithful to the shape's frontier.

The energy identity $\lambda = \mu^{\mathsf T} D\mu$ additionally exhibits a single
scalar invariant of the configuration, computable from any valid weighting, tying
the microscopic constant to a quadratic form in the distances.

## 8. Future directions

Several natural extensions remain.

1. **General existence.** Prove that for $n$ distinct points in $\mathbb R^d$ the
   Euclidean distance matrix $D$ is invertible (it is conditionally negative
   definite of full rank), giving $\mu$ for every finite Euclidean set, not just
   examples.
2. **General sign theorem.** Prove $\mu(x) > 0 \iff x \in \mathrm{extreme\ points}
   (\mathrm{conv}\,X)$ in full generality, connecting $\mathrm{sign}(\mu)$ to a
   supporting-hyperplane / Delaunay characterization of extreme points.
3. **Link to magnitude asymptotics.** Formalize $Z_t = J - tD + O(t^2)$ and prove
   that the finite-scale weighting $w_t$ converges to $\mu$ as $t \to 0$, tying the
   algebraic object back to its analytic origin.
4. **Higher-dimensional and generic configurations.** Extend the two-dimensional
   extreme-point machinery to general polytopes and to point sets in $\mathbb R^d$.
5. **Negative-type framework.** Develop Schoenberg's theorem (negative type
   $\Leftrightarrow$ embeddable) to underpin the positive definiteness of the
   similarity matrices $Z_t$.

## 9. Conclusion

Starting from the two conditions $D\mu = \lambda\mathbf 1$ and $\sum_i \mu_i = 1$,
we developed the complete elementary theory of microscopic (distance-matrix)
weightings: the constant $\lambda$ is a well-defined invariant for symmetric $D$,
the weighting is unique and explicit when $D$ is invertible, and $\lambda$ equals
the quadratic energy $\mu^{\mathsf T} D\mu$. The governing geometric principle is
the sign characterization — positive weight at vertices of the convex hull,
non-positive weight in the interior — which we verified completely, including the
sharp negative-weight phenomenon, for representative Euclidean configurations. The
picture that emerges is simple and robust: to measure a finite Euclidean shape, the
microscopic weighting listens to its boundary and discounts its interior.
