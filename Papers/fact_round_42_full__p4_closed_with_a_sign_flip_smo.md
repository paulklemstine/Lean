# Computational Evidence — Round 42 follow-up

All numbers below are labelled by their status:
**[Lean]** = checked inside a compiled Lean file; **[script]** = ad-hoc Python exploration,
*not* formally verified (included only as context for the conjectures).

## 1. Checked in Lean
| Fact | Value | File |
|---|---|---|
| `10188² − 103764863` | `30481 = 11·17·163`, and `(103764863/163) = +1` | `QSSplitSetForcing.lean` |
| `det` of the triangle incidence matrix `trap3` | `2` | `GF2RankTrap.lean` |
| `rank_ℚ(trap3)`, `rank_𝔽₂(trap3)` | `3`, `2` (the round-42 "3 vs 2" instrument trap) | `GF2RankTrap.lean` |
| `Ψ_{2,3}(100)`, `Ψ_{2,3}(20)`, `Ψ_{2,3,5}(100)` | `20`, `10`, `34` (OEIS A003586 / A051037 counts) | `QSSplitSmoothYield.lean` |
| model work `(Q+1)/Ψ_S(100)` | `3/20` for `S={2,3}` → `4/34` for `S={2,3,5}` (decreases as `Q` grows) | `QSSplitSmoothYield.lean` |

## 2. Script exploration [script, not verified]
Fixed `B = 200` (`π(B) = 46`), window of `20000` positions starting at `⌈√N⌉`, 12 random
semiprimes `N = pq` with `p, q ∈ [8000, 12000]` (seed 42). `yield_B` counts `B`-smooth
`x² − N`; `yield_A` counts values smooth over the admissible (split ∪ ramified) set only.

| N | Q(N,B) | yield_B | yield_A |
|---|---|---|---|
| 74491601 | 15 | 161 | 161 |
| 118349591 | 20 | 72 | 72 |
| 81740969 | 21 | 224 | 224 |
| 88622867 | 21 | 65 | 65 |
| 118176241 | 22 | 390 | 390 |
| 110999183 | 22 | 169 | 169 |
| 76113109 | 25 | 296 | 296 |
| 85772657 | 25 | 291 | 291 |
| 69070957 | 25 | 283 | 283 |
| 137859923 | 27 | 138 | 138 |
| 97379041 | 27 | 816 | 816 |
| 126958759 | 29 | 536 | 536 |

* `yield_B = yield_A` on every row — the theorem `qs_smooth_iff_admissible_support` says it must.
* Counterexample hunt for the universal claim "every prime dividing a sieve value is split or
  ramified": none (it is a theorem, `sieveReachable_eq_admissiblePrimes`).
* The yield trends upward with `Q` but is noisy (the `N mod 8` behaviour of the prime 2
  and which *small* primes split matter much more than `Q` alone) — this is why the Lean
  result is stated as a ceiling `(log₂X+1)^Q`, not as a monotone law.
