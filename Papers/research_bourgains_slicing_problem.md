# Coordinate Hyperplane Slicing of Unit-Volume Boxes

## A finite multiplicative model for Bourgain’s slicing problem

**Author:** Aristotle  
**Date:** August 2, 2026

## Abstract

Bourgain’s slicing problem asks whether every convex body of volume $1$ in $\mathbb{R}^n$ admits a hyperplane section whose $(n-1)$-dimensional volume is bounded below by a positive universal constant independent of $n$. This paper establishes an exact special case for positive axis-aligned boxes and identifies the finite multiplicative mechanism behind it. If a box has side lengths $a_1,\ldots,a_n>0$, its volume is $V=\prod_i a_i$, while the central coordinate section perpendicular to direction $i$ has volume $S_i=\prod_{j\ne i}a_j$. Hence $S_i a_i=V$. For $V=1$, a multiplicative pigeonhole principle implies that some $a_i\le 1$, and therefore $S_i\ge 1$. We prove the sharper equivalence $a_i\le 1$ if and only if $S_i\ge 1$, show that the universal constant $1$ is optimal for this class, derive further identities among all coordinate sections, and present a linear-time algorithm for locating a guaranteed large section. Logarithmic coordinates convert the argument into a zero-sum principle and provide a numerically stable implementation. The result is a complete box model of slicing, while remaining distinct from the unresolved dimension-free assertion for arbitrary convex bodies.

## 1. Introduction

Let $K\subset\mathbb{R}^n$ be a convex body, meaning a compact convex set with nonempty interior. The broad slicing question asks whether volume normalization forces a substantial codimension-one section. More precisely, the dimension-free slicing conjecture seeks a constant $c>0$, independent of $n$ and of $K$, such that whenever

$$
\operatorname{vol}_n(K)=1,
$$

there exists an affine hyperplane $H$ for which

$$
\operatorname{vol}_{n-1}(K\cap H)\ge c.
$$

The significance of the conjecture lies in its uniformity across dimensions. Bounds that decay with $n$ do not answer the question. The geometry of a general body can be highly anisotropic, and its cross-sectional profile can vary continuously along every direction.

This paper studies the exact statement for axis-aligned boxes. Although boxes form a restricted class of convex bodies, they expose a structural bridge that is useful in thinking about the general problem. Their volume factors into finitely many positive widths, and every coordinate section is obtained by omitting one factor. Consequently, slicing becomes a finite multiplicative selection problem.

The principal theorem is as follows.

> **Coordinate-Box Slicing Theorem.** Let $n\ge 1$, and let $B\subset\mathbb{R}^n$ be an axis-aligned box with positive side lengths $a_1,\ldots,a_n$ and volume $1$. Then some central coordinate hyperplane section of $B$ has $(n-1)$-dimensional volume at least $1$.

The constant $1$ is independent of dimension and optimal for this class: the unit cube has all coordinate section volumes equal to $1$.

The proof has three ingredients. First, the section perpendicular to direction $i$ has volume $S_i=\prod_{j\ne i}a_j$. Second, $S_i a_i=1$. Third, not every positive factor in a finite product equal to $1$ can exceed $1$. Choosing a width $a_i\le 1$ yields $S_i=1/a_i\ge 1$.

The exact reciprocal relation also produces a pointwise classification:

$$
a_i\le 1\quad\Longleftrightarrow\quad S_i\ge 1.
$$

This paper develops these statements self-containedly, gives algorithms and examples, and explains both the value and the limitation of the box model. In particular, no claim is made that the argument proves the dimension-free conjecture for arbitrary convex bodies.

## 2. Geometric setting and definitions

### 2.1 Axis-aligned boxes

Fix an integer $n\ge 1$. Let $a_1,\ldots,a_n$ be positive real numbers. An axis-aligned box with these side lengths may be written as

$$
B=\prod_{i=1}^n\left[-\frac{a_i}{2},\frac{a_i}{2}\right].
$$

Centering at the origin is convenient but inessential: translations preserve all volumes under discussion. Positivity ensures that $B$ has nonempty interior and full dimension $n$.

> **Definition 2.1 (Box volume).** The $n$-dimensional volume of $B$ is
>
> $$
> V(B)=\prod_{i=1}^n a_i.
> $$

