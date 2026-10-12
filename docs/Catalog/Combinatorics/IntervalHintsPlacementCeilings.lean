/-
# ET-HINTS-FULL (II): placement-structured ceilings (FACT round 40 #4, paper 148, theorem T8)

Min-law prior `P(J = i+1) = (2(M-1-i)+1)/M²` (`J = min(p, q)`, `p, q` uniform), perfect coverage
(`α = 1`): the oracle names the window `{s, …, s+W-1}` and the searcher scans it in ascending
order — the Bayes-optimal order inside the window (`placementCost_eq_optCost`).

## Main results
* **`placementCost_eq`** — exact placement law: with `d = M - s` (distance of the window start
  from the right end), `E = (W+1)(6d - 4W + 1) / (6(2d - W))`.
* **`placementCost_strictAnti`** — moving the window to the right strictly lowers the cost
  (`W ≥ 2`); the right-placed window is the cheapest of all placements.
* `rightCost_eq`, `right_selfSimilar` — the right window reproduces the min-law on `W` cells
  ("truncated `w` reproduces min-of-two-uniforms"): `E = (W+1)(2W+1)/(6W)`.
* **`placementSpeedup_le`** — universal ceiling: *every* placement has speedup `≤ M/W = 1/x`.
* **`placementSpeedup_tendsto`** — with `M = kW` and `d = mW`, the speedup tends to
  `k(2m-1)/(3m-2)`: `k = 1/x` for right (`m = 1`), `(2-x)/(x(3-2x))` for left (`m = k`), and
  `≈ 2/(3x)` for centered windows.
* `best_cell_right_sixteenth` — `M = 256`, right, `x = 1/16`: speedup `∈ (14.68, 14.69)`
  (reported `14.69×`).
* **`leftCommitted_eq`** and `left_crossing_eighth`, `left_crossing_sixtyfourth` — exact trusted
  committed cost for left windows; the `5.19×` crossing at `M = 256` sits in `(0.995, 0.996)` for
  `x = 1/8` and in `(0.836, 0.837)` for `x = 1/64`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (H1) ceiling `2/(3x)` for centered/left windows, `1/x` for right windows;
  (H2) "placement doubles what width buys"; (H3) best cell `14.69×` at right `x = 1/16`;
  (H4) `5.19×` crossing `α* = 0.832 (x=1/64) → 0.996 (x=1/8)`.
Experiment (Stage 2): exact rationals (`M = 256/512/1024`), committed window-first scan:
  `α = 1` speedups at `M = 256`: left/center/right `x = 1/64`: `34.40 / 34.47 / 45.78`;
  `x = 1/8`: `5.32 / 5.42 / 7.68`.  Crossing `5.19×`, left: `x = 1/64`: `0.8367 (256)`,
  `0.8344 (512)`, `0.8332 (1024)`; `x = 1/8`: `0.9957 (256)`, `0.9935 (512)`, `0.9923 (1024)`.
  Right `x = 1/64`: `0.8332 (256)`.  Best cell `M = 256, W = 16`: `2109384/143616 = 14.6877`.
Analysis (Stage 3): (H1) true asymptotically, and both are instances of one placement law
  `k(2m-1)/(3m-2)`.  (H2) the asymptotic right/left ratio is `(3-2x)/(2-x) → 3/2`, not `2`.
  (H3) true exactly at `M = 256`.  (H4) the `x = 1/8` value `0.996` is the left window at
  `M = 256`; the `x = 1/64` value `0.832` matches the continuum (`M → ∞`) or the right
  window, not left at `M = 256` (`0.8367`).
Critique (Stage 4): `1/x` is an exact finite-`M` ceiling over all placements, not just a limit.
-/
import Combinatorics.IntervalHintsHedgingHump

namespace IntervalHintsPlacementCeilings

open Finset Filter Topology IntervalHintsTwoNumbers IntervalHintsHedgingHump

