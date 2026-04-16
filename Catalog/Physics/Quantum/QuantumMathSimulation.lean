/-! # CatalogBuild.Physics.Quantum.QuantumMathSimulation

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 26
-/

import Mathlib

noncomputable section

/-- A quantum state is a unit vector: the norm-squared of amplitudes equals 1.
This is the Born rule normalization condition. -/
def IsQuantumState {d : ℕ} (ψ : Fin d → ℂ) : Prop :=
  ∑ i, ‖ψ i‖^2 = 1



/-- A quantum gate is a unitary matrix: U† * U = I.
Unitarity guarantees reversibility and probability conservation. -/
def IsUnitaryGate {d : ℕ} (U : Matrix (Fin d) (Fin d) ℂ) : Prop :=
  U.conjTranspose * U = 1



/-- [Section: # CatalogBuild.Physics.Quantum.QuantumMathSimulation
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 26] -/
theorem identity_is_unitary (d : ℕ) : IsUnitaryGate (1 : Matrix (Fin d) (Fin d) ℂ) := by
  -- The identity matrix is unitary because its conjugate transpose is itself, and multiplying it by itself gives the identity matrix.
  simp [IsUnitaryGate]



theorem unitary_comp {d : ℕ} (U V : Matrix (Fin d) (Fin d) ℂ)
    (hU : IsUnitaryGate U) (hV : IsUnitaryGate V) :
    IsUnitaryGate (U * V) := by
  simp_all +decide [ IsUnitaryGate, Matrix.conjTranspose_mul ];
  simp +decide [ ← mul_assoc, hU, hV ];
  simp_all +decide [ mul_assoc ]



theorem unitary_adjoint {d : ℕ} (U : Matrix (Fin d) (Fin d) ℂ)
    (hU : IsUnitaryGate U) (hU' : U * U.conjTranspose = 1) :
    IsUnitaryGate U.conjTranspose := by
  unfold IsUnitaryGate at *; aesop;



/-- Born rule: measurement probabilities from a quantum state sum to 1. -/
theorem born_rule_valid {d : ℕ} (ψ : Fin d → ℂ) (hψ : IsQuantumState ψ) :
    ∑ i : Fin d, ‖ψ i‖^2 = 1 := hψ



/-- A two-system state is separable if it factors as a tensor product. -/
def QSeparable {d₁ d₂ : ℕ} (ψ : Fin d₁ → Fin d₂ → ℂ) : Prop :=
  ∃ (a : Fin d₁ → ℂ) (b : Fin d₂ → ℂ), ∀ i j, ψ i j = a i * b j



/-- A state is entangled if and only if it is not separable. -/
def QEntangled {d₁ d₂ : ℕ} (ψ : Fin d₁ → Fin d₂ → ℂ) : Prop :=
  ¬ QSeparable ψ



/-- The Bell state (1/√2)(|00⟩ + |11⟩) expressed as a 2×2 matrix of amplitudes. -/
noncomputable def bellState : Fin 2 → Fin 2 → ℂ := fun i j =>
  if i = j then (↑(1 / Real.sqrt 2) : ℂ) else 0



theorem bell_state_entangled : QEntangled bellState := by
  rintro ⟨ a, b, h ⟩;
  unfold bellState at h; aesop;



/-- Applying a quantum gate to a state is matrix-vector multiplication. -/
noncomputable def applyGate {d : ℕ} (U : Matrix (Fin d) (Fin d) ℂ) (ψ : Fin d → ℂ) :
    Fin d → ℂ :=
  U.mulVec ψ



/-- A quantum circuit is a sequence of gates, composed by matrix multiplication. -/
noncomputable def applyCircuit {d : ℕ} (gates : List (Matrix (Fin d) (Fin d) ℂ))
    (ψ : Fin d → ℂ) : Fin d → ℂ :=
  match gates with
  | [] => ψ
  | U :: rest => applyCircuit rest (applyGate U ψ)



/-- The total unitary of a circuit is the reversed product of its gates.
For gates [U₁, U₂, ...], we apply U₁ first, then U₂, etc.
So the total unitary is ... * U₂ * U₁. -/
noncomputable def circuitUnitary {d : ℕ}
    (gates : List (Matrix (Fin d) (Fin d) ℂ)) : Matrix (Fin d) (Fin d) ℂ :=
  gates.foldl (fun acc U => U * acc) 1



theorem circuit_composition {d : ℕ} (gates : List (Matrix (Fin d) (Fin d) ℂ))
    (ψ : Fin d → ℂ) :
    applyCircuit gates ψ = (circuitUnitary gates).mulVec ψ := by
  induction' gates using List.reverseRecOn with gates U hU;
  · unfold applyCircuit circuitUnitary; norm_num;
  · -- By definition of applyCircuit, we have:
    have h_applyCircuit : applyCircuit (gates ++ [U]) ψ = applyCircuit [U] (applyCircuit gates ψ) := by
      -- By definition of applyCircuit, we have applyCircuit (gates ++ [U]) ψ = applyCircuit [U] (applyCircuit gates ψ).
      have h_applyCircuit : ∀ (gates : List (Matrix (Fin d) (Fin d) ℂ)) (ψ : Fin d → ℂ), applyCircuit (gates ++ [U]) ψ = applyCircuit [U] (applyCircuit gates ψ) := by
        intros gates ψ; induction' gates with gates U hU generalizing ψ <;> simp_all +decide [ applyCircuit ] ;
      apply h_applyCircuit;
    simp_all +decide [ applyCircuit, circuitUnitary ];
    simp +decide [ applyGate, Matrix.mulVec_mulVec ]



theorem state_space_exponential (n : ℕ) :
    Fintype.card (Fin (2^n)) = 2^n := by
  convert Fintype.card_fin ( 2 ^ n )



theorem qubit_doubles_space (n : ℕ) :
    Fintype.card (Fin (2^(n+1))) = 2 * Fintype.card (Fin (2^n)) := by
  norm_num [ pow_succ' ]



theorem simulation_dimension (n : ℕ) :
    Module.finrank ℂ (Fin (2^n) → ℂ) = 2^n := by
  norm_num +zetaDelta at *



/-- The Hadamard gate: H = (1/√2) [[1, 1], [1, -1]] -/
noncomputable def hadamardGate : Matrix (Fin 2) (Fin 2) ℂ :=
  (↑(1 / Real.sqrt 2) : ℂ) • !![1, 1; 1, -1]



theorem pauliX_unitary : IsUnitaryGate pauliX := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, pauliX ] ;



theorem pauliZ_unitary : IsUnitaryGate pauliZ := by
  unfold IsUnitaryGate; norm_num [ pauliZ ] ;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Matrix.conjTranspose ]



