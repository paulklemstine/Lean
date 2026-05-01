import Mathlib

/-! # CatalogBuild.Speculative.SPBCORDIC

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10
-/

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBCORDIC
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
def cordicStep (x y : ℝ) (d : ℝ) (n : ℕ) : ℝ × ℝ :=
  (x - d * y * (2 : ℝ)⁻¹ ^ n, y + d * x * (2 : ℝ)⁻¹ ^ n)

/-- [Section: # CatalogBuild.Speculative.SPBCORDIC
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
theorem cordic_in_spb (x y d : ℝ) (n : ℕ) (hx : x ≠ 0)
    (hx' : x - d * y * (2 : ℝ)⁻¹ ^ n ≠ 0) :
    (cordicStep x y d n).2 / (cordicStep x y d n).1 = spbC (y / x) (d * (2 : ℝ)⁻¹ ^ n) := by
  unfold cordicStep spbC;
  grind

def spbCordic (t₀ : ℝ) (d : ℕ → ℝ) : ℕ → ℝ
  | 0 => t₀
  | n + 1 => spbC (spbCordic t₀ d n) (d n * (2 : ℝ)⁻¹ ^ n)

theorem spbCordic_one (d : ℕ → ℝ) :
    spbCordic 0 d 1 = d 0 := by simp [spbCordic, spbC]

def cordicAngle (n : ℕ) : ℝ := arctan ((2 : ℝ)⁻¹ ^ n)

theorem cordicAngle_zero : cordicAngle 0 = π / 4 := by simp [cordicAngle, arctan_one]

theorem cordicAngle_pos (n : ℕ) : 0 < cordicAngle n := by
  rw [cordicAngle, arctan_pos]; positivity

theorem cordicAngle_decreasing (n : ℕ) : cordicAngle (n + 1) < cordicAngle n := by
  apply Real.arctan_strictMono
  norm_num [ pow_succ ]

def cordicGain (n : ℕ) : ℝ := ∏ i ∈ Finset.range n, 1 / Real.sqrt (1 + (2 : ℝ)⁻¹ ^ (2 * i))

theorem cordicGain_pos (n : ℕ) : 0 < cordicGain n := by
  unfold cordicGain
  apply Finset.prod_pos
  intro i _
  apply div_pos one_pos
  exact Real.sqrt_pos.mpr (by positivity)

end