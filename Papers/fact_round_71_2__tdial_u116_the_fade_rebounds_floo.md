# Computational evidence — TDIAL-U116 rebound / floor cycle (exp 553, with exp 554 follow-up)

All numbers below are exact rational arithmetic on the recorded ladder; each one is
re-derived inside Lean (`norm_num` on `ℚ`) in
`Catalog/Probability/TDialU116ReboundFloor.lean` and
`Catalog/Probability/TDialU116FloorIdentifiability.lean`, so nothing here is an unchecked
scratch computation.

## 1. The recorded ladder

```
bitlen rung :  ...    0.5739  0.5436  0.5005  0.4880  0.4621  0.4847 | 0.43636
step        :        -0.0303 -0.0431 -0.0125 -0.0259 +0.0226 | -0.0483
```

The `+0.0226` step at U116 is the first positive step of the thread.  Since every rung is
positive, no multiplicative law `ρₖ₊₁ ≤ q ρₖ` with `q ≤ 1` can produce it — formalised as
`u116_refutes_multiplicative_fade`.

## 2. Three-point Δ² (Aitken) fit on the rungs surrounding the rebound

Using `a = 0.4880`, `b = 0.4621`, `c = 0.4847` (exact rationals `4880/10⁴`, `4621/10⁴`,
`4847/10⁴`):

| quantity | exact value | decimal |
|---|---|---|
| step `b − a` | `−259/10000` | `−0.0259` |
| step `c − b` | `226/10000` | `+0.0226` |
| second difference `c − 2b + a` | `485/10000` | `0.0485` |
| fitted ratio `λ = (c−b)/(b−a)` | `−226/259` | `−0.8725869…` |
| Aitken floor `L = a − (b−a)²/(c−2b+a)` | `2299719/4850000` | `0.4741689…` |
| predicted next rung `L + λ(c−L)` | `1204297/2590000` | `0.4649795…` |
| recorded next rung (exp 554) | `43636/100000` | `0.43636` |
| prediction error | `370623/12950000` | `0.0286195…` |
| trap band `η/(1−|λ|)` at that error | — | `0.22462` |
| floor resolution `2η/|1−λ|` | — | `0.0305628…` |
| three-rung mean `(a+b+c)/3` | `14348/30000` | `0.4782667…` |
| gap between the two estimators | — | `0.0040978…` |

Two independent estimators (nonlinear Δ², linear mean) both land inside the pre-registered
floor window `[0.46, 0.49]`, and agree to `0.0041`.

## 3. Counterexample hunt (what failed)

* **Δ² fit on earlier triples.**  Applying the same extrapolant to `(0.5739, 0.5436, 0.5005)`
  gives `λ = 0.0431/0.0303 = 1.4224 > 1` and `L = 0.6456`; on `(0.5005, 0.4880, 0.4621)` it
  gives `λ = 2.072` and `L = 0.5122`.  Both fits are *divergent* (`|λ| > 1`), i.e. the early
  ladder is not an affine fade at all.  Only the triple containing the rebound rung yields a
  contractive fit.  This is why the rebound rung is informative rather than disposable.
* **Extrapolation.**  The contractive fit's forecast for the next rung, `0.46498`, misses the
  recorded `0.43636`.  The forced noise level `η ≥ 0.02862` makes the model's trap band
  (`0.2246`) wider than the whole recorded fade (`0.5739 − 0.4364 = 0.1375`), so the fitted
  model has no extrapolative content.  Formalised honestly as `u120_outcome_forces_noise`
  and `u120_trap_band_exceeds_total_fade`.
* **Identifiability survives.**  The same noise level still pins the floor to a window of
  width `2η/|1−λ| = 0.0306` (`u116_floor_resolution`), which excludes the zero floor
  (`u116_zero_floor_excluded`).  Predictive power and identifiability come apart.

## 4. Sign-pattern drift (checked by hand on small patterns, then proved)

For `±1` patterns with `c` adjacent sign changes among the first `K + 1` terms, the partial
sum budget `K + 1 − c` is exactly right on every small case tried:

| pattern | `K + 1` | `c` | `|∑|` | budget `K+1−c` |
|---|---|---|---|---|
| `+ + + +` | 4 | 0 | 4 | 4 |
| `+ + + −` | 4 | 1 | 2 | 3 |
| `+ + − +` | 4 | 2 | 2 | 2 |
| `+ − + −` | 4 | 3 | 0 | 1 |
| `+ − + − +` | 5 | 4 | 1 | 1 |

Both extremes are attained (`sign_pattern_drift_sharp_constant`,
`sign_pattern_drift_sharp_alternating`).  The naive extension to residuals that are merely
*bounded* by `η` is **false**: `η, −ε, η, −ε, …` has `K` sign changes but drifts like `ηK/2`,
which is why the theorem is stated for exact amplitude and the bounded case is recorded as an
open direction.

## 5. Sequence lookup

