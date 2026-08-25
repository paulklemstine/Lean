/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Portfolio scheduling over an invisible channel — core theory

This file formalises the probabilistic skeleton behind the empirical finding of
experiment 560 ("no universal winner, no dial edge; the regret tail is
`N`-invisible"): a finite portfolio of algorithms is run on instances drawn from
a finite probability space; each instance carries an *observable* feature
(bit length, balance, ... — anything computable from `N`) and a *hidden* feature
(the powersmoothness of `p - 1`), and the running cost of every member of the
portfolio depends only on the hidden feature.

The main results are:

* `PortfolioRegret.ev_policy_eq_sum_fiber` — a fiberwise decomposition of the
  expected cost of a *dial rule* (a policy that reads the observable only);
* `PortfolioRegret.bestConstant_eq_inf_mean` — under invisibility the value of
  the best constant strategy is exactly `min_s m s`;
* `PortfolioRegret.no_dial_edge` — **no dial rule beats the best constant
  strategy**: the "tuned dial" of the experiment provably tunes itself to
  do-nothing;
* `PortfolioRegret.ml_rule_strictly_worse` — a *strict* converse: any rule that
  deviates towards a suboptimal strategy on a positive-mass fiber is strictly
  worse than doing nothing (the formal shadow of "the ML rule is significantly
  worse than static");
* `PortfolioRegret.exists_policy_eq_oracle` and
  `PortfolioRegret.paid_probe_beneficial_iff` — a probe that reveals the hidden
  channel attains the oracle, and is worth its price exactly when the price
  undercuts the static regret.

Everything is stated over `ℚ` on finite spaces, so the accompanying concrete
portfolios are exactly computable.
-/
import Mathlib

namespace Probability.PortfolioRegret

open Finset

variable {Ω O S : Type*}

/-! ## Basic objects -/

/-- Expectation of `f : Ω → ℚ` under the weights `w`. -/
def EV [Fintype Ω] (w f : Ω → ℚ) : ℚ := ∑ ω, w ω * f ω

/-- Total mass of the fiber of the observation map `obs` over `o`. -/
def fiberMass [Fintype Ω] [DecidableEq O] (w : Ω → ℚ) (obs : Ω → O) (o : O) : ℚ :=
  ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω

/-- Cost incurred by the *dial rule* `π`, which picks a portfolio member from the
observable feature alone. -/
def policyCost (cost : Ω → S → ℚ) (obs : Ω → O) (π : O → S) (ω : Ω) : ℚ :=
  cost ω (π (obs ω))

/-- The oracle cost: the best member of the portfolio, chosen with hindsight. -/
noncomputable def oracleCost [Fintype S] [Nonempty S] (cost : Ω → S → ℚ) (ω : Ω) : ℚ :=
  univ.inf' univ_nonempty (cost ω)

/-- Expected cost of the best *constant* strategy (the "static" schedule). -/
noncomputable def bestConstant [Fintype Ω] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) : ℚ :=
  univ.inf' univ_nonempty (fun s => EV w (fun ω => cost ω s))

/-- Static regret: how much the best fixed strategy loses against the oracle. -/
noncomputable def staticRegret [Fintype Ω] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) : ℚ :=
  bestConstant w cost - EV w (oracleCost cost)

/-- **Invisibility of the organising channel.**  Relative to the observation map
`obs`, the conditional mean cost of every portfolio member is the same number
`m s` on every fiber: the observation carries no information about which member
will win. -/
def Invisible [Fintype Ω] [DecidableEq O] (w : Ω → ℚ) (cost : Ω → S → ℚ)
    (obs : Ω → O) (m : S → ℚ) : Prop :=
  ∀ (o : O) (s : S),
    ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * cost ω s = fiberMass w obs o * m s

/-! ## Fiberwise decomposition -/

