# Future Directions: Multivariate Tropical Phase Transitions in Learning

## Synthesis

This cycle lifts the one-dimensional tropical phase-transition theory of
`Catalog/Tropical/GrokPhaseTransition.lean` (`affine1D_convexOn`,
`trop1D_two_piece_convexOn`, `crossover_monotone_in_gap`) into `ℝⁿ`, the regime
that models an actual ReLU layer, in
`Catalog/Tropical/MultivariatePhaseTransition.lean`. The unifying observation is
that the entire tropical hierarchy reduces to two elementary facts — affine
pieces are convex, and convexity is closed under binary maximum — once finite
maxima are handled by `Finset.sup'_induction`. From there convexity becomes a
*width-independent, coordinate-free invariant*, which is exactly what turns a
local geometric fact (a single non-convex line restriction) into a global
architecture lower bound.

## Results Summary

Proved, with `sorry`-free proofs depending only on `propext`,
`Classical.choice`, `Quot.sound`:

1. `affineFun_convexOn` — affine functionals `x ↦ ⟨a,x⟩ + b` on `ℝⁿ` are convex.
2. `mvTropical_poly_convexOn` — every finite tropical maximum over `ℝⁿ` is convex
   (the multivariate lift of `trop1D_two_piece_convexOn`).
3. `tropical_hypersurface_facet_bound` — an `m`-monomial tropical hypersurface in
   `ℝⁿ` has at most `m choose 2` co-dimension-one facets, via `card_filter_le`
   and `card_powersetCard`.
4. `twoLayer_relu_convexOn` — two-layer ReLU networks with nonnegative outer
   weights compute convex functions, at any width.
5. `tropical_restrict_to_line_convexOn` — convexity transfers to every line
   restriction (the bridge back to the 1-D crossover theory).
6. `nonconvex_not_twoLayer_relu` — a separation engine: any function whose
   restriction to some line is non-convex is unrealizable by such networks.

Supporting 1-D results: `affine1D_convexOn`, `trop1D_two_piece_convexOn`,
`crossover_monotone_in_gap`, `crossover_balances`.

## Research Directions

### 1. Tightness of the facet bound in generic position

We proved `tropical_hypersurface_facet_bound`: at most `m choose 2` facets. The
matching lower bound should hold generically — pick slopes `aᵢ ∈ ℝⁿ` and
intercepts `bᵢ` so that *every* pair attains co-dominance on a nonempty piece of
the hyperplane `⟨aᵢ - aⱼ, x⟩ = bⱼ - bᵢ`, giving `(facetPairs s a b).card =
(s.card).choose 2` exactly. **The key insight is** that generic intercepts make
the `m choose 2` co-dominance hyperplanes mutually non-redundant, so the
`CoDominant` predicate holds for every 2-subset and the filtered cardinality
saturates the bound. **Why now?** The upper bound is already a one-line `Finset`
fact; the lower bound only requires exhibiting one explicit witness family (e.g.
`aᵢ = i • e₁` with strictly convex intercepts) and proving each pair active — a
finite, constructive obligation, not new theory.

### 2. Strict-local-maximum certificates against depth

`nonconvex_not_twoLayer_relu` already rules out non-convex targets for
nonnegative two-layer nets. The next step is to manufacture *reusable* witnesses:
prove that any `f` with a strict interior local maximum fails the midpoint
inequality on the line through the maximizer, hence triggers the separation
engine. **The key insight is** that a strict local maximum is a purely local,
scalar certificate, so one `ConvexOn`-violating triple `(x₀, v, λ)` rules out the
entire nonnegative-weight architecture class independent of width. **Why now?**
With `tropical_restrict_to_line_convexOn` and `twoLayer_relu_convexOn` in hand,
the only missing lemma is "strict local max ⇒ some line restriction non-convex",
a standard one-variable midpoint computation.

### 3. Tropical Legendre–Fenchel duality over `ℝⁿ`

`mvTropical_poly_convexOn` is exactly the hypothesis the Legendre–Fenchel
transform needs to be involutive. Define the tropical dual of
`p(x) = maxᵢ (⟨aᵢ,x⟩ + bᵢ)` as the support function of the Newton polytope
`conv{aᵢ}` weighted by `bᵢ`, and prove `p** = p`. **The key insight is** that
convexity guarantees the dual is single-valued, so implicit regularization
(minimum-norm interpolation) becomes a well-posed selection of the Newton
polytope with minimum perimeter. **Why now?** Convexity over `ℝⁿ` was the precise
missing prerequisite, and Mathlib's `ConvexOn` / `comp_affineMap` /
support-function API makes the dual definable today.

### 4. Multiplicative facet growth under composition (depth separation)

Composing `d` tropical layers can multiply the number of linear regions.
Conjecture: there is a width-`w` depth-`(d+1)` circuit whose hypersurface has
strictly more facets than any width-`w` depth-`d` circuit, with the gap growing
like `w^d`. **The key insight is** that `facetPairs` is a monotone `Finset`
cardinality that is sub-multiplicative under tropical sum but *super-additive*
under composition, so iterating the `CoDominant` construction across layers
yields a facet count no shallower circuit can match — a combinatorial
depth-lower-bound certificate. **Why now?** The facet count is now a formally
defined, monotone functional; tracking its transformation under the
convexity-preserving two-layer map `twoLayer_relu_convexOn` is the concrete next
step.

### 5. Quantitative crossover dynamics along training lines

`tropical_restrict_to_line_convexOn` says every line restriction of the
landscape is a convex piecewise-linear curve with finitely many breakpoints.
Conjecture: gradient flow projected onto such a line crosses at most `m - 1`
breakpoints, and the dwell time near a breakpoint scales as `Θ(1/gap)` in the
co-dominance gap — the tropical analogue of saddle-point slowdown producing
delayed generalization ("grokking"). **The key insight is** that convexity forces
breakpoints to be totally ordered along the line, so the trajectory visits them
monotonically and the dwell-time analysis reduces to the 1-D
`crossover_monotone_in_gap` estimate already formalized. **Why now?** The
line-restriction theorem converts the multivariate dynamical question into the
exact 1-D setting where the monotone-crossover machinery is complete.
