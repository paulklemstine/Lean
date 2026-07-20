#!/usr/bin/env python3
"""Numerical demonstrations for higher-order co-citation complexes.

The script uses only the Python standard library.  It constructs genuine
co-citation complexes, pairwise flag completions, boundary matrices over F_2,
Betti numbers, conformality certificates, and a small temporal filtration.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Face = FrozenSet[int]
Corpus = Sequence[Face]
Complex = Set[Face]
Interval = Tuple[int, int | None]


def powerset(vertices: Iterable[int]) -> Iterable[Face]:
    """Yield every subset of the supplied finite iterable."""
    items = sorted(set(vertices))
    for size in range(len(items) + 1):
        for subset in combinations(items, size):
            yield frozenset(subset)


def co_citation_complex(corpus: Corpus) -> Complex:
    """Return the downward closure of all document citation sets."""
    return {face for document in corpus for face in powerset(document)}


def pairwise_edges(corpus: Corpus) -> Set[Face]:
    """Return all two-element co-citation edges."""
    return {
        frozenset(pair)
        for document in corpus
        for pair in combinations(sorted(document), 2)
    }


def clique_complex(vertices: Iterable[int], edges: Set[Face]) -> Complex:
    """Return the flag complex of a graph by exhaustive clique enumeration."""
    result: Complex = set()
    for candidate in powerset(vertices):
        if all(frozenset(pair) in edges for pair in combinations(candidate, 2)):
            result.add(candidate)
    return result


def conformality_obstructions(corpus: Corpus) -> List[Face]:
    """List inclusion-maximal graph cliques lacking a common document witness."""
    vertices = set().union(*corpus) if corpus else set()
    genuine = co_citation_complex(corpus)
    flag = clique_complex(vertices, pairwise_edges(corpus))
    missing = flag - genuine
    return sorted(
        (face for face in missing if not any(face < other for other in missing)),
        key=lambda face: (len(face), sorted(face)),
    )


def rank_mod2(matrix: List[List[int]]) -> int:
    """Compute matrix rank over the field with two elements."""
    if not matrix or not matrix[0]:
        return 0
    data = [row[:] for row in matrix]
    rows, cols = len(data), len(data[0])
    rank = 0
    for col in range(cols):
        pivot = next((r for r in range(rank, rows) if data[r][col]), None)
        if pivot is None:
            continue
        data[rank], data[pivot] = data[pivot], data[rank]
        for r in range(rows):
            if r != rank and data[r][col]:
                data[r] = [a ^ b for a, b in zip(data[r], data[rank])]
        rank += 1
        if rank == rows:
            break
    return rank


def faces_by_dimension(complex_: Complex, dimension: int) -> List[Face]:
    """Return sorted faces of a fixed simplicial dimension."""
    return sorted(
        (face for face in complex_ if len(face) == dimension + 1),
        key=lambda face: sorted(face),
    )


def boundary_rank(complex_: Complex, dimension: int) -> int:
    """Compute the rank over F_2 of the dimension-th boundary map."""
    if dimension <= 0:
        return 0
    columns = faces_by_dimension(complex_, dimension)
    rows = faces_by_dimension(complex_, dimension - 1)
    row_index = {face: i for i, face in enumerate(rows)}
    matrix = [[0 for _ in columns] for _ in rows]
    for j, simplex in enumerate(columns):
        for boundary_face in combinations(sorted(simplex), dimension):
            matrix[row_index[frozenset(boundary_face)]][j] = 1
    return rank_mod2(matrix)


def betti_numbers(complex_: Complex, max_dimension: int | None = None) -> List[int]:
    """Compute ordinary Betti numbers over F_2 using boundary ranks."""
    largest = max((len(face) - 1 for face in complex_ if face), default=0)
    limit = largest if max_dimension is None else max_dimension
    ranks = [boundary_rank(complex_, k) for k in range(limit + 2)]
    return [
        len(faces_by_dimension(complex_, k)) - ranks[k] - ranks[k + 1]
        for k in range(limit + 1)
    ]


def betti_ceiling_table(complex_: Complex, vertex_count: int) -> List[Tuple[int, int, int, int]]:
    """Return rows (k, beta_k, f_k, binomial ceiling) for all dimensions."""
    betti = betti_numbers(complex_, vertex_count)
    return [
        (
            k,
            betti[k],
            len(faces_by_dimension(complex_, k)),
            comb(vertex_count, k + 1) if k + 1 <= vertex_count else 0,
        )
        for k in range(vertex_count + 1)
    ]


def cycle_lifetime(corpora: Sequence[Corpus]) -> List[int]:
    """Return beta_1 at each stage of a nested corpus sequence."""
    return [betti_numbers(co_citation_complex(corpus), 1)[1] for corpus in corpora]


def main() -> None:
    """Run three demonstrations of the principal structural results."""
    triangle_boundary: Corpus = [
        frozenset({0, 1}),
        frozenset({0, 2}),
        frozenset({1, 2}),
    ]
    genuine = co_citation_complex(triangle_boundary)
    flag = clique_complex({0, 1, 2}, pairwise_edges(triangle_boundary))

    print("DEMO 1 — Pairwise projection can fill a nonexistent triangle")
    print("Conformality obstruction:", [sorted(x) for x in conformality_obstructions(triangle_boundary)])
    print("Genuine Betti numbers:", betti_numbers(genuine, 2))
    print("Flag-completion Betti numbers:", betti_numbers(flag, 2))
    assert betti_numbers(genuine, 2) == [1, 1, 0]
    assert betti_numbers(flag, 2) == [1, 0, 0]

    print("\nDEMO 2 — Universal binomial ceilings")
    for k, beta, faces, ceiling in betti_ceiling_table(genuine, 3):
        print(f"k={k}: beta={beta}, faces={faces}, choose(3,{k + 1})={ceiling}")
        assert 0 <= beta <= faces <= ceiling
    assert betti_numbers(genuine, 3)[3] == 0

    print("\nDEMO 3 — A loop is born and then filled")
    stages: Sequence[Corpus] = [
        [frozenset({0, 1})],
        [frozenset({0, 1}), frozenset({1, 2})],
        triangle_boundary,
        [*triangle_boundary, frozenset({0, 1, 2})],
    ]
    beta_one = cycle_lifetime(stages)
    print("beta_1 by stage:", beta_one)
    assert beta_one == [0, 0, 1, 0]

    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
