# Computational Evidence

Target identity:
$$\sum_{i_1+\cdots+i_m=d}\ \prod_{j=1}^{m}\binom{a+i_j}{a}=\binom{ma+d+m-1}{d}.$$

## 1. Small-case verification

Exhaustive check over `0 ≤ m ≤ 3`, `0 ≤ a ≤ 3`, `0 ≤ d ≤ 4` (all tuples
enumerated via the antidiagonal-tuple construction): every instance matches the
right-hand side. Selected values:

| m | a | d | LHS (sum of products) | RHS = C(ma+d+m-1, d) |
|---|---|---|-----------------------|----------------------|
| 1 | 2 | 3 | C(5,2) = 10           | C(5,3) = 10          |
| 2 | 1 | 2 | 1·3+2·2+3·1 = 10      | C(5,2) = 10          |
| 3 | 0 | 2 | number of tuples = 6  | C(4,2) = 6           |
| 3 | 2 | 2 | 45                    | C(10,2) = 45         |

All rows were computed by directly enumerating the tuples and summing the
binomial products, then compared against the closed form; every entry agrees.

## 2. Auxiliary identities checked

* `choose_eq_multichoose`: `C(a+i, a) = multichoose(a+1, i)` for `0 ≤ a,i ≤ 4` — all true.
* `multichoose_conv` (Vandermonde–Chu):
  `∑_{k=0}^{d} multichoose(r,k)·multichoose(t,d-k) = multichoose(r+t,d)`
  for `0 ≤ r,t,d ≤ 5` — all true.

## 3. Boundary probes

* `m = 0`: sum is `1` when `d = 0` and `0` when `d ≥ 1`, matching `C(d-1, d)`.
* `d = 0`: unique zero tuple, both sides equal `1`.
* `a = 0`: sum equals the number of tuples, `C(d+m-1, d)` (stars and bars).

## 4. Sequence identification

For fixed `a = 1`, the values `C(m+d+m-1, d)` reproduce the diagonals of
Pascal's triangle; the general right-hand side is the entry
`multichoose(m(a+1), d)`, i.e. the multiset coefficient family (OEIS A007318 as
the underlying binomial triangle).

## 5. Counterexample hunt

No counterexample found across the full sampled range. The identity is a
convolution consequence of the generating-function factorisation
`∏ (1-x)^{-(a+1)} = (1-x)^{-m(a+1)}`, so no counterexample is expected.

All numerical checks were performed by evaluating the finite sums directly and
comparing against the closed form; the formal development then proves the
statement for **all** `m, a, d`.
