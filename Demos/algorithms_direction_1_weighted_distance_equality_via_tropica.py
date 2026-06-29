"""
Algorithms for Weighted Distance Equality via Tropical Cycle Optimization.

This module implements the core algorithms for computing minimum cycle weights,
cycle support weights, girth-adapted filtrations, and first cycle birth values
in weighted graphs. These algorithms connect tropical optimization to quantum
code distance.

Author: Harmonic Research
"""

from typing import List, Tuple, Dict, Set, Optional
from itertools import combinations
from collections import defaultdict
import heapq


class WeightedGraph:
    """A finite simple weighted graph.

    Attributes:
        vertices: Set of vertex labels.
        edges: Dict mapping (u, v) pairs (u < v) to positive weights.
        adj: Adjacency list representation.
    """

    def __init__(self):
        self.vertices: Set[int] = set()
        self.edges: Dict[Tuple[int, int], float] = {}
        self.adj: Dict[int, Set[int]] = defaultdict(set)

    def add_edge(self, u: int, v: int, weight: float) -> None:
        """Add an undirected edge with positive weight."""
        assert weight > 0, "Edge weights must be positive"
        a, b = min(u, v), max(u, v)
        self.vertices.add(a)
        self.vertices.add(b)
        self.edges[(a, b)] = weight
        self.adj[a].add(b)
        self.adj[b].add(a)

    def get_weight(self, u: int, v: int) -> float:
        """Get weight of edge (u, v)."""
        a, b = min(u, v), max(u, v)
        return self.edges.get((a, b), float('inf'))

    def edge_list(self) -> List[Tuple[int, int]]:
        """Return sorted list of edges."""
        return sorted(self.edges.keys())

    def num_vertices(self) -> int:
        return len(self.vertices)

    def num_edges(self) -> int:
        return len(self.edges)


def enumerate_simple_cycles(G: WeightedGraph) -> List[List[Tuple[int, int]]]:
    """Enumerate all simple cycles in a graph.

    Uses DFS-based cycle detection. Each cycle is returned as a list of
    edges (u, v) with u < v.

    Time complexity: O(V! / (V - k)!) in the worst case for cycles of length k.
    For small graphs (V ≤ 20), this is tractable.

    Args:
        G: A WeightedGraph instance.

    Returns:
        List of cycles, each cycle being a list of edges.
    """
    vertices = sorted(G.vertices)
    cycles = []
    seen_cycles = set()

    def dfs(start: int, current: int, path: List[int], visited: Set[int]):
        for neighbor in sorted(G.adj[current]):
            if neighbor == start and len(path) >= 3:
                # Found a cycle
                cycle_edges = []
                for i in range(len(path)):
                    u, v = path[i], path[(i + 1) % len(path)]
                    a, b = min(u, v), max(u, v)
                    cycle_edges.append((a, b))
                # Canonical form: sort edges for deduplication
                key = tuple(sorted(cycle_edges))
                if key not in seen_cycles:
                    seen_cycles.add(key)
                    cycles.append(cycle_edges)
            elif neighbor > start and neighbor not in visited:
                visited.add(neighbor)
                path.append(neighbor)
                dfs(start, neighbor, path, visited)
                path.pop()
                visited.remove(neighbor)

    for v in vertices:
        dfs(v, v, [v], {v})

    return cycles


def cycle_weight(G: WeightedGraph, cycle: List[Tuple[int, int]]) -> float:
    """Compute total weight of a cycle.

    Args:
        G: The weighted graph.
        cycle: List of edges forming the cycle.

    Returns:
        Sum of edge weights in the cycle.
    """
    return sum(G.edges[e] for e in cycle)


def min_simple_cycle_weight(G: WeightedGraph) -> Optional[float]:
    """Compute the minimum simple cycle weight (weighted girth / systole).

    This is the tropical optimization invariant: the minimum of the
    linear functional ⟨w, x⟩ over the cycle polytope.

    Args:
        G: A WeightedGraph instance.

    Returns:
        Minimum cycle weight, or None if graph is acyclic.
    """
    cycles = enumerate_simple_cycles(G)
    if not cycles:
        return None
    return min(cycle_weight(G, c) for c in cycles)


def cycle_support_weight(G: WeightedGraph, edge: Tuple[int, int]) -> float:
    """Compute cycle support weight of an edge.

    csw(e) = min{∑_{e' ∈ C} w(e') : C is a simple cycle, e ∈ C}

    This is the "local tropical shadow" of the global weighted systole.

    Args:
        G: The weighted graph.
        edge: The edge (u, v) with u < v.

    Returns:
        Minimum weight of any cycle containing edge, or infinity if bridge.
    """
    cycles = enumerate_simple_cycles(G)
    relevant = [c for c in cycles if edge in c]
    if not relevant:
        return float('inf')
    return min(cycle_weight(G, c) for c in relevant)


