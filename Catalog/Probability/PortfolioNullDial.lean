/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# What a null dial measurement actually certifies

Sixth cycle of the portfolio programme.  `Probability.PortfolioRegretCore` proves
that an *invisible* observation gives no scheduling edge (`no_dial_edge`), and
`Probability.PortfolioEpsInvisible` makes that quantitative and shows that the
naive converse fails: a measured dial gain of `0` does **not** imply that the
observation is `ε`-invisible.  The obvious question left open by that cycle is
what a null measurement *does* certify.  This file answers it exactly.

Main results.

* `fiberRegret_eq`, `gap_eq_inf_fiberRegret` — the dial gain
  `bestConstant - dialValue` equals the *smallest fiberwise regret* of a member,
  `min_s ∑_o (fiberVal o s - min_t fiberVal o t)`.  The scheduling gap is thus an
  exact optimisation over members, not merely bounded by one.
* `gap_zero_iff_exists_fiberwise_optimal` — **the correct converse.**  The dial
  gain vanishes **iff** some single member minimises the conditional cost on
  *every* fiber.  So the measured `Δ = 0.000` certifies exactly a fiberwise
  champion; it certifies neither invisibility of the observation nor absence of
  member-discriminating information.  (Direction 1 of `FUTURE_DIRECTIONS.md`,
  answered in the corrected — centred, i.e. difference-based — form.)
* `min_sum_sub_sum_min`, `two_member_gap` — for a two-member portfolio the gain
  is *exactly* `min` of the two **swap masses** `∑_o (fiberVal o s - fiberVal o t)^+`:
  a dial earns precisely the smaller of the two directions in which the members
  trade places, and `two_member_dial_edge_iff` turns this into a decidable test.
* `swap_hidden_by_third_member` — the pair certificate is *not* visible at the
  portfolio level: an explicit three-member portfolio has gain exactly `0` while
  two of its members swap with positive mass on the fibers.  A null dial hides
  arbitrarily much pairwise structure behind a dominating third member.
* `dialValueOn_erase_of_fiberwise_dominates`,
  `bestConstantOn_erase_of_fiberwise_dominates` — **fiberwise dominance is an
  elimination certificate**: deleting a member that is beaten on every fiber
  changes neither the optimal dial value nor the best static value.  This is the
  safe middle rung between the pointwise test of
  `Probability.PortfolioElimination` and the unsafe mean comparison refuted there.

Everything is finite and rational.
-/
import Mathlib
import Probability.PortfolioRegretCore
import Probability.PortfolioDialEdge
import Probability.PortfolioEpsInvisible

namespace Probability.PortfolioRegret

open Finset

variable {Ω O S : Type*}

/-! ## The dial gain as an optimisation over members -/

