import Algebra.RLHFTiltTorsorPTX

/-!
# Legendre duality between the alignment value and the KL penalty

The Bregman identity of `Algebra.RLHFTiltTorsorPTX` says that the free energy
`F(r) = β log Z(β, r, p)` behaves like a convex potential whose gradient is the aligned policy.
This file proves the corresponding **Fenchel–Legendre duality**, in both directions and with
the maximizers exhibited, so that no smoothness or subdifferential theory is needed:

* `RLHF.isGreatest_freeEnergy` — `F(r) = max_q ( 𝔼_q[r] − β·KL(q ‖ p) )`, the maximum being
  attained at the Gibbs policy;
* `RLHF.isGreatest_klPenalty` — dually, `β·KL(q ‖ p) = max_r ( 𝔼_q[r] − F(r) )`, the maximum
  being attained at the DPO implicit reward `β log (q / p)`.

So the convex conjugate of the alignment value, as a function of the reward model, is exactly
the KL penalty of the RLHF objective: **reward models and policies are Legendre-dual
coordinates on the alignment problem**, and the tilting torsor of the previous file is the
gradient correspondence between them.

Two immediate consequences are recorded:

* `RLHF.fenchel_young` — the Fenchel–Young inequality `𝔼_q[r] ≤ F(r) + β·KL(q ‖ p)`;
* `RLHF.fenchel_young_eq_iff` — equality holds exactly on the graph of the tilting map, i.e.
  exactly when `q` is the aligned policy of `r`.

All results are `sorry`-free.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. Primal problem: the free energy is the value of the RLHF program -/

/-- **The alignment value is a maximum, attained at the Gibbs policy.** -/
theorem isGreatest_freeEnergy {β : ℝ} {r p : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) :
    IsGreatest {v : ℝ | ∃ q, IsDist q ∧ v = (∑ y, q y * r y) - β * klDiv q p}
      (freeEnergy β r p) := by
  constructor
  · refine ⟨gibbsPolicy β r p, (gibbsPolicy_isPosDist hp).isDist, ?_⟩
    have := objective_gibbs (β := β) (r := r) hβ hp
    rw [objective] at this
    unfold freeEnergy
    linarith
  · rintro v ⟨q, hq, rfl⟩
    have := variational_principle (β := β) (r := r) hβ hp hq
    rw [objective] at this
    unfold freeEnergy
    linarith

/-! ## 2. Fenchel–Young inequality and its equality case -/

/-- The Fenchel–Young inequality for the alignment pair `(reward, policy)`. -/
theorem fenchel_young {β : ℝ} {r p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p) (hq : IsDist q) :
    ∑ y, q y * r y ≤ freeEnergy β r p + β * klDiv q p := by
  have := variational_principle (β := β) (r := r) hβ hp hq
  rw [objective] at this
  unfold freeEnergy
  linarith

/-- Equality in Fenchel–Young holds exactly on the graph of the tilting map. -/
theorem fenchel_young_eq_iff {β : ℝ} {r p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsDist q) :
    ∑ y, q y * r y = freeEnergy β r p + β * klDiv q p ↔ q = gibbsPolicy β r p := by
  have hkey : (∑ y, q y * r y) - β * klDiv q p
      = freeEnergy β r p - β * klDiv q (gibbsPolicy β r p) := by
    have := objective_eq_free_energy_sub_kl (β := β) (r := r) hβ hp hq
    rw [objective] at this
    unfold freeEnergy
    linarith
  constructor
  · intro h
    have hzero : β * klDiv q (gibbsPolicy β r p) = 0 := by linarith [hkey, h]
    have : klDiv q (gibbsPolicy β r p) = 0 := by
      rcases mul_eq_zero.mp hzero with h' | h'
      · exact absurd h' (ne_of_gt hβ)
      · exact h'
    exact (kl_eq_zero_iff hq (gibbsPolicy_isPosDist hp)).mp this
  · rintro rfl
    have : klDiv (gibbsPolicy β r p) (gibbsPolicy β r p) = 0 :=
      (kl_eq_zero_iff hq (gibbsPolicy_isPosDist hp)).mpr rfl
    rw [this] at hkey
    linarith

/-! ## 3. Dual problem: the KL penalty is the convex conjugate of the alignment value -/

omit [Nonempty Ω] in
/-- The free energy of the DPO implicit reward vanishes: its partition function is `1`. -/
theorem freeEnergy_implicitReward {β : ℝ} {p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsPosDist q) : freeEnergy β (implicitReward β p q) p = 0 := by
  have hexp : ∀ y, p y * Real.exp (implicitReward β p q y / β) = q y := by
    intro y
    have hpy := hp.1 y
    have hqy := hq.1 y
    unfold implicitReward
    rw [show β * Real.log (q y / p y) / β = Real.log (q y / p y) by field_simp [ne_of_gt hβ],
      Real.exp_log (by positivity)]
    field_simp
  have hZ : partition β (implicitReward β p q) p = 1 := by
    unfold partition
    rw [Finset.sum_congr rfl (fun y _ => hexp y), hq.2]
  unfold freeEnergy
  rw [hZ, Real.log_one, mul_zero]

omit [Nonempty Ω] in
/-- The expected implicit reward is exactly `β` times the KL penalty. -/
theorem expectation_implicitReward {β : ℝ} {p q : Ω → ℝ} :
    ∑ y, q y * implicitReward β p q y = β * klDiv q p := by
  unfold implicitReward klDiv
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl (fun y _ => by ring)

/-- **Convex conjugate.**  The KL penalty is the Legendre transform of the alignment value:
`β·KL(q ‖ p) = max_r ( 𝔼_q[r] − F(r) )`, attained at the DPO implicit reward. -/
theorem isGreatest_klPenalty {β : ℝ} {p q : Ω → ℝ} (hβ : 0 < β) (hp : IsPosDist p)
    (hq : IsPosDist q) :
    IsGreatest {v : ℝ | ∃ r : Ω → ℝ, v = (∑ y, q y * r y) - freeEnergy β r p}
      (β * klDiv q p) := by
  constructor
  · refine ⟨implicitReward β p q, ?_⟩
    rw [freeEnergy_implicitReward hβ hp hq, expectation_implicitReward]
    ring
  · rintro v ⟨r, rfl⟩
    have := fenchel_young (β := β) (r := r) hβ hp hq.isDist
    linarith

end RLHF