def girth_adapted_order(G: WeightedGraph) -> List[Tuple[int, int]]:
    """Compute girth-adapted edge ordering.

    The ordering ensures that a minimum-weight cycle's edges are processed
    early enough that the first redundant edge creates a minimum-weight cycle.

    Strategy: find a minimum-weight cycle C*. Process its edges such that
    the heaviest edge comes last (making it the redundant/closing edge).
    Then process remaining edges by (csw, weight).

    Time complexity: O(|E| · C) where C is the cost of cycle enumeration.

    Args:
        G: A WeightedGraph instance.

    Returns:
        List of edges in girth-adapted order.
    """
    cycles = enumerate_simple_cycles(G)
    if not cycles:
        return sorted(G.edge_list(), key=lambda e: (G.edges[e], e))

    # Find minimum-weight cycle
    min_cycle = min(cycles, key=lambda c: cycle_weight(G, c))
    min_cycle_set = set(min_cycle)

    # Order min cycle edges: process all but heaviest first, heaviest last
    min_cycle_sorted = sorted(min_cycle, key=lambda e: (G.edges[e], e))
    # heaviest edge of min cycle goes last among min_cycle edges
    priority_edges = min_cycle_sorted  # ascending weight → heaviest last

    # Remaining edges by (csw, weight)
    remaining = [e for e in G.edge_list() if e not in min_cycle_set]
    csw_cache = {e: cycle_support_weight(G, e) for e in remaining}
    remaining_sorted = sorted(remaining, key=lambda e: (csw_cache[e], G.edges[e], e))

    return priority_edges + remaining_sorted


def kruskal_order(G: WeightedGraph) -> List[Tuple[int, int]]:
    """Compute Kruskal (raw weight) edge ordering.

    Edges sorted by weight, with tiebreaking by edge label.

    Args:
        G: A WeightedGraph instance.

    Returns:
        List of edges in Kruskal order.
    """
    return sorted(G.edge_list(), key=lambda e: (G.edges[e], e))


