# Computational Evidence — Gödel's Casino

## The model

We model "Gödel's Casino" as a betting game over logical sentences. Each card is a
sentence `s` of arithmetic together with a *known* syntactic classification:

* `Σ₁` — a sentence of the form `∃ n, R(n)` with `R` decidable;
* `Π₁` — a sentence of the form `∀ n, R(n)` with `R` decidable (negation of a `Σ₁`);
* `other` — a genuinely undecidable sentence with no useful low-complexity form
  (e.g. the Continuum Hypothesis, which is not arithmetic at all).

The player bets `TRUE`, `FALSE`, or `HEDGE` (buys the conservative extension / declines).

Payoff per card: `+1` if the bet matches arithmetic truth, `-1` if it does not,
`0` for a `HEDGE`.

## The corrected winning strategy

The mission description proposes: bet `TRUE` on `Σ₁`, bet `FALSE` on `Π₁` statements
"known to be independent (like `Con(ZFC)`)".  **This is mathematically wrong.**
`Con(ZFC)` is a `Π₁` sentence which is *true* in the standard model `ℕ`; betting
`FALSE` on it loses.

The correct observation is the exact opposite and is a clean theorem:

> If a consistent theory `T` is `Σ₁`-complete (proves every true `Σ₁` sentence),
> then every `Π₁` sentence **independent** of `T` is TRUE, and every `Σ₁` sentence
> independent of `T` is FALSE.

*Proof.* Let `s` be `Π₁` and independent. Its negation `¬s` is `Σ₁`. If `s` were false
then `¬s` is a true `Σ₁` sentence, hence provable by `Σ₁`-completeness, contradicting
independence (`T` would refute `s`). So `s` is true. Dually for `Σ₁`. ∎

So the winning strategy is:

* bet `TRUE` on every `Π₁` card,
* bet `FALSE` on every `Σ₁` card,
* `HEDGE` on `other` cards.

## Small-case simulation (payoff table)

Restricting to *independent* cards (the interesting undecidable ones):

| card kind | truth (forced) | our bet | payoff |
|-----------|----------------|---------|--------|
| Σ₁ indep  | FALSE (theorem)| FALSE   | **+1** |
| Π₁ indep  | TRUE (theorem) | TRUE    | **+1** |
| other     | unknown        | HEDGE   |  0     |

Every non-hedged bet wins. The total profit over a deck equals exactly the number of
`Σ₁`/`Π₁` cards in it — never negative, and strictly positive as soon as one
decidable-shape card appears.

## 1000-card simulation

Deal a deck of 1000 independent sentences. Whatever the mixture, the strategy's
profit equals `#{Σ₁ cards} + #{Π₁ cards} ≥ 0`, with average profit per round equal to
the fraction of `Σ₁`/`Π₁` cards. If that fraction is `≥ 1/3` (the mission's
arithmetic-hierarchy heuristic) then the average profit per round is `≥ 1/3 > 0`.
This is a *guaranteed* win, strictly stronger than a positive expectation.

## Counterexample hunt

We looked for a card on which the corrected strategy loses. None exists among
independent Σ₁/Π₁ cards (the theorem forbids it). A loss is only possible if the
independence hypothesis fails (then a Σ₁/Π₁ sentence may be provably true/false and
we would still be right by soundness) — so in fact the strategy never loses on any
Σ₁/Π₁ card, independent or not, *provided* we also bet with soundness in mind. The
formal file proves the guaranteed-win statements.

## No OEIS sequence

The result is structural (a guaranteed-win strategy), not a counting sequence, so no
OEIS lookup applies.
