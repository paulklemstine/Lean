/-
Copyright (c) 2025. All rights reserved.

# The Neurosymbolic RLHF Objective: a Variational / Torsor-Theoretic Analysis

## Overview

This file gives a complete, `sorry`-free formal analysis of the KL-regularised
reinforcement-learning objective used by RLHF (InstructGPT / PPO-ptx style):

  `Objective(p) = 𝔼_p[RM] - β * KL(p ‖ p_SFT) + γ * 𝔼_{x∼D_pre}[log p x]`

over a finite response space `ι`.

The mathematical content is organised as a strict hierarchy:

* **Level 0 (information theory).**  Gibbs' inequality for the finite
  Kullback–Leibler divergence, together with its *equality case*.
* **Level 1 (exact decomposition).**  The *three-point identity*
  `Objective β r ref p = freeEnergy β ref r - β * KL(p ‖ gibbs β ref r)`.
  Every optimality statement below is a corollary of this single identity.
* **Level 2 (variational principle).**  The Donsker–Varadhan / Gibbs
  variational principle: the KL-regularised optimum is the exponentially tilted
  ("softmax") policy, the optimal value is the free energy `β log Z`, and the
  maximiser is *unique*.
* **Level 3 (quantitative alignment corollaries).**  Sandwich
  `𝔼_ref[r] ≤ β log Z ≤ max r`, monotonicity of the optimal value in the
  KL-coefficient β, the drift bound `KL(π* ‖ ref) ≤ (max r - min r)/β`, and the
  fact that tilting never decreases expected reward.
* **Level 4 (algebra ⋈ information geometry).**  Exponential tilting is an
  *additive group action* of the reward space `(ι → ℝ, +)` on the open simplex,
  it is transitive, and its stabiliser is exactly the constant rewards.  Hence
  the open simplex is a torsor under `(ι → ℝ)/ℝ·1`, and *sequential RLHF with
  rewards `r₁` then `r₂` equals single-stage RLHF with reward `r₁ + r₂`*.
* **Level 5 (PTX).**  The pre-training mix-in term is bounded by the negative
  entropy of the pre-training distribution, and the two upper bounds (reward+KL
  and PTX) are *simultaneously attainable if and only if* the pre-training
  distribution coincides with the tilted policy — an exact obstruction theorem
  for the reward/PTX tension.

All results are proved from scratch; no `sorry`, no `native_decide`.
-/
import Mathlib

open Finset Real BigOperators

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι]

/-! ## Basic definitions -/

/-- A finite probability vector: nonnegative and summing to one. -/
structure IsProb (p : ι → ℝ) : Prop where
  nonneg : ∀ i, 0 ≤ p i
  sum_one : ∑ i, p i = 1

/-- A strictly positive finite probability vector (full support). -/
structure IsPosProb (p : ι → ℝ) : Prop where
  pos : ∀ i, 0 < p i
  sum_one : ∑ i, p i = 1

theorem IsPosProb.isProb {p : ι → ℝ} (hp : IsPosProb p) : IsProb p :=
  ⟨fun i => (hp.pos i).le, hp.sum_one⟩

/-- Finite Kullback–Leibler divergence, with the usual `0 log 0 = 0` convention
(automatic in Lean since `Real.log 0 = 0`). -/
def klDivFin (p q : ι → ℝ) : ℝ := ∑ i, p i * Real.log (p i / q i)

/-- Partition function of the exponentially tilted (softmax) policy. -/
def tiltZ (β : ℝ) (ref r : ι → ℝ) : ℝ := ∑ i, ref i * Real.exp (r i / β)

/-- The exponentially tilted policy `ref(i) exp(r i / β) / Z`, i.e. the
"softmax over the reward" policy. -/
def gibbs (β : ℝ) (ref r : ι → ℝ) : ι → ℝ :=
  fun i => ref i * Real.exp (r i / β) / tiltZ β ref r

/-- The free energy `β log Z`, the optimal value of the RLHF objective. -/
def freeEnergy (β : ℝ) (ref r : ι → ℝ) : ℝ := β * Real.log (tiltZ β ref r)

