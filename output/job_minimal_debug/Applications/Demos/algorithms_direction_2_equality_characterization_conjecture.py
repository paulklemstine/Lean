"""
Algorithms for the Equality Characterization in the Tropical Chip-Firing Bridge.

Implements the core computational procedures for testing whether a subset S
of vertices satisfies the equality conditions in the tropical chip-firing bridge:
    r(D_S) = tropRank(L_S) - 1

The equality criterion requires:
1. S lies in a single connected component of G - {q}
2. The induced subgraph G[S] is a tree

Also implements computation of:
- Graph Laplacian and its principal minors
- Restricted Laplacian (internal edges only)
- Cut degrees and Laplacian decomposition
- Laplacian energy (Dirichlet energy on graphs)
"""

from __future__ import annotations
import numpy as np
from typing import Optional
from collections import defaultdict, deque


class SimpleGraph:
    """A simple undirected graph on vertices 0..n-1.

    Attributes:
        n: Number of vertices.
        adj: Adjacency list representation.
    """

    def __init__(self, n: int, edges: list[tuple[int, int]]):
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        for u, v in edges:
            if u != v:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def degree(self, v: int) -> int:
        """Return the degree of vertex v."""
        return len(self.adj[v])

    def is_adjacent(self, u: int, v: int) -> bool:
        """Check if u and v are adjacent."""
        return v in self.adj[u]

    def vertices(self) -> list[int]:
        """Return all vertices."""
        return list(range(self.n))

    def edges(self) -> list[tuple[int, int]]:
        """Return all edges as sorted pairs."""
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result


def graph_laplacian(G: SimpleGraph) -> np.ndarray:
    """Compute the combinatorial Laplacian matrix L(G).

    L(v,v) = deg(v), L(v,w) = -1 if v~w, L(v,w) = 0 otherwise.

    Time: O(|V|^2)
    Space: O(|V|^2)

    Args:
        G: A SimpleGraph instance.

    Returns:
        The Laplacian matrix as an integer numpy array.

    Example:
        >>> G = SimpleGraph(3, [(0,1), (1,2)])
        >>> graph_laplacian(G)
        array([[ 1, -1,  0],
               [-1,  2, -1],
               [ 0, -1,  1]])
    """
    L = np.zeros((G.n, G.n), dtype=int)
    for v in range(G.n):
        L[v, v] = G.degree(v)
        for w in G.adj[v]:
            L[v, w] = -1
    return L


def restricted_laplacian(G: SimpleGraph, S: set[int]) -> np.ndarray:
    """Compute the restricted Laplacian on S.

    Diagonal: count of edges within S.
    Off-diagonal: -1 if adjacent, 0 otherwise.

    Time: O(|S|^2)
    Space: O(|S|^2)

    Args:
        G: A SimpleGraph instance.
        S: A set of vertex indices.

    Returns:
        The restricted Laplacian as a numpy array, indexed by sorted S.
    """
    S_list = sorted(S)
    k = len(S_list)
    idx = {v: i for i, v in enumerate(S_list)}
    RL = np.zeros((k, k), dtype=int)
    for v in S_list:
        i = idx[v]
        internal_deg = sum(1 for w in G.adj[v] if w in S)
        RL[i, i] = internal_deg
        for w in G.adj[v]:
            if w in S and w != v:
                RL[i, idx[w]] = -1
    return RL


def cut_degree(G: SimpleGraph, v: int, S: set[int]) -> int:
    """Compute the cut degree of v relative to S.

    Number of edges from v to vertices outside S.

    Time: O(deg(v))

    Args:
        G: A SimpleGraph instance.
        v: A vertex index.
        S: A set of vertex indices.

    Returns:
        The number of edges from v to V \\ S.
    """
    return sum(1 for w in G.adj[v] if w not in S)


def principal_minor(G: SimpleGraph, S: set[int]) -> np.ndarray:
    """Compute the Laplacian principal minor L_S.

    This is the full Laplacian restricted to rows and columns in S.

    Time: O(|S|^2)
    Space: O(|S|^2)

    Args:
        G: A SimpleGraph instance.
        S: A set of vertex indices.

    Returns:
        The principal minor as a numpy array.
    """
    L = graph_laplacian(G)
    S_list = sorted(S)
    return L[np.ix_(S_list, S_list)]


