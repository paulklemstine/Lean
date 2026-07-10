/-
# Gödel's Casino: Incomplete but Winnable Games

A playful conjecture (see the "Gödel's Casino" mission) proposes that undecidability
can be turned into a *winning* betting game: a player who bets on the truth values of
statements independent of a theory can guarantee a strictly positive expected profit
"even though individual bets are undecidable", with a claimed universal lower bound of
`1/3` per round.

This file builds a small, fully self-contained model of such a casino and settles the
conjecture. The verdict is **contrarian**: the optimistic conjecture is *false*, and we
prove precisely *why*.

## The model

Fix a finite space of models `Ω` (the "possible worlds" / models of the theory). A
`Statement` is identified with its truth value in each world, `s : Ω → Bool`. The player
places a bet `b : Bool`; in world `ω` the payoff is `+1` if the bet matches the truth
value there and `-1` otherwise (`payoff`). Two natural evaluations of a bet:

* worst-case (adversarial house that picks the world), and
* expected value under the uniform prior over worlds (`expProfit`).

## Main results

* `expProfit_zero_sum` : the game is zero-sum — betting TRUE and betting FALSE on the
  same statement have opposite expected profits, so they sum to `0`.
* `expProfit_valid` / `expProfit_unsat` : **decidable** statements are fully winnable:
  a valid statement pays `+1` for the TRUE bet, an unsatisfiable one `+1` for FALSE.
* `expProfit_balanced` : a **balanced** statement (true in exactly half the worlds)
  yields expected profit `0` for *every* bet.
* `independent_has_loss` : for a genuinely **independent** statement, *whatever* the player
  bets there is a world in which the payoff is `-1`. Hence the adversarial (guaranteed)
  profit is `≤ -1 < 0`: independence cannot be beaten in the worst case.
* `casino_no_edge_on_independent` : there is an independent statement on which every bet
  has expected profit exactly `0` — refuting "each undecidable bet is individually
  winnable with positive expected value".
* `no_one_third_bound` : a deck of balanced cards has average optimal profit `0`,
  refuting the claimed universal `≥ 1/3` lower bound.
* `decidable_deck_wins` : conversely, a deck consisting only of *decidable* (valid) cards
  wins every round (`= 1`).

The upshot: the player's entire edge comes from the *decidable* cards; genuine
incompleteness contributes exactly zero. Incompleteness is, in this precise betting
sense, a barrier after all — not a free lunch.

This development is elementary and self-contained (only finite sums over `ℚ`); it does not
attempt to formalize the arithmetic hierarchy or ZFC. It is a faithful model of the
*game-theoretic* content of the conjecture.
-/
import Mathlib

namespace GodelCasino

open Finset

variable {Ω : Type*} [Fintype Ω]

/-- A `Statement` is identified with its truth value in each model `ω : Ω`. -/
abbrev Statement (Ω : Type*) := Ω → Bool

/-- Per-model payoff of betting `b` on statement `s` in world `ω`:
`+1` if the bet matches the truth value there, `-1` otherwise. -/
def payoff (s : Statement Ω) (b : Bool) (ω : Ω) : ℚ :=
  if b = s ω then 1 else -1

/-- Expected profit of a bet `b` on `s` under the uniform prior over the finite world
space. -/
def expProfit (s : Statement Ω) (b : Bool) : ℚ :=
  (∑ ω, payoff s b ω) / Fintype.card Ω

/-- Number of worlds in which `s` is true. -/
def trueCount (s : Statement Ω) : ℕ := (univ.filter (fun ω => s ω = true)).card

/-- The optimal expected profit: the best of the two bets. -/
def optProfit (s : Statement Ω) : ℚ := max (expProfit s true) (expProfit s false)

/-- A statement is *valid* (a decidable truth) if it holds in every world. -/
def IsValid (s : Statement Ω) : Prop := ∀ ω, s ω = true

/-- A statement is *unsatisfiable* (a decidable falsehood) if it fails in every world. -/
def IsUnsat (s : Statement Ω) : Prop := ∀ ω, s ω = false

/-- A statement is *independent* if it is true in some world and false in another. -/
def IsIndependent (s : Statement Ω) : Prop := (∃ ω, s ω = true) ∧ (∃ ω, s ω = false)

/-- A statement is *balanced* if it is true in exactly half of the worlds. -/
def IsBalanced (s : Statement Ω) : Prop := 2 * trueCount s = Fintype.card Ω

/-! ## The game is zero-sum -/

omit [Fintype Ω] in
/-- In every world, betting TRUE and betting FALSE give opposite payoffs. -/
theorem payoff_zero_sum (s : Statement Ω) (ω : Ω) :
    payoff s true ω + payoff s false ω = 0 := by
  unfold payoff; cases s ω <;> norm_num

