/-! # CatalogBuild.Speculative.SciFi.Information_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

noncomputable section

/-- Gaussian channel capacity function. -/
def gaussianCapacity (W SNR : ℝ) : ℝ :=
  W * Real.log (1 + SNR) / Real.log 2


/-- [Section: # CatalogBuild.Speculative.SciFi.Information_2
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4] -/
theorem gaussianCapacity_nonneg (W SNR : ℝ) (hW : 0 ≤ W) (hSNR : 0 ≤ SNR) :
    0 ≤ gaussianCapacity W SNR := by
  exact div_nonneg ( mul_nonneg hW ( Real.log_nonneg ( by linarith ) ) ) ( Real.log_nonneg ( by norm_num ) )


/-- [Section: # CatalogBuild.Speculative.SciFi.Information_2
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4] -/
theorem gaussianCapacity_mono_SNR (W : ℝ) (hW : 0 < W) {a b : ℝ}
    (ha : 0 ≤ a) (hab : a ≤ b) :
    gaussianCapacity W a ≤ gaussianCapacity W b := by
  unfold gaussianCapacity; gcongr


/-- Abstract invariance theorem: two complexity measures agree up to a constant. -/
theorem kolmogorov_invariance {X : Type*} (K₁ K₂ : X → ℕ)
    (c : ℕ) (h : ∀ x, K₁ x ≤ K₂ x + c) (h' : ∀ x, K₂ x ≤ K₁ x + c)
    (x : X) : (K₁ x : ℤ) - (K₂ x : ℤ) ≤ c ∧ (K₂ x : ℤ) - (K₁ x : ℤ) ≤ c := by
  constructor <;> { have := h x; have := h' x; omega }


end
