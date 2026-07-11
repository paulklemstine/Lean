import Applications.CakeBalancingRatio.Core

/-!
# Balancing ratios of circular partitions — Full-period balance

Building on `Applications.CakeBalancingRatio.Core`, this file records the exact
*periodic recurrence* of perfect balance in the cake balancing ratio sequence.

While `window_ratio_le_gap_ratio` shows that widening the window can only improve
balance, it does not by itself force the ratio down to `1`.  Here we prove the
sharper phenomenon that drives the `limsup` in the mission statement: whenever the
window length is a multiple of the period, the window sums are **all equal**, so
the ratio is *exactly* `1`.

## Main results

* `shift_sum` : a full-period sum `∑_{j<n} g (i+j)` is independent of the
  starting position `i` and equals the total circumference `totalLength`.
* `W_period`, `W_mul_period` : a window of `k` full periods has sum `k · L`,
  independent of where it starts.
* `winRatio_period_eq_one`, `winRatio_mul_period_eq_one` : the window ratio is
  exactly `1` at every multiple of the period.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  A window that wraps exactly around the circle sees
each arc the same number of times, so it should be perfectly balanced regardless
of phase.  Concretely `μ^{kn}_n = 1` for every `k ≥ 1`.

EXPERIMENT (Experimenter).  The engine is `shift_sum`: shifting the starting
index by one removes the first arc and re-adds an arc of *equal* length (by
periodicity), so a full-period sum is shift-invariant.  A telescoping induction
delivers `∑_{j<n} g (i+j) = L`, and a block decomposition (`sum_range_add`)
extends it to `k` periods.

ANALYSIS (Analyst).  Combined with `Core.one_le_winRatio`, this pins the exact
minimum of the window-ratio sequence and shows the ratio *returns to `1`
infinitely often* — the balance oscillates rather than converging monotonically.
This is precisely why the mission quantity `μ_r` is a `limsup`, not a `lim`.

CRITIQUE (Critic).  `totalLength_pos` guards against a zero denominator; the
`k ≥ 1` hypothesis rules out the vacuous `r = 0` window.

SYNTHESIS (PI).  Full-period balance is the recurrent "reset" of the ratio
sequence; the conjectured `2r/p + 1` bound must control the *excursions between*
these resets.
-/

namespace CakeBalancing

open Finset

namespace CircPartition

variable (P : CircPartition)

/-- Total circumference of the circle: the sum of all `n` arc lengths. -/
noncomputable def totalLength : ℝ := ∑ j ∈ range P.n, P.g j

/-- The total circumference is positive. -/
lemma totalLength_pos : 0 < P.totalLength := by
  rw [totalLength]; exact Finset.sum_pos (fun i _ => P.pos i) P.range_nonempty

/-- **Phase invariance of full-period sums.** A window of `n` consecutive arcs
sees each arc exactly once, so its length equals the total circumference,
independently of the starting position. -/
lemma shift_sum (i : ℕ) : (∑ j ∈ range P.n, P.g (i + j)) = P.totalLength := by
  rw [totalLength]
  induction i with
  | zero => simp
  | succ k ih =>
    have step : (∑ j ∈ range P.n, P.g (k + 1 + j)) = ∑ j ∈ range P.n, P.g (k + j) := by
      have e1 : (∑ j ∈ range (P.n + 1), P.g (k + j))
          = (∑ j ∈ range P.n, P.g (k + j)) + P.g (k + P.n) :=
        Finset.sum_range_succ _ _
      have e2 : (∑ j ∈ range (P.n + 1), P.g (k + j))
          = (∑ j ∈ range P.n, P.g (k + (j + 1))) + P.g (k + 0) :=
        Finset.sum_range_succ' _ _
      have key : (∑ j ∈ range P.n, P.g (k + (j + 1))) + P.g (k + 0)
          = (∑ j ∈ range P.n, P.g (k + j)) + P.g (k + P.n) := by rw [← e2, e1]
      have hper : P.g (k + P.n) = P.g (k + 0) := by rw [Nat.add_zero]; exact P.periodic k
      rw [hper] at key
      have h2 : (∑ j ∈ range P.n, P.g (k + (j + 1))) = (∑ j ∈ range P.n, P.g (k + j)) := by
        linarith
      calc (∑ j ∈ range P.n, P.g (k + 1 + j))
          = (∑ j ∈ range P.n, P.g (k + (j + 1))) := by
            apply Finset.sum_congr rfl; intro j _; ring_nf
        _ = _ := h2
    rw [step, ih]

/-- A window of one full period has length equal to the total circumference. -/
lemma W_period (i : ℕ) : P.W P.n i = P.totalLength := P.shift_sum i

/-- A window of `k` full periods has length `k · L`, independent of its start. -/
lemma W_mul_period (k i : ℕ) : P.W (k * P.n) i = k * P.totalLength := by
  induction k with
  | zero => simp [W]
  | succ m ih =>
    have hsplit : (m + 1) * P.n = m * P.n + P.n := by ring
    rw [W, hsplit, Finset.sum_range_add]
    have h1 : (∑ j ∈ range (m * P.n), P.g (i + j)) = P.W (m * P.n) i := rfl
    have h2 : (∑ j ∈ range P.n, P.g (i + (m * P.n + j))) = P.totalLength := by
      have hre : (∑ j ∈ range P.n, P.g (i + (m * P.n + j)))
          = ∑ j ∈ range P.n, P.g ((i + m * P.n) + j) := by
        apply Finset.sum_congr rfl; intro j _; ring_nf
      rw [hre]; exact P.shift_sum _
    rw [h1, ih, h2]; push_cast; ring

/-- **Perfect balance at the period.** The window ratio is exactly `1` when the
window length equals the number of arcs. -/
theorem winRatio_period_eq_one : P.winRatio P.n = 1 := by
  have hconst : (fun i => P.W P.n i) = (fun _ => P.totalLength) := funext P.W_period
  simp only [winRatio, maxwin, minwin, hconst]
  rw [Finset.sup'_const, Finset.inf'_const, div_self (ne_of_gt P.totalLength_pos)]

/-- The window ratio is exactly `1` at every positive multiple of the period, so
the balancing ratio sequence returns to its minimum value infinitely often. -/
theorem winRatio_mul_period_eq_one {k : ℕ} (hk : 1 ≤ k) : P.winRatio (k * P.n) = 1 := by
  have hconst : (fun i => P.W (k * P.n) i) = (fun _ => (k : ℝ) * P.totalLength) :=
    funext (P.W_mul_period k)
  have hne : (k : ℝ) * P.totalLength ≠ 0 := by
    have h0 : 0 < k := hk
    have hkr : (0 : ℝ) < (k : ℝ) := by exact_mod_cast h0
    have := P.totalLength_pos; positivity
  simp only [winRatio, maxwin, minwin, hconst]
  rw [Finset.sup'_const, Finset.inf'_const, div_self hne]

end CircPartition

end CakeBalancing