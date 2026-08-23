# Computational Evidence — Parity-corrected asymptotics for the information-free werewolf game

All numbers below were produced by `#eval` inside the Lean project itself (exact `ℚ`
arithmetic for the small tables, `Float` for the long ladders), against the *same*
definitions that the theorems are stated about
(`Catalog/Physics/InfoFreeWerewolf/Defs.lean`).

## 1. The model

State: `(v villagers, k wolves)`, population `n = v + k`, at the start of a day.

* **Day.** One of the `n` players is lynched, uniformly at random (information-free village).
* **Night.** If at least one wolf survives the day, exactly one villager is eaten.
* Wolves win when no villagers remain; the village wins when no wolves remain.

Hence, *after a day that misses a wolf*, the population drops by exactly **2**
(one villager lynched + one villager eaten). After a day that hits a wolf the population
also drops by 2 in the sense that a wolf is removed and the night kill is skipped only if
no wolf remains. In either case the population decreases by two per round until absorption:

> **The parity of the population is a conserved quantity of the game.**

This is the "parity trace" of the mission statement, and it is the reason a single scaling
law cannot exist.

`failProb v k` (Lean: `InfoFreeWerewolf.failProb`) is the wolf-win probability:

```
failProb 0 0 = 0        failProb 0 (k+1) = 1        failProb (v+1) 0 = 0
failProb (v+1) (k+1) = ((k+1)·failProb v k + (v+1)·failProb (v-1) (k+1)) / (v+k+2)
```

`villageWin v k = 1 - failProb v k`, and `surv` is the single-wolf survival product
`surv 0 = surv 1 = 1`, `surv (n+2) = surv n · (n+1)/(n+2)`.

## 2. Small-case exact table (populations 7 … 20)

`p(n,k) = failProb (n-k) k` is the exact wolf-win probability; the second entry in each
cell is `√n · p(n,k)`.

| n | k=1 | √n·p | k=2 | √n·p | k=3 | √n·p |
|---|-----|------|-----|------|-----|------|
| 7 | 16/35 | 1.20949 | 27/35 | 2.04101 | 33/35 | 2.49457 |
| 8 | 35/128 | 0.77340 | 35/64 | 1.54680 | 25/32 | 2.20971 |
| 9 | 128/315 | 1.21905 | 221/315 | 2.10476 | 31/35 | 2.65714 |
| 10 | 63/256 | 0.77822 | 63/128 | 1.55643 | 91/128 | 2.24818 |
| 11 | 256/693 | 1.22519 | 449/693 | 2.14887 | 193/231 | 2.77103 |
| 12 | 231/1024 | 0.78145 | 231/512 | 1.56291 | 21/32 | 2.27332 |
| 13 | 1024/3003 | 1.22947 | 1817/3003 | 2.18158 | 61/77 | 2.85635 |
| 14 | 429/2048 | 0.78378 | 429/1024 | 1.56755 | 627/1024 | 2.29103 |
| 15 | 2048/6435 | 1.23261 | 3667/6435 | 2.20703 | 1619/2145 | 2.92325 |
| 16 | 6435/32768 | 0.78552 | 6435/16384 | 1.57105 | 4719/8192 | 2.30420 |
| 17 | 32768/109395 | 1.23503 | 59101/109395 | 2.22752 | 1549/2145 | 2.97748 |
| 18 | 12155/65536 | 0.78689 | 12155/32768 | 1.57377 | 17875/32768 | 2.31437 |
| 19 | 65536/230945 | 1.23694 | 118917/230945 | 2.24446 | 160143/230945 | 3.02257 |
| 20 | 46189/262144 | 0.78798 | 46189/131072 | 1.57595 | 17017/32768 | 2.32246 |

**The oscillation is immediate.** For `k = 1`, the column `√n·p` alternates between two
clearly separated bands: `≈ 1.21 … 1.24` on odd `n` and `≈ 0.773 … 0.788` on even `n`.
No smoothing in `n` can reconcile them; the two bands converge to
`√(π/2) = 1.2533141…` and `√(2/π) = 0.7978846…`, whose ratio is `π/2 = 1.5707963…`.

These are the values recorded and machine-checked in the `LabNotes` section of
`Catalog/Physics/InfoFreeWerewolf/FiniteParity.lean`
(`lab_one_wolf_7_to_12`, `lab_two_wolves`, `lab_three_wolves`,
`lab_oscillation_one_wolf`, `lab_union_bound_sharpness`).

## 3. Long-ladder confirmation, k = 1 … 5

Iterating the recursion in `Float` up to `v = 20001`. Note that the relevant parity is that
of the **population** `n = v + k`, not of `v`; the table below is arranged so that this is
visible (each row is a fixed `v`, so `n` alternates parity as `k` increases).

