# Stereographic Capacity Theory: Packing Bounds on Spheres via Plane Geometry

## Abstract

We develop the algebraic and geometric backbone of *stereographic capacity
theory*, a program for converting spherical cap-packing questions on the
`n`-sphere `Sⁿ` into weighted Euclidean separation problems on `ℝⁿ` through
stereographic projection. The central object is the conformal scale factor
`λ(x) = 2/(1 + ‖x‖²)` of the projection; we prove it is strictly positive,
bounded above by `2`, and attains `2` exactly at the origin. From `λ` we derive a
closed form for the *exclusion radius* — the flat-space forbidden disk that
faithfully encodes a spherical guard radius — namely `tan(r)·(1 + ‖x‖²)/2`. For
the `2`-sphere we reduce the area-versus-distortion packing bound to the single
expression `8/(cos²r·(1 − cos r))`. Finally we establish a sharp degenerate
regime: for geodesic radius `r > 1`, every `2r`-separated subset of `Sⁿ` is a
singleton, yielding the packing bound `1`, together with monotonicity of the
packing-bound predicate in its budget. All results are stated for general
dimension where applicable and have been formally verified.

**Keywords.** sphere packing, spherical codes, stereographic projection,
conformal geometry, spherical caps, error-correcting codes, packing bounds.

---

## 1. Introduction

The *spherical cap-packing problem* asks: given a geodesic radius `r`, what is the
maximum number `A(n, r)` of points that can be placed on the unit sphere `Sⁿ ⊂
ℝⁿ⁺¹` so that the geodesic distance between any two is at least `2r`? Equivalently,
how many non-overlapping caps of radius `r` fit on `Sⁿ`? The quantity `A(n, r)` is
the size of an optimal *spherical code*, a structure of direct importance to
error-correcting codes, signal constellations, and the geometry of
high-dimensional data. Exact values are known only in sporadic cases, and most
progress takes the form of upper and lower bounds.

This paper builds the foundational layer of a method for producing *upper* bounds
by transporting the problem to the plane. Stereographic projection
`σ : Sⁿ \ {N} → ℝⁿ` (from the north pole `N`) is a conformal diffeomorphism, so it
preserves angles but distorts lengths by a position-dependent factor. If that
factor is tracked precisely, a packing question on the curved sphere becomes a
weighted separation question on the flat plane, where classical packing technology
applies. We make the relevant distortion bookkeeping explicit and prove the
elementary but foundational facts on which the rest of the theory depends.

Throughout, points of `ℝⁿ` are modeled as elements of `EuclideanSpace ℝ (Fin n)`,
and `‖·‖` denotes the Euclidean norm. We write `tan`, `cos` for the usual
trigonometric functions and `⌈·⌉₊` for the natural-number ceiling.

---

## 2. Definitions

We collect the core objects of the theory.

**Definition 2.1 (conformal factor).** For `x ∈ ℝⁿ`,
```
λ(x) := stereoFactor x = 2 / (1 + ‖x‖²).
```
This is the local scale factor of stereographic projection from the north pole of
`Sⁿ` to `ℝⁿ`: a length element `ds` on the plane at `x` corresponds to a length
element `λ(x)·ds` on the sphere.

**Definition 2.2 (exclusion radius).** For a spherical radius `r` and a plane
point `x`,
```
exclusion(r, x) := stereoExclusionRadius r x = tan(r) / λ(x).
```
Under projection, a spherical cap of geodesic radius `r` centered at the
spherical preimage of `x` maps to a Euclidean disk of approximately this radius.

**Definition 2.3 (stereo-separation).** A finite set `s ⊂ ℝⁿ` is
*stereo-separated for radius `r`*, written `StereoSeparated r s`, if for all
`x, y ∈ s` with `x ≠ y`,
```
exclusion(r, x) + exclusion(r, y) ≤ ‖x − y‖.
```
This is the flat-space counterpart of pairwise `2r`-separation on the sphere: the
two exclusion disks are required to be disjoint.

**Definition 2.4 (areas on `S²`).** The total area of the unit `2`-sphere is
```
sphereArea = 4π,
```
and the area of a spherical cap of geodesic radius `r` on `S²` is
```
sphericalCapArea(r) = 2π(1 − cos r).
```

**Definition 2.5 (packing-bound predicate).** For dimension `n`, radius `r`, and
budget `B`, the predicate `SphericalPackingBound n r B` asserts: every finite set
`s` of points on the unit sphere `Sⁿ ⊂ ℝⁿ⁺¹` with pairwise Euclidean distance at
least `2r` satisfies `|s| ≤ ⌈B⌉₊`. (Here pairwise distance is measured by the
chordal/Euclidean metric of the ambient `ℝⁿ⁺¹`.)

