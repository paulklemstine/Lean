import Mathlib

/-!
# Balancing ratios of circular partitions — Core

This file develops the structural core behind the *cake balancing ratio sequence*
studied in the mission "Upper bound conjecture for the cake balancing ratio
sequence" (in the spirit of de Bruijn–Erdős cake cutting and discrepancy theory
for circular partitions).

## Setting

A sequence of points placed on a circle cuts it into arcs.  We model a *cyclic
partition* by its sequence of **gap lengths** `g : ℕ → ℝ`, positive and periodic
with period `n` (so the circle carries `n` distinct arcs `g 0, …, g (n-1)`,
repeated cyclically).  For a window length `r ≥ 1`, the **`r`-window sum**
starting at position `i` is the length of `r` consecutive arcs,
`W r i = g i + g (i+1) + ⋯ + g (i+r-1)`.

The **single-gap ratio** is `gapRatio = maxgap / mingap`, and the
**`r`-window ratio** is `winRatio r = maxwin r / minwin r`, where the extrema
range over the `n` cyclic starting positions.  These are the finite-stage
quantities `μ¹_n` and `μ^r_n` from the mission statement.

## Main results

* `mingap_le_maxgap`, `one_le_gapRatio` : the ratio is always `≥ 1`.
* `window_ratio_le_gap_ratio` : `winRatio r ≤ gapRatio` for every `r ≥ 1`.
  Aggregating `r` consecutive arcs can only *improve* balance — the key
  structural monotonicity behind the `2r/p + 1` upper-bound conjecture.
* `one_le_winRatio` : `winRatio r ≥ 1`.
* `winRatio_uniform_eq_one` : the equal-arc partition has every window ratio `1`.
* `vdc3_gapRatio_eq_two` : the de Bruijn–Erdős three-point van der Corput
  partition `{1/4, 1/4, 1/2}` realises single-gap ratio exactly `2`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The mission conjecture `μ_r^σ ≤ 2r/p + 1` predicts
that window ratios grow at most linearly in `r`.  A necessary structural fact
underneath any such bound is that *windowing cannot make balance worse*: since
each `r`-window sum lies between `r·mingap` and `r·maxgap`, the window ratio is
squeezed below the raw gap ratio.  We conjecture `winRatio r ≤ gapRatio` for all
`r`, unconditionally.

EXPERIMENT (Experimenter).  Proven below via the two envelope bounds
`maxwin_le_r_mul_maxgap` and `r_mul_mingap_le_minwin`, then a division estimate.

ANALYSIS (Analyst).  The bound is *exact at `r = 1`* and *tight for the uniform
partition* (ratio `1` at every `r`).  The van der Corput example shows the raw
ratio `2` is attainable, matching the de Bruijn–Erdős cake-cutting benchmark.

CRITIQUE (Critic).  Positivity of `mingap` (hence of `minwin`) is load-bearing;
every division lemma carries the `r ≥ 1` hypothesis so denominators stay
positive.  No statement is vacuous: the uniform and van der Corput witnesses
show the extremal values `1` and `2` are attained.

SYNTHESIS (PI).  `winRatio r ≤ gapRatio` is the monotone scaffold on which the
full `2r/p + 1` recipe bound should rest; see `FUTURE_DIRECTIONS.md`.
-/

namespace CakeBalancing

open Finset

/-- A cyclic partition of a circle into `n` positive arcs, described by its
periodic sequence of gap lengths. -/
structure CircPartition where
  /-- number of arcs -/
  n : ℕ
  /-- there is at least one arc -/
  npos : 0 < n
  /-- gap length sequence -/
  g : ℕ → ℝ
  /-- all arcs have positive length -/
  pos : ∀ i, 0 < g i
  /-- the arc pattern repeats with period `n` -/
  periodic : ∀ i, g (i + n) = g i

namespace CircPartition

variable (P : CircPartition)

/-- The index set of cyclic starting positions is nonempty. -/
lemma range_nonempty : (range P.n).Nonempty := nonempty_range_iff.mpr P.npos.ne'

/-- Largest single arc length. -/
noncomputable def maxgap : ℝ := (range P.n).sup' P.range_nonempty P.g

/-- Smallest single arc length. -/
noncomputable def mingap : ℝ := (range P.n).inf' P.range_nonempty P.g

/-- Sum of `r` consecutive arcs starting at position `i`. -/
noncomputable def W (r i : ℕ) : ℝ := ∑ j ∈ range r, P.g (i + j)

/-- Largest `r`-window sum over the `n` cyclic starting positions. -/
noncomputable def maxwin (r : ℕ) : ℝ := (range P.n).sup' P.range_nonempty (fun i => P.W r i)

/-- Smallest `r`-window sum over the `n` cyclic starting positions. -/
noncomputable def minwin (r : ℕ) : ℝ := (range P.n).inf' P.range_nonempty (fun i => P.W r i)

/-- Single-gap ratio `μ¹_n`. -/
noncomputable def gapRatio : ℝ := P.maxgap / P.mingap

