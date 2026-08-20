import Algebra.RLHFPTXExistence

/-!
# How far does the pretraining mix-in drag the aligned policy?

The PPO-ptx objective

```
J_γ(q) = 𝔼_q[r] − β · KL(q ‖ p) + γ · 𝔼_{x∼d}[log q x]
```

has a unique maximizer `q*_γ` (`RLHF.existsUnique_ptx_maximizer`), but no closed form.  This
file bounds `q*_γ` *quantitatively* against the closed-form pure-RLHF optimum
`π_β = gibbsPolicy β r p`.

Main results (all `sorry`-free):

* `RLHF.ptx_pythagorean` — a **Pythagorean-type inequality**: for any policy at least as good
  as `π_β` for the PTX objective,
  `β · KL(q ‖ π_β) + γ · KL(d ‖ q) ≤ γ · KL(d ‖ π_β)`.
  The two information distances trade off exactly against the alignment/pretraining budget.
* `RLHF.ptx_drift_le` — hence `KL(q*_γ ‖ π_β) ≤ (γ/β) · KL(d ‖ π_β)`: the PTX mix-in moves the
  aligned policy by an amount controlled by the *ratio of coefficients* times the information
  distance between the pretraining distribution and the Gibbs policy.
* `RLHF.ptx_eq_gibbs_of_pretrain_eq_gibbs` — a rigidity statement: if the pretraining
  distribution already equals the Gibbs policy, PTX changes nothing at all.
* `RLHF.ptx_drift_tendsto_zero` — the `γ → 0⁺` limit: PPO-ptx degenerates continuously to
  plain KL-regularized RLHF, in the strong sense of KL convergence of the optimum.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- Rewriting of the PTX objective through the KL divergence to the Gibbs policy and the
cross-entropy against the pretraining distribution. -/
theorem objectivePTX_eq_kl_form {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hd : IsDist d) (hq : IsPosDist q) :
    objectivePTX β γ r p d q
      = freeEnergy β r p - β * klDiv q (gibbsPolicy β r p)
        - γ * entropy d - γ * klDiv d q := by
  have h1 : objective β r p q
      = β * Real.log (partition β r p) - β * klDiv q (gibbsPolicy β r p) :=
    objective_eq_free_energy_sub_kl hβ hp hq.isDist
  have h2 : klDiv d q = -entropy d - ∑ y, d y * Real.log (q y) :=
    klDiv_eq_neg_entropy_sub_cross hd hq
  unfold objectivePTX freeEnergy
  rw [h1]
  have h3 : ∑ y, d y * Real.log (q y) = -entropy d - klDiv d q := by linarith
  rw [h3]
  ring

