/-
Copyright (c) 2025. All rights reserved.

# Exact Cusick Density for the Shift `t = 5`: `c₅ = 5/8 ≠ 11/16 = c₃`

## Overview

Cusick's conjecture (a theorem of Drmota–Kauers–Spiegelhofer 2016) gives the
explicit lower bound `c_t ≥ 1/2 + 2^{-(2 s₂(t) + 1)}` for the asymptotic density
`c_t = dens { n : s₂(n) ≤ s₂(n + t) }`.

The catalog already computes the *exact* density for `t = 3` (`c_3 = 11/16`, file
`CusickShiftThreeDensity.lean`), the first shift with `s₂(t) = 2`.  This file
computes the exact density for the *other* small odd `s₂(t) = 2` shift, `t = 5`,
and records the central structural finding of this research cycle:

* `CusickShiftFive.cusickCount_five` — the exact finite count
  `cusickCount 5 (32m) = 20m`, hence `c_5 = 20/32 = 5/8`.  The period is
  `32 = 2^{L + s₂(5)}` with `L = 3` (`5 < 2^3`) and `s₂(5) = 2`.
* `CusickShiftFive.cusick_t5_bound` — the explicit Drmota–Kauers–Spiegelhofer
  bound holds with margin: `c_5 = 5/8 = 20/32 ≥ 17/32 = 1/2 + 2^{-(2·s₂(5)+1)}`.
* `CusickShiftFive.cusick_density_not_s2_function` — the headline comparison:
  over a common aligned window `[0, 32m)`, the `t = 5` count (`20m`) and the
  `t = 3` count (`22m`) **differ**, even though `s₂(5) = s₂(3) = 2`.  Hence the
  Cusick density `c_t` is *not* a function of `s₂(t)` alone.
* `CusickShiftFive.cusick_t5_orbit_density` — propagation along the doubling
  orbit: `c_{5·2^k} = 5/8` for every `k`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): With `c_3 = 11/16`, a naive guess is that the density
depends only on `s₂(t)`, so every `s₂(t) = 2` shift would give `11/16`.  Test the
next odd `s₂ = 2` shift `t = 5`.

Experiment (Experimenter): A scan of `n < 32·50 = 1600` shows `P_5` is purely
periodic mod `32` with exactly `20` good residues, so `c_5 = 20/32 = 5/8 = 10/16`.
This is *strictly smaller* than `c_3 = 11/16`: the naive hypothesis is FALSE.

Analysis (Analyst): Both `3 = 11₂` and `5 = 101₂` have `s₂ = 2`, but their
*carry geometry* differs — `3` has two adjacent low ones, `5` has two ones
separated by a zero.  The separated ones in `5` create an extra overflow residue
class compared with `3`, lowering the good count from `22/32` to `20/32`.  So the
fine structure of the binary expansion of `t`, not merely `s₂(t)`, governs `c_t`.
This refutes the simplest possible closed form and sharpens the search for the
true formula (see `FUTURE_DIRECTIONS.md`).

Critique (Critic): Could the discrepancy be a window-alignment artifact?  No —
both counts are taken over the *same* window `[0, 32m)` (note `32` is a common
period: `16 ∣ 32`), and both are exact for all `m` via `cusickCount_period`.  The
inequality `20m < 22m` (for `m ≥ 1`) is therefore a genuine, exact separation,
not a sampling effect.  The bound itself is non-vacuous: `5/8` clears `17/32` by
`3/32 > 0`.
-/

import Catalog.Applications.CusickPeriodicity

open Nat Finset

namespace CusickShiftFive

open CusickSumDigits CusickDensity CusickDoubling CusickShiftThree CusickPeriodicity

/-- A **computable copy** of the binary digit sum `s2` (the catalog's `s2` is
`noncomputable`), enabling kernel evaluation of the base block count. -/
def s2compute (n : ℕ) : ℕ := (Nat.digits 2 n).sum

/-- The computable copy agrees with the catalog digit sum (definitionally). -/
theorem s2compute_eq (n : ℕ) : s2compute n = s2 n := rfl

