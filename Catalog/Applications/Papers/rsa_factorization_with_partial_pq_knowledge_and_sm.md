# Computational Evidence — Modified Wiener Attack and Factorization Recovery

This evidence supports `WienerFactorization.lean`, which closes the modified Wiener
pipeline by turning recovered private-exponent data into an explicit factorization of `n`.

## 1. Small-case calculation (the canonical worked instance)

Take `p = 17`, `q = 11`, so `n = p·q = 187`, `φ(n) = (p−1)(q−1) = 160`.
Pick `e = 7`, `d = 23`, `k = 1` (note `e·d = 161 = 1·160 + 1`, the key equation).

- Perfect estimate `s = p+q = 28`, corrected modulus `ñ = n + 1 − s = 160 = φ(n)`.
- Approximation error: `e/ñ − k/d = 7/160 − 1/23 = 1/3680`.
- Legendre threshold: `1/(2·d²) = 1/1058`. Since `1/3680 < 1/1058`, `k/d` is a convergent. ✓
- Factorization step: `S = n − φ(n) + 1 = 187 − 160 + 1 = 28 = p+q`.
  Discriminant `S² − 4n = 784 − 748 = 36 = 6²` (a perfect square = `(p−q)²`).
  Quadratic formula: `p = (28 + 6)/2 = 17`, `q = (28 − 6)/2 = 11`. ✓ recovered.

These match `worked_example_error`, `worked_example_below_threshold`,
`worked_example_separation` (catalog) and `worked_example_factor` (this file).

## 2. Perfect-square discriminant — the structural invariant

For *every* semiprime, `(p+q)² − 4·p·q = (p−q)²`. Spot checks:

| p  | q  | n=pq | p+q | (p+q)²−4n | √ = p−q |
|----|----|------|-----|-----------|---------|
| 17 | 11 | 187  | 28  | 36        | 6       |
| 13 | 7  | 91   | 20  | 36        | 6       |
| 23 | 5  | 115  | 28  | 324       | 18      |
| 31 | 29 | 899  | 60  | 4         | 2       |

The discriminant is always a perfect square, so the real square root is *exact*
(`= p−q`), and no rounding is needed in the final factorization — this is exactly the
content of `discriminant_eq` and `factor_from_sum_prod`.

## 3. Counterexample hunt

- `factor_from_sum_prod` without `q < p`: at `p = q` the formula still holds, but for
  `q > p` the `+` root returns `q`, not `p` — the sign of `√((p−q)²) = |p−q|` flips. The
  hypothesis `q < p` is therefore load-bearing (it selects the larger prime). No
  counterexample to the *stated* theorem was found.
- Smallness condition: dropping `2·d·(k·Δ+1) < ñ` breaks the convergent criterion
  (verified by the catalog file's design); no counterexample to the guarded statement.

## 4. Conclusion

All numeric checks corroborate the formal results. The decisive, machine-verified fact is
the perfect-square discriminant, which makes recovery of `d` and factorization of `n`
equivalent and exact.
