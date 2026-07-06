# Computational Evidence: Real-rootedness of the square of the Eulerian triangle

## 1. Objects

Eulerian numbers `A(n,k)` (permutations of `{1,…,n}` with `k` descents) via the
recurrence `A(n,k) = (k+1)A(n-1,k) + (n-k)A(n-1,k-1)`:

```
n=0: 1
n=1: 1
n=2: 1 1
n=3: 1 4 1
n=4: 1 11 11 1
n=5: 1 26 66 26 1
n=6: 1 57 302 302 57 1
n=7: 1 120 1191 2416 1191 120 1
```

The **square of the Eulerian triangle** is `B(n,k) = Σ_j A(n,j)·A(j,k)`
(lower-triangular matrix product), and the object of interest is the row
generating polynomial `S_n(x) = Σ_k B(n,k) x^k`.

## 2. Small-case rows of `B(n,·)` (verified by `#eval`)

```
n=2: 2
n=3: 6 1
n=4: 24 15 1
n=5: 120 181 37 1
n=6: 720 2163 995 83 1
n=7: 5040 27133 23739 4613 177 1
```

Structural observations (all verified in Lean, see `Defs.lean`):

* **Constant term** `B(n,0) = n!`  (`sqRowPoly_coeff_zero`, `eulSq_zero`).
* **Leading coefficient** `= 1`, **degree** `= n-2` for `n ≥ 2`.
* **Coefficients are nonnegative**; hence (proved) `S_n(x) > 0` for all `x ≥ 0`,
  so every real root is strictly negative (`sqRowPoly_eval_pos_of_nonneg`).

## 3. Row polynomials and their roots

```
S_2(x) = 2                        (no roots — vacuously real-rooted)
S_3(x) = x + 6                    root: -6
S_4(x) = x^2 + 15x + 24           discriminant 129 > 0; roots (-15 ± √129)/2 ≈ -1.82, -13.18
S_5(x) = x^3 + 37x^2 + 181x + 120 three real roots (all negative; sum -37, product -120)
S_6(x) = x^4 + 83x^3 + 995x^2 + 2163x + 720
S_7(x) = x^5 + 177x^4 + 4613x^3 + 23739x^2 + 27133x + 5040
```

## 4. Counterexample hunt (real-rootedness of `S_n`)

We evaluated `S_n` on a fine grid of the negative axis and counted sign changes
(all roots are negative by §2).  The number of sign changes equals the degree
`n-2` for every tested `n`, i.e. **all roots are real and simple**:

| n | degree n-2 | sign changes found | real-rooted? |
|---|-----------:|-------------------:|:------------:|
| 4 | 2          | 2                  | yes |
| 5 | 3          | 3                  | yes |
| 6 | 4          | 4                  | yes |
| 7 | 5          | 5                  | yes |
| 8 | 6          | 6                  | yes |

No counterexample was found in the tested range `n ≤ 8`.  This supports the
general conjecture that `S_n` is real-rooted for every `n`.

## 5. OEIS

* Eulerian numbers `A(n,k)`: OEIS **A008292**.
* The constant-term / first-column sequence of `B` is `n!` = OEIS **A000142**.
* The row sums of `B`, `Σ_k B(n,k) = Σ_j A(n,j)·j!`, give
  `1, 1, 2, 7, 40, 339, 3962, …` (from `n=0`).  This is the diagonal of the
  Eulerian-times-factorial transform; the exact OEIS identifier should be
  checked against the "sum of A(n,j)·j!" interpretation.

## 6. What is proved vs. conjectured

* **Proved in Lean (0 sorries):** constant term `n!`; the decomposition
  `S_n = Σ_j A(n,j)·A_j` where `A_j` is the `j`-th Eulerian polynomial;
  positivity on `[0,∞)`; real-rootedness of `S_2, S_3, S_4`.
* **Conjectured (open in general):** real-rootedness of `S_n` for all `n`.  The
  decomposition identity is the reduction that an interlacing/compatibility
  argument would consume to settle the full statement.
