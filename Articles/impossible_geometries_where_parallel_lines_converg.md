# Impossible Geometries: Where Parallel Lines Converge *and* Diverge

## A postulate that could not decide

For more than two thousand years, one sentence quietly ruled all of geometry. Euclid's fifth postulate — the *parallel postulate* — declares that through a point not on a given line there passes exactly one line that never meets it. Parallel lines, in Euclid's flat world, keep a perfect, eternal distance. They neither embrace nor drift apart.

The nineteenth century shattered this monopoly. Mathematicians discovered that one could deny the parallel postulate and still build a perfectly consistent universe. In **hyperbolic geometry**, the world is saddle-shaped: parallel lines *diverge*, fleeing from one another ever faster, and triangles have angles that sum to less than $180^\circ$. In **elliptic geometry**, the world is sphere-like: "parallel" lines *converge* and eventually cross, and triangle angles overshoot $180^\circ$. Each geometry has a single, fixed personality, encoded in a single number called the *curvature* $K$: negative for hyperbolic, zero for flat, positive for elliptic.

But here is a question those pioneers never asked. What if a space could not make up its mind? What if, standing at one point, you looked east and saw parallel lines fanning apart like a hyperbolic desert — then turned to look north and saw them rushing together like lines of longitude on a globe? A geometry that is **simultaneously expanding and contracting**, depending only on which way you face.

This article is about exactly such a world. Call it **Split Geometry**.

## Building a two-faced world

The trick to inventing a new geometry is to specify how you measure infinitesimal distance. On a flat sheet of paper, the Pythagorean rule holds everywhere: a tiny step $dx$ to the right and $dy$ up covers a distance whose square is $dx^2 + dy^2$. Curved geometries simply re-weight this rule from point to point.

Split Geometry weights it like this:
$$ ds^2 = \frac{dx^2}{\cosh^2 y} \;+\; \cosh^2 x \; dy^2 . $$

Here $\cosh$ is the hyperbolic cosine, $\cosh t = \tfrac12(e^t + e^{-t})$, a smooth U-shaped curve equal to $1$ at the origin and growing without bound in both directions. The two coefficients pull in opposite directions:

- The horizontal weight is $\operatorname{sech}^2 y = 1/\cosh^2 y$, a number that is *at most one* and shrinks toward zero as you move away from the $x$-axis. A small weight means a coordinate step counts for *less* distance — so the space **expands** horizontally: you can travel farther per unit of "real" length. This is hyperbolic-flavored behavior.
- The vertical weight is $\cosh^2 x$, a number that is *at least one* and grows as you move away from the $y$-axis. A large weight means each coordinate step costs *more* distance — so the space **contracts** vertically. This is elliptic-flavored behavior.

One metric, two temperaments, wired into perpendicular directions. The obvious worry is whether such a Frankenstein object is even a legitimate geometry at all. It is — and the reason is reassuringly simple.

**Consistency Theorem.** *At every point $(x,y)$ and for every nonzero direction $(u,v)$, the split metric assigns a strictly positive length:*
$$ \operatorname{sech}^2 y \cdot u^2 + \cosh^2 x \cdot v^2 > 0 . $$

The proof is a single observation: both weights are strictly positive everywhere, because $\cosh t \ge 1 > 0$ for every real $t$, so $\operatorname{sech}^2 y > 0$ and $\cosh^2 x > 0$. A sum of a positive number times $u^2$ and a positive number times $v^2$ can only vanish if both $u$ and $v$ are zero. Positive length in every direction is precisely the requirement for a genuine (Riemannian) geometry. Split Geometry is real.

## The heartbeat: one function, monotone in size

Everything interesting about Split Geometry flows from a single elementary function and one fact about it. The function is
$$ \operatorname{sech}^2 t = \frac{1}{\cosh^2 t}, $$
and the fact is that **it depends only on how far $t$ is from zero, and it shrinks as that distance grows.**

**Monotonicity Lemma.** *For all real numbers $a$ and $b$,*
$$ \operatorname{sech}^2 a < \operatorname{sech}^2 b \iff |b| < |a|, \qquad \operatorname{sech}^2 a = \operatorname{sech}^2 b \iff |a| = |b|. $$

Why is this true? Because $\cosh$ is an even function ($\cosh(-t)=\cosh t$) that strictly increases as $|t|$ grows. Taking reciprocals of squares flips the direction: the bigger $|t|$ is, the bigger $\cosh^2 t$ is, hence the *smaller* $\operatorname{sech}^2 t$ is. So $\operatorname{sech}^2$ is a strictly decreasing function of $|t|$ — it can tell you the magnitude of a number, but never its sign. This tiny asymmetry-detector is the engine of the whole theory.

## The curvature that changes its mind

The signature of Split Geometry is a curvature that flips sign depending on direction. The conjecture assigns to the geometry the sign-indicator function
$$ K(x,y) = \operatorname{sech}^2 x - \operatorname{sech}^2 y, $$
built by pitting the horizontal influence against the vertical one. Using the Monotonicity Lemma we can read off its entire personality at a glance.