/-- The RLHF objective: expected reward minus `β` times the KL penalty against
the SFT reference policy. -/
def rlhfObj (β : ℝ) (ref r p : ι → ℝ) : ℝ :=
  (∑ i, p i * r i) - β * klDivFin p ref

/-- The PTX (pre-training mix-in) term: `γ * 𝔼_{x ∼ pre}[log p x]`. -/
def ptxTerm (γ : ℝ) (pre p : ι → ℝ) : ℝ := γ * ∑ i, pre i * Real.log (p i)

/-- The full PPO-ptx objective of InstructGPT, rebranded neurosymbolically. -/
def rlhfPtxObj (β γ : ℝ) (ref r pre p : ι → ℝ) : ℝ :=
  rlhfObj β ref r p + ptxTerm γ pre p

/-! ## Level 0: Gibbs' inequality and its equality case -/

/-- Pointwise convexity estimate `a - b ≤ a log (a/b)` for `a ≥ 0 < b`. -/
theorem term_le (a b : ℝ) (ha : 0 ≤ a) (hb : 0 < b) : a - b ≤ a * Real.log (a / b) := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h, hb.le]
  · have ht : 0 < b / a := div_pos hb h
    have := Real.log_le_sub_one_of_pos ht
    have hlog : Real.log (b / a) = -Real.log (a / b) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hlog] at this
    have : a * (-Real.log (a / b)) ≤ a * (b / a - 1) := by
      exact mul_le_mul_of_nonneg_left this ha
    have hfield : a * (b / a - 1) = b - a := by field_simp
    nlinarith [this]

/-- Strict version of `term_le` when `a ≠ b`. -/
theorem term_lt (a b : ℝ) (ha : 0 ≤ a) (hb : 0 < b) (hab : a ≠ b) :
    a - b < a * Real.log (a / b) := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [← h, hb]
  · have ht : 0 < b / a := div_pos hb h
    have hne : b / a ≠ 1 := by
      intro hcon
      apply hab
      field_simp at hcon
      linarith
    have := Real.log_lt_sub_one_of_pos ht hne
    have hlog : Real.log (b / a) = -Real.log (a / b) := by
      rw [← Real.log_inv]; congr 1; field_simp
    rw [hlog] at this
    have h2 : a * (-Real.log (a / b)) < a * (b / a - 1) :=
      mul_lt_mul_of_pos_left this h
    have hfield : a * (b / a - 1) = b - a := by field_simp
    nlinarith [h2]

/-- **Gibbs' inequality**: the KL divergence between a probability vector and a
positive probability vector is nonnegative. -/
theorem klDivFin_nonneg {p q : ι → ℝ} (hp : IsProb p) (hq : IsPosProb q) :
    0 ≤ klDivFin p q := by
  have key : ∑ i, (p i - q i) ≤ ∑ i, p i * Real.log (p i / q i) :=
    Finset.sum_le_sum (fun i _ => term_le (p i) (q i) (hp.nonneg i) (hq.pos i))
  have hz : ∑ i : ι, (p i - q i) = 0 := by
    rw [Finset.sum_sub_distrib, hp.sum_one, hq.sum_one, sub_self]
  rw [hz] at key
  exact key

