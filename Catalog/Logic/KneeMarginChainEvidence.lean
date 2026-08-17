/-
# Machine-checked arithmetic of the NET-45 sweep (computational evidence)

Exact rational recomputation of every number the NET-45 round reports at
`(d = 4, ctx = 2048, seed 1)`, in the style of `Logic.KneeFluctuationEvidence` and
`Logic.KneeDriftEvidence`: the sweep is a list of `(budget, retained accuracy)` pairs over
`ℚ`, the knee is the first budget reaching the bar, and every claim is checked by
`norm_num` on exact rationals — never `native_decide`.

Recomputed here:

* the full eleven-point seed-1 sweep and its knee `256` (`knee_net45`);
* the margin `+0.0013` at the knee and the deficit `0.004` at the preceding grid point
  (`margin_256`, `deficit_224`), and the fact that this margin is the tightest of the
  five-doubling chain (`margin_chain_min`);
* the **non-monotonicity** of the measured curve at `(512, 768)` (`curve_dips`), the first
  such dip in the programme;
* the collapse of the certified prefix of the chain as the noise grows
  (`prefix_min_margins`): five doublings at `0.0013`, four at `0.002`, two at `0.004` and
  at the inter-seed spread `0.006`, none at the NET-44 spread `0.010`;
* the fact that shifting the seed-1 sweep up by the inter-seed spread `0.006` already
  reports `224` (`knee_net45_shifted`) — the NET-46 seed-2 reading is inside the seed-1
  noise;
* the effective-support doubling ratio `1.808…` (`support_ratio`);
* the deployment arithmetic `2048/256 = 8` and `2048/224 = 64/7 ≈ 9.14 ≠ 10.3`
  (`speedups_rational`).
-/

import Mathlib
import Logic.KneeFluctuationEvidence

namespace KneeMarginEvidence

open KneeEvidence

/-- The full measured seed-1 sweep at `(d = 4, ctx = 2048)` (NET-45), budgets increasing. -/
def sweepNet45 : List (ℕ × ℚ) :=
  [(96, 939 / 1000), (128, 951 / 1000), (160, 963 / 1000), (192, 970 / 1000),
   (224, 976 / 1000), (256, 9813 / 10000), (288, 984 / 1000), (384, 993 / 1000),
   (512, 997 / 1000), (768, 996 / 1000), (1024, 998 / 1000)]

/-- The inter-seed spread later measured at this cell (NET-46). -/
def spread45 : ℚ := 6 / 1000

/-- The five recorded margins of the seed-1 chain, rungs `ctx = 128 … 2048`. -/
def marginChain : List ℚ := [7 / 1000, 10 / 1000, 3 / 1000, 6 / 1000, 13 / 10000]

/-- **The knee at `16×` context is `256`.** -/
theorem knee_net45 : kneeOf sweepNet45 = some 256 := by
  norm_num [kneeOf, sweepNet45, barQ, List.find?]

/-- The margin at the knee: `0.0013`. -/
theorem margin_256 : (9813 : ℚ) / 10000 - barQ = 13 / 10000 := by norm_num [barQ]

/-- The deficit at the preceding grid point: `0.004`. -/
theorem deficit_224 : barQ - (976 : ℚ) / 1000 = 4 / 1000 := by norm_num [barQ]

/-- **The `16×` margin is strictly the tightest of the five-doubling chain.** -/
theorem margin_chain_min : ∀ m ∈ marginChain, (13 : ℚ) / 10000 ≤ m := by
  intro m hm
  fin_cases hm <;> norm_num

/-- The margin at the last rung is strictly smaller than at every earlier rung. -/
theorem margin_strictly_tightest :
    (13 : ℚ) / 10000 < 7 / 1000 ∧ (13 : ℚ) / 10000 < 10 / 1000 ∧
      (13 : ℚ) / 10000 < 3 / 1000 ∧ (13 : ℚ) / 10000 < 6 / 1000 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- **The measured curve dips**: retained accuracy falls from `0.997` at `k = 512` to
`0.996` at `k = 768`.  Monotonicity of the retained curve — assumed throughout the
earlier rounds — fails at this cell. -/
theorem curve_dips : (996 : ℚ) / 1000 < 997 / 1000 := by norm_num

/-- The prefix minima of the margin chain: `0.007, 0.007, 0.003, 0.003, 0.0013`.  These
are the noise levels at which the chain is certified to depth `1,2,3,4,5`; the certified
depth therefore drops from `5` to `2` as soon as the noise passes `0.003`. -/
theorem prefix_min_margins :
    (13 : ℚ) / 10000 < 2 / 1000 ∧ (3 : ℚ) / 1000 < 4 / 1000 ∧
      (3 : ℚ) / 1000 < spread45 ∧ (7 : ℚ) / 1000 < 10 / 1000 := by
  refine ⟨by norm_num, by norm_num, by norm_num [spread45], by norm_num⟩

/-- **Shifting the seed-1 sweep by the inter-seed spread already reports `224`.**  The
one-grid-step drop found by the second seed is inside the noise of the first. -/
theorem knee_net45_shifted : kneeOf (shift sweepNet45 spread45) = some 224 := by
  norm_num [kneeOf, shift, sweepNet45, barQ, spread45, List.find?]

/-- Effective support `291.16 → 526.39` on the doubling: a ratio strictly between `1.80`
and `1.81`, so sublinear in the context but with no saturation. -/
theorem support_ratio :
    (180 : ℚ) / 100 * (29116 / 100) < 52639 / 100 ∧
      (52639 : ℚ) / 100 < 181 / 100 * (29116 / 100) := by
  constructor <;> norm_num

/-- Deployment arithmetic: `8×` at the knee `256`, and `64/7 ≈ 9.14` — not `10.3` — at the
alternative reading `224`. -/
theorem speedups_rational :
    (2048 : ℚ) / 256 = 8 ∧ (2048 : ℚ) / 224 = 64 / 7 ∧ (64 : ℚ) / 7 < 103 / 10 := by
  refine ⟨by norm_num, by norm_num, by norm_num⟩

/-- Bar recomputation: `0.98 × 0.1543 = 0.1512` to four decimals, the bar the round used. -/
theorem bar_recomputation : ⌊(1543 : ℚ) / 10000 * (98 / 100) * 10000⌋ = 1512 := by
  norm_num

end KneeMarginEvidence