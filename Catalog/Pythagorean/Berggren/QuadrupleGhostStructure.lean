/-! # CatalogBuild.Pythagorean.Berggren.QuadrupleGhostStructure

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 30
-/

import Mathlib

/-- Lorentz form for quadruples: a² + b² + c² - d². -/
def lorentzQ₄ (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2


/-- Ghost p₁ parameter for quadruples (same formula as triple p). -/
def quad_p₁ (a b _c d : ℤ) : ℤ := a + 2 * b - 2 * d


/-- Ghost p₂ parameter for quadruples (same formula as triple q). -/
def quad_p₂ (a b _c d : ℤ) : ℤ := 2 * a + b - 2 * d


/-- Ghost hypotenuse for quadruples. -/
def quad_h (a b _c d : ℤ) : ℤ := -2 * a - 2 * b + 3 * d

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Corrected Ghost Pythagorean Theorem
-- ═══════════════════════════════════════════════════════════════


/-- **Ghost Quadruple Pythagorean Theorem**: The corrected ghost parameters
(p₁, p₂, c, h) form a Pythagorean quadruple when (a, b, c, d) does.
The third coordinate c passes through UNCHANGED. -/
theorem ghost_quad_pythagorean (a b c d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (quad_p₁ a b c d) ^ 2 + (quad_p₂ a b c d) ^ 2 + c ^ 2 =
    (quad_h a b c d) ^ 2 := by
  simp only [quad_p₁, quad_p₂, quad_h]; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Universal Parent for Quadruples
-- ═══════════════════════════════════════════════════════════════


/-- The universal parent inverse for Pythagorean quadruples. -/
def universalParentQuad (a b c d : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (|quad_p₁ a b c d|, |quad_p₂ a b c d|, |c|, quad_h a b c d)


/-- The universal parent quadruple is Pythagorean. -/
theorem universalParentQuad_pythagorean (a b c d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (universalParentQuad a b c d).1 ^ 2 +
    (universalParentQuad a b c d).2.1 ^ 2 +
    (universalParentQuad a b c d).2.2.1 ^ 2 =
    (universalParentQuad a b c d).2.2.2 ^ 2 := by
  simp only [universalParentQuad, sq_abs]
  exact ghost_quad_pythagorean a b c d hpyth

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Ghost Preserves Lorentz Form
-- ═══════════════════════════════════════════════════════════════


/-- Ghost parameters preserve the Lorentz form (with corrected p₃ = c). -/
theorem ghost_quad_preserves_lorentz (a b c d : ℤ) :
    lorentzQ₄ (quad_p₁ a b c d) (quad_p₂ a b c d) c (quad_h a b c d) =
    lorentzQ₄ a b c d := by
  simp only [lorentzQ₄, quad_p₁, quad_p₂, quad_h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Sign-Flip Group ℤ/2 × ℤ/2
-- ═══════════════════════════════════════════════════════════════


/-- All 4 sign-flip variants (±p₁, ±p₂, c, h) are Pythagorean quadruples. -/
theorem quad_sign_flips (a b c d : ℤ)
    (hpyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (s₁ s₂ : ℤ) (hs₁ : s₁ = 1 ∨ s₁ = -1) (hs₂ : s₂ = 1 ∨ s₂ = -1) :
    (s₁ * quad_p₁ a b c d) ^ 2 + (s₂ * quad_p₂ a b c d) ^ 2 + c ^ 2 =
    (quad_h a b c d) ^ 2 := by
  have h := ghost_quad_pythagorean a b c d hpyth
  rcases hs₁ with rfl | rfl <;> rcases hs₂ with rfl | rfl <;> simp <;> linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Algebraic Identities
-- ═══════════════════════════════════════════════════════════════


/-- p₁ - p₂ = b - a (same as triple case!). -/
theorem quad_p₁_minus_p₂ (a b c d : ℤ) :
    quad_p₁ a b c d - quad_p₂ a b c d = b - a := by
  simp only [quad_p₁, quad_p₂]; ring


/-- p₁ + p₂ = 3(a + b) - 4d. -/
theorem quad_p₁_plus_p₂ (a b c d : ℤ) :
    quad_p₁ a b c d + quad_p₂ a b c d = 3 * (a + b) - 4 * d := by
  simp only [quad_p₁, quad_p₂]; ring


/-- Descent gap: d - h = 2(a + b) - 2d. -/
theorem quad_descent_gap (a b c d : ℤ) :
    d - quad_h a b c d = 2 * (a + b) - 2 * d := by
  simp only [quad_h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Parity Conservation
-- ═══════════════════════════════════════════════════════════════


/-- p₁ has same parity as a. -/
theorem quad_p₁_parity (a b c d : ℤ) : quad_p₁ a b c d % 2 = a % 2 := by
  unfold quad_p₁; omega


/-- p₂ has same parity as b. -/
theorem quad_p₂_parity (a b c d : ℤ) : quad_p₂ a b c d % 2 = b % 2 := by
  unfold quad_p₂; omega


/-- h has same parity as d. -/
theorem quad_h_parity (a b c d : ℤ) : quad_h a b c d % 2 = d % 2 := by
  unfold quad_h; omega

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Projection to Triples
-- ═══════════════════════════════════════════════════════════════


/-- When c = 0, the quadruple ghost reduces to the triple ghost. -/
theorem quad_projection_pythagorean (a b d : ℤ) (hpyth : a ^ 2 + b ^ 2 = d ^ 2) :
    (quad_p₁ a b 0 d) ^ 2 + (quad_p₂ a b 0 d) ^ 2 = (quad_h a b 0 d) ^ 2 := by
  simp only [quad_p₁, quad_p₂, quad_h]; nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Concrete Examples
-- ═══════════════════════════════════════════════════════════════


/-- [Section: # Ghost Structure for Pythagorean Quadruples
## Overview
We explore whether the Ghost Triple Structure extends to **Pythagorean quadruples**
`a² + b² + c² = d²`.
## Key Discovery
The naive extension (p₁, p₂, 2c, h) does NOT form a Pythagorean quadruple.
However, the **corrected** ghost structure with p₃ = c (third coordinate preserved)
DOES work: p₁² + p₂² + c² = h² whenever a² + b² + c² = d².
This means the quadruple ghost acts on the (a,b) subspace exactly like the
triple ghost, while the third coordinate passes through unchanged.
The sign-flip group remains ℤ/2 × ℤ/2 (acting on p₁, p₂), identical to triples.
## Results
1. **Corrected Ghost Pythagorean Theorem**: p₁² + p₂² + c² = h²
2. **Universal Parent for Quadruples**: (|p₁|, |p₂|, |c|, h)
3. **Sign-flip group is ℤ/2 × ℤ/2** (same as triples)
4. **Parity conservation**: p₁ ≡ a, p₂ ≡ b, h ≡ d (mod 2)
5. **Projection theorem**: c = 0 reduces to triple ghost exactly] -/
theorem pyth_quad_1_2_2_3 : (1 : ℤ) ^ 2 + 2 ^ 2 + 2 ^ 2 = 3 ^ 2 := by norm_num

theorem pyth_quad_2_3_6_7 : (2 : ℤ) ^ 2 + 3 ^ 2 + 6 ^ 2 = 7 ^ 2 := by norm_num


/-- Ghost of (1, 2, 2, 3) = (1, 2, 2, 3) — it is a fixed point! -/
theorem upq_1_2_2_3 : universalParentQuad 1 2 2 3 = (1, 2, 2, 3) := by native_decide


/-- Ghost of (2, 3, 6, 7) = (6, 7, 6, 11). -/
theorem upq_2_3_6_7 : universalParentQuad 2 3 6 7 = (6, 7, 6, 11) := by native_decide


/-- Verify: 6² + 7² + 6² = 36 + 49 + 36 = 121 = 11². -/
theorem verify_6_7_6_11 : (6 : ℤ) ^ 2 + 7 ^ 2 + 6 ^ 2 = 11 ^ 2 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 10: 4D Matrix Form
-- ═══════════════════════════════════════════════════════════════


/-- The 4D universal parent matrix (B₂⁻¹ extended to 4D with c-identity). -/
def M₄_UP : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 2, 0, -2; 2, 1, 0, -2; 0, 0, 1, 0; -2, -2, 0, 3]


/-- M₄_UP preserves the 4D Lorentz form. -/
theorem M₄_UP_lorentz : M₄_UP.transpose * Q₄ * M₄_UP = Q₄ := by native_decide


/-- M₄_UP has determinant -1. -/
theorem M₄_UP_det : Matrix.det M₄_UP = -1 := by native_decide


/-- M₄_UP has trace 6. -/
theorem M₄_UP_trace : Matrix.trace M₄_UP = 6 := by native_decide


/-- M₄_UP² -/
theorem M₄_UP_squared :
    M₄_UP * M₄_UP = !![9, 8, 0, -12; 8, 9, 0, -12; 0, 0, 1, 0; -12, -12, 0, 17] := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Leg Swap Symmetry (Quadruples)
-- ═══════════════════════════════════════════════════════════════


/-- Swapping legs a ↔ b swaps p₁ and p₂ (same as triples). -/
theorem quad_leg_swap_p (a b c d : ℤ) :
    quad_p₁ b a c d = quad_p₂ a b c d := by
  simp only [quad_p₁, quad_p₂]; ring


/-- h is symmetric in a, b. -/
theorem quad_leg_swap_h (a b c d : ℤ) :
    quad_h b a c d = quad_h a b c d := by
  simp only [quad_h]; ring

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Research Note — When Does Descent Work?
-- ═══════════════════════════════════════════════════════════════


/-- Descent works when a + b > d. -/
theorem quad_descent_when_sum_exceeds (a b c d : ℤ)
    (hab : a + b > d) :
    quad_h a b c d < d := by
  simp only [quad_h]; linarith


/-- For the specific case (1,2,2,3): a + b = 3 = d, so h = d (no descent!). -/
theorem quad_no_descent_1_2_2_3 : quad_h 1 2 2 3 = 3 := by simp [quad_h]

#print axioms ghost_quad_pythagorean
#print axioms universalParentQuad_pythagorean
#print axioms quad_sign_flips
#print axioms M₄_UP_lorentz

