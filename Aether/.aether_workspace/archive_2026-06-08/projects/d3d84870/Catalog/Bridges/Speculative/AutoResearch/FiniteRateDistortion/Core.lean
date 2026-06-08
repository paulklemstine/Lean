import Mathlib

/-!
# Finite Rate-Distortion Theory

This file develops finite rate-distortion theory over finite alphabets with explicit
probability distributions and stochastic channels. It proves core structural theorems
including monotonicity, convexity of the feasible set, and existence of minimizers.

## Main Definitions

* `FinProb` — Finite probability distribution
* `Channel` — Stochastic channel (conditional distribution)
* `expectedDistortion` — Expected distortion under a channel
* `mutualInfo` — Mutual information between source and channel output
* `rateDistortion` — The rate-distortion function R(D)
* `IsMinimizer` — Predicate for rate-distortion minimizing channels

## Main Theorems

* `rateDistortion_antitone_feasible` — R(D) is antitone on the feasible set
* `feasibleDistortionSet_convex` — The feasible distortion set is convex
* `expectedDistortion_mix` — Expected distortion is affine in channel mixing
* `finite_rateDistortion_exists_minimizer` — Existence of minimizers

## Mathematical Significance

These results establish that for finite source and reproduction alphabets,
rate-distortion theory has clean combinatorial structure: the infimum is always
attained, monotonicity holds, and the feasible set is well-behaved. This creates
a foundation for certified computation of R(D) curves and connections to
tropical/polyhedral optimization.
-/

open Finset BigOperators Real

noncomputable section

namespace FiniteRateDistortion

/-! ## Core Definitions -/

/-- A finite probability distribution over a finite type. -/
structure FinProb (α : Type*) [Fintype α] where
  prob : α → ℝ
  prob_nonneg : ∀ x, 0 ≤ prob x
  prob_sum : ∑ x : α, prob x = 1

variable {α β : Type*} [Fintype α] [Fintype β]

/-- A stochastic channel from α to β: for each input, a probability distribution on outputs. -/
structure Channel (α β : Type*) [Fintype α] [Fintype β] where
  cond : α → β → ℝ
  cond_nonneg : ∀ x y, 0 ≤ cond x y
  cond_sum : ∀ x, ∑ y : β, cond x y = 1

/-- The joint mass function induced by a source distribution and a channel. -/
def jointMass (μ : FinProb α) (K : Channel α β) (x : α) (y : β) : ℝ :=
  μ.prob x * K.cond x y

/-- The second marginal (output) distribution. -/
def marginal₂ (μ : FinProb α) (K : Channel α β) (y : β) : ℝ :=
  ∑ x : α, jointMass μ K x y

/-- Expected distortion under a channel. -/
def expectedDistortion (μ : FinProb α) (K : Channel α β) (d : α → β → ℝ) : ℝ :=
  ∑ x : α, ∑ y : β, jointMass μ K x y * d x y

/-- The negative-entropy summand: x * log x, extended by 0 at x = 0. -/
def negEntSummand (x : ℝ) : ℝ :=
  if x = 0 then 0 else x * Real.log x

/-- Shannon entropy of a finite distribution given by mass function p. -/
def shannonEntropy' (ι : Type*) [Fintype ι] (p : ι → ℝ) : ℝ :=
  - ∑ i : ι, negEntSummand (p i)

/-- Mutual information: I(X;Y) = H(X) + H(Y) - H(X,Y) -/
def mutualInfo (μ : FinProb α) (K : Channel α β) : ℝ :=
  shannonEntropy' α μ.prob + shannonEntropy' β (marginal₂ μ K) -
  shannonEntropy' (α × β) (fun p => jointMass μ K p.1 p.2)

/-- Whether a distortion level D is feasible (some channel achieves it). -/
def IsFeasible (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) : Prop :=
  ∃ K : Channel α β, expectedDistortion μ K d ≤ D