/-! ## 1. Window sums of the min-law -/

lemma sum_minLaw_window (M s W : ℕ) :
    ∑ r ∈ range W, minLaw M (s + r)
      = ((W : ℝ) * (2 * ((M : ℝ) - 1 - s) + 1) - W * (W - 1)) / (M : ℝ) ^ 2 := by
  induction W with
  | zero => simp
  | succ k ih =>
    rw [sum_range_succ, ih]; unfold minLaw; push_cast; ring

lemma sum_pos_minLaw_window (M s W : ℕ) :
    ∑ r ∈ range W, ((r : ℝ) + 1) * minLaw M (s + r)
      = ((2 * ((M : ℝ) - 1 - s) + 1) * (W * (W + 1) / 2)
          - 2 * (((W : ℝ) - 1) * W * (W + 1) / 3)) / (M : ℝ) ^ 2 := by
  rw [← inner_block_sum, sum_div]
  refine sum_congr rfl fun r _ => ?_
  unfold minLaw; push_cast; ring

/-! ## 2. The placement law -/

/-- Expected probes when the oracle names the window `{s, …, s+W-1}` with certainty and the
searcher scans it in ascending order. -/
noncomputable def placementCost (M s W : ℕ) : ℝ :=
  (∑ r ∈ range W, ((r : ℝ) + 1) * minLaw M (s + r)) / ∑ r ∈ range W, minLaw M (s + r)

/-- Ascending scan is Bayes-optimal inside the window: the placement cost is the optimal cost of
the conditional distribution on the `W` window cells. -/
theorem placementCost_eq_optCost (M s W : ℕ) (hsW : s + W ≤ M) :
    placementCost M s W = optCost (fun r : Fin W =>
      minLaw M (s + r) / ∑ r ∈ range W, minLaw M (s + r)) := by
  rcases Nat.eq_zero_or_pos W with rfl | hW
  · simp [placementCost, optCost, probeCost]
  have hM : 0 < M := by omega
  have hZ : 0 < ∑ r ∈ range W, minLaw M (s + r) := by
    refine sum_pos (fun r hr => ?_) ⟨0, by simp [hW]⟩
    unfold minLaw
    have : (s + r : ℕ) + 1 ≤ M := by have := mem_range.1 hr; omega
    have : ((s + r : ℕ) : ℝ) + 1 ≤ M := by exact_mod_cast this
    apply div_pos _ (by positivity); linarith
  rw [optCost_eq_of_antitone _ (Equiv.refl _)]
  · unfold placementCost probeCost
    simp only [Equiv.refl_apply]
    rw [Fin.sum_univ_eq_sum_range (fun i => ((i : ℝ) + 1) *
      (minLaw M (s + i) / ∑ r ∈ range W, minLaw M (s + r))), sum_div]
    exact sum_congr rfl fun r _ => by ring
  · intro i j hij
    simp only [Function.comp_apply, Equiv.refl_apply]
    apply div_le_div_of_nonneg_right _ hZ.le
    exact (minLaw_strictAnti M hM).antitone (Nat.add_le_add_left (show (i : ℕ) ≤ j from hij) s)

/-- **Placement law (T8).**  With `d = M - s`, the cost of the window `{s, …, s+W-1}` is
`(W+1)(6d - 4W + 1) / (6(2d - W))`. -/
theorem placementCost_eq (M s W : ℕ) (hW : 0 < W) (hsW : s + W ≤ M) :
    placementCost M s W
      = ((W : ℝ) + 1) * (6 * ((M : ℝ) - s) - 4 * W + 1) / (6 * (2 * ((M : ℝ) - s) - W)) := by
  unfold placementCost
  rw [sum_pos_minLaw_window, sum_minLaw_window]
  have hM : (0 : ℝ) < M := by exact_mod_cast (show 0 < M by omega)
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have hd : (W : ℝ) ≤ (M : ℝ) - s := by
    have : ((s + W : ℕ) : ℝ) ≤ M := by exact_mod_cast hsW
    push_cast at this; linarith
  have h1 : (2 * ((M : ℝ) - s) - W) ≠ 0 := by nlinarith
  have h2 : ((W : ℝ) * (2 * ((M : ℝ) - 1 - s) + 1) - W * (W - 1)) ≠ 0 := by nlinarith
  rw [div_div_div_cancel_right₀ (by positivity), div_eq_div_iff h2 (by positivity)]
  ring

