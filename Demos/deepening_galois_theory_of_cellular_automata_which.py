#!/usr/bin/env python3
"""Numerical demonstrations for reversible elementary cellular automata.

The program uses only the Python standard library. It classifies all 256
Wolfram rules by bijectivity on cycles of lengths 1 through 4, displays the six
survivors, checks them on additional cycle lengths, and prints a short collision
witness for selected irreversible rules.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Optional


REVERSIBLE_RULES: tuple[int, ...] = (15, 51, 85, 170, 204, 240)


def bit(state: int, index: int, size: int) -> int:
    """Return the bit at a cyclic index of an encoded configuration."""
    return (state >> (index % size)) & 1


def local_output(rule: int, left: int, center: int, right: int) -> int:
    """Evaluate a Wolfram rule on one binary neighborhood."""
    neighborhood = 4 * left + 2 * center + right
    return (rule >> neighborhood) & 1


def global_step(rule: int, state: int, size: int) -> int:
    """Apply one synchronous update on a nonempty cyclic lattice."""
    if not 0 <= rule < 256:
        raise ValueError("rule must lie between 0 and 255")
    if size <= 0:
        raise ValueError("cycle size must be positive")
    output = 0
    for i in range(size):
        value = local_output(
            rule,
            bit(state, i - 1, size),
            bit(state, i, size),
            bit(state, i + 1, size),
        )
        output |= value << i
    return output


def state_string(state: int, size: int) -> str:
    """Render sites 0 through size-1 from left to right."""
    return "".join(str(bit(state, i, size)) for i in range(size))


@dataclass(frozen=True)
class Collision:
    """Two distinct inputs with the same global image."""

    size: int
    first: int
    second: int
    image: int


def collision_witness(rule: int, size: int) -> Optional[Collision]:
    """Return a collision if the global map is not injective."""
    first_preimage: dict[int, int] = {}
    for state in range(1 << size):
        image = global_step(rule, state, size)
        if image in first_preimage:
            return Collision(size, first_preimage[image], state, image)
        first_preimage[image] = state
    return None


def is_bijective_on_cycle(rule: int, size: int) -> bool:
    """Decide bijectivity of a rule on one finite cycle."""
    return collision_witness(rule, size) is None


def classify_rules(sizes: Iterable[int] = range(1, 5)) -> list[int]:
    """Return rules bijective on every requested cycle size."""
    checked_sizes = tuple(sizes)
    if not checked_sizes or any(size <= 0 for size in checked_sizes):
        raise ValueError("sizes must be a nonempty collection of positive integers")
    return [
        rule
        for rule in range(256)
        if all(is_bijective_on_cycle(rule, size) for size in checked_sizes)
    ]


def first_short_obstruction(rule: int, maximum_size: int = 4) -> Optional[Collision]:
    """Find the first collision on cycles up to maximum_size, if one exists."""
    for size in range(1, maximum_size + 1):
        witness = collision_witness(rule, size)
        if witness is not None:
            return witness
    return None


def inverse_step_for_six(rule: int, state: int, size: int) -> int:
    """Apply the explicit inverse of one of the six universally reversible rules."""
    if rule not in REVERSIBLE_RULES:
        raise ValueError("the explicit inverse is defined here only for the six classified rules")
    # Rule forms use source offsets -1, 0, +1. The inverse uses the opposite
    # offset and applies complement again when the forward rule complements.
    source_offset = {15: -1, 51: 0, 85: 1, 170: 1, 204: 0, 240: -1}[rule]
    complemented = rule in (15, 51, 85)
    output = 0
    for i in range(size):
        value = bit(state, i - source_offset, size)
        if complemented:
            value ^= 1
        output |= value << i
    return output


def demonstrate() -> None:
    """Run the classification, inverse checks, and obstruction examples."""
    survivors = classify_rules()
    print("Rules bijective on cycles of lengths 1, 2, 3, and 4:")
    print(survivors)
    assert tuple(survivors) == REVERSIBLE_RULES

    print("\nAdditional exhaustive inverse checks for the six survivors:")
    for rule in REVERSIBLE_RULES:
        for size in range(1, 9):
            for state in range(1 << size):
                image = global_step(rule, state, size)
                assert inverse_step_for_six(rule, image, size) == state
        print(f"  Rule {rule:3d}: explicit inverse succeeds through size 8")

    print("\nShort collision witnesses for representative excluded rules:")
    for rule in (0, 30, 90, 110, 255):
        witness = first_short_obstruction(rule)
        assert witness is not None
        n = witness.size
        print(
            f"  Rule {rule:3d}, size {n}: "
            f"{state_string(witness.first, n)} and "
            f"{state_string(witness.second, n)} both map to "
            f"{state_string(witness.image, n)}"
        )

    sample_rule, sample_size, sample_state = 15, 6, int("001101", 2)
    image = global_step(sample_rule, sample_state, sample_size)
    recovered = inverse_step_for_six(sample_rule, image, sample_size)
    print("\nExplicit round trip for rule 15 on a six-cell ring:")
    print(f"  input     = {state_string(sample_state, sample_size)}")
    print(f"  image     = {state_string(image, sample_size)}")
    print(f"  recovered = {state_string(recovered, sample_size)}")
    assert recovered == sample_state


if __name__ == "__main__":
    demonstrate()
