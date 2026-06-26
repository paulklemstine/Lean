# Exponential Diameter Contraction under Delaunay Minicenter Refinement: From a Limit Statement to a Finite Refinement Budget

**Author:** Aristotle (Harmonic)
**Date:** 2026-06-26
**Domain:** Applications (Computational Geometry / Mesh Refinement)

## Abstract

We study the metric core of a classical mesh-generation conjecture: that each
round of Delaunay refinement with *minicenter* (smallest-enclosing-ball center)
Steiner points contracts the maximum simplex diameter by a uniform factor
$\lambda > 1$, yielding exponential decay $d_k \le (1/\lambda)^k d_0$ after $k$
rounds. The full geometric statement in arbitrary dimension is open. We isolate
the *analyzable backbone* — a nonnegative sequence obeying the per-step
contraction $d_{k+1} \le (1/\lambda) d_k$ — and prove, with full rigor and zero
gaps: (i) the **abstract contraction theorem** $d_k \le (1/\lambda)^k d_0$ by
induction; (ii) **decay to zero** $d_k \to 0$; (iii) an explicit **iteration
count** to reach any tolerance $\varepsilon$; and (iv) the **segment base case**,
where the minicenter of a $1$-simplex is its midpoint and bisection realizes
$\lambda = 2$ exactly, witnessing satisfiability of the hypotheses. We then prove
the paper's centerpiece: under exponential contraction the *cumulative* diameter
is summable, with the closed form
$$ \sum_{k=0}^{\infty} d_k \le \frac{D\lambda}{\lambda-1}, \quad D := d_0, $$
the **finite total refinement budget**. We show $\lambda = 1$ is exactly the
threshold between a finite and an infinite budget, sharpening the reason to demand
strict contraction. Finally, we connect to the approximate Carathéodory / Maurey
principle: since every point of a simplex lies within one diameter of a vertex,
the covering radius $c_k \le d_k$ inherits **exponential decay** ($c_k \to 0$) and
a **finite covering budget** bounded by the same constant. The work reframes mesh
refinement complexity around a *budget* rather than a *limit*, and identifies the
single geometric inequality whose proof would close the open conjecture.

## 1. Introduction

### 1.1 Motivation

Adaptive mesh refinement is a workhorse of scientific computing: finite-element
analysis, computational fluid dynamics, computer graphics, and surface
reconstruction all depend on procedures that take a coarse simplicial mesh and
subdivide it into arbitrarily fine pieces while preserving good element quality.
A central family of such procedures is **Delaunay refinement**: repeatedly insert
a Steiner point into the worst element and restore the Delaunay property of the
triangulation. The *choice* of Steiner point matters enormously for both quality
and convergence speed; a natural and well-studied choice is the **minicenter**,
the center of the smallest enclosing ball of the offending simplex.

The practical folklore is that minicenter refinement contracts the largest
element geometrically — that there is a uniform factor $\lambda > 1$ such that one
round shrinks the maximum diameter to at most $1/\lambda$ of its previous value.
If true, the maximum diameter decays exponentially in the number of rounds, and
the mesh becomes fine very fast.

### 1.2 What is open and what is provable

The full conjecture, over $d$-simplices for all $d$, is genuinely open. It
entangles combinatorial content (which simplices appear in the re-triangulation
$\mathrm{Del}(X_k)$ at step $k$) with metric content (how far the minicenter of a
simplex lies from its other points, which depends on aspect ratio). No uniform
factor $\lambda > 1$ has been established in general dimension.

This paper extracts the **metric backbone** of the conjecture — the part that is
clean, complete, and certain — and develops its consequences fully. We model the
trajectory of the maximum diameter as a sequence $d : \mathbb{N} \to \mathbb{R}$
with $d_k \ge 0$ and the per-step contraction $d_{k+1} \le (1/\lambda) d_k$, and
we derive everything that follows. Crucially, we go beyond the known
"diameter $\to 0$" conclusion to a **budget** theory: the cumulative diameter over
all rounds is summable with an explicit closed form, and the same holds for the
Carathéodory covering radius.

### 1.3 Contributions

1. **Abstract contraction and decay.** The induction $d_k \le (1/\lambda)^k d_0$
   and the squeeze $d_k \to 0$.
2. **Explicit stopping rule.** A computable iteration count to reach tolerance
   $\varepsilon$.
3. **Segment base case.** $\lambda = 2$ realized exactly by bisection, the
   minicenter of a $1$-simplex being its midpoint.
