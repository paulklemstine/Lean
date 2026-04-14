/-
# Advanced SPB Theorems: New Results

## Overview
This file contains new formally verified results about the SPB framework:
1. SPB involution structure
2. SPB and arctan homomorphism
3. Cauchy distribution as SPB invariant measure
4. Weierstrass substitution via SPB
5. Denominator nonvanishing
6. SPB power iteration and tangent
7. SPB monotonicity
-/

import Mathlib

noncomputable section

open Real

/-! ## Core SPB definitions (self-contained) -/

/-- The SPB operator. -/
def spbA (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic SPB operator. -/
def spbHA (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- n-fold SPB iteration. -/
def spbPowA (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spbA x (spbPowA x n)

/-! ## Basic identities -/

theorem spbA_comm (x y : ℝ) : spbA x y = spbA y x := by
  simp [spbA, add_comm, mul_comm]

theorem spbA_zero (x : ℝ) : spbA x 0 = x := by simp [spbA]

theorem spbA_neg (x : ℝ) : spbA x (-x) = 0 := by simp [spbA]

theorem spbPowA_zero (x : ℝ) : spbPowA x 0 = 0 := rfl

theorem spbPowA_one (x : ℝ) : spbPowA x 1 = x := by simp [spbPowA, spbA]

theorem spbPowA_succ (x : ℝ) (n : ℕ) :
    spbPowA x (n + 1) = spbA x (spbPowA x n) := rfl

/-! ## SPB Involution: spb(spb(x, y), -y) = x -/

/-
SPB with y followed by SPB with -y is the identity (when denominators are nonzero).
-/
theorem spbA_cancel (x y : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - spbA x y * (-y) ≠ 0) :
    spbA (spbA x y) (-y) = x := by
  simp +decide [ *, spbA ];
  -- Combine and simplify the fractions in the numerator and denominator.
  field_simp [h1, h2]
  ring;
  linarith [ inv_mul_cancel_left₀ ( by positivity : ( 1 + y ^ 2 ) ≠ 0 ) x ]

/-! ## SPB as Möbius Transformation: Composition Law -/

/-
Composing two SPB translations is associativity of SPB.
-/
theorem spbA_compose (x a b : ℝ)
    (h1 : 1 - x * b ≠ 0) (h2 : 1 - b * a ≠ 0)
    (h3 : 1 - spbA x b * a ≠ 0) (h4 : 1 - x * spbA b a ≠ 0) :
    spbA (spbA x b) a = spbA x (spbA b a) := by
  unfold spbA at *;
  grind

/-! ## SPB Derivative -/

/-
The derivative of x ↦ spbA(x, a) is (1 + a²)/(1 - xa)².
-/
theorem spbA_hasDerivAt (x a : ℝ) (h : 1 - x * a ≠ 0) :
    HasDerivAt (fun x' => spbA x' a) ((1 + a ^ 2) / (1 - x * a) ^ 2) x := by
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ) _ using 1 <;> norm_num [ h ] ; ring

/-! ## SPB and arctan: The Group Homomorphism -/

/-- arctan is an SPB homomorphism: arctan(spb(x, y)) = arctan(x) + arctan(y)
    when xy < 1 (the principal branch condition). -/
theorem arctan_spbA (x y : ℝ) (hxy : x * y < 1) :
    arctan (spbA x y) = arctan x + arctan y := by
  rw [spbA]
  exact (Real.arctan_add hxy).symm

/-! ## Hyperbolic SPB: Self-composition -/

/-- The hyperbolic midpoint: spbHA(x, x) = 2x/(1+x²). -/
theorem spbHA_self (x : ℝ) : spbHA x x = 2 * x / (1 + x * x) := by
  unfold spbHA; ring

/-! ## SPB and the Unit Circle Parametrization -/

/-
For t = tan(θ/2), cos θ = (1 - t²)/(1 + t²). This is the
    Weierstrass substitution, which IS the real part of the Cayley transform.
-/
theorem weierstrass_cos (θ : ℝ) (h : cos (θ / 2) ≠ 0) :
    cos θ = (1 - tan (θ / 2) ^ 2) / (1 + tan (θ / 2) ^ 2) := by
  rw [ ← eq_comm, Real.tan_eq_sin_div_cos ];
  field_simp;
  rw [ Real.sin_sq, Real.cos_sq ] ; ring

/-
For t = tan(θ/2), sin θ = 2t/(1 + t²).
-/
theorem weierstrass_sin (θ : ℝ) (h : cos (θ / 2) ≠ 0) :
    sin θ = 2 * tan (θ / 2) / (1 + tan (θ / 2) ^ 2) := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.sin_two_mul, Real.tan_eq_sin_div_cos ];
  field_simp;
  norm_num

/-! ## SPB Denominator Nonvanishing for Small Arguments -/

/-
If |x| < 1 and |y| < 1, then 1 - xy > 0.
-/
theorem spbA_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    1 - x * y > 0 := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]

