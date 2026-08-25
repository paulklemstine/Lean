/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The exp-560 portfolio: an exact rational model of the measured winner shares

A concrete instance of the theory of `Probability.PortfolioRegretCore`, built so
that its numbers coincide *exactly* with the measured ones of experiment 560:

| member (index)        | oracle winner share |
| --------------------- | ------------------- |
| `ρ` (Pollard rho, 0)  | `0.580`             |
| `p-1 @ 256` (1)       | `0.345`             |
| `PM1 @ 1024` (2)      | `0.045`             |
| Fermat (3)            | `0.028`             |
| trial division (4)    | `0.002`             |

The instance space is `Fin 5 × Fin 2`: the first coordinate is the *hidden*
`p-1` powersmoothness class (which member of the portfolio will win), the second
is an *observable* bit (a bit-length / balance quintile marker), drawn
independently of the class.  Every member costs `1` on the class it wins and the
common penalty `1179/140` elsewhere.

The verified consequences are:

* `exp560_winner_shares` — the oracle winner shares are exactly the table above;
* `exp560_no_universal_winner` — every member loses on a set of positive mass,
  so no member dominates the portfolio;
* `exp560_staticRegret` — the static regret against the oracle is exactly
  `3.117`, matching the measured value;
* `exp560_no_dial_edge` — *no* rule reading the observable bit beats the best
  static member: a tuned dial provably tunes itself to do-nothing;
* `exp560_ml_rule_strictly_worse` — the two-armed "learned" rule is strictly
  worse, with expected cost exactly `279385/56000 ≈ 4.989`;
* `exp560_probe_threshold` — a probe that reveals the hidden smoothness class is
  worth its price exactly when the price is below `3.117`.
-/
import Mathlib
import Probability.PortfolioRegretCore

namespace Probability.PortfolioRegret

open Finset

/-! ## The model -/