theorem sum_fiberMass [Fintype Ω] [Fintype O] [DecidableEq O]
    (w : Ω → ℚ) (obs : Ω → O) : ∑ o, fiberMass w obs o = ∑ ω, w ω := by
  simpa [fiberMass] using Finset.sum_fiberwise (univ : Finset Ω) obs w

theorem fiberMass_nonneg [Fintype Ω] [DecidableEq O] {w : Ω → ℚ} (hw : ∀ ω, 0 ≤ w ω)
    (obs : Ω → O) (o : O) : 0 ≤ fiberMass w obs o :=
  Finset.sum_nonneg fun ω _ => hw ω

/-- The expected cost of a dial rule splits over the fibers of the observation. -/
theorem ev_policy_eq_sum_fiber [Fintype Ω] [Fintype O] [DecidableEq O]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hinv : Invisible w cost obs m) (π : O → S) :
    EV w (policyCost cost obs π) = ∑ o, fiberMass w obs o * m (π o) := by
  have h : ∑ o, ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * cost ω (π (obs ω))
      = ∑ ω, w ω * cost ω (π (obs ω)) :=
    Finset.sum_fiberwise (univ : Finset Ω) obs (fun ω => w ω * cost ω (π (obs ω)))
  simp only [EV, policyCost]
  rw [← h]
  refine Finset.sum_congr rfl fun o _ => ?_
  have : ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * cost ω (π (obs ω))
      = ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * cost ω (π o) := by
    refine Finset.sum_congr rfl fun ω hω => ?_
    rw [(Finset.mem_filter.mp hω).2]
  rw [this, hinv o (π o)]

/-- Under invisibility every constant strategy has expected cost `m s`. -/
theorem ev_const_eq [Fintype Ω] [Fintype O] [DecidableEq O]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hinv : Invisible w cost obs m) (hw : ∑ ω, w ω = 1) (s : S) :
    EV w (fun ω => cost ω s) = m s := by
  have h := ev_policy_eq_sum_fiber (O := O) hinv (fun _ => s)
  have hmass : ∑ o, fiberMass w obs o = 1 := by rw [sum_fiberMass, hw]
  simpa [policyCost, ← Finset.sum_mul, hmass] using h

/-! ## No dial edge -/

/-- Under invisibility, the best constant strategy achieves the smallest of the
conditional means. -/
theorem bestConstant_eq_inf_mean [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hinv : Invisible w cost obs m) (hw : ∑ ω, w ω = 1) :
    bestConstant w cost = univ.inf' univ_nonempty m := by
  unfold bestConstant
  exact Finset.inf'_congr univ_nonempty rfl fun s _ => ev_const_eq (obs := obs) hinv hw s

