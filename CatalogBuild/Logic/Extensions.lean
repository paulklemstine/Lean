/-! # CatalogBuild.Logic.Extensions

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7
-/

import Mathlib

/-- [Section: # CatalogBuild.Logic.Extensions
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7] -/
theorem ppt_c_odd (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (hodd_a : Odd a) (heven_b : Even b) : Odd c := by
  apply_fun fun x => x % 4 at h
  rcases hodd_a with ⟨k, rfl⟩
  rcases heven_b with ⟨m, rfl⟩
  rcases Int.even_or_odd' c with ⟨n, rfl | rfl⟩ <;> ring_nf at * <;> norm_num at *


/-- [Section: # CatalogBuild.Logic.Extensions
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7] -/
theorem det_B₁_eq_one : Matrix.det !![(1 : ℤ), -2, 2; 2, -1, 2; 2, -2, 3] = 1 := by
  native_decide


/-- [Section: # CatalogBuild.Logic.Extensions
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 7] -/
theorem det_B₂_eq_neg_one : Matrix.det !![(1 : ℤ), 2, 2; 2, 1, 2; 2, 2, 3] = -1 := by
  native_decide


theorem det_B₃_eq_one : Matrix.det !![(-1 : ℤ), 2, 2; -2, 1, 2; -2, 2, 3] = 1 := by
  native_decide


theorem qr_from_pyth (a c : ℤ) :
    ∃ x : ℤ, x ^ 2 ≡ a ^ 2 [ZMOD c] :=
  ⟨a, Int.ModEq.refl _⟩


theorem pyth_factored (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (c - a) * (c + a) = b ^ 2 := by nlinarith [sq_abs a, sq_abs b, sq_abs c]


theorem B₂_on_345 :
    !![(1 : ℤ), 2, 2; 2, 1, 2; 2, 2, 3] *ᵥ ![3, 4, 5] = ![21, 20, 29] := by
  ext i; fin_cases i <;> simp [Matrix.mulVec, dotProduct, Fin.sum_univ_three]


