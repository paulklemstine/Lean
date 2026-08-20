import Algebra.RLHFStationarity

/-!
# Stability of the PPO-ptx optimum under reward perturbation

`RLHF.freeEnergy_lipschitz` bounds how much a corrupted reward model can move the attainable
*value* of alignment.  This file bounds how much it can move the *policy*.

The mechanism is a strengthening of the tangent bound of `Catalog/Algebra/RLHFStationarity.lean`:
at a PPO-ptx optimum the objective does not merely decrease away from the optimum, it decreases
by at least `β · KL(q ‖ q*)` (`RLHF.objectivePTX_add_kl_le_of_maximizer`).  Playing that
"strong concavity" statement off against itself for two reward models gives the main result.

Main results (all `sorry`-free):

* `RLHF.ptxCoord_add_kl_le_tangent` — the tangent bound with an explicit Bregman remainder.
* `RLHF.objectivePTX_add_kl_le_of_maximizer` — `β`-strong concavity of the PPO-ptx objective
  relative to KL, at the optimum.
* `RLHF.ptx_optimum_stability_l1` — the symmetrized KL between the optima of two reward models
  is bounded by their inner product against the difference of the optima, hence by
  `K · ‖q₁ − q₂‖₁ / β`.
* `RLHF.ptx_optimum_stability` — the clean corollary
  `β · (KL(q₁‖q₂) + KL(q₂‖q₁)) ≤ 2K` for reward models within `K` in sup-norm: a reward-hacking
  immunity band for the *policy*, not just for the value.
* `RLHF.exists_ptx_optima_stability` — non-vacuity: both optima exist, so the band is a
  statement about genuinely existing policies.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- The coordinatewise tangent bound with its exact Bregman remainder. -/
theorem ptxCoord_add_kl_le_tangent {β γ rv pv dv t t' : ℝ} (hγ : 0 ≤ γ) (hpv : 0 < pv)
    (hdv : 0 ≤ dv) (ht : 0 < t) (ht' : 0 < t') :
    ptxCoord β γ rv pv dv t' + β * (t' * Real.log (t' / t) - (t' - t))
      ≤ ptxCoord β γ rv pv dv t
        + (rv - β * (Real.log (t / pv) + 1) + γ * dv / t) * (t' - t) := by
  have hA : Real.log t' = Real.log t + Real.log (t' / t) := by
    rw [Real.log_div ht'.ne' ht.ne']; ring
  have hB : Real.log (t' / pv) = Real.log (t / pv) + Real.log (t' / t) := by
    rw [Real.log_div ht'.ne' hpv.ne', Real.log_div ht.ne' hpv.ne', Real.log_div ht'.ne' ht.ne']
    ring
  have h2 : Real.log (t' / t) ≤ t' / t - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  have h3 : γ * (dv * Real.log (t' / t)) ≤ γ * (dv * (t' / t - 1)) :=
    mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left h2 hdv) hγ
  have hdt : γ * dv / t * (t' - t) = γ * (dv * (t' / t - 1)) := by
    field_simp
  simp only [ptxCoord]
  rw [hA, hB]
  nlinarith [h3, hdt]