/-- The set of feasible distortion levels. -/
def feasibleDistortionSet (μ : FinProb α) (d : α → β → ℝ) : Set ℝ :=
  {D | IsFeasible μ d D}

/-- The set of channels achieving expected distortion at most D. -/
def feasibleChannels (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) : Set (Channel α β) :=
  {K | expectedDistortion μ K d ≤ D}

/-- The rate-distortion function R(D) = inf { I(X;Y) : E[d] ≤ D }. -/
def rateDistortion (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf {r | ∃ K : Channel α β, expectedDistortion μ K d ≤ D ∧ mutualInfo μ K = r}

/-- A channel is a rate-distortion minimizer at level D. -/
def IsMinimizer (μ : FinProb α) (d : α → β → ℝ) (D : ℝ) (K : Channel α β) : Prop :=
  expectedDistortion μ K d ≤ D ∧
  ∀ K' : Channel α β, expectedDistortion μ K' d ≤ D →
    mutualInfo μ K ≤ mutualInfo μ K'

/-! ## Basic Lemmas -/

theorem jointMass_nonneg (μ : FinProb α) (K : Channel α β) (x : α) (y : β) :
    0 ≤ jointMass μ K x y :=
  mul_nonneg (μ.prob_nonneg x) (K.cond_nonneg x y)

theorem marginal₂_nonneg (μ : FinProb α) (K : Channel α β) (y : β) :
    0 ≤ marginal₂ μ K y :=
  Finset.sum_nonneg (fun x _ => jointMass_nonneg μ K x y)

theorem jointMass_sum (μ : FinProb α) (K : Channel α β) :
    ∑ x : α, ∑ y : β, jointMass μ K x y = 1 := by
  simp only [jointMass, ← Finset.mul_sum]
  simp [K.cond_sum, μ.prob_sum]

theorem marginal₂_sum (μ : FinProb α) (K : Channel α β) :
    ∑ y : β, marginal₂ μ K y = 1 := by
  simp only [marginal₂]
  rw [Finset.sum_comm]
  exact jointMass_sum μ K

/-- Feasibility is upward-closed in D. -/
theorem IsFeasible.of_le {μ : FinProb α} {d : α → β → ℝ} {D₁ D₂ : ℝ}
    (h : IsFeasible μ d D₁) (hle : D₁ ≤ D₂) : IsFeasible μ d D₂ := by
  obtain ⟨K, hK⟩ := h
  exact ⟨K, le_trans hK hle⟩

/-! ## Channel Mixing -/

/-- The mixing (convex combination) of two channels. -/
def Channel.mix (K₁ K₂ : Channel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    Channel α β where
  cond x y := t * K₁.cond x y + (1 - t) * K₂.cond x y
  cond_nonneg x y := by
    apply add_nonneg
    · exact mul_nonneg ht0 (K₁.cond_nonneg x y)
    · exact mul_nonneg (by linarith) (K₂.cond_nonneg x y)
  cond_sum x := by
    trans t * ∑ y : β, K₁.cond x y + (1 - t) * ∑ y : β, K₂.cond x y
    · rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    · rw [K₁.cond_sum, K₂.cond_sum]; ring

/-- Expected distortion is affine in the channel. -/
theorem expectedDistortion_mix (μ : FinProb α) (d : α → β → ℝ)
    (K₁ K₂ : Channel α β) (t : ℝ) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    expectedDistortion μ (Channel.mix K₁ K₂ t ht0 ht1) d =
    t * expectedDistortion μ K₁ d + (1 - t) * expectedDistortion μ K₂ d := by
  simp only [expectedDistortion, Channel.mix, jointMass]
  have : ∀ x : α, ∀ y : β,
      μ.prob x * (t * K₁.cond x y + (1 - t) * K₂.cond x y) * d x y =
      t * (μ.prob x * K₁.cond x y * d x y) + (1 - t) * (μ.prob x * K₂.cond x y * d x y) := by
    intros; ring
  simp_rw [this, Finset.sum_add_distrib, Finset.mul_sum]

/-! ## Monotonicity and Convexity -/

/-- The feasible channel set grows as D increases. -/
theorem feasibleChannels_mono {μ : FinProb α} {d : α → β → ℝ} {D₁ D₂ : ℝ}
    (h : D₁ ≤ D₂) : feasibleChannels μ d D₁ ⊆ feasibleChannels μ d D₂ := by
  intro K hK; exact le_trans hK h

/-- The achievable MI set at D₂ ⊇ that at D₁ when D₁ ≤ D₂. -/
theorem rateDistortion_values_subset {μ : FinProb α} {d : α → β → ℝ} {D₁ D₂ : ℝ}
    (h : D₁ ≤ D₂) :
    {r | ∃ K : Channel α β, expectedDistortion μ K d ≤ D₁ ∧ mutualInfo μ K = r} ⊆
    {r | ∃ K : Channel α β, expectedDistortion μ K d ≤ D₂ ∧ mutualInfo μ K = r} := by
  rintro r ⟨K, hK, hr⟩; exact ⟨K, le_trans hK h, hr⟩

/-
**R(D) is antitone**: larger distortion budget → more channels feasible → smaller infimum.
-/
theorem rateDistortion_antitone_feasible (μ : FinProb α) (d : α → β → ℝ) {D₁ D₂ : ℝ}
    (h : D₁ ≤ D₂) (hD₁ : IsFeasible μ d D₁) :
    rateDistortion μ d D₂ ≤ rateDistortion μ d D₁ := by
  unfold rateDistortion
  apply csInf_le_csInf
  ·
    refine' ⟨ - ( Fintype.card α * Fintype.card β + 1 ), fun r hr => _ ⟩;
    obtain ⟨ K, hK₁, rfl ⟩ := hr;
    refine' le_trans _ ( sub_le_sub ( le_add_of_nonneg_right _ ) ( show ( shannonEntropy' ( α × β ) ( fun p => jointMass μ K p.1 p.2 ) ) ≤ ( Fintype.card α * Fintype.card β ) from _ ) );
    · unfold shannonEntropy';
      norm_num [ negEntSummand ];
      refine' le_trans ( Finset.sum_le_sum fun x _ => _ ) _;
      use fun x => μ.prob x;
      · split_ifs <;> simp_all +decide [ Real.log_le_iff_le_exp ];
        exact mul_le_of_le_one_right ( μ.prob_nonneg x ) ( Real.log_le_iff_le_exp ( by exact lt_of_le_of_ne ( μ.prob_nonneg x ) ( Ne.symm ‹_› ) ) |>.2 ( by linarith [ Real.add_one_le_exp 1, μ.prob_nonneg x, μ.prob_sum, Finset.single_le_sum ( fun a _ => μ.prob_nonneg a ) ( Finset.mem_univ x ) ] ) );
      · exact μ.prob_sum.le;
    · refine' neg_nonneg_of_nonpos ( Finset.sum_nonpos fun y _ => _ );
      unfold negEntSummand;
      split_ifs <;> simp_all +decide [ marginal₂ ];
      refine' mul_nonpos_of_nonneg_of_nonpos ( Finset.sum_nonneg fun _ _ => jointMass_nonneg _ _ _ _ ) ( Real.log_nonpos _ _ );
      · exact Finset.sum_nonneg fun _ _ => jointMass_nonneg μ K _ _;
      · rw [ ← marginal₂_sum μ K ];
        exact Finset.single_le_sum ( fun y _ => marginal₂_nonneg μ K y ) ( Finset.mem_univ y );
    · refine' le_trans ( neg_le_neg <| Finset.sum_le_sum fun _ _ => _ ) _;
      use fun p => -1;
      · unfold negEntSummand;
        split_ifs <;> norm_num;
        have := Real.log_le_sub_one_of_pos ( show 0 < ( jointMass μ K ‹α × β›.1 ‹α × β›.2 ) ⁻¹ from inv_pos.mpr ( lt_of_le_of_ne ( jointMass_nonneg μ K _ _ ) ( Ne.symm ‹_› ) ) );
        rw [ Real.log_inv ] at this ; nlinarith [ inv_mul_cancel₀ ‹_›, jointMass_nonneg μ K ( ‹α × β›.1 ) ( ‹α × β›.2 ) ];
      · norm_num  -- BddBelow: needs mutual info lower bound
  · obtain ⟨K, hK⟩ := hD₁; exact ⟨mutualInfo μ K, K, hK, rfl⟩
  · exact rateDistortion_values_subset h

