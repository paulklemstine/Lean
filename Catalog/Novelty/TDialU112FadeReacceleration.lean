import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialU120Floor
import Probability.TDialU116ReboundFloor

/-!
# The U112 rung: a sharp decorrelation bound, a noise floor from step-ratio mismatch,
# and a divergent local fit

## Research context (FACT round-70 #1, exp 545, `TDIAL-U112-CONTINUES-FADE`)

The recorded measurement is the fifth rung of the `T`-dial bitlen ladder: the pooled Spearman
rank correlation between a trailing-zero / small-prime-QR statistic `T` of a uniformly drawn
integer and a downstream `rate`.

```
bitlen   :  96      100     104     108     112    | (116)    (120)
rho      :  0.5739  0.5436  0.5005  0.4880  0.4621 | 0.4847   0.43636
step     :         -0.0303 -0.0431 -0.0125 -0.0259 | +0.0226  -0.0483
```

At U112 the pooled reading is `0.462`, CI `[0.415, 0.508]`, per-seed `0.409 / 0.509 / 0.460`;
the entire CI sits below the pre-registered `0.55` band floor for the **second consecutive**
rung, and the paired advantage of `T` over the plain count baseline is `+0.047`, CI
`[0.003, 0.090]` — positive, but for the first time in the ladder below the `+0.05`
decisiveness bar.  The last two rungs (`116`, `120`) are *later* measurements, already
recorded in `Probability.TDialU116ReboundFloor`; this file uses them only to score the
extrapolation that the U112 data licensed at the time.

Earlier files in the thread analyse a *single* pooled number against tie geometry
(`Novelty.ZeroFitDialU64`), Gram geometry (`Algebra.ZeroFitDialU72Parity`), pooling geometry
(`Algebra.ZeroFitDialU120Floor`) and floor identifiability
(`Probability.TDialU116FloorIdentifiability`).  Two questions they leave open are settled
here.

1. `Algebra.ZeroFitDialU120Floor.corr_le_of_advantage` converts a measured advantage
   `a − b = δ` into the decorrelation certificate `c ≤ 1 − δ²/2`.  **Is that bound tight?**
2. The ladder is fitted rung-by-rung by an affine fade.  **How much noise does a single
   `(L, λ)` pair need in order to reproduce five rungs at once?**

## Main results

### 1. The sharp decorrelation bound (Section 2)

* `gram_sub_mul_sq_le` — Gram positivity in the strongest scalar form:
  `(c − a b)² ≤ (1 − a²)(1 − b²)`, i.e. `|c − ab| ≤ √((1−a²)(1−b²))`.  In angle coordinates
  `a = cos α`, `b = cos β` this is exactly `|α − β| ≤ ∠ ≤ α + β`: the spherical triangle
  inequality for the three correlation angles.
* `corr_le_sharp` / `corr_le_sharp_vectors` — hence `c ≤ ab + √((1−a²)(1−b²))`.
* `crude_sub_sharp_identity` — the **exact defect identity**
  `(1 − ab − (a−b)²/2)² − (1−a²)(1−b²) = (a−b)²(a+b)²/4`.
  The previous catalog bound is therefore always weaker, and its slack is governed by the
  product `(a−b)(a+b)` — it is tight only in the degenerate cases `a = ±b`.
* `sharp_le_crude`, `sharp_lt_crude` — the resulting comparison, strict off the degenerate
  locus.
* `sharp_bound_attained` — sharpness: an explicit planar configuration realising
  `corr = a`, `corr = b`, `corr = ab + √((1−a²)(1−b²))` simultaneously.  So no bound
  depending only on `(a, b)` can be better.
* `u112_advantage_forces_decorrelation_sharp`,
  `u112_sharp_beats_crude` — at the recorded `a = 0.462`, `δ = 0.047` the sharp certificate
  reads `corr(T, count) ≤ 0.99864`, strictly stronger than the `0.99889` the old bound gives.

### 2. A noise floor from step-ratio mismatch (Section 3)

