#!/usr/bin/env python3
"""Numerical demonstrations for iterated Collatz-map obstructions."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List, Tuple


def collatz(n: int) -> int:
    """Return one Collatz step on a nonnegative integer."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return n // 2 if n % 2 == 0 else 3 * n + 1


def iterate_collatz(n: int, steps: int) -> int:
    """Apply the Collatz map exactly ``steps`` times."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    for _ in range(steps):
        n = collatz(n)
    return n


def trajectory(n: int, steps: int) -> List[int]:
    """Return the initial value and all states through the requested depth."""
    if steps < 0:
        raise ValueError("steps must be nonnegative")
    states = [n]
    for _ in range(steps):
        n = collatz(n)
        states.append(n)
    return states


def canonical_preimage(steps: int, target: int) -> int:
    """Construct the all-even depth-``steps`` preimage ``2**steps * target``."""
    if steps < 0 or target < 0:
        raise ValueError("steps and target must be nonnegative")
    return target << steps


def collision_pair(k: int) -> Tuple[int, int]:
    """Return the parameterized one-step collision (2k+1, 12k+8)."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    return 2 * k + 1, 12 * k + 8


@dataclass(frozen=True)
class InversionExample:
    steps: int
    target: int


def demonstrate_inversion(examples: Iterable[InversionExample]) -> None:
    """Print and verify canonical preimages and their all-even trajectories."""
    print("CANONICAL ALL-EVEN INVERSION")
    for example in examples:
        preimage = canonical_preimage(example.steps, example.target)
        path = trajectory(preimage, example.steps)
        assert path[-1] == example.target
        assert all(value % 2 == 0 for value in path[:-1])
        print(
            f"depth={example.steps:2d}, target={example.target:4d}, "
            f"preimage={preimage:8d}: " + " -> ".join(map(str, path))
        )


def demonstrate_collisions(parameters: Iterable[int], depth: int) -> None:
    """Print collision families and verify persistence at a common depth."""
    if depth <= 0:
        raise ValueError("depth must be positive")
    print(f"\nPARAMETERIZED COLLISIONS AT DEPTH {depth}")
    for k in parameters:
        left, right = collision_pair(k)
        common = 6 * k + 4
        assert left != right
        assert collatz(left) == common == collatz(right)
        left_end = iterate_collatz(left, depth)
        right_end = iterate_collatz(right, depth)
        assert left_end == right_end
        print(
            f"k={k:3d}: T({left}) = T({right}) = {common}; "
            f"T^{depth} endpoints both equal {left_end}"
        )


def demonstrate_composition(a: int, b: int, target: int) -> None:
    """Verify I_(a+b)(y) = I_a(I_b(y)) and inversion at total depth."""
    direct = canonical_preimage(a + b, target)
    staged = canonical_preimage(a, canonical_preimage(b, target))
    assert direct == staged
    assert iterate_collatz(direct, a + b) == target
    print("\nADDITIVE COMPOSITION OF CANONICAL PREIMAGES")
    print(f"I_({a}+{b})({target}) = {direct}")
    print(f"I_{a}(I_{b}({target})) = {staged}")


def main() -> None:
    demonstrate_inversion(
        [
            InversionExample(0, 19),
            InversionExample(3, 7),
            InversionExample(5, 13),
            InversionExample(8, 1),
        ]
    )
    demonstrate_collisions(range(6), depth=10)
    demonstrate_composition(a=4, b=7, target=9)
    print("\nAll identities verified for the displayed examples.")


if __name__ == "__main__":
    main()
