#!/usr/bin/env python3
"""Numerical demonstrations for ranked finite dependency networks."""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Iterable

Vertex = int
Edge = tuple[Vertex, Vertex]


@dataclass(frozen=True)
class DependencyDAG:
    """A finite directed graph with vertices 0 through n-1."""

    n: int
    edges: tuple[Edge, ...]

    def adjacency(self) -> list[list[int]]:
        out = [[] for _ in range(self.n)]
        for u, v in self.edges:
            out[u].append(v)
        return out

    def topological_order(self) -> list[int]:
        out = self.adjacency()
        indegree = [0] * self.n
        for _, v in self.edges:
            indegree[v] += 1
        queue = deque(v for v in range(self.n) if indegree[v] == 0)
        order: list[int] = []
        while queue:
            u = queue.popleft()
            order.append(u)
            for v in out[u]:
                indegree[v] -= 1
                if indegree[v] == 0:
                    queue.append(v)
        if len(order) != self.n:
            raise ValueError("The graph contains a directed cycle")
        return order

    def ancestor_sets(self) -> list[set[int]]:
        """Compute all strict ancestors by topological dynamic programming."""
        out = self.adjacency()
        ancestors = [set() for _ in range(self.n)]
        for u in self.topological_order():
            for v in out[u]:
                ancestors[v].update(ancestors[u])
                ancestors[v].add(u)
        return ancestors

    def canonical_ranks(self) -> list[int]:
        return [len(items) for items in self.ancestor_sets()]

    def incomparable_pairs(self) -> list[tuple[int, int]]:
        ancestors = self.ancestor_sets()
        return [
            (a, b)
            for a in range(self.n)
            for b in range(a + 1, self.n)
            if a not in ancestors[b] and b not in ancestors[a]
        ]

    def weakly_connected_after_deletion(self, deleted: int) -> bool:
        survivors = [v for v in range(self.n) if v != deleted]
        if len(survivors) <= 1:
            return True
        undirected = [set() for _ in range(self.n)]
        for u, v in self.edges:
            if u != deleted and v != deleted:
                undirected[u].add(v)
                undirected[v].add(u)
        seen = {survivors[0]}
        queue = deque([survivors[0]])
        while queue:
            u = queue.popleft()
            for v in undirected[u] - seen:
                seen.add(v)
                queue.append(v)
        return len(seen) == len(survivors)


def total_order_dag(n: int) -> DependencyDAG:
    """Return the robust acyclic graph with edge i -> j exactly when i < j."""
    return DependencyDAG(n, tuple((i, j) for i in range(n) for j in range(i + 1, n)))


def graph_from_edges(n: int, edges: Iterable[Edge]) -> DependencyDAG:
    return DependencyDAG(n, tuple(edges))


def print_graph_report(name: str, graph: DependencyDAG) -> None:
    ancestors = graph.ancestor_sets()
    ranks = graph.canonical_ranks()
    print(f"\n{name}")
    print("-" * len(name))
    print(f"vertices={graph.n}, edges={len(graph.edges)}")
    for v in range(graph.n):
        print(f"vertex {v}: ancestors={sorted(ancestors[v])}, rank={ranks[v]}")
    print(f"incomparable pairs: {graph.incomparable_pairs()}")
    robustness = [graph.weakly_connected_after_deletion(v) for v in range(graph.n)]
    print(f"weakly connected after deleting each vertex: {robustness}")


def demonstrate_width_depth() -> None:
    """Show that equal strict ranks produce an incomparable pair."""
    diamond = graph_from_edges(4, [(0, 1), (0, 2), (1, 3), (2, 3)])
    ranks = diamond.canonical_ranks()
    assert ranks == [0, 1, 1, 3]
    assert (1, 2) in diamond.incomparable_pairs()
    print_graph_report("Diamond: a rank collision forces width", diamond)


def demonstrate_robust_family(n: int = 7) -> None:
    """Check every deletion in a strict total-order DAG."""
    graph = total_order_dag(n)
    assert graph.canonical_ranks() == list(range(n))
    assert all(graph.weakly_connected_after_deletion(v) for v in range(n))
    print_graph_report(f"Strict total order on {n} vertices", graph)


def contrast_chain_and_total_order(n: int = 6) -> None:
    """Compare graphs with identical ranks but different deletion robustness."""
    chain = graph_from_edges(n, ((i, i + 1) for i in range(n - 1)))
    dense = total_order_dag(n)
    assert chain.canonical_ranks() == dense.canonical_ranks() == list(range(n))
    chain_status = [chain.weakly_connected_after_deletion(v) for v in range(n)]
    dense_status = [dense.weakly_connected_after_deletion(v) for v in range(n)]
    print("\nSame canonical ranks, different robustness")
    print("------------------------------------------")
    print(f"chain deletion status:       {chain_status}")
    print(f"total-order deletion status: {dense_status}")


def main() -> None:
    demonstrate_width_depth()
    demonstrate_robust_family()
    contrast_chain_and_total_order()


if __name__ == "__main__":
    main()
