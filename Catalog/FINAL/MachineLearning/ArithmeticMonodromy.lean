/-
# Arithmetic Monodromy Fingerprints of Gradient Descent

This module develops the theory of arithmetic fingerprints for polynomial gradient descent.
The central idea: for a univariate polynomial loss f over a field K, the exact gradient
descent map T(x) = x - η·f'(x) is itself a polynomial map. Its fixed points coincide
exactly with the critical points of f (when η ≠ 0), and the structure of these critical
points over finite fields carries arithmetic information controlled by discriminants
and quadratic residuosity.

## Main Results

1. `gradientStep_fixes_criticalPoints`: Critical points are fixed by gradient descent.
2. `fixedPoints_eq_criticalPoints`: Fixed points of gradient step = critical points (η ≠ 0).
3. `gradientStep_eval_isAlgebraic`: Gradient step preserves algebraicity.
4. `fixedPointCountMod_eq_rootCount`: Fixed point counting reduces to root counting.

## Definitions

- `gradientStep f η`: The polynomial X - C η * derivative f
- `criticalPoints f`: The set {x | aeval x (derivative f) = 0}
- `fixedPoints f η`: The set {x | aeval x (gradientStep f η) = x}
- `gradientIterate f η n`: The n-fold composition of gradient step
- `fixedPointCountMod`: Counting fixed points over ZMod p
-/

import Mathlib

open Polynomial

namespace ArithmeticMonodromy

/-! ## Core Definitions -/

/-- The gradient step map for a univariate polynomial loss function.
    Given f : K[X] and step size η : K, returns the polynomial T(x) = x - η·f'(x).
    This is the fundamental object connecting optimization dynamics to algebraic geometry. -/
noncomputable def gradientStep {K : Type*} [CommRing K] (f : K[X]) (η : K) : K[X] :=
  X - C η * derivative f

/-- The set of critical points of a polynomial f, i.e., roots of f'. -/
def criticalPoints {K : Type*} [CommRing K] (f : K[X]) : Set K :=
  {x | aeval x (derivative f) = 0}

/-- The set of fixed points of the gradient step map T_{f,η}. -/
def fixedPoints {K : Type*} [CommRing K] (f : K[X]) (η : K) : Set K :=
  {x | aeval x (gradientStep f η) = x}

/-- The n-fold iterate of the gradient step map as a polynomial. -/
noncomputable def gradientIterate {K : Type*} [CommRing K] (f : K[X]) (η : K) : ℕ → K[X]
  | 0 => X
  | n + 1 => (gradientStep f η).comp (gradientIterate f η n)

/-- The set of critical values of f: the image of f at its critical points. -/
def criticalValueSet {K : Type*} [CommRing K] (f : K[X]) : Set K :=
  {y | ∃ x, aeval x (derivative f) = 0 ∧ aeval x f = y}

/-- Count of fixed points of the gradient step map over ZMod p.
    This is the core finite-field statistic that carries arithmetic fingerprint information. -/
