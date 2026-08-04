import Mathlib

/-!
# No rational solutions of `y'' = r·y`, and the Riccati correspondence

This file complements the EML solution theory of second-order linear equations
`y'' = r·y` with two independent ingredients.

## 1. The Riccati correspondence (analytic)

For a nowhere-vanishing `y`, writing `u = y'/y` turns the *linear* equation
`y'' = r·y` into the *nonlinear* Riccati equation `u' + u² = r`, and conversely.
This is the change of variables underlying Kovacic's algorithm; it is proved here
for genuine real functions in `riccati_of_secondOrder` and
`secondOrder_of_riccati`.

## 2. `y'' = r·y` has no rational solution for `r ≠ 0`

Writing a candidate rational solution as `P/Q` and clearing denominators turns
the equation into the polynomial identity

  `W'·Q - 2·W·Q' = r·P·Q²`,   `W = P'·Q - P·Q'`,

and a degree count shows this is impossible whenever `r ≠ 0` and `P ≠ 0`
(`secondOrder_no_rational_solution`).  Specialising to `r = x` gives
`airy_no_rational_solution`: **the Airy equation has no nonzero rational
solution**, and in particular no polynomial one.

The analytic form `airy_rational_not_solution` states this for actual real
functions.
-/

namespace AiryRational

open Polynomial

/-! ## 1. The Riccati correspondence -/

