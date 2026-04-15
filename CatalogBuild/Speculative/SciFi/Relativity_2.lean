/-! # CatalogBuild.Speculative.SciFi.Relativity_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 7
-/

import Mathlib

noncomputable section

/-- Lorentz factor (with c = 1). -/
def lorentzFactor (v : ℝ) : ℝ :=
  1 / Real.sqrt (1 - v ^ 2)


/-- [Section: ## The Lorentz Factor
γ = 1 / √(1 - v²/c²)] -/
theorem lorentz_ge_one (v : ℝ) (hv : |v| < 1) : 1 ≤ lorentzFactor v := by
  refine one_le_one_div ( Real.sqrt_pos.mpr ?_ ) ?_;
  · nlinarith [ abs_lt.mp hv ];
  · exact Real.sqrt_le_iff.mpr ⟨ by nlinarith, by nlinarith ⟩


theorem lorentz_strictMono_on :
    StrictMonoOn (fun v => lorentzFactor v) (Set.Ico 0 1) := by
  unfold StrictMonoOn lorentzFactor;
  simp +zetaDelta at *;
  exact fun a ha₁ ha₂ b hb₁ hb₂ hab => inv_strictAnti₀ ( Real.sqrt_pos.2 <| by nlinarith ) ( Real.sqrt_lt_sqrt ( by nlinarith ) ( by nlinarith ) )


/-- [Section: ## Time Dilation
dτ/dt = 1/γ = √(1 - v²/c²)
The traveling twin ages less.] -/
theorem time_dilation_range (v : ℝ) (hv : |v| < 1) :
    0 < Real.sqrt (1 - v ^ 2) ∧ Real.sqrt (1 - v ^ 2) ≤ 1 := by
  exact ⟨ Real.sqrt_pos.2 ( by nlinarith [ abs_lt.mp hv ] ), Real.sqrt_le_iff.2 ⟨ by nlinarith [ abs_lt.mp hv ], by nlinarith [ abs_lt.mp hv ] ⟩ ⟩


/-- The relativistic rocket velocity (with c = 1). -/
def rocketVelocity (ve : ℝ) (massRatio : ℝ) : ℝ :=
  Real.tanh (ve * Real.log massRatio)


/-- [Section: ## The Relativistic Rocket Equation
v = c · tanh(vₑ/c · ln(M₀/Mf))
v < c for all finite mass ratios.] -/
theorem rocket_below_lightspeed (ve : ℝ) (R : ℝ) :
    |rocketVelocity ve R| < 1 := by
  apply Real.abs_tanh_lt_one


theorem rocket_velocity_increasing (ve : ℝ) (hve : 0 < ve) {R₁ R₂ : ℝ}
    (hR₁ : 0 < R₁) (h : R₁ < R₂) :
    rocketVelocity ve R₁ < rocketVelocity ve R₂ := by
  unfold rocketVelocity;
  rw [ Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh ];
  rw [ div_lt_div_iff₀ ] <;> try positivity;
  -- Use the hyperbolic sine and cosine subtraction formulas.
  have h_sinh_cosh : Real.sinh (ve * Real.log R₂) * Real.cosh (ve * Real.log R₁) - Real.sinh (ve * Real.log R₁) * Real.cosh (ve * Real.log R₂) = Real.sinh (ve * (Real.log R₂ - Real.log R₁)) := by
    rw [ mul_sub, Real.sinh_sub ] ; ring;
  linarith [ Real.sinh_pos_iff.2 ( show 0 < ve * ( Real.log R₂ - Real.log R₁ ) by exact mul_pos hve ( sub_pos.2 ( Real.log_lt_log hR₁ h ) ) ) ]


end