/-- The casino is a zero-sum game: the two bets on any statement have opposite expected
profits. In particular the house has no built-in edge — all edge must come from
*information* about the statement. -/
theorem expProfit_zero_sum (s : Statement Ω) :
    expProfit s true + expProfit s false = 0 := by
  unfold expProfit
  rw [← add_div, ← Finset.sum_add_distrib]
  simp only [payoff_zero_sum, Finset.sum_const_zero, zero_div]

/-! ## Decidable statements are winnable -/

/-- Betting TRUE on a valid statement wins every round: expected profit `1`. -/
theorem expProfit_valid [Nonempty Ω] {s : Statement Ω} (h : IsValid s) :
    expProfit s true = 1 := by
  have hval : ∀ ω, payoff s true ω = 1 := by
    intro ω; unfold payoff; rw [h ω]; simp
  unfold expProfit
  simp only [hval, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  have : (Fintype.card Ω : ℚ) ≠ 0 := by positivity
  field_simp

/-- Betting FALSE on an unsatisfiable statement wins every round: expected profit `1`. -/
theorem expProfit_unsat [Nonempty Ω] {s : Statement Ω} (h : IsUnsat s) :
    expProfit s false = 1 := by
  have hval : ∀ ω, payoff s false ω = 1 := by
    intro ω; unfold payoff; rw [h ω]; simp
  unfold expProfit
  simp only [hval, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  have : (Fintype.card Ω : ℚ) ≠ 0 := by positivity
  field_simp

/-! ## The exact expected-profit formula -/

/-- The total TRUE-payoff equals `2·(#true worlds) − (#worlds)`. -/
theorem sum_payoff_true (s : Statement Ω) :
    (∑ ω, payoff s true ω) = 2 * (trueCount s : ℚ) - (Fintype.card Ω : ℚ) := by
  have h1 : (∑ ω, payoff s true ω)
      = (∑ ω, (if s ω = true then (1:ℚ) else -1)) := by
    apply Finset.sum_congr rfl; intro ω _; unfold payoff
    rcases Bool.eq_false_or_eq_true (s ω) with h | h <;> simp [h]
  have hsplit := Finset.card_filter_add_card_filter_not
      (s := (univ : Finset Ω)) (fun ω => s ω = true)
  have hc : ((trueCount s : ℚ)) + ((univ.filter (fun ω => ¬ s ω = true)).card : ℚ)
      = (Fintype.card Ω : ℚ) := by
    unfold trueCount
    rw [Finset.card_univ] at hsplit
    exact_mod_cast hsplit
  rw [h1, Finset.sum_ite]
  simp only [Finset.sum_const, nsmul_eq_mul, mul_one, mul_neg]
  have hrw : ((univ.filter (fun ω => s ω = true)).card : ℚ) = trueCount s := rfl
  rw [hrw]
  linarith [hc]

/-- Expected profit of the TRUE bet in closed form: `(2·#true − #worlds)/#worlds`. -/
theorem expProfit_true_formula (s : Statement Ω) :
    expProfit s true
      = (2 * (trueCount s : ℚ) - (Fintype.card Ω : ℚ)) / (Fintype.card Ω : ℚ) := by
  unfold expProfit; rw [sum_payoff_true]

/-! ## Independence cannot be beaten -/

/-- A balanced statement yields expected profit `0` for *every* bet: it is not winnable. -/
theorem expProfit_balanced {s : Statement Ω} (h : IsBalanced s) (b : Bool) :
    expProfit s b = 0 := by
  have htrue : expProfit s true = 0 := by
    rw [expProfit_true_formula]
    have hz : (2 * (trueCount s : ℚ) - (Fintype.card Ω : ℚ)) = 0 := by
      have h' : (2 * (trueCount s : ℚ)) = (Fintype.card Ω : ℚ) := by
        have := h; unfold IsBalanced at this; exact_mod_cast this
      linarith
    rw [hz, zero_div]
  cases b with
  | true => exact htrue
  | false => have := expProfit_zero_sum s; linarith

omit [Fintype Ω] in
/-- Worst-case defeat: for an independent statement, whatever the player bets, there is a
world where the payoff is `-1`. So the guaranteed (adversarial) profit is `≤ -1 < 0`. -/
theorem independent_has_loss {s : Statement Ω} (h : IsIndependent s) (b : Bool) :
    ∃ ω, payoff s b ω = -1 := by
  obtain ⟨⟨ωt, ht⟩, ⟨ωf, hf⟩⟩ := h
  unfold payoff
  cases b with
  | true => exact ⟨ωf, by rw [hf]; simp⟩
  | false => exact ⟨ωt, by rw [ht]; simp⟩

omit [Fintype Ω] in
/-- Dually, for an independent statement there is always a world where the bet wins. -/
theorem independent_has_win {s : Statement Ω} (h : IsIndependent s) (b : Bool) :
    ∃ ω, payoff s b ω = 1 := by
  obtain ⟨⟨ωt, ht⟩, ⟨ωf, hf⟩⟩ := h
  unfold payoff
  cases b with
  | true => exact ⟨ωt, by rw [ht]; simp⟩
  | false => exact ⟨ωf, by rw [hf]; simp⟩

/-! ## Optimal profit -/

/-- The optimal profit is always nonnegative (choose the better of the two bets). -/
theorem optProfit_nonneg (s : Statement Ω) : 0 ≤ optProfit s := by
  unfold optProfit
  have := expProfit_zero_sum s
  rcases le_total 0 (expProfit s true) with h | h
  · exact le_max_of_le_left h
  · apply le_max_of_le_right; linarith

/-- A valid statement has optimal profit `1`. -/
theorem optProfit_valid [Nonempty Ω] {s : Statement Ω} (h : IsValid s) :
    optProfit s = 1 := by
  unfold optProfit
  rw [expProfit_valid h]
  have := expProfit_zero_sum s
  rw [expProfit_valid h] at this
  rw [show expProfit s false = -1 by linarith]
  norm_num

/-- A balanced (genuinely independent) statement has optimal profit `0`. -/
theorem optProfit_balanced {s : Statement Ω} (h : IsBalanced s) : optProfit s = 0 := by
  unfold optProfit
  rw [expProfit_balanced h true, expProfit_balanced h false]; simp

/-! ## Refuting the conjecture -/

/-- The two-world casino `s = id` on `Bool` is both independent and balanced. -/
theorem exists_balanced_independent :
    ∃ s : Statement Bool, IsIndependent s ∧ IsBalanced s := by
  refine ⟨id, ⟨⟨true, rfl⟩, ⟨false, rfl⟩⟩, ?_⟩
  unfold IsBalanced trueCount
  decide

/-- **Main contrarian theorem (expected value).** There is a genuinely independent
statement on which *no* bet has positive expected profit: both bets give exactly `0`.
This refutes the conjecture that each undecidable statement is individually winnable with
strictly positive expected value. -/
theorem casino_no_edge_on_independent :
    ∃ s : Statement Bool, IsIndependent s ∧ ∀ b, expProfit s b = 0 := by
  obtain ⟨s, hind, hbal⟩ := exists_balanced_independent
  exact ⟨s, hind, fun b => expProfit_balanced hbal b⟩

/-- Average optimal profit over a deck (one round per card, uniform over the deck). -/
def deckOptProfit (deck : List (Statement Ω)) : ℚ :=
  (deck.map optProfit).sum / deck.length

/-- **Refutation of the "≥ 1/3 per round" claim.** A nonempty deck of balanced cards has
average optimal profit `0`, hence not `≥ 1/3`. -/
theorem no_one_third_bound :
    ∃ deck : List (Statement Bool), deck ≠ [] ∧ deckOptProfit deck = 0 := by
  refine ⟨[id], by simp, ?_⟩
  have hbal : IsBalanced (id : Statement Bool) := by
    unfold IsBalanced trueCount; decide
  unfold deckOptProfit
  simp [optProfit_balanced hbal]

/-- The specific numeric bound really fails: the expected profit per round can be strictly
below `1/3` (indeed `0`). -/
theorem one_third_bound_false :
    ∃ deck : List (Statement Bool), deck ≠ [] ∧ deckOptProfit deck < 1 / 3 := by
  obtain ⟨deck, hne, h0⟩ := no_one_third_bound
  exact ⟨deck, hne, by rw [h0]; norm_num⟩

/-- **The edge comes only from decidable cards.** A nonempty deck of valid statements is
won every round: average optimal profit `1`. -/
theorem decidable_deck_wins {deck : List (Statement Ω)} [Nonempty Ω]
    (hne : deck ≠ []) (hv : ∀ s ∈ deck, IsValid s) : deckOptProfit deck = 1 := by
  unfold deckOptProfit
  have hmap : deck.map optProfit = deck.map (fun _ => (1:ℚ)) := by
    apply List.map_congr_left
    intro s hs; exact optProfit_valid (hv s hs)
  rw [hmap, List.map_const', List.sum_replicate, nsmul_eq_mul, mul_one]
  have hlen : (deck.length : ℚ) ≠ 0 := by
    simp [List.length_eq_zero_iff, hne]
  field_simp

/-! ## The abstract soundness / Σ₁ strategy -/

/-- **Soundness makes provable statements winnable.** If a proof system `Prov` only proves
valid statements (soundness), then betting TRUE on any provable statement wins every round.
This is the abstract form of the intended sub-strategy "bet TRUE on (provable) Σ₁
statements": provability plus soundness gives a real edge — but only because a provable
statement is, by soundness, *decidable-true*, not independent. -/
theorem sound_strategy_wins [Nonempty Ω] (Prov : Statement Ω → Prop)
    (hsound : ∀ s, Prov s → IsValid s) {s : Statement Ω} (hp : Prov s) :
    expProfit s true = 1 :=
  expProfit_valid (hsound s hp)

end GodelCasino