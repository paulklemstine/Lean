import Mathlib

/-! # CatalogBuild.EML.SPBResearchExploration

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 54
-/

noncomputable section

/-- [Section: # CatalogBuild.EML.SPBResearchExploration
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 54] -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

def cocycle (x y : ℝ) : ℝ := 1 / (1 - x * y)

def cMul (p q : ℝ × ℝ) : ℝ × ℝ :=
  (p.1 * q.1 - p.2 * q.2, p.1 * q.2 + p.2 * q.1)

def cNorm (p : ℝ × ℝ) : ℝ := p.1 ^ 2 + p.2 ^ 2

/-- [Section: ## Section 2: SPB Norm Theory] -/
theorem normSPB_pos (x : ℝ) : normSPB x > 0 := by unfold normSPB; positivity

theorem normSPB_zero : normSPB 0 = 1 := by unfold normSPB; norm_num

theorem normSPB_neg (x : ℝ) : normSPB (-x) = normSPB x := by unfold normSPB; ring

theorem normSPB_ge_one (x : ℝ) : normSPB x ≥ 1 := by
  unfold normSPB; nlinarith [sq_nonneg x]

theorem normSPB_product_identity (x y : ℝ) :
    normSPB x * normSPB y = (1 - x * y) ^ 2 + (x + y) ^ 2 := by
  unfold normSPB; ring

theorem normSPB_mul (x y : ℝ) (h : 1 - x * y ≠ 0) :
    normSPB (spb x y) * (1 - x * y) ^ 2 = normSPB x * normSPB y := by
  unfold normSPB spb; field_simp; ring

theorem normSPB_eq_one_iff (x : ℝ) : normSPB x = 1 ↔ x = 0 := by
  unfold normSPB; constructor
  · intro h; nlinarith [sq_nonneg x]
  · intro h; rw [h]; norm_num

theorem spbMat_det_pos (a : ℝ) : (spbMat a).det > 0 := by
  rw [spbMat_det]; positivity

theorem spbMat_mul_entry_00 (a b : ℝ) :
    (spbMat a * spbMat b) 0 0 = 1 - a * b := by
  simp [spbMat, Matrix.mul_apply, Fin.sum_univ_two]; ring

theorem spbMat_mul_entry_01 (a b : ℝ) :
    (spbMat a * spbMat b) 0 1 = a + b := by
  simp [spbMat, Matrix.mul_apply, Fin.sum_univ_two]; ring

theorem spbMat_mul_encodes_spb (a b : ℝ) (h : 1 - a * b ≠ 0) :
    (spbMat a * spbMat b) 0 1 / (spbMat a * spbMat b) 0 0 = spb a b := by
  rw [spbMat_mul_entry_01, spbMat_mul_entry_00]; unfold spb; ring

theorem spbMat_det_mul_norm (a b : ℝ) :
    (spbMat a * spbMat b).det = normSPB a * normSPB b := by
  rw [Matrix.det_mul, spbMat_det, spbMat_det]; unfold normSPB; ring

/-- [Section: ## Section 6: Cocycle Theory] -/
theorem cocycle_condition (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; field_simp; ring

theorem cocycle_symm (x y : ℝ) : cocycle x y = cocycle y x := by unfold cocycle; ring

theorem cocycle_zero (x : ℝ) : cocycle x 0 = 1 := by unfold cocycle; simp

theorem cocycle_series (x y : ℝ) (hxy : |x * y| < 1) :
    HasSum (fun n => (x * y) ^ n) (1 / (1 - x * y)) := by
  simpa using hasSum_geometric_of_abs_lt_one hxy

theorem projSPB_inverse (x₁ x₂ : ℝ) :
    projSPB x₁ x₂ (-x₁) x₂ = (0, x₂ ^ 2 + x₁ ^ 2) := by
  simp only [projSPB, Prod.mk.injEq]; constructor <;> ring

/-- [Section: ## Section 8: Infinitesimal Generator] -/
theorem generator_pos (x : ℝ) : (1 : ℝ) + x ^ 2 > 0 := by positivity

theorem generator_even (x : ℝ) : 1 + (-x) ^ 2 = 1 + x ^ 2 := by ring

theorem generator_ge_one (x : ℝ) : (1 : ℝ) + x ^ 2 ≥ 1 := by nlinarith [sq_nonneg x]

/-- [Section: ## Section 9: Wick Rotation Duality] -/
theorem wick_circular (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (1 - x * y) ^ 2 + (x + y) ^ 2 := by ring

theorem wick_hyperbolic (x y : ℝ) :
    (1 - x ^ 2) * (1 - y ^ 2) = (1 + x * y) ^ 2 - (x + y) ^ 2 := by ring

theorem wick_rotation_sum (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) + (1 - x ^ 2) * (1 - y ^ 2) =
    2 * (1 + x ^ 2 * y ^ 2) := by ring

/-- [Section: ## Section 10: Cauchy Distribution Connection] -/
theorem cauchy_pullback (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spb x a ^ 2) * (1 - x * a) ^ 2 = (1 + x ^ 2) * (1 + a ^ 2) := by
  unfold spb; field_simp; ring

/-- [Section: ## Section 14: Hyperbolic SPB] -/
theorem spbH_comm (x y : ℝ) : spbH x y = spbH y x := by unfold spbH; ring

theorem spbH_zero_right (x : ℝ) : spbH x 0 = x := by unfold spbH; simp

theorem spbH_odd (x y : ℝ) : spbH (-x) (-y) = -spbH x y := by unfold spbH; ring

theorem spbH_norm_identity (x y : ℝ) :
    (1 - x ^ 2) * (1 - y ^ 2) = (1 + x * y) ^ 2 - (x + y) ^ 2 := by ring

/-- [Section: ## Section 16: Complex Number Connection] -/
theorem cMul_spb_encode (x y : ℝ) :
    cMul (1, x) (1, y) = (1 - x * y, x + y) := by
  simp only [cMul, Prod.mk.injEq]; constructor <;> ring

theorem cNorm_eq_normSPB (x : ℝ) : cNorm (1, x) = normSPB x := by
  unfold cNorm normSPB; ring

theorem cNorm_mul (p q : ℝ × ℝ) : cNorm (cMul p q) = cNorm p * cNorm q := by
  unfold cNorm cMul; simp only; ring

/-- [Section: ## Section 21: SPB Matrix Inverse] -/
theorem spbMat_neg (a : ℝ) : spbMat (-a) = !![1, -a; a, 1] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [spbMat]

theorem spbMat_mul_neg_diag (a : ℝ) :
    (spbMat a * spbMat (-a)) 0 0 = 1 + a ^ 2 := by
  simp [spbMat, Matrix.mul_apply, Fin.sum_univ_two]; ring

theorem spbMat_mul_neg_offdiag (a : ℝ) :
    (spbMat a * spbMat (-a)) 0 1 = 0 := by
  simp only [spbMat, Matrix.mul_apply, Fin.sum_univ_two, Matrix.of_apply, Matrix.cons_val',
    Matrix.cons_val_zero, Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.cons_val_one,
    Matrix.head_cons, neg_neg]; ring

/-- [Section: ## Section 23: SPB Determinant Flow] -/
theorem det_flow_derivative (a : ℝ) :
    HasDerivAt (fun a => (1 : ℝ) + a ^ 2) (2 * a) a := by
  have h1 : HasDerivAt (fun a : ℝ => (1 : ℝ)) 0 a := hasDerivAt_const a 1
  have h2 : HasDerivAt (fun a : ℝ => a ^ 2) (2 * a) a := by
    have := (hasDerivAt_id a).pow 2; simpa using this
  convert h1.add h2 using 1; ring

/-- [Section: ## Section 25: Norm Parallelogram Law] -/
theorem normSPB_parallelogram (x y : ℝ) :
    normSPB (x + y) + normSPB (x - y) = 2 * (normSPB x + normSPB y) - 2 := by
  unfold normSPB; ring

/-- [Section: ## Section 26: Hyperbolic SPB Identity] -/
theorem spbH_identity (x y : ℝ) (h : 1 + x * y ≠ 0) :
    spbH x y * (1 + x * y) = x + y := by
  unfold spbH; field_simp

/-- [Section: ## Section 27: arctan as Cauchy Integral] -/
theorem arctan_deriv_is_cauchy (x : ℝ) :
    HasDerivAt Real.arctan (1 / (1 + x ^ 2)) x := by
  convert Real.hasDerivAt_arctan x using 1

/-- [Section: ## Section 28: Norm Strict Monotonicity] -/
theorem normSPB_strict_mono_pos (x y : ℝ) (hx : 0 ≤ x) (hxy : x < y) :
    normSPB x < normSPB y := by
  unfold normSPB; nlinarith [sq_nonneg x, sq_nonneg y]

/-- [Section: ## Section 29: Matrix Invertibility] -/
theorem spbMat_invertible (a : ℝ) : (spbMat a).det ≠ 0 := ne_of_gt (spbMat_det_pos a)

/-- [Section: ## Section 30: Norm Triangle] -/
theorem normSPB_triangle (x y : ℝ) :
    normSPB (x + y) ≤ normSPB x + normSPB y + 2 * |x * y| - 1 := by
  unfold normSPB
  nlinarith [sq_nonneg (x + y), sq_nonneg x, sq_nonneg y, abs_nonneg (x * y),
             sq_abs (x * y), le_abs_self (x * y)]

/-- [Section: ## Section 31: Brahmagupta-Fibonacci (Two-Square Identity)] -/
theorem four_square_identity (a b c d : ℝ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

/-- [Section: ## Section 32: Det = Norm] -/
theorem spbMat_det_eq_norm (a : ℝ) : (spbMat a).det = normSPB a := by
  rw [spbMat_det]; unfold normSPB; ring

/-- [Section: ## Section 33: Cauchy Density Positivity] -/
theorem cauchy_density_pos (x : ℝ) : 1 / (1 + x ^ 2) > 0 := by positivity

/-- [Section: ## Section 34: SPB Conjugation] -/
def spbConj (a x : ℝ) : ℝ := spb a (spb x (-a))

theorem spbConj_zero (x : ℝ) : spbConj 0 x = x := by
  simp [spbConj, spb]

/-- The SPB norm factors as N(x) = (1 + ix)(1 - ix) over ℂ.
Over ℝ, this means N(x) is irreducible as a polynomial. -/
theorem normSPB_irreducible_hint (x : ℝ) : normSPB x > 0 := normSPB_pos x

/-- The norm of a triple SPB composition: applying norm multiplicativity twice.
N(spb(spb(x,x),x)) · (1 - spb(x,x)·x)² = N(spb(x,x)) · N(x)
and N(spb(x,x)) · (1-x²)² = N(x)². -/
theorem normSPB_triple_step1 (x : ℝ) (h1 : 1 - x * x ≠ 0) :
    normSPB (spb x x) * (1 - x * x) ^ 2 = normSPB x * normSPB x := by
  exact normSPB_mul x x h1

/-- [Section: ## Section 38: New — SPB Composition of Norms] -/
theorem normSPB_triple_step2 (x : ℝ) (h2 : 1 - spb x x * x ≠ 0) :
    normSPB (spb (spb x x) x) * (1 - spb x x * x) ^ 2 =
    normSPB (spb x x) * normSPB x := by
  exact normSPB_mul (spb x x) x h2

/-- The SPB matrix M(a) has the same eigenvalues as a rotation by arctan(a)
scaled by √(1+a²). The trace being 2 means the "rotation" has a specific
relationship to the norm. -/
theorem spbMat_trace_det_relation (a : ℝ) :
    (spbMat a).trace ^ 2 + 4 * a ^ 2 = 4 * (spbMat a).det := by
  rw [spbMat_trace, spbMat_det]; ring

end