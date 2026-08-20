/-
Copyright (c) 2025. All rights reserved.

# The Alignment Pareto Frontier and the Low-Temperature Limit of RLHF

Fourth research cycle, building on
`Catalog.Shared.NeuroSymbolicRLHFObjective`.

* **Pareto monotonicity of the KL coefficient.**  Lowering `β` moves the RLHF
  optimum monotonically along a frontier: both the KL divergence from the SFT
  policy *and* the achieved expected reward increase.  The proof is a pure
  exchange argument between the two optimality inequalities — no differentiation
  of the free energy in `β` is needed, so no smoothness hypotheses appear.

* **Low-temperature limit.**  As `β → 0⁺` the optimal value converges to the
  maximal reward, and every strictly suboptimal response is asymptotically
  abandoned by the aligned policy.  Together with `gibbs_tendsto_ref`
  (`β → ∞`, aligned policy → SFT policy) this pins down both ends of the
  frontier.

No `sorry`, no `native_decide`.
-/
import Mathlib
import Catalog.Shared.NeuroSymbolicRLHFObjective

open Finset Real BigOperators Filter Topology

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι]

/-! ## The Pareto frontier in the KL coefficient -/

/-- **KL monotonicity**: the optimal policy for a smaller KL coefficient is
strictly further (weakly) from the SFT reference in KL divergence. -/
theorem klDivFin_gibbs_antitone_beta {β₁ β₂ : ℝ} (h1 : 0 < β₁) (h12 : β₁ < β₂)
    {ref r : ι → ℝ} [Nonempty ι] (href : IsPosProb ref) :
    klDivFin (gibbs β₂ ref r) ref ≤ klDivFin (gibbs β₁ ref r) ref := by
  have hβ₂ : 0 < β₂ := lt_trans h1 h12
  have hg1 : IsPosProb (gibbs β₁ ref r) := gibbs_isPosProb href
  have hg2 : IsPosProb (gibbs β₂ ref r) := gibbs_isPosProb href
  have hopt1 := rlhfObj_gibbs (β := β₁) (r := r) h1 href
  have hopt2 := rlhfObj_gibbs (β := β₂) (r := r) hβ₂ href
  have hcross1 := rlhfObj_le_freeEnergy (β := β₁) (r := r) (p := gibbs β₂ ref r) h1 href hg2.isProb
  have hcross2 := rlhfObj_le_freeEnergy (β := β₂) (r := r) (p := gibbs β₁ ref r) hβ₂ href hg1.isProb
  unfold rlhfObj at hopt1 hopt2 hcross1 hcross2
  nlinarith [hopt1, hopt2, hcross1, hcross2, sub_pos.2 h12]

/-- **Reward monotonicity**: the optimal policy for a smaller KL coefficient
achieves at least as much expected reward. -/
theorem gibbs_reward_antitone_beta {β₁ β₂ : ℝ} (h1 : 0 < β₁) (h12 : β₁ < β₂)
    {ref r : ι → ℝ} [Nonempty ι] (href : IsPosProb ref) :
    ∑ i, gibbs β₂ ref r i * r i ≤ ∑ i, gibbs β₁ ref r i * r i := by
  have hβ₂ : 0 < β₂ := lt_trans h1 h12
  have hg2 : IsPosProb (gibbs β₂ ref r) := gibbs_isPosProb href
  have hopt1 := rlhfObj_gibbs (β := β₁) (r := r) h1 href
  have hcross1 := rlhfObj_le_freeEnergy (β := β₁) (r := r) (p := gibbs β₂ ref r) h1 href hg2.isProb
  have hkl := klDivFin_gibbs_antitone_beta h1 h12 href (r := r)
  unfold rlhfObj at hopt1 hcross1
  nlinarith [hkl, h1]

/-- **The alignment Pareto frontier**: decreasing the KL coefficient trades KL
drift for reward, monotonically in both coordinates simultaneously. -/
theorem alignment_pareto_frontier {β₁ β₂ : ℝ} (h1 : 0 < β₁) (h12 : β₁ < β₂)
    {ref r : ι → ℝ} [Nonempty ι] (href : IsPosProb ref) :
    klDivFin (gibbs β₂ ref r) ref ≤ klDivFin (gibbs β₁ ref r) ref ∧
      ∑ i, gibbs β₂ ref r i * r i ≤ ∑ i, gibbs β₁ ref r i * r i :=
  ⟨klDivFin_gibbs_antitone_beta h1 h12 href, gibbs_reward_antitone_beta h1 h12 href⟩

/-! ## The low-temperature limit `β → 0⁺` -/

