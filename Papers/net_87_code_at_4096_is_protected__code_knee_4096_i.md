# Computational Evidence — NET-87 (CODE-AT-4096-IS-PROTECTED)

All numbers below were computed in Lean (`#eval` over `ℚ`, exact rational
arithmetic) before the theorems were stated, and every qualitative claim they
suggest is now a `sorry`-free theorem in
`Catalog/Novelty/KneeDomainNarrowing.lean` or
`Catalog/Novelty/KneePhaseCoordinate.lean`.

Definitions used in the evaluation:

```lean
def K (a b T : ℚ) : ℚ := a + b * T          -- kneeLaw
def r (T : ℚ) : ℚ := K 12 20 T / K 16 24 T  -- protected fit  (code/prose)
def rpar (T : ℚ) : ℚ := K 12 4 T / K 16 4 T -- parity fit     (code/prose)
```

## 1. The measured cell and the protected fit

The reported data: code knees `{12 @512, 16 @1024, 32 @4096}`, prose knee
`40 @4096`, code/prose factor `≈0.75` short, `≈0.80` at 4096.

`#eval` of `(T, r T, gap T)` for the protected fit `12 + 20T` vs `16 + 24T`:

| T | r(T) | r(T) ≈ | gap = K_prose − K_code |
|---|------|--------|------------------------|
| 0        | 3/4       | 0.7500 | 4    |
| 1/5      | 10/13     | 0.7692 | 24/5 |
| 1/2      | 11/14     | 0.7857 | 6    |
| 1        | 4/5       | 0.8000 | 8    |
| 2        | 13/16     | 0.8125 | 12   |
| 5        | 14/17     | 0.8235 | 24   |
| 20       | 103/124   | 0.8306 | 84   |
| 100      | 503/604   | 0.8328 | 404  |
| 1000     | 5003/6004 | 0.8333 | 4004 |

The fit reproduces the two measured factors exactly (`3/4` and `4/5`), the two
measured knee pairs (`12 vs 16`, `32 vs 40`), and the measured gap growth
(`4 → 8`).  The factor is monotone increasing but bounded by `20/24 = 5/6`:
this is `net87_measured_fit`, `net87_fit_narrows`, `ratio_lt_limit`.

## 2. Counterexample hunt: does narrowing imply eventual parity?

No.  A second fit reproduces both measured factors with limit `1`:

| T | rpar(T) | gap |
|---|---------|-----|
| 0   | 3/4     | 4 |
| 1/5 | 16/21   | 4 |
| 1   | 4/5     | 4 |
| 5   | 8/9     | 4 |
| 100 | 103/104 | 4 |

Two laws, identical factors at the two measured contexts, limits `5/6` and `1`.
The discriminating observable is the **gap**: constant `4` in the parity law,
`4 → 8` in the protected law — and the measurement reports `4 → 8`.
Formalised as `two_ratios_underdetermine_limit`, `two_limits_distinct`,
`protection_permanent`.

## 3. The acceleration (P2)

Concave extrapolation of the code chain from `K(512) = 12`, `K(1024) = 16`
(one doubling per index step, `j = 0,1,2,3` for `512,1024,2048,4096`):

`#eval` of `(j, 12 + 4j)` → `[(0,12), (1,16), (2,20), (3,24)]`.

Measured `K(4096) = 32 > 24`.  Any law with nonincreasing increments is capped
at `24`, so the measured chain refutes every concave law by a margin of `8`
keys: `concave_chain_bound`, `code_chain_refutes_concavity`,
`code_chain_extrapolation_gap`.

## 4. The forecast rule

The code chain forces `T₃ − T₁ = 5 (T₂ − T₁)`, hence
`K(4096) = K(512) + 5 (K(1024) − K(512))` for every domain on the same
transition.  `#eval` of that rule:

| K(512) | K(1024) | forecast K(4096) |
|--------|---------|------------------|
| 12 | 16    | 32 (matches the measured code cell) |
| 16 | 104/5 | 40 (matches the measured prose cell) |
| 10 | 14    | 30 |
| 14 | 20    | 44 |
| 16 | 24    | 56 |

The second row is the forced prose knee at ctx 1024, `104/5 = 20.8`
(`prose_knee_at_1024_forced`); the last three are the next-cycle targets for
math/German/French (`domain_jump_forecast_examples`).

## 5. How far is 0.80 from saturation?

Threshold from `ratio_within_eps`: the factor is within `ε` of `5/6` once the
prose knee exceeds `|a_c b_p − a_p b_c| / (b_p ε) = 32 / (24 ε)`.

| ε | required prose knee |
|---|---------------------|
| 1/10   | 40/3 ≈ 13.3 |
| 1/50   | 200/3 ≈ 66.7 |
| 1/100  | 400/3 ≈ 133.3 |
| 1/1000 | 4000/3 ≈ 1333 |

At the measured prose knee of `40` the factor is `4/5`, i.e. `≈0.033` below the
limit — early in the approach, not near saturation.

## 6. Rates behind the chain

Since `K = log(1/delta) / lambda`, the code chain `12, 16, 32` fixes the rate
ratios exactly: `lambda_1 / lambda_0 = 12/16 = 3/4` and
`lambda_3 / lambda_0 = 12/32 = 3/8`.  The affine (harmonic) prediction
`K(4096) = 24` would give `lambda_3 / lambda_0 = 1/2`, so the measured
degradation is strictly faster: `3/8 < 1/2`.  Formalised as
`rates_from_code_chain`, `acceleration_superharmonic`, and — for the whole
harmonic class `lambda_j = C/(j+c)` — `no_generalized_harmonic_rate`.
On the domain side, `K_code / K_prose = lambda_prose / lambda_code`, so the
measured factors `3/4` and `4/5` say code attention is `4/3` then only `5/4`
times as peaked as prose, with a permanent floor of `6/5`
(`net87_peakedness_ratios`, `peakedness_advantage_permanent`).

## 7. OEIS

No integer sequence beyond the finite measured chains `12, 16, 32` and
`16, 20.8, 40` arises here; no OEIS entry is relevant (the chains are three
terms of a two-parameter affine family, not a combinatorial sequence).

## 8. Sanity check of the profile layer

`net87_configuration_realisable` exhibits explicit nonnegative antitone
profiles with knees `12, 16, 32, 40` (uniform profiles on `n` keys, whose knee
at bar `n` is exactly `n`), so the whole measured configuration — narrowing
factor, growing gap, protection at both contexts — is realisable by honest
attention profiles and contains no hidden inconsistency.
