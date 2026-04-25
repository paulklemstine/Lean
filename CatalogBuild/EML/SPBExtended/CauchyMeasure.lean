/-! # CatalogBuild.EML.SPBExtended.CauchyMeasure

Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 10
-/

import Mathlib

noncomputable section

/-- [Section: # SPB and the Cauchy Distribution
The Cauchy distribution dμ = dx/(π(1+x²)) is invariant under SPB translations.
## Key Results
- Cauchy invariance identity: (1+spb(x,a)²)(1-xa)² = (1+x²)(1+a²)
- The CDF shifts by arctan(a)/π under SPB translation
- Monotonicity of the Cauchy CDF
- Fisher information structure] -/
def spbCM (x y : ℝ) : ℝ := (x + y) / (1 - x * y)


/-- [Section: # CatalogBuild.EML.SPBExtended.CauchyMeasure
Auto-generated from theorem catalog database.
Domain: EML/SPBExtended
Declarations: 10] -/
def cauchyCDF (x : ℝ) : ℝ := Real.arctan x / π + 1/2

-- ═══════════════════════════════════════════
-- § 1. Density Properties
-- ═══════════════════════════════════════════


theorem cauchyDensity_even (x : ℝ) : cauchyDensity (-x) = cauchyDensity x := by
  simp [cauchyDensity]


theorem cauchyDensity_zero : cauchyDensity 0 = 1 := by simp [cauchyDensity]

-- The key invariance identity


theorem cauchy_density_transform (x a : ℝ) (h : 1 - x * a ≠ 0) :
    cauchyDensity (spbCM x a) * ((1 + a ^ 2) / (1 - x * a) ^ 2) =
    cauchyDensity x := by
  unfold cauchyDensity spbCM;
  field_simp [h]
  ring

-- ═══════════════════════════════════════════
-- § 2. CDF
-- ═══════════════════════════════════════════


theorem cauchyCDF_zero : cauchyCDF 0 = 1/2 := by simp [cauchyCDF]

-- CDF shifts by arctan(a)/π under SPB translation


theorem cauchyCDF_shift (x a : ℝ) (h : x * a < 1) :
    cauchyCDF (spbCM x a) = cauchyCDF x + Real.arctan a / π := by
  simp only [cauchyCDF, spbCM]
  rw [← Real.arctan_add h]; ring

-- CDF is monotone


theorem cauchyCDF_mono : Monotone cauchyCDF := by
  intro x y hxy; simp only [cauchyCDF]; gcongr

-- ═══════════════════════════════════════════
-- § 3. Fisher Information
-- ═══════════════════════════════════════════


theorem score_squared (x θ : ℝ) :
    (2 * (x - θ) / (1 + (x - θ) ^ 2)) ^ 2 =
    4 * (x - θ) ^ 2 / (1 + (x - θ) ^ 2) ^ 2 := by
  have h : (1 + (x - θ) ^ 2) ≠ 0 := by positivity
  field_simp; ring

-- ═══════════════════════════════════════════
-- § 4. Bernstein-Cauchy Connection
-- ═══════════════════════════════════════════


theorem bernstein_cauchy (x : ℝ) :
    x ^ 2 / (1 + x ^ 2) + 1 / (1 + x ^ 2) = 1 := by
  have : (1 + x ^ 2) ≠ 0 := by positivity
  field_simp; ring


end
