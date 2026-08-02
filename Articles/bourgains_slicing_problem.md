# The Slice Hidden Inside a Box

## A geometric riddle with a multiplicative answer

Imagine a loaf of bread that lives not merely in three dimensions but in $n$ dimensions. Its volume is exactly $1$. How large a slice can we guarantee by cutting it with a hyperplane?

This innocent question points toward **Bourgain’s slicing problem**, one of the central organizing questions of high-dimensional convex geometry. In its broad form, it asks whether there is a universal number $c>0$, independent of the dimension, such that every convex body of volume $1$ in $\mathbb{R}^n$ has some hyperplane section whose $(n-1)$-dimensional volume is at least $c$. The word “universal” is the source of the difficulty: the same lower bound must survive as the number of dimensions grows without limit.

For arbitrary convex bodies, that dimension-free assertion remains a conjectural frontier. But for one fundamental family—positive axis-aligned boxes—the complete story is both exact and unexpectedly simple. Every such box has a central coordinate slice of volume at least $1$. No deterioration with dimension occurs, and the constant $1$ is best possible.

The proof is a miniature model of a recurring phenomenon in modern mathematics: geometry becomes transparent after it is translated into multiplication.

## Boxes as lists of widths

An axis-aligned box in $\mathbb{R}^n$ is determined by positive side lengths

$$
a_1,a_2,\ldots,a_n>0.
$$

Its volume is

$$
V=\prod_{j=1}^n a_j.
$$

The location of the box does not matter for the argument, so we may picture it as centered at the origin. A central coordinate hyperplane perpendicular to the $i$th axis cuts through the box while deleting the $i$th direction. The resulting section is itself a box of dimension $n-1$, with every side length except $a_i$. Its section volume is therefore

$$
S_i=\prod_{j\ne i}a_j.
$$

The crucial identity is immediate but powerful:

$$
S_i a_i=V.
$$

In words, **section volume multiplied by perpendicular width equals full volume**. This is the bridge between the geometric cut and the arithmetic of the side lengths.

Under the normalization $V=1$, the identity becomes

$$
S_i=\frac{1}{a_i}.
$$

A narrow direction produces a large perpendicular slice; a wide direction produces a small one. The geometry of every coordinate section is encoded in a reciprocal.

## The multiplicative pigeonhole principle

The ordinary pigeonhole principle says that if too many objects are forced into too few boxes, some box receives more than one object. Its multiplicative cousin says something equally elementary:

> **Multiplicative Pigeonhole Principle.** If $n\ge 1$, the positive numbers $a_1,\ldots,a_n$ have product $1$, then at least one of them is at most $1$.

Why? If every $a_i$ were strictly greater than $1$, multiplying them would give

$$
\prod_{i=1}^n a_i>1,
$$

contradicting the assumed product. The statement needs positivity and at least one factor. Neither condition is cosmetic: positivity lets inequalities behave predictably under multiplication, while positive dimension ensures that there is a width to choose.

This small observation identifies a direction $i$ with $a_i\le 1$. Since $S_i=1/a_i$, positivity gives

$$
S_i\ge 1.
$$

That is the entire slicing argument.

## The coordinate-box slicing theorem

The result can now be stated without any hidden machinery.

> **Coordinate-Box Slicing Theorem.** Let $n\ge 1$, and let an axis-aligned box in $\mathbb{R}^n$ have positive side lengths $a_1,\ldots,a_n$ and volume $\prod_i a_i=1$. Then there is an index $i$ such that the central coordinate hyperplane perpendicular to the $i$th axis cuts out an $(n-1)$-dimensional box of volume at least $1$.

**Proof sketch.** The product of the widths is $1$, so some width satisfies $a_i\le 1$. The perpendicular section has volume $S_i=\prod_{j\ne i}a_j$, and $S_i a_i=1$. Hence $S_i=1/a_i\ge 1$.

The constant cannot be improved. For the unit cube, every side length equals $1$, and every central coordinate section also has volume exactly $1$. Thus no theorem valid for all unit-volume axis-aligned boxes can guarantee a coordinate section larger than $1$.

There is also an exact local equivalence:

> **Width–Section Equivalence.** In a positive unit-volume axis-aligned box, a coordinate width satisfies $a_i\le 1$ if and only if its perpendicular coordinate section has volume $S_i\ge 1$.

This follows directly from $S_i=1/a_i$. It says more than existence: it completely classifies which coordinate directions yield large sections.

## A three-dimensional picture

Take a box with side lengths

$$
2,\quad \frac12,\quad 1.
$$

Its volume is $2\cdot \frac12\cdot 1=1$. The three central coordinate sections have areas

$$
\frac12\cdot 1=\frac12,\qquad 2\cdot 1=2,\qquad 2\cdot\frac12=1.
$$

The width $2$ corresponds to the small section $1/2$; the width $1/2$ corresponds to the large section $2$; and the width $1$ corresponds to a section of area $1$. Each width–section pair multiplies to $1$.

