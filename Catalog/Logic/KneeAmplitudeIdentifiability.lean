/-
# Amplitude identifiability of a knee ladder: the seed-2 chain admits **no** single
# Zipf amplitude, the seed-1 chain admits exactly the window `(14, 16]`, and the two
# surviving seed-2 hypotheses make disjoint predictions at `ctx = 4096` (NET-46, cycle 2)

`Logic.KneeDriftLadder` records the NET-46 measurement and shows that no *affine* law
in the context length fits the five seed-2 knees.  That refutation still leaves the
mechanism of `Probability.AttentionCostLaw` intact: there the knee is
`κ(ctx) = A·d·ctx/δ`, a pure *multiplicative* law with one fitted constant, the Zipf
tail amplitude `A`.  `Logic.KneeFluctuationTwoSeed.net44_amplitude_slack` reads the
NET-44 drop as a `3/4` change in `A`.  The natural rescue of "the law is fine, only `A`
fluctuates between seeds" is therefore:

> **is there a single amplitude `A` that explains *both* seed-2 rungs at once, once
> grid quantisation is taken into account?**

This file answers **no**, and pins the obstruction exactly.

**The measurement, as windows.**  A sweep that reports knee `k` at a rung whose previous
swept budget is `p` places the underlying continuous knee in the half-open window
`(p, k]` (`KneeAmplitude.window_of_isKnee`, proved from `KneeFluctuation.IsKnee` alone —
no continuity assumption).  Writing the rung index `i` for `ctx = 128·2^i`, a
multiplicative law contributes `A·2^i`, so the rung constrains `A` to
`(p/2^i, k/2^i]`:

| round  | seed | rung `i` | `ctx`  | prev `p` | knee `k` | amplitude window |
|--------|------|----------|--------|----------|----------|------------------|
| NET-44 | 1    | 3        | 1024   | 96       | 128      | `(12, 16]`       |
| NET-46 | 1    | 4        | 2048   | 224      | 256      | `(14, 16]`       |
| NET-44 | 2    | 3        | 1024   | 64       | 96       | `(8, 12]`        |
| NET-46 | 2    | 4        | 2048   | 192      | 224      | `(12, 14]`       |

The two seed-1 windows meet in `(14, 16]`, which contains the product law's `A = 16`.
The two seed-2 windows are **disjoint**: `(8, 12] ∩ (12, 14] = ∅`.

**Main results.**

* `KneeAmplitude.seed2_no_common_amplitude` : **no amplitude explains both seed-2 rungs.**
  So the announced "systematic sub-linear drift" cannot be a single re-fitted constant of
  the Zipf mechanism; at most one of the two broken cells can be the law, the other is a
  fluctuation.  This is the formal content of the round's own "the highest-value open
  cell is a third seed at `ctx = 1024`".
* `KneeAmplitude.seed2_each_rung_explainable` : each broken rung *alone* is explainable,
  so the data is exactly *one outlier* away from consistency — the obstruction is a
  genuine two-point conflict, not a degenerate model.
* `KneeAmplitude.seed1_amplitude_iff` : the seed-1 chain is explainable, and the set of
  amplitudes doing so is exactly `(14, 16]` — a sharp identifiability statement, with
  `KneeAmplitude.productLaw_amplitude_explains_seed1` placing the law's `A = 16` in it.
* `KneeAmplitude.seed1_next_rung_prediction`,
  `KneeAmplitude.seed2_hypotheses_disagree_at_next_rung` : the resulting decisive
  experiment at `ctx = 4096`.  Seed 1 predicts a reported knee in `[480, 512]`; the
  `ctx = 1024` seed-2 hypothesis predicts `≤ 384`; the `ctx = 2048` seed-2 hypothesis
  predicts `[416, 448]`.  The three predictions are pairwise separated by at least one
  grid step, so a single `4096` run adjudicates between them.
* `KneeAmplitude.gridKnee_le_of_le`, `KneeAmplitude.le_gridKnee_of_gt` : the general
  two-sided bracketing of the quantisation operator `KneeFluctuation.gridKnee` used
  throughout.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed
import Logic.KneeLawIdentifiability
import Logic.KneeDriftLadder

namespace KneeAmplitude

