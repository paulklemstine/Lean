# Computational evidence (Phase A, q-Vandermonde / q-binomial)

All numbers below were produced with `#eval` inside Lean 4 (Mathlib v4.28.0), using the
same recursive definition that the formal development uses,

```lean
qBinom q n 0       = 1
qBinom q 0 (k+1)   = 0
qBinom q (n+1) (k+1) = qBinom q n k + q^(k+1) * qBinom q n (k+1)
```

Every claim that survived this stage was subsequently **proved** in
`Catalog/Applications/`; the tables are exploratory data, not a substitute for the proofs.

## 1. Small-case tables

Gaussian binomials at `q = 2` (rows `n = 0..5`):

| n | ⟦n,0⟧ | ⟦n,1⟧ | ⟦n,2⟧ | ⟦n,3⟧ | ⟦n,4⟧ | ⟦n,5⟧ |
|---|---|---|---|---|---|---|
| 0 | 1 | | | | | |
| 1 | 1 | 1 | | | | |
| 2 | 1 | 3 | 1 | | | |
| 3 | 1 | 7 | 7 | 1 | | |
| 4 | 1 | 15 | 35 | 15 | 1 | |
| 5 | 1 | 31 | 155 | 155 | 31 | 1 |

This is OEIS **A022166** (Gaussian binomial coefficients for `q = 2`), and the visible
row symmetry is the theorem `qBinom_symm`.  `⟦4,2⟧_2 = 35` is exactly the number of
lines of `PG(3,2)`, matching `Shared.GrassmannJq2.numLines 2 = 5·7 = 35`
(proved in general as `qBinom_four_two_eq_numLines`).

## 2. Universal claims tested before formalisation

Each of the following was tested over `q ∈ {-2, 0, 1, 2, 3, 5}` (as integers), all
`m, n ≤ 6`, all `k ≤ 8`, and `x ∈ {-1, 2, 7}` where relevant.  "OK" means no
counterexample in the whole sample.

| Claim | Result | Formal name |
|---|---|---|
| `⟦m+n,k⟧ = ∑_{j≤k} q^{(m-j)(k-j)} ⟦m,j⟧⟦n,k-j⟧` | OK | `qBinom_vandermonde` |
| `∏_{i<n}(1+q^i x) = ∑_k q^{k(k-1)/2} ⟦n,k⟧ x^k` | OK | `qBinom_rothe` |
| second q-Pascal `⟦n+1,k+1⟧ = q^{n-k}⟦n,k⟧+⟦n,k+1⟧` | OK | `qBinom_succ_succ'` |
| `⟦n,k⟧ = ⟦n,n-k⟧` (`k ≤ n`) | OK | `qBinom_symm` |
| `⟦n,k⟧(q;q)_k(q;q)_{n-k} = (q;q)_n` | OK | `qBinom_mul_qPoch` |
| `G_{n+2} = 2G_{n+1} + (q^{n+1}-1)G_n` | OK | `qGalois_rec` |
| `∑_k (-1)^k q^{k(k-1)/2}⟦n,k⟧ = 0` (`n ≥ 1`) | OK | `qBinom_alternating_sum` |
| `⟦n,k⟧_1 = C(n,k)` | OK | `qBinom_one_eq_choose` |

## 3. Counterexample hunt (a claim that failed)

A tempting "reflected" q-Vandermonde with exponent `j·(n-k+j)` written using **natural**
subtraction,

`⟦m+n,k⟧ =? ∑_{j≤k} q^{j(n-k+j)} ⟦m,j⟧⟦n,k-j⟧`,

**fails** already for small data (`q = 2, m = n = 1, k = 2`: LHS `⟦2,2⟧ = 1`, RHS `= 2`).
The reason is that `n - k + j ≠ n - (k - j)` in `ℕ` when `k > n`.  The corrected form
with exponent `j·(n-(k-j))` passed the same sweep and is the theorem
`qBinom_vandermonde'`.  This is a concrete instance of the general hazard: identities
involving `q^{(m-j)(k-j)}` must be checked in truncated arithmetic, and are only safe
because the coefficients `⟦m,j⟧` vanish exactly where the truncation bites.

## 4. Galois numbers (OEIS hits)

`G_n(q) = ∑_k ⟦n,k⟧_q` (total number of subspaces of `𝔽_q^n` for prime power `q`):

* `q = 2`: 1, 2, 5, 16, 67, 374, 2825, 29212 — OEIS **A006116**.
* `q = 3`: 1, 2, 6, 28, 212, 2664, 56632 — OEIS **A006117**.

Both sequences satisfy the Goldman–Rota recurrence `G_{n+2} = 2G_{n+1} + (q^{n+1}-1)G_n`
in the sampled range (e.g. `2825 = 2·374 + (2^5-1)·67 = 748 + 2077`), which is the
proved theorem `qGalois_rec`.

## 5. Central q-binomial and Cauchy inverse

`⟦2n,n⟧_2` for `n = 0..4`: 1, 3, 35, 1395, 200787, and in each case the value agrees with
`∑_j 2^{(n-j)^2} ⟦n,j⟧_2^2` (theorem `qBinom_sq_sum`).

Truncated product of the series `∑_k ⟦n+k-1,k⟧_q x^k` with `∏_{i<n}(1-q^i x)` at
`q = 2, n = 3`: coefficients `[1, 0, 0, 0, 0, 0]` up to `x^5`, i.e. the product is `1`
to the tested order — the finite shadow of `qBinom_cauchy`.
