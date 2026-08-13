# Computational evidence — the symmetry-breaking cost of factoring

All numbers below were produced with `#eval` inside Lean 4 / Mathlib (same toolchain as the
proofs), so they are reproducible from the project itself.  They guided, and then cross-checked,
the four theorem files in `Catalog/Novelty/SymmetryBreakingCost*.lean`.

## 1.  Isolation cost vs. `log₂ π(√N)`

For `N = 2^k` we list the number of odd-prime candidates below `√N` and the two logarithms that
appear in the theorems (`Nat.clog 2` is `⌈log₂ ·⌉`).

| `N` | `π(√N)` | `⌈log₂ π(√N)⌉` (proved cost) | `⌈log₂ √N⌉ = ½ log₂ N` (proved upper bound) |
|---|---|---|---|
| `2^10` | 11 | 4 | 5 |
| `2^12` | 18 | 5 | 6 |
| `2^16` | 54 | 6 | 8 |
| `2^20` | 172 | 8 | 10 |
| `2^24` | 564 | 10 | 12 |

The proved statements are `isolationCost_isLeast` (cost `= ⌈log₂ |S|⌉` exactly) and
`isolation_cost_le_of_le_four_pow` (`k` queries suffice as soon as `N ≤ 4 ^ k`), and the table
is consistent with both: column 3 ≤ column 4 in every row.

## 2.  A concrete separating battery

Candidate set `S = {3, 5, 7, 11, 13}` (`|S| = 5`, `⌈log₂ 5⌉ = 3`).  An exhaustive search over all
triples of test integers in `[2, 20)` found separating batteries; the first is `[2, 3, 10]`:

| `r` | `J(2\|r)` | `J(3\|r)` | `J(10\|r)` |
|---|---|---|---|
| 3 | −1 | 0 | 1 |
| 5 | −1 | −1 | 0 |
| 7 | 1 | −1 | −1 |
| 11 | −1 | 1 | −1 |
| 13 | −1 | 1 | 1 |

All five signatures are distinct, so a depth-3 decision tree identifies every candidate; no
depth-2 tree can (it has at most 4 leaves) — this is exactly `QTree.card_le_two_pow_depth` and
`QTree.adaptiveCost_isLeast`.

## 3.  Zero pruning: moduli with identical Jacobi batteries

`J(a | M)` for `a = 1 … 40` coprime to the modulus:

| modulus | squarefree kernel | battery |
|---|---|---|
| 15 = 3·5 | {3, 5} | reference row |
| 135 = 3³·5 | {3, 5} | identical to 15 |
| 375 = 3·5³ | {3, 5} | identical to 15 |
| 3375 = 3³·5³ | {3, 5} | identical to 15 |
| 21 = 3·7 | {3, 7} | differs already at `a = 2`: `J(2\|15) = 1`, `J(2\|21) = −1` |

Formalised as `jacobiSym_battery_eq_iff` (equal batteries ⟺ equal kernels), `sqKernel_mul_sq`
and `zero_pruning_sharp`.

## 4.  Factoring witnesses always exist

CRT witness `x ≡ 1 (mod p)`, `x ≡ −1 (mod q)`:

| `(p, q)` | `N` | `x` | `x² mod N` | `gcd(x − 1, N)` |
|---|---|---|---|---|
| (3, 5) | 15 | 4 | 1 | 3 |
| (3, 7) | 21 | 13 | 1 | 3 |
| (3, 11) | 33 | 10 | 1 | 3 |
| (5, 7) | 35 | 6 | 1 | 5 |
| (7, 11) | 77 | 43 | 1 | 7 |
| (11, 13) | 143 | 12 | 1 | 11 |

Formalised as `exists_nontrivial_sqrt_one` and `gcd_witness_eq_prime`; the converse (no other
kind of nontrivial square root exists) is `factor_of_any_nontrivial_sqrt`.

## 5.  Counterexample hunt

* Enumerated all pairs of odd moduli `m < n ≤ 400`, comparing the vectors
  `(J(a | ·))` for `a ≤ 200` coprime to the modulus: **0** pairs had equal vectors with different
  squarefree kernels, consistent with `jacobiSym_battery_eq_iff`.
* Enumerated all odd semiprimes `p q ≤ 2000` with `p < q` and searched for a nontrivial square
  root of `1` modulo `p q`: **0** semiprimes lacked one, as `exists_nontrivial_sqrt_one` now
  proves is impossible.
* No battery of size `< ⌈log₂ |S|⌉` can separate `S`; this is not a search but the pigeonhole
  half of `isolationCost_isLeast`, and the depth-2 case of Section 2 is an instance of it.

## 6.  OEIS

`π(√N)` for `N = 2^k` (11, 18, 54, 172, 564, …) is the prime-counting function sampled at powers
of two; no separate sequence entry was pursued, and no new integer sequence arose in this work.
