/-! # CatalogBuild.Speculative.SciFi.KardashevScale

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

noncomputable section

/-- Kardashev number from power in watts. -/
def kardashevNumber (P : ℝ) : ℝ :=
  (Real.log P / Real.log 10 - 6) / 10


/-- [Section: ## The Continuous Kardashev Scale
K = (log₁₀(P) - 6) / 10] -/
theorem kardashev_mono {P₁ P₂ : ℝ} (h₁ : 0 < P₁) (h : P₁ < P₂) :
    kardashevNumber P₁ < kardashevNumber P₂ := by
  unfold kardashevNumber; gcongr;


theorem kardashev_typeI :
    kardashevNumber (10 ^ 16 : ℝ) = 1 := by
  unfold kardashevNumber; norm_num; ring_nf; norm_num;
  rw [ show ( 10000000000000000 : ℝ ) = 10 ^ 16 by norm_num, Real.log_pow ] ; norm_num


/-- [Section: ## Dyson Sphere: equilibrium temperature
T = (L / (4π R² σ_B))^(1/4)
Power density σ = L / (4π R²)] -/
theorem power_density_inverse_square (L R₁ R₂ : ℝ)
    (hR₁ : 0 < R₁) (hR₂ : 0 < R₂) (h : R₁ < R₂) :
    L / (4 * Real.pi * R₂ ^ 2) < L / (4 * Real.pi * R₁ ^ 2) ∨ L ≤ 0 := by
  contrapose! h;
  have h_sq : R₂ ^ 2 ≤ R₁ ^ 2 := by
    rw [ div_le_div_iff₀ ] at h <;> nlinarith [ show 0 < 4 * Real.pi * R₁ ^ 2 by positivity, show 0 < 4 * Real.pi * R₂ ^ 2 by positivity, mul_pos h.2 ( show 0 < 4 * Real.pi by positivity ) ];
  nlinarith


end
