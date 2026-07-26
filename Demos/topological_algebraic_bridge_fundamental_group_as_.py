#!/usr/bin/env python3
"""Finite demonstrations of connected-groupoid classification and its boundary."""
from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


@dataclass(frozen=True)
class Arrow:
    """An arrow between two objects, labelled by an element of a cyclic group."""

    source: int
    target: int
    label: int


class CyclicConnectedGroupoid:
    """Connected groupoid with n objects and vertex group Z/modulus Z."""

    def __init__(self, object_count: int, modulus: int) -> None:
        if object_count < 1 or modulus < 1:
            raise ValueError("object_count and modulus must be positive")
        self.object_count = object_count
        self.modulus = modulus

    def arrows(self) -> List[Arrow]:
        return [Arrow(a, b, g) for a in range(self.object_count)
                for b in range(self.object_count) for g in range(self.modulus)]

    def identity(self, obj: int) -> Arrow:
        return Arrow(obj, obj, 0)

    def inverse(self, arrow: Arrow) -> Arrow:
        return Arrow(arrow.target, arrow.source, (-arrow.label) % self.modulus)

    def compose(self, first: Arrow, second: Arrow) -> Arrow:
        """Return second after first."""
        if first.target != second.source:
            raise ValueError("arrows are not composable")
        return Arrow(first.source, second.target,
                     (first.label + second.label) % self.modulus)

    def vertex_group_table(self, base: int = 0) -> List[List[int]]:
        if not 0 <= base < self.object_count:
            raise ValueError("invalid base object")
        return [[(a + b) % self.modulus for b in range(self.modulus)]
                for a in range(self.modulus)]

    def encode_at_vertex(self, arrow: Arrow) -> int:
        """Encode an arrow by its loop label at the chosen reference vertex."""
        return arrow.label % self.modulus


def cyclic_groups_isomorphic(m: int, n: int) -> bool:
    """Two finite cyclic groups are isomorphic exactly when their orders agree."""
    return m == n


def brute_force_group_isomorphism(
    table_a: Sequence[Sequence[int]], table_b: Sequence[Sequence[int]]
) -> Optional[Tuple[int, ...]]:
    """Find a multiplication-preserving bijection between finite group tables."""
    n = len(table_a)
    if n != len(table_b) or any(len(row) != n for row in table_a + table_b):
        return None
    for candidate in permutations(range(n)):
        if candidate[0] != 0:
            continue
        if all(candidate[table_a[x][y]] == table_b[candidate[x]][candidate[y]]
               for x in range(n) for y in range(n)):
            return candidate
    return None


def discrete_fundamental_group_order(point_count: int, base: int = 0) -> int:
    """Return the order of the based fundamental group of a finite discrete space."""
    if point_count < 1 or not 0 <= base < point_count:
        raise ValueError("a valid basepoint is required")
    return 1


def discrete_spaces_homotopy_equivalent(point_count_a: int,
                                         point_count_b: int) -> bool:
    """Finite discrete spaces are homotopy equivalent exactly when cardinalities agree."""
    return point_count_a == point_count_b


def demonstrate_compression() -> None:
    large = CyclicConnectedGroupoid(object_count=5, modulus=4)
    small = CyclicConnectedGroupoid(object_count=2, modulus=4)
    different = CyclicConnectedGroupoid(object_count=5, modulus=3)
    print("CONNECTED GROUPOID COMPRESSION")
    print(f"large model: {large.object_count} objects, {len(large.arrows())} arrows")
    print(f"small model: {small.object_count} objects, {len(small.arrows())} arrows")
    print(f"both vertex groups have order {large.modulus}")
    print("equivalent by vertex-group classification:",
          cyclic_groups_isomorphic(large.modulus, small.modulus))
    print("different modulus gives equivalence:",
          cyclic_groups_isomorphic(large.modulus, different.modulus))
    print("vertex multiplication table for Z/4Z:")
    for row in large.vertex_group_table():
        print(" ", row)


def demonstrate_transport() -> None:
    model = CyclicConnectedGroupoid(object_count=3, modulus=5)
    f = Arrow(0, 1, 2)
    g = Arrow(1, 2, 4)
    composite = model.compose(f, g)
    print("\nTRANSPORT TO ONE VERTEX")
    print(f"labels {f.label} and {g.label} compose to {composite.label} modulo 5")
    print("composition is preserved:",
          model.encode_at_vertex(composite)
          == (model.encode_at_vertex(f) + model.encode_at_vertex(g)) % 5)


def demonstrate_counterexample() -> None:
    point_group = discrete_fundamental_group_order(1)
    two_point_group = discrete_fundamental_group_order(2)
    print("\nCOUNTEREXAMPLE OUTSIDE THE CONNECTED SETTING")
    print("fundamental-group orders:", point_group, two_point_group)
    print("based groups agree:", point_group == two_point_group)
    print("spaces homotopy equivalent:", discrete_spaces_homotopy_equivalent(1, 2))
    print("reason: a homotopy equivalence of discrete spaces must be a bijection")


def run_self_checks() -> None:
    for objects in range(1, 5):
        for modulus in range(1, 7):
            groupoid = CyclicConnectedGroupoid(objects, modulus)
            assert len(groupoid.arrows()) == objects * objects * modulus
            assert brute_force_group_isomorphism(
                groupoid.vertex_group_table(), groupoid.vertex_group_table()) is not None
    assert discrete_fundamental_group_order(1) == discrete_fundamental_group_order(2)
    assert not discrete_spaces_homotopy_equivalent(1, 2)


if __name__ == "__main__":
    run_self_checks()
    demonstrate_compression()
    demonstrate_transport()
    demonstrate_counterexample()
