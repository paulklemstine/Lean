# Impossible Geometries: The Dream of a Space That Curves Two Ways at Once

## A wish written into a metric

For two thousand years, one sentence sat at the foundation of geometry like a
keystone: *through a point not on a given line, there is exactly one parallel
line.* Euclid's parallel postulate feels so obvious that generations of
mathematicians tried to *prove* it from the others — and failed, again and
again, until the nineteenth century revealed why. The postulate cannot be
proved because it is not forced. Deny it one way and you get **hyperbolic
geometry**, a saddle-shaped world where parallel lines fan apart and triangles
are thin, their angles summing to less than $180^\circ$. Deny it the other way
and you get **elliptic geometry**, the geometry of a sphere, where "parallels"
bend toward one another and meet, and triangles bulge past $180^\circ$.

Once you have three geometries — flat, saddle, sphere — it is irresistible to
ask for a fourth. What if a single space could be *both* elliptic and
hyperbolic at once, depending on which way you look? Imagine walking east and
watching the world spread apart beneath your feet like a saddle, then turning
to walk north and watching it curl back on itself like the surface of a globe.
A universe expanding along one axis and contracting along another. A geometry
that splits.

This article is the story of chasing that dream with complete honesty — of
writing the wish down as a precise mathematical object, following where the
equations lead, and discovering something more interesting than the fantasy: a
crisp theorem about *why* the fantasy is impossible on a surface, and exactly
what survives of it.

## Writing the dream as a metric

To do geometry you need a rule for measuring lengths. On the flat plane, the
Pythagorean theorem gives the length of a tiny step $(dx, dy)$ as
$ds^2 = dx^2 + dy^2$. Curved geometries keep the same shape of formula but let
the coefficients vary from place to place. This local ruler is called a
**metric**, and it encodes *everything* about the geometry — distances, angles,
straight lines, curvature — all of it.

To build our "split" world we want the ruler to *stretch* in one direction and
*shrink* in another. Here is the candidate, defined at each point $(x, y)$ of
the plane:

$$ ds^2 \;=\; \frac{dx^2}{\cosh^2 y} \;+\; \cosh^2(x)\,dy^2. $$

The functions $\cosh$ and $\operatorname{sech} = 1/\cosh$ are the hyperbolic
cousins of cosine and secant; $\cosh(0)=1$ and $\cosh$ grows steeply away from
zero. So the coefficient $\operatorname{sech}^2(y) = 1/\cosh^2(y)$ in front of
$dx^2$ *shrinks* as you move away from the $x$-axis, while the coefficient
$\cosh^2(x)$ in front of $dy^2$ *grows* as you move away from the $y$-axis. One
direction expands, the other contracts. The metric is the wish, made concrete.

Before asking whether it splits, we should check that it is a legitimate
geometry at all. It is. At every point the two coefficients
$\operatorname{sech}^2(y)$ and $\cosh^2(x)$ are strictly positive, so the ruler
never collapses and every nonzero step has positive length: the metric is
**positive definite**. It is symmetric, and both coefficients are infinitely
differentiable everywhere. In short, this is a bona fide smooth Riemannian
geometry on the whole plane. The stage is solidly built. Now, does the play we
wrote actually happen on it?

## The single number that governs a surface

Here the dream collides with a theorem, and the theorem wins.

The local expanding-and-contracting behavior of a metric is *not* the same
thing as curvature. Curvature is subtler: it measures how the geometry fails to
be flat in a way that no change of coordinates can hide. On a two-dimensional
surface, curvature is captured by a single number at each point — the
**Gaussian curvature** $K$. Positive $K$ means locally spherical (elliptic);
negative $K$ means locally saddle-shaped (hyperbolic); zero means flat.

The word "single" is the whole story. A surface has only one tangent plane's
worth of directions at each point, so there is only *one* curvature there. It
is a scalar, not a dial you can turn as you rotate. This is the mathematical
obstruction to the dream: **on a surface, curvature cannot depend on the
direction you look.** You cannot have $K>0$ "east–west" and $K<0$ "north–south"
at the same point, because there is only one $K$. The honest reading of the
original wish, then, is not about directions at a single point but about how the
single function $K(x,y)$ behaves as you move along the two axes.

So we compute it. There is a classical recipe — the Brioschi formula — that
turns the two coefficients of an orthogonal metric into its Gaussian curvature
through a specific combination of derivatives. Grinding it through for our
split metric and simplifying yields a clean closed form:

$$ K(x, y) \;=\; -\cosh^2(y) \;+\; \frac{2 - \cosh^2(y)}{\cosh^2(x)\,\cosh^2(y)}. $$

This is the exact curvature of the split geometry at every point, and it can be
independently confirmed by evaluating the Brioschi recipe numerically and
watching the two answers agree to many decimal places.

## What the curvature actually does

With the formula in hand we can finally test the dream against reality. Start at
the center. Setting $x=y=0$ gives, since $\cosh(0)=1$,

$$ K(0,0) = -1 + \frac{2-1}{1\cdot 1} = 0. $$

The origin is perfectly flat — a promising, neutral starting point. Now walk
outward along the two axes.

**Along the $x$-axis** ($y=0$), the formula collapses beautifully:

