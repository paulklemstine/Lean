# Computational evidence — paper 142 / exp 472 (per-N predictor at the ceiling)

Exploratory computations were done with a short Python script (exact `Fraction` arithmetic where
noted). They are **not** Lean-verified on their own; the Lean results in
`Catalog/Computation/PerNPredictorCeiling.lean` and `Catalog/Computation/PerNPredictorQRFeature.lean`
prove the general identities that these numbers are instances of.

## 1. Small cases of the Euler-test feature (proved in general: `sum_qrInd`, `factor_blind_balance`)

| p | #{a mod p : a^((p-1)/2) ≡ 1} | (p−1)/2 | factorisations x·y = n with x square / x non-square |
|---|---|---|---|
| 3 | 1 | 1 | 1 / 1 |
| 5 | 2 | 2 | 2 / 2 |
| 7 | 3 | 3 | 3 / 3 |
| 11 | 5 | 5 | 5 / 5 |
| 13 | 6 | 6 | 6 / 6 |
| 17 | 8 | 8 | 8 / 8 |

No counterexample. Residue `0` always fails the test, so per-prime mean is `(p−1)/(2p) < 1/2`.

## 2. CRT orthogonality (proved in general: `qrCount_mean`, `qrCount_variance`)

Brute force over `Z/105` (primes 3, 5, 7), exact fractions:
mean QR-count = 122/105 = ∑ (q−1)/(2q); variance = 7796/11025 = ∑ (q²−1)/(4q²). Exact match.

For the exp 472 feature set (the **24** odd primes ≤ 100; Lean: `card_oddPrimesTo100`):
mean = 11.3486, variance = 5.9499 (sd 2.439) over a full CRT period. (Script only.)

## 3. Binomial floor at n = 60 (proved in general: `binom_bias_variance`)

| θ | E[(k/60 − θ)²] (direct sum) | θ(1−θ)/60 |
|---|---|---|
| 0.1 | 0.0015000 | 0.0015000 |
| 0.2 | 0.0026667 | 0.0026667 |
| 0.3 | 0.0035000 | 0.0035000 |

## 4. Consistency of the reported exp 472 numbers (Lean: `exp472_u25_fraction`, `exp472_u35_fraction`, `exp472_u25_tension`, `exp472_u35_ratio`)

| u | R² | ceiling | R²/ceiling | implied κ = (1−R²)/(1−ceiling) | reported κ band |
|---|---|---|---|---|---|
| 2.5 | 0.2998 | 0.45 | 0.666 | **1.273** | 1.12–1.24 |
| 3.5 | 0.2246 | 0.31 | 0.725 | 1.124 | 1.12–1.24 |

At u = 3.5 the triple fits together. At u = 2.5 it does not quite fit the in-sample identity
`1 − R² = κ(1 − ceiling)`: either the ceiling is ≈ 0.435 (not 0.45), or κ ≈ 1.27, or the held-out R²
and the in-sample ceiling use different sums of squares. Lean records this as `exp472_u25_tension`.

## OEIS
The per-prime counts `(p−1)/2` are the sequence (odd prime − 1)/2 (believed to be OEIS A005097; not re-checked online in this run).