def verify_decomposition(G: SimpleGraph, S: set[int]) -> bool:
    """Verify the Laplacian decomposition theorem:
    L_S = RestrictedLap + diag(cutDegrees).

    This checks Theorem 3 from the formalization.

    Time: O(|S|^2)

    Args:
        G: A SimpleGraph instance.
        S: A set of vertex indices.

    Returns:
        True if the decomposition holds.
    """
    PM = principal_minor(G, S)
    RL = restricted_laplacian(G, S)
    S_list = sorted(S)
    k = len(S_list)
    cut_diag = np.zeros((k, k), dtype=int)
    for i, v in enumerate(S_list):
        cut_diag[i, i] = cut_degree(G, v, S)
    return np.array_equal(PM, RL + cut_diag)


def laplacian_energy(G: SimpleGraph, c: dict[int, int]) -> int:
    """Compute the Laplacian energy: sum_v sum_w c(v) * L(v,w) * c(w).

    Time: O(|V|^2)

    Args:
        G: A SimpleGraph instance.
        c: A function from vertices to integers.

    Returns:
        The Laplacian energy as an integer.
    """
    L = graph_laplacian(G)
    total = 0
    for v in range(G.n):
        for w in range(G.n):
            total += c.get(v, 0) * L[v, w] * c.get(w, 0)
    return total


def edge_energy(G: SimpleGraph, c: dict[int, int]) -> int:
    """Compute the edge energy: sum_{v~w} (c(v) - c(w))^2.

    Time: O(|V|^2)

    Args:
        G: A SimpleGraph instance.
        c: A function from vertices to integers.

    Returns:
        The edge energy sum over ordered pairs.
    """
    total = 0
    for v in range(G.n):
        for w in range(G.n):
            if G.is_adjacent(v, w):
                total += (c.get(v, 0) - c.get(w, 0)) ** 2
    return total


def verify_energy_formula(G: SimpleGraph, c: dict[int, int]) -> bool:
    """Verify the energy formula: 2 * Laplacian_energy = edge_energy.

    This checks Theorem 4 from the formalization.

    Args:
        G: A SimpleGraph instance.
        c: A function from vertices to integers.

    Returns:
        True if the formula holds.
    """
    return 2 * laplacian_energy(G, c) == edge_energy(G, c)


def is_connected_subgraph(G: SimpleGraph, S: set[int]) -> bool:
    """Check if the induced subgraph G[S] is connected.

    Uses BFS on the induced subgraph.

    Time: O(|S| + |E(G[S])|)

    Args:
        G: A SimpleGraph instance.
        S: A set of vertex indices.

    Returns:
        True if G[S] is connected (or S is empty).
    """
    if len(S) <= 1:
        return True
    start = next(iter(S))
    visited = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for w in G.adj[v]:
            if w in S and w not in visited:
                visited.add(w)
                queue.append(w)
    return visited == S


def induced_edge_count(G: SimpleGraph, S: set[int]) -> int:
    """Count ordered pairs (u,v) with u,v in S, u != v, u~v.

    Time: O(|S|^2)

    Args:
        G: A SimpleGraph instance.
        S: A set of vertex indices.

    Returns:
        Number of ordered adjacent pairs in S.
    """
    count = 0
    for u in S:
        for v in S:
            if u != v and G.is_adjacent(u, v):
                count += 1
    return count


def is_induced_tree(G: SimpleGraph, S: set[int]) -> bool:
    """Check if G[S] is a tree: connected and |edges| = |S| - 1.

    The edge count uses ordered pairs: 2*(|S|-1).

    Time: O(|S|^2)

    Args:
        G: A SimpleGraph instance.
        S: A set of vertex indices.

    Returns:
        True if the induced subgraph is a tree.
    """
    if len(S) <= 1:
        return True
    return (is_connected_subgraph(G, S) and
            induced_edge_count(G, S) == 2 * (len(S) - 1))


def is_single_component_of_delete_root(
    G: SimpleGraph, q: int, S: set[int]
) -> bool:
    """Check if S lies in a single connected component of G - {q}.

    Uses BFS in G - {q} starting from an arbitrary vertex in S.

    Time: O(|V| + |E|)

    Args:
        G: A SimpleGraph instance.
        q: The root vertex to delete.
        S: A set of vertex indices (should not contain q).

    Returns:
        True if S is contained in one component of G - {q}.
    """
    if len(S) <= 1:
        return True
    start = next(iter(S))
    visited = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for w in G.adj[v]:
            if w != q and w not in visited:
                visited.add(w)
                queue.append(w)
    return S <= visited


