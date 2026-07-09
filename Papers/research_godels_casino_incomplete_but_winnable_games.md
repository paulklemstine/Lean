# Positive Expected Profit in Gödel's Casino via Model-Probability Measures

**Formalisation:** `Catalog/Bridges/GodelCasino.lean` (module `Bridges.GodelCasino`).
All results build against Lean 4 (`v4.28.0`) + Mathlib and depend only on the standard
axioms `propext`, `Classical.choice`, `Quot.sound` (no `sorry`, no custom axioms).

---

## 1. Problem statement

*Gödel's Casino* is a game in which a player bets on the truth value of arithmetic
statements that are independent of `ZFC`. Fix a "natural" probability measure `μ` on a
space `Ω` of models of `ZFC` — for concreteness one imagines a definable density on the
Gödel numbers of countable transitive models, but the arguments below only use that `μ`
is a probability measure. For a card (statement) `φ` the player commits to a bet,
possibly randomised, and *wins* on the set of models `W_φ ⊆ Ω` in which the bet agrees
with the truth value of `φ`. The card's **win-probability** is

```
p_φ := (μ W_φ).toReal ∈ [0, 1].
```

A correct bet pays `+1` and an incorrect bet pays `−1`, so the **expected payoff** of a
single card is

```
expectedPayoff(p_φ) = 2·p_φ − 1.
```

For a finite deck `D = (φ_i)_{i∈s}` the **total expected payoff** is the sum
`∑_{i∈s} (2·p_{φ_i} − 1)`.

**Central question.** Under what conditions is the total expected payoff of a finite
deck strictly positive?

## 2. Two calibrating strategies

* A *winnable* card, where the player can determine the truth in the ambient model, has
  a winning event of full measure, so `p_φ = 1` and expected payoff `+1`
  (`cardExpectedPayoff_winnable`).
* An undecidable card that the player *hedges* by flipping a fair coin has `p_φ = 1/2`
  and expected payoff `0` (`hedge_break_even`, `cardExpectedPayoff_hedge`).

Since an optimal player never does worse than hedging, the natural regime is
`p_φ ≥ 1/2` for every card, with `p_φ > 1/2` exactly on the cards the player can exploit.

## 3. Definitions (Lean)

| Concept | Lean name | Definition |
|---|---|---|
| Expected payoff of one card | `expectedPayoff p` | `2 * p - 1` |
| Total expected payoff of a deck | `totalExpectedPayoff s p` | `∑ i ∈ s, expectedPayoff (p i)` |
| Win-probability from a measure | `winProbability μ W` | `(μ W).toReal` |
| Card payoff from a winning event | `cardExpectedPayoff μ W` | `expectedPayoff (winProbability μ W)` |

The measure layer is certified honest: `winProbability_nonneg` and
`winProbability_le_one` show `winProbability μ W ∈ [0, 1]` whenever `μ` is a probability
measure.

## 4. Main theorems

1. **`hedge_break_even`** `: p = 1/2 → expectedPayoff p = 0`.
   A perfect hedge breaks even.

2. **`payoff_pos_iff`** `: 0 < expectedPayoff p ↔ 1/2 < p`.
   Positivity of a card's expected payoff is equivalent to beating the fair coin.

3. **`casino_positive_profit`** `: (∀ i ∈ s, 1/2 ≤ p i) → (∃ i ∈ s, 1/2 < p i) →
   0 < totalExpectedPayoff s p`.
   If every card at least breaks even and at least one card is strictly profitable, the
   whole deck is strictly profitable. *Proof idea:* every summand is `≥ 0`
   (`hall` + `payoff_pos_iff`), and the profitable card contributes a strictly positive
   summand that is dominated by the total (`Finset.single_le_sum`).

4. **`fraction_bound`** (quantitative) `: 0 < ε → (∀ i ∈ s, 1/2 ≤ p i) →
   α · #s ≤ #{i ∈ s : 1/2 + ε ≤ p i} → α · #s · (2ε) ≤ totalExpectedPayoff s p`.
   If a fraction `α` of the deck enjoys a uniform winning margin `ε`, the total profit is
   bounded below by `α · (deck size) · 2ε`. *Proof idea:* split the sum into the
   high-margin cards and the rest (`Finset.sum_filter_add_sum_filter_not`); the
   high-margin part is `≥ #good · 2ε` (`Finset.card_nsmul_le_sum`), the rest is `≥ 0`
   (`Finset.sum_nonneg`), and `#good ≥ α · #s` scales the bound.

5. **`casino_one_third_profit`** (corollary) `: s.Nonempty → (∀ i ∈ s, 1/2 ≤ p i) →
   #s / 3 ≤ #{i ∈ s : 1/2 < p i} → 0 < totalExpectedPayoff s p`.
   A nonempty deck in which at least a third of the cards are strictly profitable turns a
   strictly positive profit, regardless of the remaining (possibly perfectly
   undecidable) cards. *Proof idea:* the one-third hypothesis forces the profitable set
   nonempty, then `casino_positive_profit` applies.

## 5. A remark on the "ε depending only on α" phrasing

The original direction stated `fraction_bound` as producing a lower bound `α · n · ε`
"for some `ε > 0` depending only on `α`". That is not achievable: as a winning
probability decreases towards `1/2` from above, its expected payoff decreases towards
`0`, so no positive lower bound can depend on `α` alone — one can push the total profit
arbitrarily close to `0` while keeping the fraction `α` fixed. The faithful correction,
implemented here, makes the winning margin `ε` an explicit hypothesis: a fraction `α` of
the deck must satisfy `p ≥ 1/2 + ε`. The qualitative corollary
`casino_one_third_profit` needs no margin hypothesis, because on a *finite* deck the
finitely many strictly profitable cards automatically possess a positive minimal margin.

## 6. Scope and honesty of the model

The construction of a canonical probability measure on the countable transitive models
of `ZFC` is a deep (and, without further stipulation, under-determined) problem; it is
*not* claimed here. Instead the development is parametric in an arbitrary probability
measure `μ` on an arbitrary measurable space `Ω`, and the win-probabilities are exactly
`(μ W).toReal`. Every profit theorem is then a theorem about honest probabilities in
`[0,1]`, valid for *any* such measure — in particular for whichever measure on models of
`ZFC` one eventually adopts. The quantitative content lives entirely in the payoff
arithmetic and the finite-deck combinatorics, which is where the interesting inequalities
are and which is fully formalised.

## 7. Open questions

* **Canonical model-measure.** Is there a definable, base-independent probability measure
  on the countable transitive models of `ZFC` (e.g. via the constructible hierarchy or a
  Gödel-number density) for which the winning events `W_φ` of natural independent
  statements are measurable, and what are the induced `p_φ`?
* **Measurability of winning events.** For a fixed betting strategy, when is
  `W_φ = {ω : bet(ω) = truth_φ(ω)}` measurable, and how does `p_φ` depend on the
  strategy?
* **Beyond finite decks.** Extend `casino_positive_profit` / `fraction_bound` to
  countable decks with a summability / density hypothesis on `(2 p_i − 1)`, giving an
  asymptotic profit rate.
* **Adversarial house.** Model a house that chooses the deck to minimise profit subject
  to a fixed decidable fraction; compute the value of the resulting game.
* **Variance and risk.** Move from expected payoff to the full payoff distribution and
  study concentration (a law of large numbers / Hoeffding bound for the deck profit).
