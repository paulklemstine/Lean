import Novelty.IITTensorNetworkEntropy

/-! # Bipartite pure states, Schmidt rank and quantum mutual information

A pure state of a bipartite quantum system `A ⊗ B` with finite local index sets
`α` and `β` is encoded by its coefficient matrix `M : Matrix α β ℂ`, normalized
by `∑ i j, ‖M i j‖ ^ 2 = 1`.  The two reduced density matrices are `M * Mᴴ`
(on `A`) and `Mᴴ * M` (on `B`), the *Schmidt rank* across the cut is the rank of
`M`, and, since the global state is pure, the quantum mutual information across
the cut is

`I(A : B) = S(ρ_A) + S(ρ_B) - S(ρ_AB) = S(ρ_A) + S(ρ_B)`.

Main results:

* `rhoLeft_trace`, `rhoRight_trace` : the reduced matrices are density matrices;
* `schmidtRank_pos` : the Schmidt rank of a normalized state is at least one;
* `mutualInformation_nonneg`;
* `mutualInformation_le_two_log_schmidtRank` : the mutual information across a
  cut is at most `2 log (Schmidt rank)`;
* `mutualInformation_eq_zero_iff_schmidtRank_eq_one` : the mutual information
  vanishes exactly for product states across the cut;
* `vnEntropy_rhoLeft_eq_rhoRight` : the two marginal entropies of a pure state
  agree (equal-dimension parts), so `I(A : B) = 2 S(ρ_A)`;
* `mutualInformation_flat` : a flat Schmidt spectrum of rank `r` gives
  `I(A : B) = 2 log r`, the maximum allowed by the Schmidt rank.
-/

open Finset Matrix
open scoped ComplexOrder

namespace IITTensorNetwork

section Bipartite

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- Normalization of the coefficient matrix of a pure bipartite state. -/
def Normalized (M : Matrix α β ℂ) : Prop := ∑ i, ∑ j, ‖M i j‖ ^ 2 = 1

/-- The reduced density matrix on the left factor. -/
noncomputable def rhoLeft (M : Matrix α β ℂ) : Matrix α α ℂ := M * Mᴴ

/-- The reduced density matrix on the right factor. -/
noncomputable def rhoRight (M : Matrix α β ℂ) : Matrix β β ℂ := Mᴴ * M

/-- The Schmidt rank of a bipartite pure state across the given cut. -/
noncomputable def schmidtRank (M : Matrix α β ℂ) : ℕ := M.rank

omit [DecidableEq α] [DecidableEq β] in
lemma rhoLeft_posSemidef (M : Matrix α β ℂ) : (rhoLeft M).PosSemidef :=
  Matrix.posSemidef_self_mul_conjTranspose M

omit [DecidableEq α] [DecidableEq β] in
lemma rhoRight_posSemidef (M : Matrix α β ℂ) : (rhoRight M).PosSemidef :=
  Matrix.posSemidef_conjTranspose_mul_self M

