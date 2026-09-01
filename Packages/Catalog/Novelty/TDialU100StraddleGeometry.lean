import Mathlib
import Novelty.TDialU100RangeShape
import MachineLearning.ZeroFitDialFade104

/-!
# Straddle geometry: what a confidence interval crossing the floor can and cannot decide

## Research context (FACT round-67 #2, exp 540, `TDIAL-U100`)

At bitlen 100 the pooled Spearman estimate is `0.544` with CI `[0.498, 0.588]`; for the first
time on uniform draws the interval *straddles* the validation floor `0.55`.  The reports
describe this as "the dial begins to fade".  A straddle, however, is a statement about the
*decision procedure*, not only about the signal: it says the experiment can no longer separate
"inside the band" from "outside the band" at this resolution.

This file develops the elementary but sharp geometry of that situation and applies it to the
recorded numbers.  Everything is exact rational arithmetic on the reported values, and the
structural theorems are stated for arbitrary erosion sequences, not just the recorded one.

## Main results

* `Straddles`, `Resolves` — the decision predicates.
* `descent_bound` — an eroding sequence with per-rung drop at least `d` satisfies
  `f i ≥ f j + (j−i)·d` for `i ≤ j` (induction on the rung gap).
* `straddle_indices_close` — **resolution horizon**: any two rungs whose intervals both
  straddle the same threshold are fewer than `2w/d` rungs apart.  Ambiguity about the band is
  therefore confined to a window of bounded width; it cannot persist.
* `straddle_span_at_most_three_rungs` — with the recorded half-width `0.045` and 4-bit drop
  `0.030`, that window is at most three rungs, i.e. **12 bitlens**.
* `exit_bound` — once the top of the interval is within `k·d` of the threshold, the whole
  interval is below it after `k` further rungs; `u100_exit_by_bitlen_108` predicts, from the
  bitlen-100 data alone, a complete exit by bitlen 108.
* `u100_exit_earlier_than_guaranteed` — the recorded bitlen-104 interval (`MachineLearning.
  ZeroFitDialFade104`) is already entirely below the floor: the exit happened one rung before
  the guaranteed bound, i.e. the erosion between 100 and 104 exceeded the rate assumed.
* `u100_advantage_resolvable_step_not` — the decisive asymmetry of exp 540: the `T`-over-count
  advantage `+0.098` exceeds the interval width `0.090`, while the 4-bit erosion step `0.030`
  does not.  At bitlen 100 the experiment can still resolve *which statistic is better* but can
  no longer resolve *how fast the dial is fading*.
* `u100_cross_experiment_agreement` — the exp-540 pooled value `0.544` and the value `0.543`
  reconstructed independently from the exp-541 bitlen-104 report agree to `0.001`.
-/

namespace Catalog.Novelty.TDialU100StraddleGeometry

open Catalog.Novelty.TDialU100RangeShape

/-! ## 1. Decision predicates -/

/-- The interval of half-width `w` about `c` straddles the threshold `B`. -/
def Straddles (c w B : ℚ) : Prop := c - w < B ∧ B < c + w

/-- The interval of half-width `w` about `c` resolves the threshold `B`: it lies entirely on
one side. -/
def Resolves (c w B : ℚ) : Prop := c + w < B ∨ B < c - w

lemma not_straddles_of_resolves {c w B : ℚ} (h : Resolves c w B) :
    ¬ Straddles c w B := by
  rintro ⟨h1, h2⟩
  rcases h with h | h <;> linarith

/-! ## 2. Erosion sequences -/

/-- `f` erodes by at least `d` per rung. -/
def Erodes (f : ℕ → ℚ) (d : ℚ) : Prop := ∀ k, f (k + 1) ≤ f k - d

/-- **Descent bound.**  An eroding sequence drops by at least `(j−i)·d` between rungs. -/
theorem descent_bound {f : ℕ → ℚ} {d : ℚ} (h : Erodes f d) :
    ∀ i j : ℕ, i ≤ j → f j + ((j : ℚ) - (i : ℚ)) * d ≤ f i := by
  intro i j hij
  induction j, hij using Nat.le_induction with
  | base => simp
  | succ m hm ih =>
      have hstep := h m
      have hcast : ((m + 1 : ℕ) : ℚ) = (m : ℚ) + 1 := by push_cast; ring
      rw [hcast]
      have : f (m + 1) + d ≤ f m := by linarith
      nlinarith [ih]

