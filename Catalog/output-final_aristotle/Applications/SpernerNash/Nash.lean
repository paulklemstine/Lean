import Mathlib

/-!
# Finite two–player games, Nash equilibria, and the pure–deviation principle

Nash's theorem — every finite game has a mixed strategy equilibrium — is proved via
the Brouwer/Kakutani fixed point theorem, whose combinatorial core is Sperner's
lemma (developed in `Sperner1D.lean`).  This file sets up the algebraic side of the
story: finite two–player games, mixed strategies, expected payoffs, and Nash
equilibria, and proves the key structural fact that underlies every equilibrium
computation:

> **Pure–deviation principle.**  Because expected payoff is *linear* in each player's
> mixed strategy, a profile is a Nash equilibrium as soon as no player can gain by
> switching to a *pure* strategy.  One never has to test the (infinitely many) mixed
> deviations.

This is exactly the finiteness that makes Sperner/Brouwer based algorithms for Nash
equilibria possible: best responses can be read off from finitely many pure
strategies.

## Main results

* `SpernerNash.E1_linear_pure` / `E2_linear_pure` — expected payoff is the
  `p`-weighted (resp. `q`-weighted) average of the pure-strategy payoffs.
* `SpernerNash.isNash_of_pure` — the pure–deviation principle: checking pure
  deviations of both players suffices to certify a Nash equilibrium.
* `SpernerNash.matchingPennies_uniform_isNash` — the uniform profile is a Nash
  equilibrium of Matching Pennies (a game with *no* pure equilibrium).
* `SpernerNash.prisonersDilemma_defect_isNash` — mutual defection is a Nash
  equilibrium of the Prisoner's Dilemma.
-/

namespace SpernerNash

open Finset

/-- A finite two–player game: finite strategy sets `I`, `J` and real payoff
matrices `u1`, `u2` for the two players. -/
structure FinGame (I J : Type*) [Fintype I] [Fintype J] where
  /-- Payoff to player 1 when the pure strategies `(i, j)` are played. -/
  u1 : I → J → ℝ
  /-- Payoff to player 2 when the pure strategies `(i, j)` are played. -/
  u2 : I → J → ℝ

variable {I J : Type*} [Fintype I] [Fintype J]

