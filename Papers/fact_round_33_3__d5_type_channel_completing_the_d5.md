# Computational evidence — D5-TYPE-CHANNEL at m* = 320 (FACT round-33 #3, paper 118)

**Status: these are exploratory numerical runs (a short Python script, not formally
checked).** The exact statements they motivated are proved in Lean in
`Catalog/Probability/D5TypeChannel*.lean`; the numbers below are *not* claimed as verified.

## 1. Test field

The classical solvable quintic `f(x) = x⁵ − 5x + 12` (Galois group `D₅`, discriminant
`2¹²·5⁶`), ramified only at 2 and 5 — compatible with the conductor `m* = 320 = 2⁶·5`.
For each prime `7 ≤ p ≤ 2·10⁶` the number of roots of `f mod p` (degree of
`gcd(x^p − x, f)` over `F_p`) gives the splitting type:
5 roots → `1⁵`, 0 roots → `5`, 1 root → `1·2²`.

## 2. Small-case / full-range counts (148 930 primes)

| type | count | empirical | Chebotarev |
|---|---|---|---|
| `1·2²` (reflections) | 74 538 | 0.5005 | 0.5 |
| `5` (rotations)      | 59 576 | 0.4000 | 0.4 |
| `1⁵` (identity)      | 14 816 | 0.0995 | 0.1 |

## 3. Which quadratic character?

Agreement of "`p` has type `1·2²`" with "`χ_d(p) = −1`":

| d | 5 | −1 | 2 | −2 | −5 | 10 | **−10** |
|---|---|---|---|---|---|---|---|
| agreement | 0.499 | 0.500 | 0.500 | 0.500 | 0.499 | 0.500 | **1.000** |

So the quadratic subfield is `ℚ(√−10)` (conductor 40, which divides 320). This is the
character `chiM10` used in `d5_dial_prime_320`.

## 4. Plug-in channel estimates versus the exact values (proved in Lean)

| sample (first M primes) | H(T) | H(T \| p mod 320) | I(p mod 320; T) |
|---|---|---|---|
| 20 000  | 1.3583 | 0.3564 | 1.0019 |
| 34 000  | 1.3615 | 0.3605 | 1.0010 |
| 50 000  | 1.3603 | 0.3597 | 1.0005 |
| 100 000 | 1.3594 | 0.3591 | 1.0003 |
| 148 930 | 1.3598 | 0.3595 | 1.0002 |
| **exact (Lean)** | **1/5 + ½·log₂5 ≈ 1.36096** | **½·log₂5 − 4/5 ≈ 0.36096** | **1** |
| FACT record | 1.3517 | 0.3463 | 1.0054 |

The plug-in mutual information approaches the exact 1 bit from above as M grows, with
the excess shrinking roughly like `1/M`, which is what one expects from the upward bias
of plug-in mutual information over 128 residue cells. The recorded excess `0.0054` has
the same sign; its size is larger than the Miller–Madow estimate
`(128−1)(3−1)/(2M ln 2)` at M ≈ 1.5·10⁵ (≈ 0.0012), so the FACT run either used a
smaller sample or a different field — this could not be checked here.

## 5. Counterexample hunt

* The one-bit law needs odd `n`: for `D₂` the order read-out gives
  `3/2 − (3/4)·log₂3 ≈ 0.311 < 1` (proved in Lean: `dihedral_two_dial`).
* No prime in the range contradicted "type `1·2²` ⇔ `χ₋₁₀(p) = −1`".
