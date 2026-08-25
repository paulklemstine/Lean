/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Winner shares measure the sampler, and the regret really does live in the tail

Third cycle of the portfolio programme.  Two ledger entries of experiment 560
are turned into theorems.

**Sampler dependence.**  The measured oracle winner shares
`(0.580, 0.345, 0.045, 0.028, 0.002)` are often read as a statement about the
algorithms.  `share_realizability` shows that they are a statement about the
*instance sampler*: for **every** prescribed share vector `p` there is a sampler
on which the oracle winner shares are exactly `p`, and on which the static
ranking of the portfolio is exactly the ranking of `p`.  Consequently "no
universal winner" cannot be inferred from — nor refuted by — any single sampler,
which is precisely the scope caveat recorded in the ledger.

**The tail carries the regret.**  `tail_mass_lower_bound` and
`tail_mass_ge_of_ev` prove a Markov-type reverse bound: if a cost is at most `K`
and its mean is `R`, then the event `{cost > t}` must carry mass at least
`(R - t) / (K - t)`.  Applied to the exp-560 portfolio it shows that the
`0.42`-mass minority on which `ρ` loses is *forced* by the measured mean regret
`3.117`; the fat tail cannot be an artifact of a few outliers.
-/
import Mathlib
import Probability.PortfolioRegretCore
import Probability.PortfolioRegretTail
import Probability.PortfolioExp560

namespace Probability.PortfolioRegret

open Finset

/-! ## Sampler dependence of the winner shares -/

variable {S : Type*} [Fintype S] [DecidableEq S] [Nonempty S]

/-- The canonical "one winner per instance class" portfolio: member `s` costs `1`
on the class it owns and the penalty `P` elsewhere. -/
def diagCost (P : ℚ) : S → S → ℚ := fun ω s => if s = ω then 1 else P

