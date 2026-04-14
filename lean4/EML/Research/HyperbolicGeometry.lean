import Mathlib

/-!
# Lorentz Group and Hyperbolic Geometry Connection

The Lorentz form Q(a,b,c) = a² + b² - c² defines a hyperboloid model of
hyperbolic geometry. The Berggren matrices are isometries of this geometry,
with determinant 1 (orientation-preserving), creating a tessellation of
the hyperbolic plane analogous to Escher's Circle Limit tilings.
-/

open Matrix

/-! ## The Lorentz Form -/

def lorentzQuad (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2

theorem pyth_is_null (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    lorentzQuad ![a, b, c] = 0 := by
  simp [lorentzQuad]; omega

/-! ## Berggren Matrices as Lorentz Isometries -/

def B1 : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def B2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def B3 : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

def Q_metric : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

theorem B1_lorentz : B1ᵀ * Q_metric * B1 = Q_metric := by native_decide
theorem B2_lorentz : B2ᵀ * Q_metric * B2 = Q_metric := by native_decide
theorem B3_lorentz : B3ᵀ * Q_metric * B3 = Q_metric := by native_decide

/-! ## Determinant Properties -/

-- B₁ and B₃ have det = 1 (proper Lorentz), B₂ has det = -1 (improper)
theorem det_B1 : Matrix.det B1 = 1 := by native_decide
theorem det_B2 : Matrix.det B2 = -1 := by native_decide
theorem det_B3 : Matrix.det B3 = 1 := by native_decide

/-! ## The Upper Hyperboloid -/

-- Points with a² + b² - c² = -1, c > 0 form the upper sheet of the hyperboloid.
def OnUpperHyperboloid (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2 = -1 ∧ 0 < v 2

/-! ## Angle of a Pythagorean Triple -/

noncomputable def pythAngle (a b : ℝ) : ℝ := Real.arctan (b / a)

-- For the root triple (3,4,5), the angle is arctan(4/3)
noncomputable def rootAngle : ℝ := Real.arctan (4 / 3)

/-! ## Hyperbolic Depth Ratio -/

noncomputable def depthRatio (c₁ c₂ : ℤ) (hc₁ : 0 < c₁) (hc₂ : 0 < c₂) : ℝ :=
  |Real.log ((c₁ : ℝ) / c₂)|

/-! ## The Dominant Eigenvalue of B₂ -/

-- The characteristic polynomial of B₂ restricted to the null cone
-- gives the recurrence c_{n+1} = 6c_n - c_{n-1} (Pell equation).
-- The dominant root is 3 + 2√2.

theorem dominant_eigenvalue_eq :
    (3 + 2 * Real.sqrt 2) ^ 2 = 6 * (3 + 2 * Real.sqrt 2) - 1 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  nlinarith

-- 3 + 2√2 ≈ 5.828, the growth rate of B-branch hypotenuses
-- Hypotenuses: 5, 29, 169, 985, 5741, ...
-- Ratios: 5.8, 5.827..., 5.8284..., converging to 3 + 2√2