/-- **Resolution horizon.**  If the intervals of half-width `w` at two rungs `i ≤ j` both
straddle the same threshold, then `(j − i)·d < 2w`: ambiguity about the band lives in a window
of at most `2w/d` rungs. -/
theorem straddle_indices_close {f : ℕ → ℚ} {d w B : ℚ} (h : Erodes f d) {i j : ℕ} (hij : i ≤ j)
    (hi : Straddles (f i) w B) (hj : Straddles (f j) w B) :
    ((j : ℚ) - (i : ℚ)) * d < 2 * w := by
  have hdesc := descent_bound h i j hij
  have h1 : f i - w < B := hi.1
  have h2 : B < f j + w := hj.2
  linarith

/-- **Exit bound.**  If the top of the interval at rung `i` is at most `k·d` above the
threshold, then the interval at rung `i + k` lies entirely below the threshold. -/
theorem exit_bound {f : ℕ → ℚ} {d w B : ℚ} (h : Erodes f d) (i k : ℕ)
    (hk : f i + w < B + (k : ℚ) * d) : f (i + k) + w < B := by
  have hdesc := descent_bound h i (i + k) (Nat.le_add_right i k)
  have hcast : ((i + k : ℕ) : ℚ) - (i : ℚ) = (k : ℚ) := by push_cast; ring
  rw [hcast] at hdesc
  linarith

/-- Once an eroding dial's interval is entirely below the threshold, it stays there. -/
theorem miss_persists {f : ℕ → ℚ} {d w B : ℚ} (hd : 0 ≤ d) (h : Erodes f d) (i k : ℕ)
    (hi : f i + w < B) : f (i + k) + w < B := by
  have hdesc := descent_bound h i (i + k) (Nat.le_add_right i k)
  have hcast : ((i + k : ℕ) : ℚ) - (i : ℚ) = (k : ℚ) := by push_cast; ring
  rw [hcast] at hdesc
  have hk0 : (0 : ℚ) ≤ (k : ℚ) := by positivity
  nlinarith

/-! ## 3. The recorded bitlen-100 geometry -/

/-- The recorded CI half-width at bitlen 100 (the interval `[0.498, 0.588]` about `0.544`
is symmetric to within `0.001`; we use the conservative half-width `0.046`). -/
def halfWidth100 : ℚ := 46 / 1000

/-- The recorded 4-bit erosion step from bitlen 96 to bitlen 100. -/
def rungStep : ℚ := 30 / 1000

/-- The recorded interval straddles the floor. -/
theorem u100_straddles : Straddles pooled100 halfWidth100 bandFloor := by
  constructor <;> norm_num [pooled100, halfWidth100, bandFloor]

/-- The recorded interval does *not* resolve the floor. -/
theorem u100_not_resolves : ¬ Resolves pooled100 halfWidth100 bandFloor :=
  fun h => not_straddles_of_resolves h u100_straddles

/-- **The straddle window is at most three rungs (12 bitlens).**  For any dial eroding by at
least the recorded 4-bit step `0.030` per rung, two rungs whose intervals both straddle the
floor differ by fewer than `3.07` rungs, hence by at most `3` rungs — 12 bitlens.  The band
question is undecidable only inside a 12-bit window; outside it the answer is definite. -/
theorem straddle_span_at_most_three_rungs {f : ℕ → ℚ} (h : Erodes f rungStep) {i j : ℕ}
    (hij : i ≤ j) (hi : Straddles (f i) halfWidth100 bandFloor)
    (hj : Straddles (f j) halfWidth100 bandFloor) : j - i ≤ 3 := by
  have hlt := straddle_indices_close h hij hi hj
  by_contra hcon
  push_neg at hcon
  have h4 : 4 ≤ j - i := hcon
  have hq : (4 : ℚ) ≤ (j : ℚ) - (i : ℚ) := by
    have : (4 : ℕ) + i ≤ j := by omega
    have : ((4 : ℕ) + i : ℚ) ≤ (j : ℚ) := by exact_mod_cast this
    push_cast at this
    linarith
  rw [rungStep, halfWidth100] at hlt
  nlinarith

