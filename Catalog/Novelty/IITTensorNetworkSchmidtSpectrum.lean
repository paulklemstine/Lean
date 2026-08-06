import Novelty.IITTensorNetworkEquality

/-! # Schmidt-diagonal states and the failure of "Φ = 2 log (Schmidt rank)"

The mission conjecture in its naive reading — that the integrated information of
a tensor network state is determined by its Schmidt rank — is *false*: the
mutual information across a cut depends on the whole Schmidt spectrum, not just
on the number of nonzero Schmidt coefficients.  The Schmidt rank only provides
the upper bound `2 log (Schmidt rank)` proved in the companion files, and the
bound is attained exactly at a flat spectrum (`IITTensorNetworkEquality`).

This file provides the explicit witness.  We work with states given in Schmidt
form: a real vector `v` of Schmidt coefficients yields the coefficient matrix
`schmidtDiag v = diagonal v`, for which everything is computable:

* `normalized_schmidtDiag_iff` : normalization is `∑ v i ^ 2 = 1`;
* `mutualInformation_schmidtDiag` : `I = 2 ∑ -v i² log (v i²)`;
* `schmidtRank_schmidtDiag` : the Schmidt rank is the number of nonzero
  coefficients;
* `mutualInformation_schmidtDiag_lt_of_not_flat` /
  `mutualInformation_schmidtDiag_of_flat` : the sharp dichotomy against the
  bound `2 log (card)`.

We then instantiate this with a one-parameter family of two-qubit states
`qubitPairState c s = c|00⟩ + s|11⟩` (a matrix product state of bond dimension
two) and prove:

* `phi_qubitPair` : `Φ = 2(-c² log c² - s² log s²)`;
* `schmidtRank_qubitPair` : the Schmidt rank is `2` whenever `c, s ≠ 0`;
* `phi_qubitPair_lt_two_log_two` : as soon as `c² ≠ 1/2` the integrated
  information is *strictly* below `2 log 2 = 2 log (Schmidt rank)`, so `Φ` is
  not a function of the Schmidt rank;
* `phi_bellPair` : at `c = s = 1/√2` the value `2 log 2` is attained, so the
  bound is sharp — the bond-dimension-two cap `Φ ≤ 2 log 2` of
  `mutualInformation_mps_bondDim_two_le` is exactly the Bell/GHZ value.
-/

open Finset Matrix
open scoped ComplexOrder

namespace IITTensorNetwork

/-! ## States in Schmidt-diagonal form -/

section DiagonalState

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The bipartite coefficient matrix determined by a real vector of Schmidt
coefficients: the diagonal matrix with those entries. -/
noncomputable def schmidtDiag (v : α → ℝ) : Matrix α α ℂ :=
  Matrix.diagonal (fun i => (v i : ℂ))

/-- The left marginal of a Schmidt-diagonal state is diagonal with the squared
Schmidt coefficients on the diagonal. -/
lemma rhoLeft_schmidtDiag (v : α → ℝ) :
    rhoLeft (schmidtDiag v) = Matrix.diagonal (fun i => ((v i ^ 2 : ℝ) : ℂ)) := by
  rw [rhoLeft, schmidtDiag, Matrix.diagonal_conjTranspose, Matrix.diagonal_mul_diagonal]
  congr 1
  funext i
  simp [Complex.conj_ofReal, sq]

/-- A Schmidt-diagonal state is normalized exactly when its coefficients form a
unit vector. -/
lemma normalized_schmidtDiag_iff (v : α → ℝ) :
    Normalized (schmidtDiag v) ↔ ∑ i, v i ^ 2 = 1 := by
  unfold Normalized schmidtDiag
  constructor
  · intro h
    rw [← h]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_eq_single i]
    · simp [Matrix.diagonal_apply_eq, Complex.norm_real, sq_abs]
    · intro j _ hj
      simp [Matrix.diagonal_apply_ne _ (Ne.symm hj)]
    · intro h; exact absurd (Finset.mem_univ i) h
  · intro h
    rw [← h]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.sum_eq_single i]
    · simp [Matrix.diagonal_apply_eq, Complex.norm_real, sq_abs]
    · intro j _ hj
      simp [Matrix.diagonal_apply_ne _ (Ne.symm hj)]
    · intro h; exact absurd (Finset.mem_univ i) h

/-- The entanglement entropy of a Schmidt-diagonal state is the Shannon entropy
of the squared Schmidt coefficients. -/
lemma vnEntropy_rhoLeft_schmidtDiag (v : α → ℝ) :
    vnEntropy (rhoLeft (schmidtDiag v)) = ∑ i, Real.negMulLog (v i ^ 2) := by
  rw [rhoLeft_schmidtDiag, vnEntropy_diagonal]

/-- The quantum mutual information of a Schmidt-diagonal state. -/
lemma mutualInformation_schmidtDiag (v : α → ℝ) :
    mutualInformation (schmidtDiag v) = 2 * ∑ i, Real.negMulLog (v i ^ 2) := by
  rw [mutualInformation_eq_two_mul_entanglementEntropy, entanglementEntropy,
    vnEntropy_rhoLeft_schmidtDiag]

