#!/usr/bin/env python3
"""
Tropical Graph Optimization Algorithms

Implements the core algorithms from the research paper:
1. Tropical Bellman-Ford shortest path
2. Tropical matrix powers (Kleene star)
3. Hexagonal lattice operations
4. Kardashev index computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional
import math


# ============================================================================
# TROPICAL ALGEBRA
# ============================================================================

class TropicalSemiring:
    """
    The tropical (min-plus) semiring over ℝ ∪ {+∞}.

    Operations:
        ⊕ (tropical add) = min
        ⊗ (tropical mul) = +

    Identity elements:
        Additive identity: +∞ (since min(a, ∞) = a)
        Multiplicative identity: 0 (since a + 0 = a)
    """

    INF = float('inf')

    @staticmethod
    def add(a: float, b: float) -> float:
        """Tropical addition: min(a, b)"""
        return min(a, b)

    @staticmethod
    def mul(a: float, b: float) -> float:
        """Tropical multiplication: a + b"""
        if a == float('inf') or b == float('inf'):
            return float('inf')
        return a + b

    @staticmethod
    def zero() -> float:
        """Additive identity: +∞"""
        return float('inf')

    @staticmethod
    def one() -> float:
        """Multiplicative identity: 0"""
        return 0.0

    @staticmethod
    def verify_distributivity(a: float, b: float, c: float) -> bool:
        """
        Verify: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
        i.e., a + min(b, c) = min(a+b, a+c)
        """
        lhs = TropicalSemiring.mul(a, TropicalSemiring.add(b, c))
        rhs = TropicalSemiring.add(
            TropicalSemiring.mul(a, b),
            TropicalSemiring.mul(a, c)
        )
        return abs(lhs - rhs) < 1e-12 if lhs != float('inf') else rhs == float('inf')


# ============================================================================
# TROPICAL BELLMAN-FORD
# ============================================================================

def tropical_bellman_ford(
    n: int,
    weights: np.ndarray,
    source: int,
    max_iterations: Optional[int] = None
) -> Tuple[np.ndarray, np.ndarray, int]:
    """
    Tropical Bellman-Ford algorithm for shortest path distances.

    Computes the tropical (min-plus) shortest path distance from a source
    vertex to all other vertices in a weighted directed graph.

    Parameters:
        n: Number of vertices (vertices are indexed 0 to n-1)
        weights: n×n matrix where weights[u][v] = cost of edge u→v
                 Use float('inf') for non-edges
        source: Source vertex index
        max_iterations: Maximum iterations (default: n-1)

    Returns:
        dist: Array of tropical distances from source
        predecessors: Array of predecessor vertices (-1 for source/unreachable)
        iterations: Number of iterations until convergence

    Complexity:
        Time: O(n³) worst case, O(n²) per iteration
        Space: O(n)

    Correctness:
        Under nonneg edge weights, converges in at most n-1 iterations.
        The result satisfies the Bellman optimality equation:
            dist[v] = min(dist[v], min_u(dist[u] + weights[u][v]))
    """
    if max_iterations is None:
        max_iterations = n - 1

    dist = np.full(n, float('inf'))
    dist[source] = 0.0
    predecessors = np.full(n, -1, dtype=int)

    iterations = 0
    for i in range(max_iterations):
        updated = False
        for v in range(n):
            for u in range(n):
                candidate = dist[u] + weights[u][v]
                if candidate < dist[v]:
                    dist[v] = candidate
                    predecessors[v] = u
                    updated = True
        iterations = i + 1
        if not updated:
            break

    return dist, predecessors, iterations


def reconstruct_path(predecessors: np.ndarray, source: int, target: int) -> List[int]:
    """
    Reconstruct shortest path from predecessor array.

    Parameters:
        predecessors: Predecessor array from Bellman-Ford
        source: Source vertex
        target: Target vertex

    Returns:
        List of vertices on the shortest path from source to target
    """
    if predecessors[target] == -1 and target != source:
        return []  # Unreachable

    path = [target]
    current = target
    while current != source:
        current = predecessors[current]
        if current == -1:
            return []
        path.append(current)
        if len(path) > len(predecessors):
            return []  # Cycle detection

    return list(reversed(path))


# ============================================================================
# TROPICAL MATRIX OPERATIONS
# ============================================================================

def tropical_matrix_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical matrix multiplication.

    (A ⊗ B)[i][j] = min_k(A[i][k] + B[k][j])

    This is standard matrix multiplication with (min, +) replacing (+, ×).

    Complexity: O(n³)
    """
    n = A.shape[0]
    C = np.full((n, n), float('inf'))
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i][k] + B[k][j]
                if val < C[i][j]:
                    C[i][j] = val
    return C


