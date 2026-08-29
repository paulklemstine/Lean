# Computational Evidence — Oracle-Realization Gap (round-74 formalization)

All tables below were produced before or alongside the Lean development and drove the choice of
statements.  Everything **proved** lives in `Catalog/Novelty/` and is machine-checked; the tables
here are exploratory evidence, not verification.  Where a numerical fact is used inside a proof
(the witness semiprime), it is re-derived inside Lean and is machine-checked there
(`OracleRealizationGap.witness_gap`, `witness_realisation_gap`).

Notation: for `p ≤ q` odd, `N = pq`, `mid = (p+q)/2`, `gap = mid − ⌊√N⌋`.

## Table 1 — Fermat gap of sample semiprimes

| p | q | N | ⌊√N⌋ | mid | gap |
|---|---|---|---|---|---|
| 3 | 5 | 15 | 3 | 4 | 1 |
| 3 | 101 | 303 | 17 | 52 | 35 |
| 101 | 103 | 10403 | 101 | 102 | 1 |
| 997 | 1009 | 1005973 | 1002 | 1003 | 1 |
| 9973 | 10007 | 99799811 | 9989 | 9990 | 1 |
| 65521 | 65537 | 4294049777 | 65528 | 65529 | 1 |
| **955277** | **1044727** | **998003674379** | **999001** | **1000002** | **1001** |

The last row is the witness used in Lean: `295 < 1001 ≤ 22758`, i.e. it sits strictly inside the
window between the reported 295-item menu budget and the reported sensor threshold `B = 22758`.
Both factors are prime (verified in Lean by `norm_num`), and `mid² − N = 44725² = 2000325625`.

## Table 2 — Budget law, brute force

Claim under test: a Fermat scan of budget `k` (probing `⌊√N⌋ … ⌊√N⌋+k`, demanding a square
remainder and a nontrivial split) succeeds **iff** `gap ≤ k`.

* population: all semiprimes `N < 10^5` with two odd prime factors — **18 245** samples;
* budgets tested per sample: `k ∈ {0,1,2,3,5,10,50, gap−1, gap, gap+1}`;
* **violations: 0**.

Formalized as `OracleRealizationGap.scanHit_iff_gap_le`.

## Table 3 — Sparsity of the Fermat-close population

Count of `N ≤ X` that are products of two odd primes with `gap ≤ B`, against the bound proved in
`FermatCloseDensity.closeSet_ncard_le` (which counts a superset: all odd-factor pairs).

| X | B | count | empirical density | proved bound |
|---|---|---|---|---|
| 10^4 | 1 | 117 | 0.0117 | 1530 |
| 10^4 | 4 | 220 | 0.0220 | 3045 |
| 10^4 | 16 | 407 | 0.0407 | 7137 |
| 10^5 | 1 | 416 | 0.00416 | 8268 |
| 10^5 | 4 | 803 | 0.00803 | 16371 |
| 10^5 | 16 | 1537 | 0.01537 | 34632 |
| 10^6 | 1 | 1572 | 0.001572 | 45090 |
| 10^6 | 4 | 3063 | 0.003063 | 90450 |
| 10^6 | 16 | 6048 | 0.006048 | 184077 |

The empirical density falls by a factor ≈ 2.6 per decade of `X` at fixed `B`, consistent with the
proved `O(√B · X^{3/4})` count (density `O(√B · X^{-1/4})`, i.e. a factor `10^{-1/4} ≈ 0.56` per
decade for the *bound*; the true counts fall faster because primality is an extra constraint).
A fixed hit rate such as the reported `0.2053` therefore cannot survive as `X → ∞`; it is a
property of a finite laboratory population.

## Table 4 — The crediting law on random populations

Claim under test: for a finite population, a statistic `T` and a Boolean target `s`,
`min_f #{i : f(T i) ≠ s i} = Σ_classes min(#true, #false)`.

* 2000 random populations with `|P| ≤ 8` and `|image T| ≤ 3`, all `2^{|image T|}` policies
  enumerated;
* **violations: 0**.

Formalized as `StatisticRealization.isLeast_err` (lower bound `err_ge_irredError`, attainment
`exists_majority_optimal`).

## Table 5 — The divisor-midpoint law (cycle 2)

Claim under test: for odd composite `N`, the least budget with a scan hit equals
`min { (d + N/d)/2 − ⌊√N⌋ : d ∣ N, 1 < d < N }`.

* population: all odd composite `N < 20000` — **7738** samples;
* **violations: 0**;
* in **3878** of them (50.1 %) the minimum is *not* attained at the smallest prime factor but at
  an interior divisor — the navigation cost is a divisor-lattice functional, not a prime-factor
  functional.

Formalized as `OracleRealizationGap.scanHit_iff_exists_divisor`.

## OEIS

No OEIS lookup was performed (no network access in this environment), so no OEIS identifiers are
claimed.  The sequence of counts in Table 3 at `B = 1`
(`117, 416, 1572, …` for `X = 10^4, 10^5, 10^6`) is recorded here for a later search.

## Counterexample hunt

* `scanHit ↔ gap ≤ k` without the nontriviality guard `1 < a − b` is **false**: every odd `N`
  satisfies `N = ((N+1)/2)² − ((N−1)/2)²`, so the guard is mandatory.  This is why `ScanHit`
  carries it, and the Critic note in the Lean file records it.
* The divisor law genuinely fails for even `N`: take `N = 12`, `k = 0`.  The divisor `d = 3`
  has pair `(3, 4)` with *floored* midpoint `(3+4)/2 = 3 = ⌊√12⌋`, so the right-hand side holds,
  yet no scan hit exists at budget `0` (`3² = 9 < 12`).  Parity of the pair is what makes the
  midpoint exact, hence the `Odd N` hypothesis.
* No counterexample was found to any statement that was formalized.

## Table 6 — Parity-free (doubled) law, cycle 4

Claim under test: for every `N ≥ 1`, a doubled scan (probing `⌊√(4N)⌋ … ⌊√(4N)⌋+k`, guard
`2 < a − b`) succeeds iff `N` has a divisor `d` with `1 < d < N` and `d + N/d ≤ ⌊√(4N)⌋ + k`.

* population: all `N < 5000`, even and odd, budgets `k ∈ {0,…,20}`;
* **violations: 0** over 5000 × 21 = 105000 checks;
* the guard `2 < a − b` is essential: with `1 < a − b` the trivial split `4N = (N+1)² − (N−1)²`
  makes every `N` a hit.

Formalized as `OracleRealizationGap.scanHit2_iff_exists_divisor`.
