# Computational Evidence — Divisor Factorization of `T(2,n)` Alexander Polynomials

We test the central claim

  **A_n(X) = ∏_{d ∣ n, d > 1} Φ_{2d}(X)**   (n odd),

where `A_n(X) = 1 − X + X² − ⋯ + X^{n-1}` is the Alexander polynomial of the torus
knot `T(2,n)` and `Φ_m` is the `m`-th cyclotomic polynomial.

## 1. Small-case cyclotomic decompositions

For each odd `n` the nontrivial divisors `d > 1` of `n` predict the exact list of
cyclotomic factors `Φ_{2d}`:

| n  | factorization type | nontrivial divisors d | predicted factors Φ_{2d} | Σ φ(2d) | n − 1 |
|----|--------------------|-----------------------|---------------------------|---------|-------|
| 3  | prime              | 3                     | Φ₆                        | 2       | 2     |
| 5  | prime              | 5                     | Φ₁₀                       | 4       | 4     |
| 9  | 3²                 | 3, 9                  | Φ₆·Φ₁₈                    | 8       | 8     |
| 15 | 3·5                | 3, 5, 15              | Φ₆·Φ₁₀·Φ₃₀                | 14      | 14    |
| 21 | 3·7                | 3, 7, 21              | Φ₆·Φ₁₄·Φ₄₂                | 20      | 20    |
| 27 | 3³                 | 3, 9, 27              | Φ₆·Φ₁₈·Φ₅₄                | 26      | 26    |
| 45 | 3²·5               | 3, 5, 9, 15, 45       | Φ₆·Φ₁₀·Φ₁₈·Φ₃₀·Φ₉₀        | 44      | 44    |

In every case the sum of the factor degrees `Σ_{d∣n, d>1} φ(2d)` equals `n − 1`,
which is exactly `deg A_n`. This is a necessary (degree-matching) check for the
factorization identity and is confirmed for all tested `n`.

## 2. Layer counts vs. primality

The number of primitive-root OAM "layers" equals the number of nontrivial divisors,
`τ(n) − 1`. Scanning `n = 3, 5, 7, …, 21` gives (n, layer count, degree):

```
(3,1,2) (5,1,4) (7,1,6) (9,2,8) (11,1,10) (13,1,12) (15,3,14) (17,1,16) (19,1,18) (21,3,20)
```

The layer count is `1` precisely at the primes `3,5,7,11,13,17,19` and jumps to `2`
at `9 = 3²` and `3` at `15 = 3·5` and `21 = 3·7`. This matches the single-layer
criterion: exactly one layer ⇔ `n` prime.

## 3. Counterexample hunt

No counterexample was found: for every odd `n` tested up to the small-case range,
the predicted factor list has total degree `n − 1` and the layer count equals
`τ(n) − 1`. The polynomial identity itself is established in full generality (all
odd `n`) in the accompanying development, so the search is corroborative rather
than exhaustive.

## 4. Notes

* The two "smallest-knot" cases `n = 3, 5` recover the classical facts that the
  trefoil and cinquefoil Alexander polynomials are `Φ₆` and `Φ₁₀`.
* The prime-power column (`9, 27`) exhibits the nested stratification
  `Φ_{2p}, Φ_{2p²}, …, Φ_{2p^k}`.
* The mixed case `45 = 3²·5` shows the layers need not be nested: they are indexed
  by the full divisor lattice of `n`.
