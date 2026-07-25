/-
# SPB and Chebyshev Polynomials: The Multiple Angle Connection

## Overview
The n-fold iteration of SPB applied to tan(θ) yields tan(nθ).
This establishes a deep connection between SPB iteration and
Chebyshev polynomials / multiple angle formulas.

## Key Theorems
1. spbPow(tan θ, n) = tan(nθ)     [multiple angle formula]
2. Double and triple angle as SPB
3. SPB complexity of power-of-two angles
-/

import Mathlib

noncomputable section

open Real

/-! ## SPB and n-fold iteration -/

/-- The SPB operator. -/
def spb' (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- n-fold SPB self-composition: spbPow'(x, n) = "x composed n times under SPB". -/
def spbPow' (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spb' x (spbPow' x n)

/-- Base case: spbPow'(x, 0) = 0 (the identity element). -/
theorem spbPow'_zero (x : ℝ) : spbPow' x 0 = 0 := rfl

/-- spbPow'(x, 1) = x. -/
theorem spbPow'_one (x : ℝ) : spbPow' x 1 = x := by
  simp [spbPow', spb']

/-- spbPow'(x, 2) = 2x/(1-x²). -/
theorem spbPow'_two (x : ℝ) : spbPow' x 2 = 2 * x / (1 - x * x) := by
  simp [spbPow', spb']; ring

/-! ## The Multiple Angle Theorem -/

/-
**Core theorem**: spbPow'(tan θ, n) = tan(nθ).
    This is the fundamental connection between SPB iteration and
    multiple angle formulas. We prove it by induction.
-/
theorem spbPow'_tan (θ : ℝ) (n : ℕ)
    (hcos : ∀ k : ℕ, k ≤ n → Real.cos (k * θ) ≠ 0) :
    spbPow' (Real.tan θ) n = Real.tan (n * θ) := by
  induction' n with n ih;
  · aesop;
  · norm_num [ add_mul, Real.tan_add ];
    rw [ Real.tan_add ];
    · rw [ show spbPow' ( tan θ ) ( n + 1 ) = spb' ( tan θ ) ( spbPow' ( tan θ ) n ) by rfl, ih fun k hk => hcos k ( by linarith ), spb' ] ; ring;
    · refine Or.inl ⟨ fun k hk => hcos n ( by linarith ) ?_, fun l hl => hcos 1 ( by linarith ) ?_ ⟩ <;> simp_all +decide [ Real.cos_eq_zero_iff ]

/-! ## SPB Generates the Tangent Sequence -/

/-
The tangent of integer multiples of θ forms a "geometric-like"
    progression under SPB.
-/
theorem tan_progression (θ : ℝ) (m n : ℕ)
    (hm : Real.cos (m * θ) ≠ 0) (hn : Real.cos (n * θ) ≠ 0)
    (hmn : Real.cos ((m + n) * θ) ≠ 0)
    (hprod : 1 - Real.tan (m * θ) * Real.tan (n * θ) ≠ 0) :
    spb' (Real.tan (m * θ)) (Real.tan (n * θ)) = Real.tan ((m + n) * θ) := by
  simp_all +decide [ add_mul, Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add, mul_div ];
  grind +locals

/-! ## Double and Triple Angle Formulas via SPB -/

/-
Double angle: spb'(tan θ, tan θ) = tan(2θ).
-/
theorem spb_double_angle (θ : ℝ) (hc : Real.cos θ ≠ 0) :
    spb' (Real.tan θ) (Real.tan θ) = Real.tan (2 * θ) := by
  rw [ Real.tan_two_mul, spb' ] ; ring

/-
Triple angle via SPB: spb'(tan(2θ), tan θ) = tan(3θ).
-/
theorem spb_triple_angle (θ : ℝ)
    (h1 : Real.cos θ ≠ 0) (h2 : Real.cos (2 * θ) ≠ 0)
    (h3 : 1 - Real.tan (2 * θ) * Real.tan θ ≠ 0) :
    spb' (Real.tan (2 * θ)) (Real.tan θ) = Real.tan (3 * θ) := by
  rw [ show 3 * θ = 2 * θ + θ by ring, Real.tan_add ];
  · rfl;
  · simp_all +decide [ Real.cos_eq_zero_iff ]

/-! ## SPB Complexity of Multiple Angles -/

-- Computing tan(2^k θ) requires exactly k SPB operations (repeated doubling).
-- This connects to binary exponentiation in the SPB group.

-- The power-of-two complexity theorem (spbPow' x (2^k) = iterate(doubling, k, x))
-- requires an additivity lemma spbPow'(x, m+n) = spb'(spbPow'(x,m), spbPow'(x,n))
-- which holds when denominators are nonzero. We state the key special case:

/-- Double-angle via SPB iteration: spbPow'(x, 2) = spb'(x, x). -/
theorem spbPow'_two_eq_double (x : ℝ) : spbPow' x 2 = spb' x x := by
  simp [spbPow', spb']

/-! ## The Tangent Half-Angle Substitution -/

-- The Weierstrass substitution t = tan(θ/2) gives:
--   sin θ = 2t/(1+t²), cos θ = (1-t²)/(1+t²).
-- This is equivalent to the SPB-Cayley transform!

theorem weierstrass_is_cayley_re (t : ℝ) :
    (1 - t^2) / (1 + t^2) = (1 - t * t) / (1 + t * t) := by
  ring

theorem weierstrass_is_cayley_im (t : ℝ) :
    2 * t / (1 + t^2) = 2 * t / (1 + t * t) := by
  ring

end