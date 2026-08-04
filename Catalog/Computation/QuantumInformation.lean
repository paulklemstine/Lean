import Mathlib

/-!
# Quantum information: no-cloning, teleportation, and qubit monogamy

This file uses the catalog's `Qubit` amplitude convention and Mathlib's matrix
C*-algebra.  The no-cloning statement is made for the carrier of the qubit observable
C*-algebra `M₂(ℂ)`.  Teleportation is verified amplitude-by-amplitude, including all
four classical measurement outcomes.  Finally, determinant/concurrence tangles are
computed for the three-qubit W sector, where the Coffman–Kundu–Wootters monogamy
inequality is saturated.
-/

open scoped TensorProduct ComplexConjugate
open Matrix

noncomputable section
namespace QuantumInformation

/-- The diagonal observable C*-algebra of one qubit. -/
abbrev QubitObservable := Fin 2 → ℂ

/-- The qubit observable algebra is a C*-algebra (the existing Mathlib instance). -/
example : CStarAlgebra QubitObservable := inferInstance

/-- No linear map on any nontrivial complex C*-algebra can universally clone an
algebra element into its algebraic tensor square.  In particular, complete positivity
or unitarity cannot rescue a universal cloner, since those are stronger requirements
than linearity. -/
theorem no_cloning_cstar (A : Type*) [CStarAlgebra A] [Nontrivial A] :
    ¬ ∃ C : A →ₗ[ℂ] A ⊗[ℂ] A, ∀ a, C a = a ⊗ₜ[ℂ] a := by
  rintro ⟨C, hC⟩
  have hlin : C ((2 : ℂ) • (1 : A)) = (2 : ℂ) • C (1 : A) := C.map_smul _ _
  rw [hC, hC] at hlin
  let m : A →ₗ[ℂ] A →ₗ[ℂ] A :=
    LinearMap.mk₂ ℂ (fun a b => a * b)
      (fun _ _ _ => add_mul _ _ _) (fun _ _ _ => by simp)
      (fun _ _ _ => mul_add _ _ _) (fun _ _ _ => by simp)
  let f : A ⊗[ℂ] A →ₗ[ℂ] A := TensorProduct.lift m
  apply_fun f at hlin
  simp [f, m] at hlin
  have hnorm := congrArg norm hlin
  norm_num at hnorm

/-- No universal linear cloner exists for the qubit observable C*-algebra. -/
theorem no_cloning_cstar_qubit :
    ¬ ∃ C : QubitObservable →ₗ[ℂ] QubitObservable ⊗[ℂ] QubitObservable,
      ∀ A, C A = A ⊗ₜ[ℂ] A :=
  no_cloning_cstar QubitObservable

/-! ## Teleportation -/

/-- An (unnormalized) qubit amplitude vector.  We use `Bool` for the computational
basis so circuit equations can be reduced by the four finite cases. -/
abbrev QubitVec := Bool → ℂ

/-- The coefficient `1/√2`, coerced to `ℂ`. -/
noncomputable def invSqrtTwo : ℂ := (1 / Real.sqrt 2 : ℝ)

/-- The square of the Hadamard coefficient is one half. -/
theorem invSqrtTwo_sq : invSqrtTwo * invSqrtTwo = (1 / 2 : ℂ) := by
  have hr : (1 / Real.sqrt 2) * (1 / Real.sqrt 2) = (1 / 2 : ℝ) := by
    have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := by norm_num
    have hn : Real.sqrt 2 ≠ 0 := by positivity
    field_simp
    simp [pow_two, hs]
  simpa [invSqrtTwo] using congrArg Complex.ofReal hr

/-- A Bell pair `(|00⟩+|11⟩)/√2`. -/
noncomputable def bellAmplitude (b c : Bool) : ℂ :=
  if b = c then invSqrtTwo else 0

/-- Input qubit tensored with the Bell pair shared by Alice and Bob. -/
noncomputable def teleportInitial (ψ : QubitVec) (a b c : Bool) : ℂ :=
  ψ a * bellAmplitude b c

/-- Apply Alice's CNOT (first wire controls the second) to an amplitude table. -/
noncomputable def cnot12 (v : Bool → Bool → Bool → ℂ) (a b c : Bool) : ℂ :=
  v a (xor a b) c