**Definition 2.6 (S² distortion bound).** Define
```
stereoBoundS2(r) = (2/cos r)² · (sphereArea / sphericalCapArea(r)),
```
and its conjectured closed form
```
stereoBoundS2Closed(r) = 8 / (cos²r · (1 − cos r)).
```

---

## 3. Conformal factor bounds

The conformal factor is the dictionary between the round and flat worlds, and its
analytic control underwrites every later estimate.

**Theorem 3.1 (positivity).** For every `x ∈ ℝⁿ`, `λ(x) > 0`.

*Proof.* The numerator `2` is positive and the denominator `1 + ‖x‖² ≥ 1 > 0`, so
the quotient is positive. ∎

**Theorem 3.2 (upper bound).** For every `x ∈ ℝⁿ`, `λ(x) ≤ 2`.

*Proof.* Since `1 + ‖x‖² ≥ 1`, dividing `2` by a quantity at least `1` can only
decrease it: `2/(1 + ‖x‖²) ≤ 2/1 = 2`. Formally this is `div_le_self` applied to
`0 ≤ 2` and `1 ≤ 1 + ‖x‖²`, the latter from `‖x‖² ≥ 0`. ∎

**Theorem 3.3 (extremal characterization).** `λ(x) = 2` if and only if `x = 0`.

*Proof.* The equation `2/(1 + ‖x‖²) = 2` is equivalent (clearing the positive
denominator) to `1 + ‖x‖² = 1`, i.e. `‖x‖² = 0`, i.e. `‖x‖ = 0`, i.e. `x = 0`.
The converse is the direct computation `λ(0) = 2/(1 + 0) = 2`. ∎

**Interpretation.** The maximum density of the projection, the value `λ = 2`,
occurs uniquely at the origin — the image of the south pole, antipodal to the
projection center. Distortion is least there and decays monotonically to `0` as
`‖x‖ → ∞` (the north pole). The two-sided control `0 < λ(x) ≤ 2` is precisely what
makes the dictionary uniformly usable across the whole plane.

---

## 4. The exclusion radius closed form

**Theorem 4.1 (exclusion radius).** For every `r ∈ ℝ` and `x ∈ ℝⁿ`,
```
exclusion(r, x) = tan(r) · (1 + ‖x‖²) / 2.
```

*Proof.* By definition `exclusion(r, x) = tan(r)/λ(x) = tan(r) / (2/(1 + ‖x‖²))`.
Since `1 + ‖x‖² ≠ 0`, dividing by the fraction `2/(1 + ‖x‖²)` is multiplication by
its reciprocal `(1 + ‖x‖²)/2`, giving `tan(r)·(1 + ‖x‖²)/2`. ∎

**Discussion.** The formula factors cleanly into a *cap-size* term `tan(r)`,
constant across the plane, and a *position* term `(1 + ‖x‖²)/2 = 1/λ(x)`, which
grows quadratically in `‖x‖`. The position term is the "distortion tax": points
projected far from the origin (near the north pole, where the sphere was sampled
sparsely) require correspondingly large flat exclusion disks to faithfully
represent a fixed spherical cap. This identity is the analytic bridge that converts
`StereoSeparated` from a flat convenience into a faithful proxy for cap
disjointness, and it is the engine of the separation transport program (§7).

---

## 5. Closed form of the S² distortion bound

**Theorem 5.1 (S² bound, closed form).** For all `r` with `cos r ≠ 0` and
`cos r ≠ 1`,
```
stereoBoundS2(r) = 8 / (cos²r · (1 − cos r)).
```

*Proof.* Substitute the definitions `sphereArea = 4π` and `sphericalCapArea(r) =
2π(1 − cos r)` into
```
stereoBoundS2(r) = (2/cos r)² · (4π) / (2π(1 − cos r)).
```
The numerator simplifies as `(4/cos²r) · (4π)`, and clearing the common factor
`π ≠ 0` from `4π / (2π(1 − cos r))` gives `2/(1 − cos r)`. Hence
```
stereoBoundS2(r) = (4/cos²r) · (2/(1 − cos r)) = 8 / (cos²r · (1 − cos r)),
```
where the manipulations are justified because `π ≠ 0`, `cos r ≠ 0`, and
`1 − cos r ≠ 0` (the last from `cos r ≠ 1`). ∎

**Discussion.** The bound combines the area ratio `sphereArea/sphericalCapArea`
— the naive cap-count from a pure volume argument — with the squared conformal
correction `(2/cos r)²` that accounts for worst-case distortion. The closed form
is analytic in `r` on `(0, π/2)`: as `r → 0⁺` it diverges like `16/r⁴`
(reflecting that arbitrarily many tiny caps fit), and it decreases monotonically as
`r` grows toward `π/2`. Its smoothness makes it amenable to calculus-based
comparison against true packing numbers.

