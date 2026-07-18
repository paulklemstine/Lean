#!/usr/bin/env python3
"""Numerical demonstrations for structural cryptanalysis of the logistic map.

The script uses only Python's standard library. It demonstrates reflection
collisions with exact rational arithmetic, explicit inverse branches, the
angle-doubling orbit formula, exceptional short orbits, and cycle detection
for a fully specified fixed-point implementation.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from math import asin, sin, sqrt
from typing import Callable, Hashable, Iterable, TypeVar

T = TypeVar("T", bound=Hashable)


def logistic(x: float) -> float:
    """Return the parameter-four logistic update 4*x*(1-x)."""
    return 4.0 * x * (1.0 - x)


def logistic_fraction(x: Fraction) -> Fraction:
    """Evaluate the logistic update exactly over rational numbers."""
    return 4 * x * (1 - x)


def orbit(update: Callable[[T], T], seed: T, steps: int) -> list[T]:
    """Return the seed followed by ``steps`` successive states."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    values = [seed]
    for _ in range(steps):
        values.append(update(values[-1]))
    return values


def inverse_branches(y: float) -> tuple[float, float]:
    """Return the two real preimages in [0,1] of y in [0,1]."""
    if not 0.0 <= y <= 1.0:
        raise ValueError("y must lie in [0, 1]")
    root = sqrt(1.0 - y)
    return ((1.0 - root) / 2.0, (1.0 + root) / 2.0)


def chosen_ancestor(target: float, branches: Iterable[int]) -> float:
    """Follow an inverse path, where each branch is 0 (lower) or 1 (upper)."""
    value = target
    for branch in branches:
        if branch not in (0, 1):
            raise ValueError("branches must contain only 0 or 1")
        value = inverse_branches(value)[branch]
    return value


def inverse_tree(target: float, depth: int, tolerance: float = 1e-14) -> list[float]:
    """Enumerate numerically distinct depth-``depth`` ancestors of a target."""
    if depth < 0:
        raise ValueError("depth must be nonnegative")
    level = [target]
    for _ in range(depth):
        candidates = [x for y in level for x in inverse_branches(y)]
        candidates.sort()
        level = []
        for candidate in candidates:
            if not level or abs(candidate - level[-1]) > tolerance:
                level.append(candidate)
    return level


def angular_iterate(seed: float, n: int) -> float:
    """Evaluate f^n(seed) through seed = sin(theta)^2."""
    if not 0.0 <= seed <= 1.0 or n < 0:
        raise ValueError("seed must be in [0,1] and n must be nonnegative")
    theta = asin(sqrt(seed))
    return sin((2**n) * theta) ** 2


@dataclass(frozen=True)
class CycleData:
    """Transient and cycle information for a finite deterministic orbit."""

    transient_length: int
    cycle_length: int
    repeated_state: int
    visited_states: int


def fixed_point_update(state: int, bits: int) -> int:
    """Logistic update on integers 0..2^bits using nearest fixed-point rounding.

    The integer ``state`` represents the real number state/2^bits. The returned
    numerator is round(4*state*(2^bits-state)/2^bits), with integer half-up
    rounding, clamped to the representable closed unit interval.
    """
    if bits <= 0:
        raise ValueError("bits must be positive")
    scale = 1 << bits
    if not 0 <= state <= scale:
        raise ValueError("state is outside the fixed-point interval")
    numerator = 4 * state * (scale - state)
    rounded = (numerator + scale // 2) // scale
    return min(scale, rounded)


def find_cycle(update: Callable[[int], int], seed: int) -> CycleData:
    """Find a finite orbit's transient and period using first occurrences."""
    first_seen: dict[int, int] = {}
    state = seed
    index = 0
    while state not in first_seen:
        first_seen[state] = index
        state = update(state)
        index += 1
    start = first_seen[state]
    return CycleData(start, index - start, state, len(first_seen))


def demo_reflection() -> None:
    """Print an exact reflected-seed collision."""
    seed = Fraction(3, 10)
    reflected = 1 - seed
    left = orbit(logistic_fraction, seed, 5)
    right = orbit(logistic_fraction, reflected, 5)
    print("\n1. Exact reflection collision")
    print(f"seeds: {seed} and {reflected}")
    for n, (a, b) in enumerate(zip(left, right)):
        print(f"n={n}: {a} | {b} {'equal' if a == b else 'different'}")
    assert left[1:] == right[1:]


def demo_inverse() -> None:
    """Print explicit preimages and verify a selected depth-four ancestor."""
    target = 0.73
    lower, upper = inverse_branches(target)
    path = [0, 1, 1, 0]
    ancestor = chosen_ancestor(target, path)
    recovered = orbit(logistic, ancestor, len(path))[-1]
    print("\n2. Explicit inverse branches")
    print(f"target={target:.12f}")
    print(f"preimages={lower:.12f}, {upper:.12f}")
    print(f"forward errors={abs(logistic(lower)-target):.3e}, "
          f"{abs(logistic(upper)-target):.3e}")
    print(f"branch path={path}, ancestor={ancestor:.12f}, "
          f"depth-{len(path)} error={abs(recovered-target):.3e}")
    print(f"distinct depth-4 ancestors: {len(inverse_tree(target, 4))}")


def demo_angle_formula() -> None:
    """Compare recurrence and angular closed-form evaluation."""
    seed = 0.123456789
    values = orbit(logistic, seed, 12)
    print("\n3. Angle-doubling closed formula")
    print(" n       recurrence        angular formula      absolute error")
    for n, direct in enumerate(values):
        angular = angular_iterate(seed, n)
        print(f"{n:2d}  {direct: .12f}    {angular: .12f}      "
              f"{abs(direct-angular):.3e}")


def demo_exceptional_and_finite() -> None:
    """Show exceptional real orbits and finite-precision cycle data."""
    print("\n4. Exceptional seeds and finite-state cycles")
    print("orbit of 0:", orbit(logistic, 0.0, 5))
    print("orbit of 1/2:", orbit(logistic, 0.5, 5))
    bits = 12
    scale = 1 << bits
    for numerator in (0, scale // 2, 1234, 2345):
        data = find_cycle(lambda s: fixed_point_update(s, bits), numerator)
        print(f"{bits}-bit numerator {numerator:4d}: "
              f"transient={data.transient_length}, period={data.cycle_length}, "
              f"visited={data.visited_states}")
        assert data.visited_states <= scale + 1


def main() -> None:
    """Run all demonstrations."""
    print("Structural Cryptanalysis of the Parameter-Four Logistic Map")
    demo_reflection()
    demo_inverse()
    demo_angle_formula()
    demo_exceptional_and_finite()


if __name__ == "__main__":
    main()