/-- Masses of the five hidden powersmoothness classes: `0.580, 0.345, 0.045,
`0.028`, `0.002`. -/
def classW : Fin 5 → ℚ
  | 0 => 58/100
  | 1 => 69/200
  | 2 => 9/200
  | 3 => 7/250
  | 4 => 1/500

/-- The observable bit is a fair coin, independent of the hidden class. -/
def obsW : Fin 2 → ℚ
  | 0 => 1/2
  | 1 => 1/2

/-- Product weights on `Fin 5 × Fin 2`. -/
def exp560W : Fin 5 × Fin 2 → ℚ := fun x => classW x.1 * obsW x.2

/-- The common penalty paid by a member off its own class. -/
def penalty : ℚ := 1179/140

/-- Cost matrix: a member costs `1` on its class and `penalty` elsewhere. -/
def exp560Cost : Fin 5 × Fin 2 → Fin 5 → ℚ := fun x s => if s = x.1 then 1 else penalty

/-- The observation available to a scheduler: the `N`-visible bit only. -/
def exp560Obs : Fin 5 × Fin 2 → Fin 2 := Prod.snd

/-- Conditional mean cost of each member — the same on both fibers. -/
def exp560Mean : Fin 5 → ℚ := fun s => classW s + (1 - classW s) * penalty

theorem classW_sum : ∑ c, classW c = 1 := by
  norm_num [classW, Fin.sum_univ_five]

theorem exp560W_nonneg (x : Fin 5 × Fin 2) : 0 ≤ exp560W x := by
  obtain ⟨c, b⟩ := x
  fin_cases c <;> fin_cases b <;> norm_num [exp560W, classW, obsW]

theorem exp560W_sum : ∑ x, exp560W x = 1 := by
  norm_num [exp560W, classW, obsW, Fintype.sum_prod_type, Fin.sum_univ_five, Fin.sum_univ_two]

/-! ## The oracle and the winner shares -/

/-- The oracle always finishes at cost `1`: some member of the portfolio wins on
every hidden class. -/
theorem exp560_oracle (x : Fin 5 × Fin 2) : oracleCost exp560Cost x = 1 := by
  refine le_antisymm ?_ (Finset.le_inf' _ _ ?_)
  · have : exp560Cost x x.1 = 1 := by simp [exp560Cost]
    exact this ▸ Finset.inf'_le _ (mem_univ x.1)
  · intro s _
    by_cases h : s = x.1
    · simp [exp560Cost, h]
    · simp only [exp560Cost, if_neg h, penalty]
      norm_num

/-- Each member wins exactly on its own hidden class. -/
theorem exp560_winner_set (s : Fin 5) :
    (univ.filter (fun x : Fin 5 × Fin 2 => exp560Cost x s = oracleCost exp560Cost x))
      = univ.filter (fun x : Fin 5 × Fin 2 => x.1 = s) := by
  ext x
  simp only [mem_filter, mem_univ, true_and, exp560_oracle, exp560Cost]
  constructor
  · intro h
    by_cases hs : s = x.1
    · exact hs.symm
    · rw [if_neg hs] at h; exfalso; rw [penalty] at h; norm_num at h
  · intro h; rw [if_pos h.symm]

/-- **The measured winner shares.**  The oracle winner shares of the five
members are exactly `0.580, 0.345, 0.045, 0.028, 0.002`. -/
theorem exp560_winner_shares :
    (∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 =>
        exp560Cost x 0 = oracleCost exp560Cost x), exp560W x) = 58/100 ∧
    (∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 =>
        exp560Cost x 1 = oracleCost exp560Cost x), exp560W x) = 69/200 ∧
    (∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 =>
        exp560Cost x 2 = oracleCost exp560Cost x), exp560W x) = 9/200 ∧
    (∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 =>
        exp560Cost x 3 = oracleCost exp560Cost x), exp560W x) = 7/250 ∧
    (∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 =>
        exp560Cost x 4 = oracleCost exp560Cost x), exp560W x) = 1/500 := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
  · rw [exp560_winner_set]
    norm_num [Finset.sum_filter, exp560W, classW, obsW, Fintype.sum_prod_type,
      Fin.sum_univ_five, Fin.sum_univ_two]

/-- **No universal winner.**  Every member of the portfolio is strictly beaten by
the oracle on a set of positive mass, and every member wins on a set of positive
mass. -/
theorem exp560_no_universal_winner (s : Fin 5) :
    (∃ x : Fin 5 × Fin 2, oracleCost exp560Cost x < exp560Cost x s) ∧
    0 < ∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 => x.1 = s), exp560W x := by
  constructor
  · refine ⟨(s + 1, 0), ?_⟩
    have hne : s ≠ s + 1 := by
      fin_cases s <;> decide
    rw [exp560_oracle, exp560Cost, if_neg hne, penalty]
    norm_num
  · have : (univ.filter (fun x : Fin 5 × Fin 2 => x.1 = s)) = {(s, 0), (s, 1)} := by
      ext x
      obtain ⟨c, b⟩ := x
      fin_cases b <;> simp [Prod.ext_iff]
    rw [this]
    fin_cases s <;> norm_num [exp560W, classW, obsW]

/-! ## Invisibility of the observable bit -/

theorem obsW_eq (o : Fin 2) : obsW o = 1/2 := by fin_cases o <;> rfl

/-- The fiber of the observation map over `o` is the whole class axis. -/
theorem exp560_fiber (o : Fin 2) :
    (univ.filter (fun x : Fin 5 × Fin 2 => exp560Obs x = o))
      = univ.image (fun c : Fin 5 => (c, o)) := by
  ext x
  obtain ⟨c, b⟩ := x
  simp [exp560Obs, Prod.ext_iff, eq_comm]

theorem exp560_sum_fiber (o : Fin 2) (f : Fin 5 × Fin 2 → ℚ) :
    ∑ x ∈ univ.filter (fun x : Fin 5 × Fin 2 => exp560Obs x = o), f x = ∑ c : Fin 5, f (c, o) := by
  rw [exp560_fiber, Finset.sum_image (fun a _ b _ h => (Prod.ext_iff.mp h).1)]

/-- Averaging the cost of a fixed member over the hidden classes. -/
theorem classW_weighted (s : Fin 5) :
    ∑ c, classW c * (if s = c then (1 : ℚ) else penalty)
      = classW s + (1 - classW s) * penalty := by
  have hpt : ∀ c : Fin 5, classW c * (if s = c then (1 : ℚ) else penalty)
      = classW c * penalty + (if c = s then classW c * (1 - penalty) else 0) := by
    intro c
    by_cases h : c = s
    · subst h; simp; ring
    · simp [h, Ne.symm h]
  rw [Finset.sum_congr rfl (fun c _ => hpt c), Finset.sum_add_distrib,
    Finset.sum_ite_eq' univ s (fun c => classW c * (1 - penalty)), ← Finset.sum_mul, classW_sum]
  simp
  ring

theorem fiberMass_exp560 (o : Fin 2) : fiberMass exp560W exp560Obs o = 1/2 := by
  rw [fiberMass, exp560_sum_fiber o exp560W]
  simp only [exp560W]
  rw [← Finset.sum_mul, classW_sum, one_mul, obsW_eq]

/-- **Invisibility.**  Conditioned on the observable bit, every member of the
portfolio has the *same* mean cost on both fibers: the observation carries no
information about the winner. -/
theorem exp560_invisible : Invisible exp560W exp560Cost exp560Obs exp560Mean := by
  intro o s
  rw [exp560_sum_fiber o (fun x => exp560W x * exp560Cost x s), fiberMass_exp560,
    exp560Mean, ← classW_weighted s]
  have : ∀ c : Fin 5, exp560W (c, o) * exp560Cost (c, o) s
      = (1/2 : ℚ) * (classW c * (if s = c then (1 : ℚ) else penalty)) := by
    intro c
    simp only [exp560W, exp560Cost, obsW_eq]
    ring
  rw [Finset.sum_congr rfl (fun c _ => this c), ← Finset.mul_sum]

/-! ## Static value, regret, and the impotence of every dial -/

theorem exp560_ev_const (s : Fin 5) :
    EV exp560W (fun x => exp560Cost x s) = exp560Mean s :=
  ev_const_eq (obs := exp560Obs) exp560_invisible exp560W_sum s

/-- The best static member is `ρ`, with expected cost exactly `4.117`. -/
theorem exp560_bestConstant : bestConstant exp560W exp560Cost = 4117/1000 := by
  have hmean : ∀ s : Fin 5, EV exp560W (fun x => exp560Cost x s) = exp560Mean s :=
    exp560_ev_const
  have h0 : exp560Mean 0 = 4117/1000 := by norm_num [exp560Mean, classW, penalty]
  refine le_antisymm ?_ (Finset.le_inf' _ _ ?_)
  · calc bestConstant exp560W exp560Cost
        ≤ EV exp560W (fun x => exp560Cost x 0) := Finset.inf'_le _ (mem_univ 0)
      _ = 4117/1000 := by rw [hmean 0, h0]
  · intro s _
    rw [hmean s]
    fin_cases s <;> norm_num [exp560Mean, classW, penalty]

/-- The oracle has expected cost `1`. -/
theorem exp560_ev_oracle : EV exp560W (oracleCost exp560Cost) = 1 := by
  simp only [EV, exp560_oracle, mul_one]
  exact exp560W_sum

/-- **The measured static regret.**  The best static schedule loses exactly
`3.117` to the oracle — the number reported by experiment 560. -/
theorem exp560_staticRegret : staticRegret exp560W exp560Cost = 3117/1000 := by
  rw [staticRegret, exp560_bestConstant, exp560_ev_oracle]
  norm_num

/-- **No dial edge.**  Every scheduling rule that reads the observable bit is at
least as expensive as the best static member. -/
theorem exp560_no_dial_edge (π : Fin 2 → Fin 5) :
    4117/1000 ≤ EV exp560W (policyCost exp560Cost exp560Obs π) := by
  rw [← exp560_bestConstant]
  exact no_dial_edge exp560W_nonneg exp560W_sum exp560_invisible π

/-- **A learned rule is strictly worse.**  The two-armed rule that plays `ρ` on
one value of the observable and `p-1 @ 256` on the other has expected cost
`279385/56000 ≈ 4.989`, strictly above the static optimum `4.117`. -/
theorem exp560_ml_rule_strictly_worse :
    EV exp560W (policyCost exp560Cost exp560Obs ![0, 1]) = 279385/56000 ∧
    bestConstant exp560W exp560Cost < EV exp560W (policyCost exp560Cost exp560Obs ![0, 1]) := by
  have hval : EV exp560W (policyCost exp560Cost exp560Obs ![0, 1]) = 279385/56000 := by
    rw [ev_policy_eq_sum_fiber exp560_invisible ![0, 1]]
    rw [Fin.sum_univ_two, fiberMass_exp560 0, fiberMass_exp560 1]
    norm_num [exp560Mean, classW, penalty]
  refine ⟨hval, ?_⟩
  rw [hval, exp560_bestConstant]
  norm_num

/-- **Paid smoothness probes.**  Buying the hidden powersmoothness class at price
`κ` per instance beats the best static schedule exactly when `κ < 3.117`. -/
theorem exp560_probe_threshold (κ : ℚ) :
    EV exp560W (oracleCost exp560Cost) + κ < bestConstant exp560W exp560Cost ↔
      κ < 3117/1000 := by
  rw [paid_probe_beneficial_iff, exp560_staticRegret]

end Probability.PortfolioRegret