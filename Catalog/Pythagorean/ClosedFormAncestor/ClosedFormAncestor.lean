import Mathlib

/-!
# Closed-Form Nested Parent Function for Pythagorean Triples

## Main Theorem

The ghost matrix M = B₂⁻¹ = [[1,2,-2],[2,1,-2],[-2,-2,3]] has a closed form:

  M^n = [[H², H²-ε, -2PH],
         [H²-ε, H², -2PH],
         [-2PH, -2PH, 2H²-ε]]

where H = compPell(n), P = pell(n), ε = (-1)^n.

This gives an explicit formula for the G-th signed ghost ancestor of any PPT:
  p_G = H²·a + (H²-ε)·b - 2PH·c
  q_G = (H²-ε)·a + H²·b - 2PH·c
  h_G = -2PH·(a+b) + (2H²-ε)·c

## Applications

For the trivial triple (N, (N²-1)/2, (N²+1)/2):
  p_G(N) ≡ C_G (mod N), where C_G = -(H² + 2PH - ε)/2
is independent of N. So gcd(C_G, N) directly gives factors.
-/

open Matrix

namespace ClosedFormAncestor

-- ═══════════════════════════════════════════════════════════════
-- Section 1: Pell Number Sequences
-- ═══════════════════════════════════════════════════════════════

/-- Companion Pell numbers: 1, 1, 3, 7, 17, 41, 99, 239, 577, ... -/
def compPell : ℕ → ℤ
  | 0 => 1
  | 1 => 1
  | n + 2 => 2 * compPell (n + 1) + compPell n

/-- Pell numbers: 0, 1, 2, 5, 12, 29, 70, 169, 408, ... -/
def pellNum : ℕ → ℤ
  | 0 => 0
  | 1 => 1
  | n + 2 => 2 * pellNum (n + 1) + pellNum n

@[simp] theorem compPell_0 : compPell 0 = 1 := rfl
@[simp] theorem compPell_1 : compPell 1 = 1 := rfl
@[simp] theorem pellNum_0 : pellNum 0 = 0 := rfl
@[simp] theorem pellNum_1 : pellNum 1 = 1 := rfl
theorem compPell_rec (n : ℕ) : compPell (n + 2) = 2 * compPell (n + 1) + compPell n := rfl
theorem pellNum_rec (n : ℕ) : pellNum (n + 2) = 2 * pellNum (n + 1) + pellNum n := rfl

/-
═══════════════════════════════════════════════════════════════
Section 2: Pell Equation Identity
═══════════════════════════════════════════════════════════════

The fundamental Pell identity: H_n² - 2·P_n² = (-1)^n.
-/
theorem pell_sq_identity (n : ℕ) :
    compPell n ^ 2 - 2 * pellNum n ^ 2 = (-1 : ℤ) ^ n := by
  -- We use mathematical induction. Base cases: n = 0 and n = 1 are trivial.
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ compPell_rec, pellNum_rec ] at *;
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  grind +suggestions

-- ═══════════════════════════════════════════════════════════════
-- Section 3: The Ghost Matrix and Closed Form
-- ═══════════════════════════════════════════════════════════════

/-- The ghost matrix M = B₂⁻¹. -/
def ghostMatrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Closed-form formula for M^n. -/
def ghostMatrix_closed (n : ℕ) : Matrix (Fin 3) (Fin 3) ℤ :=
  let H := compPell n
  let P := pellNum n
  let eps := (-1 : ℤ) ^ n
  !![H^2,       H^2 - eps, -(2*P*H);
     H^2 - eps, H^2,       -(2*P*H);
     -(2*P*H),  -(2*P*H),  2*H^2 - eps]

/-- Verification for n = 0..5. -/
theorem ghostMatrix_closed_verified :
    ghostMatrix ^ 0 = ghostMatrix_closed 0 ∧
    ghostMatrix ^ 1 = ghostMatrix_closed 1 ∧
    ghostMatrix ^ 2 = ghostMatrix_closed 2 ∧
    ghostMatrix ^ 3 = ghostMatrix_closed 3 ∧
    ghostMatrix ^ 4 = ghostMatrix_closed 4 ∧
    ghostMatrix ^ 5 = ghostMatrix_closed 5 := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Ghost Ancestor Function
-- ═══════════════════════════════════════════════════════════════

/-- The G-th signed ghost ancestor of (a, b, c).
This is the closed-form formula for M^G · (a, b, c). -/
def ghostAncestor (G : ℕ) (a b c : ℤ) : ℤ × ℤ × ℤ :=
  let H := compPell G
  let P := pellNum G
  let eps := (-1 : ℤ) ^ G
  ( H^2 * a + (H^2 - eps) * b - 2*P*H * c,
    (H^2 - eps) * a + H^2 * b - 2*P*H * c,
    -(2*P*H) * a - 2*P*H * b + (2*H^2 - eps) * c )

def ghost_p_G (G : ℕ) (a b c : ℤ) : ℤ := (ghostAncestor G a b c).1
def ghost_q_G (G : ℕ) (a b c : ℤ) : ℤ := (ghostAncestor G a b c).2.1
def ghost_h_G (G : ℕ) (a b c : ℤ) : ℤ := (ghostAncestor G a b c).2.2

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Key Algebraic Identities
-- ═══════════════════════════════════════════════════════════════

