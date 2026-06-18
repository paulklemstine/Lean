# Future Directions: Stereographic Capacity Theory (Cycle 2)

## Synthesis

This cycle turned the *skeleton* of stereographic capacity theory into a small but
load-bearing, fully verified module under `Geometry/StereographicCapacity/`. The
`Defs.lean` file fixes the vocabulary — the conformal factor `stereoFactor x = 2/(1+x²)`,
the linearized exclusion radius `stereoExclusionRadius r x = tan r / stereoFactor x`, the
packing predicates `OnSphere`, `Separated`, `SphericalPackingBound` over the genuine
Euclidean sphere `Sⁿ ⊂ ℝⁿ⁺¹`, the cap/sphere measures `sphericalCapArea`, `sphereArea`,
and the distortion bound `stereoBoundS2` with its closed form `stereoBoundS2Closed`.
`Theorems.lean` proves the backbone and, crucially, pushes past it into two *quantitative*
results that were only conjectural in the previous cycle: the **sharpness** of the
diameter threshold and the **two-sided `Θ(r⁻²)` asymptotic** of the closed-form bound.

## Results Summary (all `sorry`-free, only standard axioms)

- `stereoFactor_pos`, `stereoFactor_le_two` — the conformal factor lives in `(0, 2]`.
- `stereoBoundS2_eq_closed` — the distortion bound collapses to
  `8/(cos²r·(1−cos r))` as an *unconditional* algebraic identity (the only analytic
  content is the cancellation of `π`).
- `sphericalCapArea_le_sphereArea` — a cap never beats its sphere (`2π(1−cos r) ≤ 4π`).
- `sphericalCapArea_monotone` — cap area is monotone in geodesic radius on `[0, π]`.
- `sphericalPackingBound_mono_B` — the packing budget is monotone.
- `sphericalPackingBound_large_radius` — beyond the diameter threshold `r > 1` (chord
  `> 2`) at most one point can be packed on **any** `Sⁿ`.
- `sphericalPackingBound_fails_small_radius` — the matching lower bound: for `r ≤ 1`
  (in dimension `n ≥ 1`) the antipodal pair `{e₀, −e₀}` is `2r`-separated, so the bound
  `1` *fails*; the threshold `r = 1` is genuinely sharp.
- `stereoBoundS2Closed_asymptotic` — on `(0, 1]`,
  `16/r² ≤ stereoBoundS2Closed r ≤ 16π²/r²`, recovering the textbook `Θ(r⁻²)` packing
  growth with the sharp leading constant `16` on the lower side.

The two new "phase boundary" facts (`sphericalPackingBound_large_radius` together with
`sphericalPackingBound_fails_small_radius`) pin the packing transition exactly at `r = 1`,
and the asymptotic gives the framework its first honest order-of-growth statement.

## Direction 1: The exact two-sided constant and the location of the optimum

We proved `16/r² ≤ stereoBoundS2Closed r ≤ 16π²/r²` on `(0,1]`, a factor `π²` gap. The
next milestone is to *close the constant*: prove
`limₐ→0₊ r²·stereoBoundS2Closed r = 16` and, more strongly, that
`r ↦ r²·stereoBoundS2Closed r` is monotone (or unimodal) on `(0, π/2)`, so the leading
constant `16` is attained only in the small-cap limit.

The key insight is that `stereoBoundS2_eq_closed` already exposes the exact rational-trig
form, so the entire question reduces to the analytic behavior of the single scalar
function `g(r) = r²/(cos²r·(1−cos r))` and the textbook expansion `1−cos r = r²/2 − r⁴/24
+ O(r⁶)`, which Mathlib's `Real.cos` Taylor estimates support.

Why now? The two-sided sandwich is already formalized, so tightening it from a `π²`-gap
to the exact limit `16` is a self-contained analysis exercise that upgrades a qualitative
`Θ(r⁻²)` statement into a quantitative packing-number asymptotic.

## Direction 2: The stereographic transfer principle (the missing bridge)