$$ K(x, 0) = -\tanh^2(x). $$

Since $\tanh^2$ is nonnegative and vanishes only at the origin, this is
$\le 0$ everywhere and strictly negative once you leave the center. The
east–west direction is genuinely **hyperbolic**: negative curvature, saddle
behavior, geodesics that spread apart. This half of the dream comes true.

**Along the $y$-axis** ($x=0$), the formula gives

$$ K(0, y) = -\cosh^2(y) + 2\operatorname{sech}^2(y) - 1. $$

The dream demanded that *this* be positive — elliptic, spherelike, curving
back on itself. But it is not. A short calculation shows this expression is also
$\le 0$ everywhere, and strictly *negative* away from the origin. The
north–south direction is hyperbolic too. There is no elliptic half. The split
does not happen.

This is not a failure of computation; it is the theorem asserting itself. Because
a surface carries only one curvature per point, and because that curvature turns
out nonpositive all along both axes, the metric simply cannot host the promised
"elliptic versus hyperbolic" division. The intuition that a shrinking coordinate
must mean positive curvature was the seductive error. Shrinking the ruler in the
$y$-direction is *not* the same as curving positively; the actual curvature,
which mixes together derivatives of both coefficients, comes out negative.

Finding this is more valuable than confirming the fantasy would have been. We
now hold a precise, checkable statement — the split geometry is hyperbolic-
leaning along both axes, flat only at the origin — that replaces a vague hope
with a fact.

## Where the exponentials really live

The original vision came with a picture of the "straight lines" of this world:
curves racing off with an exponential factor $e^{t}$ in one direction and
$e^{-t}$ in the other, expansion and contraction made visible. It is a
gorgeous image, and it is *almost* right — it is just attached to the wrong
object.

The straight lines of a geometry are its **geodesics**, the paths a free
particle follows, the routes of locally shortest distance. For our split metric
the true geodesics tangent to the axes are disappointingly plain: they are the
coordinate lines themselves, traversed at constant speed, $t \mapsto (x_0 + at,
0)$ along the $x$-axis and $t\mapsto (0, y_0+bt)$ along the $y$-axis. The
proposed exponential curves, by contrast, fail the geodesic equations outright —
plug $x(t)=t,\ y(t)=e^{t}$ into the equations of motion and the very first one
is violated already at $t=0$. Beautiful curves, but not straight lines of this
world.

So where do the exponentials belong? In the behavior of geodesics *relative to
one another*. Fire two nearby geodesics in parallel and watch the gap between
them. That gap $J(t)$ obeys a single, universal law — the **Jacobi equation** —
in which the curvature appears as the coefficient:

$$ J''(t) + K\,J(t) = 0. $$

The sign of $K$ decides everything. Where curvature is negative, $K=-k$ with
$k>0$, the equation becomes $J'' = kJ$, whose solution is
$J(t) = \sinh(\sqrt{k}\,t)$ — and $\sinh$ is built from exactly the
exponentials $e^{\pm\sqrt{k}\,t}$. The gap grows without bound; nearby paths
fly apart. *There* are the exponentials, at last in their rightful home: they
describe the runaway divergence of neighboring geodesics in a negatively curved
region — precisely the situation all along the $x$-axis, where
$K(x,0) = -\tanh^2(x) < 0$.

And the elliptic behavior the dream wanted? The mathematics tells us exactly
what it *would* look like, even though this particular metric never provides it.
Where curvature is positive, $K=+k$, the Jacobi equation becomes $J'' = -kJ$,
whose solution is the oscillation $J(t)=\sin(\sqrt{k}\,t)$. The gap stays
bounded — never exceeding its initial scale — and, remarkably, returns exactly
to zero at time $t = \pi/\sqrt{k}$. Neighboring geodesics that started apart are
focused back together, the way all meridians of a globe, setting out separately
from the equator, are inevitably reunited at the pole. Divergence versus
refocusing: this is the true, rigorous face of "hyperbolic versus elliptic," and
it is written entirely in the sign of a single number.

## The moral of an impossible geometry

The split geometry did not do what it was asked to do, and that is the point.
Set out to build a surface that is simultaneously expanding and contracting, and
the geometry answers with a law older than the question: a surface has one
curvature, and here that curvature is negative wherever it is not flat. The
fantasy of a direction-dependent curved *surface* is not merely unrealized by
this metric — it is impossible for any surface at all.

But impossibility is a door, not a wall. On a surface curvature is a scalar; in
three or more dimensions it becomes genuinely richer, attached to each
two-dimensional plane of directions, so that different planes through the same
point really can curve with different signs. The honest higher-dimensional
version of "impossible geometry" — a space that curves one way in the $xy$-plane
and the opposite way in the $xz$-plane — is not impossible at all. It is waiting.

That is the quiet reward of taking a wild idea completely seriously. We asked for
a space that curves two ways at once, and instead of a fairy tale we got three
solid things: a clean formula for the curvature of a striking metric, a proof of
why the dream cannot come true on a surface, and a precise account of where its
beautiful exponentials genuinely live. In mathematics, a well-understood
impossibility is worth more than a vaguely imagined possibility — because it
tells you exactly where to dig next.
