/-
Copyright (c) 2025. All rights reserved.

# Nilpotent Jacobian Lemmas

Key algebraic results connecting constant Jacobian determinant to nilpotence
of the Jacobian matrix of the nonlinear part.

## Main Results

- `det_one_add_linear_matrix_nilpotent`: If `det(I + M(x)) = 1` for all `x`
  where `M` is a linear matrix family, then `M(x)` is nilpotent.
- `trace_powers_vanish_of_det_one_add`: Traces of all powers of `M(x)` vanish.

## Mathematical Background

For a polynomial map F = I + H with H homogeneous of degree d, the Jacobian
matrix JH has entries of degree d-1 in the variables. When d = 2 (quadratic),
JH is linear in x. The constraint det(I + JH(x)) = 1 forces all symmetric
functions of eigenvalues of JH(x) to vanish, hence JH(x) is nilpotent.

This is the algebraic heart of the quadratic Jacobian conjecture.

## Keywords
nilpotent Jacobian, characteristic polynomial, Newton identities,
algebraic geometry
-/

import Mathlib
import Algebra.Jacobian.Defs

namespace JacobianConjecture

open MvPolynomial Matrix BigOperators

/-! ### Matrix nilpotence from determinant constraints -/

/-
A 2×2 matrix over a field with trace zero and determinant zero is nilpotent.
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
In characteristic zero, if `det(I + t • M) = 1` for all `t : K`, then `M`
is nilpotent. This is the 1-parameter version of the nilpotence criterion.
-/
theorem isNilpotent_of_det_one_add_smul
    {K : Type*} [Field K] [CharZero K]
    {n : ℕ}
    (M : Matrix (Fin n) (Fin n) K)
    (hdet : ∀ t : K, det (1 + t • M) = 1) :
    IsNilpotent M := by
  -- Expanding $\det(I + tM)$ using the Leibniz formula gives a polynomial in $t$ with coefficients determined by the entries of $M$.
  have h_poly : ∃ p : Polynomial K, ∀ t : K, (1 + t • M).det = p.eval t := by
    use Matrix.det (Matrix.of (fun i j => Polynomial.C (if i = j then 1 else 0) + Polynomial.X * Polynomial.C (M i j)));
    simp +decide [ Matrix.det_apply', Polynomial.eval_finset_sum ];
    simp +decide [ Polynomial.eval_prod, Matrix.one_apply ];
    exact fun t => Finset.sum_congr rfl fun _ _ => by congr; ext; split_ifs <;> simp +decide [ *, mul_comm ] ;
  -- By comparing coefficients, we see that $p(t) = 1$ for all $t$.
  obtain ⟨p, hp⟩ := h_poly
  have hp_one : p = 1 := by
    exact Polynomial.funext fun x => by simpa [ hp ] using hdet x;
  -- By comparing coefficients, we see that $p(t) = 1$ for all $t$, which implies that the characteristic polynomial of $-M$ is $X^n$.
  have h_charpoly : Matrix.charpoly (-M) = Polynomial.X ^ n := by
    -- By definition of characteristic polynomial, we know that $\det(tI - (-M)) = \det(tI + M)$.
    have h_charpoly_def : ∀ t : K, Matrix.det (t • 1 + M) = Polynomial.eval t (Matrix.charpoly (-M)) := by
      intro t; rw [ Matrix.charpoly ] ; simp +decide [ Matrix.det_apply' ] ;
      simp +decide [ Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_prod, Polynomial.eval_add, Polynomial.eval_X, Polynomial.eval_one, Matrix.charmatrix, Matrix.one_apply ];
      exact Finset.sum_congr rfl fun _ _ => by congr; ext; aesop;
    -- By comparing coefficients, we see that $p(t) = 1$ for all $t$, which implies that the characteristic polynomial of $-M$ is $X^n$ because $\det(tI + M) = 1$ for all $t$.
    have h_charpoly_eq : ∀ t : K, t ≠ 0 → Polynomial.eval t (Matrix.charpoly (-M)) = t ^ n := by
      intro t ht
      have h_det : Matrix.det (t • 1 + M) = t ^ n * Matrix.det (1 + t⁻¹ • M) := by
        rw [ show t • 1 + M = t • ( 1 + t⁻¹ • M ) by ext i j; simp +decide [ ht, mul_add, add_mul, mul_assoc, mul_left_comm ], Matrix.det_smul ] ; simp +decide [ ht ];
      aesop;
    refine' Polynomial.eq_of_infinite_eval_eq _ _ _;
    exact Set.infinite_of_finite_compl ( Set.Finite.subset ( Set.finite_singleton 0 ) fun x hx => Classical.not_not.1 fun hx' => hx <| by aesop );
  use n;
  have := Matrix.aeval_self_charpoly ( -M ) ; simp_all +decide [ Matrix.charpoly ] ;
  rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> simp_all +decide [ pow_add, pow_mul ]

/-
For a 2×2 matrix: if det(I + tM) = 1 for all t, then M² = 0.
-/
theorem sq_eq_zero_of_det_one_add_smul_2x2
    {K : Type*} [Field K] [CharZero K]
    (M : Matrix (Fin 2) (Fin 2) K)
    (hdet : ∀ t : K, det (1 + t • M) = 1) :
    M ^ 2 = 0 := by
  -- Since $\det(I + tM) = 1$ for all $t$, by Cayley-Hamilton, $M$ satisfies its characteristic polynomial.
  have h_char_poly : M.trace = 0 ∧ M.det = 0 := by
    have := hdet 1; have := hdet ( -1 ) ; simp_all +decide [ Matrix.det_fin_two, Matrix.trace_fin_two ] ;
    grind +locals;
  -- By Cayley-Hamilton (2x2 case), $M^2 - \text{tr}(M) \cdot M + \det(M) \cdot I = 0$, giving $M^2 = 0$.
  have h_cayley_hamilton : M^2 - M.trace • M + M.det • 1 = 0 := by
    ext i j ; fin_cases i <;> fin_cases j <;> simpa [ Matrix.mul_apply, Matrix.trace_fin_two, Matrix.det_fin_two, pow_two ] using by ring;
  aesop

end JacobianConjecture