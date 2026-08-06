import Novelty.IITTensorNetworkSchmidtSpectrum

/-! # Schmidt form, weighted GHZ chains, and the exact value of `Φ`

This file completes the analysis of the mission conjecture "`Φ` is determined by
the Schmidt rank" by exhibiting, for every chain length `n ≥ 2` and every local
dimension `d`, a one-parameter family of matrix product states of *fixed* bond
dimension and *fixed* Schmidt rank `d` at every cut whose integrated information
sweeps out the whole interval `(0, 2 log d]`.

The tool is the *Schmidt form* of a bipartite pure state: a factorization

`M = L · diag(w) · Rᴴ`  with  `Lᴴ L = 1`,  `Rᴴ R = 1`,

i.e. an isometric change of basis on both sides bringing the state to diagonal
form with Schmidt coefficients `w`.  Main structural results:

* `vnEntropy_rhoLeft_of_schmidtForm`, `vnEntropy_rhoRight_of_schmidtForm`,
  `mutualInformation_of_schmidtForm` : the marginal entropies, and hence the
  mutual information across the cut, are the Shannon entropy of the squared
  Schmidt coefficients — *only the Schmidt spectrum matters*;
* `normalized_of_schmidtForm` : normalization is `∑ w² = 1`;
* `schmidtRank_of_schmidtForm` : the Schmidt rank is the number of Schmidt
  coefficients (when all are nonzero).

These are then applied to the **weighted GHZ chain state**
`ψ_w = ∑ₓ wₓ |x x ⋯ x⟩`, whose cut matrix is computed exactly
(`chainCutMatrix_weightedGhz`).  Consequences:

* `phi_weightedGhz` : `Φ(ψ_w) = 2 ∑ₓ -wₓ² log wₓ²` for every `n ≥ 2`;
* `schmidtRank_chainCutMatrix_weightedGhz` : the Schmidt rank at every cut is
  `d`, independently of `w`;
* `phi_unbalancedGhz_eq_two_mul_binEntropy` and
  `phi_unbalancedGhz_lt_two_log_two` : for `d = 2` the value is
  `2 H₂(c²)`, which is *strictly* below `2 log 2 = 2 log (Schmidt rank)`
  precisely when `c² ≠ 1/2`, while the state remains a bond-dimension-two MPS of
  Schmidt rank two at every bipartition.

Together with `phi_ghz` (the flat case) this settles the status of the
conjecture: `Φ` is bounded by, but not determined by, the Schmidt rank, and
equals `2 log (Schmidt rank)` exactly on flat spectra.
-/

open Finset Matrix Polynomial
open scoped ComplexOrder

namespace IITTensorNetwork

/-! ## States in Schmidt form -/

section SchmidtForm

