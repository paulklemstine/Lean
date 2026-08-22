# Geometry Between Dimensions: The Surface That Outgrows Every Space

## A shape with no number

Ask a geometer for the dimension of an object and you usually get a number. A curve is $1$-dimensional, a sheet of paper $2$-dimensional, a lump of clay $3$-dimensional. Fractal geometry loosened this a little: the Koch snowflake has dimension $\log 4 / \log 3 \approx 1.2619$, the Sierpiński gasket $\log 3/\log 2 \approx 1.585$. Dimension became a real number rather than an integer, but it stayed a *number*.

This article is about a shape for which no number will do.

The object is a surface — a genuine, concrete, bounded subset of a metric space, built by hand from ordinary rectangular boxes — with the following four properties simultaneously:

1. Its Hausdorff dimension exceeds every real number.
2. It cannot be copied, even with bounded distortion, into $\mathbb{R}^m$ for any $m$: no finite-dimensional Euclidean space is big enough to hold it.
3. It nevertheless fits inside the **Hilbert cube**, the infinite-dimensional box $[0,1] \times [0,1] \times \cdots$, as a topological subspace.
4. It has exactly as many points as the real line — and therefore, if the Continuum Hypothesis is true, exactly $\aleph_1$ points.

And there is a fifth property, the one that surprised us most: the surface's dimension is an *arithmetic* invariant. Whether it can be cut into finitely many pieces of bounded dimension is equivalent to a statement about whether a certain set of integers is finite. Feed it the primes and the answer is Euclid's theorem. Feed it the twin primes and the answer is an open problem.

## Building the thing

The construction is almost embarrassingly simple, which is part of the point. Work inside $\ell^2$, the space of square-summable real sequences $x = (x_0, x_1, x_2, \dots)$ with $\sum_i x_i^2 < \infty$, equipped with the distance $\|x-y\| = \big(\sum_i (x_i-y_i)^2\big)^{1/2}$. This is the canonical infinite-dimensional geometry: Pythagoras, extended to infinitely many perpendicular directions.

Inside it, pick a box with shrinking sides. Let

$$\text{side}(i) = 2^{-i}, \qquad H = \{x \in \ell^2 : 0 \le x_i \le 2^{-i} \text{ for every } i\}.$$

The sides shrink fast enough that $\sum_i 4^{-i} = 4/3$ converges, so every point of $H$ really is square-summable, with $\|x\| \le \sqrt{4/3} \approx 1.1547$. Call $H$ the **Hilbert box**.

Now carve $H$ into flat slabs. For each $n$, let the **$n$-th cell** be the set of points of $H$ whose coordinates beyond the $n$-th are all zero:

$$C_n = \{x \in H : x_i = 0 \text{ for all } i \ge n\} = [0,1] \times [0,\tfrac12] \times \cdots \times [0,2^{-(n-1)}] \times \{0\} \times \{0\} \times \cdots.$$

Each $C_n$ is a perfectly ordinary compact $n$-dimensional rectangular box, just tilted into the first $n$ coordinate axes of an infinite-dimensional space. And the cells are nested: $C_0 \subset C_1 \subset C_2 \subset \cdots$, because padding a vector with one more zero keeps it in the next cell.

The **aleph-one surface** is their union:

$$\mathcal{A} = \bigcup_{n=0}^{\infty} C_n.$$

That is the whole construction: an infinite staircase of boxes, each one dimension taller than the last, all packed into a single bounded region of $\ell^2$.

## Why its dimension is off the scale

Hausdorff dimension measures how the number of small balls needed to cover a set grows as the balls shrink. It is the definition that assigns $\log 4/\log 3$ to the Koch curve. It behaves in two ways that are decisive here.

First: **a Lipschitz map cannot increase Hausdorff dimension**. If $f$ satisfies $\|f(x)-f(y)\| \le K\|x-y\|$, then $\dim_H f(S) \le \dim_H S$ — squashing and bending can destroy dimension, never create it.

Second: **the dimension of a countable union is the supremum of the pieces**. Dimension is not additive; it is a maximum.

Apply the first fact twice to a single cell. On one side, the projection $\pi_n$ that reads off the first $n$ coordinates of a point of $\ell^2$ is $1$-Lipschitz onto $\mathbb{R}^n$ with the max-norm — because a single coordinate can never differ by more than the whole $\ell^2$ distance. On the other side, the map $\iota_n$ that takes a vector in $\mathbb{R}^n$ and pads it with zeros is $\sqrt{n}$-Lipschitz, because $n$ coordinate discrepancies, each at most the max-norm distance, combine in quadrature. The two maps are mutually inverse on the box, so dimension cannot drop in either direction, and the flat cell inherits exactly the dimension of the solid $n$-box it copies:

$$\dim_H C_n = n \quad \text{for every } n.$$

Now the second fact finishes the job. The surface contains cells of every finite dimension, so

$$\dim_H \mathcal{A} = \sup_n \dim_H C_n = \sup_n n = \infty.$$

