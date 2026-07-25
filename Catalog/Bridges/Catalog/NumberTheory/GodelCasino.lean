import Mathlib

/-!
# Gödel's Casino: finite betting games

This file isolates the probabilistic content of the proposed casino.  A card has a
Boolean truth value, and a deterministic player chooses a Boolean prediction.
A correct unit bet pays `+1`; an incorrect bet pays `-1`.

The first group of results is a no-free-lunch theorem: complementing every truth
value negates the player's total payoff, so no fixed strategy can have strictly
positive payoff in every possible world.  The second group gives the sharp
positive result: expected profit is positive exactly when aggregate predictive
accuracy exceeds one half.  In particular, per-card accuracy at least `2/3`
gives expected profit at least `1/3` per round, including an exact 1000-card
instance.
-/

namespace GodelCasino

/-- Payoff of a unit Boolean bet: `+1` if correct and `-1` if incorrect. -/
def unitPayoff (prediction truth : Bool) : ℤ :=
  if prediction = truth then 1 else -1

/-- Total payoff of a deterministic strategy against a truth assignment. -/
def totalPayoff {n : ℕ} (strategy truth : Fin n → Bool) : ℤ :=
  ∑ i, unitPayoff (strategy i) (truth i)

/-- Complement every truth value in a possible world. -/
def complementWorld {n : ℕ} (truth : Fin n → Bool) : Fin n → Bool :=
  fun i => !(truth i)

lemma unitPayoff_not_right (prediction truth : Bool) :
    unitPayoff prediction (!truth) = -unitPayoff prediction truth := by
  decide +revert

/-
The complementary possible world gives exactly the opposite payoff.
-/
theorem totalPayoff_complement {n : ℕ} (strategy truth : Fin n → Bool) :
    totalPayoff strategy (complementWorld truth) = -totalPayoff strategy truth := by
  unfold totalPayoff complementWorld;
  rw [ ← Finset.sum_neg_distrib ] ; congr ; ext i ; unfold unitPayoff ; aesop;

/-
No deterministic strategy wins strictly in both a world and its complement.
-/
theorem no_uniform_strict_win {n : ℕ} (strategy truth : Fin n → Bool) :
    ¬(0 < totalPayoff strategy truth ∧
      0 < totalPayoff strategy (complementWorld truth)) := by
  exact fun h => by linarith [ totalPayoff_complement strategy truth ] ;

/-
Consequently, every deterministic strategy has some possible world in which
its payoff is nonpositive.
-/
theorem exists_nonpositive_world {n : ℕ} (strategy : Fin n → Bool) :
    ∃ truth : Fin n → Bool, totalPayoff strategy truth ≤ 0 := by
  by_contra! h_contra;
  exact absurd ( no_uniform_strict_win strategy ( fun _ => Bool.true ) ) ( by aesop )

/-- Expected payoff when `p i` is the probability that prediction `i` is correct. -/
def expectedPayoff {n : ℕ} (p : Fin n → ℚ) : ℚ :=
  ∑ i, (2 * p i - 1)

/-
Expected payoff is twice the sum of success probabilities minus the number
of rounds.
-/
theorem expectedPayoff_eq {n : ℕ} (p : Fin n → ℚ) :
    expectedPayoff p = 2 * (∑ i, p i) - n := by
  unfold expectedPayoff
  rw [Finset.mul_sum]
  simp +decide

/-
Sharp aggregate criterion: expected profit is positive exactly when the sum
of success probabilities exceeds half the number of rounds.
-/
theorem expectedPayoff_pos_iff {n : ℕ} (p : Fin n → ℚ) :
    0 < expectedPayoff p ↔ (n : ℚ) / 2 < ∑ i, p i := by
  constructor <;> intro <;> rw [ lt_iff_not_ge ] at * <;> linarith [ expectedPayoff_eq p ]

/-
A uniform lower bound `q` on prediction accuracy gives total expected payoff
at least `n(2q-1)`.
-/
theorem expectedPayoff_lower_bound {n : ℕ} (p : Fin n → ℚ) (q : ℚ)
    (h : ∀ i, q ≤ p i) :
    (n : ℚ) * (2 * q - 1) ≤ expectedPayoff p := by
  rw [expectedPayoff_eq];
  linarith [ show ( ∑ i, p i : ℚ ) ≥ n * q by simpa using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h i ]

/-
Accuracy at least `2/3` guarantees expected profit at least `1/3` per card.
-/
theorem two_thirds_guarantee {n : ℕ} (p : Fin n → ℚ)
    (h : ∀ i, (2 : ℚ) / 3 ≤ p i) :
    (n : ℚ) / 3 ≤ expectedPayoff p := by
  have hbound := expectedPayoff_lower_bound p (2 / 3) h
  norm_num at hbound ⊢
  linarith

/-
Constant per-round accuracy has the expected linear payoff.
-/
theorem constant_accuracy_expected_payoff {n : ℕ} (q : ℚ) :
    expectedPayoff (fun _ : Fin n => q) = (n : ℚ) * (2 * q - 1) := by
  unfold expectedPayoff; norm_num; ring;

/-
The proposed 1000-round numerical benchmark, under the explicit and necessary
`2/3` per-round accuracy assumption.
-/
theorem thousand_round_guarantee (p : Fin 1000 → ℚ)
    (h : ∀ i, (2 : ℚ) / 3 ≤ p i) :
    (1000 : ℚ) / 3 ≤ expectedPayoff p := by
  convert two_thirds_guarantee p h using 1

/-
For 1000 cards whose predictions each succeed with probability exactly
`2/3`, the expected profit is exactly `1000/3`.
-/
theorem thousand_round_exact_two_thirds :
    expectedPayoff (fun _ : Fin 1000 => (2 : ℚ) / 3) = 1000 / 3 := by
  rw [constant_accuracy_expected_payoff]
  norm_num

/-
If each unresolved card is only a fair guess, its expected contribution is
zero; knowing `d` cards with certainty contributes exactly `d`.
-/
theorem known_and_fair_expected_payoff (d u : ℕ) :
    expectedPayoff (fun i : Fin (d + u) => if i.val < d then (1 : ℚ) else 1 / 2) = d := by
  unfold expectedPayoff;
  convert Finset.sum_range_add ( fun i => ( if i < d then 1 else 1 / 2 : ℚ ) * 2 - 1 ) d u using 1 <;> norm_num [ Finset.sum_range ];
  grind

/-
An adversary who makes every card opposite to the prediction forces the
exact worst-case payoff `-n`.
-/
theorem adversarial_world_exact {n : ℕ} (strategy : Fin n → Bool) :
    totalPayoff strategy (fun i => !(strategy i)) = -(n : ℤ) := by
  unfold totalPayoff;
  unfold unitPayoff; aesop;

/-
Making every card agree with the prediction gives the exact best-case
payoff `n`.
-/
theorem agreeing_world_exact {n : ℕ} (strategy : Fin n → Bool) :
    totalPayoff strategy strategy = n := by
  unfold totalPayoff;
  unfold unitPayoff; aesop;

/-
Averaging a world's payoff with that of its complement always gives zero.
-/
theorem complementary_pair_average_zero {n : ℕ}
    (strategy truth : Fin n → Bool) :
    ((totalPayoff strategy truth : ℚ) +
      totalPayoff strategy (complementWorld truth)) / 2 = 0 := by
  rw [totalPayoff_complement]
  norm_num

end GodelCasino