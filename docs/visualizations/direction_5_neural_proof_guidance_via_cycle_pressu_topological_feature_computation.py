"""
Algorithms for Cycle Pressure and Topological Feature Computation.

This module implements the core algorithms from the research paper on
neural proof guidance via cycle pressure features. All algorithms are
designed for finite simple graphs represented as adjacency lists.
"""

from __future__ import annotations
import math
from collections import defaultdict, deque
from dataclasses import dataclass
from typing import Dict, List, Set, Tuple, Optional


@dataclass
class TopologicalFeatureVector:
    """Topological feature vector for a vertex in a graph.

    Attributes:
        cycle_rank: First Betti number (|E| + 1 - |V| for connected graphs)
        degree: Degree of the vertex
        edge_count: Number of edges in the graph/neighborhood
        vertex_count: Number of vertices in the graph/neighborhood
    """
    cycle_rank: int
    degree: int
    edge_count: int
    vertex_count: int

    def to_tree_local(self) -> 'TreeLocalFeatureVector':
        """Project to tree-local features, discarding cycle information."""
        return TreeLocalFeatureVector(degree=self.degree, vertex_count=self.vertex_count)


@dataclass
class TreeLocalFeatureVector:
    """Tree-local feature vector (cycle-blind).

    Attributes:
        degree: Degree of the vertex
        vertex_count: Number of vertices in the neighborhood
    """
    degree: int
    vertex_count: int


class SimpleGraph:
    """A finite simple graph represented as an adjacency list.

    Example:
        >>> g = SimpleGraph()
        >>> g.add_edge(0, 1)
        >>> g.add_edge(1, 2)
        >>> g.add_edge(2, 0)
        >>> g.vertex_count()
        3
        >>> g.edge_count()
        3
        >>> g.cycle_rank()
        1
    """

    def __init__(self) -> None:
        self._adj: Dict[int, Set[int]] = defaultdict(set)
        self._edges: Set[frozenset] = set()

    def add_vertex(self, v: int) -> None:
        """Add an isolated vertex."""
        if v not in self._adj:
            self._adj[v] = set()

    def add_edge(self, u: int, v: int) -> None:
        """Add an undirected edge. No self-loops allowed."""
        if u == v:
            raise ValueError(f"Self-loops not allowed: {u}")
        self._adj[u].add(v)
        self._adj[v].add(u)
        self._edges.add(frozenset({u, v}))

    def vertices(self) -> Set[int]:
        return set(self._adj.keys())

    def edges(self) -> Set[frozenset]:
        return set(self._edges)

    def vertex_count(self) -> int:
        return len(self._adj)

    def edge_count(self) -> int:
        return len(self._edges)

    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return len(self._adj.get(v, set()))

    def neighbors(self, v: int) -> Set[int]:
        return set(self._adj.get(v, set()))

    def connected_components(self) -> int:
        """Count the number of connected components using BFS."""
        visited: Set[int] = set()
        count = 0
        for v in self._adj:
            if v not in visited:
                count += 1
                queue = deque([v])
                while queue:
                    u = queue.popleft()
                    if u in visited:
                        continue
                    visited.add(u)
                    for w in self._adj[u]:
                        if w not in visited:
                            queue.append(w)
        return count

    def is_connected(self) -> bool:
        return self.connected_components() == 1

    def cycle_rank(self) -> int:
        """Compute the cycle rank (first Betti number).

        For a graph with |E| edges, |V| vertices, and c components:
            cycle_rank = |E| - |V| + c

        For connected graphs, this equals |E| - |V| + 1.

        Returns:
            The cycle rank (always ≥ 0 for simple graphs).
        """
        return self.edge_count() - self.vertex_count() + self.connected_components()

    def nat_cycle_rank(self) -> int:
        """Natural cycle rank: max(0, |E| + 1 - |V|).

        Matches the Lean definition for connected graphs.
        """
        return max(0, self.edge_count() + 1 - self.vertex_count())

    def r_hop_neighborhood(self, v: int, r: int) -> 'SimpleGraph':
        """Extract the r-hop neighborhood subgraph around vertex v.

        Args:
            v: Center vertex
            r: Radius (number of hops)

        Returns:
            Induced subgraph on vertices within distance r of v.
        """
        # BFS to find vertices within distance r
        visited: Dict[int, int] = {v: 0}
        queue = deque([(v, 0)])
        while queue:
            u, d = queue.popleft()
            if d >= r:
                continue
            for w in self._adj.get(u, set()):
                if w not in visited:
                    visited[w] = d + 1
                    queue.append((w, d + 1))

        # Build induced subgraph
        subgraph = SimpleGraph()
        for u in visited:
            subgraph.add_vertex(u)
        for e in self._edges:
            u, w = tuple(e)
            if u in visited and w in visited:
                subgraph.add_edge(u, w)
        return subgraph


