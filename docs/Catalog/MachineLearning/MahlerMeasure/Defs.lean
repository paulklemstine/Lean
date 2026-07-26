/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Mahler Measure for Integer Polynomials: Definitions and Root Factorization

This file defines the logarithmic Mahler measure for integer polynomials and proves
the root-factorization formula, which expresses the logarithmic Mahler measure as
a sum of `max(0, log |α|)` over the complex roots.

## Main definitions

- `logMahlerMeasureInt P`: the logarithmic Mahler measure of `P : ℤ[X]`, defined as
  the logarithmic Mahler measure of its complexification.

## Main results

- `logMahlerMeasureInt_eq_sum_roots`: for a monic integer polynomial, the logarithmic
  Mahler measure equals the sum of `max(0, log ‖z‖)` over its complex roots (with multiplicity).
- `logMahlerMeasureInt_nonneg`: for a monic nonzero integer polynomial, the logarithmic
  Mahler measure is nonneg.
- `logMahlerMeasureInt_pos_of_exists_root_norm_gt_one`: if a monic integer polynomial
  has a root outside the unit circle, its logarithmic Mahler measure is strictly positive.
- `logMahlerMeasureInt_eq_zero_iff_all_roots_norm_le_one`: for a monic nonzero integer
  polynomial, the logarithmic Mahler measure is zero iff all roots have norm ≤ 1.

These results build on Mathlib's `Polynomial.logMahlerMeasure` and
`Polynomial.logMahlerMeasure_eq_log_leadingCoeff_add_sum_log_roots`.
-/

open Polynomial Real Complex

noncomputable section

/-- The logarithmic Mahler measure of an integer polynomial, defined as the logarithmic
Mahler measure of its complexification. -/
noncomputable def logMahlerMeasureInt (P : Polynomial ℤ) : ℝ :=
  (P.map (Int.castRingHom ℂ)).logMahlerMeasure

/-- The (exponential) Mahler measure of an integer polynomial. -/
noncomputable def mahlerMeasureInt (P : Polynomial ℤ) : ℝ :=
  (P.map (Int.castRingHom ℂ)).mahlerMeasure

theorem mahlerMeasureInt_def (P : Polynomial ℤ) :
    mahlerMeasureInt P = (P.map (Int.castRingHom ℂ)).mahlerMeasure := rfl

theorem logMahlerMeasureInt_def (P : Polynomial ℤ) :
    logMahlerMeasureInt P = (P.map (Int.castRingHom ℂ)).logMahlerMeasure := rfl

/-! ### Root factorization formula -/

/-
For a monic integer polynomial, the logarithmic Mahler measure equals the sum of
`max(0, log ‖z‖)` over its complex roots, counted with multiplicity. This is the
fundamental root-factorization formula.
-/
theorem logMahlerMeasureInt_eq_sum_roots
    (P : Polynomial ℤ)
    (hmonic : P.Monic) :
    logMahlerMeasureInt P =
      ((P.map (Int.castRingHom ℂ)).roots.map (fun z => max 0 (Real.log ‖z‖))).sum := by
  convert Polynomial.logMahlerMeasure_eq_log_leadingCoeff_add_sum_log_roots ( map ( Int.castRingHom ℂ ) P ) using 1;
  erw [ Polynomial.leadingCoeff_map_of_leadingCoeff_ne_zero ] <;> aesop

/-! ### Basic properties -/

/-
`max 0 (log ‖z‖)` is nonneg for any complex number.
-/
theorem max_zero_log_norm_nonneg (z : ℂ) : 0 ≤ max 0 (Real.log ‖z‖) := by
  exact le_max_left _ _

/-
The sum of `max(0, log ‖z‖)` over any multiset of complex numbers is nonneg.
-/
theorem sum_max_zero_log_norm_nonneg (s : Multiset ℂ) :
    0 ≤ (s.map (fun z => max 0 (Real.log ‖z‖))).sum := by
  -- Apply the fact that the sum of nonnegative terms is nonnegative.
  apply Multiset.sum_nonneg; intro x hx; exact (by
  aesop)

/-
The logarithmic Mahler measure of a monic integer polynomial is nonneg.
-/
theorem logMahlerMeasureInt_nonneg
    (P : Polynomial ℤ)
    (hmonic : P.Monic) :
    0 ≤ logMahlerMeasureInt P := by
  convert sum_max_zero_log_norm_nonneg ( P.map ( Int.castRingHom ℂ ) |> Polynomial.roots );
  convert logMahlerMeasureInt_eq_sum_roots P hmonic

