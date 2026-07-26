/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-! # The Periodic Table Is a Lie: Elements as Eigenvalues

A cross-domain *connector* bridging **spectral / linear algebra** (self-adjoint
operators, eigenvalues, trace, determinant, characteristic polynomial) with
**elementary number theory** (triangular numbers `n(n+1)/2`, factorials `n!`).

## The construction

Mendeleev arranges the elements by atomic number `Z`.  We reinterpret the
periodic table spectrally: define the *nuclear Hamiltonian* as the diagonal
operator on the `n`-dimensional real Hilbert space `Fin n → ℝ` whose diagonal
entries are the atomic numbers `1, 2, …, n`.

## Main results

* `nuclearHamiltonian_isHermitian` — the Hamiltonian is self-adjoint (a genuine
  quantum-mechanical observable).
* `hasEigenvalue_atomicNumber` / `eigenvalue_imp_atomicNumber` /
  `spectrum_eq_range` — its spectrum is **exactly** the set of atomic numbers:
  the periodic table *is* the spectrum of an operator.
* `range_atomicNumber` — those eigenvalues are precisely the integers `1, …, n`.
* `trace_nuclearHamiltonian` — **spectral ↔ arithmetic bridge**: the trace (sum
  of eigenvalues) equals the Gauss triangular number `n(n+1)/2`.
* `trace_pow_nuclearHamiltonian` — **power-sum ladder**: the trace of the `k`-th
  power of the Hamiltonian equals the `k`-th power sum of the atomic numbers.
* `det_nuclearHamiltonian` — **spectral ↔ arithmetic bridge**: the determinant
  (product of eigenvalues) equals `n!`.
* `charpoly_nuclearHamiltonian` — the characteristic polynomial factors into
  linear terms rooted at the atomic numbers.
-/

open Matrix Module.End Polynomial

namespace PeriodicTableEigenvalues

/-- The atomic number of the `i`-th element (`1`-indexed), as a real scalar. -/
def atomicNumber (n : ℕ) (i : Fin n) : ℝ := (i : ℝ) + 1

/-- The *nuclear Hamiltonian*: the diagonal operator whose spectrum is the
periodic table of the first `n` elements. -/
noncomputable def nuclearHamiltonian (n : ℕ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (atomicNumber n)

/-- The Hamiltonian as an endomorphism of the Hilbert space `Fin n → ℝ`. -/
noncomputable def H (n : ℕ) : Module.End ℝ (Fin n → ℝ) :=
  Matrix.toLin' (nuclearHamiltonian n)

/-- The nuclear Hamiltonian is self-adjoint: a legitimate quantum observable. -/
theorem nuclearHamiltonian_isHermitian (n : ℕ) :
    (nuclearHamiltonian n).IsHermitian :=
  isHermitian_diagonal _

/-- Each atomic number is an eigenvalue of the nuclear Hamiltonian, with the
corresponding standard basis vector as eigenstate. -/
theorem hasEigenvalue_atomicNumber (n : ℕ) (i : Fin n) :
    Module.End.HasEigenvalue (H n) (atomicNumber n i) := by
  apply Module.End.hasEigenvalue_of_hasEigenvector (x := Pi.single i 1)
  constructor
  · rw [Module.End.mem_eigenspace_iff]
    ext j
    simp only [H, nuclearHamiltonian, Matrix.toLin'_apply, Matrix.mulVec_diagonal,
      Pi.smul_apply, smul_eq_mul]
    rcases eq_or_ne j i with h | h
    · subst h; simp
    · simp [Pi.single_eq_of_ne h]
  · intro hc
    have := congrFun hc i
    simp at this

/-- Conversely, every eigenvalue of the nuclear Hamiltonian is an atomic number. -/
theorem eigenvalue_imp_atomicNumber (n : ℕ) (μ : ℝ)
    (h : Module.End.HasEigenvalue (H n) μ) : ∃ i, atomicNumber n i = μ := by
  obtain ⟨x, hx, hx0⟩ := h.exists_hasEigenvector
  rw [Module.End.mem_eigenspace_iff] at hx
  obtain ⟨j, hj⟩ := Function.ne_iff.mp hx0
  refine ⟨j, ?_⟩
  have hcong := congrFun hx j
  simp only [H, nuclearHamiltonian, Matrix.toLin'_apply, Matrix.mulVec_diagonal,
    Pi.smul_apply, smul_eq_mul] at hcong
  have hxj : x j ≠ 0 := by simpa using hj
  exact mul_right_cancel₀ hxj hcong

/-- **The periodic table is the spectrum of an operator.** The set of eigenvalues
of the nuclear Hamiltonian is exactly the set of atomic numbers. -/
theorem spectrum_eq_range (n : ℕ) :
    {μ : ℝ | Module.End.HasEigenvalue (H n) μ} = Set.range (atomicNumber n) := by
  ext μ
  constructor
  · intro h; exact eigenvalue_imp_atomicNumber n μ h
  · rintro ⟨i, rfl⟩; exact hasEigenvalue_atomicNumber n i

/-- The atomic numbers are exactly the integers `1, 2, …, n`. -/
theorem range_atomicNumber (n : ℕ) :
    Set.range (atomicNumber n) = {x : ℝ | ∃ k : ℕ, 1 ≤ k ∧ k ≤ n ∧ x = k} := by
  ext x
  constructor
  · rintro ⟨i, rfl⟩
    exact ⟨i + 1, by omega, by omega, by push_cast [atomicNumber]; ring⟩
  · rintro ⟨k, hk1, hkn, rfl⟩
    refine ⟨⟨k - 1, by omega⟩, ?_⟩
    simp only [atomicNumber]
    have hkr : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
      have : 1 ≤ k := hk1; push_cast [Nat.cast_sub this]; ring
    rw [hkr]; ring

theorem sum_atomicNumber (n : ℕ) :
    ∑ i, atomicNumber n i = (n * (n + 1) : ℝ) / 2 := by
  simp only [atomicNumber]
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Fin.sum_univ_castSucc]
    simp only [Fin.val_castSucc, Fin.val_last]
    rw [ih]; push_cast; ring