/-- **Equality case of Gibbs' inequality**: `KL(p ‖ q) = 0` forces `p = q`. -/
theorem klDivFin_eq_zero_iff {p q : ι → ℝ} (hp : IsProb p) (hq : IsPosProb q) :
    klDivFin p q = 0 ↔ p = q := by
  constructor
  · intro h
    by_contra hne
    obtain ⟨j, hj⟩ : ∃ j, p j ≠ q j := by
      by_contra hall
      exact hne (funext fun i => not_not.1 (fun h' => hall ⟨i, h'⟩))
    have hlt : ∑ i, (p i - q i) < ∑ i, p i * Real.log (p i / q i) := by
      refine Finset.sum_lt_sum (fun i _ => term_le (p i) (q i) (hp.nonneg i) (hq.pos i))
        ⟨j, Finset.mem_univ j, term_lt (p j) (q j) (hp.nonneg j) (hq.pos j) hj⟩
    have hz : ∑ i : ι, (p i - q i) = 0 := by
      rw [Finset.sum_sub_distrib, hp.sum_one, hq.sum_one, sub_self]
    rw [hz, ← klDivFin] at hlt
    linarith
  · rintro rfl
    unfold klDivFin
    have : ∀ i : ι, p i * Real.log (p i / p i) = 0 := by
      intro i
      rw [div_self (hq.pos i).ne']
      simp
    exact Finset.sum_eq_zero fun i _ => this i

/-! ## Basic facts about the tilted policy -/

theorem tiltZ_pos {β : ℝ} {ref r : ι → ℝ} (href : IsPosProb ref) [Nonempty ι] :
    0 < tiltZ β ref r := by
  unfold tiltZ
  apply Finset.sum_pos
  · intro i _
    exact mul_pos (href.pos i) (Real.exp_pos _)
  · exact Finset.univ_nonempty

theorem gibbs_pos {β : ℝ} {ref r : ι → ℝ} (href : IsPosProb ref) [Nonempty ι] (i : ι) :
    0 < gibbs β ref r i :=
  div_pos (mul_pos (href.pos i) (Real.exp_pos _)) (tiltZ_pos href)

theorem gibbs_sum_one {β : ℝ} {ref r : ι → ℝ} (href : IsPosProb ref) [Nonempty ι] :
    ∑ i, gibbs β ref r i = 1 := by
  unfold gibbs
  rw [← Finset.sum_div]
  exact div_self (tiltZ_pos (β := β) (r := r) href).ne'

/-- The tilted policy is a positive probability vector. -/
theorem gibbs_isPosProb {β : ℝ} {ref r : ι → ℝ} (href : IsPosProb ref) [Nonempty ι] :
    IsPosProb (gibbs β ref r) :=
  ⟨fun i => gibbs_pos href i, gibbs_sum_one href⟩

/-! ## Level 1: the exact three-point decomposition -/

/-- Pointwise change of reference measure: the KL divergence to the tilted
policy in terms of the KL divergence to the reference policy. -/
theorem klDivFin_gibbs_eq {β : ℝ} {ref r p : ι → ℝ}
    [Nonempty ι] (href : IsPosProb ref) (hp : IsProb p) :
    klDivFin p (gibbs β ref r)
      = klDivFin p ref - (∑ i, p i * r i) / β + Real.log (tiltZ β ref r) := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hterm : ∀ i : ι,
      p i * Real.log (p i / gibbs β ref r i)
        = p i * Real.log (p i / ref i) - p i * (r i / β) + p i * Real.log (tiltZ β ref r) := by
    intro i
    rcases eq_or_lt_of_le (hp.nonneg i) with h | h
    · simp [← h]
    · have hgpos : 0 < gibbs β ref r i := gibbs_pos href i
      have hg : gibbs β ref r i = ref i * Real.exp (r i / β) / tiltZ β ref r := rfl
      have hnum : (0:ℝ) < ref i * Real.exp (r i / β) :=
        mul_pos (href.pos i) (Real.exp_pos _)
      have h1 : Real.log (p i / gibbs β ref r i)
          = Real.log (p i) - Real.log (ref i) - r i / β + Real.log (tiltZ β ref r) := by
        rw [hg, Real.log_div h.ne' (by positivity),
          Real.log_div hnum.ne' hZ.ne', Real.log_mul (href.pos i).ne'
            (Real.exp_ne_zero _), Real.log_exp]
        ring
      rw [h1, Real.log_div h.ne' (href.pos i).ne']
      ring
  have hr : ∑ i, p i * (r i / β) = (∑ i, p i * r i) / β := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl (fun i _ => by ring)
  calc klDivFin p (gibbs β ref r)
      = ∑ i, (p i * Real.log (p i / ref i) - p i * (r i / β)
          + p i * Real.log (tiltZ β ref r)) :=
        Finset.sum_congr rfl (fun i _ => hterm i)
    _ = klDivFin p ref - (∑ i, p i * r i) / β + Real.log (tiltZ β ref r) := by
        rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, hr,
          hp.sum_one, one_mul]
        rfl

