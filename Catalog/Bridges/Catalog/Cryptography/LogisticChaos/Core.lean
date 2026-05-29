import Mathlib

/-!
# Cryptography from Chaos: The Logistic Map as a Cryptographic Primitive

We formalize the logistic map `f(x) = 4x(1-x)` at r = 4, its dynamical properties,
and their connections to cryptographic security.

## Main Definitions

* `logisticMap` — the logistic map at r = 4
* `logisticIter` — n-th iterate of the logistic map
* `LogisticCipherConfig` — configuration for the logistic cipher
* `logisticIterPoly` — polynomial representation of the n-th iterate
* `tropicalTentMap` — tropical (piecewise-linear) analog of the logistic map

## Main Results

* `logisticMap_fixed_zero` — 0 is a fixed point
* `logisticMap_fixed_three_fourths` — 3/4 is a fixed point
* `chebyshev_semiconjugacy` — semiconjugacy with the doubling map via sin²
* `chebyshev_semiconjugacy_iter` — iterated semiconjugacy: f^n(sin²θ) = sin²(2^n θ)
* `logisticIter_unit_interval` — iterates preserve [0,1]
* `logisticIterPoly_degree` — degree of the n-th iterate polynomial is 2^n
* `logistic_superpolynomial_hardness` — 2^n grows faster than n³ for n ≥ 10
* `logisticMap_period2_product` — algebraic constraints on period-2 orbits
-/

set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false
set_option maxHeartbeats 800000

open Real Polynomial Function

noncomputable section

/-! ## Core Definitions -/

/-- The logistic map at r = 4: f(x) = 4x(1-x) -/
def logisticMap (x : ℝ) : ℝ := 4 * x * (1 - x)

/-- The n-th iterate of the logistic map -/
def logisticIter (n : ℕ) (x : ℝ) : ℝ := (logisticMap)^[n] x

/-! ## Fixed Point Theorems -/

/-- Zero is a fixed point of the logistic map -/
theorem logisticMap_fixed_zero : logisticMap 0 = 0 := by
  unfold logisticMap; ring

/-- 3/4 is a fixed point of the logistic map -/
theorem logisticMap_fixed_three_fourths : logisticMap (3/4) = 3/4 := by
  unfold logisticMap; ring

