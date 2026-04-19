import Mathlib

/-!
# Quaternionic Interpretation of 4D Ghost Structure

This file explores the connection between Pythagorean quadruples and quaternions.

## Main Results

1. **Euler's four-square identity**: The quaternion norm multiplicativity
2. **Quaternion norm characterization**: PQ ↔ quaternion norm = 2d²
3. **Sign flips as quaternion conjugation**: i, j, k conjugations
4. **Cauchy-Schwarz for PQs**: Inner product bounded by hypotenuse products
5. **Norm multiplicativity for PQ pairs**: Product of norms = 4d₁²d₂²
-/

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Definitions
-- ═══════════════════════════════════════════════════════════════

def IsPQ (a b c d : ℤ) : Prop := a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Euler's Four-Square Identity
-- ═══════════════════════════════════════════════════════════════

theorem euler_four_square (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Scaling Law
-- ═══════════════════════════════════════════════════════════════

theorem pq_scaling (a b c d k : ℤ) (h : IsPQ a b c d) :
    IsPQ (k*a) (k*b) (k*c) (k*d) := by
  simp only [IsPQ] at *; ring_nf; nlinarith [sq_nonneg k]

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Sign Flip as Quaternion Conjugation
-- ═══════════════════════════════════════════════════════════════

theorem conj_i_action (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ a (-b) (-c) d := by
  simp [IsPQ] at *; nlinarith

theorem conj_j_action (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ (-a) b (-c) d := by
  simp [IsPQ] at *; nlinarith

theorem conj_k_action (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ (-a) (-b) c d := by
  simp [IsPQ] at *; nlinarith

theorem sign_flip_a (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ (-a) b c d := by
  simp [IsPQ] at *; nlinarith

theorem sign_flip_b (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ a (-b) c d := by
  simp [IsPQ] at *; nlinarith

theorem sign_flip_c (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ a b (-c) d := by
  simp [IsPQ] at *; nlinarith

theorem sign_flip_all (a b c d : ℤ) (h : IsPQ a b c d) : IsPQ (-a) (-b) (-c) d := by
  simp [IsPQ] at *; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Norm-Based Characterization
-- ═══════════════════════════════════════════════════════════════

def quatNorm (a b c d : ℤ) : ℤ := a^2 + b^2 + c^2 + d^2

theorem pq_quat_norm (a b c d : ℤ) (h : IsPQ a b c d) :
    quatNorm a b c d = 2 * d^2 := by
  simp [quatNorm, IsPQ] at *; linarith

theorem pq_as_norm_eq (a b c d : ℤ) :
    IsPQ a b c d ↔ quatNorm a b c d = 2 * d^2 := by
  simp [quatNorm, IsPQ]; constructor <;> intro h <;> linarith

theorem reduced_norm_invariant (a b c : ℤ)
    (s₁ s₂ s₃ : ℤ) (hs₁ : s₁^2 = 1) (hs₂ : s₂^2 = 1) (hs₃ : s₃^2 = 1) :
    (s₁*a)^2 + (s₂*b)^2 + (s₃*c)^2 = a^2 + b^2 + c^2 := by nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Sum of Three Squares Examples
-- ═══════════════════════════════════════════════════════════════

theorem sum3sq_9 : (1 : ℤ)^2 + 2^2 + 2^2 = 9 := by norm_num
theorem sum3sq_49 : (2 : ℤ)^2 + 3^2 + 6^2 = 49 := by norm_num
theorem sum3sq_81 : (1 : ℤ)^2 + 4^2 + 8^2 = 81 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Cauchy-Schwarz for PQs
-- ═══════════════════════════════════════════════════════════════

theorem pq_product_relation (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) :
    (a₁*a₂ + b₁*b₂ + c₁*c₂)^2 ≤
    (a₁^2 + b₁^2 + c₁^2) * (a₂^2 + b₂^2 + c₂^2) := by
  nlinarith [sq_nonneg (a₁*b₂ - b₁*a₂), sq_nonneg (a₁*c₂ - c₁*a₂),
             sq_nonneg (b₁*c₂ - c₁*b₂)]

theorem pq_cauchy_schwarz (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPQ a₁ b₁ c₁ d₁) (h₂ : IsPQ a₂ b₂ c₂ d₂) :
    (a₁*a₂ + b₁*b₂ + c₁*c₂)^2 ≤ d₁^2 * d₂^2 := by
  have := pq_product_relation a₁ b₁ c₁ a₂ b₂ c₂
  simp [IsPQ] at h₁ h₂
  nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Lipschitz Integer Norms
-- ═══════════════════════════════════════════════════════════════

theorem lipschitz_pure_norm (a b c d : ℤ) (h : IsPQ a b c d) :
    0^2 + a^2 + b^2 + c^2 = d^2 := by
  simp [IsPQ] at h; linarith

theorem quat_product_norm (a b c d : ℤ) (h : IsPQ a b c d) :
    d^2 + a^2 + b^2 + c^2 = 2 * d^2 := by
  simp [IsPQ] at h; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Full Ghost Group
-- ═══════════════════════════════════════════════════════════════

theorem ghost_group_is_Z2_cubed (a b c d : ℤ) (h : IsPQ a b c d)
    (s₁ s₂ s₃ : ℤ) (hs₁ : s₁ = 1 ∨ s₁ = -1) (hs₂ : s₂ = 1 ∨ s₂ = -1)
    (hs₃ : s₃ = 1 ∨ s₃ = -1) :
    IsPQ (s₁ * a) (s₂ * b) (s₃ * c) d := by
  simp [IsPQ] at *
  rcases hs₁ with rfl | rfl <;> rcases hs₂ with rfl | rfl <;> rcases hs₃ with rfl | rfl <;>
    nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Norm Multiplicativity
-- ═══════════════════════════════════════════════════════════════

theorem norm_mult_pq (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h₁ : IsPQ a₁ b₁ c₁ d₁) (h₂ : IsPQ a₂ b₂ c₂ d₂) :
    (d₁^2 + a₁^2 + b₁^2 + c₁^2) * (d₂^2 + a₂^2 + b₂^2 + c₂^2) =
    4 * d₁^2 * d₂^2 := by
  simp [IsPQ] at h₁ h₂; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Axiom checks
-- ═══════════════════════════════════════════════════════════════

#print axioms euler_four_square
#print axioms pq_quat_norm
#print axioms pq_cauchy_schwarz
#print axioms conj_i_action
#print axioms norm_mult_pq
