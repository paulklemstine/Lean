# Computational evidence — metaplectic extension of the Gabor window action

All numbers below were produced with `#eval` inside Lean 4 using `Float` arithmetic on
complex numbers represented as pairs `(re, im)`.  **These evaluations are exploratory only.**
Every statement they support is *separately* proved, without floating point, in the Lean files
`Catalog/Geometry/Metaplectic*.lean`; the theorem names are given after each block.

Notation: `τ = α + iβ` is the complex width of the chirped Gaussian `G_{α,β}(t) = exp(-π τ t²)`
and `z = siegel(α,β) = i/τ` is its Siegel parameter (a point of the upper half plane).

## 1. Chirp ↔ shear matrix `[[1,0],[-2c,1]]`

Claim: `siegel(α, β - 2c) = z / (-2c·z + 1)`.

| α | β | c | `siegel(α, β-2c)` | Möbius image of `siegel(α,β)` |
| --- | --- | --- | --- | --- |
| 1.3 | −0.7 | 0.45 | (−0.376471, 0.305882) | (−0.376471, 0.305882) |

Agreement to all printed digits.  Proved: `siegel_chirp`, `siegelPt_chirp`.

## 2. Fourier transform ↔ rotation by π/2, `[[0,-1],[1,0]]`

Claim: `siegel(α/(α²+β²), −β/(α²+β²)) = −1/z`, i.e. `τ ↦ 1/τ`.

| α | β | LHS | `−1/z` |
| --- | --- | --- | --- |
| 1.3 | −0.7 | (0.700000, 1.300000) | (0.700000, 1.300000) |

Note the answer `(β, α)` up to the factor `α²+β²`, as expected from `z ↦ iτ`.
Proved: `fourier_gaussChirp` (analysis), `siegel_fourier`, `siegelPt_fourier` (geometry).

## 3. Dilation ↔ diagonal subgroup `diag(e^u, e^{-u})`

Claim: `siegel(e^{-2u}α, e^{-2u}β) = e^{2u} z`.

| α | β | u | LHS | `e^{2u} z` |
| --- | --- | --- | --- | --- |
| 1.3 | −0.7 | 0.37 | (−0.673007, 1.249870) | (−0.673007, 1.249870) |

Proved: `siegel_dilate`, `siegelPt_dilate`, `dilOp_gaussChirp`.

## 4. The catalog's Gaussian windows lie on the imaginary geodesic

Claim: `siegel(1/s², 0) = i s²`.

| s | computed | expected |
| --- | --- | --- |
| 1.7 | (0.000000, 2.890000) | (0, 2.89) |

The real part is exactly `0`, so widening the window is translation along the imaginary
geodesic — the diagonal one-parameter subgroup.  Proved: `siegel_gaussC`, `siegel_gaussC_re`,
`siegelPt_width_dilate`, and the monotonicity consequences
`gaussSpectral_dilate_monotone`, `gaussSpectral_dilate_strictMono`.

## 5. Counterexample hunt: does the shear preserve the integer Heisenberg lattice?

For a lattice element `(a,b) = (m,n)` the shear produces `b + 2c·a = n + 2c·m`.

| c | image of `(1,0)` | image of `(3,0)` | integral? |
| --- | --- | --- | --- |
| 0.5 | 1.0 | 3.0 | yes |
| 0.3 | 0.6 | 1.8 | **no** — counterexample already at `(1,0)` |

So the naive expectation "`SL₂(ℝ)` acts on the discrete Gabor lattice" is false; the search
located the exact threshold `2c ∈ ℤ`, which is the statement proved in
`chirpShear_mapsTo_heisLattice_iff`.

## 6. Counterexample hunt: is `𝓕²` the identity?

`S² = −1` acts trivially on every Siegel parameter (item 3 with the Möbius map of `−1` is the
identity map), so a naive lift would predict `𝓕² = id`.  Symbolic evaluation of the Gabor atom
`T_a M_b g_s` after two Fourier transforms gives `T_{−a} M_{−b} g_s`; e.g. at `a = 0.8`, the
moduli at the point `t = a` are `gaussWin s (2a) < 1` for the transformed atom against `1` for
the original — different windows.  This is the anomaly, proved (without floats) in
`fourier_fourier_gaborAtom`, `gaborAtom_ne_neg` and `metaplectic_anomaly`.

## 7. OEIS

No integer sequence arises in this project — the objects are Lie-group orbits on the upper half
plane and continuous window families — so no OEIS lookup applies.  The only discrete invariant
that appears, the index of the lattice-preserving shears, is the set `{c : 2c ∈ ℤ}`, i.e. a
copy of `½ℤ`.
