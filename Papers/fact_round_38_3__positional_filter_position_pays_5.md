# Computational Evidence — Paper 137 (positional filter)

**Status:** ad-hoc exploration in Python. These numbers are *not* Lean-verified. The
statements they motivated are proved in Lean in `Catalog/Cryptography/PositionalFilter/`.

## 1. Small-case check of the exact cost formulas

Brute-force trial division on every semiprime `N = p q` with primes `p ≤ q < 400`
(3081 pairs). Ascending scan over `2, 3, …, ⌊√N⌋` and descending scan over `⌊√N⌋, …, 2`,
counting divisibility tests up to and including the first hit:

| check | result |
|---|---|
| ascending cost `= p - 1` | 0 mismatches / 3081 |
| descending cost `= ⌊√N⌋ + 1 - p` | 0 mismatches / 3081 |
| `asc + desc = ⌊√N⌋` | 0 mismatches / 3081 |

Proved for all primes in Lean as `ascCost_semiprime`, `descCost_semiprime`, `asc_add_desc`.

Example: `N = 101·103 = 10403`, `⌊√N⌋ = 101`: ascending pays 100 tests, descending pays 1
(`example_twin`, proved).

## 2. Stratum ratios of expected costs (independent sample, not a replication)

Seed 20260821, 200000 random pairs of distinct primes in `[2^15, 2^17)`, ratio
`E[asc]/E[desc]` per balance stratum:

| stratum `q/p` | n | `E[asc]/E[desc]` | Lean band (`stratum_*`) | exp 467 (a) |
|---|---|---|---|---|
| `[1, 1.25)` | 64381 | 18.668 | `≥ 4 + 2√5 ≈ 8.472` | 20.67 |
| `[1.25, 2)` | 90255 | 4.245 | `[1 + √2, 4 + 2√5] ≈ [2.414, 8.472]` | 4.74 |
| `[2, 4)` | 45364 | 1.736 | `[1, 1 + √2] ≈ [1, 2.414]` | 1.97 |

All three ratios from this sample, and all three exp-467 mechanism-(a) values, fall inside
the bands proved in `stratum_ratio_band` (mediant principle). The proved check that the
exp-467 values lie in the bands is `exp467_mechanism_a_consistent`. The exact values differ
from exp 467 because the sampling distribution is different (this sample does not use the
experiment's pool or its truncation rule).

## 3. Counterexample hunt

* An early version of `pool_dvd_iff` dropped the hypothesis `p ≤ q`. Lean rejected it, and
  it is false: for `p > q` the pool hit is `q`, not `p`. The hypothesis is now in the
  statement.
* An early bound "`4p · desc ≤ (q-p)² + 4p`" was refuted on paper before formalising:
  with `q = p x²` it needs `(x-1)(x+1)² ≥ 4`, which fails for `x` close to `1`. It was
  replaced by the correct gap bound `2(desc - 1) ≤ q - p` (`two_mul_desc_le_gap`).
* No mismatches turned up in the formula checks of section 1.

## 4. Wall location

`posSpeedup(49/16) = 1/(7/4 - 1) = 4/3`, the residue cap. Proved:
`residue_cap_reached_at_wall`, `position_beats_every_residue_dial`.

OEIS: there is no integer sequence of interest here, so no lookup was done.
