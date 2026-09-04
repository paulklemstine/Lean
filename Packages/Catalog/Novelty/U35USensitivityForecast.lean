import Mathlib
import Novelty.U35SubfloorCap
import Novelty.U35PairedDrop

/-!
# U35 localization III: "degrades everywhere", and where the floor is actually crossed

## Research context (FACT round-45 #1, exp 500, assessment v276)

Files I and II proved (i) that the recorded summary caps the sub-floor count at three while the
ledger reports zero, and (ii) that the paired column is significant at exact randomization
level `2⁻¹⁴` and forces a seed-level correlation `≥ 0.74`.  This third file closes the loop
with the two operational questions the verdict leaves open.

### A. Is the `u`-sensitivity loss uniform across seeds? (Section 1)

The exp-500 verdict says "degrades everywhere", but the ledger publishes only the mean drop
`0.1057` and the CI.  Section 1 shows that the summary *by itself* already forbids any seed
from being nearly insensitive: applying the file-I Chebyshev bound to the *difference* column,

* `u35_drop_uniform_lower_bound` — every one of the 14 seeds has drop `dᵢ > 0.066`, i.e. more
  than **62 %** of the mean drop, whenever the paired mean is `0.1057` and the paired sample sd
  is at most `0.0110`.

There is no room for a "flat seed": the dispersion budget is spent before a single seed can get
within `0.04` of zero drop.  This is the sharpest available formal content of "degrades
everywhere", and it is derived, not observed.

### B. Where does the floor actually get crossed? (Section 2)

The dial does not breach at `u = 3.5`; it is `0.0282` above the floor and losing `0.1057` per
unit of `u`.  The affine `u`-model therefore predicts a first breach strictly above `3.5`:

* `linModel_strictAnti`, `linModel_root_unique` — for a positive slope the model has a unique
  floor-crossing abscissa, `u★ = 3.5 + (m − 0.60)/b`;
* `u35_crossing_bracket` — at the recorded point estimates, `3.766 < u★ < 3.767`;
* `u35_crossing_forecast_window` — **the falsifiable forecast**: for *every* centre in the
  recorded CI `[0.6204, 0.6363]` and *every* slope in the recorded paired CI
  `[0.0999, 0.1112]`, the crossing satisfies `3.68 < u★ < 3.87`.  The prediction excludes a
  breach at `u = 3.5` (consistent with the verdict) and equally excludes survival at `u = 4.0`.
  A single `u = 4.0` population above the floor, or a single `u = 3.6` population below it,
  refutes the affine model.

### C. Is the published `± 0.0041` really the standard error? (Section 3)

* `u35_se_consistency` — `0.0155/√14 = 0.0041425…`, within `5 · 10⁻⁵` of the published
  `± 0.0041`.  So the reported uncertainty is the ordinary `sd/√n`, and the bootstrap added no
  extra width: the CI `[0.6204, 0.6363]` is `± 1.92` standard errors, i.e. an ordinary
  two-sided `95 %` interval, not an inflated one.  This closes the last route by which the
  "excludes the floor" claim could have been an artefact of the resampling procedure.

## Lab notes (derived quantities, all verified below)

```
paired dispersion budget   13 * 0.0110^2       = 0.0015730
gap needed to admit a flat seed  (0.1057 - c)^2 > 0.0015730  <=>  c < 0.06604
uniform drop floor         every d_i > 0.066   (= 62.4 % of the mean drop)
crossing, point estimates  3.5 + 0.0282/0.1057 = 3.76679...
crossing, CI box           [3.5 + 0.0204/0.1112, 3.5 + 0.0363/0.0999] = [3.6835, 3.8634]
standard error check       0.0155/sqrt 14      = 0.00414254...   vs published 0.0041
CI half-width / s.e.       0.00795/0.0041425   = 1.9191
```
-/

namespace Catalog.Novelty.U35USensitivityForecast

open Finset
open Catalog.Novelty.U35SubfloorCap

/-! ## 1. The `u`-sensitivity loss is uniform over seeds -/

/-- The recorded mean paired drop `Δ = sp(2.5) − sp(3.5)`. -/
def dropMean : ℚ := 1057 / 10000

/-- The paired sample standard deviation implied by the recorded paired CI. -/
def dropSd : ℚ := 110 / 10000

