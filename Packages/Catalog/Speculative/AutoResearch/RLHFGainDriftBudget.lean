import Novelty.RLHFQuadraticDrift

/-!
# The gain–drift budget of RLHF, with and without the PTX mix-in

Domain: Novelty (convex duality × information geometry × alignment theory).

Two complementary questions about the InstructGPT objective
```
J(q) = 𝔼_q[r] − β KL(q ‖ p) + γ 𝔼_d[log q]
```
are settled here quantitatively.

**1. Gain costs drift, and drift caps gain.**  For the KL-regularized optimum `π_β`:

* `RLHF.gain_ge_beta_kl` — the reward gain `𝔼_{π_β}[r] − 𝔼_p[r]` is at least
  `β · KL(π_β ‖ p)`: *every* unit of reward improvement must be paid for in
  divergence from the SFT reference;
* `RLHF.gain_ge_half_beta_l1_sq` — combined with Pinsker, gain `≥ (β/2)‖π_β − p‖₁²`;
* `RLHF.gain_le_range_mul_l1` — conversely gain `≤ (range r/2)·‖π_β − p‖₁`, so a
  policy that does not move cannot improve;
* `RLHF.gain_le_range_sq_div` — hence the achievable gain itself decays like
  `range(r)²/β`.

**2. A drift budget for the PTX-augmented objective.**  If a policy `q` is at least
as good as the reference under the *full* PTX objective, then

* `RLHF.ptx_budget` — `β KL(q ‖ p) + γ KL(d ‖ q) ≤ range(r) + γ KL(d ‖ p)`.

This single inequality contains both halves of the alignment tax: the RL term can
buy at most `range(r)/β` of divergence from the SFT model, and the pretraining
mix-in can be pushed away from `d` by at most `range(r)/γ`.  Corollaries
`RLHF.ptx_kl_le` and `RLHF.ptx_l1_le` give the explicit drift bounds.

All statements are `sorry`-free.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Reward gain versus drift for the KL-regularized optimum -/

