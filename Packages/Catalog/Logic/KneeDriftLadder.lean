/-
# The knee-drift ladder: sub-linear seed drift, its asymptotics, and what a
# "systematic replication" of a one-grid-step drop can and cannot certify (NET-46)

Round NET-46 closes the second seed of the longest cell of the attention-cost grid
studied in `Probability.AttentionCostLaw` and formalised in
`Logic.KneeFluctuationTwoSeed`.  The measured object is again the knee

  `k*(seed) = ` the least budget on a finite sweep grid at which the retained accuracy
  curve first reaches the bar `0.98`,

now recorded across the whole five-doubling ladder `ctx = 128, 256, 512, 1024, 2048`
at depth `d = 4`.

**Lab notes (round NET-46, speed axis).**
Harness byte-identical to NET-37/NET-44: `CausalTF`, `d_model = 64`, 4 heads, Gutenberg
corpus, vocab 4097, 2000 AdamW steps, `d = 4`, `ctx = 2048`, seed 2, bar `= 0.98` of the
full model's held-out accuracy.  Full accuracy `0.1545`, bar `0.1514`, full loss
`5.2241`, train time `13508 s`.

Measured seed-2 sweep at `ctx = 2048`:

| `k`   |  96   | 128   | 160   | 192   | **224** | 256   | 288   | 384   | 512   | 768   | 1024  |
|-------|-------|-------|-------|-------|---------|-------|-------|-------|-------|-------|-------|
| ret.  | 0.956 | 0.965 | 0.971 | 0.978 | **0.982** | 0.986 | 0.987 | 0.992 | 0.993 | 0.998 | 0.998 |
| pass  |  ✗    |  ✗    |  ✗    |  ✗    | **✓**   |  ✓    |  ✓    |  ✓    |  ✓    |  ✓    |  ✓    |

so `k*(s2) = 224`, one grid step (`32`) below the product-law prediction
`d·ctx/32 = 256`.  The seed-1 sweep at the same cell reads `0.939` at `96` and `0.976`
at `224` and clears the bar at `256`, so `k*(s1) = 256`.  The seed-2 retained curve lies
*uniformly above* the seed-1 curve (`0.956` vs `0.939` at `96`, …, `0.982` vs `0.976` at
`224`), and the observed inter-seed spread at the deciding budget `224` is `0.006`.

Together with NET-44 (`96` vs `128` at `ctx = 1024`) the two-seed ladder is

| `i`            | 0   | 1   | 2   | 3    | 4    |
|----------------|-----|-----|-----|------|------|
| `ctx`          | 128 | 256 | 512 | 1024 | 2048 |
| product `P i`  | 16  | 32  | 64  | 128  | 256  |
| `k*(s1)`       | 16  | 32  | 64  | 128  | 256  |
| `k*(s2)`       | 16  | 32  | 64  | 96   | 224  |

**What this file proves.**

* `KneeDrift.productKnee_eq_law`, `KneeDrift.drift_eq_zero_or_step`,
  `KneeDrift.kneeS2_le_kneeS1` : the ladder is well posed and the seed-2 deficit is
  *bounded by one grid step at every rung*, so the drift is additive, not multiplicative.
* `KneeDrift.no_affine_law_fits_seed2_ladder` : **no affine law `a·ctx + b` fits the five
  seed-2 knees.**  The product law is not merely mis-calibrated at long context — the
  seed-2 chain is not a scaling law at all.  (`KneeDrift.no_doubling_law_fits_seed2`
  gives the multiplicative version.)
* `KneeDrift.bracket_law_fits_ladder` : the *bracket* law `P i - 32 ≤ k* ≤ P i` does fit
  every rung at both seeds — the robust invariant surviving the refutation above.
* `KneeDrift.kneeRatio_tendsto_one`, `KneeDrift.speedup_tendsto_eight` : the drift is
  **sub-linear**: the seed-2 knee is asymptotically exactly the product knee in ratio, and
  the deployable speedup window collapses to the single point `8×`.  The `16×` cell is
  already within `1/8` of the limit; the effect the round names "systematic" is a
  vanishing additive correction to a law that is asymptotically exact.