/-
If |x| < 1 and |y| < 1, then 1 + xy > 0.
-/
theorem spbHA_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    1 + x * y > 0 := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]

/-! ## SPB over ℤ-coefficients: Rational Closed Form -/

/-
spb of two rationals is rational (when denominator is nonzero).
-/
theorem spbA_rat (p q r s : ℤ) (hq : (q : ℝ) ≠ 0) (hs : (s : ℝ) ≠ 0)
    (hd : (q * s - p * r : ℝ) ≠ 0) :
    spbA (p / q) (r / s) = (p * s + r * q) / (q * s - p * r) := by
  unfold spbA;
  grind

/-! ## SPB Power-of-Two Doubling -/

/-- spbPowA(x, 2) = spbA(x, x). -/
theorem spbPowA_two (x : ℝ) : spbPowA x 2 = spbA x x := by
  simp [spbPowA, spbA]

/-! ## SPB Iteration Preserves Tangent -/

/-
spbPowA(tan θ, n) = tan(n * θ) when all intermediate cosines are nonzero.
-/
theorem spbPowA_tan (θ : ℝ) (n : ℕ) (hcos : ∀ k : ℕ, k ≤ n → cos (k * θ) ≠ 0) :
    spbPowA (tan θ) n = tan (n * θ) := by
  -- Let's prove the auxiliary result that spbA(tan θ, tan kθ) = tan((k+1)θ) for any k ≤ n.
  have h_aux (k : ℕ) (hk : k ≤ n) : spbA (Real.tan θ) (Real.tan (k * θ)) = Real.tan ((k + 1) * θ) := by
    simp +decide only [spbA, tan_eq_sin_div_cos];
    by_cases h : Real.cos θ = 0 <;> by_cases h' : Real.cos ( k * θ ) = 0 <;> simp_all +decide [ add_mul, Real.sin_add, Real.cos_add, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
    · specialize hcos 1 ; aesop;
    · simp_all +decide [ mul_add, Real.sin_add, Real.cos_add, mul_assoc, mul_comm, mul_left_comm ];
      grind;
  induction' n with n ih <;> simp_all +decide [ spbPowA ];
  grind +splitIndPred

/-! ## The Cauchy Distribution Connection -/

/-
The Cauchy density f(x) = 1/(π(1+x²)) satisfies the invariance equation
    for the SPB dynamical system x ↦ spbA(x, a) = (x+a)/(1-xa).
    Specifically, 1/(1 + spb(x,a)²) · (1+a²)/(1-xa)² = 1/(1+x²).
-/
theorem cauchy_spb_invariance (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + spbA x a ^ 2)⁻¹ * ((1 + a ^ 2) / (1 - x * a) ^ 2) =
    (1 + x ^ 2)⁻¹ := by
  -- Simplifying the left-hand side:
  unfold spbA;
  -- Combine and simplify the fractions in the left-hand side.
  field_simp
  ring

/-! ## SPB Monotonicity -/

/-- SPB derivative is always positive when denominator is nonzero. -/
theorem spbA_deriv_pos (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / (1 - x * a) ^ 2 > 0 := by
  apply div_pos
  · linarith [sq_nonneg a]
  · positivity

end