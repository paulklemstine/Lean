#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Algorithms

Complete implementations of the key algorithms from the research,
including tropical matrix operations, path enumeration, and
min-plus permanent computation.
"""

import numpy as np
from itertools import permutations
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


# =============================================================================
# Core Data Structures
# =============================================================================

@dataclass
class LayeredCircuitMatrix:
    """A layered circuit matrix: weighted adjacency matrix of a DAG.

    The matrix M is n×n over ℕ, with M[i,j] > 0 indicating a directed
    edge from gate i to gate j with weight M[i,j]. The layered condition
    requires all edges to go from smaller to larger indices (i < j).

    Attributes:
        matrix: The n×n weight matrix
        n: Dimension

    Invariant: M[i,j] > 0 implies i < j (strictly upper triangular support)
    """
    matrix: np.ndarray
    n: int

    def __post_init__(self):
        assert self.matrix.shape == (self.n, self.n)
        for i in range(self.n):
            for j in range(self.n):
                if self.matrix[i, j] > 0:
                    assert i < j, f"Layered violation: M[{i},{j}] = {self.matrix[i,j]} > 0 but {i} >= {j}"


@dataclass
class Path:
    """A path in the support graph of a matrix.

    Attributes:
        vertices: List of vertex indices
        edges: Number of edges (= len(vertices) - 1)
        cost: Total edge weight cost
    """
    vertices: List[int]
    edges: int
    cost: int


# =============================================================================
# Algorithm 1: Layered Matrix Construction
# =============================================================================

def build_layered_matrix(n: int, weight_fn=None) -> LayeredCircuitMatrix:
    """Build a layered circuit matrix with given weight function.

    Args:
        n: Matrix dimension
        weight_fn: Function (i, j) -> weight for i < j. Default: j - i.

    Returns:
        A LayeredCircuitMatrix instance.

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    if weight_fn is None:
        weight_fn = lambda i, j: j - i

    M = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            w = weight_fn(i, j)
            if w > 0:
                M[i, j] = w

    return LayeredCircuitMatrix(matrix=M, n=n)


# =============================================================================
# Algorithm 2: Depth Computation via Dynamic Programming
# =============================================================================