/-- `s₂(5) = 2`. -/
theorem s2_five : s2 5 = 2 := rfl

/-- **Base block count.**  Exactly `20` of the residues in `[0, 32)` satisfy the
Cusick inequality for `t = 5`: `cusickCount 5 32 = 20`. -/
theorem cusickCount_five_base : cusickCount 5 32 = 20 := by
  unfold cusickCount
  have h : ((range 32).filter (fun n => s2 n ≤ s2 (n + 5)))
      = ((range 32).filter (fun n => s2compute n ≤ s2compute (n + 5))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Exact finite Cusick density for `t = 5`.**  For every `m`,
`cusickCount 5 (32m) = 20m`, i.e. exactly `20/32 = 5/8` of the integers in any
aligned block `[0, 32m)` satisfy `s₂(n) ≤ s₂(n + 5)`.  Hence `c_5 = 5/8`. -/
theorem cusickCount_five (m : ℕ) : cusickCount 5 (32 * m) = 20 * m := by
  have h := cusickCount_period 5 3 m (by norm_num) (by norm_num)
  rw [s2_five] at h
  norm_num at h
  rw [h, cusickCount_five_base]; ring

/-- **Explicit Drmota–Kauers–Spiegelhofer bound for `t = 5`, with margin.**  Over
any aligned block `[0, 32m)` the Cusick count is at least `17/32` of the block:
`32 · cusickCount 5 (32m) ≥ 17 · (32m)`.  The actual value `5/8 = 20/32` clears
the bound `1/2 + 2^{-(2·s₂(5)+1)} = 17/32` by `3/32`. -/
theorem cusick_t5_bound (m : ℕ) :
    32 * cusickCount 5 (32 * m) ≥ 17 * (32 * m) := by
  rw [cusickCount_five]; omega

/-- **Explicit density bias for `t = 5`.**  Over the block `[0, 32m)`, whose exact
half is `16m`, the Cusick count exceeds the half by `4m`:
`cusickCount 5 (32m) = 16m + 4m`.  This is the explicit positive bias
`c_5 - 1/2 = 4/32 = 1/8`. -/
theorem cusick_t5_bias (m : ℕ) :
    cusickCount 5 (32 * m) = 16 * m + 4 * m := by
  rw [cusickCount_five]; ring

/-- **The Cusick density is not a function of `s₂(t)`.**  Although
`s₂(5) = s₂(3) = 2`, the Cusick counts over the *common* aligned window
`[0, 32m)` differ for every `m ≥ 1`:
`cusickCount 5 (32m) = 20m  <  22m = cusickCount 3 (32m)`.
(Equivalently `c_5 = 5/8 = 10/16 < 11/16 = c_3`.)  Hence no closed form
`c_t = f(s₂(t))` can exist. -/
theorem cusick_density_not_s2_function (m : ℕ) (hm : 1 ≤ m) :
    cusickCount 5 (32 * m) < cusickCount 3 (32 * m) := by
  have h5 : cusickCount 5 (32 * m) = 20 * m := cusickCount_five m
  -- `32 = 16·2`, so the `t = 3` count over `[0, 32m)` is `cusickCount 3 (16·(2m)) = 11·(2m) = 22m`.
  have h3 : cusickCount 3 (32 * m) = 22 * m := by
    have := CusickShiftThree.cusickCount_three (2 * m)
    rw [show 16 * (2 * m) = 32 * m by ring] at this
    rw [this]; ring
  rw [h5, h3]; omega

/-- **Doubling-orbit density.**  For every `k`, `cusickCount (2^k·5) (2^k·32m) =
2^k·20m`, i.e. the Cusick density along the orbit `{5, 10, 20, 40, …}` is
constantly `5/8`.  Combines `cusickCount_five` with `cusickCount_two_pow_mul`. -/
theorem cusick_t5_orbit_density (k m : ℕ) :
    cusickCount (2 ^ k * 5) (2 ^ k * (32 * m)) = 2 ^ k * (20 * m) := by
  rw [cusickCount_two_pow_mul, cusickCount_five]

end CusickShiftFive