#!/usr/bin/env python3
"""
Algorithms for the Universal Defect Formula.

Implements:
1. Structural defect computation: β₁(G[S]) + κ(G,q,S) - 1
2. Higher defect spectrum: δ_d = d·β₁ + κ - 1
3. Tropical Laplacian construction
4. Graph invariant computation (Betti numbers, connected components)

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import Dict, List, Set, Tuple, Optional
import itertools


class Graph:
    """Simple undirected graph on vertices {0, ..., n-1}.

    Time complexity for construction: O(|E|)
    Space complexity: O(|V| + |E|)
    """

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
        self.edges: Set[Tuple[int, int]] = set()
        for u, v in edges:
            if u != v and u < n and v < n:
                self.adj[u].add(v)
                self.adj[v].add(u)
                self.edges.add((min(u, v), max(u, v)))

    def degree(self, v: int) -> int:
        """Degree of vertex v. O(1)."""
        return len(self.adj[v])

    def induced_subgraph(self, S: Set[int]) -> 'Graph':
        """Induced subgraph G[S]. O(|S|² + |E|)."""
        vmap = {v: i for i, v in enumerate(sorted(S))}
        edges = [(vmap[u], vmap[v]) for u, v in self.edges if u in S and v in S]
        g = Graph(len(S), edges)
        g._original_vertices = sorted(S)
        return g

    def connected_components(self) -> List[Set[int]]:
        """Connected components via DFS. O(|V| + |E|)."""
        visited: Set[int] = set()
        components: List[Set[int]] = []
        for v in range(self.n):
            if v not in visited:
                comp: Set[int] = set()
                stack = [v]
                while stack:
                    u = stack.pop()
                    if u in visited:
                        continue
                    visited.add(u)
                    comp.add(u)
                    stack.extend(self.adj[u] - visited)
                components.append(comp)
        return components

    def is_connected(self) -> bool:
        """O(|V| + |E|)."""
        return self.n <= 1 or len(self.connected_components()) == 1

    def num_edges(self) -> int:
        return len(self.edges)


# ────────────────────────────────────────────────────────────
# Algorithm 1: First Betti Number
# ────────────────────────────────────────────────────────────

def betti_one(G: Graph) -> int:
    """Compute the first Betti number β₁(G) = |E| - |V| + c(G).

    The first Betti number counts the number of independent cycles
    in the graph. For a connected graph, β₁ = |E| - |V| + 1.

    Time: O(|V| + |E|)  (dominated by connected components)
    Space: O(|V|)

    Args:
        G: A simple graph.

    Returns:
        β₁(G), the cycle rank (first Betti number).

    Examples:
        >>> betti_one(Graph(3, [(0,1), (1,2), (2,0)]))  # triangle
        1
        >>> betti_one(Graph(4, [(0,1), (1,2), (2,3)]))  # path
        0
    """
    c = len(G.connected_components())
    return G.num_edges() - G.n + c


# ────────────────────────────────────────────────────────────
# Algorithm 2: κ (q-visible component count)
# ────────────────────────────────────────────────────────────

def kappa(G: Graph, q: int, S: Set[int]) -> int:
    """Compute κ(G,q,S): the number of q-visible components of G[S].

    A connected component C of G[S] is q-visible if there exists
    a vertex v ∈ C such that G.Adj(q, v).

    Time: O(|S| + |E(G[S])| + deg(q))
    Space: O(|S|)

    Args:
        G: The ambient graph.
        q: The root vertex.
        S: The vertex subset (q ∉ S).

    Returns:
        The number of q-visible connected components of G[S].

    Examples:
        >>> G = Graph(4, [(0,1), (1,2), (2,3)])
        >>> kappa(G, 0, {1, 2, 3})
        1
        >>> kappa(G, 0, {2, 3})  # not adjacent to 0
        0
    """
    sub = G.induced_subgraph(S)
    original = sub._original_vertices
    q_neighbors = G.adj[q]
    count = 0
    for comp in sub.connected_components():
        original_verts = {original[i] for i in comp}
        if original_verts & q_neighbors:
            count += 1
    return count


# ────────────────────────────────────────────────────────────
# Algorithm 3: Structural Defect
# ────────────────────────────────────────────────────────────

def structural_defect(G: Graph, q: int, S: Set[int]) -> int:
    """Compute the structural defect δ_str = β₁(G[S]) + κ(G,q,S) - 1.

    This is the topological side of the universal defect formula.
    The conjecture states that this equals the equality defect
    δ_eq = tropRank(L_S) - 1 - r(D_S).

    Time: O(|S| + |E(G[S])| + deg(q))
    Space: O(|S|)

    Args:
        G: A connected graph.
        q: Root vertex.
        S: Nonempty subset of V \ {q}.

    Returns:
        The structural defect (integer).
    """
    sub = G.induced_subgraph(S)
    b1 = betti_one(sub)
    k = kappa(G, q, S)
    return b1 + k - 1


# ────────────────────────────────────────────────────────────
# Algorithm 4: Higher Defect Spectrum
# ────────────────────────────────────────────────────────────

def higher_defect_spectrum(G: Graph, q: int, S: Set[int],
                           max_d: int = 10) -> List[int]:
    """Compute the higher defect spectrum {δ_d : d = 0, ..., max_d}.

    The spectrum δ_d = d · β₁(G[S]) + κ(G,q,S) - 1 is an affine
    function of d with slope β₁ and intercept κ - 1.

    Time: O(|S| + |E(G[S])| + max_d)
    Space: O(max_d)

    Args:
        G: A connected graph.
        q: Root vertex.
        S: Nonempty subset of V \ {q}.
        max_d: Maximum degree parameter.

    Returns:
        List of defect values [δ_0, δ_1, ..., δ_{max_d}].
    """
    sub = G.induced_subgraph(S)
    b1 = betti_one(sub)
    k = kappa(G, q, S)
    return [d * b1 + k - 1 for d in range(max_d + 1)]


# ────────────────────────────────────────────────────────────
# Algorithm 5: Graph Laplacian
# ────────────────────────────────────────────────────────────

def graph_laplacian(G: Graph) -> List[List[int]]:
    """Compute the combinatorial Laplacian matrix L(G).

    L(i,j) = deg(i) if i = j
    L(i,j) = -1     if i ~ j
    L(i,j) = 0      otherwise

    Properties (verified in Lean):
    - Row sums are zero: Σ_j L(i,j) = 0
    - Symmetric: L(i,j) = L(j,i)
    - Diagonal nonneg: L(i,i) ≥ 0

    Time: O(|V|² + |E|)
    Space: O(|V|²)
    """
    n = G.n
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = G.degree(i)
        for j in G.adj[i]:
            L[i][j] = -1
    return L


def principal_minor(L: List[List[int]], S: List[int]) -> List[List[int]]:
    """Extract principal submatrix L_S.

    Time: O(|S|²)
    Space: O(|S|²)
    """
    k = len(S)
    return [[L[S[i]][S[j]] for j in range(k)] for i in range(k)]


# ────────────────────────────────────────────────────────────
# Algorithm 6: Defect Landscape
# ────────────────────────────────────────────────────────────

def defect_landscape(G: Graph, q: int) -> Dict[frozenset, dict]:
    """Compute the complete defect landscape for all S ⊆ V \ {q}.

    Time: O(2^{n-1} · (|S| + |E|))
    Space: O(2^{n-1})

    Returns dict mapping frozenset(S) → {β₁, κ, δ_str, ...}
    """
    vertices = [v for v in range(G.n) if v != q]
    landscape = {}
    for size in range(1, len(vertices) + 1):
        for subset in itertools.combinations(vertices, size):
            S = frozenset(subset)
            S_set = set(subset)
            sub = G.induced_subgraph(S_set)
            b1 = betti_one(sub)
            k = kappa(G, q, S_set)
            landscape[S] = {
                'betti_one': b1,
                'kappa': k,
                'structural_defect': b1 + k - 1,
                'edge_count': sub.num_edges(),
                'component_count': len(sub.connected_components()),
                'size': len(S),
            }
    return landscape


# ────────────────────────────────────────────────────────────
# Example usage
# ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: Complete graph K_5
    K5 = Graph(5, [(i, j) for i in range(5) for j in range(i+1, 5)])
    q = 0
    S = {1, 2, 3, 4}

    print("Complete graph K₅, q=0, S={1,2,3,4}")
    print(f"  β₁(G[S]) = {betti_one(K5.induced_subgraph(S))}")
    print(f"  κ(G,q,S) = {kappa(K5, q, S)}")
    print(f"  δ_str    = {structural_defect(K5, q, S)}")
    print(f"  Spectrum = {higher_defect_spectrum(K5, q, S, 5)}")

    # Laplacian
    L = graph_laplacian(K5)
    print(f"\n  Laplacian of K₅:")
    for row in L:
        print(f"    {row}")

    # Verify row-sum zero
    for i, row in enumerate(L):
        assert sum(row) == 0, f"Row {i} sum ≠ 0"
    print(f"  Row sums all zero ✓")

    # Landscape
    print(f"\n  Defect landscape (first 5 entries):")
    landscape = defect_landscape(K5, q)
    for S_key, data in list(landscape.items())[:5]:
        print(f"    S={set(S_key)}: δ_str={data['structural_defect']}, "
              f"β₁={data['betti_one']}, κ={data['kappa']}")
