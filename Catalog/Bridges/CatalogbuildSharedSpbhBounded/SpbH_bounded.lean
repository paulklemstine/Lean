import Mathlib

/-! # CatalogBuild.Shared.SpbH_bounded

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3
-/

noncomputable section

/-- The hyperbolic speed-addition law.  (Supplied here: referenced but missing.) -/
def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)

/-- [Section: # CatalogBuild.Shared.SpbH_bounded
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6] -/
theorem spbH_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.2 ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> nlinarith only [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> nlinarith only [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-- [Section: # CatalogBuild.Shared.SpbH_bounded
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 3] -/
theorem spbH_assoc (u v w : ℝ) (huv : u * v ≠ -1) (hvw : v * w ≠ -1)
    (huvw : spbH u v * w ≠ -1) (huvw' : u * spbH v w ≠ -1) :
    spbH (spbH u v) w = spbH u (spbH v w) := by
  unfold spbH at *;
  grind

/-- Inverse in hyperbolic SPB. -/
theorem spbH_neg_self (u : ℝ) : spbH u (-u) = 0 := by
  simp [spbH]

end