def is_equality_tight_set(
    G: SimpleGraph, q: int, S: set[int]
) -> bool:
    """Check if S satisfies the equality conditions:
    RootSeparatedSingleComponent AND InducedTreeOn.

    This is the full equality criterion from the formalization.

    Time: O(|V| + |E| + |S|^2)

    Args:
        G: A SimpleGraph instance.
        q: The root vertex.
        S: A set of vertex indices (should not contain q).

    Returns:
        True if S satisfies both conditions.
    """
    return (is_single_component_of_delete_root(G, q, S) and
            is_induced_tree(G, S))


def rooted_subset_divisor(q: int, S: set[int], n: int) -> dict[int, int]:
    """Compute the rooted subset divisor D_S.

    D_S(v) = 1 if v in S, D_S(q) = -|S|, D_S(v) = 0 otherwise.

    Args:
        q: Root vertex.
        S: Subset of vertices.
        n: Total number of vertices.

    Returns:
        Dictionary mapping vertices to divisor values.
    """
    D: dict[int, int] = {}
    for v in range(n):
        if v in S:
            D[v] = 1
        elif v == q:
            D[v] = -len(S)
        else:
            D[v] = 0
    return D


def classify_all_subsets(
    G: SimpleGraph, q: int
) -> dict[str, list[frozenset[int]]]:
    """Classify all subsets S ⊆ V \\ {q} by equality criterion.

    Returns subsets grouped by:
    - 'tight': satisfies both conditions (equality holds)
    - 'not_connected': G[S] is not connected
    - 'has_cycle': G[S] is connected but has a cycle
    - 'multi_component': single component condition fails
    - 'other': none of the above

    Time: O(2^n * (|V| + |E|))

    Args:
        G: A SimpleGraph instance.
        q: The root vertex.

    Returns:
        Dictionary mapping classification to lists of subsets.
    """
    from itertools import combinations

    vertices = [v for v in range(G.n) if v != q]
    result: dict[str, list[frozenset[int]]] = {
        'tight': [], 'not_connected': [], 'has_cycle': [],
        'multi_component': [], 'other': []
    }

    for r in range(len(vertices) + 1):
        for combo in combinations(vertices, r):
            S = set(combo)
            fs = frozenset(S)
            single_comp = is_single_component_of_delete_root(G, q, S)
            connected = is_connected_subgraph(G, S)
            tree = is_induced_tree(G, S)

            if single_comp and tree:
                result['tight'].append(fs)
            elif not connected:
                result['not_connected'].append(fs)
            elif not single_comp:
                result['multi_component'].append(fs)
            elif not tree and connected:
                result['has_cycle'].append(fs)
            else:
                result['other'].append(fs)

    return result


if __name__ == "__main__":
    # Example: Path graph P4
    print("=== Path Graph P4 ===")
    G = SimpleGraph(4, [(0, 1), (1, 2), (2, 3)])
    q = 0
    print(f"Vertices: {G.vertices()}")
    print(f"Edges: {G.edges()}")
    print(f"Root: {q}")
    print()

    # Classify all subsets
    classes = classify_all_subsets(G, q)
    print(f"Tight sets (equality holds): {len(classes['tight'])}")
    for s in sorted(classes['tight'], key=len):
        print(f"  S = {set(s)}")
    print(f"Not connected: {len(classes['not_connected'])}")
    print(f"Has cycle: {len(classes['has_cycle'])}")
    print(f"Multi-component: {len(classes['multi_component'])}")

    # Verify decomposition
    print("\n=== Decomposition Verification ===")
    S = {1, 2, 3}
    print(f"S = {S}")
    print(f"Decomposition holds: {verify_decomposition(G, S)}")
    print(f"Principal minor:\n{principal_minor(G, S)}")
    print(f"Restricted Laplacian:\n{restricted_laplacian(G, S)}")
    print(f"Cut degrees: {[cut_degree(G, v, S) for v in sorted(S)]}")

    # Energy formula
    print("\n=== Energy Formula ===")
    c = {0: 1, 1: 2, 2: -1, 3: 3}
    print(f"c = {c}")
    print(f"2 * Laplacian energy = {2 * laplacian_energy(G, c)}")
    print(f"Edge energy = {edge_energy(G, c)}")
    print(f"Formula verified: {verify_energy_formula(G, c)}")