The product formula follows from the standard volume of a Cartesian product of intervals.

### 2.2 Central coordinate hyperplane sections

For each $i\in\{1,\ldots,n\}$, let

$$
H_i=\{x\in\mathbb{R}^n:x_i=0\}
$$

be the central coordinate hyperplane perpendicular to the $i$th coordinate axis. The section $B\cap H_i$ is naturally an $(n-1)$-dimensional box with all side lengths except $a_i$.

> **Definition 2.2 (Coordinate section volume).** The $(n-1)$-dimensional volume of the central coordinate section perpendicular to direction $i$ is
>
> $$
> S_i(B)=\prod_{\substack{1\le j\le n\\j\ne i}}a_j.
> $$

When $n=1$, the section is zero-dimensional. The empty product is $1$, in agreement with the convention that a point has zero-dimensional volume $1$. Thus all statements below include the one-dimensional case.

### 2.3 Normalization

The slicing problem is sensitive to scale. If all coordinates are multiplied by $t>0$, full volume scales by $t^n$ and section volume by $t^{n-1}$. We therefore impose the normalization

$$
V(B)=1.
$$

For a general box of volume $V>0$, rescaling by $V^{-1/n}$ produces a unit-volume box. Section bounds can then be translated back to the original scale; this is discussed in Section 6.

## 3. The multiplicative bridge

The key geometric identity is a factorization of full volume into a perpendicular width and its complementary section.

> **Lemma 3.1 (Section–width product identity).** For every positive axis-aligned box $B$ and every coordinate direction $i$,
>
> $$
> S_i(B)a_i=V(B).
> $$

**Proof sketch.** By definition,

$$
S_i(B)a_i=\left(\prod_{j\ne i}a_j\right)a_i.
$$

The right-hand side contains every factor $a_j$ exactly once, so it equals $\prod_{j=1}^n a_j=V(B)$.

Under unit-volume normalization, Lemma 3.1 becomes the reciprocal formula

$$
S_i(B)=\frac{1}{a_i}.
$$

This formula is the complete geometric–arithmetic dictionary for coordinate sections of boxes.

The required selection principle is finite and elementary.

> **Lemma 3.2 (Finite multiplicative pigeonhole principle).** Let $n\ge 1$ and let $a_1,\ldots,a_n>0$. If
>
> $$
> \prod_{i=1}^n a_i=1,
> $$
>
> then there exists $i$ such that $a_i\le 1$.

**Proof sketch.** Suppose instead that $a_i>1$ for every $i$. The product of two positive numbers greater than $1$ is greater than $1$, and induction gives $\prod_i a_i>1$. This contradicts the product normalization.

A logarithmic proof is equally informative. Set $x_i=\log a_i$. The product condition is equivalent to $\sum_i x_i=0$. If every $a_i>1$, then every $x_i>0$, making their sum positive, again a contradiction.

The positivity assumption guarantees that logarithms and reciprocal inequalities are valid. Positive dimension guarantees that an index exists.

## 4. Main slicing results

### 4.1 Existence of a large coordinate section

> **Theorem 4.1 (Coordinate-Box Slicing Theorem).** Let $n\ge 1$. If $B\subset\mathbb{R}^n$ is an axis-aligned box with positive side lengths and $V(B)=1$, then there exists an index $i$ such that
>
> $$
> S_i(B)\ge 1.
> $$

**Proof sketch.** By Lemma 3.2, some side length satisfies $a_i\le 1$. Lemma 3.1 and $V(B)=1$ give $S_i(B)a_i=1$. Since $a_i>0$,

$$
S_i(B)=\frac{1}{a_i}\ge 1.
$$

Thus the central coordinate hyperplane $H_i$ provides the required section.

The theorem gives more than the existence of an arbitrary hyperplane. It finds a section among the fixed family of $n$ central coordinate hyperplanes. In this class no optimization over translations or directions is necessary.

### 4.2 Pointwise width–section equivalence

> **Theorem 4.2 (Width–Section Equivalence).** Let $B$ be a positive axis-aligned box of volume $1$. For every coordinate direction $i$,
>
> $$
> a_i\le 1\quad\Longleftrightarrow\quad S_i(B)\ge 1.
> $$

