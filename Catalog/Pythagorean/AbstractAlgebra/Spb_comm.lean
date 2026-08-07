import Mathlib

/-! # CatalogBuild.Shared.Spb_comm

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 25

The SPB ("stereographic projection bridge") operation `spb x y = (x+y)/(1-x*y)`
is the tangent addition law.  It is the Möbius transformation with matrix
`!![1, a; -a, 1]`, and this file records its algebraic identities, its
Möbius/cross-ratio geometry, and the elliptic classification of the associated
`SL(2,ℝ)`-type matrix.
-/

noncomputable section

open Matrix

/-- [Section: ## Core Definitions] -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The cross ratio of four reals. -/
def crossRatio (a b c d : ℝ) : ℝ := ((a - c) * (b - d)) / ((a - d) * (b - c))

/-- The Möbius matrix implementing `x ↦ spb x a`. -/
def spbMat (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ := !![1, a; -a, 1]

theorem spbMat_trace (a : ℝ) : (spbMat a).trace = 2 := by
  simp [spbMat, Matrix.trace_fin_two]
  norm_num

theorem spbMat_det (a : ℝ) : (spbMat a).det = 1 + a ^ 2 := by
  simp [spbMat, Matrix.det_fin_two]
  ring

/-- [Section: ## Section 24: SPB Linearization Error] -/
theorem spb_linearization_error (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y - (x + y) = x * y * (x + y) / (1 - x * y) := by
  unfold spb; field_simp; ring

/-- [Section: ## Section 35: SPB Lissajous] -/
theorem spb_lissajous (x : ℝ) :
    spb x x = 2 * x / (1 - x ^ 2) := by unfold spb; ring

/-- Difference of two SPB translates, in lowest terms. -/
theorem spb_sub_of (t u v : ℝ) (hu : 1 - u * t ≠ 0) (hv : 1 - v * t ≠ 0) :
    spb u t - spb v t = (u - v) * (1 + t ^ 2) / ((1 - u * t) * (1 - v * t)) := by
  unfold spb
  rw [div_sub_div _ _ hu hv]
  congr 1
  ring

/-- [Section: # CatalogBuild.Shared.Spb_comm
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 25] -/
theorem spb_cross_ratio_invariant (a b c d t : ℝ)
    (h1 : 1 - a * t ≠ 0) (h2 : 1 - b * t ≠ 0)
    (h3 : 1 - c * t ≠ 0) (h4 : 1 - d * t ≠ 0)
    (hden : (a - d) * (b - c) ≠ 0)
    (hden' : (spb a t - spb d t) * (spb b t - spb c t) ≠ 0) :
    crossRatio (spb a t) (spb b t) (spb c t) (spb d t) = crossRatio a b c d := by
  rw [spb_sub_of t a d h1 h4, spb_sub_of t b c h2 h3] at hden'
  unfold crossRatio
  rw [spb_sub_of t a c h1 h3, spb_sub_of t b d h2 h4,
      spb_sub_of t a d h1 h4, spb_sub_of t b c h2 h3]
  rw [div_eq_div_iff hden' hden]
  field_simp

theorem spb_jacobian (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 =
    (1 + spb x a ^ 2) / (1 + x ^ 2) := by
  have hx : (1:ℝ) + x ^ 2 ≠ 0 := by positivity
  have h2 : ((1:ℝ) - x * a) ^ 2 ≠ 0 := pow_ne_zero 2 h
  have key : (1 + spb x a ^ 2) * (1 - x * a) ^ 2 = (1 + x ^ 2) * (1 + a ^ 2) := by
    unfold spb; field_simp; ring
  rw [div_eq_div_iff h2 hx]
  linear_combination -key

theorem spb_neg_first (x y : ℝ) : spb (-x) y = -(spb x (-y)) := by unfold spb; ring

/-- [Section: ## Section 4: Elliptic Classification] -/
theorem spb_discriminant (a : ℝ) :
    (spbMat a).trace ^ 2 - 4 * (spbMat a).det = -(4 * a ^ 2) := by
  rw [spbMat_trace, spbMat_det]; ring

theorem spb_neg_right (x : ℝ) : spb x (-x) = 0 := by unfold spb; simp

/-- [Section: ## Section 22: Möbius Connection] -/
theorem spb_is_moebius (t x : ℝ) :
    spb x t = (1 * x + t) / ((-t) * x + 1) := by unfold spb; ring

theorem spb_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  have hD : (1:ℝ) - x * y - y * z - x * z ≠ 0 := by
    have e : (1 - x * y) * (1 - spb x y * z) = 1 - x * y - y * z - x * z := by
      unfold spb; field_simp; ring
    rw [← e]; exact mul_ne_zero h1 h3
  have e1 : spb (spb x y) z = (x + y + z - x * y * z) / (1 - x * y - y * z - x * z) := by
    unfold spb at h3 ⊢
    rw [div_eq_div_iff (by intro h; exact h3 (by rw [h])) hD]
    field_simp
    ring
  have e2 : spb x (spb y z) = (x + y + z - x * y * z) / (1 - x * y - y * z - x * z) := by
    unfold spb at h4 ⊢
    rw [div_eq_div_iff (by intro h; exact h4 (by rw [h])) hD]
    field_simp
    ring
  rw [e1, e2]

theorem spb_zero_right (x : ℝ) : spb x 0 = x := by unfold spb; simp

/-- [Section: ## Section 11: Multi-Angle Formulas] -/
theorem spb_double (x : ℝ) : spb x x = 2 * x / (1 - x * x) := by unfold spb; ring

theorem spb_parabolic_at_zero :
    (spbMat 0).trace ^ 2 = 4 * (spbMat 0).det := by
  rw [spbMat_trace, spbMat_det]; norm_num

theorem spb_zero_left (x : ℝ) : spb 0 x = x := by unfold spb; simp

theorem spb_triple (x : ℝ) (h1 : 1 - x * x ≠ 0) (h2 : 1 - spb x x * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  have h1' : (1:ℝ) - x ^ 2 ≠ 0 := by rw [pow_two]; exact h1
  have hD : (1:ℝ) - 3 * x ^ 2 ≠ 0 := by
    have e : (1 - x * x) * (1 - spb x x * x) = 1 - 3 * x ^ 2 := by
      unfold spb; field_simp; ring
    rw [← e]; exact mul_ne_zero h1 h2
  unfold spb at h2 ⊢
  rw [div_eq_div_iff (by intro h; exact h2 (by rw [h])) hD]
  field_simp
  ring

/-- [Section: ## Section 1: SPB Algebraic Structure] -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := by unfold spb; ring

theorem spb_moebius_det_pos (t : ℝ) : 1 * 1 - t * (-t) > 0 := by
  nlinarith [sq_nonneg t]

theorem spb_idempotent_iff (x : ℝ) (h : 1 - x * x ≠ 0) :
    spb x x = x ↔ x = 0 := by
  constructor
  · intro heq; unfold spb at heq
    have := (div_eq_iff h).mp heq
    have : x * (1 + x ^ 2) = 0 := by nlinarith
    rcases mul_eq_zero.mp this with h1 | h2
    · exact h1
    · nlinarith [sq_nonneg x]
  · intro h; rw [h]; simp [spb]

/-- The denominator pattern: 1 - spb(x,y)·z relates to three-body interactions. -/
theorem spb_three_body (x y z : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = 1 - x * y - (x + y) * z := by
  unfold spb; field_simp

/-- [Section: ## Section 12: SPB Symmetries] -/
theorem spb_odd (x y : ℝ) : spb (-x) (-y) = -spb x y := by unfold spb; ring

/-- [Section: ## Section 36: SPB Negation Symmetry] -/
theorem spb_neg_comm (x y : ℝ) : -(spb x y) = spb (-x) (-y) := by rw [spb_odd]

/-- [Section: ## Section 18: Involution Classification] -/
theorem spb_involution_iff (a : ℝ) (h : 1 - a * a ≠ 0) :
    spb a a = 0 ↔ a = 0 := by
  constructor
  · intro heq; unfold spb at heq; rw [div_eq_zero_iff] at heq
    rcases heq with h1 | h2
    · linarith
    · exact absurd h2 h
  · intro h; rw [h]; simp [spb]

/-- [Section: ## Section 13: Cancellation Laws] -/
theorem spb_cancel_right (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 + y ^ 2 ≠ 0) :
    spb (spb x y) (-y) = x := by
  unfold spb
  rw [show (1 - (x + y) / (1 - x * y) * -y) = (1 + y ^ 2) / (1 - x * y) from by
    field_simp; ring]
  rw [show ((x + y) / (1 - x * y) + -y) = x * (1 + y ^ 2) / (1 - x * y) from by
    field_simp; ring]
  field_simp

theorem spb_elliptic (a : ℝ) (ha : a ≠ 0) :
    (spbMat a).trace ^ 2 < 4 * (spbMat a).det := by
  have hpos : (0:ℝ) < a ^ 2 :=
    lt_of_le_of_ne (sq_nonneg a) (Ne.symm (pow_ne_zero 2 ha))
  have h := spb_discriminant a
  nlinarith

/-- [Section: ## Section 17: Fixed Point Theory] -/
theorem spb_no_fixed_points (a : ℝ) (ha : a ≠ 0) (x : ℝ) (hd : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  intro heq; unfold spb at heq
  have := (div_eq_iff hd).mp heq
  have : a * (1 + x ^ 2) = 0 := by nlinarith
  rcases mul_eq_zero.mp this with h1 | h2
  · exact ha h1
  · nlinarith [sq_nonneg x]

end