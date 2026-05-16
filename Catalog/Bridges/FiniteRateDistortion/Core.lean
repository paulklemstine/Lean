import Mathlib

/-!
# Finite Rate-Distortion Theory: Core Definitions and Structural Theorems

This file formalizes the **finite-dimensional rate-distortion function** for
finite source and reproduction alphabets. We prove:

1. **Feasibility**: the feasible set is nonempty when β is nonempty.
2. **Monotonicity**: the rate-distortion function R(D) is nonincreasing.
3. **Linearity of distortion** in channel mixtures.
4. **Lagrangian dual bound**: R(D) ≥ L(s) - s·D for all s ≥ 0.

## Mathematical Setup

Given finite types α (source) and β (reproduction), a source distribution
μ summing to 1, and distortion d : α → β → ℝ, a stochastic channel W has
each row summing to 1. The rate-distortion function is the infimum of
mutual information over channels meeting a distortion constraint.
-/

open Finset BigOperators Real

noncomputable section

/-! ## Finite Probability Distributions -/

/-- A finite probability distribution on a finite type α. -/
structure FinProbDist (α : Type*) [Fintype α] where
  prob : α → ℝ
  prob_nonneg : ∀ a, 0 ≤ prob a
  prob_sum : ∑ a : α, prob a = 1

/-- A stochastic channel from α to β. -/
structure Channel (α β : Type*) [Fintype α] [Fintype β] where
  cond : α → β → ℝ
  cond_nonneg : ∀ a b, 0 ≤ cond a b
  cond_sum : ∀ a, ∑ b : β, cond a b = 1

/-! ## Joint and Marginal Distributions -/

variable {α β : Type*} [Fintype α] [Fintype β]

/-- The joint distribution induced by source μ and channel W. -/
def jointDist (μ : FinProbDist α) (W : Channel α β) (a : α) (b : β) : ℝ :=
  μ.prob a * W.cond a b

/-- The output marginal distribution. -/
def outputDist (μ : FinProbDist α) (W : Channel α β) (b : β) : ℝ :=
  ∑ a : α, jointDist μ W a b

theorem jointDist_nonneg (μ : FinProbDist α) (W : Channel α β) (a : α) (b : β) :
    0 ≤ jointDist μ W a b :=
  mul_nonneg (μ.prob_nonneg a) (W.cond_nonneg a b)

theorem outputDist_nonneg (μ : FinProbDist α) (W : Channel α β) (b : β) :
    0 ≤ outputDist μ W b :=
  Finset.sum_nonneg fun a _ => jointDist_nonneg μ W a b

/-! ## Expected Distortion -/

/-- The expected distortion under source μ and channel W. -/
def expectedDistortion (μ : FinProbDist α) (W : Channel α β) (d : α → β → ℝ) : ℝ :=
  ∑ a : α, ∑ b : β, jointDist μ W a b * d a b

/-! ## Mutual Information (finite case) -/

/-- Safe log: log x if x > 0, else 0. -/
def safeLog (x : ℝ) : ℝ := if x > 0 then Real.log x else 0

/-- Mutual information I(X;Y) for a given source and channel. -/
def mutualInfo (μ : FinProbDist α) (W : Channel α β) : ℝ :=
  ∑ a : α, ∑ b : β, jointDist μ W a b *
    safeLog (jointDist μ W a b / (μ.prob a * outputDist μ W b))

/-! ## Feasible Set and Rate-Distortion Function -/

/-- Predicate for feasible distortion level. -/
def FeasibleDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ W : Channel α β, expectedDistortion μ W d ≤ D

