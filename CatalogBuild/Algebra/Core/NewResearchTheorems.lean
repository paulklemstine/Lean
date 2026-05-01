/-! # CatalogBuild.Algebra.Core.NewResearchTheorems

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 52
-/

import Mathlib

/-- ═══════════════════════════════════════════════════════════════ Core Definitions ═══════════════════════════════════════════════════════════════ -/
def nr_ghost_p (a b c : ℤ) : ℤ := a + 2 * b - 2 * c


/-- [Section: # CatalogBuild.Pythagorean.Berggren.NewResearchTheorems
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 52] -/
def nr_ghost_q (a b c : ℤ) : ℤ := 2 * a + b - 2 * c


def nr_ghost_h (a b c : ℤ) : ℤ := 3 * c - 2 * (a + b)

-- ═══════════════════════════════════════════════════════════════
-- Algebraic Identities
-- ═══════════════════════════════════════════════════════════════


theorem nr_ghost_pq_sum (a b c : ℤ) :
    nr_ghost_p a b c + nr_ghost_q a b c = 3 * (a + b) - 4 * c := by
  delta nr_ghost_p nr_ghost_q; ring


theorem nr_ghost_pq_diff (a b c : ℤ) :
    nr_ghost_p a b c - nr_ghost_q a b c = b - a := by
  delta nr_ghost_p nr_ghost_q; ring


/-- **Corrected trilinear identity**: p + q + 2h = 2c - (a+b). -/
theorem nr_ghost_trilinear (a b c : ℤ) :
    nr_ghost_p a b c + nr_ghost_q a b c + 2 * nr_ghost_h a b c + (a + b) = 2 * c := by
  delta nr_ghost_p nr_ghost_q nr_ghost_h; ring


theorem nr_ghost_pq_product (a b c : ℤ) :
    nr_ghost_p a b c * nr_ghost_q a b c =
    2 * a ^ 2 + 5 * a * b + 2 * b ^ 2 - 6 * a * c - 6 * b * c + 4 * c ^ 2 := by
  delta nr_ghost_p nr_ghost_q; ring


theorem nr_ghost_lorentz (a b c : ℤ) :
    (nr_ghost_p a b c) ^ 2 + (nr_ghost_q a b c) ^ 2 - (nr_ghost_h a b c) ^ 2 =
    a ^ 2 + b ^ 2 - c ^ 2 := by
  delta nr_ghost_p nr_ghost_q nr_ghost_h; ring


theorem nr_ghost_pythagorean (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (nr_ghost_p a b c) ^ 2 + (nr_ghost_q a b c) ^ 2 = (nr_ghost_h a b c) ^ 2 := by
  delta nr_ghost_p nr_ghost_q nr_ghost_h; nlinarith


theorem nr_ghost_energy (a b c : ℤ) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    (nr_ghost_p a b c) ^ 2 + (nr_ghost_q a b c) ^ 2 + (nr_ghost_h a b c) ^ 2 =
    2 * (nr_ghost_h a b c) ^ 2 := by
  have := nr_ghost_pythagorean a b c hpyth; linarith


theorem nr_ghost_h_mod2 (a b c : ℤ) :
    nr_ghost_h a b c % 2 = c % 2 := by
  delta nr_ghost_h; omega

-- ═══════════════════════════════════════════════════════════════
-- Quadruple Definitions
-- ═══════════════════════════════════════════════════════════════


def nr_quad_p₁ (a b _c d : ℤ) : ℤ := a + 2 * b - 2 * d


def nr_quad_p₂ (a b _c d : ℤ) : ℤ := 2 * a + b - 2 * d


def nr_quad_h (a b _c d : ℤ) : ℤ := -2 * a - 2 * b + 3 * d

-- ═══════════════════════════════════════════════════════════════
-- Quadruple Fixed Point Theorem (corrected with absolute values)
-- ═══════════════════════════════════════════════════════════════


/-- When a + b = d, the ghost p₁ = -a, so |p₁| = a. -/
theorem nr_quad_fixed_abs_p₁ (a b c d : ℤ) (ha : 0 < a) (hab : a + b = d) :
    |nr_quad_p₁ a b c d| = a := by
  have : nr_quad_p₁ a b c d = -a := by delta nr_quad_p₁; linarith
  rw [this, abs_neg, abs_of_pos ha]


/-- When a + b = d, the ghost p₂ = -b, so |p₂| = b. -/
theorem nr_quad_fixed_abs_p₂ (a b c d : ℤ) (hb : 0 < b) (hab : a + b = d) :
    |nr_quad_p₂ a b c d| = b := by
  have : nr_quad_p₂ a b c d = -b := by delta nr_quad_p₂; linarith
  rw [this, abs_neg, abs_of_pos hb]


/-- When a + b = d, the ghost hypotenuse h = d. -/
theorem nr_quad_fixed_h (a b c d : ℤ) (hab : a + b = d) :
    nr_quad_h a b c d = d := by
  delta nr_quad_h; linarith


/-- **Fixed Point Characterization**: If a + b = d and a² + b² + c² = d²,
then c² = 2ab. -/
theorem nr_quad_fixed_point_csq (a b c d : ℤ) (hab : a + b = d)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) : c ^ 2 = 2 * a * b := by
  have hd : d = a + b := hab.symm; subst hd; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Multi-axis Ghost Structure
