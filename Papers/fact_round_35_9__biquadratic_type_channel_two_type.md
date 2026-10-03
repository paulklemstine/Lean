# Computational evidence — biquadratic type channel of `x⁴ - 10x² + 1`

These numbers come from ad-hoc Python scripts. They are **not** formal results. The
formal statements are in `Catalog/Novelty/BiquadraticTypeChannel.lean` and
`Catalog/Novelty/BiquadraticEntropy.lean`.

## 1. Small cases (number of roots mod p)

| p | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 |
|---|---|---|----|----|----|----|----|----|----|----|----|----|----|----|----|
| roots | 0 | 0 | 0 | 0 | 0 | 0 | **4** | 0 | 0 | 0 | 0 | 0 | **4** | 0 | 0 |
| p mod 24 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 5 | 7 | 13 | 17 | 19 | 23 | 5 | 11 |

## 2. Counterexample hunt

A brute-force root count for every prime `5 ≤ p < 3000` gave **0 mismatches**
against "4 roots iff `p ≡ ±1 (mod 24)`, otherwise 0". No prime has 1, 2 or 3 roots.
(The formal theorem `biqType_eq` proves this for all primes `p ≥ 5`.)

## 3. Empirical entropy vs. the exact Chebotarev value

| bound N | #primes 5 ≤ p < N | share split | empirical H(T) |
|---------|------------------|-------------|----------------|
| 10³ | 166 | 0.21687 | 0.75441 |
| 10⁴ | 1227 | 0.24042 | 0.79574 |
| 10⁵ | 9590 | 0.24765 | **0.80754** |
| 10⁶ | 78496 | 0.24940 | 0.81033 |
| exact (class level) | — | 1/4 | 2 − (3/4)·log₂3 = 0.811278… |

The reported value `H(T) = 0.8074` matches the `N = 10⁵` row. The empirical
entropy rises towards the exact value `0.81128` from below. Formally,
`empirical_below_limit` proves `0.8074 < 2 − (3/4)·log₂3`.

Semiprime pair channel: the exact class-level value is
`19/8 − (21/16)·log₂3 = 0.294737…`, compared with the reported finite-sample `0.2909`.
The which-factor channel is exactly `0`, compared with the reported `0.0001`.

## 4. OEIS

The primes that split completely (`p ≡ ±1 mod 24`: 23, 47, 71, 73, 97, …) are the
primes `p` for which both 2 and 3 are quadratic residues. No OEIS lookup was made
in this session, so no sequence ID is given here.