class UnionFind:
    """Union-Find data structure for cycle detection during filtration."""

    def __init__(self, vertices):
        self.parent = {v: v for v in vertices}
        self.rank = {v: 0 for v in vertices}

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y) -> bool:
        """Union two sets. Returns True if they were already in the same set (cycle!)."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return True  # Same component → cycle created
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return False

    def connected(self, x, y) -> bool:
        return self.find(x) == self.find(y)


def find_cycle_in_forest(G: WeightedGraph, forest_edges: List[Tuple[int, int]],
                          new_edge: Tuple[int, int]) -> List[Tuple[int, int]]:
    """Find the cycle created by adding new_edge to a forest.

    Uses BFS to find the path in the forest between the endpoints of
    new_edge, then combines with new_edge to form the cycle.

    Args:
        G: The weighted graph.
        forest_edges: Current forest edges.
        new_edge: The edge being added (creates a cycle).

    Returns:
        List of edges forming the cycle.
    """
    u, v = new_edge
    # Build adjacency for forest
    adj = defaultdict(list)
    for a, b in forest_edges:
        adj[a].append(b)
        adj[b].append(a)

    # BFS from u to v in the forest
    queue = [(u, [u])]
    visited = {u}
    while queue:
        current, path = queue.pop(0)
        for neighbor in adj[current]:
            if neighbor == v:
                # Found path, construct cycle edges
                full_path = path + [v]
                cycle_edges = []
                for i in range(len(full_path) - 1):
                    a, b = min(full_path[i], full_path[i+1]), max(full_path[i], full_path[i+1])
                    cycle_edges.append((a, b))
                cycle_edges.append(new_edge)
                return cycle_edges
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, path + [neighbor]))

    return [new_edge]  # Shouldn't happen in a valid forest


def first_cycle_birth_value(G: WeightedGraph,
                             order: List[Tuple[int, int]]) -> Optional[Tuple[float, List[Tuple[int, int]]]]:
    """Compute first cycle birth value under a given edge ordering.

    Process edges in the given order, maintaining a spanning forest.
    When the first redundant edge is encountered (creating a cycle),
    return the total weight of that cycle.

    This is the key algorithmic component: it connects edge ordering
    to cycle weight computation.

    Args:
        G: The weighted graph.
        order: Edge ordering (list of edges).

    Returns:
        Tuple of (cycle_weight, cycle_edges) or None if acyclic.
    """
    uf = UnionFind(G.vertices)
    forest_edges = []

    for edge in order:
        u, v = edge
        if uf.connected(u, v):
            # Redundant edge → cycle!
            cycle_edges = find_cycle_in_forest(G, forest_edges, edge)
            total_weight = sum(G.edges[e] for e in cycle_edges)
            return (total_weight, cycle_edges)
        else:
            uf.union(u, v)
            forest_edges.append(edge)

    return None  # Acyclic graph


def compare_filtrations(G: WeightedGraph) -> Dict:
    """Compare Kruskal and girth-adapted filtrations.

    Computes the first cycle birth value under both orderings and
    compares with the exhaustive minimum simple cycle weight.

    Returns:
        Dictionary with comparison results and obstruction data.
    """
    min_weight = min_simple_cycle_weight(G)
    if min_weight is None:
        return {"acyclic": True}

    kruskal = kruskal_order(G)
    girth = girth_adapted_order(G)

    kruskal_result = first_cycle_birth_value(G, kruskal)
    girth_result = first_cycle_birth_value(G, girth)

    kruskal_val = kruskal_result[0] if kruskal_result else None
    girth_val = girth_result[0] if girth_result else None

    result = {
        "acyclic": False,
        "min_simple_cycle_weight": min_weight,
        "kruskal_first_birth": kruskal_val,
        "girth_adapted_first_birth": girth_val,
        "kruskal_correct": abs(kruskal_val - min_weight) < 1e-10 if kruskal_val else False,
        "girth_correct": abs(girth_val - min_weight) < 1e-10 if girth_val else False,
        "kruskal_order": kruskal,
        "girth_order": girth,
    }

    # Check for Kruskal obstruction
    if kruskal_val and abs(kruskal_val - min_weight) > 1e-10:
        # Find obstruction witness
        cycles = enumerate_simple_cycles(G)
        min_cycles = [c for c in cycles if abs(cycle_weight(G, c) - min_weight) < 1e-10]
        kruskal_cycle = kruskal_result[1] if kruskal_result else []

        result["obstruction"] = {
            "kruskal_cycle_weight": kruskal_val,
            "min_cycle_weight": min_weight,
            "excess": kruskal_val - min_weight,
            "num_min_weight_cycles": len(min_cycles),
            "kruskal_cycle": kruskal_cycle,
            "min_cycle_example": min_cycles[0] if min_cycles else None,
        }

    return result


def redundant_edge_count(G: WeightedGraph) -> int:
    """Compute the number of redundant edges (cycle rank = β₁).

    β₁ = |E| - |V| + c, where c is the number of connected components.
    This is weight-invariant (topological invariant).

    Args:
        G: A WeightedGraph instance.

    Returns:
        The cycle rank (first Betti number).
    """
    uf = UnionFind(G.vertices)
    for u, v in G.edges:
        uf.union(u, v)
    components = len(set(uf.find(v) for v in G.vertices))
    return G.num_edges() - G.num_vertices() + components


def build_random_weighted_graph(n: int, p: float = 0.4,
                                 max_weight: int = 10, seed: int = None) -> WeightedGraph:
    """Build a random weighted graph.

    Args:
        n: Number of vertices (labeled 0..n-1).
        p: Edge probability.
        max_weight: Maximum integer weight.
        seed: Random seed.

    Returns:
        A random WeightedGraph.
    """
    import random
    if seed is not None:
        random.seed(seed)

    G = WeightedGraph()
    for v in range(n):
        G.vertices.add(v)

    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                w = random.randint(1, max_weight)
                G.add_edge(i, j, w)

    return G


if __name__ == "__main__":
    # Example: demonstrate the algorithms
    print("=" * 60)
    print("Weighted Cycle Distance Algorithms - Example")
    print("=" * 60)

    # Build example graph where Kruskal fails
    G = WeightedGraph()
    # 11-cycle with unit weights
    for i in range(11):
        G.add_edge(i, (i + 1) % 11, 1.0)
    # Add chord creating a triangle with weight 5
    G.add_edge(0, 2, 3.0)

    print(f"\nGraph: 11-cycle + chord (0,2)")
    print(f"Vertices: {len(G.vertices)}")
    print(f"Edges: {len(G.edges)}")

    min_w = min_simple_cycle_weight(G)
    print(f"\nMinimum simple cycle weight: {min_w}")

    result = compare_filtrations(G)
    print(f"Kruskal first birth:       {result['kruskal_first_birth']}")
    print(f"Girth-adapted first birth: {result['girth_adapted_first_birth']}")
    print(f"Kruskal correct: {result['kruskal_correct']}")
    print(f"Girth-adapted correct: {result['girth_correct']}")

    if "obstruction" in result:
        obs = result["obstruction"]
        print(f"\n*** Kruskal FAILURE detected ***")
        print(f"Kruskal cycle weight: {obs['kruskal_cycle_weight']}")
        print(f"Min cycle weight: {obs['min_cycle_weight']}")
        print(f"Excess: {obs['excess']}")
