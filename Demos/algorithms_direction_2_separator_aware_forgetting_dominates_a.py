"""
Separator-Aware Clause Retention: Core Algorithms

Implements the mathematically verified separator-aware retention algorithm
for clause database management in SAT-like contexts.

The key insight: given a path decomposition of a clause interaction graph,
the optimal retention policy at any cut is exactly the bag at that position.
This module provides the algorithm and supporting data structures.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import FrozenSet, Optional


@dataclass
class SimpleGraph:
    """A simple undirected graph on integer vertices."""
    vertices: set[int] = field(default_factory=set)
    edges: set[frozenset[int]] = field(default_factory=set)

    def add_edge(self, u: int, v: int) -> None:
        """Add an undirected edge {u, v}."""
        if u == v:
            raise ValueError("Self-loops are not allowed in a simple graph")
        self.vertices.add(u)
        self.vertices.add(v)
        self.edges.add(frozenset({u, v}))

    def adj(self, u: int, v: int) -> bool:
        """Check if u and v are adjacent."""
        return frozenset({u, v}) in self.edges

    def neighbors(self, v: int) -> set[int]:
        """Return the set of neighbors of v."""
        return {u for e in self.edges if v in e for u in e if u != v}


@dataclass
class PathDecomposition:
    """
    A path decomposition of a simple graph.

    Attributes:
        bags: List of bags (each a frozenset of vertices), indexed by position.
        graph: The underlying simple graph.
    """
    bags: list[frozenset[int]]
    graph: SimpleGraph

    def __post_init__(self) -> None:
        if not self.bags:
            raise ValueError("Path decomposition must have at least one bag")

    @property
    def num_bags(self) -> int:
        return len(self.bags)

    @property
    def width(self) -> int:
        """Width = max bag size - 1."""
        return max(len(b) for b in self.bags) - 1

    @property
    def max_bag_size(self) -> int:
        return max(len(b) for b in self.bags)

    def verify(self) -> list[str]:
        """
        Verify the path decomposition axioms. Returns a list of violations
        (empty if valid).
        """
        violations = []

        # Edge coverage
        for e in self.graph.edges:
            u, v = tuple(e)
            if not any(u in bag and v in bag for bag in self.bags):
                violations.append(f"Edge {{{u},{v}}} not covered by any bag")

        # Running intersection
        for v in self.graph.vertices:
            indices = [i for i, bag in enumerate(self.bags) if v in bag]
            if indices:
                lo, hi = min(indices), max(indices)
                for j in range(lo, hi + 1):
                    if v not in self.bags[j]:
                        violations.append(
                            f"Vertex {v} violates running intersection: "
                            f"in bags {lo} and {hi} but not in bag {j}"
                        )

        return violations


def past_vertices(pd: PathDecomposition, i: int) -> frozenset[int]:
    """Vertices appearing in bags at or before position i."""
    result: set[int] = set()
    for j in range(min(i + 1, pd.num_bags)):
        result |= pd.bags[j]
    return frozenset(result)


def future_vertices(pd: PathDecomposition, i: int) -> frozenset[int]:
    """Vertices appearing in bags at or after position i."""
    result: set[int] = set()
    for j in range(i, pd.num_bags):
        result |= pd.bags[j]
    return frozenset(result)


def frontier_at_cut(pd: PathDecomposition, i: int) -> frozenset[int]:
    """
    The frontier at cut i: vertices in both past and future.

    By the Frontier = Bag theorem, this equals pd.bags[i].
    """
    return past_vertices(pd, i) & future_vertices(pd, i)


def strict_past(pd: PathDecomposition, i: int) -> frozenset[int]:
    """Vertices in past but not in future."""
    return past_vertices(pd, i) - future_vertices(pd, i)


def strict_future(pd: PathDecomposition, i: int) -> frozenset[int]:
    """Vertices in future but not in past."""
    return future_vertices(pd, i) - past_vertices(pd, i)


def separator_aware_retain(pd: PathDecomposition, i: int) -> frozenset[int]:
    """
    The separator-aware retention algorithm.

    Returns the bag at position i — the unique minimal interaction-preserving
    retention set (among frontier subsets).

    This is the verified algorithm from the formal development.

    Args:
        pd: A path decomposition
        i: The cut index (0 ≤ i < num_bags)

    Returns:
        The retained set (= B_i = frontier at cut i)
    """
    if i < 0 or i >= pd.num_bags:
        raise IndexError(f"Cut index {i} out of range [0, {pd.num_bags})")
    return pd.bags[i]


def is_interaction_preserving(
    graph: SimpleGraph,
    pd: PathDecomposition,
    i: int,
    retained: frozenset[int]
) -> bool:
    """
    Check if a retention policy is interaction-preserving at cut i.

    A policy R is interaction-preserving if for every edge {u,v} with
    u in Past(i) and v in Future(i), at least one of u, v is in R.
    """
    past = past_vertices(pd, i)
    future = future_vertices(pd, i)

    for e in graph.edges:
        u, v = tuple(e)
        # Check both orientations for past-future crossings
        if (u in past and v in future) or (v in past and u in future):
            if u not in retained and v not in retained:
                return False
    return True


def cross_cut_edges(
    graph: SimpleGraph,
    pd: PathDecomposition,
    i: int
) -> list[tuple[int, int]]:
    """Return all edges crossing the cut at position i."""
    past = past_vertices(pd, i)
    future = future_vertices(pd, i)
    result = []
    for e in graph.edges:
        u, v = tuple(e)
        if (u in past and v in future) or (v in past and u in future):
            result.append((u, v))
    return result


@dataclass
class StreamingSeparatorRetainer:
    """
    Streaming version of separator-aware retention.

    Maintains the retained set as the decomposition progresses from
    one cut to the next. Supports incremental updates.
    """
    pd: PathDecomposition
    current_cut: int = 0
    retained: frozenset[int] = field(default_factory=frozenset)

    def __post_init__(self) -> None:
        self.retained = self.pd.bags[0]

    def advance(self) -> frozenset[int]:
        """
        Advance to the next cut position.

        Returns:
            The new retained set.
        """
        if self.current_cut + 1 >= self.pd.num_bags:
            raise StopIteration("No more cuts to advance to")

        self.current_cut += 1
        old_retained = self.retained
        self.retained = self.pd.bags[self.current_cut]

        return self.retained

    def added(self) -> frozenset[int]:
        """Vertices added in the last advance."""
        prev = self.pd.bags[max(0, self.current_cut - 1)]
        return self.retained - prev

    def removed(self) -> frozenset[int]:
        """Vertices removed in the last advance."""
        prev = self.pd.bags[max(0, self.current_cut - 1)]
        return prev - self.retained

    @property
    def memory_usage(self) -> int:
        """Current retained set size."""
        return len(self.retained)


# Example usage
if __name__ == "__main__":
    # Build the path graph P_5: 0-1-2-3-4
    g = SimpleGraph()
    for u in range(4):
        g.add_edge(u, u + 1)

    # Path decomposition with bags [{0,1}, {1,2}, {2,3}, {3,4}]
    pd = PathDecomposition(
        bags=[frozenset({i, i + 1}) for i in range(4)],
        graph=g
    )

    print(f"Graph: {g.vertices}, {g.edges}")
    print(f"Decomposition width: {pd.width}")
    print(f"Verification: {pd.verify()}")
    print()

    for i in range(pd.num_bags):
        frontier = frontier_at_cut(pd, i)
        bag = pd.bags[i]
        retained = separator_aware_retain(pd, i)
        preserves = is_interaction_preserving(g, pd, i, retained)
        cross = cross_cut_edges(g, pd, i)

        print(f"Cut {i}:")
        print(f"  Bag = {set(bag)}")
        print(f"  Frontier = {set(frontier)}")
        print(f"  Frontier == Bag: {frontier == bag}")
        print(f"  Retained = {set(retained)}")
        print(f"  Interaction-preserving: {preserves}")
        print(f"  Cross-cut edges: {cross}")
        print(f"  Strict past: {set(strict_past(pd, i))}")
        print(f"  Strict future: {set(strict_future(pd, i))}")
        print()

    # Streaming demo
    print("=== Streaming Retention ===")
    streamer = StreamingSeparatorRetainer(pd)
    print(f"Cut 0: retained = {set(streamer.retained)}, size = {streamer.memory_usage}")
    for _ in range(pd.num_bags - 1):
        streamer.advance()
        print(f"Cut {streamer.current_cut}: retained = {set(streamer.retained)}, "
              f"added = {set(streamer.added())}, removed = {set(streamer.removed())}, "
              f"size = {streamer.memory_usage}")
