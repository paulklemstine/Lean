/-
Copyright (c) 2025. All rights reserved.

# Equal Cusick Densities for Binary Digit-Reversal Pairs

## Overview

Cusick's density `c_t = dens { n : s₂(n) ≤ s₂(n + t) }` is a dyadic rational with
denominator `2^{L + s₂(t)}` (`t < 2^L`), by the pure periodicity established in
`CusickPeriodicity` (`cusick_periodic`, `cusickCount_period`).

This file records a small but striking coincidence in the data: the Cusick
densities of certain *binary digit-reversal pairs* coincide exactly.

* `19 = 10011₂` and `25 = 11001₂` are reverses of one another (both have
  `s₂ = 3`, both `< 2^5`, hence both have fundamental period `2^{5+3} = 256`).
  Their per-period Cusick counts are both `164`, so `c_19 = c_25 = 164/256 =
  41/64`.
* `23 = 10111₂` and `29 = 11101₂` are reverses of one another (both have
  `s₂ = 4`, both `< 2^5`, hence both have fundamental period `2^{5+4} = 512`).
  Their per-period Cusick counts are both `300`, so `c_23 = c_29 = 300/512 =
  75/128`.

The two base blocks `[0, 256)` and `[0, 512)` are kernel computations
(`native_decide`); the unbounded `m`-dependence is supplied by the general
`CusickPeriodicity.cusickCount_period`.

* `CusickDigitReversal.cusick_density_19_eq_25` — `cusickCount 19 (256 m) =
  cusickCount 25 (256 m)` for every `m`.
* `CusickDigitReversal.cusick_density_23_eq_29` — `cusickCount 23 (512 m) =
  cusickCount 29 (512 m)` for every `m`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Reversing the binary digits of `t` preserves `s₂(t)`
and the bit-length, hence the period; perhaps it also preserves the Cusick
density.

Experiment (Experimenter): For the reversal pairs `(19, 25)` and `(23, 29)` a scan
of the base block confirms equal per-period counts (`164` and `300`
respectively), so the densities are equal on each pair.

Analysis (Analyst): Only the two base blocks `[0, 256)`, `[0, 512)` are checked;
equality over all aligned blocks `[0, 256 m)`, `[0, 512 m)` is genuine via
`cusickCount_period`.
-/

import Catalog.Applications.CusickPeriodicity

open Nat Finset

namespace CusickDigitReversal

open CusickSumDigits CusickDensity CusickDoubling CusickShiftThree CusickPeriodicity

/-- A **computable copy** of the binary digit sum `s2` (the catalog's `s2` is
`noncomputable`), enabling kernel evaluation of the base block counts. -/
def s2compute (n : ℕ) : ℕ := (Nat.digits 2 n).sum

/-- The computable copy agrees with the catalog digit sum (definitionally). -/
theorem s2compute_eq (n : ℕ) : s2compute n = s2 n := rfl

/-- `s₂(19) = 3`. -/
theorem s2_nineteen : s2 19 = 3 := rfl

/-- `s₂(25) = 3`. -/
theorem s2_twentyfive : s2 25 = 3 := rfl

/-- `s₂(23) = 4`. -/
theorem s2_twentythree : s2 23 = 4 := rfl

/-- `s₂(29) = 4`. -/
theorem s2_twentynine : s2 29 = 4 := rfl

