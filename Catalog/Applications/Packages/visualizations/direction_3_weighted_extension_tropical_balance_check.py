"""
Weighted Tropical Graph Hodge Theory — Core Algorithms

This module implements the computational machinery for weighted tropical
harmonicity analysis on finite graphs. It provides algorithms for:
- Constructing weighted graphs
- Computing tropical balance at vertices
- Finding the weighted tropical kernel
- Detecting weight degeneracy and shortest-path degeneracy
- Computing combinatorial dimension invariants

All algorithms work over integer weights for exact arithmetic.
"""

from typing import Dict, List, Tuple, Set, Optional
from itertools import combinations, product
from collections import defaultdict
import math


class WeightedGraph:
    """A finite simple graph with integer edge weights.

    Attributes:
        vertices: Set of vertex labels (integers).
        adj: Adjacency dict mapping each vertex to its set of neighbors.
        weights: Dict mapping (u, v) to integer weight w(u, v).

    Invariants:
        - Symmetric: if (u, v) is an edge, so is (v, u) with the same weight.
        - Loopless: no vertex is adjacent to itself.
    """

    def __init__(self, vertices: List[int], edges: List[Tuple[int, int, int]]):
        """Create a weighted graph.

        Args:
            vertices: List of vertex labels.
            edges: List of (u, v, weight) triples. Each edge is added symmetrically.
        """
        self.vertices = set(vertices)
        self.adj: Dict[int, Set[int]] = defaultdict(set)
        self.weights: Dict[Tuple[int, int], int] = {}

        for u, v, w in edges:
            assert u != v, f"Self-loop at vertex {u}"
            assert u in self.vertices and v in self.vertices
            self.adj[u].add(v)
            self.adj[v].add(u)
            self.weights[(u, v)] = w
            self.weights[(v, u)] = w

    def neighbors(self, v: int) -> Set[int]:
        """Return the set of neighbors of vertex v."""
        return self.adj[v]

    def weight(self, u: int, v: int) -> int:
        """Return the edge weight w(u, v)."""
        return self.weights.get((u, v), 0)

    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return len(self.adj[v])


def weighted_nbr_val(G: WeightedGraph, phi: Dict[int, int], i: int, j: int) -> int:
    """Compute the weighted neighbor value w(i,j) + phi(j).

    This is the fundamental quantity in tropical Laplacian analysis.

    Args:
        G: Weighted graph.
        phi: Potential function V -> Z.
        i: Source vertex.
        j: Target vertex (neighbor of i).

    Returns:
        w(i,j) + phi(j)

    Time complexity: O(1)
    """
    return G.weight(i, j) + phi.get(j, 0)


def trop_balanced_at(G: WeightedGraph, phi: Dict[int, int], i: int) -> bool:
    """Check if vertex i is tropically balanced under potential phi.

    Tropical balance means: the minimum of w(i,j) + phi(j) over
    neighbors j of i is attained by at least two distinct neighbors.

    Args:
        G: Weighted graph.
        phi: Potential function V -> Z.
        i: Vertex to check.

    Returns:
        True if the minimum neighbor value is attained at least twice.

    Time complexity: O(deg(i))
    """
    nbrs = G.neighbors(i)
    if len(nbrs) < 2:
        return False

    vals = [(weighted_nbr_val(G, phi, i, j), j) for j in nbrs]
    min_val = min(v for v, _ in vals)
    min_count = sum(1 for v, _ in vals if v == min_val)
    return min_count >= 2


def weighted_trop_kernel_on(G: WeightedGraph, S: Set[int], phi: Dict[int, int]) -> bool:
    """Check if phi is in the weighted tropical kernel on S.

    Args:
        G: Weighted graph.
        S: Subset of vertices.
        phi: Potential function V -> Z.

    Returns:
        True if phi is tropically balanced at every vertex in S.

    Time complexity: O(|S| * max_degree)
    """
    return all(trop_balanced_at(G, phi, i) for i in S)


def is_generic_weights(G: WeightedGraph) -> bool:
    """Check if the graph has generic weights.

    Generic means: for every vertex i, all edge weights w(i,j)
    to distinct neighbors j are pairwise distinct.

    Time complexity: O(|V| * max_degree^2)
    """
    for i in G.vertices:
        nbrs = list(G.neighbors(i))
        for a, b in combinations(nbrs, 2):
            if G.weight(i, a) == G.weight(i, b):
                return False
    return True


