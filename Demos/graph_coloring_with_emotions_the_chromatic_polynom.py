#!/usr/bin/env python3
"""Numerical demonstrations of chromatic positivity thresholds.

The script uses no third-party packages. It evaluates friendship-graph formulas,
checks them by exhaustive enumeration for small cases, and computes emotional
chromatic thresholds (the first colorable palette of size at least three).
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, Sequence

Edge = tuple[int, int]


def normalize_edges(edges: Iterable[Edge]) -> tuple[Edge, ...]:
    """Return undirected, deduplicated edges with smaller endpoint first."""
    normalized = {tuple(sorted(edge)) for edge in edges}
    if any(u == v for u, v in normalized):
        raise ValueError("Simple graphs cannot contain loops")
    return tuple(sorted(normalized))


def friendship_graph(n: int) -> tuple[int, tuple[Edge, ...]]:
    """Construct F_n with hub 0 and outer pairs (2i+1, 2i+2)."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    edges: list[Edge] = []
    for i in range(n):
        a, b = 2 * i + 1, 2 * i + 2
        edges.extend(((0, a), (0, b), (a, b)))
    return 2 * n + 1, normalize_edges(edges)


def is_proper(assignment: Sequence[int], edges: Sequence[Edge]) -> bool:
    """Test whether adjacent vertices have distinct labels."""
    return all(assignment[u] != assignment[v] for u, v in edges)


def chromatic_count(vertex_count: int, edges: Sequence[Edge], k: int) -> int:
    """Count proper k-assignments by exhaustive enumeration."""
    if vertex_count < 0 or k < 0:
        raise ValueError("vertex_count and k must be nonnegative")
    return sum(
        is_proper(assignment, edges)
        for assignment in product(range(k), repeat=vertex_count)
    )


def is_k_colorable(vertex_count: int, edges: Sequence[Edge], k: int) -> bool:
    """Decide k-colorability with recursive backtracking and pruning."""
    adjacency = [set() for _ in range(vertex_count)]
    for u, v in edges:
        adjacency[u].add(v)
        adjacency[v].add(u)
    order = sorted(range(vertex_count), key=lambda v: len(adjacency[v]), reverse=True)
    colors = [-1] * vertex_count

    def search(position: int) -> bool:
        if position == vertex_count:
            return True
        vertex = order[position]
        forbidden = {colors[w] for w in adjacency[vertex] if colors[w] >= 0}
        for color in range(k):
            if color not in forbidden:
                colors[vertex] = color
                if search(position + 1):
                    return True
        colors[vertex] = -1
        return False

    return search(0)


def emotional_chromatic_number(vertex_count: int, edges: Sequence[Edge]) -> int:
    """Return the least colorable palette size k >= 3."""
    upper = max(3, vertex_count)
    for k in range(3, upper + 1):
        if is_k_colorable(vertex_count, edges, k):
            return k
    raise RuntimeError("The distinct-label upper bound should always succeed")


def friendship_formula(n: int, k: int) -> int:
    """Evaluate P_{F_n}(k) = k(k-1)^n(k-2)^n."""
    if n < 0 or k < 0:
        raise ValueError("n and k must be nonnegative")
    return k * (k - 1) ** n * (k - 2) ** n


def demonstrate_friendship_profiles(max_n: int = 6) -> None:
    """Print exact minimum- and six-palette profiles for F_0,...,F_max_n."""
    print("Friendship-network threshold profile")
    print(" n | tau_E | P_Fn(3) | P_Fn(6) | ratio")
    print("---+-------+---------+---------+----------------")
    for n in range(max_n + 1):
        minimum_count = friendship_formula(n, 3)
        six_count = friendship_formula(n, 6)
        ratio = six_count // minimum_count
        print(f"{n:2d} | {3:5d} | {minimum_count:7d} | {six_count:7d} | {ratio:16d}")
        assert minimum_count == 3 * 2**n
        assert six_count == 6 * 20**n
        assert ratio == 2 * 10**n


def verify_small_friendship_cases() -> None:
    """Compare the closed formula with brute-force counts in tractable cases."""
    print("\nBrute-force checks of P_Fn(k) = k(k-1)^n(k-2)^n")
    for n in range(4):
        vertex_count, edges = friendship_graph(n)
        for k in range(3, 6):
            enumerated = chromatic_count(vertex_count, edges, k)
            closed = friendship_formula(n, k)
            assert enumerated == closed
            print(f"F_{n}, k={k}: enumerated={enumerated}, formula={closed}")
        assert emotional_chromatic_number(vertex_count, edges) == 3


def demonstrate_six_emotion_boundary() -> None:
    """Show a graph accepted and a graph rejected by the six-label test."""
    f_vertices, f_edges = friendship_graph(3)
    clique_vertices = 7
    clique_edges = normalize_edges(
        (u, v) for u in range(clique_vertices) for v in range(u + 1, clique_vertices)
    )
    examples = (
        ("Friendship graph F_3", f_vertices, f_edges),
        ("Seven-vertex clique K_7", clique_vertices, clique_edges),
    )
    print("\nSix-emotion positivity boundary")
    for name, vertices, edges in examples:
        threshold = emotional_chromatic_number(vertices, edges)
        six_positive = is_k_colorable(vertices, edges, 6)
        print(f"{name}: tau_E={threshold}, P_G(6)>0 is {six_positive}")
        assert six_positive == (3 <= threshold <= 6)


def main() -> None:
    demonstrate_friendship_profiles()
    verify_small_friendship_cases()
    demonstrate_six_emotion_boundary()
    print("\nAll numerical demonstrations passed.")


if __name__ == "__main__":
    main()
