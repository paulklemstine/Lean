/-! # CatalogBuild.Algebra.Diophantine.LinearDiophantine

Auto-generated from theorem catalog database.
Domain: Algebra/Diophantine
Declarations: 7
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.Diophantine.LinearDiophantine
Auto-generated from theorem catalog database.
Domain: Algebra/Diophantine
Declarations: 7] -/
theorem bezout_identity_explicit (a b : ℤ) :
    ∃ x y : ℤ, a * x + b * y = Int.gcd a b := by
  exact Int.gcd_eq_gcd_ab a b ▸ ⟨ _, _, rfl ⟩




/-- [Section: # CatalogBuild.Algebra.Diophantine.LinearDiophantine
Auto-generated from theorem catalog database.
Domain: Algebra/Diophantine
Declarations: 7] -/
theorem linear_diophantine_solvable_iff (a b c : ℤ) :
    (∃ x y : ℤ, a * x + b * y = c) ↔ (↑(Int.gcd a b) : ℤ) ∣ c := by
  constructor;
  · exact fun ⟨ x, y, h ⟩ => h ▸ dvd_add ( dvd_mul_of_dvd_left ( Int.gcd_dvd_left _ _ ) _ ) ( dvd_mul_of_dvd_left ( Int.gcd_dvd_right _ _ ) _ );
  · exact fun h => by rcases h with ⟨ k, rfl ⟩ ; exact ⟨ k * Int.gcdA a b, k * Int.gcdB a b, by rw [ Int.gcd_eq_gcd_ab ] ; ring ⟩ ;




theorem linear_diophantine_family (a b c x₀ y₀ k : ℤ) (g : ℤ)
    (hg_def : g = Int.gcd a b)
    (h : a * x₀ + b * y₀ = c) :
    a * (x₀ + k * (b / g)) + b * (y₀ - k * (a / g)) = c := by
  cases' eq_or_ne g 0 <;> simp_all +decide [ mul_left_comm, mul_assoc ];
  · lia;
  · rw [ ← h ] ; ring;
    rw [ ← Int.mul_ediv_assoc _ ( Int.gcd_dvd_left _ _ ), ← Int.mul_ediv_assoc _ ( Int.gcd_dvd_right _ _ ) ] ; ring;




/-- The homogeneous equation `ax + by = 0` always has the solution `(b, -a)`. -/
theorem linear_diophantine_homogeneous (a b : ℤ) :
    a * b + b * (-a) = 0 := by ring




theorem linear_diophantine_difference (a b c x₁ y₁ x₂ y₂ : ℤ)
    (h₁ : a * x₁ + b * y₁ = c)
    (h₂ : a * x₂ + b * y₂ = c) :
    a * (x₁ - x₂) + b * (y₁ - y₂) = 0 := by
  linear_combination h₁ - h₂




theorem linear_diophantine_coprime (a b c : ℤ)
    (hcop : Int.gcd a b = 1) :
    ∃ x y : ℤ, a * x + b * y = c := by
  exact linear_diophantine_solvable_iff a b c |>.2 ( by simp +decide [ hcop ] )




theorem linear_diophantine_zero (c : ℤ) :
    (∃ x y : ℤ, (0 : ℤ) * x + (0 : ℤ) * y = c) ↔ c = 0 := by
  grind


