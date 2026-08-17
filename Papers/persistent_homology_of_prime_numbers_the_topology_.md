# Computational Evidence — Persistent Homology of the Prime Point Cloud

All numbers below come from an exploratory sieve computation over the primes up to
`10^6` (78 498 primes, 78 497 finite `H₀` bars).  They are **exploratory numerics**,
not machine-checked statements; every claim that is asserted as a fact in this
project is proved in Lean (see `Catalog/Computation/PrimeBarcodePoissonObstruction.lean`).

## 1. Setup

For the point cloud `P n = p_n ⊂ ℝ`, single-linkage on a line gives the finite `H₀`
barcode: the `i`-th finite bar has length exactly the prime gap `g_i = p_{i+1} − p_i`
(proved in the catalog file `Novelty/PrimePersistentHomology.lean`).  So the whole
zero-dimensional barcode is the gap multiset.

## 2. Bar-length histogram up to `10^6`

| bar length | 1 | 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 22 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| # bars | 1 | 8169 | 8143 | 13549 | 5569 | 7079 | 8005 | 4233 | 2881 | 4909 | 2401 | 2172 |

* Exactly **one** odd bar (length `1`, the bar `p_0 = 2 → p_1 = 3`).
* Every other bar length is **even**; no bar length is an odd number ≥ 3, and no bar
  length lies strictly between two consecutive even integers.
* mean bar length = `12.739…`, `log 10^6 = 13.8155…` (the PNT prediction for the mean,
  the small deficit is the usual `li`-type correction).
* max bar length = `114`, first attained after the prime `492113`.

## 3. Counterexample hunt against the Poisson/exponential conjecture

The conjecture asserts that the `H₀` bar lengths are exponentially distributed with
mean `m ≈ log x`.  With the empirical mean `m = 12.7391`:

| window | Exp(m) predicted mass | empirical frequency |
|---|---|---|
| `(0,1)` | 0.07550 | **0** |
| `(2,4)` | 0.12418 | **0** |
| `(4,6)` | 0.10614 | **0** |

The empirical mass on every open window between consecutive even integers is exactly
zero, whereas the exponential law predicts positive mass on each.  This is a *structural*
(not statistical) refutation: the barcode measure is atomic, supported on `{1} ∪ 2ℕ`,
while any exponential law is absolutely continuous.  This is the content of the Lean
theorems `bar_window_count_eq_zero` and `poisson_exponential_model_refuted`.

## 4. Betti curve is a step function with jumps only at even scales

`b₀(ε, n) = 1 + #{i < n : g_i > ε}`:

| ε | 1 | 1.5 | 2 | 2.9 | 3 | 4 | 6 |
|---|---|---|---|---|---|---|---|
| `b₀` | 78497 | 78497 | 70328 | 70328 | 70328 | 62185 | 48636 |

`b₀` is constant on `[2,4)` and on `[4,6)`: the Betti curve of the prime cloud is a
right-continuous staircase whose jumps sit only on even integers (and at `ε = 1`).
Formalised as `prime_bettiZero_const_on_even_window`.

## 5. The twin-prime step

`b₀(1,n) − b₀(2,n) = #{i < n : g_i = 2}` = number of twin pairs among the first `n`
gaps; below `10^6` this equals `8169`.  The twin prime conjecture is exactly the
statement that this *single step of the Betti curve* is unbounded in `n`
(`twinPrime_iff_betti_step_unbounded`).

## 6. `H₁`

For a point cloud on a line the Vietoris–Rips graph is an indifference (unit-interval)
graph; sampling random cycles in the prime Rips graph for `ε ≤ 200` produced no induced
cycle of length ≥ 4 — consistent with the theorem proved here, that every cycle admits a
two-step chord.  So there is no scale at which a "hole" can be created, in contrast to
the conjectured `H₁` bars at `ε ∼ (log x)²`.

## 7. OEIS

The prime gap sequence `g_n = p_{n+1} − p_n` begins `1, 2, 2, 4, 2, 4, 2, 4, 6, 2, …`
(OEIS A001223); the twin primes themselves are A001359 and the record (maximal) gaps
are A005250.  The histogram in §2 was produced by the sieve computation above, not read
off from OEIS.

## 8. Adjacent bar-length pairs (pair correlation)

Sieve to `2·10^5` (17 984 primes, 17 983 bars), counting adjacent bar-length patterns
`(g_i, g_{i+1})`:

| pattern | count |
|---|---|
| `(2,2)` | 1 (only at `i = 1`, the triple `3,5,7`) |
| `(4,4)` | 0 |
| `(8,8)` | 0 |
| `(6,6)` | 544 |
| `(2,4)` | 416 |
| `(4,2)` | 424 |
| `(2,6)` | 379 |

A repeated pattern `(d,d)` occurs only when `3 ∣ d`.  This is the empirical face of the
mod-3 law `PrimeBarcodeCorr.gap_pair_mod_three` and its corollary
`repeated_gap_dvd_three`, both proved in
`Catalog/Computation/PrimeBarcodeCorrelations.lean`.  An i.i.d. barcode with the empirical twin frequency
`q = 2160/17983 ≈ 0.1201` would predict about `(n−1)q² ≈ 259` occurrences of `(2,2)` in
this range; the true count is `1`.
