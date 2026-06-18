# Future Directions: From the Tropical Quadratic to Newton-Polygon Geometry

## Synthesis

This cycle delivered a complete, machine-checked theory of the **roots of the
tropical (min-plus) quadratic** in `Catalog/Tropical/NewtonQuadratic.lean`. A
degree-two tropical polynomial is the pointwise minimum of three affine pieces
`min(c0, c1 + x, c2 + 2x)` with slopes `0, 1, 2`, and a *tropical root* is a point
where the minimum is attained at least twice. We proved the full dichotomy:

- When the middle coefficient lies on or below the chord (`2*c1 ≤ c0 + c2`, the
  *non-degenerate* Newton polygon), the roots are exactly the two corners
  `c1 - c2` and `c0 - c1` (`tropQuad_root_separated`).
- When it lies strictly above (`c0 + c2 < 2*c1`), the middle piece is hidden and
  there is a single **double root** `(c0 - c2)/2` (`tropQuad_root_degenerate`).

The switch between the regimes is governed by the *tropical discriminant*
`c0 + c2 - 2*c1`, the exact min-plus shadow of the classical discriminant's sign.
We then proved the **tropical Vieta formula** (`tropQuad_vieta`): any two distinct
roots sum to `c0 - c2`, the min-plus analogue of "product of roots = a0/a2". The
non-strict inequalities in the `IsTropRoot` predicate make the two regimes agree
continuously at the boundary `2*c1 = c0 + c2`, where the simple roots collide.

Finally, `tropQuad_concaveOn` records the structural fact that the value function
is globally concave — a pointwise minimum of affine pieces — linking this work to
the continuous-piecewise-linear (CPL) / ReLU programme: a tropical polynomial is a
concave CPL function, and its corner set (its roots) is precisely the breakpoint
locus studied there.

## Results Summary

- `tropQuad` / `IsTropRoot`: definitions of the min-plus quadratic and its root set.
- `tropQuad_root_separated`: proved — exact two-root characterization in the
  non-degenerate regime.
- `tropQuad_root_degenerate`: proved — double-root characterization in the
  degenerate regime.
- `tropQuad_vieta`: proved — tropical Vieta (distinct roots sum to `c0 - c2`).
- `tropQuad_concaveOn`: proved — global concavity of the value function.

All main results are `sorry`-free and use only the standard axioms
`propext, Classical.choice, Quot.sound`.

## Research Directions

### Direction 1: The Tropical Cubic and the Three-Slope Newton Polygon
The natural next step is `min(c0, c1 + x, c2 + 2x, c3 + 3x)`. The root set should be
governed by the *lower convex hull* of the four points `(i, c_i)`: each edge of the
hull of slope `s` contributes a corner, and an edge spanning `k` lattice columns
contributes a root of multiplicity `k`. **Test**: prove that the number of roots
(with multiplicity) equals the horizontal width of the Newton polygon, and that the
distinct root values are the negatives of the hull's edge slopes, for degree 3.
**The key insight is** that `tropQuad_root_separated` already exhibits the
"convex coefficients ⇒ simple roots" mechanism in miniature; the cubic just adds one
more potential corner, so the proof is a finite case split on the four convexity
inequalities `c_{i-1} + c_{i+1} ⋛ 2 c_i`. **Why now**: the degree-2 dichotomy gives
the exact template (discriminant sign → corner existence) and the concavity lemma
generalizes verbatim. **If false**: multiplicity would fail to match lattice width,
indicating the tropical fundamental theorem needs a weighting correction.

### Direction 2: Tropical Fundamental Theorem of Algebra (degree n)
Generalize to `min_i (c_i + i*x)` over `i = 0..n` and prove that the multiset of
roots has total size `n` (counted by Newton-polygon width), i.e. a *tropical
fundamental theorem of algebra*. **Test**: define the Newton polygon as the lower
convex hull of `{(i, c_i)}` and prove a bijection between hull edges and root
intervals. **The key insight is** that the global concavity (`tropQuad_concaveOn`,
generalized) means the value function's slope is monotone, so corners are linearly
ordered and counted by slope jumps — turning an algebraic count into a monotone
step-counting argument. **Why now**: we have both the concavity infrastructure and a
proven base case (`n = 2`). **If false**: a degenerate plateau (an affine piece never
on the envelope) would break the width count, exposing the need for "essential
coefficients."

### Direction 3: Tropical Vieta for All Symmetric Functions
`tropQuad_vieta` is the first symmetric-function identity (sum of roots). The full
program: the `k`-th tropical elementary symmetric function of the roots equals
`c_{n-k} - c_n` (min-plus), i.e. coefficients ARE the symmetric functions. **Test**:
for degree 3, prove `r1 + r2 + r3 = c0 - c3` and `min(r1+r2, r1+r3, r2+r3) = c1 - c3`.
**The key insight is** that in min-plus, multiplication is addition, so Vieta becomes
a statement about sums and minima of corner coordinates — exactly the data the Newton
polygon encodes. **Why now**: the degree-2 sum identity is proven and its proof is a
pure corner-coordinate computation that scales. **If false**: a multiplicity-weighted
correction would be required, revealing where tropical and classical Vieta diverge.

### Direction 4: The Root Set as the Non-Differentiability Locus (CPL Bridge)
Connect roots to analysis: prove that `x` is a tropical root of `tropQuad` **iff**
the value function `tropQuad c0 c1 c2` fails to be differentiable at `x` (its left
and right slopes differ). **Test**: compute one-sided derivatives of the min of
affine pieces and show the corner set equals the non-smooth set. **The key insight
is** that `IsTropRoot` ("min attained twice") is exactly the analytic condition for a
slope jump in a concave function, so `tropQuad_concaveOn` provides the monotone-slope
backbone for the equivalence. **Why now**: concavity is already proven, and Mathlib
has the one-sided-derivative API for convex/concave functions. **If false**, a hidden
affine piece tangent to the envelope would create a root with no slope jump,
sharpening the distinction between "algebraic" and "geometric" roots.

### Direction 5: Stability / Perturbation of Tropical Roots
Adversarially stress-test the dichotomy: how do roots move under perturbation of
`(c0, c1, c2)`? Conjecture: in the non-degenerate regime the root map
`(c0,c1,c2) ↦ {c1-c2, c0-c1}` is `1`-Lipschitz in each coordinate, but at the
discriminant wall `2*c1 = c0 + c2` it is only Hölder-`1/2` (the double root splits
like a square root). **Test**: prove the Lipschitz bound away from the wall and the
`1/2`-Hölder bound across it. **The key insight is** that `(c0-c2)/2` (the double
root) versus `{c1-c2, c0-c1}` (simple roots) shows the same `1/2` exponent as
classical double roots — the tropical discriminant controls conditioning. **Why
now**: the explicit closed-form roots from this cycle make the perturbation analysis
a direct estimate. **If false**: a worse-than-`1/2` exponent would signal that
tropical root-finding is more ill-conditioned than its classical counterpart,
with direct consequences for numerical tropical geometry.