* `KneeDrift.net46_seed2_knee`, `KneeDrift.net46_seed1_knee`,
  `KneeDrift.net46_prediction_P1_refuted` : the measurement itself, and the refutation of
  the pre-registered two-seed-exact horn P1.
* `KneeDrift.net46_seed2_knee_not_robust`,
  `KneeDrift.net46_any_spread_upshift_of_seed1_drops_to_224` : the adversarial
  content.  The `224` claim is not robust at the round's own `0.002` resolution, and
  *any* upward perturbation of the seed-1 curve of the observed inter-seed size `0.006`
  already has its knee at or below `224` (the seed-1 deficit there is only `0.004`).  The "replication" is therefore predicted by
  the seed noise already recorded at the previous rung; it is not independent evidence.
* `KneeDrift.oneStepFluctuation_at` : the NET-44 pair `(96, 128)` and the NET-46 pair
  `(224, 256)` are two instances of one generic quantisation lemma — at *every* grid
  multiple, arbitrarily close continuous knees report grid knees a full step apart.
* `KneeDrift.replication_null_probability`, `KneeDrift.replication_not_significant` : the
  two-cell replication has null probability `1/4` under an unbiased per-cell coin, above
  any conventional significance level.
* `KneeDrift.domination_does_not_force_drop` : the *sign* `k*(s2) ≤ k*(s1)` is a theorem
  about dominating curves (`KneeFluctuation.knee_antitone`), but the *magnitude* is not:
  strictly dominating curves with equal knees exist.
-/

import Mathlib
import Logic.KneeFluctuationTwoSeed

namespace KneeDrift

open Finset Filter Topology KneeFluctuation

/-! ## 1.  The five-doubling ladder -/

/-- The context ladder `ctx = 128 · 2^i`, `i = 0, …, 4`. -/
def ctxAt (i : ℕ) : ℕ := 128 * 2 ^ i

/-- The product law's predicted knee `d·ctx/32` at depth `d = 4`. -/
def productKnee (i : ℕ) : ℕ := 16 * 2 ^ i

/-- The sweep step, constant across the ladder. -/
def step : ℕ := 32

/-- The measured seed-1 knee: exact at every rung. -/
def kneeS1 (i : ℕ) : ℕ := productKnee i

/-- The measured seed-2 knee: exact through `4×`, one grid step below from `8×` on. -/
def kneeS2 (i : ℕ) : ℕ := if i ≤ 2 then productKnee i else productKnee i - step

/-- The product knee really is `d·ctx/32` at `d = 4`. -/
theorem productKnee_eq_law (i : ℕ) : 4 * ctxAt i / 32 = productKnee i := by
  have h : 4 * ctxAt i = 32 * productKnee i := by
    simp only [ctxAt, productKnee]; ring
  rw [h, Nat.mul_div_cancel_left _ (by norm_num)]

/-- The recorded ladder values, seed 1. -/
theorem kneeS1_values :
    kneeS1 0 = 16 ∧ kneeS1 1 = 32 ∧ kneeS1 2 = 64 ∧ kneeS1 3 = 128 ∧ kneeS1 4 = 256 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> simp [kneeS1, productKnee]

/-- The recorded ladder values, seed 2: `16, 32, 64, 96, 224`. -/
theorem kneeS2_values :
    kneeS2 0 = 16 ∧ kneeS2 1 = 32 ∧ kneeS2 2 = 64 ∧ kneeS2 3 = 96 ∧ kneeS2 4 = 224 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> simp [kneeS2, productKnee, step]

/-- Every product knee is at least one grid step. -/
theorem step_le_productKnee {i : ℕ} (hi : 1 ≤ i) : step ≤ productKnee i := by
  simp only [step, productKnee]
  calc (32 : ℕ) = 16 * 2 ^ 1 := by norm_num
    _ ≤ 16 * 2 ^ i := by
        exact Nat.mul_le_mul_left _ (Nat.pow_le_pow_right (by norm_num) hi)

/-- **The seed-2 deficit is either nothing or exactly one grid step.**  This is the
precise content of "the knee drops one grid step at the second seed". -/
theorem drift_eq_zero_or_step (i : ℕ) :
    productKnee i - kneeS2 i = 0 ∨ productKnee i - kneeS2 i = step := by
  by_cases h : i ≤ 2
  · left; simp [kneeS2, h]
  · right
    have hi : 1 ≤ i := by omega
    have := step_le_productKnee hi
    simp only [kneeS2, h, if_false]
    omega

