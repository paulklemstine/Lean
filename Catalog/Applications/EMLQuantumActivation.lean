import Mathlib

/-!
# Quantum exponential--matrix-logarithm activation

This file tests the proposed quantum EML activation in the general setting of a
unital C⋆-algebra.  It builds on Mathlib's continuous functional calculus and its
existing exponential map from self-adjoint to unitary elements.

The proposed expression is not, in general, unitary: setting the second
Hamiltonian to zero makes the logarithmic factor (and hence the whole neuron)
zero.  Thus it does not define a map into `SU(2)` without an additional
normalisation or a restriction on the second Hamiltonian.  The results below
formalize this obstruction; they apply in particular to the C⋆-algebra of
operators on a two-dimensional complex Hilbert space.
-/

noncomputable section

open Complex NormedSpace

namespace QuantumEML

variable {A : Type*} [CStarAlgebra A]

/-- The quantum EML expression proposed in the mission: the unitary exponential
of a self-adjoint first Hamiltonian, multiplied by the principal matrix
logarithm (continuous functional calculus) of `1 + i H₂`. -/
def neuron (H₁ H₂ : selfAdjoint A) : A :=
  (selfAdjoint.expUnitary H₁ : A) * cfc Complex.log (1 + I • (H₂ : A))

/-- With zero second Hamiltonian, the matrix-logarithm input is the identity and
its logarithm is zero, so the entire activation vanishes. -/
theorem neuron_second_zero (H₁ : selfAdjoint A) :
    neuron H₁ 0 = 0 := by
  simp [neuron]

/-- The proposed expression is not unitary-valued in any nontrivial unital
C⋆-algebra.  This is the formal counterexample to treating `neuron` as a map
into a unitary group (and hence into `SU(2)`). -/
theorem neuron_not_always_unitary [Nontrivial A] :
    ∃ H₁ H₂ : selfAdjoint A, neuron H₁ H₂ ∉ unitary A := by
  refine ⟨0, 0, ?_⟩
  rw [neuron_second_zero]
  intro hzero
  have h := Unitary.star_mul_self_of_mem hzero
  simp at h

/-- More strongly, no choice of first Hamiltonian repairs the zero-second-input
case: its output cannot equal any unitary element. -/
theorem neuron_second_zero_ne_unitary [Nontrivial A]
    (H₁ : selfAdjoint A) (U : unitary A) :
    neuron H₁ 0 ≠ (U : A) := by
  rw [neuron_second_zero]
  intro h
  have hU : (U : A) ≠ 0 := by
    intro hU0
    have hmul := Unitary.coe_mul_star_self U
    rw [hU0, zero_mul] at hmul
    exact zero_ne_one hmul
  exact hU h.symm

/-- A necessary condition for any represented unitary target: because the first
factor is itself unitary, the matrix-logarithm factor must also be unitary.
This isolates the missing hypothesis in the original conjecture. -/
theorem log_factor_unitary_of_neuron_unitary
    (H₁ H₂ : selfAdjoint A)
    (hout : neuron H₁ H₂ ∈ unitary A) :
    cfc Complex.log (1 + I • (H₂ : A)) ∈ unitary A := by
  let E : unitary A := selfAdjoint.expUnitary H₁
  let L : A := cfc Complex.log (1 + I • (H₂ : A))
  have hEL : (E : A) * L ∈ unitary A := by
    simpa [neuron, E, L] using hout
  have hEstar : star (E : A) ∈ unitary A := Unitary.star_mem E.property
  have hprod : star (E : A) * ((E : A) * L) ∈ unitary A :=
    (unitary A).mul_mem hEstar hEL
  have hcancel : star (E : A) * ((E : A) * L) = L := by
    rw [← mul_assoc, Unitary.coe_star_mul_self E, one_mul]
  rwa [hcancel] at hprod

/-- Consequently, if the logarithmic factor fails to be unitary, the neuron
cannot represent a unitary target, independently of the first Hamiltonian. -/
theorem neuron_not_unitary_of_log_factor_not_unitary
    (H₁ H₂ : selfAdjoint A)
    (hlog : cfc Complex.log (1 + I • (H₂ : A)) ∉ unitary A) :
    neuron H₁ H₂ ∉ unitary A := by
  intro hout
  exact hlog (log_factor_unitary_of_neuron_unitary H₁ H₂ hout)

end QuantumEML