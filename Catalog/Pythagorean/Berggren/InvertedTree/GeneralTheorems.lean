import Mathlib

/-!
# General Theorems about the Ghost Matrix

This file proves general (∀ n) theorems about the ghost matrix M,
going beyond the concrete instance verification in other files.

## Main Results

1. **det(Mⁿ) = (−1)ⁿ**: For all n
2. **M^n preserves the Lorentz form**: For all n
3. **M is symmetric implies M^n is symmetric**: For all n
4. **Ghost map preserves the Lorentz quadratic form**: For all triples
5. **Parity conservation**: For all triples
6. **Leg difference sign flip**: For all triples
7. **Hypotenuse descent**: For positive Pythagorean triples
-/

namespace GeneralTheorems

def M : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, -2; 2, 1, -2; -2, -2, 3]
def eta : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]
def B2 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

def ghostP (a b c : ℤ) : ℤ := a + 2*b - 2*c
def ghostQ (a b c : ℤ) : ℤ := 2*a + b - 2*c
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

/-- M preserves the Lorentz form. -/
theorem M_lorentz : M.transpose * eta * M = eta := by native_decide

/-
M^n preserves the Lorentz form for all n.
-/
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

/-
M^n is symmetric for all n.
-/
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

/-- The Lorentz form is preserved by the ghost map. -/
theorem ghost_lorentz (a b c : ℤ) :
    (ghostP a b c)^2 + (ghostQ a b c)^2 - (ghostH a b c)^2 = a^2 + b^2 - c^2 := by
  simp only [ghostP, ghostQ, ghostH]; ring

/-- Sum formula: p + q + h = a + b − c. -/
theorem ghost_sum (a b c : ℤ) :
    ghostP a b c + ghostQ a b c + ghostH a b c = a + b - c := by
  simp only [ghostP, ghostQ, ghostH]; ring

/-- Leg difference sign flip: p − q = −(a − b). -/
theorem ghost_leg_diff (a b c : ℤ) :
    ghostP a b c - ghostQ a b c = -(a - b) := by
  simp only [ghostP, ghostQ]; ring

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

/-- Hypotenuse descent: for positive PPTs, ghost hypotenuse < original. -/
theorem ghost_descent (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hp : a^2 + b^2 = c^2) : ghostH a b c < c := by
  simp only [ghostH]
  have : c < a + b := by nlinarith [sq_nonneg (a - b)]
  linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Recovery (B₂ inverts M)
-- ═══════════════════════════════════════════════════════════════

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

end GeneralTheorems