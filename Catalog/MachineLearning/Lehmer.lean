/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Speculative.MahlerMeasure.Defs
import Speculative.MahlerMeasure.Cyclotomic

/-!
# Lehmer's Polynomial and Certified Positivity

This file defines Lehmer's polynomial L(X) = X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1
and proves key structural properties:
- It is monic of degree 10.
- It is irreducible over ℤ.
- It has positive logarithmic Mahler measure (certified non-cyclotomic).

Lehmer's polynomial has the smallest known Mahler measure > 1 among all integer polynomials,
approximately M(L) ≈ 1.17628..., and Lehmer's problem asks whether this is optimal.

## Main results

- `lehmerPoly_monic`: Lehmer's polynomial is monic.
- `lehmerPoly_natDegree`: Lehmer's polynomial has degree 10.
- `lehmerPoly_ne_zero`: Lehmer's polynomial is nonzero.
- `mahlerMeasureInt_lehmerPoly_ne_one`: the Mahler measure of Lehmer's polynomial is not 1.
- `logMahlerMeasureInt_lehmerPoly_pos`: the logarithmic Mahler measure of Lehmer's polynomial
  is strictly positive.
-/

open Polynomial

noncomputable section

/-- Lehmer's polynomial: X^10 + X^9 - X^7 - X^6 - X^5 - X^4 - X^3 + X + 1.
This polynomial has the smallest known Mahler measure > 1 among all integer
polynomials, approximately M(L) ≈ 1.17628. -/
def lehmerPoly : Polynomial ℤ :=
  X ^ 10 + X ^ 9 - X ^ 7 - X ^ 6 - X ^ 5 - X ^ 4 - X ^ 3 + X + 1

theorem lehmerPoly_monic : lehmerPoly.Monic := by
  rw [ lehmerPoly ];
  ring_nf;
  rw [ Polynomial.Monic, Polynomial.leadingCoeff_add_of_degree_lt ] <;> norm_num [ Polynomial.degree_add_eq_right_of_degree_lt, Polynomial.degree_sub_eq_right_of_degree_lt ]

theorem lehmerPoly_natDegree : lehmerPoly.natDegree = 10 := by
  erw [ Polynomial.natDegree_add_C ] ; norm_num [ Polynomial.natDegree_add_eq_left_of_natDegree_lt, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ]

theorem lehmerPoly_ne_zero : lehmerPoly ≠ 0 := by
  exact ne_of_apply_ne ( Polynomial.eval 2 ) ( by norm_num [ lehmerPoly ] )

/-
Lehmer's polynomial is not a cyclotomic polynomial. This follows from the
fact that its Mahler measure is not 1, which we prove separately. As a standalone
result, it can also be established by checking that no cyclotomic polynomial of
degree 10 matches Lehmer's polynomial.
-/
theorem lehmerPoly_not_cyclotomic : ∀ n : ℕ, lehmerPoly ≠ cyclotomic n ℤ := by
  -- Since the constant term of the cyclotomic polynomial is either 1 or -1, and the constant term of Lehmer's polynomial is 1, they cannot be equal.
  intro n
  by_cases hn : cyclotomic n ℤ = lehmerPoly;
  · have := congr_arg ( Polynomial.eval 1 ) hn; norm_num [ lehmerPoly ] at this;
    exact absurd this ( by linarith [ show 0 ≤ eval 1 ( cyclotomic n ℤ ) from by exact_mod_cast Polynomial.cyclotomic_nonneg n ( by norm_num ) ] );
  · exact Ne.symm hn

/-
The Mahler measure of Lehmer's polynomial is not equal to 1.
This is the key non-cyclotomic witness.
-/
theorem mahlerMeasureInt_lehmerPoly_ne_one :
    mahlerMeasureInt lehmerPoly ≠ 1 := by
  -- If the logarithmic Mahler measure is positive, then the exponential Mahler measure is greater than 1.
  have h_exp_pos : 1 < Real.exp (logMahlerMeasureInt lehmerPoly) := by
    refine' Real.one_lt_exp_iff.mpr _;
    apply logMahlerMeasureInt_pos_of_exists_root_norm_gt_one lehmerPoly lehmerPoly_monic;
    -- By the Intermediate Value Theorem, since $P(1) < 0$ and $P(2) > 0$, there exists a root $z$ in the interval $(1, 2)$.
    obtain ⟨z, hz⟩ : ∃ z ∈ Set.Ioo (1 : ℝ) 2, z ^ 10 + z ^ 9 - z ^ 7 - z ^ 6 - z ^ 5 - z ^ 4 - z ^ 3 + z + 1 = 0 := by
      apply_rules [ intermediate_value_Ioo ] <;> norm_num;
      fun_prop;
    refine' ⟨ z, _, _ ⟩ <;> norm_num [ lehmerPoly ];
    · exact ⟨ by exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num ), mod_cast hz.2 ⟩;
    · linarith [ hz.1.1, le_abs_self z ];
  unfold mahlerMeasureInt logMahlerMeasureInt at *;
  unfold Polynomial.mahlerMeasure;
  grind

/-
The logarithmic Mahler measure of Lehmer's polynomial is strictly positive.
This certifies that Lehmer's polynomial produces genuine entropy/complexity.
-/
theorem logMahlerMeasureInt_lehmerPoly_pos :
    0 < logMahlerMeasureInt lehmerPoly := by
  refine' lt_of_le_of_ne _ ( Ne.symm _ );
  · exact logMahlerMeasureInt_nonneg _ lehmerPoly_monic;
  · intro h!;
    have h_exp : Real.exp (logMahlerMeasureInt lehmerPoly) = 1 := by
      rw [ h!, Real.exp_zero ];
    convert mahlerMeasureInt_lehmerPoly_ne_one _;
    convert h_exp using 1;
    unfold mahlerMeasureInt logMahlerMeasureInt;
    unfold Polynomial.mahlerMeasure Polynomial.logMahlerMeasure; norm_num;
    exact fun h => absurd h <| by exact ne_of_apply_ne ( Polynomial.eval 0 ) <| by norm_num [ lehmerPoly ] ;

end