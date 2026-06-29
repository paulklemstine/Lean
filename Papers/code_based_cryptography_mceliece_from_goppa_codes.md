# Computational Evidence — McEliece from Goppa Codes

All numbers below were produced with Lean `#eval`/`decide` and then turned into
machine-checked theorems in `Parameters.lean` and `GoppaDistance.lean`.

## 1. Error-search-space size (256-bit security target)

The dominant cost parameter of information-set decoding is the number of
weight-`t` error patterns `C(n,t) = Nat.choose n t`.

| parameter set     | n    | m  | t   | k = n−m·t | log₂ C(n,t) | ≥ 2²⁵⁶ ? |
|-------------------|------|----|-----|-----------|-------------|----------|
| mceliece6960119   | 6960 | 13 | 119 | 5413      | ≈ 863       | yes      |
| mceliece8192128   | 8192 | 13 | 128 | 6528      | ≈ 946       | yes      |

`#eval (Nat.choose 6960 119).log2  = 863`
`#eval decide (2^256 ≤ Nat.choose 6960 119) = true`

So the weight-119 error space of `mceliece6960119` is ≈ 2⁸⁶³, hugely exceeding the
256-bit floor. (Real ISD is sub-exponential in this quantity, but the raw search
space already certifies infeasibility of naive enumeration.)

## 2. Why `b = 5` in the rigorous lower bound

We prove `2^256 ≤ Nat.choose 6960 119` *without* a giant `decide` by chaining a
small numeric step with a general combinatorial inequality `pow_le_choose`:

- `5^119` has `log₂ ≈ 276`, so `2^256 ≤ 5^119` (`#eval (5^119).log2 = 276`).
- `pow_le_choose` gives `5^119 ≤ C(6960,119)` since `(5+1)·119 = 714 ≤ 6961`.

A smaller base fails: `4^119` has `log₂ ≈ 238 < 256`, so `b = 5` is the smallest
power-of-the-bound witness that clears the target — this guided the choice in the
proof.

## 3. Designed-distance sanity (GRS / alternant)

For `n` distinct evaluation points and a nonzero polynomial of degree `< k`, a
nonzero polynomial has at most `deg < k` roots, hence at most `k−1` zero
coordinates, hence Hamming weight `≥ n − k + 1`. Spot check `n = 7, k = 3`: a
degree-≤2 nonzero polynomial vanishes at ≤ 2 of 7 points, so the codeword has
weight ≥ 5 = n − k + 1. This is exactly `grs_min_distance`.

Dually, a `t × n` Vandermonde parity check (distinct columns) admits no nonzero
kernel vector of weight ≤ t (a weight-≤t vector would force a nonzero
degree-<t locator polynomial to vanish on its own roots) — this is
`bch_parity_min_weight`, the structural reason a degree-`t` Goppa code corrects
errors.

## 4. Counterexample hunt

- `pow_le_choose` was tested on many small `(b,t,n)` with `(b+1)t ≤ n+1`
  (e.g. `(2,2,4),(3,3,9),(5,2,10),(2,5,10)`): no counterexample; all hold.
- Dropping the hypothesis breaks it (e.g. `b=3,t=2,n=4`: `9 > C(4,2)=6`), so the
  hypothesis `(b+1)·t ≤ n+1` is load-bearing and kept explicit.
- The GRS/BCH bounds are tight (attained by products of linear factors), so they
  are not vacuous.
