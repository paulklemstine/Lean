# Future Directions — Tropical Convexity

## Synthesis

This cycle attacked the tropical (max-plus) domain from the angle of *convex
analysis*. The catalog already contained the degree-1 and degree-2 tropical
polynomials (`tropicalLinear`, `tropicalQuadratic`) together with monotonicity
facts (`tropical_linear_mono`, `tropical_quadratic_mono`) and the basic
semiring laws (`tropical_scalar_distrib`, `tropical_add_assoc`, …). The
structural observation that drove this cycle is that **monotonicity is the wrong
invariant to track**: the genuinely robust property of a tropical polynomial is
that it is a finite pointwise maximum of *affine* functions, and a finite
pointwise maximum of convex functions is convex. So we replaced the catalog's
case-by-case monotonicity lemmas with a single uniform notion, `ConvexOn`, that
holds at *every* degree and (as it turned out) in *every* dimension.

The cycle's central engine is `convexOn_finset_sup'`: the pointwise `Finset.sup'`
of a family of convex functions is convex. With that in hand,
`tropPoly_convexOn` — every degree-`n` tropical polynomial is convex — is a
one-line corollary, and `tropPoly_midpoint_le` (a tropical Jensen inequality)
follows by specializing the convex-combination bound to weights `(½,½)`. The
attempted Step-7 generalization to an arbitrary real vector-space domain,
`tropPoly_convexOn_general`, *succeeded outright* rather than remaining a
conjecture: the proof never used one-dimensionality, which is itself the key
structural lesson — tropical hypersurfaces are convex objects in all dimensions.

What failed / where the boundary is: the freshman's-dream / Frobenius identity
`k·max(a,b) = max(k·a,k·b)` is *exactly* the place where sign matters. It holds
iff `k ≥ 0`; for `k < 0` scaling reverses order and `max` collapses to `min`.
This sign sensitivity is the honest boundary of the whole "tropical = convex"
picture: convexity of `tropPoly` needed *no* sign hypothesis on the slopes, but
the multiplicative power rule does. The directions below push on exactly these
seams: dropping convexity of the pieces, sharpening Jensen to full convexity
combinations, and turning the convexity statement into a Newton-polygon /
piecewise-linearity structure theorem.

## Results Summary

- `tropMonomial_convexOn`: proved — a single tropical monomial `a + c·x` is convex on `ℝ`.
- `tropMonomial_concaveOn`: proved — it is also concave (affine ⇒ both), pinning down that the convexity in tropical polynomials comes only from the `max`, never from the monomials.
- `convexOn_finset_sup'`: proved — the pointwise `Finset.sup'` of convex functions is convex; the structural engine of the cycle.
- `tropPoly_convexOn`: proved (MAIN) — every degree-`n` tropical polynomial is convex, generalizing the catalog's degree-1/2 monotonicity lemmas.
- `tropPoly_monotone_of_slopes_nonneg`: proved — nonnegative slopes ⇒ globally monotone increasing, the all-degrees version of `tropical_linear_mono`/`tropical_quadratic_mono`.
- `tropPoly_midpoint_le`: proved — tropical Jensen midpoint inequality, a quantitative corollary of convexity.
- `tropical_freshmans_dream`: proved — max-plus Frobenius/power rule `k·max(a,b)=max(k·a,k·b)` for `k ≥ 0`; disproved for `k<0` (boundary case).
- `tropPoly_convexOn_general`: proved — multivariate generalization over any real vector-space domain; the intended Step-7 conjecture turned into a theorem.

## Research Directions

### Direction 1: Non-convex pieces break tropical convexity (sharpness)
**Hypothesis**: There exist functions `f g : ℝ → ℝ` with `g` convex but `f` not,
such that `fun x => max (f x) (g x)` is not convex; hence the convexity
hypothesis in `convexOn_finset_sup'` cannot be dropped, even for two pieces.
**Test**: Construct an explicit counterexample (e.g. `f x = -x²`, `g x = 0`) and
prove `¬ ConvexOn ℝ univ (fun x => max (f x) (g x))` by exhibiting a violated
midpoint inequality at a concrete triple of points.
**Why now**: This cycle isolated convexity-of-pieces as the *only* assumption the
proof actually uses (dimension was shown irrelevant by `tropPoly_convexOn_general`),
so the natural sharpness question is whether that single assumption is necessary.
**If true**: It certifies `convexOn_finset_sup'` as tight and clarifies that
"tropical = convex" is exactly the statement that the monomials are affine.
**If false**: A weaker sufficient condition (e.g. quasiconvex pieces) would be a
strictly stronger theorem and worth formalizing.

