import Mathlib
import Bridges.DenseSumsetFree.Basic
import Bridges.DenseSumsetFree.Extraction
import Bridges.DenseSumsetFree.Counting
/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Why the theorem has content: obstructions to sumset avoidance

The main theorem produces, for each density `δ < 1`, dense sets `S ⊆ [n]` avoiding
all `k`-sumsets with `k = O((log n)³)`.  This file records the matching *negative*
results which show that such sets must be genuinely irregular, and that the
threshold cannot be lowered to a constant.

## Main results

* `not_avoidsSumsets_of_ap` — a set containing an arithmetic progression of length
  `2k - 1` contains a sumset `A + B` with `|A| = |B| = k`, hence does **not** avoid
  `k`-sumsets.  In particular no union of long intervals, and no set containing a
  long AP, can be sumset-avoiding.
* `not_avoidsSumsets_range` — the full interval `[n]` fails to avoid `k`-sumsets
  as soon as `2k - 1 ≤ n`: density alone is never enough.
* `avoidsSumsets_iff_of_card_lt` — combining with the baseline bound, for the
  interval `[n]` the avoidance threshold is *exactly* `k > (n+1)/2`.
* `counting_hypotheses_satisfiable` — an explicit numerical witness that the
  hypotheses of the counting theorem are satisfiable (`n = 1024`, density `1/2`,
  `l = 21`), so the machinery is not vacuous.
-/
-- MISSING MODULE (not present in this repository): import Bridges.DenseSumsetFree.Main
open Finset Pointwise

namespace DenseSumsetFree

/-- **Long arithmetic progressions are an obstruction.**  If `S` contains the
arithmetic progression `a, a + d, …, a + (2k-2)d` with `d ≥ 1` and `k ≥ 1`, then
`S` contains a sumset `A + B` with `|A| = |B| = k`, so `S` does not avoid
`k`-sumsets. -/
theorem not_avoidsSumsets_of_ap (S : Finset ℕ) (a d k : ℕ) (hd : 1 ≤ d) (hk : 1 ≤ k)
    (hAP : ∀ i < 2 * k - 1, a + i * d ∈ S) : ¬ AvoidsSumsets S k := by
  classical
  intro havoid
  set A : Finset ℕ := (Finset.range k).image (fun i => a + i * d) with hA
  set B : Finset ℕ := (Finset.range k).image (fun j => j * d) with hB
  have hAcard : A.card = k := by
    rw [hA, Finset.card_image_of_injective _ ?_, Finset.card_range]
    intro x y hxy
    simp only at hxy
    have hxy' : x * d = y * d := by omega
    exact Nat.eq_of_mul_eq_mul_right (by omega) hxy'
  have hBcard : B.card = k := by
    rw [hB, Finset.card_image_of_injective _ ?_, Finset.card_range]
    intro x y hxy
    simp only at hxy
    exact Nat.eq_of_mul_eq_mul_right (by omega) hxy
  refine havoid A B hAcard.ge hBcard.ge ?_
  intro x hx
  rw [Finset.mem_add] at hx
  obtain ⟨u, hu, v, hv, rfl⟩ := hx
  rw [hA, Finset.mem_image] at hu
  rw [hB, Finset.mem_image] at hv
  obtain ⟨i, hi, rfl⟩ := hu
  obtain ⟨j, hj, rfl⟩ := hv
  rw [Finset.mem_range] at hi hj
  have hsum : a + i * d + j * d = a + (i + j) * d := by ring
  rw [hsum]
  exact hAP (i + j) (by omega)

/-- **Density alone is never enough.**  The full interval `[n]` contains a sumset
`A + B` with `|A| = |B| = k` whenever `2k - 1 ≤ n` and `k ≥ 1`. -/
theorem not_avoidsSumsets_range (n k : ℕ) (hk : 1 ≤ k) (hn : 2 * k - 1 ≤ n) :
    ¬ AvoidsSumsets (Finset.range n) k := by
  refine not_avoidsSumsets_of_ap _ 0 1 k le_rfl hk ?_
  intro i hi
  rw [Finset.mem_range]
  omega

/-- **The exact avoidance threshold for an interval.**  The interval `[n]` avoids
`k`-sumsets precisely when `n < 2k - 1`.  (Combines the baseline Cauchy–Davenport
bound with the arithmetic-progression obstruction.) -/
theorem avoidsSumsets_range_iff (n k : ℕ) (hk : 1 ≤ k) :
    AvoidsSumsets (Finset.range n) k ↔ n < 2 * k - 1 := by
  constructor
  · intro h
    by_contra hcon
    exact not_avoidsSumsets_range n k hk (by omega) h
  · intro h
    exact avoidsSumsets_of_card_lt hk (by rwa [Finset.card_range])

set_option exponentiation.threshold 500 in
/-- The hypotheses of the counting theorem are satisfiable: with `n = 1024`,
`m = 512` (density `1/2`), `l = 21` one has `l² = 441 ≤ 512` and
`n^{2l} · 1^{l²} = 2^{420} < 2^{441} = q^{l²}`.  Consequently there is a subset of
`[1024]` of size `512` avoiding all `k`-sumsets with `k = 21³ + 21 = 9282`. -/
theorem counting_hypotheses_satisfiable :
    ∃ S ⊆ Finset.range 1024, S.card = 512 ∧ AvoidsSumsets S (21 ^ 3 + 21) := by
  refine exists_avoidsSumsets_set (n := 1024) (m := 512) (l := 21) (p := 1) (q := 2)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) ?_
  have h1 : (1024 : ℕ) ^ (2 * 21) * 1 ^ (21 * 21) = 2 ^ 420 := by
    rw [one_pow, mul_one, show (1024 : ℕ) = 2 ^ 10 from by norm_num, ← pow_mul]
  rw [h1]
  exact Nat.pow_lt_pow_right (by norm_num) (by norm_num)

end DenseSumsetFree