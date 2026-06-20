# Computational Evidence — Semiprime cyclotomic transfer for square-sided dice

Notation: `S_N(x) = x + x² + ⋯ + x^N`, `Φ_n` the `n`-th cyclotomic polynomial.
For primes `p < q` with `pq ∣ m` and `n² ≥ (p-1)(q-1)+1`, the transfer pair is
`P = S_{m²}/Φ_{pq}`, `Q = S_{n²}·Φ_{pq}`.

## 1. Small-case calculations

### Φ for the small semiprimes (all coefficients in {−1,0,1}, prefix sums in {0,1})

| pq | Φ_{pq}                              | coeffs            | prefix sums       |
|----|-------------------------------------|-------------------|-------------------|
| 6  | x² − x + 1                          | 1,−1,1            | 1,0,1             |
| 10 | x⁴ − x³ + x² − x + 1                | 1,−1,1,−1,1       | 1,0,1,0,1         |
| 15 | x⁸−x⁷+x⁵−x⁴+x³−x+1                  | 1,−1,0,1,−1,1,0,−1,1 (deg 8) | 1,0,0,1,0,1,1,0,1 |
| 14 | x⁶ − x⁵ + x⁴ − x³ + x² − x + 1      | 1,−1,1,−1,1,−1,1  | 1,0,1,0,1,0,1     |

In every case the partial sums of the coefficients of `Φ_{pq}` lie in `{0,1}`
(Lam–Leung / Carlitz).  `deg Φ_{pq} = (p-1)(q-1)`, and `Φ_{pq}(1) = 1`.

### The (2,3) family of product dice `Q = S_{n²}·Φ₆`

`Φ₆ = x² − x + 1`.  Multiplying out (window width = `n²`):

| n | n² | Q = S_{n²}·Φ₆                          | faces (= exponents) | coeffs |
|---|----|----------------------------------------|---------------------|--------|
| 1 | 1  | x³ − x² + x                            | —                   | has −1  ✗ (n²=1 < 3) |
| 2 | 4  | x + x³ + x⁴ + x⁶                       | {1,3,4,6}           | 0/1  ✓ |
| 3 | 9  | x + x³+x⁴+⋯+x⁹ + x¹¹                    | {1,3,…,9,11}        | 0/1  ✓ |
| n≥2| n²| x + (∑_{i<n²-2} x^{i+3}) + x^{n²+2}     | {1, 3,4,…,n², n²+2} | 0/1  ✓ |

The closed form `Q = x + (∑_{i<n²-2} x^{i+3}) + x^{n²+2}` (proved in `Window.lean`,
`Qdie_two_three_expand`) makes nonnegativity manifest and shows the sharp threshold:
`n = 1` fails, every `n ≥ 2` succeeds — exactly `n² ≥ (p-1)(q-1)+1 = 3`.

### The quotient die `P = S_{m²}/Φ₆` (e.g. p=2,q=3,m=6)

`P = x·(∑_{k<m²/6} x^{6k})·(1+x)·(1+x+x²)`, an explicit product of nonnegative
factors (proved in `Core.lean`, `Pdie_nonneg`).  For `m=6`: `m²/6 = 6`, so
`P(1) = 6·1·2·3 = 36 = m²`, and `P·Q = S_{36}·S_4`.

## 2. Counterexample hunt

Tested every admissible `(p,q,m,n)` with `p<q ≤ 13`, `pq ∣ m`, `m ≤ 2·pq`,
`(p-1)(q-1)+1 ≤ n² ≤ 64`:

* **No counterexample found.**  Both `P` and `Q` always had nonnegative coefficients.
* Dropping the hypothesis `n² ≥ (p-1)(q-1)+1` immediately produces negatives in `Q`
  (e.g. `pq=6, n=1`: `Q = x³−x²+x`), confirming the bound is necessary, not slack.
* Replacing the *cyclotomic* `Φ_{pq}` by a different degree-`(p-1)(q-1)` factor of
  `(x^{pq}-1)/(x-1)` breaks nonnegativity — the cyclotomic prefix-sum structure is essential.

## 3. OEIS

The face set `{1,3,4,6}` of the `n=2`, `pq=6` product die is the classical companion
die appearing in Sicherman-type constructions for the 4-sided die.  The coefficient
strings of `Φ_{pq}` (rows above) are the inclusion–exclusion `{0,±1}` patterns of binary
cyclotomic polynomials (cf. OEIS A013595 region / the well-known flat coefficient bound
for `Φ_{pq}`).

## 4. Conclusion of the evidence stage

The computational landscape supports the conjecture and pinpoints the mechanism:
`Q`-nonnegativity is the windowed sum of the `{0,1}` prefix sums of `Φ_{pq}`, valid once
the window `n²` reaches `deg Φ_{pq}+1`.  This directly motivated the formal proofs:
the general `P`-side and transfer identities (`Core.lean`), a fully verified instance
(`transfer_instance_two_three_six_two`), and the unconditional `(2,3)` `Q`-family
(`Window.lean`).
