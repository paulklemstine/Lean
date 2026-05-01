/-! # CatalogBuild.Speculative.SciFi.Information

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.Information
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 6] -/
theorem deterministic_zero_entropy :
    -((1 : ℝ) * Real.log 1) = 0 := by
  norm_num


/-- [Section: # CatalogBuild.Speculative.SciFi.Information
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 6] -/
theorem noiseless_binary_capacity : Real.log 2 > 0 := by
  positivity


theorem pigeonhole_compression (n : ℕ) (hn : 0 < n) :
    2 ^ n > 2 ^ (n - 1) := by
  exact pow_lt_pow_right₀ one_lt_two ( Nat.pred_lt hn.ne' )


theorem inverse_square_law (P d₁ d₂ : ℝ) (hP : 0 < P)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hd : d₁ < d₂) :
    P / d₂ ^ 2 < P / d₁ ^ 2 := by
  gcongr


theorem double_distance_quarter_power (P d : ℝ) (hP : 0 < P) (hd : 0 < d) :
    P / (2 * d) ^ 2 = P / d ^ 2 / 4 := by
  ring