/-- Apply a Hadamard gate to Alice's first wire. -/
noncomputable def hadamard1 (v : Bool → Bool → Bool → ℂ) (a b c : Bool) : ℂ :=
  invSqrtTwo * (if a then v false b c - v true b c else v false b c + v true b c)

/-- Bob's conditional (unnormalized) state after Alice measures bits `a,b`. -/
noncomputable def teleportMeasured (ψ : QubitVec) (a b : Bool) : QubitVec :=
  fun c => hadamard1 (cnot12 (teleportInitial ψ)) a b c

/-- Pauli-X on amplitude vectors. -/
def pauliXVec (v : QubitVec) : QubitVec := fun c => v (!c)

/-- Pauli-Z on amplitude vectors. -/
def pauliZVec (v : QubitVec) : QubitVec := fun c => if c then -v c else v c

/-- Bob's correction: first X according to the second measurement bit, then Z
according to the first measurement bit. -/
def teleportCorrection (a b : Bool) (v : QubitVec) : QubitVec :=
  let x := if b then pauliXVec v else v
  if a then pauliZVec x else x

/-- **Correctness of quantum teleportation.**  For each of Alice's four outcomes,
Bob's corrected branch is exactly the input state, with the common branch amplitude
`1/2`.  Thus normalization of the post-measurement branch recovers `ψ`. -/
theorem teleportation_correct (ψ : QubitVec) (a b c : Bool) :
    teleportCorrection a b (teleportMeasured ψ a b) c = (1 / 2 : ℂ) * ψ c := by
  cases a <;> cases b <;> cases c <;>
    simp [teleportCorrection, teleportMeasured, hadamard1, cnot12,
      teleportInitial, bellAmplitude, pauliXVec, pauliZVec] <;>
    calc
      invSqrtTwo * (ψ _ * invSqrtTwo) =
          (invSqrtTwo * invSqrtTwo) * ψ _ := by ring
      _ = (1 / 2 : ℂ) * ψ _ := by rw [invSqrtTwo_sq]
      _ = (2 : ℂ)⁻¹ * ψ _ := by norm_num

/-! ## Entanglement measures and monogamy in the W sector -/

/-- Squared modulus, used in pure-state tangles and squared concurrence. -/
def modulusSq (z : ℂ) : ℝ := Complex.normSq z

/-- The one-tangle between qubit A and BC for a W state
`a|100⟩ + b|010⟩ + c|001⟩`. -/
def wOneTangleA (a b c : ℂ) : ℝ :=
  4 * modulusSq a * (modulusSq b + modulusSq c)

/-- Squared concurrence of the AB reduced state of a W state. -/
def wConcurrenceSqAB (a b : ℂ) : ℝ := 4 * modulusSq a * modulusSq b

/-- Squared concurrence of the AC reduced state of a W state. -/
def wConcurrenceSqAC (a c : ℂ) : ℝ := 4 * modulusSq a * modulusSq c

/-- **Monogamy of entanglement for three qubits in the W sector.**  The CKW bound is
saturated: all of A's one-tangle is pairwise concurrence with B and C. -/
theorem w_state_monogamy_eq (a b c : ℂ) :
    wConcurrenceSqAB a b + wConcurrenceSqAC a c = wOneTangleA a b c := by
  simp only [wConcurrenceSqAB, wConcurrenceSqAC, wOneTangleA]
  ring

/-- The inequality form of W-state monogamy. -/
theorem w_state_monogamy (a b c : ℂ) :
    wConcurrenceSqAB a b + wConcurrenceSqAC a c ≤ wOneTangleA a b c := by
  rw [w_state_monogamy_eq]

/-- For a normalized W state, the one-tangle is at most one. -/
theorem w_one_tangle_le_one (a b c : ℂ)
    (hnorm : modulusSq a + modulusSq b + modulusSq c = 1) :
    wOneTangleA a b c ≤ 1 := by
  have ha : 0 ≤ modulusSq a := Complex.normSq_nonneg a
  have hb : 0 ≤ modulusSq b := Complex.normSq_nonneg b
  have hc : 0 ≤ modulusSq c := Complex.normSq_nonneg c
  simp only [wOneTangleA]
  nlinarith [sq_nonneg (2 * modulusSq a - 1)]

end QuantumInformation