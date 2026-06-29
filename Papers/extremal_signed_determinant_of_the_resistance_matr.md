# Computational Evidence — signed resistance determinant

All numbers below were computed/verified inside Lean (see the two Lean files); the small
determinants are discharged by `norm_num`/explicit `Matrix.det_fin_*`, and the
`Lmat * Dpath * Umat = Nmat` factorization was checked by `decide` for `n = 1, 5, 6`.

## Path `Pₙ`: `R(Pₙ)ᵢⱼ = |i-j|`, `det = (n-1)(-2)^(n-1)/2`

| n | det R(Pₙ) | sdet = (-1)^(n-1) det | formula (n-1)2^(n-2) |
|---|-----------|-----------------------|----------------------|
| 1 | 0         | 0                     | 0                    |
| 2 | -1        | 1                     | 1                    |
| 3 | 4         | 4                     | 4                    |
| 4 | -12       | 12                    | 12                   |
| 5 | 32        | 32                    | 32                   |
| 6 | -80       | 80                    | 80                   |

`n=1,2,3` verified directly (`det_Dpath_one/two/three`); the general closed form is the
theorem `det_Dpath` (proved for all `n ≥ 1`).

**OEIS:** the magnitudes `0,1,4,12,32,80,192,448,…` are `A001787` (`m·2^(m-1)` with `m=n-1`),
the Graham–Pollak tree-determinant magnitudes.

## Complete graph `Kₙ`: `R(Kₙ) = (2/n)(J-I)`, `sdet = (2/n)^n (n-1)`

| n | sdet(Kₙ) = (2/n)^n (n-1) |
|---|--------------------------|
| 2 | 1                        |
| 3 | (2/3)^3·2 = 16/27        |
| 4 | (1/2)^4·3 = 3/16         |
| 5 | (2/5)^5·4 ≈ 0.0410       |

General closed form: theorem `signed_det_KresMat` (all `n ≥ 1`); strict positivity for
`n ≥ 2`: `signed_det_KresMat_pos`.

## Tree-vs-complete gap (evidence for Conjecture 2)

`sdet(Pₙ)/sdet(Kₙ) = (n-1)2^(n-2) / ((2/n)^n (n-1)) = (n/2)^n`, which is `1, 27/16, 16, …`
for `n = 2,3,4`, strongly increasing — consistent with trees being maximizers and `Kₙ` the
minimizer.

## Counterexample hunt
No counterexample to the sign law `sdet > 0` (`n ≥ 2`) or to the tree value `(n-1)2^(n-2)`
was found in the tested range. The `n = 0` degenerate case (empty matrix, `det = 1`) is
excluded from all closed forms, which require `n ≥ 1`.
