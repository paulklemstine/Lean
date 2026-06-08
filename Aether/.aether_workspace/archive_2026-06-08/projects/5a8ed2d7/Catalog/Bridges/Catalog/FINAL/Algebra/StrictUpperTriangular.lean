/-
Copyright (c) 2025. All rights reserved.

# Strictly Upper Triangular Matrices and Nilpotence

## Main Results

* `strictUpperTriangular_pow_entry_zero`: For a strictly upper triangular matrix `A`,
  `(A^k) i j = 0` whenever `j.val < i.val + k`.

* `strictUpperTriangular_nilpotent`: A strictly upper triangular n×n matrix
  satisfies `A ^ n = 0`.

* `chain_perturbation_jacobian_superdiagonal`: The Jacobian of the perturbation
  part of a chain map (H - Id) has entries only on the first superdiagonal.

* `chain_perturbation_nilpotent`: The Jacobian perturbation matrix of a chain
  map is nilpotent.

## Keywords
strictly upper triangular, nilpotent matrix, superdiagonal, chain map,
polynomial automorphism, Jacobian
-/

import Mathlib
import Algebra.Jacobian.Defs

namespace JacobianConjecture

open Matrix Finset MvPolynomial

variable {R : Type*} [CommRing R]

/-! ### Strictly Upper Triangular Matrices -/

/-- A matrix is strictly upper triangular if `A i j = 0` whenever `j ≤ i`. -/
def IsStrictlyUpperTriangular {n : ℕ} (A : Matrix (Fin n) (Fin n) R) : Prop :=
  ∀ i j : Fin n, j.val ≤ i.val → A i j = 0

/-- A matrix has entries only on the first superdiagonal. -/
def IsSuperdiagonal {n : ℕ} (A : Matrix (Fin n) (Fin n) R) : Prop :=
  ∀ i j : Fin n, (j.val ≠ i.val + 1) → A i j = 0

/-- Superdiagonal matrices are strictly upper triangular. -/
theorem IsSuperdiagonal.isStrictlyUpperTriangular {n : ℕ}
    (A : Matrix (Fin n) (Fin n) R) (h : IsSuperdiagonal A) :
    IsStrictlyUpperTriangular A := by
  intro i j hle
  apply h
  omega

/-! ### Key lemma: entries of powers of strictly upper triangular matrices -/

/-- For a strictly upper triangular matrix `A`, the entry `(A^k) i j = 0`
    whenever `j.val < i.val + k`. This is the inductive engine for the
    nilpotence proof. -/
theorem strictUpperTriangular_pow_entry_zero {n : ℕ}
    (A : Matrix (Fin n) (Fin n) R) (hA : IsStrictlyUpperTriangular A)
    (k : ℕ) (i j : Fin n) (h : j.val < i.val + k) :
    (A ^ k) i j = 0 := by
  induction' k with k ih generalizing i j;
  · simp +decide [ Matrix.one_apply ]; grind;
  · rw [ pow_succ', Matrix.mul_apply ];
    rw [ Finset.sum_eq_single i ] <;> simp_all +decide [ IsStrictlyUpperTriangular ];
    grind

/-- **Strictly upper triangular matrices are nilpotent.**
    An `n × n` strictly upper triangular matrix satisfies `A ^ n = 0`. -/
theorem strictUpperTriangular_nilpotent {n : ℕ}
    (A : Matrix (Fin n) (Fin n) R) (hA : IsStrictlyUpperTriangular A) :
    A ^ n = 0 := by
  exact Matrix.ext fun i j =>
    strictUpperTriangular_pow_entry_zero A hA n i j (by omega)

/-- Strictly upper triangular matrices are nilpotent (existential form). -/
theorem strictUpperTriangular_isNilpotent {n : ℕ}
    (A : Matrix (Fin n) (Fin n) R) (hA : IsStrictlyUpperTriangular A) :
    IsNilpotent A :=
  ⟨n, strictUpperTriangular_nilpotent A hA⟩

/-- Superdiagonal matrices are nilpotent. -/
theorem superdiagonal_nilpotent {n : ℕ}
    (A : Matrix (Fin n) (Fin n) R) (hA : IsSuperdiagonal A) :
    A ^ n = 0 :=
  strictUpperTriangular_nilpotent A (hA.isStrictlyUpperTriangular A)

/-! ### Application to Chain Polynomial Maps -/

variable {k : Type*} [CommRing k] {m : ℕ}

/-- A chain polynomial map: coordinate `i` is `X_i` plus a polynomial depending
    only on `X_{i+1}`. -/
def IsChainMap (H : PolyMap k m) : Prop :=
  ∀ i : Fin m, ∀ j : Fin m, j ∈ (H i - MvPolynomial.X i).vars → j.val = i.val + 1

/-- The perturbation of a polynomial map: `P_i = H_i - X_i`. -/
noncomputable def perturbation (H : PolyMap k m) : PolyMap k m :=
  fun i => H i - MvPolynomial.X i

/-
The Jacobian of the perturbation of a chain map is superdiagonal.
    If `H` is a chain map, then `(jacobianMatrix (H - Id)) i j = 0`
    unless `j.val = i.val + 1`.
-/
theorem chain_perturbation_jacobian_superdiagonal
    (H : PolyMap k m) (hH : IsChainMap H) :
    IsSuperdiagonal (jacobianMatrix (perturbation H)) := by
  intro i j hj;
  apply MvPolynomial.pderiv_eq_zero_of_notMem_vars;
  exact fun h => hj <| hH i j h;

/-- **The Jacobian perturbation of a chain map is nilpotent.**
    For a chain map `H`, the Jacobian of `H - Id` satisfies
    `(jacobianMatrix (H - Id))^m = 0`. -/
theorem chain_perturbation_nilpotent
    (H : PolyMap k m) (hH : IsChainMap H) :
    (jacobianMatrix (perturbation H)) ^ m = 0 := by
  exact superdiagonal_nilpotent _ (chain_perturbation_jacobian_superdiagonal H hH)

end JacobianConjecture