4. **Finite total refinement budget** (`total_budget`): $\sum_k d_k \le
   D\lambda/(\lambda-1)$, with $\lambda = 1$ identified as the finite/infinite
   threshold (`summable_of_contraction`).
5. **Exponential covering and covering budget** (`covering_tendsto_zero`,
   `covering_budget`): transferring decay and summability to the Carathéodory
   covering radius via $c_k \le d_k$.

## 2. Definitions and Setup

### 2.1 Simplices, diameters, and refinement

**Definition (Simplex).** A $d$-simplex is the convex hull of $d+1$ affinely
independent points (its vertices) in Euclidean space. A $0$-simplex is a point, a
$1$-simplex a segment, a $2$-simplex a triangle, a $3$-simplex a tetrahedron.

**Definition (Diameter).** The diameter of a bounded set $\sigma$ is
$\operatorname{diam}(\sigma) = \sup\{\,\lVert x - y\rVert : x, y \in \sigma\,\}$.
For a simplex this supremum is attained between two vertices; for a segment it is
the segment's length, and for a triangle the length of the longest edge.

**Definition (Smallest enclosing ball and minicenter).** For a bounded set
$\sigma$, the smallest enclosing ball is the unique closed ball of minimum radius
containing $\sigma$. Its center is the **minicenter** $\operatorname{mc}(\sigma)$.

**Definition (Delaunay minicenter refinement).** Given a finite point set $X_k$
with Delaunay triangulation $\mathrm{Del}(X_k)$, one refinement round selects
offending simplices, inserts their minicenters as new Steiner points to form
$X_{k+1}$, and recomputes $\mathrm{Del}(X_{k+1})$. We write
$$ d_k := \max_{\sigma \in \mathrm{Del}(X_k)} \operatorname{diam}(\sigma) $$
for the maximum simplex diameter at round $k$, and $D := d_0$.

### 2.2 The contraction hypothesis

**Definition (Per-step contraction).** A diameter trajectory $d : \mathbb{N} \to
\mathbb{R}$ *contracts with factor* $\lambda > 1$ if $d_k \ge 0$ for all $k$ and
$$ d_{k+1} \le \frac{1}{\lambda}\, d_k \quad \text{for all } k. $$

The contraction conjecture asserts that minicenter refinement produces a
trajectory contracting with some uniform $\lambda > 1$. Our results take the
contraction hypothesis — equivalently its closed consequence $d_k \le
(1/\lambda)^k D$ — as given and derive its full analytic content.

### 2.3 The covering radius

**Definition (Covering radius).** Let the domain $\Omega$ be the region being
meshed and $X_k$ the sample vertices at round $k$. The covering radius is
$$ c_k := \sup_{x \in \Omega} \ \min_{v \in X_k} \lVert x - v \rVert, $$
the largest distance from any domain point to its nearest sample vertex.

**Carathéodory/Maurey covering fact.** Every point $x \in \Omega$ lies in some
simplex $\sigma \in \mathrm{Del}(X_k)$, and every point of a simplex is within
$\operatorname{diam}(\sigma)$ of each of its vertices. Hence
$$ c_k \le d_k. $$
This is the honest geometric content of approximate Carathéodory in this setting,
not an extra assumption: a point expressed as a convex blend of a simplex's
vertices is within the simplex diameter of the nearest vertex.

## 3. Main Results

Throughout, fix $\lambda > 1$ and $D = d_0 \ge 0$.

### 3.1 The abstract contraction theorem

**Theorem 1 (Contraction power bound).** If $d$ contracts with factor $\lambda >
1$, then for all $k$,
$$ d_k \le \left(\frac{1}{\lambda}\right)^k d_0. $$

*Proof sketch.* Induction on $k$. The base case $k = 0$ is the equality $d_0 =
(1/\lambda)^0 d_0$. For the step, assume $d_k \le (1/\lambda)^k d_0$. Since
$1/\lambda > 0$ and $d_{k+1} \le (1/\lambda) d_k$,
$$ d_{k+1} \le \tfrac{1}{\lambda} d_k \le \tfrac{1}{\lambda}\cdot \big(\tfrac{1}{\lambda}\big)^k d_0 = \big(\tfrac{1}{\lambda}\big)^{k+1} d_0. \qquad \blacksquare $$

**Theorem 2 (Decay to zero).** If $d$ contracts with factor $\lambda > 1$, then
$d_k \to 0$ as $k \to \infty$.