/-- **Three-point identity.**  The RLHF objective differs from its optimal value
`freeEnergy = β log Z` by exactly `β` times the KL divergence to the tilted
policy.  Everything else in this file is a corollary. -/
theorem rlhfObj_eq_freeEnergy_sub {β : ℝ} (hβ : 0 < β) {ref r p : ι → ℝ}
    [Nonempty ι] (href : IsPosProb ref) (hp : IsProb p) :
    rlhfObj β ref r p = freeEnergy β ref r - β * klDivFin p (gibbs β ref r) := by
  rw [klDivFin_gibbs_eq href hp]
  unfold rlhfObj freeEnergy
  field_simp
  ring

/-! ## Level 2: the variational principle -/

/-- The tilted policy attains the free energy. -/
theorem rlhfObj_gibbs {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) :
    rlhfObj β ref r (gibbs β ref r) = freeEnergy β ref r := by
  rw [rlhfObj_eq_freeEnergy_sub hβ href (gibbs_isPosProb href).isProb,
    (klDivFin_eq_zero_iff (gibbs_isPosProb href).isProb (gibbs_isPosProb href)).2 rfl]
  ring

/-- **Gibbs / Donsker–Varadhan variational principle**: the KL-regularised
reward objective is bounded above by the free energy. -/
theorem rlhfObj_le_freeEnergy {β : ℝ} (hβ : 0 < β) {ref r p : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hp : IsProb p) :
    rlhfObj β ref r p ≤ freeEnergy β ref r := by
  rw [rlhfObj_eq_freeEnergy_sub hβ href hp]
  have := klDivFin_nonneg hp (gibbs_isPosProb (β := β) (r := r) href)
  nlinarith

/-- **Uniqueness of the RLHF optimum**: a policy attains the optimal value if
and only if it is the exponentially tilted (softmax) policy. -/
theorem rlhfObj_eq_freeEnergy_iff {β : ℝ} (hβ : 0 < β) {ref r p : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hp : IsProb p) :
    rlhfObj β ref r p = freeEnergy β ref r ↔ p = gibbs β ref r := by
  rw [rlhfObj_eq_freeEnergy_sub hβ href hp]
  constructor
  · intro h
    have hkl : klDivFin p (gibbs β ref r) = 0 := by
      have : β * klDivFin p (gibbs β ref r) = 0 := by linarith
      rcases mul_eq_zero.1 this with h' | h'
      · exact absurd h' hβ.ne'
      · exact h'
    exact (klDivFin_eq_zero_iff hp (gibbs_isPosProb href)).1 hkl
  · rintro rfl
    rw [(klDivFin_eq_zero_iff (gibbs_isPosProb href).isProb (gibbs_isPosProb href)).2 rfl]
    ring

/-! ## Level 3: quantitative alignment corollaries -/

theorem klDivFin_self {p : ι → ℝ} (hp : IsPosProb p) : klDivFin p p = 0 :=
  (klDivFin_eq_zero_iff hp.isProb hp).2 rfl

/-- Expectations of a bounded reward under a probability vector are bounded. -/
theorem expectation_le {p r : ι → ℝ} {M : ℝ} (hp : IsProb p) (hM : ∀ i, r i ≤ M) :
    ∑ i, p i * r i ≤ M := by
  calc ∑ i, p i * r i ≤ ∑ i, p i * M :=
        Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hM i) (hp.nonneg i)
    _ = M := by rw [← Finset.sum_mul, hp.sum_one, one_mul]

theorem le_expectation {p r : ι → ℝ} {m : ℝ} (hp : IsProb p) (hm : ∀ i, m ≤ r i) :
    m ≤ ∑ i, p i * r i := by
  calc m = ∑ i, p i * m := by rw [← Finset.sum_mul, hp.sum_one, one_mul]
    _ ≤ ∑ i, p i * r i :=
        Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hm i) (hp.nonneg i)

/-- The free energy dominates the reward already achieved by the SFT reference
policy: KL-regularised RL never lowers the objective value. -/
theorem expected_ref_le_freeEnergy {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) : ∑ i, ref i * r i ≤ freeEnergy β ref r := by
  have h := rlhfObj_le_freeEnergy (β := β) (r := r) hβ href href.isProb
  unfold rlhfObj at h
  rw [klDivFin_self href] at h
  linarith

