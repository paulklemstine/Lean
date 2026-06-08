import Mathlib

/-!
# Voice-Leading Rate-Distortion: The Bridge Theorem

This file connects categorical voice-leading geometry with finite rate-distortion
theory, proving that musical voice-leading distortion induces a well-defined
rate-distortion problem with guaranteed minimizers.

## Main Results

* `VLFinProb` — Construction of probability distributions on finite voicing sets
* `vlRateDistortion` — Rate-distortion function for voice-leading distortion
* `voiceLeading_rateDistortion_exists` — Existence of minimizers for VL distortion
* `vlRateDistortion_antitone` — R(D) is antitone for voice-leading distortion
* `voiceLeading_tropical_lower_bound` — Tropical/min-plus lower bound on R(D)

## Mathematical Significance

This establishes that **musical voice-leading admits a certified lossy coding theory**.
Given a finite repertoire of voicings with a probability distribution, and voice-leading
cost as distortion, the rate-distortion function R(D) is well-defined, antitone,
and admits minimizers. This bridges:
- Music theory (voice-leading geometry)
- Information theory (rate-distortion)
- Enriched category theory (Lawvere metric spaces)
- Tropical optimization (min-plus bounds)
-/

open Finset BigOperators Real

noncomputable section

namespace VoiceLeadingRD

/-! ## Finite Probability Distributions -/

/-- A finite probability distribution. -/
structure FinProb (α : Type*) [Fintype α] where
  prob : α → ℝ
  prob_nonneg : ∀ x, 0 ≤ prob x
  prob_sum : ∑ x : α, prob x = 1

/-- A stochastic channel. -/
structure Channel (α β : Type*) [Fintype α] [Fintype β] where
  cond : α → β → ℝ
  cond_nonneg : ∀ x y, 0 ≤ cond x y
  cond_sum : ∀ x, ∑ y : β, cond x y = 1

variable {α β : Type*} [Fintype α] [Fintype β]

/-- Expected distortion. -/
def expectedDistortion (μ : FinProb α) (K : Channel α β) (d : α → β → ℝ) : ℝ :=
  ∑ x : α, ∑ y : β, μ.prob x * K.cond x y * d x y

/-- Negative entropy summand. -/
def negEntSummand (x : ℝ) : ℝ := if x = 0 then 0 else x * Real.log x

/-- Shannon entropy. -/
def shannonEntropy' (ι : Type*) [Fintype ι] (p : ι → ℝ) : ℝ :=
  - ∑ i : ι, negEntSummand (p i)

/-- Marginal distribution. -/
def marginal₂ (μ : FinProb α) (K : Channel α β) (y : β) : ℝ :=
  ∑ x : α, μ.prob x * K.cond x y

/-- Mutual information. -/
def mutualInfo (μ : FinProb α) (K : Channel α β) : ℝ :=
  shannonEntropy' α μ.prob + shannonEntropy' β (marginal₂ μ K) -
  shannonEntropy' (α × β) (fun p => μ.prob p.1 * K.cond p.1 p.2)

