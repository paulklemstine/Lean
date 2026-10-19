# Computational Evidence — round 33 corrections

All numbers below were computed with short scripts and are **also** checked inside Lean,
in the declaration named next to each one.

## 1. GFHP Lemma 3.5 precondition window (base-2 log, `N = 2^k`)
The precondition `N^{1/3} ≥ N^{1/4}·lg⁸N` is equivalent to `k^96 ≤ 2^k`.

| k | `k^96 ≤ 2^k`? |
|---|---|
| 1 | yes |
| 2 … 949 | **no** (948 consecutive values) |
| 950 | yes (smallest value where it holds again) |
| 1024, 2048, 4096 | yes |

The script found failure exactly on `k ∈ [2, 949]`. Lean (`gfhpPre_fails_window`,
`gfhpPre_holds_from`) proves failure on `[96, 949]` and success for all `k ≥ 950`.
**Counterexample to the note's claim** "violates the precondition for every `N ≥ 2^96`":
`N = 2^2048` meets the precondition (`gfhpPre_rsa2048`).

## 2. Euler-gap reveal counts `#{k < ab : a∣k xor b∣k}` (coprime `a, b`)
(a,b,count): (1,1,0) (1,2,1) (1,3,2) (1,5,4) (2,3,3) (2,5,5) (3,4,5) (3,5,6) (4,5,7).
Every value equals `a + b − 2` (`reveal_count_cofactor`). Recomputing with `p−1 = ga`,
`q−1 = gb` for g = 1..6 gives the same counts (`reveal_count_gap_cancels`).

## 3. The free `a ≤ b` filter on `{ab ≤ r}`
At r = 100 there are 482 pairs and 246 with `a ≤ b`: `2·246 = 482 + 10 = 482 + ⌊√100⌋`
(`two_mul_card_ordered_pairs`, plus a `decide` check). The filter keeps a fraction → 1/2.

## 4. Effective sample size
Primes in `[2^19, 2^20)`: **38 635**; of these, **163** have 13-smooth `p − 1`
(`effective_sample_size`, checked by compiled evaluation).

## 5. Harvey filter-target table (exponent model, `filteredOpt σ₁ σ₂ = 1/5 − σ₂/5 − 2σ₁/5`)
| filter divides | rate | σ needed for 1/6 |
|---|---|---|
| pair term only | 1/5 − σ/5 | **1/6** |
| pair and sweep terms | 1/5 − 3σ/5 | 1/18 |
| sweep term only | 1/5 − 2σ/5 | 1/12 |

## 6. Counterexample hunts
* `good_pair_ordered` without `0 < p`: `p=−2, q=−1, a=2, b=1` gives `|aq−bp| = 0 < b` but
  `a > b`, so the positivity hypothesis is needed and was added.
* "sup ρ = 1/2": false once `a = 1` is allowed (ρ(1,b) = (b−1)/b → 1); true on `a,b ≥ 2`.

OEIS: no sequence lookup was relevant (the counts are the closed form `a + b − 2`).