theorem pauliX_involution : pauliX * pauliX = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ pauliX ]



theorem pauliZ_involution : pauliZ * pauliZ = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  -- By definition of matrix multiplication and the properties of the Pauli matrices, we can compute the product directly.
  ext i j; simp [pauliZ];
  fin_cases i <;> fin_cases j <;> rfl



theorem hadamard_unitary : IsUnitaryGate hadamardGate := by
  unfold hadamardGate IsUnitaryGate;
  ext i j ; fin_cases i <;> fin_cases j <;> norm_num [ Matrix.mul_apply, Complex.ext_iff ] <;> ring <;> norm_num [ ← Complex.ofReal_pow ] <;> norm_cast <;> norm_num [ Real.sqrt_div_self ] at * <;> first | linarith | aesop | assumption;



theorem hadamard_conjugation :
    hadamardGate * pauliZ * hadamardGate = pauliX := by
  ext i j; fin_cases i <;> fin_cases j <;> norm_num [ hadamardGate, pauliZ, pauliX ] <;> ring_nf <;> norm_num;
  · norm_num [ ← Complex.ofReal_pow ];
  · norm_num [ ← Complex.ofReal_pow ]



theorem no_cloning_inner_product {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℂ V]
    (ψ φ : V) (_hψ : ‖ψ‖ = 1) (_hφ : ‖φ‖ = 1)
    (h_clone : @inner ℂ V _ ψ φ = (@inner ℂ V _ ψ φ) ^ 2) :
    @inner ℂ V _ ψ φ = (0 : ℂ) ∨ @inner ℂ V _ ψ φ = (1 : ℂ) := by
  exact eq_zero_or_one_of_sq_eq_self (id (Eq.symm h_clone))



theorem quantum_is_linear_algebra {d : ℕ} (U : Matrix (Fin d) (Fin d) ℂ)
    (ψ₁ ψ₂ : Fin d → ℂ) (h : ψ₁ = ψ₂) :
    U.mulVec ψ₁ = U.mulVec ψ₂ := by
  rw [ h ]



end