/-- The Schmidt rank of a Schmidt-diagonal state is the number of nonzero
Schmidt coefficients. -/
lemma schmidtRank_schmidtDiag (v : α → ℝ) :
    schmidtRank (schmidtDiag v) = (Finset.univ.filter (fun i => v i ≠ 0)).card := by
  rw [schmidtDiag, schmidtRank, Matrix.rank_diagonal, Fintype.card_subtype]
  congr 1
  ext i
  simp [Complex.ofReal_eq_zero]

/-- A Schmidt-diagonal state with all coefficients nonzero has full Schmidt
rank. -/
lemma schmidtRank_schmidtDiag_of_ne_zero {v : α → ℝ} (hv : ∀ i, v i ≠ 0) :
    schmidtRank (schmidtDiag v) = Fintype.card α := by
  rw [schmidtRank_schmidtDiag, Finset.filter_true_of_mem (fun i _ => hv i), Finset.card_univ]

/-- **A non-flat Schmidt spectrum falls strictly below the rank bound.** -/
theorem mutualInformation_schmidtDiag_lt_of_not_flat {v : α → ℝ} (hv : ∑ i, v i ^ 2 = 1)
    (hne : ∃ i, v i ^ 2 ≠ ((Fintype.card α : ℝ))⁻¹) :
    mutualInformation (schmidtDiag v) < 2 * Real.log (Fintype.card α) := by
  have h := sum_negMulLog_lt_log_card (p := fun i => v i ^ 2) (fun i => sq_nonneg _) hv hne
  rw [mutualInformation_schmidtDiag]
  linarith

