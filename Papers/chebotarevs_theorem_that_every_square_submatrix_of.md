# Computational evidence — Chebotarev's theorem on the DFT matrix

All numbers below were produced by short exploratory scripts (exact integer arithmetic where
indicated, floating-point where indicated).  **They are exploratory only and are not
machine-verified.**  The machine-verified statements are the Lean theorems in
`Catalog/Novelty/ChebotarevDFT.lean` and `Catalog/Novelty/ChebotarevUncertainty.lean`,
which build with no `sorry`.

## 1. Exhaustive check of Chebotarev's theorem, exact arithmetic

For a prime `p`, every entry `ζ^{ab}` of the DFT matrix is a monomial in `ζ`, so the
determinant of a square submatrix indexed by `A, B ⊆ Z/p` is computed **exactly** by summing
signs over permutations into a coefficient vector in `Z[x]/(x^p − 1)` and then reducing modulo
`Φ_p` (i.e. subtracting the coefficient of `x^{p−1}` from all others).  The determinant is `0`
iff the reduced vector is identically `0`.

| p | pairs `(A,B)` with `#A = #B` tested | singular submatrices found |
|---|---|---|
| 2 | all | 0 |
| 3 | all | 0 |
| 5 | all | 0 |
| 7 | all | 0 |

(The counts include `k = 1, …, p`; the search is exhaustive over *all* pairs of subsets of equal
size, not a sample.)  No counterexample exists in this range — consistent with the theorem.

## 2. The staircase coefficient `c_N = det(vandermonde a) · chooseDet(b)`

The Lean proof shows `det((1+X)^{a_i b_j})` vanishes to order exactly
`N = 0 + 1 + ⋯ + (n−1)` at `X = 0`, with

```
c_N = det (vandermonde a) · det ( C(b_i, j) )   and   p ∤ c_N .
```

Exact integer computation of `c_N mod p` over **all** pairs `(A,B)` of equal-size subsets:

| p | number of pairs | minimum of `c_N mod p` |
|---|---|---|
| 5 | 251  | 1 |
| 7 | 3431 | 1 |

A value `0` would refute the key lemma; none occurs.

## 3. Counterexample hunt: composite moduli

For composite `N` the analogous statement is false.  Smallest singular square submatrix found
(floating-point determinant, threshold `10^{-9}`; the `N = 4` case is *proved* in Lean as
`ChebotarevDFT.singular_submatrix_of_composite`):

| N | size | rows `A` | columns `B` |
|---|---|---|---|
| 4 | 2 | {0,2} | {0,2} |
| 6 | 2 | {0,2} | {0,3} |
| 8 | 2 | {0,2} | {0,4} |
| 9 | 2 | {0,3} | {0,3} |
| 10 | 2 | {0,2} | {0,5} |
| 12 | 2 | {0,2} | {0,6} |
| 15 | 2 | {0,3} | {0,5} |

Pattern: a `2 × 2` singular minor exists as soon as `N` has a nontrivial divisor `d`, namely
`A = {0, N/d}`, `B = {0, d}` — this is exactly the obstruction that primality removes.

## 4. The uncertainty principle `|supp f| + |supp f̂| ≥ p + 1`

Exhaustive minimisation over all `f ∈ {−1,0,1}^{Z/p}`, `f ≠ 0` (floating point, threshold
`10^{-9}`):

| p | minimum of `#supp f + #supp f̂` | bound `p+1` | witness |
|---|---|---|---|
| 3 | 4 | 4 | constant function |
| 5 | 6 | 6 | constant function |
| 7 | 8 | 8 | constant function |

The minimum equals the theoretical bound in every case, so the inequality proved in
`ChebotarevDFT.uncertainty` is sharp; the Lean file records sharpness via a Dirac mass
(`ChebotarevDFT.uncertainty_sharp_delta`), the dual witness of the constant function above.

## 5. OEIS

The auxiliary integer `∏_{l<n} l!` (superfactorial) appearing in
`ChebotarevDFT.superFactorial_mul_chooseDet` is [OEIS A000178](https://oeis.org/A000178):
`1, 1, 2, 12, 288, 34560, …`.  No other new integer sequence arises from the computation
above: the pairs counts `251, 3431` are `∑_k C(p,k)^2 − 1 = C(2p,p) − 1`
(`C(10,5) − 1 = 251`, `C(14,7) − 1 = 3431`, [OEIS A000984](https://oeis.org/A000984) shifted).
