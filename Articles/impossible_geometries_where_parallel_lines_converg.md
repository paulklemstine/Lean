# The Geometry That Refused to Split

## A metric built to make space expand one way and contract the other reveals a subtler world

Geometry begins with a physical intuition: a ruler should tell us how far apart two nearby points are. Change the ruler from place to place, and the familiar plane can acquire curvature without ever leaving two dimensions. That simple idea powers the geometry of curved surfaces, gravitational fields, and many modern models of anisotropic materials.

Consider a plane with ordinary coordinates $(x,y)$, but equip it with the squared line element

$$
ds^2=\frac{dx^2}{\cosh^2 y}+\cosh^2 x\,dy^2.
$$

Here $\cosh t=(e^t+e^{-t})/2$ is the hyperbolic cosine. It is always positive, equals $1$ at $t=0$, and grows rapidly as $|t|$ increases. The metric therefore treats the two coordinate directions very differently. At height $y$, a horizontal displacement is discounted by the factor $1/\cosh y$. At horizontal position $x$, a vertical displacement is magnified by the factor $\cosh x$. Far from the axes, the plane resembles a fabric that has been compressed in one family of directions and stretched in the perpendicular family.

This construction invites a dramatic conjecture. Might the competing effects make some regions positively curved, like a sphere, and others negatively curved, like a saddle? Could the diagonals become boundaries between two geometric phases? The answer is more illuminating than the conjecture: the proposed split never occurs. A complete curvature calculation shows that this metric is flat only at the origin and negatively curved everywhere else.

The geometry does not divide into elliptic and hyperbolic countries. It is a single saddle-like world with one exceptionally flat point.

## First question: does this really define a geometry?

At a point $(x,y)$, let a tangent vector have coordinate components $(u,v)$. Its squared length is

$$
\| (u,v)\|_{(x,y)}^2=\frac{u^2}{\cosh^2 y}+\cosh^2 x\,v^2.
$$

Both coefficients are strictly positive. Consequently, every nonzero vector has strictly positive squared length. This proves the basic consistency theorem: the formula defines a smooth, positive-definite Riemannian metric on the entire plane. There are no singular points, forbidden zones, or directions of zero length.

The determinant of the metric matrix is

$$
\det g=\frac{\cosh^2 x}{\cosh^2 y},
$$

so the area density is its positive square root,

$$
dA=\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

Thus metric area is not ordinary coordinate area. A tiny coordinate rectangle near $(x,y)$ is weighted by $\cosh x/\cosh y$. Moving far in the $x$ direction increases its geometric area; moving far in the $y$ direction decreases it. This clean formula is already a useful description of the plane’s anisotropy.

## The hidden steering rules

Curvature is not read directly from stretching factors. One must first understand how the local rulers vary. The Levi–Civita connection supplies the steering corrections that make a freely moving path as straight as this changing metric permits. Those corrections are encoded by Christoffel symbols.

For this diagonal metric, the independent nonzero symbols reduce to four simple expressions:

$$
\Gamma^1_{12}=\Gamma^1_{21}=-\tanh y,
$$

$$
\Gamma^1_{22}=-\cosh^2 y\,\cosh x\,\sinh x,
$$

$$
\Gamma^2_{11}=\frac{\sinh y}{\cosh^3 y\,\cosh^2 x},
$$

$$
\Gamma^2_{12}=\Gamma^2_{21}=\tanh x.
$$

The remaining diagonal symbols $\Gamma^1_{11}$ and $\Gamma^2_{22}$ vanish. These six independent entries give the complete local rule for parallel transport and geodesic acceleration.

A path $t\mapsto(x(t),y(t))$ is a geodesic precisely when it satisfies

$$
\ddot x-2\tanh y\,\dot x\dot y
-\cosh^2 y\,\cosh x\,\sinh x\,\dot y^2=0,
$$

$$
\ddot y+\frac{\sinh y}{\cosh^3 y\,\cosh^2 x}\,\dot x^2
+2\tanh x\,\dot x\dot y=0.
$$

These equations matter because they correct another tempting picture. The coefficients vary smoothly throughout the plane. Nothing in the metric abruptly switches from an exponential law to a trigonometric law at a diagonal. Geodesics are solutions of one coupled smooth system, not pieces from two different geometries pasted together.

## The curvature verdict

For an orthogonal metric $ds^2=E\,dx^2+G\,dy^2$, Gaussian curvature can be computed from the way $E$ and $G$ vary. Substituting

$$
E(x,y)=\operatorname{sech}^2 y,
\qquad
G(x,y)=\cosh^2 x
$$

into the orthogonal-coordinate curvature formula yields the exact result

$$
K(x,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2 x\,\cosh^2 y}.
$$

This is the central theorem. It differs decisively from the attractive guess $\operatorname{sech}^2 x-\operatorname{sech}^2 y$. A metric can stretch one direction and contract another without turning the signs of those scale factors into separate signs of intrinsic curvature. Curvature is a nonlinear synthesis of all first and second variations of the metric.

The exact formula has a sharp global consequence:

