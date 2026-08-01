/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Alternating adjacent-sum transfer matrices

This file formalizes the algebraic mechanism behind the parity split for
period-two adjacent-sum constraints.  A bound `b` is represented by its finite
zero-one compatibility matrix.  Pairing two successive bounds gives a single
transfer matrix.  Cayley--Hamilton in dimension two then shows that open
boundary counts and both cyclic parity classes obey the same second-order
recurrence, hence have a common quadratic denominator.
-/

open Finset BigOperators

namespace AlternatingAdjacentSum

/-- The zero-one transfer matrix for the constraint `i + j ≤ b`. -/
def adjacencyMatrix (d b : ℕ) : Matrix (Fin d) (Fin d) ℤ :=
  fun i j => if (i : ℕ) + (j : ℕ) ≤ b then 1 else 0

/-- The two-step transfer matrix for consecutive bounds `s` and `s+1`. -/
def periodMatrix (d s : ℕ) : Matrix (Fin d) (Fin d) ℤ :=
  adjacencyMatrix d s * adjacencyMatrix d (s + 1)

/-- A scalar obtained by imposing arbitrary left and right boundary weights on
`n` periods of a transfer matrix. -/
def openCount {R : Type*} [CommRing R] (u v : Fin 2 → R)
    (M : Matrix (Fin 2) (Fin 2) R) (n : ℕ) : R :=
  ∑ i, ∑ j, u i * (M ^ n) i j * v j

/-- The even cyclic parity class is the trace after `n` complete periods. -/
def evenCyclicCount {R : Type*} [CommRing R]
    (M : Matrix (Fin 2) (Fin 2) R) (n : ℕ) : R :=
  Matrix.trace (M ^ n)

/-- The odd cyclic parity class has one extra transfer step. -/
def oddCyclicCount {R : Type*} [CommRing R]
    (M A : Matrix (Fin 2) (Fin 2) R) (n : ℕ) : R :=
  Matrix.trace (M ^ n * A)

/-- Cayley--Hamilton written entrywise for a two-state transfer matrix. -/
theorem two_state_cayley_hamilton {R : Type*} [CommRing R]
    (M : Matrix (Fin 2) (Fin 2) R) :
    M * M - (Matrix.trace M) • M + (Matrix.det M) • (1 : Matrix (Fin 2) (Fin 2) R) = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Matrix.trace, Matrix.det_fin_two] <;> ring

/-- Every matrix power satisfies the characteristic recurrence. -/
theorem matrix_power_recurrence {R : Type*} [CommRing R]
    (M : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    M ^ (n + 2) = (Matrix.trace M) • M ^ (n + 1) - (Matrix.det M) • M ^ n := by
  have hc : M * M = (Matrix.trace M) • M - (Matrix.det M) • 1 := by
    rw [eq_sub_iff_add_eq]
    have h := two_state_cayley_hamilton M
    rw [← sub_eq_zero]
    convert h using 1
    abel
  rw [show M ^ (n + 2) = M ^ n * (M * M) by
    simp [pow_succ, Matrix.mul_assoc]]
  rw [hc, Matrix.mul_sub, Matrix.mul_smul]
  ext i j
  simp [pow_succ]

/-- Open-boundary counts obey the same second-order recurrence as the transfer
matrix itself.  This is the source of their quadratic rational denominator. -/
theorem open_count_recurrence {R : Type*} [CommRing R]
    (u v : Fin 2 → R) (M : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    openCount u v M (n + 2) =
      Matrix.trace M * openCount u v M (n + 1) -
        Matrix.det M * openCount u v M n := by
  rw [openCount, openCount, openCount, matrix_power_recurrence]
  simp [Matrix.trace]
  ring

/-- The even cyclic counts satisfy the characteristic recurrence. -/
theorem even_cyclic_recurrence {R : Type*} [CommRing R]
    (M : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    evenCyclicCount M (n + 2) =
      Matrix.trace M * evenCyclicCount M (n + 1) -
        Matrix.det M * evenCyclicCount M n := by
  rw [evenCyclicCount, evenCyclicCount, evenCyclicCount, matrix_power_recurrence]
  simp [Matrix.trace]
  ring

/-- The odd cyclic counts, with one unpaired transfer step, satisfy exactly the
same recurrence and therefore have the same denominator as the even class. -/
theorem odd_cyclic_recurrence {R : Type*} [CommRing R]
    (M A : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    oddCyclicCount M A (n + 2) =
      Matrix.trace M * oddCyclicCount M A (n + 1) -
        Matrix.det M * oddCyclicCount M A n := by
  rw [oddCyclicCount, oddCyclicCount, oddCyclicCount, matrix_power_recurrence]
  simp [Matrix.trace, Matrix.mul_apply]
  ring

/-- Moving the first factor of an alternating product to the end rotates all
complete periods. -/
theorem alternating_power_rotation {R : Type*} [CommRing R]
    (A B : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    B * (A * B) ^ n = (B * A) ^ n * B := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, pow_succ, ← Matrix.mul_assoc, ih]
      simp only [Matrix.mul_assoc]

/-- Rotating the two alternating transfer steps does not change any positive
cyclic count: traces of `(AB)^n` and `(BA)^n` agree. -/
theorem cyclic_rotation_invariance {R : Type*} [CommRing R]
    (A B : Matrix (Fin 2) (Fin 2) R) (n : ℕ) :
    Matrix.trace ((A * B) ^ (n + 1)) = Matrix.trace ((B * A) ^ (n + 1)) := by
  rw [pow_succ, pow_succ]
  calc
    Matrix.trace ((A * B) ^ n * (A * B)) =
        Matrix.trace (((A * B) ^ n * A) * B) := by rw [Matrix.mul_assoc]
    _ = Matrix.trace (B * ((A * B) ^ n * A)) := Matrix.trace_mul_comm _ _
    _ = Matrix.trace ((B * A) ^ n * (B * A)) := by
      rw [← Matrix.mul_assoc, alternating_power_rotation]
      rw [Matrix.mul_assoc]

/-- Matrix multiplication sums over the intermediate coordinate, so an entry of
the period matrix counts all two-edge adjacent-sum paths between its endpoints. -/
theorem period_matrix_entry (d s : ℕ) (i k : Fin d) :
    periodMatrix d s i k =
      ∑ j : Fin d,
        (if (i : ℕ) + (j : ℕ) ≤ s then 1 else 0) *
          (if (j : ℕ) + (k : ℕ) ≤ s + 1 then 1 else 0) := by
  simp [periodMatrix, adjacencyMatrix, Matrix.mul_apply]

end AlternatingAdjacentSum