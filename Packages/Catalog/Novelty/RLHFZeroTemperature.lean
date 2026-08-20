import Novelty.RLHFQuadraticDrift

/-!
# The low-temperature phase: Laplace principle and policy collapse

Domain: Novelty (large deviations × alignment theory).

`Novelty.RLHFQuadraticDrift` describes the *high*-temperature phase: the aligned
policy `π_β` stays `Θ(β⁻¹)`-close to the SFT reference `p`.  This file describes the
opposite regime `β ↓ 0`, where KL regularization is switched off:

* `RLHF.freeEnergy_le_sup` and `RLHF.freeEnergy_ge_sup_add` — the two-sided
  Laplace estimate
  `max r + β log (min p) ≤ β log Z ≤ max r`,
  an explicit, non-asymptotic form of Varadhan's lemma on a finite space;
* `RLHF.freeEnergy_tendsto_sup` — hence `β log Z → max r` as `β ↓ 0`;
* `RLHF.gibbs_le_exp_gap` — every suboptimal response is exponentially suppressed:
  `π_β y ≤ (1/min p) · exp(−(max r − r y)/β)`;
* `RLHF.gibbs_tendsto_zero_of_lt` — so its probability vanishes as `β ↓ 0`;
* `RLHF.l1Dist_spike_tendsto_one` — and in the two-point model the drift tends to
  its maximum value `1`: **total policy collapse**.

Together with the `Θ(β⁻¹)` law this gives the complete phase picture of the KL
penalty: full collapse at `β = 0⁺`, exact reference recovery at `β = ∞`.
-/

namespace RLHF

open Finset Filter Topology

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. The two-sided Laplace estimate -/

