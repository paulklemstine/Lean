import Mathlib
import Tropical.FootprintScaleCalibration

/-!
# Footprint-scale transfer: how `R²` grows with the relation count (FACT round-40 #3)

Experiment 478 reports that the in-cell `R²` of the footprint-weighted yield dial rises from
`0.41` to `0.60` (bit length 48, `u = 2.5`) when the number of sieve values per modulus goes
from `80` to `240`.  This file proves what that pair of numbers does and does not allow.

Model (`relR2`).  The yield measured from `m` relations is the true signal (variance `V`)
plus a fixed structural residual (variance `F`, independent of `m`) plus sampling noise
averaged over the relations (variance `σ / m`):

`R²(m) = V / (V + F + σ / m)`.

* `inv_relR2` — `1 / R²(m)` is **affine in `1/m`**: `1/R² = 1 + F/V + (σ/V)·(1/m)`.
* `relR2_strictMono`, `tendsto_relR2_ceiling`, `relR2_lt_ceiling` — `R²` increases strictly
  with the relation count and converges to the **ceiling** `V / (V + F)`, never reaching it.
* `spearman_brown` — with no structural residual (`F = 0`) the curve is the classical
  Spearman–Brown law `R²(k m) = k R / (1 + (k-1) R)`.
* `relR2_le_spearmanBrown`, `relR2_lt_spearmanBrown_iff` — in general Spearman–Brown is an
  *upper bound*, attained iff `F = 0`.
* `ceiling_two_point` — two cells identify the ceiling:
  `1 / ceiling = (m₂ / R₂ - m₁ / R₁) / (m₂ - m₁)`.
* `exp478_structural_floor` — the measured pair `(80, 0.41)`, `(240, 0.60)` lies strictly
  below the Spearman–Brown prediction `1.23 / 1.82 ≈ 0.676`, so **any** model of this form
  consistent with the data has a strictly positive structural residual `F > 0`.
* `exp478_ceiling` — the data pin the ceiling to exactly `82/105 ≈ 0.781` and the noise
  ratio to `σ / V = 3800/41`.
* `exp478_relations_for_070` — `R² ≥ 0.70` holds iff `m ≥ 53200/85 ≈ 625.9`, i.e. at least
  `626` values per modulus are needed; `exp478_never_079` — no relation count reaches `0.79`.
* `calibration_rsq_link` — the bridge to `FootprintScaleCalibration`: under the attenuation
  law with `c = 1` and a noiseless yield, the calibration slope *equals* `R²`, so the two
  curves (slope and `R²` against relation count) are one curve.
* `rsq_eq_slope_mul_yield_reliability`, `rsq_le_slope_attenuation` — with yield noise,
  `R² = slope · V/(V+H)`: the gap between the slope column (`≈ 0.9`) and the `R²` column
  (`0.41–0.60`) is yield noise, not miscalibration.
-/

open Filter Topology

namespace FootprintScale

/-- The relation-count reliability curve `R²(m) = V / (V + F + σ / m)`. -/
noncomputable def relR2 (V F σ m : ℝ) : ℝ := V / (V + F + σ / m)

/-- The asymptotic `R²` (infinitely many relations). -/
noncomputable def ceiling (V F : ℝ) : ℝ := V / (V + F)

/-- Spearman–Brown prophecy: the `R²` predicted after multiplying the relation count by `k`. -/
noncomputable def spearmanBrown (k R : ℝ) : ℝ := k * R / (1 + (k - 1) * R)

section
variable {V F σ : ℝ}

/-- `1 / R²` is affine in `1 / m`. -/
theorem inv_relR2 (hV : 0 < V) (m : ℝ) :
    1 / relR2 V F σ m = 1 + F / V + σ / V * (1 / m) := by
  unfold relR2
  rw [one_div_div]
  field_simp

lemma relR2_pos (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ) {m : ℝ} (hm : 0 < m) :
    0 < relR2 V F σ m := by
  unfold relR2; positivity

/-- More relations strictly increase `R²` when there is sampling noise. -/
theorem relR2_strictMono (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 < σ) {m₁ m₂ : ℝ}
    (hm₁ : 0 < m₁) (hm : m₁ < m₂) : relR2 V F σ m₁ < relR2 V F σ m₂ := by
  unfold relR2
  have hm₂ : 0 < m₂ := lt_trans hm₁ hm
  have h1 : σ / m₂ < σ / m₁ := div_lt_div_of_pos_left hσ hm₁ hm
  apply div_lt_div_of_pos_left hV (by positivity) (by linarith)