/-
If a monic integer polynomial has a root outside the unit circle, its logarithmic
Mahler measure is strictly positive. This is the entropy-positivity principle:
spectral escape produces measurable complexity.
-/
theorem logMahlerMeasureInt_pos_of_exists_root_norm_gt_one
    (P : Polynomial ℤ)
    (hmonic : P.Monic)
    (hroot : ∃ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots ∧ 1 < ‖z‖) :
    0 < logMahlerMeasureInt P := by
  have h_log_pos : 0 < ∑ z ∈ (P.map (Int.castRingHom ℂ)).roots.toFinset, (max 0 (Real.log ‖z‖)) * Multiset.count z (P.map (Int.castRingHom ℂ)).roots := by
    refine' lt_of_lt_of_le _ ( Finset.single_le_sum ( fun x _ => mul_nonneg ( by positivity ) ( Nat.cast_nonneg _ ) ) ( Multiset.mem_toFinset.mpr hroot.choose_spec.1 ) );
    exact mul_pos ( lt_max_of_lt_right ( Real.log_pos hroot.choose_spec.2 ) ) ( Nat.cast_pos.mpr ( Multiset.count_pos.mpr hroot.choose_spec.1 ) );
  convert h_log_pos using 1;
  convert logMahlerMeasureInt_eq_sum_roots P hmonic using 1;
  rw [ Finset.sum_multiset_map_count ];
  grind

/-
For a monic nonzero integer polynomial, the logarithmic Mahler measure is zero
if and only if all roots have norm at most 1. This gives a clean reduction principle:
the entire Lehmer barrier is encoded in proving a strict positive gap once a root
escapes the unit circle in a non-cyclotomic way.
-/
theorem logMahlerMeasureInt_eq_zero_iff_all_roots_norm_le_one
    (P : Polynomial ℤ)
    (_hP0 : P ≠ 0)
    (hmonic : P.Monic) :
    logMahlerMeasureInt P = 0 ↔
      ∀ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots → ‖z‖ ≤ 1 := by
  constructor;
  · intro hlog z hz;
    contrapose! hlog;
    exact ne_of_gt ( logMahlerMeasureInt_pos_of_exists_root_norm_gt_one P hmonic ⟨ z, hz, hlog ⟩ );
  · intro h;
    rw [ logMahlerMeasureInt_eq_sum_roots P hmonic ];
    rw [ Multiset.map_congr rfl fun x hx => by rw [ max_eq_left ( Real.log_nonpos ( norm_nonneg x ) ( h x hx ) ) ] ] ; aesop

/-
One direction: if logMahlerMeasure = 0 then all roots have norm ≤ 1.
-/
theorem roots_le_one_of_logMahlerMeasureInt_eq_zero
    (P : Polynomial ℤ)
    (hP0 : P ≠ 0)
    (hmonic : P.Monic)
    (hzero : logMahlerMeasureInt P = 0) :
    ∀ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots → ‖z‖ ≤ 1 := by
  convert logMahlerMeasureInt_eq_zero_iff_all_roots_norm_le_one P hP0 hmonic |>.1 hzero using 1

/-! ### Multiplicativity -/

/-
The logarithmic Mahler measure is additive under multiplication of monic integer polynomials.
-/
theorem logMahlerMeasureInt_mul
    (P Q : Polynomial ℤ)
    (hP : P ≠ 0)
    (hQ : Q ≠ 0)
    (_hPm : P.Monic)
    (_hQm : Q.Monic) :
    logMahlerMeasureInt (P * Q) = logMahlerMeasureInt P + logMahlerMeasureInt Q := by
  unfold logMahlerMeasureInt;
  rw [ Polynomial.map_mul, Polynomial.logMahlerMeasure_mul_eq_add_logMahlerMeasure ];
  exact mul_ne_zero ( by simpa [ Polynomial.ext_iff ] using hP ) ( by simpa [ Polynomial.ext_iff ] using hQ )

/-! ### Lehmer's reduction principle -/

/-
The Lehmer reduction principle: for a monic nonzero integer polynomial, either the
logarithmic Mahler measure is zero, or there exists a root with norm strictly greater
than 1. This localizes positivity to explicit spectral escape.
-/
theorem lehmer_reduction_principle
    (P : Polynomial ℤ)
    (hP0 : P ≠ 0)
    (hmonic : P.Monic) :
    logMahlerMeasureInt P = 0 ∨
    ∃ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots ∧ 1 < ‖z‖ := by
  by_contra h_contra;
  -- Apply the contrapositive of the reduction principle to obtain that all roots must have norm ≤ 1.
  have h_roots_le_one : ∀ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots → ‖z‖ ≤ 1 := by
    exact fun z hz => le_of_not_gt fun h => h_contra <| Or.inr ⟨ z, hz, h ⟩;
  exact h_contra <| Or.inl <| logMahlerMeasureInt_eq_zero_iff_all_roots_norm_le_one P hP0 hmonic |>.2 h_roots_le_one

end