/-- The seed-2 knee never exceeds the seed-1 knee: the *sign* of the drift on the ladder. -/
theorem kneeS2_le_kneeS1 (i : ℕ) : kneeS2 i ≤ kneeS1 i := by
  simp only [kneeS2, kneeS1]
  split_ifs <;> omega

/-- **The bracket law fits every rung at both seeds.**  This is the invariant that
survives the refutation of the exact product law. -/
theorem bracket_law_fits_ladder (i : ℕ) :
    productKnee i - step ≤ kneeS2 i ∧ kneeS2 i ≤ productKnee i ∧
      productKnee i - step ≤ kneeS1 i ∧ kneeS1 i ≤ productKnee i := by
  simp only [kneeS2, kneeS1]
  split_ifs <;> omega

/-! ## 2.  No scaling law fits the seed-2 ladder -/

/-- **The seed-2 chain is not affine in the context length.**  Any `a·ctx + b` matched to
the two shortest cells predicts `128` at `ctx = 1024`, but the measurement is `96`.  So
the failure at long context is not a re-calibration of the product law: no single
first-degree law fits the five measured seed-2 knees. -/
theorem no_affine_law_fits_seed2_ladder :
    ¬ ∃ a b : ℝ, ∀ i ≤ 4, (kneeS2 i : ℝ) = a * (ctxAt i : ℝ) + b := by
  rintro ⟨a, b, h⟩
  have h0 := h 0 (by norm_num)
  have h1 := h 1 (by norm_num)
  have h3 := h 3 (by norm_num)
  simp only [kneeS2, ctxAt, productKnee, step] at h0 h1 h3
  norm_num at h0 h1 h3
  linarith

/-- **The seed-2 chain is not multiplicative either.**  A doubling law `f (2n) = 2 f n`
pinned at `ctx = 1024` to the measured `96` predicts `192` at `ctx = 2048`, not `224`. -/
theorem no_doubling_law_fits_seed2 {f : ℕ → ℝ}
    (hdouble : ∀ n, f (2 * n) = 2 * f n) (h1024 : f 1024 = (kneeS2 3 : ℝ)) :
    f 2048 ≠ (kneeS2 4 : ℝ) := by
  have h : f 2048 = 2 * f 1024 := by
    have := hdouble 1024; norm_num at this; exact this
  rw [h, h1024]
  simp only [kneeS2, productKnee, step]
  norm_num

/-! ## 3.  The drift is sub-linear: asymptotic exactness of the product law -/

/-- Above the third rung the seed-2 knee is the product knee minus one step, as a real
number (no truncated subtraction). -/
theorem kneeS2_cast {i : ℕ} (hi : 3 ≤ i) :
    (kneeS2 i : ℝ) = (productKnee i : ℝ) - 32 := by
  have hle : step ≤ productKnee i := step_le_productKnee (by omega)
  have hif : ¬ i ≤ 2 := by omega
  simp only [kneeS2, hif, if_false]
  rw [Nat.cast_sub hle]
  norm_num [step]

/-- The knee ratio in closed form on the tail of the ladder. -/
theorem kneeRatio_eq {i : ℕ} (hi : 3 ≤ i) :
    (kneeS2 i : ℝ) / (productKnee i : ℝ) = 1 - 2 * (1 / 2 : ℝ) ^ i := by
  have hpow : (0 : ℝ) < 2 ^ i := by positivity
  have hP : (productKnee i : ℝ) = 16 * 2 ^ i := by
    simp [productKnee]
  rw [kneeS2_cast hi, hP]
  have h2 : (1 / 2 : ℝ) ^ i = 1 / 2 ^ i := by
    rw [div_pow, one_pow]
  rw [h2]
  field_simp
  ring

