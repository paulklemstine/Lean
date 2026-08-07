/-
  # Local Unitary Invariance and the Reduced Density Matrix

  Cycle-2 deepening of the entanglement/linking dictionary.

  Having identified entanglement with a linking number
  (`Pythagorean.HopfLinkingEntanglement`), the natural next question is
  *invariance*: a topological invariant must be unchanged by the symmetries of
  the situation.  For two-qubit states those symmetries are the **local
  unitaries** `U ⊗ V`, the operations that Alice and Bob can perform on their own
  qubits without communicating.

  Main results.

  * `coeffMatrix_localAct`, `entanglementDet_localAct` — under `ψ ↦ (A ⊗ B) ψ`
    the coefficient matrix transforms as `M ↦ A M Bᵀ`, hence the entanglement
    determinant is multiplied by `det A · det B`.
  * `normSq_localAct` — local unitaries preserve the norm of the state
    (Frobenius norm invariance, proved through the trace).
  * `concurrence_localUnitary_invariant` — **concurrence is a local-unitary
    invariant**.
  * `stateLinkingNumber_localUnitary_invariant` — **the linking number of the
    two Hopf circles is a local-unitary invariant**: the topological
    classification is intrinsic, not an artefact of the chosen basis.
  * `su2_four_square` — the Euler/Gauss two-square identity for complex numbers
    *is* the statement that `SU(2)` preserves the Hermitian norm; the arithmetic
    face of the same fact is `pythagorean_quadruple_of_gaussian`.
  * `det_rhoA`, `trace_rhoA`, `purity_eq` — the reduced density matrix
    `ρ_A = M Mᴴ` satisfies `det ρ_A = C²/4` and `Tr(ρ_A²) = ‖ψ‖⁴ - C²/2`.
  * `entangled_iff_rhoA_nondegenerate`, `maximally_entangled_iff_purity_half` —
    entanglement is exactly the degeneracy defect of the reduced state, and
    maximal entanglement is exactly the maximally mixed reduced state.
-/
import Mathlib
import Bridges.QuantumSystems.QuantumEntanglementLinkingNumber
import Pythagorean.HopfEntanglementGeometry
import Pythagorean.HopfLinkingEntanglement

open Complex Matrix

noncomputable section

namespace EntanglementInvariance

open TwoQubitState HopfLink

/-! ## The coefficient matrix and the local unitary action -/

/-- The coefficient matrix `M = !![α, β; γ, δ]` of a two-qubit state. -/
def coeffMatrix (ψ : TwoQubitState) : Matrix (Fin 2) (Fin 2) ℂ := !![ψ.α, ψ.β; ψ.γ, ψ.δ]

/-- A `2 × 2` complex matrix, read back as a two-qubit state. -/
def ofMatrix (M : Matrix (Fin 2) (Fin 2) ℂ) : TwoQubitState :=
  ⟨M 0 0, M 0 1, M 1 0, M 1 1⟩

@[simp] lemma coeffMatrix_ofMatrix (M : Matrix (Fin 2) (Fin 2) ℂ) :
    coeffMatrix (ofMatrix M) = M := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [coeffMatrix, ofMatrix]

@[simp] lemma ofMatrix_coeffMatrix (ψ : TwoQubitState) : ofMatrix (coeffMatrix ψ) = ψ := by
  cases ψ; simp [coeffMatrix, ofMatrix]

lemma det_coeffMatrix (ψ : TwoQubitState) : (coeffMatrix ψ).det = ψ.entanglementDet := by
  simp [coeffMatrix, Matrix.det_fin_two, TwoQubitState.entanglementDet]

lemma normSq_eq_trace (ψ : TwoQubitState) :
    (ψ.normSq : ℂ) = Matrix.trace (coeffMatrix ψ * (coeffMatrix ψ)ᴴ) := by
  simp only [coeffMatrix, TwoQubitState.normSq, Matrix.trace_fin_two, Matrix.mul_apply,
    Fin.sum_univ_two, Matrix.conjTranspose_apply, RCLike.star_def]
  norm_num [Complex.normSq_eq_conj_mul_self]
  ring

/-- The action of a local operation `A ⊗ B` on a two-qubit state: on coefficient
matrices it is `M ↦ A M Bᵀ`. -/
def localAct (A B : Matrix (Fin 2) (Fin 2) ℂ) (ψ : TwoQubitState) : TwoQubitState :=
  ofMatrix (A * coeffMatrix ψ * Bᵀ)

