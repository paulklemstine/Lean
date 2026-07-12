/-
Copyright (c) 2025. All rights reserved.

# Exact Cusick Density for the All-Ones Shift `t = 15`: `c₁₅ = 171/256`

## Overview

Cusick's conjecture (a theorem of Drmota–Kauers–Spiegelhofer 2016) gives the
explicit lower bound `c_t ≥ 1/2 + 2^{-(2 s₂(t) + 1)}` for the asymptotic density
`c_t = dens { n : s₂(n) ≤ s₂(n + t) }`.

This file continues the **all-ones family** `t = 2^s − 1` (`1, 3, 7, 15, …`),
whose exact densities are computed elsewhere in the catalog for `s = 1, 2, 3`
(`c_1 = 3/4`, `c_3 = 11/16`, `c_7 = 43/64`).  Here we resolve the `s = 4` case:

* `CusickShiftFifteen.cusickCount_fifteen` — the exact finite count
  `cusickCount 15 (256m) = 171m`, hence `c_15 = 171/256`.  The period is
  `256 = 2^{L + s₂(15)}` with `L = 4` (`15 < 2^4`) and `s₂(15) = 4`.
* `CusickShiftFifteen.cusick_t15_bound` — the explicit Drmota–Kauers–Spiegelhofer
  bound holds with an enormous margin: `c_15 = 171/256 = 684/1024 ≥ 513/1024 =
  1/2 + 2^{-(2·s₂(15)+1)}`.
* `CusickShiftFifteen.cusick_t15_orbit_density` — `c_{15·2^k} = 171/256` for all `k`.

## The all-ones recurrence

Writing `c_{2^s−1} = 1/2 + a_s / 4^s`, the proved values give bias numerators
`a_1 = 1, a_2 = 3, a_3 = 11, a_4 = 43` (here `a_4 = 171 − 128 = 43`, since the
per-period count `171` exceeds the half `128` by `43`), matching the conjectured
linear recurrence `a_{s+1} = 4 a_s − 1`.  Equivalently the per-period **counts**
`3, 11, 43, 171` (over periods `4, 16, 64, 256`) each satisfy `next = 4·prev − 1`.
See `FUTURE_DIRECTIONS.md`, Conjecture 5.  This file pins the `s = 4` data point
(`count = 171`, bias `a_4 = 43`) as a theorem.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The all-ones densities follow a clean rule; the next
data point should be `c_15 = 171/256`, with `171 = 4·43 − 1` continuing the
pattern `1, 3, 11, 43, 171` (each `= 4·prev − 1`).

Experiment (Experimenter): A scan of `n < 256·20` confirms `P_15` is purely
periodic mod `256` with exactly `171` good residues, so `c_15 = 171/256`.  The
prediction is confirmed exactly.

Analysis (Analyst): As with `t = 7`, the unbounded `m`-dependence is supplied by
the general `cusickCount_period`, and only the single base block `[0,256)` is a
kernel computation (`native_decide`).  Four proved all-ones values
(`s = 1,2,3,4`) now pin the recurrence `a_{s+1} = 4 a_s − 1` at four points;
`c_31 = 683/1024` (`a_6 = 683 = 4·171 − 1`) is the next predicted check.

Critique (Critic): Finite check or real theorem?  Only `[0,256)` is checked; the
density over all `[0,256m)` is genuine via periodicity.  Bound vacuous?  No — the
margin over DKS is `171/256 − 513/1024 = 171/256 − 0.5009… ≈ 0.17`.
-/

import Applications.CusickPeriodicity

open Nat Finset

namespace CusickShiftFifteen

open CusickSumDigits CusickDensity CusickDoubling CusickShiftThree CusickPeriodicity

/-- A **computable copy** of the binary digit sum `s2` (the catalog's `s2` is
`noncomputable`), enabling kernel evaluation of the base block count. -/
def s2compute (n : ℕ) : ℕ := (Nat.digits 2 n).sum

/-- The computable copy agrees with the catalog digit sum (definitionally). -/
theorem s2compute_eq (n : ℕ) : s2compute n = s2 n := rfl

/-- `s₂(15) = 4`. -/
theorem s2_fifteen : s2 15 = 4 := rfl

/-- **Base block count.**  Exactly `171` of the residues in `[0, 256)` satisfy the
Cusick inequality for `t = 15`: `cusickCount 15 256 = 171`. -/
theorem cusickCount_fifteen_base : cusickCount 15 256 = 171 := by
  unfold cusickCount
  have h : ((range 256).filter (fun n => s2 n ≤ s2 (n + 15)))
      = ((range 256).filter (fun n => s2compute n ≤ s2compute (n + 15))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Exact finite Cusick density for `t = 15`.**  For every `m`,
`cusickCount 15 (256m) = 171m`, i.e. exactly `171/256` of the integers in any
aligned block `[0, 256m)` satisfy `s₂(n) ≤ s₂(n + 15)`.  Hence `c_15 = 171/256`. -/
theorem cusickCount_fifteen (m : ℕ) : cusickCount 15 (256 * m) = 171 * m := by
  have h := cusickCount_period 15 4 m (by norm_num) (by norm_num)
  rw [s2_fifteen] at h
  norm_num at h
  rw [h, cusickCount_fifteen_base]; ring

/-- **Explicit Drmota–Kauers–Spiegelhofer bound for `t = 15`, with margin.**  Over
any aligned block `[0, 256m)` the Cusick count is at least `513/1024` of the
block: `1024 · cusickCount 15 (256m) ≥ 513 · (256m)`.  The actual value
`171/256 = 684/1024` clears `1/2 + 2^{-(2·s₂(15)+1)} = 513/1024` by `171/1024`. -/
theorem cusick_t15_bound (m : ℕ) :
    1024 * cusickCount 15 (256 * m) ≥ 513 * (256 * m) := by
  rw [cusickCount_fifteen]; omega

/-- **Explicit density bias for `t = 15`.**  Over the block `[0, 256m)`, whose
exact half is `128m`, the Cusick count exceeds the half by `43m`:
`cusickCount 15 (256m) = 128m + 43m`.  This is the explicit positive bias
`c_15 − 1/2 = 43/256`, the `a_4 = 43` numerator of the all-ones recurrence. -/
theorem cusick_t15_bias (m : ℕ) :
    cusickCount 15 (256 * m) = 128 * m + 43 * m := by
  rw [cusickCount_fifteen]; ring

/-- **Doubling-orbit density.**  For every `k`, `cusickCount (2^k·15) (2^k·256m) =
2^k·171m`, i.e. the Cusick density along the orbit `{15, 30, 60, …}` is constantly
`171/256`. -/
theorem cusick_t15_orbit_density (k m : ℕ) :
    cusickCount (2 ^ k * 15) (2 ^ k * (256 * m)) = 2 ^ k * (171 * m) := by
  rw [cusickCount_two_pow_mul, cusickCount_fifteen]

end CusickShiftFifteen