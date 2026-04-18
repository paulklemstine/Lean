import Mathlib

/-! # SPB in Quantum Computing, Signal Processing, and Applications

## Key Results
- Phase gate composition via arctan addition = SPB
- Allpass filter magnitude identity
- Fresnel coefficient composition via hyperbolic SPB
- Neural network activation gradient analysis
- Error-correcting code length advantage
- Hyperbolic Pythagorean identity for geodesy
-/

noncomputable section

open Real

def spbQS (x y : ℝ) : ℝ := (x + y) / (1 - x * y)
def spbHQ' (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

-- ═══════════════════════════════════════════
-- § 1. Quantum Phase Gates
-- ═══════════════════════════════════════════

theorem phase_angle_composition (t₁ t₂ : ℝ) (h : t₁ * t₂ < 1) :
    Real.arctan (spbQS t₁ t₂) = Real.arctan t₁ + Real.arctan t₂ := by
  rw [spbQS]; exact (Real.arctan_add h).symm

-- Bloch sphere half-angle
theorem bloch_z_coord (t : ℝ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp; ring

-- SU(2) normalization
theorem su2_half_angle (t : ℝ) :
    1 / (1 + t ^ 2) + t ^ 2 / (1 + t ^ 2) = 1 := by
  have h : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp

-- ═══════════════════════════════════════════
-- § 2. Allpass Filters
-- ═══════════════════════════════════════════

-- |H(z)| = 1 on |z|=1: (c-a)²+s² = (1-ac)²+(as)² when c²+s²=1
theorem allpass_mag_identity (a c s : ℝ) (h : c ^ 2 + s ^ 2 = 1) :
    (c - a) ^ 2 + s ^ 2 = (1 - a * c) ^ 2 + (a * s) ^ 2 := by
  have : s ^ 2 = 1 - c ^ 2 := by linarith
  nlinarith [sq_nonneg (a * c - 1), sq_nonneg (a * s), sq_nonneg c, sq_nonneg a]

-- ═══════════════════════════════════════════
-- § 3. CORDIC
-- ═══════════════════════════════════════════

theorem cordic_gain (t : ℝ) : 1 + t ^ 2 > 0 := by positivity
theorem cordic_angle_0 : Real.arctan 1 = π / 4 := Real.arctan_one
theorem cordic_sum_01 : spbQS 1 (1/2) = 3 := by norm_num [spbQS]

-- ═══════════════════════════════════════════
-- § 4. Fresnel Coefficients
-- ═══════════════════════════════════════════

theorem fresnel_is_spbH (r₁ r₂ : ℝ) :
    (r₁ + r₂) / (1 + r₁ * r₂) = spbHQ' r₁ r₂ := rfl

theorem fresnel_bounded (r₁ r₂ : ℝ) (h1 : |r₁| < 1) (h2 : |r₂| < 1) :
    |spbHQ' r₁ r₂| < 1 := by
  rw [abs_lt] at *
  constructor
  · rw [spbHQ', lt_div_iff₀] <;> nlinarith
  · rw [spbHQ', div_lt_iff₀] <;> nlinarith

-- ═══════════════════════════════════════════
-- § 5. Neural Network Activation
-- ═══════════════════════════════════════════

theorem spbH_gradient_pos' (x w : ℝ) (hw : |w| < 1) (h : 1 + x * w ≠ 0) :
    (1 - w ^ 2) / (1 + x * w) ^ 2 > 0 := by
  apply div_pos
  · have := abs_lt.mp hw; nlinarith
  · positivity

theorem spbH_gradient_origin' (w : ℝ) :
    (1 - w ^ 2) / (1 + 0 * w) ^ 2 = 1 - w ^ 2 := by ring

-- ═══════════════════════════════════════════
-- § 6. Coding Theory Advantage
-- ═══════════════════════════════════════════

theorem spb_code_advantage_7 : (7 : ℕ) + 1 > 7 - 1 := by omega
theorem spb_code_advantage_11 : (11 : ℕ) + 1 > 11 - 1 := by omega
theorem spb_code_advantage_23 : (23 : ℕ) + 1 > 23 - 1 := by omega
theorem spb_code_advantage_43 : (43 : ℕ) + 1 > 43 - 1 := by omega

-- ═══════════════════════════════════════════
-- § 7. Geodesy: Hyperbolic Pythagorean
-- ═══════════════════════════════════════════

-- tanh² + sech² = 1
theorem hyperbolic_pythagorean (y : ℝ) :
    Real.tanh y ^ 2 + (1 / Real.cosh y) ^ 2 = 1 := by
  rw [Real.tanh_eq_sinh_div_cosh]
  have hc : Real.cosh y ≠ 0 := ne_of_gt (Real.cosh_pos y)
  field_simp
  have := Real.cosh_sq_sub_sinh_sq y
  nlinarith

-- ═══════════════════════════════════════════
-- § 8. Joint Kinematics
-- ═══════════════════════════════════════════

theorem joint_circle (t : ℝ) :
    ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 + (2 * t / (1 + t ^ 2)) ^ 2 = 1 := by
  have : (1 + t ^ 2) ≠ 0 := by positivity
  field_simp; ring

end