`v = 20000`:

| k | population n | √n·p(n,k) | √n·p/k | nearest constant |
|---|---|---|---|---|
| 1 | 20001 (odd) | 1.253298 | 1.253298 | √(π/2) = 1.253314 |
| 2 | 20002 (even) | 1.595749 | 0.797875 | √(2/π) = 0.797885 |
| 3 | 20003 (odd) | 3.738684 | 1.246228 | √(π/2) |
| 4 | 20004 (even) | 3.191339 | 0.797835 | √(2/π) |
| 5 | 20005 (odd) | 6.195792 | 1.239158 | √(π/2) |

`v = 20001`:

| k | population n | √n·p(n,k) | √n·p/k | nearest constant |
|---|---|---|---|---|
| 1 | 20002 (even) | 0.797875 | 0.797875 | √(2/π) |
| 2 | 20003 (odd) | 2.499526 | 1.249763 | √(π/2) |
| 3 | 20004 (even) | 2.393584 | 0.797861 | √(2/π) |
| 4 | 20005 (odd) | 4.970773 | 1.242693 | √(π/2) |
| 5 | 20006 (even) | 3.988974 | 0.797795 | √(2/π) |

Observations:

* The even-population entries are already accurate to `10⁻⁵` in `√n·p/k`, for every `k`.
* The odd-population entries converge visibly more slowly and **from below**
  (`1.2533 → 1.2462 → 1.2392` as `k` grows at fixed `n ≈ 2·10⁴`); this is the
  `O(k²/n)` relative correction of the union bound, and it is exactly what
  `failProb_ge_union_error` quantifies (an `O(1/n)` additive defect).
* The parity-blind sequence `n ↦ √n · p(n,k)` therefore has *two* distinct subsequential
  limits and no limit at all — theorem `not_tendsto_scaled_failProb`.

## 4. Exact closed forms found and then proved

Discovered by exact `ℚ` evaluation, then formalized:

| statement | Lean name |
|---|---|
| `failProb v 1 = surv (v+1)` | `failProb_one_wolf` |
| `surv n · surv (n+1) = 1/(n+1)` | `surv_mul_succ_gen` |
| `failProb (2m) 2 = 2·surv (2m+2)` (union bound **exact**, even population) | `failProb_two_wolves_even` |
| `failProb 3 2 ≠ 2·surv 5` (fails at odd population) | `failProb_two_wolves_odd_ne` |
| `failProb (2m+1) 3 = ((6m+8)/(2m+3))·surv (2m+4)` | `failProb_three_wolves_even` |
| `failProb (2M) 4 = ((8M+8)/(2M+3))·surv (2M+4)` | `failProb_four_wolves_even` |
| `surv (2m+1) = W_m · surv (2m)` (Wallis) | `surv_eq_wallis_mul` |

The prefactors `ρ_k(m)` in the even-population closed forms
(`ρ_1 = 1`, `ρ_2 = 2`, `ρ_3 = 3 - 1/(2m+3)·1`, `ρ_4 = (8M+8)/(2M+3)`) are **rational
functions of the population increasing to `k`** — this observation is spun off as
Direction 1 in `FUTURE_DIRECTIONS.md`. The odd-population prefactors are *not* rational
functions; they carry a Wallis-type `m^{-1/2}` correction.

## 5. OEIS

For one wolf and odd population `n = 2m+1`:
`failProb (2m) 1 = surv (2m+1) = 4^m / ((2m+1)·C(2m,m))`.
For one wolf and even population `n = 2m`:
`failProb (2m-1) 1 = surv (2m) = C(2m,m)/4^m`.

* Numerators of `C(2m,m)/4^m` (in lowest terms) : `1, 1, 3, 5, 35, 63, 231, 429, 6435, 12155, …`
  — **OEIS A001790**. Visible directly in the `k = 1` column above (rows n = 8, 10, 12, 14,
  16, 18, 20 give `35/128, 63/256, 231/1024, 429/2048, 6435/32768, 12155/65536, 46189/262144`).
* The corresponding denominators `1, 2, 8, 16, 128, 256, 1024, 2048, 32768, …` are **OEIS A046161**.
* The central binomial coefficients `C(2m,m) = 1, 2, 6, 20, 70, 252, 924, …` are **A000984**.

The appearance of `C(2m,m)/4^m ~ 1/√(πm)` is precisely the source of the two constants:
`√(2m)·C(2m,m)/4^m → √(2/π)`, while the odd ladder `4^m/((2m+1)C(2m,m))` is its Wallis
reciprocal and gives `√(π/2)`.

## 6. Counterexample hunt

Universal claims tested, with no counterexample found:

All searches below were run in **exact `ℚ` arithmetic** with a memoised iterative version of
the recursion (the ranges quoted are exactly the ranges that were executed).

