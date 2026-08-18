# Computational Evidence — support size of power-sum near misses

All numbers below were produced by `#eval` inside the Lean project (scratch module, removed
after use), using the catalog definitions `evenPart`, `oddPart`, `powerSum`, `wsum` from
`Shared/PowerSumSharpness.lean` and `Catalog/Applications/NearMiss*.lean`.  They are
*exploratory* data; every claim that survived is proved formally in the `.lean` files and is
`sorry`-free.

## 1. Support sizes of the binomial pair

`support s = s.toFinset` (distinct values used).

| `N`                          | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|------------------------------|---|---|---|---|---|---|---|---|---|
| `#support (evenPart N)`      | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 | 5 |
| `#support (oddPart N)`       | 0 | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 |
| `max`                        | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 | 5 |
| `(N+2)/2 = ⌈(N+1)/2⌉`        | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 | 5 |
| `min`                        | 0 | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 |
| `(N+1)/2 = ⌊(N+1)/2⌋`        | 0 | 1 | 1 | 2 | 2 | 3 | 3 | 4 | 4 |
| `card (evenPart N)`          | 1 | 1 | 2 | 4 | 8 | 16| 32| 64|128|

Actual supports:

```
N = 0 : evens [0]          odds []
N = 1 : evens [0]          odds [1]
N = 2 : evens [0,2]        odds [1]
N = 3 : evens [0,2]        odds [1,3]
N = 4 : evens [0,2,4]      odds [1,3]
...
N = 8 : evens [0,2,4,6,8]  odds [1,3,5,7]
```

The two support-size sequences are `⌈(N+1)/2⌉` (OEIS A008619 shifted: 1,1,2,2,3,3,…) and
`⌊(N+1)/2⌋` (A004526 shifted: 0,1,1,2,2,3,3,…); their sum is exactly `N+1`, i.e. the two
supports *partition* `{0,…,N}`.  The cardinalities are `2^(N-1)` for `N ≥ 1` (A000079),
matching the cycle-3 result `card_evenPart`.

**Conjecture suggested by the table (now proved).** The minimum support size over all near
misses at level `N` is `⌈(N+1)/2⌉` on the larger side and `⌊(N+1)/2⌋` on the smaller side,
attained by the binomial pair.  Formal statements: `card_support_max_lower_bound`,
`card_support_min_lower_bound`, `binomial_pair_minimises_support`.

## 2. Counterexample hunt for the support bound

The bound cannot be beaten because *both* supports together must cover `{0,…,N}`
(`support_union_eq_range`): by the classification, the multiplicity difference at every
`j ≤ N` is `lam·(-1)^j·C(N,j) ≠ 0`.  Sampling padded and scaled pairs
(`lam • evenPart N + u` versus `lam • oddPart N + u` for `lam ∈ {1,2}`,
`u ∈ {0, {1,1,3}}`) never produced a smaller total support — as it must not, since padding
only *adds* to supports and scaling leaves them unchanged.

## 3. The universality law, checked numerically

Test functions `f₁(n) = n⁴ + 3n − 7` and `f₂(n) = if n % 3 = 0 then 5 else n²`, compared with
`A(N,f) = ∑_{j≤N} (−1)^j C(N,j) f(j)`:

| `N`                                  | 0  | 1  | 2  | 3   | 4  | 5 | 6 |
|--------------------------------------|----|----|----|-----|----|---|---|
| `wsum (evenPart N) f₁ − wsum (oddPart N) f₁` | −7 | −4 | 14 | −36 | 24 | 0 | 0 |
| `A(N, f₁)`                           | −7 | −4 | 14 | −36 | 24 | 0 | 0 |
| `wsum (evenPart N) f₂ − wsum (oddPart N) f₂` | 5 | 4 | 7 | 9 | 21 | 45 | 54 |
| `A(N, f₂)`                           | 5  | 4  | 7  | 9   | 21 | 45| 54|

Two structural facts jump out and are now theorems:

* `f₁` has degree 4, and the discrepancy dies for `N ≥ 5`: near misses at level `N` are
  blind to test functions with vanishing `N`-th finite difference
  (`near_miss_blind_to_low_degree`, `near_miss_eq_fwdDiff`).
* Padding by `{1,1,3}` leaves the discrepancy unchanged (`−7,−4,14,−36,24,0,0`), and doubling
  the pair doubles it (`−14,−8,28,−72,48,0,0`) — exactly the content of the structure theorem
  `near_miss_structure` and of `near_miss_test_function`.

## 4. Verified formal artifacts

All theorems referenced above compile in Lean 4 / Mathlib (`lake build` clean) and depend
only on `propext`, `Classical.choice`, `Quot.sound`.  No `sorry`, no `native_decide`.
