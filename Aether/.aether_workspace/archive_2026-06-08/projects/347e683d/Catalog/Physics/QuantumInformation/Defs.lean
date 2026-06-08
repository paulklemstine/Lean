/-
  # Quantum Information: Basic Definitions

  Concrete qubit infrastructure for quantum information theory.
  Uses `Fin 2 → ℂ` for single-qubit states, `Fin 2 × Fin 2 → ℂ` for two-qubit states,
  and explicit matrix definitions for standard quantum gates.
-/
import Mathlib

namespace QuantumInformation

open Complex Matrix Finset

noncomputable section

/-! ## Qubit basis states -/

/-- The |0⟩ computational basis state. -/
def ket0 : Fin 2 → ℂ := ![1, 0]

/-- The |1⟩ computational basis state. -/
def ket1 : Fin 2 → ℂ := ![0, 1]

/-! ## Pauli matrices and standard gates -/

/-- Pauli X (NOT) gate. -/
def pauliX : Matrix (Fin 2) (Fin 2) ℂ := !![0, 1; 1, 0]

/-- Pauli Z gate. -/
def pauliZ : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; 0, -1]

/-- Pauli Y gate. -/
def pauliY : Matrix (Fin 2) (Fin 2) ℂ := !![0, -I; I, 0]

/-- Identity matrix on qubits. -/
def qubitId : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; 0, 1]

/-- Hadamard gate (unnormalized by √2 for cleaner arithmetic).
The actual Hadamard is (1/√2) • hadamardUnscaled. -/
def hadamardUnscaled : Matrix (Fin 2) (Fin 2) ℂ := !![1, 1; 1, -1]

/-- Hadamard gate (properly normalized). -/
def hadamard : Matrix (Fin 2) (Fin 2) ℂ :=
  (1 / Real.sqrt 2 : ℂ) • hadamardUnscaled

/-! ## Two-qubit gates and states -/

/-- CNOT gate on two qubits, controlled on first qubit, target second qubit.
Maps |00⟩→|00⟩, |01⟩→|01⟩, |10⟩→|11⟩, |11⟩→|10⟩. -/
def cnotMatrix : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ :=
  fun ⟨c, t⟩ ⟨c', t'⟩ =>
    if c = c' then
      if c.val = 0 then (if t = t' then 1 else 0)  -- identity on second qubit when control=0
      else (if t.val + t'.val = 1 then 1 else 0)     -- X on second qubit when control=1
    else 0

/-- Kronecker product of two vectors. -/
def kronVec {m n : Type*} (u : m → ℂ) (v : n → ℂ) : m × n → ℂ :=
  fun ⟨i, j⟩ => u i * v j

/-- Kronecker product of two matrices. -/
def kronMat {m₁ n₁ m₂ n₂ : Type*}
    (A : Matrix m₁ n₁ ℂ) (B : Matrix m₂ n₂ ℂ) :
    Matrix (m₁ × m₂) (n₁ × n₂) ℂ :=
  fun ⟨i₁, i₂⟩ ⟨j₁, j₂⟩ => A i₁ j₁ * B i₂ j₂

/-! ## Bell states -/

/-- The Bell state |Φ⁺⟩ = (|00⟩ + |11⟩)/√2 (unnormalized: |00⟩ + |11⟩). -/
def bellPlusUnnorm : Fin 2 × Fin 2 → ℂ :=
  fun ⟨i, j⟩ => if i = j then 1 else 0

/-- The Bell state |Φ⁺⟩ = (|00⟩ + |11⟩)/√2 (normalized). -/
def bellPlus : Fin 2 × Fin 2 → ℂ :=
  fun ⟨i, j⟩ => if i = j then (1 / Real.sqrt 2 : ℂ) else 0

/-! ## Two-qubit basis states -/

def basis00 : Fin 2 × Fin 2 → ℂ := kronVec ket0 ket0
def basis01 : Fin 2 × Fin 2 → ℂ := kronVec ket0 ket1
def basis10 : Fin 2 × Fin 2 → ℂ := kronVec ket1 ket0
def basis11 : Fin 2 × Fin 2 → ℂ := kronVec ket1 ket1

/-! ## Density matrices -/

/-- A complex matrix is positive semidefinite: it is Hermitian and ⟨v, ρv⟩ ≥ 0 for all v. -/
def IsPosSemidef {n : Type*} [Fintype n] [DecidableEq n]
    (ρ : Matrix n n ℂ) : Prop :=
  ρ.IsHermitian ∧ ∀ v : n → ℂ, 0 ≤ (dotProduct (star v) (ρ.mulVec v)).re

/-- A matrix is a density matrix if it is positive semidefinite and has trace 1. -/
def IsDensityMatrix {n : Type*} [Fintype n] [DecidableEq n]
    (ρ : Matrix n n ℂ) : Prop :=
  IsPosSemidef ρ ∧ ρ.trace = 1

/-- Pure state density matrix |ψ⟩⟨ψ|. -/
def pureDensity {n : Type*} (ψ : n → ℂ) : Matrix n n ℂ :=
  fun i j => ψ i * starRingEnd ℂ (ψ j)

/-! ## Partial trace -/

/-- Partial trace over the second subsystem.
For a matrix on H_A ⊗ H_B, traces out H_B to give a matrix on H_A. -/
def partialTraceRight {m n : Type*} [Fintype n]
    (ρ : Matrix (m × n) (m × n) ℂ) : Matrix m m ℂ :=
  fun i j => ∑ k : n, ρ ⟨i, k⟩ ⟨j, k⟩

/-- Partial trace over the first subsystem.
For a matrix on H_A ⊗ H_B, traces out H_A to give a matrix on H_B. -/
def partialTraceLeft {m n : Type*} [Fintype m]
    (ρ : Matrix (m × n) (m × n) ℂ) : Matrix n n ℂ :=
  fun i j => ∑ k : m, ρ ⟨k, i⟩ ⟨k, j⟩

end

end QuantumInformation