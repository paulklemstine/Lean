/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Irredundancy does not rescue the pairwise certificate

Eighth cycle of the portfolio programme.  `Probability.PortfolioNullDial` shows
that the portfolio-level dial gain can be `0` while two members swap places with
positive mass, the swap being hidden by a third member that is optimal on every
fiber.  The natural repair — and the first conjecture recorded in the previous
cycle's `FUTURE_DIRECTIONS.md` — is to delete such dominating structure first: on
an **irredundant** portfolio (no member weakly beats another on *every* fiber, so
nothing can be eliminated by the proved fiberwise rule) one might hope that the
measured gain controls all pairwise swap masses, up to a constant depending only
on the number of members.

This file **refutes** that hope, for every constant and already with three
members:

* `IrredundantPortfolio` — no member fiberwise dominates another;
* `irred_portfolio_irredundant` — the explicit family `irredCost e` (three
  instances, each its own fiber, uniform weights) is irredundant for `0 < e`;
* `irred_gap`, `irred_swapMass` — its dial gain is exactly `2e/3` while the swap
  masses of its first two members are exactly `10/3` in both directions;
* `swap_unbounded_on_irredundant` — hence for **every** ratio `M` there is an
  irredundant three-member portfolio whose pairwise swap mass exceeds `M` times
  its dial gain.  No constant, and no function of the number of members, can
  bound pairwise swaps by the measured gain.

The moral for the measured cell: a small scheduling gain is compatible with
arbitrarily large pairwise trade-offs even after every eliminable member has been
removed, so pairwise structure must be measured pair by pair
(`two_member_gap`), never inferred from the portfolio-level dial.
-/
import Mathlib
import Probability.PortfolioRegretCore
import Probability.PortfolioDialEdge
import Probability.PortfolioEpsInvisible
import Probability.PortfolioNullDial

namespace Probability.PortfolioRegret

open Finset

variable {Ω O S : Type*}

/-- A portfolio is **irredundant** for the observation `obs` when no member is
weakly beaten by another on every fiber — i.e. when the fiberwise elimination rule
`dialValueOn_erase_of_fiberwise_dominates` applies to no pair. -/
def IrredundantPortfolio [Fintype Ω] [DecidableEq O] (w : Ω → ℚ) (cost : Ω → S → ℚ)
    (obs : Ω → O) : Prop :=
  ∀ s t : S, s ≠ t → ∃ o : O, fiberVal w cost obs o t < fiberVal w cost obs o s

/-- Uniform weights on three instances. -/
def irredW : Fin 3 → ℚ := fun _ => 1/3

/-- Three instances (each its own fiber) and three members.  Members `0` and `1`
trade places on the first two fibers and are both bad on the third; member `2` is
cheap (`e`) on the first two fibers and free on the third, but never *dominates*,
because `e > 0` while members `0`, `1` are free on their own fiber. -/
def irredCost (e : ℚ) : Fin 3 → Fin 3 → ℚ := fun o s =>
  if (s : ℕ) = 2 then (if (o : ℕ) = 2 then 0 else e)
  else if (o : ℕ) = 2 then 10
  else if (s : ℕ) = (o : ℕ) then 0 else 10

theorem fiberVal_irred (e : ℚ) (o s : Fin 3) :
    fiberVal irredW (irredCost e) id o s = irredW o * irredCost e o s :=
  fiberVal_id irredW (irredCost e) o s

theorem irredW_nonneg (o : Fin 3) : 0 ≤ irredW o := by norm_num [irredW]

theorem sum_irredW : ∑ o, irredW o = 1 := by
  norm_num [irredW, Fin.sum_univ_three]

/-- For `0 < e` the portfolio is irredundant: no member fiberwise dominates
another, so nothing can be deleted by the proved elimination rule. -/
theorem irred_portfolio_irredundant {e : ℚ} (he : 0 < e) :
    IrredundantPortfolio irredW (irredCost e) id := by
  have hv : ∀ o s, fiberVal irredW (irredCost e) id o s = irredW o * irredCost e o s :=
    fiberVal_irred e
  intro s t hst
  fin_cases s <;> fin_cases t
  · exact absurd rfl hst
  · exact ⟨1, by rw [hv, hv]; norm_num [irredW, irredCost, Fin.ext_iff]⟩
  · exact ⟨2, by rw [hv, hv]; norm_num [irredW, irredCost, Fin.ext_iff]⟩
  · exact ⟨0, by rw [hv, hv]; norm_num [irredW, irredCost, Fin.ext_iff]⟩
  · exact absurd rfl hst
  · exact ⟨2, by rw [hv, hv]; norm_num [irredW, irredCost, Fin.ext_iff]⟩
  · exact ⟨0, by rw [hv, hv]; norm_num [irredW, irredCost, Fin.ext_iff]; linarith⟩
  · exact ⟨1, by rw [hv, hv]; norm_num [irredW, irredCost, Fin.ext_iff]; linarith⟩
  · exact absurd rfl hst