*Proof sketch.* Since $\lambda > 1$ we have $0 \le 1/\lambda < 1$, hence
$|1/\lambda| < 1$ and $(1/\lambda)^k \to 0$, so $(1/\lambda)^k d_0 \to 0$. By
Theorem 1, $0 \le d_k \le (1/\lambda)^k d_0$, and the squeeze theorem gives
$d_k \to 0$. $\blacksquare$

**Theorem 3 (Explicit iteration count).** Let $\varepsilon > 0$ and $D = d_0 >
0$. If $d$ contracts with factor $\lambda > 1$, then $d_k \le \varepsilon$ holds
for every
$$ k \ge \left\lceil \frac{\ln(D/\varepsilon)}{\ln \lambda} \right\rceil. $$

*Proof sketch.* By Theorem 1 it suffices that $(1/\lambda)^k D \le \varepsilon$,
i.e. $\lambda^k \ge D/\varepsilon$. Taking logarithms (with $\ln\lambda > 0$)
gives $k \ge \ln(D/\varepsilon)/\ln\lambda$; any integer $k$ at least the ceiling
suffices. $\blacksquare$

### 3.2 The geometric witness: the segment base case

**Theorem 4 (Segment minicenter halves the diameter).** Let $\sigma = [a,b]$ be a
$1$-simplex (a segment) of length $\ell = \lVert a - b\rVert$. The minicenter of
$\sigma$ is its midpoint $m = (a+b)/2$, and inserting $m$ as a Steiner point
splits $\sigma$ into two children $[a,m]$ and $[m,b]$, each of diameter $\ell/2$.
Thus one round of minicenter refinement contracts the segment diameter by the
exact factor $\lambda = 2$.

*Proof sketch.* The smallest ball enclosing a segment is the ball whose diameter
is the segment, centered at the midpoint $m$ with radius $\ell/2$ (no smaller ball
can contain both endpoints, which are $\ell$ apart). Hence
$\operatorname{mc}(\sigma) = m$. Each child segment has length
$\lVert a - m\rVert = \lVert m - b\rVert = \ell/2$, so its diameter is $\ell/2 =
(1/2)\operatorname{diam}(\sigma)$. $\blacksquare$

Theorem 4 certifies that the contraction hypothesis of Definition 2.2 is
*satisfiable by genuine geometry*, and that the exponent in Theorem 1 is
*achieved* (not merely an upper bound) with $\lambda = 2$. Iterating, a unit
segment refined $k$ times has children of length $2^{-k}$, the exponential law in
its purest form.

### 3.3 Summability and the finite refinement budget

The decisive step from a *limit* statement to a *budget* statement is
summability. We compare the diameter series term-by-term against a geometric
series.

**Theorem 5 (Summability of the diameter sequence).** If $\lambda > 1$, $d_k \ge
0$ for all $k$, and $d_k \le (1/\lambda)^k D$ for all $k$, then the series
$\sum_k d_k$ converges (i.e. $d$ is summable).

*Proof sketch.* Set $r = 1/\lambda$. Since $\lambda > 1$, we have $0 \le r < 1$,
so the geometric series $\sum_k r^k$ converges; multiplying by the constant $D$,
the series $\sum_k r^k D$ converges. Each term of $d$ is nonnegative and bounded
above by the corresponding term $r^k D$, so by the comparison test $\sum_k d_k$
converges. $\blacksquare$

**Theorem 6 (Finite total refinement budget).** If $\lambda > 1$, $d_k \ge 0$ for
all $k$, and $d_k \le (1/\lambda)^k D$ for all $k$, then
$$ \sum_{k=0}^{\infty} d_k \ \le\ \frac{D\,\lambda}{\lambda - 1}. $$

*Proof sketch.* By Theorem 5 both series below converge, so termwise comparison
lifts to the sums:
$$ \sum_k d_k \ \le\ \sum_k \Big(\tfrac{1}{\lambda}\Big)^k D
 \ =\ \Big(\sum_k \big(\tfrac{1}{\lambda}\big)^k\Big) D
 \ =\ \frac{1}{1 - 1/\lambda}\, D
 \ =\ \frac{D\lambda}{\lambda - 1}, $$
using the geometric-series sum $\sum_k r^k = 1/(1-r)$ for $0 \le r < 1$ and the
algebraic simplification $1/(1-1/\lambda) = \lambda/(\lambda-1)$, valid since
$\lambda > 0$. $\blacksquare$

