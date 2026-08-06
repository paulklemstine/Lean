import Novelty.IITTensorNetworkSchmidt

/-! # Bond dimension of matrix product states and the Schmidt rank bound

A tensor network state has *bond dimension at most `χ`* across a cut when its
coefficient matrix factors through a `χ`-dimensional auxiliary (virtual) space.
This is exactly the structure of a matrix product state (MPS) cut open at one
bond.  We prove:

* `schmidtRank_le_of_hasBondDim` : bond dimension bounds the Schmidt rank;
* `mutualInformation_le_two_log_bondDim` : hence the quantum mutual information
  across the cut is at most `2 log χ`;
* `mpsCutMatrix_factorization` and `hasBondDim_mpsCutMatrix` : an explicit MPS
  built from local tensors of bond dimension `χ` has bond dimension `χ`;
* `mutualInformation_mps_bondDim_two_le` : for bond dimension `2`, the mutual
  information across the cut is at most `2 log 2 = log 4`, the value attained by
  a maximally entangled qubit pair.
-/

open Finset Matrix
open scoped ComplexOrder

namespace IITTensorNetwork

section BondDimension

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- A bipartite coefficient matrix has *bond dimension at most `χ`* when it
factors through a `χ`-dimensional virtual space. -/
def HasBondDim (M : Matrix α β ℂ) (χ : ℕ) : Prop :=
  ∃ (L : Matrix α (Fin χ) ℂ) (R : Matrix (Fin χ) β ℂ), M = L * R

omit [Fintype α] [DecidableEq α] [DecidableEq β] in
/-- **Bond dimension bounds the Schmidt rank.** -/
theorem schmidtRank_le_of_hasBondDim {M : Matrix α β ℂ} {χ : ℕ} (h : HasBondDim M χ) :
    schmidtRank M ≤ χ := by
  obtain ⟨L, R, rfl⟩ := h
  calc (L * R).rank ≤ L.rank := Matrix.rank_mul_le_left L R
    _ ≤ Fintype.card (Fin χ) := Matrix.rank_le_card_width L
    _ = χ := Fintype.card_fin χ

/-- **Bond dimension bounds the quantum mutual information across the cut.** -/
theorem mutualInformation_le_two_log_bondDim {M : Matrix α β ℂ} {χ : ℕ}
    (hM : Normalized M) (h : HasBondDim M χ) :
    mutualInformation M ≤ 2 * Real.log χ := by
  have hrank := schmidtRank_le_of_hasBondDim h
  have hpos : 1 ≤ schmidtRank M := schmidtRank_pos hM
  have hlog : Real.log (schmidtRank M) ≤ Real.log χ := by
    apply Real.log_le_log
    · exact_mod_cast hpos
    · exact_mod_cast hrank
  have := mutualInformation_le_two_log_schmidtRank hM
  linarith

/-- For bond dimension two the mutual information across the cut is at most
`2 log 2 = log 4`. -/
theorem mutualInformation_le_log_four {M : Matrix α β ℂ}
    (hM : Normalized M) (h : HasBondDim M 2) :
    mutualInformation M ≤ 2 * Real.log 2 := by
  have := mutualInformation_le_two_log_bondDim hM h
  norm_num at this
  exact this

omit [Fintype α] [Fintype β] in
/-- A maximally entangled state whose Schmidt vectors are labelled by `Fin χ`
has bond dimension `χ`. -/
theorem hasBondDim_maxEntState {χ : ℕ} (c : ℝ) (u : Fin χ → α) (v : Fin χ → β) :
    HasBondDim (maxEntState c u v) χ :=
  ⟨(c : ℂ) • isoMatrix u, (isoMatrix v)ᴴ, by rw [maxEntState, Matrix.smul_mul]⟩

omit [Fintype α] [Fintype β] in
/-- The canonical maximally entangled state of Schmidt rank `χ` has bond
dimension `χ`. -/
theorem hasBondDim_maxEnt {χ : ℕ} (u : Fin χ → α) (v : Fin χ → β) :
    HasBondDim (maxEnt u v) χ :=
  hasBondDim_maxEntState _ u v

end BondDimension

section MPS

variable {l m d χ : ℕ}