There is no real number that is the dimension of $\mathcal{A}$. Every finite-dimensional Hausdorff measure of the surface — length, area, volume, and every fractional analogue — is infinite. We call such a set **transfinite-dimensional**.

## Three ways it refuses to be tamed

Transfinite dimension is not just a large number; it is a structural obstruction, and one single inequality — dimension does not increase under Lipschitz maps — generates all of its consequences.

**No bounded-distortion copy in Euclidean space.** Suppose $f$ maps the surface into $\mathbb{R}^m$ in such a way that it never collapses distances by more than a bounded factor: $\|f(x)-f(y)\| \ge K^{-1}\,\|x-y\|$. Such a map cannot lower dimension, so $\dim_H f(\mathcal{A}) \ge \dim_H \mathcal{A} = \infty$. But $f(\mathcal{A})$ sits in $\mathbb{R}^m$, whose dimension is $m$. Contradiction. **No finite-dimensional Euclidean space admits a bi-Lipschitz — indeed even a merely non-collapsing — image of the surface.**

**No triangulation.** Take the weakest imaginable notion of "cutting into $d$-dimensional pieces": a *Lipschitz $d$-triangulation* of a set $A$ is a **countable** family of Lipschitz maps $\varphi_j$, each defined on some subset $D_j \subseteq \mathbb{R}^d$, whose images together cover $A$. The cells may overlap, be curved, be wildly non-simplicial; there may be countably infinitely many of them. Even so, each image has dimension at most $d$, and a countable supremum of numbers $\le d$ is $\le d$. So a triangulable set has $\dim_H \le d$, and the surface has none for any $d$. **The aleph-one surface admits no finite triangulation — and no countable one either.**

**No finite-dimensional atlas.** Same argument, with $C^1$ maps from a finite-dimensional model space in place of Lipschitz maps from $\mathbb{R}^d$: continuously differentiable maps are locally Lipschitz on convex sets, so a countable $C^1$ atlas would again cap the dimension at the model's rank. **The surface is not a countable-atlas manifold over any finite-dimensional model.**

These are not vacuous impossibility statements. When you *shrink* the surface, the constructions reappear: if you use only the cells whose dimensions lie in a **finite** set $S$, the resulting object genuinely is triangulated, by exactly $|S|$ cells of dimension $\max S$ — restrict to the first $d$ coordinates, then pad with zeros. The impossibility theorems mark a precise boundary, not an empty region.

## Yet it fits in a box

Here is where the story turns. Everything above says the surface is too big for finite dimensions. But it is not too big for *the* infinite-dimensional box.

The Hilbert cube is the countable product $Q = [0,1]^{\mathbb{N}}$ with the product topology — a compact, metrizable space, the universal home of all separable metric spaces. Our $\ell^2$ Hilbert box $H$ turns out to be a faithful copy of it. Two things must be checked, and both are genuine analysis rather than bookkeeping.

*Compactness.* A point of the product box $\prod_i [0,2^{-i}]$, read coordinatewise, gives a point of $\ell^2$. The map is injective with image exactly $H$; the delicate part is continuity, since product convergence is coordinatewise and $\ell^2$ convergence is not. It works because the tails are uniformly small: the coordinates beyond the $N$-th contribute at most

$$T(N) = \sum_{i \ge N} 4^{-i} = \tfrac{4}{3}\cdot 4^{-N},$$

to the squared norm, a bound *independent of the point*. So the finite truncations converge uniformly to the identity, and uniform limits of continuous maps are continuous. Tychonoff makes the product box compact; a continuous bijection from a compact space to a Hausdorff space is a homeomorphism. Hence **$H$ is compact and homeomorphic to the Hilbert cube** — and every subset of $H$, the surface included, embeds topologically in the Hilbert cube.

So the surface is simultaneously (i) unable to sit bi-Lipschitzly in any $\mathbb{R}^m$ and (ii) able to sit topologically inside a compact space. There is no contradiction: **Hausdorff dimension is not a topological invariant.** It depends on the metric, and the homeomorphism between $H$ and $Q$ distorts distances without bound. The Hilbert cube is topologically tame and metrically monstrous.

## The skeleton and its shadow

Where exactly does the surface sit inside its box? Take the *diagonal point* $\delta = (1, \frac12, \frac14, \frac18, \dots)$, whose every coordinate is maximal. It lies in $H$ but in no cell, since it has infinitely many nonzero coordinates. Yet its distance to the $n$-th cell is exactly the tail

$$\operatorname{dist}(\delta, C_n) = \Big(\sum_{i \ge n} 4^{-i}\Big)^{1/2} = \frac{2}{\sqrt3}\,2^{-n} \longrightarrow 0.$$

The same estimate works at every point of the box, so **the closure of the surface is exactly the Hilbert box.** The surface is a *dense skeleton*: it carries all of the box's dimension while missing "most" of its points. It is a countable union of compact cells (σ-compact), but it is neither closed nor compact, and it is a proper subset of its own closure.