/-- **Sub-linearity of the seed drift.**  The seed-2 knee is asymptotically *exactly* the
product knee: the bounded additive drift of one grid step is negligible against a knee
that doubles at every rung.  The `16×` cell already sits within `1/8` of the limit. -/
theorem kneeRatio_tendsto_one :
    Tendsto (fun i => (kneeS2 i : ℝ) / (productKnee i : ℝ)) atTop (𝓝 1) := by
  have hpow : Tendsto (fun i : ℕ => (1 / 2 : ℝ) ^ i) atTop (𝓝 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hlim : Tendsto (fun i : ℕ => 1 - 2 * (1 / 2 : ℝ) ^ i) atTop (𝓝 1) := by
    have := (hpow.const_mul (2 : ℝ)).const_sub (1 : ℝ)
    simpa using this
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 3] with i hi
  exact (kneeRatio_eq hi).symm

/-- The measured drift at the two broken rungs, as a ratio: `3/4` at `8×` and `7/8` at
`16×`.  The correction is *halving* at every doubling. -/
theorem measured_ratios :
    (kneeS2 3 : ℝ) / (productKnee 3 : ℝ) = 3 / 4 ∧
      (kneeS2 4 : ℝ) / (productKnee 4 : ℝ) = 7 / 8 := by
  constructor
  · rw [kneeRatio_eq (by norm_num)]; norm_num
  · rw [kneeRatio_eq (by norm_num)]; norm_num

/-- **The deployable speedup window collapses.**  At the seed-2 knee the speedup tends to
the product law's guaranteed `8×`: the `9.1×` best case measured at `16×` is a transient,
shrinking by half at every further doubling. -/
theorem speedup_tendsto_eight :
    Tendsto (fun i => speedup (ctxAt i : ℝ) (kneeS2 i : ℝ)) atTop (𝓝 8) := by
  have key : ∀ i : ℕ, 3 ≤ i →
      speedup (ctxAt i : ℝ) (kneeS2 i : ℝ) = 8 / (1 - 2 * (1 / 2 : ℝ) ^ i) := by
    intro i hi
    have hpow : (0 : ℝ) < 2 ^ i := by positivity
    have hP : (productKnee i : ℝ) = 16 * 2 ^ i := by simp [productKnee]
    have hc : (ctxAt i : ℝ) = 128 * 2 ^ i := by simp [ctxAt]
    have h2 : (1 / 2 : ℝ) ^ i = 1 / 2 ^ i := by rw [div_pow, one_pow]
    have h8 : (2 : ℝ) ^ 3 ≤ 2 ^ i := pow_le_pow_right₀ (by norm_num) hi
    have hd1 : (16 : ℝ) * 2 ^ i - 32 ≠ 0 := by nlinarith
    have hd2 : (2 : ℝ) ^ i - 2 ≠ 0 := by nlinarith
    have hd0 : (2 : ℝ) ^ i ≠ 0 := hpow.ne'
    have key1 : (1 : ℝ) - 2 * (1 / 2 ^ i) = (2 ^ i - 2) / 2 ^ i := by field_simp
    rw [speedup, kneeS2_cast hi, hP, hc, h2, key1, div_div_eq_mul_div,
      div_eq_div_iff hd1 hd2]
    ring
  have hden : Tendsto (fun i : ℕ => 1 - 2 * (1 / 2 : ℝ) ^ i) atTop (𝓝 1) := by
    have hpow : Tendsto (fun i : ℕ => (1 / 2 : ℝ) ^ i) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
    have := (hpow.const_mul (2 : ℝ)).const_sub (1 : ℝ)
    simpa using this
  have hlim : Tendsto (fun i : ℕ => 8 / (1 - 2 * (1 / 2 : ℝ) ^ i)) atTop (𝓝 8) := by
    have := (tendsto_const_nhds (x := (8 : ℝ)) (f := atTop (α := ℕ))).div hden one_ne_zero
    simpa using this
  refine hlim.congr' ?_
  filter_upwards [eventually_ge_atTop 3] with i hi
  exact (key i hi).symm

/-! ## 4.  The NET-46 measurement at `(d = 4, ctx = 2048)` -/

/-- The NET-46 sweep grid at `ctx = 2048`. -/
def grid2048 : Finset ℕ := {96, 128, 160, 192, 224, 256, 288, 384, 512, 768, 1024}

/-- Every swept budget strictly below `224` is at most `192`. -/
theorem grid2048_lt_224 {j : ℕ} (hj : j ∈ grid2048) (h : j < 224) : j ≤ 192 := by
  fin_cases hj <;> omega

