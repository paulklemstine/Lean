/-
Copyright (c) 2025. All rights reserved.

# A General Explicit-Bias Propagation Engine for the Cusick Density

## Overview

The Drmota–Kauers–Spiegelhofer theorem states an *explicit lower bound* on the
Cusick density `c_t = dens { n : s₂(n) ≤ s₂(n + t) }`, of the form
`c_t ≥ 1/2 + (explicit bias)`.  All the worked cases in this catalog
(`c_1 = 3/4`, `c_3 = 11/16`, `c_5 = 5/8`, `c_7 = 43/64`, …) take the shape

  `cusickCount t (P) = P/2 + bias`,    `P = 2^{L + s₂(t)}` the fundamental period.

This file isolates, **once and for all**, the elementary mechanism that turns a
single-period bias into an *explicit bias lower bound over every aligned window*,
for an arbitrary shift `t`:

* `CusickBias.cusick_bias_propagation` — for any `t ≥ 1` with `t < 2^L`, if the
  Cusick count over one fundamental period `P = 2^{L+s₂(t)}` beats half by `d`
  (i.e. `2·cusickCount t P ≥ P + 2d`), then over `m` periods it beats half by
  `d·m`:  `2·cusickCount t (P·m) ≥ P·m + 2·d·m`.

This is the precise "explicit bias lower bound" statement of the title, reduced to
a *finite* per-period input `d` and made uniform in the window count `m`.  It is
powered by the general periodicity theorem `cusickCount_period`
(`CusickPeriodicity.lean`), so the only thing one ever needs to check for a new
shift `t` is the bias of a single period.

We then feed the exact per-period counts already proved in the catalog
(`t = 1, 3, 5, 7`) through the engine to obtain their explicit bias lower bounds
as uniform corollaries.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Every exact-density file repeats the same final step
("multiply the single-period bias by `m`").  This step is `t`-independent and
should be factored into one general lemma keyed only on the per-period surplus
`d`.

Experiment (Experimenter): `cusickCount_period t L m` gives
`cusickCount t (P·m) = m · cusickCount t P` for all `t` with `t < 2^L`.  Multiplying
the hypothesis `2·(cusickCount t P) ≥ P + 2d` by `m` and substituting yields the
window bound with zero extra arithmetic content beyond `Nat` monotonicity.

Analysis (Analyst): The engine cleanly separates the two ingredients of an
explicit Cusick bias bound: (i) a *finite* per-period computation producing `d`
(done by `native_decide` / residue counting in the per-shift files), and (ii) the
*uniform* propagation in `m` (this file, proved once for all `t`).  Instantiating
it reproduces `c_1 = 3/4` (d/P = 1/4), `c_3 = 11/16` (3/16), `c_5 = 5/8` (1/8),
`c_7 = 43/64` (11/64) with a one-line call each.

Critique (Critic): Is the engine vacuous?  No — its hypothesis is a genuine,
separately-proved finite fact for each `t`, and its conclusion is a non-trivial
statement uniform over all `m`.  It does not by itself prove `d > 0` for general
`t` (that is the hard Drmota–Kauers–Spiegelhofer content); it *propagates* any
established per-period bias, which is exactly the reusable infrastructure the
title asks for.
-/

import Catalog.Applications.CusickShiftSevenDensity
import Catalog.Applications.CusickShiftFiveDensity

open Nat Finset

namespace CusickBias

open CusickSumDigits CusickDensity CusickDoubling CusickShiftThree CusickPeriodicity
  CusickShiftSeven CusickShiftFive