open Finset KneeFluctuation

/-! ## 1.  From a grid measurement to a window on the continuous knee -/

/-- **The window lemma.**  If a sweep reports knee `k` and `p` is a swept budget below
`k`, then any real threshold `κ` of the (monotone) retained curve — a point where the bar
is reached, below which it never is — lies in `(p, k]`.  Only the order structure of
`IsKnee` is used: no continuity, no differentiability, no model of the curve. -/
theorem window_of_isKnee {G : Finset ℕ} {barv : ℝ} {C : ℝ → ℝ} {k p : ℕ} {κ : ℝ}
    (hmono : Monotone C) (hk : IsKnee G barv (fun n : ℕ => C n) k)
    (hp : p ∈ G) (hpk : p < k)
    (hκ1 : barv ≤ C κ) (hκ2 : ∀ x, x < κ → C x < barv) :
    (p : ℝ) < κ ∧ κ ≤ (k : ℝ) := by
  constructor
  · by_contra hcon
    push_neg at hcon
    have hfail : C p < barv := hk.fails_below hp hpk
    have : barv ≤ C p := hκ1.trans (hmono hcon)
    linarith
  · by_contra hcon
    push_neg at hcon
    have := hκ2 (k : ℝ) hcon
    exact absurd hk.2.1 (not_le.mpr this)

/-- `ExplainsRung p k i A` : the single-amplitude multiplicative law contributing `A·2^i`
at the rung `ctx = 128·2^i` is consistent with a sweep that reported knee `k` there, the
previous swept budget being `p`. -/
def ExplainsRung (p k : ℝ) (i : ℕ) (A : ℝ) : Prop := p < A * 2 ^ i ∧ A * 2 ^ i ≤ k

/-- `ExplainsRung` is exactly the amplitude window `(p/2^i, k/2^i]`. -/
theorem explainsRung_iff (p k : ℝ) (i : ℕ) (A : ℝ) :
    ExplainsRung p k i A ↔ p / 2 ^ i < A ∧ A ≤ k / 2 ^ i := by
  have hpos : (0 : ℝ) < 2 ^ i := by positivity
  rw [ExplainsRung, div_lt_iff₀ hpos, le_div_iff₀ hpos]

/-- The window lemma, packaged: a measured rung constrains the amplitude of any
multiplicative law reproducing it. -/
theorem explainsRung_of_isKnee {G : Finset ℕ} {barv : ℝ} {C : ℝ → ℝ} {k p i : ℕ} {A : ℝ}
    (hmono : Monotone C) (hk : IsKnee G barv (fun n : ℕ => C n) k)
    (hp : p ∈ G) (hpk : p < k)
    (hκ1 : barv ≤ C (A * 2 ^ i)) (hκ2 : ∀ x, x < A * 2 ^ i → C x < barv) :
    ExplainsRung (p : ℝ) (k : ℝ) i A :=
  window_of_isKnee hmono hk hp hpk hκ1 hκ2

/-- The window lemma in the quantisation picture of `KneeFluctuation.gridKnee`: if the
step-`s` sweep reports `k` for the law's value `A·2^i`, then the rung is explained with
`p = k - s`. -/
theorem explainsRung_of_gridKnee {s k A : ℝ} {i : ℕ} (hs : 0 < s) (hA : 0 ≤ A)
    (h : gridKnee s (A * 2 ^ i) = k) : ExplainsRung (k - s) k i A := by
  have hnn : (0 : ℝ) ≤ A * 2 ^ i := by positivity
  exact KneeLaw.true_knee_mem_Ioc hs hnn h

/-! ## 2.  The seed-2 chain admits no single amplitude -/

/-- **The central obstruction.**  The NET-44 seed-2 rung (`ctx = 1024`: knee `96`,
previous swept budget `64`) forces `A ≤ 12`, while the NET-46 seed-2 rung
(`ctx = 2048`: knee `224`, previous swept budget `192`) forces `A > 12`.  Hence **no
amplitude whatsoever explains both seed-2 measurements.**

