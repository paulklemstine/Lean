import Mathlib

/-!
# The logistic map is a Chebyshev polynomial: a bridge between chaos and orthogonal polynomials

The **logistic map** `f(x) = 4·x·(1 - x)` on the unit interval is the archetypal
smooth one-dimensional chaotic system.  The **Chebyshev polynomials** `T_m` are the
central objects of classical approximation theory and the theory of orthogonal
polynomials, characterised by the trigonometric identity `T_m(cos θ) = cos(m θ)`.

These two worlds — nonlinear real dynamics on one side, orthogonal polynomials and
approximation theory on the other — look unrelated.  This file proves they are the
*same object*: the `n`-fold iterate of the logistic map is, exactly, a rescaled
Chebyshev polynomial of degree `2ⁿ`.

Concretely, writing `x = sin²(φ)` turns the logistic map into angle doubling
(`f(sin²φ) = sin²(2φ)`), so the `n`-th iterate doubles the angle `n` times.  Since
`sin²(2ⁿφ) = (1 - cos(2ⁿ⁺¹φ))/2` and `T_{2ⁿ}(cos 2φ) = cos(2ⁿ⁺¹φ)`, the iterate is
literally

  `fⁿ(x) = (1 - T_{2ⁿ}(1 - 2x)) / 2`   for every real `x`.

This is an *exact* polynomial identity, not an approximation.  From it the
"algebraic depth" folklore (`fⁿ` has degree `2ⁿ`) drops out as the Chebyshev degree
`deg T_{2ⁿ} = 2ⁿ`, and the exponential stretching of the dynamics is exactly the
`2ⁿ`-fold angle multiplication encoded by Chebyshev.

## Main results

* `LogisticChebyshev.logistic_sin_sq` — `f(sin²φ) = sin²(2φ)` (semiconjugacy to
  angle doubling).
* `LogisticChebyshev.logistic_iterate_sin_sq` — `fⁿ(sin²φ) = sin²(2ⁿφ)`.
* `LogisticChebyshev.sin_sq_eq_chebyshev` — `sin²(2ⁿφ) = (1 - T_{2ⁿ}(cos 2φ))/2`.
* `LogisticChebyshev.logistic_iterate_eq_chebyshev` — **the bridge**: for *every*
  real `x`, `fⁿ(x) = (1 - T_{2ⁿ}(1 - 2x))/2`.
* `LogisticChebyshev.chebRHS_natDegree` — the Chebyshev description has degree `2ⁿ`.
* `LogisticChebyshev.logistic_iterate_natDegree` — hence the `n`-th logistic iterate
  is a polynomial of degree `2ⁿ`, read off from the Chebyshev degree.
-/

namespace LogisticChebyshev

open Polynomial Polynomial.Chebyshev Set

/-- The logistic map at the fully chaotic parameter `r = 4`. -/
def logistic (x : ℝ) : ℝ := 4 * x * (1 - x)

@[simp] lemma logistic_zero : logistic 0 = 0 := by simp [logistic]
@[simp] lemma logistic_one : logistic 1 = 0 := by simp [logistic]

/-! ## Semiconjugacy to angle doubling -/

/-- **Semiconjugacy.**  Under `x = sin²φ` the logistic map becomes angle doubling:
`f(sin²φ) = sin²(2φ)`. -/
theorem logistic_sin_sq (φ : ℝ) :
    logistic (Real.sin φ ^ 2) = Real.sin (2 * φ) ^ 2 := by
  unfold logistic
  rw [Real.sin_two_mul, ← Real.cos_sq_add_sin_sq φ]
  ring_nf

/-- The `n`-fold logistic iterate doubles the angle `n` times:
`fⁿ(sin²φ) = sin²(2ⁿφ)`. -/
theorem logistic_iterate_sin_sq (n : ℕ) (φ : ℝ) :
    logistic^[n] (Real.sin φ ^ 2) = Real.sin (2 ^ n * φ) ^ 2 := by
  induction n generalizing φ with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ', Function.comp_apply, ih, logistic_sin_sq]
    rw [show 2 * (2 ^ k * φ) = 2 ^ (k + 1) * φ by ring]

/-! ## The Chebyshev identity -/

/-
`sin²(2ⁿφ)` is exactly `(1 - T_{2ⁿ}(cos 2φ))/2`, the Chebyshev polynomial of
degree `2ⁿ` evaluated at `cos 2φ`.
-/
theorem sin_sq_eq_chebyshev (n : ℕ) (φ : ℝ) :
    Real.sin (2 ^ n * φ) ^ 2
      = (1 - (T ℝ ((2 : ℤ) ^ n)).eval (Real.cos (2 * φ))) / 2 := by
  -- Use the double-angle form sin²a = (1 - cos(2a))/2 with a = 2^n * φ, so 2a = 2*(2^n*φ).
  have h_double_angle : Real.sin (2 ^ n * φ) ^ 2 = (1 - Real.cos (2 * (2 ^ n * φ))) / 2 := by
    rw [ Real.sin_sq, Real.cos_sq ] ; ring;
  convert h_double_angle using 3;
  convert Polynomial.Chebyshev.T_real_cos _ _ using 2 ; norm_cast ; ring