/-- **Linear ⟶ Riccati.**  If `y` never vanishes, `y' = u·y` and `y'' = r·y`,
then `u` satisfies the Riccati equation `u' + u² = r`. -/
theorem riccati_of_secondOrder (r y u u' : ℝ → ℝ) (hy0 : ∀ x, y x ≠ 0)
    (hy : ∀ x, HasDerivAt y (u x * y x) x)
    (hu : ∀ x, HasDerivAt u (u' x) x)
    (h2 : ∀ x, HasDerivAt (fun t => u t * y t) (r x * y x) x) :
    ∀ x, u' x + u x ^ 2 = r x := by
  intro x
  have hEq := (h2 x).unique ((hu x).mul (hy x))
  have h0 : (u' x + u x ^ 2 - r x) * y x = 0 := by linear_combination -hEq
  have := (mul_eq_zero.mp h0).resolve_right (hy0 x)
  linarith

/-- **Riccati ⟶ linear.**  If `u' + u² = r` and `y' = u·y`, then `y'' = r·y`. -/
theorem secondOrder_of_riccati (r y u u' : ℝ → ℝ)
    (hy : ∀ x, HasDerivAt y (u x * y x) x)
    (hu : ∀ x, HasDerivAt u (u' x) x)
    (hric : ∀ x, u' x + u x ^ 2 = r x) :
    ∀ x, HasDerivAt (fun t => u t * y t) (r x * y x) x := by
  intro x
  have h := (hu x).mul (hy x)
  convert h using 1
  rw [← hric x]
  ring

/-- The logarithmic derivative of a product is the sum of the logarithmic
derivatives: the "EML group" law behind the exponential parametrisation of
solutions of first-order equations. -/
theorem logDeriv_mul_of_hasDerivAt (f g f' g' : ℝ → ℝ) (x : ℝ)
    (hf : HasDerivAt f (f' x) x) (hg : HasDerivAt g (g' x) x)
    (hf0 : f x ≠ 0) (hg0 : g x ≠ 0) :
    HasDerivAt (fun t => f t * g t) ((f' x / f x + g' x / g x) * (f x * g x)) x := by
  convert hf.mul hg using 1
  field_simp

/-! ## 2. The algebraic obstruction to rational solutions -/

section Algebraic

variable {K : Type*} [Field K]

/-- If `A` and `B` are nonzero then `A'·B` has degree `< deg A + deg B`, and
likewise `A·B'`; hence any `K`-linear combination of the two does. -/
theorem degree_deriv_comb_lt (A B : K[X]) (c : K) (hA : A ≠ 0) (hB : B ≠ 0) :
    (derivative A * B - C c * (A * derivative B)).degree < A.degree + B.degree := by
  have h1 : (derivative A * B).degree < A.degree + B.degree := by
    calc (derivative A * B).degree ≤ (derivative A).degree + B.degree :=
          Polynomial.degree_mul_le _ _
      _ < A.degree + B.degree :=
          WithBot.add_lt_add_right (by simpa using hB) (Polynomial.degree_derivative_lt hA)
  have h2 : (C c * (A * derivative B)).degree < A.degree + B.degree := by
    have hCle : (C c * (A * derivative B)).degree ≤ (A * derivative B).degree := by
      refine le_trans (Polynomial.degree_mul_le _ _) ?_
      have hz : (C c).degree + (A * derivative B).degree
          ≤ 0 + (A * derivative B).degree := by
        gcongr
        exact Polynomial.degree_C_le
      rwa [zero_add] at hz
    calc (C c * (A * derivative B)).degree ≤ (A * derivative B).degree := hCle
      _ ≤ A.degree + (derivative B).degree := Polynomial.degree_mul_le _ _
      _ < A.degree + B.degree :=
          WithBot.add_lt_add_left (by simpa using hA) (Polynomial.degree_derivative_lt hB)
  exact lt_of_le_of_lt (Polynomial.degree_sub_le _ _) (max_lt h1 h2)

/-- **`y'' = r·y` has no nonzero rational solution when `r ≠ 0`.**

Writing `y = P/Q` and `W = P'Q - PQ'` (so that `y' = W/Q²` and
`y'' = (W'Q - 2WQ')/Q³`), the equation `y'' = r·y` becomes the polynomial
identity `W'·Q - 2·W·Q' = r·P·Q²`.  A degree count rules it out: the left-hand
side has degree `< deg P + 2·deg Q`, whereas the right-hand side has degree
`deg r + deg P + 2·deg Q`. -/
theorem secondOrder_no_rational_solution (r P Q : K[X]) (hr : r ≠ 0) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    derivative (derivative P * Q - P * derivative Q) * Q
        - C (2 : K) * ((derivative P * Q - P * derivative Q) * derivative Q)
      ≠ r * P * Q ^ 2 := by
  set W : K[X] := derivative P * Q - P * derivative Q with hWdef
  intro heq
  have hRHS0 : r * P * Q ^ 2 ≠ 0 := mul_ne_zero (mul_ne_zero hr hP) (pow_ne_zero 2 hQ)
  rcases eq_or_ne W 0 with hW0 | hW0
  · rw [hW0] at heq
    simp only [Polynomial.derivative_zero, zero_mul, mul_zero, sub_zero] at heq
    exact hRHS0 heq.symm
  · -- degree of the left-hand side
    have hLHS : (derivative W * Q - C (2 : K) * (W * derivative Q)).degree
        < W.degree + Q.degree := degree_deriv_comb_lt W Q 2 hW0 hQ
    have hWlt : W.degree < P.degree + Q.degree := by
      rw [hWdef]
      have := degree_deriv_comb_lt P Q 1 hP hQ
      simpa using this
    have hstep : W.degree + Q.degree < P.degree + Q.degree + Q.degree :=
      WithBot.add_lt_add_right (by simpa using hQ) hWlt
    have hPQd : P.degree + Q.degree + Q.degree
        = ((P.natDegree + 2 * Q.natDegree : ℕ) : WithBot ℕ) := by
      rw [Polynomial.degree_eq_natDegree hP, Polynomial.degree_eq_natDegree hQ]
      push_cast
      ring
    have hRHSd : (r * P * Q ^ 2).degree
        = ((r.natDegree + P.natDegree + 2 * Q.natDegree : ℕ) : WithBot ℕ) := by
      rw [Polynomial.degree_eq_natDegree hRHS0, Polynomial.natDegree_mul (mul_ne_zero hr hP)
        (pow_ne_zero 2 hQ), Polynomial.natDegree_mul hr hP, Polynomial.natDegree_pow]
    have hfin : (derivative W * Q - C (2 : K) * (W * derivative Q)).degree
        < (r * P * Q ^ 2).degree := by
      refine lt_of_lt_of_le (lt_trans hLHS hstep) ?_
      rw [hPQd, hRHSd]
      exact_mod_cast (by omega : P.natDegree + 2 * Q.natDegree
        ≤ r.natDegree + P.natDegree + 2 * Q.natDegree)
    rw [heq] at hfin
    exact lt_irrefl _ hfin

/-- **The Airy equation has no nonzero rational solution.** -/
theorem airy_no_rational_solution (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    derivative (derivative P * Q - P * derivative Q) * Q
        - C (2 : K) * ((derivative P * Q - P * derivative Q) * derivative Q)
      ≠ (X : K[X]) * P * Q ^ 2 :=
  secondOrder_no_rational_solution X P Q Polynomial.X_ne_zero hP hQ

/-- **The Airy equation has no nonzero polynomial solution** (the case `Q = 1` of
`airy_no_rational_solution`, stated directly). -/
theorem airy_no_polynomial_solution (P : K[X]) (hP : P ≠ 0) :
    derivative (derivative P) ≠ (X : K[X]) * P := by
  intro h
  have h1 : (X * P).degree = 1 + P.degree := by
    rw [Polynomial.degree_mul, Polynomial.degree_X]
  have h2 : (derivative (derivative P)).degree < P.degree := by
    rcases eq_or_ne (derivative P) 0 with h0 | h0
    · rw [h0, Polynomial.derivative_zero, Polynomial.degree_zero,
        Polynomial.degree_eq_natDegree hP]
      exact WithBot.bot_lt_coe _
    · exact lt_trans (Polynomial.degree_derivative_lt h0) (Polynomial.degree_derivative_lt hP)
  rw [h, h1, Polynomial.degree_eq_natDegree hP] at h2
  have : 1 + P.natDegree < P.natDegree := by exact_mod_cast h2
  omega

end Algebraic

/-! ## 3. Analytic form -/

/-- **Airy functions are not rational.**

If `Q` is a nowhere-vanishing real polynomial and `P ≠ 0`, then the rational
function `y = P/Q` is not a solution of the Airy equation `y'' = x·y`: its first
derivative `W/Q²` (with `W = P'Q - PQ'`) cannot have derivative `x·y`. -/
theorem airy_rational_not_solution (P Q : ℝ[X]) (hP : P ≠ 0) (hQ : ∀ x : ℝ, Q.eval x ≠ 0)
    (hairy : ∀ x : ℝ,
      HasDerivAt (fun t : ℝ => (derivative P * Q - P * derivative Q).eval t / (Q.eval t) ^ 2)
        (x * (P.eval x / Q.eval x)) x) : False := by
  set W : ℝ[X] := derivative P * Q - P * derivative Q with hWdef
  have hQ0 : Q ≠ 0 := fun h => hQ 0 (by simp [h])
  -- differentiate `W / Q²` by the quotient rule
  have hd : ∀ x : ℝ, HasDerivAt (fun t : ℝ => W.eval t / (Q.eval t) ^ 2)
      (((derivative W).eval x * (Q.eval x) ^ 2
        - W.eval x * (2 * Q.eval x * (derivative Q).eval x)) / ((Q.eval x) ^ 2) ^ 2) x := by
    intro x
    have hq2 : HasDerivAt (fun t : ℝ => (Q.eval t) ^ 2)
        (2 * Q.eval x * (derivative Q).eval x) x := by
      have := (Q.hasDerivAt x).pow 2
      convert this using 1
      ring
    exact (W.hasDerivAt x).div hq2 (pow_ne_zero 2 (hQ x))
  -- pointwise identity, then a polynomial identity
  have hpoly : ∀ x : ℝ,
      ((derivative W * Q - C (2 : ℝ) * (W * derivative Q)).eval x)
        = (((X : ℝ[X]) * P * Q ^ 2).eval x) := by
    intro x
    have hEq := (hairy x).unique (hd x)
    have hQx := hQ x
    simp only [Polynomial.eval_sub, Polynomial.eval_mul, Polynomial.eval_pow,
      Polynomial.eval_X, Polynomial.eval_C]
    field_simp at hEq
    linarith [hEq]
  exact airy_no_rational_solution P Q hP hQ0 (Polynomial.funext hpoly)

end AiryRational