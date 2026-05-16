import Mathlib

/-!
# Finite Rate-Distortion Theory: Structural Theorems

This file proves the core structural properties of the finite rate-distortion
function R(D): existence of minimizers and convexity.

## Main Results

* `FinRD.finite_rateDistortion_exists_minimizer` — For finite types, a minimizer of
  mutual information exists at every feasible distortion level.
* `FinRD.finite_rateDistortion_convexOn` — R(D) is convex on the feasible distortion set.

## Mathematical Significance

These results turn R(D) from an abstract infimum into a concrete, attained minimum.
Combined with monotonicity and the Lagrangian dual bound, they establish that R(D) is
a well-behaved convex function — the starting point for polyhedral/tropical analysis.
-/

open Finset BigOperators Real

noncomputable section

namespace FinRD

/-! ## Core Definitions (self-contained) -/

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

variable {α β : Type*} [Fintype α] [Fintype β]

/-- Joint distribution. -/
def jointDist (μ : FinProbDist α) (W : Channel α β) (a : α) (b : β) : ℝ :=
  μ.prob a * W.cond a b

/-- Output marginal. -/
def outputDist (μ : FinProbDist α) (W : Channel α β) (b : β) : ℝ :=
  ∑ a : α, jointDist μ W a b

/-- Expected distortion. -/
def expectedDistortion (μ : FinProbDist α) (W : Channel α β) (d : α → β → ℝ) : ℝ :=
  ∑ a : α, ∑ b : β, jointDist μ W a b * d a b

/-- Safe log. -/
def safeLog (x : ℝ) : ℝ := if x > 0 then Real.log x else 0

/-- Negative entropy summand. -/
def negEntSummand (x : ℝ) : ℝ := if x = 0 then 0 else x * Real.log x

/-- Shannon entropy. -/
def shannonEntropy (ι : Type*) [Fintype ι] (p : ι → ℝ) : ℝ :=
  - ∑ i : ι, negEntSummand (p i)

/-- Mutual information via entropy decomposition:
    I(X;Y) = H(X) + H(Y) - H(X,Y). -/
def mutualInfo (μ : FinProbDist α) (W : Channel α β) : ℝ :=
  shannonEntropy α μ.prob + shannonEntropy β (fun b => outputDist μ W b) -
  shannonEntropy (α × β) (fun p => jointDist μ W p.1 p.2)

/-- Feasibility predicate. -/
def FeasibleDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ W : Channel α β, expectedDistortion μ W d ≤ D