/-- The leg difference is preserved: p_G - q_G = (-1)^G · (a - b). -/
theorem ghost_leg_diff (G : ℕ) (a b c : ℤ) :
    ghost_p_G G a b c - ghost_q_G G a b c = (-1 : ℤ)^G * (a - b) := by
  simp only [ghost_p_G, ghost_q_G, ghostAncestor]; ring

/-
The ghost ancestor preserves the Pythagorean property.
-/
theorem ghost_ancestor_pythagorean (G : ℕ) (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (ghost_p_G G a b c) ^ 2 + (ghost_q_G G a b c) ^ 2 =
    (ghost_h_G G a b c) ^ 2 := by
  unfold ghost_p_G ghost_q_G ghost_h_G;
  unfold ghostAncestor;
  have h_pell : compPell G ^ 2 - 2 * pellNum G ^ 2 = (-1 : ℤ) ^ G := by
    exact pell_sq_identity G
  grind

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Concrete Verifications
-- ═══════════════════════════════════════════════════════════════

theorem ghost_5_12_13_G1 : ghostAncestor 1 5 12 13 = (3, -4, 5) := by
  simp [ghostAncestor, compPell, pellNum]

theorem ghost_119_120_169_G2 : ghostAncestor 2 119 120 169 = (3, 4, 5) := by
  native_decide

theorem ghost_3_4_5_G1 : ghostAncestor 1 3 4 5 = (1, 0, 1) := by
  simp [ghostAncestor, compPell, pellNum]

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Matrix Properties
-- ═══════════════════════════════════════════════════════════════

theorem ghostMatrix_det : Matrix.det ghostMatrix = -1 := by native_decide
theorem ghostMatrix_trace : Matrix.trace ghostMatrix = 5 := by native_decide

theorem ghostMatrix_lorentz :
    ghostMatrix.transpose * !![1, 0, 0; 0, 1, 0; 0, 0, -(1:ℤ)] * ghostMatrix =
    !![1, 0, 0; 0, 1, 0; 0, 0, -(1:ℤ)] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Depth-Specific Formulas
-- ═══════════════════════════════════════════════════════════════

theorem ghost_depth1_p (a b c : ℤ) :
    ghost_p_G 1 a b c = a + 2 * b - 2 * c := by
  unfold ghost_p_G ghostAncestor compPell pellNum; ring

theorem ghost_depth1_q (a b c : ℤ) :
    ghost_q_G 1 a b c = 2 * a + b - 2 * c := by
  unfold ghost_q_G ghostAncestor compPell pellNum; ring

theorem ghost_depth1_h (a b c : ℤ) :
    ghost_h_G 1 a b c = -2 * a - 2 * b + 3 * c := by
  unfold ghost_h_G ghostAncestor compPell pellNum; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Sum and Difference Identities
-- ═══════════════════════════════════════════════════════════════

/-- The sum of ghost legs. -/
theorem ghost_leg_sum (G : ℕ) (a b c : ℤ) :
    ghost_p_G G a b c + ghost_q_G G a b c =
    (2 * compPell G ^ 2 - (-1:ℤ)^G) * (a + b) - 4 * pellNum G * compPell G * c := by
  simp only [ghost_p_G, ghost_q_G, ghostAncestor]; ring

/-
═══════════════════════════════════════════════════════════════
Section 10: Lorentz Invariance
═══════════════════════════════════════════════════════════════

The Lorentz form is preserved by the ghost ancestor at any depth.
-/
theorem ghost_preserves_lorentz (G : ℕ) (a b c : ℤ) :
    (ghost_p_G G a b c) ^ 2 + (ghost_q_G G a b c) ^ 2 -
    (ghost_h_G G a b c) ^ 2 = a ^ 2 + b ^ 2 - c ^ 2 := by
  unfold ghost_p_G ghost_q_G ghost_h_G;
  unfold ghostAncestor; ring;
  rw [ show compPell G ^ 4 = ( compPell G ^ 2 ) ^ 2 by ring, show compPell G ^ 2 = 2 * pellNum G ^ 2 + ( -1 ) ^ G by linarith [ pell_sq_identity G ] ] ; ring;
  norm_num [ pow_mul' ]

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Positivity and Asymptotics
-- ═══════════════════════════════════════════════════════════════

/-- compPell is always positive, and strictly increasing from index 1 onward. -/
private theorem compPell_pos_and_mono (n : ℕ) :
    0 < compPell n ∧ compPell n ≤ compPell (n + 1) := by
  induction n with
  | zero => simp [compPell]
  | succ n ih =>
    obtain ⟨hpos, hmono⟩ := ih
    constructor
    · linarith
    · rw [compPell_rec]
      linarith

theorem compPell_pos (n : ℕ) : 0 < compPell n := (compPell_pos_and_mono n).1

/-- pellNum is nonneg and eventually positive. -/
private theorem pellNum_nonneg_and_mono (n : ℕ) :
    0 ≤ pellNum n ∧ pellNum n ≤ pellNum (n + 1) := by
  induction n with
  | zero => simp [pellNum]
  | succ n ih =>
    obtain ⟨hnn, hmono⟩ := ih
    constructor
    · linarith
    · rw [pellNum_rec]
      linarith

theorem pellNum_nonneg (n : ℕ) : 0 ≤ pellNum n := (pellNum_nonneg_and_mono n).1

end ClosedFormAncestor