@[simp] lemma coeffMatrix_localAct (A B : Matrix (Fin 2) (Fin 2) ℂ) (ψ : TwoQubitState) :
    coeffMatrix (localAct A B ψ) = A * coeffMatrix ψ * Bᵀ := by
  simp [localAct]

/-- **Transformation law of the entanglement determinant.**  Under a local
operation the entanglement determinant is multiplied by `det A · det B`. -/
theorem entanglementDet_localAct (A B : Matrix (Fin 2) (Fin 2) ℂ) (ψ : TwoQubitState) :
    (localAct A B ψ).entanglementDet = A.det * B.det * ψ.entanglementDet := by
  rw [← det_coeffMatrix, coeffMatrix_localAct, Matrix.det_mul, Matrix.det_mul,
    Matrix.det_transpose, det_coeffMatrix]
  ring

/-! ## Unitarity -/

/-- A unitary matrix has determinant of modulus one. -/
lemma norm_det_of_unitary {A : Matrix (Fin 2) (Fin 2) ℂ} (hA : Aᴴ * A = 1) : ‖A.det‖ = 1 := by
  have h : (starRingEnd ℂ) A.det * A.det = 1 := by
    have hd := congrArg Matrix.det hA
    rwa [Matrix.det_mul, Matrix.det_conjTranspose, Matrix.det_one] at hd
  have h2 : ((Complex.normSq A.det : ℝ) : ℂ) = 1 := by
    rw [Complex.normSq_eq_conj_mul_self]; exact h
  have h3 : Complex.normSq A.det = 1 := by exact_mod_cast h2
  have h4 : ‖A.det‖ ^ 2 = 1 := by rw [← Complex.normSq_eq_norm_sq]; exact h3
  nlinarith [norm_nonneg A.det]

/-- Left multiplication by a unitary preserves the Frobenius trace form. -/
lemma trace_unitary_left (A X : Matrix (Fin 2) (Fin 2) ℂ) (hA : Aᴴ * A = 1) :
    Matrix.trace (A * X * (A * X)ᴴ) = Matrix.trace (X * Xᴴ) := by
  calc Matrix.trace (A * X * (A * X)ᴴ) = Matrix.trace (A * (X * Xᴴ * Aᴴ)) := by
        rw [Matrix.conjTranspose_mul]; simp [Matrix.mul_assoc]
    _ = Matrix.trace (X * Xᴴ * Aᴴ * A) := Matrix.trace_mul_comm _ _
    _ = Matrix.trace (X * Xᴴ) := by rw [Matrix.mul_assoc, hA, Matrix.mul_one]

/-- Right multiplication by the transpose of a unitary preserves the Frobenius
trace form. -/
lemma trace_unitary_right (X B : Matrix (Fin 2) (Fin 2) ℂ) (hB : Bᴴ * B = 1) :
    Matrix.trace (X * Bᵀ * (X * Bᵀ)ᴴ) = Matrix.trace (X * Xᴴ) := by
  have hBT : Bᵀ * (Bᵀ)ᴴ = 1 := by
    have h := congrArg Matrix.transpose hB
    rw [Matrix.transpose_mul, Matrix.transpose_one, Matrix.conjTranspose_transpose] at h
    rw [Matrix.transpose_conjTranspose]
    exact h
  calc Matrix.trace (X * Bᵀ * (X * Bᵀ)ᴴ) = Matrix.trace (X * (Bᵀ * (Bᵀ)ᴴ) * Xᴴ) := by
        rw [Matrix.conjTranspose_mul]; simp [Matrix.mul_assoc]
    _ = Matrix.trace (X * Xᴴ) := by rw [hBT, Matrix.mul_one]

/-- **Local unitaries preserve the norm of the state.**  This is Frobenius-norm
invariance, obtained from cyclicity of the trace. -/
theorem normSq_localAct {A B : Matrix (Fin 2) (Fin 2) ℂ} (hA : Aᴴ * A = 1) (hB : Bᴴ * B = 1)
    (ψ : TwoQubitState) : (localAct A B ψ).normSq = ψ.normSq := by
  have key : ((localAct A B ψ).normSq : ℂ) = (ψ.normSq : ℂ) := by
    rw [normSq_eq_trace, normSq_eq_trace, coeffMatrix_localAct]
    set M := coeffMatrix ψ with hM
    have hassoc : A * M * Bᵀ = A * (M * Bᵀ) := Matrix.mul_assoc _ _ _
    rw [hassoc, trace_unitary_left _ _ hA, trace_unitary_right _ _ hB]
  exact_mod_cast key