`StereoSeparated` is defined but not yet *connected* to `Separated`. The defining bet of
the theory is the transfer lemma: the stereographic image of a `2r`-separated spherical
configuration (excluding the north pole) is exactly `StereoSeparated` for `r`, and
conversely. This converts every `SphericalPackingBound` statement into a Euclidean
exclusion-ball statement where volume packing arguments live.

The key insight is that the conformal factor `stereoFactor x = 2/(1+‖x‖²)` is precisely
the first-order ratio between spherical and Euclidean distance, so the exclusion radius
`tan r / stereoFactor x` is the *exact* linearization — the `tan r` (not `sin r`) is what
upgrades the leading-order statement to an exact pairwise inequality.

Why now? With `stereoFactor_pos`, `stereoFactor_le_two`, and the closed-form distortion
identity all proved, the transfer lemma is the one remaining bridge, and it would let the
freshly proved `sphericalPackingBound_*` results be re-derived purely in the plane.

## Direction 3: A proved Euclidean volume packing bound for `S²`

Promote `stereoBoundS2Closed r` from a *definition* to a *theorem*: for suitable
`r ∈ (0, π/2)`, prove `SphericalPackingBound 2 r (stereoBoundS2Closed r)` by a
disjointness-of-balls measure estimate transported through Direction 2, presented in
closed form via `stereoBoundS2_eq_closed`.

The key insight is that `stereoBoundS2_eq_closed` isolates the only analytic content (the
`π` cancellation), so the remaining work is a pure measure-of-disjoint-balls estimate that
Mathlib's `MeasureTheory` volume-of-ball API supports directly.

Why now? `stereoBoundS2_eq_closed`, `sphericalCapArea_le_sphereArea`, and the new
asymptotic are all proved, so the target inequality is the natural next milestone and the
first non-degenerate quantitative packing bound in the geometry tree.

## Direction 4: Dimension-uniform caps and the simplex bound `n + 2`

`sphericalCapArea` is `S²`-specific, but `sphericalPackingBound_*` already range over all
`Sⁿ`. Define an `Sⁿ` cap measure, prove the analogues of `sphericalCapArea_le_sphereArea`
and `sphericalCapArea_monotone`, and then derive the classical *simplex bound*: for
`2r ≥ π/2` (caps subtending a right angle) at most `n + 2` points fit on `Sⁿ`, attained by
the regular simplex.

The key insight is that mutually `90°`-or-more separated unit vectors are pairwise
non-acute, and a set of pairwise non-acute unit vectors in `ℝⁿ⁺¹` has size at most `n + 2`
— a Gram-matrix/rank fact that sidesteps measure theory and connects this module to the
catalog's inner-product machinery.

Why now? Our packing predicate is already dimension-uniform and
`sphericalPackingBound_fails_small_radius` already constructs explicit unit-vector
witnesses via `EuclideanSpace.single`, so the linear-algebra simplex bound reuses exactly
that construction at scale.

## Direction 5: Decidable finite witnesses and a computational packing oracle

The packing predicate `SphericalPackingBound` quantifies over arbitrary finite
configurations. For *rational* unit-vector configurations the separation condition
`2r ≤ dist x y` becomes a polynomial inequality, so membership and violation are
*decidable*. We should build a `Decidable`-backed checker that, given an explicit finite
list of rational sphere points, certifies whether it is `2r`-separated, and use it to
produce machine-checked lower-bound witnesses (e.g. the icosahedral 12-point `S²`
configuration).

The key insight is that `sphericalPackingBound_fails_small_radius` is really a *witness*
theorem — it refutes a bound by exhibiting a configuration — so the same pattern, made
computational over `ℚ`, turns every concrete packing into a `decide`-checkable lower bound
that complements the analytic upper bounds.

Why now? The antipodal-witness proof already demonstrates the witness-refutation pattern
on `EuclideanSpace`, and porting it to a `decide`-friendly rational model is the cheapest
way to give the framework constructive, `#eval`-able content alongside its analytic core.
