#!/usr/bin/env python3
"""Numerical demonstrations of graded fixed-point averaging and conjugacy invariance."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations, product
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

T = TypeVar("T", bound=Hashable)
Permutation = tuple[int, ...]


@dataclass(frozen=True)
class GradeResult:
    """Fixed-point and orbit data for one finite group action."""

    name: str
    object_count: int
    fixed_counts: tuple[int, ...]
    orbit_count: int


def apply_permutation(permutation: Permutation, item: tuple[int, ...]) -> tuple[int, ...]:
    """Act on a tuple of vertex labels and return a canonically sorted tuple."""
    return tuple(sorted(permutation[index] for index in item))


def fixed_point_count(
    objects: Iterable[T], action: Callable[[T], T]
) -> int:
    """Count objects fixed by one action map."""
    return sum(1 for item in objects if action(item) == item)


def orbit_partition(
    objects: Iterable[T], actions: Sequence[Callable[[T], T]]
) -> list[set[T]]:
    """Partition a finite set into orbits under the supplied group actions."""
    unseen = set(objects)
    orbits: list[set[T]] = []
    while unseen:
        seed = next(iter(unseen))
        orbit = {action(seed) for action in actions}
        orbits.append(orbit)
        unseen.difference_update(orbit)
    return orbits


def analyze_grade(
    name: str, objects: Sequence[T], actions: Sequence[Callable[[T], T]]
) -> GradeResult:
    """Compute both sides of Burnside's coefficient identity for one grade."""
    fixed = tuple(fixed_point_count(objects, action) for action in actions)
    orbits = orbit_partition(objects, actions)
    assert sum(fixed) == len(actions) * len(orbits)
    return GradeResult(name, len(objects), fixed, len(orbits))


def square_rotation_demo() -> list[GradeResult]:
    """Analyze vertices and vertex pairs under the four rotations of a square."""
    rotations: tuple[Permutation, ...] = tuple(
        tuple((vertex + shift) % 4 for vertex in range(4)) for shift in range(4)
    )
    vertex_actions = [lambda x, p=p: p[x] for p in rotations]
    pair_actions = [lambda x, p=p: apply_permutation(p, x) for p in rotations]
    vertices = list(range(4))
    pairs = list(combinations(range(4), 2))
    return [
        analyze_grade("single vertices", vertices, vertex_actions),
        analyze_grade("unordered vertex pairs", pairs, pair_actions),
    ]


def rotate_coloring(coloring: tuple[int, ...], shift: int) -> tuple[int, ...]:
    """Rotate a cyclic coloring by ``shift`` positions."""
    size = len(coloring)
    result = [0] * size
    for index, color in enumerate(coloring):
        result[(index + shift) % size] = color
    return tuple(result)


def necklace_orbit_count(length: int, colors: int) -> tuple[tuple[int, ...], int]:
    """Count cyclic colorings by fixed-point averaging and direct orbits."""
    colorings = list(product(range(colors), repeat=length))
    actions = [lambda x, s=s: rotate_coloring(x, s) for s in range(length)]
    result = analyze_grade(
        f"{colors}-color necklaces of length {length}", colorings, actions
    )
    return result.fixed_counts, result.orbit_count


def permutation_inverse(permutation: Permutation) -> Permutation:
    """Return the inverse of a finite permutation."""
    inverse = [0] * len(permutation)
    for source, target in enumerate(permutation):
        inverse[target] = source
    return tuple(inverse)


def compose(left: Permutation, right: Permutation) -> Permutation:
    """Compose permutations as left after right."""
    return tuple(left[right[index]] for index in range(len(left)))


def conjugacy_demo() -> tuple[int, int]:
    """Verify equal fixed counts for conjugate transpositions in S3."""
    g: Permutation = (1, 0, 2)  # (0 1)
    h: Permutation = (1, 2, 0)  # (0 1 2)
    conjugate = compose(compose(h, g), permutation_inverse(h))
    points = list(range(3))
    fixed_g = fixed_point_count(points, lambda x: g[x])
    fixed_conjugate = fixed_point_count(points, lambda x: conjugate[x])
    assert fixed_g == fixed_conjugate
    return fixed_g, fixed_conjugate


def main() -> None:
    """Run all demonstrations and print readable certificates."""
    print("Square rotations, grade by grade")
    for result in square_rotation_demo():
        total = sum(result.fixed_counts)
        print(
            f"  {result.name}: |X|={result.object_count}, "
            f"fixed={result.fixed_counts}, sum={total}, "
            f"sum/|G|={total // 4}, orbits={result.orbit_count}"
        )

    print("\nBinary necklaces")
    for length in range(1, 9):
        fixed, orbits = necklace_orbit_count(length, 2)
        print(f"  length={length}: fixed={fixed}, orbit count={orbits}")

    left, right = conjugacy_demo()
    print("\nConjugacy invariance in S3")
    print(f"  conjugate transpositions have fixed counts {left} and {right}")


if __name__ == "__main__":
    main()