def compute_topological_features(g: SimpleGraph, v: int) -> TopologicalFeatureVector:
    """Compute the topological feature vector for vertex v in graph g.

    This is the Python implementation of the formally verified Lean function
    `computeTopologicalFeatures`.

    Args:
        g: A finite simple graph
        v: A vertex in g

    Returns:
        TopologicalFeatureVector with cycle_rank, degree, edge_count, vertex_count

    Example:
        >>> triangle = SimpleGraph()
        >>> for u, w in [(0,1), (1,2), (0,2)]: triangle.add_edge(u, w)
        >>> features = compute_topological_features(triangle, 1)
        >>> features.cycle_rank
        1
        >>> features.degree
        2
    """
    return TopologicalFeatureVector(
        cycle_rank=g.nat_cycle_rank(),
        degree=g.degree(v),
        edge_count=g.edge_count(),
        vertex_count=g.vertex_count()
    )


def compute_local_cycle_pressure(g: SimpleGraph, v: int, radius: int) -> int:
    """Compute the local cycle pressure of vertex v at given radius.

    Args:
        g: A finite simple graph
        v: A vertex in g
        radius: The neighborhood radius

    Returns:
        The cycle rank of the r-hop neighborhood around v.

    Example:
        >>> g = SimpleGraph()
        >>> for u, w in [(0,1), (1,2), (2,3), (3,0)]: g.add_edge(u, w)
        >>> compute_local_cycle_pressure(g, 0, 2)
        1
    """
    neighborhood = g.r_hop_neighborhood(v, radius)
    return neighborhood.nat_cycle_rank()


def branching_factor(cycle_rank: int) -> int:
    """Compute the branching factor from cycle rank: 2^cycle_rank.

    Args:
        cycle_rank: The cycle rank (≥ 0)

    Returns:
        2^cycle_rank

    Example:
        >>> branching_factor(0)
        1
        >>> branching_factor(3)
        8
    """
    return 2 ** cycle_rank


def branching_lower_bound(cycle_rank: int) -> int:
    """Compute the theoretical lower bound: cr * floor(log2(cr + 1)).

    This is the lower bound from Theorem 1.

    Args:
        cycle_rank: The cycle rank (≥ 0)

    Returns:
        cycle_rank * floor(log2(cycle_rank + 1))

    Example:
        >>> branching_lower_bound(3)
        6
        >>> branching_lower_bound(0)
        0
    """
    if cycle_rank == 0:
        return 0
    return cycle_rank * int(math.log2(cycle_rank + 1))


def verify_branching_bound(max_k: int = 20) -> List[Tuple[int, int, int, bool]]:
    """Verify the branching factor bound for k = 0, ..., max_k.

    Returns a list of (k, lower_bound, branching_factor, bound_holds).

    Example:
        >>> results = verify_branching_bound(5)
        >>> all(r[3] for r in results)
        True
    """
    results = []
    for k in range(max_k + 1):
        lb = branching_lower_bound(k)
        bf = branching_factor(k)
        results.append((k, lb, bf, lb <= bf))
    return results


def compute_cycle_pressure_profile(
    g: SimpleGraph, radius: int
) -> Dict[int, TopologicalFeatureVector]:
    """Compute topological features for all vertices in a graph.

    Args:
        g: A finite simple graph
        radius: Neighborhood radius for local cycle pressure

    Returns:
        Dictionary mapping vertex -> TopologicalFeatureVector
        (computed on the local neighborhood)

    Example:
        >>> g = SimpleGraph()
        >>> for u, w in [(0,1), (1,2), (2,0)]: g.add_edge(u, w)
        >>> profile = compute_cycle_pressure_profile(g, 2)
        >>> profile[0].cycle_rank
        1
    """
    result = {}
    for v in g.vertices():
        neighborhood = g.r_hop_neighborhood(v, radius)
        result[v] = compute_topological_features(neighborhood, v)
    return result