/-- A first consequence of the file-I cap: at the recorded paired dispersion, *no* seed can sit
at or below `0.066`, so the sub-floor count for the difference column at that level is `0`. -/
theorem u35_drop_belowCard_zero (d : Fin 14 → ℚ)
    (hvar : sqDev d dropMean ≤ 13 * dropSd ^ 2) :
    belowCard d (66 / 1000) = 0 := by
  have hlt : (66 / 1000 : ℚ) < dropMean := by norm_num [dropMean]
  have hkey := belowCard_mul_sq_margin_le d dropMean (66 / 1000) hlt
  set k : ℕ := belowCard d (66 / 1000) with hk
  by_contra hne
  have hk1 : 1 ≤ k := Nat.one_le_iff_ne_zero.mpr hne
  have hk1' : (1 : ℚ) ≤ (k : ℚ) := by exact_mod_cast hk1
  have hmargin : (dropMean - 66 / 1000) ^ 2 = 397 ^ 2 / 10000 ^ 2 := by
    norm_num [dropMean]
  have h1 : (k : ℚ) * (dropMean - 66 / 1000) ^ 2 ≤ 13 * dropSd ^ 2 := le_trans hkey hvar
  rw [hmargin] at h1
  have h2 : (397 : ℚ) ^ 2 / 10000 ^ 2 ≤ 13 * dropSd ^ 2 := by nlinarith
  rw [show (13 : ℚ) * dropSd ^ 2 = 157300 / 100000000 by norm_num [dropSd]] at h2
  norm_num at h2

/-- **"Degrades everywhere", as a theorem.**  Any 14-seed paired column with the recorded mean
drop `0.1057` and paired sample sd at most `0.0110` has *every* seed dropping by more than
`0.066` — over `62 %` of the mean drop.  No seed can be `u`-insensitive. -/
theorem u35_drop_uniform_lower_bound (d : Fin 14 → ℚ)
    (hvar : sqDev d dropMean ≤ 13 * dropSd ^ 2) (i : Fin 14) :
    66 / 1000 < d i := by
  by_contra hle
  push_neg at hle
  have hmem : i ∈ ({j | d j ≤ 66 / 1000} : Finset (Fin 14)) := by
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact hle
  have hpos : 0 < belowCard d (66 / 1000) :=
    Finset.card_pos.mpr ⟨i, hmem⟩
  rw [u35_drop_belowCard_zero d hvar] at hpos
  exact lt_irrefl 0 hpos

/-- In particular the mean drop itself is more than `1.6 ×` the guaranteed per-seed drop: the
uniform bound captures `62.4 %` of the recorded effect. -/
theorem u35_uniform_bound_fraction : (66 / 1000 : ℚ) / dropMean > 624 / 1000 := by
  norm_num [dropMean]

/-! ## 2. The affine `u`-model and the floor-crossing forecast -/

/-- The affine `u`-sensitivity model anchored at `u = 3.5`: centre `m`, loss `b` per unit `u`. -/
noncomputable def linModel (m b u : ℝ) : ℝ := m - b * (u - 7 / 2)

/-- For a positive `u`-sensitivity loss the model is strictly decreasing in `u`. -/
theorem linModel_strictAnti {m b : ℝ} (hb : 0 < b) : StrictAnti (linModel m b) := by
  intro u v huv
  have : b * (u - 7 / 2) < b * (v - 7 / 2) := by
    apply mul_lt_mul_of_pos_left _ hb
    linarith
  simp only [linModel]
  linarith

