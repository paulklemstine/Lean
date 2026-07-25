import Mathlib

/-!
# SPB New Theorems: Extending the Stereographic Projection Bridge

This file establishes new formally verified results for the SPB framework,
extending the existing foundation in several directions:

1. **Automorphism group** — The Klein four-group structure
2. **Negation automorphism** — spb(-x, -y) = -spb(x, y)
3. **Composition automorphism** — spb(-1/x, -1/y) = spb(x, y)
4. **Cancellation law** — spb(spb(x, y), -y) = x
5. **No fixed points** — spb(x, a) ≠ x for a ≠ 0
6. **Norm multiplicativity** — The fundamental identity
7. **Brahmagupta-Fibonacci via SPB** — Sum-of-squares identity
8. **Möbius matrix representation** — SPB as matrix multiplication
9. **Conjugate identities** — Sum and product of spb(x,y) and spb(x,-y)
10. **Einstein velocity bound** — |spbH(u,v)| < 1
11. **Cayley transform** — Maps to the unit circle
12. **Cocycle condition** — Denominator associativity
-/

noncomputable section

open Real

namespace SPBNew

/-! ## Core definition -/

/-- The SPB operator. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB (Einstein velocity addition). -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-! ## Section 1: Basic Algebraic Properties -/

theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  unfold spb; ring

theorem spb_zero (x : ℝ) : spb x 0 = x := by
  simp [spb]

theorem spb_neg_self (x : ℝ) : spb x (-x) = 0 := by
  simp [spb]

theorem spb_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb; field_simp; ring

/-! ## Section 2: Automorphism Group (Klein Four-Group) -/

