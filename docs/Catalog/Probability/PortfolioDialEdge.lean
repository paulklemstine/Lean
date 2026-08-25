/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# When does a dial help?  An exact characterisation, and the information ladder

Second cycle of the portfolio programme.  `Probability.PortfolioRegretCore`
shows that an *invisible* observation gives no scheduling edge.  Here we drop the
invisibility hypothesis entirely and compute the exact optimum over all
observation-measurable rules.

For an observation map `obs` write `fiberVal o s` for the unnormalised
conditional cost of member `s` on the fiber over `o`.  Then

* `ev_policy_eq_sum_fiberVal` — every rule costs `∑ o, fiberVal o (π o)`;
* `dialValue` `= ∑ o, min_s fiberVal o s` is attained (`exists_optimal_dial`)
  and is a lower bound for every rule (`dialValue_le_ev_policy`);
* `dialValue_le_bestConstant` — a dial never hurts if it is *optimised*;
* `dial_edge_iff` — **exact characterisation**: an optimised dial strictly beats
  the best static member if and only if every member is beaten on some fiber;
* `dialValue_mono_of_refines` — a finer observation is worth (weakly) more:
  monotonicity of the value of information;
* `ev_oracle_le_dialValue` — the whole ladder
  `E[oracle] ≤ dialValue ≤ bestConstant`.

Combined with the `N`-invisibility of the `p - 1` powersmoothness channel
(`Probability.PortfolioSmoothnessChannel`), `dial_edge_iff` explains the measured
`Δ = 0.000`: the tuned dial found nothing because on each fiber the same member
minimises the conditional cost.
-/
import Mathlib
import Probability.PortfolioRegretCore

namespace Probability.PortfolioRegret

open Finset

