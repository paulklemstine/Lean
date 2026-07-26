/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Reed–Solomon Key Equation: Formal Decoding as Linear Algebra and Vanishing Geometry

This file formalizes the core algebraic machinery behind Reed–Solomon decoding,
centering on the **key equation** that transforms the nonlinear problem of
locating errors into a system of linear constraints on polynomial coefficients.

## Main results

* `errorLocator` — the error-locator polynomial ∏_{i ∈ S} (X - C(a_i))
* `keyEquationHolds` — the predicate Q(a_i) = r(i) · E(a_i) for all i
* `key_equation_pointwise` — the pointwise key equation from an error set
* `polynomial_eq_zero_of_natDegree_lt_and_eval_eq_zero_on_finset` — vanishing rigidity
* `key_equation_unique` — uniqueness of key-equation solutions under decoding bounds
* `decoded_polynomial_unique` — uniqueness of the decoded message polynomial

## Mathematical significance

The key equation recasts error correction as a theorem about low-degree polynomials:
corrupted evaluation data, when multiplied by an appropriate annihilating polynomial,
satisfies a global polynomial identity. The uniqueness theorem shows that under the
classical decoding bound 2t + k ≤ n, any two solutions to the key equation must
satisfy Q₁E₂ = Q₂E₁, yielding unique recovery of the transmitted message.
-/

import Mathlib

open Polynomial Classical

noncomputable section

variable {F : Type*} [Field F]

/-! ## Definitions -/

/-- The error-locator polynomial: the product ∏_{i ∈ S} (X - C(a_i)) over the error set S.
This polynomial vanishes exactly at the evaluation points corresponding to errors. -/
def errorLocator {n : ℕ} (a : Fin n → F) (S : Finset (Fin n)) : F[X] :=
  S.prod (fun i => X - C (a i))

/-- The key equation predicate: Q(a_i) = r(i) · E(a_i) holds at all evaluation points. -/
def keyEquationHolds {n : ℕ} (a : Fin n → F) (r : Fin n → F) (Q E : F[X]) : Prop :=
  ∀ i : Fin n, Polynomial.eval (a i) Q = r i * Polynomial.eval (a i) E

/-- A bundled solution to the key equation with the constraint E ≠ 0. -/
structure KeyEquationSolution {n : ℕ} (a : Fin n → F) (r : Fin n → F) where
  Q : F[X]
  E : F[X]
  hE : E ≠ 0
  hrel : keyEquationHolds a r Q E

/-! ## Evaluation lemmas for the error-locator polynomial -/

/-- Evaluating the error-locator at a_j gives ∏_{i ∈ S} (a_j - a_i). -/
theorem eval_errorLocator {n : ℕ} (a : Fin n → F) (S : Finset (Fin n)) (j : Fin n) :
    Polynomial.eval (a j) (errorLocator a S) = S.prod (fun i => a j - a i) := by
  simp [errorLocator, eval_prod, eval_sub, eval_X, eval_C]

/-- The error-locator vanishes at a_j when j ∈ S. -/
theorem eval_errorLocator_eq_zero_of_mem {n : ℕ} (a : Fin n → F) (S : Finset (Fin n))
    {j : Fin n} (hj : j ∈ S) :
    Polynomial.eval (a j) (errorLocator a S) = 0 := by
  rw [eval_errorLocator]
  exact Finset.prod_eq_zero hj (sub_self _)

/-- The error-locator is nonzero at a_j when j ∉ S and a is injective. -/
theorem eval_errorLocator_ne_zero_of_not_mem {n : ℕ} (a : Fin n → F)
    (ha : Function.Injective a) (S : Finset (Fin n))
    {j : Fin n} (hj : j ∉ S) :
    Polynomial.eval (a j) (errorLocator a S) ≠ 0 := by
  rw [eval_errorLocator]
  exact Finset.prod_ne_zero_iff.mpr (fun i hi =>
    sub_ne_zero.mpr (ha.ne (fun h => hj (h ▸ hi))))

/-! ## Degree bound for the error-locator -/

/-- The natDegree of the error-locator is at most |S|. -/
theorem natDegree_errorLocator_le_card {n : ℕ} (a : Fin n → F) (S : Finset (Fin n)) :
    (errorLocator a S).natDegree ≤ S.card := by
  unfold errorLocator
  calc (S.prod (fun i => X - C (a i))).natDegree
      ≤ S.sum (fun i => (X - C (a i)).natDegree) := natDegree_prod_le S _
    _ = S.sum (fun _ => 1) := by
        congr 1; ext i; simp
    _ = S.card := by simp