/-- The **fiberwise regret** of member `s`: the total amount by which `s` is beaten
by the fiberwise best member, summed over the fibers of the observation. -/
noncomputable def fiberRegret [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (s : S) : ℚ :=
  ∑ o, (fiberVal w cost obs o s - univ.inf' univ_nonempty (fiberVal w cost obs o))

theorem fiberRegret_nonneg [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (s : S) : 0 ≤ fiberRegret w cost obs s :=
  Finset.sum_nonneg fun _ _ => sub_nonneg.2 (Finset.inf'_le _ (mem_univ s))

/-- The fiberwise regret of `s` is its static cost minus the optimal dial value. -/
theorem fiberRegret_eq [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (s : S) :
    fiberRegret w cost obs s = EV w (fun ω => cost ω s) - dialValue w cost obs := by
  rw [fiberRegret, ev_const_eq_sum_fiberVal w cost obs s, dialValue, ← Finset.sum_sub_distrib]

/-- **The dial gain is an optimisation over members.**  The amount an optimised
observation-measurable rule wins over the best static member equals the smallest
fiberwise regret in the portfolio. -/
theorem gap_eq_inf_fiberRegret [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) :
    bestConstant w cost - dialValue w cost obs
      = univ.inf' univ_nonempty (fiberRegret w cost obs) := by
  obtain ⟨s₀, -, hs₀⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S))
    (fun s => EV w (fun ω => cost ω s))
  obtain ⟨s₁, -, hs₁⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S))
    (fiberRegret w cost obs)
  have hb : bestConstant w cost = EV w (fun ω => cost ω s₀) := hs₀
  refine le_antisymm ?_ ?_
  · rw [hs₁, fiberRegret_eq]
    have : bestConstant w cost ≤ EV w (fun ω => cost ω s₁) := Finset.inf'_le _ (mem_univ s₁)
    linarith
  · have h1 : univ.inf' univ_nonempty (fiberRegret w cost obs) ≤ fiberRegret w cost obs s₀ :=
      Finset.inf'_le _ (mem_univ s₀)
    rw [fiberRegret_eq] at h1
    linarith [hb]

/-- **The correct converse of `no_dial_edge`.**  An optimised dial gains nothing
if and only if some *single* member minimises the conditional cost on every fiber
of the observation.  A measured `Δ = 0.000` therefore certifies the existence of a
fiberwise champion — and nothing more; in particular it does not certify that the
observation carries no information (see `gap_zero_not_epsInvisible`). -/
theorem gap_zero_iff_exists_fiberwise_optimal [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S] (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) :
    dialValue w cost obs = bestConstant w cost ↔
      ∃ s : S, ∀ o : O, fiberVal w cost obs o s = univ.inf' univ_nonempty (fiberVal w cost obs o) := by
  constructor
  · intro h
    obtain ⟨s, -, hs⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S))
      (fiberRegret w cost obs)
    have hzero : fiberRegret w cost obs s = 0 := by
      have hgap := gap_eq_inf_fiberRegret w cost obs
      rw [hs] at hgap
      linarith [hgap, h]
    refine ⟨s, fun o => ?_⟩
    have hnn : ∀ o ∈ (univ : Finset O),
        0 ≤ fiberVal w cost obs o s - univ.inf' univ_nonempty (fiberVal w cost obs o) :=
      fun o _ => sub_nonneg.2 (Finset.inf'_le _ (mem_univ s))
    have := (Finset.sum_eq_zero_iff_of_nonneg hnn).mp hzero o (mem_univ o)
    linarith
  · rintro ⟨s, hs⟩
    have hzero : fiberRegret w cost obs s = 0 := by
      rw [fiberRegret]
      exact Finset.sum_eq_zero fun o _ => by rw [hs o]; ring
    have hle : univ.inf' univ_nonempty (fiberRegret w cost obs) ≤ 0 := by
      rw [← hzero]; exact Finset.inf'_le _ (mem_univ s)
    have hge : (0 : ℚ) ≤ univ.inf' univ_nonempty (fiberRegret w cost obs) :=
      Finset.le_inf' _ _ fun t _ => fiberRegret_nonneg w cost obs t
    have := gap_eq_inf_fiberRegret w cost obs
    linarith

/-! ## Two members: the gain is the smaller swap mass -/

/-- The **swap mass** of `f` over `g`: the total excess of `f` on the fibers where
`f` loses. -/
def swapMassFun [Fintype O] (f g : O → ℚ) : ℚ := ∑ o, max (f o - g o) 0

theorem swapMassFun_nonneg [Fintype O] (f g : O → ℚ) : 0 ≤ swapMassFun f g :=
  Finset.sum_nonneg fun _ _ => le_max_right _ _

theorem sum_sub_sum_min [Fintype O] (f g : O → ℚ) :
    (∑ o, f o) - ∑ o, min (f o) (g o) = swapMassFun f g := by
  rw [swapMassFun, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun o _ => ?_
  rcases le_total (f o) (g o) with h | h
  · rw [min_eq_left h, max_eq_right (by linarith)]; ring
  · rw [min_eq_right h, max_eq_left (by linarith)]

/-- **Exact two-member gain.**  For two cost profiles on the fibers, the gain of the
fiberwise minimum over the better of the two totals is exactly the smaller of the
two swap masses. -/
theorem min_sum_sub_sum_min [Fintype O] (f g : O → ℚ) :
    min (∑ o, f o) (∑ o, g o) - ∑ o, min (f o) (g o)
      = min (swapMassFun f g) (swapMassFun g f) := by
  have hf := sum_sub_sum_min f g
  have hg := sum_sub_sum_min g f
  have hmin : ∀ o, min (g o) (f o) = min (f o) (g o) := fun o => min_comm _ _
  rw [Finset.sum_congr rfl (fun o _ => hmin o)] at hg
  rcases le_total (∑ o, f o) (∑ o, g o) with h | h
  · rw [min_eq_left h, min_eq_left (by linarith)]
    linarith
  · rw [min_eq_right h, min_eq_right (by linarith)]
    linarith

theorem inf'_fin_two (f : Fin 2 → ℚ) :
    (univ : Finset (Fin 2)).inf' univ_nonempty f = min (f 0) (f 1) := by
  refine le_antisymm (le_min (Finset.inf'_le _ (mem_univ 0)) (Finset.inf'_le _ (mem_univ 1))) ?_
  refine Finset.le_inf' _ _ fun s _ => ?_
  fin_cases s
  · exact min_le_left _ _
  · exact min_le_right _ _

theorem inf'_fin_three (f : Fin 3 → ℚ) :
    (univ : Finset (Fin 3)).inf' univ_nonempty f = min (f 0) (min (f 1) (f 2)) := by
  refine le_antisymm (le_min (Finset.inf'_le _ (mem_univ 0))
    (le_min (Finset.inf'_le _ (mem_univ 1)) (Finset.inf'_le _ (mem_univ 2)))) ?_
  refine Finset.le_inf' _ _ fun s _ => ?_
  fin_cases s
  · exact min_le_left _ _
  · exact le_trans (min_le_right _ _) (min_le_left _ _)
  · exact le_trans (min_le_right _ _) (min_le_right _ _)

/-- **The two-member scheduling gain, exactly.**  For a portfolio of two members
the dial gain equals the smaller of the two swap masses of their conditional
costs. -/
theorem two_member_gap [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (cost : Ω → Fin 2 → ℚ) (obs : Ω → O) :
    bestConstant w cost - dialValue w cost obs
      = min (swapMassFun (fun o => fiberVal w cost obs o 0) (fun o => fiberVal w cost obs o 1))
            (swapMassFun (fun o => fiberVal w cost obs o 1) (fun o => fiberVal w cost obs o 0)) := by
  have hb : bestConstant w cost
      = min (∑ o, fiberVal w cost obs o 0) (∑ o, fiberVal w cost obs o 1) := by
    rw [bestConstant, inf'_fin_two, ev_const_eq_sum_fiberVal w cost obs 0,
      ev_const_eq_sum_fiberVal w cost obs 1]
  have hd : dialValue w cost obs
      = ∑ o, min (fiberVal w cost obs o 0) (fiberVal w cost obs o 1) := by
    rw [dialValue]
    exact Finset.sum_congr rfl fun o _ => inf'_fin_two _
  rw [hb, hd]
  exact min_sum_sub_sum_min _ _

/-- A decidable test for a two-member dial edge: the dial helps iff *both* swap
masses are positive, i.e. iff each member is strictly beaten somewhere. -/
theorem two_member_dial_edge_iff [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (cost : Ω → Fin 2 → ℚ) (obs : Ω → O) :
    dialValue w cost obs < bestConstant w cost ↔
      0 < swapMassFun (fun o => fiberVal w cost obs o 0) (fun o => fiberVal w cost obs o 1) ∧
        0 < swapMassFun (fun o => fiberVal w cost obs o 1) (fun o => fiberVal w cost obs o 0) := by
  have h := two_member_gap w cost obs
  constructor
  · intro hlt
    have : 0 < min
        (swapMassFun (fun o => fiberVal w cost obs o 0) (fun o => fiberVal w cost obs o 1))
        (swapMassFun (fun o => fiberVal w cost obs o 1) (fun o => fiberVal w cost obs o 0)) := by
      linarith
    exact lt_min_iff.mp this
  · rintro ⟨h0, h1⟩
    have : 0 < min
        (swapMassFun (fun o => fiberVal w cost obs o 0) (fun o => fiberVal w cost obs o 1))
        (swapMassFun (fun o => fiberVal w cost obs o 1) (fun o => fiberVal w cost obs o 0)) :=
      lt_min_iff.mpr ⟨h0, h1⟩
    linarith

/-! ## A null dial hides pairwise structure -/

/-- Uniform weights on two instances. -/
def swapW : Fin 2 → ℚ := fun _ => 1/2

/-- Three members on two instances: members `0` and `1` trade places (each costing
`1` on its own instance and `3` on the other), while member `2` costs `0` on both
and hence dominates them. -/
def swapCost : Fin 2 → Fin 3 → ℚ :=
  fun o s => if s = 2 then 0 else if (s : ℕ) = (o : ℕ) then 1 else 3

theorem fiberVal_swap (o : Fin 2) (s : Fin 3) :
    fiberVal swapW swapCost id o s = swapW o * swapCost o s :=
  fiberVal_id swapW swapCost o s

/-- **The pair certificate is invisible at the portfolio level.**  This explicit
three-member portfolio has dial gain exactly `0` — so by
`gap_zero_iff_exists_fiberwise_optimal` a fiberwise champion exists — and yet its
first two members swap places with swap mass `1` in *both* directions.  A measured
null dial therefore says nothing about the pairwise structure of the losing
members: arbitrarily much of it can hide behind one dominating member. -/
theorem swap_hidden_by_third_member :
    dialValue swapW swapCost id = bestConstant swapW swapCost ∧
      swapMassFun (fun o => fiberVal swapW swapCost id o 0)
          (fun o => fiberVal swapW swapCost id o 1) = 1 ∧
      swapMassFun (fun o => fiberVal swapW swapCost id o 1)
          (fun o => fiberVal swapW swapCost id o 0) = 1 := by
  have hv : ∀ o s, fiberVal swapW swapCost id o s = swapW o * swapCost o s := fiberVal_swap
  refine ⟨?_, ?_, ?_⟩
  · rw [gap_zero_iff_exists_fiberwise_optimal]
    refine ⟨2, fun o => ?_⟩
    rw [inf'_fin_three, hv o 0, hv o 1, hv o 2]
    fin_cases o <;> norm_num [swapW, swapCost, Fin.ext_iff]
  · rw [swapMassFun, Fin.sum_univ_two, hv 0 0, hv 0 1, hv 1 0, hv 1 1]
    norm_num [swapW, swapCost, Fin.ext_iff]
  · rw [swapMassFun, Fin.sum_univ_two, hv 0 0, hv 0 1, hv 1 0, hv 1 1]
    norm_num [swapW, swapCost, Fin.ext_iff]

/-! ## Fiberwise dominance is an elimination certificate -/

/-- Optimal dial value of the sub-portfolio `T`. -/
noncomputable def dialValueOn [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (T : Finset S) (hT : T.Nonempty) : ℚ :=
  ∑ o, T.inf' hT (fiberVal w cost obs o)

/-- Best static value of the sub-portfolio `T`. -/
noncomputable def bestConstantOn [Fintype Ω] (w : Ω → ℚ) (cost : Ω → S → ℚ)
    (T : Finset S) (hT : T.Nonempty) : ℚ :=
  T.inf' hT (fun s => EV w (fun ω => cost ω s))

/-- Deleting an element that is weakly beaten by a surviving element does not change
an infimum. -/
theorem inf'_erase_of_le [DecidableEq S] {T : Finset S} {a b : S} (f : S → ℚ)
    (ha : a ∈ T.erase b) (hab : f a ≤ f b) (hT : T.Nonempty) :
    (T.erase b).inf' ⟨a, ha⟩ f = T.inf' hT f := by
  refine le_antisymm ?_ (Finset.le_inf' _ _ fun s hs => Finset.inf'_le _ (Finset.mem_of_mem_erase hs))
  refine Finset.le_inf' _ _ fun s hs => ?_
  by_cases hsb : s = b
  · subst hsb
    exact le_trans (Finset.inf'_le _ ha) hab
  · exact Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hsb, hs⟩)

/-- **Fiberwise dominance preserves the optimal dial value.**  If `a` is at least as
cheap as `b` on every fiber, deleting `b` costs nothing to any observation-measurable
schedule. -/
theorem dialValueOn_erase_of_fiberwise_dominates [Fintype Ω] [Fintype O] [DecidableEq O]
    [DecidableEq S] {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {T : Finset S} {a b : S}
    (ha : a ∈ T.erase b) (hT : T.Nonempty)
    (hdom : ∀ o, fiberVal w cost obs o a ≤ fiberVal w cost obs o b) :
    dialValueOn w cost obs (T.erase b) ⟨a, ha⟩ = dialValueOn w cost obs T hT := by
  refine Finset.sum_congr rfl fun o _ => ?_
  exact inf'_erase_of_le (fiberVal w cost obs o) ha (hdom o) hT

/-- **Fiberwise dominance preserves the best static value.** -/
theorem bestConstantOn_erase_of_fiberwise_dominates [Fintype Ω] [Fintype O] [DecidableEq O]
    [DecidableEq S] {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {T : Finset S} {a b : S}
    (ha : a ∈ T.erase b) (hT : T.Nonempty)
    (hdom : ∀ o, fiberVal w cost obs o a ≤ fiberVal w cost obs o b) :
    bestConstantOn w cost (T.erase b) ⟨a, ha⟩ = bestConstantOn w cost T hT := by
  have hev : EV w (fun ω => cost ω a) ≤ EV w (fun ω => cost ω b) := by
    rw [ev_const_eq_sum_fiberVal w cost obs a, ev_const_eq_sum_fiberVal w cost obs b]
    exact Finset.sum_le_sum fun o _ => hdom o
  exact inf'_erase_of_le _ ha hev hT

/-- Consequently the whole information ladder of the sub-portfolio is unchanged by a
fiberwise-dominated deletion: both rungs move together. -/
theorem gap_erase_of_fiberwise_dominates [Fintype Ω] [Fintype O] [DecidableEq O]
    [DecidableEq S] {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {T : Finset S} {a b : S}
    (ha : a ∈ T.erase b) (hT : T.Nonempty)
    (hdom : ∀ o, fiberVal w cost obs o a ≤ fiberVal w cost obs o b) :
    bestConstantOn w cost (T.erase b) ⟨a, ha⟩ - dialValueOn w cost obs (T.erase b) ⟨a, ha⟩
      = bestConstantOn w cost T hT - dialValueOn w cost obs T hT := by
  rw [bestConstantOn_erase_of_fiberwise_dominates ha hT hdom,
    dialValueOn_erase_of_fiberwise_dominates ha hT hdom]

end Probability.PortfolioRegret