Consequently the "systematic one-grid-step drop" is *not* a re-calibration of the Zipf
amplitude: a single fluctuating constant cannot produce this pair.  At most one of the
two broken cells reflects the law. -/
theorem seed2_no_common_amplitude :
    ¬ ∃ A : ℝ, ExplainsRung 64 96 3 A ∧ ExplainsRung 192 224 4 A := by
  rintro ⟨A, ⟨-, h3⟩, ⟨h4, -⟩⟩
  norm_num at h3 h4
  linarith

/-- **One outlier suffices.**  Each broken rung is separately explainable — by `A = 10`
at `ctx = 1024` and by `A = 13` at `ctx = 2048` — so the inconsistency above is a genuine
two-point conflict rather than an empty model. -/
theorem seed2_each_rung_explainable :
    ExplainsRung 64 96 3 10 ∧ ExplainsRung 192 224 4 13 := by
  constructor <;> exact ⟨by norm_num, by norm_num⟩

/-- The seed-2 amplitude windows in closed form: `(8, 12]` and `(12, 14]`. -/
theorem seed2_windows (A : ℝ) :
    (ExplainsRung 64 96 3 A ↔ 8 < A ∧ A ≤ 12) ∧
      (ExplainsRung 192 224 4 A ↔ 12 < A ∧ A ≤ 14) := by
  constructor
  · rw [explainsRung_iff]; norm_num
  · rw [explainsRung_iff]; norm_num

/-- The seed-2 windows are disjoint, and the gap closes exactly at `A = 12`: the two
measurements are *adjacent but incompatible*.  This is the sharpest possible statement of
"the second seed drifts" — it drifts by different amounts at the two rungs. -/
theorem seed2_windows_disjoint :
    ∀ A : ℝ, ¬ ((8 < A ∧ A ≤ 12) ∧ (12 < A ∧ A ≤ 14)) := by
  rintro A ⟨⟨-, h1⟩, h2, -⟩
  linarith

/-! ## 3.  The seed-1 chain is explainable, and identifiably so -/

/-- **Sharp identifiability at seed 1.**  An amplitude explains both seed-1 rungs
(`ctx = 1024`: knee `128` after `96`; `ctx = 2048`: knee `256` after `224`) **iff** it
lies in `(14, 16]`.  The seed-1 chain therefore *does* determine the Zipf amplitude — to
within `12.5%`, and the determination is two-sided. -/
theorem seed1_amplitude_iff (A : ℝ) :
    (ExplainsRung 96 128 3 A ∧ ExplainsRung 224 256 4 A) ↔ (14 < A ∧ A ≤ 16) := by
  have e3 : (2 : ℝ) ^ 3 = 8 := by norm_num
  have e4 : (2 : ℝ) ^ 4 = 16 := by norm_num
  simp only [ExplainsRung, e3, e4]
  constructor
  · rintro ⟨⟨-, -⟩, h1, h2⟩
    exact ⟨by linarith, by linarith⟩
  · rintro ⟨h1, h2⟩
    exact ⟨⟨by linarith, by linarith⟩, by linarith, by linarith⟩

/-- The product law's own amplitude `A = 16` (giving `κ = d·ctx/32` exactly) explains the
seed-1 chain: the law survives at seed 1 in the strongest available sense. -/
theorem productLaw_amplitude_explains_seed1 :
    ExplainsRung 96 128 3 16 ∧ ExplainsRung 224 256 4 16 :=
  (seed1_amplitude_iff 16).2 ⟨by norm_num, by norm_num⟩

/-- **Seed 1 and seed 2 cannot share an amplitude either** — already at the `16×` cell,
since `(12, 14]` and `(14, 16]` are disjoint.  So the inter-seed effect is real at the
level of the mechanism's single constant, even though (by `seed2_no_common_amplitude`)
seed 2 has no constant of its own. -/
theorem seeds_share_no_amplitude :
    ¬ ∃ A : ℝ, ExplainsRung 192 224 4 A ∧ ExplainsRung 224 256 4 A := by
  rintro ⟨A, ⟨-, h2⟩, h1, -⟩
  norm_num at h1 h2
  linarith

/-! ## 4.  Bracketing the quantisation operator -/

