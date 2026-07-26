/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Potential games and the Matching Pennies boundary example

This file develops a minimal framework for finite strategic games, exact
potential functions, and pure-strategy Nash equilibria.  The main positive
result, `exists_pureNash_of_exactPotential`, states that any finite game which
admits an exact potential function has a pure-strategy Nash equilibrium (a
maximizer of the potential).

As a boundary example we formalize *Matching Pennies*, the classic 2×2 zero-sum
game with no pure-strategy equilibrium.  We prove directly, by case analysis,
that it has no pure Nash equilibrium (`matchingPennies_no_pureNash`), and deduce
from the general theorem that it therefore admits no exact potential function
(`matchingPennies_no_exactPotential`).
-/
import Mathlib

namespace PotentialGames

open Function

/-- A (pure-strategy) profile assigns to each player `i` a strategy in `S i`. -/
def Profile {ι : Type*} (S : ι → Type*) : Type _ := ∀ i, S i

/-- The profile obtained from `p` by having player `i` unilaterally switch to
strategy `s`, leaving everyone else unchanged. -/
def deviate {ι : Type*} [DecidableEq ι] {S : ι → Type*}
    (p : Profile S) (i : ι) (s : S i) : Profile S :=
  Function.update p i s

/-- A profile `p` is a pure-strategy Nash equilibrium for the payoff family
`payoff` if no player can strictly improve their own payoff by deviating. -/
def IsPureNash {ι : Type*} [DecidableEq ι] {S : ι → Type*}
    (payoff : ι → Profile S → ℝ) (p : Profile S) : Prop :=
  ∀ (i : ι) (s : S i), payoff i (deviate p i s) ≤ payoff i p

/-- `Φ` is an exact potential function for `payoff` if every unilateral
deviation changes the deviating player's payoff by exactly the same amount as it
changes `Φ`. -/
def IsExactPotential {ι : Type*} [DecidableEq ι] {S : ι → Type*}
    (payoff : ι → Profile S → ℝ) (Φ : Profile S → ℝ) : Prop :=
  ∀ (i : ι) (p : Profile S) (s : S i),
    payoff i (deviate p i s) - payoff i p = Φ (deviate p i s) - Φ p

/-- **Existence of pure Nash equilibria in exact potential games.**
If the profile space is finite and nonempty and `Φ` is an exact potential for
`payoff`, then any maximizer of `Φ` is a pure-strategy Nash equilibrium.  The
proof uses only finiteness/nonemptiness of the profile space and maximization of
the potential; it is independent of the Matching Pennies example. -/
theorem exists_pureNash_of_exactPotential
    {ι : Type*} [DecidableEq ι] {S : ι → Type*}
    [Finite (Profile S)] [Nonempty (Profile S)]
    (payoff : ι → Profile S → ℝ) (Φ : Profile S → ℝ)
    (h : IsExactPotential payoff Φ) :
    ∃ p : Profile S, IsPureNash payoff p := by
  obtain ⟨p, hp⟩ := Finite.exists_max Φ
  refine ⟨p, ?_⟩
  intro i s
  have hpot := h i p s
  have hle : Φ (deviate p i s) ≤ Φ p := hp _
  linarith

/-! ## Matching Pennies -/

/-- The two players of Matching Pennies. -/
inductive MPPlayer : Type
  | row
  | col
  deriving DecidableEq, Fintype

/-- The two available moves. -/
inductive MPMove : Type
  | heads
  | tails
  deriving DecidableEq, Fintype

/-- Both players choose among the same two moves. -/
abbrev MPStrategy : MPPlayer → Type := fun _ => MPMove

instance : DecidableEq (Profile MPStrategy) := by
  unfold Profile MPStrategy; infer_instance

instance : Fintype (Profile MPStrategy) := by
  unfold Profile MPStrategy; infer_instance

instance : Nonempty (Profile MPStrategy) := ⟨fun _ => MPMove.heads⟩

/-- Payoffs of Matching Pennies.  Row earns `1` when the two moves match and
`-1` otherwise; Column earns the opposite. -/
def matchingPenniesPayoff : MPPlayer → Profile MPStrategy → ℝ :=
  fun player p =>
    match player with
    | .row => if p .row = p .col then 1 else -1
    | .col => if p .row = p .col then -1 else 1

/-- **Matching Pennies has no pure-strategy Nash equilibrium.**
Proved directly by case analysis on the two moves: in each of the four cases the
loser of the round can strictly improve by switching moves.  This proof is
self-contained and does not depend on `matchingPennies_no_exactPotential`. -/
theorem matchingPennies_no_pureNash :
    ¬ ∃ p : Profile MPStrategy, IsPureNash matchingPenniesPayoff p := by
  rintro ⟨p, hp⟩
  -- Case split on both players' moves; the losing player can profitably deviate.
  rcases hpr : p MPPlayer.row with _ | _ <;> rcases hpc : p MPPlayer.col with _ | _
  · -- (heads, heads): Column deviates to tails to break the match.
    have h := hp MPPlayer.col MPMove.tails
    simp only [matchingPenniesPayoff, deviate, hpr, hpc, Function.update_self,
      Function.update_of_ne (by decide : MPPlayer.row ≠ MPPlayer.col), reduceCtorEq,
      if_true, if_false] at h
    norm_num at h
  · -- (heads, tails): Row deviates to tails to create a match.
    have h := hp MPPlayer.row MPMove.tails
    simp only [matchingPenniesPayoff, deviate, hpr, hpc, Function.update_self,
      Function.update_of_ne (by decide : MPPlayer.col ≠ MPPlayer.row), reduceCtorEq,
      if_true, if_false] at h
    norm_num at h
  · -- (tails, heads): Row deviates to heads to create a match.
    have h := hp MPPlayer.row MPMove.heads
    simp only [matchingPenniesPayoff, deviate, hpr, hpc, Function.update_self,
      Function.update_of_ne (by decide : MPPlayer.col ≠ MPPlayer.row), reduceCtorEq,
      if_true, if_false] at h
    norm_num at h
  · -- (tails, tails): Column deviates to heads to break the match.
    have h := hp MPPlayer.col MPMove.heads
    simp only [matchingPenniesPayoff, deviate, hpr, hpc, Function.update_self,
      Function.update_of_ne (by decide : MPPlayer.row ≠ MPPlayer.col), reduceCtorEq,
      if_true, if_false] at h
    norm_num at h

/-- **Matching Pennies admits no exact potential function.**
If it did, the general existence theorem would yield a pure Nash equilibrium,
contradicting `matchingPennies_no_pureNash`. -/
theorem matchingPennies_no_exactPotential :
    ¬ ∃ Φ : Profile MPStrategy → ℝ, IsExactPotential matchingPenniesPayoff Φ := by
  rintro ⟨Φ, hΦ⟩
  obtain ⟨p, hp⟩ := exists_pureNash_of_exactPotential matchingPenniesPayoff Φ hΦ
  exact matchingPennies_no_pureNash ⟨p, hp⟩

end PotentialGames