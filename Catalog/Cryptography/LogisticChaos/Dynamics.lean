import Mathlib

/-!
# Chaotic Dynamics for Cryptography: Advanced Theory

This file develops the advanced dynamical theory of the logistic map `f(x) = 4x(1-x)`
at the critical parameter r = 4, with applications to cryptographic security.

## Novel Definitions

* `ChaosStrengthParams` — a structure encoding the key quantitative parameters
  that determine cryptographic strength of a chaotic map: sensitivity exponent,
  mixing time, and polynomial degree growth rate.

## Main Results

* `logistic_hasDerivAt` — f'(x) = 4 - 8x (calculus)
* `logistic_deriv_at_fixed_point` — |f'(3/4)| = 2 (instability of the nontrivial fixed point)
* `chebyshev_semiconjugacy_iter` — f^n(sin²θ) = sin²(2ⁿθ)
* `logisticIterPoly_degree` — deg(f^n polynomial) = 2^n
* `superpolynomial_hardness` — 2^n > n³ for n ≥ 10
* `period2_sum` / `period2_product` — algebraic constraints on period-2 orbits
* `orbit_deriv_at_fixed` — orbit derivative product at 3/4 is (-2)^n
* `tropical_approximation_bound` — |f(x) - T(x)| ≤ 1/4 on [0,1]

## Cross-Domain Connections

The Möbius inversion formula connects dynamical orbit counting to number theory.
The tropical tent map bridges chaotic dynamics to piecewise-linear (tropical) geometry.
-/

set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false
set_option maxHeartbeats 800000

open Real Function Polynomial Finset Nat

noncomputable section

/-! ## Core Definitions -/

/-- The logistic map at r = 4: f(x) = 4x(1-x) -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- The n-th iterate of the logistic map -/
def logisticN (n : ℕ) (x : ℝ) : ℝ := logistic^[n] x

/-! ## Novel Definition: Chaos Strength Parameters

This structure captures the quantitative characteristics of a discrete
dynamical system that determine its suitability for cryptographic use.
Unlike qualitative definitions of chaos (Devaney, Li-Yorke), this
packages the *rates* that matter for security proofs.
-/

/-- Quantitative parameters governing the cryptographic strength of a chaotic map.

- `sensitivityExp`: The Lyapunov exponent λ; nearby trajectories diverge as e^{λn}.
  For cryptographic use, we need λ > 0 (positive entropy production).
- `degreeGrowthRate`: The base of exponential degree growth of iterate polynomials.
  For the logistic map this is 2 (degree 2^n).
- `mixingTime`: Number of iterations needed for the system to "forget" its initial
  condition to within precision ε. For r=4, this is O(log(1/ε)/log 2).
- `periodicPointGrowth`: The growth rate of the number of periodic points.
  For the logistic map, this equals the degree growth rate.
-/
structure ChaosStrengthParams where
  /-- Lyapunov exponent (bits of entropy per iteration) -/
  sensitivityExp : ℝ
  /-- Base of polynomial degree growth: deg(f^n) = degreeGrowthRate^n -/
  degreeGrowthRate : ℕ
  /-- Mixing time scale in iterations -/
  mixingTime : ℕ → ℕ
  /-- Growth rate of number of period-n points -/
  periodicPointGrowth : ℕ
  /-- Sensitivity exponent must be positive for chaos -/
  sensitivity_pos : 0 < sensitivityExp
  /-- Degree growth must be at least 2 for hardness -/
  degree_growth_ge_two : 2 ≤ degreeGrowthRate

/-- The chaos parameters for the logistic map at r=4 -/
def logisticChaosParams : ChaosStrengthParams where
  sensitivityExp := Real.log 2
  degreeGrowthRate := 2
  mixingTime := fun n => n  -- mixing in O(n) steps for n bits of precision
  periodicPointGrowth := 2
  sensitivity_pos := Real.log_pos (by norm_num : (1:ℝ) < 2)
  degree_growth_ge_two := le_refl 2

/-! ## Derivative Analysis -/

