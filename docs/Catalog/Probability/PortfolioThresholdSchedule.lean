/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Threshold schedules: monotone comparative statics for portfolio scheduling

Seventh cycle of the portfolio programme, closing direction 2 of
`FUTURE_DIRECTIONS.md` ("smoothness-quantile scheduling law").

The measured cell of experiment 560 is organised by a *single hidden scalar* — the
powersmoothness of `p - 1` — and the named next experiment buys a noisy view of
that scalar with a short-capped `p - 1` probe.  If the probe's output is ordered
(a smoothness quantile), one wants to know whether the optimal schedule is a
*threshold rule* in that one number rather than an unstructured policy.  This file
proves that it is, under the exact structural hypothesis that makes it true.

* `DecreasingDifferences` — the single-crossing hypothesis: raising the observed
  quantile never raises the *relative* cost of a later portfolio member.
* `leastArgmin_monotone` — **discrete Topkis theorem**: under decreasing
  differences the least fiberwise-optimal member is a monotone function of the
  observation.
* `exists_monotone_optimal_dial` — hence some *monotone* rule attains the optimal
  dial value `dialValue`: the optimal schedule is order-structured, and searching
  monotone rules loses nothing.
* `dial_fibers_ordConnected` — the instance set on which a given member is played
  is an interval of quantiles; `monotone_two_member_upward_closed` states the
  two-member case as a genuine threshold: the second member is played exactly on
  an upward-closed set of quantiles.
* `leastArgmin_not_monotone_without_dd` — the hypothesis is not decorative: an
  explicit `2 x 2` cost matrix without decreasing differences has a
  non-monotone (hence non-threshold) optimal schedule.

The results are stated for an arbitrary finite linearly ordered observation space
and finite linearly ordered portfolio, and then specialised to the fiber values
`fiberVal` of `Probability.PortfolioDialEdge`.
-/
import Mathlib
import Probability.PortfolioRegretCore
import Probability.PortfolioDialEdge

namespace Probability.PortfolioRegret

open Finset

variable {Ω O S : Type*}

/-! ## Least minimisers -/

open scoped Classical in
/-- The set of minimisers of `f`. -/
noncomputable def argminSet [Fintype S] (f : S → ℚ) : Finset S :=
  univ.filter (fun s => ∀ t, f s ≤ f t)

theorem mem_argminSet [Fintype S] {f : S → ℚ} {s : S} :
    s ∈ argminSet f ↔ ∀ t, f s ≤ f t := by
  classical
  simp [argminSet]

theorem argminSet_nonempty [Fintype S] [Nonempty S] (f : S → ℚ) : (argminSet f).Nonempty := by
  obtain ⟨s, -, hs⟩ := Finset.exists_min_image (univ : Finset S) f univ_nonempty
  exact ⟨s, mem_argminSet.mpr fun t => hs t (mem_univ t)⟩

/-- The smallest minimiser of `f` — the canonical tie-breaking choice. -/
noncomputable def leastArgmin [Fintype S] [LinearOrder S] [Nonempty S] (f : S → ℚ) : S :=
  (argminSet f).min' (argminSet_nonempty f)

