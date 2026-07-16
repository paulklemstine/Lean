#!/usr/bin/env python3
"""Numerical experiments for cyclically stable Kneser graphs.

The program uses only the Python standard library. It generates stable sets,
checks the canonical least-element coloring, computes exact chromatic numbers
for small instances by DSATUR backtracking, and summarizes cyclic gap profiles.
"""

from __future__ import annotations

from collections import Counter
from itertools import combinations
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Vertex = Tuple[int, ...]
Adjacency = List[Set[int]]


def cyclic_gaps(vertex: Sequence[int], n: int) -> Tuple[int, ...]:
    """Return successive cyclic gaps of a sorted nonempty vertex."""
    if not vertex:
        raise ValueError("a stable set must be nonempty")
    return tuple(vertex[i + 1] - vertex[i] for i in range(len(vertex) - 1)) + (
        n + vertex[0] - vertex[-1],
    )


def is_cyclically_stable(vertex: Sequence[int], n: int, s: int) -> bool:
    """Test whether every cyclic gap is at least s."""
    return bool(vertex) and all(gap >= s for gap in cyclic_gaps(vertex, n))


def stable_sets(n: int, k: int, s: int) -> List[Vertex]:
    """Enumerate all cyclically s-stable k-subsets of {1,...,n}."""
    if min(n, k, s) < 1 or k > n:
        return []
    return [
        candidate
        for candidate in combinations(range(1, n + 1), k)
        if is_cyclically_stable(candidate, n, s)
    ]


def disjointness_graph(vertices: Sequence[Vertex]) -> Adjacency:
    """Build adjacency sets, joining exactly the disjoint vertex pairs."""
    adjacency: Adjacency = [set() for _ in vertices]
    supports = [set(vertex) for vertex in vertices]
    for i, j in combinations(range(len(vertices)), 2):
        if supports[i].isdisjoint(supports[j]):
            adjacency[i].add(j)
            adjacency[j].add(i)
    return adjacency


def least_element_coloring(vertices: Iterable[Vertex]) -> Dict[Vertex, int]:
    """Color each stable set by its least element."""
    return {vertex: vertex[0] for vertex in vertices}


def validate_coloring(
    vertices: Sequence[Vertex], adjacency: Adjacency, colors: Dict[Vertex, int]
) -> bool:
    """Check that every edge has differently colored endpoints."""
    return all(
        colors[vertices[i]] != colors[vertices[j]]
        for i in range(len(vertices))
        for j in adjacency[i]
        if i < j
    )


def _dsatur_m_coloring(adjacency: Adjacency, color_count: int) -> Optional[List[int]]:
    """Find a coloring with color_count colors, or return None."""
    size = len(adjacency)
    colors = [-1] * size

    def choose_vertex() -> int:
        uncolored = [v for v in range(size) if colors[v] < 0]
        return max(
            uncolored,
            key=lambda v: (
                len({colors[w] for w in adjacency[v] if colors[w] >= 0}),
                len(adjacency[v]),
            ),
        )

    def search(colored: int) -> bool:
        if colored == size:
            return True
        vertex = choose_vertex()
        forbidden = {colors[w] for w in adjacency[vertex] if colors[w] >= 0}
        for color in range(color_count):
            if color not in forbidden:
                colors[vertex] = color
                if search(colored + 1):
                    return True
                colors[vertex] = -1
        return False

    return colors if search(0) else None


def exact_chromatic_number(adjacency: Adjacency, upper_bound: int) -> int:
    """Determine the exact chromatic number of a small graph by backtracking."""
    if not adjacency:
        return 0
    for color_count in range(1, upper_bound + 1):
        if _dsatur_m_coloring(adjacency, color_count) is not None:
            return color_count
    raise RuntimeError("the supplied upper bound was not a valid bound")


def normalized_gap_profile(vertex: Vertex, n: int) -> Tuple[int, ...]:
    """Canonicalize a cyclic gap tuple up to rotation."""
    gaps = cyclic_gaps(vertex, n)
    rotations = [gaps[i:] + gaps[:i] for i in range(len(gaps))]
    return min(rotations)


def run_instance(n: int, k: int, s: int, exact: bool = True) -> None:
    """Generate one graph and print its principal numerical invariants."""
    vertices = stable_sets(n, k, s)
    adjacency = disjointness_graph(vertices)
    colors = least_element_coloring(vertices)
    edge_count = sum(map(len, adjacency)) // 2
    predicted = n - s * k + s
    proper = validate_coloring(vertices, adjacency, colors)
    used = len(set(colors.values()))
    profiles = Counter(normalized_gap_profile(vertex, n) for vertex in vertices)

    print(f"n={n}, k={k}, s={s}")
    print(f"  vertices={len(vertices)}, edges={edge_count}")
    print(f"  predicted palette n-sk+s={predicted}")
    print(f"  least-element colors used={used}, proper={proper}")
    print(f"  rotational gap profiles={dict(sorted(profiles.items()))}")
    if exact:
        chromatic = exact_chromatic_number(adjacency, max(used, 1))
        print(f"  exact chromatic number={chromatic}")
    print()


def main() -> None:
    """Run boundary and nearby examples for cyclically 3-stable triples."""
    for n in (9, 10, 11):
        run_instance(n=n, k=3, s=3, exact=True)


if __name__ == "__main__":
    main()
