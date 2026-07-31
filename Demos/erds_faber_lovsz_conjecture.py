#!/usr/bin/env python3
"""Numerical demonstrations for finite linear intersecting hypergraphs.

The script uses only the Python standard library. It audits uniformity,
linearity, intersectingness, exact pairwise unions, contact partitions,
punctured-star disjointness, and rainbow colorings on finite examples.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import Dict, FrozenSet, Hashable, Iterable, Mapping, Sequence, Tuple, TypeVar

Vertex = TypeVar("Vertex", bound=Hashable)
Edge = FrozenSet[Vertex]


@dataclass(frozen=True)
class PairReport:
    """Pairwise intersection and union data for two indexed edges."""

    first: int
    second: int
    intersection: FrozenSet[Hashable]
    union_size: int


def normalize(edges: Iterable[Iterable[Vertex]]) -> Tuple[Edge[Vertex], ...]:
    """Convert an iterable of finite edges to an immutable representation."""
    return tuple(frozenset(edge) for edge in edges)


def uniform_rank(edges: Sequence[Edge[Vertex]]) -> int | None:
    """Return the common edge size, or None when edge sizes differ."""
    if not edges:
        return 0
    rank = len(edges[0])
    return rank if all(len(edge) == rank for edge in edges) else None


def pair_reports(edges: Sequence[Edge[Vertex]]) -> list[PairReport]:
    """Compute intersection sets and union sizes for all unordered edge pairs."""
    reports: list[PairReport] = []
    for i, j in combinations(range(len(edges)), 2):
        reports.append(
            PairReport(i, j, frozenset(edges[i] & edges[j]), len(edges[i] | edges[j]))
        )
    return reports


def is_linear(edges: Sequence[Edge[Vertex]]) -> bool:
    """Test whether distinct edges intersect in at most one vertex."""
    return all(len(report.intersection) <= 1 for report in pair_reports(edges))


def is_intersecting(edges: Sequence[Edge[Vertex]]) -> bool:
    """Test whether every two distinct edges have nonempty intersection."""
    return all(bool(report.intersection) for report in pair_reports(edges))


def contact_partition(
    edges: Sequence[Edge[Vertex]], reference: int
) -> Dict[Vertex, list[int]]:
    """Assign every nonreference edge to its unique contact on a reference edge.

    Raises ValueError unless every nonreference edge meets the reference edge in
    exactly one point.
    """
    base = edges[reference]
    buckets: Dict[Vertex, list[int]] = {vertex: [] for vertex in base}
    for index, edge in enumerate(edges):
        if index == reference:
            continue
        contact = base & edge
        if len(contact) != 1:
            raise ValueError(
                f"edges {reference} and {index} have {len(contact)} contact points"
            )
        buckets[next(iter(contact))].append(index)
    return buckets


def punctured_star(
    edges: Sequence[Edge[Vertex]], center: Vertex
) -> Dict[int, Edge[Vertex]]:
    """Return all incident edges with the center removed."""
    return {
        index: frozenset(edge - {center})
        for index, edge in enumerate(edges)
        if center in edge
    }


def punctured_star_is_disjoint(
    edges: Sequence[Edge[Vertex]], center: Vertex
) -> bool:
    """Check pairwise disjointness of all punctured edges through a center."""
    branches = list(punctured_star(edges, center).values())
    return all(not (left & right) for left, right in combinations(branches, 2))


def star_union_size(edges: Sequence[Edge[Vertex]], center: Vertex) -> int:
    """Count vertices in the union of all edges containing center."""
    incident = [edge for edge in edges if center in edge]
    return len(set().union(*incident)) if incident else 0


def is_rainbow_coloring(
    edges: Sequence[Edge[Vertex]], coloring: Mapping[Vertex, int]
) -> bool:
    """Check that every edge receives pairwise distinct colors."""
    for edge in edges:
        try:
            colors = [coloring[vertex] for vertex in edge]
        except KeyError:
            return False
        if len(colors) != len(set(colors)):
            return False
    return True


def audit(edges: Sequence[Edge[Vertex]]) -> dict[str, object]:
    """Return a compact structural audit and exact-union check."""
    rank = uniform_rank(edges)
    reports = pair_reports(edges)
    exact_intersections = all(len(item.intersection) == 1 for item in reports)
    union_formula = (
        rank is not None
        and all(item.union_size == 2 * rank - 1 for item in reports)
    )
    return {
        "edge_count": len(edges),
        "rank": rank,
        "linear": is_linear(edges),
        "intersecting": is_intersecting(edges),
        "all_intersections_have_size_one": exact_intersections,
        "all_pair_unions_have_size_2r_minus_1": union_formula,
    }


def projective_plane_order_two() -> Tuple[Edge[int], ...]:
    """Return the seven lines of the Fano plane, a 3-uniform example."""
    return normalize(
        [
            {0, 1, 2},
            {0, 3, 4},
            {0, 5, 6},
            {1, 3, 5},
            {1, 4, 6},
            {2, 3, 6},
            {2, 4, 5},
        ]
    )


def print_example(
    title: str,
    edges: Sequence[Edge[Vertex]],
    coloring: Mapping[Vertex, int] | None = None,
) -> None:
    """Print a readable report for one finite example."""
    print(f"\n=== {title} ===")
    print("Edges:", [sorted(edge) for edge in edges])
    for key, value in audit(edges).items():
        print(f"{key}: {value}")
    for report in pair_reports(edges):
        print(
            f"E{report.first} ∩ E{report.second} = "
            f"{sorted(report.intersection)}, "
            f"|E{report.first} ∪ E{report.second}| = {report.union_size}"
        )
    if edges and all(len(edges[0] & edge) == 1 for edge in edges[1:]):
        print("Contact partition at E0:", contact_partition(edges, 0))
    if coloring is not None:
        print("Coloring:", dict(sorted(coloring.items())))
        print("Rainbow on every edge:", is_rainbow_coloring(edges, coloring))


def main() -> None:
    """Run three numerical demonstrations and one deliberate counterexample."""
    triangle_system = normalize([{0, 1}, {1, 2}, {0, 2}])
    triangle_coloring = {0: 0, 1: 1, 2: 2}
    print_example("Three pairwise-intersecting 2-edges", triangle_system, triangle_coloring)

    triple_system = normalize([{0, 1, 2}, {0, 3, 4}, {1, 3, 5}])
    triple_coloring = {0: 0, 1: 1, 2: 2, 3: 2, 4: 1, 5: 0}
    print_example("A 3-uniform linear intersecting system", triple_system, triple_coloring)
    center = 0
    branches = punctured_star(triple_system, center)
    print(f"Punctured star at {center}:", {i: sorted(e) for i, e in branches.items()})
    print("Branches pairwise disjoint:", punctured_star_is_disjoint(triple_system, center))
    degree = sum(center in edge for edge in triple_system)
    rank = uniform_rank(triple_system)
    assert rank is not None
    print(
        "Star count:",
        star_union_size(triple_system, center),
        "= 1 + d(r-1) =",
        1 + degree * (rank - 1),
    )

    fano = projective_plane_order_two()
    print_example("The seven lines of the Fano plane", fano)

    nonlinear = normalize([{0, 1, 2}, {0, 1, 3}])
    print_example("Diagnostic failure: two shared vertices", nonlinear)

    assert audit(triple_system)["all_pair_unions_have_size_2r_minus_1"] is True
    assert punctured_star_is_disjoint(triple_system, 0)
    assert is_rainbow_coloring(triple_system, triple_coloring)
    assert audit(nonlinear)["linear"] is False


if __name__ == "__main__":
    main()