omit [DecidableEq α] [DecidableEq β] in
lemma rhoLeft_trace {M : Matrix α β ℂ} (hM : Normalized M) : (rhoLeft M).trace = 1 := by
  have h : (rhoLeft M).trace = ∑ i, ∑ j, ((‖M i j‖ ^ 2 : ℝ) : ℂ) := by
    simp [rhoLeft, Matrix.trace, Matrix.mul_apply, Matrix.conjTranspose_apply, Complex.mul_conj']
  rw [h]
  exact_mod_cast congrArg (fun x : ℝ => (x : ℂ)) hM

omit [DecidableEq α] [DecidableEq β] in
lemma rhoRight_trace {M : Matrix α β ℂ} (hM : Normalized M) : (rhoRight M).trace = 1 := by
  have h : (rhoRight M).trace = ∑ j, ∑ i, ((‖M i j‖ ^ 2 : ℝ) : ℂ) := by
    simp [rhoRight, Matrix.trace, Matrix.mul_apply, Matrix.conjTranspose_apply,
      Complex.mul_conj', mul_comm]
  rw [h, Finset.sum_comm]
  exact_mod_cast congrArg (fun x : ℝ => (x : ℂ)) hM

omit [DecidableEq α] [DecidableEq β] in
@[simp] lemma rank_rhoLeft (M : Matrix α β ℂ) : (rhoLeft M).rank = schmidtRank M :=
  Matrix.rank_self_mul_conjTranspose M

omit [DecidableEq α] [DecidableEq β] in
@[simp] lemma rank_rhoRight (M : Matrix α β ℂ) : (rhoRight M).rank = schmidtRank M :=
  Matrix.rank_conjTranspose_mul_self M

/-- **Quantum mutual information** across the cut of a bipartite *pure* state:
the sum of the two marginal entropies (the global entropy vanishes). -/
noncomputable def mutualInformation (M : Matrix α β ℂ) : ℝ :=
  vnEntropy (rhoLeft M) + vnEntropy (rhoRight M)

/-- The entanglement entropy of the left marginal. -/
noncomputable def entanglementEntropy (M : Matrix α β ℂ) : ℝ := vnEntropy (rhoLeft M)

omit [DecidableEq β] in
/-- A normalized bipartite state has Schmidt rank at least one. -/
theorem schmidtRank_pos {M : Matrix α β ℂ} (hM : Normalized M) : 1 ≤ schmidtRank M := by
  have hps := rhoLeft_posSemidef M
  have hsum := sum_eigenvalues_eq_one hps (rhoLeft_trace hM)
  have hne := support_nonempty hsum
  have hrk : (rhoLeft M).rank = (support hps.isHermitian.eigenvalues).card :=
    rank_eq_card_support hps.isHermitian
  rw [rank_rhoLeft] at hrk
  rw [hrk]
  exact Finset.card_pos.mpr hne

omit [DecidableEq β] in
/-- Marginal entropies of a normalized bipartite state are nonnegative. -/
theorem entanglementEntropy_nonneg {M : Matrix α β ℂ} (hM : Normalized M) :
    0 ≤ entanglementEntropy M :=
  vnEntropy_nonneg (rhoLeft_posSemidef M) (rhoLeft_trace hM)

/-- Quantum mutual information across a cut is nonnegative. -/
theorem mutualInformation_nonneg {M : Matrix α β ℂ} (hM : Normalized M) :
    0 ≤ mutualInformation M :=
  add_nonneg (vnEntropy_nonneg (rhoLeft_posSemidef M) (rhoLeft_trace hM))
    (vnEntropy_nonneg (rhoRight_posSemidef M) (rhoRight_trace hM))

omit [DecidableEq β] in
/-- **Entropy–Schmidt rank bound.**  The entanglement entropy across a cut is at
most the logarithm of the Schmidt rank. -/
theorem entanglementEntropy_le_log_schmidtRank {M : Matrix α β ℂ} (hM : Normalized M) :
    entanglementEntropy M ≤ Real.log (schmidtRank M) := by
  have := vnEntropy_le_log_rank (rhoLeft_posSemidef M) (rhoLeft_trace hM)
  rwa [rank_rhoLeft] at this

/-- **Mutual information–Schmidt rank bound.**  Across any cut, the quantum
mutual information of a pure state is at most `2 log` of the Schmidt rank. -/
theorem mutualInformation_le_two_log_schmidtRank {M : Matrix α β ℂ} (hM : Normalized M) :
    mutualInformation M ≤ 2 * Real.log (schmidtRank M) := by
  have h1 := vnEntropy_le_log_rank (rhoLeft_posSemidef M) (rhoLeft_trace hM)
  have h2 := vnEntropy_le_log_rank (rhoRight_posSemidef M) (rhoRight_trace hM)
  rw [rank_rhoLeft] at h1
  rw [rank_rhoRight] at h2
  simp only [mutualInformation]
  linarith

/-- **Reducibility criterion.**  The quantum mutual information across a cut
vanishes exactly when the state is a product state across that cut, i.e. exactly
when the Schmidt rank equals one. -/
theorem mutualInformation_eq_zero_iff_schmidtRank_eq_one {M : Matrix α β ℂ}
    (hM : Normalized M) : mutualInformation M = 0 ↔ schmidtRank M = 1 := by
  have h1 := vnEntropy_eq_zero_iff_rank_eq_one (rhoLeft_posSemidef M) (rhoLeft_trace hM)
  have h2 := vnEntropy_eq_zero_iff_rank_eq_one (rhoRight_posSemidef M) (rhoRight_trace hM)
  rw [rank_rhoLeft] at h1
  rw [rank_rhoRight] at h2
  have hn1 : 0 ≤ vnEntropy (rhoLeft M) :=
    vnEntropy_nonneg (rhoLeft_posSemidef M) (rhoLeft_trace hM)
  have hn2 : 0 ≤ vnEntropy (rhoRight M) :=
    vnEntropy_nonneg (rhoRight_posSemidef M) (rhoRight_trace hM)
  constructor
  · intro h
    have : vnEntropy (rhoLeft M) = 0 := by
      simp only [mutualInformation] at h
      linarith
    exact h1.mp this
  · intro h
    simp only [mutualInformation, h1.mpr h, h2.mpr h, add_zero]

end Bipartite

section Symmetry

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- **Marginal entropies of a pure state agree.**  For a bipartite pure state
whose two parts have the same index type, the entropy of the left marginal
equals the entropy of the right marginal. -/
theorem vnEntropy_rhoLeft_eq_rhoRight (M : Matrix α α ℂ) :
    vnEntropy (rhoLeft M) = vnEntropy (rhoRight M) := by
  rw [vnEntropy_eq_multiset_sum (rhoLeft_posSemidef M).isHermitian,
    vnEntropy_eq_multiset_sum (rhoRight_posSemidef M).isHermitian]
  congr 2
  exact congrArg Polynomial.roots (Matrix.charpoly_mul_comm M Mᴴ)

/-- For a pure bipartite state with equal-dimension parts, the quantum mutual
information across the cut is twice the entanglement entropy. -/
theorem mutualInformation_eq_two_mul_entanglementEntropy (M : Matrix α α ℂ) :
    mutualInformation M = 2 * entanglementEntropy M := by
  rw [mutualInformation, entanglementEntropy, ← vnEntropy_rhoLeft_eq_rhoRight M]
  ring

end Symmetry

section MaximallyEntangled

variable {α β γ : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  [Fintype γ] [DecidableEq γ] {u : γ → α} {v : γ → β}

omit [DecidableEq α] [DecidableEq β] in
lemma trace_rhoLeft_eq (M : Matrix α β ℂ) :
    (rhoLeft M).trace = ((∑ i, ∑ j, ‖M i j‖ ^ 2 : ℝ) : ℂ) := by
  push_cast
  simp [rhoLeft, Matrix.trace, Matrix.mul_apply, Matrix.conjTranspose_apply, Complex.mul_conj']

omit [DecidableEq α] [DecidableEq β] in
/-- Normalization is equivalent to the left marginal having unit trace. -/
lemma normalized_iff_trace_rhoLeft (M : Matrix α β ℂ) :
    Normalized M ↔ (rhoLeft M).trace = 1 := by
  rw [trace_rhoLeft_eq M, Normalized]
  constructor
  · intro h; rw [h]; norm_num
  · intro h; exact_mod_cast h

/-- The isometry matrix attached to a labelling `u : γ → α` of Schmidt vectors. -/
def isoMatrix (u : γ → α) : Matrix α γ ℂ := fun f x => if u x = f then 1 else 0

omit [Fintype γ] in
lemma isoMatrix_conjTranspose_mul (hu : Function.Injective u) :
    (isoMatrix u)ᴴ * isoMatrix u = 1 := by
  ext x y
  rw [Matrix.mul_apply, Matrix.one_apply]
  by_cases hxy : x = y
  · subst hxy
    rw [if_pos rfl, Finset.sum_eq_single (u x)]
    · simp [isoMatrix]
    · intro f _ hf
      simp [isoMatrix, Matrix.conjTranspose_apply, Ne.symm hf]
    · intro h
      exact absurd (Finset.mem_univ (u x)) h
  · rw [if_neg hxy]
    refine Finset.sum_eq_zero fun f _ => ?_
    simp only [isoMatrix, Matrix.conjTranspose_apply, RCLike.star_def]
    by_cases h1 : u x = f
    · have h2 : u y ≠ f := fun h => hxy (hu (h1.trans h.symm))
      simp [h1, h2]
    · simp [h1]

omit [Fintype α] [DecidableEq γ] in
lemma isoMatrix_mul_conjTranspose (hu : Function.Injective u) :
    isoMatrix u * (isoMatrix u)ᴴ
      = Matrix.diagonal (fun f => if f ∈ Finset.image u Finset.univ then (1 : ℂ) else 0) := by
  ext f f'
  rw [Matrix.mul_apply, Matrix.diagonal_apply]
  by_cases hff : f = f'
  · subst hff
    rw [if_pos rfl]
    by_cases hmem : f ∈ Finset.image u Finset.univ
    · obtain ⟨x0, -, hx0⟩ := Finset.mem_image.mp hmem
      rw [if_pos hmem, Finset.sum_eq_single x0]
      · simp [isoMatrix, Matrix.conjTranspose_apply, hx0]
      · intro x _ hx
        have hne : u x ≠ f := fun h => hx (hu (h.trans hx0.symm))
        simp [isoMatrix, Matrix.conjTranspose_apply, hne]
      · intro h
        exact absurd (Finset.mem_univ x0) h
    · rw [if_neg hmem]
      refine Finset.sum_eq_zero fun x _ => ?_
      have hne : u x ≠ f := fun h => hmem (Finset.mem_image.mpr ⟨x, Finset.mem_univ x, h⟩)
      simp [isoMatrix, Matrix.conjTranspose_apply, hne]
  · rw [if_neg hff]
    refine Finset.sum_eq_zero fun x _ => ?_
    simp only [isoMatrix, Matrix.conjTranspose_apply, RCLike.star_def]
    by_cases h1 : u x = f
    · have h2 : u x ≠ f' := fun h => hff (h1.symm.trans h)
      simp [h1, hff]
    · simp [h1]

/-- The coefficient matrix of a maximally entangled state with Schmidt
coefficient `c` and Schmidt vectors labelled by `u` and `v`. -/
noncomputable def maxEntState (c : ℝ) (u : γ → α) (v : γ → β) : Matrix α β ℂ :=
  (c : ℂ) • (isoMatrix u * (isoMatrix v)ᴴ)

omit [Fintype α] [Fintype β] [DecidableEq γ] in
lemma conjTranspose_maxEntState (c : ℝ) (u : γ → α) (v : γ → β) :
    (maxEntState c u v)ᴴ = maxEntState c v u := by
  simp [maxEntState, Matrix.conjTranspose_smul, Matrix.conjTranspose_mul]

omit [Fintype α] in
lemma rhoLeft_maxEntState (hu : Function.Injective u) (hv : Function.Injective v) (c : ℝ) :
    rhoLeft (maxEntState c u v)
      = Matrix.diagonal
          (fun f => ((if f ∈ Finset.image u Finset.univ then c ^ 2 else 0 : ℝ) : ℂ)) := by
  have hmul : isoMatrix u * (isoMatrix v)ᴴ * (isoMatrix v * (isoMatrix u)ᴴ)
      = isoMatrix u * ((isoMatrix v)ᴴ * isoMatrix v) * (isoMatrix u)ᴴ := by
    simp [Matrix.mul_assoc]
  rw [rhoLeft, conjTranspose_maxEntState, maxEntState, maxEntState, Matrix.smul_mul,
    Matrix.mul_smul, smul_smul, hmul, isoMatrix_conjTranspose_mul hv, Matrix.mul_one,
    isoMatrix_mul_conjTranspose hu]
  ext f f'
  by_cases hff : f = f'
  · subst hff
    by_cases hmem : f ∈ Finset.image u Finset.univ <;>
      simp [sq, apply_ite (fun x : ℝ => (x : ℂ))]
  · simp [hff]

lemma trace_rhoLeft_maxEntState (hu : Function.Injective u) (hv : Function.Injective v) (c : ℝ) :
    (rhoLeft (maxEntState c u v)).trace = ((Fintype.card γ : ℝ) * c ^ 2 : ℝ) := by
  rw [rhoLeft_maxEntState hu hv c, Matrix.trace_diagonal]
  rw [← Complex.ofReal_sum]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const,
    Finset.card_image_of_injective _ hu, Finset.card_univ, nsmul_eq_mul]

lemma vnEntropy_rhoLeft_maxEntState (hu : Function.Injective u) (hv : Function.Injective v)
    (c : ℝ) :
    vnEntropy (rhoLeft (maxEntState c u v))
      = (Fintype.card γ : ℝ) * Real.negMulLog (c ^ 2) := by
  rw [rhoLeft_maxEntState hu hv c, vnEntropy_diagonal]
  rw [Finset.sum_congr rfl (fun f _ => by
    by_cases hmem : f ∈ Finset.image u Finset.univ <;> simp [hmem] :
      ∀ f ∈ Finset.univ,
        Real.negMulLog (if f ∈ Finset.image u Finset.univ then c ^ 2 else 0)
          = if f ∈ Finset.image u Finset.univ then Real.negMulLog (c ^ 2) else 0)]
  rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.sum_const,
    Finset.card_image_of_injective _ hu, Finset.card_univ, nsmul_eq_mul]

lemma rank_maxEntState (hu : Function.Injective u) (hv : Function.Injective v) {c : ℝ}
    (hc : c ≠ 0) : schmidtRank (maxEntState c u v) = Fintype.card γ := by
  have h := rank_rhoLeft (maxEntState c u v)
  rw [rhoLeft_maxEntState hu hv c, Matrix.rank_diagonal, Fintype.card_subtype] at h
  rw [← h]
  have hfilter : (Finset.univ.filter
      (fun f : α => ((if f ∈ Finset.image u Finset.univ then c ^ 2 else 0 : ℝ) : ℂ) ≠ 0))
      = Finset.image u Finset.univ := by
    ext f
    by_cases hmem : f ∈ Finset.image u Finset.univ <;>
      simp [hmem, hc, pow_eq_zero_iff]
  rw [hfilter, Finset.card_image_of_injective _ hu, Finset.card_univ]

/-- The maximally entangled state of Schmidt rank `|γ|` attached to two
injective labellings of Schmidt vectors. -/
noncomputable def maxEnt (u : γ → α) (v : γ → β) : Matrix α β ℂ :=
  maxEntState ((Real.sqrt (Fintype.card γ))⁻¹) u v

omit [DecidableEq γ] in
lemma maxEnt_sq (hγ : 0 < Fintype.card γ) :
    ((Real.sqrt (Fintype.card γ))⁻¹ : ℝ) ^ 2 = ((Fintype.card γ : ℝ))⁻¹ := by
  have hpos : (0 : ℝ) < (Fintype.card γ : ℝ) := by exact_mod_cast hγ
  rw [sq, ← mul_inv, Real.mul_self_sqrt hpos.le]

theorem normalized_maxEnt (hu : Function.Injective u) (hv : Function.Injective v)
    (hγ : 0 < Fintype.card γ) : Normalized (maxEnt u v) := by
  have hpos : (0 : ℝ) < (Fintype.card γ : ℝ) := by exact_mod_cast hγ
  rw [normalized_iff_trace_rhoLeft, maxEnt, trace_rhoLeft_maxEntState hu hv, maxEnt_sq hγ]
  rw [mul_inv_cancel₀ (ne_of_gt hpos)]
  norm_num

theorem schmidtRank_maxEnt (hu : Function.Injective u) (hv : Function.Injective v)
    (hγ : 0 < Fintype.card γ) : schmidtRank (maxEnt u v) = Fintype.card γ := by
  have hpos : (0 : ℝ) < (Fintype.card γ : ℝ) := by exact_mod_cast hγ
  refine rank_maxEntState hu hv ?_
  positivity

/-- **Maximal entanglement saturates the Schmidt-rank bound.**  The quantum
mutual information of a maximally entangled state of Schmidt rank `r` across its
cut equals `2 log r`. -/
theorem mutualInformation_maxEnt (hu : Function.Injective u) (hv : Function.Injective v)
    (hγ : 0 < Fintype.card γ) :
    mutualInformation (maxEnt u v) = 2 * Real.log (schmidtRank (maxEnt u v)) := by
  have hpos : (0 : ℝ) < (Fintype.card γ : ℝ) := by exact_mod_cast hγ
  have hleft : vnEntropy (rhoLeft (maxEnt u v)) = Real.log (Fintype.card γ) := by
    rw [maxEnt, vnEntropy_rhoLeft_maxEntState hu hv, maxEnt_sq hγ, Real.negMulLog,
      Real.log_inv]
    field_simp
  have hright : vnEntropy (rhoRight (maxEnt u v)) = Real.log (Fintype.card γ) := by
    have hcT : rhoRight (maxEnt u v) = rhoLeft (maxEnt v u) := by
      rw [rhoRight, rhoLeft, maxEnt, maxEnt, conjTranspose_maxEntState]
      congr 1
      rw [← conjTranspose_maxEntState]
    rw [hcT, maxEnt, vnEntropy_rhoLeft_maxEntState hv hu, maxEnt_sq hγ, Real.negMulLog,
      Real.log_inv]
    field_simp
  rw [mutualInformation, hleft, hright, schmidtRank_maxEnt hu hv hγ]
  ring

end MaximallyEntangled

end IITTensorNetwork