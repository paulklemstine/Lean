import Mathlib

/-!
# Positive Expected Profit in Gödel's Casino via Model-Probability Measures

## Informal setting

*Gödel's Casino* is a game in which a player bets on the truth value of arithmetic
statements that are independent of `ZFC`.  Fix a "natural" probability measure `μ` on a
space `Ω` of models of `ZFC` (for instance a definable density on the Gödel numbers of
countable transitive models).  For a card (statement) `φ` the player commits to a bet,
possibly randomised, and *wins* on those models `ω ∈ Ω` in which the bet agrees with the
truth value of `φ` in `ω`.  Writing `W_φ ⊆ Ω` for this **winning event**, the card's
**win-probability** is

```
p_φ := (μ W_φ).toReal ∈ [0, 1].
```

Two extreme strategies bracket the range of interest:

* a *winnable* card, where the player can determine the truth, has `W_φ` of full
  measure, so `p_φ = 1`;
* an undecidable card that the player *hedges* by flipping a fair coin has
  `p_φ = 1/2` (the bet is correct on exactly half of the models).

Since an optimal player never does worse than hedging, every card satisfies
`p_φ ≥ 1/2` in practice.

A correct bet pays `+1` and an incorrect bet pays `−1`, so the **expected payoff** of a
single card is `2 p_φ − 1`.  The central quantitative question is: when is the expected
total payoff of a finite deck strictly positive?

## Main results

* `GodelCasino.hedge_break_even` — a perfect hedge (`p = 1/2`) has expected payoff `0`.
* `GodelCasino.payoff_pos_iff` — `expectedPayoff p > 0 ↔ p > 1/2`.
* `GodelCasino.casino_positive_profit` — if every card in a finite deck has `p ≥ 1/2`
  and at least one has `p > 1/2`, the total expected payoff is strictly positive.
* `GodelCasino.fraction_bound` — a quantitative version: if every card has `p ≥ 1/2` and
  at least a fraction `α` of the deck has a uniform winning margin `p ≥ 1/2 + ε`, then
  the total expected payoff is at least `α · (deck size) · (2ε)`.
* `GodelCasino.casino_one_third_profit` — a nonempty deck in which every card has
  `p ≥ 1/2` and at least a third of the cards have `p > 1/2` yields strictly positive
  expected profit, regardless of the remaining cards.

The winning events live inside a genuine probability space; `winProbability` packages
`(μ W).toReal` and `winProbability_nonneg` / `winProbability_le_one` certify that it is
an honest probability in `[0, 1]`.

## Note on faithfulness

The direction phrases `fraction_bound` as giving a lower bound `α · n · ε` "for some
`ε > 0` depending only on `α`".  As stated that is not achievable: as a winning
probability decreases to `1/2` from above, its expected payoff decreases to `0`, so no
positive lower bound can depend on `α` alone.  We therefore make the winning margin `ε`
an explicit hypothesis (a fraction `α` of the deck satisfies `p ≥ 1/2 + ε`); the
resulting bound `α · n · (2ε)` is exactly the intended quantitative statement and is
provably true.  The qualitative corollary `casino_one_third_profit` needs no margin
hypothesis because on a finite deck the finitely many winning cards automatically have a
positive minimal margin.
-/

open MeasureTheory Finset

namespace GodelCasino

noncomputable section

/-- Expected payoff of a card with win-probability `p`: `+1` on a correct bet (weight
`p`) and `−1` on an incorrect bet (weight `1 − p`), i.e. `p - (1 - p) = 2p - 1`. -/
def expectedPayoff (p : ℝ) : ℝ := 2 * p - 1

/-- Total expected payoff of a finite deck, indexed by `s`, with win-probabilities `p`. -/
def totalExpectedPayoff {ι : Type*} (s : Finset ι) (p : ι → ℝ) : ℝ :=
  ∑ i ∈ s, expectedPayoff (p i)

/-- **Perfect hedge breaks even.** A card that is hedged to win-probability `1/2` has
expected payoff `0`. -/
theorem hedge_break_even {p : ℝ} (h : p = 1/2) : expectedPayoff p = 0 := by
  subst h; simp [expectedPayoff]

/-- **Positivity criterion.** A card's expected payoff is strictly positive exactly when
its win-probability exceeds `1/2`. -/
theorem payoff_pos_iff {p : ℝ} : 0 < expectedPayoff p ↔ 1/2 < p := by
  rw [expectedPayoff]; constructor <;> intro h <;> linarith

/-- **Positive expected profit.** If every card in a finite deck has win-probability at
least `1/2` and at least one card strictly exceeds `1/2`, then the total expected payoff
is strictly positive. -/
theorem casino_positive_profit {ι : Type*} (s : Finset ι) (p : ι → ℝ)
    (hall : ∀ i ∈ s, 1/2 ≤ p i) (hex : ∃ i ∈ s, 1/2 < p i) :
    0 < totalExpectedPayoff s p := by
  obtain ⟨j, hj, hjp⟩ := hex
  have hnn : ∀ i ∈ s, 0 ≤ expectedPayoff (p i) := by
    intro i hi; have := hall i hi; simp only [expectedPayoff]; linarith
  have hpos : 0 < expectedPayoff (p j) := by simp only [expectedPayoff]; linarith
  have hle := Finset.single_le_sum hnn hj
  exact lt_of_lt_of_le hpos hle