/-- **Base block count for `t = 19`.**  Exactly `164` of the residues in
`[0, 256)` satisfy the Cusick inequality for `t = 19`. -/
theorem cusickCount_nineteen_base : cusickCount 19 256 = 164 := by
  unfold cusickCount
  have h : ((range 256).filter (fun n => s2 n ≤ s2 (n + 19)))
      = ((range 256).filter (fun n => s2compute n ≤ s2compute (n + 19))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Base block count for `t = 25`.**  Exactly `164` of the residues in
`[0, 256)` satisfy the Cusick inequality for `t = 25`. -/
theorem cusickCount_twentyfive_base : cusickCount 25 256 = 164 := by
  unfold cusickCount
  have h : ((range 256).filter (fun n => s2 n ≤ s2 (n + 25)))
      = ((range 256).filter (fun n => s2compute n ≤ s2compute (n + 25))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Base block count for `t = 23`.**  Exactly `300` of the residues in
`[0, 512)` satisfy the Cusick inequality for `t = 23`. -/
theorem cusickCount_twentythree_base : cusickCount 23 512 = 300 := by
  unfold cusickCount
  have h : ((range 512).filter (fun n => s2 n ≤ s2 (n + 23)))
      = ((range 512).filter (fun n => s2compute n ≤ s2compute (n + 23))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Base block count for `t = 29`.**  Exactly `300` of the residues in
`[0, 512)` satisfy the Cusick inequality for `t = 29`. -/
theorem cusickCount_twentynine_base : cusickCount 29 512 = 300 := by
  unfold cusickCount
  have h : ((range 512).filter (fun n => s2 n ≤ s2 (n + 29)))
      = ((range 512).filter (fun n => s2compute n ≤ s2compute (n + 29))) := by
    apply Finset.filter_congr; intro n _; simp only [s2compute_eq]
  rw [h]; native_decide

/-- **Exact finite Cusick count for `t = 19`.**  For every `m`,
`cusickCount 19 (256 m) = 164 m`. -/
theorem cusickCount_nineteen (m : ℕ) : cusickCount 19 (256 * m) = 164 * m := by
  have h := cusickCount_period 19 5 m (by norm_num) (by norm_num)
  rw [s2_nineteen] at h
  norm_num at h
  rw [h, cusickCount_nineteen_base]; ring

/-- **Exact finite Cusick count for `t = 25`.**  For every `m`,
`cusickCount 25 (256 m) = 164 m`. -/
theorem cusickCount_twentyfive (m : ℕ) : cusickCount 25 (256 * m) = 164 * m := by
  have h := cusickCount_period 25 5 m (by norm_num) (by norm_num)
  rw [s2_twentyfive] at h
  norm_num at h
  rw [h, cusickCount_twentyfive_base]; ring

/-- **Exact finite Cusick count for `t = 23`.**  For every `m`,
`cusickCount 23 (512 m) = 300 m`. -/
theorem cusickCount_twentythree (m : ℕ) : cusickCount 23 (512 * m) = 300 * m := by
  have h := cusickCount_period 23 5 m (by norm_num) (by norm_num)
  rw [s2_twentythree] at h
  norm_num at h
  rw [h, cusickCount_twentythree_base]; ring

/-- **Exact finite Cusick count for `t = 29`.**  For every `m`,
`cusickCount 29 (512 m) = 300 m`. -/
theorem cusickCount_twentynine (m : ℕ) : cusickCount 29 (512 * m) = 300 * m := by
  have h := cusickCount_period 29 5 m (by norm_num) (by norm_num)
  rw [s2_twentynine] at h
  norm_num at h
  rw [h, cusickCount_twentynine_base]; ring

/-- **Equal Cusick densities for the reversal pair `(19, 25)`.**  Since `25` is the
binary digit-reversal of `19`, they share the period `256` and have equal
per-period count; hence over every aligned block `[0, 256 m)` the Cusick counts
agree: `cusickCount 19 (256 m) = cusickCount 25 (256 m)`.  In particular
`c_19 = c_25 = 164/256`. -/
theorem cusick_density_19_eq_25 (m : ℕ) :
    cusickCount 19 (256 * m) = cusickCount 25 (256 * m) := by
  rw [cusickCount_nineteen, cusickCount_twentyfive]

/-- **Equal Cusick densities for the reversal pair `(23, 29)`.**  Since `29` is the
binary digit-reversal of `23`, they share the period `512` and have equal
per-period count; hence over every aligned block `[0, 512 m)` the Cusick counts
agree: `cusickCount 23 (512 m) = cusickCount 29 (512 m)`.  In particular
`c_23 = c_29 = 300/512`. -/
theorem cusick_density_23_eq_29 (m : ℕ) :
    cusickCount 23 (512 * m) = cusickCount 29 (512 * m) := by
  rw [cusickCount_twentythree, cusickCount_twentynine]

end CusickDigitReversal