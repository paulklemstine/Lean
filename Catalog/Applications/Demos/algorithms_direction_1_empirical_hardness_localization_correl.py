"""
Algorithms for Topological Hardness-Localization Duality

Implements the core computational algorithms from the research:
- Cycle rank computation
- Local cycle pressure computation
- Semantic pressure field construction
- Bridge detection via DFS

All algorithms operate on simple undirected graphs represented
as adjacency lists.
"""

from __future__ import annotations
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict, deque
import math


class SimpleGraph:
    """A simple undirected graph with labeled vertices.
    
    Attributes:
        vertices: Set of vertex labels
        adj: Adjacency list (vertex -> set of neighbors)
    """
    
    def __init__(self, vertices: Set[int] = None):
        self.vertices: Set[int] = vertices or set()
        self.adj: Dict[int, Set[int]] = defaultdict(set)
    
    def add_vertex(self, v: int) -> None:
        self.vertices.add(v)
    
    def add_edge(self, u: int, v: int) -> None:
        """Add undirected edge {u, v}."""
        if u == v:
            return  # No self-loops
        self.vertices.add(u)
        self.vertices.add(v)
        self.adj[u].add(v)
        self.adj[v].add(u)
    
    def edges(self) -> Set[Tuple[int, int]]:
        """Return set of edges as (min, max) tuples."""
        result = set()
        for u in self.vertices:
            for v in self.adj[u]:
                result.add((min(u, v), max(u, v)))
        return result
    
    def degree(self, v: int) -> int:
        return len(self.adj[v])
    
    def num_vertices(self) -> int:
        return len(self.vertices)
    
    def num_edges(self) -> int:
        return len(self.edges())
    
    def copy(self) -> 'SimpleGraph':
        g = SimpleGraph(self.vertices.copy())
        for v in self.vertices:
            g.adj[v] = self.adj[v].copy()
        return g
    
    def remove_edge(self, u: int, v: int) -> None:
        self.adj[u].discard(v)
        self.adj[v].discard(u)


def connected_components(G: SimpleGraph) -> List[Set[int]]:
    """Find all connected components using BFS.
    
    Time complexity: O(V + E)
    Space complexity: O(V)
    
    Returns:
        List of sets, each set is a connected component.
    """
    visited = set()
    components = []
    for start in G.vertices:
        if start in visited:
            continue
        component = set()
        queue = deque([start])
        while queue:
            v = queue.popleft()
            if v in visited:
                continue
            visited.add(v)
            component.add(v)
            for w in G.adj[v]:
                if w not in visited:
                    queue.append(w)
        components.append(component)
    return components


def is_connected(G: SimpleGraph) -> bool:
    """Check if graph is connected. O(V + E)."""
    if not G.vertices:
        return True
    comps = connected_components(G)
    return len(comps) == 1


def graph_cycle_rank(G: SimpleGraph) -> int:
    """Compute the cycle rank (cyclomatic number) of a graph.
    
    Formula: β₁ = |E| - |V| + |C|
    where |C| is the number of connected components.
    
    This is the first Betti number of the graph viewed as a 
    1-dimensional CW complex.
    
    Time complexity: O(V + E) (dominated by component counting)
    Space complexity: O(V)
    
    Returns:
        The cycle rank (always ≥ 0).
    
    Example:
        >>> G = SimpleGraph()
        >>> for i in range(4): G.add_vertex(i)
        >>> G.add_edge(0,1); G.add_edge(1,2); G.add_edge(2,0); G.add_edge(2,3)
        >>> graph_cycle_rank(G)
        1
    """
    E = G.num_edges()
    V = G.num_vertices()
    C = len(connected_components(G))
    return E - V + C


def find_bridges(G: SimpleGraph) -> Set[Tuple[int, int]]:
    """Find all bridge edges using Tarjan's bridge-finding algorithm.
    
    An edge is a bridge if removing it increases the number of 
    connected components. Equivalently, an edge is a bridge iff
    it does not lie on any cycle.
    
    Time complexity: O(V + E)
    Space complexity: O(V)
    
    Returns:
        Set of bridge edges as (min, max) tuples.
    
    Example:
        >>> G = SimpleGraph()
        >>> G.add_edge(0,1); G.add_edge(1,2); G.add_edge(2,0); G.add_edge(2,3)
        >>> find_bridges(G)
        {(2, 3)}
    """
    bridges = set()
    visited = set()
    disc = {}
    low = {}
    parent = {}
    timer = [0]
    
    def dfs(u: int):
        visited.add(u)
        disc[u] = low[u] = timer[0]
        timer[0] += 1
        
        for v in G.adj[u]:
            if v not in visited:
                parent[v] = u
                dfs(v)
                low[u] = min(low[u], low[v])
                if low[v] > disc[u]:
                    bridges.add((min(u, v), max(u, v)))
            elif v != parent.get(u, -1):
                low[u] = min(low[u], disc[v])
    
    for v in G.vertices:
        if v not in visited:
            parent[v] = -1
            dfs(v)
    
    return bridges


