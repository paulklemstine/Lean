# Computational evidence — inverse stereographic neural field theory

All numbers below were produced with Lean 4 `#eval` on `Float` models of the same objects
that are treated symbolically in `Catalog/Physics/StereoNeuralField*.lean`.  They are
*evidence*, not proof: every claim they support is separately proved in Lean without any
numerical evaluation (no `native_decide`, no floating point in the theorems).

## 1. Laplace–Beltrami eigenvalues of pulled-back harmonics

Central second differences (step `1e-4`) of the pulled-back harmonics in the plane,
divided by `4W²·u` with `W = 1/(1+x²+y²)`.  The conjectured value is `-l(l+1)`.

| pattern | degree `l` | test point | measured `Δu / (4W²u)` | `-l(l+1)` |
|---|---|---|---|---|
| `σ₁` (dipole) | 1 | `(0.3, 0.7)` | `-2.000000` | `-2` |
| `σ₁σ₂` (quadrupole) | 2 | `(0.3, 0.7)` | `-6.000000` | `-6` |
| `σ₁³-3σ₁σ₂²` (sectoral octupole) | 3 | `(0.3, 0.7)` | `-12.000000` | `-12` |
| `5σ₃³-3σ₃` (zonal octupole) | 3 | `(0.4, -0.2)` | `-11.999999` | `-12` |
| `σ₁`, `σ₁σ₂`, `σ₁³-3σ₁σ₂²` | 1,2,3 | `(1.3, -2.1)` | `-1.999999, -5.999999, -11.999998` | `-2, -6, -12` |

Proved symbolically: `chartX_deg1`, `H2xy_deg2`, `H3a_deg3`, `H3g_deg3`, … (15 patterns in
`StereoNeuralFieldHarmonics.lean`).

## 2. Mexican-hat spectral multiplier `λ_l(r) = (lr)² e^{1-(lr)²}`

Values for `l = 0, …, 7`:

| `r` | `l=0` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | argmax |
|---|---|---|---|---|---|---|---|---|---|
| `1` | 0 | **1.000000** | 0.199148 | 0.003019 | 0.000005 | 0 | 0 | 0 | `l=1` |
| `1/2` | 0 | 0.529250 | **1.000000** | 0.644636 | 0.199148 | 0.032797 | 0.003019 | 0.000159 | `l=2` |
| `1/3` | 0 | 0.270269 | 0.774626 | **1.000000** | 0.816757 | 0.469481 | 0.199148 | 0.063938 | `l=3` |
| `0.4` | 0 | 0.370619 | 0.917331 | **0.927412** | 0.537948 | 0.199148 | 0.049338 | 0.008390 | `l=3` |

Two observations, both of which became theorems:

* at the resonant radii `r = 1/k` the maximiser is exactly `k` with peak value `1`
  (`mexicanHat_selects`, `mexicanHatMultiplier_reciprocal_self`);
* at `r = 0.4` the maximiser is `3 = ⌈1/r⌉`, **not** `⌊1/r⌋ = 2`.  The conjecture's formula
  `N = ⌊1/r⌋` is therefore false for general `r`; the correct general statement is the
  bracketing result `mexicanHatMultiplier_argmax`, and `⌊1/r⌋` is right exactly on the
  resonant radii the conjecture asks about.

## 3. Symmetry checks

* three-fold symmetry: `h₃(0.3, 0.7) = -0.839690` and `h₃(R_{2π/3}(0.3,0.7)) = -0.839690`
  (proved: `H3a_threefold`);
* Kelvin duality: `σ₃(0.3,0.7) = -0.265823` and `σ₃((0.3,0.7)/|(0.3,0.7)|²) = +0.265823`
  (proved: `kelvin_chartZ`).

## 4. The pattern-count sequence

The multiplicities `2l+1` for `l = 0,1,2,…` are `1, 3, 5, 7, 9, …`, the odd numbers
(OEIS A005408).  The combinatorial identity `C(l+2,2) − C(l,2) = 2l+1` behind them is proved
in `spherical_harmonic_dimension`.

## 5. Counterexample hunt

* Decay at infinity: sampling the zonal modes along rays shows convergence to the
  north-pole value rather than to `0` (`σ₃ → 1`).  This refutes the "all `2N+1` patterns
  decay" clause; the exact boundary is proved in `degree_one_decay_iff` and the sectoral
  modes are proved to decay at rates `O(R⁻²)`, `O(R⁻³)` (`H2x2y2_ray_decay`,
  `H3a_ray_decay`).
* Selection at non-resonant radii: see the `r = 0.4` row above.
* No counterexample was found to the eigenvalue relation, the `2N+1` count at resonant
  radii, the symmetry statements, or the Kelvin duality; all of these are now theorems.