**Proof sketch.** The reciprocal formula gives $S_i(B)=1/a_i$. For $a_i>0$, the inequality $a_i\le 1$ is equivalent to $1/a_i\ge 1$.

This theorem classifies all guaranteed large coordinate sections, not just one of them. The number of coordinate sections with volume at least $1$ is exactly the number of widths at most $1$.

### 4.3 Optimality

> **Proposition 4.3 (Sharpness of the constant).** The lower bound $1$ in Theorem 4.1 is optimal among all positive unit-volume axis-aligned boxes.

**Proof sketch.** Take the unit cube, for which $a_i=1$ for every $i$. Its volume is $1$, and each coordinate section has volume

$$
S_i(B)=\prod_{j\ne i}1=1.
$$

Therefore no constant strictly larger than $1$ can be guaranteed for every box.

### 4.4 Extremal characterization

The sharpness example has a useful converse.

> **Proposition 4.4 (Equality characterization for the maximal coordinate section).** Let $B$ be a positive unit-volume axis-aligned box. Then
>
> $$
> \max_i S_i(B)=1
> $$
>
> if and only if $a_i=1$ for every $i$.

**Proof sketch.** If every width equals $1$, every section equals $1$. Conversely, suppose the maximum section volume is $1$. Theorem 4.1 implies the maximum is at least $1$, so every $S_i\le 1$. By Theorem 4.2, no width can be below $1$; hence every $a_i\ge 1$. Their product is $1$, so every factor must equal $1$.

Thus the cube is the unique unit-volume box, up to translation, whose largest central coordinate section is as small as possible.

## 5. Consequences for the full family of sections

The reciprocal relation yields identities involving all $n$ coordinate sections.

> **Proposition 5.1 (Product of coordinate section volumes).** For a positive box of volume $V$,
>
> $$
> \prod_{i=1}^n S_i(B)=V^{n-1}.
> $$

**Proof sketch.** In the product $\prod_i S_i$, each width $a_j$ appears in every section except $S_j$, hence exactly $n-1$ times. Therefore

$$
\prod_{i=1}^nS_i(B)=\prod_{j=1}^n a_j^{n-1}=V^{n-1}.
$$

For $V=1$, this gives

$$
\prod_{i=1}^n S_i(B)=1.
$$

Consequently, the geometric mean of the section volumes equals $1$.

> **Corollary 5.2 (Two-sided section balance).** For a positive unit-volume box, at least one coordinate section has volume at least $1$, and at least one coordinate section has volume at most $1$.

**Proof sketch.** A positive finite family with product $1$ cannot have every member below $1$, nor can it have every member above $1$.

The first half recovers Theorem 4.1. The second half shows that volume normalization also prevents all coordinate sections from being uniformly large.

> **Corollary 5.3 (Best section and narrowest width).** For a positive unit-volume box,
>
> $$
> \max_i S_i(B)=\frac{1}{\min_i a_i}.
> $$

**Proof sketch.** Since $S_i=1/a_i$ and reciprocal order reverses on positive numbers, maximizing $S_i$ is equivalent to minimizing $a_i$.

This identity turns the geometric optimization problem into a simple scan through the widths.

## 6. Scaling beyond unit volume

Although unit volume is the natural slicing normalization, the box theorem has an equivalent scale-covariant form.

> **Theorem 6.1 (Geometric-mean slicing bound).** Let $B$ be a positive axis-aligned box in $\mathbb{R}^n$ with volume $V>0$. Then some central coordinate section satisfies
>
> $$
> S_i(B)\ge V^{(n-1)/n}.
> $$

**Proof sketch.** The geometric mean of the widths is $V^{1/n}$. Some width therefore satisfies $a_i\le V^{1/n}$; otherwise their product would exceed $V$. Using $S_i=V/a_i$ gives

$$
S_i(B)\ge \frac{V}{V^{1/n}}=V^{(n-1)/n}.
$$

The bound is sharp for cubes with side length $V^{1/n}$. Setting $V=1$ recovers Theorem 4.1.

This form clarifies dimensions: an $n$-volume raised to the power $(n-1)/n$ has the units of an $(n-1)$-volume.

## 7. Algorithms

### 7.1 Direct selection algorithm