The effect becomes more dramatic in high dimensions. Suppose one side has length $10^{-6}$ while the remaining widths compensate so that the total volume stays $1$. The section perpendicular to that tiny direction has volume $10^6$. Volume normalization does not prevent extreme anisotropy; rather, it forces anisotropy in one direction to reappear as a large cross-section in the complementary directions.

## Logarithms reveal the balancing law

There is another way to see the principle. Write

$$
x_i=\log a_i.
$$

The unit-volume condition becomes

$$
\sum_{i=1}^n x_i=0.
$$

A finite list of real numbers summing to zero cannot consist entirely of positive numbers. Thus some $x_i\le 0$, which means $a_i\le 1$. Meanwhile,

$$
\log S_i=-x_i.
$$

So the theorem is an additive balancing statement in logarithmic coordinates: a nonpositive log-width becomes a nonnegative log-section. This viewpoint is numerically useful as well. In large dimensions, multiplying many very large and very small numbers can overflow or underflow on a computer, while adding logarithms remains stable.

The log picture also exposes a stronger identity. Since $S_i=1/a_i$,

$$
\prod_{i=1}^n S_i=\frac{1}{\prod_i a_i}=1.
$$

Thus the coordinate section volumes themselves form another positive unit-product family. Their geometric mean equals $1$, so at least one is at least $1$ and at least one is at most $1$. A box cannot make every coordinate section simultaneously small while retaining volume $1$.

## Why this is a model, not the whole slicing problem

Boxes are special because their volume factors perfectly into independent coordinate widths. An arbitrary convex body may be curved, tilted, or tapered. It has no canonical finite list of side lengths, and a section generally does not satisfy an exact relation of the form “section times width equals volume.”

For a general body, one studies a continuum of parallel slices. If a direction is fixed and $A(t)$ denotes the $(n-1)$-dimensional volume of the slice at position $t$, then a Fubini-type principle expresses total volume schematically as

$$
\operatorname{vol}_n(K)=\int A(t)\,dt.
$$

This is an integral analogue of multiplying a constant cross-sectional area by a width. For a box cut perpendicular to a coordinate axis, $A(t)$ is constant across the interior, and the integral collapses exactly to $S_i a_i$. For a general convex body, $A(t)$ varies, and controlling its maximum uniformly in dimension becomes much subtler.

That distinction is essential. The theorem for boxes does not settle the universal slicing conjecture for arbitrary convex bodies. Instead, it isolates the mechanism one would like to recover in a more flexible form: normalize total volume, find a direction that cannot be too wide in the relevant sense, and turn that directional control into a large section.

## Where the idea travels

The same product structure appears in several applied settings.

In **uncertainty quantification**, a rectangular parameter region has side lengths representing admissible ranges. Fixing one parameter leaves a lower-dimensional feasible region whose volume is the product of the remaining ranges. Under normalized total uncertainty, any parameter with range at most $1$ leaves a conditional region of volume at least $1$.

In **data geometry**, axis-aligned bounding boxes summarize feature scales. A narrow feature direction corresponds to a large complementary coordinate footprint after volume normalization. The theorem gives an exact diagnostic for this elementary model of anisotropy.

In **numerical integration and sampling**, product domains are ubiquitous. Conditioning on one coordinate produces a section, and the identity $S_i a_i=V$ provides a consistency check for domain decompositions and tensor-product grids.

In **optimization**, logarithmic side lengths turn multiplicative volume constraints into linear equations. Selecting a width no larger than the geometric mean becomes a one-pass operation, illustrating why geometric programming often prefers log coordinates.

## The algorithm inside the proof

The argument is constructive. Given positive widths with product $1$:

1. inspect the widths and choose an index $i$ minimizing $a_i$;
2. compute the complementary section volume as $S_i=1/a_i$;
3. report the coordinate hyperplane perpendicular to direction $i$.

Because the geometric mean of the widths is $1$, the minimum width is at most $1$. Therefore the returned section has volume at least $1$. The scan takes time proportional to $n$ and uses constant additional memory. When numerical scales are extreme, the same procedure can compare $\log a_i$ and evaluate section sizes in logarithmic form.

## A small theorem with a large silhouette

The coordinate-box theorem is elementary enough to explain on a blackboard in minutes, yet it captures the silhouette of a major geometric question. The normalization $V=1$ creates a conservation law. The factorization $S_i a_i=1$ turns that law into reciprocity. The multiplicative pigeonhole principle guarantees a narrow direction. Together, these ingredients force a large slice.

The broader slicing problem asks whether some analogue of this conclusion survives after the clean edges and independent widths of a box disappear. Boxes answer yes with the exact constant $1$. Their lesson is not that every convex body secretly factors, but that volume normalization demands compensation: thinness somewhere must be paid for somewhere else. In a box, the payment is visible as a reciprocal section. In general convex geometry, finding the right currency for that compensation is the heart of the problem.
