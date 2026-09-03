# Computational evidence — T-DIAL-UNIF-48 vs. the quadratic-residue baseline

All tables below were produced with exact rational arithmetic (`fractions.Fraction`) on the
*tie-attenuation ceiling*

```
rho^2(profile) = 1 - sum_j (m_j^3 - m_j) / (n^3 - n),    n = sum_j m_j,
```

the exact Spearman ceiling of a tied statistic against any tie-refining response
(`Catalog/Novelty/ZeroFitDialU64.lean`, `spearmanSq_eq`).  Every entry that is asserted as a
*theorem* in `Catalog/Cryptography/ZeroFitDialQRUnif48.lean` is proved there; the tables are
exploration, and are labelled as such.

## 1. The Legendre (QR-indicator) profile mod p, by brute-force enumeration

For each odd prime `p` we enumerated the squares of `ZMod p` directly and formed the tie
profile `[#non-residues, #squares]`.

| p | profile | rho^2 |
|---|---------|-------|
| 3 | [1, 2] | 3/4 |
| 5 | [2, 3] | 3/4 |
| 7 | [3, 4] | 3/4 |
| 11 | [5, 6] | 3/4 |
| 13 | [6, 7] | 3/4 |
| 17 | [8, 9] | 3/4 |
| 19 | [9, 10] | 3/4 |
| 23 | [11, 12] | 3/4 |
| 29 | [14, 15] | 3/4 |
| 31 | [15, 16] | 3/4 |
| 37 | [18, 19] | 3/4 |
| 41 | [20, 21] | 3/4 |
| 43 | [21, 22] | 3/4 |
| 47 | [23, 24] | 3/4 |
| 53 | [26, 27] | 3/4 |
| 59 | [29, 30] | 3/4 |

The value is **exactly** `3/4` at every prime — no drift, no dependence on `p mod 4`.  This is
the `qr_ceiling_exact` theorem (prime-independence law), and the profile itself is the
`legendre_profile` theorem.  Counterexample hunt: none exists among the primes below 1000
(checked; the identity `(m+1)^3 + m^3 - (2m+1) = m(m+1)(2m+1)` makes the cancellation exact).

## 2. QR-count vs. QR-vector over the first `r` odd primes

`count` = number of primes at which the draw is a QR (the "bare QR-count" baseline, extended
to `r` symbols); `vector` = the full Legendre vector.  Profiles by CRT/convolution.

| r | primes | count profile | rho^2 count | rho^2 vector |
|---|--------|---------------|-------------|--------------|
| 1 | 3 | [2, 1] | 0.750000 | 0.750000 |
| 2 | 3,5 | [6, 7, 2] | 0.835714 | 0.910714 |
| 3 | 3,5,7 | [24, 46, 29, 6] | 0.882801 | 0.975327 |
| 4 | 3,5,7,11 | [144, 396, 404, 181, 30] | 0.911098 | 0.993657 |
| 5 | +13 | [1008, 3636, 5204, 3691, 1296, 180] | 0.928365 | 0.998386 |
| 6 | +17 | … | 0.940037 | 0.999592 |
| 8 | +19,23 | … | 0.954780 | 0.999974 |
| 11 | +29,31,37 | … | 0.966970 | 0.999999 |

Reference line: the dyadic (trailing-zero) ceiling is `6/7 = 0.857143` to 12 decimals at every
bitlen in 44–64.

*Crossover:* the QR **count** passes the dyadic ceiling between `r = 2` (0.8357, below) and
`r = 3` (0.8828, above); the QR **vector** passes it already at `r = 2` (0.9107).  Both facts
are theorems (`qr_symbol_crossover`).  The systematic gap `count < vector` at every `r` is the
counting-collapse theorem (`qrCount_ceiling_le_qrVec`), proved for arbitrary prime lists.

## 3. The dyadic ceiling across the recorded envelope

| bitlen | rho^2 | rho |
|--------|-------|-----|
| 44 | 0.857142857143 | 0.9258201 |
| 48 | 0.857142857143 | 0.9258201 |
| 52 | 0.857142857143 | 0.9258201 |
| 64 | 0.857142857143 | 0.9258201 |

The ceiling is flat to `4^{-b}` across the whole envelope (`envelope_ceiling_flat`): the
recorded bitlen dependence of the dial cannot be tie geometry.

## 4. The recorded round-52 numbers against the two ceilings

* Recorded `T`: 0.777 / 0.755 / 0.801, pooled 0.7777; all inside `[0.55, 0.85]` and all below
  `rho(dyadic 48) = 0.92582`.
* Implied QR-count readings (subtracting the recorded `+0.09 … +0.13`): 0.625 – 0.711; all
  below `rho(QR) = sqrt(3/4) = 0.8660254`.
* Tie-geometry headroom: `0.9258201 - 0.8660254 = 0.0597947 < 0.09`.

So the *entire* tie-resolution advantage available to `T` over a bare QR symbol is `0.0598`,
strictly less than the smallest recorded advantage `0.09`.  Formalised as
`qr_headroom_lt_six_hundredths` and `recorded_gap_forces_slack`.

## 5. Replicated-symbol tower (prime 3, vector of `r` symbols)

| r | rho^2 exact | lower bound `1 - 2·3^{-r}` |
|---|-------------|-----------------------------|
| 1 | 3/4 = 0.750000 | 0.333333 |
| 2 | 9/10 = 0.900000 | 0.777778 |
| 3 | 0.964286 | 0.925926 |
| 4 | 0.987805 | 0.975309 |
| 5 | 0.995902 | 0.991770 |
| 6 | 0.998630 | 0.997257 |

Closed form `1 - (9^r - 3^r)/(27^r - 3^r)`, matching `qrVec_replicate_ceiling`, with the
bound of `qrVec_replicate_ge`.

## 6. OEIS

The `r`-symbol QR-count profiles are the coefficient lists of
`prod_i ((p_i+1)/2 + (p_i-1)/2 z)`; for the degenerate all-`3` case they are `2^{r-k} C(r,k)`,
i.e. rows of the (1,2)-Pascal triangle **A013609**.  The Franel-type sums `sum_j m_j^3` used by
the ceiling are not, for the mixed-prime case, an OEIS sequence we could identify; no claim is
made.
