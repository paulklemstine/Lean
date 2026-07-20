#!/usr/bin/env python3
"""Exact numerical demonstrations for the finite Boolean casino.

The script uses fractions throughout. It computes the Bayes threshold strategy,
the exact deck value, the regret of alternative strategies, and complementary-
world payoffs for finite weighted mixtures.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Iterable, Sequence

Truth = bool
Strategy = tuple[Truth, ...]
World = tuple[Truth, ...]


def unit_payoff(prediction: Truth, truth: Truth) -> int:
    """Return +1 for a correct Boolean prediction and -1 otherwise."""
    return 1 if prediction == truth else -1


def total_payoff(strategy: Sequence[Truth], world: Sequence[Truth]) -> int:
    """Compute additive unit-stake payoff in one world."""
    if len(strategy) != len(world):
        raise ValueError("strategy and world must have equal lengths")
    return sum(unit_payoff(prediction, truth) for prediction, truth in zip(strategy, world))


def card_expected_payoff(q: Fraction, prediction: Truth) -> Fraction:
    """Compute one-card expected payoff from its truth marginal."""
    return 2 * q - 1 if prediction else 1 - 2 * q


def bayes_strategy(probabilities: Sequence[Fraction]) -> Strategy:
    """Predict true exactly when the truth probability is at least one half."""
    half = Fraction(1, 2)
    return tuple(q >= half for q in probabilities)


def bayesian_payoff(probabilities: Sequence[Fraction], strategy: Sequence[Truth]) -> Fraction:
    """Compute the additive expected payoff of a deterministic strategy."""
    if len(probabilities) != len(strategy):
        raise ValueError("probabilities and strategy must have equal lengths")
    return sum(
        (card_expected_payoff(q, prediction) for q, prediction in zip(probabilities, strategy)),
        start=Fraction(0),
    )


def exact_bayesian_value(probabilities: Sequence[Fraction]) -> Fraction:
    """Return the sum of absolute marginal biases."""
    return sum((abs(2 * q - 1) for q in probabilities), start=Fraction(0))


def exact_regret(probabilities: Sequence[Fraction], strategy: Sequence[Truth]) -> Fraction:
    """Return twice the bias on precisely the cards that disagree with Bayes."""
    if len(probabilities) != len(strategy):
        raise ValueError("probabilities and strategy must have equal lengths")
    optimal = bayes_strategy(probabilities)
    return sum(
        (2 * abs(2 * q - 1) for q, choice, best in zip(probabilities, strategy, optimal) if choice != best),
        start=Fraction(0),
    )


def complement_world(world: Sequence[Truth]) -> World:
    """Reverse every truth value in a world."""
    return tuple(not truth for truth in world)


def mixed_payoff(
    weights: Sequence[Fraction], strategies: Sequence[Sequence[Truth]], world: Sequence[Truth]
) -> Fraction:
    """Compute the rational weighted payoff of finitely many strategies."""
    if len(weights) != len(strategies):
        raise ValueError("weights and strategies must have equal lengths")
    return sum(
        (weight * total_payoff(strategy, world) for weight, strategy in zip(weights, strategies)),
        start=Fraction(0),
    )


def all_strategies(n: int) -> Iterable[Strategy]:
    """Enumerate all Boolean strategies on n cards."""
    return product((False, True), repeat=n)


def demonstrate_exact_value() -> None:
    """Reproduce the five-card value 79/30 and verify global optimality."""
    probabilities = [Fraction(1, 2), Fraction(2, 3), Fraction(1, 4), Fraction(9, 10), Fraction(0)]
    optimal = bayes_strategy(probabilities)
    value = exact_bayesian_value(probabilities)
    direct = bayesian_payoff(probabilities, optimal)
    competitors = [(bayesian_payoff(probabilities, s), s) for s in all_strategies(len(probabilities))]
    maximum = max(score for score, _ in competitors)

    assert optimal == (True, True, False, True, False)
    assert value == direct == maximum == Fraction(79, 30)
    print("Five-card Bayes strategy:", optimal)
    print("Exact value:", value, "=", float(value))
    print("Best payoff among all 32 deterministic strategies:", maximum)


def demonstrate_regret() -> None:
    """Show that a fair-card mismatch is free and a biased mismatch is costly."""
    probabilities = [Fraction(1, 2), Fraction(2, 3), Fraction(1, 4), Fraction(9, 10), Fraction(0)]
    candidate = (False, True, True, True, False)
    optimal = bayes_strategy(probabilities)
    regret = exact_regret(probabilities, candidate)
    payoff_gap = bayesian_payoff(probabilities, optimal) - bayesian_payoff(probabilities, candidate)

    assert regret == payoff_gap == 1
    assert bayesian_payoff(probabilities, candidate) == Fraction(49, 30)
    print("Candidate strategy:", candidate)
    print("Exact regret:", regret)
    print("Candidate expected payoff:", bayesian_payoff(probabilities, candidate))


def demonstrate_no_free_lunch() -> None:
    """Verify complement reversal for a nontrivial rational strategy mixture."""
    weights = [Fraction(1, 2), Fraction(1, 3), Fraction(1, 6)]
    strategies = [
        (True, True, False, False),
        (False, True, True, False),
        (True, False, True, True),
    ]
    world = (True, False, False, True)
    opposite = complement_world(world)
    payoff = mixed_payoff(weights, strategies, world)
    opposite_payoff = mixed_payoff(weights, strategies, opposite)

    assert opposite_payoff == -payoff
    assert min(payoff, opposite_payoff) <= 0
    print("World and complement:", world, opposite)
    print("Mixed payoffs:", payoff, opposite_payoff)
    print("A nonpositive witness is:", world if payoff <= 0 else opposite)


def main() -> None:
    """Run all exact demonstrations."""
    demonstrate_exact_value()
    print()
    demonstrate_regret()
    print()
    demonstrate_no_free_lunch()


if __name__ == "__main__":
    main()