# --- Graph constructors for standard families ---

def complete_graph(n: int) -> SimpleGraph:
    """Construct the complete graph K_n.

    Example:
        >>> k4 = complete_graph(4)
        >>> k4.edge_count()
        6
        >>> k4.cycle_rank()
        3
    """
    g = SimpleGraph()
    for i in range(n):
        g.add_vertex(i)
        for j in range(i):
            g.add_edge(i, j)
    return g


def cycle_graph(n: int) -> SimpleGraph:
    """Construct the cycle graph C_n.

    Example:
        >>> c5 = cycle_graph(5)
        >>> c5.edge_count()
        5
        >>> c5.cycle_rank()
        1
    """
    g = SimpleGraph()
    for i in range(n):
        g.add_vertex(i)
        g.add_edge(i, (i + 1) % n)
    return g


def path_graph(n: int) -> SimpleGraph:
    """Construct the path graph P_n on n vertices.

    Example:
        >>> p4 = path_graph(4)
        >>> p4.edge_count()
        3
        >>> p4.cycle_rank()
        0
    """
    g = SimpleGraph()
    for i in range(n):
        g.add_vertex(i)
        if i > 0:
            g.add_edge(i - 1, i)
    return g


def binary_tree(depth: int) -> SimpleGraph:
    """Construct a complete binary tree of given depth.

    Example:
        >>> t = binary_tree(3)
        >>> t.vertex_count()
        15
        >>> t.cycle_rank()
        0
    """
    g = SimpleGraph()
    n_vertices = 2 ** (depth + 1) - 1
    for i in range(n_vertices):
        g.add_vertex(i)
    for i in range(n_vertices):
        left = 2 * i + 1
        right = 2 * i + 2
        if left < n_vertices:
            g.add_edge(i, left)
        if right < n_vertices:
            g.add_edge(i, right)
    return g


def petersen_graph() -> SimpleGraph:
    """Construct the Petersen graph.

    Example:
        >>> p = petersen_graph()
        >>> p.vertex_count()
        10
        >>> p.edge_count()
        15
        >>> p.cycle_rank()
        6
    """
    g = SimpleGraph()
    for i in range(10):
        g.add_vertex(i)
    # Outer cycle
    for i in range(5):
        g.add_edge(i, (i + 1) % 5)
    # Inner pentagram
    for i in range(5):
        g.add_edge(5 + i, 5 + (i + 2) % 5)
    # Spokes
    for i in range(5):
        g.add_edge(i, 5 + i)
    return g


if __name__ == "__main__":
    # Verify the main theorem computationally
    print("=== Verifying Branching Factor Bound (Theorem 1) ===")
    print(f"{'k':>4} {'k*log2(k+1)':>12} {'2^k':>12} {'Holds':>8}")
    print("-" * 40)
    for k, lb, bf, holds in verify_branching_bound(15):
        print(f"{k:>4} {lb:>12} {bf:>12} {'✓' if holds else '✗':>8}")

    print("\n=== Witness Graphs for Theorem 2 (Tree Feature Insufficiency) ===")
    tri = complete_graph(3)
    path = path_graph(3)
    tri_feat = compute_topological_features(tri, 1)
    path_feat = compute_topological_features(path, 1)
    print(f"K₃ at vertex 1: {tri_feat}")
    print(f"P₃ at vertex 1: {path_feat}")
    print(f"Tree-local equal: {tri_feat.to_tree_local() == path_feat.to_tree_local()}")
    print(f"Topological different: {tri_feat != path_feat}")

    print("\n=== Cycle Pressure Profile ===")
    for name, g in [("K₃", complete_graph(3)), ("K₄", complete_graph(4)),
                     ("C₅", cycle_graph(5)), ("Petersen", petersen_graph()),
                     ("P₃", path_graph(3)), ("Tree(3)", binary_tree(3))]:
        cr = g.nat_cycle_rank()
        bf = branching_factor(cr)
        lb = branching_lower_bound(cr)
        print(f"{name:>10}: V={g.vertex_count()}, E={g.edge_count()}, "
              f"cr={cr}, BF=2^{cr}={bf}, LB={lb}")
