#!/usr/bin/env python3
"""Numerical demonstrations for higher-order theorem co-citation topology.

The script uses only the Python standard library.  It constructs witness
complexes from citation records, computes homology over F_2 by boundary-matrix
ranks, compares pairwise graphs, checks temporal face persistence, and displays
the finite-dimensional obstruction to a dimension-uniform Betti power law.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Hashable, Iterable, Sequence, TypeVar

Vertex = TypeVar("Vertex", bound=Hashable)
Face = FrozenSet[Vertex]
Corpus = Sequence[Face[Vertex]]


def powerset(record: Face[Vertex]) -> set[Face[Vertex]]:
    """Return all subsets of one finite citation record."""
    ordered = tuple(sorted(record, key=repr))
    return {
        frozenset(choice)
        for size in range(len(ordered) + 1)
        for choice in combinations(ordered, size)
    }


def cocitation_complex(corpus: Corpus[Vertex]) -> set[Face[Vertex]]:
    """Build the downward-closed common-witness complex of a corpus."""
    faces: set[Face[Vertex]] = set()
    for record in corpus:
        faces.update(powerset(record))
    return faces


def cocitation_graph(corpus: Corpus[Vertex]) -> set[Face[Vertex]]:
    """Return the pairwise shadow as a set of two-vertex edges."""
    return {
        frozenset(pair)
        for record in corpus
        for pair in combinations(sorted(record, key=repr), 2)
    }


def simplices(complex_: set[Face[Vertex]], dimension: int) -> list[Face[Vertex]]:
    """List simplices of a chosen dimension in deterministic order."""
    return sorted(
        (face for face in complex_ if len(face) == dimension + 1),
        key=lambda face: tuple(sorted(map(repr, face))),
    )


def rank_mod2(rows: list[int]) -> int:
    """Compute the rank over F_2 of bit-packed matrix rows."""
    rows = [row for row in rows if row]
    rank = 0
    while rows:
        pivot = max(rows, key=int.bit_length)
        rows.remove(pivot)
        pivot_bit = 1 << (pivot.bit_length() - 1)
        rows = [
            reduced
            for row in rows
            if (reduced := row ^ pivot if row & pivot_bit else row) != 0
        ]
        rank += 1
    return rank


def boundary_rank(complex_: set[Face[Vertex]], dimension: int) -> int:
    """Compute rank of the dimension-k boundary matrix over F_2."""
    if dimension <= 0:
        return 0
    lower = simplices(complex_, dimension - 1)
    upper = simplices(complex_, dimension)
    upper_index = {face: column for column, face in enumerate(upper)}
    rows: list[int] = []
    for lower_face in lower:
        packed = 0
        for upper_face, column in upper_index.items():
            if lower_face < upper_face:
                packed |= 1 << column
        rows.append(packed)
    return rank_mod2(rows)


def betti_numbers(complex_: set[Face[Vertex]], max_dimension: int) -> list[int]:
    """Compute Betti numbers over F_2 through max_dimension."""
    face_counts = [len(simplices(complex_, k)) for k in range(max_dimension + 2)]
    ranks = [boundary_rank(complex_, k) for k in range(max_dimension + 2)]
    return [face_counts[k] - ranks[k] - ranks[k + 1] for k in range(max_dimension + 1)]


def triangle_demo() -> None:
    """Show that a triple fills a hole without changing any graph edge."""
    boundary: list[Face[str]] = [
        frozenset(("A", "B")),
        frozenset(("B", "C")),
        frozenset(("A", "C")),
    ]
    filled = boundary + [frozenset(("A", "B", "C"))]
    boundary_complex = cocitation_complex(boundary)
    filled_complex = cocitation_complex(filled)
    graph_equal = cocitation_graph(boundary) == cocitation_graph(filled)

    print("TRIANGLE FILLING")
    print(f"Pairwise graphs equal: {graph_equal}")
    print(f"Boundary face counts f0,f1,f2: {[len(simplices(boundary_complex, k)) for k in range(3)]}")
    print(f"Filled face counts f0,f1,f2:   {[len(simplices(filled_complex, k)) for k in range(3)]}")
    print(f"Boundary Betti numbers: {betti_numbers(boundary_complex, 2)}")
    print(f"Filled Betti numbers:   {betti_numbers(filled_complex, 2)}")
    assert graph_equal
    assert boundary_complex < filled_complex
    assert betti_numbers(boundary_complex, 2) == [1, 1, 0]
    assert betti_numbers(filled_complex, 2) == [1, 0, 0]


def persistence_demo() -> None:
    """Check face persistence and exhibit death of the triangular loop."""
    stages: list[list[Face[str]]] = [
        [frozenset(("A", "B"))],
        [frozenset(("A", "B")), frozenset(("B", "C")), frozenset(("A", "C"))],
        [frozenset(("A", "B")), frozenset(("B", "C")), frozenset(("A", "C")),
         frozenset(("A", "B", "C"))],
    ]
    complexes = [cocitation_complex(stage) for stage in stages]
    monotone = all(earlier <= later for earlier, later in zip(complexes, complexes[1:]))
    profiles = [betti_numbers(complex_, 2) for complex_ in complexes]
    print("\nTEMPORAL FILTRATION")
    print(f"Every earlier face persists: {monotone}")
    for time, profile in enumerate(profiles):
        print(f"time {time}: Betti numbers {profile}")
    assert monotone
    assert profiles[1][1] == 1 and profiles[2][1] == 0


def dimensional_ceiling_demo(n: int = 5) -> None:
    """Display the binomial ceiling and contradiction at k=n."""
    if n <= 0:
        raise ValueError("n must be positive")
    print(f"\nDIMENSIONAL CEILING FOR n={n}")
    print(" k | maximum k-faces | proposed n^(k+1)")
    for k in range(n + 2):
        maximum = comb(n, k + 1) if k + 1 <= n else 0
        proposed = n ** (k + 1)
        print(f"{k:2d} | {maximum:15d} | {proposed:18d}")
    assert (comb(n, n + 1) if n + 1 <= n else 0) == 0
    assert n ** (n + 1) > 0


def main() -> None:
    triangle_demo()
    persistence_demo()
    dimensional_ceiling_demo()


if __name__ == "__main__":
    main()