### Direction 2: Full tropical Jensen, not just midpoints
**Hypothesis**: For any finite family of weights `w : Fin m → ℝ≥0` with
`∑ w j = 1` and points `p : Fin m → ℝ`,
`tropPoly coeffs slopes (∑ j, w j * p j) ≤ ∑ j, w j * tropPoly coeffs slopes (p j)`.
**Test**: Derive it from `tropPoly_convexOn` via `ConvexOn.inner_smul_le_map_sum`
/ `ConvexOn.map_centerMass_le` from Mathlib; confirm the API matches.
**Why now**: `tropPoly_midpoint_le` already extracts the 2-point case from
convexity; the general finite-weight version is the same theorem with the full
`ConvexOn` combination lemma, so the groundwork is in place.
**If true**: Gives a ready-made "tropical Jensen" usable in tropical
probability / large-deviations bridges already present in the catalog
(`Catalog/Bridges/EMLTropicalBridge`).
**If false** (i.e. the Mathlib lemma needs extra hypotheses): it pinpoints
exactly which regularity (continuity, closedness of the domain) the finite
extension secretly relies on.

### Direction 3: Newton-polygon structure theorem (convexity ⇒ piecewise-linear)
**Hypothesis**: `tropPoly coeffs slopes` equals the support function of the
finite point set `{(slopes i, coeffs i)}`, and is therefore a *piecewise-linear*
convex function whose distinct linear pieces are indexed by the vertices of the
upper convex hull (the Newton polygon).
**Test**: Define `tropRoots` as the breakpoints where the arg-max changes, and
prove that on each maximal interval `tropPoly` agrees with a single
`tropMonomial`; count the number of pieces by the hull's vertices.
**Why now**: We have proved convexity (`tropPoly_convexOn`); convex + finite-max
of affine ⇒ piecewise-linear is the next structural layer, and the `Finset.sup'`
representation already exposes the candidate pieces.
**If true**: It formalizes the tropical/Newton-polygon dictionary and connects to
`Catalog/Bridges/AlgebraTropicalGeometry/TropicalBezoutFactorization`.
**If false**: Failure would reveal a degeneracy (coincident slopes) that the
naive breakpoint definition mishandles, guiding a corrected definition.

### Direction 4: The sign boundary — a tropical "min-plus" Frobenius
**Hypothesis**: For `k < 0`, `k * max a b = min (k*a) (k*b)`, and more generally
the sign of `k` toggles between the max-plus and min-plus semirings; thus
`tropical_freshmans_dream` has an exact min-plus mirror with a flipped operation.
**Test**: Prove `k ≤ 0 → k * max a b = min (k*a) (k*b)` by the same case split,
and package both as one statement parameterized by `Sign k`.
**Why now**: This cycle's Lab Notebook flagged `k<0` as the precise failure point
of the freshman's dream; turning that failure into a clean min-plus theorem is
immediate and converts a boundary into a result.
**If true**: It gives a uniform "signed tropical scaling" law unifying the
max-plus and min-plus catalogs.
**If false**: It would mean the order reversal interacts non-trivially with ties,
flagging a subtlety in how `max`/`min` handle equal arguments under scaling.

### Direction 5: Tropical polynomials are globally Lipschitz with explicit constant
**Hypothesis**: `tropPoly coeffs slopes` is Lipschitz with constant
`max_i |slopes i|`; i.e.
`|tropPoly _ _ x - tropPoly _ _ y| ≤ (max_i |slopes i|) * |x - y|`.
**Test**: Bound each `|coeffs i + slopes i·x - (coeffs i + slopes i·y)|` by
`|slopes i|·|x-y|`, then transfer the bound through `Finset.sup'` using that
`sup'` is 1-Lipschitz in the sup norm of its argument family.
**Why now**: Convexity (this cycle) plus the affine pieces give an obvious slope
bound; Lipschitz-ness is the analytic counterpart that complements the order- and
convexity-theoretic results already proved.
**If true**: It supplies the quantitative regularity needed for tropical neural
network robustness bounds (`Catalog/Tropical/NeuralNetworks/TropicalDegreeRobustness`).
**If false**: The candidate constant must be wrong, indicating that the relevant
constant is instead the diameter of the slope set, which is itself informative.
