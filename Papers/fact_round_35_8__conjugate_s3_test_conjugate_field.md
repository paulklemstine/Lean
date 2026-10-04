# Computational evidence — CONJUGATE-S3-TEST (paper 127)

These numbers come from ad-hoc Python exploration, not from Lean. The exact
statements behind them are proved in `Catalog/Novelty/ConjugateS3FieldInvariance.lean`;
the numerical values themselves (entropy estimates) are **not** formally verified.

## 1. Small cases: \(T(n) = \#\{x \bmod n : f(x) \equiv 0\}\)

| p | 2 | 3 | 5 | 7 | 11 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 |
|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|----|----|----|
| `x³-x+1` | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 2 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 3 |
| `x³-x-1` | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 2 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 3 |
| `x³+x²-1` | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 2 | 0 | 0 | 1 | 0 | 1 | 0 | 1 | 3 |
| `x³+x+1` (disc −31) | 1 | 1 | 0 | 0 | 1 | 1 | 1 | 0 | 1 | 1 | 2 | 1 | 0 | 1 | 3 | 1 | 0 |

* p = 23 is the ramified prime: `x³-x-1 ≡ (x-3)(x-10)² (mod 23)` (proved: `ramified_at_23`).
* p = 59 is the first prime that splits completely (type 1+1+1).
* The disc −31 field differs from the disc −23 field already at p = 3 (proved: `field_distinguished_at_3`).

## 2. Counterexample search over all moduli
For every n from 1 to 59 (prime, prime power, semiprime, …) the three generators
`x³-x+1`, `x³-x-1`, `x³+x²-1` have the same root count mod n. **No counterexample.**
This holds for every n: see `typeFn_plus_eq_minus` and `typeFn_recip_eq_minus`.

## 3. Type channel \(I(p \bmod 23; T)\), all 2262 primes below 20000

| generator | I (bits) | type histogram {0 roots, 1 root, 2 (ramified), 3 roots} |
|---|---|---|
| `x³-x+1` | 1.005354 | {762, 1133, 1, 366} |
| `x³-x-1` | 1.005354 | {762, 1133, 1, 366} |
| `x³+x²-1` | 1.005354 | {762, 1133, 1, 366} |

The three values are identical because the three type sequences are identical
(`typeChannel_identical`, `typeChannel_identical_recip`). The asymptotic value 1 bit
is the `S₃` sign-channel law (`S3SignChannelUniversal.S3_sign_channel`) and assumes
Chebotarev equidistribution; the measured excess (≈0.005 here, ≈0.000065 in the
experiment's larger sample) is a finite-sample bias.

## 4. OEIS
The sequence of primes at which `x³-x-1` splits completely (59, 101, 167, 173, 211, …)
is computed above (59, 101, 167, 173, 211, 223, 271, 307, 317, 347 below 400).
The OEIS ID was not checked here,
so none is cited.