def tropical_matrix_power(W: np.ndarray, k: int) -> np.ndarray:
    """
    Compute W^k in the tropical semiring (k-step distances).

    W^k[i][j] = minimum cost of a path from i to j using exactly k edges.

    Complexity: O(n³ · k)
    """
    n = W.shape[0]
    # Identity matrix (tropical): 0 on diagonal, ∞ elsewhere
    result = np.full((n, n), float('inf'))
    np.fill_diagonal(result, 0.0)

    for _ in range(k):
        result = tropical_matrix_mul(result, W)
    return result


def tropical_kleene_star(W: np.ndarray, max_steps: Optional[int] = None) -> np.ndarray:
    """
    Compute the Kleene star W* = I ⊕ W ⊕ W² ⊕ ... in the tropical semiring.

    W*[i][j] = minimum cost of any path from i to j (all-pairs shortest paths).

    Under nonneg edge weights, this stabilizes after at most n steps.

    Parameters:
        W: n×n tropical adjacency matrix
        max_steps: Maximum number of powers (default: n)

    Returns:
        All-pairs shortest distance matrix

    Complexity: O(n⁴) worst case
    """
    n = W.shape[0]
    if max_steps is None:
        max_steps = n

    # Start with identity
    result = np.full((n, n), float('inf'))
    np.fill_diagonal(result, 0.0)

    current_power = np.full((n, n), float('inf'))
    np.fill_diagonal(current_power, 0.0)

    for step in range(max_steps):
        current_power = tropical_matrix_mul(current_power, W)
        new_result = np.minimum(result, current_power)

        # Check convergence
        if np.allclose(new_result, result):
            break
        result = new_result

    return result


# ============================================================================
# HEXAGONAL LATTICE
# ============================================================================

class HexLattice:
    """
    Operations on the hexagonal lattice ℤ × ℤ with axial coordinates.

    Adjacency directions: (1,0), (-1,0), (0,1), (0,-1), (1,-1), (-1,1)

    Hex distance: max(|Δa|, |Δb|, |Δa + Δb|)
    """

    DIRECTIONS = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]

    @staticmethod
    def distance(p: Tuple[int, int], q: Tuple[int, int]) -> int:
        """
        Hex distance between two points.

        Complexity: O(1)
        """
        da = q[0] - p[0]
        db = q[1] - p[1]
        return max(abs(da), abs(db), abs(da + db))

    @staticmethod
    def neighbors(p: Tuple[int, int]) -> List[Tuple[int, int]]:
        """
        Return 6 hex-adjacent neighbors.

        Complexity: O(1)
        """
        a, b = p
        return [(a + da, b + db) for da, db in HexLattice.DIRECTIONS]

    @staticmethod
    def patch(r: int) -> Set[Tuple[int, int]]:
        """
        Generate hexagonal patch of radius r centered at origin.

        Returns all points (a, b) with hex_distance((0,0), (a,b)) ≤ r.

        Complexity: O(r²)
        """
        cells = set()
        for a in range(-r, r + 1):
            for b in range(-r, r + 1):
                if HexLattice.distance((0, 0), (a, b)) <= r:
                    cells.add((a, b))
        return cells

    @staticmethod
    def edge_boundary(S: Set[Tuple[int, int]]) -> int:
        """
        Count directed (interior, exterior) adjacent pairs.

        Complexity: O(6|S|)
        """
        count = 0
        for x in S:
            for y in HexLattice.neighbors(x):
                if y not in S:
                    count += 1
        return count

    @staticmethod
    def patch_card_formula(r: int) -> int:
        """Centered hexagonal number: 3r² + 3r + 1."""
        return 3 * r * r + 3 * r + 1

    @staticmethod
    def boundary_formula(r: int) -> int:
        """Edge boundary of hex patch: 12r + 6."""
        return 12 * r + 6

    @staticmethod
    def isoperimetric_ratio(r: int) -> float:
        """Boundary-to-area ratio: (12r + 6) / (3r² + 3r + 1)."""
        if r == 0:
            return 6.0
        return (12 * r + 6) / (3 * r * r + 3 * r + 1)


# ============================================================================
# KARDASHEV INDEX
# ============================================================================

