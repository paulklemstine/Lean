/-
Copyright (c) 2026. All rights reserved.

# The Polynomial Method for Cap Sets

This file develops the polynomial method infrastructure for bounding the size of
progression-free subsets of 𝔽₃ⁿ.

## Key Results

* Indicator polynomial construction and evaluation properties
* Fermat's Little Theorem in ZMod 3
* Kronecker delta function via `1 - (a-b)²`
* Reduced polynomial representation theorem
* Linear independence of reduced monomial evaluations
* Small-case cap set bounds

## Mathematical Context

In `𝔽₃ⁿ`, every function `f : 𝔽₃ⁿ → 𝔽₃` can be uniquely expressed as a polynomial
where each variable has degree at most 2 (since `x³ = x` in `𝔽₃`). This gives
a bijection between functions and "reduced" polynomials, with the space of reduced
polynomials having dimension `3ⁿ` (matching `|𝔽₃ⁿ|`).
-/

import Mathlib
import Algebra.CapSets.Defs

open Finset BigOperators MvPolynomial

namespace CapSet

/-! ## Fermat's Little Theorem in ZMod 3 -/

/-- In `ZMod 3`, we have `a ^ 3 = a` for all `a`. -/
theorem ZMod3.pow_three (a : ZMod 3) : a ^ 3 = a := by
  fin_cases a <;> decide

/-- In `ZMod 3`, `1 - (a - b)^2 = 0` when `a ≠ b` and `= 1` when `a = b`.
This is the Kronecker delta function in `ZMod 3`. -/
theorem ZMod3.one_sub_sq_diff_eq_delta (a b : ZMod 3) :
    1 - (a - b) ^ 2 = if a = b then 1 else 0 := by
  fin_cases a <;> fin_cases b <;> decide

/-! ## Cardinality of F3Vec -/

/-- The cardinality of `𝔽₃ⁿ` is `3^n`. -/
theorem card_F3Vec (n : ℕ) : Fintype.card (F3Vec n) = 3 ^ n := by
  simp [F3Vec, Fintype.card_fin, ZMod.card]

/-! ## The Indicator Polynomial -/

/-- The "delta" polynomial at coordinate `i`: evaluates to `1` if `xᵢ = aᵢ` and `0` otherwise.
In `𝔽₃`, this is `1 - (xᵢ - aᵢ)²`. -/
noncomputable def deltaCoordPoly {n : ℕ} (a : F3Vec n) (i : Fin n) :
    MvPolynomial (Fin n) (ZMod 3) :=
  1 - (MvPolynomial.X i - MvPolynomial.C (a i)) ^ 2

/-- The indicator polynomial for point `a ∈ 𝔽₃ⁿ`: the product of delta polynomials
over all coordinates. Evaluates to `1` at `a` and `0` at any other point. -/
noncomputable def indicatorPoly {n : ℕ} (a : F3Vec n) :
    MvPolynomial (Fin n) (ZMod 3) :=
  ∏ i : Fin n, deltaCoordPoly a i

/-- Evaluation of the delta coordinate polynomial. -/
theorem deltaCoordPoly_eval {n : ℕ} (a x : F3Vec n) (i : Fin n) :
    MvPolynomial.eval x (deltaCoordPoly a i) = if x i = a i then 1 else 0 := by
  convert ZMod3.one_sub_sq_diff_eq_delta (x i) (a i) using 1
  simp [deltaCoordPoly]

/-- The indicator polynomial evaluates to 1 at its target point. -/
theorem indicatorPoly_eval_self {n : ℕ} (a : F3Vec n) :
    MvPolynomial.eval a (indicatorPoly a) = 1 := by
  unfold indicatorPoly
  have h_delta : ∀ i : Fin n, (MvPolynomial.eval a (deltaCoordPoly a i)) = 1 :=
    fun i => deltaCoordPoly_eval a a i ▸ if_pos rfl
  rw [map_prod, Finset.prod_eq_one]; aesop

/-- The indicator polynomial evaluates to 0 at any other point. -/
theorem indicatorPoly_eval_ne {n : ℕ} (a b : F3Vec n) (hab : a ≠ b) :
    MvPolynomial.eval a (indicatorPoly b) = 0 := by
  unfold indicatorPoly
  simp +decide only [eval_prod]
  exact Finset.prod_eq_zero (Finset.mem_univ (Classical.choose (Function.ne_iff.mp hab)))
    (by rw [deltaCoordPoly_eval]
        simpa using Classical.choose_spec (Function.ne_iff.mp hab))

/-- Combined evaluation property: the indicator polynomial is the Kronecker delta. -/
theorem indicatorPoly_eval {n : ℕ} (a b : F3Vec n) :
    MvPolynomial.eval a (indicatorPoly b) = if a = b then 1 else 0 := by
  split_ifs <;> simp_all +decide [indicatorPoly_eval_self, indicatorPoly_eval_ne]

