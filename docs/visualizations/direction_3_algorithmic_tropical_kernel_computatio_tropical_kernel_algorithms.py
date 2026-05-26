"""
Algorithmic Tropical Kernel Computation for Weighted Graphs.

Implements the algorithms from the formal theory:
- Normalization preprocessor
- Constraint extraction from tropical balance
- Bellman-Ford feasibility checking
- Brute-force kernel search

Application Keywords: tropical linear programming, min-plus algebra, graph Laplacian,
weighted networks, shortest paths, difference constraints, Bellman-Ford certificates,
tropical Hodge theory, sparse algorithms, combinatorial optimization.
"""

from typing import Optional
from itertools import product
import numpy as np


class WeightedGraph:
    """A finite weighted simple graph with integer edge weights.

    Attributes:
        n: Number of vertices (labeled 0..n-1)
        adj: Adjacency dict {v: set of neighbors}
        w: Weight function as dict {(u,v): weight}
    """

    def __init__(self, n: int):
        self.n = n
        self.adj: dict[int, set[int]] = {v: set() for v in range(n)}
        self.w: dict[tuple[int, int], int] = {}

    def add_edge(self, u: int, v: int, weight: int) -> None:
        """Add an undirected edge with given weight."""
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.w[(u, v)] = weight
        self.w[(v, u)] = weight

    def neighbors(self, v: int) -> set[int]:
        return self.adj[v]

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def max_degree(self) -> int:
        return max(self.degree(v) for v in range(self.n))

    def edge_weight(self, u: int, v: int) -> int:
        return self.w.get((u, v), 0)


def wnv(G: WeightedGraph, phi: dict[int, int], i: int, j: int) -> int:
    """Weighted neighbor value: w(i,j) + phi(j)."""
    return G.edge_weight(i, j) + phi[j]


def is_tropically_balanced_at(G: WeightedGraph, phi: dict[int, int], v: int) -> bool:
    """Check if phi is tropically balanced at vertex v.

    The minimum of wnv(phi, v, j) over neighbors j must be attained
    by at least two distinct neighbors.
    """
    nbrs = list(G.neighbors(v))
    if len(nbrs) < 2:
        return False

    values = [(wnv(G, phi, v, j), j) for j in nbrs]
    min_val = min(val for val, _ in values)
    minimizers = [j for val, j in values if val == min_val]

    return len(minimizers) >= 2


def is_in_tropical_kernel(G: WeightedGraph, phi: dict[int, int]) -> bool:
    """Check if phi is in the tropical kernel (balanced at every vertex)."""
    return all(is_tropically_balanced_at(G, phi, v) for v in range(G.n))


def normalize(phi: dict[int, int], v0: int) -> dict[int, int]:
    """Normalize potential at base vertex v0: subtract phi(v0) from all values.

    Certified by: normalize_preserves_kernel
    """
    c = phi[v0]
    return {v: phi[v] - c for v in phi}


def extract_minimizer(
    G: WeightedGraph, phi: dict[int, int], u: int
) -> Optional[int]:
    """Extract a minimizing witness at vertex u.

    Returns the neighbor j minimizing wnv(phi, u, j), or None if no neighbors.
    """
    nbrs = list(G.neighbors(u))
    if not nbrs:
        return None
    return min(nbrs, key=lambda j: wnv(G, phi, u, j))


class DifferenceConstraint:
    """A difference constraint: phi(tgt) - phi(src) <= bound."""

    def __init__(self, src: int, tgt: int, bound: int):
        self.src = src
        self.tgt = tgt
        self.bound = bound

    def is_satisfied(self, phi: dict[int, int]) -> bool:
        return phi[self.tgt] - phi[self.src] <= self.bound

    def __repr__(self) -> str:
        return f"φ({self.tgt}) - φ({self.src}) ≤ {self.bound}"


def extract_constraints(
    G: WeightedGraph, u: int, j: int
) -> list[DifferenceConstraint]:
    """Extract induced difference constraints at vertex u with minimizer j.

    For each neighbor v of u: phi(j) - phi(v) <= w(u,v) - w(u,j).
    Certified by: extractConstraints_satisfied
    """
    constraints = []
    for v in G.neighbors(u):
        bound = G.edge_weight(u, v) - G.edge_weight(u, j)
        constraints.append(DifferenceConstraint(src=v, tgt=j, bound=bound))
    return constraints


