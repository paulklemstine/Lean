/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The parity gap between the proved and the necessary threshold for ex(n, K_{a,b}, K_{3,t})

The Janzer–Longbrake–Yepremyan theorem establishes `ex(n, K_{a,b}, K_{3,t}) = Θ(n^3)` for
`t ≥ 2·max{3, ⌈b/2⌉} + 1`.  The cubic *upper* bound (formalized in
`GenTuranK3tUpperBound.lean`) holds already at the conjectured **necessary** threshold
`t = b + 1`.  This file pins down, with exact arithmetic, the gap between the two thresholds:

* it is `0` exactly when `b` is even (so the proved threshold already meets the necessary one),
* it is `1` exactly when `b` is odd (the only remaining gap, which the conjecture claims is
  illusory).

We work over `ℕ` with `⌈b/2⌉ = (b+1)/2`.

## Catalog connections
* `Janzer-Longbrake-Yepremyan theorem for ex(n,K_{a,b},K_{3,t})`: `paperThreshold` is their
  hypothesis `2·max{3, ⌈b/2⌉}+1`.
* The leading constant in `GenTuranK3tUpperBound.KabCopies_cubic_of_K3tFree` collapses at the
  necessary threshold, recorded here in `cubic_constant_at_threshold`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The proved threshold `2·max{3,⌈b/2⌉}+1` and the necessary threshold
  `b+1` differ by exactly the parity of `b` (for `b ≥ 6`).
Experiment (Experimenter): Reduced the ceiling/`max` expression over `ℕ` to a single closed form
  `paperThreshold b = b + 1 + b % 2` (`b ≥ 6`), discharged by `omega`, then specialized to even
  and odd `b`.
Analysis (Analyst): The `max{3, ⋯}` clause is inert once `b ≥ 6` (since `⌈b/2⌉ ≥ 3`), so the gap
  is governed purely by whether doubling `⌈b/2⌉` recovers `b` (even) or overshoots by one (odd).
Critique (Critic): The closed form would be *false* for small `b` (e.g. `b ≤ 4`, where the `max`
  clause dominates), so the `6 ≤ b` guard is load-bearing and kept explicit.  No statement is
  vacuous; `necessary_lt_paper_iff_odd` is a genuine `↔`.
Synthesis (PI): The odd case is the unique frontier; closing it is exactly the stated conjecture.
-/
import Mathlib

namespace GenTuranK3t

/-- The threshold under which Janzer–Longbrake–Yepremyan prove `ex(n,K_{a,b},K_{3,t}) = Θ(n^3)`:
`t ≥ 2·max{3, ⌈b/2⌉} + 1`, with `⌈b/2⌉ = (b+1)/2` over `ℕ`. -/
def paperThreshold (b : ℕ) : ℕ := 2 * max 3 ((b + 1) / 2) + 1

/-- The conjectured necessary threshold: `t ≥ b + 1` (equivalently `b ≤ t - 1`, so that
`K_{a,b}` can be `K_{3,t}`-free). -/
def necessaryThreshold (b : ℕ) : ℕ := b + 1

/-- **Closed form.** For `b ≥ 6` the proved threshold is `b + 1 + (b mod 2)`. -/
theorem paperThreshold_eq (b : ℕ) (hb : 6 ≤ b) :
    paperThreshold b = b + 1 + b % 2 := by
  unfold paperThreshold; omega

/-- For even `b ≥ 6` the proved threshold already equals the necessary threshold `b + 1`. -/
theorem paperThreshold_even (b : ℕ) (hb : 6 ≤ b) (he : Even b) :
    paperThreshold b = necessaryThreshold b := by
  unfold necessaryThreshold
  rw [paperThreshold_eq b hb]
  obtain ⟨k, rfl⟩ := he
  omega

/-- For odd `b ≥ 6` the proved threshold is `b + 2`, one above the necessary threshold. -/
theorem paperThreshold_odd (b : ℕ) (hb : 6 ≤ b) (ho : Odd b) :
    paperThreshold b = necessaryThreshold b + 1 := by
  unfold necessaryThreshold
  rw [paperThreshold_eq b hb]
  obtain ⟨k, rfl⟩ := ho
  omega

/-- **Threshold gap.** For `b ≥ 6` the gap between the proved and the necessary threshold is
exactly `b mod 2`. -/
theorem threshold_gap (b : ℕ) (hb : 6 ≤ b) :
    paperThreshold b = necessaryThreshold b + b % 2 := by
  unfold necessaryThreshold; rw [paperThreshold_eq b hb]

/-- **The frontier is exactly the odd case.** For `b ≥ 6`, the necessary threshold is strictly
below the proved threshold iff `b` is odd; closing this strict gap is the stated conjecture. -/
theorem necessary_lt_paper_iff_odd (b : ℕ) (hb : 6 ≤ b) :
    necessaryThreshold b < paperThreshold b ↔ Odd b := by
  rw [paperThreshold_eq b hb, necessaryThreshold, Nat.odd_iff]
  omega

/-- At the necessary threshold `t = b + 1`, the leading constant
`C(t-1, b) · C(t-1, a-3)` of the cubic upper bound collapses to `C(b, a-3)`, because
`C(b, b) = 1`. -/
theorem cubic_constant_at_threshold (a b : ℕ) :
    (necessaryThreshold b - 1).choose b * (necessaryThreshold b - 1).choose (a - 3)
      = b.choose (a - 3) := by
  unfold necessaryThreshold
  simp [Nat.choose_self]

end GenTuranK3t