/-- If the true knee is at most a grid point, the reported grid knee is too. -/
theorem gridKnee_le_of_le {s κ : ℝ} {n : ℕ} (hs : 0 < s) (h : κ ≤ s * n) :
    gridKnee s κ ≤ s * n := by
  have hdiv : κ / s ≤ (n : ℝ) := by
    rw [div_le_iff₀ hs]; linarith [h]
  have hceil : (⌈κ / s⌉₊ : ℝ) ≤ (n : ℝ) := by
    exact_mod_cast Nat.ceil_le.2 hdiv
  rw [gridKnee]
  exact mul_le_mul_of_nonneg_left hceil hs.le

/-- If the true knee exceeds a grid point, the reported grid knee is at least the next
grid point. -/
theorem le_gridKnee_of_gt {s κ : ℝ} {n : ℕ} (hs : 0 < s) (h : s * n < κ) :
    s * (n + 1) ≤ gridKnee s κ := by
  have hdiv : (n : ℝ) < κ / s := by
    rw [lt_div_iff₀ hs]; linarith [h]
  have hlt : n < ⌈κ / s⌉₊ := Nat.lt_ceil.2 hdiv
  have hceil : ((n : ℝ) + 1) ≤ (⌈κ / s⌉₊ : ℝ) := by
    have : (n : ℝ) + 1 = ((n + 1 : ℕ) : ℝ) := by push_cast; ring
    rw [this]
    exact_mod_cast hlt
  rw [gridKnee]
  exact mul_le_mul_of_nonneg_left hceil hs.le

/-- Two-sided bracketing: a knee in the half-open window `(s·n, s·(n+1)]` is reported
exactly as `s·(n+1)`. -/
theorem gridKnee_eq_of_mem_Ioc {s κ : ℝ} {n : ℕ} (hs : 0 < s)
    (hlo : s * n < κ) (hhi : κ ≤ s * (n + 1)) :
    gridKnee s κ = s * (n + 1) := by
  have h1 : s * (n + 1) ≤ gridKnee s κ := le_gridKnee_of_gt hs hlo
  have h2 : gridKnee s κ ≤ s * ((n + 1 : ℕ) : ℝ) := by
    refine gridKnee_le_of_le hs ?_
    push_cast
    linarith
  push_cast at h2
  linarith

/-! ## 5.  The decisive experiment at `ctx = 4096` -/

/-- **Seed-1 prediction at the next rung.**  Any amplitude compatible with the seed-1
chain reports a knee in `[480, 512]` at `ctx = 4096` on the step-`32` grid — i.e. the
product law's `512` is right or exactly one step high, and nothing lower than `480` is
possible. -/
theorem seed1_next_rung_prediction {A : ℝ} (h : 14 < A ∧ A ≤ 16) :
    480 ≤ gridKnee 32 (A * 2 ^ 5) ∧ gridKnee 32 (A * 2 ^ 5) ≤ 512 := by
  obtain ⟨h1, h2⟩ := h
  constructor
  · refine le_trans (by norm_num) (le_gridKnee_of_gt (s := 32) (κ := A * 2 ^ 5) (n := 14)
      (by norm_num) ?_)
    norm_num
    linarith
  · refine le_trans (gridKnee_le_of_le (s := 32) (κ := A * 2 ^ 5) (n := 16) (by norm_num)
      ?_) (by norm_num)
    norm_num
    linarith

/-- **The two surviving seed-2 hypotheses make disjoint predictions.**  If the
`ctx = 1024` rung is the law (`A ∈ (8, 12]`) the `ctx = 4096` sweep must report at most
`384`; if the `ctx = 2048` rung is the law (`A ∈ (12, 14]`) it must report at least `416`.
One run at `4096` therefore adjudicates the conflict of `seed2_no_common_amplitude` — and
by `seed1_next_rung_prediction` a report of `480` or more refutes both seed-2 hypotheses
in favour of the seed-1 amplitude. -/
theorem seed2_hypotheses_disagree_at_next_rung {A₁ A₂ : ℝ}
    (h₁ : 8 < A₁ ∧ A₁ ≤ 12) (h₂ : 12 < A₂ ∧ A₂ ≤ 14) :
    gridKnee 32 (A₁ * 2 ^ 5) ≤ 384 ∧ 416 ≤ gridKnee 32 (A₂ * 2 ^ 5) ∧
      gridKnee 32 (A₂ * 2 ^ 5) ≤ 448 := by
  obtain ⟨-, h1b⟩ := h₁
  obtain ⟨h2a, h2b⟩ := h₂
  refine ⟨?_, ?_, ?_⟩
  · refine le_trans (gridKnee_le_of_le (s := 32) (κ := A₁ * 2 ^ 5) (n := 12) (by norm_num)
      ?_) (by norm_num)
    norm_num
    linarith
  · refine le_trans (by norm_num) (le_gridKnee_of_gt (s := 32) (κ := A₂ * 2 ^ 5) (n := 12)
      (by norm_num) ?_)
    norm_num
    linarith
  · refine le_trans (gridKnee_le_of_le (s := 32) (κ := A₂ * 2 ^ 5) (n := 14) (by norm_num)
      ?_) (by norm_num)
    norm_num
    linarith

