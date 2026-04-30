import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.GeneralTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 19
-/

def ghostH (a b c : ℤ) : ℤ := -2*a - 2*b + 3*c

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Determinant Formula (general)
-- ═══════════════════════════════════════════════════════════════

/-- det(M) = −1. -/
theorem det_M : M.det = -1 := by native_decide

/-- det(M^n) = (−1)^n for all n. -/
theorem det_pow (n : ℕ) : (M ^ n).det = (-1) ^ n := by
  rw [Matrix.det_pow]; simp [det_M]

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Lorentz Form Preservation (general)
-- ═══════════════════════════════════════════════════════════════

theorem pow_lorentz (n : ℕ) : (M ^ n).transpose * eta * (M ^ n) = eta := by
  induction' n with n ih;
  · native_decide +revert;
  · simp_all +decide [ mul_assoc, pow_succ ];
    simp_all +decide [ ← mul_assoc, ← pow_succ' ]

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Symmetry (general)
-- ═══════════════════════════════════════════════════════════════

/-- M is symmetric. -/
theorem M_symmetric : M = M.transpose := by native_decide

theorem pow_symmetric (n : ℕ) : (M ^ n) = (M ^ n).transpose := by
  rw [ eq_comm ];
  induction n <;> simp_all +decide [ pow_succ' ];
  rename_i k hk; rw [ ← pow_succ', ← hk, pow_succ ] ;
  exact M_symmetric ▸ hk ▸ rfl

-- ═══════════════════════════════════════════════════════════════
-- Section 4: B₂ · M = I (inverse relationship)
-- ═══════════════════════════════════════════════════════════════

theorem B2_M_eq_one : B2 * M = 1 := by native_decide

theorem M_B2_eq_one : M * B2 = 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Ghost Map Algebraic Properties (general)
-- ═══════════════════════════════════════════════════════════════

/-- Parity conservation. -/
theorem ghost_parity_a (a b c : ℤ) : ghostP a b c % 2 = a % 2 := by
  unfold ghostP; omega

theorem ghost_parity_b (a b c : ℤ) : ghostQ a b c % 2 = b % 2 := by
  unfold ghostQ; omega

theorem ghost_parity_c (a b c : ℤ) : ghostH a b c % 2 = c % 2 := by
  unfold ghostH; omega

/-- Pythagorean preservation. -/
theorem ghost_pyth (a b c : ℤ) (hp : a^2 + b^2 = c^2) :
    (ghostP a b c)^2 + (ghostQ a b c)^2 = (ghostH a b c)^2 := by
  have := ghost_lorentz a b c
  linarith

/-- Forward B₂ applied to (p,q,h) recovers (a,b,c). -/
theorem recovery_a (a b c : ℤ) :
    ghostP a b c + 2 * ghostQ a b c + 2 * ghostH a b c = a := by
  simp only [ghostP, ghostQ, ghostH]; ring

theorem recovery_b (a b c : ℤ) :
    2 * ghostP a b c + ghostQ a b c + 2 * ghostH a b c = b := by
  simp only [ghostP, ghostQ, ghostH]; ring

theorem recovery_c (a b c : ℤ) :
    2 * ghostP a b c + 2 * ghostQ a b c + 3 * ghostH a b c = c := by
  simp only [ghostP, ghostQ, ghostH]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Cayley-Hamilton
-- ═══════════════════════════════════════════════════════════════

theorem cayley_hamilton :
    M ^ 3 = 5 • (M ^ 2) + 5 • M - 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Euclid Parameter Formulas
-- ═══════════════════════════════════════════════════════════════

/-- Ghost map in terms of Euclid parameters m, n. -/
theorem ghostP_euclid (m n : ℤ) :
    ghostP (m^2 - n^2) (2*m*n) (m^2 + n^2) = -(m - n) * (m - 3*n) := by
  simp only [ghostP]; ring

theorem ghostQ_euclid (m n : ℤ) :
    ghostQ (m^2 - n^2) (2*m*n) (m^2 + n^2) = 2*n*(m - 2*n) := by
  simp only [ghostQ]; ring

theorem ghostH_euclid (m n : ℤ) :
    ghostH (m^2 - n^2) (2*m*n) (m^2 + n^2) = (m - 2*n)^2 + n^2 := by
  simp only [ghostH]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms det_pow
#print axioms ghost_lorentz
#print axioms ghost_sum
#print axioms ghost_leg_diff
#print axioms ghost_parity_a
#print axioms ghost_pyth
#print axioms ghost_descent
#print axioms recovery_a
#print axioms ghostP_euclid