/-- **Quantitative fraction bound.** Suppose every card in a finite deck has
win-probability at least `1/2`, and at least a fraction `α` of the deck enjoys a uniform
winning margin, i.e. win-probability at least `1/2 + ε` with `ε > 0`.  Then the total
expected payoff is at least `α · (deck size) · (2ε)`. -/
theorem fraction_bound {ι : Type*} (s : Finset ι) (p : ι → ℝ) (α ε : ℝ)
    (hε : 0 < ε)
    (hall : ∀ i ∈ s, 1/2 ≤ p i)
    (hfrac : α * (s.card : ℝ) ≤
      ((s.filter (fun i => 1/2 + ε ≤ p i)).card : ℝ)) :
    α * (s.card : ℝ) * (2 * ε) ≤ totalExpectedPayoff s p := by
  classical
  set P : ι → Prop := fun i => 1/2 + ε ≤ p i with hP
  set good := s.filter P with hgood
  have hsplit :
      (∑ i ∈ good, expectedPayoff (p i))
        + (∑ i ∈ s.filter (fun i => ¬ P i), expectedPayoff (p i))
        = totalExpectedPayoff s p := by
    rw [hgood, totalExpectedPayoff]
    exact Finset.sum_filter_add_sum_filter_not s P _
  -- Lower bound on the "good" (high-margin) part.
  have hgoodlb : (good.card : ℝ) * (2 * ε) ≤ ∑ i ∈ good, expectedPayoff (p i) := by
    have h1 : ∀ i ∈ good, (2 * ε) ≤ expectedPayoff (p i) := by
      intro i hi
      rw [hgood, Finset.mem_filter] at hi
      have := hi.2
      simp only [expectedPayoff]; simp only [hP] at this; linarith
    have h2 := Finset.card_nsmul_le_sum good (fun i => expectedPayoff (p i)) (2 * ε) h1
    rwa [nsmul_eq_mul] at h2
  -- The remaining cards are individually non-negative (they hedge or better).
  have hrestnn : 0 ≤ ∑ i ∈ s.filter (fun i => ¬ P i), expectedPayoff (p i) := by
    apply Finset.sum_nonneg
    intro i hi
    rw [Finset.mem_filter] at hi
    have := hall i hi.1
    simp only [expectedPayoff]; linarith
  have hfrac' : α * (s.card : ℝ) * (2 * ε) ≤ (good.card : ℝ) * (2 * ε) := by
    apply mul_le_mul_of_nonneg_right _ (by positivity)
    rw [hgood]; exact hfrac
  calc α * (s.card : ℝ) * (2 * ε)
      ≤ (good.card : ℝ) * (2 * ε) := hfrac'
    _ ≤ ∑ i ∈ good, expectedPayoff (p i) := hgoodlb
    _ ≤ totalExpectedPayoff s p := by rw [← hsplit]; linarith

/-- **One-third corollary.** A nonempty deck in which every card has win-probability at
least `1/2` and at least a third of the cards strictly exceed `1/2` yields strictly
positive expected profit, no matter how undecidable the remaining cards are. -/
theorem casino_one_third_profit {ι : Type*} (s : Finset ι) (p : ι → ℝ)
    (hs : s.Nonempty)
    (hall : ∀ i ∈ s, 1/2 ≤ p i)
    (hthird : (s.card : ℝ) / 3 ≤ ((s.filter (fun i => 1/2 < p i)).card : ℝ)) :
    0 < totalExpectedPayoff s p := by
  classical
  apply casino_positive_profit s p hall
  set good := s.filter (fun i => 1/2 < p i) with hgood
  have hc : 0 < s.card := Finset.card_pos.mpr hs
  have hpos : (0 : ℝ) < (good.card : ℝ) := by
    have : (0 : ℝ) < (s.card : ℝ) / 3 := by positivity
    linarith
  have hgc : 0 < good.card := by exact_mod_cast hpos
  obtain ⟨i, hi⟩ := Finset.card_pos.mp hgc
  rw [hgood, Finset.mem_filter] at hi
  exact ⟨i, hi.1, hi.2⟩

/-! ### Measure-theoretic win probabilities

The win-probability of a card is the measure of its winning event inside a genuine
probability space of models. -/

/-- Win-probability of a card: the (real-valued) measure of the set of models `W` in
which the player's optimal bet matches the truth of the statement. -/
def winProbability {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (W : Set Ω) : ℝ :=
  (μ W).toReal

theorem winProbability_nonneg {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (W : Set Ω) : 0 ≤ winProbability μ W := ENNReal.toReal_nonneg

theorem winProbability_le_one {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (W : Set Ω) : winProbability μ W ≤ 1 := by
  have h : μ W ≤ 1 := prob_le_one
  calc winProbability μ W = (μ W).toReal := rfl
    _ ≤ (1 : ENNReal).toReal := ENNReal.toReal_mono (by simp) h
    _ = 1 := by simp

/-- Expected payoff of a card whose winning event is `W` under the model-measure `μ`. -/
def cardExpectedPayoff {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (W : Set Ω) : ℝ :=
  expectedPayoff (winProbability μ W)

/-- A hedged card, whose winning event has measure exactly `1/2`, breaks even. -/
theorem cardExpectedPayoff_hedge {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (W : Set Ω) (h : winProbability μ W = 1/2) : cardExpectedPayoff μ W = 0 :=
  hedge_break_even h

/-- A card with winning event of full measure (a winnable statement, `p = 1`) has the
maximal expected payoff `1`. -/
theorem cardExpectedPayoff_winnable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (W : Set Ω) (h : winProbability μ W = 1) : cardExpectedPayoff μ W = 1 := by
  rw [cardExpectedPayoff, h, expectedPayoff]; norm_num

end

end GodelCasino