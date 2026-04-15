/-! # CatalogBuild.EML.AdvancedTheorems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 13
-/

import Mathlib

noncomputable section

def spbHA (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- n-fold SPB iteration. -/

def spbPowA (x : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => spbA x (spbPowA x n)

/-! ## Basic identities -/


theorem spbPowA_zero (x : ℝ) : spbPowA x 0 = 0 := rfl


theorem spbPowA_one (x : ℝ) : spbPowA x 1 = x := by simp [spbPowA, spbA]


theorem spbPowA_succ (x : ℝ) (n : ℕ) :
    spbPowA x (n + 1) = spbA x (spbPowA x n) := rfl

/-! ## SPB Involution: spb(spb(x, y), -y) = x -/

/-
SPB with y followed by SPB with -y is the identity (when denominators are nonzero).
-/

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

theorem spbHA_denom_pos (x y : ℝ) (hx : |x| < 1) (hy : |y| < 1) :
    1 + x * y > 0 := by
  nlinarith [ abs_lt.mp hx, abs_lt.mp hy ]

/-! ## SPB over ℤ-coefficients: Rational Closed Form -/

/-
spb of two rationals is rational (when denominator is nonzero).
-/

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

end