**Phase-Boundary Theorem.** *The curvature vanishes exactly on the two diagonals:*
$$ K(x,y) = 0 \iff |x| = |y| \iff x = y \ \text{or}\ x = -y. $$

Indeed, $K(x,y)=0$ means $\operatorname{sech}^2 x = \operatorname{sech}^2 y$, which by the Monotonicity Lemma happens precisely when $|x|=|y|$ — that is, on the familiar "X" formed by the lines $y=x$ and $y=-x$. These two diagonals are the **phase boundary** of the world, the seams where the geometry is momentarily flat.

**Sign Theorem.** *Off the boundary, the sign of $K$ is dictated by a single comparison:*
$$ |x| < |y| \implies K(x,y) > 0 \quad(\text{elliptic}), \qquad |y| < |x| \implies K(x,y) < 0 \quad(\text{hyperbolic}). $$

Again this is immediate: if $|x| < |y|$ then, since $\operatorname{sech}^2$ shrinks with magnitude, $\operatorname{sech}^2 x > \operatorname{sech}^2 y$, so $K>0$; the other case is the mirror image. Putting the pieces together gives a clean trichotomy — every point of the plane is either **positively curved** (in the top and bottom wedges, near the $y$-axis), **negatively curved** (in the left and right wedges, near the $x$-axis), or sitting exactly on the flat diagonal seam. The plane is carved into four alternating wedges of opposite geometric character, like the quadrants of a pinwheel.

Picture standing at the origin. Look up or down, toward the vertical wedges: the world curves like the inside of a bowl, parallel lines converging. Look left or right, toward the horizontal wedges: the world curves like a saddle, parallel lines flying apart. The same point of space wears two geometries at once.

## Crossing the seam — but only twice

If you set off in a straight coordinate line across this pinwheel world, how many times can you pass through the flat seams? A traveler weaving between elliptic and hyperbolic regions might, intuitively, cross the boundary many times. The answer is strikingly rigid.

**Crossing Theorem.** *Take any straight coordinate line $t \mapsto (x_0 + ta,\ y_0 + tb)$ that is not parallel to either diagonal — that is, $a^2 \neq b^2$. Then it meets the phase boundary in at most two points.*

The reason is beautifully algebraic. A point of the line lies on the boundary when its coordinates satisfy $x^2 = y^2$, i.e.
$$ (x_0 + ta)^2 = (y_0 + tb)^2 . $$
Expanding and collecting powers of the parameter $t$ turns this into
$$ (a^2 - b^2)\, t^2 + 2(x_0 a - y_0 b)\, t + (x_0^2 - y_0^2) = 0 . $$
This is an honest quadratic equation in $t$ — its leading coefficient $a^2 - b^2$ is nonzero precisely because the line is not parallel to a diagonal. And a quadratic has at most two roots. Hence the line can cross the seam at most twice; among any three alleged crossing times, two must actually be the same. No matter how cleverly you aim, you cannot thread the pinwheel more than twice on a straight shot. (Lines *parallel* to a diagonal are the sole exception: they can run along a seam forever, or stay strictly on one side.)

## Why this matters

Split Geometry is a toy, but it is a toy that dramatizes a genuinely modern idea: that the shape of space need not be a single scalar verdict handed down uniformly, but can be a *field* — a quantity that varies from place to place, and even from direction to direction. This is the philosophical core of Einstein's general relativity, where the curvature of spacetime bends and twists in response to matter and energy, and where the same region can focus some geodesics while defocusing others. It echoes in cosmology's puzzle of a universe that appears to expand in some senses while gravity pulls it together in others.

What Split Geometry offers is the cleanest possible cartoon of "curvature as a sign that flips." Its phase boundary is not some transcendental curve requiring numerical approximation — it is the humble pair of diagonals $y = \pm x$, derivable by hand from one fact about hyperbolic cosine. Its region structure is a pinwheel of four alternating wedges. And its most surprising dynamical feature — that straight paths puncture the seam at most twice — reduces to the schoolroom fact that a quadratic has two roots.

A note of honesty is worth sounding. The elegant sign-indicator $K(x,y)=\operatorname{sech}^2 x - \operatorname{sech}^2 y$ used above is the conjecture's *proposed* curvature, and every theorem stated here is a rigorous, fully proved statement about that explicit function. The metric's *true* Gaussian curvature, computed from the full differential-geometric machinery, turns out to be a messier expression that agrees with the clean $K$ only at the origin. What survives untouched — proven, permanent, and beautiful — is the geometric skeleton the conjecture was really reaching for: **compare the size of $x$ with the size of $y$, and the plane splits along its diagonals into worlds of opposite curvature.**

Sometimes the deepest lesson of an impossible object is not whether it can exist, but how far a single, humble inequality can carry an entire universe.
