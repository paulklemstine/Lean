/-
# E3, cycle four: an executable verdict, and the dimensionless invariant

Cycle three fixed the protocol (a median over `n > 2k` runs).  This file supplies
the two things a protocol still needs: a *decision procedure* that can be run on
the harness output, with a soundness proof, and the *parameter-free invariant*
that the whole depth leg reduces to.

* **§1 A majority rule for medians.**  If strictly more than half of the runs
  report a value in `[a, b]`, then *every* median of the log lies in `[a, b]`
  (`median_mem_of_majority`).  This strengthens the contamination form used in
  earlier cycles: it needs no reference to an uncorrupted log, only the reported
  numbers, so it can be evaluated by the harness itself.

* **§2 The verdict.**  `e3Accept` is a `Bool`-valued, executable test on the
  reported log; `e3Accept_sound` proves it certifies E3, and
  `e3Accept_sharp_at_half` shows the strict majority cannot be weakened to a tie:
  the four-run log `[1, 1, 2, 2]` has exactly half its runs in band and admits
  the out-of-band median `2`.

* **§3 The dimensionless invariant.**  Everything in this thread collapses to one
  number with no depth, no context, no amplitude and no read-out constant in it:
  the deficit at the selected budget, measured in units of the margin over the
  read-out constant, lies in `[1/8, 1/4]` (`deficit_margin_invariant`).  A single
  measured pair `(1 - ρ(k*), m)` at any one cell tests the entire mechanism.
-/

import Mathlib
import Computation.MarginProtocolDesign

namespace MarginVerdict

open AttentionCostLaw AttentionMarginLaw MarginDepthInvariance

/-!
## 1.  A majority rule for medians
-/

/-- **Majority rule.**  If strictly more than half of the entries of a log lie in
`[a, b]`, then every median of the log lies in `[a, b]`.  Unlike
`MedianBreakdown.median_robust_interval` this refers only to the reported
numbers, so it is checkable from the harness output alone. -/
theorem median_mem_of_majority {l : List ℚ} {a b m : ℚ}
    (hmaj : l.length < 2 * l.countP (fun x => decide (a ≤ x ∧ x ≤ b)))
    (hm : MedianBreakdown.IsMedian l m) : a ≤ m ∧ m ≤ b := by
  set P : ℚ → Bool := fun x => decide (a ≤ x ∧ x ≤ b) with hP
  have hsplit : l.length = l.countP P + l.countP (fun x => ¬ P x) :=
    List.length_eq_countP_add_countP P
  constructor
  · by_contra hlt
    push_neg at hlt
    -- every entry `≤ m` is below `a`, hence outside the band
    have hmono : l.countP (fun x => decide (x ≤ m)) ≤ l.countP (fun x => ¬ P x) := by
      refine List.countP_mono_left ?_
      intro x _ hx
      have hxm : x ≤ m := by simpa using hx
      have : ¬ (a ≤ x ∧ x ≤ b) := by
        rintro ⟨hax, -⟩
        exact absurd (le_trans hax hxm) (not_le.mpr hlt)
      simp [hP, this]
    have hhalf := hm.1
    omega
  · by_contra hgt
    push_neg at hgt
    have hmono : l.countP (fun x => decide (m ≤ x)) ≤ l.countP (fun x => ¬ P x) := by
      refine List.countP_mono_left ?_
      intro x _ hx
      have hmx : m ≤ x := by simpa using hx
      have : ¬ (a ≤ x ∧ x ≤ b) := by
        rintro ⟨-, hxb⟩
        exact absurd (le_trans hmx hxb) (not_le.mpr hgt)
      simp [hP, this]
    have hhalf := hm.2
    omega

/-!
## 2.  The executable verdict
-/

/-- Is a single reported ratio inside the E3 acceptance band? -/
def inBandE3 (x : ℚ) : Bool := decide (9 / 10 ≤ x ∧ x ≤ 11 / 10)

/-- **The E3 verdict.**  Accept the depth-independence claim iff a strict
majority of the reported per-run margin ratios lie in `[0.9, 1.1]`.  This is a
`Bool` the harness can print. -/
def e3Accept (l : List ℚ) : Bool := decide (l.length < 2 * l.countP inBandE3)

/-- **Soundness of the verdict.**  If `e3Accept` fires on the reported log then
every median of that log passes E3 — no assumption about which runs are genuine
and which are corrupted. -/
theorem e3Accept_sound {l : List ℚ} {m : ℚ} (h : e3Accept l = true)
    (hm : MedianBreakdown.IsMedian l m) : PassesE3 m := by
  have hmaj : l.length < 2 * l.countP (fun x => decide (9 / 10 ≤ x ∧ x ≤ 11 / 10)) :=
    of_decide_eq_true h
  exact median_mem_of_majority hmaj hm

/-- **The strict majority is necessary.**  A four-run log with exactly half of
its runs in band admits an out-of-band median, so the verdict cannot be relaxed
to "at least half". -/
theorem e3Accept_sharp_at_half :
    ([1, 1, 2, 2] : List ℚ).length = 2 * ([1, 1, 2, 2] : List ℚ).countP inBandE3 ∧
      MedianBreakdown.IsMedian [1, 1, 2, 2] 2 ∧ ¬ PassesE3 2 := by
  refine ⟨by norm_num [inBandE3, List.countP_cons], ?_, ?_⟩
  · constructor <;> norm_num [MedianBreakdown.IsMedian, List.countP_cons]
  · rintro ⟨-, h⟩
    norm_num at h

/-- The verdict does fire on a flat log: three depths, two seeds, all ratios
inside the band. -/
theorem e3Accept_flat_log :
    e3Accept [1, 102/100, 98/100, 104/100, 97/100, 101/100] = true := by
  norm_num [e3Accept, inBandE3, List.countP_cons]

/-- ...and does not fire on a log whose runs report the naive quarter. -/
theorem e3Accept_quarter_log :
    e3Accept [1/4, 1/4, 1/4, 1/4, 1/4, 1/4] = false := by
  norm_num [e3Accept, inBandE3, List.countP_cons]

/-!
## 3.  The dimensionless invariant
-/

/-- **One number tests the mechanism.**  With the margin pinned by the
depth-linear knee, the attention deficit at the selected budget, expressed in
units of `m/(L·B)`, lies in `[1/8, 1/4]` — no depth, no context, no amplitude,
no read-out constant.  A single measured pair `(1 - ρ(k*), m)` at one cell is
therefore a complete test of the margin channel. -/
theorem deficit_margin_invariant {A ctx L B : ℝ} (hA : 0 < A) (hL : 0 < L)
    (hB : 0 < B) (hctx : (32 : ℝ) ≤ ctx) :
    1 / 8 ≤ zipfTail A ctx (marginKnee A ctx L B (128 * L * B * A)) * (L * B)
        / (128 * L * B * A) ∧
      zipfTail A ctx (marginKnee A ctx L B (128 * L * B * A)) * (L * B)
        / (128 * L * B * A) ≤ 1 / 4 := by
  obtain ⟨hlo, hhi⟩ := deficit_window_depth_and_context_free hA hL hB hctx
  have hden : (0 : ℝ) < 128 * L * B * A := by positivity
  have hLB : (0 : ℝ) < L * B := by positivity
  constructor
  · rw [le_div_iff₀ hden]
    nlinarith [hlo, hLB]
  · rw [div_le_iff₀ hden]
    nlinarith [hhi, hLB]

end MarginVerdict