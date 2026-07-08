# Computational Evidence — Matsuno-type Depths `n_ℓ`

## Depth values `n_ℓ = v₂((ℓ² − 1)/8)`

For odd primes `ℓ`, `(ℓ² − 1)/8` is an integer and `n_ℓ` is its 2-adic valuation.

| ℓ  | ℓ²−1 | (ℓ²−1)/8 | n_ℓ |
|----|------|----------|-----|
| 3  | 8    | 1        | 0   |
| 5  | 24   | 3        | 0   |
| 7  | 48   | 6        | 1   |
| 11 | 120  | 15       | 0   |
| 13 | 168  | 21       | 0   |
| 17 | 288  | 36       | 2   |
| 23 | 528  | 66       | 1   |
| 31 | 960  | 120      | 3   |
| 47 | 2208 | 276      | 2   |
| 97 | 9408 | 1176     | 3   |

These match the enumeration produced in `#eval`:
`[(3,0),(5,0),(7,1),(11,0),(13,0),(17,2),(19,0),(23,1),(29,0),(31,3),...]`.

## Closed form check

`n_ℓ + 3 = v₂(ℓ − 1) + v₂(ℓ + 1)`:

* ℓ = 17: v₂(16) + v₂(18) = 4 + 1 = 5 = 2 + 3. ✓
* ℓ = 7:  v₂(6)  + v₂(8)  = 1 + 3 = 4 = 1 + 3. ✓
* ℓ = 31: v₂(30) + v₂(32) = 1 + 5 = 6 = 3 + 3. ✓

The `−3` offset is forced: among consecutive even numbers `ℓ−1, ℓ+1`, exactly one is
divisible by 4, so `v₂(ℓ²−1) ≥ 3` for every odd `ℓ`, hence `n_ℓ ≥ 0`.

## Additivity spot-check

With `NE`, `ord` fixed, `lambdaDiff (a*b) = lambdaDiff a + lambdaDiff b` whenever
`gcd(a,b)=1`: verified symbolically (disjoint prime supports) and confirmed on
`a = 5, b = 21` (prime factors {5} and {3,7}, disjoint).

## Counterexample hunt

The additivity identity *fails* without coprimality (e.g. `a = b = 3`, where
`primeFactors 9 = {3}` gives `lambdaDiff 9 = lambdaDiff 3 ≠ 2·lambdaDiff 3` unless the
local term vanishes), confirming the coprimality hypothesis is load-bearing.