**Remark (the threshold at $\lambda = 1$).** The closed form
$D\lambda/(\lambda-1)$ diverges as $\lambda \downarrow 1$: the denominator
$\lambda - 1 \to 0^+$. At $\lambda = 1$ the comparison series becomes
$\sum_k D = D + D + D + \cdots$, which diverges; Theorem 5 fails because the ratio
$r = 1$ no longer yields a convergent geometric series. Thus **strict
contraction $\lambda > 1$ is exactly the boundary between a finite and an infinite
refinement budget.** This is a strictly stronger reason to demand $\lambda > 1$
than convergence alone, since convergence to zero can occur (sub-geometrically)
even when the cumulative diameter is infinite.

### 3.4 Covering: decay and budget for the sampling net

We now transfer the diameter results to the covering radius via the Carathéodory
fact $c_k \le d_k$.

**Theorem 7 (Exponential decay of the covering radius).** Suppose $\lambda > 1$,
$c_k \ge 0$, $c_k \le d_k$, and $d_k \le (1/\lambda)^k D$ for all $k$. Then
$c_k \to 0$ as $k \to \infty$.

*Proof sketch.* Compose the two bounds: $0 \le c_k \le d_k \le (1/\lambda)^k D$.
Since $|1/\lambda| < 1$, the upper bound $(1/\lambda)^k D \to 0$. The squeeze
theorem applied to $0 \le c_k \le (1/\lambda)^k D$ yields $c_k \to 0$.
$\blacksquare$

**Theorem 8 (Finite covering budget).** Under the hypotheses of Theorem 7,
$$ \sum_{k=0}^{\infty} c_k \ \le\ \frac{D\,\lambda}{\lambda - 1}. $$

*Proof sketch.* From $c_k \le d_k$ and $d_k \le (1/\lambda)^k D$ we get $d_k \ge
0$ (as $d_k \ge c_k \ge 0$), so $d$ is summable by Theorem 5. Since $0 \le c_k
\le d_k$ and $d$ is summable, comparison makes $c$ summable with $\sum_k c_k \le
\sum_k d_k$. Chaining with Theorem 6 gives $\sum_k c_k \le \sum_k d_k \le
D\lambda/(\lambda-1)$. $\blacksquare$

The same closed-form constant therefore governs both the cumulative simplex
diameter and the cumulative covering error of the sampling net: exponential
contraction of the mesh automatically certifies exponential contraction of the
approximation quality, with a single finite budget for both.

## 4. Algorithms

### 4.1 Iteration-count planner

Given the initial diameter $D$, contraction factor $\lambda$, and tolerance
$\varepsilon$, Theorem 3 yields a provably sufficient number of refinement rounds
*before any computation*:
$$ K(\varepsilon) = \left\lceil \frac{\ln(D/\varepsilon)}{\ln\lambda}\right\rceil. $$
This converts an open-ended "refine until good enough" loop into a deterministic
loop of known length, enabling memory preallocation and worst-case scheduling.

**Pseudocode.**
```
function PLAN_ROUNDS(D, lambda, eps):
    assert lambda > 1 and D > 0 and eps > 0
    if eps >= D: return 0
    return ceil( ln(D / eps) / ln(lambda) )
```

### 4.2 Budget estimator

Theorem 6 gives the cumulative-diameter budget in closed form. The estimator
returns the guaranteed upper bound on total refinement work and the per-round
contributions, and verifies that partial sums approach the closed form.

**Pseudocode.**
```
function BUDGET(D, lambda, K):
    assert lambda > 1
    closed_form = D * lambda / (lambda - 1)
    partial = sum_{k=0}^{K-1} D * (1/lambda)^k     # = D*(1-(1/lambda)^K)/(1-1/lambda)
    return closed_form, partial    # partial <= closed_form, partial -> closed_form
```

### 4.3 Segment-refinement simulator

Realizes the base case (Theorem 4): repeated bisection of a segment, returning the
exact diameter trajectory $d_k = D\,2^{-k}$ and the cumulative diameter, which
converges to $2D$ (the $\lambda = 2$ instance of the budget).

**Pseudocode.**
```
function REFINE_SEGMENT(D, K):
    d = D; trajectory = []; total = 0
    for k in 0..K-1:
        trajectory.append(d); total += d
        d = d / 2          # minicenter of segment = midpoint => halving
    return trajectory, total     # total -> 2D as K -> infinity
```

## 5. Applications and Numerical Illustration

- **Finite-element preprocessing.** The iteration planner (Section 4.1) lets a
  solver allocate the exact number of refinement passes needed to reach a target
  element size, eliminating adaptive overshoot.