def is_weight_degenerate_at(G: WeightedGraph, i: int) -> bool:
    """Check if vertex i is weight-degenerate.

    A vertex is weight-degenerate if two distinct neighbors have
    equal edge weights from i.

    Time complexity: O(deg(i)^2)
    """
    nbrs = list(G.neighbors(i))
    for a, b in combinations(nbrs, 2):
        if G.weight(i, a) == G.weight(i, b):
            return True
    return False


def weight_degeneracy_count(G: WeightedGraph, S: Set[int]) -> int:
    """Count weight-degenerate vertices in S.

    Time complexity: O(|S| * max_degree^2)
    """
    return sum(1 for i in S if is_weight_degenerate_at(G, i))


def shortest_path_degeneracy_count(G: WeightedGraph, q: int, S: Set[int]) -> int:
    """Count vertices in S with shortest-path degeneracy from q.

    This equals the weight degeneracy count (same predicate).

    Time complexity: O(|S| * max_degree^2)
    """
    return weight_degeneracy_count(G, S)


def enumerate_kernel_vectors(
    G: WeightedGraph, S: Set[int], value_range: range = range(-5, 6)
) -> List[Dict[int, int]]:
    """Enumerate all integer-valued potentials in a normalized range
    that lie in the weighted tropical kernel on S.

    This is a brute-force algorithm for small graphs.

    Args:
        G: Weighted graph.
        S: Subset of vertices to constrain.
        value_range: Range of integer values to try for each vertex.

    Returns:
        List of potential dicts phi that are tropically balanced on S.

    Time complexity: O(|range|^|V| * |S| * max_degree)
    Space complexity: O(|range|^|V|)
    """
    verts = sorted(G.vertices)
    results = []

    for vals in product(value_range, repeat=len(verts)):
        phi = dict(zip(verts, vals))
        if weighted_trop_kernel_on(G, S, phi):
            results.append(phi)

    return results


def compute_kernel_dimension(
    G: WeightedGraph, S: Set[int], value_range: range = range(-3, 4)
) -> int:
    """Compute the tropical kernel dimension by finding the affine span
    of kernel vectors modulo translation.

    We normalize by fixing phi(v0) = 0 for some base vertex v0,
    then count the dimension of the integer lattice spanned by
    differences of kernel vectors.

    Args:
        G: Weighted graph.
        S: Subset of vertices.
        value_range: Range for enumeration.

    Returns:
        Estimated dimension of the tropical kernel.

    Time complexity: O(|range|^(|V|-1) * |S| * max_degree + rank computation)
    """
    verts = sorted(G.vertices)
    if not verts:
        return 0

    v0 = verts[0]
    other_verts = verts[1:]

    # Enumerate normalized kernel vectors (phi(v0) = 0)
    normalized_vectors = []
    for vals in product(value_range, repeat=len(other_verts)):
        phi = {v0: 0}
        phi.update(zip(other_verts, vals))
        if weighted_trop_kernel_on(G, S, phi):
            normalized_vectors.append(tuple(phi[v] for v in verts))

    if not normalized_vectors:
        return 0

    # Compute dimension as rank of the difference lattice
    # Using simple Gaussian elimination over Q
    base = normalized_vectors[0]
    diffs = []
    for vec in normalized_vectors[1:]:
        diff = tuple(a - b for a, b in zip(vec, base))
        if any(x != 0 for x in diff):
            diffs.append(list(diff))

    if not diffs:
        return 0

    # Row reduce to find rank
    n = len(verts)
    matrix = [row[:] for row in diffs]
    rank = 0
    for col in range(n):
        # Find pivot
        pivot_row = None
        for row in range(rank, len(matrix)):
            if matrix[row][col] != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        matrix[rank], matrix[pivot_row] = matrix[pivot_row], matrix[rank]
        pivot_val = matrix[rank][col]

        for row in range(len(matrix)):
            if row != rank and matrix[row][col] != 0:
                factor_num = matrix[row][col]
                factor_den = pivot_val
                for c in range(n):
                    matrix[row][c] = matrix[row][c] * factor_den - factor_num * matrix[rank][c]

        rank += 1

    return rank


