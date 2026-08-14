# Computational Evidence — Class-Wide No-Pinning Lemma

All numbers below were produced by `#eval` inside Lean 4 (mathlib4, v4.28.0),
using the definitions

```
lcmU B = lcm(1,…,B),   L B = 4 · lcm(1,…,B)   (the modulus of a level-B battery)
```

They are exploratory data supporting the formal statements in
`Catalog/Novelty/NoPinningLemma.lean`, `NoPinningBattery.lean`,
`NoPinningSealing.lean` and `NoPinningSymmetry.lean`; the theorems themselves
are proved unconditionally in Lean and do not rely on this table.

## 1. Moduli of the poly(log N) batteries

| B | L = 4·lcm(1..B) | log₂ L |
|---|---|---|
| 2 | 8 | 3 |
| 4 | 48 | 5 |
| 6 | 240 | 7 |
| 8 | 3360 | 11 |
| 12 | 110880 | 16 |
| 20 | 4·lcm(1..20) | 29 |

## 2. The pinned set (primes dividing L) is tiny

Candidates = the 168 primes below 1000.

| B | #pinned primes (p ∣ L) | #candidates | fraction |
|---|---|---|---|
| 2 | 1 | 168 | 0.6% |
| 4 | 2 | 168 | 1.2% |
| 6 | 3 | 168 | 1.8% |
| 8 | 4 | 168 | 2.4% |
| 10 | 4 | 168 | 2.4% |
| 12 | 5 | 168 | 3.0% |
| 14 | 6 | 168 | 3.6% |
| 16 | 6 | 168 | 3.6% |
| 18 | 7 | 168 | 4.2% |
| 20 | 8 | 168 | 4.8% |

The pinned count equals π(B) exactly (verified for these B), matching the proved
statement `prime_dvd_modLevel_iff` (pinned primes = primes ≤ B, plus 2) and the
proved bound `pinnedPrimes_card_le_log` (#pinned ≤ log₂ L).

## 3. Counterexample hunt: compensating partners at B = 12

Target `N₀ = 221 = 13 · 17`, modulus `L = 110880`.  For each prime candidate
`p ≤ 80` coprime to `L`, we searched the arithmetic progression
`N₀ · p⁻¹ + j·L` for the first prime `q`, then compared the **entire** level-12
battery of `p·q` against `N₀`: 12 residues `N mod m`, 12 Jacobi symbols
`(a | N)`, and 12 gcds `gcd(N, c)`, for `m, a, c ∈ {1,…,12}`.

| p | first compensating prime q | residues agree | Jacobi agree | gcds agree |
|---|---|---|---|---|
| 13 | 17 | ✓ | ✓ | ✓ |
| 17 | 13 | ✓ | ✓ | ✓ |
| 19 | 17519 | ✓ | ✓ | ✓ |
| 23 | 207307 | ✓ | ✓ | ✓ |
| 29 | 267649 | ✓ | ✓ | ✓ |
| 31 | 17891 | ✓ | ✓ | ✓ |
| 37 | 455513 | ✓ | ✓ | ✓ |
| 41 | 329941 | ✓ | ✓ | ✓ |
| 43 | 144407 | ✓ | ✓ | ✓ |
| 47 | 4723 | ✓ | ✓ | ✓ |
| 53 | 23017 | ✓ | ✓ | ✓ |
| 59 | 13159 | ✓ | ✓ | ✓ |
| 61 | 176321 | ✓ | ✓ | ✓ |
| 67 | 117503 | ✓ | ✓ | ✓ |
| 71 | 192091 | ✓ | ✓ | ✓ |
| 73 | 285557 | ✓ | ✓ | ✓ |
| 79 | 85619 | ✓ | ✓ | ✓ |

**17/17 candidates compensated; no counterexample found.**  Note the first two
rows: the true factorisation itself is just one of the consistent completions.

An important negative datum found during the hunt: with the *original* target
`N₀ = 35 = 5·7` at `B = 12` no compensating prime exists, because `5, 7 ∣ L`, so
`N₀` is **not** coprime to `L`.  This is exactly why the hypothesis
`Nat.Coprime N₀ L` appears in every theorem; without it the statement is false.

## 4. Barrier 1: polynomial gcds

For `f(x) = 7x³ + 5x + 12` and `N = 1000 + 37j`, `j < 12`:

`gcd(f(N), N)` = 4, 1, 6, 1, 4, 3, 2, 1, 12, 1, 2, 3
`gcd(f(0), N) = gcd(12, N)` = 4, 1, 6, 1, 4, 3, 2, 1, 12, 1, 2, 3

Identical on all samples — proved in general as
`Int.gcd_eval_eq_gcd_coeff_zero`.

## 5. OEIS

The pinned-set sizes are `π(B)` (OEIS A000720, 0, 1, 2, 2, 3, 3, 4, …) and the
moduli are `4 · A003418(B)` (A003418 = lcm(1..n): 1, 1, 2, 6, 12, 60, 60, 420,
840, 2520, 2520, 27720, …).  No new sequence appears.
