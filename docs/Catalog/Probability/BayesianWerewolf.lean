import Mathlib

/-!
# Bayesian one-step decisions in Werewolf

This file isolates the part of Bayesian Werewolf that is independent of a particular
behavioural and information model.  A player's unnormalised posterior score is the
product of their prior and the likelihood of the observed evidence.  The main result
proves that eliminating a player of maximal score is optimal for the one-step objective
of eliminating a werewolf.  A second result shows that randomisation cannot improve
this objective.

These are deliberately one-step theorems: maximizing the chance of today's correct
elimination need not maximize the probability of eventually winning a dynamic game
when actions also affect future information.
-/

namespace BayesianWerewolf

/-- The unnormalised Bayesian score of player `i`. -/
def score {ι : Type*} (prior likelihood : ι → ℝ) (i : ι) : ℝ :=
  prior i * likelihood i

/-- The posterior distribution obtained by normalising Bayesian scores on a finite type. -/
noncomputable def posterior {ι : Type*} [Fintype ι] (prior likelihood : ι → ℝ) (i : ι) : ℝ :=
  score prior likelihood i / ∑ j, score prior likelihood j

/-- Normalised Bayesian scores sum to one whenever their normalising constant is nonzero. -/
theorem sum_posterior_eq_one {ι : Type*} [Fintype ι]
    (prior likelihood : ι → ℝ)
    (hZ : (∑ j, score prior likelihood j) ≠ 0) :
    ∑ i, posterior prior likelihood i = 1 := by
  simp only [posterior, score] at hZ ⊢
  rw [← Finset.sum_div, div_self hZ]

/-- A maximum-score player also has maximum posterior probability. -/
theorem posterior_le_of_score_le {ι : Type*} [Fintype ι]
    (prior likelihood : ι → ℝ) (m i : ι)
    (hZ : 0 < ∑ j, score prior likelihood j)
    (hmax : score prior likelihood i ≤ score prior likelihood m) :
    posterior prior likelihood i ≤ posterior prior likelihood m := by
  simp [posterior]
  exact div_le_div_of_nonneg_right hmax (le_of_lt hZ)

/--
**One-step MAP optimality.** If `m` has maximal Bayesian score, then every randomized
elimination rule `q` has success probability at most that of deterministically choosing
`m`. Here `q` is any probability mass function on the players.
-/
theorem map_elimination_optimal {ι : Type*} [Fintype ι]
    (prior likelihood q : ι → ℝ) (m : ι)
    (hZ : 0 < ∑ j, score prior likelihood j)
    (hq0 : ∀ i, 0 ≤ q i) (hq1 : ∑ i, q i = 1)
    (hmax : ∀ i, score prior likelihood i ≤ score prior likelihood m) :
    (∑ i, q i * posterior prior likelihood i) ≤ posterior prior likelihood m := by
  have hle : ∀ i, q i * posterior prior likelihood i ≤ q i * posterior prior likelihood m := by
    intro i
    apply mul_le_mul_of_nonneg_left (posterior_le_of_score_le prior likelihood m i hZ (hmax i)) (hq0 i)
  calc ∑ i, q i * posterior prior likelihood i
      ≤ ∑ i, q i * posterior prior likelihood m := Finset.sum_le_sum fun i _ => hle i
    _ = ∑ i, posterior prior likelihood m * q i := Finset.sum_congr rfl fun _ _ => mul_comm _ _
    _ = posterior prior likelihood m * ∑ i, q i := by rw [Finset.mul_sum]
    _ = posterior prior likelihood m * 1 := by rw [hq1]
    _ = posterior prior likelihood m := by ring

/-- With a common prior, likelihood ordering and posterior ordering coincide. -/
theorem uniform_prior_posterior_order {ι : Type*} [Fintype ι]
    (c : ℝ) (likelihood : ι → ℝ) (m i : ι)
    (hc : 0 ≤ c)
    (hZ : 0 < ∑ j, score (fun _ => c) likelihood j)
    (h : likelihood i ≤ likelihood m) :
    posterior (fun _ => c) likelihood i ≤ posterior (fun _ => c) likelihood m := by
  unfold posterior
  simp_rw [score]
  apply div_le_div_of_nonneg_right
  · exact mul_le_mul_of_nonneg_left h hc
  · exact le_of_lt (by simpa [score] using hZ)

/--
Under uniform random elimination, the probability of selecting a werewolf is exactly
`k / n` when the werewolf set has size `k` among `n` players.
-/
theorem uniform_elimination_success {ι : Type*} [Fintype ι] [DecidableEq ι]
    (wolves : Finset ι) :
    (∑ i, if i ∈ wolves then (1 / Fintype.card ι : ℝ) else 0) =
      (wolves.card : ℝ) / Fintype.card ι := by
  rw [Finset.sum_ite]
  simp [div_eq_mul_inv]

/-- For the proposed scaling expression, the case `n = 7`, `k = 2`, `C = 1` is exactly `0.36`. -/
theorem proposed_scaling_seven_two :
    (1 - (2 : ℚ) / (7 - 2)) ^ 2 = 9 / 25 := by
  norm_num

/-- The proposed scaling factor vanishes at the parity threshold `n = 2k`. -/
theorem proposed_scaling_at_parity (k : ℝ) (hk : k ≠ 0) :
    (1 - k / ((2 * k) - k)) ^ 2 = 0 := by
  field_simp
  ring

end BayesianWerewolf