/-- **No dial edge.**  If the observable feature is invisible to the portfolio,
then *every* rule that schedules on the observable does at least as badly as the
best constant strategy: the optimal dial is the do-nothing dial. -/
theorem no_dial_edge [Fintype Ω] [Fintype O] [DecidableEq O] [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1)
    (hinv : Invisible w cost obs m) (π : O → S) :
    bestConstant w cost ≤ EV w (policyCost cost obs π) := by
  rw [ev_policy_eq_sum_fiber hinv π, bestConstant_eq_inf_mean (obs := obs) hinv hw]
  set μ : ℚ := univ.inf' univ_nonempty m with hμ
  have hmass : ∑ o, fiberMass w obs o = 1 := by rw [sum_fiberMass, hw]
  calc μ = ∑ o : O, fiberMass w obs o * μ := by rw [← Finset.sum_mul, hmass, one_mul]
    _ ≤ ∑ o : O, fiberMass w obs o * m (π o) := by
        refine Finset.sum_le_sum fun o _ => ?_
        exact mul_le_mul_of_nonneg_left (hμ ▸ Finset.inf'_le m (mem_univ (π o)))
          (fiberMass_nonneg hw0 obs o)
    _ = ∑ o, fiberMass w obs o * m (π o) := rfl

/-- **A tuned rule can only hurt.**  If a dial rule deviates, on a fiber of
positive mass, towards a strategy whose conditional mean is not optimal, then it
is *strictly* worse than doing nothing.  This is the formal content of the
observed "ML rule significantly worse than static". -/
theorem ml_rule_strictly_worse [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1)
    (hinv : Invisible w cost obs m) (π : O → S) {o₀ : O}
    (hpos : 0 < fiberMass w obs o₀)
    (hbad : univ.inf' univ_nonempty m < m (π o₀)) :
    bestConstant w cost < EV w (policyCost cost obs π) := by
  rw [ev_policy_eq_sum_fiber hinv π, bestConstant_eq_inf_mean (obs := obs) hinv hw]
  set μ : ℚ := univ.inf' univ_nonempty m with hμ
  have hmass : ∑ o, fiberMass w obs o = 1 := by rw [sum_fiberMass, hw]
  have hlt : ∑ o : O, fiberMass w obs o * μ < ∑ o : O, fiberMass w obs o * m (π o) := by
    refine Finset.sum_lt_sum (fun o _ => ?_) ⟨o₀, mem_univ _, ?_⟩
    · exact mul_le_mul_of_nonneg_left (hμ ▸ Finset.inf'_le m (mem_univ (π o)))
        (fiberMass_nonneg hw0 obs o)
    · exact mul_lt_mul_of_pos_left hbad hpos
  calc μ = ∑ o : O, fiberMass w obs o * μ := by rw [← Finset.sum_mul, hmass, one_mul]
    _ < ∑ o : O, fiberMass w obs o * m (π o) := hlt

/-! ## Paid probes: buying the hidden channel -/

/-- An omniscient rule — one whose observation separates the instances — attains
the oracle exactly. -/
theorem exists_policy_eq_oracle [Fintype Ω] [Fintype S] [Nonempty S] (w : Ω → ℚ)
    (cost : Ω → S → ℚ) :
    ∃ π : Ω → S, EV w (policyCost cost id π) = EV w (oracleCost cost) := by
  classical
  choose π hπ hπ' using fun ω => Finset.exists_mem_eq_inf' (univ_nonempty (α := S)) (cost ω)
  refine ⟨π, ?_⟩
  refine Finset.sum_congr rfl fun ω _ => ?_
  rw [policyCost, oracleCost, hπ' ω]
  rfl

/-- Oracle cost is pointwise below any strategy's cost, hence in expectation. -/
theorem ev_oracle_le [Fintype Ω] [Fintype S] [Nonempty S] {w : Ω → ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (cost : Ω → S → ℚ) (s : S) :
    EV w (oracleCost cost) ≤ EV w (fun ω => cost ω s) :=
  Finset.sum_le_sum fun ω _ =>
    mul_le_mul_of_nonneg_left (Finset.inf'_le (cost ω) (mem_univ s)) (hw0 ω)

/-- The static regret is nonnegative. -/
theorem staticRegret_nonneg [Fintype Ω] [Fintype S] [Nonempty S] {w : Ω → ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (cost : Ω → S → ℚ) : 0 ≤ staticRegret w cost := by
  obtain ⟨s, -, hs⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S))
    (fun s => EV w (fun ω => cost ω s))
  have : bestConstant w cost = EV w (fun ω => cost ω s) := hs
  simp only [staticRegret, this, sub_nonneg]
  exact ev_oracle_le hw0 cost s

/-- **Paid probes.**  A probe that reveals the hidden channel and costs `κ` per
instance beats the best static schedule exactly when `κ` undercuts the static
regret; in particular a nonzero probe budget is worth spending precisely on the
regret carried by the invisible channel. -/
theorem paid_probe_beneficial_iff [Fintype Ω] [Fintype S] [Nonempty S]
    (w : Ω → ℚ) (cost : Ω → S → ℚ) (κ : ℚ) :
    EV w (oracleCost cost) + κ < bestConstant w cost ↔ κ < staticRegret w cost := by
  rw [staticRegret]
  constructor <;> intro h <;> linarith

end Probability.PortfolioRegret