/-- Negation is an automorphism: spb(-x, -y) = -spb(x, y). -/
theorem spb_neg_neg (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  unfold spb; ring

/-
The composition x ↦ -1/x is an automorphism:
    spb(-1/x, -1/y) = spb(x, y) when x, y ≠ 0.
-/
theorem spb_neg_inv_auto (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (-1/x) (-1/y) = spb x y := by
  unfold spb; ring;
  grind

/-
Inversion is an anti-automorphism: spb(1/x, 1/y) = -spb(x, y).
-/
theorem spb_inv_anti (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) :
    spb (1/x) (1/y) = -spb x y := by
  unfold spb ; ring;
  grind

/-! ## Section 3: Cancellation Law -/

/-
Left cancellation: spb(spb(x, y), -y) = x.
-/
theorem spb_cancel (x y : ℝ) (h1 : 1 - x * y ≠ 0) :
    spb (spb x y) (-y) = x := by
  unfold SPBNew.spb;
  field_simp;
  rw [ div_eq_iff ] <;> cases lt_or_gt_of_ne h1 <;> nlinarith [ mul_self_nonneg y ]

/-! ## Section 4: No Fixed Points -/

/-
No fixed points: if a ≠ 0 and 1 - xa ≠ 0, then spb(x, a) ≠ x.
-/
theorem spb_no_fixed_point (x a : ℝ) (ha : a ≠ 0) (h : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  contrapose! h;
  unfold spb at h;
  rw [ div_eq_iff <| by aesop ] at h;
  cases lt_or_gt_of_ne ha <;> nlinarith [ sq_nonneg x ]

/-! ## Section 5: Norm Multiplicativity -/

/-- The fundamental norm identity:
    (1 + spb(x,y)²) · (1 - xy)² = (1 + x²)(1 + y²) -/
theorem spb_norm_mult (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

/-! ## Section 6: Self-Composition Formulas -/

/-- spb(x, x) = 2x/(1-x²), the tangent double-angle formula. -/
theorem spb_double (x : ℝ) : spb x x = 2 * x / (1 - x ^ 2) := by
  unfold spb; ring

/-
spb(spb(x,x), x) = (3x - x³)/(1 - 3x²), the tangent triple-angle formula.
-/
theorem spb_triple (x : ℝ) (h1 : 1 - x ^ 2 ≠ 0) (h2 : 1 - 3 * x ^ 2 ≠ 0)
    (h3 : 1 - spb x x * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb;
  grind

/-! ## Section 7: Brahmagupta-Fibonacci Identity -/

/-- (1+x²)(1+y²) = (xy-1)² + (x+y)² -/
theorem brahmagupta_fibonacci (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (x * y - 1) ^ 2 + (x + y) ^ 2 := by ring

/-- (1+x²)(1+y²) = (xy+1)² + (x-y)² -/
theorem brahmagupta_fibonacci_alt (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (x * y + 1) ^ 2 + (x - y) ^ 2 := by ring

/-! ## Section 8: Möbius Matrix Representation -/

/-- The 2×2 Möbius matrix for SPB: M(a) = [[1, a], [-a, 1]]. -/
def spbMatrix (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; -a, 1]

/-- det(M(a)) = 1 + a². -/
theorem spbMatrix_det (a : ℝ) : (spbMatrix a).det = 1 + a ^ 2 := by
  simp [spbMatrix, Matrix.det_fin_two]; ring

/-- det(M(a)) > 0 always. -/
theorem spbMatrix_det_pos (a : ℝ) : 0 < (spbMatrix a).det := by
  rw [spbMatrix_det]; positivity

/-- M(a) · M(b) = [[1-ab, a+b], [-(a+b), 1-ab]]. -/
theorem spbMatrix_mul (a b : ℝ) :
    spbMatrix a * spbMatrix b =
    !![1 - a * b, a + b; -(a + b), 1 - a * b] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [spbMatrix, Matrix.mul_apply, Fin.sum_univ_two] <;> ring

/-- Det multiplicativity: det(M(a)·M(b)) = det(M(a))·det(M(b)). -/
theorem spbMatrix_det_mul (a b : ℝ) :
    (spbMatrix a * spbMatrix b).det = (spbMatrix a).det * (spbMatrix b).det :=
  Matrix.det_mul _ _

/-! ## Section 9: Conjugate Identities -/

/-- spb(x, y) + spb(x, -y) = 2x(1+y²)/((1-xy)(1+xy)). -/
theorem spb_conj_sum (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y + spb x (-y) = 2 * x * (1 + y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [h3]; field_simp; ring

/-- spb(x, y) · spb(x, -y) = (x²-y²)/((1-xy)(1+xy)). -/
theorem spb_conj_prod (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + x * y ≠ 0) :
    spb x y * spb x (-y) = (x ^ 2 - y ^ 2) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb
  have h3 : (1 : ℝ) - x * (-y) = 1 + x * y := by ring
  rw [h3]; field_simp; ring

/-! ## Section 10: Einstein Velocity Bound -/

/-
If |u|, |v| < 1 then |spbH(u,v)| < 1.
-/
theorem einstein_velocity_bound (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> cases abs_cases u <;> cases abs_cases v <;> nlinarith, by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> cases abs_cases u <;> cases abs_cases v <;> nlinarith ⟩

/-! ## Section 11: Tangent Addition Connection -/

/-- tan(α + β) = spb(tan α, tan β). -/
theorem tan_add_eq_spb (α β : ℝ) (hα : cos α ≠ 0) (hβ : cos β ≠ 0) :
    tan (α + β) = spb (tan α) (tan β) := by
  rw [spb, tan_eq_sin_div_cos, sin_add, cos_add, tan_eq_sin_div_cos, tan_eq_sin_div_cos]
  field_simp

/-! ## Section 12: Cocycle Condition -/

/-- The denominators satisfy the cocycle condition:
    (1 - xy) · (1 - spb(x,y)·z) = (1 - yz) · (1 - x·spb(y,z)). -/
theorem cocycle_denom (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; field_simp; ring

/-! ## Section 13: Derivative Positivity -/

/-- ∂spb/∂x = (1+y²)/(1-xy)² is always positive. -/
theorem spb_deriv_pos (x y : ℝ) (h : (1 - x * y) ≠ 0) :
    (1 + y ^ 2) / (1 - x * y) ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg y]
  · positivity

/-! ## Section 14: SPB Iteration -/

/-- SPB iteration: spb(·, a) applied n times starting from 0. -/
def spbIter (a : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb (spbIter a n) a

theorem spbIter_zero (a : ℝ) : spbIter a 0 = 0 := rfl
theorem spbIter_one (a : ℝ) : spbIter a 1 = a := by simp [spbIter, spb]
theorem spbIter_two (a : ℝ) : spbIter a 2 = 2 * a / (1 - a * a) := by
  simp [spbIter, spb]; ring

/-! ## Section 15: Cayley Transform -/

/-- The real Cayley transform: x ↦ ((1-x²)/(1+x²), 2x/(1+x²)). -/
def cayleyReal (x : ℝ) : ℝ × ℝ :=
  ((1 - x ^ 2) / (1 + x ^ 2), 2 * x / (1 + x ^ 2))

/-
The Cayley transform maps to the unit circle: the components square-sum to 1.
-/
theorem cayley_on_circle (x : ℝ) :
    (cayleyReal x).1 ^ 2 + (cayleyReal x).2 ^ 2 = 1 := by
  unfold cayleyReal; ring;
  -- Combine the fractions over a common denominator.
  field_simp
  ring

/-! ## Section 16: Double-Argument Functional Equation -/

/-- spb(x,x) · (1 - x²) = 2x (when we can clear the denominator). -/
theorem spb_double_clear (x : ℝ) (h : 1 - x ^ 2 ≠ 0) :
    spb x x * (1 - x ^ 2) = 2 * x := by
  have : spb x x = 2 * x / (1 - x ^ 2) := spb_double x
  rw [this, div_mul_cancel₀ _ h]

end SPBNew
end