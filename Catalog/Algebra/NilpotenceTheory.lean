/-
Copyright (c) 2025. All rights reserved.

# Nilpotence from Determinant Constraints

## Main Results

* `isNilpotent_of_det_one_add_smul`: Over a characteristic-zero field, if
  `det(I + t · A) = 1` for all scalars `t`, then `A` is nilpotent. This converts
  a nonlinear determinant constraint into a finite linear-algebraic vanishing test.

* `trace_pow_eq_zero_of_det_one_add_smul`: Under the same hypothesis, all
  traces `tr(A^k)` vanish for `k ≥ 1`.

* `charpoly_eq_X_pow_of_det_one_add_smul`: The characteristic polynomial of
  such a matrix equals `X^n`.

* `sq_eq_zero_of_det_one_add_smul_2x2`: Explicit 2×2 specialization.

These results are the algebraic heart of the Jacobian Conjecture reductions:
they show that the Keller condition on cubic homogeneous perturbations of the
identity forces the Jacobian of the perturbation to be nilpotent.

## Keywords
nilpotent Jacobian, Cayley-Hamilton, characteristic polynomial, Newton identities,
Keller condition, cubic homogeneous
-/

import Mathlib

open Matrix Polynomial BigOperators

/-! ### Core nilpotence theorem -/

/-
**Nilpotence from parametric determinant constraint.**

Over a characteristic-zero field, if `det(I + t · A) = 1` for every scalar `t`,
then the matrix `A` is nilpotent.

The proof proceeds by:
1. Observing that `det(I + tA)` is a polynomial in `t` whose coefficients are
   elementary symmetric functions of the eigenvalues of `A`.
2. Since this polynomial equals the constant `1` for infinitely many `t`,
   all non-constant coefficients vanish.
3. By Cayley–Hamilton, `A` satisfies its characteristic polynomial, which
   must be `X^n`, so `A^n = 0`.