class KardashevScale:
    """
    Kardashev index computation and bounds.

    K(P) = log₁₀(P) for power P in watts.

    Standard scale:
        Type I:   K ≈ 16-17 (planetary energy)
        Type II:  K ≈ 26-27 (stellar energy)
        Type III: K ≈ 36-37 (galactic energy)
    """

    @staticmethod
    def index(P: float) -> float:
        """
        Compute Kardashev index K(P) = log₁₀(P).

        Parameters:
            P: Power in watts (must be positive)

        Returns:
            Kardashev index
        """
        if P <= 0:
            return float('-inf')
        return math.log10(P)

    @staticmethod
    def optimal_power(L: float, eta: float, C: float) -> float:
        """
        Compute optimal collected power.

        P_opt = L · η · C

        Parameters:
            L: Stellar luminosity (watts)
            eta: Conversion efficiency (0 < η ≤ 1)
            C: Tropical capacity (0 ≤ C ≤ 1)
        """
        return L * eta * C

    @staticmethod
    def bound(L: float, eta: float, C: float, C_max: float) -> Tuple[float, float]:
        """
        Compute Kardashev index and its upper bound.

        Returns (K(L·η·C), K(L·η·C_max)) where K(L·η·C) ≤ K(L·η·C_max)
        when C ≤ C_max.

        Parameters:
            L: Stellar luminosity
            eta: Conversion efficiency
            C: Actual tropical capacity
            C_max: Capacity upper bound
        """
        P = KardashevScale.optimal_power(L, eta, C)
        P_max = KardashevScale.optimal_power(L, eta, C_max)
        return KardashevScale.index(P), KardashevScale.index(P_max)


# ============================================================================
# TROPICAL CAPACITY OF A NETWORK
# ============================================================================

def tropical_capacity(
    n: int,
    weights: np.ndarray,
    source: int,
    G: float = 1.0
) -> Tuple[float, int, np.ndarray]:
    """
    Compute tropical capacity of a network.

    The tropical capacity is the maximum normalized gain:
        C_trop = max_v (G - d(source, v)) / G

    Parameters:
        n: Number of vertices
        weights: Edge weight matrix
        source: Source vertex
        G: Gross flux (default 1.0 for normalization)

    Returns:
        capacity: Tropical capacity (0 ≤ C ≤ 1 for nonneg weights)
        optimal_vertex: Vertex achieving maximum gain
        distances: All tropical distances
    """
    dist, _, _ = tropical_bellman_ford(n, weights, source)

    gains = {}
    for v in range(n):
        if dist[v] < float('inf'):
            gains[v] = G - dist[v]

    if not gains:
        return 0.0, -1, dist

    optimal_v = max(gains, key=gains.get)
    capacity = gains[optimal_v] / G

    return capacity, optimal_v, dist


# ============================================================================
# EXAMPLE USAGE
# ============================================================================

if __name__ == "__main__":
    print("Tropical Graph Optimization — Algorithm Examples")
    print("=" * 60)

    # 1. Tropical algebra verification
    ts = TropicalSemiring()
    assert ts.verify_distributivity(3.0, 5.0, 7.0)
    assert ts.verify_distributivity(0.0, 1.0, -1.0)
    print("✓ Tropical distributivity verified")

    # 2. Bellman-Ford
    n = 5
    W = np.full((n, n), float('inf'))
    W[0][1] = 1.0; W[0][2] = 4.0; W[1][2] = 2.0; W[1][3] = 5.0
    W[2][3] = 1.0; W[3][4] = 3.0

    dist, pred, iters = tropical_bellman_ford(n, W, source=0)
    print(f"✓ Bellman-Ford: distances = {dist}, converged in {iters} iterations")

    path = reconstruct_path(pred, 0, 4)
    print(f"  Shortest path 0→4: {path}")

    # 3. Tropical matrix Kleene star
    star = tropical_kleene_star(W)
    print(f"✓ Kleene star computed, dist[0][4] = {star[0][4]}")

    # 4. Hex lattice
    for r in range(6):
        patch = HexLattice.patch(r)
        assert len(patch) == HexLattice.patch_card_formula(r)
        boundary = HexLattice.edge_boundary(patch)
        assert boundary == HexLattice.boundary_formula(r)
    print(f"✓ Hex patch formulas verified for r = 0..5")

    # 5. Kardashev bound
    L_sun = 3.846e26
    K_actual, K_bound = KardashevScale.bound(L_sun, 0.2, 0.9, 1.0)
    assert K_actual <= K_bound
    print(f"✓ Kardashev bound: K({0.9}) = {K_actual:.4f} ≤ K({1.0}) = {K_bound:.4f}")

    # 6. Tropical capacity
    cap, opt_v, dists = tropical_capacity(n, W, source=0)
    print(f"✓ Tropical capacity: C = {cap:.4f}, optimal vertex = {opt_v}")
