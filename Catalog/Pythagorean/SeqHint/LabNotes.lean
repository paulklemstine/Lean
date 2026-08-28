import Pythagorean.SeqHint.Battery
import Pythagorean.SeqHint.Adaptive

/-!
# Sequential hint pricing VIII: lab notes — the exhaustive small-case sweeps

The general theorems of this group are proved for arbitrary windows and
arbitrary batteries.  This file pins down the *exhaustive enumerations* that
motivated them, so the data itself is machine-checked (by kernel evaluation, not
by trusting a script).

Sweep 1 — window `[0, 16)`, **all** `1820` fixed batteries of `4` thresholds:
every single one leaves a class of at least `4` indistinguishable candidates.
The general bound `#W / (k + 1) = 16 / 5 = 3` is therefore attained up to the
ceiling, and the linear law is tight, not merely an upper bound
(`fixed_battery_sweep_16`).

Sweep 2 — the same window, adaptive: `4` bisection queries isolate **every**
candidate (`adaptive_sweep_16`).  Premium `4 / 1 = 4` at `k = 4`, against the
idealized `premium 4 = 16 / 5 = 3.2` lower bound on the gap.

Sweep 3 — window `[0, 8)`, all `56` batteries of `3` thresholds: the best
achievable worst-case class is `2 = 8 / 4`, again matching `#W / (k + 1)`
(`fixed_battery_sweep_8_optimum`), witnessed by the equally spaced battery
`{1, 3, 5}`.

Residual-width tables produced by the same evaluation (see
`ComputationalEvidence.md`):

| `k`                                | 0    | 1   | 2   | 3   | 6    | 9  | 12 | 20 |
|------------------------------------|------|-----|-----|-----|------|----|----|----|
| `halfIter k 1048576` (2^20 window) |2^20|2^19|2^18|2^17|2^14|2^11|2^8| 1  |
| `halfIter k 3600` (balanced)       |3600 |1800| 900 | 450 | 57   | 8  | 1  | 1  |
-/

set_option maxRecDepth 40000

namespace Pythagorean.SeqHint

open Finset

/-- **Sweep 1.**  Every one of the `4`-threshold fixed batteries on the window
`[0, 16)` leaves at least `4` candidates tied — the linear pricing law is tight
on this window. -/
theorem fixed_battery_sweep_16 :
    ∀ T ∈ (range 16).powerset.filter (fun T => T.card = 4),
      ∃ v ∈ range 5, 4 ≤ (cls T (range 16) v).card := by
  decide +kernel

/-- **Sweep 2.**  On the same window `4` *adaptive* queries isolate every
candidate: residual class size `1`, against `4` for every fixed battery. -/
theorem adaptive_sweep_16 :
    ∀ x ∈ range 16, (bisect x 4 ⟨0, 16⟩).carrier = {x} := by
  decide +kernel

/-- **Sweep 3.**  On the window `[0, 8)` the equally spaced `3`-threshold
battery attains the bound `#W / (k + 1) = 2`, and no `3`-threshold battery does
better. -/
theorem fixed_battery_sweep_8_optimum :
    (∀ v ∈ range 4, (cls {1, 3, 5} (range 8) v).card ≤ 2) ∧
    (∀ T ∈ (range 8).powerset.filter (fun T => T.card = 3),
      ∃ v ∈ range 4, 2 ≤ (cls T (range 8) v).card) := by
  constructor <;> decide +kernel

end Pythagorean.SeqHint