/-- The free energy is bounded by the maximal reward: no amount of tilting can
exceed the best achievable reward. -/
theorem freeEnergy_le_of_le {β M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hM : ∀ i, r i ≤ M) : freeEnergy β ref r ≤ M := by
  have hg : IsPosProb (gibbs β ref r) := gibbs_isPosProb href
  have h := rlhfObj_gibbs (β := β) (r := r) hβ href
  have hsum : ∑ i, gibbs β ref r i * r i ≤ M := expectation_le hg.isProb hM
  have hkl : 0 ≤ klDivFin (gibbs β ref r) ref := klDivFin_nonneg hg.isProb href
  unfold rlhfObj at h
  nlinarith

/-- **Sandwich**: the optimal RLHF value lies between the reference reward and
the maximal reward. -/
theorem freeEnergy_mem_Icc {β m M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) (hM : ∀ i, r i ≤ M) :
    m ≤ freeEnergy β ref r ∧ freeEnergy β ref r ≤ M :=
  ⟨le_trans (le_expectation href.isProb hm) (expected_ref_le_freeEnergy hβ href),
    freeEnergy_le_of_le hβ href hM⟩

/-- **Monotonicity in the KL coefficient**: a stronger KL penalty can only
lower the optimal value of the RLHF objective. -/
theorem freeEnergy_antitone_beta {β₁ β₂ : ℝ} (h1 : 0 < β₁) (h12 : β₁ ≤ β₂) {ref r : ι → ℝ}
    [Nonempty ι] (href : IsPosProb ref) :
    freeEnergy β₂ ref r ≤ freeEnergy β₁ ref r := by
  have hβ₂ : 0 < β₂ := lt_of_lt_of_le h1 h12
  have hq : IsPosProb (gibbs β₂ ref r) := gibbs_isPosProb href
  have h2 := rlhfObj_gibbs (β := β₂) (r := r) hβ₂ href
  have h1' := rlhfObj_le_freeEnergy (β := β₁) (r := r) (p := gibbs β₂ ref r) h1 href hq.isProb
  have hkl : 0 ≤ klDivFin (gibbs β₂ ref r) ref := klDivFin_nonneg hq.isProb href
  unfold rlhfObj at h2 h1'
  nlinarith

/-- **Drift bound**: the optimal policy stays within KL radius
`(max r - min r)/β` of the SFT reference. -/
theorem gibbs_kl_drift_le {β m M : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hm : ∀ i, m ≤ r i) (hM : ∀ i, r i ≤ M) :
    β * klDivFin (gibbs β ref r) ref ≤ M - m := by
  have hg : IsPosProb (gibbs β ref r) := gibbs_isPosProb href
  have h := rlhfObj_gibbs (β := β) (r := r) hβ href
  have hsum : ∑ i, gibbs β ref r i * r i ≤ M := expectation_le hg.isProb hM
  have hlow : m ≤ freeEnergy β ref r := (freeEnergy_mem_Icc hβ href hm hM).1
  unfold rlhfObj at h
  linarith

/-- **Reward improvement**: exponential tilting never decreases the expected
reward relative to the SFT reference policy. -/
theorem gibbs_expected_reward_ge {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) :
    ∑ i, ref i * r i ≤ ∑ i, gibbs β ref r i * r i := by
  have hg : IsPosProb (gibbs β ref r) := gibbs_isPosProb href
  have h := rlhfObj_gibbs (β := β) (r := r) hβ href
  have hkl : 0 ≤ klDivFin (gibbs β ref r) ref := klDivFin_nonneg hg.isProb href
  have hlow := expected_ref_le_freeEnergy (β := β) (r := r) hβ href
  unfold rlhfObj at h
  nlinarith

/-! ## Level 4: tilting as a group action (algebra meets information geometry) -/

/-- The zero reward acts trivially. -/
theorem gibbs_zero {β : ℝ} {ref : ι → ℝ} [Nonempty ι] (href : IsPosProb ref) :
    gibbs β ref (fun _ => 0) = ref := by
  have hZ : tiltZ β ref (fun _ => 0) = 1 := by
    unfold tiltZ
    simpa using href.sum_one
  funext i
  unfold gibbs
  rw [hZ]
  simp