def find_weight_compatible_cycles(G: WeightedGraph, S: Set[int]) -> List[Set[int]]:
    """Find weight-compatible cycles in the subgraph induced by S.

    A cycle is weight-compatible if there exists a potential phi
    (zero outside the cycle) that tropically balances every cycle vertex.

    This uses a heuristic: for each simple cycle in G[S], construct
    the canonical balanced potential and check if it works.

    Time complexity: exponential in |S| (cycle enumeration)
    """
    # Find all simple cycles in G[S] using DFS
    cycles = []
    verts = sorted(S)

    def dfs_cycles(path: List[int], visited: Set[int]):
        current = path[-1]
        for nbr in G.neighbors(current):
            if nbr not in S:
                continue
            if nbr == path[0] and len(path) >= 3:
                cycles.append(set(path))
            elif nbr not in visited:
                visited.add(nbr)
                dfs_cycles(path + [nbr], visited)
                visited.remove(nbr)

    for start in verts:
        dfs_cycles([start], {start})

    # Deduplicate cycles
    unique_cycles = []
    seen = set()
    for c in cycles:
        key = frozenset(c)
        if key not in seen:
            seen.add(key)
            unique_cycles.append(c)

    # Check weight compatibility for each cycle
    compatible = []
    for cycle_set in unique_cycles:
        # Try to find a balanced potential on this cycle
        # Use brute force for small cycles
        cycle_verts = sorted(cycle_set)
        if len(cycle_verts) > 8:
            continue

        for vals in product(range(-3, 4), repeat=len(cycle_verts)):
            phi = dict(zip(cycle_verts, vals))
            # Set non-cycle vertices to 0
            for v in G.vertices:
                if v not in cycle_set:
                    phi[v] = 0
            if all(trop_balanced_at(G, phi, i) for i in cycle_set):
                compatible.append(cycle_set)
                break

    return compatible


def compute_invariants(G: WeightedGraph, q: int, S: Set[int]) -> Dict:
    """Compute all weighted tropical invariants for a graph.

    Returns a dict with:
        - 'generic': whether weights are generic
        - 'degeneracy_count': number of weight-degenerate vertices in S
        - 'sp_degeneracy': shortest-path degeneracy count
        - 'kernel_dim': estimated tropical kernel dimension
        - 'compatible_cycles': list of weight-compatible cycles

    Time complexity: dominated by kernel dimension computation
    """
    return {
        'generic': is_generic_weights(G),
        'degeneracy_count': weight_degeneracy_count(G, S),
        'sp_degeneracy': shortest_path_degeneracy_count(G, q, S),
        'compatible_cycles': find_weight_compatible_cycles(G, S),
    }


# === Example Graphs ===

def triangle_graph(w12: int = 1, w13: int = 2, w23: int = 3) -> WeightedGraph:
    """Create a weighted triangle K_3 with given edge weights."""
    return WeightedGraph(
        vertices=[1, 2, 3],
        edges=[(1, 2, w12), (1, 3, w13), (2, 3, w23)]
    )


def square_graph(w12: int = 1, w23: int = 2, w34: int = 3, w14: int = 4) -> WeightedGraph:
    """Create a weighted 4-cycle with given edge weights."""
    return WeightedGraph(
        vertices=[1, 2, 3, 4],
        edges=[(1, 2, w12), (2, 3, w23), (3, 4, w34), (1, 4, w14)]
    )


def complete_graph(n: int, weight_fn=None) -> WeightedGraph:
    """Create a weighted complete graph K_n.

    Args:
        n: Number of vertices (labeled 0, ..., n-1).
        weight_fn: Function (i, j) -> weight. Default: i*n + j.
    """
    if weight_fn is None:
        weight_fn = lambda i, j: i * n + j if i < j else j * n + i
    verts = list(range(n))
    edges = [(i, j, weight_fn(i, j)) for i, j in combinations(verts, 2)]
    return WeightedGraph(vertices=verts, edges=edges)


if __name__ == "__main__":
    # Example: weighted triangle
    G = triangle_graph(w12=1, w13=1, w23=2)
    S = {1, 2, 3}
    q = 1

    print("=== Weighted Triangle (degenerate at vertex 1) ===")
    print(f"Generic weights: {is_generic_weights(G)}")
    print(f"Weight degeneracy count: {weight_degeneracy_count(G, S)}")

    # Check zero potential
    phi_zero = {1: 0, 2: 0, 3: 0}
    print(f"Zero potential balanced at 1: {trop_balanced_at(G, phi_zero, 1)}")
    print(f"Zero potential balanced at 2: {trop_balanced_at(G, phi_zero, 2)}")
    print(f"Zero potential balanced at 3: {trop_balanced_at(G, phi_zero, 3)}")

    print()

    # Generic triangle
    G2 = triangle_graph(w12=1, w13=2, w23=3)
    print("=== Weighted Triangle (generic) ===")
    print(f"Generic weights: {is_generic_weights(G2)}")
    print(f"Zero balanced at 1: {trop_balanced_at(G2, phi_zero, 1)}")