/-- `R²` converges to the ceiling as the relation count grows. -/
theorem tendsto_relR2_ceiling (hV : 0 < V) (hF : 0 ≤ F) :
    Tendsto (fun m => relR2 V F σ m) atTop (𝓝 (ceiling V F)) := by
  unfold relR2 ceiling
  have h : Tendsto (fun m : ℝ => V + F + σ / m) atTop (𝓝 (V + F + 0)) :=
    tendsto_const_nhds.add (tendsto_const_nhds.div_atTop tendsto_id)
  rw [add_zero] at h
  exact tendsto_const_nhds.div h (by linarith)

/-- The ceiling is never attained when there is sampling noise. -/
theorem relR2_lt_ceiling (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 < σ) {m : ℝ} (hm : 0 < m) :
    relR2 V F σ m < ceiling V F := by
  unfold relR2 ceiling
  have : 0 < σ / m := div_pos hσ hm
  apply div_lt_div_of_pos_left hV (by linarith) (by linarith)

/-- **Spearman–Brown** for a pure-noise residual. -/
theorem spearman_brown (hV : 0 < V) (hσ : 0 ≤ σ) {m k : ℝ} (hm : 0 < m) (hk : 0 < k) :
    relR2 V 0 σ (k * m) = spearmanBrown k (relR2 V 0 σ m) := by
  unfold relR2 spearmanBrown
  have hd : 0 < V + 0 + σ / m := by positivity
  have hd' : 0 < V + 0 + σ / (k * m) := by positivity
  have hden : 0 < 1 + (k - 1) * (V / (V + 0 + σ / m)) := by
    rw [show 1 + (k - 1) * (V / (V + 0 + σ / m)) = (k * V + σ / m) / (V + 0 + σ / m) by
      field_simp; ring]
    positivity
  rw [div_eq_div_iff hd'.ne' hden.ne']
  field_simp
  ring

/-- Closed form of the Spearman–Brown prediction inside the model. -/
lemma spearmanBrown_relR2 (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ) {m k : ℝ} (hm : 0 < m)
    (hk : 0 < k) :
    spearmanBrown k (relR2 V F σ m) = V / (V + F / k + σ / (k * m)) := by
  unfold relR2 spearmanBrown
  have hd : 0 < V + F + σ / m := by positivity
  have hd' : 0 < V + F / k + σ / (k * m) := by positivity
  have hden : 0 < 1 + (k - 1) * (V / (V + F + σ / m)) := by
    rw [show 1 + (k - 1) * (V / (V + F + σ / m)) = (k * V + F + σ / m) / (V + F + σ / m) by
      field_simp; ring]
    positivity
  rw [div_eq_div_iff hden.ne' hd'.ne']
  field_simp
  ring

/-- Spearman–Brown is an upper bound once a structural residual is allowed. -/
theorem relR2_le_spearmanBrown (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ) {m k : ℝ}
    (hm : 0 < m) (hk : 1 ≤ k) :
    relR2 V F σ (k * m) ≤ spearmanBrown k (relR2 V F σ m) := by
  have hk0 : 0 < k := by linarith
  rw [spearmanBrown_relR2 hV hF hσ hm hk0]
  unfold relR2
  have : F / k ≤ F := div_le_self hF hk
  apply div_le_div_of_nonneg_left hV.le (by positivity) (by linarith)

/-- … with strict inequality exactly when the structural residual is present. -/
theorem relR2_lt_spearmanBrown_iff (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ) {m k : ℝ}
    (hm : 0 < m) (hk : 1 < k) :
    relR2 V F σ (k * m) < spearmanBrown k (relR2 V F σ m) ↔ 0 < F := by
  have hk0 : 0 < k := by linarith
  rw [spearmanBrown_relR2 hV hF hσ hm hk0]
  unfold relR2
  have hd : 0 < V + F / k + σ / (k * m) := by positivity
  rw [div_lt_div_iff_of_pos_left hV (by positivity) hd]
  constructor
  · intro h
    by_contra hF0
    have : F = 0 := le_antisymm (not_lt.mp hF0) hF
    subst this; simp at h
  · intro hFpos
    have : F / k < F := div_lt_self hFpos hk
    linarith

/-- **Two-point identification of the ceiling.** -/
theorem ceiling_two_point (hV : 0 < V) {m₁ m₂ : ℝ} (hm₁ : 0 < m₁)
    (hm : m₁ < m₂) :
    1 / ceiling V F =
      (m₂ / relR2 V F σ m₂ - m₁ / relR2 V F σ m₁) / (m₂ - m₁) := by
  have hm₂ : 0 < m₂ := lt_trans hm₁ hm
  have e₁ : m₁ / relR2 V F σ m₁ = m₁ * (1 + F / V) + σ / V := by
    rw [div_eq_mul_one_div, inv_relR2 hV]; field_simp
  have e₂ : m₂ / relR2 V F σ m₂ = m₂ * (1 + F / V) + σ / V := by
    rw [div_eq_mul_one_div, inv_relR2 hV]; field_simp
  rw [e₁, e₂]
  unfold ceiling
  have hsub : m₂ - m₁ ≠ 0 := by linarith
  rw [one_div_div, eq_div_iff hsub]
  field_simp
  ring

end

/-! ### The experiment-478 cell (`u = 2.5`, bit length 48) -/

section Exp478
variable {V F σ : ℝ}

/-- **A structural floor is forced.**  Any parameters with `R²(80) = 0.41` and
`R²(240) = 0.60` have a strictly positive structural residual: pure relation-noise cannot
explain the measured growth, because Spearman–Brown would predict `≈ 0.676`. -/
theorem exp478_structural_floor (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ)
    (h80 : relR2 V F σ 80 = 41 / 100) (h240 : relR2 V F σ 240 = 3 / 5) : 0 < F := by
  have key := relR2_lt_spearmanBrown_iff hV hF hσ (m := 80) (k := 3) (by norm_num)
    (by norm_num)
  rw [show (3 : ℝ) * 80 = 240 by norm_num, h240, h80] at key
  apply key.mp
  unfold spearmanBrown
  norm_num

/-- The data determine the ceiling `82/105` and the noise-to-signal ratio `3800/41`. -/
theorem exp478_ceiling (hV : 0 < V) (hF : 0 ≤ F)
    (h80 : relR2 V F σ 80 = 41 / 100) (h240 : relR2 V F σ 240 = 3 / 5) :
    ceiling V F = 82 / 105 ∧ σ / V = 3800 / 41 := by
  have hc := ceiling_two_point (σ := σ) (F := F) hV (m₁ := 80) (m₂ := 240) (by norm_num)
    (by norm_num)
  rw [h80, h240] at hc
  norm_num at hc
  have hceil : ceiling V F = 82 / 105 := by
    have : ceiling V F ≠ 0 := by unfold ceiling; positivity
    field_simp at hc
    linarith
  refine ⟨hceil, ?_⟩
  have h1 := inv_relR2 (F := F) (σ := σ) hV 240
  rw [h240] at h1
  have hFV : 1 + F / V = 105 / 82 := by
    unfold ceiling at hceil
    rw [div_eq_iff (by positivity)] at hceil
    field_simp
    linarith
  rw [hFV] at h1
  linarith

/-- **Prediction.**  In this cell `R² ≥ 0.70` holds iff the relation count is at least
`53200/85 ≈ 625.9`. -/
theorem exp478_relations_for_070 (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ)
    (h80 : relR2 V F σ 80 = 41 / 100) (h240 : relR2 V F σ 240 = 3 / 5) {m : ℝ}
    (hm : 0 < m) : 7 / 10 ≤ relR2 V F σ m ↔ 53200 / 85 ≤ m := by
  obtain ⟨hceil, hratio⟩ := exp478_ceiling hV hF h80 h240
  have hFV : 1 + F / V = 105 / 82 := by
    unfold ceiling at hceil
    rw [div_eq_iff (by positivity)] at hceil
    field_simp
    linarith
  have hpos := relR2_pos hV hF hσ hm
  have hinv := inv_relR2 (F := F) (σ := σ) hV m
  rw [hFV, hratio] at hinv
  have hR : relR2 V F σ m = 1 / (105 / 82 + 3800 / 41 * (1 / m)) := by
    rw [← hinv, one_div_one_div]
  rw [hR]
  have hd : 0 < 105 / 82 + 3800 / 41 * (1 / m) := by positivity
  rw [le_div_iff₀ hd]
  constructor
  · intro h
    have h' : 3800 / 41 * (1 / m) ≤ 85 / 574 := by nlinarith
    rw [mul_one_div, div_le_iff₀ hm] at h'
    linarith
  · intro h
    have h' : 3800 / 41 * (1 / m) ≤ 85 / 574 := by
      rw [mul_one_div, div_le_iff₀ hm]; linarith
    nlinarith

/-- Integer form: at least `626` values per modulus are needed for `R² ≥ 0.70`. -/
theorem exp478_min_relations_070 (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ)
    (h80 : relR2 V F σ 80 = 41 / 100) (h240 : relR2 V F σ 240 = 3 / 5) (n : ℕ)
    (hn : 0 < n) : 7 / 10 ≤ relR2 V F σ n ↔ 626 ≤ n := by
  rw [exp478_relations_for_070 hV hF hσ h80 h240 (by exact_mod_cast hn)]
  constructor
  · intro h
    by_contra hlt
    have : (n : ℝ) ≤ 625 := by exact_mod_cast (by omega : n ≤ 625)
    linarith [show (625 : ℝ) < 53200 / 85 by norm_num]
  · intro h
    have : (626 : ℝ) ≤ n := by exact_mod_cast h
    linarith [show (53200 / 85 : ℝ) ≤ 626 by norm_num]

/-- No relation count, however large, lifts this cell to `R² = 0.79`. -/
theorem exp478_never_079 (hV : 0 < V) (hF : 0 ≤ F) (hσ : 0 ≤ σ)
    (h80 : relR2 V F σ 80 = 41 / 100) (h240 : relR2 V F σ 240 = 3 / 5) {m : ℝ}
    (hm : 0 < m) : relR2 V F σ m < 79 / 100 := by
  obtain ⟨hceil, -⟩ := exp478_ceiling hV hF h80 h240
  have hle : relR2 V F σ m ≤ ceiling V F := by
    unfold relR2 ceiling
    apply div_le_div_of_nonneg_left hV.le (by positivity) (by
      have : 0 ≤ σ / m := div_nonneg hσ hm.le
      linarith)
  rw [hceil] at hle
  linarith [show (82 / 105 : ℝ) < 79 / 100 by norm_num]

end Exp478

/-! ### Bridge: calibration slope = `R²` under pure attenuation -/

/-- Under the attenuation law with no scale drift and a noiseless yield (`y = s`), the
calibration slope of `y` on the prediction `x = s + e` equals the `R²` of that regression:
both are `V / (V + E)`.  Hence, without yield noise, the slope column and the `R²` column
of a transfer table measure the same reliability. -/
theorem calibration_rsq_link {ι : Type*} [Fintype ι] (s e : ι → ℝ) (hse : cov s e = 0)
    (hV : 0 < cov s s) :
    slope (s + e) s = rsq (s + e) s := by
  have hes : cov e s = 0 := by rw [cov_comm]; exact hse
  unfold slope rsq
  simp only [cov_add_left, cov_add_right]
  rw [hse, hes]
  have hE := cov_self_nonneg e
  field_simp
  ring

/-- **Slope–`R²` factorisation.**  With uncorrelated prediction noise `e` and yield noise `η`,
`R² = slope · V / (V + H)` where `H = cov η η`: the in-cell `R²` is the calibration slope
times the *yield reliability*.  In experiment 478 (`slope ≈ 0.9`, `R² ≈ 0.4–0.6`) the gap
between the two columns therefore measures yield noise, not dial miscalibration. -/
theorem rsq_eq_slope_mul_yield_reliability {ι : Type*} [Fintype ι] (s e η : ι → ℝ)
    (hse : cov s e = 0) (hsη : cov s η = 0) (heη : cov e η = 0) (hV : 0 < cov s s) :
    rsq (s + e) (s + η) = slope (s + e) (s + η) * (cov s s / (cov s s + cov η η)) := by
  have hes : cov e s = 0 := by rw [cov_comm]; exact hse
  have hηs : cov η s = 0 := by rw [cov_comm]; exact hsη
  have hηe : cov η e = 0 := by rw [cov_comm]; exact heη
  unfold slope rsq
  simp only [cov_add_left, cov_add_right]
  rw [hse, hes, hsη, hηs]
  have hE := cov_self_nonneg e
  have hH := cov_self_nonneg η
  have h1 : cov s s + cov e e ≠ 0 := by positivity
  have h2 : cov s s + cov η η ≠ 0 := by positivity
  rw [heη]
  field_simp
  ring

/-- Consequently `R² ≤ slope` under the attenuation model. -/
theorem rsq_le_slope_attenuation {ι : Type*} [Fintype ι] (s e η : ι → ℝ)
    (hse : cov s e = 0) (hsη : cov s η = 0) (heη : cov e η = 0) (hV : 0 < cov s s) :
    rsq (s + e) (s + η) ≤ slope (s + e) (s + η) := by
  rw [rsq_eq_slope_mul_yield_reliability s e η hse hsη heη hV]
  have hsl := (slope_attenuation_le_one s e η hse hsη heη hV).1
  have hH := cov_self_nonneg η
  have : cov s s / (cov s s + cov η η) ≤ 1 := by
    rw [div_le_one (by positivity)]; linarith
  nlinarith

end FootprintScale