-/
set_option maxHeartbeats 400000 in
theorem isNilpotent_of_det_one_add_smul
    {K : Type*} [Field K] [CharZero K]
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) K)
    (hdet : ∀ t : K, det (1 + t • A) = 1) :
    IsNilpotent A := by
  -- The characteristic polynomial of $A$ is $\det(XI - A)$.
  have h_charpoly : Matrix.charpoly A = Polynomial.X ^ n := by
    have h_charpoly_eq : ∀ t : K, t ≠ 0 → Matrix.det (t • (1 : Matrix (Fin n) (Fin n) K) - A) = t ^ n := by
      intro t ht
      have h_det : Matrix.det (t • (1 : Matrix (Fin n) (Fin n) K) - A) = t ^ n * Matrix.det (1 - t⁻¹ • A) := by
        have h_det : Matrix.det (t • (1 : Matrix (Fin n) (Fin n) K) - A) = Matrix.det (t • (1 : Matrix (Fin n) (Fin n) K) * (1 - t⁻¹ • A)) := by
          simp +decide [ mul_sub, smul_sub, ht ];
        simp_all +decide [ Matrix.det_mul, Matrix.det_smul ];
      have := hdet ( -t⁻¹ ) ; simp_all +decide [ sub_eq_add_neg ] ;
    refine' Polynomial.eq_of_infinite_eval_eq _ _ _;
    refine Set.Infinite.mono ?_ ( Set.infinite_univ.diff ( Set.finite_singleton 0 ) );
    intro t ht; specialize h_charpoly_eq t ht.2; simp_all +decide [ Matrix.charpoly, Matrix.det_apply' ] ;
    simp_all +decide [ Polynomial.eval_finset_sum, Polynomial.eval_prod, Matrix.charmatrix, Matrix.one_apply ];
    convert h_charpoly_eq using 4 ; aesop;
  exact ⟨ n, by rw [ ← Matrix.aeval_self_charpoly A, h_charpoly, Polynomial.aeval_X_pow ] ⟩

/-
The characteristic polynomial of a matrix satisfying the parametric determinant
constraint `det(I + tA) = 1` for all `t` is `X^n`.
-/
theorem charpoly_eq_X_pow_of_det_one_add_smul
    {K : Type*} [Field K] [CharZero K]
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) K)
    (hdet : ∀ t : K, det (1 + t • A) = 1) :
    A.charpoly = Polynomial.X ^ n := by
  -- The characteristic polynomial of $A$ is $\det(XI - A)$. We can relate this to the determinant condition.
  have h_charpoly : ∀ t : K, t ≠ 0 → Polynomial.eval t (Matrix.charpoly A) = t ^ n := by
    intro t ht
    have h_det : Matrix.det (1 - t⁻¹ • A) = 1 := by
      convert hdet ( -t⁻¹ ) using 1 ; simp +decide [ ht ];
      rw [ sub_eq_add_neg ];
    -- By definition of characteristic polynomial, we have $\chi_A(t) = \det(tI - A)$.
    have h_charpoly_def : Polynomial.eval t (Matrix.charpoly A) = Matrix.det (t • 1 - A) := by
      simp +decide [ Matrix.charpoly, Matrix.det_apply' ];
      simp +decide [ Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_prod, Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_one, Matrix.one_apply ];
      exact Finset.sum_congr rfl fun _ _ => by congr; ext; aesop;
    rw [ h_charpoly_def, show t • 1 - A = t • ( 1 - t⁻¹ • A ) by ext i j; simp +decide [ ht, mul_sub, smul_sub, sub_smul, mul_assoc, mul_left_comm ], Matrix.det_smul ] ; aesop;
  refine' Polynomial.eq_of_infinite_eval_eq _ _ _;
  exact Set.infinite_of_finite_compl ( Set.Finite.subset ( Set.finite_singleton 0 ) fun x hx => Classical.not_not.1 fun hx' => hx <| by aesop )

/-
**Trace vanishing theorem.**
If `det(I + t · A) = 1` for all `t` in a characteristic-zero field,
then `tr(A^k) = 0` for all positive `k`. This follows from Newton's identities
relating power sums to elementary symmetric polynomials.
-/
set_option maxHeartbeats 800000 in
theorem trace_pow_eq_zero_of_det_one_add_smul
    {K : Type*} [Field K] [CharZero K]
    {n : ℕ}
    (A : Matrix (Fin n) (Fin n) K)
    (hdet : ∀ t : K, det (1 + t • A) = 1)
    (k : ℕ) (hk : 0 < k) :
    (A ^ k).trace = 0 := by
  have h_charpoly : A.charpoly = Polynomial.X ^ n := by
    convert charpoly_eq_X_pow_of_det_one_add_smul A hdet;
  -- Since $A$ is nilpotent, we have $A^n = 0$.
  have h_nilpotent : A ^ n = 0 := by
    rw [ ← Matrix.aeval_self_charpoly A, h_charpoly, Polynomial.aeval_X_pow ];
  -- Since $A$ is nilpotent, we have $(A^k)^m = 0$ for some $m$.
  obtain ⟨m, hm⟩ : ∃ m : ℕ, (A ^ k) ^ m = 0 := by
    exact ⟨ n, by rw [ ← pow_mul, mul_comm, pow_mul, h_nilpotent, zero_pow ( by positivity ) ] ⟩;
  -- Since $A$ is nilpotent, we have $(A^k)^m = 0$ for some $m$. This implies that the trace of $(A^k)^m$ is zero.
  have h_trace_zero : ∀ (B : Matrix (Fin n) (Fin n) K), B ^ m = 0 → Matrix.trace B = 0 := by
    intro B hB
    have h_charpoly_B : B.charpoly = Polynomial.X ^ n := by
      have h_charpoly_B : B.charpoly = Polynomial.X ^ n := by
        have h_eigenvalues : ∀ (μ : AlgebraicClosure K), Polynomial.eval μ (Polynomial.map (algebraMap K (AlgebraicClosure K)) B.charpoly) = 0 → μ = 0 := by
          intro μ hμ
          have h_eigenvalue : ∃ v : Fin n → AlgebraicClosure K, v ≠ 0 ∧ Matrix.mulVec (Matrix.map B (algebraMap K (AlgebraicClosure K))) v = μ • v := by
            have h_eigenvalue : Matrix.det (Matrix.map B (algebraMap K (AlgebraicClosure K)) - Matrix.scalar (Fin n) μ) = 0 := by
              rw [ Matrix.det_eq_sign_charpoly_coeff ];
              simp_all +decide [ Matrix.charpoly, Matrix.det_apply' ];
              convert hμ using 3 ; simp +decide [ Polynomial.coeff_zero_eq_eval_zero, Polynomial.eval_prod ];
              exact Finset.prod_congr rfl fun i _ => by by_cases hi : ‹Equiv.Perm ( Fin n ) › i = i <;> simp +decide [ hi ] ;
            have := Matrix.exists_mulVec_eq_zero_iff.mpr h_eigenvalue;
            simp_all +decide [ sub_eq_iff_eq_add, Matrix.sub_mulVec ];
          obtain ⟨ v, hv_ne_zero, hv_eigenvalue ⟩ := h_eigenvalue
          have h_eigenvalue_pow : ∀ (i : ℕ), Matrix.mulVec (Matrix.map (B ^ i) (algebraMap K (AlgebraicClosure K))) v = μ ^ i • v := by
            intro i; induction i <;> simp_all +decide [ pow_succ', Matrix.mulVec_smul ] ;
            simp_all +decide [ ← Matrix.mulVec_mulVec, mul_assoc ];
            rw [ Matrix.mulVec_smul, hv_eigenvalue, smul_smul, mul_comm ];
          specialize h_eigenvalue_pow m; simp_all +decide [ funext_iff, Matrix.mulVec ] ;
          exact Or.resolve_right ( h_eigenvalue_pow hv_ne_zero.choose ) hv_ne_zero.choose_spec |>.1
        have h_charpoly_B : Polynomial.map (algebraMap K (AlgebraicClosure K)) B.charpoly = Polynomial.X ^ n := by
          have h_charpoly_B : Polynomial.map (algebraMap K (AlgebraicClosure K)) B.charpoly = Polynomial.C 1 * Multiset.prod (Multiset.map (fun μ => Polynomial.X - Polynomial.C μ) (Polynomial.roots (Polynomial.map (algebraMap K (AlgebraicClosure K)) B.charpoly))) := by
            convert Polynomial.Splits.eq_prod_roots _;
            · simp +decide [ Matrix.charpoly_monic ];
            · exact IsAlgClosed.splits _;
          rw [ h_charpoly_B ];
          rw [ Multiset.eq_replicate_of_mem fun μ hμ => h_eigenvalues μ <| Polynomial.isRoot_of_mem_roots hμ ] ; norm_num;
          replace h_charpoly_B := congr_arg Polynomial.natDegree h_charpoly_B; simp_all +decide [ Polynomial.natDegree_map ] ;
        exact Polynomial.map_injective ( algebraMap K ( AlgebraicClosure K ) ) ( algebraMap K ( AlgebraicClosure K ) ).injective <| by simpa using h_charpoly_B;
      exact h_charpoly_B;
    rcases n with ( _ | n ) <;> simp_all +decide [ Matrix.trace_eq_neg_charpoly_coeff ];
  exact h_trace_zero _ hm

/-! ### 2×2 specialization -/

/-
For 2×2 matrices: trace zero and determinant zero implies nilpotent.
-/
theorem Matrix.isNilpotent_of_trace_zero_det_zero
    {K : Type*} [Field K]
    (M : Matrix (Fin 2) (Fin 2) K)
    (htrace : M.trace = 0)
    (hdet : M.det = 0) :
    IsNilpotent M := by
  use 2;
  simp_all +decide [ sq, Matrix.det_fin_two, Matrix.trace_fin_two ];
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide [ *, Matrix.mul_apply ] <;> ring;
  · linear_combination' htrace * M 0 0 - hdet;
  · linear_combination' htrace * M 0 1;
  · linear_combination' htrace * M 1 0;
  · grind

/-
**2×2 specialization.** If `det(I + tM) = 1` for all `t`, then `M² = 0`.
-/
theorem sq_eq_zero_of_det_one_add_smul_2x2
    {K : Type*} [Field K] [CharZero K]
    (M : Matrix (Fin 2) (Fin 2) K)
    (hdet : ∀ t : K, det (1 + t • M) = 1) :
    M ^ 2 = 0 := by
  have := hdet 0; have := hdet 1; have := hdet ( -1 ) ; simp_all +decide [ Matrix.det_fin_two, Matrix.trace_fin_two ] ;
  ext i j ; fin_cases i <;> fin_cases j <;> simp +decide [ *, sq, Matrix.mul_apply ] <;> ring_nf at *;
  · grind;
  · grind;
  · grind;
  · grind +ring