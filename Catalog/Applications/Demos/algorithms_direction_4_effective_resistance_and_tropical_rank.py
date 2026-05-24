"""
Algorithms for Effective Resistance, Chip-Firing, and Tropical Rank Defect.

This module implements the computational core for analyzing the tropical rank
defect on finite graphs — the gap between tropical linear-algebraic complexity
and chip-firing realizability.

Key algorithms:
- Graph Laplacian computation
- Effective resistance via pseudoinverse
- Chip-firing rank computation (brute-force for small graphs)
- Tropical rank estimation
- Defect profiling across all rooted subsets
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class GraphData:
    """A simple undirected graph represented by adjacency matrix."""
    adj: np.ndarray  # n x n adjacency matrix (0/1, symmetric)
    n: int  # number of vertices

    @classmethod
    def path(cls, n: int) -> 'GraphData':
        """Path graph P_n on n vertices."""
        adj = np.zeros((n, n), dtype=int)
        for i in range(n - 1):
            adj[i, i + 1] = 1
            adj[i + 1, i] = 1
        return cls(adj=adj, n=n)

    @classmethod
    def cycle(cls, n: int) -> 'GraphData':
        """Cycle graph C_n on n vertices."""
        g = cls.path(n)
        g.adj[0, n - 1] = 1
        g.adj[n - 1, 0] = 1
        return g

    @classmethod
    def complete(cls, n: int) -> 'GraphData':
        """Complete graph K_n on n vertices."""
        adj = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
        return cls(adj=adj, n=n)

    @classmethod
    def barbell(cls, n: int) -> 'GraphData':
        """Barbell graph: two K_n joined by a single edge."""
        total = 2 * n
        adj = np.zeros((total, total), dtype=int)
        # First clique
        for i in range(n):
            for j in range(i + 1, n):
                adj[i, j] = 1
                adj[j, i] = 1
        # Second clique
        for i in range(n, total):
            for j in range(i + 1, total):
                adj[i, j] = 1
                adj[j, i] = 1
        # Bridge
        adj[n - 1, n] = 1
        adj[n, n - 1] = 1
        return cls(adj=adj, n=total)

    @classmethod
    def lollipop(cls, n: int, k: int) -> 'GraphData':
        """Lollipop graph: K_n with a path of length k attached."""
        total = n + k
        adj = np.zeros((total, total), dtype=int)
        # Clique
        for i in range(n):
            for j in range(i + 1, n):
                adj[i, j] = 1
                adj[j, i] = 1
        # Path from vertex n-1
        for i in range(n - 1, n + k - 1):
            adj[i, i + 1] = 1
            adj[i + 1, i] = 1
        return cls(adj=adj, n=total)

    @classmethod
    def star(cls, n: int) -> 'GraphData':
        """Star graph S_n: one center connected to n-1 leaves."""
        adj = np.zeros((n, n), dtype=int)
        for i in range(1, n):
            adj[0, i] = 1
            adj[i, 0] = 1
        return cls(adj=adj, n=n)

    def num_edges(self) -> int:
        """Number of edges."""
        return int(np.sum(self.adj) // 2)

    def is_connected(self) -> bool:
        """Check connectivity via BFS."""
        if self.n == 0:
            return True
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            v = queue.pop(0)
            for w in range(self.n):
                if self.adj[v, w] and w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


def graph_laplacian(G: GraphData) -> np.ndarray:
    """Compute the graph Laplacian L = D - A.

    L(i,j) = deg(i) if i == j, -1 if i ~ j, 0 otherwise.

    Time: O(n²), Space: O(n²)
    """
    D = np.diag(np.sum(G.adj, axis=1))
    return D - G.adj


def effective_resistance(G: GraphData) -> np.ndarray:
    """Compute pairwise effective resistance via the pseudoinverse.

    R_eff(u,v) = L†(u,u) + L†(v,v) - 2·L†(u,v)

    where L† is the Moore-Penrose pseudoinverse of the Laplacian.

    Time: O(n³), Space: O(n²)
    """
    L = graph_laplacian(G).astype(float)
    L_pinv = np.linalg.pinv(L)
    R = np.zeros((G.n, G.n))
    for u in range(G.n):
        for v in range(G.n):
            R[u, v] = L_pinv[u, u] + L_pinv[v, v] - 2 * L_pinv[u, v]
    return np.maximum(R, 0)  # Clip tiny negative values from numerics


def resistance_diameter(R: np.ndarray, vertices: List[int]) -> float:
    """Maximum pairwise effective resistance among a set of vertices.

    Time: O(|S|²)
    """
    if len(vertices) <= 1:
        return 0.0
    return max(R[u, v] for u in vertices for v in vertices)


def resistance_spread(R: np.ndarray, q: int, S: List[int]) -> float:
    """Maximum resistance from root q to any vertex in S.

    Time: O(|S|)
    """
    if not S:
        return 0.0
    return max(R[q, v] for v in S)


def commute_time_diameter(G: GraphData, R: np.ndarray, vertices: List[int]) -> float:
    """Commute time diameter = 2|E| · resistance diameter.

    Time: O(|S|²)
    """
    return 2 * G.num_edges() * resistance_diameter(R, vertices)


def principal_minor(L: np.ndarray, S: List[int]) -> np.ndarray:
    """Extract the principal submatrix L_S indexed by S.

    Time: O(|S|²)
    """
    idx = np.array(S)
    return L[np.ix_(idx, idx)]


def rooted_subset_divisor(n: int, q: int, S: List[int]) -> np.ndarray:
    """The canonical degree-zero divisor D_S.

    D_S(v) = 1 if v ∈ S, D_S(q) = -|S|, D_S(v) = 0 otherwise.

    Time: O(n)
    """
    D = np.zeros(n, dtype=int)
    for v in S:
        D[v] = 1
    D[q] = -len(S)
    return D


def chip_fire(D: np.ndarray, L: np.ndarray, f: np.ndarray) -> np.ndarray:
    """Apply chip-firing move with potential f: D' = D - L·f.

    Time: O(n²)
    """
    return D - L @ f


def is_effective(D: np.ndarray) -> bool:
    """Check if a divisor is effective (all coefficients ≥ 0).

    Time: O(n)
    """
    return np.all(D >= 0)


def divisor_rank_bruteforce(G: GraphData, D: np.ndarray, max_rank: int = 10) -> int:
    """Compute the divisor rank r(D) by brute force.

    r(D) = max r such that for all effective E of degree r,
    D - E is linearly equivalent to an effective divisor.

    For small graphs, we enumerate all effective divisors E of degree r
    and check if D - E can be made effective by chip-firing.

    Time: Exponential in n and r (for small graphs only!)

    Args:
        G: Graph data
        D: Divisor (integer array)
        max_rank: Maximum rank to check

    Returns:
        The divisor rank r(D), or -1 if D is not equivalent to any effective divisor.
    """
    n = G.n
    L = graph_laplacian(G)

    # First check if D itself can be made effective (rank ≥ 0)
    if not _can_make_effective(D, L, n):
        return -1

    for r in range(1, max_rank + 1):
        # Check all effective divisors E of degree r
        # E is a non-negative integer vector summing to r
        all_pass = True
        for E in _effective_divisors_of_degree(n, r):
            D_minus_E = D - E
            if not _can_make_effective(D_minus_E, L, n):
                all_pass = False
                break
        if not all_pass:
            return r - 1
    return max_rank


def _can_make_effective(D: np.ndarray, L: np.ndarray, n: int,
                        max_iter: int = 1000) -> bool:
    """Check if D can be made effective by chip-firing moves.

    Uses Dhar's burning algorithm / greedy approach for small graphs.
    """
    # Try all possible firing sequences up to a bound
    current = D.copy().astype(int)

    # Greedy: repeatedly fire vertices with negative coefficient
    for _ in range(max_iter):
        if np.all(current >= 0):
            return True
        # Find a vertex with negative coefficient
        neg_vertices = np.where(current < 0)[0]
        if len(neg_vertices) == 0:
            return True

        # Try firing the complement of each negative vertex
        made_progress = False
        for v in neg_vertices:
            # Fire all vertices except v (equivalent to "borrowing" from v)
            f = np.zeros(n, dtype=int)
            f[v] = -1
            new_D = current - L @ f
            if np.sum(new_D < 0) < np.sum(current < 0) or np.min(new_D) > np.min(current):
                current = new_D
                made_progress = True
                break

        if not made_progress:
            # Try individual vertex firings
            for v in range(n):
                if current[v] > 0:
                    f = np.zeros(n, dtype=int)
                    f[v] = 1
                    new_D = current - L @ f
                    if np.sum(new_D < 0) < np.sum(current < 0):
                        current = new_D
                        made_progress = True
                        break

            if not made_progress:
                return False

    return np.all(current >= 0)


def _effective_divisors_of_degree(n: int, r: int):
    """Generate all effective divisors of degree r on n vertices.

    These are non-negative integer vectors of length n summing to r.
    Uses stars-and-bars enumeration.
    """
    if n == 0 or r < 0:
        return
    if n == 1:
        yield np.array([r], dtype=int)
        return
    for first in range(r + 1):
        for rest in _effective_divisors_of_degree(n - 1, r - first):
            yield np.concatenate([[first], rest])


def tropical_rank_proxy(L_S: np.ndarray) -> int:
    """Compute a proxy for the tropical rank of L_S.

    We use the classical rank over ℝ as a lower bound for tropical rank.
    For integer matrices, rank(L_S) ≤ tropicalRank(L_S).

    Time: O(|S|³)
    """
    if L_S.size == 0:
        return 0
    return int(np.linalg.matrix_rank(L_S.astype(float)))


def tropical_rank_defect(trop_rank: int, chip_rank: int) -> int:
    """Compute the tropical rank defect Δ = (tropRank - 1) - chipRank."""
    return (trop_rank - 1) - chip_rank


def defect_profile(G: GraphData, q: int,
                   max_subset_size: Optional[int] = None) -> List[Dict]:
    """Compute the full defect profile for all subsets S ⊆ V \ {q}.

    For each subset S, computes:
    - L_S (principal Laplacian minor)
    - Tropical rank proxy
    - Divisor D_S
    - Chip-firing rank r(D_S)
    - Defect Δ(G, q, S)
    - Resistance diameter of S ∪ {q}

    Args:
        G: Connected graph
        q: Root vertex
        max_subset_size: Maximum subset size to enumerate (None = all)

    Returns:
        List of dicts with defect analysis for each subset.
    """
    n = G.n
    L = graph_laplacian(G)
    R = effective_resistance(G)
    vertices = [v for v in range(n) if v != q]

    if max_subset_size is None:
        max_subset_size = len(vertices)

    results = []
    for size in range(1, min(max_subset_size, len(vertices)) + 1):
        for S in combinations(vertices, size):
            S_list = list(S)
            S_with_q = S_list + [q]

            # Principal minor
            L_S = principal_minor(L, S_list)

            # Tropical rank proxy
            tr = tropical_rank_proxy(L_S)

            # Divisor
            D_S = rooted_subset_divisor(n, q, S_list)

            # Chip-firing rank
            cr = divisor_rank_bruteforce(G, D_S, max_rank=min(size + 2, 8))

            # Defect
            delta = tropical_rank_defect(tr, cr)

            # Resistance geometry
            r_diam = resistance_diameter(R, S_with_q)
            r_spread = resistance_spread(R, q, S_list)
            c_diam = commute_time_diameter(G, R, S_with_q)

            results.append({
                'S': S_list,
                'size': size,
                'trop_rank': tr,
                'chip_rank': cr,
                'defect': delta,
                'degree': int(np.sum(D_S)),
                'resistance_diam': round(r_diam, 6),
                'resistance_spread': round(r_spread, 6),
                'commute_time_diam': round(c_diam, 4),
                'L_S_det': round(float(np.linalg.det(L_S.astype(float))), 4)
                    if L_S.size > 0 else 0,
            })

    return results


def dirichlet_energy(G: GraphData, phi: np.ndarray) -> float:
    """Compute the Dirichlet energy ∑_{i~j} (φ(i) - φ(j))².

    Time: O(n²)
    """
    energy = 0.0
    for i in range(G.n):
        for j in range(G.n):
            if G.adj[i, j]:
                energy += (phi[i] - phi[j]) ** 2
    return energy


if __name__ == '__main__':
    # Example: path graph on 5 vertices
    print("=" * 60)
    print("Defect Profile: Path P_5, root q=0")
    print("=" * 60)

    G = GraphData.path(5)
    results = defect_profile(G, q=0, max_subset_size=3)

    for r in results[:10]:
        print(f"  S={r['S']}, |S|={r['size']}, "
              f"tropRank={r['trop_rank']}, chipRank={r['chip_rank']}, "
              f"defect={r['defect']}, Rdiam={r['resistance_diam']:.3f}")

    print()
    print("=" * 60)
    print("Defect Profile: Complete K_4, root q=0")
    print("=" * 60)

    G = GraphData.complete(4)
    results = defect_profile(G, q=0)

    for r in results:
        print(f"  S={r['S']}, |S|={r['size']}, "
              f"tropRank={r['trop_rank']}, chipRank={r['chip_rank']}, "
              f"defect={r['defect']}, Rdiam={r['resistance_diam']:.3f}")