/-- The floor-crossing abscissa exists and is unique, and is given by the explicit formula
`u★ = 3.5 + (m − 0.60)/b`. -/
theorem linModel_root_unique {m b : ℝ} (hb : 0 < b) :
    ∃! u : ℝ, linModel m b u = 6 / 10 := by
  have hb' : b ≠ 0 := ne_of_gt hb
  refine ⟨7 / 2 + (m - 6 / 10) / b, ?_, ?_⟩
  · have hcancel : b * (7 / 2 + (m - 6 / 10) / b - 7 / 2) = m - 6 / 10 := by
      field_simp
      ring
    simp only [linModel, hcancel]
    ring
  · intro u hu
    have h1 : b * (u - 7 / 2) = m - 6 / 10 := by
      simp only [linModel] at hu
      linarith
    have h2 : u - 7 / 2 = (m - 6 / 10) / b := by
      rw [eq_div_iff hb']
      linarith
    linarith

/-- **The point forecast.**  At the recorded centre `0.6282` and recorded loss `0.1057` the
model crosses the `0.60` floor between `u = 3.766` and `u = 3.767`. -/
theorem u35_crossing_bracket :
    linModel (6282 / 10000) (1057 / 10000) (3766 / 1000) > 6 / 10 ∧
      linModel (6282 / 10000) (1057 / 10000) (3767 / 1000) < 6 / 10 := by
  constructor <;> norm_num [linModel]

/-- **The falsifiable forecast window.**  For every centre inside the recorded bootstrap CI and
every loss inside the recorded paired CI, the affine model's floor crossing lies strictly
between `u = 3.68` and `u = 3.87`.  In particular `u = 3.5` is predicted safe and `u = 4.0` is
predicted breached, for the whole CI box. -/
theorem u35_crossing_forecast_window (m b : ℝ)
    (hm : 6204 / 10000 ≤ m) (hm' : m ≤ 6363 / 10000)
    (hb : 999 / 10000 ≤ b) (hb' : b ≤ 1112 / 10000) :
    368 / 100 < 7 / 2 + (m - 6 / 10) / b ∧ 7 / 2 + (m - 6 / 10) / b < 387 / 100 := by
  have hbpos : 0 < b := by linarith
  have hlow : 18 / 100 < (m - 6 / 10) / b := by
    rw [lt_div_iff₀ hbpos]
    nlinarith
  have hhigh : (m - 6 / 10) / b < 37 / 100 := by
    rw [div_lt_iff₀ hbpos]
    nlinarith
  exact ⟨by linarith, by linarith⟩

/-- The model with the recorded point estimates predicts the dial is *safe* at `u = 3.5`
(margin `+0.0282`) and *breached* at `u = 4.0` (margin `−0.0246`): the sign flip inside the
tested range is what makes the forecast testable. -/
theorem u35_forecast_sign_flip :
    6 / 10 < linModel (6282 / 10000) (1057 / 10000) (7 / 2) ∧
      linModel (6282 / 10000) (1057 / 10000) 4 < 6 / 10 := by
  constructor <;> norm_num [linModel]

/-! ## 3. The published `± 0.0041` is the ordinary standard error -/

theorem sqrt14_bracket : (37416 / 10000 : ℝ) < Real.sqrt 14 ∧ Real.sqrt 14 < 37417 / 10000 := by
  have h14 : (0 : ℝ) ≤ 14 := by norm_num
  constructor
  · have hlt : ((37416 : ℝ) / 10000) ^ 2 < 14 := by norm_num
    nlinarith [Real.sq_sqrt h14, Real.sqrt_nonneg 14]
  · have hgt : (14 : ℝ) < ((37417 : ℝ) / 10000) ^ 2 := by norm_num
    nlinarith [Real.sq_sqrt h14, Real.sqrt_nonneg 14]

/-- **Standard-error consistency.**  `sd/√n = 0.0155/√14` agrees with the published
`± 0.0041` to within `5 · 10⁻⁵`; the bootstrap therefore added no extra width, and the
"CI excludes the floor" verdict is not an artefact of resampling. -/
theorem u35_se_consistency :
    |(155 / 10000 : ℝ) / Real.sqrt 14 - 41 / 10000| < 5 / 100000 := by
  obtain ⟨hlo, hhi⟩ := sqrt14_bracket
  have hpos : (0 : ℝ) < Real.sqrt 14 := by linarith
  have hub : (155 / 10000 : ℝ) / Real.sqrt 14 < 155 / 10000 / (37416 / 10000) := by
    apply div_lt_div_of_pos_left (by norm_num) (by norm_num) hlo
  have hlb : (155 / 10000 : ℝ) / (37417 / 10000) < 155 / 10000 / Real.sqrt 14 := by
    apply div_lt_div_of_pos_left (by norm_num) hpos hhi
  rw [abs_lt]
  constructor
  · nlinarith [hlb]
  · nlinarith [hub]

/-- The recorded CI half-width is `1.92` standard errors: an ordinary two-sided `95 %`
interval, not an inflated one. -/
theorem u35_ci_halfwidth_ratio :
    let halfWidth : ℝ := (6363 / 10000 - 6204 / 10000) / 2
    191 / 100 < halfWidth / (41 / 10000) ∧ halfWidth / (41 / 10000) < 194 / 100 := by
  norm_num

end Catalog.Novelty.U35USensitivityForecast