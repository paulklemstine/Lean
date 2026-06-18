# Future Directions: Stereographic Capacity Theory

This cycle established the algebraic and geometric backbone of *stereographic
capacity theory* — the program of converting spherical cap-packing questions on
`Sⁿ` into weighted Euclidean separation problems on `ℝⁿ` via stereographic
projection. The proven results (`Geometry/StereographicCapacity/Theorems.lean`)
are:

- the conformal factor `λ(x) = 2/(1+‖x‖²)` is strictly positive, bounded by `2`,
  and attains `2` exactly at the origin (`stereoFactor_pos`,
  `stereoFactor_le_two`, `stereoFactor_eq_two_iff`);
- the weighted exclusion radius has the closed form
  `tan r · (1+‖x‖²)/2` (`stereoExclusionRadius_eq`);
- the `S²` distortion bound collapses to `8/(cos²r·(1−cos r))`
  (`stereoBoundS2_eq_closed`);
- a sharp degenerate packing bound: for geodesic radius `r > 1` every
  `2r`-separated subset of `Sⁿ` is a singleton (`spherePacking_card_le_one`,
  `sphericalPackingBound_one_of_one_lt`), together with monotonicity of the
  bound predicate in its budget (`sphericalPackingBound_mono`).

These connect to the catalog's broader stereographic toolkit — in particular the
inner-product transport formula of `StereographicPersistence` (`inner_stereoInvFun`,
`stereoDist_eq`) and the bi-Lipschitz comparison `stereoDist_biLipschitz_on_bounded`,
which is precisely the analytic bridge needed to make the conjectures below
rigorous. The directions below are stated to be testable and falsifiable: each can
be refuted by a single explicit configuration or numerical counterexample.

## Direction 1: The separation transport theorem

**Conjecture.** There is a constant regime in which `StereoSeparated r s`
(Euclidean weighted separation of the projected points) is *equivalent* to genuine
`2r`-geodesic separation on `Sⁿ` of their inverse stereographic images, with the
equivalence becoming exact as `r → 0`.

The key insight is that `stereoExclusionRadius_eq` writes the exclusion radius as
`tan r · (1+‖x‖²)/2 = tan r / λ(x)`, i.e. the *Euclidean* radius is exactly the
spherical radius rescaled by the local conformal factor — so a first-order
matching of `tan r` against geodesic chord length should turn the predicate
`StereoSeparated` into a faithful proxy for cap disjointness.

Why now? The catalog already contains `stereoDist_eq` (geodesic distance as
`arccos` of a closed-form inner product) and `stereoDist_biLipschitz_on_bounded`;
chaining `stereoExclusionRadius_eq` with these two gives an explicit two-sided
estimate, so the conjecture is reachable without building new transcendental
machinery.

## Direction 2: A genuine quantitative cap-packing upper bound on S²

**Conjecture.** For every `r` with `0 < r < π/2`, `SphericalPackingBound 2 r B`
holds with `B = stereoBoundS2Closed r = 8/(cos²r·(1−cos r))`; moreover this is the
best bound obtainable by the pure area/conformal-distortion method, off the true
packing number by at most a bounded multiplicative constant.

The key insight is that the volume (area) argument — total sphere area divided by
minimal cap area, inflated by the squared worst-case conformal distortion
`(2/cos r)²` — is captured *exactly* by `stereoBoundS2_eq_closed`, so the only
remaining step is to certify that distortion factor against a packed
configuration rather than re-deriving the algebra.

Why now? `stereoBoundS2_eq_closed` already proves the closed form is correct, and
`spherePacking_card_le_one` shows the predicate `SphericalPackingBound` is
provable in nontrivial regimes; the missing ingredient is a single
area-monotonicity lemma for `sphericalCapArea`, which is elementary calculus.

## Direction 3: Sharpness of the degenerate bound at r = 1

**Conjecture.** The threshold `r > 1` in `spherePacking_card_le_one` is sharp:
for every `r ≤ 1` and every `n ≥ 1` there exists a two-point `2r`-separated subset
of `Sⁿ` (the antipodal pair `±e₀`), so `SphericalPackingBound n r 1` *fails* for
all `r ≤ 1`.

The key insight is that the unit sphere has diameter exactly `2`, attained only by
antipodal pairs; since `2r ≤ 2` precisely when `r ≤ 1`, the antipodal pair is
admissible exactly on the complement of the proven regime, pinning the threshold.

Why now? `spherePacking_card_le_one` already isolates `r = 1` as the critical
value through the inequality `2r ≤ ‖x‖+‖y‖ = 2`; constructing the antipodal
witness only needs `EuclideanSpace.single 0 1` and its negation, both already in
Mathlib, making this a clean falsification target for the proven theorem's
hypotheses.

## Direction 4: Dimension scaling of the conformal distortion bound

**Conjecture.** The `S²` bound generalizes to `Sⁿ` as
`stereoBoundSn n r = (2/cos r)ⁿ · (vol Sⁿ / capVol n r)`, and the exponent `n` on
the distortion factor is *unavoidable*: the worst-case conformal stretch of
stereographic projection grows like `λ⁻ⁿ` in `n` dimensions, so any projection-based
bound inherits an exponential-in-`n` distortion penalty.

The key insight is that the Jacobian of stereographic projection is `λ(x)ⁿ` in
dimension `n`, so the single squared factor `(2/cos r)²` proven for `S²` is the
`n = 2` instance of a uniform `(2/cos r)ⁿ` law — the `S²` closed form is a
shadow of a dimension-graded family.

Why now? With `stereoFactor` and `stereoExclusionRadius` already defined
dimension-generically over `EuclideanSpace ℝ (Fin n)`, only the cap-volume term
`capVol n r` needs formalizing; this isolates exactly where projection methods
lose to lattice/LP methods and quantifies the gap as a function of `n`.

## Direction 5: Bridge to error-correcting codes via spherical codes

**Conjecture.** Every `2r`-separated configuration on `Sⁿ` yields, through inverse
stereographic projection composed with a fixed quantizer, a spherical code whose
minimum angular distance is controlled below by `stereoExclusionRadius`, giving an
explicit, computable lower bound on achievable code rates from packing data.

The key insight is that `stereoExclusionRadius_eq` provides a *closed-form,
pointwise* lower bound on Euclidean separation in terms of the spherical radius `r`
and the projected norm `‖x‖`, which is exactly the quantity a code's
distance-rate tradeoff is phrased in — so capacity theory exports directly into
coding bounds without an intermediate metric estimate.

Why now? The catalog's stereographic inner-product formula (`inner_stereoInvFun`)
already expresses spherical correlation in closed form; combined with
`stereoExclusionRadius_eq` it turns a packing certificate into a code-distance
certificate mechanically, opening a concrete applications pathway from the
abstract capacity bounds proven this cycle.
