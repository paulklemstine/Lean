import Novelty.IITTensorNetworkWeightedGHZ

/-! # Fibre-matching bipartite states: exact Schmidt data

This file develops the linear-algebra engine used in the assessment of the
"de-quantization of Shor" proposal (`ShorCombState`, `ShorFullState`,
`ShorQFTOutput`).

A great many states produced by a *classical reversible computation run in
superposition* have the following shape.  Two finite index sets `α` (left
register) and `β` (right register) are equipped with maps
`u : α → σ` and `v : β → σ` into a common set of *labels*, and the amplitude of
`|f⟩|g⟩` is a constant `c` when the labels match and `0` otherwise:

`M f g = if u f = v g then c else 0`.

For Shor's algorithm: `α` is the exponent register, `β` the function register,
`σ = ZMod r` records the exponent modulo the multiplicative order `r`, `u` is
reduction mod `r` and `v` is the discrete logarithm.  For the *comb* (the state
of the exponent register after the function register is measured), `α`, `β` are
the two halves of the exponent register and `σ = ZMod r` again.

We prove that such a state is *exactly* in Schmidt form with

* Schmidt rank  = `#(image u ∩ image v)`  (`schmidtRank_matchMatrix`),
* Schmidt coefficients `w s = c √(|u⁻¹ s| · |v⁻¹ s|)`,

so all entanglement quantities of the state are computed in closed form:
`entanglementEntropy_matchMatrix`, `mutualInformation_matchMatrix`, and in the
balanced ("all fibres of equal size") case the spectrum is *flat*, saturating
every Schmidt-rank bound: `entanglementEntropy_matchMatrix_of_balanced`,
`flatSchmidtSpectrum_matchMatrix_of_balanced`.

The negative consequence for tensor-network emulation is
`bondDim_matchMatrix_ge`: *any* matrix-product / tensor-train representation of
such a state across the cut needs bond dimension at least `#(image u ∩ image v)`.
-/

open Finset Matrix
open scoped ComplexOrder

namespace ShorIrreducible

open IITTensorNetwork

section MatchState

