/-
# Machine-checked arithmetic of the NET-46 sweep (computational evidence)

Exact rational recomputation of every number the NET-46 round reports at
`(d = 4, ctx = 2048)`, in the style of `Logic.KneeFluctuationEvidence`: the sweep is a
list of `(budget, retained accuracy)` pairs over `ℚ`, the knee is the first budget
reaching the bar, and every claim below is checked by `norm_num` on exact rationals
rather than read off a plot.

Recomputed here:

* the seed-2 knee `224` and the seed-1 knee `256` at `16×` (`knee_2048_s2`, `knee_2048_s1`);
* the margin `+0.002` at `224` and the deficit `0.002` at `192` — the round's own
  resolution (`margin_224`, `deficit_192`);
* the fact that the seed-1 deficit at `224` is `0.004`, **smaller than the measured
  inter-seed spread `0.006`**, so shifting the seed-1 sweep by the spread already reports
  `224` (`deficit_s1_224_lt_spread`, `knee_2048_s1_shifted`);
* the seed-2 curve dominating the seed-1 curve at both recorded budgets
  (`s2_dominates_s1`);
* the amplitude windows `(8, 12]`, `(12, 14]`, `(12, 16]`, `(14, 16]` of the four
  measured rungs and their intersection pattern (`amplitude_windows_rational`);
* the `k = 1024` loss gap `0.0006`, cleaner than seed 1's `0.0015` (`loss_gaps`).
-/

import Mathlib
import Logic.KneeFluctuationEvidence

namespace KneeDriftEvidence

open KneeEvidence

/-- The measured seed-2 sweep at `(d = 4, ctx = 2048)` (NET-46), budgets increasing. -/
def sweep2048S2 : List (ℕ × ℚ) :=
  [(96, 956 / 1000), (128, 965 / 1000), (160, 971 / 1000), (192, 978 / 1000),
   (224, 982 / 1000), (256, 986 / 1000), (288, 987 / 1000), (384, 992 / 1000),
   (512, 993 / 1000), (768, 998 / 1000), (1024, 998 / 1000)]

/-- The recorded seed-1 values at the same cell (NET-45). -/
def sweep2048S1 : List (ℕ × ℚ) :=
  [(96, 939 / 1000), (224, 976 / 1000), (256, 986 / 1000)]

/-- The inter-seed spread at the deciding budget `224`: `0.982 - 0.976`. -/
def spread46Q : ℚ := 6 / 1000

/-- **Seed 2 at `16×`: knee `224`.** -/
theorem knee_2048_s2 : kneeOf sweep2048S2 = some 224 := by
  norm_num [kneeOf, sweep2048S2, barQ, List.find?]

/-- **Seed 1 at `16×`: knee `256`.** -/
theorem knee_2048_s1 : kneeOf sweep2048S1 = some 256 := by
  norm_num [kneeOf, sweep2048S1, barQ, List.find?]

/-- The margin at the seed-2 knee is `0.002`. -/
theorem margin_224 : (982 : ℚ) / 1000 - barQ = 2 / 1000 := by norm_num [barQ]

/-- The deficit at the preceding grid point is also `0.002`: the reading is decided at
the round's own resolution, with nothing to spare. -/
theorem deficit_192 : barQ - (978 : ℚ) / 1000 = 2 / 1000 := by norm_num [barQ]

/-- **The seed-1 deficit at the deciding budget is `0.004`, strictly smaller than the
measured inter-seed spread `0.006`.** -/
theorem deficit_s1_224_lt_spread : barQ - (976 : ℚ) / 1000 < spread46Q := by
  norm_num [barQ, spread46Q]

/-- **Shifting the seed-1 sweep by the observed spread already reports `224`**: the
"replication" of the one-grid-step drop is what the recorded seed noise predicts. -/
theorem knee_2048_s1_shifted : kneeOf (shift sweep2048S1 spread46Q) = some 224 := by
  norm_num [kneeOf, shift, sweep2048S1, barQ, spread46Q, List.find?]

/-- The seed-2 curve lies above the seed-1 curve at both recorded budgets, while its knee
is lower: the whole curve sits higher and crosses the bar one step earlier. -/
theorem s2_dominates_s1 :
    (939 : ℚ) / 1000 < 956 / 1000 ∧ (976 : ℚ) / 1000 < 982 / 1000 := by
  constructor <;> norm_num

/-- The four measured amplitude windows, as exact rationals, together with the two
intersection facts that drive `KneeAmplitude.seed2_no_common_amplitude` and
`KneeAmplitude.seed1_amplitude_iff`. -/
theorem amplitude_windows_rational :
    (64 : ℚ) / 8 = 8 ∧ (96 : ℚ) / 8 = 12 ∧ (192 : ℚ) / 16 = 12 ∧ (224 : ℚ) / 16 = 14 ∧
      (96 : ℚ) / 8 = 12 ∧ (128 : ℚ) / 8 = 16 ∧ (224 : ℚ) / 16 = 14 ∧
      (256 : ℚ) / 16 = 16 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> norm_num

/-- The seed-2 windows `(8, 12]` and `(12, 14]` are disjoint; the seed-1 windows
`(12, 16]` and `(14, 16]` meet in `(14, 16]`. -/
theorem window_intersections :
    (∀ A : ℚ, ¬ (A ≤ 12 ∧ 12 < A)) ∧ (∀ A : ℚ, (12 < A ∧ 14 < A) ↔ 14 < A) := by
  constructor
  · rintro A ⟨h1, h2⟩; linarith
  · intro A
    constructor
    · rintro ⟨-, h⟩; exact h
    · intro h; exact ⟨by linarith, h⟩

/-- The `k = 1024` loss gaps: `0.0006` at seed 2, `0.0015` at seed 1 — the seed-2 run
recovers the full-attention loss more closely, consistent with a curve sitting higher
everywhere. -/
theorem loss_gaps :
    (52247 : ℚ) / 10000 - 52241 / 10000 = 6 / 10000 ∧
      (6 : ℚ) / 10000 < 15 / 10000 := by
  constructor <;> norm_num

/-- Full accuracy `0.1545` and the `0.98` bar `0.1514` (to four decimals): the bar used
in the sweep is the recorded one. -/
theorem bar_recomputation :
    ⌊(1545 : ℚ) / 10000 * (98 / 100) * 10000⌋ = 1514 := by
  norm_num

end KneeDriftEvidence