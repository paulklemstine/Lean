#!/usr/bin/env python3
"""Numerical demonstrations of finite avoidance and Turán sharpness.

The script uses only the Python standard library. It computes Ramsey union-bound
ratios, searches small complete graphs for colorings without monochromatic
cliques, demonstrates conditional survivor filtering, and constructs balanced
complete bipartite graphs while checking triangle-freeness and edge counts.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Callable, Dict, FrozenSet, Iterable, List, Optional, Sequence, Set, Tuple, TypeVar

Vertex = int
Edge = Tuple[Vertex, Vertex]
Outcome = TypeVar("Outcome")


def complete_graph_edges(n: int) -> List[Edge]:
    """Return the lexicographically ordered edges of K_n."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return list(combinations(range(n), 2))


def ramsey_union_ratio(n: int, k: int) -> float:
    """Return 2*C(n,k)/2^C(k,2), the exact union-bound ratio."""
    if not 0 <= k <= n:
        raise ValueError("require 0 <= k <= n")
    return (2 * comb(n, k)) / (2 ** comb(k, 2))


def ramsey_power_ratio(n: int, k: int) -> float:
    """Return 2*n^k/2^C(k,2), the ratio in the simpler power criterion."""
    if n < 0 or k < 0:
        raise ValueError("n and k must be nonnegative")
    return (2 * n**k) / (2 ** comb(k, 2))


def is_ramsey_avoiding(mask: int, n: int, k: int, edges: Sequence[Edge]) -> bool:
    """Test whether a bit-encoded coloring of K_n has no monochromatic K_k."""
    edge_index: Dict[Edge, int] = {edge: idx for idx, edge in enumerate(edges)}
    for vertices in combinations(range(n), k):
        colors = {
            (mask >> edge_index[tuple(sorted(edge))]) & 1
            for edge in combinations(vertices, 2)
        }
        if len(colors) == 1:
            return False
    return True


def find_ramsey_avoiding_coloring(n: int, k: int) -> Optional[Set[Edge]]:
    """Exhaustively find red edges of a coloring of K_n with no monochromatic K_k.

    This is intended only for small numerical examples: the search has 2^C(n,2)
    candidates in the worst case.
    """
    if not 2 <= k <= n:
        raise ValueError("require 2 <= k <= n")
    edges = complete_graph_edges(n)
    for mask in range(1 << len(edges)):
        if is_ramsey_avoiding(mask, n, k, edges):
            return {edge for idx, edge in enumerate(edges) if (mask >> idx) & 1}
    return None


def filter_survivors(
    outcomes: Iterable[Outcome],
    bad_predicates: Sequence[Callable[[Outcome], bool]],
) -> List[Set[Outcome]]:
    """Return the survivor set after each successive bad predicate."""
    current = set(outcomes)
    history: List[Set[Outcome]] = [set(current)]
    for is_bad in bad_predicates:
        current = {outcome for outcome in current if not is_bad(outcome)}
        history.append(set(current))
    return history


def balanced_turan_graph(m: int) -> Tuple[Set[Vertex], Set[Edge]]:
    """Construct the balanced complete bipartite graph on 2m vertices."""
    if m < 0:
        raise ValueError("m must be nonnegative")
    left = set(range(m))
    right = set(range(m, 2 * m))
    vertices = left | right
    edges = {(u, v) for u in left for v in right}
    return vertices, edges


def has_triangle(vertices: Iterable[Vertex], edges: Set[Edge]) -> bool:
    """Return whether an undirected edge set contains a triangle."""
    normalized: FrozenSet[Edge] = frozenset(tuple(sorted(edge)) for edge in edges)
    return any(
        tuple(sorted((a, b))) in normalized
        and tuple(sorted((a, c))) in normalized
        and tuple(sorted((b, c))) in normalized
        for a, b, c in combinations(vertices, 3)
    )


def demo_ramsey_bounds() -> None:
    """Print exact and power-criterion data, including (n,k)=(16,10)."""
    print("Ramsey counting ratios")
    for n, k in [(5, 3), (8, 4), (16, 10)]:
        exact = ramsey_union_ratio(n, k)
        power = ramsey_power_ratio(n, k)
        print(
            f"  n={n:2d}, k={k:2d}: exact ratio={exact:.8g}, "
            f"power ratio={power:.8g}, criterion holds={exact < 1}"
        )
    print("  For (16,10), the power ratio is 1/16, so R(10,10) > 16.")


def demo_small_search() -> None:
    """Find a small coloring of K_5 with no monochromatic triangle."""
    red = find_ramsey_avoiding_coloring(5, 3)
    assert red is not None
    print("\nSmall exhaustive Ramsey search")
    print(f"  Red edges in a K_5 coloring with no monochromatic K_3: {sorted(red)}")
    print(f"  Blue edges: {sorted(set(complete_graph_edges(5)) - red)}")


def demo_conditional_avoidance() -> None:
    """Filter integers by three constraints that leave a common survivor."""
    outcomes = range(1, 31)
    constraints: List[Callable[[int], bool]] = [
        lambda x: x % 2 == 0,
        lambda x: x % 3 == 0,
        lambda x: x % 5 == 0,
    ]
    history = filter_survivors(outcomes, constraints)
    print("\nConditional survivor filtering")
    for index, surviving in enumerate(history):
        print(f"  after {index} constraint(s): {len(surviving):2d} survivors")
    print(f"  common survivors: {sorted(history[-1])}")


def demo_turan_graphs() -> None:
    """Verify triangle-freeness and the m^2 edge identity numerically."""
    print("\nBalanced Turán graphs")
    for m in range(1, 7):
        vertices, edges = balanced_turan_graph(m)
        triangle_free = not has_triangle(vertices, edges)
        identity = 4 * len(edges) == (2 * m) ** 2
        print(
            f"  m={m}: vertices={2*m:2d}, edges={len(edges):2d}, "
            f"triangle-free={triangle_free}, 4|E|=(2m)^2={identity}"
        )


def main() -> None:
    """Run all demonstrations."""
    demo_ramsey_bounds()
    demo_small_search()
    demo_conditional_avoidance()
    demo_turan_graphs()


if __name__ == "__main__":
    main()