/-- Auxiliary: the partition function of a two-stage tilt. -/
theorem tiltZ_gibbs {β : ℝ} {ref r s : ι → ℝ} [Nonempty ι] (href : IsPosProb ref) :
    tiltZ β (gibbs β ref r) s = tiltZ β ref (fun i => r i + s i) / tiltZ β ref r := by
  have hZ1 : 0 < tiltZ β ref r := tiltZ_pos href
  have hmul : tiltZ β (gibbs β ref r) s * tiltZ β ref r
      = tiltZ β ref (fun i => r i + s i) := by
    have hZ1' : (∑ j, ref j * Real.exp (r j / β)) ≠ 0 := hZ1.ne'
    unfold tiltZ gibbs
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hexp : Real.exp ((r i + s i) / β) = Real.exp (r i / β) * Real.exp (s i / β) := by
      rw [← Real.exp_add, add_div]
    rw [hexp]
    simp only [tiltZ]
    field_simp
  rw [eq_div_iff hZ1.ne']
  exact hmul

/-- **Additivity of tilting**: tilting by `r` and then by `s` is tilting by
`r + s`.  Exponential tilting is an action of the additive group of rewards on
the open simplex. -/
theorem gibbs_add {β : ℝ} {ref r s : ι → ℝ} [Nonempty ι] (href : IsPosProb ref) :
    gibbs β (gibbs β ref r) s = gibbs β ref (fun i => r i + s i) := by
  have hZ1 : 0 < tiltZ β ref r := tiltZ_pos href
  have hZ2 : 0 < tiltZ β ref (fun i => r i + s i) := tiltZ_pos href
  funext i
  have hexp : Real.exp ((r i + s i) / β) = Real.exp (r i / β) * Real.exp (s i / β) := by
    rw [← Real.exp_add, add_div]
  have hlhs : gibbs β (gibbs β ref r) s i
      = (ref i * Real.exp (r i / β) / tiltZ β ref r) * Real.exp (s i / β)
        / tiltZ β (gibbs β ref r) s := rfl
  rw [hlhs, tiltZ_gibbs href]
  show _ = ref i * Real.exp ((r i + s i) / β) / tiltZ β ref (fun i => r i + s i)
  rw [hexp]
  field_simp

/-- Adding a constant to the reward does not change the optimal policy: only
reward *differences* matter. -/
theorem gibbs_add_const {β : ℝ} {ref r : ι → ℝ} (c : ℝ) [Nonempty ι]
    (href : IsPosProb ref) :
    gibbs β ref (fun i => r i + c) = gibbs β ref r := by
  have hZ1 : 0 < tiltZ β ref r := tiltZ_pos href
  have hZc : tiltZ β ref (fun i => r i + c) = Real.exp (c / β) * tiltZ β ref r := by
    unfold tiltZ
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [add_div, Real.exp_add]
    ring
  funext i
  show ref i * Real.exp ((r i + c) / β) / tiltZ β ref (fun i => r i + c) = _
  rw [hZc, add_div, Real.exp_add]
  have hc : Real.exp (c / β) ≠ 0 := Real.exp_ne_zero _
  unfold gibbs
  field_simp

/-- **Transitivity**: any positive policy `q` is reachable from any positive
policy `p` by tilting with the log-ratio reward.  Together with `gibbs_add` and
`gibbs_zero`, the open simplex is a torsor for the reward group modulo
constants. -/
theorem gibbs_transitive {β : ℝ} (hβ : 0 < β) {p q : ι → ℝ} [Nonempty ι]
    (hp : IsPosProb p) (hq : IsPosProb q) :
    gibbs β p (fun i => β * Real.log (q i / p i)) = q := by
  have hterm : ∀ i : ι, p i * Real.exp (β * Real.log (q i / p i) / β) = q i := by
    intro i
    have hb : β * Real.log (q i / p i) / β = Real.log (q i / p i) := by
      field_simp
    rw [hb, Real.exp_log (div_pos (hq.pos i) (hp.pos i)), mul_comm,
      div_mul_eq_mul_div, mul_div_assoc, div_self (hp.pos i).ne', mul_one]
  have hZ : tiltZ β p (fun i => β * Real.log (q i / p i)) = 1 := by
    unfold tiltZ
    rw [Finset.sum_congr rfl fun i _ => hterm i]
    exact hq.sum_one
  funext i
  show p i * Real.exp (β * Real.log (q i / p i) / β)
      / tiltZ β p (fun i => β * Real.log (q i / p i)) = q i
  rw [hZ, hterm i, div_one]

/-- **Stabiliser of the action**: two rewards induce the same optimal policy if
and only if they differ by a constant. -/
theorem gibbs_eq_gibbs_iff {β : ℝ} (hβ : 0 < β) {ref r s : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) :
    gibbs β ref r = gibbs β ref s ↔ ∃ c : ℝ, ∀ i, r i = s i + c := by
  have hZr : 0 < tiltZ β ref r := tiltZ_pos href
  have hZs : 0 < tiltZ β ref s := tiltZ_pos href
  constructor
  · intro h
    refine ⟨β * Real.log (tiltZ β ref r / tiltZ β ref s), fun i => ?_⟩
    have hi : ref i * Real.exp (r i / β) / tiltZ β ref r
        = ref i * Real.exp (s i / β) / tiltZ β ref s := congrFun h i
    have hrefi := href.pos i
    have he1 := Real.exp_pos (r i / β)
    have he2 := Real.exp_pos (s i / β)
    have hi2 : Real.exp (r i / β) * tiltZ β ref s
        = Real.exp (s i / β) * tiltZ β ref r := by
      field_simp at hi
      nlinarith [hi]
    have hdiv : Real.exp (r i / β - s i / β) = tiltZ β ref r / tiltZ β ref s := by
      rw [Real.exp_sub, div_eq_div_iff (by positivity) hZs.ne']
      nlinarith [hi2]
    have hlog : r i / β - s i / β = Real.log (tiltZ β ref r / tiltZ β ref s) := by
      rw [← hdiv, Real.log_exp]
    have hβ' : β ≠ 0 := hβ.ne'
    field_simp at hlog
    field_simp
    linarith [hlog]
  · rintro ⟨c, hc⟩
    have hrs : r = fun i => s i + c := funext hc
    rw [hrs, gibbs_add_const c href]

/-- **Sequential RLHF composes**: running a second RLHF stage with reward `s`
against the first-stage optimum is the same as a single stage with reward
`r + s`. -/
theorem rlhf_sequential {β : ℝ} (hβ : 0 < β) {ref r s p : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hp : IsProb p) :
    rlhfObj β (gibbs β ref r) s p = freeEnergy β (gibbs β ref r) s
      ↔ p = gibbs β ref (fun i => r i + s i) := by
  rw [rlhfObj_eq_freeEnergy_iff hβ (gibbs_isPosProb href) hp, gibbs_add href]

/-! ## Level 5: the pre-training mix-in (PTX) and the alignment tension -/

/-- Expansion of the KL divergence between two positive policies. -/
theorem klDivFin_of_pos {p q : ι → ℝ} (hp : IsPosProb p) (hq : IsPosProb q) :
    klDivFin p q = (∑ i, p i * Real.log (p i)) - ∑ i, p i * Real.log (q i) := by
  unfold klDivFin
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [Real.log_div (hp.pos i).ne' (hq.pos i).ne']
  ring

/-- The PTX term is maximised exactly at the pre-training distribution. -/
theorem ptxTerm_le {γ : ℝ} (hγ : 0 ≤ γ) {pre p : ι → ℝ} (hpre : IsPosProb pre)
    (hp : IsPosProb p) : ptxTerm γ pre p ≤ ptxTerm γ pre pre := by
  have hkl : 0 ≤ klDivFin pre p := klDivFin_nonneg hpre.isProb hp
  rw [klDivFin_of_pos hpre hp] at hkl
  unfold ptxTerm
  nlinarith

/-- **Master identity for the full PPO-ptx objective**: it decomposes into the
sum of its two attainable maxima minus two independent KL defects. -/
theorem rlhfPtxObj_eq {β γ : ℝ} (hβ : 0 < β) {ref r pre p : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hpre : IsPosProb pre) (hp : IsPosProb p) :
    rlhfPtxObj β γ ref r pre p
      = (freeEnergy β ref r + ptxTerm γ pre pre)
        - β * klDivFin p (gibbs β ref r) - γ * klDivFin pre p := by
  unfold rlhfPtxObj ptxTerm
  rw [rlhfObj_eq_freeEnergy_sub hβ href hp.isProb, klDivFin_of_pos hpre hp]
  ring

/-- **Upper bound for the full objective.** -/
theorem rlhfPtxObj_le {β γ : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) {ref r pre p : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (hpre : IsPosProb pre) (hp : IsPosProb p) :
    rlhfPtxObj β γ ref r pre p ≤ freeEnergy β ref r + ptxTerm γ pre pre := by
  have h1 : 0 ≤ klDivFin p (gibbs β ref r) :=
    klDivFin_nonneg hp.isProb (gibbs_isPosProb href)
  have h2 : 0 ≤ klDivFin pre p := klDivFin_nonneg hpre.isProb hp
  rw [rlhfPtxObj_eq hβ href hpre hp]
  nlinarith

/-- **Exact equality case**: the joint bound is attained by `p` iff `p` is
simultaneously the tilted policy and the pre-training distribution. -/
theorem rlhfPtxObj_eq_bound_iff {β γ : ℝ} (hβ : 0 < β) (hγ : 0 < γ) {ref r pre p : ι → ℝ}
    [Nonempty ι] (href : IsPosProb ref) (hpre : IsPosProb pre) (hp : IsPosProb p) :
    rlhfPtxObj β γ ref r pre p = freeEnergy β ref r + ptxTerm γ pre pre
      ↔ p = gibbs β ref r ∧ pre = p := by
  have h1 : 0 ≤ klDivFin p (gibbs β ref r) :=
    klDivFin_nonneg hp.isProb (gibbs_isPosProb href)
  have h2 : 0 ≤ klDivFin pre p := klDivFin_nonneg hpre.isProb hp
  rw [rlhfPtxObj_eq hβ href hpre hp]
  constructor
  · intro h
    have hz1 : klDivFin p (gibbs β ref r) = 0 := by nlinarith
    have hz2 : klDivFin pre p = 0 := by nlinarith
    exact ⟨(klDivFin_eq_zero_iff hp.isProb (gibbs_isPosProb href)).1 hz1,
      (klDivFin_eq_zero_iff hpre.isProb hp).1 hz2⟩
  · rintro ⟨rfl, rfl⟩
    rw [klDivFin_self hp]
    ring

/-- **Alignment tension theorem**: the reward/KL bound and the PTX bound are
simultaneously attainable if and only if the pre-training distribution already
*is* the KL-regularised optimal policy. -/
theorem rlhfPtx_bound_attainable_iff {β γ : ℝ} (hβ : 0 < β) (hγ : 0 < γ) {ref r pre : ι → ℝ}
    [Nonempty ι] (href : IsPosProb ref) (hpre : IsPosProb pre) :
    (∃ p : ι → ℝ, IsPosProb p ∧
        rlhfPtxObj β γ ref r pre p = freeEnergy β ref r + ptxTerm γ pre pre)
      ↔ pre = gibbs β ref r := by
  constructor
  · rintro ⟨p, hp, h⟩
    obtain ⟨h1, h2⟩ := (rlhfPtxObj_eq_bound_iff hβ hγ href hpre hp).1 h
    rw [h2, h1]
  · intro h
    exact ⟨pre, hpre, (rlhfPtxObj_eq_bound_iff hβ hγ href hpre hpre).2 ⟨h, rfl⟩⟩

/-- Strict form of the tension theorem: if the pre-training distribution is not
the tilted optimum, then *every* policy falls strictly short of the sum of the
two individual maxima. -/
theorem rlhfPtxObj_lt_bound {β γ : ℝ} (hβ : 0 < β) (hγ : 0 < γ) {ref r pre p : ι → ℝ}
    [Nonempty ι] (href : IsPosProb ref) (hpre : IsPosProb pre) (hp : IsPosProb p)
    (hne : pre ≠ gibbs β ref r) :
    rlhfPtxObj β γ ref r pre p < freeEnergy β ref r + ptxTerm γ pre pre := by
  rcases lt_or_eq_of_le (rlhfPtxObj_le hβ hγ.le href hpre hp) with h | h
  · exact h
  · exact absurd ((rlhfPtx_bound_attainable_iff hβ hγ href hpre).1 ⟨p, hp, h⟩) hne

end NeuroSymbolicRLHF