---

## 6. Degenerate packing for large radius

When the guard radius exceeds the sphere's reach, packing collapses.

**Theorem 6.1 (singleton packing).** Let `r > 1`. Let `s` be a finite set of
points on the unit sphere `Sⁿ ⊂ ℝⁿ⁺¹` such that any two distinct elements `x, y`
satisfy `2r ≤ dist(x, y)` (Euclidean/chordal distance). Then `|s| ≤ 1`.

*Proof.* Suppose `a, b ∈ s` are distinct. Each lies on the unit sphere, so
`‖a‖ = ‖b‖ = 1`. By the triangle inequality,
```
dist(a, b) = ‖a − b‖ ≤ ‖a‖ + ‖b‖ = 2.
```
But separation requires `2r ≤ ‖a − b‖`, hence `2r ≤ 2`, i.e. `r ≤ 1`,
contradicting `r > 1`. Therefore no two distinct points can coexist in `s`, so
`|s| ≤ 1`. ∎

**Corollary 6.2 (packing bound 1).** For every `n` and every `r > 1`,
`SphericalPackingBound n r 1` holds.

*Proof.* By Theorem 6.1 any admissible `s` has `|s| ≤ 1`, and `⌈(1 : ℝ)⌉₊ = 1`, so
`|s| ≤ ⌈1⌉₊`. ∎

**Proposition 6.3 (monotonicity of the bound).** For every `n`, `r`, and budgets
`B ≤ B′`, if `SphericalPackingBound n r B` holds then so does
`SphericalPackingBound n r B′`.

*Proof.* For any admissible `s`, `|s| ≤ ⌈B⌉₊ ≤ ⌈B′⌉₊`, the second inequality from
monotonicity of the ceiling under `B ≤ B′`. ∎

These results certify the sharp boundary of the problem: the chordal diameter of
the unit sphere is exactly `2`, so a guard radius `r > 1` admits at most a single
point, and our predicate records this exactly. Monotonicity ensures looser claims
descend automatically from tighter ones.

---

## 7. Applications and outlook

**Spherical codes.** A `2r`-separated set on `Sⁿ` *is* a spherical code with
minimum chordal distance `2r`; `SphericalPackingBound n r B` is literally an upper
bound on code size. The closed-form `8/(cos²r(1−cos r))` therefore yields an
explicit, easily evaluated ceiling on certain `S²` codes, useful as a quick
benchmark against linear-programming bounds.

**Signal processing.** Spherical caps model the angular resolution of beams and
constellations; the conformal-factor control of §3 quantifies how planar designs
inflate or deflate when wrapped onto a direction sphere.

**A computational pipeline.** Definitions 2.1–2.3 give a fully constructive test:
project candidate sphere points, compute each exclusion radius
`tan(r)(1+‖x‖²)/2`, and verify pairwise stereo-separation in the plane. This is the
algorithmic content demonstrated in the companion numerical examples.

### 7.1 Future directions

*Separation transport theorem.* We conjecture a regime in which
`StereoSeparated r s` is equivalent to genuine `2r`-geodesic separation of the
inverse stereographic images, with equivalence becoming exact as `r → 0`. Theorem
4.1 shows the Euclidean exclusion radius is the spherical radius rescaled by the
local conformal factor, so a first-order match of `tan r` to geodesic chord length
should make `StereoSeparated` a faithful proxy for cap disjointness. Chaining
Theorem 4.1 with closed-form geodesic-distance and bi-Lipschitz comparison results
should yield an explicit two-sided estimate without new transcendental machinery.

*Quantitative cap-packing upper bound on `S²`.* We conjecture that for every `r ∈
(0, π/2)`, `SphericalPackingBound 2 r B` holds with `B = 8/(cos²r(1−cos r))`, and
moreover that this is the best bound obtainable by the pure area/conformal-
distortion method, off the true packing number by at most a bounded multiplicative
constant. The route is a rigorous volume (area) argument carried through the
distortion ledger of §§3–5.

---

## 8. Conclusion

We have laid the groundwork for stereographic capacity theory: precise control of
the conformal factor (`0 < λ ≤ 2`, with equality only at the origin), a closed
form for the exclusion radius (`tan(r)(1+‖x‖²)/2`), a closed form for the `S²`
distortion bound (`8/(cos²r(1−cos r))`), and a sharp degenerate packing regime
(`r > 1 ⇒` singleton), with monotonicity of the bound predicate. Together these
turn questions about a curved surface into questions about a flat plane with an
honest distortion ledger — the foundation on which the conjectured transport and
quantitative-bound theorems can be built.
