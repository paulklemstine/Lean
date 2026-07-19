#!/usr/bin/env python3
"""Numerical experiments for preferred-generated argumentation complexes.

The script uses only the Python standard library.  It enumerates admissible,
preferred, complete, and grounded extensions; constructs the downward closure
of preferred extensions; and computes simplicial Betti numbers over F_2.
"""
from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple

Face = FrozenSet[int]
Attack = Tuple[int, int]


@dataclass(frozen=True)
class Framework:
    """A finite directed argumentation framework on vertices 0,...,n-1."""

    n: int
    attacks: FrozenSet[Attack]

    def subsets(self) -> Iterable[Face]:
        vertices = range(self.n)
        for size in range(self.n + 1):
            for subset in combinations(vertices, size):
                yield frozenset(subset)

    def conflict_free(self, subset: Face) -> bool:
        return all((a, b) not in self.attacks for a in subset for b in subset)

    def defends(self, subset: Face, argument: int) -> bool:
        attackers = (b for b in range(self.n) if (b, argument) in self.attacks)
        return all(any((c, b) in self.attacks for c in subset) for b in attackers)

    def admissible(self, subset: Face) -> bool:
        return self.conflict_free(subset) and all(
            self.defends(subset, a) for a in subset
        )

    def complete(self, subset: Face) -> bool:
        return self.conflict_free(subset) and all(
            (a in subset) == self.defends(subset, a) for a in range(self.n)
        )

    def preferred_extensions(self) -> List[Face]:
        admissible = [s for s in self.subsets() if self.admissible(s)]
        return sorted(
            [s for s in admissible if not any(s < t for t in admissible)],
            key=lambda s: (len(s), tuple(s)),
        )

    def complete_extensions(self) -> List[Face]:
        return [s for s in self.subsets() if self.complete(s)]

    def grounded_extension(self) -> Optional[Face]:
        complete = self.complete_extensions()
        least = [s for s in complete if all(s <= t for t in complete)]
        return least[0] if len(least) == 1 else None


def downward_closure(facets: Sequence[Face]) -> Set[Face]:
    """Return every subset of every facet."""
    faces: Set[Face] = set()
    for facet in facets:
        ordered = sorted(facet)
        for size in range(len(ordered) + 1):
            faces.update(frozenset(s) for s in combinations(ordered, size))
    return faces


def rank_mod2(rows: Sequence[int]) -> int:
    """Rank of a binary matrix represented by integer bit rows."""
    basis: Dict[int, int] = {}
    for row in rows:
        value = row
        while value:
            pivot = value.bit_length() - 1
            if pivot in basis:
                value ^= basis[pivot]
            else:
                basis[pivot] = value
                break
    return len(basis)


def boundary_rank(faces_k: Sequence[Face], faces_lower: Sequence[Face]) -> int:
    """Rank over F_2 of the simplicial boundary from k-faces downward."""
    if not faces_k or not faces_lower:
        return 0
    column_index = {face: i for i, face in enumerate(faces_k)}
    rows: List[int] = []
    for lower in faces_lower:
        row = 0
        for vertex in range(max((max(f) if f else -1 for f in faces_k), default=-1) + 1):
            coface = lower | {vertex}
            if len(coface) == len(lower) + 1 and coface in column_index:
                row |= 1 << column_index[coface]
        rows.append(row)
    return rank_mod2(rows)


def betti_numbers(faces: Set[Face]) -> List[int]:
    """Compute ordinary simplicial Betti numbers over F_2."""
    nonempty = [face for face in faces if face]
    if not nonempty:
        return []
    max_dim = max(len(face) - 1 for face in nonempty)
    by_dim: List[List[Face]] = [
        sorted((f for f in nonempty if len(f) == dim + 1), key=lambda f: tuple(f))
        for dim in range(max_dim + 1)
    ]
    ranks = [0] * (max_dim + 2)
    for dim in range(1, max_dim + 1):
        ranks[dim] = boundary_rank(by_dim[dim], by_dim[dim - 1])
    return [len(by_dim[d]) - ranks[d] - ranks[d + 1] for d in range(max_dim + 1)]


def face_vector(faces: Set[Face]) -> List[int]:
    nonempty = [f for f in faces if f]
    if not nonempty:
        return []
    return [
        sum(len(f) == dimension + 1 for f in nonempty)
        for dimension in range(max(map(len, nonempty)))
    ]


def euler_characteristic(faces: Set[Face]) -> int:
    return sum((-1) ** dimension * count for dimension, count in enumerate(face_vector(faces)))


def proposed_sides(framework: Framework, betti: Sequence[int]) -> Tuple[int, int]:
    preferred = framework.preferred_extensions()
    grounded = framework.grounded_extension()
    if grounded is None:
        raise ValueError("The exhaustive semantics did not find a unique grounded extension")
    higher_term = sum((-1) ** n * betti[n] for n in range(2, len(betti)))
    left = framework.n - len(framework.attacks) + higher_term
    right = len(preferred) - len(grounded)
    return left, right


def format_sets(sets: Sequence[Face]) -> str:
    return "[" + ", ".join("{" + ", ".join(map(str, sorted(s))) + "}" for s in sets) + "]"


def report(name: str, framework: Framework) -> None:
    preferred = framework.preferred_extensions()
    grounded = framework.grounded_extension()
    faces = downward_closure(preferred)
    betti = betti_numbers(faces)
    left, right = proposed_sides(framework, betti)
    print(f"\n{name}")
    print("-" * len(name))
    print(f"arguments: {framework.n}; attacks: {len(framework.attacks)}")
    print(f"preferred extensions: {format_sets(preferred)}")
    print(f"grounded extension: {format_sets([grounded]) if grounded is not None else 'none'}")
    print(f"face vector (f_0, f_1, ...): {face_vector(faces)}")
    print(f"Betti numbers over F_2: {betti}")
    print(f"Euler characteristic: {euler_characteristic(faces)}")
    print(f"proposed identity: left = {left}, right = {right}, equal = {left == right}")


def main() -> None:
    mutual = Framework(2, frozenset({(0, 1), (1, 0)}))
    isolated = Framework(2, frozenset())
    directed_three_cycle = Framework(3, frozenset({(0, 1), (1, 2), (2, 0)}))

    report("Two mutually attacking arguments", mutual)
    report("Two isolated arguments", isolated)
    report("Directed three-cycle", directed_three_cycle)

    assert mutual.preferred_extensions() == [frozenset({0}), frozenset({1})]
    assert face_vector(downward_closure(mutual.preferred_extensions())) == [2]
    assert isolated.preferred_extensions() == [frozenset({0, 1})]
    assert isolated.grounded_extension() == frozenset({0, 1})
    assert proposed_sides(isolated, [1, 0]) == (2, -1)
    print("\nAll stated boundary-case checks passed.")


if __name__ == "__main__":
    main()
