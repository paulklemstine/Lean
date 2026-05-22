import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.InvertedTreeCore

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 56
-/

/-- Inverse Berggren transform B₁⁻¹. -/
def invB₁' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Inverse Berggren transform B₂⁻¹. -/
def invB₂' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Inverse Berggren transform B₃⁻¹. -/
def invB₃' (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Inverse × Forward = Identity
-- ═══════════════════════════════════════════════════════════════

/-- B₁⁻¹ ∘ B₁ = Id (component-wise). -/
theorem invB₁'_comp_fwdB₁_fst (a b c : ℤ) :
    (invB₁' (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c)).1 = a := by
  unfold invB₁'; ring

/-- [Section: # Inverted Berggren Tree — Core Formalizations
This file formalizes the key theorems about the **inverted Berggren tree**:
the structure obtained by using the inverse Berggren matrices B₁⁻¹, B₂⁻¹, B₃⁻¹
to navigate from any primitive Pythagorean triple back to the root (3,4,5).
## Main Results
1. **Ghost Triple Theorem**: All three inverse branches preserve Q(a,b,c) = 0
2. **Universal Parent Hypotenuse**: c' = 3c - 2(a+b) is independent of branch
3. **Branch Exclusivity**: Exactly one inverse branch gives positive output
4. **Spectral Invariance**: Inverse matrices preserve the Lorentz form
5. **Descent Termination**: The parent hypotenuse strictly decreases] -/
theorem invB₁'_comp_fwdB₁_snd_fst (a b c : ℤ) :
    (invB₁' (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c)).2.1 = b := by
  unfold invB₁'; ring

theorem invB₁'_comp_fwdB₁_snd_snd (a b c : ℤ) :
    (invB₁' (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c)).2.2 = c := by
  unfold invB₁'; ring

/-- B₂⁻¹ ∘ B₂ = Id (component-wise). -/
theorem invB₂'_comp_fwdB₂_fst (a b c : ℤ) :
    (invB₂' (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c)).1 = a := by
  unfold invB₂'; ring

theorem invB₂'_comp_fwdB₂_snd_fst (a b c : ℤ) :
    (invB₂' (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c)).2.1 = b := by
  unfold invB₂'; ring

theorem invB₂'_comp_fwdB₂_snd_snd (a b c : ℤ) :
    (invB₂' (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c)).2.2 = c := by
  unfold invB₂'; ring

/-- B₃⁻¹ ∘ B₃ = Id (component-wise). -/
theorem invB₃'_comp_fwdB₃_fst (a b c : ℤ) :
    (invB₃' (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c)).1 = a := by
  unfold invB₃'; ring

theorem invB₃'_comp_fwdB₃_snd_fst (a b c : ℤ) :
    (invB₃' (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c)).2.1 = b := by
  unfold invB₃'; ring

theorem invB₃'_comp_fwdB₃_snd_snd (a b c : ℤ) :
    (invB₃' (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c)).2.2 = c := by
  unfold invB₃'; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Ghost Triple Theorem
-- ═══════════════════════════════════════════════════════════════

/-- **Ghost Triple Theorem (B₁⁻¹)**: B₁⁻¹ preserves the Lorentz form. -/
theorem invB₁'_preserves_lorentz (a b c : ℤ) :
    lorentzForm' (invB₁' a b c).1 (invB₁' a b c).2.1 (invB₁' a b c).2.2 =
    lorentzForm' a b c := by
  unfold lorentzForm' invB₁'; ring

/-- **Ghost Triple Theorem (B₂⁻¹)**: B₂⁻¹ preserves the Lorentz form. -/
theorem invB₂'_preserves_lorentz (a b c : ℤ) :
    lorentzForm' (invB₂' a b c).1 (invB₂' a b c).2.1 (invB₂' a b c).2.2 =
    lorentzForm' a b c := by
  unfold lorentzForm' invB₂'; ring

/-- **Ghost Triple Theorem (B₃⁻¹)**: B₃⁻¹ preserves the Lorentz form. -/
theorem invB₃'_preserves_lorentz (a b c : ℤ) :
    lorentzForm' (invB₃' a b c).1 (invB₃' a b c).2.1 (invB₃' a b c).2.2 =
    lorentzForm' a b c := by
  unfold lorentzForm' invB₃'; ring

/-- If (a,b,c) is Pythagorean, then B₁⁻¹(a,b,c) satisfies a'²+b'²=c'². -/
theorem invB₁'_ghost_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invB₁' a b c).1 ^ 2 + (invB₁' a b c).2.1 ^ 2 = (invB₁' a b c).2.2 ^ 2 := by
  have := invB₁'_preserves_lorentz a b c; unfold lorentzForm' at this; linarith

/-- If (a,b,c) is Pythagorean, then B₂⁻¹(a,b,c) satisfies a'²+b'²=c'². -/
theorem invB₂'_ghost_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invB₂' a b c).1 ^ 2 + (invB₂' a b c).2.1 ^ 2 = (invB₂' a b c).2.2 ^ 2 := by
  have := invB₂'_preserves_lorentz a b c; unfold lorentzForm' at this; linarith

/-- If (a,b,c) is Pythagorean, then B₃⁻¹(a,b,c) satisfies a'²+b'²=c'². -/
theorem invB₃'_ghost_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (invB₃' a b c).1 ^ 2 + (invB₃' a b c).2.1 ^ 2 = (invB₃' a b c).2.2 ^ 2 := by
  have := invB₃'_preserves_lorentz a b c; unfold lorentzForm' at this; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Universal Parent Hypotenuse Formula
-- ═══════════════════════════════════════════════════════════════

/-- **Universal Parent Hypotenuse Theorem**: All three inverse Berggren matrices
produce the SAME hypotenuse: c' = -2a - 2b + 3c = 3c - 2(a+b). -/
theorem universal_parent_hypotenuse' (a b c : ℤ) :
    (invB₁' a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invB₂' a b c).2.2 = -2*a - 2*b + 3*c ∧
    (invB₃' a b c).2.2 = -2*a - 2*b + 3*c := by
  simp [invB₁', invB₂', invB₃']

/-- The universal parent hypotenuse in the alternative form c' = 3c - 2(a+b). -/
theorem parent_hyp_alt_form' (a b c : ℤ) :
    -2*a - 2*b + 3*c = 3*c - 2*(a + b) := by ring

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Branch Exclusivity
-- ═══════════════════════════════════════════════════════════════

/-- The second components of B₁⁻¹ and B₂⁻¹ sum to zero. -/
theorem branch_excl_12' (a b c : ℤ) :
    (invB₁' a b c).2.1 + (invB₂' a b c).2.1 = 0 := by
  unfold invB₁' invB₂'; ring

/-- The first components of B₁⁻¹ and B₃⁻¹ sum to zero. -/
theorem branch_excl_13' (a b c : ℤ) :
    (invB₁' a b c).1 + (invB₃' a b c).1 = 0 := by
  unfold invB₁' invB₃'; ring

/-- B₁⁻¹ and B₂⁻¹ cannot both produce positive second components. -/
theorem no_both_positive_b_12' (a b c : ℤ)
    (h1 : 0 < (invB₁' a b c).2.1) (h2 : 0 < (invB₂' a b c).2.1) : False := by
  have := branch_excl_12' a b c; linarith

/-- B₁⁻¹ and B₃⁻¹ cannot both produce positive first components. -/
theorem no_both_positive_a_13' (a b c : ℤ)
    (h1 : 0 < (invB₁' a b c).1) (h3 : 0 < (invB₃' a b c).1) : False := by
  have := branch_excl_13' a b c; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Descent Hypotenuse Decrease
-- ═══════════════════════════════════════════════════════════════

/-- The decrease c - c' = 2(a + b - c). -/
theorem hyp_decrease_formula' (a b c : ℤ) :
    c - (-2*a - 2*b + 3*c) = 2*(a + b - c) := by ring

/-- **Triangle Inequality for PPTs**: a + b > c when a,b > 0. -/
theorem ppt_sum_exceeds_hyp' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : a + b > c := by
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b, sq_abs (a + b)]

/-- The parent hypotenuse is strictly less than the child's. -/
theorem parent_hyp_decreases' (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : -2*a - 2*b + 3*c < c := by
  have hab := ppt_sum_exceeds_hyp' a b c ha hb h; linarith

/-- Inverse Berggren matrix B₁⁻¹. -/
def B₁_inv_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Inverse Berggren matrix B₂⁻¹. -/
def B₂_inv_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Inverse Berggren matrix B₃⁻¹. -/
def B₃_inv_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- Forward Berggren matrix B₁. -/
def B₁_fwd_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Forward Berggren matrix B₂. -/
def B₂_fwd_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Forward Berggren matrix B₃. -/
def B₃_fwd_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- B₁⁻¹ · B₁ = I. -/
theorem B₁_inv_mul_B₁' : B₁_inv_m * B₁_fwd_m = 1 := by native_decide

/-- B₂⁻¹ · B₂ = I. -/
theorem B₂_inv_mul_B₂' : B₂_inv_m * B₂_fwd_m = 1 := by native_decide

/-- B₃⁻¹ · B₃ = I. -/
theorem B₃_inv_mul_B₃' : B₃_inv_m * B₃_fwd_m = 1 := by native_decide

/-- B₁ · B₁⁻¹ = I. -/
theorem B₁_mul_B₁_inv' : B₁_fwd_m * B₁_inv_m = 1 := by native_decide

/-- B₂ · B₂⁻¹ = I. -/
theorem B₂_mul_B₂_inv' : B₂_fwd_m * B₂_inv_m = 1 := by native_decide

/-- B₃ · B₃⁻¹ = I. -/
theorem B₃_mul_B₃_inv' : B₃_fwd_m * B₃_inv_m = 1 := by native_decide

/-- The Lorentz metric matrix Q = diag(1,1,-1). -/
def Q_lorentz_m : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- B₁⁻¹ preserves the Lorentz form (matrix version). -/
theorem B₁_inv_lorentz' : B₁_inv_m.transpose * Q_lorentz_m * B₁_inv_m = Q_lorentz_m := by
  native_decide

/-- B₂⁻¹ preserves the Lorentz form (matrix version). -/
theorem B₂_inv_lorentz' : B₂_inv_m.transpose * Q_lorentz_m * B₂_inv_m = Q_lorentz_m := by
  native_decide

/-- B₃⁻¹ preserves the Lorentz form (matrix version). -/
theorem B₃_inv_lorentz' : B₃_inv_m.transpose * Q_lorentz_m * B₃_inv_m = Q_lorentz_m := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Determinant and Trace Properties
-- ═══════════════════════════════════════════════════════════════

theorem det_B₁_inv' : Matrix.det B₁_inv_m = 1 := by native_decide

theorem det_B₂_inv' : Matrix.det B₂_inv_m = -1 := by native_decide

theorem det_B₃_inv' : Matrix.det B₃_inv_m = 1 := by native_decide

theorem trace_B₁_inv' : Matrix.trace B₁_inv_m = 3 := by native_decide

theorem trace_B₂_inv' : Matrix.trace B₂_inv_m = 5 := by native_decide

theorem trace_B₃_inv' : Matrix.trace B₃_inv_m = 3 := by native_decide

/-- **Spectral Duality**: Forward and inverse have the same trace. -/
theorem spectral_duality_B₁' : Matrix.trace B₁_fwd_m = Matrix.trace B₁_inv_m := by
  native_decide

theorem spectral_duality_B₂' : Matrix.trace B₂_fwd_m = Matrix.trace B₂_inv_m := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Nilpotency of B₁⁻¹ - I and B₃⁻¹ - I
-- ═══════════════════════════════════════════════════════════════

/-- B₁⁻¹ satisfies (λ-1)³ = 0 (Cayley-Hamilton for unipotent). -/
theorem B₁_inv_cayley_hamilton' :
    B₁_inv_m ^ 3 - 3 • B₁_inv_m ^ 2 + 3 • B₁_inv_m - 1 = 0 := by native_decide

/-- (B₁⁻¹ - I)³ = 0: nilpotent part has order 3. -/
theorem B₁_inv_minus_I_cubed : (B₁_inv_m - 1) ^ 3 = 0 := by native_decide

/-- (B₃⁻¹ - I)³ = 0. -/
theorem B₃_inv_minus_I_cubed : (B₃_inv_m - 1) ^ 3 = 0 := by native_decide

/-- (B₁⁻¹ - I)² ≠ 0: nilpotent index is exactly 3. -/
theorem B₁_inv_minus_I_sq_ne : (B₁_inv_m - 1) ^ 2 ≠ 0 := by native_decide

/-- (B₃⁻¹ - I)² ≠ 0. -/
theorem B₃_inv_minus_I_sq_ne : (B₃_inv_m - 1) ^ 2 ≠ 0 := by native_decide