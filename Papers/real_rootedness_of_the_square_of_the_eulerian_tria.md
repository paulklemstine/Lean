# Computational Evidence: Real-rootedness of the square of the Eulerian triangle

## Object

Let `A(n, k)` be the Eulerian numbers (permutations of `[n]` with `k` descents). The
square of the Eulerian triangle has entries `C(n, k) = ∑_j A(n, j) · A(j, k)`, and the
row generating polynomial is `B_n(x) = ∑_k C(n, k) · x^k`.

## Small-case rows

Computed directly from the Eulerian recurrence:

| n | row of `C(n, ·)`                      | `B_n(x)`                                             |
|---|----------------------------------------|-----------------------------------------------------|
| 0 | 1                                      | `1`                                                 |
| 1 | 1                                      | `1`                                                 |
| 2 | 2                                      | `2`                                                 |
| 3 | 6, 1                                   | `x + 6`                                              |
| 4 | 24, 15, 1                             | `x² + 15x + 24`                                      |
| 5 | 120, 181, 37, 1                      | `x³ + 37x² + 181x + 120`                            |
| 6 | 720, 2163, 995, 83, 1               | `x⁴ + 83x³ + 995x² + 2163x + 720`                  |
| 7 | 5040, 27133, 23739, 4613, 177, 1    | `x⁵ + 177x⁴ + 4613x³ + 23739x² + 27133x + 5040`    |
| 8 | 40320, 364395, 546551, 204247, 19563, 367, 1 | `x⁶ + 367x⁵ + 19563x⁴ + 204247x³ + 546551x² + 364395x + 40320` |

Two structural observations, stable across all computed rows:

* `B_n` is **monic** of degree `n − 2` (for `n ≥ 2`), with constant term `n!`.
* The leading column `C(n, 0) = n!`.

## Root behaviour (numerical)

Approximate real roots of `B_n` (all roots turned out real, negative, and simple):

| n | approximate roots                                  |
|---|----------------------------------------------------|
| 4 | −13.18, −1.82                                       |
| 5 | −31.35, −4.87, −0.79                                |
| 6 | −69.04, −11.28, −2.28, −0.41                        |
| 7 | −146.64, −23.99, −4.87, −1.28, −0.23               |
| 8 | −305.04, −49.19, −9.12, −2.72, −0.79, −0.14        |

No complex roots appear in any tested row: the maximal imaginary part over all computed
roots is `0` (to machine precision). This is direct evidence for the conjecture that every
`B_n` is real-rooted.

## Counterexample hunt

Searched `n = 0, …, 8` for a row with a non-real root: **none found**. The first row that
resists a naive integer-bracket separation is `n = 8`, where two roots (`≈ −0.79` and
`≈ −0.14`) lie in `(−1, 0)`; they are still real, but require sub-integer brackets to
separate.

## Conclusion

The evidence strongly supports real-rootedness of `B_n` for all `n`. The accompanying
development proves it rigorously for `n ≤ 7` via explicit root separation; the boundary at
`n = 8` marks exactly where a uniform integer-bracket argument breaks down.