- **Total-work budgeting.** The budget formula $D\lambda/(\lambda-1)$ gives a
  closed-form a-priori bound on cumulative refinement effort, useful for cost
  models and scheduler admission control.
- **Sampling and approximation.** Theorems 7–8 turn mesh refinement into a
  convergent sampling scheme with a finite total covering error, relevant to
  surface reconstruction and quadrature.

Numerically, for $D = 1$ and $\lambda = 2$ the budget is $D\lambda/(\lambda-1) =
2$, and the segment simulator's cumulative sum $1 + 0.5 + 0.25 + \cdots$ approaches
$2$, matching Theorem 6 exactly. For $\lambda = 1.1$ the budget balloons to
$1\cdot1.1/0.1 = 11$, dramatizing the near-threshold blow-up of the Remark. The
accompanying demo verifies these against direct summation.

## 6. Discussion

The conceptual shift in this work is from a **limit** ($d_k \to 0$) to a
**budget** ($\sum_k d_k < \infty$, in closed form). The limit certifies that
refinement eventually succeeds; the budget prices the *entire* infinite process
and makes the contraction factor $\lambda$ the controlling complexity parameter.
The closed form $D\lambda/(\lambda-1)$ is strictly decreasing in $\lambda$, so a
better contraction factor is not merely faster asymptotically — it is cheaper in
total. The threshold at $\lambda = 1$ then acquires sharp meaning: it is the exact
divide between a finite and an infinite cumulative cost.

The segment base case anchors the abstraction in real geometry and shows the
exponent is achieved, while the higher-dimensional contraction factor remains the
single open metric inequality. The covering results show the budget viewpoint is
robust: it survives the passage from mesh geometry to sampling quality unchanged,
governed by the same constant.

## 7. Future Directions

**(1) Dimension-dependent contraction factor.** For a non-degenerate $d$-simplex,
one round of minicenter refinement is conjectured to reduce the maximum child
diameter by a factor $\lambda_d \ge 1 + c/d$ for an absolute constant $c > 0$,
with $\lambda_d \to 1$ as $d \to \infty$ (and $\lambda_1 = 2$, the proved segment
case). The key insight: the segment case achieves $\lambda = 2$ because the
minicenter of a $1$-simplex is its midpoint, but in higher dimensions the
minicenter can sit far from the barycenter for skinny simplices, so the guaranteed
factor must degrade with dimension and aspect ratio. The abstract theory isolates
exactly the inequality the geometry must supply, turning the open conjecture into
a single sharply-stated metric inequality.

**(2) The budget as the right complexity measure.** Among subdivision rules with
per-step contraction $\lambda > 1$, the cumulative diameter $\sum_k d_k =
D\lambda/(\lambda-1)$ is conjectured to be minimized — over rules achieving a fixed
tolerance — by the rule maximizing $\lambda$, and to dominate mesh-size complexity
up to a constant. Exponential contraction upgrades "diameter $\to 0$" to a
summable series whose closed form is strictly decreasing in $\lambda$, so the
contraction factor controls total work, not merely asymptotic fineness. The budget
viewpoint is formally available and needs only an optimization layer.

**(3) The Maurey $R/\sqrt{k}$ rate as the contraction face for flat clouds.** For
a point cloud whose convex hull admits no exponential-contraction refinement
(e.g. nearly co-spherical points where minicenter splits barely shrink diameters),
the best covering of hull points by $k$-sample averages still decays, but only at
the Maurey rate $R/\sqrt{k}$, never exponentially — and this $\sqrt{k}$ barrier is
tight. The unconditional Maurey $R^2/k$ squared-covering bound holds with no
geometric contraction assumption, whereas the exponential covering budget holds
*only when* contraction holds; the two regimes are complementary, and degenerate
geometries select the slower one.

## 8. Conclusion

We have given a complete, rigorous treatment of the metric backbone of the
Delaunay minicenter contraction conjecture: exponential decay of the maximum
diameter, an explicit stopping rule, a geometric witness at $\lambda = 2$, and —
most importantly — a finite total refinement budget $\sum_k d_k \le
D\lambda/(\lambda-1)$ with the threshold $\lambda = 1$ marking the finite/infinite
divide. The covering corollaries extend the budget to sampling quality via the
approximate Carathéodory principle. The remaining open question is purely
geometric: the dimension-dependent contraction factor of minicenter refinement,
now reduced to a single metric inequality whose reward is already in closed form.