/-- **Strong concavity at the optimum.**  At a PPO-ptx maximizer the objective drops by at least
`β` times the KL divergence to the optimum. -/
theorem objectivePTX_add_kl_le_of_maximizer {β γ : ℝ} {r p d q q' : Ω → ℝ} (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y) (hq' : IsPosDist q')
    (hmax : IsPTXMaximizer β γ r p d q) :
    objectivePTX β γ r p d q' + β * klDiv q' q ≤ objectivePTX β γ r p d q := by
  classical
  have hq := hmax.1
  obtain ⟨c, hc⟩ : ∃ c, ∀ z, ptxScore β γ r p d q z = c := by
    exact ⟨ptxScore β γ r p d q (Classical.arbitrary Ω), fun z =>
      ptxScore_const_of_isPTXMaximizer hp hmax z (Classical.arbitrary Ω)⟩
  simp only [ptxScore] at hc
  have hle : ∀ y ∈ (univ : Finset Ω),
      ptxCoord β γ (r y) (p y) (d y) (q' y) + β * (q' y * Real.log (q' y / q y) - (q' y - q y))
        ≤ ptxCoord β γ (r y) (p y) (d y) (q y) + c * (q' y - q y) := by
    intro y _
    have h := ptxCoord_add_kl_le_tangent (β := β) (γ := γ) (rv := r y) (pv := p y) (dv := d y)
      (t := q y) (t' := q' y) hγ (hp.1 y) (hd y) (hq.1 y) (hq'.1 y)
    rwa [hc y] at h
  have hsum := Finset.sum_le_sum hle
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
    Finset.sum_sub_distrib, Finset.sum_sub_distrib, hq.2, hq'.2] at hsum
  rw [objectivePTX_eq_sum_coord, objectivePTX_eq_sum_coord, klDiv]
  simpa using hsum

omit [Nonempty Ω] in
/-- Changing only the reward model changes the PPO-ptx objective by the expected reward gap. -/
theorem objectivePTX_sub_reward {β γ : ℝ} {r s p d q : Ω → ℝ} :
    objectivePTX β γ r p d q - objectivePTX β γ s p d q = ∑ y, q y * (r y - s y) := by
  have hsplit : ∑ y, q y * (r y - s y) = (∑ y, q y * r y) - ∑ y, q y * s y := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  unfold objectivePTX objective
  rw [hsplit]
  ring

/-- **Policy stability, `ℓ¹` form.**  The symmetrized KL divergence between the PPO-ptx optima
of two reward models is controlled by the pairing of the reward gap with the policy gap. -/
theorem ptx_optimum_stability_l1 {β γ : ℝ} {r s p d q₁ q₂ : Ω → ℝ} (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y)
    (h₁ : IsPTXMaximizer β γ r p d q₁) (h₂ : IsPTXMaximizer β γ s p d q₂) :
    β * (klDiv q₁ q₂ + klDiv q₂ q₁) ≤ ∑ y, (q₁ y - q₂ y) * (r y - s y) := by
  have hq₁ := h₁.1
  have hq₂ := h₂.1
  have hA : objectivePTX β γ r p d q₂ + β * klDiv q₂ q₁ ≤ objectivePTX β γ r p d q₁ :=
    objectivePTX_add_kl_le_of_maximizer hγ hp hd hq₂ h₁
  have hB : objectivePTX β γ s p d q₁ + β * klDiv q₁ q₂ ≤ objectivePTX β γ s p d q₂ :=
    objectivePTX_add_kl_le_of_maximizer hγ hp hd hq₁ h₂
  have hR₁ : objectivePTX β γ r p d q₁ - objectivePTX β γ s p d q₁ = ∑ y, q₁ y * (r y - s y) :=
    objectivePTX_sub_reward
  have hR₂ : objectivePTX β γ r p d q₂ - objectivePTX β γ s p d q₂ = ∑ y, q₂ y * (r y - s y) :=
    objectivePTX_sub_reward
  have hsplit : ∑ y, (q₁ y - q₂ y) * (r y - s y)
      = (∑ y, q₁ y * (r y - s y)) - ∑ y, q₂ y * (r y - s y) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [hsplit]
  linarith

/-- **Reward-hacking immunity band for the policy.**  If two reward models agree to within `K`
in sup-norm, the symmetrized KL divergence between their PPO-ptx optima is at most `2K/β`.  A
bounded corruption of a neurosymbolic reward model therefore cannot move the aligned policy by
more than a bounded amount of information — the analogue, for policies, of the value bound
`freeEnergy_lipschitz`. -/
theorem ptx_optimum_stability {β γ K : ℝ} {r s p d q₁ q₂ : Ω → ℝ} (hγ : 0 ≤ γ)
    (hp : IsPosDist p) (hd : ∀ y, 0 ≤ d y)
    (h₁ : IsPTXMaximizer β γ r p d q₁) (h₂ : IsPTXMaximizer β γ s p d q₂)
    (hK : ∀ y, |r y - s y| ≤ K) :
    β * (klDiv q₁ q₂ + klDiv q₂ q₁) ≤ 2 * K := by
  have hq₁ := h₁.1
  have hq₂ := h₂.1
  have hmain := ptx_optimum_stability_l1 hγ hp hd h₁ h₂
  have hterm : ∀ y ∈ (univ : Finset Ω), (q₁ y - q₂ y) * (r y - s y) ≤ (q₁ y + q₂ y) * K := by
    intro y _
    have h1 : |(q₁ y - q₂ y) * (r y - s y)| ≤ |q₁ y - q₂ y| * K := by
      rw [abs_mul]
      exact mul_le_mul_of_nonneg_left (hK y) (abs_nonneg _)
    have h2 : |q₁ y - q₂ y| ≤ q₁ y + q₂ y := by
      rw [abs_le]
      constructor <;> linarith [hq₁.1 y, hq₂.1 y]
    have hKnn : 0 ≤ K := le_trans (abs_nonneg _) (hK y)
    calc (q₁ y - q₂ y) * (r y - s y) ≤ |(q₁ y - q₂ y) * (r y - s y)| := le_abs_self _
      _ ≤ |q₁ y - q₂ y| * K := h1
      _ ≤ (q₁ y + q₂ y) * K := mul_le_mul_of_nonneg_right h2 hKnn
  have hsum := Finset.sum_le_sum hterm
  rw [← Finset.sum_mul, Finset.sum_add_distrib, hq₁.2, hq₂.2] at hsum
  linarith

/-- Non-vacuity: for a fully supported pretraining distribution both optima exist, so the
immunity band is a statement about genuinely existing policies. -/
theorem exists_ptx_optima_stability {β γ δ K : ℝ} {r s p d : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : ∀ y, δ ≤ d y) (hδ : 0 < δ) (hK : ∀ y, |r y - s y| ≤ K) :
    ∃ q₁ q₂, IsPTXMaximizer β γ r p d q₁ ∧ IsPTXMaximizer β γ s p d q₂ ∧
      β * (klDiv q₁ q₂ + klDiv q₂ q₁) ≤ 2 * K := by
  obtain ⟨q₁, ⟨hq₁, hopt₁⟩, -⟩ := existsUnique_ptx_maximizer (r := r) hβ hγ hp hd hδ
  obtain ⟨q₂, ⟨hq₂, hopt₂⟩, -⟩ := existsUnique_ptx_maximizer (r := s) hβ hγ hp hd hδ
  have hdnn : ∀ y, 0 ≤ d y := fun y => le_trans hδ.le (hd y)
  exact ⟨q₁, q₂, ⟨hq₁, hopt₁⟩, ⟨hq₂, hopt₂⟩,
    ptx_optimum_stability hγ.le hp hdnn ⟨hq₁, hopt₁⟩ ⟨hq₂, hopt₂⟩ hK⟩

end RLHF