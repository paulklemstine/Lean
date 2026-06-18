# Future Directions: Combinatorics of Neural Network Decision Surfaces

## 1. Tight Zaslavsky Bound via Induction on Geometric Arrangements

The current formalization proves the combinatorial identity underlying Zaslavsky's theorem
(the recurrence `maxRegions (n+1) (d+1) = maxRegions n (d+1) + maxRegions n d`) purely
from binomial coefficient algebra. The next step is to formalize the geometric content:
define a hyperplane arrangement in `ℝ^d` as a finite set of affine hyperplanes, define
the connected components of the complement, and prove that the number of components
equals `maxRegions n d` when the arrangement is in general position.

**The key insight is** that the inductive step has a clean geometric interpretation —
removing one hyperplane and counting how the remaining arrangement restricts to it —
which can be formalized using the topology of `ℝ^d` minus a finite union of hyperplanes
(each component is path-connected and open).

**Why now?** Mathlib now has `Convex`, `AffineSubspace`, path-connectedness, and the
topology of `ℝ^d`. The missing piece is the Jordan-like separation theorem for
hyperplanes, which is significantly simpler than the full Jordan curve theorem.

## 2. Montúfar Deep Network Region Bound

For a ReLU network with L hidden layers of width w and input dimension d, the number
of linear regions is at most `⌊w/d⌋^(d(L-1)) · maxRegions w d`. This multiplicative
bound captures the key insight of Montúfar et al. (2014): depth allows *exponentially*
more linear regions than width alone. The current formalization defines the simpler
product bound `deepNetworkRegionBound`; the next step is the folding argument.

**The key insight is** that each hidden layer can "fold" space by a factor of `⌊w/d⌋^d`
through the piecewise-linear structure of ReLU, and this folding is multiplicative
across layers. Formalizing this requires defining the "activation pattern" of a network
(the binary vector indicating which neurons are active) and showing that the number of
distinct patterns equals the number of linear regions.

**Why now?** The combinatorial backbone (`maxRegions` and its properties) is now
formalized. The folding argument is purely combinatorial once activation patterns are
defined — it does not require continuous or topological machinery.

## 3. Euler Characteristic of Decision Surfaces

For a generic ReLU network f: ℝ^d → ℝ, the decision surface V(f) = f⁻¹(0) is a
piecewise-linear (d-1)-manifold (with boundary). Its Euler characteristic χ(V(f)) is
a topological invariant computable from the face numbers of the polyhedral complex.
Conjecture: χ(V(f)) is bounded by an explicit function of the network architecture.

**The key insight is** that the Euler characteristic of a polyhedral complex equals
the alternating sum of face numbers (by Euler's formula), and each face number is
bounded by binomial coefficients of the layer widths. This gives
`|χ(V(f))| ≤ ∑_k (-1)^k · maxRegions(w, d-k)`, an explicit architectural bound
on a topological invariant.

**Why now?** The face count bounds (`pl_hodge_face_count`) are formalized. The
alternating sum formula is elementary combinatorics. The main challenge is defining
"generic" networks (those where the decision surface is a manifold) — this requires
a transversality argument that could be formalized using Sard's theorem (available
in Mathlib as `MeasureTheory.measure_image_eq_zero_of_deriv`).

## 4. Betti Number Bounds for Tropical Hypersurfaces

A ReLU network computes a tropical rational function — the max of affine functions
composed with min operations. The decision surface of such a function is a tropical
hypersurface. Conjecture: the k-th Betti number β_k of a tropical hypersurface
defined by n tropical polynomials in d variables satisfies β_k ≤ C(n,k) · C(n,d-k).

**The key insight is** that tropical hypersurfaces have a dual complex (the regular
subdivision of the Newton polytope), and the Betti numbers of the hypersurface equal
those of the dual complex. The dual complex is a simplicial complex whose simplices
correspond to faces of the arrangement — connecting back to our `maxRegions` bounds.

**Why now?** Tropical geometry has natural connections to ReLU networks (both involve
piecewise-linear functions). The Catalog project already has a Tropical module.
Formalizing the duality between tropical hypersurfaces and regular subdivisions would
create a bridge between the neural network theory and existing tropical geometry work.

## 5. Expressivity Lower Bounds via Topological Complexity

Conjecture: if a target function g: ℝ^d → ℝ has decision surface V(g) with Betti
number β_k(V(g)) = B, then any ReLU network computing g must have at least
`Ω(B^{1/d})` neurons. This would be a topological expressivity lower bound —
fundamentally different from existing approximation-theoretic bounds.

**The key insight is** that each neuron contributes at most one hyperplane, and k
hyperplanes in ℝ^d create at most C(k, d) bounded regions, each contributing at most
1 to each Betti number. So B ≤ maxRegions(k, d), which by our bound gives
B ≤ (ek/d)^d, hence k ≥ Ω(B^{1/d} · d/e).

**Why now?** The upper bounds (`maxRegions_le_two_pow`, `pl_hodge_face_count`) are
formalized. The lower bound argument is essentially an inversion of these upper bounds.
The main formalization challenge is defining Betti numbers for PL complexes, which
could be done combinatorially via simplicial homology over ℤ (without needing the
full algebraic topology machinery).