/-- The free energy never exceeds the maximal reward. -/
theorem freeEnergy_le_sup {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    freeEnergy β r p ≤ univ.sup' univ_nonempty r := by
  have hZ := partition_pos (β := β) (r := r) hp
  have hle : partition β r p ≤ Real.exp (univ.sup' univ_nonempty r / β) := by
    have hterm : ∀ y ∈ (univ : Finset Ω),
        p y * Real.exp (r y / β) ≤ p y * Real.exp (univ.sup' univ_nonempty r / β) := by
      intro y _
      refine mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr ?_) (hp.1 y).le
      gcongr
      exact Finset.le_sup' r (mem_univ y)
    have h := Finset.sum_le_sum hterm
    rwa [← Finset.sum_mul, hp.2, one_mul] at h
  have hlog : Real.log (partition β r p) ≤ univ.sup' univ_nonempty r / β := by
    calc Real.log (partition β r p)
        ≤ Real.log (Real.exp (univ.sup' univ_nonempty r / β)) := Real.log_le_log hZ hle
      _ = univ.sup' univ_nonempty r / β := Real.log_exp _
  have := mul_le_mul_of_nonneg_left hlog hβ.le
  calc freeEnergy β r p = β * Real.log (partition β r p) := rfl
    _ ≤ β * (univ.sup' univ_nonempty r / β) := this
    _ = univ.sup' univ_nonempty r := by field_simp

/-- A matching lower bound: the free energy is within `β log (min p)` of the maximum. -/
theorem freeEnergy_ge_sup_add {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    univ.sup' univ_nonempty r + β * Real.log (univ.inf' univ_nonempty p) ≤ freeEnergy β r p := by
  obtain ⟨y₁, -, hy₁⟩ := Finset.exists_mem_eq_sup' (univ_nonempty (α := Ω)) r
  have hpmin : 0 < univ.inf' univ_nonempty p := by
    obtain ⟨y₂, -, hy₂⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := Ω)) p
    rw [hy₂]
    exact hp.1 y₂
  have hpm : univ.inf' univ_nonempty p ≤ p y₁ := Finset.inf'_le p (mem_univ y₁)
  have hge : univ.inf' univ_nonempty p * Real.exp (univ.sup' univ_nonempty r / β)
      ≤ partition β r p := by
    have hterm : ∀ y ∈ (univ : Finset Ω), (0 : ℝ) ≤ p y * Real.exp (r y / β) := by
      intro y _
      have := (hp.1 y).le
      positivity
    have hsingle : univ.inf' univ_nonempty p * Real.exp (univ.sup' univ_nonempty r / β)
        ≤ p y₁ * Real.exp (r y₁ / β) := by
      rw [hy₁]
      exact mul_le_mul_of_nonneg_right hpm (Real.exp_pos _).le
    exact hsingle.trans (Finset.single_le_sum hterm (mem_univ y₁))
  have hZ := partition_pos (β := β) (r := r) hp
  have hlog : Real.log (univ.inf' univ_nonempty p) + univ.sup' univ_nonempty r / β
      ≤ Real.log (partition β r p) := by
    have h1 : Real.log (univ.inf' univ_nonempty p * Real.exp (univ.sup' univ_nonempty r / β))
        = Real.log (univ.inf' univ_nonempty p) + univ.sup' univ_nonempty r / β := by
      rw [Real.log_mul (ne_of_gt hpmin) (Real.exp_ne_zero _), Real.log_exp]
    rw [← h1]
    exact Real.log_le_log (by positivity) hge
  have := mul_le_mul_of_nonneg_left hlog hβ.le
  calc univ.sup' univ_nonempty r + β * Real.log (univ.inf' univ_nonempty p)
      = β * (Real.log (univ.inf' univ_nonempty p) + univ.sup' univ_nonempty r / β) := by
        field_simp; ring
    _ ≤ β * Real.log (partition β r p) := this
    _ = freeEnergy β r p := rfl

/-- **Laplace / Varadhan principle for RLHF.**  As the KL penalty is switched off, the
optimal value of the objective converges to the maximal reward. -/
theorem freeEnergy_tendsto_sup {r p : Ω → ℝ} (hp : IsPosDist p) :
    Tendsto (fun β : ℝ => freeEnergy β r p) (𝓝[>] 0) (𝓝 (univ.sup' univ_nonempty r)) := by
  have hlow : Tendsto
      (fun β : ℝ => univ.sup' univ_nonempty r + β * Real.log (univ.inf' univ_nonempty p))
      (𝓝[>] (0 : ℝ)) (𝓝 (univ.sup' univ_nonempty r)) := by
    have hc : Continuous
        (fun β : ℝ => univ.sup' univ_nonempty r + β * Real.log (univ.inf' univ_nonempty p)) := by
      continuity
    have := hc.tendsto 0
    simp only [zero_mul, add_zero] at this
    exact this.mono_left nhdsWithin_le_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_ge_sup_add hβ hp
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_le_sup hβ hp

/-! ## 2. Exponential suppression of suboptimal responses -/

/-- Every response is suppressed at the exponential rate given by its reward gap. -/
theorem gibbs_le_exp_gap {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) (y : Ω) :
    gibbsPolicy β r p y
      ≤ (univ.inf' univ_nonempty p)⁻¹ * Real.exp (-(univ.sup' univ_nonempty r - r y) / β) := by
  have hpmin : 0 < univ.inf' univ_nonempty p := by
    obtain ⟨y₂, -, hy₂⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := Ω)) p
    rw [hy₂]
    exact hp.1 y₂
  have hZge : univ.inf' univ_nonempty p * Real.exp (univ.sup' univ_nonempty r / β)
      ≤ partition β r p := by
    obtain ⟨y₁, -, hy₁⟩ := Finset.exists_mem_eq_sup' (univ_nonempty (α := Ω)) r
    have hterm : ∀ z ∈ (univ : Finset Ω), (0 : ℝ) ≤ p z * Real.exp (r z / β) := by
      intro z _
      have := (hp.1 z).le
      positivity
    have hsingle : univ.inf' univ_nonempty p * Real.exp (univ.sup' univ_nonempty r / β)
        ≤ p y₁ * Real.exp (r y₁ / β) := by
      rw [hy₁]
      exact mul_le_mul_of_nonneg_right (Finset.inf'_le p (mem_univ y₁)) (Real.exp_pos _).le
    exact hsingle.trans (Finset.single_le_sum hterm (mem_univ y₁))
  have hple : p y ≤ 1 := by
    have hterm : ∀ z ∈ (univ : Finset Ω), (0 : ℝ) ≤ p z := fun z _ => (hp.1 z).le
    have h := Finset.single_le_sum hterm (mem_univ y)
    rw [hp.2] at h
    exact h
  have hnum : p y * Real.exp (r y / β) ≤ Real.exp (r y / β) := by
    nlinarith [Real.exp_pos (r y / β), hple]
  have hden : (0 : ℝ) < univ.inf' univ_nonempty p
      * Real.exp (univ.sup' univ_nonempty r / β) := by positivity
  have h1 : gibbsPolicy β r p y
      ≤ Real.exp (r y / β) / (univ.inf' univ_nonempty p
          * Real.exp (univ.sup' univ_nonempty r / β)) := by
    unfold gibbsPolicy
    gcongr
  have h2 : Real.exp (r y / β) / (univ.inf' univ_nonempty p
        * Real.exp (univ.sup' univ_nonempty r / β))
      = (univ.inf' univ_nonempty p)⁻¹ * Real.exp (-(univ.sup' univ_nonempty r - r y) / β) := by
    have h : Real.exp (-(univ.sup' univ_nonempty r - r y) / β)
        = Real.exp (r y / β) / Real.exp (univ.sup' univ_nonempty r / β) := by
      rw [← Real.exp_sub]
      congr 1
      field_simp
      ring
    rw [h]
    field_simp
  rw [← h2]
  exact h1

/-- Suboptimal responses die out as the temperature goes to zero. -/
theorem gibbs_tendsto_zero_of_lt {r p : Ω → ℝ} (hp : IsPosDist p) {y : Ω}
    (hy : r y < univ.sup' univ_nonempty r) :
    Tendsto (fun β : ℝ => gibbsPolicy β r p y) (𝓝[>] 0) (𝓝 0) := by
  have hpmin : 0 < univ.inf' univ_nonempty p := by
    obtain ⟨y₂, -, hy₂⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := Ω)) p
    rw [hy₂]
    exact hp.1 y₂
  have hgap : 0 < univ.sup' univ_nonempty r - r y := by linarith
  have hinv : Tendsto (fun β : ℝ => (univ.sup' univ_nonempty r - r y) / β)
      (𝓝[>] (0 : ℝ)) atTop := by
    have h := Filter.Tendsto.const_mul_atTop hgap tendsto_inv_nhdsGT_zero
    simpa [div_eq_mul_inv] using h
  have hexp : Tendsto
      (fun β : ℝ => Real.exp (-(univ.sup' univ_nonempty r - r y) / β)) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
    have hneg : Tendsto (fun β : ℝ => -((univ.sup' univ_nonempty r - r y) / β))
        (𝓝[>] (0 : ℝ)) atBot := tendsto_neg_atBot_iff.mpr hinv
    have := Real.tendsto_exp_atBot.comp hneg
    refine this.congr fun β => ?_
    simp only [Function.comp_apply]
    congr 1
    ring
  have hlim : Tendsto (fun β : ℝ => (univ.inf' univ_nonempty p)⁻¹
      * Real.exp (-(univ.sup' univ_nonempty r - r y) / β)) (𝓝[>] (0 : ℝ)) (𝓝 0) := by
    simpa using hexp.const_mul ((univ.inf' univ_nonempty p)⁻¹)
  refine squeeze_zero' ?_ ?_ hlim
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact (gibbsPolicy_isPosDist (β := β) (r := r) hp).1 y |>.le
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact gibbs_le_exp_gap hβ hp y

/-! ## 3. Policy collapse in the two-point model -/

/-- **Total policy collapse at zero temperature.**  In the two-point model the drift of
the aligned policy tends to its maximal possible value `1` as `β ↓ 0`: the KL penalty
no longer restrains the policy at all. -/
theorem l1Dist_spike_tendsto_one :
    Tendsto (fun β : ℝ => l1Dist (gibbsPolicy β spikeReward unifBool) unifBool)
      (𝓝[>] 0) (𝓝 1) := by
  have hEq : ∀ᶠ β in 𝓝[>] (0 : ℝ),
      l1Dist (gibbsPolicy β spikeReward unifBool) unifBool
        = 1 - 2 / (Real.exp (1 / β) + 1) := by
    filter_upwards [self_mem_nhdsWithin] with β hβ
    rw [l1Dist_spike hβ]
    have hden : (0 : ℝ) < Real.exp (1 / β) + 1 := by positivity
    field_simp
    ring
  have hinv : Tendsto (fun β : ℝ => 1 / β) (𝓝[>] (0 : ℝ)) atTop := by
    simpa [one_div] using tendsto_inv_nhdsGT_zero
  have hexp : Tendsto (fun β : ℝ => Real.exp (1 / β) + 1) (𝓝[>] (0 : ℝ)) atTop :=
    (Real.tendsto_exp_atTop.comp hinv).atTop_add tendsto_const_nhds
  have hfrac : Tendsto (fun β : ℝ => 2 / (Real.exp (1 / β) + 1)) (𝓝[>] (0 : ℝ)) (𝓝 0) :=
    Tendsto.div_atTop tendsto_const_nhds hexp
  have hlim : Tendsto (fun β : ℝ => 1 - 2 / (Real.exp (1 / β) + 1)) (𝓝[>] (0 : ℝ)) (𝓝 1) := by
    simpa using tendsto_const_nhds.sub hfrac
  exact hlim.congr' (hEq.mono fun β h => h.symm)

end RLHF