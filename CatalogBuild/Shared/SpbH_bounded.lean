/-! # CatalogBuild.Shared.SpbH_bounded

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 6
-/

import Mathlib

noncomputable section

theorem spbH_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.2 ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> nlinarith only [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> nlinarith only [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-
Hyperbolic SPB is associative.
-/

theorem spbH_comm (u v : ℝ) : spbH u v = spbH v u := by
  simp [spbH, add_comm, mul_comm]

/-- Zero is the identity for hyperbolic SPB. -/

def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)

/-- Hyperbolic SPB is commutative. -/

theorem spbH_assoc (u v w : ℝ) (huv : u * v ≠ -1) (hvw : v * w ≠ -1)
    (huvw : spbH u v * w ≠ -1) (huvw' : u * spbH v w ≠ -1) :
    spbH (spbH u v) w = spbH u (spbH v w) := by
  unfold spbH at *;
  grind

/-! ## Section 5: SPB over General Fields -/

/-- SPB over an arbitrary field. -/

theorem spbH_neg_self (u : ℝ) : spbH u (-u) = 0 := by
  simp [spbH]

/-
**Einstein velocity addition is bounded**: if `|u| < 1` and `|v| < 1`,
    then `|spbH(u,v)| < 1`. Light speed is a barrier.
-/

theorem spbH_zero_right (u : ℝ) : spbH u 0 = u := by
  simp [spbH]

/-- Inverse in hyperbolic SPB. -/

end