/-- `r`-window ratio `μ^r_n`. -/
noncomputable def winRatio (r : ℕ) : ℝ := P.maxwin r / P.minwin r

/-- The gap sequence depends only on the index modulo the period. -/
lemma g_mod (i : ℕ) : P.g i = P.g (i % P.n) := by
  have hp : Function.Periodic P.g P.n := fun x => P.periodic x
  simpa using (hp.map_mod_nat i).symm

/-- Every gap is at most the maximum gap. -/
lemma g_le_maxgap (i : ℕ) : P.g i ≤ P.maxgap := by
  rw [P.g_mod i, maxgap]
  exact Finset.le_sup' P.g (mem_range.mpr (Nat.mod_lt i P.npos))

/-- Every gap is at least the minimum gap. -/
lemma mingap_le_g (i : ℕ) : P.mingap ≤ P.g i := by
  rw [P.g_mod i, mingap]
  exact Finset.inf'_le P.g (mem_range.mpr (Nat.mod_lt i P.npos))

/-- The minimum gap is positive. -/
lemma mingap_pos : 0 < P.mingap := by
  rw [mingap, Finset.lt_inf'_iff]
  intro i _; exact P.pos i

/-- Balance is nontrivial: minimum gap does not exceed maximum gap. -/
lemma mingap_le_maxgap : P.mingap ≤ P.maxgap := by
  rw [maxgap, mingap]
  obtain ⟨a, ha⟩ := P.range_nonempty
  exact le_trans (Finset.inf'_le P.g ha) (Finset.le_sup' P.g ha)

/-- The maximum gap is positive. -/
lemma maxgap_pos : 0 < P.maxgap := lt_of_lt_of_le P.mingap_pos P.mingap_le_maxgap

/-- The single-gap ratio is at least `1`. -/
lemma one_le_gapRatio : 1 ≤ P.gapRatio := by
  rw [gapRatio, le_div_iff₀ P.mingap_pos, one_mul]
  exact P.mingap_le_maxgap

/-- An `r`-window sum is at most `r` times the maximum gap. -/
lemma W_le_r_mul_maxgap (r i : ℕ) : P.W r i ≤ (r : ℝ) * P.maxgap := by
  rw [W]
  calc ∑ j ∈ range r, P.g (i + j) ≤ ∑ _j ∈ range r, P.maxgap :=
        Finset.sum_le_sum (fun j _ => P.g_le_maxgap (i + j))
    _ = (r : ℝ) * P.maxgap := by rw [Finset.sum_const, card_range]; ring

/-- An `r`-window sum is at least `r` times the minimum gap. -/
lemma r_mul_mingap_le_W (r i : ℕ) : (r : ℝ) * P.mingap ≤ P.W r i := by
  rw [W]
  calc (r : ℝ) * P.mingap = ∑ _j ∈ range r, P.mingap := by
          rw [Finset.sum_const, card_range]; ring
    _ ≤ ∑ j ∈ range r, P.g (i + j) := Finset.sum_le_sum (fun j _ => P.mingap_le_g (i + j))

/-- The maximum window sum is at most `r` times the maximum gap. -/
lemma maxwin_le_r_mul_maxgap (r : ℕ) : P.maxwin r ≤ (r : ℝ) * P.maxgap := by
  rw [maxwin]; exact Finset.sup'_le _ _ (fun i _ => P.W_le_r_mul_maxgap r i)

/-- The minimum window sum is at least `r` times the minimum gap. -/
lemma r_mul_mingap_le_minwin (r : ℕ) : (r : ℝ) * P.mingap ≤ P.minwin r := by
  rw [minwin]; exact Finset.le_inf' _ _ (fun i _ => P.r_mul_mingap_le_W r i)

/-- For `r ≥ 1` the minimum window sum is positive. -/
lemma minwin_pos {r : ℕ} (hr : 1 ≤ r) : 0 < P.minwin r := by
  have h0 : 0 < r := hr
  have hpos : (0 : ℝ) < (r : ℝ) * P.mingap := by
    have : (0 : ℝ) < (r : ℝ) := by exact_mod_cast h0
    have := P.mingap_pos; positivity
  exact lt_of_lt_of_le hpos (P.r_mul_mingap_le_minwin r)

/-- The minimum window sum never exceeds the maximum window sum. -/
lemma minwin_le_maxwin (r : ℕ) : P.minwin r ≤ P.maxwin r := by
  rw [minwin, maxwin]
  obtain ⟨a, ha⟩ := P.range_nonempty
  exact le_trans (Finset.inf'_le _ ha) (Finset.le_sup' _ ha)

/-- **Windowing improves balance.** For every window length `r ≥ 1`, the
`r`-window ratio is bounded above by the single-gap ratio. -/
theorem window_ratio_le_gap_ratio {r : ℕ} (hr : 1 ≤ r) :
    P.winRatio r ≤ P.gapRatio := by
  have h0 : 0 < r := hr
  have hrpos : (0 : ℝ) < (r : ℝ) := by exact_mod_cast h0
  have hmaxg : (0 : ℝ) ≤ P.maxgap := le_of_lt P.maxgap_pos
  have hmnpos : 0 < P.minwin r := P.minwin_pos hr
  have hmw : P.maxwin r ≤ (r : ℝ) * P.maxgap := P.maxwin_le_r_mul_maxgap r
  have hmg : (r : ℝ) * P.mingap ≤ P.minwin r := P.r_mul_mingap_le_minwin r
  have hrmin : (0 : ℝ) < (r : ℝ) * P.mingap := by have := P.mingap_pos; positivity
  rw [winRatio, gapRatio]
  calc P.maxwin r / P.minwin r
      ≤ ((r : ℝ) * P.maxgap) / P.minwin r := by gcongr
    _ ≤ ((r : ℝ) * P.maxgap) / ((r : ℝ) * P.mingap) := by gcongr
    _ = P.maxgap / P.mingap := by rw [mul_div_mul_left _ _ (ne_of_gt hrpos)]

/-- The `r`-window ratio is at least `1`. -/
theorem one_le_winRatio {r : ℕ} (hr : 1 ≤ r) : 1 ≤ P.winRatio r := by
  rw [winRatio, le_div_iff₀ (P.minwin_pos hr), one_mul]
  exact P.minwin_le_maxwin r

end CircPartition

/-! ## The uniform partition -/

/-- The perfectly balanced partition into `n` equal arcs of length `1/n`. -/
noncomputable def uniform (n : ℕ) (hn : 0 < n) : CircPartition where
  n := n
  npos := hn
  g := fun _ => 1 / n
  pos := fun _ => by positivity
  periodic := fun _ => rfl

/-- Every window of the uniform partition has ratio exactly `1`. -/
theorem winRatio_uniform_eq_one (n : ℕ) (hn : 0 < n) {r : ℕ} (hr : 1 ≤ r) :
    (uniform n hn).winRatio r = 1 := by
  have hconst : ∀ i, (uniform n hn).W r i = (r : ℝ) * (1 / n) := by
    intro i
    simp only [CircPartition.W, uniform]
    rw [Finset.sum_const, card_range]; ring
  have hne : (r : ℝ) * (1 / n) ≠ 0 := by
    have h0 : 0 < r := hr
    have h1 : (0 : ℝ) < (r : ℝ) := by exact_mod_cast h0
    have h2 : (0 : ℝ) < n := by exact_mod_cast hn
    positivity
  simp only [CircPartition.winRatio, CircPartition.maxwin, CircPartition.minwin]
  rw [show (fun i => (uniform n hn).W r i) = (fun _ => (r : ℝ) * (1 / n)) from funext hconst]
  rw [Finset.sup'_const, Finset.inf'_const, div_self hne]

/-! ## The de Bruijn–Erdős three-point van der Corput partition -/

/-- The three-arc partition `{1/4, 1/4, 1/2}` obtained from the first three
points of the base-2 van der Corput sequence. -/
noncomputable def vdc3 : CircPartition where
  n := 3
  npos := by norm_num
  g := fun i => if i % 3 = 2 then (1 : ℝ) / 2 else 1 / 4
  pos := fun i => by split <;> norm_num
  periodic := fun i => by simp only [Nat.add_mod_right]

/-- The largest arc of the van der Corput three-point partition has length `1/2`. -/
theorem vdc3_maxgap : vdc3.maxgap = 1 / 2 := by
  apply le_antisymm
  · apply Finset.sup'_le
    intro i _
    show (if i % 3 = 2 then (1 : ℝ) / 2 else 1 / 4) ≤ 1 / 2
    split <;> norm_num
  · have h2 : (2 : ℕ) ∈ range vdc3.n := by show (2 : ℕ) ∈ range 3; decide
    have hle := Finset.le_sup' vdc3.g h2
    have hval : vdc3.g 2 = 1 / 2 := by
      show (if 2 % 3 = 2 then (1 : ℝ) / 2 else 1 / 4) = 1 / 2; norm_num
    rw [hval] at hle; exact hle

/-- The smallest arc of the van der Corput three-point partition has length `1/4`. -/
theorem vdc3_mingap : vdc3.mingap = 1 / 4 := by
  apply le_antisymm
  · have h0 : (0 : ℕ) ∈ range vdc3.n := by show (0 : ℕ) ∈ range 3; decide
    have hle := Finset.inf'_le vdc3.g h0
    have hval : vdc3.g 0 = 1 / 4 := by
      show (if 0 % 3 = 2 then (1 : ℝ) / 2 else 1 / 4) = 1 / 4; norm_num
    rw [hval] at hle; exact hle
  · apply Finset.le_inf'
    intro i _
    show (1 : ℝ) / 4 ≤ (if i % 3 = 2 then (1 : ℝ) / 2 else 1 / 4)
    split <;> norm_num

/-- The van der Corput three-point partition realises single-gap ratio exactly
`2`, the de Bruijn–Erdős cake-cutting benchmark. -/
theorem vdc3_gapRatio_eq_two : vdc3.gapRatio = 2 := by
  rw [CircPartition.gapRatio, vdc3_maxgap, vdc3_mingap]; norm_num

end CakeBalancing