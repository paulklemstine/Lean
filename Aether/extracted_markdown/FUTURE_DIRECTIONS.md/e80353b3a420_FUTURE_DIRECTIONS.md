# Future Directions: Stereographic Capacity Theory — the Chordal Metric Cycle

## Synthesis

This cycle added the **metric backbone** of stereographic capacity theory in
`Catalog/Geometry/StereographicCapacity/Chordal.lean`, the companion to the
*algebraic* backbone (`stereo_addition_law`, `stereoRot_mul`, `stereoAdd_assoc`)
in `Catalog/Geometry/StereographicCapacity/Theorems.lean`. The unifying object is
the inverse stereographic chart `invStereo t = (2t/(1+t²), (1-t²)/(1+t²))` already
defined in the catalog, now studied through the chordal (straight-line) distance
between its images.

The keystone is the **exact chordal-distance formula**

  ‖invStereo s − invStereo t‖² = 4 (s − t)² / ((1 + s²)(1 + t²)),

a purely algebraic identity (one `field_simp; ring` after clearing denominators).
Every other result is a corollary of this single rational identity: a global
2-Lipschitz upper bound, a windowed bi-Lipschitz lower bound, two-way packing
transfer theorems converting plane separations into spherical ones and back, and a
sharpness theorem certifying that the lower-bound constant `(1+A²)⁻²` genuinely
degenerates at infinity. This realizes the *duality* theme of the engine: chordal
separation on the sphere and Euclidean separation on the plane are dual
descriptions of the same packing, intertwined by the conformal weight `(1+‖x‖²)⁻¹`
— the exact Jacobian density of the chart.

## Results Summary

All theorems are complete with no `sorry` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

- `chordSq_invStereo` — the exact chordal formula
  `chordSq s t = 4(s−t)²/((1+s²)(1+t²))`.
- `chordSq_invStereo_le` — global 2-Lipschitz upper bound `chordSq ≤ 4(s−t)²`.
- `chordSq_invStereo_ge` — windowed bi-Lipschitz lower bound
  `4(s−t)²/(1+A²)² ≤ chordSq` for `|s|,|t| ≤ A`.
- `stereo_packing_pullback` — `ρ²≤chordSq ⟹ ρ/2 ≤ |s−t|` (sphere → plane code).
- `stereo_packing_pushforward` — windowed `δ ≤ |s−t| ⟹ (2δ/(1+A²))² ≤ chordSq`
  (plane → sphere code).
- `chordSq_tendsto_zero_atTop` — along `(x+1, x)` (unit-separated), `chordSq → 0`,
  proving no window-free lower bound exists.

These extend the catalog's `invStereo`/`invStereo_on_circle` from pointwise facts
to a full quantitative metric theory, and connect to `radialDistortion` in the
hyperbolic catalog through the shared conformal-weight viewpoint.

## Falsifiable Research Directions

### 1. The dimension-free chordal formula on `EuclideanSpace ℝ (Fin n)`

Define `σ : EuclideanSpace ℝ (Fin n) → EuclideanSpace ℝ (Fin (n+1))` explicitly and
prove `dist (σ x) (σ y)² = 4·dist x y² / ((1+‖x‖²)(1+‖y‖²))`. The one-dimensional
proof in `chordSq_invStereo` is a literal template.

**The key insight is** that the chordal formula never uses the dimension beyond
expanding `‖·‖²` as a finite `Finset.sum` of squares, so the `field_simp; ring`
proof lifts coordinatewise. **Why now?** The scalar case is fully proved here and
Mathlib's `EuclideanSpace`/`PiLp` norm-squared lemmas make the sum manipulation
routine — only the bookkeeping remains, not new mathematics.

### 2. A quantitative spherical-cap packing (Hamming-type) bound

Combine `stereo_packing_pullback` with a grid/volume count: a chordal `ρ`-code
pulls back to a `ρ/2`-separated plane code, whose cardinality inside `[−A,A]ⁿ` is
bounded by `(4A/ρ + 1)ⁿ`. Formalize `code.card ≤ (4A/ρ + 1)^n`.

**The key insight is** that a separation *lower* bound turns packing into a
pigeonhole over a grid: disjoint balls of radius `ρ/4` inside a box of side
`2A + ρ/2` are counted by volume, with no curvature integral. **Why now?**
`stereo_packing_pullback` already produces the clean Euclidean separation, and
Mathlib has the `Finset.card`/box-counting lemmas needed for the volume step.

### 3. Hyperbolic ↔ spherical capacity duality via a curvature parameter `κ`

The conformal factor `(1+‖x‖²)⁻¹` here is the formal mirror of the Poincaré factor
`(1−‖x‖²)⁻¹` in the hyperbolic catalog. Introduce `weight κ x = 1/(1 − κ‖x‖²)` and
prove a single parametrized distortion inequality specializing to spherical
(`κ=+1`, this file), Euclidean (`κ=0`), and hyperbolic (`κ=−1`, `radialDistortion`).

**The key insight is** that all three constant-curvature packing distortions are
the *same rational function* `1/(1 − κ‖x‖²)` evaluated at `κ ∈ {−1,0,+1}`, so one
lemma subsumes both endpoint frameworks. **Why now?** Both endpoints now exist in
the catalog (spherical here, hyperbolic in `HyperbolicDisk`/`radialDistortion`), so
the unifying `κ`-family is a synthesis target rather than foundational work.

### 4. Optimal degeneration exponent of the windowed lower bound

`chordSq_tendsto_zero_atTop` shows the lower bound must degenerate; sharpen it to a
*rate*: prove `chordSq (x+1) x` is `Θ(x⁻⁴)` and that no constant `c(A)` better than
`Θ(A⁻⁴)` can appear in `chordSq_invStereo_ge`. Concretely, exhibit matching upper
and lower bounds `c₁/A⁴ ≤ inf_{|s|,|t|≤A, |s−t|=1} chordSq ≤ c₂/A⁴`.

**The key insight is** that the point at infinity is a genuine metric singularity:
two unit-separated plane points become chordally indistinguishable at rate exactly
`x⁻⁴`, so `(1+A²)⁻²` is the true exponent, not a proof artifact. **Why now?** The
exact formula `chordSq_invStereo` turns the rate claim into a direct
`Filter.IsBigO`/`Tendsto` computation building on the limit already proved.

### 5. Möbius-invariance of the stereographic capacity functional

Define the capacity of a finite plane configuration `S` as
`minPairChord S = min_{s≠t∈S} chordSq s t` and prove it is invariant under the
subgroup of Möbius maps coming from sphere rotations (`stereoAdd`-translations),
while plane similarities only rescale it by a controlled factor.

**The key insight is** that the conformal weight `(1+‖x‖²)⁻¹` is exactly the
Jacobian making chordal — not Euclidean — distance the rotation-invariant metric,
so capacity must be phrased chordally to be a genuine sphere invariant. **Why now?**
The algebraic backbone `stereoAdd`/`stereoRot_mul` already formalizes the rotation
side, so this direction is a bridge linking the algebraic and metric backbones of
the same module through `chordSq_invStereo`.