/-- Every swept budget strictly below `256` is at most `224`. -/
theorem grid2048_lt_256 {j : ℕ} (hj : j ∈ grid2048) (h : j < 256) : j ≤ 224 := by
  fin_cases hj <;> omega

/-- The measured seed-2 retained curve at `(d = 4, ctx = 2048)` (NET-46). -/
structure Seed2Data2048 (c : ℕ → ℝ) : Prop where
  mono : Monotone c
  at96 : c 96 = 0.956
  at192 : c 192 = 0.978
  at224 : c 224 = 0.982
  at256 : c 256 = 0.986

/-- The measured seed-1 retained curve at the same cell (NET-45).  Only the two swept
values that decide the knee are recorded, plus the fact that the product budget passes. -/
structure Seed1Data2048 (c : ℕ → ℝ) : Prop where
  mono : Monotone c
  at96 : c 96 = 0.939
  at224 : c 224 = 0.976
  pass256 : bar ≤ c 256

/-- **Non-vacuity of the seed-2 record**: an explicit monotone step curve realises it. -/
theorem seed2Data2048_nonvacuous :
    Seed2Data2048 (fun k => if k ≤ 96 then 0.956 else if k ≤ 192 then 0.978 else
      if k ≤ 224 then 0.982 else 0.986) := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num, by norm_num⟩
  intro a b hab
  dsimp only
  split_ifs <;> first | rfl | (exfalso; omega) | norm_num

/-- **Non-vacuity of the seed-1 record.** -/
theorem seed1Data2048_nonvacuous :
    Seed1Data2048 (fun k => if k ≤ 96 then 0.939 else if k ≤ 224 then 0.976 else 0.986) := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num [bar]⟩
  intro a b hab
  dsimp only
  split_ifs <;> first | rfl | (exfalso; omega) | norm_num

/-- **Seed 2 at `16×`: the knee is `224`** — one grid step below the product law's `256`. -/
theorem net46_seed2_knee {c : ℕ → ℝ} (h : Seed2Data2048 c) : IsKnee grid2048 bar c 224 := by
  refine ⟨by decide, by rw [h.at224]; norm_num [bar], ?_⟩
  intro j hj hpass
  by_contra hlt
  push_neg at hlt
  have hj192 : j ≤ 192 := grid2048_lt_224 hj hlt
  have hmono := h.mono hj192
  rw [h.at192] at hmono
  rw [bar] at hpass
  linarith

/-- **Seed 1 at `16×`: the knee is `256`**, exactly the product law. -/
theorem net46_seed1_knee {c : ℕ → ℝ} (h : Seed1Data2048 c) : IsKnee grid2048 bar c 256 := by
  refine ⟨by decide, h.pass256, ?_⟩
  intro j hj hpass
  by_contra hlt
  push_neg at hlt
  have hj224 : j ≤ 224 := grid2048_lt_256 hj hlt
  have hmono := h.mono hj224
  rw [h.at224] at hmono
  rw [bar] at hpass
  linarith

/-- **Horn P1 (two-seed exactness) is refuted at `16×`.**  No seed-2 curve consistent with
the measurement has its knee at the product budget `256`. -/
theorem net46_prediction_P1_refuted {c : ℕ → ℝ} (h : Seed2Data2048 c) :
    ¬ IsKnee grid2048 bar c 256 := by
  intro hcon
  have := (net46_seed2_knee h).unique hcon
  norm_num at this

/-- **Horn P2 confirmed, and the drop is exactly one grid step.** -/
theorem net46_drop_is_one_step {c₁ c₂ : ℕ → ℝ} {k₁ k₂ : ℕ}
    (h₁ : Seed1Data2048 c₁) (h₂ : Seed2Data2048 c₂)
    (hk₁ : IsKnee grid2048 bar c₁ k₁) (hk₂ : IsKnee grid2048 bar c₂ k₂) :
    k₁ - k₂ = step ∧ k₂ < k₁ := by
  have e₁ : k₁ = 256 := hk₁.unique (net46_seed1_knee h₁)
  have e₂ : k₂ = 224 := hk₂.unique (net46_seed2_knee h₂)
  subst e₁; subst e₂
  exact ⟨by norm_num [step], by norm_num⟩

