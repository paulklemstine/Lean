/-! # CatalogBuild.Algebra.Core.CongruentNumber

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.Core.CongruentNumber
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5] -/
theorem congruent_map_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c ^ 2 * (b ^ 2 - a ^ 2) ^ 2 = c ^ 6 - 4 * a ^ 2 * b ^ 2 * c ^ 2 := by
      grind +ring




/-- [Section: # CatalogBuild.Algebra.Core.CongruentNumber
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5] -/
theorem pyth_quartic_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (b ^ 2 - a ^ 2) ^ 2 = c ^ 4 - 4 * a ^ 2 * b ^ 2 := by
      grind




/-- The congruent number curve evaluated at a specific point.
E_n : y² = x³ - n²x = x(x² - n²) = x(x-n)(x+n). -/
theorem congruent_curve_factored (x n : ℤ) :
    x ^ 3 - n ^ 2 * x = x * (x - n) * (x + n) := by ring




/-- For the 2-descent on E_n, the curve has three rational 2-torsion points:
(0,0), (n,0), (-n,0). -/
theorem two_torsion_points (n : ℤ) :
    (0 : ℤ) ^ 3 - n ^ 2 * 0 = 0 ∧
    n ^ 3 - n ^ 2 * n = 0 ∧
    (-n) ^ 3 - n ^ 2 * (-n) = 0 := by
  constructor
  · ring
  constructor <;> ring




theorem pyth_a_ne_b (a b c : ℕ) (ha : 0 < a) (_hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (_hcop : Nat.Coprime a b) : a ≠ b := by
      -- If $a = b$, then $a^2 + b^2 = 2a^2 = c^2$, which implies $c = a\sqrt{2}$. However, $c$ must be an integer, so this is impossible.
      by_contra h_eq
      have h_c : c = a * Real.sqrt 2 := by
        rw [ ← sq_eq_sq₀ ] <;> ring_nf <;> norm_num ; norm_cast ; nlinarith;
      exact irrational_sqrt_two <| ⟨ c / a, by push_cast [ h_c ] ; rw [ mul_div_cancel_left₀ _ <| by positivity ] ⟩