/-- **Pythagorean inequality for the pretraining mix-in.**  Any policy that is at least as good
as the Gibbs policy for the PTX objective satisfies
`β · KL(q ‖ π_β) + γ · KL(d ‖ q) ≤ γ · KL(d ‖ π_β)`. -/
theorem ptx_pythagorean {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hd : IsDist d) (hq : IsPosDist q)
    (hge : objectivePTX β γ r p d (gibbsPolicy β r p) ≤ objectivePTX β γ r p d q) :
    β * klDiv q (gibbsPolicy β r p) + γ * klDiv d q ≤ γ * klDiv d (gibbsPolicy β r p) := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hq' := objectivePTX_eq_kl_form (β := β) (γ := γ) (r := r) (d := d) hβ hp hd hq
  have hgg := objectivePTX_eq_kl_form (β := β) (γ := γ) (r := r) (d := d) hβ hp hd hg
  have hzero : klDiv (gibbsPolicy β r p) (gibbsPolicy β r p) = 0 :=
    (kl_eq_zero_iff hg.isDist hg).mpr rfl
  rw [hzero] at hgg
  rw [hq', hgg] at hge
  linarith

/-- **Drift bound.**  The PTX optimum stays within information distance `(γ/β)·KL(d ‖ π_β)` of
the closed-form RLHF optimum. -/
theorem ptx_drift_le {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) (hp : IsPosDist p)
    (hd : IsDist d) (hq : IsPosDist q)
    (hge : objectivePTX β γ r p d (gibbsPolicy β r p) ≤ objectivePTX β γ r p d q) :
    klDiv q (gibbsPolicy β r p) ≤ (γ / β) * klDiv d (gibbsPolicy β r p) := by
  have hpy := ptx_pythagorean hβ hp hd hq hge
  have hdq : 0 ≤ klDiv d q := kl_nonneg hd hq
  have hγdq : 0 ≤ γ * klDiv d q := mul_nonneg hγ hdq
  have hβkl : β * klDiv q (gibbsPolicy β r p) ≤ γ * klDiv d (gibbsPolicy β r p) := by linarith
  rw [div_mul_eq_mul_div, le_div_iff₀ hβ]
  linarith [hβkl]

/-- **Rigidity.**  If the pretraining distribution coincides with the Gibbs policy, the PTX
mix-in has no effect whatsoever: the aligned policy is still exactly `π_β`. -/
theorem ptx_eq_gibbs_of_pretrain_eq_gibbs {β γ : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : IsDist d) (hq : IsPosDist q)
    (hdg : d = gibbsPolicy β r p)
    (hge : objectivePTX β γ r p d (gibbsPolicy β r p) ≤ objectivePTX β γ r p d q) :
    q = gibbsPolicy β r p := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  have hbound := ptx_drift_le hβ hγ hp hd hq hge
  have hzero : klDiv d (gibbsPolicy β r p) = 0 := by
    rw [hdg]
    exact (kl_eq_zero_iff hg.isDist hg).mpr rfl
  rw [hzero, mul_zero] at hbound
  have hge0 : 0 ≤ klDiv q (gibbsPolicy β r p) := kl_nonneg hq.isDist hg
  exact (kl_eq_zero_iff hq.isDist hg).mp (le_antisymm hbound hge0)

/-- **Continuous degeneration at `γ → 0⁺`.**  Along any selection of PTX optima, the KL
divergence to the pure-RLHF Gibbs policy tends to `0`: PPO-ptx interpolates continuously into
plain KL-regularized RLHF. -/
theorem ptx_drift_tendsto_zero {β : ℝ} {r p d : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hd : IsDist d) (Q : ℝ → Ω → ℝ)
    (hQpos : ∀ γ, 0 < γ → IsPosDist (Q γ))
    (hQmax : ∀ γ, 0 < γ → ∀ q', IsPosDist q' →
      objectivePTX β γ r p d q' ≤ objectivePTX β γ r p d (Q γ)) :
    Filter.Tendsto (fun γ => klDiv (Q γ) (gibbsPolicy β r p))
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
  have hg : IsPosDist (gibbsPolicy β r p) := gibbsPolicy_isPosDist hp
  set C := klDiv d (gibbsPolicy β r p) with hC
  have hmem : ∀ᶠ γ in nhdsWithin (0:ℝ) (Set.Ioi 0), (0:ℝ) < γ :=
    eventually_nhdsWithin_of_forall (fun γ hγ => hγ)
  refine squeeze_zero' (g := fun γ : ℝ => (γ / β) * C) ?_ ?_ ?_
  · filter_upwards [hmem] with γ hγ
    exact kl_nonneg (hQpos γ hγ).isDist hg
  · filter_upwards [hmem] with γ hγ
    exact ptx_drift_le hβ hγ.le hp hd (hQpos γ hγ)
      (hQmax γ hγ _ hg)
  · have : Filter.Tendsto (fun γ : ℝ => (γ / β) * C) (nhds 0) (nhds 0) := by
      have hcont : Continuous fun γ : ℝ => (γ / β) * C :=
        (continuous_id.div_const β).mul continuous_const
      have := hcont.tendsto 0
      simpa using this
    exact this.mono_left nhdsWithin_le_nhds

end RLHF