/-- **Gain costs divergence.**  The reward improvement of the aligned policy over the
reference is at least `β` times the KL divergence it spends. -/
theorem gain_ge_beta_kl {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    β * klDiv (gibbsPolicy β r p) p
      ≤ (∑ y, gibbsPolicy β r p y * r y) - ∑ y, p y * r y := by
  have hopt : objective β r p (gibbsPolicy β r p) = β * Real.log (partition β r p) :=
    objective_gibbs hβ hp
  have href : ∑ y, p y * r y ≤ β * Real.log (partition β r p) :=
    reference_le_free_energy hβ hp
  have hobj : objective β r p (gibbsPolicy β r p)
      = (∑ y, gibbsPolicy β r p y * r y) - β * klDiv (gibbsPolicy β r p) p := rfl
  linarith [hobj ▸ hopt]

/-- **Quadratic price of alignment.**  The reward gain dominates `(β/2)‖π_β − p‖₁²`. -/
theorem gain_ge_half_beta_l1_sq {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    β / 2 * (l1Dist (gibbsPolicy β r p) p) ^ 2
      ≤ (∑ y, gibbsPolicy β r p y * r y) - ∑ y, p y * r y := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hpin := pinsker hg.isDist hp
  have hkl := gain_ge_beta_kl (r := r) hβ hp
  nlinarith [hpin, hkl, hβ]

/-- **Drift caps gain.**  A policy close to the reference in `L¹` cannot have improved
the reward by much: the gain is at most `(range r / 2) · ‖π_β − p‖₁`. -/
theorem gain_le_range_mul_l1 {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) :
    (∑ y, gibbsPolicy β r p y * r y) - ∑ y, p y * r y
      ≤ rewardRange r / 2 * l1Dist (gibbsPolicy β r p) p := by
  set c : ℝ := (univ.sup' univ_nonempty r + univ.inf' univ_nonempty r) / 2 with hc
  set f : Ω → ℝ := fun y => r y - c with hf
  have hM : ∀ y, |f y| ≤ rewardRange r / 2 := by
    intro y
    have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
    have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
    rw [abs_le]
    constructor <;> · simp only [hf, hc, rewardRange]; linarith
  have hgap : ∀ q : Ω → ℝ, IsDist q → (∑ y, q y * f y) = (∑ y, q y * r y) - c := by
    intro q hq
    have : ∀ y, q y * f y = q y * r y - c * q y := by intro y; simp only [hf]; ring
    rw [Finset.sum_congr rfl (fun y _ => this y), Finset.sum_sub_distrib, ← Finset.mul_sum, hq.2]
    ring
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have habs := audit_gap_le_l1 (q := gibbsPolicy β r p) (p := p) (f := f) hM
  rw [hgap _ hg.isDist, hgap _ hp.isDist] at habs
  have hsimp : ((∑ y, gibbsPolicy β r p y * r y) - c) - ((∑ y, p y * r y) - c)
      = (∑ y, gibbsPolicy β r p y * r y) - ∑ y, p y * r y := by ring
  rw [hsimp] at habs
  exact le_trans (le_abs_self _) habs

/-- **The achievable gain also decays like `β⁻¹`.**  Once the temperature exceeds the
reward range, no more than `range(r)²/β` of reward can be extracted. -/
theorem gain_le_range_sq_div {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hbig : rewardRange r ≤ β) :
    (∑ y, gibbsPolicy β r p y * r y) - ∑ y, p y * r y ≤ (rewardRange r) ^ 2 / β := by
  have hR := rewardRange_nonneg r
  have h1 := gain_le_range_mul_l1 (β := β) (r := r) hp
  have h2 := gibbs_l1_le_two_range_div hβ hp hbig
  have h3 : rewardRange r / 2 * l1Dist (gibbsPolicy β r p) p
      ≤ rewardRange r / 2 * (2 * rewardRange r / β) :=
    mul_le_mul_of_nonneg_left h2 (by positivity)
  have h4 : rewardRange r / 2 * (2 * rewardRange r / β) = (rewardRange r) ^ 2 / β := by
    field_simp
  linarith

/-! ## 2. The PTX drift budget

We do not need the PTX optimum: any policy that merely *beats the reference* under the
full objective already obeys the budget. -/

/-- **PTX drift budget.**  If `q` is at least as good as the SFT reference `p` under the
full RLHF+PTX objective, then the divergence it spends on the RL side plus the
divergence it loses on the pretraining side is bounded by the reward range plus the
pretraining mismatch of the reference itself. -/
theorem ptx_budget {β γ : ℝ} {r p d q : Ω → ℝ} (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q)
    (hbeat : objectivePTX β γ r p d p ≤ objectivePTX β γ r p d q) :
    β * klDiv q p + γ * klDiv d q ≤ rewardRange r + γ * klDiv d p := by
  have hklp : klDiv p p = 0 := (kl_eq_zero_iff hp.isDist hp).mpr rfl
  have hobjp : objectivePTX β γ r p d p
      = (∑ y, p y * r y) + γ * ∑ y, d y * Real.log (p y) := by
    simp only [objectivePTX, objective, hklp]
    ring
  have hobjq : objectivePTX β γ r p d q
      = (∑ y, q y * r y) - β * klDiv q p + γ * ∑ y, d y * Real.log (q y) := rfl
  have hdq := klDiv_eq_neg_entropy_sub_cross hd hq
  have hdp := klDiv_eq_neg_entropy_sub_cross hd hp
  have hsup : ∑ y, q y * r y ≤ univ.sup' univ_nonempty r := expectation_le_sup hq.isDist
  have hinf : univ.inf' univ_nonempty r ≤ ∑ y, p y * r y := inf_le_expectation hp.isDist
  have hrange : (∑ y, q y * r y) - ∑ y, p y * r y ≤ rewardRange r := by
    simp only [rewardRange]
    linarith
  rw [hobjp, hobjq] at hbeat
  -- rewrite the two cross-entropies in terms of KL divergences
  have hcq : ∑ y, d y * Real.log (q y) = -entropy d - klDiv d q := by linarith
  have hcp : ∑ y, d y * Real.log (p y) = -entropy d - klDiv d p := by linarith
  rw [hcq, hcp] at hbeat
  linarith [hbeat, hrange]

/-- Explicit KL drift bound for a PTX-competitive policy. -/
theorem ptx_kl_le {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q)
    (hbeat : objectivePTX β γ r p d p ≤ objectivePTX β γ r p d q) :
    klDiv q p ≤ (rewardRange r + γ * klDiv d p) / β := by
  have hbudget := ptx_budget hp hd hq hbeat
  have hnn : 0 ≤ γ * klDiv d q := mul_nonneg hγ (kl_nonneg hd hq)
  rw [le_div_iff₀ hβ]
  linarith

/-- Explicit `L¹` drift bound for a PTX-competitive policy: the pretraining mix-in
enlarges the drift budget by exactly `γ KL(d ‖ p)/β`. -/
theorem ptx_l1_le {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q)
    (hbeat : objectivePTX β γ r p d p ≤ objectivePTX β γ r p d q) :
    l1Dist q p ≤ Real.sqrt (2 * (rewardRange r + γ * klDiv d p) / β) := by
  have h1 := l1Dist_le_sqrt_two_mul_kl hq.isDist hp
  have h2 := ptx_kl_le hβ hγ hp hd hq hbeat
  refine h1.trans (Real.sqrt_le_sqrt ?_)
  rw [mul_div_assoc]
  linarith

/-- **The pretraining term cannot be sacrificed either.**  A PTX-competitive policy
stays within `range(r)/γ` (in KL) of the pretraining-optimal position of the
reference. -/
theorem ptx_pretrain_kl_le {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q)
    (hbeat : objectivePTX β γ r p d p ≤ objectivePTX β γ r p d q) :
    klDiv d q ≤ klDiv d p + rewardRange r / γ := by
  have hbudget := ptx_budget hp hd hq hbeat
  have hnn : 0 ≤ β * klDiv q p := mul_nonneg hβ.le (kl_nonneg hq.isDist hp)
  have h2 : γ * klDiv d q ≤ γ * (klDiv d p + rewardRange r / γ) := by
    have hrw : γ * (klDiv d p + rewardRange r / γ) = γ * klDiv d p + rewardRange r := by
      field_simp
    rw [hrw]
    linarith
  exact le_of_mul_le_mul_left h2 hγ

end RLHF