/-! ## Reduced Polynomials -/

/-- A polynomial is **reduced** if every exponent in its support has all coordinates < 3.
This is the key structural property exploited by the polynomial method.
Equivalently, `P ∈ MvPolynomial.restrictDegree (Fin n) (ZMod 3) 2`. -/
def IsReduced {n : ℕ} (P : MvPolynomial (Fin n) (ZMod 3)) : Prop :=
  ∀ d ∈ P.support, ∀ i : Fin n, d i < 3

/-- `IsReduced` is equivalent to membership in `restrictDegree`. -/
theorem isReduced_iff_mem_restrictDegree {n : ℕ}
    (P : MvPolynomial (Fin n) (ZMod 3)) :
    IsReduced P ↔ P ∈ MvPolynomial.restrictDegree (Fin n) (ZMod 3) 2 := by
  simp [IsReduced, MvPolynomial.mem_restrictDegree]
  constructor
  · intro h d hd i; exact Nat.lt_succ_iff.mp (h d hd i)
  · intro h d hd i; exact Nat.lt_of_le_of_lt (h d hd i) (by norm_num)

/-
The delta coordinate polynomial is in `restrictDegree 2`.
-/
theorem deltaCoordPoly_mem_restrictDegree {n : ℕ} (a : F3Vec n) (i : Fin n) :
    deltaCoordPoly a i ∈ MvPolynomial.restrictDegree (Fin n) (ZMod 3) 2 := by
      intro d hd;
      have h_deg : (deltaCoordPoly a i).totalDegree ≤ 2 := by
        refine' le_trans ( MvPolynomial.totalDegree_sub _ _ ) _ ; norm_num [ MvPolynomial.totalDegree_pow ];
        refine' le_trans ( MvPolynomial.totalDegree_pow _ _ ) _;
        refine' le_trans ( mul_le_mul_of_nonneg_left ( MvPolynomial.totalDegree_sub _ _ ) zero_le_two ) _ ; norm_num;
      rw [ MvPolynomial.totalDegree ] at h_deg;
      simp_all +decide [ Finsupp.sum_fintype ];
      exact fun j => le_trans ( Finset.single_le_sum ( fun i _ => Nat.zero_le ( d i ) ) ( Finset.mem_univ j ) ) ( h_deg d hd )