-- ═══════════════════════════════════════════════════════════════


def nr_quad_p₁_ac (a _b c d : ℤ) : ℤ := a + 2 * c - 2 * d


def nr_quad_p₂_ac (a _b c d : ℤ) : ℤ := 2 * a + c - 2 * d


def nr_quad_h_ac (a _b c d : ℤ) : ℤ := -2 * a - 2 * c + 3 * d


def nr_quad_p₁_bc (_a b c d : ℤ) : ℤ := b + 2 * c - 2 * d


def nr_quad_p₂_bc (_a b c d : ℤ) : ℤ := 2 * b + c - 2 * d


def nr_quad_h_bc (_a b c d : ℤ) : ℤ := -2 * b - 2 * c + 3 * d


theorem nr_ghost_quad_pythagorean_ac (a b c d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (nr_quad_p₁_ac a b c d) ^ 2 + b ^ 2 + (nr_quad_p₂_ac a b c d) ^ 2 =
    (nr_quad_h_ac a b c d) ^ 2 := by
  delta nr_quad_p₁_ac nr_quad_p₂_ac nr_quad_h_ac; nlinarith


theorem nr_ghost_quad_pythagorean_bc (a b c d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + (nr_quad_p₁_bc a b c d) ^ 2 + (nr_quad_p₂_bc a b c d) ^ 2 =
    (nr_quad_h_bc a b c d) ^ 2 := by
  delta nr_quad_p₁_bc nr_quad_p₂_bc nr_quad_h_bc; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Multi-axis Lorentz Preservation
-- ═══════════════════════════════════════════════════════════════


def nr_lorentzQ₄ (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2


theorem nr_ghost_quad_lorentz_ac (a b c d : ℤ) :
    nr_lorentzQ₄ (nr_quad_p₁_ac a b c d) b (nr_quad_p₂_ac a b c d)
      (nr_quad_h_ac a b c d) = nr_lorentzQ₄ a b c d := by
  delta nr_lorentzQ₄ nr_quad_p₁_ac nr_quad_p₂_ac nr_quad_h_ac; ring


theorem nr_ghost_quad_lorentz_bc (a b c d : ℤ) :
    nr_lorentzQ₄ a (nr_quad_p₁_bc a b c d) (nr_quad_p₂_bc a b c d)
      (nr_quad_h_bc a b c d) = nr_lorentzQ₄ a b c d := by
  delta nr_lorentzQ₄ nr_quad_p₁_bc nr_quad_p₂_bc nr_quad_h_bc; ring

-- ═══════════════════════════════════════════════════════════════
-- Euclid Parameter Descent
-- ═══════════════════════════════════════════════════════════════


theorem nr_euclid_descent_h (m n : ℤ) :
    nr_ghost_h (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) =
    (m - 2 * n) ^ 2 + n ^ 2 := by
  delta nr_ghost_h; ring


theorem nr_euclid_descent_p (m n : ℤ) :
    nr_ghost_p (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) =
    -(m - n) * (m - 3 * n) := by
  delta nr_ghost_p; ring


theorem nr_euclid_descent_q (m n : ℤ) :
    nr_ghost_q (m ^ 2 - n ^ 2) (2 * m * n) (m ^ 2 + n ^ 2) =
    2 * n * (m - 2 * n) := by
  delta nr_ghost_q; ring

-- ═══════════════════════════════════════════════════════════════
-- k-tuple Ghost (the core generalization)
-- ═══════════════════════════════════════════════════════════════


/-- **General k-tuple Ghost**: For any a² + b² + R = d²,
the ghost on (a,b) produces another valid equation. -/
theorem nr_ghost_ktuple_core (a b R d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + R = d ^ 2) :
    (a + 2 * b - 2 * d) ^ 2 + (2 * a + b - 2 * d) ^ 2 + R =
    (-2 * a - 2 * b + 3 * d) ^ 2 := by
  nlinarith


theorem nr_ghost_5tuple (a b c e d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 = d ^ 2) :
    (a + 2 * b - 2 * d) ^ 2 + (2 * a + b - 2 * d) ^ 2 +
    c ^ 2 + e ^ 2 = (-2 * a - 2 * b + 3 * d) ^ 2 := by
  have : a ^ 2 + b ^ 2 + (c ^ 2 + e ^ 2) = d ^ 2 := by linarith
  have := nr_ghost_ktuple_core a b (c ^ 2 + e ^ 2) d this; linarith

-- ═══════════════════════════════════════════════════════════════
-- Descent Convergence
-- ═══════════════════════════════════════════════════════════════


theorem nr_quad_sum_ineq (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) : a + b + c > d := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (a - c), sq_nonneg (b - c),
             sq_abs (a + b + c)]


/-- For positive Pythagorean quadruples, at least one pair sum exceeds d. -/
theorem nr_quad_exists_descent (a b c d : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a + b > d ∨ a + c > d ∨ b + c > d := by
  by_contra h; push_neg at h
  nlinarith [sq_nonneg (a + b - d), sq_nonneg (a + c - d), sq_nonneg (b + c - d),
             sq_nonneg (a - b), sq_nonneg (a - c), sq_nonneg (b - c)]


theorem nr_quad_ab_descent (a b c d : ℤ) (hab : a + b > d) :
    nr_quad_h a b c d < d := by delta nr_quad_h; linarith


theorem nr_quad_ac_descent (a b c d : ℤ) (hac : a + c > d) :
    nr_quad_h_ac a b c d < d := by delta nr_quad_h_ac; linarith


theorem nr_quad_bc_descent (a b c d : ℤ) (hbc : b + c > d) :
    nr_quad_h_bc a b c d < d := by delta nr_quad_h_bc; linarith

-- ═══════════════════════════════════════════════════════════════
-- Descent Gap Formulas
-- ═══════════════════════════════════════════════════════════════


theorem nr_quad_gap_ab (a b c d : ℤ) :
    d - nr_quad_h a b c d = 2 * (a + b) - 2 * d := by delta nr_quad_h; ring


theorem nr_quad_gap_ac (a b c d : ℤ) :
    d - nr_quad_h_ac a b c d = 2 * (a + c) - 2 * d := by delta nr_quad_h_ac; ring


theorem nr_quad_gap_bc (a b c d : ℤ) :
    d - nr_quad_h_bc a b c d = 2 * (b + c) - 2 * d := by delta nr_quad_h_bc; ring

-- ═══════════════════════════════════════════════════════════════
-- Composition (Grandparent)
-- ═══════════════════════════════════════════════════════════════


theorem nr_ghost_p_composed (a b c : ℤ) :
    nr_ghost_p (nr_ghost_p a b c) (nr_ghost_q a b c) (nr_ghost_h a b c) =
    9 * a + 8 * b - 12 * c := by
  delta nr_ghost_p nr_ghost_q nr_ghost_h; ring


theorem nr_ghost_q_composed (a b c : ℤ) :
    nr_ghost_q (nr_ghost_p a b c) (nr_ghost_q a b c) (nr_ghost_h a b c) =
    8 * a + 9 * b - 12 * c := by
  delta nr_ghost_p nr_ghost_q nr_ghost_h; ring


theorem nr_ghost_h_composed (a b c : ℤ) :
    nr_ghost_h (nr_ghost_p a b c) (nr_ghost_q a b c) (nr_ghost_h a b c) =
    -12 * a - 12 * b + 17 * c := by
  delta nr_ghost_p nr_ghost_q nr_ghost_h; ring

-- ═══════════════════════════════════════════════════════════════
-- Concrete Verifications
-- ═══════════════════════════════════════════════════════════════


theorem nr_fixed_1_2_2_3 :
    |nr_quad_p₁ 1 2 2 3| = 1 ∧ |nr_quad_p₂ 1 2 2 3| = 2 ∧ nr_quad_h 1 2 2 3 = 3 := by
  simp [nr_quad_p₁, nr_quad_p₂, nr_quad_h]


theorem nr_fixed_8_9_12_17 :
    |nr_quad_p₁ 8 9 12 17| = 8 ∧ |nr_quad_p₂ 8 9 12 17| = 9 ∧ nr_quad_h 8 9 12 17 = 17 := by
  simp [nr_quad_p₁, nr_quad_p₂, nr_quad_h]


theorem nr_csq_2ab : (12 : ℤ) ^ 2 = 2 * 8 * 9 := by norm_num


theorem nr_5tuple_check : (1 : ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Corrected Characteristic Polynomial: M³ = 5M² + 5M - I
-- eigenvalues: λ = 1, 2+√3, 2-√3
-- ═══════════════════════════════════════════════════════════════


theorem nr_char_poly_p (a b c : ℤ) :
    let p₂ := 9 * a + 8 * b - 12 * c
    let q₂ := 8 * a + 9 * b - 12 * c
    let h₂ := -12 * a - 12 * b + 17 * c
    nr_ghost_p p₂ q₂ h₂ = 5 * p₂ + 5 * (nr_ghost_p a b c) - a := by
  delta nr_ghost_p; ring


theorem nr_char_poly_q (a b c : ℤ) :
    let p₂ := 9 * a + 8 * b - 12 * c
    let q₂ := 8 * a + 9 * b - 12 * c
    let h₂ := -12 * a - 12 * b + 17 * c
    nr_ghost_q p₂ q₂ h₂ = 5 * q₂ + 5 * (nr_ghost_q a b c) - b := by
  delta nr_ghost_q; ring


theorem nr_char_poly_h (a b c : ℤ) :
    let p₂ := 9 * a + 8 * b - 12 * c
    let q₂ := 8 * a + 9 * b - 12 * c
    let h₂ := -12 * a - 12 * b + 17 * c
    nr_ghost_h p₂ q₂ h₂ = 5 * h₂ + 5 * (nr_ghost_h a b c) - c := by
  delta nr_ghost_h; ring

-- ═══════════════════════════════════════════════════════════════
-- Axiom Checks
-- ═══════════════════════════════════════════════════════════════

#print axioms nr_ghost_pythagorean
#print axioms nr_ghost_h_mod2
#print axioms nr_quad_fixed_abs_p₁
#print axioms nr_quad_fixed_point_csq
#print axioms nr_ghost_quad_pythagorean_ac
#print axioms nr_ghost_quad_pythagorean_bc
#print axioms nr_ghost_ktuple_core
#print axioms nr_quad_sum_ineq
#print axioms nr_quad_exists_descent
#print axioms nr_char_poly_p


