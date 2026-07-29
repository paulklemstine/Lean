# Renormalization on a Circle: A Geometric Portrait of the One-Dimensional Ising Model

Renormalization is often described as a change of eyesight. Stand close to a material and every microscopic spin matters; step back, and clusters replace individuals. The renormalization group is the mathematics of that retreat. It asks which features survive as fine detail is erased, which couplings weaken, and which special states remain unchanged at every scale.

For the zero-field one-dimensional Ising model, this grand idea becomes unusually exact. The model consists of spins arranged along a line, each preferring to align with its neighbors. If the dimensionless nearest-neighbor coupling is $K$, a particularly natural coordinate is

$$
g=\tanh K.
$$

In the ferromagnetic finite-temperature regime, $0\leq g<1$. The value $g=0$ represents uncoupled spins, while values approaching $1$ represent increasingly strong alignment. When every other spin is summed out—an operation called decimation—the remaining spins again form an Ising chain, but with a new coupling. In the $g$ coordinate, the entire transformation is simply

$$
R(g)=g^2.
$$

That tiny formula contains the scale evolution of the model. It also admits a striking geometric reinterpretation: the real coupling line can be wrapped around a unit circle, and decimation then becomes an explicit rational motion on that circle.

## Wrapping the coupling line around a circle

Define the inverse stereographic map $S$ by

$$
S(g)=\left(\frac{2g}{1+g^2},\frac{1-g^2}{1+g^2}\right).
$$

Write its two coordinates as $S(g)=(x,y)$. A direct expansion gives

$$
x^2+y^2
=\frac{4g^2+(1-g^2)^2}{(1+g^2)^2}
=\frac{1+2g^2+g^4}{(1+g^2)^2}
=1.
$$

Thus every finite real coupling lands on the unit circle. At $g=0$, the image is the north pole $(0,1)$. At $g=1$, it is the point $(1,0)$. Negative couplings occupy the opposite semicircle, while arbitrarily large positive or negative couplings approach the missing south pole $(0,-1)$ from opposite sides. The unbounded line has become a compact geometric object with one point at infinity.

This change of picture is more than decorative. Compactification places weak and strong coupling in one bounded scene. It also allows the renormalization step to be expressed without returning to the line.

Define a rational transformation $C$ of circle coordinates by

$$
C(x,y)=\left(\frac{x^2}{2-x^2},\frac{2y}{1+y^2}\right).
$$

The central result is the **Stereographic Conjugacy Theorem**:

> For every real coupling $g$, applying Ising decimation and then wrapping the result onto the circle gives exactly the same point as first wrapping $g$ onto the circle and then applying $C$. In symbols,
> $$
> S(R(g))=C(S(g)).
> $$

The theorem says that $R$ and $C$ are two coordinate descriptions of the same dynamics. To see why, put

$$
x=\frac{2g}{1+g^2},\qquad y=\frac{1-g^2}{1+g^2}.
$$

The first coordinate of $C(x,y)$ simplifies using

$$
(1+g^2)^2-2g^2=1+g^4
$$

to

$$
\frac{x^2}{2-x^2}=\frac{2g^2}{1+g^4}.
$$

The second simplifies to

$$
\frac{2y}{1+y^2}=\frac{1-g^4}{1+g^4}.
$$

Together these are precisely

$$
S(g^2)=\left(\frac{2g^2}{1+g^4},\frac{1-g^4}{1+g^4}\right).
$$

The denominators never vanish for real $g$, so the identity holds globally on the finite coupling line.

## Flow, fixed points, and a discrete beta observable

A beta function usually describes infinitesimal change with continuous scale. Here the transformation occurs in discrete steps, so it is more precise to define the one-step beta observable

$$
B(g)=R(g)-g=g^2-g.
$$

The **Fixed-Coupling Theorem** states:

> For a finite real coupling $g$, $B(g)=0$ if and only if $g=0$ or $g=1$.

Indeed,

$$
B(g)=g(g-1),
$$

so its only real zeros are $0$ and $1$. These are exactly the finite fixed points of $R$. In the physical interval $0\leq g<1$, only $g=0$ lies inside the finite-temperature regime; $g=1$ is its zero-temperature boundary.

Between the fixed points, $0<g<1$ implies $g^2<g$, hence $B(g)<0$. Every decimation step moves the coupling toward $0$. The circle makes the same motion visible as a drift along the first quadrant toward the north pole. For example,

$$
0\mapsto0,\qquad
\frac14\mapsto\frac1{16},\qquad
\frac12\mapsto\frac14,\qquad
\frac34\mapsto\frac9{16},\qquad
1\mapsto1.
$$

These values show how quickly moderate couplings weaken. Starting at $g=1/2$, successive values are $1/2$, $1/4$, $1/16$, $1/256$, and so on. The formula suggests the general iterate $R^n(g)=g^{2^n}$, although the results established here concern the one-step map and its exact geometric conjugacy.

## Local sensitivity

Renormalization is not only about where a point moves; it is also about how nearby points separate. Differentiating the update gives the **Linearized Update Theorem**:

> At every real coupling $g$, the derivative of $R(g)=g^2$ is
> $$
> R'(g)=2g.
> $$