The proof of Theorem 4.1 is constructive.

> **Algorithm 7.1 (Narrowest-width section selection).** Given positive widths $a_1,\ldots,a_n$ with product $1$, choose an index minimizing $a_i$ and return the central coordinate section perpendicular to that direction.

**Correctness.** Since the geometric mean is $1$, the minimum width is at most $1$. Corollary 5.3 shows that its perpendicular section is the largest coordinate section, with volume $1/\min_i a_i\ge 1$.

**Complexity.** A single scan finds the minimum in $O(n)$ time and $O(1)$ auxiliary space. If the product normalization must also be checked directly, multiplication requires another $O(n)$ operations, or it can be folded into the same scan.

### 7.2 Numerically stable logarithmic algorithm

Products can overflow or underflow when $n$ is large or the widths have extreme scales. Define $x_i=\log a_i$. Then

$$
\log V=\sum_i x_i,
\qquad
\log S_i=\log V-x_i.
$$

For a unit-volume box, the normalization becomes $\sum_i x_i=0$ and $\log S_i=-x_i$.

> **Algorithm 7.2 (Log-domain section evaluation).** Compute $x_i=\log a_i$, form $L=\sum_i x_i$, select an index minimizing $x_i$, and report the logarithmic section volume $L-x_i$.

**Correctness.** The logarithm is strictly increasing, so minimizing $x_i$ is equivalent to minimizing $a_i$. The product identity becomes additive, giving the exact logarithmic section volume.

**Complexity.** The algorithm uses $O(n)$ logarithm evaluations, $O(n)$ arithmetic operations, and $O(1)$ auxiliary space if section values are not all stored. For floating-point data, one may regard $|L|$ as a normalization residual instead of requiring exact equality.

### 7.3 Verification diagnostics

For numerical examples, three residuals are useful:

$$
r_V=\left|\prod_i a_i-1\right|,
$$

$$
r_i=|S_i a_i-1|,
$$

and, in the log domain,

$$
r_{\log}=\left|\sum_i\log a_i\right|.
$$

The first checks normalization, the second checks every section–width identity, and the third remains reliable for extreme scales. These are computational diagnostics rather than substitutes for the exact hypotheses of the theorems.

## 8. Examples

### 8.1 A balanced rectangular box

Let

$$
(a_1,a_2,a_3)=\left(2,\frac12,1\right).
$$

The volume is $1$. The section volumes are

$$
S_1=\frac12,
\qquad
S_2=2,
\qquad
S_3=1.
$$

The unique width below $1$ yields the unique section above $1$, while the width equal to $1$ yields a section equal to $1$.

### 8.2 Strong anisotropy

Consider the four-dimensional widths

$$
(10,10,10,10^{-3}).
$$

Their product is $1$. The sections perpendicular to the first three coordinates have volume $0.1$, while the section perpendicular to the last coordinate has volume $1000$. A very thin direction forces a very large complementary section.

### 8.3 Several large sections

Take

$$
\left(4,\frac12,\frac12,1\right).
$$

The product is $1$. The section volumes are

$$
\left(\frac14,2,2,1\right).
$$

There are two widths below $1$ and exactly two sections above $1$, illustrating the pointwise equivalence of Theorem 4.2.

### 8.4 The extremal cube

For $a_i=1$ in every dimension, all coordinate sections equal $1$. This simultaneously attains the lower bound and demonstrates its sharpness.

## 9. Relation to general slicing

For a coordinate box, the cross-sectional area perpendicular to a fixed coordinate direction is constant throughout the interior. If $A_i(t)$ denotes the $(n-1)$-dimensional volume of the slice at coordinate $x_i=t$, then

$$
A_i(t)=S_i
$$

for $|t|<a_i/2$, and it vanishes outside the box. Consequently,

$$
V(B)=\int_{-a_i/2}^{a_i/2}A_i(t)\,dt=S_i a_i.
$$

For an arbitrary convex body $K$, the analogous sectional profile $A_u(t)$ in a unit direction $u$ generally varies with $t$. A Fubini or coarea principle still gives

$$
\operatorname{vol}_n(K)=\int_{\mathbb{R}}A_u(t)\,dt,
$$

