import Mathlib

/-! # CatalogBuild.Pythagorean.Quadruples.ErrorCorrection

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 25
-/

/-- ═══════════════════════════════════════════════════════════════ Section 1: Syndrome ═══════════════════════════════════════════════════════════════ -/
def syndrome (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2

theorem valid_pq_syndrome (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    syndrome a b c d = 0 := by simp [syndrome]; linarith

theorem syndrome_zero_iff (a b c d : ℤ) :
    syndrome a b c d = 0 ↔ a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  constructor
  · intro h; simp [syndrome] at h; linarith
  · intro h; simp [syndrome]; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Syndrome Change Formulas
-- ═══════════════════════════════════════════════════════════════

/-- Syndrome after corrupting component a by error e. -/
theorem syndrome_change_a (a b c d e : ℤ) (hpq : syndrome a b c d = 0) :
    syndrome (a + e) b c d = e * (2 * a + e) := by
  simp [syndrome] at *; nlinarith

/-- Syndrome after corrupting component b by error e. -/
theorem syndrome_change_b (a b c d e : ℤ) (hpq : syndrome a b c d = 0) :
    syndrome a (b + e) c d = e * (2 * b + e) := by
  simp [syndrome] at *; nlinarith

/-- Syndrome after corrupting component c by error e. -/
theorem syndrome_change_c (a b c d e : ℤ) (hpq : syndrome a b c d = 0) :
    syndrome a b (c + e) d = e * (2 * c + e) := by
  simp [syndrome] at *; nlinarith

/-- Syndrome after corrupting hypotenuse d by error e. -/
theorem syndrome_change_d (a b c d e : ℤ) (hpq : syndrome a b c d = 0) :
    syndrome a b c (d + e) = -(e * (2 * d + e)) := by
  simp [syndrome] at *; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Detectable Errors
-- ═══════════════════════════════════════════════════════════════

/-- Errors in component a are detected when e(2a+e) ≠ 0. -/
theorem error_detected_a (a b c d e : ℤ) (hpq : syndrome a b c d = 0)
    (he : e ≠ 0) (hne : 2 * a + e ≠ 0) :
    syndrome (a + e) b c d ≠ 0 := by
  rw [syndrome_change_a _ _ _ _ _ hpq]
  exact mul_ne_zero he hne

/-- Errors in hypotenuse d are detected when e(2d+e) ≠ 0. -/
theorem error_detected_d (a b c d e : ℤ) (hpq : syndrome a b c d = 0)
    (he : e ≠ 0) (hne : 2 * d + e ≠ 0) :
    syndrome a b c (d + e) ≠ 0 := by
  rw [syndrome_change_d _ _ _ _ _ hpq]
  intro h; have := neg_eq_zero.mp h; exact (mul_ne_zero he hne) this

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Undetectable = Ghost Symmetry
-- ═══════════════════════════════════════════════════════════════

/-- The undetectable error e = -2a corresponds to sign flip: (a + (-2a)) = -a. -/
theorem undetectable_is_sign_flip (a : ℤ) : a + (-2 * a) = -a := by ring

/-- Sign flip preserves syndrome (explaining undetectability). -/
theorem syndrome_sign_flip_a (a b c d : ℤ) :
    syndrome (-a) b c d = syndrome a b c d := by
  unfold syndrome; ring

theorem syndrome_sign_flip_b (a b c d : ℤ) :
    syndrome a (-b) c d = syndrome a b c d := by
  unfold syndrome; ring

theorem syndrome_sign_flip_c (a b c d : ℤ) :
    syndrome a b (-c) d = syndrome a b c d := by
  unfold syndrome; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Permutation Invariance
-- ═══════════════════════════════════════════════════════════════

theorem syndrome_perm_ab (a b c d : ℤ) :
    syndrome b a c d = syndrome a b c d := by
  unfold syndrome; ring

theorem syndrome_perm_ac (a b c d : ℤ) :
    syndrome c b a d = syndrome a b c d := by
  unfold syndrome; ring

theorem syndrome_perm_bc (a b c d : ℤ) :
    syndrome a c b d = syndrome a b c d := by
  unfold syndrome; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Multi-Component Errors
-- ═══════════════════════════════════════════════════════════════

theorem error_ab (a b c d ea eb : ℤ) (hpq : syndrome a b c d = 0) :
    syndrome (a + ea) (b + eb) c d =
    ea * (2 * a + ea) + eb * (2 * b + eb) := by
  simp [syndrome] at *; nlinarith

theorem syndrome_scaling (a b c d k : ℤ) (hpq : syndrome a b c d = 0) :
    syndrome (k * a) (k * b) (k * c) (k * d) = 0 := by
  simp [syndrome] at *; nlinarith [sq_nonneg k]

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Information Rate
-- ═══════════════════════════════════════════════════════════════

theorem information_rate : (3 : ℚ) / 4 = 0.75 := by norm_num

theorem redundancy_rate : 1 - (3 : ℚ) / 4 = 1 / 4 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Examples
-- ═══════════════════════════════════════════════════════════════

theorem pq_1223_valid : syndrome 1 2 2 3 = 0 := by native_decide

theorem pq_1223_corrupt_a : syndrome 2 2 2 3 = 3 := by native_decide

theorem pq_1223_corrupt_b : syndrome 1 3 2 3 = 5 := by native_decide

theorem pq_1223_corrupt_d : syndrome 1 2 2 4 = -7 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Positive Spatial Error
-- ═══════════════════════════════════════════════════════════════

/-- Adding a positive amount to a non-negative spatial component always
produces a positive syndrome (error is always detectable). -/
theorem spatial_error_positive (a b c d e : ℤ) (he : 0 < e)
    (hpq : syndrome a b c d = 0) (ha : 0 ≤ a) :
    syndrome (a + e) b c d > 0 := by
  rw [syndrome_change_a _ _ _ _ _ hpq]
  nlinarith