/-- **Separation of the three hypotheses.**  The predicted `ctx = 4096` knees of the
seed-1 amplitude, the seed-2 `1024`-rung amplitude and the seed-2 `2048`-rung amplitude
are pairwise separated by at least one grid step `32`.  The next experiment is therefore
*decisive at the grid's own resolution* — unlike the `224`-vs-`256` reading, which by
`KneeDrift.net46_seed2_knee_not_robust` is not. -/
theorem next_rung_three_way_separation {A₀ A₁ A₂ : ℝ}
    (h₀ : 14 < A₀ ∧ A₀ ≤ 16) (h₁ : 8 < A₁ ∧ A₁ ≤ 12) (h₂ : 12 < A₂ ∧ A₂ ≤ 14) :
    gridKnee 32 (A₁ * 2 ^ 5) + 32 ≤ gridKnee 32 (A₂ * 2 ^ 5) ∧
      gridKnee 32 (A₂ * 2 ^ 5) + 32 ≤ gridKnee 32 (A₀ * 2 ^ 5) := by
  obtain ⟨hA, hB, hC⟩ := seed2_hypotheses_disagree_at_next_rung h₁ h₂
  obtain ⟨hD, -⟩ := seed1_next_rung_prediction h₀
  exact ⟨by linarith, by linarith⟩

/-! ## 6.  What the ladder does certify -/

/-- **The safe upper bound survives everything.**  Any amplitude compatible with *any* of
the four measured rungs is at most `16`, so the product-law budget `d·ctx/32` (amplitude
`16`) is never exceeded by the true knee: the law's deployable claim is intact at both
seeds and all rungs, even though its exactness is not. -/
theorem all_measured_amplitudes_le_sixteen {A : ℝ}
    (h : ExplainsRung 64 96 3 A ∨ ExplainsRung 192 224 4 A ∨
      ExplainsRung 96 128 3 A ∨ ExplainsRung 224 256 4 A) : A ≤ 16 := by
  rcases h with ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ | ⟨-, h⟩ <;> norm_num at h <;> linarith

/-- **And a matching lower bound.**  Every measured rung forces `A > 8`, so the true knee
is always at least half the product-law budget: the certified two-sided statement of the
whole two-seed ladder is `A ∈ (8, 16]`, i.e. a deployable speedup between `8×` and `16×`
at every context. -/
theorem all_measured_amplitudes_gt_eight {A : ℝ}
    (h : ExplainsRung 64 96 3 A ∨ ExplainsRung 192 224 4 A ∨
      ExplainsRung 96 128 3 A ∨ ExplainsRung 224 256 4 A) : 8 < A := by
  rcases h with ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩ <;> norm_num at h <;> linarith

/-- The certified amplitude band `(8, 16]` is *attained at both ends by the data*: the
seed-2 `1024` window reaches down to `8` and the seed-1 windows reach up to `16`, so no
narrower band contains all four measured windows. -/
theorem amplitude_band_sharp :
    (∀ ε : ℝ, 0 < ε → ε < 4 → ExplainsRung 64 96 3 (8 + ε)) ∧
      ExplainsRung 224 256 4 16 := by
  refine ⟨fun ε h1 h2 => ⟨by nlinarith, by nlinarith⟩, ?_⟩
  exact ⟨by norm_num, by norm_num⟩

end KneeAmplitude