# Future Directions — Stereographic Proof Compression

## Synthesis

This cycle turns the slogan *"a proof is a path; the best proof is the geodesic"*
into verified Lean 4 mathematics. We model proof steps as points on the unit
sphere of a real inner-product space and define the **spherical proof distance**
`sdist` as `InnerProductGeometry.angle`. Three threads were woven together:

1. **A pseudo-metric of proofs.** `sdist_comm`, `sdist_nonneg`, `sdist_le_pi`,
   `sdist_self` and the triangle inequality `sdist_triangle` establish that the
   angular proof distance behaves like a bounded metric (diameter `π`).
2. **The compression inequality.** `compression` shows by a telescoping
   induction that the total spherical length of any step-by-step proof path is at
   least the spherical distance between its endpoints — the geodesic (maximally
   compressed) proof is never longer than an explicit decomposition.
   `compression_le_pi` sharpens this with the global diameter bound.
3. **A Geometry × Logic bridge.** `stereoParam` realises proof coordinates on the
   circle `S¹ ⊂ EuclideanSpace ℝ (Fin 2)` via inverse stereographic projection,
   proven to land on the sphere (`stereo_norm`, `stereo_on_circle`), be nowhere
   degenerate (`stereo_ne_zero`), and be inverted classically (`stereo_inv`).
   `stereo_compression` then transports the abstract compression inequality onto
   concrete stereographic proof paths.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `sdist_triangle` | spherical triangle inequality | ✅ proved |
| `compression` | `sdist (p 0) (p n) ≤ pathLength p n` | ✅ proved |
| `compression_le_pi` | `sdist (p 0) (p n) ≤ min π (pathLength p n)` | ✅ proved |
| `stereo_norm` / `stereo_on_circle` / `stereo_inv` | stereographic projection is a circle bijection | ✅ proved |
| `stereo_compression` | stereographic realisation of compression | ✅ proved |

Zero `sorry`; all results depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. A genuine `MetricSpace`/`PseudoMetricSpace` instance for the sphere via `sdist`
We proved the metric *laws* pointwise but did not package them as a Mathlib
`PseudoMetricSpace` (or `MetricSpace` on the unit sphere `Metric.sphere 0 1`).
**The key insight is** that `sdist_self`, `sdist_comm`, `sdist_triangle` and
`sdist_le_pi` are exactly the field obligations of a bounded pseudo-metric, so the
instance should follow mechanically once restricted to unit vectors where
`sdist x x = 0` holds unconditionally. **Why now?** With the triangle inequality
already in Mathlib (`angle_le_angle_add_angle`, added in 2025) the last missing
ingredient is in place; bundling it would let downstream proofs use `dist`,
`Metric.ball`, and completeness machinery for free. *Falsifiable*: the claim
fails if `sdist x y = 0 → x = y` is false on the sphere (it is not — equal angles
of `0` force equal unit vectors), which can be tested directly.

### 2. Quantitative compression ratios and a "proof curvature" gap
Define the compression ratio `pathLength p n / sdist (p 0) (p n)` and ask for
lower bounds in terms of the angular "turning" at each interior step.
**The key insight is** that the slack in the telescoped triangle inequality at
step `k` equals `sdist (p 0)(p k) + sdist (p k)(p (k+1)) - sdist (p 0)(p(k+1))`,
a nonnegative *defect* that accumulates exactly the redundancy of the proof.
**Why now?** `compression` already exposes the per-step inequality; summing the
defects gives an exact identity `pathLength - sdist_endpoints = Σ defects`, which
is provable today and quantifies "how far a proof is from optimal".
*Falsifiable*: predicts the total defect is `0` iff every consecutive triple is
geodesically aligned (lies on a common great-circle arc in order) — checkable on
explicit `stereoParam` examples.

### 3. Stereographic projection as a conformal `PartialHomeomorph` to `ℝ`
We proved `stereoParam` is a bijection circle⁻north-pole ↔ ℝ with explicit
inverse but not its continuity/conformality. **The key insight is** that our
algebraic inverse `x/(1-y)` matches Mathlib's manifold `stereographic'`
construction, so the two can be identified and our elementary formulas can feed
the smooth-manifold API. **Why now?** Mathlib already carries the smooth sphere
chart `stereographic`; bridging the elementary `Fin 2` formula to it would let
"proof distance" inherit a *differentiable* structure, enabling gradient-style
proof optimisation. *Falsifiable*: fails if `stereoParam` disagrees with
`stereographic'.symm` up to the standard identification — a direct coordinate
computation settles it.

### 4. Higher-dimensional proofs: `S^n` and the curse/blessing of dimension
Generalise `stereoParam` from `S¹` to `S^n ⊂ EuclideanSpace ℝ (Fin (n+1))` and
study how endpoint proof distance scales with the number of free coordinates.
**The key insight is** that the compression theorem is already dimension-free
(it lives in an abstract inner-product space), so only the *projection* needs
generalising; the inverse stereographic formula `t ↦ (2t, |t|²-1)/(|t|²+1)`
extends verbatim. **Why now?** The abstract `compression` proof requires no
change, so the marginal cost is purely the `S^n` norm computation, which
`EuclideanSpace.norm_eq` + `field_simp` should discharge uniformly in `n`.
*Falsifiable*: predicts `‖stereoParam_n t‖ = 1` for all `n`; a single failing `n`
refutes the uniform formula.

### 5. Equality case: when is a proof already optimally compressed?
Characterise the proof paths for which `compression` is an *equality*.
**The key insight is** that Mathlib's `angle_eq_angle_add_angle_iff` (the equality
case of the angle triangle inequality, in terms of membership in the nonnegative
span) gives a local criterion that should lift, by induction, to a global
"monotone great-circle" condition on the whole path. **Why now?** The equality
lemma was proved alongside the triangle inequality and is sitting unused; pairing
it with our telescoping argument yields a clean structural theorem with no new
geometric input. *Falsifiable*: predicts equality holds iff each interior point
lies in the nonnegative span of its neighbours — testable on stereographic paths
where the spans are explicit rational vectors.
