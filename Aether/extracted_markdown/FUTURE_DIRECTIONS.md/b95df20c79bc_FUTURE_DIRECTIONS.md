# Future Directions: Tropical Canonical Forms for Neural Networks

## 1. Multivariate Extension: Tropical Rational Forms for Deep ReLU Networks

We proved that every *univariate* ReLU network computes a CPL function with a
unique canonical tropical rational form. The natural next step is extending to
multivariate inputs: a network f : ℝⁿ → ℝ computes a continuous piecewise-linear
function, and its tropical structure lives in the max-plus algebra over ℝⁿ.

**The key insight is**: in dimension n > 1, the breakpoint set becomes a
polyhedral complex (union of hyperplanes), and the analogue of our
`crossing_zeros_finite` theorem becomes a statement about the combinatorial
complexity of tropical hypersurface arrangements. The finiteness argument via
injection into gaps of the breakpoint set generalizes to an injection into
cells of the arrangement.

**Why now?** Our proof of `crossing_zeros_finite` via the "gap injection" technique
(mapping crossing zeros to gaps between breakpoint set elements) provides a template.
In higher dimensions, this becomes an injection from crossing hyperplanes to cells
of a polyhedral subdivision, which is bounded by McMullen's upper bound theorem.
The `locally_affine_implies_globally_affine_on_Ioo` lemma generalizes to convex
open regions in ℝⁿ using the same connectedness argument.

## 2. Quantitative Breakpoint Bounds: Depth-Width Tradeoffs via Tropical Degree

Our proof shows that `cpl_relu` adds at most |S|+1 new breakpoints per ReLU layer.
This gives an explicit upper bound on the number of linear regions of a ReLU network
as a function of depth and width. Specifically, a network with L layers of width w
should have at most O(w^L) breakpoints, matching the known Montúfar et al. (2014)
upper bound.

**The key insight is**: our `crossing_zeros_finite` proof provides a *constructive*
upper bound: the crossing zeros inject into Fin(|S|+1), where |S| is the breakpoint
count of the inner function. Iterating this through the network architecture gives
explicit combinatorial bounds. The "tropical degree" of the rational form should
equal the number of breakpoints, making this bound algebraically transparent.

**Why now?** The injection argument in our proof is already quantitative — we showed
|C| ≤ |S| + 1 using the Finset.card comparison. Making this bound tight and
relating it to network architecture (depth, width, skip connections) would yield
the first formally verified neural network expressivity bounds.

## 3. Decidable Equivalence via Canonical Tropical Rational Forms

Our file proves `univReluNet_is_cpl` (every ReLU network computes a CPL function),
but the full canonicalization pipeline — from CPL function to minimal tropical
rational form — remains partially formalized (the `cpl_is_tropical_rational` and
`exists_unique_minimal_tropical_rational` theorems in the Catalog file still need
proofs).

**The key insight is**: the construction of the tropical rational form from a CPL
function proceeds by decomposing f = f⁺ - f⁻ where f⁺ = max(f, 0) and
f⁻ = max(-f, 0). Both f⁺ and f⁻ are convex CPL functions, hence tropical
polynomials (maxima of affine functions). The canonical form is obtained by
removing redundant terms (non-essential affine pieces). Our `cpl_relu` proof
already handles the key step (f⁺ is CPL), and the remaining work is constructive.

**Why now?** The `locally_affine_implies_globally_affine_on_Ioo` lemma provides
the foundation: it shows that on each interval between breakpoints, the function
is globally affine, giving explicit slope-intercept pairs. Collecting these into
a tropical polynomial is straightforward. The minimality/canonicality then follows
from the already-proved `canonical_tropical_poly_unique` in the Catalog file.

## 4. Tropical Verification of Neural Network Properties

With canonical forms established, one can verify properties of neural networks
(monotonicity, Lipschitz bounds, interval bounds) by inspecting the tropical
rational form rather than running the network.

**The key insight is**: the slopes of the affine pieces in the canonical tropical
polynomial directly encode the Lipschitz constant (max |slope|) and monotonicity
(all slopes same sign) of the network. Our proof infrastructure — particularly
`locally_affine_implies_globally_affine_on_Ioo` and the `AffinePiece` structure —
makes these properties directly computable from the canonical form.

**Why now?** Our formalization already has the `AffinePiece` structure with explicit
slopes and intercepts. Proving that the Lipschitz constant equals
`max{|p.slope| : p ∈ canonical_form.terms}` should follow directly from the
canonical uniqueness theorem and our `tropical_poly_term_le` lemma.

## 5. Tropical Newton Polytopes and Network Expressivity Classification

The Newton polytope of a tropical polynomial (the convex hull of its exponent
vectors) encodes which functions the polynomial can represent. In the univariate
case, this is simply the interval [min_slope, max_slope]. Classifying which
CPL functions have "small" tropical rational representations (small Newton polytope)
versus "large" ones would give a tropical complexity theory for neural networks.

**The key insight is**: our `StrictlyIncreasingSlopes` predicate in the canonical
form already encodes the Newton polytope structure. A network with L layers of
width w can produce at most w^L distinct slopes, so the Newton polytope has at
most w^L vertices. Functions requiring more slopes need deeper or wider networks.
This connects tropical geometry to neural network architecture search.

**Why now?** The formal infrastructure (`TropicalPoly.Canonical`, `AllStrictlyEssential`,
`StrictlyIncreasingSlopes`) provides the right abstractions. The Newton polytope
is just `{p.slope : p ∈ P.terms}` for a canonical `P`, and our uniqueness theorem
ensures this is an invariant of the function, not the representation.
