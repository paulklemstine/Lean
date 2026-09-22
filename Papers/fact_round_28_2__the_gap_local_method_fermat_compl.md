# Computational evidence — Fermat's method and the locality taxonomy

All numbers below were produced by a direct simulation of Fermat's method
(`a := ⌊√N⌋ + 1`; while `a² − N` is not a perfect square, `a := a + 1`), run
before the Lean formalisation in order to fix the statements. The Lean files
then *prove* the corresponding identities; the table rows for `p = 101` are
additionally re-derived inside Lean in `FermatGapLocality.grid_row_p101`, so
for that row the numbers are machine-checked, not merely observed.

## 1. The gap-local identity, per draw

Predicted count: `(p+q)/2 − ⌊√(pq)⌋ − 1`. Measured = simulated iteration count.

| p | q | measured | predicted | match | measured / p |
|---|---|---|---|---|---|
| 101 | 211 | 10 | 10 | ✓ | 0.099 |
| 101 | 409 | 51 | 51 | ✓ | 0.505 |
| 101 | 809 | 169 | 169 | ✓ | 1.673 |
| 101 | 1619 | 455 | 455 | ✓ | 4.505 |
| 101 | 3251 | 1102 | 1102 | ✓ | 10.911 |
| 101 | 6469 | 2476 | 2476 | ✓ | 24.515 |
| 1009 | 2027 | 87 | 87 | ✓ | 0.086 |
| 1009 | 4049 | 507 | 507 | ✓ | 0.502 |
| 1009 | 8081 | 1689 | 1689 | ✓ | 1.674 |
| 1009 | 16183 | 4555 | 4555 | ✓ | 4.514 |
| 1009 | 32297 | 10944 | 10944 | ✓ | 10.846 |
| 1009 | 64577 | 24720 | 24720 | ✓ | 24.500 |
| 10007 | 20021 | 859 | 859 | ✓ | 0.086 |
| 10007 | 40031 | 5004 | 5004 | ✓ | 0.500 |
| 10007 | 80071 | 16732 | 16732 | ✓ | 1.672 |
| 10007 | 160117 | 45033 | 45033 | ✓ | 4.500 |
| 10007 | 320237 | 108512 | 108512 | ✓ | 10.844 |
| 10007 | 640457 | 245175 | 245175 | ✓ | 24.500 |
| 100003 | 200009 | 8579 | 8579 | ✓ | 0.086 |
| 100003 | 400031 | 50006 | 50006 | ✓ | 0.500 |
| 100003 | 800029 | 167163 | 167163 | ✓ | 1.672 |
| 100003 | 1600051 | 450014 | 450014 | ✓ | 4.500 |
| 100003 | 3200111 | 1084353 | 1084353 | ✓ | 10.843 |
| 100003 | 6400193 | 2450073 | 2450073 | ✓ | 24.500 |

24 / 24 exact matches. The identity is proved as
`FermatGapLocality.fermatSteps_eq`.

## 2. The `p`-unit column is a function of the balance ratio only

The last column depends on `r = q/p` and not on `p`: the four blocks agree to
three digits. The closed form is `(√r − 1)²/2`:

| r | `(√r − 1)²/2` | measured `p`-units (p = 100003) |
|---|---|---|
| 2 | 0.0858 | 0.086 |
| 4 | 0.5000 | 0.500 |
| 8 | 1.6716 | 1.672 |
| 16 | 4.5000 | 4.500 |
| 32 | 10.8431 | 10.843 |
| 64 | 24.5000 | 24.500 |

As a fraction of the cofactor-linear limit `p(r−1)/2` this is
`(√r − 1)/(√r + 1)`, which at `r = 64` equals `7/9 = 0.7778` — the observed
`0.78`. Both laws are proved: `fermat_cost_p_units`, `fermat_cost_ratio_law`.

## 3. Counterexample hunt: small gaps

Claim tested: `(q − p − 2)² ≤ 8p` implies zero iterations. No counterexample
was found in the sample; the implication is proved as
`fermatSteps_eq_zero_of_small_gap`.

| p | q | gap | measured steps | `(g−2)² ≤ 8p` |
|---|---|---|---|---|
| 3 | 5 | 2 | 0 | true |
| 11 | 13 | 2 | 0 | true |
| 101 | 103 | 2 | 0 | true |
| 10007 | 10009 | 2 | 0 | true |
| 1000003 | 1000033 | 30 | 0 | true |

Note the contrast with trial division, whose cost is exactly `p` on each of
these inputs (`minFac_semiprime`).

## 4. The degenerate square case

On `N = p²` the difference-of-squares target `a = p` lies *below* the start
`⌊√N⌋ + 1 = p + 1`, so the scan overshoots to the unrelated factorisation
`1 · p²`, i.e. to `a = (p² + 1)/2`:

| p | measured steps | `(p²+1)/2 − (p+1)` | exit value `a` |
|---|---|---|---|
| 3 | 1 | 1 | 5 |
| 5 | 7 | 7 | 13 |
| 7 | 17 | 17 | 25 |
| 11 | 49 | 49 | 61 |
| 13 | 71 | 71 | 85 |
| 101 | 4999 | 4999 | 5101 |
| 1009 | 508031 | 508031 | 509041 |

Quadratic, exactly as `fermatSteps_prime_sq` and `fermatSteps_prime_sq_lower`
assert. Starting the scan at `⌊√N⌋` instead removes the defect
(`fermatSteps'_sq`) at the price of one extra iteration elsewhere
(`fermatSteps'_eq_succ`).

## 5. Multiplier steering

`N = 303 = 3 · 101` costs 34 iterations. `33 · N = 9999 = 99 · 101` costs 0,
and `gcd(99, 303) = 3` recovers the factor. Proved as `multiplier_303_9999`.

## 6. OEIS

No new integer sequence is introduced: the cost sequence is a closed-form
expression in `p`, `q` and `⌊√(pq)⌋`, so an OEIS lookup is not informative here.