The multiplier is $0$ at $g=0$ and $2$ at $g=1$. Thus the weak-coupling fixed point strongly contracts nearby perturbations, while the boundary fixed point repels perturbations when the full real coordinate is considered. Differentiating the discrete beta observable yields the companion result

$$
B'(g)=2g-1.
$$

Consequently, $B$ decreases for $g<1/2$, is stationary at $g=1/2$, and increases for $g>1/2$. This derivative should not be confused with a continuous field-theoretic beta function: $B$ measures one finite decimation step, whereas a continuous beta function is an infinitesimal generator. The distinction matters whenever one compares formulas across renormalization schemes or coupling coordinates.

There is also a subtle geometric lesson in the phrase “derivative of the stereographic update.” The multiplier $2g$ belongs to the coupling coordinate $g$. On the circle, tangent vectors are rescaled by the chart. Conjugacy guarantees that the dynamics agree, but numerical derivatives in different coordinates transform by the chain rule. Geometry clarifies renormalization; it does not abolish coordinate dependence.

## A map you can see

Imagine marking a coupling on a horizontal number line and lifting that mark onto the circle. The formula for $S$ makes the lift continuous: as $g$ runs from $0$ to $1$, the point travels through the first quadrant from $(0,1)$ to $(1,0)$. Decimation replaces $g$ by $g^2$, which is smaller whenever $0<g<1$. The lifted point therefore reverses part of its arc and moves northward. Nothing discontinuous occurs, and no information is lost; applying $g=x/(1+y)$ recovers the original finite coupling from its circle point.

This lets a single diagram tell several stories at once. Radial distance is irrelevant because all states lie on the same circle. Position along the arc records coupling strength. Fixed points become stationary landmarks. Local stability appears in the spacing of nearby trajectories. The north pole absorbs physical interior points, whereas the point $(1,0)$ remains fixed but sends a nearby point away under the next coarse-graining step.

The geometric map is also safe from coordinate singularities on the circle. Since $x^2\leq1$, its first denominator satisfies $2-x^2\geq1$; its second denominator satisfies $1+y^2\geq1$. The rational formulas therefore define the next circle point everywhere, including the south pole used to represent infinity. At that pole, $C(0,-1)=(0,-1)$, adding a compactified fixed point that is not a finite zero of $B(g)$. This distinction—finite coupling versus the point at infinity—is exactly why compactification is informative.

## From microscopic elimination to geometry

The squaring law has a direct physical origin. For neighboring spins $\sigma_i$ and $\sigma_{i+1}$, each taking values $\pm1$, one may write the bond weight as

$$
e^{K\sigma_i\sigma_{i+1}}=\cosh K\left(1+g\sigma_i\sigma_{i+1}\right).
$$

When an intermediate spin is summed over, terms odd in that spin cancel, while the product of the two adjacent bond couplings survives. Two identical bonds therefore produce the effective coordinate $g'=g\cdot g=g^2$. Stereography does not alter this physics. It packages the exact result into a bounded phase portrait where the coarse-graining trajectory can be followed without an unbounded axis.

## Why this picture matters

The one-dimensional Ising chain is a laboratory in which an ambitious geometric idea can be tested without approximation. Three facts fit together exactly:

1. the coupling update is $g\mapsto g^2$;
2. inverse stereography sends every finite $g$ to the unit circle;
3. the induced circle dynamics is the rational map
   $$
   (x,y)\mapsto\left(\frac{x^2}{2-x^2},\frac{2y}{1+y^2}\right).
   $$

This is a genuine bridge between coarse-graining and conformal geometry, but it is deliberately narrow. It does not establish that a perturbative beta function in four-dimensional $\phi^4$ theory is literally a derivative of stereographic projection. Such a claim would require a chosen dimension, regularization, subtraction scheme, coupling normalization, and continuous scale parameter. Beta functions change under reparametrization, so any comparison must include the relevant coordinate-change law.

What the circle supplies is a disciplined prototype. It suggests studying renormalization maps through compactifying charts, asking when changing stereographic poles produces a coherent family of Möbius transformations, and seeking local conjugacies near hyperbolic fixed points rather than demanding equality of coordinate-dependent expressions.

The next mathematical steps are clear. One can prove the full iteration formula $R^n(g)=g^{2^n}$ and convergence to $0$ for $0\leq g<1$, then transport that convergence to the circle. One can derive $g'=g^2$ directly by summing over the eliminated spins. One can introduce a continuous semigroup and reserve the name beta function for its generator. Finally, one can let the stereographic pole vary and investigate the cocycle conditions needed for consistent scale evolution.

Renormalization began as the art of forgetting microscopic detail. In this model, forgetting has an unexpectedly elegant portrait: square a number on a line, or move rationally around a circle. The algebra and the geometry are not analogies. They are exactly the same motion viewed through different coordinates.

The value of the example is therefore not that a circle magically solves every renormalization problem. It is that an exact solvable case teaches the right questions: What is the coupling space? Which chart compactifies it? Which quantities survive coordinate changes? And can coarse-graining be transported to a clean geometric dynamics? Here every question has an explicit answer.
