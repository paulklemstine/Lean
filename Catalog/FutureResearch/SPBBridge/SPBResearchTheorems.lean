import Mathlib

/-!
# SPB Research Theorems: New Frontiers for the Stereographic Projection Bridge

This file establishes new formally verified results extending the SPB framework
into matrix spectral theory, power iteration, field-theoretic identities,
and cross-domain connections.

All theorems target 0 sorry with standard axioms only.
-/

noncomputable section
open Real Matrix

namespace SPBResearch

/-! ## Core Definitions -/

/-- The SPB operation: (x + y) / (1 - xy) -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition) -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Part I: Matrix Spectral Theory -/

/-- The SPB Möbius matrix M(a) = [[1, a], [-a, 1]] -/
def spbM (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; -a, 1]

/-
tr(M(a)) = 2
-/
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

theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  unfold spb; ring

theorem spb_zero (x : ℝ) : spb x 0 = x := by simp [spb]

theorem spb_neg_self (x : ℝ) : spb x (-x) = 0 := by simp [spb]

theorem spb_neg_neg (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  unfold spb; ring

theorem spb_double (x : ℝ) : spb x x = 2 * x / (1 - x ^ 2) := by
  unfold spb; ring

theorem spb_one_right (x : ℝ) : spb 1 x = (1 + x) / (1 - x) := by
  unfold spb; ring

/-- Norm multiplicativity -/
theorem spb_norm_mult (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

/-- Brahmagupta-Fibonacci -/
theorem brahmagupta_fibonacci (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (x * y - 1) ^ 2 + (x + y) ^ 2 := by ring

theorem brahmagupta_fibonacci_alt (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (x * y + 1) ^ 2 + (x - y) ^ 2 := by ring

/-- Gaussian norm via SPB denominators -/
theorem gaussian_norm_spb (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (1 - x * y) ^ 2 + (x + y) ^ 2 := by ring

/-- Cocycle identity -/
theorem cocycle_denom (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; field_simp; ring

/-
Conjugate sum
-/
theorem spb_conj_sum (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y + spb x (-y) = 2 * x * (1 + y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb; rw [ div_add_div ] <;> ring <;> positivity;

/-
Conjugate product
-/
theorem spb_conj_prod (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y * spb x (-y) = (x ^ 2 - y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  simp_all +decide [ spb ];
  grind +revert

/-- SPB derivative is positive -/
theorem spb_deriv_pos (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + y ^ 2) / (1 - x * y) ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · exact sq_pos_of_ne_zero h

/-! ## Part III: Cancellation and Fixed Points -/

/-
spb(spb(x,y), -y) = x
-/
theorem spb_cancel (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb (spb x y) (-y) = x := by
  unfold spb;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne h <;> cases lt_or_ge x 0 <;> cases lt_or_ge y 0 <;> nlinarith

/-
spb(x, a) ≠ x when a ≠ 0
-/
theorem spb_no_fixed_point (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  unfold spb;
  rw [ Ne.eq_def, div_eq_iff h ];
  cases lt_or_gt_of_ne ha <;> cases lt_or_gt_of_ne h <;> nlinarith [ sq_nonneg x ]

/-! ## Part IV: SPB Over General Fields -/

def spbF {F : Type*} [Field F] (x y : F) : F := (x + y) / (1 - x * y)

theorem spbF_comm {F : Type*} [Field F] (x y : F) : spbF x y = spbF y x := by
  simp [spbF, add_comm, mul_comm]

theorem spbF_zero {F : Type*} [Field F] (x : F) : spbF x 0 = x := by
  simp [spbF]

theorem spbF_neg_neg {F : Type*} [Field F] (x y : F) :
    spbF (-x) (-y) = -spbF x y := by
  unfold spbF; ring

theorem spbF_double {F : Type*} [Field F] (x : F) :
    spbF x x = 2 * x / (1 - x ^ 2) := by
  unfold spbF; ring

theorem spbF_assoc {F : Type*} [Field F] (x y z : F)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spbF x y * z ≠ 0) (h4 : 1 - x * spbF y z ≠ 0) :
    spbF (spbF x y) z = spbF x (spbF y z) := by
  unfold spbF; field_simp; ring

/-! ## Part V: Tangent Connection -/

/-- tan(α + β) = spb(tan α, tan β) -/
theorem tan_add_eq_spb (α β : ℝ) (hα : cos α ≠ 0) (hβ : cos β ≠ 0) :
    tan (α + β) = spb (tan α) (tan β) := by
  rw [spb, tan_eq_sin_div_cos, sin_add, cos_add, tan_eq_sin_div_cos, tan_eq_sin_div_cos]
  field_simp

/-- Cayley maps to unit circle -/
theorem cayley_on_circle (x : ℝ) :
    ((1 - x ^ 2) / (1 + x ^ 2)) ^ 2 + (2 * x / (1 + x ^ 2)) ^ 2 = 1 := by
  have h : (1 + x ^ 2) ≠ 0 := by positivity
  field_simp; ring

/-! ## Part VI: Einstein Velocity Addition -/

theorem spbH_comm (u v : ℝ) : spbH u v = spbH v u := by
  unfold spbH; ring

theorem spbH_zero (u : ℝ) : spbH u 0 = u := by simp [spbH]

theorem spbH_neg_self (u : ℝ) : spbH u (-u) = 0 := by simp [spbH]

/-
Einstein velocity bound
-/
theorem einstein_velocity_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-- The correct sum identity: spb(x,y) + spb(-x,y) = 2y(1+x²)/((1-xy)(1+xy)) -/
theorem spb_sum_neg_first (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y + spb (-x) y = 2 * y * (1 + x ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - -x * y = 1 + x * y := by ring
  rw [h3, div_add_div _ _ h1 h2]
  congr 1
  ring

/-! ## Part VII: Power Iteration -/

def spbIter (a : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb (spbIter a n) a

theorem spbIter_zero (a : ℝ) : spbIter a 0 = 0 := rfl
theorem spbIter_one (a : ℝ) : spbIter a 1 = a := by simp [spbIter, spb]
theorem spbIter_two (a : ℝ) : spbIter a 2 = 2 * a / (1 - a ^ 2) := by
  simp [spbIter, spb]; ring

/-! ## Part VIII: Triple & Quadruple Angle -/

theorem spb_triple (x : ℝ) (h1 : 1 - x ^ 2 ≠ 0)
    (h3 : 1 - spb x x * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb; field_simp; ring

theorem spb_quadruple (x : ℝ) :
    spb (spb x x) (spb x x) =
    2 * (2 * x / (1 - x ^ 2)) / (1 - (2 * x / (1 - x ^ 2)) ^ 2) := by
  rw [spb_double x, spb_double]

/-! ## Part IX: Weierstrass Substitution -/

/-
If t = tan(θ/2), then spb(t,t) = tan(θ)
-/
theorem weierstrass_spb (θ : ℝ) (_hcos : cos (θ / 2) ≠ 0) (_hcos2 : cos θ ≠ 0) :
    spb (tan (θ / 2)) (tan (θ / 2)) = tan θ := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.tan_two_mul ];
  unfold spb; ring;

/-! ## Part X: Inversion Properties -/

/-
spb(1/x, 1/y) = -spb(x,y)
-/
theorem spb_inv_anti (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (1/x) (1/y) = -(spb x y) := by
  unfold SPBResearch.spb;
  grind

/-
spb(-1/x, -1/y) = spb(x,y)
-/
theorem spb_neg_inv_auto (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (-1/x) (-1/y) = spb x y := by
  unfold spb; ring_nf;
  grind +splitImp

/-- Note: spb(x, 1/x) is degenerate since x·(1/x) = 1 makes the denominator 0.
    In Lean, spb(x, 1/x) = 0 for all x ≠ 0. -/
theorem spb_self_reciprocal_degen (x : ℝ) (hx : x ≠ 0) :
    spb x (1/x) = 0 := by
  simp only [spb, one_div, add_comm x, mul_inv_cancel₀ hx, sub_self, div_zero]

/-! ## Part XI: More identities -/

/-- spb(x,x) · (1 - x²) = 2x -/
theorem spb_double_clear (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x x * (1 - x ^ 2) = 2 * x := by
  rw [spb_double, div_mul_cancel₀ _ h]

/-- Associativity -/
theorem spb_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (_h3 : 1 - spb x y * z ≠ 0) (_h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb; field_simp; ring

end SPBResearch
end