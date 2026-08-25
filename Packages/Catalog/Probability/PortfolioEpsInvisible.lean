/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quantitative (ε-)invisibility: stability of the no-dial-edge theorem

`Probability.PortfolioRegretCore` proves that an *exactly* invisible observation
is worthless for scheduling: the optimal dial is the do-nothing dial.  Exact
invisibility is a knife-edge hypothesis, and no measurement can ever certify it.
This file replaces it by a measurable one.

An observation is **ε-invisible** for the portfolio when, on every fiber, the
(unnormalised) conditional cost of every member differs from its global
conditional mean `m s` by at most `ε` times the mass of the fiber:

`|fiberVal o s - fiberMass o * m s| ≤ ε * fiberMass o`.

Main results:

* `bestConstant_le_of_epsInvisible` — the best static member costs at most
  `min m + ε`;
* `dialValue_ge_of_epsInvisible` — the *optimal* observation-measurable rule
  costs at least `min m - ε`;
* `eps_invisible_gap_le` — hence `bestConstant - dialValue ≤ 2 * ε`: a small
  measured dial gain is a certificate of near-invisibility, and conversely
  near-invisibility caps the achievable gain.  This is the conjectured
  stability statement of the previous cycle (`FUTURE_DIRECTIONS.md`, direction 1);
* `eps_invisible_policy_ge` — the approximate no-dial-edge inequality for an
  arbitrary rule, degenerating to `no_dial_edge` at `ε = 0`;
* **sharpness**: the explicit "anti-diagonal" portfolios `spreadCost n`
  (`n+1` members, `n+1` fibers, uniform weights, cost `-1` on the diagonal and
  `+1` off it) are `1`-invisible with gap exactly `2 n / (n+1)`
  (`spread_gap`), so the constant `2` cannot be lowered
  (`eps_invisible_two_sharp`), while a *single* fiber pair already forces the gap
  to be at least `ε` (`spread_gap` at `n = 1`).

* **the naive converse fails** (`gap_zero_of_identical_members`,
  `gap_zero_not_epsInvisible`): a portfolio of indistinguishable members has dial
  gain `0` on *every* observation, and an explicit two-instance example with gain
  `0` fails to be `ε`-invisible for any `ε < 1` and any mean profile.  A null dial
  measurement is therefore one-sided evidence only.

Everything is finite and rational; no measure theory is involved.
-/
import Mathlib
import Probability.PortfolioRegretCore
import Probability.PortfolioDialEdge

namespace Probability.PortfolioRegret

open Finset

variable {Ω O S : Type*}

/-! ## ε-invisibility -/

/-- **Quantitative invisibility.**  Relative to the observation `obs`, the
conditional cost of every member on every fiber agrees with the global mean
profile `m` up to a relative error `eps`. -/
def EpsInvisible [Fintype Ω] [DecidableEq O] (w : Ω → ℚ) (cost : Ω → S → ℚ)
    (obs : Ω → O) (m : S → ℚ) (eps : ℚ) : Prop :=
  ∀ (o : O) (s : S),
    |fiberVal w cost obs o s - fiberMass w obs o * m s| ≤ eps * fiberMass w obs o

/-- Exact invisibility is `0`-invisibility. -/
theorem epsInvisible_zero_of_invisible [Fintype Ω] [DecidableEq O]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hinv : Invisible w cost obs m) : EpsInvisible w cost obs m 0 := by
  intro o s
  have h : fiberVal w cost obs o s = fiberMass w obs o * m s := hinv o s
  simp [h]

theorem fiberVal_le_of_epsInvisible [Fintype Ω] [DecidableEq O]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (h : EpsInvisible w cost obs m eps) (o : O) (s : S) :
    fiberVal w cost obs o s ≤ fiberMass w obs o * m s + eps * fiberMass w obs o := by
  have := (abs_le.mp (h o s)).2
  linarith

theorem le_fiberVal_of_epsInvisible [Fintype Ω] [DecidableEq O]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (h : EpsInvisible w cost obs m eps) (o : O) (s : S) :
    fiberMass w obs o * m s - eps * fiberMass w obs o ≤ fiberVal w cost obs o s := by
  have := (abs_le.mp (h o s)).1
  linarith