/-- **Concurrence is a local-unitary invariant.** -/
theorem concurrence_localUnitary_invariant {A B : Matrix (Fin 2) (Fin 2) ℂ}
    (hA : Aᴴ * A = 1) (hB : Bᴴ * B = 1) (ψ : TwoQubitState) :
    (localAct A B ψ).concurrence = ψ.concurrence := by
  simp only [TwoQubitState.concurrence, entanglementDet_localAct, norm_mul,
    norm_det_of_unitary hA, norm_det_of_unitary hB, one_mul]

/-- **The linking number is a local-unitary invariant.**  Together with
`entangled_iff_linked` this says the topological classification of a two-qubit
state is intrinsic: no change of local basis can create or destroy the link. -/
theorem stateLinkingNumber_localUnitary_invariant {A B : Matrix (Fin 2) (Fin 2) ℂ}
    (hA : Aᴴ * A = 1) (hB : Bᴴ * B = 1) (ψ : TwoQubitState) :
    stateLinkingNumber (localAct A B ψ) = stateLinkingNumber ψ := by
  rw [HopfLink.stateLinkingNumber_eq_ite, HopfLink.stateLinkingNumber_eq_ite,
    concurrence_localUnitary_invariant hA hB ψ]

/-! ## `SU(2)` and the two-square identity -/

/-- The generic element of `SU(2)`: `!![a, b; -b̄, ā]` with `|a|² + |b|² = 1`. -/
def su2 (a b : ℂ) : Matrix (Fin 2) (Fin 2) ℂ :=
  !![a, b; -(starRingEnd ℂ) b, (starRingEnd ℂ) a]

lemma det_su2 (a b : ℂ) :
    (su2 a b).det = ((Complex.normSq a + Complex.normSq b : ℝ) : ℂ) := by
  simp [su2, Matrix.det_fin_two, Complex.normSq_eq_conj_mul_self]
  ring

/-- **The Gauss two-square identity as unitarity of `SU(2)`.**
`|ax + by|² + |-b̄x + āy|² = (|a|²+|b|²)(|x|²+|y|²)`; with `|a|²+|b|² = 1` this
is exactly the statement that `SU(2)` acts by isometries.  Over the Gaussian
integers this is the composition law for sums of four squares. -/
theorem su2_four_square (a b x y : ℂ) :
    Complex.normSq (a * x + b * y)
      + Complex.normSq (-(starRingEnd ℂ) b * x + (starRingEnd ℂ) a * y)
      = (Complex.normSq a + Complex.normSq b) * (Complex.normSq x + Complex.normSq y) := by
  simp only [Complex.normSq_apply, Complex.add_re, Complex.add_im, Complex.mul_re,
    Complex.mul_im, Complex.neg_re, Complex.neg_im, Complex.conj_re, Complex.conj_im]
  ring

/-- `SU(2)` matrices are unitary. -/
lemma su2_unitary (a b : ℂ) (h : Complex.normSq a + Complex.normSq b = 1) :
    (su2 a b)ᴴ * (su2 a b) = 1 := by
  have hab : (starRingEnd ℂ) a * a + (starRingEnd ℂ) b * b = 1 := by
    rw [← Complex.normSq_eq_conj_mul_self, ← Complex.normSq_eq_conj_mul_self]
    exact_mod_cast congrArg (fun r : ℝ => (r : ℂ)) h
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [su2, Matrix.mul_apply, Fin.sum_univ_two] <;>
    (first | linear_combination hab | linear_combination -hab | linear_combination (0:ℂ) * hab)

/-- Local `SU(2) × SU(2)` transformations preserve both norm and concurrence:
the physical statement that entanglement cannot be created locally. -/
theorem concurrence_su2_invariant (a b c d : ℂ)
    (ha : Complex.normSq a + Complex.normSq b = 1)
    (hc : Complex.normSq c + Complex.normSq d = 1) (ψ : TwoQubitState) :
    (localAct (su2 a b) (su2 c d) ψ).concurrence = ψ.concurrence :=
  concurrence_localUnitary_invariant (su2_unitary a b ha) (su2_unitary c d hc) ψ

/-! ## The reduced density matrix -/

/-- Alice's reduced density matrix `ρ_A = M Mᴴ` (up to normalisation). -/
def rhoA (ψ : TwoQubitState) : Matrix (Fin 2) (Fin 2) ℂ :=
  coeffMatrix ψ * (coeffMatrix ψ)ᴴ