/-- **A flat Schmidt spectrum attains the rank bound.** -/
theorem mutualInformation_schmidtDiag_of_flat {v : α → ℝ}
    (hflat : ∀ i, v i ^ 2 = ((Fintype.card α : ℝ))⁻¹) (hcard : 0 < Fintype.card α) :
    mutualInformation (schmidtDiag v) = 2 * Real.log (Fintype.card α) := by
  have hpos : (0 : ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast hcard
  rw [mutualInformation_schmidtDiag, Finset.sum_congr rfl (fun i _ => by rw [hflat i]),
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul, Real.negMulLog, Real.log_inv]
  field_simp

end DiagonalState

/-! ## Integrated information of a two-site chain -/

section TwoSites

variable {d : ℕ} {psi : (Fin 2 → Fin d) → ℂ}

/-- For a chain of two sites there is only one bipartition, so `Φ` is the mutual
information across it. -/
theorem phi_two_sites (hpsi : ∑ s, ‖psi s‖ ^ 2 = 1) :
    Phi hpsi (le_refl 2) = mutualInformation (chainCutMatrix psi 1 (by omega)) := by
  refine le_antisymm (phi_le_mutualInformation hpsi (le_refl 2) ⟨0, by omega⟩) ?_
  refine le_phi hpsi (le_refl 2) (fun p => ?_)
  obtain ⟨pv, hpv⟩ := p
  have h0 : pv = 0 := by omega
  subst h0
  exact le_refl _

end TwoSites

/-! ## The two-qubit family `c|00⟩ + s|11⟩` -/

section QubitPair

/-- The two-qubit state `c|00⟩ + s|11⟩`, a matrix product state of bond
dimension two whose Schmidt coefficients are `c` and `s`. -/
noncomputable def qubitPairState (c s : ℝ) : (Fin 2 → Fin 2) → ℂ :=
  fun t => if t 0 = t 1 then (if t 0 = 0 then (c : ℂ) else (s : ℂ)) else 0

/-- The Schmidt coefficient vector of the two-qubit family, indexed by the
configurations of a single site. -/
def qubitPairCoeff (c s : ℝ) : (Fin 1 → Fin 2) → ℝ :=
  fun f => if f 0 = 0 then c else s

lemma card_one_site : Fintype.card (Fin 1 → Fin 2) = 2 := by simp

/-- Sums over the configurations of one qubit. -/
lemma sum_one_site (F : (Fin 1 → Fin 2) → ℝ) :
    ∑ f, F f = F (fun _ => 0) + F (fun _ => 1) := by
  rw [← Equiv.sum_comp (Equiv.funUnique (Fin 1) (Fin 2)).symm, Fin.sum_univ_two]
  rfl

/-- The two-qubit family is normalized when `c² + s² = 1`. -/
theorem qubitPairState_normalized {c s : ℝ} (h : c ^ 2 + s ^ 2 = 1) :
    ∑ t, ‖qubitPairState c s t‖ ^ 2 = 1 := by
  rw [← Equiv.sum_comp (finTwoArrowEquiv (Fin 2)).symm]
  simp [Fintype.sum_prod_type, Fin.sum_univ_two, qubitPairState, finTwoArrowEquiv]
  exact h

/-- The cut matrix of the two-qubit family is the Schmidt-diagonal matrix with
coefficients `c` and `s`. -/
theorem chainCutMatrix_qubitPairState (c s : ℝ) (hl : (1 : ℕ) ≤ 2) :
    chainCutMatrix (qubitPairState c s) 1 hl = schmidtDiag (qubitPairCoeff c s) := by
  ext f g
  have hg0 : glue 1 hl f g 0 = f 0 := by simp [glue]
  have hg1 : glue 1 hl f g 1 = g 0 := by
    simp only [glue]
    rw [dif_neg (by norm_num)]
    congr 1
  have hfg : (f = g) ↔ (f 0 = g 0) := by
    constructor
    · rintro rfl; rfl
    · intro h; funext i; rw [Subsingleton.elim i 0]; exact h
  simp only [chainCutMatrix, Matrix.of_apply, schmidtDiag, Matrix.diagonal_apply,
    qubitPairState, qubitPairCoeff]
  rw [hg0, hg1]
  by_cases hc : f 0 = g 0
  · rw [if_pos hc, if_pos (hfg.mpr hc)]
    by_cases h0 : f 0 = 0 <;> simp [h0]
  · rw [if_neg hc, if_neg (fun h => hc (hfg.mp h))]

/-- **Integrated information of the two-qubit family.**  It is twice the binary
entropy of the Schmidt weights. -/
theorem phi_qubitPair {c s : ℝ} (h : c ^ 2 + s ^ 2 = 1) :
    Phi (qubitPairState_normalized h) (le_refl 2)
      = 2 * (Real.negMulLog (c ^ 2) + Real.negMulLog (s ^ 2)) := by
  rw [phi_two_sites, chainCutMatrix_qubitPairState, mutualInformation_schmidtDiag,
    sum_one_site]
  norm_num [qubitPairCoeff]

/-- The Schmidt rank of the two-qubit family is `2` whenever both Schmidt
coefficients are nonzero. -/
theorem schmidtRank_qubitPair {c s : ℝ} (hc : c ≠ 0) (hs : s ≠ 0) (hl : (1 : ℕ) ≤ 2) :
    schmidtRank (chainCutMatrix (qubitPairState c s) 1 hl) = 2 := by
  rw [chainCutMatrix_qubitPairState,
    schmidtRank_schmidtDiag_of_ne_zero (v := qubitPairCoeff c s) ?_, card_one_site]
  intro f
  by_cases h0 : f 0 = 0 <;> simp [qubitPairCoeff, h0, hc, hs]

/-- **`Φ` is not a function of the Schmidt rank.**  As soon as the Schmidt
spectrum is unbalanced (`c² ≠ 1/2`), the integrated information of the two-qubit
state `c|00⟩ + s|11⟩` is strictly below `2 log 2`, even though the state has
Schmidt rank `2` and bond dimension `2` just like the Bell state. -/
theorem phi_qubitPair_lt_two_log_two {c s : ℝ} (h : c ^ 2 + s ^ 2 = 1)
    (hne : c ^ 2 ≠ (2 : ℝ)⁻¹) :
    Phi (qubitPairState_normalized h) (le_refl 2) < 2 * Real.log 2 := by
  have hcoeff : ∑ f, qubitPairCoeff c s f ^ 2 = 1 := by
    rw [sum_one_site]
    norm_num [qubitPairCoeff]
    exact h
  have hexists : ∃ f, qubitPairCoeff c s f ^ 2
      ≠ ((Fintype.card (Fin 1 → Fin 2) : ℝ))⁻¹ := by
    refine ⟨fun _ => 0, ?_⟩
    rw [card_one_site]
    simpa [qubitPairCoeff] using hne
  have hlt := mutualInformation_schmidtDiag_lt_of_not_flat hcoeff hexists
  rw [card_one_site] at hlt
  rw [phi_two_sites, chainCutMatrix_qubitPairState]
  exact_mod_cast hlt

/-- **The bound is attained at the Bell state.**  For `c = s = 1/√2` the
integrated information is exactly `2 log 2 = 2 log (Schmidt rank)`. -/
theorem phi_bellPair :
    Phi (qubitPairState_normalized (c := (Real.sqrt 2)⁻¹) (s := (Real.sqrt 2)⁻¹)
      (by rw [← two_mul]; rw [inv_pow, Real.sq_sqrt (by norm_num)]; norm_num)) (le_refl 2)
      = 2 * Real.log 2 := by
  have hsq : ((Real.sqrt 2)⁻¹ : ℝ) ^ 2 = (2 : ℝ)⁻¹ := by
    rw [inv_pow, Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2)]
  have hflat : ∀ f, qubitPairCoeff (Real.sqrt 2)⁻¹ (Real.sqrt 2)⁻¹ f ^ 2
      = ((Fintype.card (Fin 1 → Fin 2) : ℝ))⁻¹ := by
    intro f
    rw [card_one_site]
    by_cases h0 : f 0 = 0 <;> simp [qubitPairCoeff, h0, hsq]
  have hcard : 0 < Fintype.card (Fin 1 → Fin 2) := by rw [card_one_site]; norm_num
  have heq := mutualInformation_schmidtDiag_of_flat hflat hcard
  rw [card_one_site] at heq
  rw [phi_two_sites, chainCutMatrix_qubitPairState]
  exact_mod_cast heq

end QubitPair

end IITTensorNetwork