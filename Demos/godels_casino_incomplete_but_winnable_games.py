#!/usr/bin/env python3
"""Numerical demonstrations for Gödel's Casino.

The script uses only the Python standard library. It audits deterministic
complement symmetry, evaluates exact expected-payoff formulas, and performs a
reproducible Monte Carlo study of the 1,000-card two-thirds benchmark.
"""

from __future__ import annotations

import random
from dataclasses import dataclass
from fractions import Fraction
from math import sqrt
from statistics import fmean, pstdev
from typing import Iterable, Sequence


@dataclass(frozen=True)
class SimulationSummary:
    rounds_per_trial: int
    trials: int
    accuracy: float
    theoretical_mean: float
    theoretical_standard_deviation: float
    sample_mean: float
    sample_standard_deviation: float
    minimum: int
    maximum: int
    losing_trials: int


def unit_payoff(prediction: bool, truth: bool) -> int:
    """Return +1 for a correct Boolean prediction and -1 otherwise."""
    return 1 if prediction == truth else -1


def total_payoff(predictions: Sequence[bool], truths: Sequence[bool]) -> int:
    """Compute total unit-stake payoff, rejecting arrays of unequal length."""
    if len(predictions) != len(truths):
        raise ValueError("predictions and truths must have equal length")
    return sum(unit_payoff(prediction, truth)
               for prediction, truth in zip(predictions, truths))


def complement_world(truths: Iterable[bool]) -> list[bool]:
    """Reverse every truth value in a possible world."""
    return [not truth for truth in truths]


def expected_payoff(probabilities: Iterable[Fraction]) -> Fraction:
    """Return the exact expectation sum_i (2 p_i - 1)."""
    return sum((2 * probability - 1 for probability in probabilities),
               start=Fraction(0))


def known_and_fair_expectation(known: int, unresolved: int) -> Fraction:
    """Evaluate a deck with certain known cards and unresolved fair guesses."""
    if known < 0 or unresolved < 0:
        raise ValueError("card counts must be nonnegative")
    probabilities = [Fraction(1)] * known + [Fraction(1, 2)] * unresolved
    return expected_payoff(probabilities)


def simulate_constant_accuracy(
    rounds_per_trial: int = 1000,
    trials: int = 20_000,
    accuracy: float = 2.0 / 3.0,
    seed: int = 20260718,
) -> SimulationSummary:
    """Simulate independent rounds and compare observations with exact theory."""
    if rounds_per_trial < 0 or trials <= 0:
        raise ValueError("rounds must be nonnegative and trials must be positive")
    if not 0.0 <= accuracy <= 1.0:
        raise ValueError("accuracy must lie in [0, 1]")

    generator = random.Random(seed)
    payoffs = [
        sum(1 if generator.random() < accuracy else -1
            for _ in range(rounds_per_trial))
        for _ in range(trials)
    ]
    theoretical_mean = rounds_per_trial * (2.0 * accuracy - 1.0)
    theoretical_sd = 2.0 * sqrt(rounds_per_trial * accuracy * (1.0 - accuracy))
    return SimulationSummary(
        rounds_per_trial=rounds_per_trial,
        trials=trials,
        accuracy=accuracy,
        theoretical_mean=theoretical_mean,
        theoretical_standard_deviation=theoretical_sd,
        sample_mean=fmean(payoffs),
        sample_standard_deviation=pstdev(payoffs),
        minimum=min(payoffs),
        maximum=max(payoffs),
        losing_trials=sum(payoff < 0 for payoff in payoffs),
    )


def demonstrate_complement_symmetry(seed: int = 314159, n: int = 1000) -> None:
    """Print exact complementary, adversarial, and agreeing-world identities."""
    generator = random.Random(seed)
    strategy = [bool(generator.getrandbits(1)) for _ in range(n)]
    world = [bool(generator.getrandbits(1)) for _ in range(n)]
    complement = complement_world(world)
    payoff = total_payoff(strategy, world)
    complement_payoff = total_payoff(strategy, complement)
    adversarial_payoff = total_payoff(strategy, complement_world(strategy))
    agreeing_payoff = total_payoff(strategy, strategy)

    assert complement_payoff == -payoff
    assert adversarial_payoff == -n
    assert agreeing_payoff == n
    print("Deterministic complement audit")
    print(f"  cards: {n}")
    print(f"  world payoff: {payoff:+d}")
    print(f"  complementary-world payoff: {complement_payoff:+d}")
    print(f"  pair sum: {payoff + complement_payoff}")
    print(f"  adversarial payoff: {adversarial_payoff:+d}")
    print(f"  agreeing payoff: {agreeing_payoff:+d}\n")


def main() -> None:
    demonstrate_complement_symmetry()

    exact = expected_payoff([Fraction(2, 3)] * 1000)
    mixed = known_and_fair_expectation(137, 863)
    assert exact == Fraction(1000, 3)
    assert mixed == 137
    print("Exact expectation audit")
    print(f"  1,000 cards at accuracy 2/3: {exact} = {float(exact):.6f}")
    print(f"  137 known and 863 fair cards: {mixed}\n")

    summary = simulate_constant_accuracy()
    print("Monte Carlo benchmark")
    print(f"  trials: {summary.trials:,}")
    print(f"  cards per trial: {summary.rounds_per_trial:,}")
    print(f"  theoretical mean: {summary.theoretical_mean:.6f}")
    print(f"  sample mean: {summary.sample_mean:.6f}")
    print(f"  theoretical standard deviation: "
          f"{summary.theoretical_standard_deviation:.6f}")
    print(f"  sample standard deviation: {summary.sample_standard_deviation:.6f}")
    print(f"  observed range: [{summary.minimum}, {summary.maximum}]")
    print(f"  losing trials: {summary.losing_trials:,}")


if __name__ == "__main__":
    main()