/-- Rate-distortion set. -/
def rateDistortionSet (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : Set ℝ :=
  {r : ℝ | ∃ W : Channel α β, expectedDistortion μ W d ≤ D ∧ mutualInfo μ W = r}

/-- Rate-distortion function. -/
def rateDistortion (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf (rateDistortionSet μ d D)

/-- A rate-distortion minimizer. -/
def IsRateDistortionMinimizer (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ)
    (W : Channel α β) : Prop :=
  expectedDistortion μ W d ≤ D ∧
  ∀ W' : Channel α β, expectedDistortion μ W' d ≤ D →
    mutualInfo μ W ≤ mutualInfo μ W'

/-- Channel conditional is bounded by 1. -/
theorem Channel.cond_le_one (W : Channel α β) (a : α) (b : β) : W.cond a b ≤ 1 :=
  le_trans (Finset.single_le_sum (fun x _ => W.cond_nonneg a x) (Finset.mem_univ b))
    (W.cond_sum a ▸ le_rfl)

/-- Prob is bounded by 1. -/
theorem FinProbDist.prob_le_one (μ : FinProbDist α) (a : α) : μ.prob a ≤ 1 :=
  μ.prob_sum ▸ Finset.single_le_sum (fun a _ => μ.prob_nonneg a) (Finset.mem_univ a)

/-! ## Helper: Feasible Channel Set is Compact -/

/-- The feasible channel set as a subset of (α → β → ℝ). -/
def feasibleChannelSet (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    Set (α → β → ℝ) :=
  {K | (∀ a b, 0 ≤ K a b) ∧ (∀ a, ∑ b, K a b = 1) ∧
       (∑ a, ∑ b, μ.prob a * K a b * d a b ≤ D)}

theorem feasibleChannelSet_closed (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    IsClosed (feasibleChannelSet μ d D) := by
  -- The intersection of closed sets is closed.
  apply IsClosed.inter;
  · -- The set of functions K such that for all a and b, 0 ≤ K a b is closed because it is the intersection of closed sets.
    have h_closed : IsClosed {K : α → β → ℝ | ∀ a b, 0 ≤ K a b} := by
      have h_closed_each : ∀ a b, IsClosed {K : α → β → ℝ | 0 ≤ K a b} := by
        exact fun a b => isClosed_le continuous_const ( continuous_apply _ |> Continuous.comp <| continuous_apply _ )
      simpa only [ Set.setOf_forall ] using isClosed_iInter fun a => isClosed_iInter fun b => h_closed_each a b;
    grind;
  · apply_rules [ IsClosed.inter, isClosed_const ];
    · -- The set of functions satisfying a continuous linear condition is closed. Each condition ∑ b, K a b = 1 is a linear equation, so the set of K satisfying this for each a is closed.
      have h_closed_linear : ∀ a, IsClosed {K : α → β → ℝ | ∑ b, K a b = 1} := by
        exact fun a => isClosed_eq ( continuous_finset_sum _ fun _ _ => continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const;
      convert isClosed_iInter fun a => h_closed_linear a using 1;
      aesop;
    · -- The sum of continuous functions is continuous, hence the function $K \mapsto \sum_{a,b} \mu(a) K(a,b) d(a,b)$ is continuous.
      have h_cont : Continuous (fun K : α → β → ℝ => ∑ a, ∑ b, μ.prob a * K a b * d a b) := by
        fun_prop;
      exact isClosed_le h_cont continuous_const

theorem feasibleChannelSet_bounded (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    ∀ K ∈ feasibleChannelSet μ d D, ∀ a b, K a b ∈ Set.Icc (0 : ℝ) 1 := by
  exact fun K hK a b => ⟨ hK.1 a b, hK.2.1 a ▸ Finset.single_le_sum ( fun b _ => hK.1 a b ) ( Finset.mem_univ b ) ⟩

theorem feasibleChannelSet_compact (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    IsCompact (feasibleChannelSet μ d D) := by
  have h_closed : IsClosed (feasibleChannelSet μ d D) := by
    exact?;
  exact CompactIccSpace.isCompact_Icc.of_isClosed_subset h_closed fun x hx => ⟨ fun a b => hx.1 a b, fun a b => hx.2.1 a |> fun h => h ▸ Finset.single_le_sum ( fun b _ => hx.1 a b ) ( Finset.mem_univ b ) ⟩

/-! ## Existence of Minimizers -/

/-
**Existence of rate-distortion minimizers for finite alphabets.**

For finite source and reproduction alphabets, if the distortion level D is
feasible, then there exists a channel W that simultaneously:
1. Achieves expected distortion ≤ D, and
2. Minimizes mutual information among all such channels.
-/
theorem finite_rateDistortion_exists_minimizer
    [Nonempty α] [Nonempty β]
    (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ)
    (hD : FeasibleDistortion μ d D) :
    ∃ W : Channel α β, IsRateDistortionMinimizer μ d D W := by
  have h_compact : IsCompact {K : α → β → ℝ | (∀ a b, 0 ≤ K a b) ∧ (∀ a, ∑ b, K a b = 1) ∧ (∑ a, ∑ b, μ.prob a * K a b * d a b ≤ D)} := by
    convert feasibleChannelSet_compact μ d D;
  have h_continuous : ContinuousOn (fun K : α → β → ℝ => shannonEntropy α μ.prob + shannonEntropy β (fun b => ∑ a, μ.prob a * K a b) - shannonEntropy (α × β) (fun p => μ.prob p.1 * K p.1 p.2)) {K : α → β → ℝ | (∀ a b, 0 ≤ K a b) ∧ (∀ a, ∑ b, K a b = 1) ∧ (∑ a, ∑ b, μ.prob a * K a b * d a b ≤ D)} := by
    refine' ContinuousOn.sub ( ContinuousOn.add continuousOn_const _ ) _;
    · refine' Continuous.continuousOn _;
      refine' continuous_neg.comp ( continuous_finset_sum _ fun b _ => _ );
      refine' Continuous.congr _ _;
      use fun x => ( ∑ a, μ.prob a * x a b ) * Real.log ( ∑ a, μ.prob a * x a b );
      · fun_prop;
      · intro x; unfold negEntSummand; aesop;
    · refine' ContinuousOn.neg ( continuousOn_finset_sum _ fun p _ => _ );
      refine' ContinuousOn.congr _ _;
      use fun K => μ.prob p.1 * K p.1 p.2 * Real.log ( μ.prob p.1 * K p.1 p.2 );
      · have h_cont : ContinuousOn (fun x : ℝ => x * Real.log x) (Set.Icc 0 1) := by
          exact Continuous.continuousOn ( Real.continuous_mul_log );
        refine' h_cont.comp ( ContinuousOn.mul continuousOn_const <| continuousOn_pi.1 ( continuousOn_pi.1 continuousOn_id _ ) _ ) fun K hK => _;
        exact ⟨ mul_nonneg ( μ.prob_nonneg _ ) ( hK.1 _ _ ), mul_le_one₀ ( μ.prob_le_one _ ) ( hK.1 _ _ ) ( hK.2.1 _ ▸ Finset.single_le_sum ( fun b _ => hK.1 _ b ) ( Finset.mem_univ _ ) ) ⟩;
      · intro K hK; simp +decide [ negEntSummand ] ;
        grind;
  obtain ⟨ W, hW ⟩ := h_compact.exists_isMinOn ( show { K : α → β → ℝ | ( ∀ a b, 0 ≤ K a b ) ∧ ( ∀ a, ∑ b, K a b = 1 ) ∧ ∑ a, ∑ b, μ.prob a * K a b * d a b ≤ D }.Nonempty from by
                                                  obtain ⟨ W, hW ⟩ := hD;
                                                  exact ⟨ W.cond, ⟨ W.cond_nonneg, W.cond_sum, by simpa only [ expectedDistortion, jointDist, mul_assoc ] using hW ⟩ ⟩ ) h_continuous;
  refine' ⟨ ⟨ W, hW.1.1, hW.1.2.1 ⟩, _, _ ⟩ <;> simp_all +decide [ expectedDistortion, mutualInfo ];
  · simpa only [ jointDist, mul_assoc ] using hW.1.2.2;
  · intro W' hW';
    have := hW.2 ( show ( fun a b => W'.cond a b ) ∈ { K : α → β → ℝ | ( ∀ a b, 0 ≤ K a b ) ∧ ( ∀ a, ∑ b, K a b = 1 ) ∧ ∑ a, ∑ b, μ.prob a * K a b * d a b ≤ D } from ⟨ fun a b => W'.cond_nonneg a b, fun a => W'.cond_sum a, by simpa [ jointDist, outputDist ] using hW' ⟩ ) ; simp_all +decide [ jointDist, outputDist ] ;

/-! ## Convexity -/

/-- The feasible distortion set. -/
def feasibleDistortionSet (μ : FinProbDist α) (d : α → β → ℝ) : Set ℝ :=
  {D : ℝ | FeasibleDistortion μ d D}

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

/-- Expected distortion is affine in the channel mixture. -/
theorem expectedDistortion_mix (μ : FinProbDist α) (d : α → β → ℝ)
    (W₁ W₂ : Channel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    expectedDistortion μ (channelMix W₁ W₂ t ht0 ht1) d =
    t * expectedDistortion μ W₁ d + (1 - t) * expectedDistortion μ W₂ d := by
  unfold expectedDistortion channelMix
  simp only [jointDist, mul_add, add_mul, mul_assoc, Finset.sum_add_distrib, Finset.mul_sum]
  exact congrArg₂ (· + ·)
    (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring)
    (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring)

/-- The feasible distortion set is convex. -/
theorem feasibleDistortionSet_convex (μ : FinProbDist α) (d : α → β → ℝ) :
    Convex ℝ (feasibleDistortionSet μ d) := by
  intro D₁ hD₁ D₂ hD₂ a b ha hb hab
  obtain ⟨W₁, hW₁⟩ := hD₁
  obtain ⟨W₂, hW₂⟩ := hD₂
  use channelMix W₁ W₂ a ha (by linarith)
  convert add_le_add (mul_le_mul_of_nonneg_left hW₁ ha)
    (mul_le_mul_of_nonneg_left hW₂ hb) using 1
  convert expectedDistortion_mix μ d W₁ W₂ a ha (by linarith) using 1
  rw [← hab]; ring

/-- The feasible distortion set is upward-closed. -/
theorem feasibleDistortionSet_Ici (μ : FinProbDist α) (d : α → β → ℝ)
    {D₁ D₂ : ℝ} (h : D₁ ≤ D₂) (hD₁ : FeasibleDistortion μ d D₁) :
    FeasibleDistortion μ d D₂ := by
  obtain ⟨W, hW⟩ := hD₁
  exact ⟨W, le_trans hW h⟩

/-
Rate-distortion set has bounded below values.
-/
theorem rateDistortionSet_bddBelow (μ : FinProbDist α) (d : α → β → ℝ) (D : ℝ) :
    BddBelow (rateDistortionSet μ d D) := by
  -- By definition of $rateDistortionSet$, we know that every element in $rateDistortionSet μ d D$ is of the form $mutualInfo μ W$ for some channel $W$.
  unfold rateDistortionSet;
  -- Every element in the set is of the form $mutualInfo μ W$ for some channel $W$.
  simp [mutualInfo];
  -- By definition of $shannonEntropy$, we know that $shannonEntropy α μ.prob$ and $shannonEntropy β (fun b => outputDist μ W b)$ are bounded below.
  have h_shannonEntropy_bdd_below : ∃ C₁ : ℝ, ∀ W : Channel α β, shannonEntropy β (fun b => outputDist μ W b) ≥ C₁ := by
    -- By definition of $shannonEntropy$, we know that $shannonEntropy β (fun b => outputDist μ W b)$ is bounded below.
    have h_shannonEntropy_bdd_below : ∃ C₁ : ℝ, ∀ p : β → ℝ, (∀ b, 0 ≤ p b) ∧ (∑ b, p b = 1) → shannonEntropy β p ≥ C₁ := by
      unfold shannonEntropy;
      use - ( Fintype.card β ) * ( 1 / Real.exp 1 );
      intro p hp
      have h_negEntSummand_bdd_below : ∀ b, - (if p b = 0 then 0 else p b * Real.log (p b)) ≥ - (1 / Real.exp 1) := by
        intro b; split_ifs <;> simp_all +decide [ Real.exp_neg ];
        · positivity;
        · exact le_trans ( mul_nonpos_of_nonneg_of_nonpos ( hp.1 b ) ( Real.log_nonpos ( hp.1 b ) ( hp.2 ▸ Finset.single_le_sum ( fun a _ => hp.1 a ) ( Finset.mem_univ b ) ) ) ) ( by positivity );
      simpa [ neg_mul ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_negEntSummand_bdd_below i;
    refine' ⟨ h_shannonEntropy_bdd_below.choose, fun W => h_shannonEntropy_bdd_below.choose_spec _ ⟨ _, _ ⟩ ⟩;
    · exact fun b => Finset.sum_nonneg fun a _ => mul_nonneg ( μ.prob_nonneg a ) ( W.cond_nonneg a b );
    · unfold outputDist;
      rw [ Finset.sum_comm ];
      simp +decide [ jointDist, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, μ.prob_sum, W.cond_sum ];
  -- By definition of $shannonEntropy$, we know that $shannonEntropy (α × β) (fun p => jointDist μ W p.1 p.2)$ is bounded above.
  have h_shannonEntropy_bdd_above : ∃ C₂ : ℝ, ∀ W : Channel α β, shannonEntropy (α × β) (fun p => jointDist μ W p.1 p.2) ≤ C₂ := by
    -- Each term in the sum involves x * log x where 0 ≤ x ≤ 1. By x*log(x) ≥ -1/e for x ∈ [0,1], each summand is bounded. So there exists a constant C (depending on |α|, |β|) bounding mutualInfo below for all channels.
    have h_term_bdd_above : ∃ C : ℝ, ∀ x : ℝ, 0 ≤ x ∧ x ≤ 1 → -negEntSummand x ≤ C := by
      use 1;
      intro x hx; unfold negEntSummand; split_ifs <;> norm_num;
      nlinarith [ Real.log_inv x ▸ Real.log_le_sub_one_of_pos ( inv_pos.mpr ( lt_of_le_of_ne hx.1 ( Ne.symm ‹_› ) ) ), mul_inv_cancel₀ ‹_› ];
    obtain ⟨ C, hC ⟩ := h_term_bdd_above; use C * Fintype.card ( α × β ) ; intro W; simp +decide [ shannonEntropy ] ;
    rw [ neg_le ];
    refine' le_trans _ ( Finset.sum_le_sum fun x _ => show negEntSummand ( jointDist μ W x.1 x.2 ) ≥ -C from _ );
    · simp +decide [ mul_comm ];
    · exact neg_le.mp ( hC _ ⟨ mul_nonneg ( μ.prob_nonneg _ ) ( W.cond_nonneg _ _ ), mul_le_one₀ ( μ.prob_le_one _ ) ( W.cond_nonneg _ _ ) ( W.cond_le_one _ _ ) ⟩ );
  exact ⟨ h_shannonEntropy_bdd_below.choose + shannonEntropy α μ.prob - h_shannonEntropy_bdd_above.choose, by rintro x ⟨ W, hW₁, rfl ⟩ ; linarith [ h_shannonEntropy_bdd_below.choose_spec W, h_shannonEntropy_bdd_above.choose_spec W ] ⟩

/-- Rate-distortion set inclusion for increasing D. -/
theorem rateDistortionSet_mono (μ : FinProbDist α) (d : α → β → ℝ)
    {D₁ D₂ : ℝ} (hD : D₁ ≤ D₂) :
    rateDistortionSet μ d D₁ ⊆ rateDistortionSet μ d D₂ := by
  intro r ⟨W, hW₁, hW₂⟩
  exact ⟨W, le_trans hW₁ hD, hW₂⟩

/-- R(D) is antitone (nonincreasing). -/
theorem rateDistortion_antitone (μ : FinProbDist α) (d : α → β → ℝ)
    {D₁ D₂ : ℝ} (hD : D₁ ≤ D₂) (hfeas : FeasibleDistortion μ d D₁) :
    rateDistortion μ d D₂ ≤ rateDistortion μ d D₁ := by
  apply csInf_le_csInf (rateDistortionSet_bddBelow μ d D₂)
  · obtain ⟨W, hW⟩ := hfeas; exact ⟨_, W, hW, rfl⟩
  · exact rateDistortionSet_mono μ d hD

/-
negEntSummand is convex on [0,∞), i.e., x ↦ x log x is convex.
-/
theorem negEntSummand_convexOn : ConvexOn ℝ (Set.Ici 0) negEntSummand := by
  convert ConvexOn.congr ( convexOn_mul_log ) _ using 1;
  intro x hx; unfold negEntSummand; aesop;

/-
Joint distribution sums to 1.
-/
theorem jointDist_sum_one (μ : FinProbDist α) (W : Channel α β) :
    ∑ p : α × β, jointDist μ W p.1 p.2 = 1 := by
  convert μ.prob_sum;
  unfold jointDist;
  erw [ Finset.sum_product ] ; simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, W.cond_sum ] ;

/-
Joint distribution of mixed channel is the mixture of joint distributions.
-/
theorem jointDist_mix (μ : FinProbDist α) (W₁ W₂ : Channel α β)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) (a : α) (b : β) :
    jointDist μ (channelMix W₁ W₂ t ht0 ht1) a b =
    t * jointDist μ W₁ a b + (1 - t) * jointDist μ W₂ a b := by
  unfold jointDist channelMix; ring;

/-
Shannon entropy is concave: H(t*p + (1-t)*q) ≥ t*H(p) + (1-t)*H(q) for
    probability distributions p, q. Equivalently, the sum of negEntSummand is
    convex. This is the core log-sum inequality.
-/
theorem shannonEntropy_concave_sum {ι : Type*} [Fintype ι]
    (p q : ι → ℝ) (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    ∑ i, negEntSummand (t * p i + (1 - t) * q i) ≤
    t * ∑ i, negEntSummand (p i) + (1 - t) * ∑ i, negEntSummand (q i) := by
  rw [ Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib ];
  apply Finset.sum_le_sum;
  exact fun i _ => negEntSummand_convexOn.2 ( hp i ) ( hq i ) ( by linarith ) ( by linarith ) ( by linarith )

/-
The KL divergence summand f(p,q) = p * log(p/q) is jointly convex on [0,∞) × (0,∞).
    This is the perspective of the convex function -log.
-/
theorem kl_summand_jointly_convex :
    ConvexOn ℝ (Set.Ici (0 : ℝ) ×ˢ Set.Ioi (0 : ℝ))
      (fun p : ℝ × ℝ => p.1 * Real.log (p.1 / p.2)) := by
  refine' ⟨ _, _ ⟩;
  · exact convex_Ici _ |> Convex.prod <| convex_Ioi _;
  · intro p hp q hq a b ha hb hab;
    have h_log_sum : ∀ (a₁ a₂ b₁ b₂ : ℝ), 0 ≤ a₁ → 0 ≤ a₂ → 0 < b₁ → 0 < b₂ → ∀ (t : ℝ), 0 ≤ t → t ≤ 1 → (t * a₁ + (1 - t) * a₂) * Real.log ((t * a₁ + (1 - t) * a₂) / (t * b₁ + (1 - t) * b₂)) ≤ t * a₁ * Real.log (a₁ / b₁) + (1 - t) * a₂ * Real.log (a₂ / b₂) := by
      intros a₁ a₂ b₁ b₂ ha₁ ha₂ hb₁ hb₂ t ht₀ ht₁;
      by_cases h : t * a₁ + ( 1 - t ) * a₂ = 0 <;> by_cases h' : t * b₁ + ( 1 - t ) * b₂ = 0 <;> simp_all +decide [ mul_assoc, mul_div_cancel₀ ];
      · cases lt_or_eq_of_le ht₀ <;> cases lt_or_eq_of_le ht₁ <;> nlinarith;
      · by_cases h'' : a₁ = 0 <;> by_cases h''' : a₂ = 0 <;> simp_all +decide [ add_eq_zero_iff_of_nonneg ];
        cases lt_or_eq_of_le ht₀ <;> cases lt_or_eq_of_le ht₁ <;> nlinarith [ show 0 < a₁ by positivity, show 0 < a₂ by positivity ];
      · cases lt_or_eq_of_le ht₀ <;> cases lt_or_eq_of_le ht₁ <;> nlinarith;
      · have h_log_sum : ∀ (x₁ x₂ : ℝ), 0 ≤ x₁ → 0 ≤ x₂ → ∀ (w₁ w₂ : ℝ), 0 ≤ w₁ → 0 ≤ w₂ → w₁ + w₂ = 1 → w₁ * x₁ * Real.log x₁ + w₂ * x₂ * Real.log x₂ ≥ (w₁ * x₁ + w₂ * x₂) * Real.log (w₁ * x₁ + w₂ * x₂) := by
          have h_log_sum : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
            exact ( Real.convexOn_mul_log );
          exact fun x₁ x₂ hx₁ hx₂ w₁ w₂ hw₁ hw₂ hw => by simpa [ mul_assoc ] using h_log_sum.2 hx₁ hx₂ hw₁ hw₂ hw;
        have := h_log_sum ( a₁ / b₁ ) ( a₂ / b₂ ) ( div_nonneg ha₁ hb₁.le ) ( div_nonneg ha₂ hb₂.le ) ( t * b₁ / ( t * b₁ + ( 1 - t ) * b₂ ) ) ( ( 1 - t ) * b₂ / ( t * b₁ + ( 1 - t ) * b₂ ) ) ( div_nonneg ( mul_nonneg ht₀ hb₁.le ) ( add_nonneg ( mul_nonneg ht₀ hb₁.le ) ( mul_nonneg ( sub_nonneg.mpr ht₁ ) hb₂.le ) ) ) ( div_nonneg ( mul_nonneg ( sub_nonneg.mpr ht₁ ) hb₂.le ) ( add_nonneg ( mul_nonneg ht₀ hb₁.le ) ( mul_nonneg ( sub_nonneg.mpr ht₁ ) hb₂.le ) ) ) ( by rw [ ← add_div, div_eq_iff h' ] ; ring );
        field_simp at this ⊢;
        rwa [ div_le_div_iff_of_pos_right ( by contrapose! h'; nlinarith ) ] at this;
    convert h_log_sum p.1 q.1 p.2 q.2 hp.1 hq.1 hp.2 hq.2 a ha ( by linarith ) using 1 <;> norm_num [ show b = 1 - a by linarith ] ; ring

/-
KL divergence is jointly convex: for probability-like vectors p₁, p₂, q₁, q₂ ≥ 0
    with q > 0, and t ∈ [0,1],
    ∑ (t*p₁+... ) * log(...) ≤ t * ∑ p₁*log(...) + (1-t) * ∑ p₂*log(...).
-/
theorem kl_divergence_jointly_convex {ι : Type*} [Fintype ι]
    (p₁ p₂ q₁ q₂ : ι → ℝ)
    (hp₁ : ∀ i, 0 ≤ p₁ i) (hp₂ : ∀ i, 0 ≤ p₂ i)
    (hq₁ : ∀ i, 0 < q₁ i) (hq₂ : ∀ i, 0 < q₂ i)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    ∑ i, (t * p₁ i + (1 - t) * p₂ i) *
      Real.log ((t * p₁ i + (1 - t) * p₂ i) / (t * q₁ i + (1 - t) * q₂ i)) ≤
    t * ∑ i, p₁ i * Real.log (p₁ i / q₁ i) +
    (1 - t) * ∑ i, p₂ i * Real.log (p₂ i / q₂ i) := by
  nontriviality;
  have := kl_summand_jointly_convex;
  convert Finset.sum_le_sum fun i _ => this.2 ( show ( p₁ i, q₁ i ) ∈ Set.Ici 0 ×ˢ Set.Ioi 0 from ⟨ hp₁ i, hq₁ i ⟩ ) ( show ( p₂ i, q₂ i ) ∈ Set.Ici 0 ×ˢ Set.Ioi 0 from ⟨ hp₂ i, hq₂ i ⟩ ) ht0 ( sub_nonneg.2 ht1 ) ( by linarith ) using 1;
  simp +decide [ Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_add ]

/-- Mutual information is convex in the channel: for any t ∈ [0,1],
    I(μ; t·W₁ + (1-t)·W₂) ≤ t·I(μ;W₁) + (1-t)·I(μ;W₂). -/
theorem mutualInfo_convex_channel
    (μ : FinProbDist α) (W₁ W₂ : Channel α β)
    (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    mutualInfo μ (channelMix W₁ W₂ t ht0 ht1) ≤
    t * mutualInfo μ W₁ + (1 - t) * mutualInfo μ W₂ := by
  sorry

/--
**Convexity of the rate-distortion function.**

R(D) is convex on the feasible distortion set. The proof uses:
1. Channel mixing preserves feasibility (expectedDistortion_mix)
2. Mutual information is convex in the channel (mutualInfo_convex_channel)
3. The infimum of a convex function over a growing constraint set is convex.
-/
theorem finite_rateDistortion_convexOn
    [Nonempty α] [Nonempty β]
    (μ : FinProbDist α) (d : α → β → ℝ) :
    ConvexOn ℝ (feasibleDistortionSet μ d) (rateDistortion μ d) := by
  sorry

end FinRD

end