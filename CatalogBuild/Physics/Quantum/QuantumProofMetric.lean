/-! # CatalogBuild.Physics.Quantum.QuantumProofMetric

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A proof vector is a function from Fin n to ℂ, representing amplitudes
for each proof technique. -/
def ProofVector (n : ℕ) := Fin n → ℂ



/-- The inner product of two proof vectors. -/
noncomputable def proofInnerProduct {n : ℕ} (ψ φ : ProofVector n) : ℂ :=
  ∑ i : Fin n, (starRingEnd ℂ (ψ i)) * (φ i)



/-- The norm squared of a proof vector. -/
noncomputable def proofNormSq {n : ℕ} (ψ : ProofVector n) : ℝ :=
  (∑ i : Fin n, ‖ψ i‖ ^ 2)



/-- A proof vector is normalized if its norm squared equals 1. -/
def isNormalized {n : ℕ} (ψ : ProofVector n) : Prop :=
  proofNormSq ψ = 1



/-- The overlap (fidelity) between two proof vectors. -/
noncomputable def proofFidelity {n : ℕ} (ψ φ : ProofVector n) : ℝ :=
  ‖proofInnerProduct ψ φ‖



/-- The fidelity is non-negative. -/
theorem fidelity_nonneg {n : ℕ} (ψ φ : ProofVector n) :
    0 ≤ proofFidelity ψ φ := by
  exact norm_nonneg _



/-- [Section: # CatalogBuild.Physics.Quantum.QuantumProofMetric
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 16] -/
theorem self_fidelity_normalized {n : ℕ} (ψ : ProofVector n) (h : isNormalized ψ) :
    proofFidelity ψ ψ = proofNormSq ψ := by
  unfold proofFidelity proofNormSq proofInnerProduct;
  norm_num [ Complex.normSq, Complex.sq_norm ];
  convert Complex.norm_of_nonneg _;
  · simp +decide [ Complex.ext_iff, mul_comm ];
  · exact Finset.sum_nonneg fun _ _ => add_nonneg ( mul_self_nonneg _ ) ( mul_self_nonneg _ )



theorem fubiniStudy_self {n : ℕ} (ψ : ProofVector n) (h : isNormalized ψ) :
    fubiniStudyDist ψ ψ = 0 := by
  unfold fubiniStudyDist; have := self_fidelity_normalized ψ h; simp_all +decide [ isNormalized ] ;



theorem fubiniStudy_symm {n : ℕ} (ψ φ : ProofVector n) :
    fubiniStudyDist ψ φ = fubiniStudyDist φ ψ := by
  unfold fubiniStudyDist;
  -- Since ⟨ψ|φ⟩ = starRingEnd ℂ (⟨φ|ψ⟩), we have ‖⟨ψ|φ⟩‖ = ‖starRingEnd ℂ (⟨φ|ψ⟩)‖.
  have h_conj : proofInnerProduct ψ φ = starRingEnd ℂ (proofInnerProduct φ ψ) := by
    unfold proofInnerProduct; simp +decide [ mul_comm ] ;
  unfold proofFidelity; aesop;



/-- Two proof vectors are orthogonal if their inner product is zero. -/
def areOrthogonal {n : ℕ} (ψ φ : ProofVector n) : Prop :=
  proofInnerProduct ψ φ = 0



theorem orthogonal_zero_fidelity {n : ℕ} (ψ φ : ProofVector n)
    (h : areOrthogonal ψ φ) : proofFidelity ψ φ = 0 := by
  unfold proofFidelity; aesop;



/-- A unitary transformation on proof space (n×n unitary matrix). -/
structure ProofRefactoring (n : ℕ) where
  transform : ProofVector n → ProofVector n
  preserves_inner : ∀ ψ φ : ProofVector n,
    proofInnerProduct (transform ψ) (transform φ) = proofInnerProduct ψ φ



theorem refactoring_preserves_fidelity {n : ℕ} (U : ProofRefactoring n)
    (ψ φ : ProofVector n) :
    proofFidelity (U.transform ψ) (U.transform φ) = proofFidelity ψ φ := by
  exact congr_arg _ ( U.preserves_inner ψ φ )



theorem refactoring_preserves_distance {n : ℕ} (U : ProofRefactoring n)
    (ψ φ : ProofVector n) :
    fubiniStudyDist (U.transform ψ) (U.transform φ) = fubiniStudyDist ψ φ := by
  unfold fubiniStudyDist; exact congr_arg Real.arccos ( refactoring_preserves_fidelity U ψ φ ) ;



/-- A superposition of two proof strategies with amplitudes α and β. -/
noncomputable def proofSuperposition {n : ℕ} (α β : ℂ) (ψ φ : ProofVector n) :
    ProofVector n :=
  fun i => α * ψ i + β * φ i



theorem superposition_norm {n : ℕ} (α β : ℂ) (ψ φ : ProofVector n) :
    proofNormSq (proofSuperposition α β ψ φ) =
    ‖α‖^2 * proofNormSq ψ + ‖β‖^2 * proofNormSq φ +
    2 * ((starRingEnd ℂ α * β) * proofInnerProduct ψ φ).re := by
  unfold proofSuperposition proofNormSq proofInnerProduct;
  norm_num [ Complex.normSq, Complex.sq_norm ] ; ring!;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
  simpa only [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] using by ring;


end