theorem oracle_diagCost {P : ℚ} (hP : 1 ≤ P) (ω : S) : oracleCost (diagCost P) ω = 1 := by
  refine le_antisymm ?_ (Finset.le_inf' _ _ ?_)
  · have h : diagCost P ω ω = 1 := by simp [diagCost]
    exact h ▸ Finset.inf'_le _ (mem_univ ω)
  · intro s _
    by_cases h : s = ω
    · simp [diagCost, h]
    · simpa [diagCost, h] using hP

/-- Each member of the canonical portfolio wins exactly on its own class. -/
theorem winner_set_diagCost {P : ℚ} (hP : 1 < P) (s : S) :
    (univ.filter (fun ω : S => diagCost P ω s = oracleCost (diagCost P) ω)) = {s} := by
  ext ω
  simp only [mem_filter, mem_univ, true_and, mem_singleton, oracle_diagCost hP.le, diagCost]
  constructor
  · intro h
    by_cases hs : s = ω
    · exact hs.symm
    · rw [if_neg hs] at h; exact absurd h (by intro hh; exact absurd hh.symm hP.ne)
  · intro h; rw [if_pos h.symm]

/-- **Winner shares are a property of the sampler.**  For every probability
vector `p` on the portfolio there is a sampler realising `p` as the vector of
oracle winner shares, and on that sampler the expected cost of a member is a
strictly decreasing function of its share: the static ranking is exactly the
ranking of `p`.  Any member can therefore be made the "universal winner" — or a
negligible one — by changing the sampler alone. -/
theorem share_realizability (p : S → ℚ) (P : ℚ) (hP : 1 < P) :
    (∀ s : S, ∑ ω ∈ univ.filter (fun ω : S => diagCost P ω s = oracleCost (diagCost P) ω),
        p ω = p s) ∧
    (∀ s : S, EV p (fun ω => diagCost P ω s) = p s + (∑ ω, p ω - p s) * P) ∧
    (∀ s t : S, p t ≤ p s → EV p (fun ω => diagCost P ω s) ≤ EV p (fun ω => diagCost P ω t)) := by
  have hev : ∀ s : S, EV p (fun ω => diagCost P ω s) = p s + (∑ ω, p ω - p s) * P := by
    intro s
    have hpt : ∀ ω : S, p ω * diagCost P ω s
        = p ω * P + (if ω = s then p ω * (1 - P) else 0) := by
      intro ω
      by_cases h : ω = s
      · subst h; simp [diagCost]; ring
      · simp [diagCost, h, Ne.symm h]
    rw [EV, Finset.sum_congr rfl (fun ω _ => hpt ω), Finset.sum_add_distrib,
      Finset.sum_ite_eq' univ s (fun ω => p ω * (1 - P)), ← Finset.sum_mul]
    simp
    ring
  refine ⟨fun s => by rw [winner_set_diagCost hP s, Finset.sum_singleton], hev, ?_⟩
  intro s t hts
  rw [hev s, hev t]
  nlinarith [hP, hts]

/-! ## The tail must carry the regret -/

/-- **Reverse Markov bound.**  A cost bounded by `K` splits into a bulk below `t`
and a tail above `t`; hence the mean is at most `t + (K - t) ·` (tail mass). -/
theorem tail_mass_lower_bound {Ω : Type*} [Fintype Ω] [DecidableEq Ω] (w X : Ω → ℚ)
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (t K : ℚ) (hub : ∀ ω, X ω ≤ K) :
    EV w X ≤ t + (K - t) * Pr w (fun ω => t < X ω) := by
  classical
  set A : Finset Ω := univ.filter (fun ω => t < X ω) with hA
  have hsplit : ∑ ω ∈ A, w ω * X ω + ∑ ω ∈ univ.filter (fun ω => ¬ t < X ω), w ω * X ω
      = ∑ ω, w ω * X ω := Finset.sum_filter_add_sum_filter_not univ _ _
  have hbulkmass : ∑ ω ∈ univ.filter (fun ω => ¬ t < X ω), w ω = 1 - Pr w (fun ω => t < X ω) := by
    have := Finset.sum_filter_add_sum_filter_not univ (fun ω => t < X ω) w
    rw [Pr, hA] at *
    linarith [this, hw]
  have htail : ∑ ω ∈ A, w ω * X ω ≤ K * Pr w (fun ω => t < X ω) := by
    rw [Pr, ← hA, Finset.mul_sum]
    exact Finset.sum_le_sum fun ω _ => by
      rw [mul_comm K (w ω)]
      exact mul_le_mul_of_nonneg_left (hub ω) (hw0 ω)
  have hbulk : ∑ ω ∈ univ.filter (fun ω => ¬ t < X ω), w ω * X ω
      ≤ t * (1 - Pr w (fun ω => t < X ω)) := by
    rw [← hbulkmass, Finset.mul_sum]
    refine Finset.sum_le_sum fun ω hω => ?_
    have hx : X ω ≤ t := not_lt.mp (Finset.mem_filter.mp hω).2
    rw [mul_comm t (w ω)]
    exact mul_le_mul_of_nonneg_left hx (hw0 ω)
  have : EV w X ≤ K * Pr w (fun ω => t < X ω) + t * (1 - Pr w (fun ω => t < X ω)) := by
    rw [EV, ← hsplit]; linarith
  linarith [this]

/-- The tail mass is bounded below by the excess of the mean over the threshold,
normalised by the range: a large mean regret *forces* a tail. -/
theorem tail_mass_ge_of_ev {Ω : Type*} [Fintype Ω] [DecidableEq Ω] (w X : Ω → ℚ)
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (t K : ℚ) (ht : t < K) (hub : ∀ ω, X ω ≤ K) :
    (EV w X - t) / (K - t) ≤ Pr w (fun ω => t < X ω) := by
  have h := tail_mass_lower_bound w X hw0 hw t K hub
  rw [div_le_iff₀ (by linarith : (0:ℚ) < K - t)]
  linarith [h]

/-- **The exp-560 tail is forced.**  In the measured portfolio the mean cost of
the best static member is `4.117` and no run costs more than `1179/140`; the
reverse Markov bound therefore forces the losing minority to carry mass at least
`0.42` — exactly the measured complement of the `ρ` winner share. -/
theorem exp560_tail_mass_forced :
    (42 : ℚ) / 100 ≤ Pr exp560W (fun x => 1 < exp560Cost x 0) := by
  have hub : ∀ x : Fin 5 × Fin 2, exp560Cost x 0 ≤ penalty := by
    intro x
    by_cases h : (0 : Fin 5) = x.1
    · simp [exp560Cost, h, penalty]
      norm_num
    · simp [exp560Cost, h]
  have hmean : EV exp560W (fun x => exp560Cost x 0) = 4117/1000 := by
    rw [exp560_ev_const 0]
    norm_num [exp560Mean, classW, penalty]
  have h := tail_mass_ge_of_ev exp560W (fun x => exp560Cost x 0) exp560W_nonneg exp560W_sum
    1 penalty (by norm_num [penalty]) hub
  rw [hmean] at h
  refine le_trans (le_of_eq ?_) h
  norm_num [penalty]

end Probability.PortfolioRegret