/-! ## Theorem 1: Pointwise key equation from an error set -/

/-- **Pointwise key equation.** If p is the transmitted polynomial, r is the received word,
and S is the error set (r agrees with p outside S), then Q = p · E satisfies the
key equation Q(a_i) = r(i) · E(a_i) for all i.

This is the foundational identity that linearizes the error-correction problem:
the nonlinear unknown "which positions are corrupted?" is absorbed into the
polynomial E, and the key equation becomes a linear relation in the coefficients
of Q and E. -/
theorem key_equation_pointwise
    {n k t : ℕ}
    (a : Fin n → F)
    (_ha : Function.Injective a)
    (p : F[X])
    (r : Fin n → F)
    (S : Finset (Fin n))
    (_hdegp : p.natDegree < k)
    (_hS : S.card ≤ t)
    (hr : ∀ i : Fin n, i ∉ S → r i = Polynomial.eval (a i) p) :
    let E : F[X] := S.prod (fun i => X - C (a i))
    let Q : F[X] := p * E
    ∀ i : Fin n, Polynomial.eval (a i) Q = r i * Polynomial.eval (a i) E := by
  intro E Q i
  simp only [Q, eval_mul]
  by_cases hi : i ∈ S
  · have hE : Polynomial.eval (a i) E = 0 := eval_errorLocator_eq_zero_of_mem a S hi
    simp [hE]
  · rw [hr i hi]

/-! ## Theorem 2: Vanishing-on-many-points forces polynomial to be zero -/

/-- **Polynomial vanishing rigidity.** A polynomial with more roots than its degree must be zero.
This is the fundamental tool for the uniqueness argument: if a low-degree polynomial
vanishes on sufficiently many distinct points, it must be the zero polynomial. -/
theorem polynomial_eq_zero_of_natDegree_lt_and_eval_eq_zero_on_finset
    (f : F[X]) (s : Finset F)
    (hs : s.card > f.natDegree)
    (hvan : ∀ x ∈ s, Polynomial.eval x f = 0) :
    f = 0 :=
  Polynomial.eq_zero_of_natDegree_lt_card_of_eval_eq_zero' f s hvan hs

/-! ## Key lemma for uniqueness: the cross-difference vanishes everywhere -/

/-- The image of injective evaluation points as a finset in F. -/
def evalPointsFinset {n : ℕ} (a : Fin n → F) : Finset F :=
  Finset.univ.image a

omit [Field F] in
theorem evalPointsFinset_card {n : ℕ} (a : Fin n → F) (ha : Function.Injective a) :
    (evalPointsFinset a).card = n := by
  unfold evalPointsFinset
  rw [Finset.card_image_of_injective _ ha, Finset.card_univ, Fintype.card_fin]

omit [Field F] in
theorem mem_evalPointsFinset {n : ℕ} (a : Fin n → F) (i : Fin n) :
    a i ∈ evalPointsFinset a := by
  simp [evalPointsFinset]

/-- The cross-difference D = Q₁E₂ - Q₂E₁ vanishes at all evaluation points. -/
theorem cross_diff_eval_eq_zero
    {n : ℕ}
    (a : Fin n → F)
    (r : Fin n → F)
    (Q1 Q2 E1 E2 : F[X])
    (hsol1 : ∀ i : Fin n, Polynomial.eval (a i) Q1 = r i * Polynomial.eval (a i) E1)
    (hsol2 : ∀ i : Fin n, Polynomial.eval (a i) Q2 = r i * Polynomial.eval (a i) E2)
    (i : Fin n) :
    Polynomial.eval (a i) (Q1 * E2 - Q2 * E1) = 0 := by
  simp only [eval_sub, eval_mul, hsol1 i, hsol2 i]
  ring

/-
The natDegree of Q₁E₂ - Q₂E₁ is bounded under the degree constraints.
-/
theorem cross_diff_natDegree_bound
    {k t : ℕ}
    (Q1 Q2 E1 E2 : F[X])
    (hdegQ1 : Q1.natDegree < k + t)
    (hdegQ2 : Q2.natDegree < k + t)
    (hdegE1 : E1.natDegree ≤ t)
    (hdegE2 : E2.natDegree ≤ t) :
    (Q1 * E2 - Q2 * E1).natDegree < k + 2 * t := by
  refine' lt_of_le_of_lt ( Polynomial.natDegree_sub_le _ _ ) _;
  exact max_lt ( lt_of_le_of_lt ( Polynomial.natDegree_mul_le .. ) ( by linarith ) ) ( lt_of_le_of_lt ( Polynomial.natDegree_mul_le .. ) ( by linarith ) )

