import Mathlib

/-! # CatalogBuild.Shared.SpbH_bounded

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3

The hyperbolic SPB law `spbH u v = (u+v)/(1+uv)` is the relativistic velocity
addition law; the open interval `(-1,1)` is closed under it.
-/

noncomputable section

/-- Hyperbolic (relativistic) SPB: `spbH u v = (u + v)/(1 + u*v)`. -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- [Section: # CatalogBuild.Shared.SpbH_bounded
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6] -/
theorem spbH_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  obtain ⟨hu1, hu2⟩ := abs_lt.mp hu
  obtain ⟨hv1, hv2⟩ := abs_lt.mp hv
  have hden : (0:ℝ) < 1 + u * v := by nlinarith
  rw [abs_lt]
  constructor
  · rw [spbH, lt_div_iff₀ hden]; nlinarith
  · rw [spbH, div_lt_iff₀ hden]; nlinarith

/-- [Section: # CatalogBuild.Shared.SpbH_bounded
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3] -/
theorem spbH_assoc (u v w : ℝ) (huv : u * v ≠ -1) (hvw : v * w ≠ -1)
    (huvw : spbH u v * w ≠ -1) (huvw' : u * spbH v w ≠ -1) :
    spbH (spbH u v) w = spbH u (spbH v w) := by
  have hA : (1:ℝ) + u * v ≠ 0 := fun h => huv (by linarith)
  have hB : (1:ℝ) + v * w ≠ 0 := fun h => hvw (by linarith)
  have h1 : (1:ℝ) + spbH u v * w ≠ 0 := fun h => huvw (by linarith)
  have h2 : (1:ℝ) + u * spbH v w ≠ 0 := fun h => huvw' (by linarith)
  have hD : (1:ℝ) + u * v + v * w + u * w ≠ 0 := by
    have e : (1 + u * v) * (1 + spbH u v * w) = 1 + u * v + v * w + u * w := by
      unfold spbH; field_simp; ring
    rw [← e]; exact mul_ne_zero hA h1
  have e1 : spbH (spbH u v) w = (u + v + w + u * v * w) / (1 + u * v + v * w + u * w) := by
    unfold spbH at h1 ⊢
    rw [div_eq_div_iff (by intro h; exact h1 (by rw [h])) hD]
    field_simp; ring
  have e2 : spbH u (spbH v w) = (u + v + w + u * v * w) / (1 + u * v + v * w + u * w) := by
    unfold spbH at h2 ⊢
    rw [div_eq_div_iff (by intro h; exact h2 (by rw [h])) hD]
    field_simp; ring
  rw [e1, e2]

/-- Inverse in hyperbolic SPB. -/
theorem spbH_neg_self (u : ℝ) : spbH u (-u) = 0 := by
  simp [spbH]

end