* `noisyFade_step_recursion` — the steps `dₖ = ρ_{k+1} − ρₖ` of a noisy affine fade obey
  `|d_{k+1} − λ dₖ| ≤ 2η`.
* `ratio_sub_lam_le`, `noise_lower_bound_of_ratio_mismatch` — eliminating the unknown `λ`
  between two step pairs gives the **model-free noise floor**
  `|d_{i+1}/dᵢ − d_{j+1}/d_j| ≤ 2η (1/|dᵢ| + 1/|d_j|)`.
* `u112_noise_floor` — applied to the five recorded rungs: **any** `(L, λ, η)` noisy affine
  fade reproducing U96…U112 has `η ≥ 73943/7340000 ≈ 0.010074`.  That is 38% of the U112
  step itself: at the recorded resolution the fade *shape* is not identifiable, which is the
  precise content of "the U108 plateau read does not hold".

### 3. Band loss is permanent under any contractive nonnegative model (Section 4)

* `floor_le_of_declining_step` — for a noisy fade with `0 ≤ λ < 1` and a declining step,
  `L ≤ ρ_{k+1} + η/(1−λ)`.
* `u112_floor_below_band` — with `η ≤ 0.02` and `λ ≤ 1/2` the floor obeys `L ≤ 0.5021 < 0.55`:
  the band is lost permanently, not transiently.
* `u112_noise_window_nonempty` — the noise floor of Section 3 and the band-loss hypothesis
  are jointly satisfiable (`0.010074 ≤ η ≤ 0.02`), so the conclusion is not vacuous.

### 4. The U112 local fit diverges, and its scored prediction (Section 5)

* `u112_fitted_ratio_gt_one` — the three-rung ratio at U112 is `259/125 = 2.072 > 1`: the
  local fit is **expansive**, so the Aitken value `686295/1340000 ≈ 0.51216` is not a limit
  but a repelling fixed point.  A fade toward a floor is the wrong local model here.
* `u112_predicted_u116`, `u112_extrapolation_error` — the prediction the U112 record licensed
  for U116 is `≈ 0.40843`, while the recorded U116 rung is `0.4847`: an error of
  `12774356/167500000 ≈ 0.0763`, more than seven times the noise floor of Section 3.
* `u112_extrapolation_error_exceeds_noise_floor` — hence the failure is not attributable to
  the measured noise: the expansive fit is refuted by the data at its own resolution.

### 5. Decisiveness is not a sample-size problem (Section 6)

* `bar_unreachable_of_center_below` — if the point estimate sits below the decisiveness bar,
  no shrinking of the confidence interval (any sample size, any positive width) puts the
  lower endpoint above the bar.
* `u112_advantage_needs_center_shift` — the U112 advantage `0.047 < 0.05` therefore cannot be
  made decisive by replication; the required shift of the point estimate is exactly `0.003`.

## Lab notes (exp 545)

```
pooled Spearman(T, rate)  : 0.462      CI [0.415, 0.508]
per-seed                  : 0.409 / 0.509 / 0.460     seeds 20261210-12
advantage over count      : +0.047     CI [0.003, 0.090]   bar +0.05
band floor                : 0.55       (entire CI below, 2nd consecutive rung)
step delta                : -0.0259    (U108 step -0.0125; fade re-accelerates)
derived noise floor       : 73943/7340000 = 0.0100740      (38% of the U112 step)
derived local ratio       : 259/125 = 2.072 > 1            (expansive, not a fade)
scored U116 prediction    : 68412896/167500000 = 0.408435  vs recorded 0.4847
sharp decorrelation bound : 0.99864    (old bound 0.99890)
```
-/

open Finset
open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU120Floor
open Catalog.Probability.TDialU116ReboundFloor

namespace Catalog.Novelty.TDialU112FadeReacceleration

/-! ## 1. Recorded data -/