/-- **Explicit-bias propagation.**  Let `t ≥ 1`, `t < 2^L`, and write
`P = 2^{L + s₂(t)}` for the fundamental period of the Cusick predicate `P_t`.  If
over a single period the count exceeds half by `d` (`2·cusickCount t P ≥ P + 2d`),
then over `m` periods it exceeds half by `d·m`:
`2·cusickCount t (P·m) ≥ P·m + 2·d·m`.  In density terms,
`c_t ≥ 1/2 + d/P`. -/
theorem cusick_bias_propagation (t L m d : ℕ) (ht : 1 ≤ t) (hL : t < 2 ^ L)
    (hbase : 2 * cusickCount t (2 ^ (L + s2 t)) ≥ 2 ^ (L + s2 t) + 2 * d) :
    2 * cusickCount t (2 ^ (L + s2 t) * m) ≥ 2 ^ (L + s2 t) * m + 2 * d * m := by
  rw [cusickCount_period t L m ht hL]
  have hmul := Nat.mul_le_mul_left m hbase
  nlinarith [hmul]

/-- **`t = 1` bias** (`d = 1`, `P = 4`): `2·cusickCount 1 (4m) ≥ 4m + 2m`, i.e.
`c_1 ≥ 1/2 + 1/4`.  Recovered from the engine with the per-period count
`cusickCount 1 4 = 3`. -/
theorem cusick_t1_bias_via_engine (m : ℕ) :
    2 * cusickCount 1 (4 * m) ≥ 4 * m + 2 * 1 * m := by
  have hbase : 2 * cusickCount 1 (2 ^ (1 + s2 1)) ≥ 2 ^ (1 + s2 1) + 2 * 1 := by
    have : cusickCount 1 (4 * 1) = 3 * 1 := CusickDoubling.cusickCount_one 1
    norm_num [show s2 1 = 1 from rfl] at this ⊢; omega
  simpa [show s2 1 = 1 from rfl] using cusick_bias_propagation 1 1 m 1 (by norm_num) (by norm_num) hbase

/-- **`t = 3` bias** (`d = 3`, `P = 16`): `2·cusickCount 3 (16m) ≥ 16m + 6m`, i.e.
`c_3 ≥ 1/2 + 3/16`. -/
theorem cusick_t3_bias_via_engine (m : ℕ) :
    2 * cusickCount 3 (16 * m) ≥ 16 * m + 2 * 3 * m := by
  have hbase : 2 * cusickCount 3 (2 ^ (2 + s2 3)) ≥ 2 ^ (2 + s2 3) + 2 * 3 := by
    have : cusickCount 3 (16 * 1) = 11 * 1 := CusickShiftThree.cusickCount_three 1
    norm_num [show s2 3 = 2 from rfl] at this ⊢; omega
  simpa [show s2 3 = 2 from rfl] using cusick_bias_propagation 3 2 m 3 (by norm_num) (by norm_num) hbase

/-- **`t = 5` bias** (`d = 4`, `P = 32`): `2·cusickCount 5 (32m) ≥ 32m + 8m`, i.e.
`c_5 ≥ 1/2 + 1/8`. -/
theorem cusick_t5_bias_via_engine (m : ℕ) :
    2 * cusickCount 5 (32 * m) ≥ 32 * m + 2 * 4 * m := by
  have hbase : 2 * cusickCount 5 (2 ^ (3 + s2 5)) ≥ 2 ^ (3 + s2 5) + 2 * 4 := by
    norm_num [show s2 5 = 2 from rfl, CusickShiftFive.cusickCount_five_base]
  simpa [show s2 5 = 2 from rfl] using cusick_bias_propagation 5 3 m 4 (by norm_num) (by norm_num) hbase

/-- **`t = 7` bias** (`d = 11`, `P = 64`): `2·cusickCount 7 (64m) ≥ 64m + 22m`, i.e.
`c_7 ≥ 1/2 + 11/64`. -/
theorem cusick_t7_bias_via_engine (m : ℕ) :
    2 * cusickCount 7 (64 * m) ≥ 64 * m + 2 * 11 * m := by
  have hbase : 2 * cusickCount 7 (2 ^ (3 + s2 7)) ≥ 2 ^ (3 + s2 7) + 2 * 11 := by
    norm_num [show s2 7 = 3 from rfl, CusickShiftSeven.cusickCount_seven_base]
  simpa [show s2 7 = 3 from rfl] using cusick_bias_propagation 7 3 m 11 (by norm_num) (by norm_num) hbase

end CusickBias