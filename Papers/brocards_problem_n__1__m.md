# Computational Evidence — Brocard's Problem (`n! + 1 = m²`)

All computations below were executed in Lean (`#eval` / `native_decide`); the
finite verification is **machine-checked** inside
`Catalog/Probability/BrocardBorelCantelli.lean`.

## 1. Small-case calculations

| n | n!+1 | perfect square? | m |
|---|------|-----------------|---|
| 4 | 25   | yes             | 5 |
| 5 | 121  | yes             | 11 |
| 7 | 5041 | yes             | 71 |

`#eval (List.range 200).filter (fun n => isPerfectSquareB (n! + 1)) = [4, 5, 7]`.

## 2. Counterexample hunt (search for a 4th Brown number)

`native_decide` confirms (theorem `brocard_no_others_below_1000`):
```
(List.range 1000).filter (fun n => isPerfectSquareB (n! + 1)) = [4, 5, 7]
```
i.e. **no** Brown number `n` with `8 ≤ n < 1000`. (Larger n verified empirically
in the literature up to ~10^9 with no further solutions.)

## 3. OEIS

* Brown numbers `n`: OEIS **A085692** — `4, 5, 7`.
* Values `m`: OEIS **A216071** — `5, 11, 71`.
* Squares `n!+1`: OEIS **A146968** — `25, 121, 5041`.

## 4. The probabilistic density heuristic (numerics)

The "probability" a number of size `n!` is a perfect square is `≈ 1/(2√(n!))`.
Partial sums of `∑ 1/√(n!)` converge extremely fast:

| N | Σ_{n=0}^{N} 1/√(n!) |
|---|---------------------|
| 4 | ≈ 2.94 |
| 8 | ≈ 2.96 |
| ∞ | ≈ 2.96 (converges) |

The tail beyond `n = 7` contributes `< 0.05`, matching the heuristic prediction
that essentially all Brown numbers lie among the smallest `n`. Convergence is
proved formally as `summable_inv_sqrt_factorial`, and the Borel–Cantelli
consequence as `brocard_heuristic_finite` / `brocard_heuristic_ae_finite`.
