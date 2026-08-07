import Mathlib
import Shared.AbstractAlgebra.SpbMatrix

/-! # CatalogBuild.Shared.Spb

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 25
-/

noncomputable section

/-- [Section: ## Core Definitions] -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The classical cross ratio of four real points. -/
def crossRatio (p q r s : ℝ) : ℝ := ((p - r) * (q - s)) / ((p - s) * (q - r))

/-- The basic difference identity for `spb`:
`spb u t - spb v t = (u - v)(1 + t²) / ((1 - ut)(1 - vt))`. -/
theorem spb_sub (t u v : ℝ) (hu : 1 - u * t ≠ 0) (hv : 1 - v * t ≠ 0) :
    spb u t - spb v t = (u - v) * (1 + t ^ 2) / ((1 - u * t) * (1 - v * t)) := by
  unfold spb
  rw [div_sub_div _ _ hu hv]
  congr 1
  ring

/-- [Section: ## Section 24: SPB Linearization Error] -/
theorem spb_linearization_error (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spb x y - (x + y) = x * y * (x + y) / (1 - x * y) := by
  unfold spb; field_simp; ring

/-- [Section: ## Section 35: SPB Lissajous] -/
theorem spb_lissajous (x : ℝ) :
    spb x x = 2 * x / (1 - x ^ 2) := by unfold spb; ring

/-- [Section: ## Möbius invariance of the cross ratio]

The `spb` translation `x ↦ spb x t` is a Möbius transformation, hence it preserves
the cross ratio.  (The two non-degeneracy hypotheses `hden`, `hden'` of the original
catalog statement are not needed: the identity holds verbatim without them, because
both sides degenerate simultaneously.) -/
theorem spb_cross_ratio_invariant (a b c d t : ℝ)
    (h1 : 1 - a * t ≠ 0) (h2 : 1 - b * t ≠ 0)
    (h3 : 1 - c * t ≠ 0) (h4 : 1 - d * t ≠ 0) :
    crossRatio (spb a t) (spb b t) (spb c t) (spb d t) = crossRatio a b c d := by
  have hK : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  set P : ℝ := (1 - a * t) * (1 - b * t) * (1 - c * t) * (1 - d * t) with hPdef
  have hP : P ≠ 0 := by
    simp only [hPdef]
    exact mul_ne_zero (mul_ne_zero (mul_ne_zero h1 h2) h3) h4
  have hm : (1 + t ^ 2) ^ 2 / P ≠ 0 := div_ne_zero (pow_ne_zero 2 hK) hP
  have hnum : (spb a t - spb c t) * (spb b t - spb d t)
      = ((a - c) * (b - d)) * ((1 + t ^ 2) ^ 2 / P) := by
    rw [spb_sub t a c h1 h3, spb_sub t b d h2 h4, hPdef]
    field_simp
  have hden : (spb a t - spb d t) * (spb b t - spb c t)
      = ((a - d) * (b - c)) * ((1 + t ^ 2) ^ 2 / P) := by
    rw [spb_sub t a d h1 h4, spb_sub t b c h2 h3, hPdef]
    field_simp
  unfold crossRatio
  rw [hnum, hden, mul_div_mul_right _ _ hm]

/-- The Jacobian identity for `spb`. -/
theorem spb_jacobian (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 =
    (1 + spb x a ^ 2) / (1 + x ^ 2) := by
  have hs : spb x a ^ 2 = (x + a) ^ 2 / (1 - x * a) ^ 2 := by unfold spb; rw [div_pow]
  have h2 : (1 - x * a) ^ 2 ≠ 0 := pow_ne_zero 2 h
  have hx : (1 : ℝ) + x ^ 2 ≠ 0 := by positivity
  have key : (1 : ℝ) + (x + a) ^ 2 / (1 - x * a) ^ 2
      = (1 + x ^ 2) * (1 + a ^ 2) / (1 - x * a) ^ 2 := by
    rw [eq_div_iff h2, add_mul, one_mul, div_mul_cancel₀ _ h2]; ring
  rw [hs, key, div_div, mul_comm ((1 - x * a) ^ 2) (1 + x ^ 2), mul_div_mul_left _ _ hx]

theorem spb_neg_first (x y : ℝ) : spb (-x) y = -(spb x (-y)) := by unfold spb; ring

/-- [Section: ## Section 4: Elliptic Classification] -/
theorem spb_discriminant (a : ℝ) :
    (spbMatrix a).trace ^ 2 - 4 * (spbMatrix a).det = -(4 * a ^ 2) := by
  rw [spbMatrix_trace, spbMatrix_det]; ring

theorem spb_neg_right (x : ℝ) : spb x (-x) = 0 := by unfold spb; simp

/-- [Section: ## Section 22: Möbius Connection] -/
theorem spb_is_moebius (t x : ℝ) :
    spb x t = (1 * x + t) / ((-t) * x + 1) := by unfold spb; ring

theorem spb_assoc (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold spb at *; field_simp; ring

theorem spb_zero_right (x : ℝ) : spb x 0 = x := by unfold spb; simp

/-- [Section: ## Section 11: Multi-Angle Formulas] -/
theorem spb_double (x : ℝ) : spb x x = 2 * x / (1 - x * x) := by unfold spb; ring

theorem spb_parabolic_at_zero :
    (spbMatrix 0).trace ^ 2 = 4 * (spbMatrix 0).det := by
  rw [spbMatrix_trace, spbMatrix_det]; norm_num

theorem spb_zero_left (x : ℝ) : spb 0 x = x := by unfold spb; simp

theorem spb_triple (x : ℝ) (h1 : 1 - x * x ≠ 0) (h2 : 1 - spb x x * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb;
  grind

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
    (spbMatrix a).trace ^ 2 < 4 * (spbMatrix a).det := by
  have h := spb_discriminant a; nlinarith [mul_self_pos.mpr ha]

/-- [Section: ## Section 12: SPB Symmetries] -/
theorem spb_odd (x y : ℝ) : spb (-x) (-y) = -spb x y := by unfold spb; ring

/-- [Section: ## Section 17: Fixed Point Theory] -/
theorem spb_no_fixed_points (a : ℝ) (ha : a ≠ 0) (x : ℝ) (hd : 1 - x * a ≠ 0) :
    spb x a ≠ x := by
  intro heq; unfold spb at heq
  have := (div_eq_iff hd).mp heq
  have : a * (1 + x ^ 2) = 0 := by nlinarith
  rcases mul_eq_zero.mp this with h1 | h2
  · exact ha h1
  · nlinarith [sq_nonneg x]

/-- [Section: ## Section 36: SPB Negation Symmetry] -/
theorem spb_neg_comm (x y : ℝ) : -(spb x y) = spb (-x) (-y) := by rw [spb_odd]




end