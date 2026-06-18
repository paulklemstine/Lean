# Future Directions: Stereographic Capacity Theory

This cycle established the algebraic and order-theoretic backbone of stereographic
capacity theory in `Geometry/StereographicCapacity/Theorems.lean`, building directly
on the definitions in `Geometry/StereographicCapacity/Defs.lean`
(`stereoFactor`, `stereoExclusionRadius`, `StereoSeparated`, `sphericalCapArea`,
`SphericalPackingBound`, `stereoBoundS2`, `stereoBoundS2Closed`). We proved that the
distortion bound collapses to a clean closed form (`stereoBoundS2_eq_closed`), that a
cap never exceeds the sphere it lives on (`sphericalCapArea_le_sphereArea`), that cap
area is monotone in geodesic radius (`sphericalCapArea_monotone`), and — the geometric
heart of the cycle — that beyond the diameter threshold only one point can be packed
(`sphericalPackingBound_large_radius`), with packing budgets behaving monotonically
(`sphericalPackingBound_mono_B`). The directions below push from these "skeleton"
results toward the genuinely quantitative packing theorems the framework was built for.

## Direction 1: The stereographic transfer principle

The defining bet of the theory is that a `StereoSeparated` Euclidean configuration is
exactly the stereographic image of a `2r`-separated spherical configuration. We should
prove the transfer lemma: if a finite set on `S^n` is `2r`-separated, then its image
under stereographic projection (excluding the north pole) is `StereoSeparated` for `r`,
and conversely. This converts `SphericalPackingBound` statements into statements about
Euclidean exclusion balls, where volume packing arguments are available.

The key insight is that the conformal factor `stereoFactor x = 2/(1+‖x‖²)` is precisely
the first-order ratio between spherical and Euclidean distance, so the exclusion radius
`stereoExclusionRadius r x = tan r / stereoFactor x` is the *correct* linearization that
makes separation transfer hold to leading order — the `tan r` (not `sin r`) is what
upgrades the leading-order statement to an exact pairwise inequality.

Why now? We already have `stereoFactor_pos` and the closed-form distortion bound; the
transfer lemma is the one missing bridge that turns every spherical packing question in
this module into a plane-geometry question, unlocking all later directions.

## Direction 2: A proved Euclidean volume packing bound for `S²`

With the transfer principle in hand, the quantity `stereoBoundS2Closed r =
8/(cos²r·(1−cos r))` should become a *theorem*, not just a definition: for suitable
`r ∈ (0, π/2)`, `SphericalPackingBound 2 r (stereoBoundS2Closed r)` holds. The proof
route is a volume/measure argument — disjoint exclusion balls of total measure at most
the measure of an enclosing region — combined with `stereoBoundS2_eq_closed` to present
the answer in closed form.

The key insight is that `stereoBoundS2_eq_closed` already isolates the *only* analytic
content (an algebraic identity), so the remaining work is purely a disjointness-of-balls
measure estimate, which Mathlib's `MeasureTheory` volume-of-ball API supports directly.

Why now? `stereoBoundS2_eq_closed` and `sphericalCapArea_le_sphereArea` are proved, so
the target inequality is the natural and immediate next milestone, and it would be the
first *quantitative* (non-degenerate) packing bound in the catalog's geometry tree.

## Direction 3: Sharpness at the diameter threshold

`sphericalPackingBound_large_radius` shows at most one point fits when `r > 1`. We should
prove this is sharp and locate the exact transition: for `r ≤ 1` an antipodal pair gives
a `2r`-separated 2-element configuration, so `SphericalPackingBound n r 1` *fails* for
`r ≤ 1` (when `n ≥ 1`), and at the critical value `r = 1` (chord `2`, i.e. antipodal)
exactly two points fit.

The key insight is that the chord length between unit-sphere points equals
`2·sin(θ/2)` for geodesic angle `θ`, so the diameter-2 obstruction used in our proof is
attained *only* by antipodal pairs — making `r = 1` a genuine phase boundary rather than
an artifact of the triangle-inequality slack.

Why now? The upper bound `sphericalPackingBound_large_radius` is freshly proved with an
explicit antipodal witness already implicit in its triangle-inequality argument;
formalizing the matching lower bound is a small, self-contained companion result.

## Direction 4: Dimension-uniform caps and the simplex bound

`sphericalCapArea` is currently `S²`-specific. We should define the `S^n` cap measure
and prove the analogue of `sphericalCapArea_le_sphereArea` and
`sphericalCapArea_monotone` in every dimension, then derive the classical *simplex
bound*: for `2r ≥ π/2` (caps subtending a right angle), at most `n + 2` points fit on
`S^n`, realized by the regular simplex.

The key insight is that mutually `90°`-or-more separated unit vectors are pairwise
non-acute, and a set of pairwise non-acute unit vectors in `ℝ^{n+1}` has size at most
`n + 2` — a linear-algebra fact (rank/Gram-matrix positivity) that sidesteps measure
theory entirely and meshes with the catalog's existing Gram-matrix and inner-product
machinery.

Why now? Our monotonicity and budget-monotonicity lemmas (`sphericalCapArea_monotone`,
`sphericalPackingBound_mono_B`) are dimension-agnostic in spirit; generalizing the cap
definitions is the cross-domain step that connects this geometry module to the catalog's
linear-algebra results and yields an integer packing bound provable without analysis.

## Direction 5: Asymptotics of the distortion bound as `r → 0`

The closed form `stereoBoundS2Closed r = 8/(cos²r·(1−cos r))` should be analyzed in the
small-cap limit. Using `1 − cos r ∼ r²/2` and `cos²r → 1`, we get
`stereoBoundS2Closed r ∼ 16/r²`, matching the known `Θ(r^{-2})` growth of `S²` packing
numbers. We should prove a two-sided asymptotic `c₁/r² ≤ stereoBoundS2Closed r ≤ c₂/r²`
on a fixed interval `(0, r₀]`.

The key insight is that `stereoBoundS2_eq_closed` already gives the exact rational-trig
form, so the asymptotic reduces to elementary bounds on `cos` and `1 − cos` that
Mathlib provides (`Real.cos_le_one`, `Real.one_sub_cos_*` style estimates and
`Real.cos_lt_one`), making a fully rigorous packing-number growth rate attainable.

Why now? With the closed form proved this cycle, the order-of-growth statement is the
cheapest way to demonstrate the theory recovers the textbook `r^{-2}` packing scaling,
providing an external sanity check on the whole framework.
