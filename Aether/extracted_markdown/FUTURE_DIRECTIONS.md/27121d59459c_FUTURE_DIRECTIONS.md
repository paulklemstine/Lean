# Future Directions — Inverse Stereographic Neural Field Theory

## Synthesis

This cycle separated the *geometric* and *counting* content of the inverse
stereographic neural-field program from the (hard, analytic) PDE existence theory,
and proved both pieces constructively in Lean 4.

On the geometric side (`Applications/StereographicNeuralField.lean`) we gave a
closed-form inverse stereographic projection `invStereo : ℝ² → S² ⊂ ℝ³`, proved it
lands on the unit sphere (`invStereo_mem_sphere`), exhibited an explicit left inverse
`stereo` (`stereo_invStereo`) and hence injectivity (`invStereo_injective`), showed it
avoids the north pole (`invStereo_third_lt_one`), and—most importantly for the PDE
transform—identified the conformal weight `λ(x) = 2/(1+|x|²)` with the geometric
"height defect" `1 − z` of the projected point (`conformalFactor_eq`).

On the counting side (`Applications/NeuralPatternCount.lean`) we proved that the
conjectural pattern multiplicity `2N+1` is exactly the dimension of the degree-`N`
harmonic irreducible of `SO(3)`, realized as the difference of triangular numbers
`homogDim l − homogDim (l−2) = 2l+1` (`harmonic_dim_eq_patternCount`), and that
Mexican-hat selection composes with this count to give `2k+1` for *every* radius
`r = 1/k` (`patternCount_selectedDegree`), with `k = 1,2,3 ↦ 3,5,7` as corollaries.
Distinct degrees are separated by the strictly monotone eigenvalue `l(l+1)`
(`lapEigenvalue_strictMono`), so the mode selection is well posed.

## Results Summary

| Theorem | Statement |
|---|---|
| `invStereo_mem_sphere` | `invStereo` maps `ℝ²` into the unit sphere `S²`. |
| `stereo_invStereo` | `stereo ∘ invStereo = id` (constructive chart inverse). |
| `invStereo_injective` | the projection is injective. |
| `conformalFactor_eq` | `λ(x) = 1 − z(invStereo x)`: weight = height defect. |
| `harmonic_dim_eq_patternCount` | `homogDim l − homogDim (l−2) = 2l+1`. |
| `patternCount_selectedDegree` | for `r = 1/k`, predicted count `= 2k+1`. |
| `lapEigenvalue_strictMono` | eigenvalues `l(l+1)` separate degrees. |

## Research Directions

### 1. The conformal Laplacian transformation law
We proved the weight identity `λ = 1 − z`; the natural next step is to prove the full
operator transformation: for `u` on `S²` and `v = u ∘ invStereo` on `ℝ²`,
`(Δ_{S²} u) ∘ invStereo = (λ⁻²) · Δ_{ℝ²} v` in dimension 2 (and the curvature-corrected
version in higher `n`). The key insight is that, in 2D, the Laplace–Beltrami operator is
conformally covariant with weight exactly `λ⁻²`, so the entire PDE transport is encoded
by the single scalar `conformalFactor` we already built. Why now? With `conformalFactor_eq`
and `invStereo_mem_sphere` in hand, the remaining work is a `fderiv`/`Real`-analysis
computation rather than new geometry — it is the smallest extension that turns the chart
into a genuine PDE equivalence.

### 2. Linear independence of the `2l+1` coordinate harmonics
We proved the *count* `2l+1` abstractly; the constructive sharpening is to exhibit, for
small `l`, an explicit basis of `2l+1` real spherical harmonics (e.g. `{x, y, z}` for
`l=1`) and prove linear independence over the sphere. The key insight is that restricting
homogeneous harmonic polynomials to `S²` is injective on each degree, so a degree-`l`
basis of polynomials descends to a basis of pattern variants. Why now? `harmonic_dim_eq_patternCount`
gives the target dimension; pairing it with an explicit independent family upgrades a
dimension equality into a concrete, `#eval`-checkable construction of the patterns.

### 3. Mexican-hat kernel selects a unique degree
We modeled selection as `selectedDegree r = ⌊1/r⌋` and proved its composition law. The
falsifiable refinement is to *derive* this selection from a kernel: define the Mexican-hat
connectivity as a difference of Gaussians (or its Legendre/Funk–Hecke coefficients
`λ_l`) and prove that `argmax_l λ_l = ⌊1/r⌋` for `r = 1/k`. The key insight is that the
Funk–Hecke theorem turns convolution against a radial kernel on `S²` into multiplication
of each harmonic by a scalar `λ_l`, so "pattern selection" becomes "which `λ_l` is
largest" — a decidable comparison of explicit integrals. Why now? Our `lapEigenvalue_strictMono`
already shows the degrees are linearly ordered; supplying the matching ordering of the
kernel eigenvalues closes the loop between geometry and the bifurcation that picks `N`.

### 4. Counts on `Sⁿ` and the general multiplicity polynomial
The triangular-difference identity generalizes: degree-`l` harmonics on `Sⁿ` have
multiplicity `C(n+l, l) − C(n+l−2, l−2)`. The key insight is that this is again a pure
polynomial identity in `l` (for fixed `n`), so it is provable by the same doubling /
`ring` strategy that beat `omega` here — no analysis required. Why now? We isolated the
exact obstruction (nonlinear products vs. `omega`) and the fix (`two_mul_homogDim` style
doubling); replaying it dimension-by-dimension yields a uniform `Sⁿ` pattern-count theorem
that subsumes the `S²` case as `n = 2`.

### 5. Decay-at-infinity of the projected patterns on ℝ²
The conjecture claims the `S²` patterns become `N`-fold symmetric patterns on `ℝ²` that
*decay at infinity*. The key insight is that a spherical harmonic is bounded on `S²`, and
under `stereo` the north-pole neighbourhood maps to `|x| → ∞` while `λ(x) → 0`, so any
field carried by the conformal weight inherits explicit decay `O(|x|⁻²)`. Why now? With
`invStereo_third_lt_one` (north pole avoided) and `conformalFactor_pos` already proved, the
decay estimate is a direct limit computation on the closed-form weight — the last
qualitative claim of the conjecture still unformalized.