theorem irred_dialValue {e : ℚ} (he : 0 < e) :
    dialValue irredW (irredCost e) id = 0 := by
  have hv : ∀ o s, fiberVal irredW (irredCost e) id o s = irredW o * irredCost e o s :=
    fiberVal_irred e
  have h0 : univ.inf' univ_nonempty (fiberVal irredW (irredCost e) id 0) = 0 := by
    rw [inf'_fin_three, hv 0 0, hv 0 1, hv 0 2]
    norm_num [irredW, irredCost, Fin.ext_iff]
    linarith
  have h1 : univ.inf' univ_nonempty (fiberVal irredW (irredCost e) id 1) = 0 := by
    rw [inf'_fin_three, hv 1 0, hv 1 1, hv 1 2]
    norm_num [irredW, irredCost, Fin.ext_iff]
    linarith
  have h2 : univ.inf' univ_nonempty (fiberVal irredW (irredCost e) id 2) = 0 := by
    rw [inf'_fin_three, hv 2 0, hv 2 1, hv 2 2]
    norm_num [irredW, irredCost, Fin.ext_iff]
  rw [dialValue, Fin.sum_univ_three, h0, h1, h2]
  norm_num

theorem irred_ev (e : ℚ) :
    EV irredW (fun ω => irredCost e ω 0) = 20/3 ∧
      EV irredW (fun ω => irredCost e ω 1) = 20/3 ∧
      EV irredW (fun ω => irredCost e ω 2) = 2 * e / 3 := by
  refine ⟨?_, ?_, ?_⟩ <;>
  · rw [EV, Fin.sum_univ_three]
    norm_num [irredW, irredCost, Fin.ext_iff]
    all_goals ring

theorem irred_bestConstant {e : ℚ} (he1 : e ≤ 1) :
    bestConstant irredW (irredCost e) = 2 * e / 3 := by
  obtain ⟨h0, h1, h2⟩ := irred_ev e
  have hinf : (univ : Finset (Fin 3)).inf' univ_nonempty
      (fun s => EV irredW (fun ω => irredCost e ω s))
      = min (EV irredW (fun ω => irredCost e ω 0))
          (min (EV irredW (fun ω => irredCost e ω 1)) (EV irredW (fun ω => irredCost e ω 2))) :=
    inf'_fin_three _
  have hinner : min (20/3 : ℚ) (2 * e / 3) = 2 * e / 3 := min_eq_right (by linarith)
  rw [bestConstant, hinf, h0, h1, h2, hinner, min_eq_right (by linarith)]

/-- The dial gain of the irredundant family is exactly `2e/3`. -/
theorem irred_gap {e : ℚ} (he : 0 < e) (he1 : e ≤ 1) :
    bestConstant irredW (irredCost e) - dialValue irredW (irredCost e) id = 2 * e / 3 := by
  rw [irred_bestConstant he1, irred_dialValue he, sub_zero]

/-- The two swap masses of its first two members are exactly `10/3`, independently
of `e`. -/
theorem irred_swapMass (e : ℚ) :
    swapMassFun (fun o => fiberVal irredW (irredCost e) id o 0)
        (fun o => fiberVal irredW (irredCost e) id o 1) = 10/3 ∧
      swapMassFun (fun o => fiberVal irredW (irredCost e) id o 1)
        (fun o => fiberVal irredW (irredCost e) id o 0) = 10/3 := by
  have hv : ∀ o s, fiberVal irredW (irredCost e) id o s = irredW o * irredCost e o s :=
    fiberVal_irred e
  constructor <;>
  · rw [swapMassFun, Fin.sum_univ_three, hv 0 0, hv 0 1, hv 1 0, hv 1 1, hv 2 0, hv 2 1]
    norm_num [irredW, irredCost, Fin.ext_iff]

/-- **Refutation of the pairwise-swap conjecture.**  For every ratio `M` there is an
*irredundant* three-member portfolio — uniform weights, each instance its own
fiber — whose two first members swap with mass `10/3` in both directions while the
whole portfolio's dial gain is smaller than `(10/3)/M`.  So no constant, and no
function of the number of members, bounds pairwise swap masses by the measured
dial gain, even after every fiberwise-eliminable member has been deleted. -/
theorem swap_unbounded_on_irredundant (M : ℚ) :
    ∃ e : ℚ, 0 < e ∧ e ≤ 1 ∧
      (∀ o, 0 ≤ irredW o) ∧ (∑ o, irredW o = 1) ∧
      IrredundantPortfolio irredW (irredCost e) id ∧
      M * (bestConstant irredW (irredCost e) - dialValue irredW (irredCost e) id) <
        min (swapMassFun (fun o => fiberVal irredW (irredCost e) id o 0)
              (fun o => fiberVal irredW (irredCost e) id o 1))
            (swapMassFun (fun o => fiberVal irredW (irredCost e) id o 1)
              (fun o => fiberVal irredW (irredCost e) id o 0)) := by
  have habs : (0 : ℚ) ≤ |M| := abs_nonneg M
  have hpos : (0 : ℚ) < |M| + 1 := by linarith
  set e : ℚ := 1 / (|M| + 1) with hedef
  have he : 0 < e := by rw [hedef]; positivity
  have he1 : e ≤ 1 := by
    rw [hedef, div_le_one hpos]; linarith
  refine ⟨e, he, he1, irredW_nonneg, sum_irredW, irred_portfolio_irredundant he, ?_⟩
  obtain ⟨h0, h1⟩ := irred_swapMass e
  rw [irred_gap he he1, h0, h1, min_self]
  have hMe : M * e < 1 := by
    have h2 : M * e ≤ |M| * e := mul_le_mul_of_nonneg_right (le_abs_self M) he.le
    have h3 : |M| * e < 1 := by
      rw [hedef, mul_one_div, div_lt_one hpos]; linarith
    linarith
  have hrw : M * (2 * e / 3) = (M * e) * (2 / 3) := by ring
  rw [hrw]
  linarith

/-! ## The inequality that *is* true: the gap is covered by pairwise swaps

The refutation above is one-sided.  In the opposite direction the portfolio gain
is always dominated by the pairwise swap masses against a best static member, and
the bound is exactly the anti-diagonal ratio `|S| - 1`. -/

/-- The two swap masses of a pair differ by the difference of the static costs. -/
theorem swapMassFun_sub [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (s t : S) :
    swapMassFun (fun o => fiberVal w cost obs o s) (fun o => fiberVal w cost obs o t)
        - swapMassFun (fun o => fiberVal w cost obs o t) (fun o => fiberVal w cost obs o s)
      = EV w (fun ω => cost ω s) - EV w (fun ω => cost ω t) := by
  rw [ev_const_eq_sum_fiberVal w cost obs s, ev_const_eq_sum_fiberVal w cost obs t,
    swapMassFun, swapMassFun, ← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun o _ => ?_
  rcases le_total (fiberVal w cost obs o s) (fiberVal w cost obs o t) with h | h
  · rw [max_eq_right (by linarith), max_eq_left (by linarith)]; ring
  · rw [max_eq_left (by linarith), max_eq_right (by linarith)]; ring

/-- The fiberwise regret of a member is covered by its swap masses against the
other members. -/
theorem fiberRegret_le_sum_swapMass [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [DecidableEq S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (s₀ : S) :
    fiberRegret w cost obs s₀
      ≤ ∑ t ∈ univ.erase s₀,
          swapMassFun (fun o => fiberVal w cost obs o s₀) (fun o => fiberVal w cost obs o t) := by
  have hpt : ∀ o : O,
      fiberVal w cost obs o s₀ - univ.inf' univ_nonempty (fiberVal w cost obs o)
        ≤ ∑ t ∈ univ.erase s₀, max (fiberVal w cost obs o s₀ - fiberVal w cost obs o t) 0 := by
    intro o
    obtain ⟨t₀, -, ht₀⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S)) (fiberVal w cost obs o)
    have hnn : ∀ t ∈ univ.erase s₀,
        0 ≤ max (fiberVal w cost obs o s₀ - fiberVal w cost obs o t) 0 :=
      fun t _ => le_max_right _ _
    by_cases h : t₀ = s₀
    · have : fiberVal w cost obs o s₀ - univ.inf' univ_nonempty (fiberVal w cost obs o) = 0 := by
        rw [ht₀, h]; ring
      rw [this]
      exact Finset.sum_nonneg hnn
    · have hmem : t₀ ∈ univ.erase s₀ := Finset.mem_erase.mpr ⟨h, mem_univ t₀⟩
      have hle : fiberVal w cost obs o s₀ - univ.inf' univ_nonempty (fiberVal w cost obs o)
          ≤ max (fiberVal w cost obs o s₀ - fiberVal w cost obs o t₀) 0 := by
        rw [ht₀]; exact le_max_left _ _
      exact hle.trans (Finset.single_le_sum hnn hmem)
  calc fiberRegret w cost obs s₀
      ≤ ∑ o, ∑ t ∈ univ.erase s₀,
          max (fiberVal w cost obs o s₀ - fiberVal w cost obs o t) 0 :=
        Finset.sum_le_sum fun o _ => hpt o
    _ = ∑ t ∈ univ.erase s₀, ∑ o : O,
          max (fiberVal w cost obs o s₀ - fiberVal w cost obs o t) 0 := Finset.sum_comm
    _ = ∑ t ∈ univ.erase s₀,
          swapMassFun (fun o => fiberVal w cost obs o s₀) (fun o => fiberVal w cost obs o t) := rfl

/-- **The gap is covered by pairwise swaps.**  Against a best static member `s₀`,
each pairwise swap mass in the direction of `s₀` is the *smaller* of the two, and
their sum dominates the whole portfolio's dial gain.  Together with
`swap_unbounded_on_irredundant` this pins the relationship between the two
functionals exactly: the gap is bounded by the pairwise swaps, never the reverse. -/
theorem gap_le_sum_pair_swaps [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [DecidableEq S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) {s₀ : S}
    (hs₀ : EV w (fun ω => cost ω s₀) = bestConstant w cost) :
    bestConstant w cost - dialValue w cost obs
      ≤ ∑ t ∈ univ.erase s₀,
          min (swapMassFun (fun o => fiberVal w cost obs o s₀)
                (fun o => fiberVal w cost obs o t))
              (swapMassFun (fun o => fiberVal w cost obs o t)
                (fun o => fiberVal w cost obs o s₀)) := by
  have hmin : ∀ t ∈ univ.erase s₀,
      min (swapMassFun (fun o => fiberVal w cost obs o s₀) (fun o => fiberVal w cost obs o t))
          (swapMassFun (fun o => fiberVal w cost obs o t) (fun o => fiberVal w cost obs o s₀))
        = swapMassFun (fun o => fiberVal w cost obs o s₀)
            (fun o => fiberVal w cost obs o t) := by
    intro t _
    have hdiff := swapMassFun_sub w cost obs s₀ t
    have hEV : bestConstant w cost ≤ EV w (fun ω => cost ω t) := Finset.inf'_le _ (mem_univ t)
    exact min_eq_left (by rw [hs₀] at hdiff; linarith)
  rw [Finset.sum_congr rfl hmin]
  have hfr : fiberRegret w cost obs s₀ = bestConstant w cost - dialValue w cost obs := by
    rw [fiberRegret_eq, hs₀]
  rw [← hfr]
  exact fiberRegret_le_sum_swapMass w cost obs s₀

/-- Corollary in the anti-diagonal form: if every pairwise swap against a best
static member is at most `c`, the dial gain is at most `(|S| - 1) * c`.  The
constant is attained by the anti-diagonal portfolios of
`Probability.PortfolioEpsInvisible`. -/
theorem gap_le_card_mul_pair_swap [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [DecidableEq S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) {s₀ : S} {c : ℚ}
    (hs₀ : EV w (fun ω => cost ω s₀) = bestConstant w cost)
    (hc : ∀ t ∈ univ.erase s₀,
      min (swapMassFun (fun o => fiberVal w cost obs o s₀) (fun o => fiberVal w cost obs o t))
          (swapMassFun (fun o => fiberVal w cost obs o t)
            (fun o => fiberVal w cost obs o s₀)) ≤ c) :
    bestConstant w cost - dialValue w cost obs ≤ ((Fintype.card S : ℚ) - 1) * c := by
  have hsum := gap_le_sum_pair_swaps w cost obs hs₀
  have hle : ∑ t ∈ univ.erase s₀,
      min (swapMassFun (fun o => fiberVal w cost obs o s₀) (fun o => fiberVal w cost obs o t))
          (swapMassFun (fun o => fiberVal w cost obs o t) (fun o => fiberVal w cost obs o s₀))
      ≤ ∑ _t ∈ univ.erase s₀, c := Finset.sum_le_sum hc
  have hcard : ((univ.erase s₀).card : ℚ) = (Fintype.card S : ℚ) - 1 := by
    rw [Finset.card_erase_of_mem (mem_univ s₀)]
    have h1 : 1 ≤ Fintype.card S := Fintype.card_pos
    rw [Finset.card_univ, Nat.cast_sub h1, Nat.cast_one]
  rw [Finset.sum_const, nsmul_eq_mul, hcard] at hle
  linarith

end Probability.PortfolioRegret