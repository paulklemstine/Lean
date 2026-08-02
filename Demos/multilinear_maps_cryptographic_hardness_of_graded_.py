#!/usr/bin/env python3
"""Numerical demonstrations of exact and approximate game reductions.

The examples use exact rational arithmetic. They audit a mass-preserving
transcript permutation, compare source and target distinguishing advantages,
and verify the additive l1 game-hop bound over every Boolean distinguisher.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, Iterable, Mapping, Sequence, Tuple, TypeVar

Transcript = TypeVar("Transcript")
TargetTranscript = TypeVar("TargetTranscript")
Mass = Mapping[Transcript, Fraction]
Distinguisher = Callable[[Transcript], bool]


@dataclass(frozen=True)
class DecisionGame:
    """A finite real-versus-random game represented by exact mass tables."""

    random: Mapping[str, Fraction]
    real: Mapping[str, Fraction]

    def __post_init__(self) -> None:
        if set(self.random) != set(self.real):
            raise ValueError("Both worlds must use the same transcript space")
        for world in (self.random, self.real):
            if any(value < 0 for value in world.values()):
                raise ValueError("Masses must be nonnegative")
            if sum(world.values(), Fraction(0)) != 1:
                raise ValueError("Each world must have total mass one")


def acceptance(mass: Mapping[str, Fraction], accepts: Mapping[str, bool]) -> Fraction:
    """Return the mass of the distinguisher's acceptance set."""
    if set(mass) != set(accepts):
        raise ValueError("The decision table must cover exactly the transcript space")
    return sum((weight for point, weight in mass.items() if accepts[point]), Fraction(0))


def advantage(game: DecisionGame, accepts: Mapping[str, bool]) -> Fraction:
    """Return absolute real-versus-random acceptance difference."""
    return abs(acceptance(game.real, accepts) - acceptance(game.random, accepts))


def l1_gap(left: Mapping[str, Fraction], right: Mapping[str, Fraction]) -> Fraction:
    """Compute the l1 distance between two mass functions."""
    if set(left) != set(right):
        raise ValueError("Mass functions must use the same transcript space")
    return sum((abs(left[x] - right[x]) for x in left), Fraction(0))


def transport_game(source: DecisionGame, permutation: Mapping[str, str]) -> DecisionGame:
    """Transport both source worlds along a transcript bijection."""
    points = set(source.random)
    if set(permutation) != points or len(set(permutation.values())) != len(points):
        raise ValueError("The transcript map must be a bijection on the source space")
    random = {permutation[x]: source.random[x] for x in points}
    real = {permutation[x]: source.real[x] for x in points}
    return DecisionGame(random=random, real=real)


def pull_back_distinguisher(
    target_accepts: Mapping[str, bool], permutation: Mapping[str, str]
) -> Dict[str, bool]:
    """Compose a target decision table with the source-to-target map."""
    return {source: target_accepts[target] for source, target in permutation.items()}


def all_distinguishers(points: Sequence[str]) -> Iterable[Dict[str, bool]]:
    """Enumerate all Boolean distinguishers on a finite ordered space."""
    for bits in product((False, True), repeat=len(points)):
        yield dict(zip(points, bits))


def as_decimal(value: Fraction) -> str:
    """Format an exact rational as a decimal and fraction."""
    return f"{float(value):.6f} ({value})"


def exact_reduction_demo() -> None:
    """Demonstrate exact acceptance and advantage preservation."""
    source = DecisionGame(
        random={"s0": Fraction(40, 100), "s1": Fraction(30, 100),
                "s2": Fraction(20, 100), "s3": Fraction(10, 100)},
        real={"s0": Fraction(10, 100), "s1": Fraction(20, 100),
              "s2": Fraction(30, 100), "s3": Fraction(40, 100)},
    )
    permutation = {"s0": "t2", "s1": "t0", "s2": "t3", "s3": "t1"}
    target = transport_game(source, permutation)
    target_accepts = {"t0": False, "t1": True, "t2": False, "t3": True}
    source_accepts = pull_back_distinguisher(target_accepts, permutation)

    source_random = acceptance(source.random, source_accepts)
    source_real = acceptance(source.real, source_accepts)
    target_random = acceptance(target.random, target_accepts)
    target_real = acceptance(target.real, target_accepts)

    assert source_random == target_random
    assert source_real == target_real
    assert advantage(source, source_accepts) == advantage(target, target_accepts)

    print("EXACT MASS-PRESERVING REDUCTION")
    print(f"  random acceptance: {as_decimal(target_random)}")
    print(f"  real acceptance:   {as_decimal(target_real)}")
    print(f"  source advantage:  {as_decimal(advantage(source, source_accepts))}")
    print(f"  target advantage:  {as_decimal(advantage(target, target_accepts))}")
    print("  Result: acceptance in each world and advantage are identical.\n")


def approximate_game_hop_demo() -> None:
    """Verify the additive l1 bound for all 16 distinguishers on four points."""
    points = ("x0", "x1", "x2", "x3")
    source = DecisionGame(
        random=dict(zip(points, map(Fraction, ("0.40", "0.30", "0.20", "0.10")))),
        real=dict(zip(points, map(Fraction, ("0.10", "0.20", "0.30", "0.40")))),
    )
    target = DecisionGame(
        random=dict(zip(points, map(Fraction, ("0.39", "0.31", "0.21", "0.09")))),
        real=dict(zip(points, map(Fraction, ("0.12", "0.19", "0.29", "0.40")))),
    )
    delta_random = l1_gap(target.random, source.random)
    delta_real = l1_gap(target.real, source.real)

    largest_slack = Fraction(-10)
    largest_increase = Fraction(-10)
    checked = 0
    for accepts in all_distinguishers(points):
        source_adv = advantage(source, accepts)
        target_adv = advantage(target, accepts)
        bound = source_adv + delta_random + delta_real
        assert target_adv <= bound
        largest_slack = max(largest_slack, bound - target_adv)
        largest_increase = max(largest_increase, target_adv - source_adv)
        checked += 1

    epsilon = Fraction(5, 100)
    transferred_bound = epsilon + delta_random + delta_real
    print("APPROXIMATE GAME HOP")
    print(f"  random-world l1 gap: {as_decimal(delta_random)}")
    print(f"  real-world l1 gap:   {as_decimal(delta_real)}")
    print(f"  distinguishers exhaustively checked: {checked}")
    print(f"  largest observed advantage increase: {as_decimal(largest_increase)}")
    print(f"  theorem's additive allowance: {as_decimal(delta_random + delta_real)}")
    print(f"  if source hardness is 0.05, target bound is {as_decimal(transferred_bound)}")
    print("  Result: every Boolean acceptance set satisfies the additive bound.\n")


def graded_product_demo() -> None:
    """Illustrate level accounting with integer plaintext multiplication."""
    plaintexts = [2, 3, 5, 7]
    product_value = 1
    level = 0
    trace: list[Tuple[int, int]] = [(level, product_value)]
    for value in plaintexts:
        product_value *= value
        level += 1
        trace.append((level, product_value))

    assert level == len(plaintexts)
    assert product_value == 210
    print("CANONICAL GRADED PRODUCT")
    for current_level, value in trace:
        print(f"  level {current_level}: canonical plaintext product = {value}")
    print("  Result: four level-one inputs yield the level-four product 210.")


def main() -> None:
    exact_reduction_demo()
    approximate_game_hop_demo()
    graded_product_demo()


if __name__ == "__main__":
    main()
