# Computational evidence — Singmaster multiplicity

All numbers below were produced by direct enumeration of Pascal's triangle
(`C(N,k)` for `2 ≤ k ≤ N-2`, `C(N,2) ≤ 10^5`) before the Lean formalisation, and every
claim that ended up in a theorem was subsequently re-verified inside Lean by kernel
computation (`decide`) or by proof.

Throughout, `mult n = #{(N,k) : k ≤ N, C(N,k) = n}`.

## 1. The spectrum below 10^5

Distribution of `mult n` over `3 ≤ n ≤ 100000`:

| value of `mult n` | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|
| # of `n ≤ 10^5` | 99406 | 8 | 577 | **0** | 6 | **0** | 1 |

* The eight values with `mult n = 3` are exactly the central binomial coefficients
  `6, 20, 70, 252, 924, 3432, 12870, 48620` — matching the parity theorem
  `Singmaster.odd_mult_iff` (odd multiplicity ⟺ central binomial coefficient).
* The seven values with `mult n ≥ 6` are `120, 210, 1540, 3003, 7140, 11628, 24310`
  (OEIS A003015, "numbers occurring 5 or more times in Pascal's triangle").
* `3003` is the unique value with `mult n = 8` in this range (OEIS A098565 lists the
  known 6-fold values).
* `5` and `7` are **not attained**, which is what
  `Singmaster.mult_ne_five_or_seven_of_lt` proves rigorously for `n < 3003`.

## 2. Multiplicity exactly four

First values with `mult n = 4`:
`10, 15, 21, 28, 35, 36, 45, 55, 56, 66, 78, 84, 91, 105, 126, 136, 153, 165, 171, 190`
(mostly triangular numbers `C(M,2)`).  The subfamily `C(p,2)` for primes `p ≥ 5`
(`10, 21, 55, 78, 190, 231, …`) always has multiplicity exactly `4`; this observation
became the theorem `Singmaster.mult_choose_two_prime`.

## 3. Counterexample hunt for the counting bound

Comparison of the true count `#{3 ≤ n ≤ x : mult n ≥ 3}` with the proved bound
`(⌊√(2x)⌋+2)(⌊log₂ x⌋+2)`:

| `x` | true count | proved bound |
|---|---|---|
| 10^2 | 16 | 128 |
| 10^3 | 64 | 506 |
| 10^4 | 199 | 2145 |
| 10^5 | 592 | 8082 |

No counterexample; the bound is valid but not tight (the true growth looks like `c√x`
with `c ≈ 1.9`, consistent with the `k = 2` column dominating).

## 4. The row-shift / Fibonacci family

`C(N,k) = C(N-1,k+1)` with `N = F(2i+2)F(2i+3)`, `k = F(2i)F(2i+3)`:

| `i` | `N` | `k` | identity holds | `C(N,k)` |
|---|---|---|---|---|
| 1 | 15 | 5 | yes | 3003 |
| 2 | 104 | 39 | yes | ≈ 6.12·10^28 |
| 3 | 714 | 272 | yes | ≈ 3.54·10^204 |
| 4 | 4895 | 1869 | yes | ≈ 4.59·10^1435 |

Each such value has at least the six occurrences
`(n,1), (n,n-1), (N,k), (N,N-k), (N-1,k+1), (N-1,N-2-k)`, verified numerically for
`i = 1,2` and proved in general in `Catalog/NumberTheory/SingmasterFibonacciSix.lean`.

## 4b. Exhaustive search for row-shift solutions

Solving `N(k+1) = (N-k)(N-k-1)` exactly (the discriminant `5N²+2N+1` must be a perfect
square) for all `N < 300000` with `2 ≤ k ≤ N/2` yields exactly

`(15,5), (104,39), (714,272), (4895,1869), (33552,12815), (229970,87840)`

— precisely the Fibonacci parametrisation, with no sporadic solutions.  This is the
evidence behind future direction D3.

## 5. Search-radius calibration (used by the Lean `decide` calls)

An interior occurrence of `n` satisfies `N(N-1) ≤ 2n`, so a search radius `b` with
`2n < b(b-1)` is sufficient.  Calibrated radii actually used:

| `n` | 6 | 20 | 70 | 252 | 924 | 120 | 3003 |
|---|---|---|---|---|---|---|---|
| radius `b` | 5 | 7 | 13 | 23 | 44 | 17 | 79 |
| interior occurrences found | 1 | 1 | 1 | 1 | 1 | 4 | 6 |
| `mult n` | 3 | 3 | 3 | 3 | 3 | 6 | 8 |

## 6. Follow-up cycle: row-shift classification and depth-two shifts

**Row-shift solutions (D3, now proved).**  An exploratory enumeration of the Diophantine
form `k² + k + N² = 3Nk + 2N` over `N < 2000` with `2k ≤ N` returns

`(0,0), (2,0), (15,5), (104,39), (714,272)`

i.e. the Fibonacci ladder `(fibRow i, fibCol i)` for `i = 0,1,2,3` together with the
degenerate pair `(0,0)`.  This is exactly the shape of the theorem now proved in
`Catalog/NumberTheory/SingmasterRowShiftClassification.lean`
(`rowShift_classification`, which assumes `1 ≤ N` precisely to exclude `(0,0)`); the Lean
statement is unconditional in `N`, so the search is illustrative rather than load-bearing.

**Depth-two shifts (D4, open).**  An exploratory search for solutions of
`C(N,k) = C(N-2,j)` with `2 ≤ k`, `2j ≤ N-2`, `k < j`, over `N < 200` and `k, j ≤ 9`,
found none.  This search is *not* machine-checked and only motivates conjecture D4.