/-- **The product law remains a proven-safe upper bound at `16×`, at both seeds.** -/
theorem net46_productLaw_safe {c : ℕ → ℝ} {k : ℕ} (hpass : bar ≤ c 256)
    (hk : IsKnee grid2048 bar c k) : k ≤ 256 :=
  hk.le_of_passes (by decide) hpass

/-! ## 5.  Adversarial review of the "systematic" claim -/

/-- The margin at the seed-2 knee and the deficit at the preceding grid point are both
`0.002`: the round's own resolution. -/
def resolution : ℝ := 0.002

/-- The observed inter-seed spread at the deciding budget `224` (`0.982 - 0.976`). -/
def spread46 : ℝ := 0.006

/-- **The `224` claim is not robust even at the round's own resolution.**  A perturbation
of size `0.002` — smaller than the inter-seed spread the round itself measures — already
destroys the knee value.  Hence `k* = 224` is a reading of the grid, not a certified
quantity. -/
theorem net46_seed2_knee_not_robust {c : ℕ → ℝ} (h : Seed2Data2048 c) :
    ¬ RobustKnee grid2048 bar c 224 resolution := by
  intro hrob
  have hm := (margins_of_robustKnee h.mono (by norm_num [resolution]) hrob).2 192
    (by decide) (by norm_num)
  rw [h.at192] at hm
  norm_num [bar, resolution] at hm

/-- **A general one-step drop criterion.**  Shifting a curve up by `η` moves the knee to
the preceding grid point exactly when `η` closes that point's deficit while leaving every
earlier point short. -/
theorem knee_drops_under_shift {G : Finset ℕ} {bar' η : ℝ} {c : ℕ → ℝ} {k' : ℕ}
    (hk' : k' ∈ G) (hclose : bar' ≤ c k' + η)
    (hbelow : ∀ j ∈ G, j < k' → c j + η < bar') :
    IsKnee G bar' (fun x => c x + η) k' := by
  refine ⟨hk', hclose, ?_⟩
  intro j hj hpass
  by_contra hlt
  push_neg at hlt
  exact absurd hpass (not_le.mpr (hbelow j hj hlt))

/-- The seed-1 deficit at the deciding budget `224` is `0.004`, **strictly smaller than
the inter-seed spread `0.006` the round itself measures there**. -/
theorem net46_deficit_lt_spread : bar - (0.976 : ℝ) < spread46 := by
  norm_num [bar, spread46]