def bellman_ford_feasibility(
    n: int, constraints: list[DifferenceConstraint], v0: int = 0
) -> Optional[dict[int, int]]:
    """Check feasibility of difference constraints via Bellman-Ford.

    Returns a feasible potential (normalized at v0=0) if feasible,
    or None if a negative cycle is detected.

    Complexity: O(n * |constraints|)
    """
    # Initialize distances from v0
    dist = {v: 0 for v in range(n)}  # All zero (source-free version)

    # Relax edges n-1 times
    for _ in range(n - 1):
        updated = False
        for c in constraints:
            # phi(tgt) - phi(src) <= bound
            # Interpreted as: dist[tgt] <= dist[src] + bound
            if dist[c.src] + c.bound < dist[c.tgt]:
                dist[c.tgt] = dist[c.src] + c.bound
                updated = True
        if not updated:
            break

    # Check for negative cycles
    for c in constraints:
        if dist[c.src] + c.bound < dist[c.tgt]:
            return None  # Negative cycle detected

    # Normalize at v0
    offset = dist[v0]
    return {v: dist[v] - offset for v in range(n)}


def brute_force_search(
    G: WeightedGraph, bound: int = 20, v0: int = 0
) -> Optional[dict[int, int]]:
    """Brute-force search for tropical kernel elements.

    Searches over all potentials with values in [-bound, bound]
    and phi(v0) = 0.

    Complexity: O((2*bound+1)^{n-1} * n * Delta)
    """
    other_vertices = [v for v in range(G.n) if v != v0]
    values = range(-bound, bound + 1)

    for combo in product(values, repeat=len(other_vertices)):
        phi = {v0: 0}
        for i, v in enumerate(other_vertices):
            phi[v] = combo[i]
        if is_in_tropical_kernel(G, phi):
            return phi

    return None


def constraint_based_check(
    G: WeightedGraph, v0: int = 0
) -> tuple[bool, Optional[dict[int, int]]]:
    """Check tropical kernel feasibility using the constraint-based algorithm.

    Enumerates minimizer assignments and checks each via Bellman-Ford.

    Returns (is_feasible, potential_or_None).
    """
    # Get neighbor lists for each vertex
    neighbor_lists = {v: list(G.neighbors(v)) for v in range(G.n)}

    # Check if any vertex has < 2 neighbors (impossible to balance)
    for v in range(G.n):
        if len(neighbor_lists[v]) < 2:
            return False, None

    # Enumerate minimizer assignments
    choices = [neighbor_lists[v] for v in range(G.n)]
    for assignment in product(*choices):
        # Extract constraints for this minimizer assignment
        constraints = []
        for u in range(G.n):
            j = assignment[u]
            constraints.extend(extract_constraints(G, u, j))

        # Check feasibility via Bellman-Ford
        potential = bellman_ford_feasibility(G.n, constraints, v0)
        if potential is not None:
            # Verify the potential actually satisfies tropical balance
            if is_in_tropical_kernel(G, potential):
                return True, potential

    return False, None


# === Graph Constructors ===

def complete_graph(n: int, weights: Optional[dict[tuple[int, int], int]] = None) -> WeightedGraph:
    """Create a complete graph K_n with given or random weights."""
    G = WeightedGraph(n)
    for i in range(n):
        for j in range(i + 1, n):
            w = weights.get((i, j), 0) if weights else np.random.randint(-5, 6)
            G.add_edge(i, j, w)
    return G


def cycle_graph(n: int, weights: Optional[list[int]] = None) -> WeightedGraph:
    """Create a cycle graph C_n with given or random weights."""
    G = WeightedGraph(n)
    for i in range(n):
        j = (i + 1) % n
        w = weights[i] if weights else np.random.randint(-5, 6)
        G.add_edge(i, j, w)
    return G


def path_graph(n: int, weights: Optional[list[int]] = None) -> WeightedGraph:
    """Create a path graph P_n with given or random weights."""
    G = WeightedGraph(n)
    for i in range(n - 1):
        w = weights[i] if weights else np.random.randint(-5, 6)
        G.add_edge(i, i + 1, w)
    return G


if __name__ == "__main__":
    # Example: Triangle with degenerate weights
    G = cycle_graph(3, weights=[1, 1, 1])
    print("Triangle C3 with weights [1,1,1]:")
    phi = {0: 0, 1: 0, 2: 0}
    print(f"  Zero potential balanced: {is_in_tropical_kernel(G, phi)}")
    result = brute_force_search(G, bound=5)
    print(f"  Brute-force kernel element: {result}")
    feasible, potential = constraint_based_check(G)
    print(f"  Constraint-based: feasible={feasible}, potential={potential}")