**Curvature Sign Theorem.** For every $(x,y)\in\mathbb R^2$, the Gaussian curvature satisfies $K(x,y)\le 0$. Moreover,

$$
K(x,y)=0 \quad\Longleftrightarrow\quad (x,y)=(0,0).
$$

Therefore $K(x,y)<0$ at every non-origin point.

One can see the result immediately on the horizontal axis. Setting $y=0$ gives

$$
K(x,0)=-1+\frac{1}{\cosh^2 x}=-\tanh^2 x.
$$

It is zero at $x=0$ and negative for every $x\ne0$. So even the region that was expected to have positive curvature already fails the test along its central axis.

The full inequality follows by clearing the positive denominator $\cosh^2 x\cosh^2 y$ and using the identity $\cosh^2 t-\sinh^2 t=1$. Equality forces both hyperbolic sines to vanish, hence $x=y=0$. This proof is global: it does not depend on plotting a finite window or sampling a grid.

## Why anisotropy is not mixed curvature

A sphere and a saddle are distinguished intrinsically. On a sphere, nearby initially parallel geodesics tend to focus; on a negatively curved surface, they tend to separate. But coordinate stretching alone can be deceptive. The coefficients $\operatorname{sech}^2 y$ and $\cosh^2 x$ describe the cost of motion along chosen coordinate lines. Gaussian curvature asks whether the entire metric can locally be flattened while preserving all distances. It combines cross-effects that a direction-by-direction reading misses.

This distinction appears throughout mathematical physics. An anisotropic optical medium may transmit light at different effective speeds in different directions without behaving like two unrelated spaces. A cosmological model may have distinct scale factors along distinct axes, yet its curvature is determined by their coupled evolution. A material may expand longitudinally and contract transversely, while its intrinsic defect structure obeys a single compatibility law. The lesson is broad: directional behavior and curvature sign are related, but they are not interchangeable.

The present plane is an especially clean case study. Horizontally, lengths shrink as $|y|$ grows. Vertically, lengths expand as $|x|$ grows. Meanwhile the area element weights regions asymmetrically, and the connection couples both motions. After all of those effects are assembled, the curvature is nonpositive everywhere.

## What becomes of the “phase boundary”?

The anticipated diagonals $y=x$ and $y=-x$ are not zero-curvature boundaries. Except at their common point, they lie in strictly negative curvature. There are no positive-curvature regions to separate, so a theorem claiming that geodesics cross a sign-changing boundary at most twice cannot apply to this metric.

There is, however, a meaningful replacement question. Since the zero-curvature set consists only of the origin, how often can a geodesic pass through that point? The smooth geodesic equations imply local uniqueness once a position and velocity are fixed. Turning this into a global statement requires a careful study of solutions, but it is the right problem suggested by the actual geometry.

Triangle area must likewise be posed with care. For a specified region $T$ bounded by chosen geodesic segments, its area is

$$
\operatorname{Area}(T)=\iint_T \frac{\cosh x}{\cosh y}\,dx\,dy.
$$

Three vague “phases” cannot determine an area because those phases do not exist, and even three vertices require a choice of connecting geodesics when global uniqueness is unknown. Once the boundary is fixed, however, the area formula is exact and ready for numerical integration.

## How to explore the surface numerically

A small numerical experiment makes the correction visible. Choose a rectangular grid, evaluate $\cosh x$, $\sinh y$, and the exact expression for $K$ at every grid point, and color the points by curvature. The resulting map has no red islands of positive curvature and no diagonal white seams. Instead, a single value $K=0$ occurs at the center, surrounded by increasingly negative shades. A second plot of $\cosh x/\cosh y$ reveals a different pattern: area grows toward the left and right and shrinks toward the top and bottom. Comparing the plots is instructive. The area-density image displays the directional stretching clearly, while the curvature image refuses to inherit its sign pattern.

Numerical plots cannot prove a global statement on an infinite plane, but they can expose a faulty conjecture and guide exact analysis. Here the formula supplies the proof, while computation provides intuition and test cases. Together they show why one should visualize both the metric coefficients and the intrinsic invariants rather than treating either picture as the whole geometry.

## A productive failure

The most valuable mathematical models are not those that merely confirm an evocative picture. They tell us precisely where the picture breaks. This metric succeeds as a globally smooth, positive-definite, strongly anisotropic geometry. It has explicit connection coefficients, an explicit area density, and an exact curvature law. What it does not have is a curvature-sign split.

That correction opens better questions. Is the resulting metric geodesically complete? How rapidly do geodesics separate? Can distance be bounded effectively in terms of the coordinates? What is the global behavior of the exponential map? How often can a geodesic return to the origin? The coefficients become extreme far from the axes, so these are not cosmetic extensions; they probe the geometry’s deepest large-scale structure.

A universe may expand in one measured direction and contract in another. But whether it is spherical, flat, or saddle-like is decided by a more subtle accounting. In this plane, the accounting is exact: one flat point sits at the center, surrounded everywhere by negative curvature. The imagined border between two worlds dissolves, revealing a single geometry more coherent—and more interesting—than the split that inspired it.