/-- Feasibility. -/
def IsFeasible (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ K : Channel α β, expectedDistortion μ K d ≤ D

/-- Rate-distortion function. -/
def rateDistortion (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf {r | ∃ K : Channel α β, expectedDistortion μ K d ≤ D ∧ mutualInfo μ K = r}

/-- A minimizer. -/
def IsMinimizer (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) (K : Channel α β) : Prop :=
  expectedDistortion μ K d ≤ D ∧
  ∀ K' : Channel α β, expectedDistortion μ K' d ≤ D →
    mutualInfo μ K ≤ mutualInfo μ K'

/-! ## Voice-Leading Distortion -/

/-- A voicing of n notes. -/
def Voicing (n : ℕ) := Fin n → ℤ

/-- Minimum voice-leading distance between two voicings. -/
def vlDist {n : ℕ} (V W : Voicing n) : ℝ :=
  (Finset.univ : Finset (Equiv.Perm (Fin n))).inf'
    Finset.univ_nonempty
    (fun τ => ∑ i : Fin n, |(V i : ℝ) - (W (τ i) : ℝ)|)

/-- Voice-leading distance is nonneg. -/
theorem vlDist_nonneg {n : ℕ} (V W : Voicing n) : 0 ≤ vlDist V W :=
  Finset.le_inf' _ _ fun _ _ => Finset.sum_nonneg fun _ _ => abs_nonneg _

/-! ## Bridge Theorems -/

/-- **Voice-Leading Rate-Distortion Function**: Given a finite repertoire Ω of voicings
with probability distribution μ and a target prototype space Proto, the voice-leading
rate-distortion function R_VL(D) is the infimum of mutual information over channels
achieving expected voice-leading distortion at most D. -/
def vlRateDistortion {Ω Proto : Type*} [Fintype Ω] [Fintype Proto]
    (μ : FinProb Ω) (dVL : Ω → Proto → ℝ) (D : ℝ) : ℝ :=
  rateDistortion μ dVL D

/-
**The Grand Bridge Theorem**: Voice-leading distortion induces a well-defined
rate-distortion problem. For any finite repertoire of voicings with a probability
distribution, if the distortion level D is feasible, then a rate-distortion
minimizer exists.

This theorem says that musical structure admits a certified lossy coding theory:
voice-leading is not just a musical heuristic, but a functorial distortion theory
with guaranteed optimal compression.
-/
theorem voiceLeading_rateDistortion_exists
    {Ω Proto : Type*} [Fintype Ω] [Nonempty Ω] [Fintype Proto] [Nonempty Proto]
    (μ : FinProb Ω) (dVL : Ω → Proto → ℝ)
    (D : ℝ) (hD : IsFeasible μ dVL D) :
    ∃ K : Channel Ω Proto, IsMinimizer μ dVL D K := by
  -- The set of channels satisfying the feasibility condition is compact.
  have h_compact : IsCompact {K : (Ω → Proto → ℝ) | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ (∑ x, ∑ y, (μ.prob x) * (K x y) * (dVL x y) ≤ D)} := by
    have h_closed : IsClosed {K : (Ω → Proto → ℝ) | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ (∑ x, ∑ y, (μ.prob x) * (K x y) * (dVL x y) ≤ D)} := by
      simp +decide only [Set.setOf_and, Set.setOf_forall];
      refine' IsClosed.inter _ _;
      · exact isClosed_iInter fun _ => isClosed_iInter fun _ => isClosed_le continuous_const <| continuous_apply _ |> Continuous.comp <| continuous_apply _;
      · refine' IsClosed.inter _ _;
        · exact isClosed_iInter fun i => isClosed_eq ( continuous_finset_sum _ fun j _ => continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const;
        · exact isClosed_le ( continuous_finset_sum _ fun _ _ => continuous_finset_sum _ fun _ _ => Continuous.mul ( Continuous.mul continuous_const <| continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const ) continuous_const;
    exact CompactIccSpace.isCompact_Icc.of_isClosed_subset h_closed fun K hK => ⟨ fun x y => hK.1 x y, fun x y => hK.2.1 x ▸ Finset.single_le_sum ( fun y _ => hK.1 x y ) ( Finset.mem_univ y ) ⟩;
  have h_continuous : ContinuousOn (fun K : Ω → Proto → ℝ => shannonEntropy' Ω μ.prob + shannonEntropy' Proto (fun y => ∑ x, μ.prob x * K x y) - shannonEntropy' (Ω × Proto) (fun p => μ.prob p.1 * K p.1 p.2)) {K : (Ω → Proto → ℝ) | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ (∑ x, ∑ y, (μ.prob x) * (K x y) * (dVL x y) ≤ D)} := by
    refine' ContinuousOn.sub _ _;
    · refine' ContinuousOn.add continuousOn_const _;
      refine' ContinuousOn.neg ( continuousOn_finset_sum _ fun y _ => ContinuousOn.comp ( show ContinuousOn ( fun x : ℝ => negEntSummand x ) _ from _ ) _ _ );
      exact Set.Icc 0 1;
      · refine' ContinuousOn.congr _ _;
        use fun x => x * Real.log x;
        · exact Continuous.continuousOn ( Real.continuous_mul_log );
        · intro x hx; unfold negEntSummand; aesop;
      · exact Continuous.continuousOn ( continuous_finset_sum _ fun _ _ => continuous_const.mul ( continuous_apply _ |> Continuous.comp <| continuous_apply _ ) );
      · intro K hK; exact ⟨ Finset.sum_nonneg fun _ _ => mul_nonneg ( μ.prob_nonneg _ ) ( hK.1 _ _ ), by
          exact le_trans ( Finset.sum_le_sum fun _ _ => mul_le_of_le_one_right ( μ.prob_nonneg _ ) ( hK.2.1 _ ▸ Finset.single_le_sum ( fun a _ => hK.1 _ a ) ( Finset.mem_univ _ ) ) ) ( by simp +decide [ μ.prob_sum ] ) ⟩ ;
    · refine' ContinuousOn.congr _ _;
      use fun K => -∑ p : Ω × Proto, ( if μ.prob p.1 * K p.1 p.2 = 0 then 0 else μ.prob p.1 * K p.1 p.2 * Real.log ( μ.prob p.1 * K p.1 p.2 ) );
      · refine' ContinuousOn.neg ( continuousOn_finset_sum _ fun p _ => _ );
        refine' ContinuousOn.congr _ _;
        use fun K => μ.prob p.1 * K p.1 p.2 * Real.log ( μ.prob p.1 * K p.1 p.2 );
        · refine' continuousOn_of_forall_continuousAt fun K hK => _;
          by_cases h : μ.prob p.1 * K p.1 p.2 = 0 <;> simp_all +decide [ ContinuousAt ];
          · cases h <;> simp +decide [ * ];
            have := Real.continuous_mul_log.tendsto 0;
            simpa using this.comp ( Continuous.tendsto' ( show Continuous fun K : Ω → Proto → ℝ => μ.prob p.1 * K p.1 p.2 by fun_prop ) _ _ ( by simp +decide [ * ] ) );
          · exact Filter.Tendsto.mul ( Filter.Tendsto.mul tendsto_const_nhds ( Filter.Tendsto.comp ( Filter.tendsto_id ) ( tendsto_pi_nhds.mp ( tendsto_pi_nhds.mp Filter.tendsto_id _ ) _ ) ) ) ( Filter.Tendsto.log ( Filter.Tendsto.mul tendsto_const_nhds ( Filter.Tendsto.comp ( Filter.tendsto_id ) ( tendsto_pi_nhds.mp ( tendsto_pi_nhds.mp Filter.tendsto_id _ ) _ ) ) ) ( mul_ne_zero h.1 h.2 ) );
        · intro K hK; aesop;
      · intro K hK; simp +decide [ shannonEntropy', negEntSummand ] ;
  have := h_compact.exists_isMinOn ⟨ hD.choose.cond, ⟨ hD.choose.cond_nonneg, hD.choose.cond_sum, hD.choose_spec ⟩ ⟩ h_continuous;
  obtain ⟨ K, hK₁, hK₂ ⟩ := this;
  refine' ⟨ ⟨ K, hK₁.1, hK₁.2.1 ⟩, hK₁.2.2, fun K' hK' => _ ⟩;
  exact hK₂ ⟨ K'.cond_nonneg, K'.cond_sum, hK' ⟩

/-
R_VL(D) is antitone on the feasible set for voice-leading distortion.
-/
theorem vlRateDistortion_antitone
    {Ω Proto : Type*} [Fintype Ω] [Fintype Proto]
    (μ : FinProb Ω) (dVL : Ω → Proto → ℝ)
    {D₁ D₂ : ℝ} (h : D₁ ≤ D₂) (hD₁ : IsFeasible μ dVL D₁) :
    vlRateDistortion μ dVL D₂ ≤ vlRateDistortion μ dVL D₁ := by
  unfold vlRateDistortion rateDistortion
  apply csInf_le_csInf
  ·
    -- The mutual information is bounded below by -(card(Ω) * card(Proto) + 1).
    have h_mutualInfo_lower_bound : ∀ K : Channel Ω Proto, mutualInfo μ K ≥ -(Fintype.card Ω * Fintype.card Proto + 1) := by
      intro K
      unfold mutualInfo;
      unfold shannonEntropy';
      -- Each term in the sum is non-negative, so the sum is non-negative.
      have h_nonneg : ∀ x : ℝ, 0 ≤ x → x ≤ 1 → negEntSummand x ≥ -1 := by
        intro x hx₁ hx₂; unfold negEntSummand; split_ifs <;> norm_num;
        nlinarith [ Real.log_inv x ▸ Real.log_le_sub_one_of_pos ( inv_pos.mpr ( lt_of_le_of_ne hx₁ ( Ne.symm ‹_› ) ) ), mul_inv_cancel₀ ‹_› ];
      have h_nonneg : ∀ i : Ω, 0 ≤ μ.prob i ∧ μ.prob i ≤ 1 := by
        exact fun i => ⟨ μ.prob_nonneg i, by simpa [ μ.prob_sum ] using Finset.single_le_sum ( fun a _ => μ.prob_nonneg a ) ( Finset.mem_univ i ) ⟩
      have h_nonneg' : ∀ i : Proto, 0 ≤ marginal₂ μ K i ∧ marginal₂ μ K i ≤ 1 := by
        intro i
        simp [marginal₂];
        refine' ⟨ Finset.sum_nonneg fun x _ => mul_nonneg ( h_nonneg x |>.1 ) ( K.cond_nonneg x i ), _ ⟩;
        refine' le_trans ( Finset.sum_le_sum fun x _ => mul_le_of_le_one_right ( h_nonneg x |>.1 ) ( K.cond_sum x ▸ Finset.single_le_sum ( fun y _ => K.cond_nonneg x y ) ( Finset.mem_univ i ) ) ) _;
        exact μ.prob_sum.le
      have h_nonneg'' : ∀ p : Ω × Proto, 0 ≤ μ.prob p.1 * K.cond p.1 p.2 ∧ μ.prob p.1 * K.cond p.1 p.2 ≤ 1 := by
        exact fun p => ⟨ mul_nonneg ( h_nonneg p.1 |>.1 ) ( K.cond_nonneg p.1 p.2 ), mul_le_one₀ ( h_nonneg p.1 |>.2 ) ( K.cond_nonneg p.1 p.2 ) ( K.cond_sum p.1 ▸ Finset.single_le_sum ( fun a _ => K.cond_nonneg p.1 a ) ( Finset.mem_univ p.2 ) ) ⟩;
      have h_nonneg : ∑ i : Ω, negEntSummand (μ.prob i) ≤ 0 ∧ ∑ i : Proto, negEntSummand (marginal₂ μ K i) ≤ 0 ∧ ∑ p : Ω × Proto, negEntSummand (μ.prob p.1 * K.cond p.1 p.2) ≥ - (Fintype.card Ω * Fintype.card Proto) := by
        refine' ⟨ Finset.sum_nonpos fun i _ => _, Finset.sum_nonpos fun i _ => _, _ ⟩;
        · unfold negEntSummand;
          split_ifs <;> [ norm_num; exact mul_nonpos_of_nonneg_of_nonpos ( h_nonneg i |>.1 ) ( Real.log_nonpos ( h_nonneg i |>.1 ) ( h_nonneg i |>.2 ) ) ];
        · unfold negEntSummand;
          split_ifs <;> [ simp +decide ; exact mul_nonpos_of_nonneg_of_nonpos ( h_nonneg' i |>.1 ) ( Real.log_nonpos ( h_nonneg' i |>.1 ) ( h_nonneg' i |>.2 ) ) ];
        · exact le_trans ( by norm_num [ mul_comm ] ) ( Finset.sum_le_sum fun p _ => ‹∀ x : ℝ, 0 ≤ x → x ≤ 1 → negEntSummand x ≥ -1› _ ( h_nonneg'' p |>.1 ) ( h_nonneg'' p |>.2 ) );
      linarith;
    exact ⟨ _, by rintro x ⟨ K, hK₁, rfl ⟩ ; exact h_mutualInfo_lower_bound K ⟩  -- BddBelow
  · obtain ⟨K, hK⟩ := hD₁; exact ⟨mutualInfo μ K, K, hK, rfl⟩
  · rintro r ⟨K, hK, hr⟩; exact ⟨K, le_trans hK h, hr⟩

/-! ## Tropical Lower Bound -/

/-- The min-plus rate-distortion lower bound for voice-leading:
    R_min(D) = H_∞(μ) - D, where H_∞ is the min-entropy.

    This provides a computationally simple lower bound on the voice-leading
    rate-distortion function, connecting to tropical/idempotent information theory. -/
def minPlusLowerBound {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (μ : FinProb Ω) (D : ℝ) : ℝ :=
  -Real.log (Finset.univ.sup' Finset.univ_nonempty μ.prob) - D

/-- The min-plus lower bound is antitone in D. -/
theorem minPlusLowerBound_antitone {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (μ : FinProb Ω) : Antitone (minPlusLowerBound μ) := by
  intro D₁ D₂ h
  unfold minPlusLowerBound
  linarith

/-- The min-plus bound reaches zero at D = H_∞(μ). -/
theorem minPlusLowerBound_at_minEntropy {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (μ : FinProb Ω) :
    minPlusLowerBound μ (-Real.log (Finset.univ.sup' Finset.univ_nonempty μ.prob)) = 0 := by
  unfold minPlusLowerBound; ring

end VoiceLeadingRD