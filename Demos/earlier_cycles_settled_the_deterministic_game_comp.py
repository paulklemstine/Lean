#!/usr/bin/env python3
"""Numerical demonstrations for asymmetric Boolean wagers.

The calculations use Fraction, so every displayed value is exact.  No external
packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Iterable, Sequence


@dataclass(frozen=True)
class World:
    """A possible world with prior weight and a Boolean truth value."""

    name: str
    weight: Fraction
    truth: bool


def masses(worlds: Iterable[World]) -> tuple[Fraction, Fraction]:
    """Return total true-world and false-world mass."""
    true_mass = Fraction(0)
    false_mass = Fraction(0)
    for world in worlds:
        if world.truth:
            true_mass += world.weight
        else:
            false_mass += world.weight
    return true_mass, false_mass


def pure_values(
    true_mass: Fraction,
    false_mass: Fraction,
    reward: Fraction,
    loss: Fraction,
) -> tuple[Fraction, Fraction]:
    """Return (always-false value, always-true value)."""
    false_value = reward * false_mass - loss * true_mass
    true_value = reward * true_mass - loss * false_mass
    return false_value, true_value


def randomized_value(
    true_mass: Fraction,
    false_mass: Fraction,
    reward: Fraction,
    loss: Fraction,
    true_probability: Fraction,
) -> Fraction:
    """Expected value when true is selected with the given probability."""
    true_world_payoff = (reward + loss) * true_probability - loss
    false_world_payoff = reward - (reward + loss) * true_probability
    return true_world_payoff * true_mass + false_world_payoff * false_mass


def affine_value(
    false_value: Fraction,
    true_value: Fraction,
    true_probability: Fraction,
) -> Fraction:
    """Compute the same mixed value as an affine endpoint combination."""
    return true_probability * true_value + (1 - true_probability) * false_value


def optimal_action(
    true_mass: Fraction,
    false_mass: Fraction,
    reward: Fraction,
    loss: Fraction,
) -> tuple[str, Fraction]:
    """Return a maximizing action among false, true, and abstain."""
    false_value, true_value = pure_values(true_mass, false_mass, reward, loss)
    candidates = (("abstain", Fraction(0)), ("bet false", false_value), ("bet true", true_value))
    return max(candidates, key=lambda item: item[1])


def profitability_thresholds(reward: Fraction, loss: Fraction) -> tuple[Fraction, Fraction]:
    """Return (false-bet upper threshold, true-bet lower threshold)."""
    denominator = reward + loss
    if denominator <= 0:
        raise ValueError("reward + loss must be positive")
    return reward / denominator, loss / denominator


def format_fraction(value: Fraction) -> str:
    """Format an exact rational together with a decimal approximation."""
    return f"{value} ({float(value): .4f})"


def demonstrate_case(reward: int, loss: int, pi: Fraction, grid: Sequence[Fraction]) -> None:
    """Print endpoints, thresholds, optimum, and an affine identity check."""
    a, b = Fraction(reward), Fraction(loss)
    false_value, true_value = pure_values(pi, 1 - pi, a, b)
    false_threshold, true_threshold = profitability_thresholds(a, b)
    action, best = optimal_action(pi, 1 - pi, a, b)

    print(f"\nreward a={a}, loss b={b}, true mass pi={pi}")
    print(f"  false bet value: {format_fraction(false_value)}")
    print(f"  true bet value:  {format_fraction(true_value)}")
    print(f"  false is profitable below pi={false_threshold}")
    print(f"  true is profitable above pi={true_threshold}")
    print(f"  optimal with abstention: {action}, value {format_fraction(best)}")
    print("  randomized strategy line:")
    for r in grid:
        direct = randomized_value(pi, 1 - pi, a, b, r)
        affine = affine_value(false_value, true_value, r)
        assert direct == affine
        assert direct <= max(false_value, true_value)
        assert direct <= best
        print(f"    r={str(r):>4}: V(r)={format_fraction(direct)}")


def world_table_example() -> None:
    """Show that an entire finite world table compresses to two masses."""
    worlds = [
        World("alpha", Fraction(1, 12), True),
        World("beta", Fraction(1, 4), False),
        World("gamma", Fraction(1, 3), True),
        World("delta", Fraction(1, 3), False),
    ]
    true_mass, false_mass = masses(worlds)
    assert true_mass + false_mass == 1
    print("Finite-world aggregation")
    for world in worlds:
        print(f"  {world.name:>5}: weight={world.weight}, truth={world.truth}")
    print(f"  compressed masses: T={true_mass}, F={false_mass}")
    action, value = optimal_action(true_mass, false_mass, Fraction(1), Fraction(2))
    print(f"  with a=1, b=2: {action}, value={format_fraction(value)}")


def main() -> None:
    """Run exact examples covering fair, favorable, and punitive odds."""
    world_table_example()
    grid = [Fraction(0), Fraction(1, 4), Fraction(1, 2), Fraction(3, 4), Fraction(1)]
    cases = [
        (1, 1, Fraction(1, 2)),
        (2, 1, Fraction(1, 3)),
        (2, 1, Fraction(2, 3)),
        (1, 2, Fraction(1, 2)),
    ]
    for reward, loss, pi in cases:
        demonstrate_case(reward, loss, pi, grid)


if __name__ == "__main__":
    main()