def compute_depth(M: np.ndarray) -> Tuple[int, List[int]]:
    """Compute the depth (longest path) of a DAG encoded by matrix M.

    Uses dynamic programming on the topological order (which for
    strictly upper triangular matrices is simply 0, 1, ..., n-1).

    Args:
        M: n×n weight matrix (strictly upper triangular support)

    Returns:
        (depth, longest_path) where depth is the number of edges
        in the longest path and longest_path is the path achieving it.

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = M.shape[0]
    # dp[j] = length of longest path ending at vertex j
    dp = [0] * n
    # pred[j] = predecessor of j on the longest path
    pred = [-1] * n

    for j in range(n):
        for i in range(j):
            if M[i, j] > 0 and dp[i] + 1 > dp[j]:
                dp[j] = dp[i] + 1
                pred[j] = i

    # Find the vertex with maximum dp value
    depth = max(dp) if n > 0 else 0
    end = dp.index(depth) if depth > 0 else 0

    # Reconstruct path
    path = []
    v = end
    while v != -1:
        path.append(v)
        v = pred[v]
    path.reverse()

    return depth, path


# =============================================================================
# Algorithm 3: All Admissible Paths Enumeration
# =============================================================================

def enumerate_paths(M: np.ndarray, min_length: int = 2) -> List[Path]:
    """Enumerate all admissible paths in the support graph.

    Args:
        M: n×n weight matrix
        min_length: Minimum path length (number of vertices)

    Returns:
        List of all admissible paths with at least min_length vertices.

    Time complexity: O(n · 2^n) worst case (exponential in n)
    Space complexity: O(n · 2^n)

    Warning: Only practical for small n (≤ 20).
    """
    n = M.shape[0]
    paths = []

    def dfs(current: int, path: List[int], cost: int):
        if len(path) >= min_length:
            paths.append(Path(
                vertices=path[:],
                edges=len(path) - 1,
                cost=cost
            ))
        for j in range(n):
            if M[current, j] > 0:
                dfs(j, path + [j], cost + M[current, j])

    for start in range(n):
        dfs(start, [start], 0)

    return paths


# =============================================================================
# Algorithm 4: Min-Plus Permanent (Exact)
# =============================================================================

def min_plus_permanent_exact(M: np.ndarray) -> Tuple[int, Tuple[int, ...]]:
    """Compute the exact min-plus permanent by brute force.

    The min-plus permanent is: min_σ Σᵢ M[i, σ(i)]

    Args:
        M: n×n weight matrix

    Returns:
        (permanent_value, optimal_permutation)

    Time complexity: O(n! · n)
    Space complexity: O(n)

    Warning: Only practical for n ≤ 10.
    """
    n = M.shape[0]
    best_cost = float('inf')
    best_perm = None

    for perm in permutations(range(n)):
        cost = sum(int(M[i, perm[i]]) for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm

    return int(best_cost), best_perm


# =============================================================================
# Algorithm 5: Min-Plus Permanent (Hungarian Algorithm)
# =============================================================================

def min_plus_permanent_hungarian(M: np.ndarray) -> Tuple[int, List[int]]:
    """Compute the min-plus permanent using the Hungarian algorithm.

    This is the standard O(n³) algorithm for the assignment problem,
    which is equivalent to computing the min-plus permanent.

    Args:
        M: n×n cost matrix (non-negative integers)

    Returns:
        (permanent_value, assignment) where assignment[i] = σ(i)

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = M.shape[0]
    if n == 0:
        return 0, []

    # Use the Kuhn-Munkres (Hungarian) algorithm
    INF = float('inf')
    cost = M.astype(float).copy()

    u = np.zeros(n + 1)  # potential for rows
    v = np.zeros(n + 1)  # potential for cols
    p = np.zeros(n + 1, dtype=int)  # assignment
    way = np.zeros(n + 1, dtype=int)

    for i in range(1, n + 1):
        p[0] = i
        j0 = 0
        minv = np.full(n + 1, INF)
        used = np.zeros(n + 1, dtype=bool)

        while True:
            used[j0] = True
            i0 = p[j0]
            delta = INF
            j1 = -1

            for j in range(1, n + 1):
                if not used[j]:
                    cur = cost[i0 - 1, j - 1] - u[i0] - v[j]
                    if cur < minv[j]:
                        minv[j] = cur
                        way[j] = j0
                    if minv[j] < delta:
                        delta = minv[j]
                        j1 = j

            for j in range(n + 1):
                if used[j]:
                    u[p[j]] += delta
                    v[j] -= delta
                else:
                    minv[j] -= delta

            j0 = j1
            if p[j0] == 0:
                break

        while j0 != 0:
            p[j0] = p[way[j0]]
            j0 = way[j0]

    assignment = [0] * n
    for j in range(1, n + 1):
        assignment[p[j] - 1] = j - 1

    total_cost = sum(int(M[i, assignment[i]]) for i in range(n))
    return total_cost, assignment


# =============================================================================
# Algorithm 6: Tropical Spectral Gap Computation
# =============================================================================

def tropical_spectral_gap(M: np.ndarray) -> dict:
    """Compute tropical spectral gap invariants.

    Returns a dictionary with:
    - min_offdiag: minimum off-diagonal positive entry
    - min_diag: minimum diagonal entry
    - gap: min_offdiag - min_diag (the tropical spectral gap)
    - max_entry: maximum entry
    - weight_ratio: max_entry / min_offdiag (if defined)

    Time complexity: O(n²)
    Space complexity: O(1)
    """
    n = M.shape[0]

    diag = [M[i, i] for i in range(n)]
    offdiag_pos = [M[i, j] for i in range(n) for j in range(n) if i != j and M[i, j] > 0]

    result = {
        'min_diag': min(diag) if diag else None,
        'max_diag': max(diag) if diag else None,
        'min_offdiag': min(offdiag_pos) if offdiag_pos else None,
        'max_entry': int(M.max()),
        'gap': None,
        'weight_ratio': None,
    }

    if result['min_offdiag'] is not None and result['min_diag'] is not None:
        result['gap'] = result['min_offdiag'] - result['min_diag']

    if result['min_offdiag'] is not None and result['min_offdiag'] > 0:
        result['weight_ratio'] = result['max_entry'] / result['min_offdiag']

    return result


# =============================================================================
# Algorithm 7: Depth-Cost Tradeoff Analysis
# =============================================================================

