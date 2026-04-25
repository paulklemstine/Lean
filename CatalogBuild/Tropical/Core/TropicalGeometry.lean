/-! # CatalogBuild.Tropical.Core.TropicalGeometry

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.Tropical.Core.TropicalGeometry
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 5] -/
theorem tropical_zero (a : WithTop ℤ) : min a ⊤ = a :=
  min_top_right a


/-- [Section: # CatalogBuild.Tropical.Core.TropicalGeometry
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 5] -/
theorem tropical_triangle {d : ℕ → ℕ → ℤ}
    (htri : ∀ x y z, d x z ≤ d x y + d y z)
    (x y z : ℕ) : d x z ≤ d x y + d y z :=
  htri x y z

-- Newton polygon: the minimum is achieved by one of the terms


/-- [Section: # CatalogBuild.Tropical.Core.TropicalGeometry
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 5] -/
theorem newton_polygon_slope (a₀ a₁ : ℤ) :
    min a₀ a₁ = a₀ ∨ min a₀ a₁ = a₁ := by
  rcases le_or_gt a₀ a₁ with h | h
  · left; exact min_eq_left h
  · right; exact min_eq_right (le_of_lt h)


theorem tropical_convex_hull (a b c : ℤ) (h : c = min a b) :
    c ≤ a ∧ c ≤ b := by
  subst h; exact ⟨min_le_left a b, min_le_right a b⟩

-- Bellman equation for shortest paths


theorem bellman_equation (d : ℕ → ℤ) (w : ℕ → ℤ)
    (h : ∀ v, d v = min (d v) (d 0 + w v)) (v : ℕ) :
    d v ≤ d 0 + w v := by
  specialize h v; omega