/-- Rung U96 of the recorded bitlen ladder. -/
def rungU96 : ℚ := 5739 / 10000
/-- Rung U100 of the recorded bitlen ladder. -/
def rungU100 : ℚ := 5436 / 10000
/-- Rung U104 of the recorded bitlen ladder. -/
def rungU104 : ℚ := 5005 / 10000
/-- Rung U108 of the recorded bitlen ladder. -/
def rungU108 : ℚ := 4880 / 10000
/-- Rung U112 of the recorded bitlen ladder (exp 545). -/
def rungU112 : ℚ := 4621 / 10000
/-- Rung U116, recorded later (exp 553); used only to score the U112 extrapolation. -/
def rungU116 : ℚ := 4847 / 10000

/-- The pre-registered band floor for the dial. -/
def bandFloor : ℚ := 55 / 100
/-- The recorded paired advantage of `T` over the plain count baseline at U112. -/
def advantageU112 : ℚ := 47 / 1000
/-- The decisiveness bar for the paired advantage. -/
def decisivenessBar : ℚ := 5 / 100

/-- **The fade re-accelerates.**  The U112 step is more than twice the U108 step, so the
"plateau" read of U108 is not sustained. -/
theorem u112_step_reaccelerates :
    rungU108 - rungU112 = 259 / 10000 ∧ rungU104 - rungU108 = 125 / 10000 ∧
      2 * (rungU104 - rungU108) < rungU108 - rungU112 := by
  refine ⟨by norm_num [rungU108, rungU112], by norm_num [rungU104, rungU108], ?_⟩
  norm_num [rungU104, rungU108, rungU112]

/-- The whole recorded U112 confidence interval lies below the band floor. -/
theorem u112_ci_below_band : (508 : ℚ) / 1000 < bandFloor := by
  norm_num [bandFloor]

/-! ## 2. The sharp decorrelation bound

Gram positivity for three vectors reads `a² + b² + c² ≤ 1 + 2abc`.  Completing the square in
`c` turns it into a statement about the *distance* of `c` from `ab`, which is the sharp form.
-/

/-- **Gram positivity, completed square form.**  `(c − ab)² ≤ (1 − a²)(1 − b²)`. -/
theorem gram_sub_mul_sq_le {a b c : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    (c - a * b) ^ 2 ≤ (1 - a ^ 2) * (1 - b ^ 2) := by
  nlinarith [hg]

/-- The **sharp decorrelation bound**: `c ≤ ab + √((1−a²)(1−b²))`. -/
theorem corr_le_sharp {a b c : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1)
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) :
    c ≤ a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) := by
  have hnn : 0 ≤ (1 - a ^ 2) * (1 - b ^ 2) := mul_nonneg (by linarith) (by linarith)
  have h := gram_sub_mul_sq_le hg
  have habs : |c - a * b| ≤ Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) := by
    have := Real.sqrt_le_sqrt h
    rwa [Real.sqrt_sq_eq_abs] at this
  have := (abs_le.mp habs).2
  linarith

/-- The same bound for genuine vectors, via `corr_gram`. -/
theorem corr_le_sharp_vectors {n : ℕ} {u v w : Fin n → ℝ}
    (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) (hw : dot w w ≠ 0) :
    corr u v ≤ corr u w * corr v w +
      Real.sqrt ((1 - corr u w ^ 2) * (1 - corr v w ^ 2)) := by
  have hg := corr_gram u v w hu hv hw
  have huw := abs_le.mp (abs_corr_le_one u w hu hw)
  have hvw := abs_le.mp (abs_corr_le_one v w hv hw)
  refine corr_le_sharp (a := corr u w) (b := corr v w) (c := corr u v) ?_ ?_ ?_
  · nlinarith [huw.1, huw.2]
  · nlinarith [hvw.1, hvw.2]
  · nlinarith [hg]

/-- **The exact defect identity.**  The square of the old catalog bound exceeds
`(1 − a²)(1 − b²)` by exactly `(a−b)²(a+b)²/4`.  This is the algebraic reason the old bound
can never be tight away from `a = ±b`. -/
theorem crude_sub_sharp_identity (a b : ℝ) :
    (1 - a * b - (a - b) ^ 2 / 2) ^ 2 - (1 - a ^ 2) * (1 - b ^ 2)
      = (a - b) ^ 2 * (a + b) ^ 2 / 4 := by
  ring

