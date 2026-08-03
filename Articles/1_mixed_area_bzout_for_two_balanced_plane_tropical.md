# The Missing Half in Tropical Bézout Counting

## When area counts crossings

A line drawn on ordinary paper is thin, straight, and familiar. A tropical line is stranger: it looks like three rays meeting at a central vertex, rather like a railway junction extending toward three horizons. Yet tropical curves are not merely angular imitations of classical curves. They encode algebraic information in a piecewise-linear landscape, turning difficult questions about polynomial equations into questions about polygons, slopes, and weighted crossings.

One of the most beautiful promises of this translation is that intersections can be counted by area. Give each plane tropical curve a Newton polygon—a lattice polygon whose vertices have integer coordinates—and the geometry of those polygons predicts how often the curves meet. This resembles the classical Bézout principle: curves of degrees $d$ and $e$ have $de$ intersections when multiplicity is counted correctly and the ambient setting is chosen appropriately.

But area comes in two common units, and confusing them creates a factor-of-two error. For the standard degree triangles that represent plane curves of degrees $d$ and $e$, the raw polarization of **normalized lattice area** is not $de$. It is $2de$. The missing half is not a technical nuisance; it is the conversion factor between two natural ways to measure a lattice triangle.

This article explains why that factor appears, how the smallest example exposes it immediately, and why the corrected formula has exactly the symmetry and additivity expected of a genuine mixed-area intersection invariant.

## The triangle behind a degree

Start with the standard lattice triangle

$$
\Delta=\operatorname{conv}\{(0,0),(1,0),(0,1)\}.
$$

Its Euclidean area is $1/2$. In lattice geometry it is often more convenient to declare this primitive triangle to have area $1$. That convention defines **normalized lattice area** in the plane:

$$
A(P)=2\operatorname{Area}_{\mathrm{Euc}}(P).
$$

Thus $A(\Delta)=1$. Dilating the triangle by a natural number $d$ multiplies both side lengths by $d$ and therefore multiplies area by $d^2$. The normalized area of the degree-$d$ triangle is consequently

$$
A(d\Delta)=d^2.
$$

For standard plane curves, $d\Delta$ is the Newton triangle associated with degree $d$. This simple quadratic law is all that is needed for the central calculation.

The sum of two polygons here means their **Minkowski sum**:

$$
P+Q=\{p+q:p\in P,\ q\in Q\}.
$$

For homothetic standard triangles, Minkowski addition adds the dilation factors:

$$
d\Delta+e\Delta=(d+e)\Delta.
$$

The raw area polarization is the increase in area left after subtracting the separate contributions:

$$
D(d,e)=A((d+e)\Delta)-A(d\Delta)-A(e\Delta).
$$

Substituting the quadratic area law gives

$$
D(d,e)=(d+e)^2-d^2-e^2=2de.
$$

This is the central identity. It is nothing more mysterious than the cross term in a square, but that cross term controls the normalization of tropical intersection counting.

## The two-line test

The fastest way to detect a normalization error is to test the smallest nontrivial case. Set $d=e=1$. Two generic tropical lines have stable intersection number $1$, just as two ordinary projective lines meet once. But their Newton triangles satisfy

$$
A(2\Delta)-A(\Delta)-A(\Delta)=4-1-1=2.
$$

So the statement “intersection number equals the raw difference of normalized areas” predicts $2$ where geometry requires $1$. The formula fails already for two lines.

This example is decisive because no complicated combinatorics can hide inside it. The primitive triangle has normalized area $1$; doubling it produces normalized area $4$; and the difference is visibly $2$. Any convention claiming that this raw difference is the Bézout number has mixed up normalized and Euclidean area.

The corrected rule is

$$
I(P,Q)=\frac{A(P+Q)-A(P)-A(Q)}{2},
$$

where $A$ is normalized lattice area and $I(P,Q)$ denotes the mixed-area quantity appropriate for plane intersection counting. For degree triangles this becomes

$$
I(d\Delta,e\Delta)=\frac{2de}{2}=de.
$$

There is an equivalent convention with no visible factor of $1/2$: use Euclidean area instead. Since normalized area is twice Euclidean area in the plane,

$$
I(P,Q)=\operatorname{Area}_{\mathrm{Euc}}(P+Q)
-\operatorname{Area}_{\mathrm{Euc}}(P)
-\operatorname{Area}_{\mathrm{Euc}}(Q).
$$

Neither convention is more correct. Trouble begins only when the normalized-area unit is inserted into the Euclidean-area formula without compensating for the change of scale.

## Why the uncorrected formula never works in positive degree

The two-line example is not an isolated accident. If $d>0$ and $e>0$, then $de>0$, and the identity $D(d,e)=2de$ shows that

$$
D(d,e)-de=de>0.
$$

Therefore the raw normalized-area difference can never equal the usual Bézout number for a pair of positive degrees. It always doubles it.

This matters conceptually. A mistaken formula might sometimes survive small tests because two errors cancel or because a degenerate input makes both sides vanish. Here the positive-degree theorem rules that out entirely. The only cases in which $2de=de$ are those with $de=0$, corresponding to at least one zero degree. Every genuine positive-degree intersection detects the discrepancy.

