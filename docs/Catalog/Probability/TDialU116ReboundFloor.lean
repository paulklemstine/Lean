import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialU120Floor

/-!
# Rebound geometry of a fading dial: affine floors, noise traps, and Aitken floor recovery

## Research context (FACT round-71 #2, exp 553, `U116-MIXED`)

The `T`-dial thread records a pooled Spearman correlation `ρ(T, rate)` as a function of the
bitlen rung.  The recorded ladder is

```
0.5739 → 0.5436 → 0.5005 → 0.4880 → 0.4621 → 0.4847      (U116, exp 553)
                                              ↑ +0.0226 : the FIRST POSITIVE step
```

and the follow-up rung recorded in the sibling file `Algebra.ZeroFitDialU120Floor`
(exp 554, `U120`) reads `0.43636`.

Two *incompatible* generative stories were floated for this thread:

* **pure multiplicative fade** — `ρₖ₊₁ ≤ q ρₖ` with `q < 1`, i.e. a slide to zero.  This is
  the model analysed in `Algebra.ZeroFitDialU120Floor` (`fade_geometric`,
  `fade_below_any_floor`);
* **affine fade to a positive floor with rebound noise** — `ρₖ₊₁ − L ≈ λ (ρₖ − L)`, the model
  suggested by the U116 record ("asymptotic fade with rebound noise toward a floor near
  0.46–0.49").

This file supplies the missing *floor-model* layer and, crucially, the exact logical
relation between the two stories.  The headline is a clean dichotomy: **a positive step is
mathematically impossible under any nonnegative multiplicative fade, and its size is a hard
lower bound for the noise of any monotone affine floor model.**  So the U116 rebound is not
a decoration of either story; it is a quantitative constraint on both.

## Main results

### 1. Affine fade toward a floor
* `AffineFade`, `affineFade_closed_form`, `affineFade_tendsto` — the deterministic model and
  its geometric closed form `ρₖ = L + λᵏ(ρ₀ − L)`, convergent to the floor iff `|λ| < 1`.
* `affineFade_alternates_of_neg` — a *negative* ratio makes consecutive steps alternate in
  sign: rebounds are a **prediction** of the floor model, not an anomaly in it.

### 2. The noise trap
* `NoisyFade`, `noisyFade_trap` — the quantitative trapping estimate
  `|ρₖ − L| ≤ qᵏ|ρ₀ − L| + η/(1−q)` for `|λ| ≤ q < 1`;
* `noisyFade_eventually_band` — the ladder is eventually confined to the band of half-width
  `η/(1−q)` around the floor;
* `noisyFadeOf`, `noisyFadeOf_isNoisyFade`, `noisyFadeOf_trapped` — a converse: *every*
  admissible error sequence is realised by an actual ladder, so the band is the exact
  informational content of the model.

### 3. Rebound dichotomy (the sharp part)
* `multiplicative_fade_no_rebound`, `rebound_refutes_multiplicative` — under `ρₖ₊₁ ≤ qρₖ`
  with `0 ≤ ρₖ` and `q ≤ 1` no step can be positive.  The recorded `+0.0226` therefore
  **refutes** the pure multiplicative law outright: `u116_refutes_multiplicative_fade`.
* `positive_step_above_floor_forces_noise` — in a non-expanding (`λ ≤ 1`) affine floor model
  sitting above its floor, a positive step of size `δ` forces `η ≥ δ`;
  `u116_monotone_model_needs_noise` instantiates this at `δ = 0.0226`.
* `alternating_rebound_realizable` — sharpness: with an oscillatory model the same data are
  reproduced by an explicit ladder with infinitely many positive steps inside the band.

### 4. Aitken floor recovery, applied to the record
* `aitken`, `aitken_eq_floor`, `aitken_ratio_eq` — the `Δ²` extrapolant of three consecutive
  affine-fade rungs recovers the floor **exactly**, and the step ratio recovers `λ`.
* `u116_fitted_ratio_contractive`, `u116_fitted_ratio_alternating` — the fit on the three
  recorded rungs `0.4880, 0.4621, 0.4847` is contractive (`|λ| = 226/259 < 1`) and
  alternating (`λ < 0`).
* `u116_floor_estimate_in_band` — the recovered floor is `2299719/4850000 ≈ 0.474169`,
  **inside the pre-registered `[0.46, 0.49]` floor window**.  This is the file's main
  empirical statement: the rebound rung, far from being noise, is exactly the third datum
  needed to identify a floor, and the identified floor lands in the pre-registered window.
* `u116_predicts_u120_in_band` — the same fit predicts the next rung at `≈ 0.46498`,
  inside the U120 confirmation window `[0.46, 0.53]`.
* `u120_outcome_forces_noise`, `u120_trap_band_exceeds_total_fade` — the honest negative:
  the *recorded* U120 rung `0.43636` misses that prediction by `≈ 0.02862`, so the fitted
  model needs `η ≥ 0.02862`, whose trap band `η/(1−|λ|) ≈ 0.2246` is wider than the entire
  observed fade `0.5739 − 0.4364 = 0.1375`.  A three-point floor fit on this ladder is
  therefore *not* predictive, even though its point estimate landed in the window.

### 5. Bridge to the Gram/pooling geometry
* `corr_limit_abs_le_one` — any floor that a ladder of genuine correlations converges to is
  admissible (`|L| ≤ 1`); with `Algebra.ZeroFitDialU72Parity.abs_corr_le_one`.
* `exists_seed_corr_gt_of_pooled_gt` — contrapositive of
  `Algebra.ZeroFitDialU120Floor.pooled_le_max_corr`: a pooled reading above `R ≥ 0`
  certifies an individual seed above `R`;
* `u116_pooled_certifies_seed` — the recorded pooled `0.4847` certifies a single seed block
  reading above the CI floor `0.4413`, hence a genuine per-seed signal.

## Lab notes (recorded data, exp 553 / exp 554)

```
ladder                : 0.5739 0.5436 0.5005 0.4880 0.4621 0.4847 | 0.43636 (U120)
U116 step             : +0.0226   (first positive step of the ladder)
U116 pooled CI        : [0.4413, 0.5283]
T over count          : +0.1002   paired CI [+0.0481, +0.1461]
three-point Δ² fit    : L = 2299719/4850000 = 0.4741689…,  λ = -226/259 = -0.8725869…
predicted next rung   : 1204297/2590000 = 0.4649795…       recorded next rung : 0.43636
prediction error      : 370623/12950000 = 0.0286195…       trap band η/(1-|λ|) : 0.22462
```
-/

open Finset Filter
open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU120Floor

namespace Catalog.Probability.TDialU116ReboundFloor

/-! ## 1. Affine fade toward a floor -/

/-- A ladder `ρ` performs an **affine fade** toward the floor `L` with ratio `λ` if each rung
is obtained from the previous one by contracting the offset from `L`. -/
def AffineFade (L lam : ℝ) (rho : ℕ → ℝ) : Prop :=
  ∀ k, rho (k + 1) = L + lam * (rho k - L)

/-- Closed form of an affine fade: `ρₖ = L + λᵏ (ρ₀ − L)`. -/
theorem affineFade_closed_form {L lam : ℝ} {rho : ℕ → ℝ} (h : AffineFade L lam rho) (k : ℕ) :
    rho k = L + lam ^ k * (rho 0 - L) := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [h k, ih]
      ring

/-- An affine fade with contractive ratio converges to its floor. -/
theorem affineFade_tendsto {L lam : ℝ} {rho : ℕ → ℝ} (h : AffineFade L lam rho)
    (hlam : |lam| < 1) : Tendsto rho atTop (nhds L) := by
  have h0 : Tendsto (fun k : ℕ => lam ^ k) atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_abs_lt_one hlam
  have h1 : Tendsto (fun k : ℕ => L + lam ^ k * (rho 0 - L)) atTop (nhds (L + 0 * (rho 0 - L))) :=
    tendsto_const_nhds.add (h0.mul_const _)
  simp only [zero_mul, add_zero] at h1
  exact h1.congr fun k => (affineFade_closed_form h k).symm

/-- **Rebounds are predicted by a floor model.**  If the fade ratio is negative and the ladder
does not start exactly at the floor, then consecutive steps alternate in sign: after every
decline there is a rise. -/
theorem affineFade_alternates_of_neg {L lam : ℝ} {rho : ℕ → ℝ} (h : AffineFade L lam rho)
    (hlam : lam < 0) (h0 : rho 0 ≠ L) (k : ℕ) :
    (rho (k + 1) - rho k) * (rho (k + 2) - rho (k + 1)) < 0 := by
  have hd : rho 0 - L ≠ 0 := sub_ne_zero.mpr h0
  have e1 : rho (k + 1) - rho k = (lam - 1) * (lam ^ k * (rho 0 - L)) := by
    rw [affineFade_closed_form h (k + 1), affineFade_closed_form h k]; ring
  have e2 : rho (k + 2) - rho (k + 1) = lam * ((lam - 1) * (lam ^ k * (rho 0 - L))) := by
    rw [affineFade_closed_form h (k + 2), affineFade_closed_form h (k + 1)]; ring
  rw [e1, e2]
  have hne : (lam - 1) * (lam ^ k * (rho 0 - L)) ≠ 0 := by
    have hz : lam ≠ 0 := ne_of_lt hlam
    have hl1 : lam - 1 ≠ 0 := ne_of_lt (by linarith)
    exact mul_ne_zero hl1 (mul_ne_zero (pow_ne_zero _ hz) hd)
  have hsq : 0 < ((lam - 1) * (lam ^ k * (rho 0 - L))) ^ 2 := by positivity
  nlinarith [hsq]

/-! ## 2. The noise trap -/

/-- A ladder performs a **noisy affine fade** toward `L` with ratio `λ` and noise level `η` if
each rung deviates from the affine prediction by at most `η`. -/
def NoisyFade (L lam eta : ℝ) (rho : ℕ → ℝ) : Prop :=
  ∀ k, |rho (k + 1) - (L + lam * (rho k - L))| ≤ eta

/-- The noise level of a noisy fade is nonnegative. -/
theorem NoisyFade.eta_nonneg {L lam eta : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho) :
    0 ≤ eta :=
  le_trans (abs_nonneg _) (h 0)

/-- **Trapping estimate.**  A noisy affine fade with `|λ| ≤ q < 1` satisfies
`|ρₖ − L| ≤ qᵏ |ρ₀ − L| + η/(1 − q)`: the transient decays geometrically and the residual is
the noise band `η/(1 − q)`. -/
theorem noisyFade_trap {L lam eta q : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    (hq0 : 0 ≤ q) (hq1 : q < 1) (hlam : |lam| ≤ q) (k : ℕ) :
    |rho k - L| ≤ q ^ k * |rho 0 - L| + eta / (1 - q) := by
  have hq : 0 < 1 - q := by linarith
  have heta : 0 ≤ eta := h.eta_nonneg
  have hband : 0 ≤ eta / (1 - q) := div_nonneg heta hq.le
  induction k with
  | zero => simpa using hband
  | succ k ih =>
      have e := h k
      have habs : |rho (k + 1) - L|
          ≤ |rho (k + 1) - (L + lam * (rho k - L))| + |lam * (rho k - L)| := by
        have : rho (k + 1) - L
            = (rho (k + 1) - (L + lam * (rho k - L))) + lam * (rho k - L) := by ring
        rw [this]
        exact abs_add_le _ _
      have hmul : |lam * (rho k - L)| ≤ q * (q ^ k * |rho 0 - L| + eta / (1 - q)) := by
        rw [abs_mul]
        exact mul_le_mul hlam ih (abs_nonneg _) hq0
      have hsum : eta + q * (eta / (1 - q)) = eta / (1 - q) := by
        field_simp
        ring
      calc |rho (k + 1) - L| ≤ eta + q * (q ^ k * |rho 0 - L| + eta / (1 - q)) := by
            linarith [habs, e, hmul]
        _ = q ^ (k + 1) * |rho 0 - L| + (eta + q * (eta / (1 - q))) := by ring
        _ = q ^ (k + 1) * |rho 0 - L| + eta / (1 - q) := by rw [hsum]

/-- Eventually, a noisy affine fade lives inside the band of half-width `η/(1−q)` about the
floor, up to any prescribed slack. -/
theorem noisyFade_eventually_band {L lam eta q : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    (hq0 : 0 ≤ q) (hq1 : q < 1) (hlam : |lam| ≤ q) {eps : ℝ} (heps : 0 < eps) :
    ∃ N, ∀ k, N ≤ k → |rho k - L| ≤ eta / (1 - q) + eps := by
  obtain ⟨N, hN⟩ := exists_pow_lt_of_lt_one (show 0 < eps / (|rho 0 - L| + 1) by positivity) hq1
  refine ⟨N, fun k hk => ?_⟩
  have hb := noisyFade_trap h hq0 hq1 hlam k
  have h2 : q ^ k ≤ q ^ N := pow_le_pow_of_le_one hq0 hq1.le hk
  have h3 : q ^ k * |rho 0 - L| ≤ q ^ N * |rho 0 - L| :=
    mul_le_mul_of_nonneg_right h2 (abs_nonneg _)
  have h4 : q ^ N * |rho 0 - L| ≤ eps / (|rho 0 - L| + 1) * |rho 0 - L| :=
    mul_le_mul_of_nonneg_right hN.le (abs_nonneg _)
  have h5 : eps / (|rho 0 - L| + 1) * |rho 0 - L| ≤ eps := by
    rw [div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
    nlinarith [abs_nonneg (rho 0 - L)]
  linarith

/-- The ladder generated from a floor `L`, ratio `λ`, start `r₀` and a prescribed error
sequence `s`. -/
def noisyFadeOf (L lam r0 : ℝ) (s : ℕ → ℝ) : ℕ → ℝ
  | 0 => r0
  | k + 1 => L + lam * (noisyFadeOf L lam r0 s k - L) + s k

/-- Every error sequence bounded by `η` is realised by an actual noisy fade. -/
theorem noisyFadeOf_isNoisyFade {L lam eta r0 : ℝ} {s : ℕ → ℝ} (hs : ∀ k, |s k| ≤ eta) :
    NoisyFade L lam eta (noisyFadeOf L lam r0 s) := by
  intro k
  have : noisyFadeOf L lam r0 s (k + 1)
      - (L + lam * (noisyFadeOf L lam r0 s k - L)) = s k := by
    simp [noisyFadeOf]
  rw [this]
  exact hs k

/-- A realised noisy fade started at the floor never leaves the band `η/(1−|λ|)`. -/
theorem noisyFadeOf_trapped {L lam eta : ℝ} {s : ℕ → ℝ} (hs : ∀ k, |s k| ≤ eta)
    (hlam : |lam| < 1) (k : ℕ) :
    |noisyFadeOf L lam L s k - L| ≤ eta / (1 - |lam|) := by
  have h := noisyFadeOf_isNoisyFade (L := L) (lam := lam) (eta := eta) (r0 := L) hs
  have hb := noisyFade_trap h (abs_nonneg lam) hlam (le_refl _) k
  simpa [noisyFadeOf] using hb

/-! ## 3. The rebound dichotomy -/

/-- Under a nonnegative multiplicative fade with ratio at most one, no step can be positive. -/
theorem multiplicative_fade_no_rebound {q x y : ℝ} (hq : q ≤ 1) (hx : 0 ≤ x)
    (h : y ≤ q * x) : y ≤ x := by
  nlinarith

/-- **A positive step refutes the multiplicative law.**  If a rung is positive and the next
rung is strictly larger, then no ratio `q ≤ 1` can explain the step. -/
theorem rebound_refutes_multiplicative {x y : ℝ} (hx : 0 ≤ x) (hxy : x < y) :
    ∀ q : ℝ, q ≤ 1 → ¬ (y ≤ q * x) := by
  intro q hq hle
  exact absurd (multiplicative_fade_no_rebound hq hx hle) (not_le.mpr hxy)

/-- **A positive step above the floor is a noise certificate.**  In a non-expanding affine
floor model (`λ ≤ 1`) evaluated at a rung sitting above the floor, a step of size `δ > 0`
forces the noise level to satisfy `η ≥ δ`. -/
theorem positive_step_above_floor_forces_noise {L lam eta delta : ℝ} {rho : ℕ → ℝ}
    (h : NoisyFade L lam eta rho) (hlam1 : lam ≤ 1) {k : ℕ}
    (hfloor : L ≤ rho k) (hstep : delta ≤ rho (k + 1) - rho k) : delta ≤ eta := by
  have e := (abs_le.mp (h k)).2
  nlinarith [sub_nonneg.mpr hfloor]

/-- One recorded rung of a noisy fade bounds the noise from below by the prediction error. -/
theorem noisyFade_prediction_error_le_eta {L lam eta : ℝ} {rho : ℕ → ℝ}
    (h : NoisyFade L lam eta rho) (k : ℕ) :
    |rho (k + 1) - (L + lam * (rho k - L))| ≤ eta := h k

/-- **Sharpness of the rebound analysis.**  For every floor `L` and every noise level
`η > 0` there is a ladder that is a noisy fade (ratio `0`), stays inside the band of
half-width `η`, and has infinitely many strictly positive steps.  Rebounds therefore carry
no information beyond the noise level itself. -/
theorem alternating_rebound_realizable (L : ℝ) {eta : ℝ} (heta : 0 < eta) :
    ∃ rho : ℕ → ℝ, NoisyFade L 0 eta rho ∧ (∀ k, |rho k - L| ≤ eta) ∧
      ∀ N, ∃ k, N ≤ k ∧ rho k < rho (k + 1) := by
  refine ⟨fun k => L + eta * (-1) ^ k, ?_, ?_, ?_⟩
  · intro k
    have : L + eta * (-1) ^ (k + 1) - (L + 0 * ((L + eta * (-1) ^ k) - L))
        = eta * (-1) ^ (k + 1) := by ring
    rw [this, abs_mul, abs_pow]
    simp [abs_of_pos heta]
  · intro k
    have : L + eta * (-1) ^ k - L = eta * (-1) ^ k := by ring
    rw [this, abs_mul, abs_pow]
    simp [abs_of_pos heta]
  · intro N
    refine ⟨2 * N + 1, by omega, ?_⟩
    have h1 : ((-1 : ℝ)) ^ (2 * N + 1) = -1 := by
      rw [pow_succ, pow_mul]
      norm_num
    have h2 : ((-1 : ℝ)) ^ (2 * N + 1 + 1) = 1 := by
      rw [pow_succ, h1]
      norm_num
    show L + eta * (-1 : ℝ) ^ (2 * N + 1) < L + eta * (-1 : ℝ) ^ (2 * N + 1 + 1)
    rw [h1, h2]
    linarith

/-! ## 4. Aitken `Δ²` floor recovery -/

/-- The Aitken `Δ²` extrapolant of three consecutive readings. -/
def aitken {K : Type*} [Field K] (a b c : K) : K := a - (b - a) ^ 2 / (c - 2 * b + a)

/-- **Exact floor recovery.**  Three consecutive rungs of an affine fade with ratio `λ ≠ 1`,
started off the floor, determine the floor exactly through the Aitken extrapolant. -/
theorem aitken_eq_floor {L lam : ℝ} {rho : ℕ → ℝ} (h : AffineFade L lam rho) (hlam : lam ≠ 1)
    (h0 : rho 0 ≠ L) : aitken (rho 0) (rho 1) (rho 2) = L := by
  have hd : rho 0 - L ≠ 0 := sub_ne_zero.mpr h0
  have hl : lam - 1 ≠ 0 := sub_ne_zero.mpr hlam
  have h1 : rho 1 = L + lam * (rho 0 - L) := by
    simpa using affineFade_closed_form h 1
  have h2 : rho 2 = L + lam ^ 2 * (rho 0 - L) := affineFade_closed_form h 2
  have hden : rho 2 - 2 * rho 1 + rho 0 = (lam - 1) ^ 2 * (rho 0 - L) := by
    rw [h1, h2]; ring
  have hnum : (rho 1 - rho 0) ^ 2 = (lam - 1) ^ 2 * (rho 0 - L) ^ 2 := by
    rw [h1]; ring
  unfold aitken
  rw [hden, hnum]
  have hne : ((lam - 1) ^ 2 * (rho 0 - L)) ≠ 0 := mul_ne_zero (pow_ne_zero _ hl) hd
  field_simp
  ring

/-- The step ratio of three consecutive rungs recovers the fade ratio. -/
theorem aitken_ratio_eq {L lam : ℝ} {rho : ℕ → ℝ} (h : AffineFade L lam rho) (hlam : lam ≠ 1)
    (h0 : rho 0 ≠ L) : (rho 2 - rho 1) / (rho 1 - rho 0) = lam := by
  have hd : rho 0 - L ≠ 0 := sub_ne_zero.mpr h0
  have hl : lam - 1 ≠ 0 := sub_ne_zero.mpr hlam
  have h1 : rho 1 = L + lam * (rho 0 - L) := by
    simpa using affineFade_closed_form h 1
  have h2 : rho 2 = L + lam ^ 2 * (rho 0 - L) := affineFade_closed_form h 2
  have e1 : rho 1 - rho 0 = (lam - 1) * (rho 0 - L) := by rw [h1]; ring
  have e2 : rho 2 - rho 1 = lam * ((lam - 1) * (rho 0 - L)) := by rw [h1, h2]; ring
  rw [e1, e2]
  field_simp

/-! ## 5. The recorded ladder (exp 553, with the exp 554 follow-up) -/

/-- Rung at bitlen 108 of the recorded ladder. -/
def rungA : ℚ := 4880 / 10000

/-- Rung at bitlen 112 (the ladder minimum before the rebound). -/
def rungB : ℚ := 4621 / 10000

/-- Rung at bitlen 116: the U116 rebound, `+0.0226` above `rungB`. -/
def rungC : ℚ := 4847 / 10000

/-- Rung at bitlen 120 (recorded later, exp 554). -/
def rungD : ℚ := 43636 / 100000

/-- The recorded rebound step. -/
theorem u116_step_positive : rungC - rungB = 226 / 10000 := by
  unfold rungB rungC; norm_num

/-- **The rebound refutes the pure multiplicative fade law.**  No ratio `q ≤ 1` explains the
U116 step, since the previous rung is positive and the step is upward. -/
theorem u116_refutes_multiplicative_fade :
    ∀ q : ℝ, q ≤ 1 → ¬ ((rungC : ℝ) ≤ q * (rungB : ℝ)) := by
  have hb : (0 : ℝ) ≤ (rungB : ℝ) := by
    exact_mod_cast (by unfold rungB; norm_num : (0 : ℚ) ≤ rungB)
  have hc : ((rungB : ℚ) : ℝ) < ((rungC : ℚ) : ℝ) := by
    exact_mod_cast (by unfold rungB rungC; norm_num : (rungB : ℚ) < rungC)
  exact rebound_refutes_multiplicative hb hc

/-- **Any monotone floor model must carry noise at least the size of the rebound.**  If the
ladder is a noisy affine fade with `λ ≤ 1` whose floor lies at or below the U116 rung's
predecessor, then `η ≥ 0.0226`. -/
theorem u116_monotone_model_needs_noise {L lam eta : ℝ} {rho : ℕ → ℝ} {k : ℕ}
    (h : NoisyFade L lam eta rho) (hlam1 : lam ≤ 1)
    (hk : rho k = (rungB : ℝ)) (hk1 : rho (k + 1) = (rungC : ℝ)) (hfloor : L ≤ (rungB : ℝ)) :
    (226 / 10000 : ℝ) ≤ eta := by
  refine positive_step_above_floor_forces_noise h hlam1 (k := k) (by rw [hk]; exact hfloor)
    ?_
  rw [hk, hk1]
  unfold rungB rungC
  norm_num

/-- The three-point `Δ²` floor estimate from the rungs `0.4880, 0.4621, 0.4847`. -/
def floorEstimate : ℚ := aitken rungA rungB rungC

/-- The three-point fade-ratio estimate. -/
def fittedRatio : ℚ := (rungC - rungB) / (rungB - rungA)

/-- The next rung predicted by the fitted affine floor model. -/
def predictedNext : ℚ := floorEstimate + fittedRatio * (rungC - floorEstimate)

/-- The fitted floor in closed form. -/
theorem floorEstimate_value : floorEstimate = 2299719 / 4850000 := by
  unfold floorEstimate aitken rungA rungB rungC; norm_num

/-- The fitted ratio in closed form. -/
theorem fittedRatio_value : fittedRatio = -226 / 259 := by
  unfold fittedRatio rungA rungB rungC; norm_num

/-- **The fit is contractive**: `|λ| < 1`, so the three recorded rungs really do describe a
convergent approach to a floor rather than a divergence. -/
theorem u116_fitted_ratio_contractive : |fittedRatio| < 1 := by
  rw [fittedRatio_value]
  rw [abs_lt]
  constructor <;> norm_num

/-- **The fit is alternating**: `λ < 0`, i.e. the model that fits the record is exactly one
that predicts rebounds (compare `affineFade_alternates_of_neg`). -/
theorem u116_fitted_ratio_alternating : fittedRatio < 0 := by
  rw [fittedRatio_value]; norm_num

/-- **Main empirical statement.**  The floor recovered from the three rungs surrounding the
U116 rebound lies inside the pre-registered floor window `[0.46, 0.49]`. -/
theorem u116_floor_estimate_in_band :
    (46 : ℚ) / 100 ≤ floorEstimate ∧ floorEstimate ≤ 49 / 100 := by
  rw [floorEstimate_value]
  constructor <;> norm_num

/-- The fitted model predicts the next rung inside the U120 confirmation window
`[0.46, 0.53]`. -/
theorem u116_predicts_u120_in_band :
    (46 : ℚ) / 100 ≤ predictedNext ∧ predictedNext ≤ 53 / 100 := by
  have : predictedNext = 1204297 / 2590000 := by
    unfold predictedNext
    rw [floorEstimate_value, fittedRatio_value]
    unfold rungC
    norm_num
  rw [this]
  constructor <;> norm_num

/-- The prediction error against the recorded U120 rung. -/
theorem u120_prediction_error : predictedNext - rungD = 370623 / 12950000 := by
  unfold predictedNext rungD
  rw [floorEstimate_value, fittedRatio_value]
  unfold rungC
  norm_num

/-- **The honest negative.**  Any noisy affine fade realising the fitted floor and ratio and
passing through the recorded U116 and U120 rungs has noise level at least the prediction
error `0.0286…`. -/
theorem u120_outcome_forces_noise {eta : ℝ} {rho : ℕ → ℝ} {k : ℕ}
    (h : NoisyFade ((floorEstimate : ℚ) : ℝ) ((fittedRatio : ℚ) : ℝ) eta rho)
    (hk : rho k = (rungC : ℝ)) (hk1 : rho (k + 1) = (rungD : ℝ)) :
    (2861 / 100000 : ℝ) ≤ eta := by
  have hpred := h k
  rw [hk, hk1] at hpred
  have hval : ((rungD : ℚ) : ℝ)
      - (((floorEstimate : ℚ) : ℝ) + ((fittedRatio : ℚ) : ℝ) * (((rungC : ℚ) : ℝ)
        - ((floorEstimate : ℚ) : ℝ))) = -(370623 / 12950000 : ℝ) := by
    rw [floorEstimate_value, fittedRatio_value]
    unfold rungC rungD
    push_cast
    ring
  rw [hval, abs_neg, abs_of_pos (by norm_num : (0:ℝ) < 370623 / 12950000)] at hpred
  linarith

/-- **The fitted model is not predictive.**  With the noise level forced by the U120 rung, the
trap band `η/(1−|λ|)` of `noisyFade_trap` is wider than `0.2`, hence wider than the entire
recorded fade `0.5739 − 0.4364 = 0.1375`.  A three-point floor fit on this ladder therefore
constrains nothing, notwithstanding that its point estimate landed in the window. -/
theorem u120_trap_band_exceeds_total_fade {eta : ℝ} (heta : (2861 / 100000 : ℝ) ≤ eta) :
    (1375 / 10000 : ℝ) < eta / (1 - |((fittedRatio : ℚ) : ℝ)|) := by
  have hr : ((fittedRatio : ℚ) : ℝ) = -(226 / 259 : ℝ) := by
    rw [fittedRatio_value]; norm_num
  rw [hr, abs_neg, abs_of_pos (by norm_num : (0:ℝ) < 226 / 259)]
  rw [lt_div_iff₀ (by norm_num : (0:ℝ) < 1 - 226 / 259)]
  nlinarith

/-! ## 6. Bridge to the Gram and pooling geometry -/

/-- Any floor that a ladder of genuine correlations converges to is admissible: `|L| ≤ 1`. -/
theorem corr_limit_abs_le_one {n : ℕ} {L : ℝ} {rho : ℕ → ℝ} {u v : ℕ → (Fin n → ℝ)}
    (hu : ∀ k, dot (u k) (u k) ≠ 0) (hv : ∀ k, dot (v k) (v k) ≠ 0)
    (hrho : ∀ k, rho k = corr (u k) (v k)) (hlim : Tendsto rho atTop (nhds L)) :
    |L| ≤ 1 := by
  have habs : Tendsto (fun k => |rho k|) atTop (nhds |L|) := hlim.abs
  refine le_of_tendsto habs ?_
  filter_upwards with k
  rw [hrho k]
  exact abs_corr_le_one _ _ (hu k) (hv k)

/-- **A pooled reading above a threshold certifies a single seed above it.**  Contrapositive of
`Algebra.ZeroFitDialU120Floor.pooled_le_max_corr`: pooling never inflates, so a high pooled
dial is a witness for at least one seed block. -/
theorem exists_seed_corr_gt_of_pooled_gt {m n : ℕ} {u v : Fin m → (Fin n → ℝ)} {R : ℝ}
    (hR : 0 ≤ R) (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hv : 0 < blockNormSq v) (hpool : R < pooledCorr u v) :
    ∃ k, R < corr (u k) (v k) := by
  by_contra hcon
  push_neg at hcon
  exact absurd (pooled_le_max_corr hR hu0 hv0 hu hv hcon) (not_le.mpr hpool)

/-- The recorded U116 pooled reading `0.4847` certifies a seed block reading above the lower
CI endpoint `0.4413`: the dial signal is carried by an individual seed, not manufactured by
concatenation. -/
theorem u116_pooled_certifies_seed {m n : ℕ} {u v : Fin m → (Fin n → ℝ)}
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u) (hv : 0 < blockNormSq v)
    (hpool : (rungC : ℝ) ≤ pooledCorr u v) :
    ∃ k, (4413 / 10000 : ℝ) < corr (u k) (v k) := by
  refine exists_seed_corr_gt_of_pooled_gt (by norm_num) hu0 hv0 hu hv ?_
  have : (4413 / 10000 : ℝ) < (rungC : ℝ) := by unfold rungC; norm_num
  linarith

/-- **H2 as a decorrelation certificate (exp 553).**  The recorded paired advantage of the
trailing-zero statistic `T` over the plain count baseline against the shared response,
`+0.1002`, forces the two statistics to be measurably decorrelated from one another:
`corr(T, count) ≤ 1 - 0.1002²/2 = 0.99498…`.  The bound uses nothing but positivity of the
`3 × 3` Gram matrix of the three vectors. -/
theorem u116_advantage_forces_decorrelation {n : ℕ} {Tv Cv Rv : Fin n → ℝ}
    (hT : dot Tv Tv ≠ 0) (hC : dot Cv Cv ≠ 0) (hR : dot Rv Rv ≠ 0)
    (hadv : (1002 / 10000 : ℝ) ≤ corr Tv Rv - corr Cv Rv) :
    corr Tv Cv ≤ 99498 / 100000 := by
  have hg := corr_gram Tv Cv Rv hT hC hR
  have hTC := abs_le.mp (abs_corr_le_one Tv Cv hT hC)
  have hTR := abs_le.mp (abs_corr_le_one Tv Rv hT hR)
  have hCR := abs_le.mp (abs_corr_le_one Cv Rv hC hR)
  have hmain : corr Tv Cv ≤ 1 - (corr Tv Rv - corr Cv Rv) ^ 2 / 2 := by
    refine corr_le_of_advantage (a := corr Tv Rv) (b := corr Cv Rv) (c := corr Tv Cv)
      ?_ ?_ hTC.1 hTC.2 ?_
    · nlinarith [hTR.1, hTR.2]
    · nlinarith [hCR.1, hCR.2]
    · nlinarith [hg]
  nlinarith [hmain, hadv]

end Catalog.Probability.TDialU116ReboundFloor