/-- The ordered product of the local tensors of the left block along a
configuration of the left block. -/
noncomputable def leftProd (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (f : Fin l → Fin d) :
    Matrix (Fin χ) (Fin χ) ℂ :=
  Fin.foldr l (fun i acc => A i (f i) * acc) 1

/-- The ordered product of the local tensors of the right block along a
configuration of the right block. -/
noncomputable def rightProd (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (g : Fin m → Fin d) :
    Matrix (Fin χ) (Fin χ) ℂ :=
  Fin.foldr m (fun j acc => B j (g j) * acc) 1

/-- The coefficient matrix, across the bond joining the two blocks, of the
matrix product state with local tensors `A` (left block), `B` (right block) and
boundary vectors `vL`, `vR`. -/
noncomputable def mpsCutMatrix (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vL vR : Fin χ → ℂ) :
    Matrix (Fin l → Fin d) (Fin m → Fin d) ℂ :=
  Matrix.of fun f g => vL ⬝ᵥ ((leftProd A f * rightProd B g) *ᵥ vR)

/-- The left environment matrix obtained by cutting the MPS at the bond. -/
noncomputable def mpsLeftEnv (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vL : Fin χ → ℂ) :
    Matrix (Fin l → Fin d) (Fin χ) ℂ :=
  Matrix.of fun f b => (vL ᵥ* leftProd A f) b

/-- The right environment matrix obtained by cutting the MPS at the bond. -/
noncomputable def mpsRightEnv (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vR : Fin χ → ℂ) :
    Matrix (Fin χ) (Fin m → Fin d) ℂ :=
  Matrix.of fun b g => (rightProd B g *ᵥ vR) b

/-- **Cutting an MPS at a bond.**  The coefficient matrix of a matrix product
state factors, across the bond, into a left environment matrix and a right
environment matrix joined by the `χ`-dimensional bond index. -/
theorem mpsCutMatrix_factorization (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vL vR : Fin χ → ℂ) :
    mpsCutMatrix A B vL vR = mpsLeftEnv A vL * mpsRightEnv B vR := by
  ext f g
  show vL ⬝ᵥ ((leftProd A f * rightProd B g) *ᵥ vR)
      = ∑ b, (vL ᵥ* leftProd A f) b * (rightProd B g *ᵥ vR) b
  rw [← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec]
  rfl

/-- An MPS with bond dimension `χ` has bond dimension at most `χ` across its
bond, in the sense of `HasBondDim`. -/
theorem hasBondDim_mpsCutMatrix (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vL vR : Fin χ → ℂ) :
    HasBondDim (mpsCutMatrix A B vL vR) χ :=
  ⟨_, _, mpsCutMatrix_factorization A B vL vR⟩

/-- **Schmidt rank of an MPS is bounded by its bond dimension.** -/
theorem schmidtRank_mpsCutMatrix_le (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vL vR : Fin χ → ℂ) :
    schmidtRank (mpsCutMatrix A B vL vR) ≤ χ :=
  schmidtRank_le_of_hasBondDim (hasBondDim_mpsCutMatrix A B vL vR)

/-- **Mutual information of an MPS is bounded by `2 log χ`.** -/
theorem mutualInformation_mpsCutMatrix_le (A : Fin l → Fin d → Matrix (Fin χ) (Fin χ) ℂ)
    (B : Fin m → Fin d → Matrix (Fin χ) (Fin χ) ℂ) (vL vR : Fin χ → ℂ)
    (hnorm : Normalized (mpsCutMatrix A B vL vR)) :
    mutualInformation (mpsCutMatrix A B vL vR) ≤ 2 * Real.log χ :=
  mutualInformation_le_two_log_bondDim hnorm (hasBondDim_mpsCutMatrix A B vL vR)

/-- **Bond dimension two.**  Every MPS with bond dimension `2` carries at most
`2 log 2 = log 4` of quantum mutual information across its bond. -/
theorem mutualInformation_mps_bondDim_two_le (A : Fin l → Fin d → Matrix (Fin 2) (Fin 2) ℂ)
    (B : Fin m → Fin d → Matrix (Fin 2) (Fin 2) ℂ) (vL vR : Fin 2 → ℂ)
    (hnorm : Normalized (mpsCutMatrix A B vL vR)) :
    mutualInformation (mpsCutMatrix A B vL vR) ≤ 2 * Real.log 2 := by
  have := mutualInformation_mpsCutMatrix_le A B vL vR hnorm
  norm_num at this
  exact this

end MPS

end IITTensorNetwork