/-- The sharp bound is never worse than `1 − (a−b)²/2`. -/
theorem sharp_le_crude {a b : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1) :
    a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) ≤ 1 - (a - b) ^ 2 / 2 := by
  have hnn : 0 ≤ (1 - a ^ 2) * (1 - b ^ 2) := mul_nonneg (by linarith) (by linarith)
  have hrhs : 0 ≤ 1 - a * b - (a - b) ^ 2 / 2 := by nlinarith [sq_nonneg (a + b)]
  have hsq : (1 - a ^ 2) * (1 - b ^ 2) ≤ (1 - a * b - (a - b) ^ 2 / 2) ^ 2 := by
    nlinarith [sq_nonneg ((a - b) * (a + b))]
  have := Real.sqrt_le_sqrt hsq
  rw [Real.sqrt_sq hrhs] at this
  linarith

/-- Strictness off the degenerate locus `a = ±b`. -/
theorem sharp_lt_crude {a b : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1)
    (hne : (a - b) * (a + b) ≠ 0) :
    a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) < 1 - (a - b) ^ 2 / 2 := by
  have hnn : 0 ≤ (1 - a ^ 2) * (1 - b ^ 2) := mul_nonneg (by linarith) (by linarith)
  have hrhs : 0 ≤ 1 - a * b - (a - b) ^ 2 / 2 := by nlinarith [sq_nonneg (a + b)]
  have hpos : 0 < ((a - b) * (a + b)) ^ 2 := by positivity
  have hsq : (1 - a ^ 2) * (1 - b ^ 2) < (1 - a * b - (a - b) ^ 2 / 2) ^ 2 := by nlinarith
  have := Real.sqrt_lt_sqrt hnn hsq
  rw [Real.sqrt_sq hrhs] at this
  linarith

/-! ### Sharpness: a planar configuration attaining the bound -/

/-- The response direction of the extremal planar configuration. -/
def refVec : Fin 2 → ℝ := ![1, 0]

/-- The unit vector at cosine `t` from `refVec` in the upper half plane. -/
noncomputable def planarVec (t : ℝ) : Fin 2 → ℝ := ![t, Real.sqrt (1 - t ^ 2)]

lemma dot_planar_self {t : ℝ} (ht : t ^ 2 ≤ 1) : dot (planarVec t) (planarVec t) = 1 := by
  have h : (0:ℝ) ≤ 1 - t ^ 2 := by linarith
  simp [dot, planarVec, Fin.sum_univ_two, Real.mul_self_sqrt h]
  ring

lemma dot_ref_self : dot refVec refVec = 1 := by
  simp [dot, refVec, Fin.sum_univ_two]

lemma nrm_planar {t : ℝ} (ht : t ^ 2 ≤ 1) : nrm (planarVec t) = 1 := by
  rw [nrm, dot_planar_self ht, Real.sqrt_one]

lemma nrm_ref : nrm refVec = 1 := by
  rw [nrm, dot_ref_self, Real.sqrt_one]

lemma corr_planar_ref {t : ℝ} (ht : t ^ 2 ≤ 1) : corr (planarVec t) refVec = t := by
  rw [corr, nrm_planar ht, nrm_ref]
  simp [dot, planarVec, refVec, Fin.sum_univ_two]

/-- **Sharpness of the decorrelation bound.**  For any admissible pair of correlations
`(a, b)` there is a configuration of three nonzero vectors whose correlations with the shared
response are exactly `a` and `b` and whose mutual correlation attains
`ab + √((1−a²)(1−b²))`.  Hence no `(a, b)`-only bound improves on `corr_le_sharp`. -/
theorem sharp_bound_attained {a b : ℝ} (ha : a ^ 2 ≤ 1) (hb : b ^ 2 ≤ 1) :
    ∃ u v w : Fin 2 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u w = a ∧ corr v w = b ∧
      corr u v = a * b + Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) := by
  refine ⟨planarVec a, planarVec b, refVec, ?_, ?_, ?_, corr_planar_ref ha, corr_planar_ref hb, ?_⟩
  · rw [dot_planar_self ha]; norm_num
  · rw [dot_planar_self hb]; norm_num
  · rw [dot_ref_self]; norm_num
  · rw [corr, nrm_planar ha, nrm_planar hb]
    have hsq : Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2))
        = Real.sqrt (1 - a ^ 2) * Real.sqrt (1 - b ^ 2) :=
      Real.sqrt_mul (by linarith) _
    simp [dot, planarVec, Fin.sum_univ_two, hsq]

