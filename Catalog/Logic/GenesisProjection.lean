import Mathlib

/-! # CatalogBuild.Logic.GenesisProjection

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16
-/

noncomputable section

/-- [Section: # CatalogBuild.Logic.GenesisProjection
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem invStereo1_on_circle (y : ℝ) :
    (invStereo1 y).1 ^ 2 + (invStereo1 y).2 ^ 2 = 1 := by
  unfold invStereo1; ring;
  -- Combine and simplify the terms in the equation.
  field_simp
  ring

/-- [Section: # CatalogBuild.Logic.GenesisProjection
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 16] -/
theorem invStereo1_zero : invStereo1 0 = (0, -1) := by
  unfold invStereo1; norm_num;

theorem invStereo1_limit_north :
    Filter.Tendsto (fun y => (invStereo1 y).2) Filter.atTop (nhds 1) := by
  unfold invStereo1; norm_num [ Filter.Tendsto ] ; ring_nf; (
  field_simp;
  exact ( Metric.tendsto_atTop.mpr <| fun ε εpos ↦ ⟨ ε⁻¹ + 1, fun y hy ↦ abs_lt.mpr <| by constructor <;> nlinarith [ inv_pos.mpr εpos, mul_inv_cancel₀ ( ne_of_gt εpos ), sq_nonneg ( y - 1 ), mul_div_cancel₀ ( y ^ 2 - 1 ) ( by nlinarith [ inv_pos.mpr εpos ] : ( 1 + y ^ 2 ) ≠ 0 ) ] ⟩ ));

theorem invStereo2_on_sphere (y : Fin 2 → ℝ) :
    (invStereo2 y) 0 ^ 2 + (invStereo2 y) 1 ^ 2 + (invStereo2 y) 2 ^ 2 = 1 := by
  -- Expand the squares of the coordinates and simplify.
  simp [invStereo2] at *;
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-- The conformal factor of (inverse) stereographic projection. -/
def conformalFactor (y : ℝ) : ℝ := 2 / (1 + y ^ 2)

theorem conformalFactor_pos (y : ℝ) : 0 < conformalFactor y := by
  exact div_pos zero_lt_two ( by positivity )

theorem conformalFactor_zero : conformalFactor 0 = 2 := by
  unfold conformalFactor; norm_num;

theorem conformalFactor_one : conformalFactor 1 = 1 := by
  unfold conformalFactor; norm_num;

theorem conformalFactor_tendsto_zero :
    Filter.Tendsto conformalFactor Filter.atTop (nhds 0) := by
  exact tendsto_const_nhds.div_atTop ( tendsto_const_nhds.add_atTop ( by norm_num ) )

theorem conformalFactor_le_two (y : ℝ) : conformalFactor y ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

theorem sq_add_one_pos (y : ℝ) : 0 < y ^ 2 + 1 := by
  positivity

/-- The volume of the unit n-sphere Sⁿ.
Vol(S¹) = 2π, Vol(S²) = 4π, Vol(S³) = 2π². -/
def sphereVolume : ℕ → ℝ
  | 0 => 2
  | 1 => 2 * π
  | 2 => 4 * π
  | 3 => 2 * π ^ 2
  | (n + 4) => 2 * π / (n + 3 : ℝ) * sphereVolume (n + 2)

theorem sphereVolume_zero : sphereVolume 0 = 2 := by
  rfl

theorem sphereVolume_one : sphereVolume 1 = 2 * π := by
  rfl

theorem sphereVolume_two : sphereVolume 2 = 4 * π := by
  rfl

theorem sphereVolume_three : sphereVolume 3 = 2 * π ^ 2 := by
  rfl

end