/-! ## The polynomial bridge -/

/-- The Chebyshev description of the `n`-th logistic iterate, as a real polynomial:
`(1 - T_{2ⁿ}(1 - 2X))/2`. -/
noncomputable def chebRHS (n : ℕ) : Polynomial ℝ :=
  Polynomial.C (1 / 2) - Polynomial.C (1 / 2) *
    (T ℝ ((2 : ℤ) ^ n)).comp (Polynomial.C 1 - Polynomial.C 2 * X)

@[simp] lemma chebRHS_eval (n : ℕ) (x : ℝ) :
    (chebRHS n).eval x = (1 - (T ℝ ((2 : ℤ) ^ n)).eval (1 - 2 * x)) / 2 := by
  simp only [chebRHS, eval_sub, eval_mul, eval_C, eval_comp, eval_X]
  ring

/-- The logistic map as a real polynomial. -/
noncomputable def logisticPoly : Polynomial ℝ := Polynomial.C 4 * X * (1 - X)

/-- The `n`-fold composition of `logisticPoly` with itself. -/
noncomputable def logisticPolyIter : ℕ → Polynomial ℝ
  | 0 => X
  | (n + 1) => logisticPoly.comp (logisticPolyIter n)

/-- The polynomial iterate evaluates to the functional iterate. -/
theorem logisticPolyIter_eval (n : ℕ) (x : ℝ) :
    (logisticPolyIter n).eval x = logistic^[n] x := by
  induction n generalizing x with
  | zero => simp [logisticPolyIter]
  | succ k ih =>
    rw [logisticPolyIter, Polynomial.eval_comp, Function.iterate_succ',
      Function.comp_apply, ih]
    simp only [logisticPoly, logistic]
    simp

