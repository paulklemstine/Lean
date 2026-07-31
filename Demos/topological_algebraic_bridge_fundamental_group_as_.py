#!/usr/bin/env python3
"""Finite demonstrations of groupoid compression and the discrete counterexample.

No third-party packages are required.  The connected groupoid used below has
objects 0,...,n-1 and arrows (source, group_element, target), with group
C_k = Z/kZ.  Composition adds labels modulo k.  It is equivalent to the
one-object groupoid BC_k, and conjugating an arrow to the basepoint recovers
its group label.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable


@dataclass(frozen=True)
class Arrow:
    """An arrow source -> target carrying an element of a cyclic vertex group."""

    source: int
    label: int
    target: int


def compose(first: Arrow, second: Arrow, modulus: int) -> Arrow:
    """Return second ∘ first in the standard connected C_modulus-groupoid."""
    if first.target != second.source:
        raise ValueError("arrows are not composable")
    return Arrow(first.source, (first.label + second.label) % modulus, second.target)


def inverse(arrow: Arrow, modulus: int) -> Arrow:
    """Return the inverse arrow."""
    return Arrow(arrow.target, (-arrow.label) % modulus, arrow.source)


def connected_cyclic_groupoid(objects: int, modulus: int) -> list[Arrow]:
    """Construct one arrow for every (source, label, target) triple."""
    if objects < 1 or modulus < 1:
        raise ValueError("objects and modulus must be positive")
    return [
        Arrow(source, label, target)
        for source in range(objects)
        for target in range(objects)
        for label in range(modulus)
    ]


def connector(base: int, target: int) -> Arrow:
    """Choose the zero-labelled reference arrow from base to target."""
    return Arrow(base, 0, target)


def encode_at_basepoint(arrow: Arrow, base: int, modulus: int) -> int:
    """Compute p_target^{-1} ∘ arrow ∘ p_source as a vertex-group element."""
    p_source = connector(base, arrow.source)
    p_target = connector(base, arrow.target)
    loop = compose(compose(p_source, arrow, modulus), inverse(p_target, modulus), modulus)
    if loop.source != base or loop.target != base:
        raise AssertionError("encoding did not produce a basepoint loop")
    return loop.label


def decode_from_basepoint(
    source: int, target: int, label: int, base: int, modulus: int
) -> Arrow:
    """Recover p_target ∘ label ∘ p_source^{-1} from a vertex-group element."""
    p_source = connector(base, source)
    p_target = connector(base, target)
    loop = Arrow(base, label % modulus, base)
    return compose(compose(inverse(p_source, modulus), loop, modulus), p_target, modulus)


def verify_compression(objects: int, modulus: int, base: int = 0) -> bool:
    """Check encode/decode and composition preservation for every finite arrow."""
    arrows = connected_cyclic_groupoid(objects, modulus)
    for arrow in arrows:
        label = encode_at_basepoint(arrow, base, modulus)
        if decode_from_basepoint(arrow.source, arrow.target, label, base, modulus) != arrow:
            return False
    for first in arrows:
        for second in arrows:
            if first.target == second.source:
                composite = compose(first, second, modulus)
                expected = (
                    encode_at_basepoint(first, base, modulus)
                    + encode_at_basepoint(second, base, modulus)
                ) % modulus
                if encode_at_basepoint(composite, base, modulus) != expected:
                    return False
    return True


def discrete_space_signature(points: int) -> tuple[int, int]:
    """Return (number of components, order of any based fundamental group)."""
    if points < 1:
        raise ValueError("a based finite space must be nonempty")
    return points, 1


def discrete_homotopy_equivalent(points_x: int, points_y: int) -> bool:
    """Decide homotopy equivalence for finite discrete spaces: it is cardinality."""
    if points_x < 0 or points_y < 0:
        raise ValueError("cardinalities must be nonnegative")
    return points_x == points_y


def print_discrete_table(sizes: Iterable[int]) -> None:
    """Print how identical fundamental groups coexist with distinct homotopy types."""
    print("points | components | |pi_1| | homotopy equivalent to one point?")
    print("-------+------------+--------+----------------------------------")
    for points in sizes:
        components, group_order = discrete_space_signature(points)
        equivalent = discrete_homotopy_equivalent(points, 1)
        print(f"{points:6d} | {components:10d} | {group_order:6d} | {str(equivalent):>32}")


def main() -> None:
    """Run both demonstrations."""
    object_count, modulus = 4, 3
    arrows = connected_cyclic_groupoid(object_count, modulus)
    print("CONNECTED GROUPOID COMPRESSION")
    print(f"Objects: {object_count}")
    print(f"Arrows in redundant presentation: {len(arrows)}")
    print(f"Arrows in one-object vertex group C_{modulus}: {modulus}")
    print(f"All encoding and composition checks pass: {verify_compression(object_count, modulus)}")
    sample = Arrow(2, 2, 3)
    encoded = encode_at_basepoint(sample, base=0, modulus=modulus)
    print(f"Sample arrow {sample} encodes as {encoded} and decodes as "
          f"{decode_from_basepoint(2, 3, encoded, 0, modulus)}")

    print("\nDISCRETE COUNTEREXAMPLE FAMILY")
    print_discrete_table(range(1, 7))
    assert discrete_space_signature(1)[1] == discrete_space_signature(2)[1]
    assert not discrete_homotopy_equivalent(1, 2)
    print("\nOne and two points have the same trivial based fundamental group,"
          " but are not homotopy equivalent.")


if __name__ == "__main__":
    main()