## The fingerprint of mixed area

A plausible intersection invariant should not merely produce the right number once. It should behave correctly when its inputs are exchanged or assembled from pieces. The raw polarization $D$ has both properties.

First, it is symmetric:

$$
D(d,e)=2de=2ed=D(e,d).
$$

That matches the geometric fact that counting intersections of the first curve with the second should not depend on their order.

Second, it is additive in either degree. If a degree is split as $a+b$, then

$$
D(a+b,e)=2(a+b)e=2ae+2be=D(a,e)+D(b,e).
$$

After division by $2$, the corrected quantity inherits the same behavior:

$$
I((a+b)\Delta,e\Delta)=I(a\Delta,e\Delta)+I(b\Delta,e\Delta).
$$

This resembles distributivity. If one geometric input is assembled from contributions of degrees $a$ and $b$, its interaction with degree $e$ is the sum of the two interactions. Symmetry and additivity are the characteristic fingerprints of a bilinear mixed quantity hidden inside a quadratic area function.

There is a useful analogy with the elementary identity

$$
\lVert u+v\rVert^2-\lVert u\rVert^2-\lVert v\rVert^2=2\langle u,v\rangle.
$$

A squared norm is quadratic, and polarization extracts twice the associated inner product. Area under Minkowski addition behaves similarly: a quadratic measurement of a sum contains two copies of the mixed interaction. Dividing by $2$ extracts the bilinear part in the chosen normalization.

## From railway junctions to polynomial systems

Why care about a factor of two in a polygon calculation? Because tropical geometry is a bridge between several mathematical worlds.

On one side lie polynomial systems. A polynomial in two variables carries a set of exponent vectors, and their convex hull is its Newton polygon. On another side lies a piecewise-linear curve determined by competing affine functions. On a third side lies convex geometry, where Minkowski sums and areas are natural. Intersection theory connects all three: the combinatorics of Newton polygons predicts weighted counts of curve intersections.

Such counts appear wherever sparse polynomial systems matter. They can guide equation solving, reveal how the pattern of monomials constrains the number of solutions, and provide polyhedral models for degenerations in algebraic geometry. Tropical methods also turn nonlinear phenomena into combinatorial structures that can be explored algorithmically.

Normalization is therefore part of the mathematical content, not bookkeeping after the fact. A count of geometric objects must be an integer with the intended multiplicity. If area is measured in primitive-triangle units, its polarization is even for standard degree triangles, and halving is precisely what converts that cross term into the expected count.

## A practical diagnostic

The calculation suggests a compact checklist for any proposed mixed-area formula.

1. **Declare the area convention.** Does a primitive lattice triangle have area $1/2$ or $1$?
2. **Test two lines.** For $d=e=1$, the answer must be $1$.
3. **Expand the degree triangle.** Verify whether the polarization is $de$ or $2de$.
4. **Check symmetry.** Exchanging the two polygons should not change the result.
5. **Check additivity.** Splitting one degree should split its interaction count.

For normalized lattice area, these checks force the half-polarization formula. For Euclidean area, they force the unhalved formula.

## A picture made of three squares

There is another way to see the identity without expanding an equation. Imagine a square of side $d+e$. Divide each side into a segment of length $d$ and one of length $e$. The square breaks into a $d$-by-$d$ square, an $e$-by-$e$ square, and two congruent rectangles, each of area $de$. Subtracting the two square pieces leaves both rectangles, hence $2de$.

That picture explains why division by $2$ is natural. The interaction between the $d$-part and the $e$-part appears twice: once in each orientation. A symmetric mixed quantity counts one copy of that interaction. Normalized triangle area follows the same quadratic arithmetic as square area, so its raw polarization retains both rectangles.

This visual argument also clarifies additivity. Splitting $d$ into $a+b$ slices each mixed rectangle into pieces of areas $ae$ and $be$. Nothing is lost or created; the interaction simply separates into two contributions. The algebraic laws are therefore geometric bookkeeping rules for the cross-shaped region left after the pure areas are removed.

## What remains beyond triangles

Degree triangles are the cleanest laboratory because their area is exactly $d^2$ and their Minkowski sum is immediate. General lattice polygons carry richer information: different edge directions, nontrivial shapes, and intersection counts controlled by more than a single degree.

The natural next step is to establish the full polygonal theory. One defines normalized area for finite lattice polygons, studies the quadratic behavior of $A(P+tQ)$ under Minkowski addition, and extracts the coefficient measuring the mixed interaction of $P$ and $Q$. That invariant should then be linked to determinant-weighted stable intersections of balanced tropical curves.

The triangle computation already fixes the convention that any such theory must respect. It establishes four durable facts: the raw normalized polarization equals $2de$; two lines refute the uncorrected formula; positive degrees never satisfy that formula; and the corrected half-polarization is symmetric and additive, yielding the Bézout count $de$.

Sometimes a broad theory turns on a very small example. Here, one triangle of area $1$, enlarged once, exposes the missing half—and restores the exact agreement between area and intersection.