/-
On the unit interval, the `n`-th logistic iterate agrees with the Chebyshev
description.
-/
theorem chebyshev_iterate_Icc (n : ℕ) {x : ℝ} (hx : x ∈ Icc (0 : ℝ) 1) :
    logistic^[n] x = (1 - (T ℝ ((2 : ℤ) ^ n)).eval (1 - 2 * x)) / 2 := by
  obtain ⟨φ, hφ⟩ : ∃ φ : ℝ, Real.sin φ = Real.sqrt x ∧ 0 ≤ φ ∧ φ ≤ Real.pi / 2 := by
    exact ⟨ Real.arcsin ( Real.sqrt x ), by rw [ Real.sin_arcsin ] <;> nlinarith [ hx.1, hx.2, Real.mul_self_sqrt hx.1 ], Real.arcsin_nonneg.2 <| Real.sqrt_nonneg _, Real.arcsin_le_pi_div_two _ ⟩;
  convert sin_sq_eq_chebyshev n φ using 1;
  · rw [ ← logistic_iterate_sin_sq, hφ.1, Real.sq_sqrt hx.1 ];
  · rw [ Real.cos_two_mul, show Real.cos φ ^ 2 = 1 - Real.sin φ ^ 2 by rw [ Real.cos_sq' ] ] ; rw [ hφ.1, Real.sq_sqrt hx.1 ];
    ring_nf

/-- **The iterate IS the Chebyshev polynomial.**  As real polynomials, the `n`-fold
composition of the logistic map equals the rescaled `2ⁿ`-th Chebyshev polynomial.
Two polynomials agreeing on the whole (infinite) unit interval must be equal. -/
theorem logisticPolyIter_eq_chebRHS (n : ℕ) : logisticPolyIter n = chebRHS n := by
  apply Polynomial.eq_of_infinite_eval_eq;
  exact Set.Infinite.mono ( fun x hx => by simpa [ logisticPolyIter_eval, chebRHS_eval ] using chebyshev_iterate_Icc n hx ) ( Set.Icc_infinite ( by norm_num : ( 0 : ℝ ) < 1 ) )

/-- **The bridge.**  For *every* real `x`, the `n`-fold iterate of the logistic map
equals the rescaled Chebyshev polynomial of degree `2ⁿ`:
`fⁿ(x) = (1 - T_{2ⁿ}(1 - 2x))/2`.  Chaos and orthogonal polynomials are the same
object. -/
theorem logistic_iterate_eq_chebyshev (n : ℕ) (x : ℝ) :
    logistic^[n] x = (1 - (T ℝ ((2 : ℤ) ^ n)).eval (1 - 2 * x)) / 2 := by
  rw [← logisticPolyIter_eval, logisticPolyIter_eq_chebRHS, chebRHS_eval]

/-! ## Algebraic depth via the Chebyshev degree -/

/-- The Chebyshev description has degree `2ⁿ`, since `deg T_{2ⁿ} = 2ⁿ`. -/
theorem chebRHS_natDegree (n : ℕ) : (chebRHS n).natDegree = 2 ^ n := by
  convert Polynomial.natDegree_sub_eq_right_of_natDegree_lt _ using 1;
  · rw [ Polynomial.natDegree_C_mul, Polynomial.natDegree_comp, Polynomial.natDegree_sub_eq_right_of_natDegree_lt ] <;> norm_num;
  · erw [ Polynomial.natDegree_C_mul, Polynomial.natDegree_comp, Polynomial.natDegree_sub_eq_right_of_natDegree_lt ] <;> norm_num

/-- **Exponential algebraic depth, via Chebyshev.**  The `n`-th logistic iterate is
a polynomial of degree `2ⁿ` — a fact read off directly from the degree of the
Chebyshev polynomial `T_{2ⁿ}`. -/
theorem logistic_iterate_natDegree (n : ℕ) : (logisticPolyIter n).natDegree = 2 ^ n := by
  rw [logisticPolyIter_eq_chebRHS, chebRHS_natDegree]

/-! ## Periodic points: the base case of the `2ⁿ` law

The strongest remaining conjecture is that the logistic map has exactly `2ⁿ` points
of period `n` (fixed points of `fⁿ`).  Here we settle the base case `n = 1`
explicitly: the fixed points of the logistic map are precisely `{0, 3/4}`, and there
are exactly `2 = 2¹` of them, matching the conjectured count. -/

/-- The fixed points of the logistic map are exactly `0` and `3/4`. -/
theorem logistic_fixedPoints (x : ℝ) : logistic x = x ↔ x = 0 ∨ x = 3 / 4 := by
  unfold logistic
  constructor
  · intro h
    rcases mul_eq_zero.1 (show x * (3 - 4 * x) = 0 by nlinarith) with h1 | h1
    · exact Or.inl h1
    · exact Or.inr (by linarith)
  · rintro (rfl | rfl) <;> ring

/-- **Base case of the `2ⁿ` periodic-point law.**  The logistic map has exactly
`2 = 2¹` fixed points (period-`1` points). -/
theorem logistic_fixedPoints_card :
    Set.ncard {x : ℝ | logistic x = x} = 2 ^ 1 := by
  have h : {x : ℝ | logistic x = x} = {0, 3 / 4} := by
    ext x
    simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
    exact logistic_fixedPoints x
  rw [h, Set.ncard_pair (by norm_num), pow_one]

/-! ### The case `n = 2` of the `2ⁿ` law

The fixed points of the second iterate `f²` (the points of period dividing `2`)
are exactly the two genuine fixed points `0, 3/4` together with the period-`2`
orbit `{(5 - √5)/8, (5 + √5)/8}`.  There are `4 = 2²` of them, matching the
conjectured count.  The key algebraic fact is the exact factorisation
`f²(x) - x = -4·x·(x - 3/4)·(16x² - 20x + 5)`, whose quadratic factor has roots
`(5 ± √5)/8`. -/

/-- The fixed points of the second logistic iterate `f²` are exactly the four
points `0`, `3/4`, `(5 - √5)/8`, `(5 + √5)/8`. -/
theorem logistic_iterate2_fixedPoints (x : ℝ) :
    logistic^[2] x = x ↔
      x = 0 ∨ x = 3 / 4 ∨ x = (5 - Real.sqrt 5) / 8 ∨ x = (5 + Real.sqrt 5) / 8 := by
  simp +decide [ logistic ] ; ring_nf;
  grind

/-- **Case `n = 2` of the `2ⁿ` periodic-point law.**  The second logistic iterate
`f²` has exactly `4 = 2²` fixed points (points of period dividing `2`). -/
theorem logistic_iterate2_fixedPoints_card :
    Set.ncard {x : ℝ | logistic^[2] x = x} = 2 ^ 2 := by
  rw [ show { x | logistic^[2] x = x } = { 0, 3 / 4, ( 5 - Real.sqrt 5 ) / 8, ( 5 + Real.sqrt 5 ) / 8 } from ?_ ];
  · rw [ Set.ncard_insert_of_notMem, Set.ncard_insert_of_notMem, Set.ncard_insert_of_notMem, Set.ncard_singleton ] <;> ring <;> norm_num;
    · linarith [ Real.sqrt_pos.2 ( show 5 > 0 by norm_num ) ];
    · grind;
    · grind;
  · exact Set.ext fun x => logistic_iterate2_fixedPoints x

end LogisticChebyshev