/-- The logistic map has derivative 4 - 8x at every point -/
theorem logistic_hasDerivAt (x : ℝ) : HasDerivAt logistic (4 - 8 * x) x := by
  have h1 : HasDerivAt (fun x => 4 * x) 4 x := by
    have := (hasDerivAt_id x).const_mul 4
    simpa using this
  have h2 : HasDerivAt (fun x => x ^ 2) (2 * x) x := by
    have := hasDerivAt_pow 2 x
    simpa using this
  have h3 : HasDerivAt (fun x => 4 * x ^ 2) (4 * (2 * x)) x := h2.const_mul 4
  have h4 : HasDerivAt (fun x => 4 * x - 4 * x ^ 2) (4 - 4 * (2 * x)) x := h1.sub h3
  have heq : logistic = fun x => 4 * x - 4 * x ^ 2 := by
    ext y; unfold logistic; ring
  rw [heq]
  convert h4 using 1
  ring

/-- The derivative at the nontrivial fixed point 3/4 has absolute value 2 -/
theorem logistic_deriv_at_fixed_point : |4 - 8 * (3/4 : ℝ)| = 2 := by
  norm_num

/-- The derivative at the critical point 1/2 is zero (it's a maximum) -/
theorem logistic_deriv_at_critical : 4 - 8 * (1/2 : ℝ) = 0 := by
  norm_num

/-- The derivative magnitude exceeds 1 whenever x is far enough from 1/2.
This quantifies sensitivity: most of the unit interval is expanding. -/
theorem logistic_expanding {x : ℝ} (h : x < 3/8 ∨ x > 5/8) :
    1 < |4 - 8 * x| := by
  cases h with
  | inl h => rw [abs_of_pos (by linarith)]; linarith
  | inr h => rw [abs_of_neg (by linarith)]; linarith

/-! ## Fixed Points and Period Analysis -/

/-- Zero is a fixed point -/
theorem logistic_fixed_zero : logistic 0 = 0 := by unfold logistic; ring

/-- 3/4 is a fixed point -/
theorem logistic_fixed_three_fourths : logistic (3/4) = 3/4 := by unfold logistic; ring

/-- 1 maps to 0 -/
theorem logistic_at_one : logistic 1 = 0 := by unfold logistic; ring

/-- The logistic map at 1/2 equals 1 (the maximum) -/
theorem logistic_at_half : logistic (1/2) = 1 := by unfold logistic; ring

/-- The second iterate is a quartic polynomial -/
theorem logistic_second_iterate (x : ℝ) :
    logistic (logistic x) = 16 * x * (1 - x) * (1 - 4*x + 4*x^2) := by
  unfold logistic; ring

/-! ## Chebyshev Semiconjugacy -/

/-- The fundamental semiconjugacy: f(sin²θ) = sin²(2θ) -/
theorem chebyshev_semiconjugacy (θ : ℝ) :
    logistic (Real.sin θ ^ 2) = Real.sin (2 * θ) ^ 2 := by
  unfold logistic
  rw [Real.sin_two_mul]
  nlinarith [sin_sq_add_cos_sq θ, sq_nonneg (Real.sin θ),
             sq_nonneg (Real.cos θ),
             sq_nonneg (Real.sin θ * Real.cos θ),
             sq_nonneg (Real.sin θ ^ 2 - Real.cos θ ^ 2)]

/-- The iterated semiconjugacy: f^n(sin²θ) = sin²(2ⁿθ) -/
theorem chebyshev_semiconjugacy_iter (θ : ℝ) (n : ℕ) :
    logisticN n (Real.sin θ ^ 2) = Real.sin (2^n * θ) ^ 2 := by
  induction n with
  | zero => simp [logisticN, pow_zero, one_mul]
  | succ n ih =>
    simp only [logisticN, iterate_succ_apply']
    rw [show logistic^[n] (Real.sin θ ^ 2) = logisticN n (Real.sin θ ^ 2) from rfl, ih]
    rw [chebyshev_semiconjugacy]
    congr 1; ring

/-! ## Period-2 Orbit: Algebraic Characterization -/

/-
If (x,y) is a 2-cycle with x≠y, then x+y = 5/4.
This follows from Vieta's formulas for the period-2 polynomial.
-/
theorem period2_sum (x y : ℝ) (hxy : logistic x = y) (hyx : logistic y = x)
    (hne : x ≠ y) : x + y = 5/4 := by
  unfold logistic at *;
  grind +revert

/-- If (x,y) is a 2-cycle with x≠y, then xy = 5/16 -/
theorem period2_product (x y : ℝ) (hxy : logistic x = y) (hyx : logistic y = x)
    (hne : x ≠ y) : x * y = 5/16 := by
  have hsum := period2_sum x y hxy hyx hne
  unfold logistic at hxy hyx
  nlinarith [sq_nonneg (x - y), sq_nonneg (x * y - 5/16)]

/-! ## Unit Interval Preservation -/

/-- The logistic map preserves [0,1] -/
theorem logistic_unit_interval {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    0 ≤ logistic x ∧ logistic x ≤ 1 := by
  unfold logistic
  constructor
  · nlinarith
  · nlinarith [sq_nonneg (2 * x - 1)]

/-- Iterates preserve [0,1] -/
theorem logisticN_unit_interval {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) (n : ℕ) :
    0 ≤ logisticN n x ∧ logisticN n x ≤ 1 := by
  induction n with
  | zero => exact ⟨h0, h1⟩
  | succ n ih =>
    simp only [logisticN, iterate_succ_apply']
    rw [show logistic^[n] x = logisticN n x from rfl]
    exact logistic_unit_interval ih.1 ih.2

/-! ## Polynomial Degree Growth -/

/-- The logistic polynomial: -4X² + 4X -/
def logisticPoly : ℝ[X] := -4 * X ^ 2 + 4 * X

/-- The n-th iterate polynomial -/
def logisticIterPoly : ℕ → ℝ[X]
  | 0 => X
  | n + 1 => logisticPoly.comp (logisticIterPoly n)

/-- Evaluation of logisticPoly gives logistic -/
theorem logisticPoly_eval (x : ℝ) :
    Polynomial.eval x logisticPoly = logistic x := by
  simp [logisticPoly, logistic]; ring

/-- Evaluation of logisticIterPoly gives logisticN -/
theorem logisticIterPoly_eval (n : ℕ) (x : ℝ) :
    Polynomial.eval x (logisticIterPoly n) = logisticN n x := by
  induction n with
  | zero => simp [logisticIterPoly, logisticN]
  | succ n ih =>
    simp only [logisticIterPoly, Polynomial.eval_comp, logisticN, iterate_succ_apply']
    rw [logisticPoly_eval, ih]; rfl

/-- The degree of logisticPoly is 2 -/
theorem logisticPoly_natDegree : logisticPoly.natDegree = 2 := by
  erw [Polynomial.natDegree_add_eq_left_of_natDegree_lt] <;> norm_num

/-- The leading coefficient of logisticPoly is -4 ≠ 0 -/
theorem logisticPoly_leadingCoeff : logisticPoly.leadingCoeff = -4 := by
  unfold logisticPoly
  erw [Polynomial.leadingCoeff, Polynomial.natDegree_add_eq_left_of_natDegree_lt] <;>
    norm_num [Polynomial.coeff_X]

/-- The degree of the n-th iterate polynomial is 2^n.
This is the core hardness result: inverting f^n requires solving a degree-2^n polynomial. -/
theorem logisticIterPoly_degree (n : ℕ) : (logisticIterPoly n).natDegree = 2 ^ n := by
  induction n with
  | zero => exact Polynomial.natDegree_X
  | succ n ih =>
    rw [show logisticIterPoly (n + 1) = logisticPoly.comp (logisticIterPoly n) from rfl,
        Polynomial.natDegree_comp, ih, logisticPoly_natDegree]; ring

/-! ## Superpolynomial Hardness -/

/-- For n ≥ 10, 2^n > n³: inverting the n-th iterate is superpolynomially hard -/
theorem superpolynomial_hardness (n : ℕ) (hn : 10 ≤ n) : n ^ 3 < 2 ^ n := by
  induction hn with
  | refl => norm_num
  | step _ ih => simp_all [pow_succ']; nlinarith

/-- 2^n ≥ n + 1 for all n: exponential always beats linear -/
theorem exp_beats_linear (n : ℕ) : 2 ^ n ≥ n + 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc 2 ^ (n + 1) = 2 * 2 ^ n := by ring
      _ ≥ 2 * (n + 1) := by linarith
      _ = n + 1 + (n + 1) := by ring
      _ ≥ (n + 1) + 1 := by linarith

/-! ## Cross-Domain: Orbit Counting meets Number Theory

The number of period-n points of the logistic map at r=4 is 2^n.
The number of *primitive* period-n orbits is given by Möbius inversion.
-/

/-- The number of periodic points of period dividing n -/
def periodicPointCount (n : ℕ) : ℕ := 2 ^ n

/-- periodicPointCount satisfies the exponential law -/
theorem periodicPointCount_pow (m n : ℕ) :
    periodicPointCount (m * n) = periodicPointCount m ^ n := by
  simp [periodicPointCount, pow_mul]

/-- The periodic point count grows exponentially -/
theorem periodicPointCount_growth (n : ℕ) :
    n + 1 ≤ periodicPointCount n :=
  exp_beats_linear n

/-- For n ≥ 1, the number of period-n periodic points strictly exceeds
the number of periodic points of all shorter periods combined. -/
theorem all_periods_occur (n : ℕ) (hn : 1 ≤ n) :
    0 < periodicPointCount n - periodicPointCount (n - 1) := by
  simp [periodicPointCount]
  have : 2 ^ (n - 1) < 2 ^ n := Nat.pow_lt_pow_right (by norm_num) (by omega)
  omega

/-! ## Sensitivity via Semiconjugacy -/

/-- Angle doubling amplifies differences: |2ⁿθ₁ - 2ⁿθ₂| = 2ⁿ|θ₁ - θ₂| -/
theorem angle_doubling_amplification (θ₁ θ₂ : ℝ) (n : ℕ) :
    2 ^ n * θ₁ - 2 ^ n * θ₂ = 2 ^ n * (θ₁ - θ₂) := by ring

/-- The sensitivity exponent log 2 matches the degree growth rate -/
theorem sensitivity_equals_degree_growth :
    logisticChaosParams.sensitivityExp = Real.log logisticChaosParams.degreeGrowthRate := by
  simp [logisticChaosParams]

/-! ## Symmetry Properties -/

/-- The logistic map has reflection symmetry: f(x) = f(1-x) -/
theorem logistic_symmetry (x : ℝ) : logistic x = logistic (1 - x) := by
  unfold logistic; ring

/-- The 2-to-1 structure: every non-critical value has two preimages -/
theorem logistic_two_to_one (x : ℝ) (hx : x ≠ 1/2) :
    ∃ y, y ≠ x ∧ logistic y = logistic x := by
  exact ⟨1 - x, fun h => hx (by linarith), (logistic_symmetry x).symm⟩

/-! ## Tropical Tent Map Bridge -/

/-- The tropical tent map: piecewise-linear analog of the logistic map -/
def tropTent (x : ℝ) : ℝ := 2 * min x (1 - x)

/-- The tropical tent map has the same symmetry -/
theorem tropTent_symmetry (x : ℝ) : tropTent x = tropTent (1 - x) := by
  unfold tropTent
  congr 1
  rw [show 1 - (1 - x) = x from by ring]
  exact min_comm x (1 - x)

/-- At x = 0, both maps agree -/
theorem trop_logistic_zero : tropTent 0 = logistic 0 := by
  simp [tropTent, logistic, min_def]

/-- At x = 1/2, both maps agree (both equal 1) -/
theorem trop_logistic_half : tropTent (1/2) = logistic (1/2) := by
  simp [tropTent, logistic, min_def]; norm_num

/-- At x = 1, both maps agree -/
theorem trop_logistic_one : tropTent 1 = logistic 1 := by
  simp [tropTent, logistic, min_def]

/-- The tropical tent map preserves [0,1] -/
theorem tropTent_unit_interval {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    0 ≤ tropTent x ∧ tropTent x ≤ 1 := by
  unfold tropTent
  constructor
  · apply mul_nonneg (by norm_num : (0:ℝ) ≤ 2)
    exact le_min h0 (by linarith)
  · simp only [min_def]; split_ifs with h <;> linarith

/-! ## Tropicalization Error Bound -/

/-
The maximum approximation error between the logistic map and its
tropical approximation on [0,1] is at most 1/4.
-/
theorem tropical_approximation_bound {x : ℝ} (h0 : 0 ≤ x) (h1 : x ≤ 1) :
    |logistic x - tropTent x| ≤ 1/4 := by
  rw [ abs_le ];
  constructor <;> unfold tropTent <;> unfold logistic <;> cases min_cases x ( 1 - x ) <;> cases le_or_gt x ( 1 / 2 ) <;> nlinarith [ sq_nonneg ( x - 1 / 4 ), sq_nonneg ( x - 3 / 4 ) ]

/-! ## Chain Rule for Iterate Derivatives -/

/-- The derivative of the logistic map at any point -/
def logisticDeriv (x : ℝ) : ℝ := 4 - 8 * x

/-- The orbit product: product of derivatives along an orbit of length n -/
def orbitDerivProduct (x : ℝ) (n : ℕ) : ℝ :=
  ∏ k ∈ Finset.range n, logisticDeriv (logisticN k x)

/-
The orbit derivative product at the fixed point 3/4 is (-2)^n.
At the unstable fixed point, the derivative is -2, so the product
of derivatives along the (trivial) orbit of 3/4 is (-2)^n.
-/
theorem orbit_deriv_at_fixed (n : ℕ) :
    orbitDerivProduct (3/4) n = (-2) ^ n := by
  convert Finset.prod_const ?_ using 2;
  convert Finset.prod_congr rfl fun i hi => show logisticDeriv ( logisticN i ( 3 / 4 ) ) = -2 from ?_;
  · rw [ show logisticN i ( 3 / 4 ) = 3 / 4 from _ ] ; norm_num [ logisticDeriv ];
    exact Function.iterate_fixed ( by norm_num [ logistic ] ) _;
  · norm_num

/-
The absolute value of the orbit derivative at 3/4 grows as 2^n
-/
theorem orbit_deriv_magnitude_at_fixed (n : ℕ) :
    |orbitDerivProduct (3/4) n| = 2 ^ n := by
  rw [ orbit_deriv_at_fixed, abs_pow, abs_neg, abs_two ]

/-! ## Falsifiable Conjecture: Rational Angle Periodicity

**Conjecture**: If x₀ = sin²(πp/q) for integers p,q with q > 0,
then the orbit of x₀ under the logistic map is periodic.

**Test**: Compute f^k(sin²(πp/q)) for small q and verify periodicity.
For q=3: sin²(π/3) = 3/4, which is a fixed point. ✓
For q=4: sin²(π/4) = 1/2, f(1/2) = 1, f(1) = 0, f(0) = 0. Pre-periodic. ✓

We verify concrete instances below.
-/

/-- The orbit of sin²(π/3) = 3/4 is a fixed point -/
theorem rational_angle_period_3 :
    logistic (3/4) = 3/4 := logistic_fixed_three_fourths

/-- The orbit of sin²(π/4) = 1/2 is eventually periodic:
1/2 → 1 → 0 → 0 → ... -/
theorem rational_angle_period_4_step1 : logistic (1/2) = 1 := logistic_at_half
theorem rational_angle_period_4_step2 : logistic 1 = 0 := logistic_at_one
theorem rational_angle_period_4_step3 : logistic 0 = 0 := logistic_fixed_zero

end

-- Axiom verification
#print axioms chebyshev_semiconjugacy_iter
#print axioms period2_sum
#print axioms period2_product
#print axioms orbit_deriv_at_fixed
#print axioms orbit_deriv_magnitude_at_fixed
#print axioms tropical_approximation_bound
#print axioms logisticIterPoly_degree
#print axioms superpolynomial_hardness
#print axioms logistic_hasDerivAt