| claim | range tested | result |
|---|---|---|
| `failProb v k ≤ k · surv (v+k)` (union bound) | all `v ≤ 60`, `k ≤ 6` (427 pairs) | 0 violations; **proved** as `failProb_le_union` |
| `(v+k)·(k·surv(v+k) - failProb v k)` bounded in `v` | all `v ≤ 60`, `k ≤ 6` | bounded; per-`k` maxima `0, 0, 1, 3, 5.9836, 9.9206, 14.7627`; **proved** as `failProb_ge_union_error` |
| `surv (2m) ≤ surv (2m+1)` | all `m ≤ 300` | 0 violations; **proved** as `surv_even_le_odd` |
| `n·surv(n)² < 1` for even `n`, `≥ 1` for odd `n` | all `n ≤ 601` | 0 violations; **proved** as `failProb_sq_parity_even/odd` |
| `√n·failProb(n-k,k)` has a limit (parity-blind) | — | **false**; disproved as `not_tendsto_scaled_failProb` |
| `failProb (2m+1) 2 = 2·surv (2m+3)` (union bound at odd population) | `m = 1` | **false** at `failProb 3 2 = 13/15 ≠ 2·surv 5 = 16/15`; recorded as `failProb_two_wolves_odd_ne` |

The last two rows are the two negative findings of the cycle, and both are formalized as
theorems rather than left as remarks.

## 7. The second-order coefficient and the constant `C(k,2)`

Writing `defect v k = k·surv n - failProb v k` (`n = v+k`), the scaled defect `n·defect`
was evaluated exactly for `k = 2 … 7`.  The odd-population values are *rational functions
of the population*, and their limit is `C(k,2) = k(k-1)/2` in every case:

| `k` | `n·defect` at odd population `n` | limit | `C(k,2)` |
|---|---|---|---|
| 2 | `1` (constant) | 1 | 1 |
| 3 | `3` (constant) | 3 | 3 |
| 4 | `(6n-13)/(n-2)`  (`17/3, 29/5, 41/7, 53/9, …` at `n = 5,7,9,11`) | 6 | 6 |
| 5 | `(10n-25)/(n-2)` (`25/3, 9, 65/7, 85/9, …` at `n = 5,7,9,11`) | 10 | 10 |
| 6 | `(15n²-105n+183)/((n-2)(n-4))` (`61/5, 453/35, 281/21, 41/3, …`) | 15 | 15 |
| 7 | `77/5, 83/5, 157/9, 595/33, 203/11, …` | 21 (numerically) | 21 |

The even-population scaled defects are qualitatively different — they *vanish*:

| `k` | `n·defect` at even population `n` |
|---|---|
| 2 | `0` exactly |
| 3 | `surv (n-2)` exactly |
| 4 | `4 · surv (n-2)` exactly |
| 5 | `27/8, 47/16, 335/128, 609/256, …` (→ 0) |

A `Float` run of the recursion to `v = 2000` gives, at `k = 2 … 7`, odd-population scaled
defects `1.000000, 3.000000, 5.999500, 9.997504, 14.992512, 20.982549` — converging to
`1, 3, 6, 10, 15, 21` — while the even-population ones are `0, 0.0178, 0.0713, 0.178,
0.356, 0.623`, all decaying like `n^{-1/2}`.

This is the observation behind the theorem `defect_scaled_le` in
`Catalog/Physics/InfoFreeWerewolf/SharpBound.lean`:

> `n · defect v k ≤ k(k-1)/2` for **all** `v, k`,

with equality at every odd population for `k = 2` and `k = 3`
(`sharp_constant_attained_two_wolves`, `sharp_constant_attained_three_wolves`).
The search above (exact `ℚ`, `v ≤ 60`, `k ≤ 6`; `Float`, `v ≤ 2000`, `k ≤ 7`) found no
violation, and the constant `C(k,2)` is exactly the number of unordered pairs of wolves —
the first inclusion–exclusion correction to the union bound.

The exact odd-population closed forms that this suggested were then found and proved:

* `failProb (2m+1) 2 = 2·surv (2m+3) - 1/(2m+3)` (`failProb_two_wolves_odd`);
* `failProb (2m)   3 = 3·surv (2m+3) - 3/(2m+3)` (`failProb_three_wolves_odd`).

Together with `failProb_two_wolves_even` this **solves the two-wolf game exactly**
(`two_wolves_exact_solution`).

## 8. Reproducing

```
lake build InfoFreeWerewolf
```

The exact tables of §2 are re-derivable with, e.g.,

```lean
import Catalog.Physics.InfoFreeWerewolf.ParityExpansion
open InfoFreeWerewolf in
#eval (failProb 6 1, failProb 5 2, failProb 4 3)
```