variable {Ω O O' S : Type*}

/-- Unnormalised conditional cost of member `s` on the fiber of `obs` over `o`. -/
def fiberVal [Fintype Ω] [DecidableEq O] (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O)
    (o : O) (s : S) : ℚ :=
  ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * cost ω s

/-- The value of the *optimal* rule measurable with respect to `obs`. -/
noncomputable def dialValue [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) : ℚ :=
  ∑ o, univ.inf' univ_nonempty (fiberVal w cost obs o)

/-- Every rule decomposes over the fibers of its observation. -/
theorem ev_policy_eq_sum_fiberVal [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (π : O → S) :
    EV w (policyCost cost obs π) = ∑ o, fiberVal w cost obs o (π o) := by
  have h : ∑ o, ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * cost ω (π (obs ω))
      = ∑ ω, w ω * cost ω (π (obs ω)) :=
    Finset.sum_fiberwise (univ : Finset Ω) obs (fun ω => w ω * cost ω (π (obs ω)))
  simp only [EV, policyCost]
  rw [← h]
  refine Finset.sum_congr rfl fun o _ => ?_
  refine Finset.sum_congr rfl fun ω hω => ?_
  rw [(Finset.mem_filter.mp hω).2]

/-- A constant rule has cost `∑ o, fiberVal o s`. -/
theorem ev_const_eq_sum_fiberVal [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (s : S) :
    EV w (fun ω => cost ω s) = ∑ o, fiberVal w cost obs o s := by
  simpa [policyCost] using ev_policy_eq_sum_fiberVal w cost obs (fun _ => s)

/-- The optimal dial value is a lower bound for every rule. -/
theorem dialValue_le_ev_policy [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) (π : O → S) :
    dialValue w cost obs ≤ EV w (policyCost cost obs π) := by
  rw [ev_policy_eq_sum_fiberVal, dialValue]
  exact Finset.sum_le_sum fun o _ => Finset.inf'_le _ (mem_univ (π o))

/-- The optimal dial value is attained by an explicit rule. -/
theorem exists_optimal_dial [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) :
    ∃ π : O → S, EV w (policyCost cost obs π) = dialValue w cost obs := by
  classical
  choose π hπmem hπ using fun o =>
    Finset.exists_mem_eq_inf' (univ_nonempty (α := S)) (fiberVal w cost obs o)
  refine ⟨π, ?_⟩
  rw [ev_policy_eq_sum_fiberVal, dialValue]
  exact Finset.sum_congr rfl fun o _ => (hπ o).symm

/-- An optimised dial never costs more than the best static member. -/
theorem dialValue_le_bestConstant [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S] (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) :
    dialValue w cost obs ≤ bestConstant w cost := by
  obtain ⟨s, -, hs⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S))
    (fun s => EV w (fun ω => cost ω s))
  have hb : bestConstant w cost = EV w (fun ω => cost ω s) := hs
  rw [hb, ev_const_eq_sum_fiberVal w cost obs s, dialValue]
  exact Finset.sum_le_sum fun o _ => Finset.inf'_le _ (mem_univ s)

/-- **Exact characterisation of a dial edge.**  An optimised observation-measurable
rule strictly beats the best static member precisely when *every* member of the
portfolio is strictly beaten on at least one fiber of the observation.  In
particular a dial is worthless as soon as one member minimises the conditional
cost on every fiber. -/
theorem dial_edge_iff [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (obs : Ω → O) :
    dialValue w cost obs < bestConstant w cost ↔
      ∀ s : S, ∃ o : O, univ.inf' univ_nonempty (fiberVal w cost obs o) < fiberVal w cost obs o s := by
  constructor
  · intro hlt s
    have hb : bestConstant w cost ≤ EV w (fun ω => cost ω s) := Finset.inf'_le _ (mem_univ s)
    have hsum : ∑ o, univ.inf' univ_nonempty (fiberVal w cost obs o)
        < ∑ o, fiberVal w cost obs o s := by
      rw [← dialValue, ← ev_const_eq_sum_fiberVal w cost obs s]
      exact lt_of_lt_of_le hlt hb
    by_contra hcon
    push_neg at hcon
    exact absurd hsum (not_lt.mpr (Finset.sum_le_sum fun o _ => hcon o))
  · intro hall
    obtain ⟨s, -, hs⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S))
      (fun s => EV w (fun ω => cost ω s))
    have hb : bestConstant w cost = EV w (fun ω => cost ω s) := hs
    obtain ⟨o₀, ho₀⟩ := hall s
    rw [hb, ev_const_eq_sum_fiberVal w cost obs s, dialValue]
    exact Finset.sum_lt_sum (fun o _ => Finset.inf'_le _ (mem_univ s)) ⟨o₀, mem_univ _, ho₀⟩

/-- **Monotone value of information.**  If the observation `obs` is a function of
the finer observation `obs'`, then the finer observation is worth at least as
much. -/
theorem dialValue_mono_of_refines [Fintype Ω] [Fintype O] [Fintype O'] [DecidableEq O]
    [DecidableEq O'] [Fintype S] [Nonempty S] (w : Ω → ℚ) (cost : Ω → S → ℚ)
    (obs : Ω → O) (obs' : Ω → O') (g : O' → O) (hg : ∀ ω, obs ω = g (obs' ω)) :
    dialValue w cost obs' ≤ dialValue w cost obs := by
  obtain ⟨π, hπ⟩ := exists_optimal_dial w cost obs
  have hcost : policyCost cost obs π = policyCost cost obs' (π ∘ g) := by
    funext ω
    simp [policyCost, hg ω]
  calc dialValue w cost obs' ≤ EV w (policyCost cost obs' (π ∘ g)) :=
        dialValue_le_ev_policy w cost obs' (π ∘ g)
    _ = EV w (policyCost cost obs π) := by rw [hcost]
    _ = dialValue w cost obs := hπ

/-- The bottom of the ladder: no observation-measurable rule beats the oracle. -/
theorem ev_oracle_le_dialValue [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    {w : Ω → ℚ} (hw0 : ∀ ω, 0 ≤ w ω) (cost : Ω → S → ℚ) (obs : Ω → O) :
    EV w (oracleCost cost) ≤ dialValue w cost obs := by
  classical
  obtain ⟨π, hπ⟩ := exists_optimal_dial w cost obs
  rw [← hπ]
  exact Finset.sum_le_sum fun ω _ =>
    mul_le_mul_of_nonneg_left (Finset.inf'_le _ (mem_univ (π (obs ω)))) (hw0 ω)

/-- **The information ladder.**  Oracle ≤ optimal dial ≤ best static member. -/
theorem oracle_le_dial_le_static [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    {w : Ω → ℚ} (hw0 : ∀ ω, 0 ≤ w ω) (cost : Ω → S → ℚ) (obs : Ω → O) :
    EV w (oracleCost cost) ≤ dialValue w cost obs ∧
      dialValue w cost obs ≤ bestConstant w cost :=
  ⟨ev_oracle_le_dialValue hw0 cost obs, dialValue_le_bestConstant w cost obs⟩

/-- Under invisibility the dial value collapses onto the static value: the
measured `Δ = 0.000` is forced. -/
theorem dialValue_eq_bestConstant_of_invisible [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S] {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (hinv : Invisible w cost obs m) :
    dialValue w cost obs = bestConstant w cost := by
  refine le_antisymm (dialValue_le_bestConstant w cost obs) ?_
  obtain ⟨π, hπ⟩ := exists_optimal_dial w cost obs
  rw [← hπ]
  exact no_dial_edge hw0 hw hinv π

end Probability.PortfolioRegret