/-- Lower bound for the free energy in terms of a maximising response. -/
theorem freeEnergy_ge_max_add {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (i0 : ι) :
    r i0 + β * Real.log (ref i0) ≤ freeEnergy β ref r := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hterm : ref i0 * Real.exp (r i0 / β) ≤ tiltZ β ref r := by
    unfold tiltZ
    refine Finset.single_le_sum (f := fun i => ref i * Real.exp (r i / β)) ?_ (Finset.mem_univ i0)
    intro i _
    exact (mul_pos (href.pos i) (Real.exp_pos _)).le
  have hpos : 0 < ref i0 * Real.exp (r i0 / β) := mul_pos (href.pos i0) (Real.exp_pos _)
  have hlog : Real.log (ref i0) + r i0 / β ≤ Real.log (tiltZ β ref r) := by
    have := Real.log_le_log hpos hterm
    rwa [Real.log_mul (href.pos i0).ne' (Real.exp_ne_zero _), Real.log_exp] at this
  unfold freeEnergy
  have := mul_le_mul_of_nonneg_left hlog hβ.le
  calc r i0 + β * Real.log (ref i0) = β * (Real.log (ref i0) + r i0 / β) := by
        field_simp
        ring
    _ ≤ β * Real.log (tiltZ β ref r) := this

/-- **Low-temperature limit of the optimal value**: as the KL penalty vanishes,
the optimal RLHF value converges to the maximal achievable reward. -/
theorem freeEnergy_tendsto_max {ref r : ι → ℝ} [Nonempty ι] (href : IsPosProb ref)
    {i0 : ι} (hmax : ∀ i, r i ≤ r i0) :
    Tendsto (fun β : ℝ => freeEnergy β ref r) (𝓝[>] 0) (𝓝 (r i0)) := by
  have hlow : Tendsto (fun β : ℝ => r i0 + β * Real.log (ref i0)) (𝓝[>] 0) (𝓝 (r i0)) := by
    have h1 : Tendsto (fun β : ℝ => r i0 + β * Real.log (ref i0)) (𝓝 0)
        (𝓝 (r i0 + 0 * Real.log (ref i0))) := by
      exact tendsto_const_nhds.add (tendsto_id.mul tendsto_const_nhds)
    simpa using h1.mono_left nhdsWithin_le_nhds
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_ge_max_add hβ href i0
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact freeEnergy_le_of_le hβ href hmax

/-- Quantitative suppression of a strictly suboptimal response. -/
theorem gibbs_le_exp_gap {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} [Nonempty ι]
    (href : IsPosProb ref) (i0 i : ι) :
    gibbs β ref r i ≤ (ref i / ref i0) * Real.exp (-((r i0 - r i) / β)) := by
  have hZ : 0 < tiltZ β ref r := tiltZ_pos href
  have hterm : ref i0 * Real.exp (r i0 / β) ≤ tiltZ β ref r := by
    unfold tiltZ
    refine Finset.single_le_sum (f := fun j => ref j * Real.exp (r j / β)) ?_ (Finset.mem_univ i0)
    intro j _
    exact (mul_pos (href.pos j) (Real.exp_pos _)).le
  have hnum : ref i * Real.exp (r i / β)
      ≤ (ref i / ref i0) * Real.exp (-((r i0 - r i) / β)) * (ref i0 * Real.exp (r i0 / β)) := by
    have hsplit : (ref i / ref i0) * Real.exp (-((r i0 - r i) / β)) * (ref i0 * Real.exp (r i0 / β))
        = ref i * (Real.exp (-((r i0 - r i) / β)) * Real.exp (r i0 / β)) := by
      have h0 : ref i0 ≠ 0 := (href.pos i0).ne'
      field_simp
    have hexp : Real.exp (-((r i0 - r i) / β)) * Real.exp (r i0 / β) = Real.exp (r i / β) := by
      rw [← Real.exp_add]
      congr 1
      field_simp
      ring
    rw [hsplit, hexp]
  have hc : 0 ≤ (ref i / ref i0) * Real.exp (-((r i0 - r i) / β)) := by
    have := href.pos i; have := href.pos i0
    positivity
  have : ref i * Real.exp (r i / β)
      ≤ (ref i / ref i0) * Real.exp (-((r i0 - r i) / β)) * tiltZ β ref r :=
    le_trans hnum (mul_le_mul_of_nonneg_left hterm hc)
  unfold gibbs
  rw [div_le_iff₀ hZ]
  exact this

/-- **Low-temperature concentration**: as `β → 0⁺` the aligned policy abandons
every strictly suboptimal response. -/
theorem gibbs_tendsto_zero_of_lt {ref r : ι → ℝ} [Nonempty ι] (href : IsPosProb ref)
    {i0 i : ι} (hlt : r i < r i0) :
    Tendsto (fun β : ℝ => gibbs β ref r i) (𝓝[>] 0) (𝓝 0) := by
  set δ := r i0 - r i with hδ
  have hδpos : 0 < δ := by simp [hδ]; linarith
  have hquot : Tendsto (fun β : ℝ => δ / β) (𝓝[>] 0) atTop := by
    have h := tendsto_inv_nhdsGT_zero.const_mul_atTop hδpos
    simpa [div_eq_mul_inv] using h
  have hexp : Tendsto (fun β : ℝ => Real.exp (-(δ / β))) (𝓝[>] 0) (𝓝 0) := by
    have h1 : Tendsto (fun β : ℝ => Real.exp (δ / β)) (𝓝[>] 0) atTop :=
      Real.tendsto_exp_atTop.comp hquot
    have h2 := h1.inv_tendsto_atTop
    simpa [Real.exp_neg] using h2
  have hbound : Tendsto (fun β : ℝ => (ref i / ref i0) * Real.exp (-(δ / β))) (𝓝[>] 0) (𝓝 0) := by
    have := hexp.const_mul (ref i / ref i0)
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hbound ?_ ?_
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact (gibbs_pos href i).le
  · filter_upwards [self_mem_nhdsWithin] with β hβ
    exact gibbs_le_exp_gap hβ href i0 i

end NeuroSymbolicRLHF