And now a genuine surprise. Being dimension-theoretically maximal does not make you topologically large. Riesz's theorem says a compact set in an infinite-dimensional normed space has empty interior; so a countable union of compact sets is *meagre* — topologically negligible in Baire's sense. The surface is such a union. Therefore:

**The aleph-one surface is nowhere dense and meagre in $\ell^2$, and its complement is dense** — while having infinite Hausdorff dimension. Dimension and category are orthogonal notions of size, and this object separates them cleanly.

Running the same machinery in reverse shows that the *ambient* space inherits rigidity from the surface: a normed space containing a transfinite-dimensional subset must be infinite-dimensional and cannot be locally compact. Pushing one step further, **every ball of $\ell^2$, however small, contains a flat cube of every finite dimension** — of side $r/(2(\sqrt n+1))$ inside a ball of radius $r$ — and hence has infinite Hausdorff dimension itself. Transfinite dimension in $\ell^2$ is a purely local phenomenon. Combined with Baire's theorem this yields a clean dichotomy: **any set that is a countable union of closed sets is either meagre or of infinite Hausdorff dimension.** The surface sits on the first side, a ball on the second.

## Where the primes come in

Nothing forced us to use *all* the cells. For any set $S \subseteq \mathbb{N}$ define the **arithmetic surface**

$$\mathcal{A}_S = \bigcup_{n \in S} C_n, \qquad \dim_H \mathcal{A}_S = \sup_{n \in S} n.$$

That supremum is finite precisely when $S$ is bounded, and — for subsets of $\mathbb{N}$ — bounded is the same as finite. So we get an exact dictionary between arithmetic and geometry:

> **$\mathcal{A}_S$ has infinite Hausdorff dimension $\iff$ $S$ is infinite $\iff$ $\mathcal{A}_S$ admits no triangulation in any finite dimension.**

Take $S$ to be the primes. The prime surface is transfinite-dimensional, and admits no finite triangulation — which is to say, Euclid's theorem has become a statement about a geometric object's resistance to being cut into pieces.

Take $S$ to be the twin primes $\{p : p \text{ and } p+2 \text{ both prime}\}$. Then the twin-prime surface has infinite Hausdorff dimension **if and only if** there are infinitely many twin primes. A conjecture about the distribution of integers has been converted, exactly and without loss, into the question of whether one particular subset of $\ell^2$ can be triangulated.

## The $\aleph_1$ in the name — and a warning

The construction was originally motivated by a tempting phrase: *a surface of Hausdorff dimension $\aleph_1$*. Two things can be said about it.

The honest, true statement is about *cardinality*. Each cell $C_1$ already contains a segment, so the surface has at least continuum many points; and $\ell^2$ has at most continuum many. Hence **the surface has exactly $\mathfrak{c}$ points**, and under the Continuum Hypothesis — where $\aleph_1 = \mathfrak{c}$ — exactly $\aleph_1$ of them. This is the sense in which it is an "aleph-one surface".

The tempting statement, that the *dimension* is $\aleph_1$, is a category error, and it fails in a way that no clever reformulation can repair. Hausdorff dimension takes values in $[0,\infty]$, which has cardinality $\mathfrak{c}$ but, crucially, the *order type* of the real line. One might still hope to smuggle in $\aleph_1$ by exhibiting an $\aleph_1$-long transfinite tower of sets whose dimensions strictly increase, and calling the level at $\omega_1$ "the $\aleph_1$-st dimension". This is impossible:

> **Every well-ordered chain of Hausdorff dimensions is countable.**

The proof is a two-line order-theoretic squeeze. If a set $D \subseteq [0,\infty]$ of dimension values is well-founded, each non-maximal $d \in D$ has an immediate successor in $D$, and the open gap between them contains a rational number. Distinct elements receive distinct rationals, so $D$ injects into $\mathbb{Q}$ up to a single exceptional maximum, and is therefore countable. Consequently no strictly increasing $\aleph_1$-indexed hierarchy of Hausdorff dimensions exists — in any metric space whatsoever. (Drop the well-ordering and the ceiling relaxes to $\mathfrak{c}$; it is precisely the *ordinal shape* an $\aleph_1$-hierarchy must have that collapses it to countable length.) Countable chains, on the other hand, are everywhere: $0, 1, 2, 3, \dots$ is realised by the cells themselves, so the ceiling is sharp at $\aleph_0$.

So the final picture is this. There is no surface of Hausdorff dimension $\aleph_1$, and there never will be — a theorem, not a failure of ingenuity. But the object the phrase was reaching for exists, and it is concrete: a bounded, non-compact, dense, meagre, σ-compact skeleton of flat boxes inside a compact Hilbert cube, with continuum many points, with dimension above every real number, admitting no bounded-distortion picture in any Euclidean space, no triangulation of any dimension, and encoding the infinitude of the primes in its refusal to be cut apart.

Geometry between dimensions, with the number line left behind.
