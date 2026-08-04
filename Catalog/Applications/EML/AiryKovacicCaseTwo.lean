import Mathlib

/-!
# Kovacic's second case for Airy's equation: products of solutions are not rational

Kovacic's algorithm for `y'' = r·y` proceeds by cases according to the shape of
the Liouvillian solution.  The first case (a solution with rational logarithmic
derivative) is ruled out for Airy's equation `y'' = x·y` in
`Applications/EML/EMLDifferentialEquations.lean`.  The present file treats the
input of the **second case**, which concerns the *second symmetric power* of the
equation: if `y₁` and `y₂` are solutions of `y'' = r·y`, then their product
`v = y₁·y₂` satisfies the third-order equation

  `v''' = 4·r·v' + 2·r'·v`.                                              (S²)

## Contents

* `product_hasDerivAt`, `product_secondDeriv`, `product_thirdDeriv` — the
  analytic derivation of (S²): the first three derivatives of a product of two
  solutions of `y'' = r·y`.
* `wronskianNum`, `secondNum`, `thirdNum` — the successive numerators of the
  derivatives of a rational function `P/Q` (`v' = W/Q²`, `v'' = B/Q³`,
  `v''' = Z/Q⁴`), together with the corresponding analytic derivative rules
  `hasDerivAt_ratFunc₁`, `hasDerivAt_ratFunc₂`, `hasDerivAt_ratFunc₃`.
* `airy_symSquare_no_polynomial` — over any field of characteristic zero, the
  equation `v''' = 4·X·v' + 2·v` has no nonzero *polynomial* solution.
* `airy_symSquare_no_rational` — the same for *rational* solutions `v = P/Q`,
  by a degree count: after clearing denominators the left-hand side has degree
  `< deg P + 3·deg Q`, while the right-hand side has exactly that degree, with
  leading coefficient `(4·(deg P − deg Q) + 2)·lead P·(lead Q)³ ≠ 0`.
* `airy_product_not_rational` — the analytic capstone: **no product of two
  solutions of Airy's equation is a nonzero rational function** (with nowhere
  vanishing denominator).  This is exactly the failure of Kovacic's second case
  for Airy.
-/

namespace AiryCaseTwo

open Polynomial

/-! ## 1. Coefficient and degree lemmas -/

section Algebraic

variable {K : Type*} [Field K]

/-- Reading off the top coefficient of a product when a degree bound on the
first factor is known. -/
theorem coeff_mul_of_natDegree_le (f g : K[X]) (m : ℕ) (hf : f.natDegree ≤ m) :
    (f * g).coeff (m + g.natDegree) = f.coeff m * g.leadingCoeff := by
  rw [Polynomial.coeff_mul, Finset.sum_eq_single (m, g.natDegree)]
  · rfl
  · rintro ⟨i, j⟩ hij hne
    simp only [Finset.mem_antidiagonal] at hij
    have hi : i ≠ m := by rintro rfl; exact hne (by simp_all)
    rcases lt_or_gt_of_ne hi with h | h
    · rw [Polynomial.coeff_eq_zero_of_natDegree_lt (show g.natDegree < j by omega), mul_zero]
    · rw [Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt hf h), zero_mul]
  · intro h; simp at h

/-- The numerator `P'Q − PQ'` of the derivative of `P/Q`. -/
noncomputable def wronskianNum (P Q : K[X]) : K[X] := derivative P * Q - P * derivative Q

/-- The numerator of the second derivative of `P/Q`, i.e. `v'' = secondNum/Q³`. -/
noncomputable def secondNum (P Q : K[X]) : K[X] :=
  derivative (wronskianNum P Q) * Q - C 2 * (wronskianNum P Q * derivative Q)

/-- The numerator of the third derivative of `P/Q`, i.e. `v''' = thirdNum/Q⁴`. -/
noncomputable def thirdNum (P Q : K[X]) : K[X] :=
  derivative (secondNum P Q) * Q - C 3 * (secondNum P Q * derivative Q)

