/-! # CatalogBuild.FutureResearch.SPBBridge.SPBResearchTheorems

Auto-generated from theorem catalog database.
Domain: FutureResearch/SPBBridge
Declarations: 16
-/

import Mathlib

noncomputable section

theorem spbM_trace (a : ℝ) : (spbM a).trace = 2 := by
  norm_num [ spbM, Matrix.trace ]

/-- det(M(a)) = 1 + a² -/

theorem spbM_det (a : ℝ) : (spbM a).det = 1 + a ^ 2 := by
  simp [spbM, Matrix.det_fin_two]; ring

/-- det(M(a)) > 0 -/

theorem spbM_det_pos (a : ℝ) : 0 < (spbM a).det := by
  rw [spbM_det]; positivity

/-- M(a)ᵀ = M(-a) -/

theorem spbM_transpose (a : ℝ) : (spbM a)ᵀ = spbM (-a) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbM, Matrix.transpose_apply] <;> ring

/-- M(a) · M(b) = [[1-ab, a+b], [-(a+b), 1-ab]] -/

theorem spbM_mul (a b : ℝ) :
    spbM a * spbM b = !![1 - a * b, a + b; -(a + b), 1 - a * b] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbM, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- M(0) = I -/

theorem spbM_zero : spbM 0 = (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbM, Matrix.one_apply]

/-- det(M(a)·M(b)) = det(M(a)) · det(M(b)) -/

theorem spbM_det_mul (a b : ℝ) :
    (spbM a * spbM b).det = (spbM a).det * (spbM b).det :=
  Matrix.det_mul _ _

/-- det(M(a)·M(b)) = (1+a²)(1+b²) -/

theorem spbM_det_mul_expand (a b : ℝ) :
    (spbM a * spbM b).det = (1 + a ^ 2) * (1 + b ^ 2) := by
  rw [spbM_det_mul, spbM_det, spbM_det]

/-- det(M(a)^n) = (1+a²)^n -/

theorem spbM_pow_det (a : ℝ) (n : ℕ) :
    (spbM a ^ n).det = (1 + a ^ 2) ^ n := by
  rw [det_pow, spbM_det]

/-
tr(M(a)·M(b)) = 2(1-ab)
-/

theorem spbM_mul_trace (a b : ℝ) : (spbM a * spbM b).trace = 2 * (1 - a * b) := by
  unfold spbM; norm_num [ Matrix.trace, Matrix.mul_apply ] ; ring;

/-! ## Part II: Basic SPB Identities -/


theorem spb_one_right (x : ℝ) : spb 1 x = (1 + x) / (1 - x) := by
  unfold spb; ring

/-- Norm multiplicativity -/

theorem spbF_neg_neg {F : Type*} [Field F] (x y : F) :
    spbF (-x) (-y) = -spbF x y := by
  unfold spbF; ring


theorem spbF_double {F : Type*} [Field F] (x : F) :
    spbF x x = 2 * x / (1 - x ^ 2) := by
  unfold spbF; ring


theorem spb_sum_neg_first (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y + spb (-x) y = 2 * y * (1 + x ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - -x * y = 1 + x * y := by ring
  rw [h3, div_add_div _ _ h1 h2]
  congr 1
  ring

/-! ## Part VII: Power Iteration -/


theorem weierstrass_spb (θ : ℝ) (_hcos : cos (θ / 2) ≠ 0) (_hcos2 : cos θ ≠ 0) :
    spb (tan (θ / 2)) (tan (θ / 2)) = tan θ := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.tan_two_mul ];
  unfold spb; ring;

/-! ## Part X: Inversion Properties -/

/-
spb(1/x, 1/y) = -spb(x,y)
-/

theorem spb_self_reciprocal_degen (x : ℝ) (hx : x ≠ 0) :
    spb x (1/x) = 0 := by
  simp only [spb, one_div, add_comm x, mul_inv_cancel₀ hx, sub_self, div_zero]

/-! ## Part XI: More identities -/

/-- spb(x,x) · (1 - x²) = 2x -/

end
