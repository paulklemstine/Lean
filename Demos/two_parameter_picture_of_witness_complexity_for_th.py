#!/usr/bin/env python3
"""Numerical demonstrations of Boolean-cube cone attachments.

The empty face is represented by ``frozenset()`` and is included throughout.
No third-party packages are required.
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations
from math import comb
from typing import FrozenSet, Hashable, Iterable, Sequence, TypeVar

Vertex = TypeVar("Vertex", bound=Hashable)
Face = FrozenSet[Vertex]


def powerset(items: Sequence[Vertex]) -> list[Face[Vertex]]:
    """Return every subset of ``items`` as a frozenset."""
    return [
        frozenset(choice)
        for size in range(len(items) + 1)
        for choice in combinations(items, size)
    ]


def cone_faces(apex: Vertex, base: Sequence[Vertex]) -> set[Face[Vertex]]:
    """Enumerate the faces created by coning a fresh apex over ``base``."""
    if apex in base:
        raise ValueError("The apex must be fresh relative to the base.")
    return {frozenset((apex,)) | face for face in powerset(base)}


def attach_cone(
    old_faces: Iterable[Face[Vertex]], apex: Vertex, base: Sequence[Vertex]
) -> set[Face[Vertex]]:
    """Attach one cone, rejecting an apex already used by an old face."""
    old = set(old_faces)
    if any(apex in face for face in old):
        raise ValueError("The apex must not occur in the old complex.")
    new = cone_faces(apex, base)
    if old & new:
        raise AssertionError("Freshness should make old and new faces disjoint.")
    return old | new


def stacked_face_count(k: int, steps: int) -> int:
    """Exact number of faces, including the empty face."""
    if k < 0 or steps < 0:
        raise ValueError("k and steps must be nonnegative.")
    return 2 ** (k + 1) + steps * 2**k


def proposed_bound(k: int, steps: int) -> int:
    """The comparison bound whose slack is exactly ``2**k - 1``."""
    if k < 0 or steps < 0:
        raise ValueError("k and steps must be nonnegative.")
    return 2**k * (steps + 1) + (2 ** (k + 1) - 1)


def face_vector(k: int, steps: int) -> list[int]:
    """Counts of faces by cardinality 0 through k+1."""
    if k < 0 or steps < 0:
        raise ValueError("k and steps must be nonnegative.")
    return [
        comb(k + 1, size)
        + (steps * comb(k, size - 1) if 1 <= size <= k + 1 else 0)
        for size in range(k + 2)
    ]


def build_example(k: int, steps: int) -> set[Face[int]]:
    """Build a stacked example by repeatedly attaching over the first k vertices."""
    base_simplex = list(range(k + 1))
    faces: set[Face[int]] = set(powerset(base_simplex))
    attaching_base = base_simplex[:k]
    for offset in range(steps):
        apex = k + 1 + offset
        faces = attach_cone(faces, apex, attaching_base)
    return faces


def demonstrate(k: int, steps: int) -> None:
    """Print and assert the exact count, face vector, and comparison slack."""
    faces = build_example(k, steps)
    exact = stacked_face_count(k, steps)
    bound = proposed_bound(k, steps)
    observed_vector_counter = Counter(len(face) for face in faces)
    observed_vector = [observed_vector_counter[size] for size in range(k + 2)]
    predicted_vector = face_vector(k, steps)

    assert len(faces) == exact
    assert observed_vector == predicted_vector
    assert sum(predicted_vector) == exact
    assert bound - exact == 2**k - 1

    n = k + 1 + steps
    print(f"k={k}, steps={steps}, vertices={n}")
    print(f"  exact total:       {exact}")
    print(f"  vertex-count form: {2**k * (n - k + 1)}")
    print(f"  face vector:       {predicted_vector}")
    print(f"  proposed bound:    {bound}")
    print(f"  exact slack:       {bound - exact}\n")


def main() -> None:
    """Run representative widths and a local Boolean-cube check."""
    for k, steps in [(0, 5), (1, 6), (2, 5), (3, 4), (5, 3)]:
        demonstrate(k, steps)

    local = cone_faces("v", ["a", "b", "c"])
    assert len(local) == 8
    histogram = Counter(len(face) for face in local)
    assert [histogram[j] for j in range(1, 5)] == [1, 3, 3, 1]
    print("One attachment over a 3-vertex face:")
    print("  8 new faces with cardinality distribution [1, 3, 3, 1].")
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