/-! ### The U112 numbers -/

/-- **The sharp certificate at U112.**  With the recorded pooled reading `corr(T, rate) ≥
0.462` and the recorded advantage `+0.047` over the count baseline, the two statistics are
decorrelated at level `corr(T, count) ≤ 0.99864`. -/
theorem u112_advantage_forces_decorrelation_sharp {n : ℕ} {Tv Cv Rv : Fin n → ℝ}
    (hT : dot Tv Tv ≠ 0) (hC : dot Cv Cv ≠ 0) (hR : dot Rv Rv ≠ 0)
    (hpool : (4621 / 10000 : ℝ) ≤ corr Tv Rv)
    (hadv : (47 / 1000 : ℝ) ≤ corr Tv Rv - corr Cv Rv) :
    corr Tv Cv ≤ 99864 / 100000 := by
  set a := corr Tv Rv with hadef
  set b := corr Cv Rv with hbdef
  set c := corr Tv Cv with hcdef
  have hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c) := by
    have := corr_gram Tv Cv Rv hT hC hR
    nlinarith [this]
  have hsq := gram_sub_mul_sq_le hg
  have ha1 := abs_le.mp (abs_corr_le_one Tv Rv hT hR)
  have hb1 := abs_le.mp (abs_corr_le_one Cv Rv hC hR)
  by_contra hcon
  push_neg at hcon
  -- `(c − ab)²` exceeds `(1 − a²)(1 − b²)` at the recorded values, contradicting Gram.
  have hab : a * b ≤ 99864 / 100000 := by nlinarith [ha1.1, ha1.2, hb1.1, hb1.2]
  have hkey : (1 - a ^ 2) * (1 - b ^ 2) ≤ (99864 / 100000 - a * b) ^ 2 := by
    nlinarith [ha1.1, ha1.2, hb1.1, hb1.2, hpool, hadv, sq_nonneg (a - b)]
  nlinarith [hcon, hab, hsq, hkey]

/-- **The sharp bound strictly improves the previous catalog certificate.**  At the recorded
advantage `δ = 0.047` the old bound `1 − δ²/2` reads `0.9988955`; the sharp bound reads
`0.99864`. -/
theorem u112_sharp_beats_crude :
    (99864 / 100000 : ℝ) < 1 - (47 / 1000 : ℝ) ^ 2 / 2 := by
  norm_num

/-! ## 3. A model-free noise floor from step-ratio mismatch -/

/-- The step sequence of a ladder. -/
def step (rho : ℕ → ℝ) (k : ℕ) : ℝ := rho (k + 1) - rho k