/-- The coefficient of `P'Q` in degree `deg P + deg Q − 1` is `deg P·lead P·lead Q`. -/
theorem coeff_derivative_mul (P Q : K[X]) (h : 1 ≤ P.natDegree + Q.natDegree) :
    (derivative P * Q).coeff (P.natDegree + Q.natDegree - 1)
      = (P.natDegree : K) * (P.leadingCoeff * Q.leadingCoeff) := by
  rcases Nat.eq_zero_or_pos P.natDegree with hn | hn
  · obtain ⟨a, ha⟩ := Polynomial.natDegree_eq_zero.1 hn
    simp [← ha]
  · have hidx : P.natDegree + Q.natDegree - 1 = (P.natDegree - 1) + Q.natDegree := by omega
    rw [hidx, coeff_mul_of_natDegree_le _ _ _ (natDegree_derivative_le P),
      Polynomial.coeff_derivative]
    have h1 : P.natDegree - 1 + 1 = P.natDegree := by omega
    have hc : ((P.natDegree - 1 : ℕ) : K) + 1 = (P.natDegree : K) := by
      have hcast : ((P.natDegree - 1 : ℕ) : K) = (P.natDegree : K) - 1 := by
        push_cast [Nat.cast_sub hn]; ring
      rw [hcast]; ring
    rw [h1, hc]
    simp only [Polynomial.leadingCoeff]
    ring

/-- The top coefficient of the Wronskian numerator: the coefficient of
`P'Q − PQ'` in degree `deg P + deg Q − 1` is `(deg P − deg Q)·lead P·lead Q`. -/
theorem coeff_wronskianNum (P Q : K[X]) :
    (wronskianNum P Q).coeff (P.natDegree + Q.natDegree - 1)
      = ((P.natDegree : K) - (Q.natDegree : K)) * (P.leadingCoeff * Q.leadingCoeff) := by
  rcases Nat.lt_or_ge (P.natDegree + Q.natDegree) 1 with h | h
  · obtain ⟨a, ha⟩ := Polynomial.natDegree_eq_zero.1 (show P.natDegree = 0 by omega)
    obtain ⟨b, hb⟩ := Polynomial.natDegree_eq_zero.1 (show Q.natDegree = 0 by omega)
    simp [wronskianNum, ← ha, ← hb]
  · rw [wronskianNum, Polynomial.coeff_sub, coeff_derivative_mul P Q h]
    have h2 : (derivative Q * P).coeff (Q.natDegree + P.natDegree - 1)
        = (Q.natDegree : K) * (Q.leadingCoeff * P.leadingCoeff) :=
      coeff_derivative_mul Q P (by omega)
    rw [mul_comm P (derivative Q),
      show P.natDegree + Q.natDegree - 1 = Q.natDegree + P.natDegree - 1 by omega, h2]
    ring

/-- A combination `A'B − c·(AB')` has degree strictly less than `deg A + deg B`. -/
theorem degree_deriv_comb_lt (A B : K[X]) (c : K) (hA : A ≠ 0) (hB : B ≠ 0) :
    (derivative A * B - C c * (A * derivative B)).degree < A.degree + B.degree := by
  have hAb : A.degree ≠ ⊥ := degree_ne_bot.mpr hA
  have hBb : B.degree ≠ ⊥ := degree_ne_bot.mpr hB
  have h1 : (derivative A * B).degree < A.degree + B.degree :=
    lt_of_le_of_lt (degree_mul_le _ _)
      (WithBot.add_lt_add_right hBb (degree_derivative_lt hA))
  have hC : (C c * (A * derivative B)).degree ≤ (A * derivative B).degree := by
    refine le_trans (degree_mul_le _ _) ?_
    calc (C c).degree + (A * derivative B).degree ≤ 0 + (A * derivative B).degree :=
          add_le_add_left (degree_C_le (a := c)) _
      _ = (A * derivative B).degree := zero_add _
  have h2 : (C c * (A * derivative B)).degree < A.degree + B.degree :=
    lt_of_le_of_lt hC (lt_of_le_of_lt (degree_mul_le _ _)
      (WithBot.add_lt_add_left hAb (degree_derivative_lt hB)))
  exact lt_of_le_of_lt (degree_sub_le _ _) (max_lt h1 h2)