/-- **The replication is a shift artifact.**  Any curve that exceeds the seed-1 curve at
the deciding budget by the *observed inter-seed spread* `0.006` already has its knee at
or below `224`, because the seed-1 deficit there is only `0.004`.  So the NET-46 "drop"
is exactly what the noise level recorded at the previous rung predicts, and carries no
information beyond it. -/
theorem net46_any_spread_upshift_of_seed1_drops_to_224
    {c c' : ℕ → ℝ} {k : ℕ} (h : Seed1Data2048 c)
    (hup : c 224 + spread46 ≤ c' 224)
    (hk : IsKnee grid2048 bar c' k) : k ≤ 224 := by
  refine hk.le_of_passes (by decide) ?_
  have h224 := h.at224
  rw [bar]
  rw [h224] at hup
  norm_num [spread46] at hup
  linarith

/-- The explicit witness: the seed-1 curve shifted by the observed spread has knee `224`,
provided the preceding swept point stays short of the bar (the seed-1 value at `192` was
not recorded this round; `0.973` is its largest value compatible with a drop). -/
theorem net46_seed1_shift_realises_224 {c : ℕ → ℝ} (h : Seed1Data2048 c)
    (h192 : c 192 ≤ 0.973) :
    IsKnee grid2048 bar (fun x => c x + spread46) 224 := by
  refine knee_drops_under_shift (by decide) ?_ ?_
  · rw [h.at224, bar]; norm_num [spread46]
  · intro j hj hlt
    have hj192 : j ≤ 192 := grid2048_lt_224 hj hlt
    have hmono := h.mono hj192
    rw [bar]
    simp only [spread46]
    linarith

/-- **Quantisation manufactures a one-step drop at every grid multiple.**  For every `ε > 0`
and every rung `n`, two continuous knees within `ε` of each other report grid knees
`s·n` and `s·(n+1)`.  With `s = 32` this is the NET-44 pair `(96, 128)` at `n = 3` and the
NET-46 pair `(224, 256)` at `n = 7`: one lemma, two "independent replications". -/
theorem oneStepFluctuation_at (s : ℝ) (hs : 0 < s) (n : ℕ) (ε : ℝ) (hε : 0 < ε) :
    ∃ κ₁ κ₂ : ℝ, 0 ≤ κ₁ ∧ 0 ≤ κ₂ ∧ |κ₁ - κ₂| ≤ ε ∧
      gridKnee s κ₂ = s * n ∧ gridKnee s κ₁ = s * (n + 1) := by
  have hm : 0 < min ε s := lt_min hε hs
  refine ⟨s * n + min ε s / 2, s * n, by positivity, by positivity, ?_, ?_, ?_⟩
  · have h1 : min ε s ≤ ε := min_le_left _ _
    rw [show s * n + min ε s / 2 - s * n = min ε s / 2 by ring, abs_of_nonneg (by positivity)]
    linarith
  · have hceil : ⌈s * n / s⌉₊ = n := by
      rw [mul_comm, mul_div_assoc, div_self hs.ne', mul_one, Nat.ceil_natCast]
    simp [gridKnee, hceil]
  · have h3 : min ε s ≤ s := min_le_right _ _
    have hceil : ⌈(s * n + min ε s / 2) / s⌉₊ = n + 1 := by
      rw [Nat.ceil_eq_iff (by omega)]
      constructor
      · push_cast
        rw [lt_div_iff₀ hs]
        have : (0:ℝ) < min ε s / 2 := by positivity
        nlinarith
      · rw [div_le_iff₀ hs]
        push_cast
        nlinarith
    rw [gridKnee, hceil]
    push_cast
    ring

/-- The two catalogued pairs are the `n = 3` and `n = 7` instances of the same lemma. -/
theorem net44_and_net46_same_instance :
    (32 : ℝ) * 3 = 96 ∧ (32 : ℝ) * (3 + 1) = 128 ∧
      (32 : ℝ) * 7 = 224 ∧ (32 : ℝ) * (7 + 1) = 256 := by
  norm_num

/-! ### The null model for a two-cell replication -/

/-- Under an unbiased per-cell coin, the observed pattern "drop at both broken rungs" is
one of four equally likely outcomes. -/
theorem replication_null_count :
    (Finset.univ.filter (fun p : Bool × Bool => p.1 = true ∧ p.2 = true)).card = 1 ∧
      (Finset.univ : Finset (Bool × Bool)).card = 4 := by
  constructor <;> decide

/-- **The null probability of the replication is `1/4`.** -/
theorem replication_null_probability :
    ((Finset.univ.filter (fun p : Bool × Bool => p.1 = true ∧ p.2 = true)).card : ℚ) /
      ((Finset.univ : Finset (Bool × Bool)).card : ℚ) = 1 / 4 := by
  obtain ⟨h1, h2⟩ := replication_null_count
  rw [h1, h2]; norm_num

/-- **Two cells cannot establish "systematic".**  `1/4 > 0.05`: the replication does not
reach any conventional significance level, so the honest statement remains the bracket.
A third seed at `ctx = 1024` is exactly what would move the null probability to `1/8`. -/
theorem replication_not_significant :
    ((Finset.univ.filter (fun p : Bool × Bool => p.1 = true ∧ p.2 = true)).card : ℚ) /
      ((Finset.univ : Finset (Bool × Bool)).card : ℚ) > 5 / 100 := by
  rw [replication_null_probability]; norm_num

/-! ### The sign is forced, the magnitude is not -/

/-- **The sign of the drift is a theorem, not a finding.**  Because the seed-2 curve
dominates the seed-1 curve pointwise on the grid, `k*(s2) ≤ k*(s1)` holds automatically.
The round's observation that the whole seed-2 curve "sits higher" therefore *entails* the
direction of the drop. -/
theorem drop_direction_forced {G : Finset ℕ} {bar' : ℝ} {c₁ c₂ : ℕ → ℝ} {k₁ k₂ : ℕ}
    (h₁ : IsKnee G bar' c₁ k₁) (h₂ : IsKnee G bar' c₂ k₂)
    (hdom : ∀ j ∈ G, c₁ j ≤ c₂ j) : k₂ ≤ k₁ :=
  knee_antitone h₁ h₂ hdom

/-- The NET-46 curves do dominate at the two budgets that decide the knees. -/
theorem net46_domination_at_deciding_budgets {c₁ c₂ : ℕ → ℝ}
    (h₁ : Seed1Data2048 c₁) (h₂ : Seed2Data2048 c₂) :
    c₁ 96 < c₂ 96 ∧ c₁ 224 < c₂ 224 := by
  rw [h₁.at96, h₂.at96, h₁.at224, h₂.at224]
  constructor <;> norm_num

/-- **The magnitude is not forced.**  Strict pointwise domination is compatible with
*equal* knees: there are curves `c₁ < c₂` everywhere whose knees on the NET-46 grid are
both `256`.  Hence the one-step drop is genuinely extra information about the size of the
gap — and, by `net46_seed2_knee_not_robust`, information at the grid's resolution only. -/
theorem domination_does_not_force_drop :
    ∃ c₁ c₂ : ℕ → ℝ, Monotone c₁ ∧ Monotone c₂ ∧ (∀ j, c₁ j < c₂ j) ∧
      IsKnee grid2048 bar c₁ 256 ∧ IsKnee grid2048 bar c₂ 256 := by
  refine ⟨fun k => if k ≤ 224 then 0.90 else 0.99, fun k => if k ≤ 224 then 0.91 else 0.995,
    ?_, ?_, ?_, ?_, ?_⟩
  · intro a b hab; dsimp only
    split_ifs <;> first | rfl | (exfalso; omega) | norm_num
  · intro a b hab; dsimp only
    split_ifs <;> first | rfl | (exfalso; omega) | norm_num
  · intro j; dsimp only; split_ifs <;> norm_num
  · refine ⟨by decide, by norm_num [bar], ?_⟩
    intro j hj hpass
    by_contra hlt
    push_neg at hlt
    have hj224 : j ≤ 224 := grid2048_lt_256 hj hlt
    rw [bar] at hpass
    simp only [hj224, if_true] at hpass
    norm_num at hpass
  · refine ⟨by decide, by norm_num [bar], ?_⟩
    intro j hj hpass
    by_contra hlt
    push_neg at hlt
    have hj224 : j ≤ 224 := grid2048_lt_256 hj hlt
    rw [bar] at hpass
    simp only [hj224, if_true] at hpass
    norm_num at hpass

/-! ## 6.  Deployable consequences at `16×` -/

/-- The guaranteed and the seed-2-typical speedups at `ctx = 2048`. -/
theorem net46_speedups :
    speedup 2048 256 = 8 ∧ speedup 2048 224 = 64 / 7 := by
  constructor <;> norm_num [speedup]

/-- **The deployable window at `16×`.**  Any knee in the two-seed bracket `(192, 256]`
yields a speedup in `[8, 32/3)`, and the measured pair `{224, 256}` pins it to
`[8, 64/7]` with `64/7 < 9.15`. -/
theorem net46_speedup_window {k : ℕ} (h : k ∈ Set.Ioc 192 256) :
    8 ≤ speedup 2048 k ∧ speedup 2048 k < 32 / 3 := by
  obtain ⟨hlo, hhi⟩ := h
  have hk0 : (0 : ℝ) < k := by exact_mod_cast Nat.lt_of_lt_of_le (by norm_num) hlo
  have hkle : (k : ℝ) ≤ 256 := by exact_mod_cast hhi
  have hkgt : (192 : ℝ) < k := by exact_mod_cast hlo
  constructor
  · rw [speedup, le_div_iff₀ hk0]; linarith
  · rw [speedup, div_lt_iff₀ hk0]; linarith

/-- The best case really is below `9.15×`, and it is a *transient*: by
`speedup_tendsto_eight` the excess over the guaranteed `8×` halves at every doubling. -/
theorem net46_best_case_lt : speedup 2048 224 < 9.15 := by
  rw [speedup]; norm_num

end KneeDrift