/-
The indicator polynomial is reduced.
-/
theorem indicatorPoly_isReduced {n : ℕ} (a : F3Vec n) :
    IsReduced (indicatorPoly a) := by
      -- By definition of IsReduced, we need to show that every exponent in the support of the indicator polynomial has all coordinates less than 3.
      intro d hd
      simp [indicatorPoly] at hd;
      -- By definition of `deltaCoordPoly`, each term in the product is of the form `1 - (X i - C (a i))^2`.
      -- The degree of each term is 2 in the variable `X i`, and 0 in all other variables.
      have h_deg : ∀ i, ∀ d ∈ (deltaCoordPoly a i).support, ∀ j, d j ≤ if j = i then 2 else 0 := by
        unfold deltaCoordPoly; contrapose! hd; simp_all +decide [ deltaCoordPoly ] ;
        obtain ⟨ i, d, hd, j, hj ⟩ := hd; simp_all +decide [ MvPolynomial.coeff_one, MvPolynomial.coeff_X', sub_sq, mul_assoc, Finset.prod_ite, Finset.filter_ne', Finset.filter_eq' ] ;
        erw [ MvPolynomial.coeff_X_pow, MvPolynomial.coeff_C_mul, MvPolynomial.coeff_mul ] at hd ; simp_all +decide [ MvPolynomial.coeff_X', MvPolynomial.coeff_C ];
        split_ifs at hd <;> simp_all +decide [ MvPolynomial.coeff_C, pow_two ];
        · aesop;
        · aesop;
        · grind;
        · rw [ Finset.sum_eq_zero ] at hd <;> aesop;
      -- By definition of polynomial multiplication, the exponent of each term in the product is the sum of the exponents of the corresponding terms in the factors.
      have h_exp : ∀ d ∈ (∏ i, deltaCoordPoly a i).support, ∀ j, d j ≤ ∑ i, (if j = i then 2 else 0) := by
        intro d hd j;
        have h_exp : ∀ {S : Finset (Fin n)}, ∀ d ∈ (∏ i ∈ S, deltaCoordPoly a i).support, ∀ j, d j ≤ ∑ i ∈ S, (if j = i then 2 else 0) := by
          intros S d hd j;
          induction' S using Finset.induction with i S hiS ih generalizing d <;> simp_all +decide [ Finset.prod_insert, Finset.sum_insert ];
          · rw [ MvPolynomial.coeff_one ] at hd ; aesop;
          · rw [ MvPolynomial.coeff_mul ] at hd;
            obtain ⟨ x, hx ⟩ := Finset.exists_ne_zero_of_sum_ne_zero hd;
            simp_all +decide [ Finsupp.ext_iff, Finset.mem_antidiagonal ];
            grind;
        exact h_exp d hd j;
      intro i; specialize h_exp d ( by simpa [ MvPolynomial.coeff_zero ] using hd ) i; simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ] ;
      linarith

/-- The interpolation polynomial for a function `f` on `𝔽₃ⁿ`. -/
noncomputable def interpolationPoly {n : ℕ} (f : F3Vec n → ZMod 3) :
    MvPolynomial (Fin n) (ZMod 3) :=
  ∑ a : F3Vec n, MvPolynomial.C (f a) * indicatorPoly a

/-
The interpolation polynomial evaluates correctly.
-/
theorem interpolationPoly_eval {n : ℕ} (f : F3Vec n → ZMod 3) (x : F3Vec n) :
    MvPolynomial.eval x (interpolationPoly f) = f x := by
      unfold interpolationPoly
      simp [indicatorPoly_eval]

/-
The interpolation polynomial is reduced.
-/
theorem interpolationPoly_isReduced {n : ℕ} (f : F3Vec n → ZMod 3) :
    IsReduced (interpolationPoly f) := by
      -- By definition of `interpolationPoly`, it is a sum of products of `indicatorPoly` with constants.
      have h_sum : interpolationPoly f = ∑ a : F3Vec n, MvPolynomial.C (f a) * indicatorPoly a := by
        rfl;
      rw [ h_sum, isReduced_iff_mem_restrictDegree ];
      -- Each term in the sum is of the form $C(f a) * \text{indicatorPoly } a$, which is in `restrictDegree` since $\text{indicatorPoly } a$ is in `restrictDegree`.
      have h_term : ∀ a : F3Vec n, MvPolynomial.C (f a) * indicatorPoly a ∈ restrictDegree (Fin n) (ZMod 3) 2 := by
        intro a;
        convert Submodule.smul_mem _ ( f a ) ( isReduced_iff_mem_restrictDegree ( indicatorPoly a ) |>.1 ( indicatorPoly_isReduced a ) ) using 1;
        rw [ MvPolynomial.C_mul' ];
      exact Submodule.sum_mem _ fun a _ => h_term a

/-- Every function `𝔽₃ⁿ → 𝔽₃` can be represented by a reduced polynomial.
This is the interpolation half of the reduced-polynomial correspondence. -/
theorem exists_reduced_poly_rep {n : ℕ} (f : F3Vec n → ZMod 3) :
    ∃ P : MvPolynomial (Fin n) (ZMod 3),
      IsReduced P ∧ ∀ x : F3Vec n, MvPolynomial.eval x P = f x :=
  ⟨interpolationPoly f, interpolationPoly_isReduced f, interpolationPoly_eval f⟩

/-- Evaluation of reduced polynomials is injective: if two reduced polynomials agree
on all of `𝔽₃ⁿ`, they are equal. -/
theorem reduced_poly_eval_injective {n : ℕ}
    (P Q : MvPolynomial (Fin n) (ZMod 3))
    (hP : IsReduced P) (hQ : IsReduced Q)
    (h : ∀ x : F3Vec n, MvPolynomial.eval x P = MvPolynomial.eval x Q) :
    P = Q := by
  have h_poly_zero : ∀ (R : MvPolynomial (Fin n) (ZMod 3)),
      IsReduced R → (∀ x : F3Vec n, MvPolynomial.eval x R = 0) → R = 0 := by
    intro R hR hR_zero
    apply MvPolynomial.eq_zero_of_eval_eq_zero
    · exact hR_zero
    · intro d hd; specialize hR d hd
      simp_all +decide [MvPolynomial.totalDegree]
      exact fun i => Nat.le_of_lt_succ (hR i)
  refine sub_eq_zero.mp (h_poly_zero (P - Q) ?_ ?_)
  · intro d hd
    simp_all +decide [IsReduced]
    grind +splitImp
  · simp +decide [h]

/-! ## Small Case Verification -/

/-- In dimension 1, a cap set has at most 2 elements. -/
theorem capset_dim1_bound {A : Finset (F3Vec 1)} (hA : IsCapSet A) :
    A.card ≤ 2 := by
  by_contra h_contra
  have hA_univ : A = Finset.univ :=
    Finset.eq_of_subset_of_card_le (Finset.subset_univ A) (by norm_num; linarith)
  simp_all +decide [IsCapSet]
  simp_all +decide [ThreeAPFree]

end CapSet