theorem leastArgmin_le [Fintype S] [LinearOrder S] [Nonempty S] (f : S → ℚ) (t : S) :
    f (leastArgmin f) ≤ f t :=
  mem_argminSet.mp ((argminSet f).min'_mem (argminSet_nonempty f)) t

theorem leastArgmin_min [Fintype S] [LinearOrder S] [Nonempty S] {f : S → ℚ} {s : S}
    (hs : ∀ t, f s ≤ f t) : leastArgmin f ≤ s :=
  (argminSet f).min'_le s (mem_argminSet.mpr hs)

/-- The least minimiser attains the infimum. -/
theorem f_leastArgmin_eq_inf' [Fintype S] [LinearOrder S] [Nonempty S] (f : S → ℚ) :
    f (leastArgmin f) = univ.inf' univ_nonempty f :=
  le_antisymm (Finset.le_inf' _ _ fun t _ => leastArgmin_le f t)
    (Finset.inf'_le _ (mem_univ _))

/-! ## Discrete Topkis: monotone comparative statics -/

/-- **Single crossing / decreasing differences.**  Moving to a higher observation
never increases the cost of a later member *relative* to an earlier one: the
observation and the portfolio index are complements. -/
def DecreasingDifferences [Preorder O] [Preorder S] (f : O → S → ℚ) : Prop :=
  ∀ ⦃o o' : O⦄, o ≤ o' → ∀ ⦃s s' : S⦄, s ≤ s' → f o' s' - f o' s ≤ f o s' - f o s

/-- **Discrete Topkis theorem.**  Under decreasing differences the least optimal
member is a monotone function of the observation. -/
theorem leastArgmin_monotone [Fintype S] [LinearOrder S] [Nonempty S] [Preorder O]
    {f : O → S → ℚ} (hdd : DecreasingDifferences f) :
    Monotone (fun o => leastArgmin (f o)) := by
  intro o o' hoo
  by_contra hcon
  push_neg at hcon
  set s := leastArgmin (f o) with hs
  set t := leastArgmin (f o') with ht
  have hts : t ≤ s := le_of_lt hcon
  have hkey : f o' s - f o' t ≤ f o s - f o t := hdd hoo hts
  have h1 : f o s ≤ f o t := leastArgmin_le (f o) t
  have h2 : f o' t ≤ f o' s := leastArgmin_le (f o') s
  have h3 : f o s = f o t := le_antisymm h1 (by linarith)
  have hmin : ∀ u, f o t ≤ f o u := fun u => h3 ▸ leastArgmin_le (f o) u
  exact absurd (leastArgmin_min hmin) (not_le.mpr hcon)

/-! ## Monotone (threshold) schedules are optimal -/

/-- The canonical fiberwise-optimal rule: on each fiber play the least optimal
member. -/
noncomputable def leastDial [Fintype Ω] [DecidableEq O] [Fintype S] [LinearOrder S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (o : O) : S :=
  leastArgmin (fiberVal w cost obs o)

theorem leastDial_attains [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [LinearOrder S]
    [Nonempty S] (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) :
    EV w (policyCost cost obs (leastDial w cost obs)) = dialValue w cost obs := by
  rw [ev_policy_eq_sum_fiberVal, dialValue]
  exact Finset.sum_congr rfl fun o _ => f_leastArgmin_eq_inf' (fiberVal w cost obs o)

/-- **Threshold optimality.**  If the conditional costs have decreasing differences
in (observation, member) — the single-crossing property of an ordered quantile
observation — then a *monotone* rule attains the optimal dial value.  Scheduling on
an ordered probe therefore reduces to a threshold search. -/
theorem exists_monotone_optimal_dial [Fintype Ω] [Fintype O] [LinearOrder O] [DecidableEq O]
    [Fintype S] [LinearOrder S] [Nonempty S] (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O)
    (hdd : DecreasingDifferences (fiberVal w cost obs)) :
    ∃ π : O → S, Monotone π ∧ EV w (policyCost cost obs π) = dialValue w cost obs :=
  ⟨leastDial w cost obs, leastArgmin_monotone hdd, leastDial_attains w cost obs⟩

/-- The set of quantiles on which a monotone optimal rule plays a fixed member is an
interval: schedules are *interval rules* in the observed scalar. -/
theorem dial_fibers_ordConnected [Fintype Ω] [Fintype O] [LinearOrder O] [DecidableEq O]
    [Fintype S] [LinearOrder S] [Nonempty S] (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O)
    (hdd : DecreasingDifferences (fiberVal w cost obs)) (s : S) {o₁ o o₂ : O}
    (h1 : o₁ ≤ o) (h2 : o ≤ o₂) (hs₁ : leastDial w cost obs o₁ = s)
    (hs₂ : leastDial w cost obs o₂ = s) :
    leastDial w cost obs o = s := by
  have hmono := leastArgmin_monotone (f := fiberVal w cost obs) hdd
  have hle : leastDial w cost obs o ≤ s := hs₂ ▸ hmono h2
  have hge : s ≤ leastDial w cost obs o := hs₁ ▸ hmono h1
  exact le_antisymm hle hge

/-- For a two-member portfolio a monotone rule is literally a threshold rule: the
second member is played exactly on an upward-closed set of quantiles. -/
theorem monotone_two_member_upward_closed [Preorder O] {π : O → Fin 2} (hπ : Monotone π)
    {o o' : O} (hoo : o ≤ o') (h : π o = 1) : π o' = 1 := by
  have := hπ hoo
  rw [h] at this
  omega

/-! ## The hypothesis is necessary -/

/-- Two quantiles, two members, *without* decreasing differences. -/
def crossCost : Fin 2 → Fin 2 → ℚ := fun o s => if (s : ℕ) = (o : ℕ) then 1 else 0

/-- **Necessity of single crossing.**  This cost matrix violates decreasing
differences, and its fiberwise-optimal schedule is not monotone — hence not a
threshold rule in the observed quantile.  Ordered observations alone do not make
schedules ordered. -/
theorem leastArgmin_not_monotone_without_dd :
    ¬ DecreasingDifferences crossCost ∧
      ¬ Monotone (fun o => leastArgmin (crossCost o)) := by
  have h0 : leastArgmin (crossCost 0) = 1 := by
    have hmin : ∀ t, crossCost 0 1 ≤ crossCost 0 t := by
      intro t; fin_cases t <;> norm_num [crossCost]
    have hle : leastArgmin (crossCost 0) ≤ 1 := leastArgmin_min hmin
    have hne : leastArgmin (crossCost 0) ≠ 0 := by
      intro h
      have := leastArgmin_le (crossCost 0) 1
      rw [h] at this
      norm_num [crossCost] at this
    omega
  have h1 : leastArgmin (crossCost 1) = 0 := by
    have hmin : ∀ t, crossCost 1 0 ≤ crossCost 1 t := by
      intro t; fin_cases t <;> norm_num [crossCost]
    exact le_antisymm (leastArgmin_min hmin) (Fin.zero_le _)
  constructor
  · intro hdd
    have := hdd (show (0 : Fin 2) ≤ 1 by omega) (show (0 : Fin 2) ≤ 1 by omega)
    norm_num [crossCost] at this
  · intro hmono
    have := hmono (show (0 : Fin 2) ≤ 1 by omega)
    simp only [h0, h1] at this
    omega

end Probability.PortfolioRegret