/-- A mixed strategy is a probability distribution over a strategy set. -/
def IsDist (p : I → ℝ) : Prop := (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1

/-- The pure strategy `a`, viewed as a degenerate mixed strategy. -/
def pureDist [DecidableEq I] (a : I) : I → ℝ := fun i => if i = a then 1 else 0

/-- Expected payoff to player 1 under the mixed profile `(p, q)`. -/
def E1 (G : FinGame I J) (p : I → ℝ) (q : J → ℝ) : ℝ :=
  ∑ i, ∑ j, p i * q j * G.u1 i j

/-- Expected payoff to player 2 under the mixed profile `(p, q)`. -/
def E2 (G : FinGame I J) (p : I → ℝ) (q : J → ℝ) : ℝ :=
  ∑ i, ∑ j, p i * q j * G.u2 i j

/-- A profile `(p, q)` is a **Nash equilibrium**: both are distributions and neither
player can strictly improve by deviating to any other mixed strategy. -/
def IsNash (G : FinGame I J) (p : I → ℝ) (q : J → ℝ) : Prop :=
  IsDist p ∧ IsDist q ∧
    (∀ p', IsDist p' → E1 G p' q ≤ E1 G p q) ∧
    (∀ q', IsDist q' → E2 G p q' ≤ E2 G p q)

/-- The pure strategy distribution is indeed a probability distribution. -/
theorem pureDist_isDist [DecidableEq I] (a : I) : IsDist (pureDist a) := by
  exact ⟨ fun _ ↦ by unfold pureDist; split_ifs <;> norm_num,
    by unfold pureDist; rw [ Finset.sum_eq_single a ] <;> aesop ⟩

/-- Player 1's expected payoff against `q` when playing the pure strategy `a`. -/
theorem E1_pure [DecidableEq I] (G : FinGame I J) (a : I) (q : J → ℝ) :
    E1 G (pureDist a) q = ∑ j, q j * G.u1 a j := by
  unfold E1 pureDist
  rw [ Finset.sum_eq_single a ] <;> simp +contextual

/-- Player 2's expected payoff against `p` when playing the pure strategy `b`. -/
theorem E2_pure [DecidableEq J] (G : FinGame I J) (p : I → ℝ) (b : J) :
    E2 G p (pureDist b) = ∑ i, p i * G.u2 i b := by
  unfold E2 pureDist
  simp +decide

/-- **Linearity of expected payoff in player 1's strategy.**  The payoff of a mixed
strategy `p'` is the `p'`-weighted average of the pure-strategy payoffs. -/
theorem E1_linear_pure [DecidableEq I] (G : FinGame I J) (p' : I → ℝ) (q : J → ℝ) :
    E1 G p' q = ∑ i, p' i * E1 G (pureDist i) q := by
  simp only [E1_pure]
  simp +decide [ E1, Finset.mul_sum _ _ _, mul_assoc ]

/-- **Linearity of expected payoff in player 2's strategy.** -/
theorem E2_linear_pure [DecidableEq J] (G : FinGame I J) (p : I → ℝ) (q' : J → ℝ) :
    E2 G p q' = ∑ j, q' j * E2 G p (pureDist j) := by
  simp +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_left_comm, E2, pureDist ]
  exact Finset.sum_comm

/-- If no pure deviation of player 1 beats `p`, then no mixed deviation does. -/
theorem E1_le_of_pure_le [DecidableEq I] (G : FinGame I J) (p q : I → ℝ) (r : J → ℝ)
    (hpure : ∀ a, E1 G (pureDist a) r ≤ E1 G p r)
    (hq : IsDist q) : E1 G q r ≤ E1 G p r := by
  rw [ E1_linear_pure ]
  exact le_trans
    ( Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( hpure i ) ( hq.1 i ) )
    ( by simp +decide [ ← Finset.sum_mul, hq.2 ] )

/-- If no pure deviation of player 2 beats `q`, then no mixed deviation does. -/
theorem E2_le_of_pure_le [DecidableEq J] (G : FinGame I J) (p : I → ℝ) (q q' : J → ℝ)
    (hpure : ∀ b, E2 G p (pureDist b) ≤ E2 G p q)
    (hq' : IsDist q') : E2 G p q' ≤ E2 G p q := by
  convert Finset.sum_le_sum fun j _ => mul_le_mul_of_nonneg_left ( hpure j ) ( hq'.1 j ) using 1
  convert E2_linear_pure G p q'
  rw [ ← Finset.sum_mul _ _ _, hq'.2, one_mul ]

/-- **Pure–deviation principle for Nash equilibria.**  A profile of distributions is
a Nash equilibrium provided neither player can gain by deviating to a *pure*
strategy.  This reduces equilibrium verification to finitely many checks. -/
theorem isNash_of_pure [DecidableEq I] [DecidableEq J] (G : FinGame I J)
    (p : I → ℝ) (q : J → ℝ) (hp : IsDist p) (hq : IsDist q)
    (h1 : ∀ a, E1 G (pureDist a) q ≤ E1 G p q)
    (h2 : ∀ b, E2 G p (pureDist b) ≤ E2 G p q) :
    IsNash G p q :=
  ⟨hp, hq,
    fun p' hp' => E1_le_of_pure_le G p p' q h1 hp',
    fun q' hq' => E2_le_of_pure_le G p q q' h2 hq'⟩

/-! ### Matching Pennies

Player 1 wins on a match, player 2 wins on a mismatch.  There is no pure
equilibrium, yet the uniform profile is a (mixed) Nash equilibrium. -/

/-- The Matching Pennies game on strategy set `Bool`. -/
def matchingPennies : FinGame Bool Bool where
  u1 a b := if a = b then 1 else -1
  u2 a b := if a = b then -1 else 1

/-- The uniform mixed strategy on `Bool`. -/
noncomputable def unifBool : Bool → ℝ := fun _ => 1 / 2

/-- **Matching Pennies has a mixed Nash equilibrium**: both players randomising
uniformly is a Nash equilibrium (even though the game has no pure equilibrium). -/
theorem matchingPennies_uniform_isNash :
    IsNash matchingPennies unifBool unifBool := by
  apply isNash_of_pure
  · exact ⟨ fun _ => by norm_num [ unifBool ], by norm_num [ unifBool, Fintype.sum_bool ] ⟩
  · exact ⟨ fun _ => by norm_num [ unifBool ], by norm_num [ unifBool, Fintype.sum_bool ] ⟩
  · unfold E1; norm_num [ pureDist, unifBool, matchingPennies ]
  · intro b
    rw [E2_pure]
    have hrhs : E2 matchingPennies unifBool unifBool = 0 := by
      unfold E2; norm_num [ unifBool, matchingPennies, Fintype.sum_bool ]
    rw [hrhs]
    cases b <;> norm_num [ unifBool, matchingPennies, Fintype.sum_bool ]

/-! ### Prisoner's Dilemma

`false` = Cooperate, `true` = Defect.  Mutual defection is a Nash equilibrium. -/

/-- The Prisoner's Dilemma with the classic `(3,3), (0,5), (5,0), (1,1)` payoffs;
`false` = Cooperate, `true` = Defect. -/
def prisonersDilemma : FinGame Bool Bool where
  u1 a b := if a then (if b then 1 else 5) else (if b then 0 else 3)
  u2 a b := if b then (if a then 1 else 5) else (if a then 0 else 3)

/-- **Mutual defection is a Nash equilibrium** of the Prisoner's Dilemma. -/
theorem prisonersDilemma_defect_isNash :
    IsNash prisonersDilemma (pureDist true) (pureDist true) := by
  apply isNash_of_pure prisonersDilemma (pureDist true) (pureDist true)
  · exact pureDist_isDist _
  · exact pureDist_isDist _
  · unfold E1 prisonersDilemma pureDist; norm_num
  · simp +decide [ E2_pure, prisonersDilemma, pureDist ]

end SpernerNash