# Computational Evidence — per-N sieve-yield dial (exp 476 follow-up)

All scripts were ad-hoc Python (seed 20260827). **Only the items marked [Lean] are machine-checked**; the rest is exploratory evidence.

## 1. Small cases: root count = 1 + (N/p)

For the odd primes p ≤ 100 (24 of them, [Lean] `oddPrimesLe100_card`), the number of r in [0, p) with p | r² − N was compared with 2·[Euler pass] + [p | N] for 2000 random N < 10^12:
**0 violations**. This is proved in general as [Lean] `qsRoots_split` / `total_roots_affine`.

## 2. Population distribution of QR(≤100)

20 000 uniform N in [10^17, 10^18):

| QR | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
|----|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|----|
| count | 1 | 1 | 24 | 91 | 321 | 637 | 1237 | 2015 | 2864 | 3166 | 3205 | 2675 | 1768 | 1090 | 536 | 251 | 91 | 20 | 7 |

Empirical mean 11.389; the exact mean on a complete period is Σ_p ((p−1)/2)/p = 11.3486 ([Lean] `population_feature_mean`, bounds [8, 12) in `population_dial_mean_bounds`). Implied mean dial value: 0.1282 (the exact level on a complete period lies in [0.08898, 0.13522), [Lean]).

## 3. Counterexample hunt: where the adopted dial goes negative

The adopted dial −0.0035 + 0.01156·q is negative exactly at q = 0 ([Lean] `dial_pos_iff`).
Searching N in increasing order (scanning N mod 3·5·7·11·13·17·19 over admissible classes) for N that is a non-residue modulo all 24 odd primes ≤ 100:

| N | factorisation | QR(≤100) |
|---|---|---|
| **163 520 117** | 2027 · 80671 (semiprime) | 0 |
| 231 912 722 | 2 · 3581 · 32381 | 0 |
| 261 153 653 | 8191 · 31883 (semiprime) | 0 |

The fact that 163 520 117 is the *smallest* such N comes only from this Python scan (not verified in Lean). That QR = 0 holds, that the root mass is 0, that both factors are prime, and that the dial value is negative are all [Lean] `dial_negative_witness` (via `decide`/`norm_num`).

## 4. Consistency check on the reported statistics

Reported: transfer R² = 0.2719 and target corr² = 0.2717. [Lean] `affineR2_le_corrSq` shows that on one sample, no affine predictor has R² above corr². [Lean] `reported_pair_impossible` then shows that the two four-decimal values cannot both be in-sample statistics of the same target sample. So the 0.2719 must have been computed on a different sample or split, or with a different R² convention, from the 0.2717.

## OEIS

The sequence "least N > 0 that is a non-residue modulo every odd prime ≤ p_k" was not looked up (no network access). We make no claim about whether 163520117 appears in OEIS.