variable {α β σ : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  [DecidableEq σ]

/-- The number of preimages of a label. -/
def fibreCard (u : α → σ) (s : σ) : ℕ := (univ.filter fun f => u f = s).card

/-- The set of labels realized on both sides of the cut. -/
def matchSet (u : α → σ) (v : β → σ) : Finset σ := (univ.image u) ∩ (univ.image v)

/-- A **fibre-matching state**: amplitude `c` exactly on the pairs whose labels
agree. -/
def matchMatrix (u : α → σ) (v : β → σ) (c : ℝ) : Matrix α β ℂ :=
  fun f g => if u f = v g then (c : ℂ) else 0

omit [DecidableEq α] in
lemma fibreCard_pos {u : α → σ} {s : σ} (h : s ∈ univ.image u) : 0 < fibreCard u s := by
  obtain ⟨f, -, hf⟩ := Finset.mem_image.mp h
  exact Finset.card_pos.mpr ⟨f, by simp [hf]⟩

omit [DecidableEq α] [DecidableEq β] in
lemma fibreCard_left_pos {u : α → σ} {v : β → σ} (s : matchSet u v) :
    0 < fibreCard u (s : σ) :=
  fibreCard_pos (Finset.mem_inter.mp s.2).1

omit [DecidableEq α] [DecidableEq β] in
lemma fibreCard_right_pos {u : α → σ} {v : β → σ} (s : matchSet u v) :
    0 < fibreCard v (s : σ) :=
  fibreCard_pos (Finset.mem_inter.mp s.2).2

omit [DecidableEq α] [DecidableEq β] in
lemma mem_matchSet_of_eq {u : α → σ} {v : β → σ} {f : α} {g : β} (h : u f = v g) :
    u f ∈ matchSet u v :=
  Finset.mem_inter.mpr ⟨Finset.mem_image_of_mem _ (Finset.mem_univ f),
    h ▸ Finset.mem_image_of_mem _ (Finset.mem_univ g)⟩

omit [DecidableEq α] [DecidableEq β] in
lemma card_matchSet_le_left (u : α → σ) (v : β → σ) :
    Fintype.card (matchSet u v) ≤ Fintype.card α := by
  rw [Fintype.card_coe]
  calc (matchSet u v).card ≤ (univ.image u).card :=
        Finset.card_le_card Finset.inter_subset_left
    _ ≤ (univ : Finset α).card := Finset.card_image_le
    _ = Fintype.card α := Finset.card_univ

omit [DecidableEq α] [DecidableEq β] in
lemma card_matchSet_le_right (u : α → σ) (v : β → σ) :
    Fintype.card (matchSet u v) ≤ Fintype.card β := by
  rw [Fintype.card_coe]
  calc (matchSet u v).card ≤ (univ.image v).card :=
        Finset.card_le_card Finset.inter_subset_right
    _ ≤ (univ : Finset β).card := Finset.card_image_le
    _ = Fintype.card β := Finset.card_univ

/-- Left Schmidt vectors: the normalized indicator of each `u`-fibre. -/
noncomputable def matchLeft (u : α → σ) (v : β → σ) : Matrix α (matchSet u v) ℂ :=
  fun f s => if u f = (s : σ) then ((Real.sqrt (fibreCard u (s : σ)) : ℝ) : ℂ)⁻¹ else 0

/-- Right Schmidt vectors: the normalized indicator of each `v`-fibre. -/
noncomputable def matchRight (u : α → σ) (v : β → σ) : Matrix β (matchSet u v) ℂ :=
  fun g s => if v g = (s : σ) then ((Real.sqrt (fibreCard v (s : σ)) : ℝ) : ℂ)⁻¹ else 0

/-- The Schmidt coefficients of a fibre-matching state. -/
noncomputable def matchWeights (u : α → σ) (v : β → σ) (c : ℝ) : matchSet u v → ℝ :=
  fun s => c * Real.sqrt (fibreCard u (s : σ) * fibreCard v (s : σ))

/-- Auxiliary: an indicator family with positive fibres is an isometry. -/
lemma indicator_isometry {γ : Type*} [Fintype γ] [DecidableEq γ] {w : γ → σ}
    {S : Finset σ} (L : Matrix γ S ℂ)
    (hL : ∀ (g : γ) (s : S),
      L g s = if w g = (s : σ) then ((Real.sqrt (fibreCard w (s : σ)) : ℝ) : ℂ)⁻¹ else 0)
    (hpos : ∀ s : S, 0 < fibreCard w (s : σ)) :
    Lᴴ * L = 1 := by
  classical
  ext s s'
  simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, RCLike.star_def, hL]
  have hterm : ∀ g : γ,
      (starRingEnd ℂ) (if w g = (s : σ) then ((Real.sqrt (fibreCard w (s : σ)) : ℝ) : ℂ)⁻¹ else 0) *
        (if w g = (s' : σ) then ((Real.sqrt (fibreCard w (s' : σ)) : ℝ) : ℂ)⁻¹ else 0)
      = if w g = (s : σ) ∧ w g = (s' : σ) then
          (((Real.sqrt (fibreCard w (s : σ)))⁻¹ * (Real.sqrt (fibreCard w (s' : σ)))⁻¹ : ℝ) : ℂ)
        else 0 := by
    intro g
    by_cases h1 : w g = (s : σ)
    · by_cases h2 : w g = (s' : σ)
      · rw [if_pos h1, if_pos h2, if_pos ⟨h1, h2⟩, ← Complex.ofReal_inv, ← Complex.ofReal_inv,
          Complex.conj_ofReal, ← Complex.ofReal_mul]
      · rw [if_pos h1, if_neg h2, mul_zero]
        exact (if_neg (fun hh => h2 hh.2)).symm
    · rw [if_neg h1, map_zero, zero_mul]
      exact (if_neg (fun hh => h1 hh.1)).symm
  rw [Finset.sum_congr rfl (fun g _ => hterm g)]
  by_cases hss : s = s'
  · subst hss
    rw [Matrix.one_apply_eq]
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, add_zero]
    have hfil : (univ.filter fun g => w g = (s : σ) ∧ w g = (s : σ))
        = univ.filter fun g => w g = (s : σ) := by
      apply Finset.filter_congr; intro g _; simp
    have hcard : (univ.filter fun g => w g = (s : σ)).card = fibreCard w (s : σ) := rfl
    rw [hfil, hcard, nsmul_eq_mul]
    have hpos' : (0 : ℝ) < fibreCard w (s : σ) := by exact_mod_cast hpos s
    have hsqsq : Real.sqrt (fibreCard w (s : σ)) * Real.sqrt (fibreCard w (s : σ))
        = (fibreCard w (s : σ) : ℝ) := Real.mul_self_sqrt hpos'.le
    have key : (fibreCard w (s : σ) : ℝ) *
        ((Real.sqrt (fibreCard w (s : σ)))⁻¹ * (Real.sqrt (fibreCard w (s : σ)))⁻¹) = 1 := by
      rw [← mul_inv, hsqsq]
      field_simp
    exact_mod_cast key
  · rw [Matrix.one_apply_ne hss]
    apply Finset.sum_eq_zero
    intro g _
    have : ¬ (w g = (s : σ) ∧ w g = (s' : σ)) := by
      rintro ⟨h1, h2⟩
      exact hss (Subtype.ext (h1 ▸ h2))
    simp [this]

omit [DecidableEq β] in
lemma matchLeft_isometry (u : α → σ) (v : β → σ) :
    (matchLeft u v)ᴴ * matchLeft u v = 1 :=
  indicator_isometry _ (fun _ _ => rfl) (fun s => fibreCard_left_pos s)

omit [DecidableEq α] in
lemma matchRight_isometry (u : α → σ) (v : β → σ) :
    (matchRight u v)ᴴ * matchRight u v = 1 :=
  indicator_isometry _ (fun _ _ => rfl) (fun s => fibreCard_right_pos s)

omit [DecidableEq α] [DecidableEq β] in
/-- **A fibre-matching state is in Schmidt form.** -/
theorem matchMatrix_schmidtForm (u : α → σ) (v : β → σ) (c : ℝ) :
    matchMatrix u v c
      = matchLeft u v * Matrix.diagonal (fun s => ((matchWeights u v c s : ℝ) : ℂ))
          * (matchRight u v)ᴴ := by
  classical
  ext f g
  rw [Matrix.mul_apply]
  simp only [Matrix.mul_diagonal, Matrix.conjTranspose_apply, RCLike.star_def]
  by_cases h : u f = v g
  · have hmem : u f ∈ matchSet u v := mem_matchSet_of_eq h
    set s0 : matchSet u v := ⟨u f, hmem⟩ with hs0
    rw [Finset.sum_eq_single s0]
    · have ha : (0 : ℝ) < fibreCard u (u f) := by exact_mod_cast fibreCard_left_pos s0
      have hb : (0 : ℝ) < fibreCard v (u f) := by exact_mod_cast fibreCard_right_pos s0
      have hsa : Real.sqrt (fibreCard u (u f)) ≠ 0 := by positivity
      have hsb : Real.sqrt (fibreCard v (u f)) ≠ 0 := by positivity
      have hL0 : matchLeft u v f s0 = (((Real.sqrt (fibreCard u (u f)))⁻¹ : ℝ) : ℂ) := by
        simp [matchLeft, hs0]
      have hR0 : matchRight u v g s0 = (((Real.sqrt (fibreCard v (u f)))⁻¹ : ℝ) : ℂ) := by
        simp [matchRight, hs0, h.symm]
      have hw0 : matchWeights u v c s0
          = c * (Real.sqrt (fibreCard u (u f)) * Real.sqrt (fibreCard v (u f))) := by
        rw [matchWeights, Real.sqrt_mul (by positivity)]
      have hM : matchMatrix u v c f g = (c : ℂ) := by rw [matchMatrix, if_pos h]
      rw [hL0, hR0, hw0, hM, Complex.conj_ofReal, ← Complex.ofReal_mul, ← Complex.ofReal_mul]
      norm_cast
      field_simp
    · intro t _ ht
      have hut : ¬ u f = (t : σ) := by
        intro hc'; exact ht (Subtype.ext hc'.symm)
      simp [matchLeft, hut]
    · intro hcon; exact absurd (Finset.mem_univ s0) hcon
  · rw [matchMatrix, if_neg h]
    refine (Finset.sum_eq_zero ?_).symm
    intro s _
    by_cases h1 : u f = (s : σ)
    · have h2 : ¬ v g = (s : σ) := by
        intro h2; exact h (h1.trans h2.symm)
      simp [matchRight, h2]
    · simp [matchLeft, h1]

/-! ### Closed-form Schmidt data -/

variable {u : α → σ} {v : β → σ} {c : ℝ}

/-- **The Schmidt rank of a fibre-matching state** is the number of jointly
realized labels. -/
theorem schmidtRank_matchMatrix (hc : c ≠ 0) :
    schmidtRank (matchMatrix u v c) = (matchSet u v).card := by
  rw [schmidtRank_of_schmidtForm (matchLeft_isometry u v) (matchRight_isometry u v)
    (matchMatrix_schmidtForm u v c) ?_, Fintype.card_coe]
  intro s
  have ha : (0 : ℝ) < fibreCard u (s : σ) := by exact_mod_cast fibreCard_left_pos s
  have hb : (0 : ℝ) < fibreCard v (s : σ) := by exact_mod_cast fibreCard_right_pos s
  have : Real.sqrt (fibreCard u (s : σ) * fibreCard v (s : σ)) ≠ 0 := by positivity
  exact mul_ne_zero hc this

/-- Normalization of a fibre-matching state. -/
theorem normalized_matchMatrix
    (hnorm : ∑ s ∈ matchSet u v, c ^ 2 * (fibreCard u s * fibreCard v s : ℝ) = 1) :
    Normalized (matchMatrix u v c) := by
  refine normalized_of_schmidtForm (matchLeft_isometry u v) (matchRight_isometry u v)
    (matchMatrix_schmidtForm u v c) ?_
  rw [← hnorm, ← Finset.sum_coe_sort (matchSet u v)
    (fun s => c ^ 2 * (fibreCard u s * fibreCard v s : ℝ))]
  refine Finset.sum_congr rfl fun s _ => ?_
  have ha : (0 : ℝ) ≤ fibreCard u (s : σ) := Nat.cast_nonneg _
  have hb : (0 : ℝ) ≤ fibreCard v (s : σ) := Nat.cast_nonneg _
  rw [matchWeights, mul_pow, Real.sq_sqrt (by positivity)]

/-- **The entanglement entropy of a fibre-matching state** in closed form. -/
theorem entanglementEntropy_matchMatrix :
    entanglementEntropy (matchMatrix u v c)
      = ∑ s ∈ matchSet u v, Real.negMulLog (c ^ 2 * (fibreCard u s * fibreCard v s : ℝ)) := by
  rw [entanglementEntropy, vnEntropy_rhoLeft_of_schmidtForm (matchLeft_isometry u v)
    (matchRight_isometry u v) (matchMatrix_schmidtForm u v c) (card_matchSet_le_left u v),
    ← Finset.sum_coe_sort (matchSet u v)
      (fun s => Real.negMulLog (c ^ 2 * (fibreCard u s * fibreCard v s : ℝ)))]
  refine Finset.sum_congr rfl fun s _ => ?_
  have ha : (0 : ℝ) ≤ fibreCard u (s : σ) := Nat.cast_nonneg _
  have hb : (0 : ℝ) ≤ fibreCard v (s : σ) := Nat.cast_nonneg _
  rw [matchWeights, mul_pow, Real.sq_sqrt (by positivity)]

/-- **The mutual information of a fibre-matching state** across the cut. -/
theorem mutualInformation_matchMatrix :
    mutualInformation (matchMatrix u v c)
      = 2 * ∑ s ∈ matchSet u v,
          Real.negMulLog (c ^ 2 * (fibreCard u s * fibreCard v s : ℝ)) := by
  rw [mutualInformation_eq_two_mul_entanglementEntropy_general,
    entanglementEntropy_matchMatrix]

/-! ### The balanced case: a flat, incompressible Schmidt spectrum -/

/-- **Balanced fibre-matching states have a flat spectrum**: entanglement
entropy exactly `log` of the Schmidt rank. -/
theorem entanglementEntropy_matchMatrix_of_balanced
    (hbal : ∀ s ∈ matchSet u v,
      c ^ 2 * (fibreCard u s * fibreCard v s : ℝ) = ((matchSet u v).card : ℝ)⁻¹)
    (hne : (matchSet u v).Nonempty) :
    entanglementEntropy (matchMatrix u v c) = Real.log ((matchSet u v).card) := by
  rw [entanglementEntropy_matchMatrix,
    Finset.sum_congr rfl (fun s hs => by rw [hbal s hs]), Finset.sum_const, nsmul_eq_mul]
  have hK : (0 : ℝ) < (matchSet u v).card := by
    exact_mod_cast Finset.card_pos.mpr hne
  rw [Real.negMulLog, Real.log_inv]
  field_simp

/-- The Schmidt spectrum of a balanced fibre-matching state is flat, in the
sense of `IITTensorNetwork.FlatSchmidtSpectrum`: there is no decaying tail to
truncate. -/
theorem flatSchmidtSpectrum_matchMatrix_of_balanced (hc : c ≠ 0)
    (hnorm : ∑ s ∈ matchSet u v, c ^ 2 * (fibreCard u s * fibreCard v s : ℝ) = 1)
    (hbal : ∀ s ∈ matchSet u v,
      c ^ 2 * (fibreCard u s * fibreCard v s : ℝ) = ((matchSet u v).card : ℝ)⁻¹)
    (hne : (matchSet u v).Nonempty) :
    FlatSchmidtSpectrum (matchMatrix u v c) := by
  refine (entanglementEntropy_eq_log_schmidtRank_iff (normalized_matchMatrix hnorm)).mp ?_
  rw [schmidtRank_matchMatrix hc]
  exact entanglementEntropy_matchMatrix_of_balanced hbal hne

/-- **The mutual information of a balanced fibre-matching state saturates the
Schmidt-rank bound.** -/
theorem mutualInformation_matchMatrix_of_balanced
    (hbal : ∀ s ∈ matchSet u v,
      c ^ 2 * (fibreCard u s * fibreCard v s : ℝ) = ((matchSet u v).card : ℝ)⁻¹)
    (hne : (matchSet u v).Nonempty) :
    mutualInformation (matchMatrix u v c) = 2 * Real.log ((matchSet u v).card) := by
  rw [mutualInformation_eq_two_mul_entanglementEntropy_general,
    entanglementEntropy_matchMatrix_of_balanced hbal hne]

/-! ### Injective labellings: automatically flat -/

omit [DecidableEq α] [DecidableEq β] in
lemma fibreCard_of_injective {γ : Type*} [Fintype γ] {w : γ → σ} (hw : Function.Injective w)
    {s : σ} (hs : s ∈ (univ : Finset γ).image w) : fibreCard w s = 1 := by
  classical
  obtain ⟨g, -, rfl⟩ := Finset.mem_image.mp hs
  have : (univ.filter fun g' : γ => w g' = w g) = {g} := by
    ext g'
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    exact ⟨fun h => hw h, fun h => by rw [h]⟩
  rw [fibreCard, this, Finset.card_singleton]

/-- **A fibre-matching state with injective labellings has a flat Schmidt
spectrum.**  This is the regime in which every nonzero amplitude of the state is
the *same*: there is no decaying singular-value tail whatsoever, so no
truncation of the bond dimension can be accurate. -/
theorem entanglementEntropy_matchMatrix_of_injective (hu : Function.Injective u)
    (hv : Function.Injective v)
    (hnorm : c ^ 2 * ((matchSet u v).card : ℝ) = 1) (hne : (matchSet u v).Nonempty) :
    entanglementEntropy (matchMatrix u v c) = Real.log ((matchSet u v).card) := by
  refine entanglementEntropy_matchMatrix_of_balanced (fun s hs => ?_) hne
  rw [fibreCard_of_injective hu (Finset.mem_inter.mp hs).1,
    fibreCard_of_injective hv (Finset.mem_inter.mp hs).2]
  have hK : (0 : ℝ) < (matchSet u v).card := by
    exact_mod_cast Finset.card_pos.mpr hne
  have hKne : ((matchSet u v).card : ℝ) ≠ 0 := hK.ne'
  have hc2 : c ^ 2 = ((matchSet u v).card : ℝ)⁻¹ := by
    field_simp
    linarith [hnorm]
  push_cast
  rw [mul_one, hc2, mul_one]

/-- The Schmidt spectrum of a fibre-matching state with injective labellings is
flat. -/
theorem flatSchmidtSpectrum_matchMatrix_of_injective (hc : c ≠ 0) (hu : Function.Injective u)
    (hv : Function.Injective v)
    (hnorm : c ^ 2 * ((matchSet u v).card : ℝ) = 1) (hne : (matchSet u v).Nonempty) :
    FlatSchmidtSpectrum (matchMatrix u v c) := by
  have hnorm' : ∑ s ∈ matchSet u v, c ^ 2 * (fibreCard u s * fibreCard v s : ℝ) = 1 := by
    rw [Finset.sum_congr rfl (fun s hs => by
      rw [fibreCard_of_injective hu (Finset.mem_inter.mp hs).1,
        fibreCard_of_injective hv (Finset.mem_inter.mp hs).2]), Finset.sum_const, nsmul_eq_mul]
    rw [← hnorm]; push_cast; ring
  refine (entanglementEntropy_eq_log_schmidtRank_iff (normalized_matchMatrix hnorm')).mp ?_
  rw [schmidtRank_matchMatrix hc]
  exact entanglementEntropy_matchMatrix_of_injective hu hv hnorm hne

/-! ### The tensor-network obstruction -/

/-- **Bond-dimension lower bound.**  Every tensor-train / MPS representation of
a fibre-matching state across the cut has bond dimension at least the number of
jointly realized labels.  This is the precise sense in which the low-rank
precondition of a tensor-network emulation fails. -/
theorem bondDim_matchMatrix_ge (hc : c ≠ 0) {χ : ℕ}
    (h : HasBondDim (matchMatrix u v c) χ) : (matchSet u v).card ≤ χ := by
  have := schmidtRank_le_of_hasBondDim h
  rwa [schmidtRank_matchMatrix hc] at this

/-- Contrapositive form: below the critical bond dimension no MPS
representation exists at all. -/
theorem not_hasBondDim_matchMatrix (hc : c ≠ 0) {χ : ℕ} (hχ : χ < (matchSet u v).card) :
    ¬ HasBondDim (matchMatrix u v c) χ :=
  fun h => absurd (bondDim_matchMatrix_ge hc h) (not_le.mpr hχ)

end MatchState

end ShorIrreducible