/-- The trace of the reduced density matrix is the norm of the state. -/
theorem trace_rhoA (ψ : TwoQubitState) : Matrix.trace (rhoA ψ) = (ψ.normSq : ℂ) :=
  (normSq_eq_trace ψ).symm

/-- **Determinant of the reduced density matrix is a quarter of `C²`.**
`det ρ_A = |αδ - βγ|² = C(ψ)²/4`.  This is the bridge between the topological
invariant and the operational one: `ρ_A` degenerates exactly on product states. -/
theorem det_rhoA (ψ : TwoQubitState) :
    (rhoA ψ).det = ((ψ.concurrence ^ 2 / 4 : ℝ) : ℂ) := by
  have h : (rhoA ψ).det = (coeffMatrix ψ).det * (starRingEnd ℂ) ((coeffMatrix ψ).det) := by
    rw [rhoA, Matrix.det_mul, Matrix.det_conjTranspose]
    rfl
  rw [h, det_coeffMatrix, mul_comm, ← Complex.normSq_eq_conj_mul_self]
  have hn : Complex.normSq ψ.entanglementDet = ‖ψ.entanglementDet‖ ^ 2 :=
    Complex.normSq_eq_norm_sq _
  rw [hn]
  simp only [TwoQubitState.concurrence]
  push_cast
  ring

/-- Cayley–Hamilton in dimension two: `Tr(ρ²) = (Tr ρ)² - 2 det ρ`. -/
lemma trace_sq_two (R : Matrix (Fin 2) (Fin 2) ℂ) :
    Matrix.trace (R * R) = (Matrix.trace R) ^ 2 - 2 * R.det := by
  simp [Matrix.trace_fin_two, Matrix.mul_apply, Fin.sum_univ_two, Matrix.det_fin_two]
  ring

/-- **Purity of the reduced state.**  `Tr(ρ_A²) = ‖ψ‖⁴ - C(ψ)²/2`;
for a normalised state, `Tr(ρ_A²) = 1 - C²/2`.  Concurrence is exactly the
linear entropy of the reduced state. -/
theorem purity_eq (ψ : TwoQubitState) :
    Matrix.trace (rhoA ψ * rhoA ψ) = ((ψ.normSq ^ 2 - ψ.concurrence ^ 2 / 2 : ℝ) : ℂ) := by
  rw [trace_sq_two, trace_rhoA, det_rhoA]
  push_cast
  ring

/-- For a normalised state the purity is `1 - C²/2`. -/
theorem purity_normalized (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    Matrix.trace (rhoA ψ * rhoA ψ) = ((1 - ψ.concurrence ^ 2 / 2 : ℝ) : ℂ) := by
  rw [purity_eq, h]
  norm_num

/-- **Entanglement is the nondegeneracy of the reduced state.**  A state is
entangled iff its reduced density matrix is invertible (nonzero determinant). -/
theorem entangled_iff_rhoA_nondegenerate (ψ : TwoQubitState) :
    ψ.concurrence ≠ 0 ↔ (rhoA ψ).det ≠ 0 := by
  rw [det_rhoA]
  constructor
  · intro hC h0
    have : ψ.concurrence ^ 2 / 4 = 0 := by exact_mod_cast h0
    have : ψ.concurrence ^ 2 = 0 := by linarith
    exact hC (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this)
  · intro hd hC
    exact hd (by rw [hC]; norm_num)

/-- Chaining the three descriptions: linked ⇔ entangled ⇔ mixed reduced state. -/
theorem linked_iff_rhoA_nondegenerate (ψ : TwoQubitState) :
    stateLinkingNumber ψ = 1 ↔ (rhoA ψ).det ≠ 0 := by
  rw [← HopfLink.entangled_iff_linked, entangled_iff_rhoA_nondegenerate]

/-- **Maximal entanglement is maximal mixedness.**  A normalised state has
`C(ψ) = 1` iff the purity of its reduced state is `1/2`, the minimum possible. -/
theorem maximally_entangled_iff_purity_half (ψ : TwoQubitState) (h : ψ.IsNormalized) :
    ψ.concurrence = 1 ↔ Matrix.trace (rhoA ψ * rhoA ψ) = ((1/2 : ℝ) : ℂ) := by
  rw [purity_normalized ψ h]
  constructor
  · intro hC; rw [hC]; norm_num
  · intro hp
    have : (1 : ℝ) - ψ.concurrence ^ 2 / 2 = 1/2 := by exact_mod_cast hp
    have hsq : ψ.concurrence ^ 2 = 1 := by linarith
    nlinarith [TwoQubitState.concurrence_nonneg ψ]

end EntanglementInvariance