/-! ## The two ends of the sandwich -/

/-- Under `eps`-invisibility the best static member costs at most `min m + eps`. -/
theorem bestConstant_le_of_epsInvisible [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (hw : ∑ ω, w ω = 1) (h : EpsInvisible w cost obs m eps) :
    bestConstant w cost ≤ univ.inf' univ_nonempty m + eps := by
  obtain ⟨s₀, -, hs₀⟩ := Finset.exists_mem_eq_inf' (univ_nonempty (α := S)) m
  have hmass : ∑ o, fiberMass w obs o = 1 := by rw [sum_fiberMass, hw]
  have hb : bestConstant w cost ≤ EV w (fun ω => cost ω s₀) :=
    Finset.inf'_le _ (mem_univ s₀)
  have hEV : EV w (fun ω => cost ω s₀) ≤ ∑ o, fiberMass w obs o * (m s₀ + eps) := by
    rw [ev_const_eq_sum_fiberVal w cost obs s₀]
    refine Finset.sum_le_sum fun o _ => ?_
    have := fiberVal_le_of_epsInvisible h o s₀
    nlinarith [this]
  have hsum : ∑ o, fiberMass w obs o * (m s₀ + eps) = m s₀ + eps := by
    rw [← Finset.sum_mul, hmass, one_mul]
  rw [hs₀]
  linarith [hb, hEV, hsum.le, hsum.ge]

/-- Under `eps`-invisibility the *optimal* observation-measurable rule costs at
least `min m - eps`: no dial can extract more than `eps` from a nearly invisible
observation. -/
theorem dialValue_ge_of_epsInvisible [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (h : EpsInvisible w cost obs m eps) :
    univ.inf' univ_nonempty m - eps ≤ dialValue w cost obs := by
  have hmass : ∑ o, fiberMass w obs o = 1 := by rw [sum_fiberMass, hw]
  have hlow : ∀ o : O,
      fiberMass w obs o * (univ.inf' univ_nonempty m - eps)
        ≤ univ.inf' univ_nonempty (fiberVal w cost obs o) := by
    intro o
    refine Finset.le_inf' univ_nonempty _ fun s _ => ?_
    have h1 : fiberMass w obs o * m s - eps * fiberMass w obs o ≤ fiberVal w cost obs o s :=
      le_fiberVal_of_epsInvisible h o s
    have h2 : univ.inf' univ_nonempty m ≤ m s := Finset.inf'_le _ (mem_univ s)
    have h3 : (0 : ℚ) ≤ fiberMass w obs o := fiberMass_nonneg hw0 obs o
    nlinarith [h1, h2, h3]
  calc univ.inf' univ_nonempty m - eps
      = ∑ o, fiberMass w obs o * (univ.inf' univ_nonempty m - eps) := by
        rw [← Finset.sum_mul, hmass, one_mul]
    _ ≤ ∑ o, univ.inf' univ_nonempty (fiberVal w cost obs o) :=
        Finset.sum_le_sum fun o _ => hlow o
    _ = dialValue w cost obs := rfl

/-! ## Stability of the no-dial-edge theorem -/

/-- **ε-invisibility stability.**  If the observation is `eps`-invisible then the
best achievable gain of an optimised dial over the best static member is at most
`2 * eps`.  At `eps = 0` this is `dialValue_eq_bestConstant_of_invisible`. -/
theorem eps_invisible_gap_le [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (h : EpsInvisible w cost obs m eps) :
    bestConstant w cost - dialValue w cost obs ≤ 2 * eps := by
  have h1 := bestConstant_le_of_epsInvisible hw h
  have h2 := dialValue_ge_of_epsInvisible hw0 hw h
  linarith

/-- **Approximate no dial edge.**  Every rule that schedules on an `eps`-invisible
observation is within `2 * eps` of the best static member — the `eps = 0` case is
`no_dial_edge`. -/
theorem eps_invisible_policy_ge [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (h : EpsInvisible w cost obs m eps)
    (π : O → S) :
    bestConstant w cost - 2 * eps ≤ EV w (policyCost cost obs π) := by
  have h1 := eps_invisible_gap_le hw0 hw h
  have h2 := dialValue_le_ev_policy w cost obs π
  linarith

/-- The measured static regret bounds the dial gain from below in the same way:
a nearly invisible observation cannot recover the regret carried by the hidden
channel unless that regret is itself at most `2 * eps`. -/
theorem staticRegret_le_of_epsInvisible_of_dial_optimal [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ} {eps : ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (h : EpsInvisible w cost obs m eps)
    (hopt : dialValue w cost obs = EV w (oracleCost cost)) :
    staticRegret w cost ≤ 2 * eps := by
  have h1 := eps_invisible_gap_le hw0 hw h
  rw [staticRegret, ← hopt]
  linarith

/-! ## Sharpness of the constant `2`

The "anti-diagonal" portfolio on `Fin (n+1)`: instance `o` is its own fiber, the
`o`-th member is the unique winner there (cost `-1`) and every other member pays
`+1`.  All members have the same global mean, so the portfolio is `1`-invisible,
yet an optimal dial saves `2 n / (n + 1)`. -/

/-- On the finest observation (each instance is its own fiber) the fiber mass is
the weight of the instance. -/
theorem fiberMass_id [Fintype Ω] [DecidableEq Ω] (w : Ω → ℚ) (o : Ω) :
    fiberMass w id o = w o := by
  simp [fiberMass, Finset.filter_eq']

/-- On the finest observation the conditional cost is a single term. -/
theorem fiberVal_id [Fintype Ω] [DecidableEq Ω] (w : Ω → ℚ) (cost : Ω → S → ℚ) (o : Ω)
    (s : S) : fiberVal w cost id o s = w o * cost o s := by
  simp [fiberVal, Finset.filter_eq']

/-- Uniform weights on `Fin (n+1)`. -/
def spreadW (n : ℕ) : Fin (n + 1) → ℚ := fun _ => 1 / (n + 1)

/-- Anti-diagonal cost matrix: member `s` wins exactly on instance `s`. -/
def spreadCost (n : ℕ) : Fin (n + 1) → Fin (n + 1) → ℚ :=
  fun o s => if o = s then -1 else 1

theorem spreadW_nonneg (n : ℕ) (o : Fin (n + 1)) : 0 ≤ spreadW n o := by
  have : (0 : ℚ) < (n : ℚ) + 1 := by positivity
  simp only [spreadW]
  positivity

theorem sum_spreadW (n : ℕ) : ∑ o, spreadW n o = 1 := by
  have hn : ((n : ℚ) + 1) ≠ 0 := by positivity
  simp [spreadW, Finset.sum_const, Finset.card_univ]
  field_simp

theorem fiberMass_spread (n : ℕ) (o : Fin (n + 1)) :
    fiberMass (spreadW n) id o = 1 / (n + 1) := by
  simp [fiberMass, Finset.filter_eq', spreadW]

theorem fiberVal_spread (n : ℕ) (o s : Fin (n + 1)) :
    fiberVal (spreadW n) (spreadCost n) id o s = (1 / (n + 1)) * spreadCost n o s := by
  simp [fiberVal, Finset.filter_eq', spreadW]

/-- The anti-diagonal portfolio is `1`-invisible for the (constant) mean profile
`m ≡ 0`: every member costs `±1` with probability `1/(n+1)` on every fiber. -/
theorem spread_epsInvisible (n : ℕ) :
    EpsInvisible (spreadW n) (spreadCost n) id (fun _ => (0 : ℚ)) 1 := by
  intro o s
  have habs : |spreadCost n o s| = 1 := by by_cases h : o = s <;> simp [spreadCost, h]
  rw [fiberVal_spread, fiberMass_spread, mul_zero, sub_zero, abs_mul, habs, mul_one, one_mul,
    abs_of_pos (by positivity : (0:ℚ) < 1 / ((n : ℚ) + 1))]

/-- Every member of the anti-diagonal portfolio has the same expected cost. -/
theorem ev_spread (n : ℕ) (s : Fin (n + 1)) :
    EV (spreadW n) (fun o => spreadCost n o s) = ((n : ℚ) - 1) / (n + 1) := by
  have hn : ((n : ℚ) + 1) ≠ 0 := by positivity
  have hsplit : ∀ o : Fin (n + 1),
      spreadW n o * spreadCost n o s
        = (1 / ((n : ℚ) + 1)) + (if o = s then (-2 : ℚ) / ((n : ℚ) + 1) else 0) := by
    intro o
    rcases eq_or_ne o s with h | h
    · subst h
      simp only [spreadW, spreadCost, if_true]
      field_simp
      ring
    · simp [spreadW, spreadCost, h]
  simp only [EV]
  rw [Finset.sum_congr rfl fun o _ => hsplit o, Finset.sum_add_distrib]
  simp [Finset.sum_const, Finset.card_univ, Finset.sum_ite_eq' univ s]
  field_simp
  ring

/-- The best static member of the anti-diagonal portfolio. -/
theorem spread_bestConstant (n : ℕ) :
    bestConstant (spreadW n) (spreadCost n) = ((n : ℚ) - 1) / (n + 1) := by
  unfold bestConstant
  rw [show (fun s => EV (spreadW n) (fun o => spreadCost n o s))
      = (fun _ : Fin (n + 1) => ((n : ℚ) - 1) / (n + 1)) from funext fun s => ev_spread n s]
  simp

/-- The optimal dial on the anti-diagonal portfolio always plays the local
winner, and therefore costs `-1`. -/
theorem spread_dialValue (n : ℕ) :
    dialValue (spreadW n) (spreadCost n) id = -1 := by
  have hpos : (0 : ℚ) < (n : ℚ) + 1 := by positivity
  have hfib : ∀ o : Fin (n + 1),
      univ.inf' univ_nonempty (fiberVal (spreadW n) (spreadCost n) id o)
        = -(1 / ((n : ℚ) + 1)) := by
    intro o
    refine le_antisymm ?_ ?_
    · have h := Finset.inf'_le (fiberVal (spreadW n) (spreadCost n) id o) (mem_univ o)
      rw [fiberVal_spread] at h
      simpa [spreadCost] using h
    · refine Finset.le_inf' univ_nonempty _ fun s _ => ?_
      rw [fiberVal_spread]
      by_cases h : o = s
      · simp [spreadCost, h]
      · simp only [spreadCost, if_neg h, mul_one]
        have : (0 : ℚ) < 1 / ((n : ℚ) + 1) := by positivity
        linarith
  simp only [dialValue]
  rw [Finset.sum_congr rfl fun o _ => hfib o]
  simp [Finset.sum_const, Finset.card_univ]
  field_simp

/-- **The gap of the anti-diagonal portfolio is exactly `2n/(n+1)`.**  Since the
portfolio is `1`-invisible, the constant `2` in `eps_invisible_gap_le` is
approached but never exceeded. -/
theorem spread_gap (n : ℕ) :
    bestConstant (spreadW n) (spreadCost n) - dialValue (spreadW n) (spreadCost n) id
      = 2 * (n : ℚ) / (n + 1) := by
  have hn : ((n : ℚ) + 1) ≠ 0 := by positivity
  rw [spread_bestConstant, spread_dialValue]
  field_simp
  ring

/-- **The constant `2` is optimal.**  For every tolerance `δ > 0` there is a
`1`-invisible portfolio whose optimal dial beats the best static member by more
than `2 - δ`. -/
theorem eps_invisible_two_sharp (δ : ℚ) (hδ : 0 < δ) :
    ∃ n : ℕ,
      EpsInvisible (spreadW n) (spreadCost n) id (fun _ => (0 : ℚ)) 1 ∧
      2 - δ < bestConstant (spreadW n) (spreadCost n)
                - dialValue (spreadW n) (spreadCost n) id := by
  obtain ⟨n, hn⟩ := exists_nat_gt (2 / δ)
  refine ⟨n, spread_epsInvisible n, ?_⟩
  rw [spread_gap]
  have hpos : (0 : ℚ) < (n : ℚ) + 1 := by positivity
  rw [lt_div_iff₀ hpos]
  have h2 : 2 < δ * n := by
    have := (div_lt_iff₀ hδ).mp hn
    linarith
  nlinarith [hδ, h2]

/-! ## The naive converse fails

A zero dial gain does **not** certify `eps`-invisibility: if the members of the
portfolio are indistinguishable, no dial can gain anything however unbalanced the
fibers are. -/

/-- If every member has the same cost function, the optimal dial and the best
static member coincide, for *every* observation. -/
theorem gap_zero_of_identical_members [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S] (w : Ω → ℚ) (f : Ω → ℚ) (obs : Ω → O) :
    bestConstant w (fun (ω : Ω) (_ : S) => f ω)
      - dialValue w (fun (ω : Ω) (_ : S) => f ω) obs = 0 := by
  have hbest : bestConstant w (fun (ω : Ω) (_ : S) => f ω) = EV w f := by
    unfold bestConstant
    exact Finset.inf'_const (univ_nonempty (α := S)) (EV w f)
  have hfib : ∀ o : O,
      univ.inf' univ_nonempty (fiberVal w (fun (ω : Ω) (_ : S) => f ω) obs o)
        = ∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * f ω := by
    intro o
    exact Finset.inf'_const (univ_nonempty (α := S))
      (∑ ω ∈ univ.filter (fun ω => obs ω = o), w ω * f ω)
  have hdial : dialValue w (fun (ω : Ω) (_ : S) => f ω) obs = EV w f := by
    simp only [dialValue]
    rw [Finset.sum_congr rfl fun o _ => hfib o]
    exact Finset.sum_fiberwise (univ : Finset Ω) obs fun ω => w ω * f ω
  rw [hbest, hdial, sub_self]

/-- A two-instance portfolio with indistinguishable members. -/
def flatW : Fin 2 → ℚ := ![1/2, 1/2]

/-- Its cost matrix: `0` on the first instance, `2` on the second, for every
member. -/
def flatCost : Fin 2 → Fin 2 → ℚ := fun ω _ => if ω = 0 then 0 else 2

/-- **The converse of `eps_invisible_gap_le` is false.**  This portfolio has a
dial gain of exactly `0` on the finest possible observation, yet it is not
`eps`-invisible for any `eps < 1` and any mean profile `m` whatsoever: a null
dial measurement is *not* by itself a certificate of near-invisibility. -/
theorem gap_zero_not_epsInvisible :
    bestConstant flatW flatCost - dialValue flatW flatCost id = 0 ∧
      ∀ (m : Fin 2 → ℚ) (eps : ℚ), EpsInvisible flatW flatCost id m eps → 1 ≤ eps := by
  constructor
  · have : flatCost = fun ω _ : Fin 2 => (if ω = 0 then (0 : ℚ) else 2) := rfl
    rw [this]
    exact gap_zero_of_identical_members flatW (fun ω => if ω = 0 then (0 : ℚ) else 2) id
  · intro m eps h
    have hA := fiberVal_le_of_epsInvisible h 1 0
    have hB := le_fiberVal_of_epsInvisible h 0 0
    rw [fiberVal_id, fiberMass_id] at hA hB
    norm_num [flatW, flatCost] at hA hB
    linarith

/-- Consistency check against the exact theory: at `eps = 0` the stability bound
reproduces the collapse of the dial value onto the static value. -/
theorem gap_zero_of_invisible [Fintype Ω] [Fintype O] [DecidableEq O]
    [Fintype S] [Nonempty S]
    {w : Ω → ℚ} {cost : Ω → S → ℚ} {obs : Ω → O} {m : S → ℚ}
    (hw0 : ∀ ω, 0 ≤ w ω) (hw : ∑ ω, w ω = 1) (hinv : Invisible w cost obs m) :
    bestConstant w cost - dialValue w cost obs = 0 := by
  have hle := eps_invisible_gap_le hw0 hw (epsInvisible_zero_of_invisible hinv)
  have hge : dialValue w cost obs ≤ bestConstant w cost :=
    dialValue_le_bestConstant w cost obs
  linarith

end Probability.PortfolioRegret