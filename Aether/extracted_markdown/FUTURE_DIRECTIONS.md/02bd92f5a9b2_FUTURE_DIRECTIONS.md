# Future Directions: Stereographic Capacity Theory

This cycle established the algebraic backbone of *stereographic capacity
theory* in `Catalog/Geometry/StereographicCapacity/Distortion.lean`: the exact
conformal distortion identity for inverse stereographic projection
ℝ² → S² ⊂ ℝ³,

  ‖σ(x) − σ(y)‖² = λ(x)·λ(y)·‖x − y‖²,   λ(z) = 2/(1 + ‖z‖²),

together with its corollaries (image on the unit sphere, diameter bound
`chordSq ≤ 4`, injectivity, and the `separation_transfer` bridge that converts
spherical cap separation into weighted Euclidean separation). These results sit
directly beneath the calibration bounds already in `Catalog/Geometry/PackingBound.lean`
(`stereoBoundS2_eq_closed`, `packing_bound_S2_pi6_calibration`, etc.) and the
definitional layer in `StereographicCapacity/Defs.lean` (`stereoFactor`,
`StereoSeparated`, `SphericalPackingBound`). The following directions extend the
frontier opened here.

## 1. From the distortion identity to a genuine cardinality packing bound

The current `SphericalPackingBound` predicate in `Defs.lean` is stated but not
yet derived from the distortion identity. The goal is to prove that any finite
`Finset` of `2r`-separated points on S² has cardinality at most
`stereoBoundS2Closed r = 8 / (cos²r (1 − cos r))`, by pushing the configuration
through `separation_transfer` to a weighted plane packing and applying a
volume/area count. **The key insight is** that `separation_transfer` already
converts pairwise chordal separation into the *exact* weighted Euclidean
separation `‖x − y‖² ≥ t·D(x)·D(y)/4`, so the cardinality bound becomes a pure
area-packing estimate against the conformal density `λ(x)²`, with no remaining
spherical geometry. **Why now?** With the identity proven and `chordSq_le_four`
giving the diameter normalization, the only missing ingredient is a measure-
theoretic disjointness lemma over `ℝ²`, which Mathlib's `MeasureTheory` API now
supports directly.

## 2. Sharpening the distortion constant from `(2/cos r)ⁿ` to the true conformal envelope

The conjectured bound uses the worst-case distortion factor `(2/cos r)²`, but
the identity shows the *pointwise* distortion is `λ(x)λ(y)`, which is strictly
smaller away from the projection center. **The key insight is** that integrating
the true conformal factor `λ(x)² = 4/(1+‖x‖²)²` over the plane (its total mass is
exactly the sphere area `4π`) replaces the crude supremum by an average, turning
the `(1 + O(r²))` heuristic into an explicit, provable second-order correction.
**Why now?** The exact identity `chordSq_eq_confFactor` makes the conformal
factor a first-class object in the formalization, so the averaging argument can
be carried out symbolically rather than estimated.

## 3. Dimensional lift: the distortion identity on Sⁿ for all n

The proof of `chordSq_eq` is a polynomial identity that is dimension-agnostic in
spirit but currently hard-coded to ℝ² → S². **The key insight is** that the same
field_simp/ring certificate generalizes verbatim once the projection is phrased
over `EuclideanSpace ℝ (Fin n)` using the existing `stereoFactor` from `Defs.lean`,
because the chordal expansion only ever uses `‖x‖²` and the inner product
`⟪x, y⟫`, never the individual coordinates. **Why now?** `Defs.lean` already
defines `stereoFactor` and `StereoSeparated` in general dimension, so an
`n`-dimensional `chordSq_eq` would immediately unlock packing bounds for spherical
codes in every dimension, the regime relevant to error-correcting codes.

## 4. Geodesic–chordal dictionary and the cap-overlap threshold

To connect cap *geodesic* radius `r` to the chordal threshold used in
`separation_transfer`, one needs `‖σ(x) − σ(y)‖² = 2(1 − cos θ)` where θ is the
geodesic angle, hence non-overlap of radius-`r` caps becomes `chordSq ≥ 2(1 − cos 2r)`.
**The key insight is** that `stereo_mem_sphere` already places images on the unit
sphere, so the dot product of two images equals `1 − ½·chordSq`, giving the
geodesic angle as `arccos(1 − ½·chordSq)` with no further geometry. **Why now?**
This is the one missing link between the algebraic layer proven here and the
trigonometric calibration constants (`cos_pi_div_six`, etc.) already verified in
`PackingBound.lean`, so closing it makes the whole pipeline end-to-end.

## 5. Tightness certificates for the named optimal configurations

`PackingBound.lean` proves the *lower* calibration inequalities
(`12 ≤ stereoBoundS2Closed (π/6)`, etc.), matching the icosahedron, octahedron,
and tetrahedron. The complementary frontier is an explicit *achievability*
witness: exhibit the 12/6/4 vertex coordinates as a `Finset` and prove they are
`StereoSeparated`, certifying that the bound is attained. **The key insight is**
that `stereo_injective` guarantees these vertex sets pull back to genuinely
distinct plane points, so a finite `decide`/`nlinarith` check on the explicit
coordinates suffices to certify pairwise separation. **Why now?** With
injectivity and `separation_transfer` in place, tightness reduces to a finite
arithmetic verification, exactly the regime where Lean's automation excels, and
would upgrade the calibration bounds from "consistent with" to "exactly equal to"
the optimal spherical codes.