def local_cycle_pressure(G: SimpleGraph, v: int) -> int:
    """Compute the local cycle pressure at vertex v.
    
    This is the number of non-bridge edges incident to v.
    High local cycle pressure indicates that v sits in a 
    cycle-dense region of the graph.
    
    Time complexity: O(V + E) (dominated by bridge-finding)
    Space complexity: O(V)
    
    Returns:
        Number of non-bridge edges incident to v.
    
    Example:
        >>> G = SimpleGraph()
        >>> G.add_edge(0,1); G.add_edge(1,2); G.add_edge(2,0); G.add_edge(2,3)
        >>> local_cycle_pressure(G, 0)
        2
        >>> local_cycle_pressure(G, 3)
        0
    """
    bridges = find_bridges(G)
    count = 0
    for w in G.adj[v]:
        edge = (min(v, w), max(v, w))
        if edge not in bridges:
            count += 1
    return count


def compute_all_pressures(G: SimpleGraph) -> Dict[int, int]:
    """Compute local cycle pressure for all vertices.
    
    Time complexity: O(V + E)
    Space complexity: O(V)
    
    Returns:
        Dictionary mapping vertex -> local cycle pressure.
    """
    bridges = find_bridges(G)
    pressures = {}
    for v in G.vertices:
        count = 0
        for w in G.adj[v]:
            edge = (min(v, w), max(v, w))
            if edge not in bridges:
                count += 1
        pressures[v] = count
    return pressures


class SemanticPressureField:
    """A semantic pressure field on a graph.
    
    Assigns to each vertex a non-negative pressure value
    bounded by the cycle rank, providing a local measure
    of topological complexity.
    
    Attributes:
        graph: The underlying SimpleGraph
        pressure: Dict mapping vertex -> pressure value
        cycle_rank: The graph's cycle rank
    """
    
    def __init__(self, graph: SimpleGraph, pressure: Dict[int, float], 
                 cycle_rank: int):
        self.graph = graph
        self.pressure = pressure
        self.cycle_rank = cycle_rank
        # Verify axioms
        assert all(p >= 0 for p in pressure.values()), \
            "Pressure must be non-negative"
        assert sum(pressure.values()) <= cycle_rank + 1e-10, \
            f"Total pressure {sum(pressure.values())} exceeds cycle rank {cycle_rank}"
    
    def top_k_vertices(self, k: int = 5) -> List[Tuple[int, float]]:
        """Return the k vertices with highest pressure."""
        sorted_verts = sorted(self.pressure.items(), 
                             key=lambda x: x[1], reverse=True)
        return sorted_verts[:k]
    
    def concentration(self, v: int) -> float:
        """Pressure concentration at vertex v."""
        if self.cycle_rank == 0:
            return 0.0
        return self.pressure[v] / self.cycle_rank


def compute_semantic_pressure_field(G: SimpleGraph) -> SemanticPressureField:
    """Compute the canonical semantic pressure field for a graph.
    
    The pressure at each vertex is the local cycle pressure
    normalized to sum to at most the cycle rank.
    
    Time complexity: O(V + E)
    Space complexity: O(V)
    
    Returns:
        A SemanticPressureField satisfying all axioms.
    
    Example:
        >>> G = SimpleGraph()
        >>> G.add_edge(0,1); G.add_edge(1,2); G.add_edge(2,0)
        >>> field = compute_semantic_pressure_field(G)
        >>> field.cycle_rank
        1
    """
    raw_pressures = compute_all_pressures(G)
    cr = graph_cycle_rank(G)
    
    # Normalize: each non-bridge edge is counted twice (once per endpoint)
    # so total raw pressure = 2 * (number of non-bridge edges) = 2 * cycle_rank
    total_raw = sum(raw_pressures.values())
    
    if total_raw == 0:
        pressure = {v: 0.0 for v in G.vertices}
    else:
        # Scale so total pressure = cycle_rank
        scale = cr / total_raw
        pressure = {v: p * scale for v, p in raw_pressures.items()}
    
    return SemanticPressureField(G, pressure, cr)


