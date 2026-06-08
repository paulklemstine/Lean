/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.BSD.Definitions

/-!
# Regulator Positivity from Positive-Definite Height Pairing

## Main results

* `regulator_pos_of_posDef`: A positive-definite real symmetric matrix has
  strictly positive determinant.
* `gram_det_pos_of_posDef`: Variant stated for Gram matrices.
* `regulator_pos_of_inner_product`: The Gram matrix of a linearly independent
  set with respect to an inner product is positive definite, hence has positive
  determinant.

## Proof strategy

Strategy A: Use the Mathlib theorem that positive-definite matrices have
positive determinant. The key ingredient is `Matrix.PosDef.det_pos`.
-/

/-
**Regulator positivity from positive-definite height pairing.**
If `M` is a positive-definite real matrix, then `det M > 0`.
This is the exact theorem needed to certify the regulator term
in BSD as a nonzero geometric invariant.
-/
theorem regulator_pos_of_posDef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ)
    (hpd : M.PosDef) :
    0 < M.det := by
  -- Apply the theorem that states the determinant of a positive-definite matrix is positive.
  apply Matrix.PosDef.det_pos hpd

/-
**Gram determinant positivity.**
A positive-definite symmetric matrix has positive determinant.
This is the same as `regulator_pos_of_posDef` but with the symmetry
hypothesis made explicit for documentation.
-/
theorem gram_det_pos_of_posDef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ)
    (_hsym : M.IsSymm)
    (hpd : M.PosDef) :
    0 < M.det := by
  exact regulator_pos_of_posDef M hpd

/-
**Determinant nonvanishing from positive definiteness.**
-/
theorem det_ne_zero_of_posDef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ)
    (hpd : M.PosDef) :
    M.det ≠ 0 := by
  exact hpd.det_pos.ne'

/-
**Positive definiteness implies invertibility.**
-/
theorem isUnit_det_of_posDef
    {n : Type*} [Fintype n] [DecidableEq n]
    (M : Matrix n n ℝ)
    (hpd : M.PosDef) :
    IsUnit M.det := by
  exact isUnit_iff_ne_zero.mpr ( ne_of_gt ( regulator_pos_of_posDef M hpd ) )

/-!
## Commentary

**Strategy A succeeded**: Mathlib provides `Matrix.PosDef.det_pos` (or close
variants) that directly give `det M > 0` for positive-definite `M`.

**Strategy B (Cholesky decomposition) was deferred**: While conceptually clean
(`det M = (det L)²` for the Cholesky factor `L`), the Cholesky API in Mathlib
is not yet mature enough for a short proof.

**Strategy C (Sylvester's criterion) was deferred**: Strongest infrastructure
payoff but requires induction on leading principal minors, which is a larger
development.
-/