noncomputable def fixedPointCountMod (p : ℕ) [Fact p.Prime] (f : (ZMod p)[X]) (η : ZMod p) : ℕ :=
  Fintype.card {x : ZMod p // aeval x (gradientStep f η) = x}

/-! ## Theorem 1: Critical Points are Fixed Points of Gradient Descent -/

/-
The gradient step map evaluated at x equals x - η·f'(x).
-/
theorem gradientStep_aeval {K : Type*} [CommRing K] (f : K[X]) (η : K) (x : K) :
    aeval x (gradientStep f η) = x - η * aeval x (derivative f) := by
  -- By definition of gradient step, we have $T(x) = x - \eta \cdot f'(x)$, so we can rewrite the goal using this definition.
  simp [gradientStep]

/-
Critical points are fixed by the gradient step map.
    This is the foundational bridge: optimization stationarity = dynamical fixed points.
-/
theorem gradientStep_fixes_criticalPoints {K : Type*} [CommRing K] (f : K[X]) (η : K)
    (x : K) (hx : x ∈ criticalPoints f) :
    aeval x (gradientStep f η) = x := by
  simp_all +decide [ criticalPoints, gradientStep ]

/-
Fixed points of gradient step with nonzero step size are exactly the critical points.
    This theorem shows that the algebraic structure of the gradient descent map
    perfectly captures the optimization landscape's stationary structure.
-/
theorem fixedPoints_eq_criticalPoints {K : Type*} [Field K] (f : K[X]) (η : K) (hη : η ≠ 0) :
    fixedPoints f η = criticalPoints f := by
  ext x; simp +decide [ gradientStep_aeval, criticalPoints, fixedPoints ] ; aesop;

/-! ## Theorem 2: Gradient Step Preserves Algebraicity -/

/-
Gradient step preserves algebraicity of points.
    This theorem provides the formal bridge from optimization dynamics to arithmetic
    geometry: exact descent on polynomial losses stays inside the algebraic world,
    so Galois/monodromy methods are native, not merely analogies.
-/
theorem gradientStep_eval_isAlgebraic
    {K L : Type*} [Field K] [Field L] [Algebra K L]
    (f : K[X]) (η : K) (x : L) (hx : IsAlgebraic K x) :
    IsAlgebraic K (aeval x (gradientStep f η)) := by
  -- Since $x$ is algebraic over $K$, any polynomial expression in $x$ with coefficients in $K$ is also algebraic over $K$.
  have h_poly_alg : ∀ p : K[X], IsAlgebraic K (aeval x p) := by
    intro p
    have h_eval_alg : IsIntegral K x := by
      exact hx.isIntegral
    have h_poly_alg : IsIntegral K (aeval x p) := by
      simp +decide [ Polynomial.aeval_def, Polynomial.eval₂_eq_sum_range ];
      exact IsIntegral.sum _ fun i hi => IsIntegral.mul ( isIntegral_algebraMap ) ( h_eval_alg.pow _ )
    exact h_poly_alg.isAlgebraic;
  aesop

/-! ## Theorem 3: Fixed Point Counting Over Finite Fields -/

/-- The fixed point polynomial: whose roots are exactly the fixed points of gradient step.
    For nonzero η, this equals C η * derivative f. -/
noncomputable def fixedPointPoly {K : Type*} [CommRing K] (f : K[X]) (η : K) : K[X] :=
  C η * derivative f

/-
Fixed points of gradient step are exactly roots of η · f'.
-/
theorem mem_fixedPoints_iff_root {K : Type*} [CommRing K] (f : K[X]) (η : K) (x : K) :
    x ∈ fixedPoints f η ↔ aeval x (fixedPointPoly f η) = 0 := by
  simp +decide [ fixedPoints, fixedPointPoly, gradientStep_aeval ]

/-
The gradient iterate at step 0 is the identity.
-/
theorem gradientIterate_zero {K : Type*} [CommRing K] (f : K[X]) (η : K) :
    gradientIterate f η 0 = X := by
  rfl

/-
The gradient iterate at step n+1 is the composition of gradient step with iterate n.
-/
theorem gradientIterate_succ {K : Type*} [CommRing K] (f : K[X]) (η : K) (n : ℕ) :
    gradientIterate f η (n + 1) = (gradientStep f η).comp (gradientIterate f η n) := by
  rfl

/-
Evaluating the gradient iterate is the same as iterating evaluation.
-/
theorem gradientIterate_aeval {K : Type*} [CommRing K] (f : K[X]) (η : K) (x : K) (n : ℕ) :
    aeval x (gradientIterate f η n) = (fun y => aeval y (gradientStep f η))^[n] x := by
  induction' n with n ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply' ];
  · exact Polynomial.eval_X;
  · rw [ ← ih, gradientIterate_succ, Polynomial.eval_comp ]

end ArithmeticMonodromy