def depth_cost_tradeoff(M: np.ndarray) -> dict:
    """Analyze the depth-cost tradeoff for a matrix.

    Computes all relevant invariants and verifies the bridge theorems.

    Args:
        M: n×n weight matrix (strictly upper triangular support expected)

    Returns:
        Dictionary with analysis results.

    Time complexity: O(n² + n! · n) — dominated by permanent computation for small n
    """
    n = M.shape[0]

    depth, longest_path = compute_depth(M)
    paths = enumerate_paths(M) if n <= 15 else []

    min_w = None
    max_w = int(M.max())
    positive = M[M > 0]
    if len(positive) > 0:
        min_w = int(positive.min())

    # Min-plus permanent
    if n <= 10:
        perm_val, perm_opt = min_plus_permanent_exact(M)
    else:
        perm_val, perm_opt = min_plus_permanent_hungarian(M)

    trace = sum(int(M[i, i]) for i in range(n))

    # Verify theorems
    results = {
        'n': n,
        'depth': depth,
        'longest_path': longest_path,
        'min_edge_weight': min_w,
        'max_edge_weight': max_w,
        'min_plus_permanent': perm_val,
        'trace': trace,
        'num_paths': len(paths),
        'spectral_gap': tropical_spectral_gap(M),
        'theorems_verified': {},
    }

    # Verify: depth ≤ n - 1
    results['theorems_verified']['depth_le_n_minus_1'] = depth <= n - 1

    # Verify: minPlusPerm ≤ trace
    results['theorems_verified']['perm_le_trace'] = perm_val <= trace

    # Verify: minPlusPerm ≤ n × max_entry
    results['theorems_verified']['perm_le_n_mul_max'] = perm_val <= n * max_w

    # Verify path cost bounds
    if paths and min_w is not None:
        all_cost_lower = all(
            min_w * p.edges <= p.cost for p in paths
        )
        all_cost_upper = all(
            p.cost <= max_w * p.edges for p in paths
        )
        results['theorems_verified']['path_cost_lower_bound'] = all_cost_lower
        results['theorems_verified']['path_cost_upper_bound'] = all_cost_upper

    return results


# =============================================================================
# Main: Run all algorithms on example matrices
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL CIRCUIT LOWER BOUNDS — ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Example 1: Small layered matrix
    print("\n--- Example 1: 5×5 Layered Matrix ---")
    lcm = build_layered_matrix(5, weight_fn=lambda i, j: 2 * (j - i) + 1)
    print(f"Matrix:\n{lcm.matrix}")
    results = depth_cost_tradeoff(lcm.matrix)
    print(f"Depth: {results['depth']}")
    print(f"Longest path: {results['longest_path']}")
    print(f"Min-plus permanent: {results['min_plus_permanent']}")
    print(f"Trace: {results['trace']}")
    print(f"Spectral gap: {results['spectral_gap']}")
    print(f"Theorems verified: {results['theorems_verified']}")

    # Example 2: Dense non-layered matrix
    print("\n--- Example 2: 4×4 Non-Layered Matrix ---")
    M2 = np.array([
        [3, 1, 5, 2],
        [4, 2, 1, 6],
        [2, 3, 4, 1],
        [5, 2, 3, 3]
    ])
    print(f"Matrix:\n{M2}")
    perm_val, perm_opt = min_plus_permanent_exact(M2)
    print(f"Min-plus permanent: {perm_val} (permutation: {perm_opt})")
    perm_h, perm_ha = min_plus_permanent_hungarian(M2)
    print(f"Hungarian algorithm: {perm_h} (assignment: {perm_ha})")
    assert perm_val == perm_h, "Hungarian and brute force disagree!"
    print("✓ Hungarian algorithm matches brute force")

    # Example 3: Family with growing weights
    print("\n--- Example 3: Family with Growing Minimum Weight ---")
    for k in range(1, 6):
        n = 5
        lcm_k = build_layered_matrix(n, weight_fn=lambda i, j, k=k: k * (j - i))
        res = depth_cost_tradeoff(lcm_k.matrix)
        print(f"  k={k}: depth={res['depth']}, min_w={res['min_edge_weight']}, "
              f"perm={res['min_plus_permanent']}, "
              f"all_verified={all(res['theorems_verified'].values())}")

    print("\n✓ All algorithms completed successfully")
