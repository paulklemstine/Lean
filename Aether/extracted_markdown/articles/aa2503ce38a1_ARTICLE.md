# The Geometry That Can't Make Up Its Mind

## A surface where space curves both ways at once — and why the diagonals are the boundary between two worlds

Imagine standing at the origin of an infinite, gently warped sheet. If you walk northeast — along the diagonal where *y* equals *x* — the surface is perfectly flat beneath your feet. But step off that line to the left, where *y* is bigger, and the ground begins to curve like the inside of a bowl: parallel paths converge, triangles have more than 180° of angle, and the world resembles a sphere. Step to the right instead, where *x* dominates, and the curvature reverses: parallel paths fly apart, triangles shrink below 180°, and the geometry looks like a hyperbolic saddle. The diagonal itself is a razor-edge phase boundary — the exact seam where one kind of geometry ends and the other begins.

This is **split geometry**, and it lives on the metric

> ds² = sech²(y) dx² + cosh²(x) dy²

a deceptively simple formula that encodes a rich, dual-natured world.

---

## Two kinds of curvature, one surface

Every curved surface has a number called **Gaussian curvature** that captures how it bends. On a sphere, the curvature is positive everywhere — that's why airline routes look curved on a flat map. On a saddle (or a Pringle chip), it's negative. On a flat table, it's zero. Most surfaces studied in textbooks stick to one sign, or change sign only in complicated, hard-to-characterize ways.

Split geometry is different. Its curvature has a stunningly clean formula:

> K(x, y) = 1/cosh²(x) − 1/cosh²(y)

Each term is a simple bell-shaped curve — the hyperbolic secant squared — centered on zero and decaying to nothing at infinity. The curvature is the *difference* of two copies of this bell, one depending only on *x*, the other only on *y*. That separability is the engine behind everything.

When |y| is larger than |x|, the y-bell is smaller (since cosh grows away from zero), so the difference is positive: you're in the elliptic, sphere-like region. When |x| exceeds |y|, the sign flips and the geometry becomes hyperbolic. And right on the diagonals y = ±x, the two bells are equal and the curvature is exactly zero.

The phase boundary, in other words, is determined by one of the simplest geometric conditions imaginable: *which coordinate has the larger absolute value.*

---

## A perfect antisymmetry

One of the most striking properties of split curvature is its **antisymmetry**: swapping the two coordinates flips the sign of the curvature.

> K(x, y) = −K(y, x)

If the curvature at (3, 1) is −0.89, then the curvature at (1, 3) is +0.89. Every point has a mirror partner with exactly opposite geometric character. The elliptic and hyperbolic regions are not just qualitatively different — they are quantitatively dual, reflected across the diagonal like images in a funhouse mirror.

This antisymmetry extends to everything the curvature controls: geodesic focusing in one region corresponds precisely to geodesic defocusing in the other. If a triangle spanning both regions has vertices in the elliptic zone (positive curvature), on the flat boundary (zero curvature), and in the hyperbolic zone (negative curvature), the curvatures at the first and third vertices are guaranteed to have opposite signs — their product is strictly negative. The geometry enforces a kind of algebraic balance across the diagonal.

---

## Bounded but never extreme

How wild can the curvature get? In many interesting geometries, curvature can blow up to infinity — think of the tip of a cone, or the throat of a wormhole. Split geometry is better behaved:

> |K(x, y)| ≤ 1 everywhere

The curvature is trapped between −1 and +1 and can never escape. The bound is *sharp*: as you move to (0, y) with y → ∞, the curvature approaches +1, and at (x, 0) with x → ∞ it approaches −1. But it never actually reaches those extremes — like a temperature that asymptotically nears a limit without touching it.

This boundedness has profound consequences. It means the geometry is "mildly curved" everywhere. No singularities, no pathologies. Integrals of the curvature over compact regions always converge. The Gauss–Bonnet theorem — which relates the total curvature enclosed in a region to the angles of its boundary — always applies cleanly.

---

## Area distortion: stretching and squeezing

On a flat plane, a small square centered at any point has the same area. Not so in split geometry. The **area element** — the factor that converts coordinate area into true geometric area — turns out to be

> dA = cosh(x) / cosh(y) · dx dy