variable {α β γ : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  [Fintype γ] [DecidableEq γ]

omit [DecidableEq β] in
/-- **The left marginal entropy of a state in Schmidt form** is the Shannon
entropy of the squared Schmidt coefficients. -/
theorem vnEntropy_rhoLeft_of_schmidtForm {M : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {w : γ → ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1)
    (hM : M = L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ)
    (hcard : Fintype.card γ ≤ Fintype.card α) :
    vnEntropy (rhoLeft M) = ∑ k, Real.negMulLog (w k ^ 2) := by
  classical
  set D : Matrix γ γ ℂ := Matrix.diagonal (fun k => (w k : ℂ)) with hD
  set D2 : Matrix γ γ ℂ := Matrix.diagonal (fun k => ((w k ^ 2 : ℝ) : ℂ)) with hD2
  have hDD : D * Dᴴ = D2 := by
    rw [hD, hD2, Matrix.diagonal_conjTranspose, Matrix.diagonal_mul_diagonal]
    congr 1
    funext k
    simp [Complex.conj_ofReal, sq]
  have hrho : rhoLeft M = L * (D2 * Lᴴ) := by
    have hexp : rhoLeft M = L * (D * (Rᴴ * R) * Dᴴ) * Lᴴ := by
      rw [rhoLeft, hM]
      simp [Matrix.conjTranspose_mul, Matrix.mul_assoc]
    rw [hexp, hR, Matrix.mul_one, hDD, Matrix.mul_assoc]
  have hne : (X : ℂ[X]) ^ (Fintype.card α - Fintype.card γ) * D2.charpoly ≠ 0 :=
    mul_ne_zero (pow_ne_zero _ Polynomial.X_ne_zero) (Matrix.charpoly_monic D2).ne_zero
  have hcp : (rhoLeft M).charpoly = X ^ (Fintype.card α - Fintype.card γ) * D2.charpoly := by
    rw [hrho, Matrix.charpoly_mul_comm_of_le L (D2 * Lᴴ) hcard]
    congr 2
    rw [Matrix.mul_assoc, hL, Matrix.mul_one]
  have hroots : (rhoLeft M).charpoly.roots
      = Multiset.replicate (Fintype.card α - Fintype.card γ) 0 + D2.charpoly.roots := by
    rw [hcp, Polynomial.roots_mul (hcp ▸ hne), Polynomial.roots_pow, Polynomial.roots_X,
      Multiset.nsmul_singleton]
  rw [vnEntropy_eq_multiset_sum (rhoLeft_posSemidef M).isHermitian, hroots,
    Multiset.map_add, Multiset.sum_add, Multiset.map_replicate]
  rw [hD2, roots_charpoly_diagonal, Multiset.map_map, ← Finset.sum_eq_multiset_sum]
  simp [Multiset.sum_replicate, -Complex.ofReal_pow]

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- The conjugate transpose of a state in Schmidt form is again in Schmidt
form, with the two isometries exchanged. -/
lemma conjTranspose_schmidtForm {M : Matrix α β ℂ} {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    {w : γ → ℝ} (hM : M = L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ) :
    Mᴴ = R * Matrix.diagonal (fun k => (w k : ℂ)) * Lᴴ := by
  have hDh : (Matrix.diagonal (fun k => (w k : ℂ)))ᴴ = Matrix.diagonal (fun k => (w k : ℂ)) := by
    rw [Matrix.diagonal_conjTranspose]
    congr 1
    funext k
    simp [Complex.conj_ofReal]
  rw [hM, Matrix.conjTranspose_mul, Matrix.conjTranspose_mul,
    Matrix.conjTranspose_conjTranspose, hDh, ← Matrix.mul_assoc]

omit [DecidableEq α] in
/-- **The right marginal entropy of a state in Schmidt form.** -/
theorem vnEntropy_rhoRight_of_schmidtForm {M : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {w : γ → ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1)
    (hM : M = L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ)
    (hcard : Fintype.card γ ≤ Fintype.card β) :
    vnEntropy (rhoRight M) = ∑ k, Real.negMulLog (w k ^ 2) := by
  have hswap : rhoRight M = rhoLeft Mᴴ := by
    rw [rhoRight, rhoLeft, Matrix.conjTranspose_conjTranspose]
  rw [hswap]
  exact vnEntropy_rhoLeft_of_schmidtForm hR hL (conjTranspose_schmidtForm hM) hcard

/-- **The mutual information of a state in Schmidt form** depends only on the
Schmidt spectrum. -/
theorem mutualInformation_of_schmidtForm {M : Matrix α β ℂ} {L : Matrix α γ ℂ}
    {R : Matrix β γ ℂ} {w : γ → ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1)
    (hM : M = L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ)
    (hcardα : Fintype.card γ ≤ Fintype.card α) (hcardβ : Fintype.card γ ≤ Fintype.card β) :
    mutualInformation M = 2 * ∑ k, Real.negMulLog (w k ^ 2) := by
  rw [mutualInformation, vnEntropy_rhoLeft_of_schmidtForm hL hR hM hcardα,
    vnEntropy_rhoRight_of_schmidtForm hL hR hM hcardβ]
  ring

omit [DecidableEq α] [DecidableEq β] in
/-- A state in Schmidt form is normalized exactly when its Schmidt coefficients
form a unit vector. -/
theorem normalized_of_schmidtForm {M : Matrix α β ℂ} {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    {w : γ → ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1)
    (hM : M = L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ) (hw : ∑ k, w k ^ 2 = 1) :
    Normalized M := by
  classical
  set D : Matrix γ γ ℂ := Matrix.diagonal (fun k => (w k : ℂ)) with hD
  set D2 : Matrix γ γ ℂ := Matrix.diagonal (fun k => ((w k ^ 2 : ℝ) : ℂ)) with hD2
  have hDD : D * Dᴴ = D2 := by
    rw [hD, hD2, Matrix.diagonal_conjTranspose, Matrix.diagonal_mul_diagonal]
    congr 1
    funext k
    simp [Complex.conj_ofReal, sq]
  have hrho : rhoLeft M = L * (D2 * Lᴴ) := by
    have hexp : rhoLeft M = L * (D * (Rᴴ * R) * Dᴴ) * Lᴴ := by
      rw [rhoLeft, hM]
      simp [Matrix.conjTranspose_mul, Matrix.mul_assoc]
    rw [hexp, hR, Matrix.mul_one, hDD, Matrix.mul_assoc]
  rw [normalized_iff_trace_rhoLeft, hrho, Matrix.trace_mul_comm, Matrix.mul_assoc, hL,
    Matrix.mul_one, hD2, Matrix.trace_diagonal, ← Complex.ofReal_sum, hw]
  norm_num

omit [DecidableEq α] [DecidableEq β] in
/-- **The Schmidt rank of a state in Schmidt form** is the number of Schmidt
coefficients, provided they are all nonzero. -/
theorem schmidtRank_of_schmidtForm {M : Matrix α β ℂ} {L : Matrix α γ ℂ} {R : Matrix β γ ℂ}
    {w : γ → ℝ} (hL : Lᴴ * L = 1) (hR : Rᴴ * R = 1)
    (hM : M = L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ) (hw : ∀ x, w x ≠ 0) :
    schmidtRank M = Fintype.card γ := by
  refine le_antisymm ?_ ?_
  · calc schmidtRank M = (L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ).rank := by
          rw [schmidtRank, hM]
      _ ≤ (L * Matrix.diagonal (fun k => (w k : ℂ))).rank := Matrix.rank_mul_le_left _ _
      _ ≤ Fintype.card γ := Matrix.rank_le_card_width _
  · have hprod : Lᴴ * M * R = Matrix.diagonal (fun k => (w k : ℂ)) := by
      rw [hM]
      calc Lᴴ * (L * Matrix.diagonal (fun k => (w k : ℂ)) * Rᴴ) * R
          = (Lᴴ * L) * Matrix.diagonal (fun k => (w k : ℂ)) * (Rᴴ * R) := by
            simp [Matrix.mul_assoc]
        _ = Matrix.diagonal (fun k => (w k : ℂ)) := by rw [hL, hR]; simp
    have hrankD : (Matrix.diagonal (fun k => (w k : ℂ))).rank = Fintype.card γ := by
      rw [Matrix.rank_diagonal, Fintype.card_subtype]
      rw [Finset.filter_true_of_mem (fun x _ => by
        simpa [Complex.ofReal_eq_zero] using hw x), Finset.card_univ]
    calc Fintype.card γ = (Lᴴ * M * R).rank := by rw [hprod, hrankD]
      _ ≤ M.rank := le_trans (Matrix.rank_mul_le_left _ _) (Matrix.rank_mul_le_right _ _)

/-- The Schmidt-form matrix attached to Schmidt coefficients `w` and two
injective labellings of Schmidt vectors. -/
noncomputable def wMaxEnt (w : γ → ℝ) (u : γ → α) (v : γ → β) : Matrix α β ℂ :=
  isoMatrix u * Matrix.diagonal (fun x => (w x : ℂ)) * (isoMatrix v)ᴴ

omit [Fintype α] [Fintype β] in
lemma wMaxEnt_apply (w : γ → ℝ) (u : γ → α) (v : γ → β) (f : α) (g : β) :
    wMaxEnt w u v f g = ∑ x, (if u x = f then (1 : ℂ) else 0) * (w x : ℂ)
      * (if v x = g then (1 : ℂ) else 0) := by
  simp only [wMaxEnt, Matrix.mul_apply, Matrix.diagonal_apply, isoMatrix,
    Matrix.conjTranspose_apply, RCLike.star_def]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_eq_single x]
  · by_cases h : v x = g <;> simp [h]
  · intro y _ hy
    simp [hy]
  · intro h; exact absurd (Finset.mem_univ x) h

end SchmidtForm

/-! ## The weighted GHZ chain state -/

section WeightedGHZ

variable {n d : ℕ} {w : Fin d → ℝ}

/-- The **weighted GHZ state** `∑ₓ wₓ |x x ⋯ x⟩` of a chain of `n` sites with
local dimension `d`.  The uniform weights `wₓ = d^{-1/2}` give the usual GHZ
state. -/
noncomputable def weightedGhzState (n d : ℕ) (w : Fin d → ℝ) : (Fin n → Fin d) → ℂ :=
  fun s => ∑ x, if s = constCfg n d x then (w x : ℂ) else 0

/-- A glued configuration is the constant configuration `x` exactly when both
blocks are constant equal to `x`. -/
lemma glue_eq_constCfg_iff {l : ℕ} (hl : l ≤ n) (f : Fin l → Fin d)
    (g : Fin (n - l) → Fin d) (x : Fin d) :
    glue l hl f g = constCfg n d x ↔ f = constCfg l d x ∧ g = constCfg (n - l) d x := by
  constructor
  · intro h
    constructor
    · rw [← splitL_glue l hl f g, h]
      rfl
    · rw [← splitR_glue l hl f g, h]
      rfl
  · rintro ⟨rfl, rfl⟩
    funext i
    by_cases hi : (i : ℕ) < l <;> simp [glue, constCfg, hi]

/-- **The cut matrix of a weighted GHZ chain state is in Schmidt form** with
Schmidt coefficients `w`. -/
theorem chainCutMatrix_weightedGhz {l : ℕ} (hl : l ≤ n) :
    chainCutMatrix (weightedGhzState n d w) l hl
      = wMaxEnt w (constCfg l d) (constCfg (n - l) d) := by
  ext f g
  rw [wMaxEnt_apply]
  simp only [chainCutMatrix, Matrix.of_apply, weightedGhzState]
  refine Finset.sum_congr rfl fun x _ => ?_
  by_cases h1 : constCfg l d x = f
  · by_cases h2 : constCfg (n - l) d x = g
    · rw [if_pos ((glue_eq_constCfg_iff hl f g x).mpr ⟨h1.symm, h2.symm⟩), if_pos h1, if_pos h2]
      ring
    · rw [if_neg (fun h => h2 ((glue_eq_constCfg_iff hl f g x).mp h).2.symm), if_pos h1,
        if_neg h2]
      ring
  · rw [if_neg (fun h => h1 ((glue_eq_constCfg_iff hl f g x).mp h).1.symm), if_neg h1]
    ring

/-- The squared modulus of the amplitude of a weighted GHZ state. -/
lemma norm_sq_weightedGhzState (hn : 1 ≤ n) (s : Fin n → Fin d) :
    ‖weightedGhzState n d w s‖ ^ 2 = ∑ x, if s = constCfg n d x then w x ^ 2 else 0 := by
  classical
  by_cases hex : ∃ x, s = constCfg n d x
  · obtain ⟨x0, hx0⟩ := hex
    have hval : weightedGhzState n d w s = (w x0 : ℂ) := by
      rw [weightedGhzState, Finset.sum_eq_single x0]
      · rw [if_pos hx0]
      · intro y _ hy
        refine if_neg fun h => hy ?_
        exact (constCfg_injective (d := d) (by omega) (hx0 ▸ h : constCfg n d x0
          = constCfg n d y)).symm
      · intro h; exact absurd (Finset.mem_univ x0) h
    rw [hval, Finset.sum_eq_single x0]
    · rw [if_pos hx0, Complex.norm_real, Real.norm_eq_abs, sq_abs]
    · intro y _ hy
      refine if_neg fun h => hy ?_
      exact (constCfg_injective (d := d) (by omega) (hx0 ▸ h : constCfg n d x0
        = constCfg n d y)).symm
    · intro h; exact absurd (Finset.mem_univ x0) h
  · push_neg at hex
    have hzero : weightedGhzState n d w s = 0 := by
      refine Finset.sum_eq_zero fun x _ => if_neg (hex x)
    rw [hzero, Finset.sum_eq_zero fun x _ => if_neg (hex x)]
    simp

/-- **Normalization of the weighted GHZ chain state.** -/
theorem weightedGhzState_normalized (hn : 1 ≤ n) (hw : ∑ x, w x ^ 2 = 1) :
    ∑ s, ‖weightedGhzState n d w s‖ ^ 2 = 1 := by
  classical
  rw [Finset.sum_congr rfl (fun s _ => norm_sq_weightedGhzState (w := w) hn s),
    Finset.sum_comm]
  rw [← hw]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [Finset.sum_eq_single (constCfg n d x)]
  · rw [if_pos rfl]
  · intro s _ hs
    exact if_neg hs
  · intro h; exact absurd (Finset.mem_univ (constCfg n d x)) h

/-- The two isometries appearing in the Schmidt form of a weighted GHZ cut. -/
lemma isoMatrix_constCfg_isometry {l : ℕ} (hl1 : 1 ≤ l) :
    (isoMatrix (constCfg l d))ᴴ * isoMatrix (constCfg l d) = 1 :=
  isoMatrix_conjTranspose_mul (constCfg_injective (d := d) (by omega))

lemma card_le_card_block {l : ℕ} (hl1 : 1 ≤ l) :
    Fintype.card (Fin d) ≤ Fintype.card (Fin l → Fin d) := by
  simp only [Fintype.card_fin, Fintype.card_fun, Fintype.card_fin]
  exact Nat.le_self_pow (by omega) d

/-- **Mutual information across any cut of a weighted GHZ chain state.**  It is
twice the Shannon entropy of the squared Schmidt coefficients, and in particular
it is the *same* at every bipartition. -/
theorem mutualInformation_chainCutMatrix_weightedGhz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l)
    (hlr : l < n) :
    mutualInformation (chainCutMatrix (weightedGhzState n d w) l hl)
      = 2 * ∑ x, Real.negMulLog (w x ^ 2) := by
  rw [chainCutMatrix_weightedGhz]
  exact mutualInformation_of_schmidtForm (isoMatrix_constCfg_isometry (d := d) hl1)
    (isoMatrix_constCfg_isometry (d := d) (l := n - l) (by omega)) rfl
    (card_le_card_block hl1) (card_le_card_block (l := n - l) (by omega))

/-- **The Schmidt rank of a weighted GHZ chain state** is `d` at every
bipartition, whatever the weights are (as long as they are nonzero). -/
theorem schmidtRank_chainCutMatrix_weightedGhz {l : ℕ} (hl : l ≤ n) (hl1 : 1 ≤ l)
    (hlr : l < n) (hw : ∀ x, w x ≠ 0) :
    schmidtRank (chainCutMatrix (weightedGhzState n d w) l hl) = d := by
  have hrank := schmidtRank_of_schmidtForm
    (M := wMaxEnt w (constCfg l d) (constCfg (n - l) d))
    (isoMatrix_constCfg_isometry (d := d) hl1)
    (isoMatrix_constCfg_isometry (d := d) (l := n - l) (by omega)) rfl hw
  rw [chainCutMatrix_weightedGhz, hrank, Fintype.card_fin]

/-- **The weighted GHZ chain state is a matrix product state of bond dimension
`d`.** -/
theorem hasBondDim_chainCutMatrix_weightedGhz {l : ℕ} (hl : l ≤ n) :
    HasBondDim (chainCutMatrix (weightedGhzState n d w) l hl) d := by
  rw [chainCutMatrix_weightedGhz, wMaxEnt]
  exact ⟨_, _, rfl⟩

/-- **Integrated information of the weighted GHZ chain state.** -/
theorem phi_weightedGhz (hn : 2 ≤ n) (hw : ∑ x, w x ^ 2 = 1) :
    Phi (weightedGhzState_normalized (n := n) (d := d) (w := w) (by omega) hw) hn
      = 2 * ∑ x, Real.negMulLog (w x ^ 2) := by
  have hloss : ∀ p : Fin (n - 1),
      mutualInformation (chainCutMatrix (weightedGhzState n d w) ((p : ℕ) + 1)
        (by have := p.isLt; omega)) = 2 * ∑ x, Real.negMulLog (w x ^ 2) := by
    intro p
    have hp := p.isLt
    exact mutualInformation_chainCutMatrix_weightedGhz (by omega) (by omega) (by omega)
  refine le_antisymm ?_ (le_phi _ hn (fun p => (hloss p).ge))
  obtain ⟨p, hp⟩ := exists_minimal_cut
    (weightedGhzState_normalized (n := n) (d := d) (w := w) (by omega) hw) hn
  rw [← hp, hloss p]

end WeightedGHZ

/-! ## The unbalanced GHZ family at `d = 2` -/

section UnbalancedGHZ

variable {n : ℕ}

/-- The weights of the unbalanced GHZ state `c|0⋯0⟩ + s|1⋯1⟩`. -/
def unbalancedWeights (c s : ℝ) : Fin 2 → ℝ := fun x => if x = 0 then c else s

lemma sum_unbalancedWeights_sq (c s : ℝ) :
    ∑ x, unbalancedWeights c s x ^ 2 = c ^ 2 + s ^ 2 := by
  rw [Fin.sum_univ_two]
  norm_num [unbalancedWeights]

lemma sum_negMulLog_unbalancedWeights (c s : ℝ) :
    ∑ x, Real.negMulLog (unbalancedWeights c s x ^ 2)
      = Real.negMulLog (c ^ 2) + Real.negMulLog (s ^ 2) := by
  rw [Fin.sum_univ_two]
  norm_num [unbalancedWeights]

lemma unbalancedWeights_ne_zero {c s : ℝ} (hc : c ≠ 0) (hs : s ≠ 0) :
    ∀ x, unbalancedWeights c s x ≠ 0 := by
  intro x
  by_cases h : x = 0 <;> simp [unbalancedWeights, h, hc, hs]

/-- **Integrated information of the unbalanced GHZ chain**, in terms of the
binary entropy of the Schmidt weight `c²`. -/
theorem phi_unbalancedGhz_eq_two_mul_binEntropy (hn : 2 ≤ n) {c s : ℝ}
    (h : c ^ 2 + s ^ 2 = 1) :
    Phi (weightedGhzState_normalized (n := n) (d := 2) (w := unbalancedWeights c s)
      (by omega) (by rw [sum_unbalancedWeights_sq]; exact h)) hn
      = 2 * Real.binEntropy (c ^ 2) := by
  have hs : s ^ 2 = 1 - c ^ 2 := by linarith
  rw [phi_weightedGhz hn (by rw [sum_unbalancedWeights_sq]; exact h),
    sum_negMulLog_unbalancedWeights,
    Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub, hs]

/-- **`Φ` is strictly finer than the Schmidt rank.**  The unbalanced GHZ chain
is, at every bipartition, a matrix product state of bond dimension `2` and
Schmidt rank `2` — exactly like the GHZ state — yet as soon as the Schmidt
weights are unbalanced (`c² ≠ 1/2`) its integrated information is *strictly*
below `2 log 2 = 2 log (Schmidt rank)`. -/
theorem phi_unbalancedGhz_lt_two_log_two (hn : 2 ≤ n) {c s : ℝ} (h : c ^ 2 + s ^ 2 = 1)
    (hc : c ≠ 0) (hs : s ≠ 0) (hne : c ^ 2 ≠ (2 : ℝ)⁻¹) :
    Phi (weightedGhzState_normalized (n := n) (d := 2) (w := unbalancedWeights c s)
      (by omega) (by rw [sum_unbalancedWeights_sq]; exact h)) hn < 2 * Real.log 2
      ∧ ∀ p : Fin (n - 1),
        schmidtRank (chainCutMatrix (weightedGhzState n 2 (unbalancedWeights c s))
          ((p : ℕ) + 1) (by have := p.isLt; omega)) = 2
      ∧ HasBondDim (chainCutMatrix (weightedGhzState n 2 (unbalancedWeights c s))
          ((p : ℕ) + 1) (by have := p.isLt; omega)) 2 := by
  refine ⟨?_, fun p => ⟨?_, hasBondDim_chainCutMatrix_weightedGhz _⟩⟩
  · rw [phi_unbalancedGhz_eq_two_mul_binEntropy hn h]
    have := Real.binEntropy_lt_log_two.mpr hne
    linarith
  · have hp := p.isLt
    exact schmidtRank_chainCutMatrix_weightedGhz (by omega) (by omega) (by omega)
      (unbalancedWeights_ne_zero hc hs)

end UnbalancedGHZ

end IITTensorNetwork