theorem prod_atomicNumber (n : ℕ) :
    ∏ i, atomicNumber n i = (n.factorial : ℝ) := by
  simp only [atomicNumber]
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Fin.prod_univ_castSucc]
    simp only [Fin.val_castSucc, Fin.val_last]
    rw [ih, Nat.factorial_succ]; push_cast; ring

/-- **Trace–triangular bridge.** The trace of the nuclear Hamiltonian (the sum of
its eigenvalues) equals the Gauss triangular number `n(n+1)/2`. -/
theorem trace_nuclearHamiltonian (n : ℕ) :
    (nuclearHamiltonian n).trace = (n * (n + 1) : ℝ) / 2 := by
  rw [nuclearHamiltonian, Matrix.trace_diagonal, sum_atomicNumber]

/-- **Power-sum ladder.** For every exponent `k`, the trace of the `k`-th power of
the nuclear Hamiltonian equals the `k`-th power sum of the atomic numbers. This
generalizes `trace_nuclearHamiltonian` (the case `k = 1`) into a full ladder of
spectral ↔ arithmetic bridges. -/
theorem trace_pow_nuclearHamiltonian (n k : ℕ) :
    ((nuclearHamiltonian n) ^ k).trace = ∑ i, (atomicNumber n i) ^ k := by
  rw [nuclearHamiltonian, Matrix.diagonal_pow, Matrix.trace_diagonal]
  simp [Pi.pow_apply]

/-- **Determinant–factorial bridge.** The determinant of the nuclear Hamiltonian
(the product of its eigenvalues) equals `n!`. -/
theorem det_nuclearHamiltonian (n : ℕ) :
    (nuclearHamiltonian n).det = (n.factorial : ℝ) := by
  rw [nuclearHamiltonian, Matrix.det_diagonal, prod_atomicNumber]

/-- **Characteristic polynomial factorization.** The characteristic polynomial of
the nuclear Hamiltonian factors into linear terms whose roots are precisely the
atomic numbers. -/
theorem charpoly_nuclearHamiltonian (n : ℕ) :
    (nuclearHamiltonian n).charpoly
      = ∏ i, (Polynomial.X - Polynomial.C (atomicNumber n i)) := by
  rw [nuclearHamiltonian, Matrix.charpoly_diagonal]

end PeriodicTableEigenvalues