/-- The feasible distortion set is convex. -/
theorem feasibleDistortionSet_convex (μ : FinProb α) (d : α → β → ℝ) :
    Convex ℝ (feasibleDistortionSet μ d) := by
  intro D₁ hD₁ D₂ hD₂ t₁ t₂ ht₁ ht₂ ht
  obtain ⟨K₁, hK₁⟩ := hD₁; obtain ⟨K₂, hK₂⟩ := hD₂
  have ht₁1 : t₁ ≤ 1 := by linarith
  refine ⟨Channel.mix K₁ K₂ t₁ ht₁ ht₁1, ?_⟩
  rw [expectedDistortion_mix]
  calc t₁ * expectedDistortion μ K₁ d + (1 - t₁) * expectedDistortion μ K₂ d
      ≤ t₁ * D₁ + (1 - t₁) * D₂ := by
        apply add_le_add
        · exact mul_le_mul_of_nonneg_left hK₁ ht₁
        · exact mul_le_mul_of_nonneg_left hK₂ (by linarith)
    _ = t₁ * D₁ + t₂ * D₂ := by
        have : 1 - t₁ = t₂ := by linarith
        rw [this]

/-! ## Existence of Minimizers -/

/-
**Main Theorem**: For finite alphabets, if D is feasible, a rate-distortion minimizer exists.
-/
theorem finite_rateDistortion_exists_minimizer
    [Nonempty α] [Nonempty β]
    (μ : FinProb α) (d : α → β → ℝ)
    (D : ℝ) (hD : IsFeasible μ d D) :
    ∃ K : Channel α β, IsMinimizer μ d D K := by
  have h_compact : IsCompact {K : α → β → ℝ | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ ∑ x, ∑ y, μ.prob x * K x y * d x y ≤ D} := by
    have h_closed : IsClosed {K : α → β → ℝ | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ ∑ x, ∑ y, μ.prob x * K x y * d x y ≤ D} := by
      simp +decide only [Set.setOf_and, Set.setOf_forall];
      apply_rules [ IsClosed.inter, isClosed_iInter ];
      · exact fun x => isClosed_iInter fun y => isClosed_le continuous_const <| continuous_apply _ |> Continuous.comp <| continuous_apply _;
      · exact fun i => isClosed_eq ( continuous_finset_sum _ fun j _ => continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const;
      · exact isClosed_le ( continuous_finset_sum _ fun _ _ => continuous_finset_sum _ fun _ _ => Continuous.mul ( Continuous.mul continuous_const <| continuous_apply _ |> Continuous.comp <| continuous_apply _ ) continuous_const ) continuous_const;
    exact CompactIccSpace.isCompact_Icc.of_isClosed_subset h_closed fun K hK => ⟨ fun x y => hK.1 x y, fun x y => hK.2.1 x ▸ Finset.single_le_sum ( fun y _ => hK.1 x y ) ( Finset.mem_univ y ) ⟩;
  have h_continuous : ContinuousOn (fun K : α → β → ℝ => shannonEntropy' α μ.prob + shannonEntropy' β (fun y => ∑ x, μ.prob x * K x y) - shannonEntropy' (α × β) (fun p => μ.prob p.1 * K p.1 p.2)) {K : α → β → ℝ | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ ∑ x, ∑ y, μ.prob x * K x y * d x y ≤ D} := by
    refine' ContinuousOn.sub _ _;
    · refine' ContinuousOn.add continuousOn_const _;
      refine' ContinuousOn.neg ( continuousOn_finset_sum _ fun y _ => ContinuousOn.comp ( show ContinuousOn ( fun x => negEntSummand x ) ( Set.Icc 0 1 ) from _ ) _ _ );
      · refine' Continuous.continuousOn _;
        have h_cont : Continuous (fun x : ℝ => x * Real.log x) := by
          exact Real.continuous_mul_log;
        exact h_cont.congr fun x => by unfold negEntSummand; aesop;
      · fun_prop;
      · intro K hK;
        refine' ⟨ Finset.sum_nonneg fun x _ => mul_nonneg ( μ.prob_nonneg x ) ( hK.1 x y ), _ ⟩;
        refine' le_trans ( Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left ( show K x y ≤ 1 from _ ) ( μ.prob_nonneg x ) ) _;
        · exact hK.2.1 x ▸ Finset.single_le_sum ( fun y _ => hK.1 x y ) ( Finset.mem_univ y );
        · simp +decide [ μ.prob_sum ];
    · refine' Continuous.continuousOn _;
      refine' continuous_neg.comp ( continuous_finset_sum _ fun p _ => _ );
      refine' Continuous.if _ _ _;
      · simp +decide [ frontier_eq_closure_inter_closure ];
        intro a ha₁ ha₂; contrapose! ha₂; simp_all +decide [ mem_closure_iff_seq_limit, mem_interior_iff_mem_nhds, Metric.mem_nhds_iff ] ;
        exact absurd ( tendsto_pi_nhds.mp ha₁.choose_spec.2 p.1 |> tendsto_pi_nhds.mp <| p.2 ) ( by simp +decide [ ha₁.choose_spec.1 ] ; aesop );
      · exact continuous_const;
      · fun_prop;
  obtain ⟨K, hK⟩ : ∃ K ∈ {K : α → β → ℝ | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ ∑ x, ∑ y, μ.prob x * K x y * d x y ≤ D}, ∀ K' ∈ {K : α → β → ℝ | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ ∑ x, ∑ y, μ.prob x * K x y * d x y ≤ D}, (shannonEntropy' α μ.prob + shannonEntropy' β (fun y => ∑ x, μ.prob x * K x y) - shannonEntropy' (α × β) (fun p => μ.prob p.1 * K p.1 p.2)) ≤ (shannonEntropy' α μ.prob + shannonEntropy' β (fun y => ∑ x, μ.prob x * K' x y) - shannonEntropy' (α × β) (fun p => μ.prob p.1 * K' p.1 p.2)) := by
    have h_nonempty : {K : α → β → ℝ | (∀ x y, 0 ≤ K x y) ∧ (∀ x, ∑ y, K x y = 1) ∧ ∑ x, ∑ y, μ.prob x * K x y * d x y ≤ D}.Nonempty := by
      obtain ⟨ K, hK ⟩ := hD;
      exact ⟨ K.cond, K.cond_nonneg, K.cond_sum, by simpa only [ expectedDistortion, jointMass ] using hK ⟩;
    exact h_compact.exists_isMinOn h_nonempty h_continuous;
  use ⟨K, hK.left.left, hK.left.right.left⟩;
  constructor;
  · convert hK.1.2.2 using 1;
  · intro K' hK';
    convert hK.2 ( fun x y => K'.cond x y ) ⟨ fun x y => K'.cond_nonneg x y, fun x => K'.cond_sum x, ?_ ⟩ using 1;
    convert hK' using 1

/-- R(D) is nonincreasing on the feasible set. -/
theorem rateDistortion_antitoneOn (μ : FinProb α) (d : α → β → ℝ) :
    AntitoneOn (rateDistortion μ d) (feasibleDistortionSet μ d) := by
  intro D₁ hD₁ D₂ _ h
  exact rateDistortion_antitone_feasible μ d h hD₁

end FiniteRateDistortion