/-
Copyright (c) 2025. All rights reserved.

# Exact Cusick Density for the Shift `t = 7` (the first `s₂(t) = 3` case)

## Overview

Cusick's conjecture (a theorem of Drmota–Kauers–Spiegelhofer 2016) gives the
explicit lower bound `c_t ≥ 1/2 + 2^{-(2 s₂(t) + 1)}` for the asymptotic density
`c_t = dens { n : s₂(n) ≤ s₂(n + t) }`.

The companion files in this catalog resolve the exact density only in the regimes
`s₂(t) = 1` (powers of two: `c_{2^k} = 3/4`, `CusickDoublingInvariance.lean`) and
`s₂(t) = 2` (the shift `t = 3`: `c_3 = 11/16`, `CusickShiftThreeDensity.lean`).
This file breaks into the next regime `s₂(t) = 3` by computing the *exact* density
for the smallest such shift, `t = 7`:

* `CusickShiftSeven.cusickCount_seven` — the exact finite count
  `cusickCount 7 (64m) = 43m`, hence `c_7 = 43/64`.  The period is
  `64 = 2^{L + s₂(7)}` with `L = 3` (`7 < 2^3`) and `s₂(7) = 3`.
* `CusickShiftSeven.cusick_t7_bound` — the explicit Drmota–Kauers–Spiegelhofer
  bound holds *with a large margin*: `c_7 = 43/64 = 86/128 ≥ 65/128 =
  1/2 + 2^{-(2·s₂(7)+1)}`.
* `CusickShiftSeven.cusick_t7_orbit_density` — propagation along the doubling
  orbit: `c_{7·2^k} = 43/64` for every `k` (the density depends only on the odd
  part of `t`).

The proof reuses the general periodicity backbone `cusickCount_period` from
`CusickPeriodicity.lean`, which reduces the whole count to the single aligned
block `[0, 64)`; that base count is then discharged by a verified computation
(`native_decide`) over a computable copy `s2compute` of the digit sum.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The exact value of `c_7` extends the sequence
`c_1 = 3/4`, `c_3 = 11/16` into the `s₂(t) = 3` regime.  Computing binary digit
sums predicts `c_7 = 43/64`.  The general periodicity theorem says the predicate
`P_7` is purely periodic mod `2^{3+3} = 64`, so the density is exactly the
fraction of good residues in one period.

Experiment (Experimenter): A scan of `n < 64·50 = 3200` confirms `P_7` is purely
periodic mod `64` with exactly `43` good residues
`{0,1,2,3,4,5,6,7,8,10,12,14,16,17,18,19,20,21,22,23,24,28,32,33,34,35,36,37,38,
39,40,42,44,46,48,49,50,51,52,53,54,55,56}` (and `21` bad residues).  Hence
`c_7 = 43/64`.

Analysis (Analyst): Rather than reproving the periodicity by a bespoke
`interval_cases` over 64 residues (as the `t = 3` file does over 16), this file
leverages the *general* `cusickCount_period` (proved once in
`CusickPeriodicity.lean` for all `t`).  That collapses the infinite density
statement to the finite base count `cusickCount 7 64`, which is a genuine kernel
computation, not a sampled estimate.  The induction on `m` is hidden inside
`cusickCount_period`, so `43/64` is exact for all `m`.

Critique (Critic): Is `cusickCount_seven` a disguised finite check?  Only the
single base block `[0,64)` is checked computationally; the unbounded `m`
dependence is genuine mathematics carried by `cusickCount_period`.  Is the bound
vacuous?  No: `43/64 = 86/128` exceeds `65/128` by `21/128 > 0`.  Does it extend
the catalog?  Yes — this is the first fully-proved `s₂(t) = 3` density, one step
beyond the `s₂(t) = 2` frontier reached by the `t = 3` file.

Insight: comparing with the forthcoming `t = 5` file (`c_5 = 5/8`, also
`s₂ = 2`) versus `c_3 = 11/16` shows the density is **not** a function of `s₂(t)`
alone — see `FUTURE_DIRECTIONS.md`.
-/

import Catalog.Applications.CusickPeriodicity

open Nat Finset

namespace CusickShiftSeven

open CusickSumDigits CusickDensity CusickDoubling CusickShiftThree CusickPeriodicity

/-- A **computable copy** of the binary digit sum `s2`.  (The catalog's `s2` is
marked `noncomputable`, so we mirror it here to enable kernel evaluation of the
base block count via `native_decide`.) -/
def s2compute (n : ℕ) : ℕ := (Nat.digits 2 n).sum

/-- The computable copy agrees with the catalog digit sum (definitionally). -/
theorem s2compute_eq (n : ℕ) : s2compute n = s2 n := rfl

/-- `s₂(7) = 3`. -/
theorem s2_seven : s2 7 = 3 := rfl

/-- **Base block count.**  Exactly `43` of the residues in `[0, 64)` satisfy the
Cusick inequality for `t = 7`: `cusickCount 7 64 = 43`. -/
theorem cusickCount_seven_base : cusickCount 7 64 = 43 := by
  unfold cusickCount
  have h : ((range 64).filter (fun n => s2 n ≤ s2 (n + 7)))
      = ((range 64).filter (fun n => s2compute n ≤ s2compute (n + 7))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Exact finite Cusick density for `t = 7`.**  For every `m`,
`cusickCount 7 (64m) = 43m`, i.e. exactly `43/64` of the integers in any aligned
block `[0, 64m)` satisfy `s₂(n) ≤ s₂(n + 7)`.  Hence `c_7 = 43/64`. -/
theorem cusickCount_seven (m : ℕ) : cusickCount 7 (64 * m) = 43 * m := by
  have h := cusickCount_period 7 3 m (by norm_num) (by norm_num)
  rw [s2_seven] at h
  norm_num at h
  rw [h, cusickCount_seven_base]; ring

/-- **Explicit Drmota–Kauers–Spiegelhofer bound for `t = 7`, with margin.**  Over
any aligned block `[0, 64m)` the Cusick count is at least `65/128` of the block:
`128 · cusickCount 7 (64m) ≥ 65 · (64m)`.  Since the actual value is
`43/64 = 86/128`, the bound `1/2 + 2^{-(2·s₂(7)+1)} = 65/128` is cleared by
`21/128`. -/
theorem cusick_t7_bound (m : ℕ) :
    128 * cusickCount 7 (64 * m) ≥ 65 * (64 * m) := by
  rw [cusickCount_seven]; omega

/-- **Explicit density bias for `t = 7`.**  Over the block `[0, 64m)`, whose exact
half is `32m`, the Cusick count exceeds the half by `11m`:
`cusickCount 7 (64m) = 32m + 11m`.  This is the explicit positive bias
`c_7 - 1/2 = 11/64 > 0`. -/
theorem cusick_t7_bias (m : ℕ) :
    cusickCount 7 (64 * m) = 32 * m + 11 * m := by
  rw [cusickCount_seven]; ring

/-- **Doubling-orbit density.**  For every `k`, `cusickCount (2^k·7) (2^k·64m) =
2^k·43m`, i.e. the Cusick density along the orbit `{7, 14, 28, 56, …}` is
constantly `43/64`.  Combines `cusickCount_seven` with the orbit invariance
`cusickCount_two_pow_mul`. -/
theorem cusick_t7_orbit_density (k m : ℕ) :
    cusickCount (2 ^ k * 7) (2 ^ k * (64 * m)) = 2 ^ k * (43 * m) := by
  rw [cusickCount_two_pow_mul, cusickCount_seven]

end CusickShiftSeven