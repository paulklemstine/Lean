# Computational evidence — sign-blind dial reporting

All numbers below were produced by exact rational (`ℚ`) evaluation in Lean before the formal
development was written; every claim they suggested is now a machine-checked theorem in
`Catalog/Algebra/SignBlindDial/`.  The rational evaluations themselves are exploratory and
are *not* the verification: the verification is the sorry-free Lean proofs.

## 1. Set-up

Four keys, uniform draw regime `pU = (1/4,1/4,1/4,1/4)`, footprint `foot = (1,2,3,4)`,
prime-power feature `pp = (1,1,0,0)`.  Moments: `σ_xx = 5/4`, `σ_zz = 1/4`, `σ_xz = −1/2`,
and the partialled feature is `ztA = (−1/10, 3/10, −3/10, 1/10)` with `‖z̃‖² = 1/20`.

The residual plane (centred and orthogonal to `foot`) is two-dimensional, spanned by `ztA`
and `eVec = (1,−1,−1,1)` (with `⟨eVec, eVec⟩ = 1`, `⟨eVec, ztA⟩ = 0`).  Writing a residual as
`α·eVec + β·ztA`:

| quantity | value |
|---|---|
| increment `ΔR²·σ_yy` | `β²/20` |
| `σ_zy` | `−b/2 + β/20` |
| `σ_yy` | `5b²/4 + α² + β²/20` |

Solving "same `σ_yy`, opposite `σ_zy`" gives `β' = 20b` and `α² − α'² = 20b²`, which is
rationally parametrised by `α = u + 5b²/u`, `α' = u − 5b²/u`.  This is the family
`rateFamB`, `rateFamC`.

## 2. The catalog pair is the base point

```
#eval (rateB (1/10) (1/2), rateC (1/10) (1/2))
-- ([7/10, -2/5, -3/10, 1], [3/10, 2/5, -7/10, 1])
```
which are exactly `rateSB` and `rateSC` of
`Combinatorics.ExtendedDialMomentGeometry`.  Formalised as `rateFamB_at_base`,
`rateFamC_at_base`.

## 3. Counterexample hunt on a grid of parameters

For each `(b,u)` the table gives
`R²(foot,·)` difference, `R²(pp,·)` difference (both between the two members of the pair),
and the two increments `ΔR²`:

| `(b,u)` | ΔR²-reading difference `foot` | difference `pp` | `ΔR²(B)` | `ΔR²(C)` |
|---|---|---|---|---|
| `(1/10, 1/2)`    | 0 | 0 | 0 | `80/149 ≈ 0.5369` |
| `(9/100, 1/2)`   | 0 | 0 | 0 | `81000/173843 ≈ 0.4660` |
| `(11/100, 51/100)` | 0 | 0 | 0 | `25177680/42687349 ≈ 0.5898` |
| `(1/10, 49/100)` | 0 | 0 | 0 | `2401000/4357963 ≈ 0.5510` |
| `(3/20, 3/5)`    | 0 | 0 | 0 | `320/461 ≈ 0.6941` |
| `(1/5, 1)`       | 0 | 0 | 0 | `80/149 ≈ 0.5369` |

The dial readings agree **exactly** (difference `0` as rationals) at every sampled parameter,
while the increments differ by more than `0.46` throughout; no counterexample to the
conjectured robustness was found.  Signed covariances at the same points:

| `(b,u)` | `σ_zy(B)` | `σ_zy(C)` | `σ_yy(B)` | `σ_yy(C)` |
|---|---|---|---|---|
| `(1/10,1/2)` | `−1/20` | `1/20` | `149/400` | `149/400` |
| `(9/100,1/2)` | `−9/200` | `9/200` | `173843/500000` | `173843/500000` |
| `(11/100,51/100)` | `−11/200` | `11/200` | `42687349/104040000` | `42687349/104040000` |
| `(1/10,49/100)` | `−1/20` | `1/20` | `4357963/12005000` | `4357963/12005000` |

Formalised as `wcov_pp_fam_sign_flip`, `wvar_rateFamB_eq_wvar_rateFamC`, `R2_foot_fam_agree`,
`R2_pp_fam_agree`, `increment_famB`, `increment_famC`.

## 4. Where is the masking largest?

With `λ = b²/u²` the increment of the active member is
`80λ / (100λ² + 45λ + 4)`, whose derivative vanishes at `λ = 1/5`, giving `16/17 ≈ 0.9412`.
The value `16/17` is reached at `b = 1`, `u = √5` (an irrational parameter — the family is a
family of *real* populations, not only rational ones).  The exploratory optimisation is
superseded by the theorems `masking_amplitude_le` (bound, from `(u² − 5b²)² ≥ 0`),
`masking_amplitude_attained` and `masking_amplitude_isGreatest`.

## 5. OEIS

No integer sequence arises: the objects here are continuous families of second moments, so an
OEIS search is not applicable.

## 6. Non-constancy of the readings on the neighbourhood

`R²(foot, rateFamB b u) = 5b²u² / (5b²u² + 4(u² + 5b²)²)` takes the value `5/149 ≈ 0.03356`
at `(1/10, 1/2)` and `≈ 0.03136` at `(19/200, 1/2)`, two points of the same ball.  So the
witness set really does sweep out an open region of dial readings; formalised as
`R2_foot_famB_formula` and `dial_readings_nonconstant_on_ball`.