def semantic_distance(features_a: Set, features_b: Set) -> int:
    """Compute semantic distance (symmetric difference cardinality).
    
    Time complexity: O(|A| + |B|)
    """
    return len(features_a.symmetric_difference(features_b))


def build_semantic_graph(feature_sets: Dict[int, Set], 
                         threshold: int) -> SimpleGraph:
    """Build a semantic threshold graph.
    
    Two vertices are adjacent iff their semantic distance
    (symmetric difference of feature sets) is ≤ threshold.
    
    Time complexity: O(V² · F) where F is max feature set size.
    Space complexity: O(V²) in the worst case.
    
    Args:
        feature_sets: Dict mapping vertex -> set of features
        threshold: Maximum distance for adjacency
    
    Returns:
        The semantic threshold graph.
    """
    G = SimpleGraph()
    vertices = list(feature_sets.keys())
    for v in vertices:
        G.add_vertex(v)
    
    for i in range(len(vertices)):
        for j in range(i + 1, len(vertices)):
            u, v = vertices[i], vertices[j]
            dist = semantic_distance(feature_sets[u], feature_sets[v])
            if dist <= threshold:
                G.add_edge(u, v)
    
    return G


def find_connectivity_threshold(feature_sets: Dict[int, Set], 
                                 max_eps: int = 100) -> Optional[int]:
    """Find the smallest ε such that the semantic graph is connected.
    
    Binary search over threshold values.
    
    Time complexity: O(V² · F · log(max_eps))
    
    Returns:
        The connectivity threshold εc, or None if not found.
    """
    lo, hi = 0, max_eps
    result = None
    
    while lo <= hi:
        mid = (lo + hi) // 2
        G = build_semantic_graph(feature_sets, mid)
        if is_connected(G):
            result = mid
            hi = mid - 1
        else:
            lo = mid + 1
    
    return result


def find_cycle_rank_maximizer(feature_sets: Dict[int, Set],
                               max_eps: int = 100) -> Tuple[int, int]:
    """Find the ε that maximizes cycle rank.
    
    Scans all threshold values and returns the maximizer.
    
    Time complexity: O(V² · F · max_eps)
    
    Returns:
        Tuple of (ε*, max_cycle_rank).
    """
    best_eps = 0
    best_rank = 0
    
    for eps in range(max_eps + 1):
        G = build_semantic_graph(feature_sets, eps)
        cr = graph_cycle_rank(G)
        if cr > best_rank:
            best_rank = cr
            best_eps = eps
    
    return best_eps, best_rank


def bfs_distance(G: SimpleGraph, source: int) -> Dict[int, int]:
    """BFS shortest distances from source.
    
    Time complexity: O(V + E)
    """
    dist = {source: 0}
    queue = deque([source])
    while queue:
        v = queue.popleft()
        for w in G.adj[v]:
            if w not in dist:
                dist[w] = dist[v] + 1
                queue.append(w)
    return dist


def hitting_time_lower_bound(G: SimpleGraph, v: int, 
                              target_set: Set[int]) -> float:
    """Lower bound on expected hitting time from v to target set.
    
    Uses the distance-based bound: hitting time ≥ min distance to target.
    When v has high cycle pressure, the actual hitting time is much larger
    due to cycle trapping.
    
    Returns:
        Lower bound on expected hitting time.
    """
    distances = bfs_distance(G, v)
    min_dist = float('inf')
    for t in target_set:
        if t in distances:
            min_dist = min(min_dist, distances[t])
    return min_dist


if __name__ == "__main__":
    # Example: Triangle with a pendant edge
    G = SimpleGraph()
    G.add_edge(0, 1)
    G.add_edge(1, 2)
    G.add_edge(2, 0)
    G.add_edge(2, 3)
    
    print("=== Graph Analysis ===")
    print(f"Vertices: {G.vertices}")
    print(f"Edges: {G.edges()}")
    print(f"Cycle rank: {graph_cycle_rank(G)}")
    print(f"Bridges: {find_bridges(G)}")
    
    pressures = compute_all_pressures(G)
    print(f"\nLocal cycle pressures: {pressures}")
    
    field = compute_semantic_pressure_field(G)
    print(f"\nSemantic Pressure Field:")
    for v, p in sorted(field.pressure.items()):
        print(f"  Vertex {v}: pressure = {p:.3f}, "
              f"concentration = {field.concentration(v):.3f}")
    
    print(f"\nTop vertices by pressure: {field.top_k_vertices(3)}")