/-- The set of achievable mutual information values at distortion ≤ D. -/
def rateDistortionSet (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Set ℝ :=
  {r : ℝ | ∃ W : Channel α β, expectedDistortion μ W d ≤ D ∧ mutualInfo μ W = r}

/-- The rate-distortion function: infimum of mutual information over
    channels achieving expected distortion ≤ D. -/
def rateDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf (rateDistortionSet μ d D)

/-! ## Channel conditional probability is bounded by 1 -/

theorem Channel.cond_le_one (W : Channel α β) (a : α) (b : β) :
    W.cond a b ≤ 1 := by
  exact le_trans ( Finset.single_le_sum ( fun x _ => W.cond_nonneg a x ) ( Finset.mem_univ b ) ) ( W.cond_sum a ▸ le_rfl )

/-! ## Boundedness of mutual information -/

/-
Mutual information is bounded below (by a finite constant depending on
    the cardinalities of α and β). This is needed for csInf to be well-behaved.
-/
theorem mutualInfo_bddBelow (μ : FinProbDist α) :
    ∃ C : ℝ, ∀ W : Channel α β, C ≤ mutualInfo μ W := by
  refine' ⟨ - ( Fintype.card α * Fintype.card β ) * Max.max ( 1 : ℝ ) ( Real.log ( Fintype.card α * Fintype.card β ) ), fun W => _ ⟩;
  have h_nonneg : ∀ a b, 0 ≤ jointDist μ W a b * safeLog (jointDist μ W a b / (μ.prob a * outputDist μ W b)) + max 1 (Real.log (Fintype.card α * Fintype.card β)) := by
    intro a b
    by_cases h_joint_zero : jointDist μ W a b = 0;
    · aesop;
    · have h_log_bound : jointDist μ W a b * safeLog (jointDist μ W a b / (μ.prob a * outputDist μ W b)) ≥ - (μ.prob a * outputDist μ W b) := by
        have h_log_bound : ∀ x : ℝ, 0 < x → x * safeLog x ≥ -1 := by
          intro x hx_pos
          have h_log_bound : x * Real.log x ≥ -1 := by
            nlinarith [ Real.log_inv x ▸ Real.log_le_sub_one_of_pos ( inv_pos.mpr hx_pos ), mul_inv_cancel₀ hx_pos.ne' ];
          unfold safeLog; aesop;
        have := h_log_bound ( jointDist μ W a b / ( μ.prob a * outputDist μ W b ) ) ?_;
        · rw [ div_mul_eq_mul_div, ge_iff_le, le_div_iff₀ ] at this <;> first | linarith | simp_all +decide [ jointDist, outputDist ] ;
          refine' mul_pos ( lt_of_le_of_ne ( μ.prob_nonneg a ) ( Ne.symm h_joint_zero.1 ) ) ( lt_of_lt_of_le ( mul_pos ( lt_of_le_of_ne ( μ.prob_nonneg a ) ( Ne.symm h_joint_zero.1 ) ) ( lt_of_le_of_ne ( W.cond_nonneg a b ) ( Ne.symm h_joint_zero.2 ) ) ) ( Finset.single_le_sum ( fun x _ => mul_nonneg ( μ.prob_nonneg x ) ( W.cond_nonneg x b ) ) ( Finset.mem_univ a ) ) );
        · refine' div_pos _ _;
          · exact lt_of_le_of_ne ( jointDist_nonneg μ W a b ) ( Ne.symm h_joint_zero );
          · refine' mul_pos _ _;
            · exact lt_of_le_of_ne ( μ.prob_nonneg a ) ( Ne.symm <| by intro h; simp_all +decide [ jointDist ] );
            · exact lt_of_lt_of_le ( by exact lt_of_le_of_ne ( jointDist_nonneg μ W a b ) ( Ne.symm h_joint_zero ) ) ( Finset.single_le_sum ( fun a _ => jointDist_nonneg μ W a b ) ( Finset.mem_univ a ) );
      have h_log_bound : μ.prob a * outputDist μ W b ≤ 1 := by
        have h_log_bound : μ.prob a ≤ 1 := by
          exact μ.prob_sum ▸ Finset.single_le_sum ( fun a _ => μ.prob_nonneg a ) ( Finset.mem_univ a )
        have h_log_bound' : outputDist μ W b ≤ 1 := by
          have h_log_bound' : ∑ a, μ.prob a * W.cond a b ≤ ∑ a, μ.prob a := by
            exact Finset.sum_le_sum fun a _ => mul_le_of_le_one_right ( μ.prob_nonneg a ) ( W.cond_le_one a b );
          exact h_log_bound'.trans ( by rw [ μ.prob_sum ] )
        exact mul_le_one₀ h_log_bound (outputDist_nonneg μ W b) h_log_bound';
      linarith [ le_max_left 1 ( Real.log ( Fintype.card α * Fintype.card β ) ), le_max_right 1 ( Real.log ( Fintype.card α * Fintype.card β ) ) ];
  have := Finset.sum_le_sum fun a ( ha : a ∈ Finset.univ ) => Finset.sum_le_sum fun b ( hb : b ∈ Finset.univ ) => h_nonneg a b;
  simp_all +decide [ Finset.sum_add_distrib, mutualInfo ];
  grind

/-- The rate-distortion set (when nonempty) is bounded below. -/
theorem rateDistortionSet_bddBelow (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    BddBelow (rateDistortionSet μ d D) := by
  obtain ⟨C, hC⟩ := mutualInfo_bddBelow μ (β := β)
  exact ⟨C, fun r ⟨W, _, hr⟩ => hr ▸ hC W⟩

/-! ## Monotonicity -/

/-- The achievable rate set grows when the distortion budget increases. -/
theorem rateDistortionSet_mono (μ : FinProbDist α) (d : α → β → ℝ)
    {D₁ D₂ : ℝ} (hD : D₁ ≤ D₂) :
    rateDistortionSet μ d D₁ ⊆ rateDistortionSet μ d D₂ := by
  intro r ⟨W, hW₁, hW₂⟩
  exact ⟨W, le_trans hW₁ hD, hW₂⟩

/-
**Monotonicity**: R(D) is nonincreasing on the feasible set.
-/
theorem rateDistortion_antitone (μ : FinProbDist α) (d : α → β → ℝ)
    {D₁ D₂ : ℝ} (hD : D₁ ≤ D₂) (hfeas : FeasibleDistortion μ d D₁) :
    rateDistortion μ d D₂ ≤ rateDistortion μ d D₁ := by
  -- Introduce a helper lemma to apply `csInf_le_csInf` with the appropriate conditions.
  have h_csInfMonad : ∀ D₁ D₂, D₁ ≤ D₂ → (rateDistortionSet μ d D₁).Nonempty →
    BddBelow (rateDistortionSet μ d D₂) →
      sInf (rateDistortionSet μ d D₂) ≤ sInf (rateDistortionSet μ d D₁) := by
    intros D₁ D₂ hD hN hB
    apply csInf_le_csInf hB hN
    apply rateDistortionSet_mono μ d hD;
  exact h_csInfMonad D₁ D₂ hD ( by obtain ⟨ W, hW ⟩ := hfeas; exact ⟨ _, W, hW, rfl ⟩ ) ( rateDistortionSet_bddBelow μ d D₂ )

/-! ## Channel Mixing -/

/-- Mix two channels with weight t ∈ [0,1]. -/
def channelMix (W₁ W₂ : Channel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Channel α β where
  cond a b := t * W₁.cond a b + (1 - t) * W₂.cond a b
  cond_nonneg a b := add_nonneg (mul_nonneg ht0 (W₁.cond_nonneg a b))
    (mul_nonneg (by linarith) (W₂.cond_nonneg a b))
  cond_sum a := by
    rw [show (∑ b, (t * W₁.cond a b + (1 - t) * W₂.cond a b)) =
        t * ∑ b, W₁.cond a b + (1 - t) * ∑ b, W₂.cond a b from by
      ring_nf; simp [Finset.mul_sum, Finset.sum_add_distrib]]
    rw [W₁.cond_sum, W₂.cond_sum]; ring

/-- Expected distortion is affine (linear) in the channel mixture. -/
theorem expectedDistortion_mix (μ : FinProbDist α) (d : α → β → ℝ)
    (W₁ W₂ : Channel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    expectedDistortion μ (channelMix W₁ W₂ t ht0 ht1) d =
    t * expectedDistortion μ W₁ d + (1 - t) * expectedDistortion μ W₂ d := by
  unfold expectedDistortion channelMix
  simp only [jointDist, mul_add, add_mul, mul_assoc, sum_add_distrib, Finset.mul_sum]
  exact congrArg₂ (· + ·)
    (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring)
    (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring)

/-! ## Tropical/Lagrangian Dual Structure -/

/-- The Lagrangian dual set for slope s. -/
def lagrangianDualSet (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) : Set ℝ :=
  {r : ℝ | ∃ W : Channel α β, mutualInfo μ W + s * expectedDistortion μ W d = r}

/-- The Lagrangian dual functional. -/
def lagrangianDual (μ : FinProbDist α) (d : α → β → ℝ) (s : ℝ) : ℝ :=
  sInf (lagrangianDualSet μ d s)

/-
**Lagrangian dual bound**: for any s ≥ 0, R(D) ≥ L(s) - s·D.
-/
theorem lagrangianDual_le_rateDistortion (μ : FinProbDist α) (d : α → β → ℝ)
    (s : ℝ) (hs : 0 ≤ s) (D : ℝ) (hD : FeasibleDistortion μ d D) :
    lagrangianDual μ d s - s * D ≤ rateDistortion μ d D := by
  refine' le_csInf _ _;
  · exact ⟨ _, ⟨ hD.choose, hD.choose_spec, rfl ⟩ ⟩;
  · obtain ⟨W₀, hW₀⟩ := hD;
    intro r hr
    obtain ⟨W, hW_dist, hW_mi⟩ := hr;
    rw [ sub_le_iff_le_add ];
    refine' le_trans ( csInf_le _ ⟨ W, rfl ⟩ ) _;
    · -- By definition of $lagrangianDualSet$, we know that it is bounded below.
      have h_bdd_below : ∃ C : ℝ, ∀ W : Channel α β, mutualInfo μ W + s * expectedDistortion μ W d ≥ C := by
        have h_bdd_below : ∃ C : ℝ, ∀ W : Channel α β, expectedDistortion μ W d ≥ C := by
          use -∑ a, ∑ b, |μ.prob a * d a b|;
          intro W
          have h_abs : ∀ a b, |μ.prob a * W.cond a b * d a b| ≤ |μ.prob a * d a b| := by
            intro a b
            have h_abs : |W.cond a b| ≤ 1 := by
              nontriviality;
              exact abs_le.mpr ⟨ by linarith [ W.cond_nonneg a b ], by linarith [ W.cond_le_one a b ] ⟩;
            rw [ abs_mul, abs_mul ];
            rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_right ( mul_le_of_le_one_right ( abs_nonneg _ ) h_abs ) ( abs_nonneg _ );
          exact le_trans ( by simp +decide [ Finset.sum_neg_distrib ] ) ( Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => neg_le_of_abs_le ( h_abs a b ) );
        exact ⟨ h_bdd_below.choose * s + ( Classical.choose ( mutualInfo_bddBelow μ ) ), fun W => by nlinarith [ Classical.choose_spec ( mutualInfo_bddBelow μ ) W, h_bdd_below.choose_spec W ] ⟩;
      exact ⟨ h_bdd_below.choose, fun x hx => by obtain ⟨ W, rfl ⟩ := hx; exact h_bdd_below.choose_spec W ⟩;
    · exact add_le_add ( hW_mi.le ) ( mul_le_mul_of_nonneg_left hW_dist hs )

/-! ## Feasibility -/

/-- When β is nonempty, there always exists a feasible distortion level. -/
theorem feasibleDistortion_nonempty [Nonempty β] (μ : FinProbDist α) (d : α → β → ℝ) :
    ∃ D : ℝ, FeasibleDistortion μ d D := by
  obtain ⟨W, hW⟩ : ∃ W : α → β → ℝ, (∀ a b, 0 ≤ W a b) ∧ (∀ a, ∑ b, W a b = 1) :=
    ⟨fun _ _ => 1 / Fintype.card β,
     fun _ _ => div_nonneg zero_le_one (Nat.cast_nonneg _),
     fun _ => by simp [ne_of_gt (Fintype.card_pos)]⟩
  exact ⟨_, ⟨⟨W, hW.1, hW.2⟩, le_refl _⟩⟩

end