/-! ## Theorem 3: Uniqueness of the key-equation solution under decoding bounds -/

/-- **Key equation uniqueness.** Given two solutions (Q₁, E₁) and (Q₂, E₂) to the key equation
with the degree bounds deg Q < k + t and deg E ≤ t, under the decoding bound k + 2t ≤ n,
we must have Q₁ · E₂ = Q₂ · E₁. This is the algebraic heart of unique decoding.

The proof proceeds by the "polynomial rigidity" argument:
1. Define D = Q₁E₂ - Q₂E₁.
2. Show D vanishes at all n evaluation points (from the key equation).
3. Bound deg D < k + 2t.
4. Since k + 2t ≤ n, D has more roots than its degree, hence D = 0. -/
theorem key_equation_unique
    {n k t : ℕ}
    (a : Fin n → F)
    (ha : Function.Injective a)
    (r : Fin n → F)
    (Q1 Q2 E1 E2 : F[X])
    (_hE1 : E1 ≠ 0) (_hE2 : E2 ≠ 0)
    (hdegQ1 : Q1.natDegree < k + t)
    (hdegQ2 : Q2.natDegree < k + t)
    (hdegE1 : E1.natDegree ≤ t)
    (hdegE2 : E2.natDegree ≤ t)
    (hbound : k + 2 * t ≤ n)
    (hsol1 : ∀ i : Fin n, Polynomial.eval (a i) Q1 = r i * Polynomial.eval (a i) E1)
    (hsol2 : ∀ i : Fin n, Polynomial.eval (a i) Q2 = r i * Polynomial.eval (a i) E2) :
    Q1 * E2 = Q2 * E1 := by
  set D := Q1 * E2 - Q2 * E1 with hD_def
  have hD_van : ∀ x ∈ evalPointsFinset a, Polynomial.eval x D = 0 := by
    intro x hx
    simp [evalPointsFinset] at hx
    obtain ⟨i, rfl⟩ := hx
    exact cross_diff_eval_eq_zero a r Q1 Q2 E1 E2 hsol1 hsol2 i
  have hD_deg : D.natDegree < (evalPointsFinset a).card := by
    rw [evalPointsFinset_card a ha]
    exact lt_of_lt_of_le
      (cross_diff_natDegree_bound Q1 Q2 E1 E2 hdegQ1 hdegQ2 hdegE1 hdegE2) hbound
  have hD_zero : D = 0 :=
    Polynomial.eq_zero_of_natDegree_lt_card_of_eval_eq_zero' D _ hD_van hD_deg
  exact sub_eq_zero.mp hD_zero

/-! ## Corollary: Decoded polynomial uniqueness -/

/-
**Decoded polynomial uniqueness.** If two key-equation solutions factor as Q₁ = p₁E₁
and Q₂ = p₂E₂ with deg p₁, deg p₂ < k, then under the decoding bound, p₁ = p₂.

This is the operational consequence of key equation uniqueness: the transmitted
message polynomial is uniquely recoverable from any valid key-equation solution.
-/
theorem decoded_polynomial_unique
    {n k t : ℕ}
    (a : Fin n → F)
    (ha : Function.Injective a)
    (r : Fin n → F)
    (Q1 Q2 E1 E2 p1 p2 : F[X])
    (hE1 : E1 ≠ 0) (hE2 : E2 ≠ 0)
    (hdegQ1 : Q1.natDegree < k + t)
    (hdegQ2 : Q2.natDegree < k + t)
    (hdegE1 : E1.natDegree ≤ t)
    (hdegE2 : E2.natDegree ≤ t)
    (hbound : k + 2 * t ≤ n)
    (hsol1 : ∀ i : Fin n, Polynomial.eval (a i) Q1 = r i * Polynomial.eval (a i) E1)
    (hsol2 : ∀ i : Fin n, Polynomial.eval (a i) Q2 = r i * Polynomial.eval (a i) E2)
    (hfact1 : Q1 = p1 * E1) (hfact2 : Q2 = p2 * E2) :
    p1 = p2 := by
  have := key_equation_unique a ha r Q1 Q2 E1 E2 hE1 hE2 hdegQ1 hdegQ2 hdegE1 hdegE2 hbound hsol1 hsol2; simp_all +decide ;
  exact mul_left_cancel₀ ( mul_ne_zero hE1 hE2 ) ( by linear_combination' this )

end