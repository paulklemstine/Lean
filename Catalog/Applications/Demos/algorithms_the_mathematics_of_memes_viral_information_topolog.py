"""
Algorithms for Sheaf Cohomology of Meme Propagation

Implementations of H⁰, H¹ computation, meme fitness scoring,
mutation sheaf propagation, and Laplacian spectral analysis.
"""

from typing import Dict, List, Optional, Set, Tuple
import numpy as np


def compute_connected_components(n: int, edges: List[Tuple[int, int]]) -> List[Set[int]]:
    """Compute connected components using union-find.

    Args:
        n: Number of vertices (labeled 0..n-1)
        edges: List of (u, v) edges

    Returns:
        List of sets, each set is a connected component
    """
    parent = list(range(n))
    rank = [0] * n

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for u, v in edges:
        union(u, v)

    components: Dict[int, Set[int]] = {}
    for i in range(n):
        root = find(i)
        if root not in components:
            components[root] = set()
        components[root].add(i)

    return list(components.values())


def compute_h0(n: int, edges: List[Tuple[int, int]]) -> int:
    """Compute dim H⁰(G, k) = number of connected components.

    Time complexity: O(n + |E|) via union-find.

    Args:
        n: Number of vertices
        edges: Edge list

    Returns:
        Dimension of H⁰
    """
    return len(compute_connected_components(n, edges))


def compute_h1(n: int, edges: List[Tuple[int, int]]) -> int:
    """Compute dim H¹(G, k) = cycle rank = |E| - |V| + c.

    The cycle rank counts independent cycles in the graph.
    Each cycle creates a potential transmission barrier.

    Args:
        n: Number of vertices
        edges: Edge list (undirected, each edge listed once)

    Returns:
        Dimension of H¹
    """
    c = compute_h0(n, edges)
    return len(edges) - n + c


def meme_fitness(h0: int, h1: int) -> float:
    """Compute meme fitness score.

    fitness = h0 / (1 + h1)

    Higher fitness = more viral. Maximized when h1 = 0 (no barriers).

    Args:
        h0: Dimension of H⁰ (interpretation diversity)
        h1: Dimension of H¹ (transmission barriers)

    Returns:
        Fitness score
    """
    return h0 / (1 + h1)


def spread_rate(n: int, h0: int, h1: int) -> float:
    """Compute meme spread rate.

    Args:
        n: Number of vertices
        h0: H⁰ dimension
        h1: H¹ dimension

    Returns:
        Spread rate in [0, 1]
    """
    if n == 0:
        return 0.0
    if h1 == 0:
        return h0 / n
    return h0 / (n * (1 + h1))


def graph_laplacian(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute the graph Laplacian matrix.

    L(i,j) = degree(i) if i == j
           = -1 if (i,j) is an edge
           = 0 otherwise

    Args:
        n: Number of vertices
        edges: Edge list

    Returns:
        n×n Laplacian matrix
    """
    L = np.zeros((n, n))
    for u, v in edges:
        L[u, v] -= 1
        L[v, u] -= 1
        L[u, u] += 1
        L[v, v] += 1
    return L


def laplacian_spectrum(n: int, edges: List[Tuple[int, int]]) -> np.ndarray:
    """Compute eigenvalues of the graph Laplacian.

    The number of zero eigenvalues equals dim H⁰.
    The smallest nonzero eigenvalue (Fiedler value) measures
    algebraic connectivity.

    Args:
        n: Number of vertices
        edges: Edge list

    Returns:
        Sorted array of eigenvalues
    """
    L = graph_laplacian(n, edges)
    eigenvalues = np.linalg.eigvalsh(L)
    return np.sort(eigenvalues)


class MutationSheaf:
    """Linear mutation sheaf over a graph.

    Each edge (u,v) carries a weight w(u,v) such that
    consistent sections satisfy f(v) = w(u,v) * f(u).
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]],
                 weights: Optional[Dict[Tuple[int, int], float]] = None):
        self.n = n
        self.edges = edges
        self.adj: Dict[int, List[int]] = {i: [] for i in range(n)}
        for u, v in edges:
            self.adj[u].append(v)
            self.adj[v].append(u)

        self.weights: Dict[Tuple[int, int], float] = {}
        if weights is None:
            for u, v in edges:
                self.weights[(u, v)] = 1.0
                self.weights[(v, u)] = 1.0
        else:
            for (u, v), w in weights.items():
                self.weights[(u, v)] = w
                if w != 0:
                    self.weights[(v, u)] = 1.0 / w

    def propagate_from(self, seed: int, seed_value: float = 1.0) -> Dict[int, float]:
        """Propagate a consistent section from a seed vertex.

        Uses BFS to compute the unique consistent section with f(seed) = seed_value.

        Args:
            seed: Starting vertex
            seed_value: Value at seed

        Returns:
            Dict mapping reachable vertices to their values
        """
        values: Dict[int, float] = {seed: seed_value}
        queue = [seed]
        visited = {seed}

        while queue:
            u = queue.pop(0)
            for v in self.adj[u]:
                if v not in visited:
                    w = self.weights.get((u, v), 1.0)
                    values[v] = w * values[u]
                    visited.add(v)
                    queue.append(v)

        return values

    def check_holonomy(self, cycle: List[int]) -> float:
        """Compute the holonomy around a cycle.

        Returns the product of weights around the cycle.
        Holonomy = 1 means no obstruction; ≠ 1 means H¹ contribution.

        Args:
            cycle: List of vertices forming a cycle (last connects to first)

        Returns:
            Holonomy value (product of edge weights around cycle)
        """
        holonomy = 1.0
        for i in range(len(cycle)):
            u = cycle[i]
            v = cycle[(i + 1) % len(cycle)]
            holonomy *= self.weights.get((u, v), 1.0)
        return holonomy


def euler_characteristic(n: int, edges: List[Tuple[int, int]]) -> int:
    """Compute the sheaf Euler characteristic χ = |V| - |E|.

    By rank-nullity: χ = dim H⁰ - dim H¹.

    Args:
        n: Number of vertices
        edges: Edge list

    Returns:
        Euler characteristic
    """
    return n - len(edges)


def community_fitness(n: int, edges: List[Tuple[int, int]],
                      communities: List[int]) -> Dict[str, float]:
    """Analyze meme fitness with respect to community structure.

    Args:
        n: Number of vertices
        edges: Edge list
        communities: Community label for each vertex

    Returns:
        Dict with h0, h1, fitness, spread_rate, euler_char, and analysis
    """
    h0 = compute_h0(n, edges)
    h1 = compute_h1(n, edges)

    num_communities = len(set(communities))
    inter_edges = sum(1 for u, v in edges if communities[u] != communities[v])
    intra_edges = len(edges) - inter_edges

    return {
        "h0_dim": h0,
        "h1_dim": h1,
        "fitness": meme_fitness(h0, h1),
        "spread_rate": spread_rate(n, h0, h1),
        "euler_char": euler_characteristic(n, edges),
        "num_communities": num_communities,
        "inter_community_edges": inter_edges,
        "intra_community_edges": intra_edges,
    }