/-- The Wronskian numerator has degree `< deg P + deg Q`. -/
theorem degree_wronskianNum_lt (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    (wronskianNum P Q).degree < P.degree + Q.degree := by
  simpa [wronskianNum] using degree_deriv_comb_lt P Q 1 hP hQ

/-! ## 2. The algebraic obstruction -/

variable [CharZero K]

/-- **No polynomial solution of the second symmetric power equation for Airy.**

If `v ≠ 0` is a polynomial then `v''' ≠ 4·X·v' + 2·v`: the right-hand side has
degree exactly `deg v` with leading coefficient `(4·deg v + 2)·lead v ≠ 0`, while
`v'''` has degree `< deg v`. -/
theorem airy_symSquare_no_polynomial (P : K[X]) (hP : P ≠ 0) :
    derivative (derivative (derivative P)) ≠ C 4 * (X * derivative P) + C 2 * P := by
  intro heq
  set n := P.natDegree with hn
  have hL : (derivative (derivative (derivative P))).coeff n = 0 := by
    rw [Polynomial.coeff_derivative]
    have hd : (derivative (derivative P)).natDegree ≤ n :=
      le_trans (natDegree_derivative_le _) (le_trans (Nat.sub_le _ _)
        (le_trans (natDegree_derivative_le _) (Nat.sub_le _ _)))
    rw [Polynomial.coeff_eq_zero_of_natDegree_lt (by omega), zero_mul]
  have hR : (C 4 * (X * derivative P) + C 2 * P).coeff n
      = (4 * (n : K) + 2) * P.leadingCoeff := by
    rw [Polynomial.coeff_add, Polynomial.coeff_C_mul, Polynomial.coeff_C_mul]
    rcases Nat.eq_zero_or_pos n with h0 | h0
    · rw [h0]
      simp [Polynomial.leadingCoeff, ← hn, h0, Polynomial.mul_coeff_zero]
    · have hidx : n = (n - 1) + 1 := by omega
      rw [hidx, Polynomial.coeff_X_mul, Polynomial.coeff_derivative]
      have h1 : n - 1 + 1 = n := by omega
      have hc : ((n - 1 : ℕ) : K) + 1 = (n : K) := by
        have hcast : ((n - 1 : ℕ) : K) = (n : K) - 1 := by push_cast [Nat.cast_sub h0]; ring
        rw [hcast]; ring
      rw [h1, hc]
      simp only [Polynomial.leadingCoeff, ← hn]
      ring
  rw [heq, hR] at hL
  have hlead : P.leadingCoeff ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hP
  have hz : (4 * (n : K) + 2) = 0 := by
    rcases mul_eq_zero.1 hL with h | h
    · exact h
    · exact absurd h hlead
  have h2 : ((4 * n + 2 : ℕ) : K) = 0 := by push_cast; exact hz
  have := (Nat.cast_eq_zero (R := K)).1 h2
  omega

/-- The `Q²`-cleared right-hand side of the symmetric-square equation. -/
noncomputable def rhsPoly (P Q : K[X]) : K[X] :=
  C 4 * (X * (wronskianNum P Q * Q ^ 2)) + C 2 * (P * Q ^ 3)

/-- The `Q²`-free part of the right-hand side, `4·X·W + 2·P·Q`. -/
noncomputable def rhsCore (P Q : K[X]) : K[X] :=
  C 4 * (X * wronskianNum P Q) + C 2 * (P * Q)

omit [CharZero K] in
/-- The right-hand side factors as `rhsCore · Q²`. -/
theorem rhsPoly_eq (P Q : K[X]) : rhsPoly P Q = rhsCore P Q * Q ^ 2 := by
  simp only [rhsPoly, rhsCore]
  ring

/-- The top coefficient of `4·X·W + 2·P·Q` in degree `deg P + deg Q` is
`(4·(deg P − deg Q) + 2)·lead P·lead Q`, which is nonzero in characteristic
zero. -/
theorem coeff_rhsCore (P Q : K[X]) :
    (rhsCore P Q).coeff (P.natDegree + Q.natDegree)
      = (4 * ((P.natDegree : K) - (Q.natDegree : K)) + 2) * (P.leadingCoeff * Q.leadingCoeff) := by
  rw [rhsCore, Polynomial.coeff_add, Polynomial.coeff_C_mul, Polynomial.coeff_C_mul,
    Polynomial.coeff_mul_degree_add_degree]
  rcases Nat.eq_zero_or_pos (P.natDegree + Q.natDegree) with h0 | h0
  · rw [h0, Polynomial.mul_coeff_zero]
    simp [show P.natDegree = 0 by omega, show Q.natDegree = 0 by omega]
  · have hidx : P.natDegree + Q.natDegree = (P.natDegree + Q.natDegree - 1) + 1 := by omega
    rw [hidx, Polynomial.coeff_X_mul, coeff_wronskianNum]
    ring

omit [CharZero K] in
/-- `rhsCore` has degree at most `deg P + deg Q`. -/
theorem natDegree_rhsCore_le (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    (rhsCore P Q).natDegree ≤ P.natDegree + Q.natDegree := by
  refine le_trans (Polynomial.natDegree_add_le _ _) (max_le ?_ ?_)
  · refine le_trans (Polynomial.natDegree_C_mul_le _ _) ?_
    rcases eq_or_ne (wronskianNum P Q) 0 with hW | hW
    · simp [hW]
    · have hdeg : (wronskianNum P Q).degree < ((P.natDegree + Q.natDegree : ℕ) : WithBot ℕ) := by
        calc (wronskianNum P Q).degree < P.degree + Q.degree := degree_wronskianNum_lt P Q hP hQ
          _ = ((P.natDegree + Q.natDegree : ℕ) : WithBot ℕ) := by
              rw [Polynomial.degree_eq_natDegree hP, Polynomial.degree_eq_natDegree hQ]
              push_cast; ring
      have hlt : (wronskianNum P Q).natDegree < P.natDegree + Q.natDegree :=
        (Polynomial.natDegree_lt_iff_degree_lt hW).2 hdeg
      refine le_trans Polynomial.natDegree_mul_le ?_
      simp only [Polynomial.natDegree_X]
      omega
  · exact le_trans (Polynomial.natDegree_C_mul_le _ _) Polynomial.natDegree_mul_le

/-- The coefficient of the cleared right-hand side in degree
`deg P + 3·deg Q` is nonzero. -/
theorem coeff_rhsPoly_ne_zero (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    (rhsPoly P Q).coeff (P.natDegree + 3 * Q.natDegree) ≠ 0 := by
  have hQ2 : (Q ^ 2).natDegree = 2 * Q.natDegree := by rw [Polynomial.natDegree_pow]
  have hidx : P.natDegree + 3 * Q.natDegree = (P.natDegree + Q.natDegree) + (Q ^ 2).natDegree := by
    rw [hQ2]; ring
  rw [rhsPoly_eq, hidx, coeff_mul_of_natDegree_le _ _ _ (natDegree_rhsCore_le P Q hP hQ),
    coeff_rhsCore]
  have hlp : P.leadingCoeff ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hP
  have hlq : Q.leadingCoeff ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hQ
  have hlq2 : (Q ^ 2).leadingCoeff ≠ 0 :=
    Polynomial.leadingCoeff_ne_zero.mpr (pow_ne_zero 2 hQ)
  have hcoef : (4 * ((P.natDegree : K) - (Q.natDegree : K)) + 2) ≠ 0 := by
    intro h
    have h2 : ((4 * P.natDegree + 2 : ℕ) : K) = ((4 * Q.natDegree : ℕ) : K) := by
      push_cast; linear_combination h
    have := Nat.cast_injective (R := K) h2
    omega
  exact mul_ne_zero (mul_ne_zero hcoef (mul_ne_zero hlp hlq)) hlq2

omit [CharZero K] in
/-- The cleared left-hand side `thirdNum` has degree `< deg P + 3·deg Q`. -/
theorem degree_thirdNum_lt (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    (thirdNum P Q).degree < ((P.natDegree + 3 * Q.natDegree : ℕ) : WithBot ℕ) := by
  have hQd : Q.degree = (Q.natDegree : WithBot ℕ) := Polynomial.degree_eq_natDegree hQ
  have hPd : P.degree = (P.natDegree : WithBot ℕ) := Polynomial.degree_eq_natDegree hP
  have hQb : Q.degree ≠ ⊥ := Polynomial.degree_ne_bot.mpr hQ
  rcases eq_or_ne (wronskianNum P Q) 0 with hW | hW
  · have hs : secondNum P Q = 0 := by simp [secondNum, hW]
    have ht : thirdNum P Q = 0 := by simp [thirdNum, hs]
    rw [ht, Polynomial.degree_zero]
    exact WithBot.bot_lt_coe _
  rcases eq_or_ne (secondNum P Q) 0 with hs | hs
  · have ht : thirdNum P Q = 0 := by simp [thirdNum, hs]
    rw [ht, Polynomial.degree_zero]
    exact WithBot.bot_lt_coe _
  have h1 : (secondNum P Q).degree < (wronskianNum P Q).degree + Q.degree :=
    degree_deriv_comb_lt _ _ 2 hW hQ
  have h2 : (thirdNum P Q).degree < (secondNum P Q).degree + Q.degree :=
    degree_deriv_comb_lt _ _ 3 hs hQ
  have hWlt : (wronskianNum P Q).degree < ((P.natDegree + Q.natDegree : ℕ) : WithBot ℕ) := by
    calc (wronskianNum P Q).degree < P.degree + Q.degree := degree_wronskianNum_lt P Q hP hQ
      _ = ((P.natDegree + Q.natDegree : ℕ) : WithBot ℕ) := by rw [hPd, hQd]; push_cast; ring
  have hSlt : (secondNum P Q).degree < ((P.natDegree + 2 * Q.natDegree : ℕ) : WithBot ℕ) := by
    refine lt_trans h1 ?_
    calc (wronskianNum P Q).degree + Q.degree
        < ((P.natDegree + Q.natDegree : ℕ) : WithBot ℕ) + Q.degree :=
          WithBot.add_lt_add_right hQb hWlt
      _ = ((P.natDegree + 2 * Q.natDegree : ℕ) : WithBot ℕ) := by rw [hQd]; push_cast; ring
  refine lt_trans h2 ?_
  calc (secondNum P Q).degree + Q.degree
      < ((P.natDegree + 2 * Q.natDegree : ℕ) : WithBot ℕ) + Q.degree :=
        WithBot.add_lt_add_right hQb hSlt
    _ = ((P.natDegree + 3 * Q.natDegree : ℕ) : WithBot ℕ) := by rw [hQd]; push_cast; ring

/-- **No rational solution of the second symmetric power equation for Airy.**

Writing a candidate solution as `v = P/Q` and clearing denominators, the equation
`v''' = 4·x·v' + 2·v` becomes `thirdNum = 4·X·W·Q² + 2·P·Q³`.  This is impossible
for `P, Q ≠ 0`. -/
theorem airy_symSquare_no_rational (P Q : K[X]) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    thirdNum P Q ≠ rhsPoly P Q := by
  intro heq
  have h1 := coeff_rhsPoly_ne_zero P Q hP hQ
  have h2 := degree_thirdNum_lt P Q hP hQ
  rw [← heq] at h1
  exact h1 (Polynomial.coeff_eq_zero_of_degree_lt h2)

end Algebraic

/-! ## 3. The analytic second symmetric power -/

section Analytic

/-- The first derivative of a product of two solutions. -/
theorem product_hasDerivAt (y₁ y₂ z₁ z₂ : ℝ → ℝ)
    (hy₁ : ∀ x, HasDerivAt y₁ (z₁ x) x) (hy₂ : ∀ x, HasDerivAt y₂ (z₂ x) x) (x : ℝ) :
    HasDerivAt (fun t => y₁ t * y₂ t) (y₁ x * z₂ x + z₁ x * y₂ x) x := by
  have h := (hy₁ x).mul (hy₂ x)
  convert h using 1
  ring

/-- The second derivative of a product of two solutions of `y'' = r·y`:
`(y₁y₂)'' = 2·z₁z₂ + 2·r·y₁y₂`. -/
theorem product_secondDeriv (r y₁ y₂ z₁ z₂ : ℝ → ℝ)
    (hy₁ : ∀ x, HasDerivAt y₁ (z₁ x) x) (hy₂ : ∀ x, HasDerivAt y₂ (z₂ x) x)
    (hz₁ : ∀ x, HasDerivAt z₁ (r x * y₁ x) x) (hz₂ : ∀ x, HasDerivAt z₂ (r x * y₂ x) x)
    (x : ℝ) :
    HasDerivAt (fun t => y₁ t * z₂ t + z₁ t * y₂ t)
      (2 * (z₁ x * z₂ x) + 2 * (r x * (y₁ x * y₂ x))) x := by
  have h := ((hy₁ x).mul (hz₂ x)).add ((hz₁ x).mul (hy₂ x))
  convert h using 1
  ring

/-- **The second symmetric power equation.**  The third derivative of a product
of two solutions of `y'' = r·y` is `4·r·(y₁y₂)' + 2·r'·(y₁y₂)`. -/
theorem product_thirdDeriv (r r' y₁ y₂ z₁ z₂ : ℝ → ℝ)
    (hy₁ : ∀ x, HasDerivAt y₁ (z₁ x) x) (hy₂ : ∀ x, HasDerivAt y₂ (z₂ x) x)
    (hz₁ : ∀ x, HasDerivAt z₁ (r x * y₁ x) x) (hz₂ : ∀ x, HasDerivAt z₂ (r x * y₂ x) x)
    (hr : ∀ x, HasDerivAt r (r' x) x) (x : ℝ) :
    HasDerivAt (fun t => 2 * (z₁ t * z₂ t) + 2 * (r t * (y₁ t * y₂ t)))
      (4 * (r x * (y₁ x * z₂ x + z₁ x * y₂ x)) + 2 * (r' x * (y₁ x * y₂ x))) x := by
  have hA : HasDerivAt (fun t => z₁ t * z₂ t)
      (r x * y₁ x * z₂ x + z₁ x * (r x * y₂ x)) x := (hz₁ x).mul (hz₂ x)
  have hB : HasDerivAt (fun t => y₁ t * y₂ t) (y₁ x * z₂ x + z₁ x * y₂ x) x :=
    product_hasDerivAt y₁ y₂ z₁ z₂ hy₁ hy₂ x
  have hC : HasDerivAt (fun t => r t * (y₁ t * y₂ t))
      (r' x * (y₁ x * y₂ x) + r x * (y₁ x * z₂ x + z₁ x * y₂ x)) x := (hr x).mul hB
  have h := (hA.const_mul (2 : ℝ)).add (hC.const_mul (2 : ℝ))
  convert h using 1
  ring

/-! ## 4. Derivatives of a rational function -/

variable (P Q : ℝ[X])

/-- `(P/Q)' = W/Q²`. -/
theorem hasDerivAt_ratFunc₁ (hQ : ∀ x : ℝ, Q.eval x ≠ 0) (x : ℝ) :
    HasDerivAt (fun t => P.eval t / Q.eval t)
      ((wronskianNum P Q).eval x / (Q.eval x) ^ 2) x := by
  have hPderiv : HasDerivAt (fun t => P.eval t) (P.derivative.eval x) x := by
    have hdiff : DifferentiableAt ℝ (fun t => P.eval t) x := Polynomial.differentiableAt P
    have hderiv : deriv (fun t => P.eval t) x = P.derivative.eval x := by simp [Polynomial.deriv]
    rw [← hderiv]
    exact hdiff.hasDerivAt
  have hQderiv : HasDerivAt (fun t => Q.eval t) (Q.derivative.eval x) x := by
    have hdiff : DifferentiableAt ℝ (fun t => Q.eval t) x := Polynomial.differentiableAt Q
    have hderiv : deriv (fun t => Q.eval t) x = Q.derivative.eval x := by simp [Polynomial.deriv]
    rw [← hderiv]
    exact hdiff.hasDerivAt
  have hne : Q.eval x ≠ 0 := hQ x
  have hquot := hPderiv.div hQderiv hne
  convert hquot using 1
  simp only [wronskianNum]
  field_simp
  simp [Polynomial.eval_sub, Polynomial.eval_mul]
  ring_nf

/-- `(W/Q²)' = secondNum/Q³`. -/
theorem hasDerivAt_ratFunc₂ (hQ : ∀ x : ℝ, Q.eval x ≠ 0) (x : ℝ) :
    HasDerivAt (fun t => (wronskianNum P Q).eval t / (Q.eval t) ^ 2)
      ((secondNum P Q).eval x / (Q.eval x) ^ 3) x := by
  have hQx : Q.eval x ≠ 0 := hQ x
  have h1 : HasDerivAt (fun t => (wronskianNum P Q).eval t) (Polynomial.eval x (derivative (wronskianNum P Q))) x := by
    have hdiff : DifferentiableAt ℝ (fun t => (wronskianNum P Q).eval t) x := Polynomial.differentiableAt (p := wronskianNum P Q)
    have hderiv : deriv (fun t => (wronskianNum P Q).eval t) x = Polynomial.eval x (derivative (wronskianNum P Q)) := by
      simp [Polynomial.deriv]
    rw [← hderiv]
    exact hdiff.hasDerivAt
  have h2 : HasDerivAt (fun t => Q.eval t ^ 2) (2 * Q.eval x * (derivative Q).eval x) x := by
    have hdiff : DifferentiableAt ℝ (fun t => Q.eval t) x := Polynomial.differentiableAt (p := Q)
    have hderiv : deriv (fun t => Q.eval t) x = (derivative Q).eval x := by simp [Polynomial.deriv]
    have := hdiff.hasDerivAt.pow 2
    convert this using 1
    rw [hderiv]
    ring
  have h3 : HasDerivAt (fun t => (wronskianNum P Q).eval t / (Q.eval t) ^ 2)
      (((derivative (wronskianNum P Q)).eval x * Q.eval x ^ 2 -
        (wronskianNum P Q).eval x * (2 * Q.eval x * (derivative Q).eval x)) / Q.eval x ^ 4) x := by
    have := h1.div h2 (pow_ne_zero 2 hQx)
    convert this using 2
    ring
  convert h3 using 1
  simp only [secondNum]
  field_simp [hQx]
  ring_nf
  simp
  ring

/-- `(secondNum/Q³)' = thirdNum/Q⁴`. -/
theorem hasDerivAt_ratFunc₃ (hQ : ∀ x : ℝ, Q.eval x ≠ 0) (x : ℝ) :
    HasDerivAt (fun t => (secondNum P Q).eval t / (Q.eval t) ^ 3)
      ((thirdNum P Q).eval x / (Q.eval x) ^ 4) x := by
  have hQx : Q.eval x ≠ 0 := hQ x
  have h1 : HasDerivAt (fun t => (secondNum P Q).eval t) (Polynomial.eval x (derivative (secondNum P Q))) x := by
    have hdiff : DifferentiableAt ℝ (fun t => (secondNum P Q).eval t) x := Polynomial.differentiableAt (p := secondNum P Q)
    have hderiv : deriv (fun t => (secondNum P Q).eval t) x = Polynomial.eval x (derivative (secondNum P Q)) := by
      simp [Polynomial.deriv]
    rw [← hderiv]
    exact hdiff.hasDerivAt
  have h2 : HasDerivAt (fun t => Q.eval t ^ 3) (3 * Q.eval x ^ 2 * (derivative Q).eval x) x := by
    have hdiff : DifferentiableAt ℝ (fun t => Q.eval t) x := Polynomial.differentiableAt (p := Q)
    have hderiv : deriv (fun t => Q.eval t) x = (derivative Q).eval x := by simp [Polynomial.deriv]
    have := hdiff.hasDerivAt.pow 3
    convert this using 1
    rw [hderiv]
    ring
  have h3 : HasDerivAt (fun t => (secondNum P Q).eval t / (Q.eval t) ^ 3)
      (((derivative (secondNum P Q)).eval x * Q.eval x ^ 3 -
        (secondNum P Q).eval x * (3 * Q.eval x ^ 2 * (derivative Q).eval x)) / Q.eval x ^ 6) x := by
    have := h1.div h2 (pow_ne_zero 3 hQx)
    convert this using 2
    ring
  convert h3 using 1
  simp only [secondNum, thirdNum]
  field_simp [hQx]
  ring_nf
  simp [Polynomial.derivative_mul, Polynomial.derivative_sub, Polynomial.derivative_C]
  ring

/-- Clearing denominators in the symmetric-square equation for `v = P/Q`. -/
theorem symSquare_polynomial_of_pointwise (hQ : ∀ x : ℝ, Q.eval x ≠ 0)
    (h : ∀ x : ℝ, (thirdNum P Q).eval x / (Q.eval x) ^ 4
      = 4 * (x * ((wronskianNum P Q).eval x / (Q.eval x) ^ 2))
        + 2 * (P.eval x / Q.eval x)) :
    thirdNum P Q = rhsPoly P Q := by
  refine Polynomial.funext fun x => ?_
  have hx := h x
  have hQx := hQ x
  field_simp at hx
  simp only [rhsPoly, Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C,
    Polynomial.eval_X, Polynomial.eval_pow]
  linear_combination hx

end Analytic

/-! ## 5. The capstone -/

/-- **Airy's equation has no product of solutions that is a nonzero rational
function.**

If `y₁, y₂` solve `y'' = x·y` and their product equals the rational function
`P/Q` (with `P ≠ 0` and `Q` nowhere vanishing), we obtain a contradiction.  This
is the failure of Kovacic's second case for Airy's equation. -/
theorem airy_product_not_rational (y₁ y₂ z₁ z₂ : ℝ → ℝ)
    (hy₁ : ∀ x, HasDerivAt y₁ (z₁ x) x) (hy₂ : ∀ x, HasDerivAt y₂ (z₂ x) x)
    (hz₁ : ∀ x, HasDerivAt z₁ (x * y₁ x) x) (hz₂ : ∀ x, HasDerivAt z₂ (x * y₂ x) x)
    (P Q : ℝ[X]) (hP : P ≠ 0) (hQ : ∀ x : ℝ, Q.eval x ≠ 0)
    (hPQ : ∀ x : ℝ, y₁ x * y₂ x = P.eval x / Q.eval x) : False := by
  have hQ0 : Q ≠ 0 := fun h => hQ 0 (by simp [h])
  have hv : (fun t => y₁ t * y₂ t) = fun t => P.eval t / Q.eval t := funext hPQ
  -- first derivative
  have d1 : ∀ x, HasDerivAt (fun t => y₁ t * y₂ t) (y₁ x * z₂ x + z₁ x * y₂ x) x :=
    product_hasDerivAt y₁ y₂ z₁ z₂ hy₁ hy₂
  have d1' : ∀ x, HasDerivAt (fun t => y₁ t * y₂ t)
      ((wronskianNum P Q).eval x / (Q.eval x) ^ 2) x := by
    intro x; rw [hv]; exact hasDerivAt_ratFunc₁ P Q hQ x
  have e1 : ∀ x, y₁ x * z₂ x + z₁ x * y₂ x = (wronskianNum P Q).eval x / (Q.eval x) ^ 2 :=
    fun x => (d1 x).unique (d1' x)
  have f1 : (fun t => y₁ t * z₂ t + z₁ t * y₂ t)
      = fun t => (wronskianNum P Q).eval t / (Q.eval t) ^ 2 := funext e1
  -- second derivative
  have d2 : ∀ x, HasDerivAt (fun t => y₁ t * z₂ t + z₁ t * y₂ t)
      (2 * (z₁ x * z₂ x) + 2 * (x * (y₁ x * y₂ x))) x :=
    fun x => product_secondDeriv (fun t => t) y₁ y₂ z₁ z₂ hy₁ hy₂ hz₁ hz₂ x
  have d2' : ∀ x, HasDerivAt (fun t => y₁ t * z₂ t + z₁ t * y₂ t)
      ((secondNum P Q).eval x / (Q.eval x) ^ 3) x := by
    intro x; rw [f1]; exact hasDerivAt_ratFunc₂ P Q hQ x
  have e2 : ∀ x, 2 * (z₁ x * z₂ x) + 2 * (x * (y₁ x * y₂ x))
      = (secondNum P Q).eval x / (Q.eval x) ^ 3 := fun x => (d2 x).unique (d2' x)
  have f2 : (fun t => 2 * (z₁ t * z₂ t) + 2 * (t * (y₁ t * y₂ t)))
      = fun t => (secondNum P Q).eval t / (Q.eval t) ^ 3 := funext e2
  -- third derivative: the second symmetric power equation
  have d3 : ∀ x, HasDerivAt (fun t => 2 * (z₁ t * z₂ t) + 2 * (t * (y₁ t * y₂ t)))
      (4 * (x * (y₁ x * z₂ x + z₁ x * y₂ x)) + 2 * (1 * (y₁ x * y₂ x))) x :=
    fun x => product_thirdDeriv (fun t => t) (fun _ => 1) y₁ y₂ z₁ z₂ hy₁ hy₂ hz₁ hz₂
      (fun t => hasDerivAt_id t) x
  have d3' : ∀ x, HasDerivAt (fun t => 2 * (z₁ t * z₂ t) + 2 * (t * (y₁ t * y₂ t)))
      ((thirdNum P Q).eval x / (Q.eval x) ^ 4) x := by
    intro x; rw [f2]; exact hasDerivAt_ratFunc₃ P Q hQ x
  have e3 : ∀ x, 4 * (x * (y₁ x * z₂ x + z₁ x * y₂ x)) + 2 * (1 * (y₁ x * y₂ x))
      = (thirdNum P Q).eval x / (Q.eval x) ^ 4 := fun x => (d3 x).unique (d3' x)
  have key : ∀ x : ℝ, (thirdNum P Q).eval x / (Q.eval x) ^ 4
      = 4 * (x * ((wronskianNum P Q).eval x / (Q.eval x) ^ 2))
        + 2 * (P.eval x / Q.eval x) := by
    intro x
    rw [← e3 x, ← e1 x, ← hPQ x]
    ring
  exact airy_symSquare_no_rational P Q hP hQ0 (symSquare_polynomial_of_pointwise P Q hQ key)

end AiryCaseTwo