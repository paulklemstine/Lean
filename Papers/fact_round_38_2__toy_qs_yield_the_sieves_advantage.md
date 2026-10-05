# Computational Evidence — TOY-QS-YIELD (exp 470)

These numbers come from small Python scripts run during this session; they are
exploration data. The parts that matter for the theorems are re-checked in Lean in
the Lab-notes sections of the `Catalog/Computation/ToyQS*.lean` files (marked ✔ below).

Toy modulus: `N = 103764863 = 9127 × 11369` (✔ `ToyQSFactor.toy_N_factorization`).

## 1. QR-restricted factor base (`B = 60`)
* Primes ≤ 60: 17. Admissible (`(N|p) = +1`, or `p = 2`): `{2,11,17,19,23,31,37,43,47,59}`, which is 10 primes.
* The 7 excluded primes (3, 5, 7, 13, 29, 41, 53) never divide any `x² − N`.

## 2. Number of Hensel lines modulo `p^k` (number of roots of `x² ≡ N`)
| p | k=1 | k=2 | k=3 |
|---|-----|-----|-----|
| 11, 17, 19, 23 (admissible) | 2 | 2 | 2 |
| 3, 5, 7 (non-residue) | 0 | 0 | 0 |
| 2 | 1 | 0 | 0 |

This matches `rootCountPow_eq_two` and `rootCountPow_eq_zero`. The `p = 2` row matches
`N ≡ 7 (mod 8)` and `four_dvd_obstruction` (✔ `toy_N_two_adic`).

## 3. Relations lost by a sieve that only uses first powers (exact threshold)
| N | B | window | #FB | smooth relations | squarefree (found by K=1 sieve) | fraction lost |
|---|---|--------|-----|------------------|------------------|--------|
| 103764863 | 60 | 2·10⁴ | 10 | 11 | 1 | 0.909 |
| 103764863 | 200 | 2·10⁵ | 23 | 271 | 115 | 0.576 |
| 8589803519 | 300 | 2·10⁵ | 25 | 83 | 38 | 0.542 |

With an exact threshold, the lost relations are exactly the non-squarefree smooth ones
(`first_power_sieve_accepts_iff`). The figure of ~20% in the experiment ledger came
from a tolerant threshold, so it is smaller than these exact-threshold fractions.

## 4. Sieve work against trial division (`B = 200`, odd admissible primes, M = 2·10⁵)
* Measured: 0.993 log-additions per value, counting all prime-power lines.
* Proven bound `sieve_work_le`: 1.001 per value.
* Trial division: 22 divisions per value.
The ratio is a constant factor set by the survivor filter (H1).

## 5. GF(2) dependencies for `N = 103764863` (`B = 60`, 11 relations)
* Three dependencies with 3 relations each: all **trivial** (`gcd = N`). One is checked ✔ in `toy_trivial_dependency`.
* Dependencies with 4 or 5 relations: 4 of the 5 found are non-trivial and give `gcd = 9127`.
  ✔ The one using `{10248, 10342, 10749, 18185}` is checked in `toy_qs_factor`.
* All four relation values in that dependency have a repeated prime factor
  (✔ `dep_factorizations`). A sieve using only first powers would have found none of them.
* The CRT count says exactly 2 of the 4 square roots are useful
  (`card_nontrivial_sqrt_semiprime`). Of the 8 small dependencies, 4 were useful.

## Counterexample hunt
No counterexamples turned up for: 2 lines modulo `p^k` (p ≤ 23, k ≤ 3), the sieve work
bound, or `x² ≡ y²` having 4 roots modulo `pq`.
