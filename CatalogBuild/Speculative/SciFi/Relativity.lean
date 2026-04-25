/-! # CatalogBuild.Speculative.SciFi.Relativity

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 9
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.Relativity
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 9] -/
theorem lorentz_denominator_pos (v c : ℝ) (hc : 0 < c) (hv : 0 ≤ v)
    (hsub : v < c) : 0 < 1 - (v / c) ^ 2 := by
  exact sub_pos_of_lt ( by rw [ div_pow, div_lt_iff₀ ] <;> nlinarith )


/-- [Section: # CatalogBuild.Speculative.SciFi.Relativity
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 9] -/
theorem lorentz_denominator_le_one (v c : ℝ) (hc : 0 < c) (hv : 0 ≤ v) :
    1 - (v / c) ^ 2 ≤ 1 := by
  nlinarith


/-- [Section: # CatalogBuild.Speculative.SciFi.Relativity
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 9] -/
theorem no_dilation_at_rest (c : ℝ) (hc : 0 < c) :
    1 - (0 / c) ^ 2 = 1 := by
  norm_num


theorem lorentz_at_light_speed (c : ℝ) (hc : 0 < c) :
    1 - (c / c) ^ 2 = 0 := by
  norm_num [ hc.ne' ]


theorem time_dilation_factor_bound (v c : ℝ) (hc : 0 < c)
    (hv : 0 ≤ v) (hsub : v < c) :
    0 < Real.sqrt (1 - (v / c) ^ 2) ∧ Real.sqrt (1 - (v / c) ^ 2) ≤ 1 := by
  exact ⟨ Real.sqrt_pos.mpr ( sub_pos.mpr ( by rw [ div_pow, div_lt_iff₀ ] <;> nlinarith ) ), Real.sqrt_le_iff.mpr ⟨ by positivity, by nlinarith ⟩ ⟩


theorem no_time_dilation_at_rest (c : ℝ) (hc : 0 < c) :
    Real.sqrt (1 - (0 / c) ^ 2) = 1 := by
  norm_num


theorem relativistic_velocity_addition_subluminal
    (v₁ v₂ c : ℝ) (hc : 0 < c)
    (hv₁ : 0 ≤ v₁) (hv₁c : v₁ < c)
    (hv₂ : 0 ≤ v₂) (hv₂c : v₂ < c) :
    (v₁ + v₂) / (1 + v₁ * v₂ / c ^ 2) < c := by
  field_simp;
  nlinarith


theorem energy_mass_proportional (m c : ℝ) (hc : 0 < c) (hm : 0 < m) :
    0 < m * c ^ 2 := by
  positivity


theorem double_mass_double_energy (m c : ℝ) :
    (2 * m) * c ^ 2 = 2 * (m * c ^ 2) := by
  ring


