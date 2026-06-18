# Future Directions — Tropical Polynomials (Convexity Foundation)

This cycle delivered a self-contained Mathlib foundation for **general-degree tropical
(max-plus) polynomials** in `Catalog/Tropical/Core/TropicalConvexity.lean`, generalizing the
catalog's existing degree-1 / degree-2 results. We modelled the polynomial as a
`Finset.sup'` of affine pieces *in the function space* `ℝ → ℝ`, which made convexity,
monotonicity, the Jensen midpoint inequality, coefficient shifts, value attainment, and the
eventual top-slope (tropical degree) theorem all accessible. Below are bold, testable
conjectures for follow-up cycles.

## C1. Tropical multiplicativity is an evaluation homomorphism
Define the **max-plus convolution** of coefficient vectors `a : Fin (m+1) → ℝ`,
`b : Fin (n+1) → ℝ` by `(a ⊛ b)_k = max_{i+j=k} (a_i + b_j)`, a vector indexed by
`Fin (m+n+1)`. Conjecture:
```
tropPolyFun (a ⊛ b) x = tropPolyFun a x + tropPolyFun b x   (for all x)
```
i.e. tropical polynomial multiplication corresponds to *pointwise addition* of evaluations.
Testable corollary: `deg (a ⊛ b) = deg a + deg b`, recovered from `tropPoly_eventually_top`.

## C2. Fundamental theorem of tropical algebra (PL characterization)
A function `f : ℝ → ℝ` equals `tropPolyFun a` for some `a : Fin (n+1) → ℝ` **iff** `f` is
continuous, convex, piecewise-linear with all slopes in `{0,1,…,n} ⊆ ℕ`, and breakpoints of
integer-spacing structure. Conjecture: the map `a ↦ tropPolyFun a` is surjective onto this
class, and two coefficient vectors give the same function iff they have the same
**concave/upper hull** (the "tropically equivalent" relation). This connects to the existing
`Catalog/Tropical/Applications/TropicalEquivalenceInvariance.lean`.

## C3. Tropical roots = breakpoints, with multiplicity = slope jump
Define a *tropical root* of `tropPolyFun a` as a point where the max is attained by ≥ 2
distinct monomials. Conjecture: counted with multiplicity (= jump in the right-slope), the
number of tropical roots equals the degree `n` whenever the coefficient vector is in
"general position" (its points `(i, a_i)` are in strictly convex position). This is the
tropical analogue of the fundamental theorem of algebra.

## C4. Tropical Jensen / power-mean monotonicity
Strengthen `tropPoly_midpoint`: for weights `w : Fin k → ℝ≥0` summing to 1 and points
`x : Fin k → ℝ`,
```
tropPolyFun a (∑ j, w j • x j) ≤ ∑ j, w j • tropPolyFun a x j.
```
Conjecture: equality holds iff all `x j` lie in a single linearity region of `tropPolyFun a`.
This is `ConvexOn.inner_smul_le_map_sum` specialized, and the equality case is new.

## C5. Multivariate convexity and Newton-polytope duality
Extend `tropPolyFun` to `n` variables: `p(x) = max_α (a_α + ⟨α, x⟩)` over a finite support
`α ∈ S ⊆ ℕ^d`. Conjecture: `p` is convex on `ℝ^d` (immediate from the same `sup'_induction`
argument), and its regions of linearity are dual to the regular subdivision of the **Newton
polytope** `conv(S)` induced by the heights `a_α`. A first testable milestone: prove
`ConvexOn ℝ Set.univ p` in the multivariate setting, reusing `affine_conv` generalized to
inner products.
