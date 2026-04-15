/-! # CatalogBuild.FutureResearch.SPBGaussianIntegers

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 4
-/

import Mathlib

noncomputable section

/-- [Section: ## Section 1: Gaussian Integer Norm and SPB] -/
theorem gaussian_norm_of_spb (n : ℤ) :
    (⟨1, n⟩ : GaussianInt).norm = 1 + n ^ 2 := by
  simp +decide [ sq, Zsqrtd.norm ]


/-- Gaussian integer multiplication is norm-multiplicative. -/
theorem gaussian_mul_norm (z w : GaussianInt) :
    (z * w).norm = z.norm * w.norm :=
  Zsqrtd.norm_mul z w


theorem spb_det_product (a b : ℤ) :
    ((⟨1, a⟩ : GaussianInt) * ⟨1, b⟩).norm = (1 + a ^ 2) * (1 + b ^ 2) := by
  exact Eq.symm ( by erw [ Zsqrtd.norm_def ] ; norm_num ; ring )


/-- SPB over ℤ/pℤ has identity 0. -/
theorem spbZMod_zero {p : ℕ} [Fact (Nat.Prime p)] (x : ZMod p) :
    spbZMod x 0 = x := by
  simp [spbZMod]


end
