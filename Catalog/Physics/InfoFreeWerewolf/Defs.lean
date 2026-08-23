/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The information-free werewolf game: definitions

This file sets up the *information-free* (a.k.a. "blind") version of the classical
Werewolf / Mafia village game and its exact win probabilities.

## The model

A population consists of `v` villagers and `k` wolves.  Play proceeds in rounds,
each round consisting of a **day** followed by a **night**.

* **Day.** The village lynches one player chosen uniformly at random from all
  `v + k` living players.  This is the *information-free* assumption: nobody has
  any information, so the vote is a uniform draw.
* **Night.** If at least one wolf survives the day, the wolves eat one villager.

The village wins as soon as every wolf has been lynched; the wolves win as soon as
no villager is left.

## The parity trace

The crucial structural observation is that **the total population drops by exactly two
each round**, whatever happens:

* a *hit* (a wolf is lynched) removes one wolf by day and one villager by night;
* a *miss* (a villager is lynched) removes one villager by day and one more by night.

Hence the parity of the initial population `v + k` is a conserved quantity of the
game, propagated unchanged until absorption.  This is the mechanism behind the
even/odd oscillation that this development makes precise.

## Main definitions

* `InfoFreeWerewolf.failProb v k` : the probability that the **wolves** win, starting
  from `v` villagers and `k` wolves at the beginning of a day.
* `InfoFreeWerewolf.villageWin v k` : the complementary village win probability.
* `InfoFreeWerewolf.surv n` : the probability that one designated wolf is never
  lynched in a game whose initial population is `n`; equivalently the product
  `∏ (1 - 1/nᵢ)` along the deterministic population ladder `n, n-2, n-4, …`.
-/

namespace InfoFreeWerewolf

open Finset

/-- `failProb v k` is the probability that the wolves win the information-free game
started with `v` villagers and `k` wolves, at the beginning of a day.

The recursion reads: with probability `k / (v + k)` the day vote hits a wolf and the
state becomes `(v - 1, k - 1)` (one wolf lynched, one villager eaten at night); with
probability `v / (v + k)` the vote misses and the state becomes `(v - 2, k)`. -/
def failProb : ℕ → ℕ → ℚ
  | 0, 0 => 0
  | 0, _ + 1 => 1
  | _ + 1, 0 => 0
  | v + 1, k + 1 =>
      ((k + 1 : ℚ) * failProb v k + ((v : ℚ) + 1) * failProb (v - 1) (k + 1)) / ((v : ℚ) + k + 2)
termination_by v _ => v
decreasing_by all_goals omega

/-- The village win probability of the information-free game. -/
def villageWin (v k : ℕ) : ℚ := 1 - failProb v k

@[simp] theorem failProb_zero_zero : failProb 0 0 = 0 := by rw [failProb]

@[simp] theorem failProb_zero_succ (k : ℕ) : failProb 0 (k + 1) = 1 := by rw [failProb]

@[simp] theorem failProb_wolfless (v : ℕ) : failProb v 0 = 0 := by
  cases v <;> rw [failProb]

/-- The defining one-step recursion, in the form used throughout. -/
theorem failProb_step (v k : ℕ) :
    failProb (v + 1) (k + 1) =
      ((k + 1 : ℚ) * failProb v k + ((v : ℚ) + 1) * failProb (v - 1) (k + 1)) /
        ((v : ℚ) + k + 2) := by
  rw [failProb]

/-- Recursion in the "two villagers lost on a miss" form, valid once `v ≥ 2`. -/
theorem failProb_step' (v k : ℕ) :
    failProb (v + 2) (k + 1) =
      ((k + 1 : ℚ) * failProb (v + 1) k + ((v : ℚ) + 2) * failProb v (k + 1)) /
        ((v : ℚ) + k + 3) := by
  rw [show v + 2 = (v + 1) + 1 from rfl, failProb_step]
  simp only [Nat.add_sub_cancel]
  push_cast
  ring_nf

/-- Probability that one designated wolf is never lynched, as a function of the
initial population `n`.  It satisfies `surv n = surv (n-2) * (n-1)/n`, the product of
the per-round survival probabilities along the deterministic ladder
`n, n - 2, n - 4, …`. -/
def surv : ℕ → ℚ
  | 0 => 1
  | 1 => 1
  | (n + 2) => surv n * ((n : ℚ) + 1) / ((n : ℚ) + 2)

@[simp] theorem surv_zero : surv 0 = 1 := rfl
@[simp] theorem surv_one : surv 1 = 1 := rfl

theorem surv_succ_succ (n : ℕ) : surv (n + 2) = surv n * ((n : ℚ) + 1) / ((n : ℚ) + 2) := rfl

theorem surv_pos : ∀ n, 0 < surv n
  | 0 => by norm_num
  | 1 => by norm_num
  | (n + 2) => by
      rw [surv_succ_succ]
      have := surv_pos n
      positivity

theorem surv_le_one : ∀ n, surv n ≤ 1
  | 0 => le_rfl
  | 1 => le_rfl
  | (n + 2) => by
      rw [surv_succ_succ]
      have h := surv_le_one n
      have hp := surv_pos n
      rw [div_le_one (by positivity)]
      nlinarith

/-- `failProb` is a probability: it lies in `[0,1]`. -/
theorem failProb_nonneg : ∀ v k, 0 ≤ failProb v k
  | 0, 0 => by simp
  | 0, _ + 1 => by simp
  | v + 1, 0 => by simp
  | v + 1, k + 1 => by
      rw [failProb_step]
      have h1 := failProb_nonneg v k
      have h2 := failProb_nonneg (v - 1) (k + 1)
      positivity
termination_by v _ => v
decreasing_by all_goals omega

theorem failProb_le_one : ∀ v k, failProb v k ≤ 1
  | 0, 0 => by simp
  | 0, _ + 1 => by simp
  | v + 1, 0 => by simp
  | v + 1, k + 1 => by
      rw [failProb_step]
      have h1 := failProb_le_one v k
      have h2 := failProb_le_one (v - 1) (k + 1)
      rw [div_le_one (by positivity)]
      nlinarith [failProb_nonneg v k, failProb_nonneg (v - 1) (k + 1)]
termination_by v _ => v
decreasing_by all_goals omega

theorem villageWin_nonneg (v k : ℕ) : 0 ≤ villageWin v k := by
  have := failProb_le_one v k; simp [villageWin]; linarith

theorem villageWin_le_one (v k : ℕ) : villageWin v k ≤ 1 := by
  have := failProb_nonneg v k; simp [villageWin]; linarith

end InfoFreeWerewolf