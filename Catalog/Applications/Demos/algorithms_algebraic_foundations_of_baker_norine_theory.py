#!/usr/bin/env python3
"""
Baker-Norine Theory: Core Algorithms

Type-hinted implementations of the fundamental algorithms in chip-firing
and divisor theory on graphs.
"""

from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass
import numpy as np


@dataclass
class Graph:
    """A simple graph represented by its adjacency matrix."""
    n: int
    adj: np.ndarray  # n x n adjacency matrix

    @classmethod
    def complete(cls, n: int) -> "Graph":
        """Complete graph K_n."""
        adj = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
        return cls(n=n, adj=adj)

    @classmethod
    def cycle(cls, n: int) -> "Graph":
        """Cycle graph C_n."""
        adj = np.zeros((n, n), dtype=int)
        for i in range(n):
            adj[i][(i + 1) % n] = 1
            adj[(i + 1) % n][i] = 1
        return cls(n=n, adj=adj)

    @classmethod
    def from_edges(cls, n: int, edges: List[Tuple[int, int]]) -> "Graph":
        """Build from edge list."""
        adj = np.zeros((n, n), dtype=int)
        for u, v in edges:
            adj[u][v] = 1
            adj[v][u] = 1
        return cls(n=n, adj=adj)

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return int(self.adj[v].sum())

    def neighbors(self, v: int) -> List[int]:
        """List of neighbors of v."""
        return [w for w in range(self.n) if self.adj[v][w] == 1]

    def num_edges(self) -> int:
        """Number of edges."""
        return int(self.adj.sum()) // 2

    def genus(self) -> int:
        """Graph genus: |E| - |V| + 1."""
        return self.num_edges() - self.n + 1

    def laplacian(self) -> np.ndarray:
        """Laplacian matrix L = D - A."""
        return np.diag(self.adj.sum(axis=1).astype(int)) - self.adj

    def canonical_divisor(self) -> np.ndarray:
        """K_G(v) = deg(v) - 2."""
        return np.array([self.degree(v) - 2 for v in range(self.n)])


def chip_fire(G: Graph, D: np.ndarray, q: int) -> np.ndarray:
    """
    Fire vertex q in divisor D on graph G.

    Algorithm:
    1. Subtract deg(q) from D(q)
    2. Add 1 to D(v) for each neighbor v of q

    Preserves total degree.
    """
    D_new = D.copy()
    D_new[q] -= G.degree(q)
    for v in G.neighbors(q):
        D_new[v] += 1
    return D_new


def fire_subset(G: Graph, D: np.ndarray, S: Set[int]) -> np.ndarray:
    """Fire all vertices in subset S simultaneously."""
    D_new = D.copy()
    for v in S:
        D_new[v] -= G.degree(v)
        for w in G.neighbors(v):
            D_new[w] += 1
    # Correction: edges within S are double-counted
    # Actually, firing subset S means each v in S sends one chip along each edge
    # Internal edges contribute net 0 between vertices in S
    D_new2 = D.copy()
    for v in S:
        for w in range(G.n):
            if G.adj[v][w] == 1:
                if w in S:
                    pass  # Internal edge: cancel
                else:
                    D_new2[v] -= 1
                    D_new2[w] += 1
    return D_new2


def dhar_burning(G: Graph, D: np.ndarray, q: int) -> Tuple[bool, Set[int]]:
    """
    Dhar's Burning Algorithm.

    Input: Graph G, divisor D, distinguished vertex q
    Output: (is_q_reduced, unburned_set)

    Algorithm:
    1. Mark q as "burning"
    2. Repeat: mark any unburned vertex v whose number of
       burning neighbors exceeds D(v)
    3. If all vertices burn, D is q-reduced (superstable)
    4. Otherwise, the unburned set can be fired

    Complexity: O(|V|²)
    """
    burned: Set[int] = {q}
    changed = True
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned:
                continue
            burning_neighbors = sum(1 for w in G.neighbors(v) if w in burned)
            if burning_neighbors > D[v]:
                burned.add(v)
                changed = True
    unburned = set(range(G.n)) - burned
    return len(unburned) == 0, unburned


def q_reduce(G: Graph, D: np.ndarray, q: int,
             max_iter: int = 10000) -> np.ndarray:
    """
    Compute the q-reduced divisor linearly equivalent to D.

    Algorithm:
    1. Run Dhar's burning algorithm
    2. If all vertices burn, D is already q-reduced
    3. Otherwise, fire the unburned set and repeat

    Terminates because each firing strictly decreases a well-ordered potential.
    """
    D_cur = D.copy()
    for _ in range(max_iter):
        is_reduced, unburned = dhar_burning(G, D_cur, q)
        if is_reduced:
            return D_cur
        D_cur = fire_subset(G, D_cur, unburned)
    raise RuntimeError("q_reduce did not converge")


def divisor_rank(G: Graph, D: np.ndarray, q: int = 0) -> int:
    """
    Compute the rank r(D) of divisor D.

    Algorithm:
    1. Compute q-reduced form D₀
    2. If D₀(q) < 0, return -1
    3. Otherwise, repeatedly subtract δ_q and re-reduce
    4. Count successful iterations

    The rank equals D₀(q) for the initial q-reduced form.
    """
    D_red = q_reduce(G, D, q)
    if D_red[q] < 0:
        return -1

    rank = 0
    D_cur = D.copy()
    while True:
        D_cur[q] -= 1
        D_red = q_reduce(G, D_cur, q)
        if D_red[q] < 0:
            return rank
        rank += 1
        D_cur = D_red
        if rank > 2 * G.n * max(abs(D).max(), 1):
            return rank


def verify_riemann_roch(G: Graph, D: np.ndarray, q: int = 0) -> Dict:
    """
    Verify the Baker-Norine Riemann-Roch theorem:
    r(D) - r(K_G - D) = deg(D) - g + 1
    """
    g = G.genus()
    K = G.canonical_divisor()
    r_D = divisor_rank(G, D, q)
    r_KD = divisor_rank(G, K - D, q)
    deg_D = int(D.sum())

    lhs = r_D - r_KD
    rhs = deg_D - g + 1

    return {
        "divisor": D.tolist(),
        "degree": deg_D,
        "genus": g,
        "r(D)": r_D,
        "r(K-D)": r_KD,
        "lhs": lhs,
        "rhs": rhs,
        "verified": lhs == rhs,
    }


def spanning_tree_count(G: Graph) -> int:
    """
    Count spanning trees via the matrix-tree theorem.
    |T(G)| = det(reduced Laplacian)
    """
    L = G.laplacian()
    L_red = L[1:, 1:]
    return int(round(np.linalg.det(L_red)))


def jacobian_order(G: Graph) -> int:
    """
    Order of the Jacobian group = number of spanning trees.
    """
    return spanning_tree_count(G)


if __name__ == "__main__":
    # Quick test
    G = Graph.complete(4)
    print(f"K₄: genus={G.genus()}, spanning trees={spanning_tree_count(G)}")
    D = np.array([3, 0, 0, 0])
    print(f"r({D.tolist()}) = {divisor_rank(G, D)}")
    result = verify_riemann_roch(G, D)
    print(f"Riemann-Roch: {result}")