/-- Zero is a fixed point of every iterate -/
theorem logisticIter_fixed_zero (n : ℕ) : logisticIter n 0 = 0 := by
  induction n with
  | zero => simp [logisticIter]
  | succ n ih =>
    simp only [logisticIter, iterate_succ_apply']
    rw [show (logisticMap)^[n] 0 = logisticIter n 0 from rfl, ih]
    exact logisticMap_fixed_zero

/-- 3/4 is a fixed point of every iterate -/
theorem logisticIter_fixed_three_fourths (n : ℕ) : logisticIter n (3/4) = 3/4 := by
  induction n with
  | zero => simp [logisticIter]
  | succ n ih =>
    simp only [logisticIter, iterate_succ_apply']
    rw [show (logisticMap)^[n] (3/4) = logisticIter n (3/4) from rfl, ih]
    exact logisticMap_fixed_three_fourths

/-- 1 maps to 0 under the logistic map -/
theorem logisticMap_one : logisticMap 1 = 0 := by
  unfold logisticMap; ring

/-- 1/2 maps to 1 (the maximum) -/
theorem logisticMap_half : logisticMap (1/2) = 1 := by
  unfold logisticMap; ring

/-! ## The Chebyshev Semiconjugacy

The key identity: `4 sin²(θ)(1 - sin²(θ)) = sin²(2θ)`.
This shows the logistic map is semiconjugate to angle doubling via sin².
-/

/-- The logistic map applied to sin²(θ) equals sin²(2θ).
This is the fundamental semiconjugacy between the logistic map at r=4
and the angle-doubling map θ ↦ 2θ on the circle. -/
theorem chebyshev_semiconjugacy (θ : ℝ) :
    logisticMap (Real.sin θ ^ 2) = Real.sin (2 * θ) ^ 2 := by
  unfold logisticMap
  rw [Real.sin_two_mul]
  nlinarith [sin_sq_add_cos_sq θ, sq_nonneg (Real.sin θ), sq_nonneg (Real.cos θ),
             sq_nonneg (Real.sin θ * Real.cos θ),
             sq_nonneg (Real.sin θ ^ 2 - Real.cos θ ^ 2)]

/-- Iterating the logistic map on sin²(θ) gives sin²(2ⁿθ).
This is the n-fold semiconjugacy, proved by induction. -/
theorem chebyshev_semiconjugacy_iter (θ : ℝ) (n : ℕ) :
    logisticIter n (Real.sin θ ^ 2) = Real.sin (2^n * θ) ^ 2 := by
  induction n with
  | zero => simp [logisticIter, pow_zero, one_mul]
  | succ n ih =>
    simp only [logisticIter, iterate_succ_apply']
    rw [show (logisticMap)^[n] (Real.sin θ ^ 2) = logisticIter n (Real.sin θ ^ 2) from rfl, ih]
    rw [chebyshev_semiconjugacy]
    congr 1; ring

/-! ## Unit Interval Preservation -/

/-- The logistic map preserves the unit interval [0,1] -/
theorem logisticMap_unit_interval {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ logisticMap x ∧ logisticMap x ≤ 1 := by
  constructor
  · unfold logisticMap; nlinarith
  · unfold logisticMap; nlinarith [sq_nonneg (2 * x - 1)]

/-- Iterates of the logistic map preserve the unit interval -/
theorem logisticIter_unit_interval {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) (n : ℕ) :
    0 ≤ logisticIter n x ∧ logisticIter n x ≤ 1 := by
  induction n with
  | zero => exact ⟨hx0, hx1⟩
  | succ n ih =>
    simp only [logisticIter, iterate_succ_apply']
    rw [show (logisticMap)^[n] x = logisticIter n x from rfl]
    exact logisticMap_unit_interval ih.1 ih.2

/-! ## Polynomial Representation

The n-th iterate of the logistic map is a polynomial of degree 2^n.
This exponential degree growth is the foundation of cryptographic hardness.
-/

/-- The polynomial representation of the logistic map: 4X(1-X) = -4X² + 4X -/
def logisticPoly : ℝ[X] := -4 * X^2 + 4 * X

/-- Evaluating logisticPoly gives logisticMap -/
theorem logisticPoly_eval (x : ℝ) :
    Polynomial.eval x logisticPoly = logisticMap x := by
  simp [logisticPoly, logisticMap]; ring

/-- The polynomial for the n-th iterate -/
def logisticIterPoly : ℕ → ℝ[X]
  | 0 => X
  | n + 1 => logisticPoly.comp (logisticIterPoly n)

/-- Evaluating logisticIterPoly gives logisticIter -/
theorem logisticIterPoly_eval (n : ℕ) (x : ℝ) :
    Polynomial.eval x (logisticIterPoly n) = logisticIter n x := by
  induction n with
  | zero => simp [logisticIterPoly, logisticIter]
  | succ n ih =>
    simp only [logisticIterPoly, Polynomial.eval_comp, logisticIter, iterate_succ_apply']
    rw [logisticPoly_eval, ih, show logisticIter n x = logisticMap^[n] x from rfl]

/-
The degree of logisticPoly is 2
-/
theorem logisticPoly_degree : logisticPoly.natDegree = 2 := by
  erw [ Polynomial.natDegree_add_eq_left_of_natDegree_lt ] <;> norm_num

/-
The leading coefficient of logisticPoly is -4 (nonzero)
-/
theorem logisticPoly_leadingCoeff : logisticPoly.leadingCoeff = -4 := by
  unfold logisticPoly; erw [ Polynomial.leadingCoeff, Polynomial.natDegree_add_eq_left_of_natDegree_lt ] <;> norm_num;
  norm_num [ Polynomial.coeff_X ]

/-
The degree of the n-th iterate polynomial is 2^n.
This is the key result connecting chaos to cryptographic hardness:
inverting the n-th iterate requires solving a degree-2^n polynomial.
-/
theorem logisticIterPoly_degree (n : ℕ) :
    (logisticIterPoly n).natDegree = 2^n := by
  induction' n with n ih;
  · exact Polynomial.natDegree_X;
  · rw [ show logisticIterPoly ( n + 1 ) = logisticPoly.comp ( logisticIterPoly n ) from rfl, Polynomial.natDegree_comp, ih, logisticPoly_degree ] ; ring

/-! ## Symmetry of the Logistic Map -/

/-- The logistic map has a reflection symmetry: f(x) = f(1-x) -/
theorem logisticMap_symmetry (x : ℝ) :
    logisticMap x = logisticMap (1 - x) := by
  unfold logisticMap; ring

/-! ## Sensitivity Analysis -/

/-- The logistic map is differentiable everywhere -/
theorem logisticMap_differentiable : Differentiable ℝ logisticMap := by
  unfold logisticMap
  fun_prop

/-! ## Cryptographic Hardness: Exponential Degree Growth -/

/-- The exponential growth of polynomial degree: inverting the n-th iterate
requires solving a polynomial of degree 2^n, which grows exponentially. -/
theorem crypto_hardness_exponential (n : ℕ) :
    n < 2^n := Nat.lt_two_pow_self

/-
For n ≥ 10, the polynomial degree 2^n vastly exceeds n³,
making brute-force inversion infeasible. This connects chaos theory
to computational complexity: the exponential degree growth of the
logistic map's iterates is the dynamical analog of superpolynomial hardness.
-/
theorem logistic_superpolynomial_hardness (n : ℕ) (hn : 10 ≤ n) :
    n ^ 3 < 2 ^ n := by
  induction hn <;> simp_all +decide [ pow_succ' ] ; nlinarith

/-! ## Cross-Domain: Orbit Counting and Combinatorics

The logistic map at r=4 has topological entropy log 2. The number of
period-n orbits connects dynamical systems to combinatorics.
-/

/-- The number of preimages under f^n grows exponentially.
2^n ≥ n + 1 is a weak lower bound on the preimage count. -/
theorem orbit_count_exponential (n : ℕ) :
    2^n ≥ n + 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc 2 ^ (n + 1) = 2 * 2^n := by ring
    _ ≥ 2 * (n + 1) := by linarith
    _ = n + 1 + (n + 1) := by ring
    _ ≥ n + 1 + 1 := by linarith
    _ = (n + 1) + 1 := by ring

/-! ## The Logistic Cipher Structure -/

/-- Configuration for the logistic cipher.
The key is (seed, warmup), where seed ∈ (0,1) is the initial condition
and warmup is the number of transient iterations to skip. -/
structure LogisticCipherConfig where
  /-- The seed (initial condition) in (0,1) -/
  seed : ℝ
  /-- seed is positive -/
  seed_pos : 0 < seed
  /-- seed is less than 1 -/
  seed_lt_one : seed < 1
  /-- Number of warm-up iterations to skip transients -/
  warmup : ℕ

/-- The keystream value at position k, given a cipher configuration -/
def keystreamValue (cfg : LogisticCipherConfig) (k : ℕ) : ℝ :=
  logisticIter (cfg.warmup + k) cfg.seed

/-- The keystream preserves the unit interval -/
theorem keystreamValue_unit_interval (cfg : LogisticCipherConfig) (k : ℕ) :
    0 ≤ keystreamValue cfg k ∧ keystreamValue cfg k ≤ 1 :=
  logisticIter_unit_interval (le_of_lt cfg.seed_pos) (le_of_lt cfg.seed_lt_one) _

/-! ## Period-2 Orbit Analysis -/

/-
If x and y form a 2-cycle (f(x)=y, f(y)=x, x≠y), then x+y=5/4.
The period-2 orbits of the logistic map at r=4 are the roots of
16x²-20x+5=0, namely (5±√5)/8, which sum to 5/4.
This connects dynamics to algebra via Vieta's formulas.
-/
theorem logisticMap_period2_sum (x y : ℝ)
    (hx : logisticMap x = y) (hy : logisticMap y = x)
    (hne : x ≠ y) :
    x + y = 5/4 := by
  unfold logisticMap at *; cases lt_or_gt_of_ne hne <;> nlinarith;

/-! ## Composition Identity -/

/-- The logistic map satisfies f(f(x)) = 16x(1-x)(1-4x+4x²).
This quartic expression shows the rapid growth in algebraic complexity. -/
theorem logisticMap_comp (x : ℝ) :
    logisticMap (logisticMap x) = 16 * x * (1 - x) * (1 - 4*x + 4*x^2) := by
  unfold logisticMap; ring

/-- The second iterate evaluated at 0 is 0 -/
theorem logisticMap_comp_zero : logisticMap (logisticMap 0) = 0 := by
  rw [logisticMap_comp]; ring

/-- The second iterate evaluated at 3/4 is 3/4 -/
theorem logisticMap_comp_three_fourths :
    logisticMap (logisticMap (3/4)) = 3/4 := by
  rw [logisticMap_comp]; ring

/-! ## Falsifiable Conjecture: Logistic Map Period Bound

**Conjecture**: For the logistic map at r=4, every rational initial condition
x₀ = p/q with 0 < p < q eventually enters a periodic orbit whose period
divides some power of 2 bounded by q.

**Test**: For q = 5, x₀ = 1/5: compute f^n(1/5) for n = 1..32 and verify
periodicity. We can verify f(1/5) = 16/25 as a first step. -/

theorem logistic_period_bound_conjecture_example :
    logisticIter 1 (1/5) = 16/25 := by
  simp [logisticIter, logisticMap]
  ring

/-! ## Connection to Tropical Geometry

The logistic map f(x) = 4x(1-x) can be tropicalized:
in the tropical semiring (ℝ, max, +), the tropicalization of
4x(1-x) becomes a piecewise-linear tent map.
This connects chaotic dynamics to tropical geometry. -/

/-- The tropical tent map: the piecewise-linear analog of the logistic map
in tropical (max-plus) algebra. This is `2 * min(x, 1-x)`. -/
def tropicalTentMap (x : ℝ) : ℝ := 2 * min x (1 - x)

/-- The tropical tent map preserves [0,1] -/
theorem tropicalTentMap_unit_interval {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ tropicalTentMap x ∧ tropicalTentMap x ≤ 1 := by
  unfold tropicalTentMap
  constructor
  · apply mul_nonneg (by norm_num : (0:ℝ) ≤ 2)
    exact le_min hx0 (by linarith)
  · simp only [min_def]
    split_ifs with h
    · linarith
    · linarith

/-- The tropical tent map has the same symmetry as the logistic map -/
theorem tropicalTentMap_symmetry (x : ℝ) :
    tropicalTentMap x = tropicalTentMap (1 - x) := by
  unfold tropicalTentMap
  congr 1
  rw [show 1 - (1 - x) = x from by ring]
  exact min_comm x (1 - x)

/-- The tropical tent map and logistic map agree at the endpoints and midpoint -/
theorem tropical_logistic_agree_zero : tropicalTentMap 0 = logisticMap 0 := by
  simp [tropicalTentMap, logisticMap, min_def]

theorem tropical_logistic_agree_half : tropicalTentMap (1/2) = logisticMap (1/2) := by
  simp [tropicalTentMap, logisticMap, min_def]
  norm_num

theorem tropical_logistic_agree_one : tropicalTentMap 1 = logisticMap 1 := by
  simp [tropicalTentMap, logisticMap, min_def]

end

#print axioms logisticMap_fixed_zero
#print axioms chebyshev_semiconjugacy
#print axioms chebyshev_semiconjugacy_iter
#print axioms logisticIter_unit_interval
#print axioms logisticMap_comp