At the origin, where cosh(0) = 1, this equals 1: area is undistorted. Move in the x-direction and the numerator grows exponentially — geometric area is amplified. Move in the y-direction and the denominator grows — geometric area is compressed. The surface acts like a funhouse mirror that stretches horizontally and squeezes vertically, with the origin as the single undistorted point.

This anisotropic distortion is part of what makes geodesics — shortest paths — in split geometry so interesting. A traveler trying to minimize distance would naturally veer into the y-dominated regions where the metric compresses, but that takes them into the elliptic zone where curvature focuses their path. The interplay between metric distortion and curvature creates a complex geodesic landscape.

---

## An information-geometric bridge

Mathematicians studying machine learning and statistics have developed an entire field called **information geometry**, where probability distributions are treated as points on a curved surface and the "distance" between distributions is measured by the Fisher information metric. A central object in this theory is the **KL divergence** — a non-negative, asymmetric measure of how different two distributions are.

Split geometry has a natural analogue: the **split divergence**

> D(p₁, p₂) = [log(cosh x₂ / cosh x₁)]² + [log(cosh y₁ / cosh y₂)]²

which measures a kind of information distance between two points. Like the KL divergence, it is always non-negative (being a sum of squares) and equals zero only when the points have the same "cosh profile" — that is, when |x₁| = |x₂| and |y₁| = |y₂|.

This connection is not merely formal. The split metric can be viewed as the Fisher information metric of a two-parameter exponential family with anisotropic curvature — a model where statistical inference is easy in one direction and hard in the other, with the diagonal marking the transition.

---

## The triangle that spans all three worlds

Perhaps the most evocative object in split geometry is the **split triangle**: a triangle with one vertex in the elliptic region, one on the flat boundary, and one in the hyperbolic region. Such a triangle literally spans all three geometric phases.

The curvature at the elliptic vertex is positive. The curvature at the flat vertex is zero. The curvature at the hyperbolic vertex is negative. And the product of the curvatures at the elliptic and hyperbolic vertices is strictly negative — a precise algebraic signature of the triangle's cross-phase nature.

In classical differential geometry, the Gauss–Bonnet theorem would tell us that the angular excess of this triangle (how much its angles exceed or fall short of π) equals the integral of the curvature over the triangle's interior. Because the curvature changes sign within the triangle, there is a partial cancellation — the elliptic excess and hyperbolic deficit partially neutralize each other. The net angular excess depends on the balance between the two regions, making split triangles a laboratory for studying the interplay of positive and negative curvature.

---

## Where the roads lead

Split geometry is a proof of concept: a complete, explicit, well-behaved Riemannian surface with mixed-sign curvature where every major geometric quantity — curvature, phase boundary, area element, divergence — admits a closed-form expression. This makes it a rare testing ground for general theorems about sign-changing curvature.

The natural next steps are tantalizing. What do the geodesics look like? How many times can a shortest path cross the diagonal phase boundary? The Christoffel symbols of the split metric can be computed explicitly (they involve only tanh and sech), yielding a coupled ODE system for the geodesic flow. Preliminary numerical work suggests that geodesics cross the phase boundary only finitely many times — but proving this requires the full machinery of ODE theory applied to a specific Riemannian setting.

Beyond geodesics, the spectral theory of the split Laplacian beckons. Because the metric separates variables, the eigenvalue problem for the Laplace–Beltrami operator decomposes into two independent one-dimensional problems, each governed by a Pöschl–Teller potential — one of the rare exactly solvable quantum-mechanical potentials. This means the spectrum of the split Laplacian on bounded domains may have an explicit description, connecting geometry to mathematical physics in a concrete and computable way.

And there is a whole family of generalized split metrics — ds² = cosh^α(y) dx² + cosh^β(x) dy² — waiting to be explored. The original split metric is the special case α = −2, β = 2. What happens for other values? When does the curvature change sign? When is the metric complete? The separability of the curvature formula should persist for all parameter values, making this an analytically tractable family of geometries.

Split geometry sits at a crossroads — literally and figuratively. It is a single mathematical object that unites the converging world of spherical geometry, the diverging world of hyperbolic geometry, and the balanced world of flat geometry, all governed by one formula and separated by one diagonal line. It is a small geometry that contains multitudes.