but there is no finite list of independent widths and no reason for $A_u$ to be constant. One must control both the effective support of the profile and the concentration of its mass. This is where the finite product argument ceases to suffice.

The box theorem should therefore be interpreted as a structural model. It isolates a successful pattern:

1. normalize total volume;
2. express volume through a directional section profile and a transverse scale;
3. select a direction whose transverse scale is controlled;
4. deduce a lower bound for a section.

For boxes, each step is exact and elementary. For general convex bodies, establishing dimension-independent substitutes is the substantive challenge.

## 10. Applications and interpretations

### 10.1 Product probability models

A uniform distribution on a box is a product distribution. Fixing coordinate $i$ leaves a uniform measure on the complementary product domain. The section volume $S_i$ records the unnormalized mass of that fiber. Under unit-volume normalization, the identity $S_i=1/a_i$ expresses a reciprocal relationship between marginal support width and fiber size.

### 10.2 Rectangular uncertainty sets

In robust optimization, a box may represent independent parameter ranges. Conditioning on one parameter produces a feasible cross-section in the remaining parameters. If total rectangular volume is normalized, at least one parameter range is no larger than the reference scale, and conditioning along that parameter leaves a complementary feasible region of volume at least $1$.

### 10.3 Feature scaling and anisotropy

Axis-aligned bounding boxes are basic summaries of multivariate data. The logarithmic widths $x_i=\log a_i$ decompose anisotropy additively. Unit volume imposes zero total log-scale, while the associated log-section sizes are $-x_i$. Thus the feature with smallest scale has the largest complementary footprint.

### 10.4 Tensor-product computation

Quadrature, grids, and separable partial differential equation discretizations often use product domains. Omitting one coordinate creates a face or central slice whose measure is exactly the complementary product. The section–width identity supplies a direct consistency relation among full-domain and reduced-domain measures.

## 11. Limitations

The assumptions define the scope precisely.

First, axis alignment provides the distinguished coordinate sections. Rotated boxes can be handled by rotating coordinates, but a general parallelotope requires tracking how hyperplane measure transforms under a linear map.

Second, strict positivity of the widths is essential for a full-dimensional body and for reciprocal reasoning. Degenerate boxes have zero full volume and lie outside the normalized setting.

Third, the theorem considers central coordinate sections. For boxes, parallel translates through the interior have the same section volume, so centrality costs nothing. That constancy fails for general convex bodies.

Fourth, the result does not prove the universal slicing conjecture for arbitrary convex bodies. The exact product factorization is a special property of Cartesian products.

## 12. Future directions

A first extension is to invertible linear images of boxes, or parallelotopes. Full volume transforms by the absolute determinant, while hyperplane measure transforms through the restriction of the linear map to the section. Formulating the resulting directional factors would generalize the multiplicative bridge beyond orthogonal axes.

Ellipsoids provide a second natural class. Representing an ellipsoid as the image of a Euclidean ball under a positive-definite linear map connects section volumes to eigenvalues and determinant normalization.

A broader development requires a precise measure-theoretic account of affine hyperplane volume, using either Hausdorff measure or isometric parametrizations. This supports the integral identity for variable section profiles.

For general convex bodies, affine normalization is central. Barycenters, covariance operators, and isotropic position translate geometry into probabilistic information. A coarea or Fubini bridge can then relate hyperplane sections to densities of one-dimensional marginals.

Before a universal bound, dimension-dependent lower bounds offer an intermediate target. They test the complete geometric framework without assuming the unresolved dimension-free step.

## 13. Conclusion

For positive axis-aligned boxes, the slicing question has an exact answer. Full volume factors as a coordinate section volume times the omitted width. A unit product cannot have every factor greater than $1$, so some width is at most $1$; its reciprocal section volume is at least $1$. The same identity yields an if-and-only-if classification of large sections, a sharpness theorem, a product law for all coordinate sections, and a linear-time selection algorithm.

The cube shows that the constant $1$ is optimal. Logarithmic coordinates reveal the theorem as a zero-sum balance law and make its computation stable across extreme scales. These conclusions form a complete theory for coordinate slicing of boxes and a transparent finite multiplicative model for the broader slicing problem. The remaining leap—from constant section profiles and factored widths to arbitrary convex bodies—is precisely where the deeper geometry begins.
