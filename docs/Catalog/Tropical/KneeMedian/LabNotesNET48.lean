/-
# Lab notes: the measured NET-48 sweep, machine-checked

Measured data (round NET-48; `d = 4`, `ctx = 2048`, seed 3; real causal word LM, vocab 4097,
held-out last 10%, data-free top-k selection):

* full-attention accuracy `0.1546`, bar `0.1516` (= `0.98 ×` full), full loss `5.2199`,
  training time `14566 s`;
* retained-accuracy ratios over the sweep grid

  | `k`   |  96   | 128   | 160   | 192   | 224   | 240   | 256   | 288   | 384   | 512   | 768   | 1024  |
  |-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
  | ratio | 0.963 | 0.973 | 0.981 | 0.984 | 0.986 | 0.987 | 0.990 | 0.993 | 0.999 | 1.000 | 1.003 | 1.003 |

* three-seed knees at this context: `256` (seed 1), `224` (seed 2), `160` (seed 3);
* the four pre-registered point predictions ("horns") were `192, 224, 240, 256`.

The sweep row is encoded here as a sum of nonnegative increments switched on at the grid
points (so monotonicity is structural), and the three claims the round rests on are then
*derived*:

* `net48_seed3_knee` — the knee at the `0.98` bar is `k* = 160`, with the razor-thin margin
  `0.001` (`net48_knee_margin`);
* `net48_horns_all_pass_but_none_is_knee` — all four horns clear the bar and none is the knee;
* `net48_sweep_monotone` — the measured curve is monotone, the hypothesis under which
  `knee_of_median_curve` applies.
-/
import Tropical.KneeMedian.KneeMedianCommutation

namespace Catalog.Tropical.KneeMedian

open Finset

/-- The sweep grid of NET-48. -/
def grid48 : Finset ℕ := {96, 128, 160, 192, 224, 240, 256, 288, 384, 512, 768, 1024}

/-- A nonnegative increment switched on at `t`. -/
def stepAt (t : ℕ) (v : ℚ) : ℕ → ℚ := fun k => if t ≤ k then v else 0

theorem stepAt_mono {t : ℕ} {v : ℚ} (hv : 0 ≤ v) : Monotone (stepAt t v) := by
  intro a b hab
  unfold stepAt
  split_ifs with h1 h2
  · exact le_rfl
  · exact absurd (le_trans h1 hab) h2
  · exact hv
  · exact le_rfl

/-- The measured retained-accuracy ratio of seed 3 at `ctx = 2048`, written as its base value
plus the measured increments. -/
def sweep48 (k : ℕ) : ℚ :=
  963 / 1000 + stepAt 128 (10 / 1000) k + stepAt 160 (8 / 1000) k + stepAt 192 (3 / 1000) k +
    stepAt 224 (2 / 1000) k + stepAt 240 (1 / 1000) k + stepAt 256 (3 / 1000) k +
    stepAt 288 (3 / 1000) k + stepAt 384 (6 / 1000) k + stepAt 512 (1 / 1000) k +
    stepAt 768 (3 / 1000) k

/-- The `0.98` retention bar. -/
def bar48 : ℚ := 98 / 100

/-- The measured sweep is monotone: retention never decreases as the budget `k` grows. -/
theorem net48_sweep_monotone : Monotone sweep48 := by
  intro a b hab
  simp only [sweep48]
  repeat' apply add_le_add
  all_goals first
    | exact le_rfl
    | exact stepAt_mono (by norm_num) hab

/-- The measured sweep row, value by value. -/
theorem net48_sweep_values :
    sweep48 96 = 963 / 1000 ∧ sweep48 128 = 973 / 1000 ∧ sweep48 160 = 981 / 1000 ∧
      sweep48 192 = 984 / 1000 ∧ sweep48 224 = 986 / 1000 ∧ sweep48 240 = 987 / 1000 ∧
      sweep48 256 = 990 / 1000 ∧ sweep48 288 = 993 / 1000 ∧ sweep48 384 = 999 / 1000 ∧
      sweep48 512 = 1 ∧ sweep48 768 = 1003 / 1000 ∧ sweep48 1024 = 1003 / 1000 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [sweep48, stepAt]

/-- **The measured knee is `160`.**  Derived from the sweep row, not assumed. -/
theorem net48_seed3_knee : IsKneeOn grid48 bar48 sweep48 160 := by
  refine ⟨by decide, by norm_num [sweep48, stepAt, bar48], ?_⟩
  intro j hj hbar
  revert hbar
  fin_cases hj <;> norm_num [sweep48, stepAt, bar48]

/-- The razor-thin margin of the read: `0.981 - 0.980 = 0.001`. -/
theorem net48_knee_margin : sweep48 160 - bar48 = 1 / 1000 := by
  norm_num [sweep48, stepAt, bar48]

/-- **All four horns pass the bar, none is the knee.**  The round's point predictions are
simultaneously "safe" (each `k` clears the bar) and "wrong" (none is the first such `k`). -/
theorem net48_horns_all_pass_but_none_is_knee :
    (∀ k ∈ ({192, 224, 240, 256} : Finset ℕ), bar48 ≤ sweep48 k) ∧
      ∀ k ∈ ({192, 224, 240, 256} : Finset ℕ), ¬ IsKneeOn grid48 bar48 sweep48 k := by
  constructor
  · intro k hk
    fin_cases hk <;> norm_num [sweep48, stepAt, bar48]
  · intro k hk hcon
    have h := hcon.2.2 160 (by decide) (by norm_num [sweep48, stepAt, bar48])
    fin_cases hk <;> omega

/-- The product point `256 = d·ctx/32` clears the bar: the product-law upper bound holds for
this seed. -/
theorem net48_product_point_passes : bar48 ≤ sweep48 256 := by
  norm_num [sweep48, stepAt, bar48]

/-- The knee is unique, so `160` is *the* knee of the measured sweep. -/
theorem net48_knee_unique {k : ℕ} (h : IsKneeOn grid48 bar48 sweep48 k) : k = 160 :=
  IsKneeOn.unique h net48_seed3_knee

end Catalog.Tropical.KneeMedian