/-- **Right placement is cheapest.**  For `W ≥ 2`, shifting the window to the right strictly
lowers the cost. -/
theorem placementCost_strictAnti (M s s' W : ℕ) (hW : 2 ≤ W) (hss' : s < s')
    (hs'W : s' + W ≤ M) : placementCost M s' W < placementCost M s W := by
  rw [placementCost_eq M s' W (by omega) hs'W, placementCost_eq M s W (by omega) (by omega)]
  have hW' : (2 : ℝ) ≤ W := by exact_mod_cast hW
  have hd' : (W : ℝ) ≤ (M : ℝ) - s' := by
    have : ((s' + W : ℕ) : ℝ) ≤ M := by exact_mod_cast hs'W
    push_cast at this; linarith
  have hlt : (s : ℝ) < s' := by exact_mod_cast hss'
  rw [div_lt_div_iff₀ (by nlinarith) (by nlinarith)]
  have key : (6 * ((M : ℝ) - s') - 4 * W + 1) * (2 * ((M : ℝ) - s) - W)
      - (6 * ((M : ℝ) - s) - 4 * W + 1) * (2 * ((M : ℝ) - s') - W)
      = -(2 * ((s' : ℝ) - s) * (W - 1)) := by ring
  have hpos : 0 < 2 * ((s' : ℝ) - s) * (W - 1) :=
    mul_pos (mul_pos two_pos (sub_pos.2 hlt)) (by linarith)
  nlinarith [mul_pos (show (0 : ℝ) < W + 1 by linarith) hpos]

/-- Cost is monotone (non-strictly) in placement for every width. -/
theorem placementCost_antitone (M s s' W : ℕ) (hW : 0 < W) (hss' : s ≤ s')
    (hs'W : s' + W ≤ M) : placementCost M s' W ≤ placementCost M s W := by
  rcases Nat.lt_or_ge W 2 with h | h
  · obtain rfl : W = 1 := by omega
    rw [placementCost_eq M s' 1 hW hs'W, placementCost_eq M s 1 hW (by omega)]
    have h1 : (1 : ℝ) ≤ (M : ℝ) - s' := by
      have : ((s' + 1 : ℕ) : ℝ) ≤ M := by exact_mod_cast hs'W
      push_cast at this; linarith
    have h2 : (1 : ℝ) ≤ (M : ℝ) - s := by
      have : (s : ℝ) ≤ s' := by exact_mod_cast hss'
      linarith
    push_cast
    rw [div_le_div_iff₀ (by nlinarith) (by nlinarith)]
    ring_nf; rfl
  · rcases hss'.lt_or_eq with hlt | rfl
    · exact (placementCost_strictAnti M s s' W h hlt hs'W).le
    · exact le_rfl

/-- The right-placed window: cost `(W+1)(2W+1)/(6W)`. -/
theorem rightCost_eq (M W : ℕ) (hW : 0 < W) (hWM : W ≤ M) :
    placementCost M (M - W) W = ((W : ℝ) + 1) * (2 * W + 1) / (6 * W) := by
  rw [placementCost_eq M (M - W) W hW (by omega), Nat.cast_sub hWM]
  have hW' : (W : ℝ) ≠ 0 := by exact_mod_cast hW.ne'
  rw [div_eq_div_iff (by ring_nf; positivity) (by positivity)]
  ring

/-- **Self-similarity.**  Conditioned on the right window, the target is again a
min-of-two-uniforms on the `W` window cells. -/
theorem right_selfSimilar (M W r : ℕ) (hWM : W ≤ M) (hW : 0 < W) :
    minLaw M (M - W + r) / ((W : ℝ) ^ 2 / (M : ℝ) ^ 2) = minLaw W r := by
  have hM : (M : ℝ) ≠ 0 := by exact_mod_cast (show M ≠ 0 by omega)
  have hW' : (W : ℝ) ≠ 0 := by exact_mod_cast hW.ne'
  unfold minLaw
  push_cast [Nat.cast_sub hWM]
  field_simp
  ring

/-- The window mass of the right window is `W²/M²`. -/
theorem right_mass (M W : ℕ) (hWM : W ≤ M) :
    ∑ r ∈ range W, minLaw M (M - W + r) = (W : ℝ) ^ 2 / (M : ℝ) ^ 2 := by
  rw [sum_minLaw_window, Nat.cast_sub hWM]; congr 1; ring

/-- Blind Bayes-optimal cost under the min-law (`minPrior_optCost`). -/
noncomputable def minBlind (M : ℕ) : ℝ := ((M : ℝ) + 1) * (2 * M + 1) / (6 * M)

/-- Speedup of the placed perfect-coverage hint over the optimal blind scan. -/
noncomputable def placementSpeedup (M s W : ℕ) : ℝ := minBlind M / placementCost M s W

theorem minBlind_eq_optCost (M : ℕ) (hM : 0 < M) : minBlind M = optCost (minPrior M) :=
  (minPrior_optCost M hM).symm

/-- **Right-window ceiling.**  `speedup ≤ M / W = 1/x`. -/
theorem rightSpeedup_le (M W : ℕ) (hW : 0 < W) (hWM : W ≤ M) :
    placementSpeedup M (M - W) W ≤ (M : ℝ) / W := by
  unfold placementSpeedup minBlind
  rw [rightCost_eq M W hW hWM]
  have hW' : (1 : ℝ) ≤ W := by exact_mod_cast hW
  have hWM' : (W : ℝ) ≤ M := by exact_mod_cast hWM
  have hM : (0 : ℝ) < M := by linarith
  have hre : ((M : ℝ) + 1) * (2 * M + 1) / (6 * M) / (((W : ℝ) + 1) * (2 * W + 1) / (6 * W))
      = ((M : ℝ) + 1) * (2 * M + 1) * W / (M * ((W + 1) * (2 * W + 1))) := by
    field_simp
  rw [hre, div_le_div_iff₀ (by positivity) (by positivity)]
  have e1 : 0 ≤ 3 * (M : ℝ) * W * (M - W) := by
    have := sub_nonneg.2 hWM'; positivity
  have e2 : (W : ℝ) ^ 2 ≤ (M : ℝ) ^ 2 := pow_le_pow_left₀ (by positivity) hWM' 2
  have h3 : 3 * (M : ℝ) * W ^ 2 + W ^ 2 ≤ 3 * (M : ℝ) ^ 2 * W + M ^ 2 := by nlinarith
  nlinarith

/-- **Universal placement ceiling (T8).**  Whatever the placement, a perfect-coverage window of
width `W` never buys more than `M / W = 1/x`. -/
theorem placementSpeedup_le (M s W : ℕ) (hW : 0 < W) (hsW : s + W ≤ M) :
    placementSpeedup M s W ≤ (M : ℝ) / W := by
  refine le_trans ?_ (rightSpeedup_le M W hW (by omega))
  unfold placementSpeedup
  have hpos : 0 < placementCost M (M - W) W := by
    rw [rightCost_eq M W hW (by omega)]; positivity
  have hM : (0 : ℝ) < minBlind M := by
    unfold minBlind; have : (0 : ℝ) < M := by exact_mod_cast (show 0 < M by omega)
    positivity
  exact div_le_div_of_nonneg_left hM.le hpos
    (placementCost_antitone M s (M - W) W hW (by omega) (by omega))

/-! ## 3. The asymptotic placement law `k(2m-1)/(3m-2)` -/

/-- **Asymptotic placement law.**  With `M = kW` cells and the window starting `d = mW` cells
from the right end (`1 ≤ m ≤ k`), the speedup tends to `k(2m-1)/(3m-2)` as `W → ∞`:
`m = 1` (right) gives `k = 1/x`; `m = k` (left) gives `(2-x)/(x(3-2x))`; `m ≈ k/2` (centered)
gives `≈ 2/(3x)`. -/
theorem placementSpeedup_tendsto (k m : ℕ) (hm : 1 ≤ m) (hmk : m ≤ k) :
    Tendsto (fun W : ℕ => placementSpeedup (k * W) ((k - m) * W) W) atTop
      (𝓝 ((k : ℝ) * (2 * m - 1) / (3 * m - 2))) := by
  have hk : (1 : ℝ) ≤ k := by exact_mod_cast (le_trans hm hmk)
  have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hinv : Tendsto (fun W : ℕ => (1 : ℝ) / W) atTop (𝓝 0) :=
    tendsto_one_div_atTop_nhds_zero_nat
  have hnum : Tendsto (fun W : ℕ => ((k : ℝ) + 1 / W) * (2 * k + 1 / W) * (2 * m - 1)) atTop
      (𝓝 (((k : ℝ) + 0) * (2 * k + 0) * (2 * m - 1))) :=
    (((tendsto_const_nhds.add hinv).mul (tendsto_const_nhds.add hinv))).mul tendsto_const_nhds
  have hden : Tendsto (fun W : ℕ => (k : ℝ) * (1 + 1 / W) * ((6 * m - 4) + 1 / W)) atTop
      (𝓝 ((k : ℝ) * (1 + 0) * ((6 * m - 4) + 0))) :=
    ((tendsto_const_nhds.mul (tendsto_const_nhds.add hinv)).mul (tendsto_const_nhds.add hinv))
  have hq := hnum.div hden (by simp; constructor <;> nlinarith)
  have hval : ((k : ℝ) + 0) * (2 * k + 0) * (2 * m - 1) / ((k : ℝ) * (1 + 0) * ((6 * m - 4) + 0))
      = (k : ℝ) * (2 * m - 1) / (3 * m - 2) := by
    have : (k : ℝ) ≠ 0 := by linarith
    have : (3 * (m : ℝ) - 2) ≠ 0 := by linarith
    have : (6 * (m : ℝ) - 4) ≠ 0 := by linarith
    rw [div_eq_div_iff (by simp; constructor <;> linarith) (by linarith)]
    ring
  rw [hval] at hq
  refine hq.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with W hW
  have hW' : (0 : ℝ) < W := by exact_mod_cast hW
  have hsW : (k - m) * W + W ≤ k * W := by
    have : (k - m) * W + W = (k - m + 1) * W := by ring
    rw [this]; exact Nat.mul_le_mul_right _ (by omega)
  simp only [Pi.div_apply]
  unfold placementSpeedup minBlind
  rw [placementCost_eq _ _ _ hW hsW]
  have hd : ((k * W : ℕ) : ℝ) - ((k - m) * W : ℕ) = m * W := by
    push_cast [Nat.cast_sub hmk]; ring
  rw [hd]
  push_cast
  have h1 : (0 : ℝ) < 2 * (m * W) - W := by nlinarith
  have h2 : (0 : ℝ) < 6 * (m * W) - 4 * W + 1 := by nlinarith
  have hk0 : (k : ℝ) ≠ 0 := by linarith
  have hW0 : (W : ℝ) ≠ 0 := hW'.ne'
  have h3 : (6 * (m : ℝ) - 4) * W + 1 ≠ 0 := by nlinarith
  field_simp

/-- Right windows (`m = 1`): the speedup tends to `k = 1/x`. -/
theorem rightSpeedup_tendsto (k : ℕ) (hk : 1 ≤ k) :
    Tendsto (fun W : ℕ => placementSpeedup (k * W) ((k - 1) * W) W) atTop (𝓝 (k : ℝ)) := by
  have := placementSpeedup_tendsto k 1 le_rfl hk
  norm_num at this
  exact this

/-- In the asymptotic law, the right window is strictly better than every other placement
(`2 ≤ m`), and the left/right ratio tends to `3/2` as `k → ∞`. -/
theorem asymptotic_right_dominates (k m : ℕ) (hm : 2 ≤ m) (hk : 1 ≤ k) :
    (k : ℝ) * (2 * m - 1) / (3 * m - 2) < k := by
  have hm' : (2 : ℝ) ≤ m := by exact_mod_cast hm
  have hk' : (1 : ℝ) ≤ k := by exact_mod_cast hk
  rw [div_lt_iff₀ (by linarith)]
  nlinarith

/-- **Best cell.**  `M = 256`, right window of width `16` (`x = 1/16`), perfect coverage:
speedup `2109384/143616 ∈ (14.68, 14.69)` (reported `14.69×`, ceiling `16`). -/
theorem best_cell_right_sixteenth :
    14.68 < placementSpeedup 256 240 16 ∧ placementSpeedup 256 240 16 < 14.69 := by
  have h := rightCost_eq 256 16 (by norm_num) (by norm_num)
  norm_num at h
  unfold placementSpeedup minBlind
  rw [h]
  norm_num

/-! ## 4. Partial trust, left windows: the `5.19×` crossing -/

/-- The left-placed window: the first `W` cells. -/
def leftWindow (M W : ℕ) : Finset (Fin M) := univ.filter fun j => (j : ℕ) < W

lemma sum_leftWindow (M W : ℕ) (hWM : W ≤ M) (f : ℕ → ℝ) :
    ∑ j ∈ leftWindow M W, f j = ∑ r ∈ range W, f r := by
  unfold leftWindow
  rw [sum_filter, Fin.sum_univ_eq_sum_range (fun i => if i < W then f i else 0), ← sum_filter]
  congr 1
  ext i; simp only [mem_filter, mem_range]; omega

/-- Partial-sum identity behind the min-law mean. -/
lemma minLaw_pos_partial (M N : ℕ) :
    ∑ i ∈ range N, ((i : ℝ) + 1) * minLaw M i
      = N * (N + 1) * ((2 * M + 1) / 2 - (2 * N + 1) / 3) / (M : ℝ) ^ 2 := by
  have h := sum_pos_minLaw_window M 0 N
  simp only [zero_add, Nat.cast_zero, sub_zero] at h
  rw [h]; ring

/-- **Exact trusted committed cost, left window.**  Trusting the left window at level `α` and
scanning in ascending order costs
`α · N_W / P_W + (1 - α)(B - N_W)/(1 - P_W)`, where `P_W = W(2M-W)/M²` is the window mass,
`N_W = W(W+1)((2M+1)/2 - (2W+1)/3)/M²` and `B = (M+1)(2M+1)/(6M)`. -/
theorem leftCommitted_eq (M W : ℕ) (hW : 0 < W) (hWM : W < M) (α : ℝ) :
    probeCost (trustPost (minPrior M) (leftWindow M W) α) (Equiv.refl _)
      = α * ((W * (W + 1) * ((2 * M + 1) / 2 - (2 * W + 1) / 3) / (M : ℝ) ^ 2)
              / (W * (2 * M - W) / (M : ℝ) ^ 2))
        + (1 - α) * ((((M : ℝ) + 1) * (2 * M + 1) / (6 * M)
              - W * (W + 1) * ((2 * M + 1) / 2 - (2 * W + 1) / 3) / (M : ℝ) ^ 2)
              / (1 - W * (2 * M - W) / (M : ℝ) ^ 2)) := by
  have hM : 0 < M := by omega
  rw [committedCost_eq]
  have hmass : windowMass (minPrior M) (leftWindow M W) = W * (2 * M - W) / (M : ℝ) ^ 2 := by
    unfold windowMass minPrior
    rw [sum_leftWindow M W hWM.le (fun j => minLaw M j)]
    unfold minLaw
    rw [← sum_div, minLaw_partial_sum]
  have hin : ∑ j ∈ leftWindow M W, (((j : ℕ) : ℝ) + 1) * minPrior M j
      = W * (W + 1) * ((2 * M + 1) / 2 - (2 * W + 1) / 3) / (M : ℝ) ^ 2 := by
    unfold minPrior
    rw [sum_leftWindow M W hWM.le (fun j => ((j : ℝ) + 1) * minLaw M j), minLaw_pos_partial]
  have htot : ∑ j : Fin M, (((j : ℕ) : ℝ) + 1) * minPrior M j
      = ((M : ℝ) + 1) * (2 * M + 1) / (6 * M) := by
    unfold minPrior
    rw [Fin.sum_univ_eq_sum_range (fun i => ((i : ℝ) + 1) * minLaw M i)]
    exact minLaw_mean M hM
  have hout : ∑ j ∈ (leftWindow M W)ᶜ, (((j : ℕ) : ℝ) + 1) * minPrior M j
      = ((M : ℝ) + 1) * (2 * M + 1) / (6 * M)
        - W * (W + 1) * ((2 * M + 1) / 2 - (2 * W + 1) / 3) / (M : ℝ) ^ 2 := by
    rw [← htot, ← hin, ← sum_add_sum_compl (leftWindow M W)]; ring
  unfold meanIn meanOut
  rw [hmass, hin, hout]

/-- Committed speedup of a trusted left window, against the optimal blind scan. -/
noncomputable def leftTrustSpeedup (M W : ℕ) (α : ℝ) : ℝ :=
  minBlind M / probeCost (trustPost (minPrior M) (leftWindow M W) α) (Equiv.refl _)

/-- **Crossing, `x = 1/8` (`M = 256`, `W = 32`).**  The `5.19×` crossing trust lies in
`(0.995, 0.996)`, and the committed speedup is strictly increasing in trust, so the crossing is
unique: the window must be *near-certain*. -/
theorem left_crossing_eighth :
    leftTrustSpeedup 256 32 0.995 < 5.19 ∧ 5.19 < leftTrustSpeedup 256 32 0.996 ∧
      StrictMono (fun α => -probeCost (trustPost (minPrior 256) (leftWindow 256 32) α)
        (Equiv.refl _)) := by
  unfold leftTrustSpeedup minBlind
  refine ⟨?_, ?_, ?_⟩
  · rw [leftCommitted_eq 256 32 (by norm_num) (by norm_num)]; norm_num
  · rw [leftCommitted_eq 256 32 (by norm_num) (by norm_num)]; norm_num
  · intro a b hab
    simp only
    rw [leftCommitted_eq 256 32 (by norm_num) (by norm_num),
      leftCommitted_eq 256 32 (by norm_num) (by norm_num)]
    norm_num
    nlinarith

/-- **Crossing, `x = 1/64` (`M = 256`, `W = 4`).**  The `5.19×` crossing trust lies in
`(0.836, 0.837)`. -/
theorem left_crossing_sixtyfourth :
    leftTrustSpeedup 256 4 0.836 < 5.19 ∧ 5.19 < leftTrustSpeedup 256 4 0.837 := by
  unfold leftTrustSpeedup minBlind
  constructor
  · rw [leftCommitted_eq 256 4 (by norm_num) (by norm_num)]; norm_num
  · rw [leftCommitted_eq 256 4 (by norm_num) (by norm_num)]; norm_num

end IntervalHintsPlacementCeilings