/-- **Prediction from the bitlen-100 data alone.**  Assuming the dial keeps eroding by at least
the recorded 4-bit step, the whole confidence interval is below the floor two rungs later, i.e.
by bitlen 108. -/
theorem u100_exit_by_bitlen_108 {f : ℕ → ℚ} (h : Erodes f rungStep) (i : ℕ)
    (h100 : f i = pooled100) : f (i + 2) + halfWidth100 < bandFloor := by
  refine exit_bound h i 2 ?_
  rw [h100]
  norm_num [pooled100, halfWidth100, bandFloor, rungStep]

/-- **The exit came one rung early.**  The recorded bitlen-104 interval of exp 541 is already
entirely below the floor, whereas the bitlen-100 data only guaranteed this by bitlen 108.  The
erosion between bitlen 100 and 104 therefore exceeded the rate that the bitlen-100 report
assumed — the quantitative content of the "fade accelerates" finding. -/
theorem u100_exit_earlier_than_guaranteed :
    Catalog.MachineLearning.ZeroFitDialFade104.ci104High < bandFloor ∧
    bandFloor < pooled100 + halfWidth100 := by
  constructor
  · norm_num [Catalog.MachineLearning.ZeroFitDialFade104.ci104High, bandFloor]
  · norm_num [pooled100, halfWidth100, bandFloor]

/-- **What the experiment can and cannot decide at bitlen 100.**  The `T`-over-count advantage
`0.098` exceeds the full interval width `2·0.046 = 0.092`, so the superiority of the
trailing-zero statistic is resolvable; the 4-bit erosion step `0.030` does not, so the fade
rate is not.  This is the precise sense in which the dial "begins to fade": the signal is still
there, but the instrument has lost the resolution to track its decay. -/
theorem u100_advantage_resolvable_step_not :
    2 * halfWidth100 < advantage100 ∧ rungStep < 2 * halfWidth100 := by
  constructor
  · norm_num [halfWidth100, advantage100]
  · norm_num [rungStep, halfWidth100]

/-- **Cross-experiment agreement.**  The bitlen-100 pooled value recorded by exp 540 and the
bitlen-100 value reconstructed independently in exp 541 (from `pooled104` and the reported
`0.043` step) agree to within `0.001`. -/
theorem u100_cross_experiment_agreement :
    |pooled100 - Catalog.MachineLearning.ZeroFitDialFade104.read100| ≤ 1 / 1000 := by
  rw [abs_le]
  constructor <;>
    norm_num [pooled100, Catalog.MachineLearning.ZeroFitDialFade104.read100,
      Catalog.MachineLearning.ZeroFitDialFade104.pooled104,
      Catalog.MachineLearning.ZeroFitDialFade104.step100]

/-- **The ambiguity window is exactly the two rungs 96 and 100.**  With the reconstructed
bitlen-96 value `0.573` of exp 541, the bitlen-96 interval of the recorded half-width *already*
straddles the floor (its point estimate is inside the band but its lower end is not), the
bitlen-100 interval straddles it too, and the bitlen-104 interval lies entirely below it.  So
the reported "validated envelope ends at bitlen ~96" is a statement about point estimates: at
the interval level the envelope already ended at bitlen 96, and the decision became definite
again at bitlen 104.  The window has width two rungs, comfortably inside the three-rung bound
of `straddle_span_at_most_three_rungs`. -/
theorem straddle_window_is_96_and_100 :
    Straddles Catalog.MachineLearning.ZeroFitDialFade104.read96 halfWidth100 bandFloor ∧
    Straddles pooled100 halfWidth100 bandFloor ∧
    bandFloor ≤ Catalog.MachineLearning.ZeroFitDialFade104.read96 ∧
    Catalog.MachineLearning.ZeroFitDialFade104.ci104High < bandFloor := by
  refine ⟨⟨?_, ?_⟩, u100_straddles, ?_, ?_⟩ <;>
    norm_num [Catalog.MachineLearning.ZeroFitDialFade104.read96,
      Catalog.MachineLearning.ZeroFitDialFade104.read100,
      Catalog.MachineLearning.ZeroFitDialFade104.pooled104,
      Catalog.MachineLearning.ZeroFitDialFade104.step100,
      Catalog.MachineLearning.ZeroFitDialFade104.step96,
      Catalog.MachineLearning.ZeroFitDialFade104.ci104High,
      halfWidth100, bandFloor]

end Catalog.Novelty.TDialU100StraddleGeometry