/-- **Step recursion of a noisy affine fade.**  Successive steps satisfy
`|d_{k+1} − λ dₖ| ≤ 2η`; the noise enters a step comparison twice, not once. -/
theorem noisyFade_step_recursion {L lam eta : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    (k : ℕ) : |step rho (k + 1) - lam * step rho k| ≤ 2 * eta := by
  have h1 := h (k + 1)
  have h2 := h k
  have hrw : step rho (k + 1) - lam * step rho k
      = (rho (k + 2) - (L + lam * (rho (k + 1) - L)))
        - (rho (k + 1) - (L + lam * (rho k - L))) := by
    simp [step]; ring
  calc |step rho (k + 1) - lam * step rho k|
      ≤ |rho (k + 2) - (L + lam * (rho (k + 1) - L))|
        + |rho (k + 1) - (L + lam * (rho k - L))| := by
        rw [hrw]; exact abs_sub _ _
    _ ≤ 2 * eta := by linarith

/-- The observed step ratio pins the model ratio to within `2η/|dₖ|`. -/
theorem ratio_sub_lam_le {L lam eta : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    {k : ℕ} (hk : step rho k ≠ 0) :
    |step rho (k + 1) / step rho k - lam| ≤ 2 * eta / |step rho k| := by
  have hpos : 0 < |step rho k| := abs_pos.mpr hk
  have hrw : step rho (k + 1) / step rho k - lam
      = (step rho (k + 1) - lam * step rho k) / step rho k := by
    field_simp
  rw [hrw, abs_div]
  gcongr
  exact noisyFade_step_recursion h k

/-- **The model-free noise floor.**  Two step ratios computed from the same ladder must agree
to within the combined noise resolution; any mismatch is a lower bound on `η`. -/
theorem noise_lower_bound_of_ratio_mismatch {L lam eta : ℝ} {rho : ℕ → ℝ}
    (h : NoisyFade L lam eta rho) {i j : ℕ}
    (hi : step rho i ≠ 0) (hj : step rho j ≠ 0) :
    |step rho (i + 1) / step rho i - step rho (j + 1) / step rho j|
      ≤ 2 * eta / |step rho i| + 2 * eta / |step rho j| := by
  have hI := ratio_sub_lam_le h hi
  have hJ := ratio_sub_lam_le h hj
  calc |step rho (i + 1) / step rho i - step rho (j + 1) / step rho j|
      ≤ |step rho (i + 1) / step rho i - lam| + |step rho (j + 1) / step rho j - lam| := by
        have := abs_sub (step rho (i + 1) / step rho i - lam)
          (step rho (j + 1) / step rho j - lam)
        simpa using this
    _ ≤ 2 * eta / |step rho i| + 2 * eta / |step rho j| := add_le_add hI hJ

/-- **The U112 noise floor.**  Any noisy affine fade `(L, λ, η)` reproducing the five recorded
rungs U96…U112 must carry noise `η ≥ 73943/7340000 ≈ 0.010074`.  This is `38%` of the U112
step and three quarters of the U108 step: with a single `(L, λ)` the ladder cannot be fitted
at the resolution at which its steps are being read. -/
theorem u112_noise_floor {L lam eta : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    (h0 : rho 0 = (rungU96 : ℝ)) (h1 : rho 1 = (rungU100 : ℝ))
    (h2 : rho 2 = (rungU104 : ℝ)) (h3 : rho 3 = (rungU108 : ℝ)) :
    73943 / 7340000 ≤ eta := by
  have e0 : step rho 0 = -(303 / 10000 : ℝ) := by
    simp only [step, h0, h1, rungU96, rungU100]; norm_num
  have e1 : step rho 1 = -(431 / 10000 : ℝ) := by
    simp only [step, h1, h2, rungU100, rungU104]; norm_num
  have e2 : step rho 2 = -(125 / 10000 : ℝ) := by
    simp only [step, h2, h3, rungU104, rungU108]; norm_num
  have hA := noisyFade_step_recursion h 0
  have hB := noisyFade_step_recursion h 1
  rw [show (0 : ℕ) + 1 = 1 from rfl, e0, e1] at hA
  rw [show (1 : ℕ) + 1 = 2 from rfl, e1, e2] at hB
  have hA' := abs_le.mp hA
  have hB' := abs_le.mp hB
  -- eliminate `lam` : 431 · (first) + 303 · (second)
  linarith [hA'.1, hA'.2, hB'.1, hB'.2]

/-- The noise floor is a substantial fraction of the very step it is meant to explain. -/
theorem u112_noise_floor_vs_step :
    (38 : ℚ) / 100 * (259 / 10000) < 73943 / 7340000 ∧
      73943 / 7340000 < (2 : ℚ) / 100 := by
  constructor <;> norm_num

/-! ## 4. Band loss is permanent under any contractive nonnegative model -/

/-- **The floor sits below a declining rung.**  For a noisy affine fade with `0 ≤ λ < 1`, one
declining step already forces `L ≤ ρ_{k+1} + η/(1−λ)`. -/
theorem floor_le_of_declining_step {L lam eta : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    (hlam0 : 0 ≤ lam) (hlam1 : lam < 1) {k : ℕ} (hdec : rho (k + 1) ≤ rho k) :
    L ≤ rho (k + 1) + eta / (1 - lam) := by
  have hpos : 0 < 1 - lam := by linarith
  have hk := abs_le.mp (h k)
  -- `ρ_{k+1} = L + λ(ρ_k − L) + s` with `|s| ≤ η`; monotonicity absorbs `λ ρ_k`.
  have hprod : 0 ≤ lam * (rho k - rho (k + 1)) := mul_nonneg hlam0 (by linarith)
  have hL : L - lam * L ≤ rho (k + 1) - lam * rho (k + 1) + eta := by nlinarith [hk.1, hprod]
  have hdiff : L - rho (k + 1) ≤ eta / (1 - lam) := by
    rw [le_div_iff₀ hpos]
    nlinarith [hL]
  linarith

/-- **Band loss is permanent.**  If the U112 ladder is a noisy affine fade with a nonnegative
contractive ratio `λ ≤ 1/2` and noise no larger than `η ≤ 0.02`, then its floor satisfies
`L ≤ 0.5021`, strictly below the pre-registered band floor `0.55`.  So the two consecutive
sub-band rungs are not a transient: the model's limit is out of band as well. -/
theorem u112_floor_below_band {L lam eta : ℝ} {rho : ℕ → ℝ} (h : NoisyFade L lam eta rho)
    (hlam0 : 0 ≤ lam) (hlam1 : lam ≤ 1 / 2) (heta : eta ≤ 2 / 100)
    (h3 : rho 3 = (rungU108 : ℝ)) (h4 : rho 4 = (rungU112 : ℝ)) :
    L ≤ 5021 / 10000 ∧ (5021 / 10000 : ℝ) < (bandFloor : ℝ) := by
  have hdec : rho (3 + 1) ≤ rho 3 := by
    rw [show (3 : ℕ) + 1 = 4 from rfl, h3, h4, rungU108, rungU112]; norm_num
  have hmain := floor_le_of_declining_step h hlam0 (by linarith) hdec
  rw [show (3 : ℕ) + 1 = 4 from rfl, h4, rungU112] at hmain
  have hpos : 0 < 1 - lam := by linarith
  have hband : eta / (1 - lam) ≤ 4 / 100 := by
    rw [div_le_iff₀ hpos]
    nlinarith [h.eta_nonneg]
  constructor
  · push_cast at hmain ⊢
    linarith
  · norm_num [bandFloor]

/-- The hypotheses of `u112_floor_below_band` are compatible with the noise floor of
Section 3: the admissible noise window `[0.010074, 0.02]` is nonempty, so the band-loss
conclusion is not vacuous. -/
theorem u112_noise_window_nonempty :
    ∃ eta : ℚ, 73943 / 7340000 ≤ eta ∧ eta ≤ 2 / 100 := by
  exact ⟨15 / 1000, by norm_num, by norm_num⟩

/-! ## 5. The U112 local fit is expansive, and its prediction is refuted -/

/-- The three-rung ratio fitted at U112 from `(U104, U108, U112)`. -/
def fittedRatio112 : ℚ := (rungU112 - rungU108) / (rungU108 - rungU104)

/-- The Aitken `Δ²` extrapolate of the U112 triple. -/
def floorEstimate112 : ℚ := aitken rungU104 rungU108 rungU112

/-- The rung that the U112 record predicted for U116. -/
def predictedU116 : ℚ := floorEstimate112 + fittedRatio112 * (rungU112 - floorEstimate112)

theorem fittedRatio112_value : fittedRatio112 = 259 / 125 := by
  norm_num [fittedRatio112, rungU104, rungU108, rungU112]

/-- **The local fit is expansive.**  Unlike every earlier rung, the U112 triple fits a ratio
`> 1`: the Aitken value is a repelling fixed point, not a floor.  Any "fade toward a floor"
reading of the U112 data is therefore locally inconsistent. -/
theorem u112_fitted_ratio_gt_one : 1 < fittedRatio112 := by
  rw [fittedRatio112_value]; norm_num

/-- Consequently the Aitken value lies *above* all three rungs it was fitted from. -/
theorem u112_aitken_above_rungs :
    floorEstimate112 = 686295 / 1340000 ∧ rungU104 < floorEstimate112 := by
  constructor
  · norm_num [floorEstimate112, aitken, rungU104, rungU108, rungU112]
  · norm_num [floorEstimate112, aitken, rungU104, rungU108, rungU112]

theorem u112_predicted_u116 : predictedU116 = 68412896 / 167500000 := by
  norm_num [predictedU116, floorEstimate112, fittedRatio112, aitken,
    rungU104, rungU108, rungU112]

/-- **Scoring the prediction.**  The recorded U116 rung is `0.4847`; the U112 extrapolation
missed it by `95331/1250000 ≈ 0.0763`. -/
theorem u112_extrapolation_error : rungU116 - predictedU116 = 95331 / 1250000 := by
  norm_num [rungU116, predictedU116, floorEstimate112, fittedRatio112, aitken,
    rungU104, rungU108, rungU112]

/-- **The failure is not attributable to noise.**  The extrapolation error exceeds the
model-free noise floor of Section 3 by a factor greater than seven, so the expansive local fit
is refuted at the resolution the experiment itself supports. -/
theorem u112_extrapolation_error_exceeds_noise_floor :
    7 * (73943 / 7340000 : ℚ) < rungU116 - predictedU116 := by
  rw [u112_extrapolation_error]; norm_num

/-! ## 6. Decisiveness is not a sample-size problem -/

/-- **A bar below the point estimate is unreachable by replication.**  If the point estimate
`c` lies strictly below the bar `B`, then for every sample size `m ≥ 1` and every positive
interval half-width `w`, the lower confidence endpoint `c − w/√m` stays below `B`. -/
theorem bar_unreachable_of_center_below {c B w : ℝ} (hcB : c < B) (hw : 0 ≤ w)
    (m : ℕ) (hm : 1 ≤ m) :
    c - w / Real.sqrt m < B := by
  have hs : 0 < Real.sqrt m := Real.sqrt_pos.mpr (by exact_mod_cast hm)
  have : 0 ≤ w / Real.sqrt m := div_nonneg hw hs.le
  linarith

/-- **The U112 advantage cannot be made decisive by more seeds.**  The point estimate `0.047`
sits below the `0.05` bar; decisiveness requires a shift of the estimate by at least `0.003`,
not a narrower interval. -/
theorem u112_advantage_needs_center_shift :
    advantageU112 < decisivenessBar ∧ decisivenessBar - advantageU112 = 3 / 1000 ∧
      ∀ (w : ℝ), 0 ≤ w → ∀ m : ℕ, 1 ≤ m →
        (advantageU112 : ℝ) - w / Real.sqrt m < (decisivenessBar : ℝ) := by
  refine ⟨by norm_num [advantageU112, decisivenessBar],
    by norm_num [advantageU112, decisivenessBar], fun w hw m hm => ?_⟩
  refine bar_unreachable_of_center_below ?_ hw m hm
  norm_num [advantageU112, decisivenessBar]

/-- **The advantage is significant but not decisive.**  The recorded CI `[0.003, 0.090]`
excludes zero, so `T` genuinely beats the count baseline; but it contains the bar `0.05`, so
the advantage is not decisive — the two readings are logically independent. -/
theorem u112_significant_not_decisive :
    (0 : ℚ) < 3 / 1000 ∧ 3 / 1000 < decisivenessBar ∧ decisivenessBar < 90 / 1000 := by
  refine ⟨by norm_num, by norm_num [decisivenessBar], by norm_num [decisivenessBar]⟩

end Catalog.Novelty.TDialU112FadeReacceleration