The ladder is a measured statistic, not an integer sequence, so no OEIS entry applies.  The
only integer sequence appearing in the formal development is the alternating sign sequence
`(−1)ᵏ` with partial sums `1, 0, 1, 0, …` (A000035 up to indexing), used in
`alternating_signs_partial_sum_eq`.

## 6. Averaging simulation (checked symbolically in Lean, not numerically)

For a ladder oscillating about a floor with amplitude `η`, every individual rung is off by
exactly `η`, whereas the mean of `K` rungs is off by at most `η/K`
(`alternating_average_recovers_floor`).  For `K = 3` and `η = 0.0286` this predicts a mean
within `0.0095` of the floor; the observed gap between the three-rung mean and the Δ² floor
is `0.0041`, comfortably inside that.

## 7. Bounded-amplitude drift: enumeration behind `TDialBoundedDriftLaw`

The bounded case left open above was resolved by enumerating, for each sign pattern of length
`K+1`, the extremal residual assignment (full amplitude `η` on one sign class, `0` on the
other).  Writing `A` for the number of rungs sharing the last rung's sign and `B` for the rest
(equivalently the two alternating block-length sums), the worst-case drift is `η·max(A, B)`:

| pattern | `K+1` | `c` | `(A, B)` | exact-amplitude bound `η(K+1−c)` | worst bounded drift `η·max(A,B)` |
|---|---|---|---|---|---|
| `+ + + +` | 4 | 0 | (4, 0) | 4η | 4η |
| `+ + + −` | 4 | 1 | (1, 3) | 3η | 3η |
| `+ + − +` | 4 | 2 | (3, 1) | 2η | 3η |
| `+ − + −` | 4 | 3 | (2, 2) | η   | 2η |
| `+ − + − +` | 5 | 4 | (3, 2) | η  | 3η |

Rows 3–5 exhibit the failure of the exact-amplitude law for bounded residuals.  The formal
counterexample uses row 4 with `η = 1` and the assignment `1, −1/4, 1, −1/4`, whose drift is
`3/2 > 1` (`exact_amplitude_law_fails_for_bounded_residuals`, checked by `norm_num` in Lean).
The table also shows why only *half* of each sign change survives in general: the bound
`η((K+1) − c/2)` gives `4η, 3.5η, 3η, 2.5η, 3η` on these rows, dominating column 6 in every
case, and the alternating rows show the constant `1/2` cannot be improved
(`half_is_optimal_constant`).

## 8. Block-balanced reweighting: the table behind `TDialBlockReweighting`

Weighting every rung of a maximal constant-sign block of length `nᵢ` by `1/nᵢ` makes each of the
`m` blocks carry total weight `1`, so the estimator is the mean of the `m` block means.  Each
block mean is bounded by `η` and carries its block's sign, and nothing more is available: an
adversary may saturate the blocks of one parity and zero the others.  Enumerating that extremal
assignment gives the worst-case error `η⌈m/2⌉/m`, computed here against the conjectured `2η/m`:

| `m` blocks | worst case / `η` = `⌈m/2⌉/m` | conjectured `2/m` | verdict |
|---|---|---|---|
| 1 | 1     | 2.000 | conjecture holds |
| 2 | 0.500 | 1.000 | conjecture holds |
| 3 | 0.667 | 0.667 | equality |
| 4 | 0.500 | 0.500 | equality (boundary) |
| 5 | 0.600 | 0.400 | **conjecture false** |
| 6 | 0.500 | 0.333 | **conjecture false** |
| 10 | 0.600 | 0.200 | **conjecture false** |
| 101 | 0.505 | 0.020 | **conjecture false** |

The row `m = 5` is the one formalised in `block_reweighting_rate_conjecture_false`; the column
`⌈m/2⌉/m ≥ 1/2` is `block_reweighting_no_decay`.  Replacing the bounded residuals by residuals
of *exact* amplitude `η` collapses the same column to `1/m` (`0.500, 0.333, 0.250, …`), which is
`exact_amplitude_blockWeightedMean_decays`; the two columns side by side are
`block_reweighting_dichotomy`.

Two further checks were run symbolically in Lean rather than numerically:

* *No weighting escapes.*  For arbitrary nonnegative block weights summing to `1`, the two
  extremal ladders give errors `η·W_even` and `η·W_odd` with `W_even + W_odd = 1`, so the larger
  is at least `η/2` (`no_weighting_beats_half`).  The uniform weights `1/m` are therefore not a
  bad choice — nothing is a good choice.
* *The barrier is information-theoretic.*  The reading sequence `L+η, L, L+η, L, …` is realised
  exactly by the floor `L` (saturating the positive blocks) and by the floor `L + η` (saturating
  the negative ones), so the two floors are indistinguishable and every estimator errs by `η/2`
  on one of them (`minimax_half_amplitude_barrier`); the midrange `(max+min)/2` attains it
  (`midrange_attains_barrier`).  At the recorded `η = 0.0226` this is `± 0.0113`, matching the
  model-based resolution floor of cycle three exactly.
