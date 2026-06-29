#!/usr/bin/env python3
"""
Tropical Circuit Lower Bounds — Algorithms

Implements the core algorithms from the tropical circuit complexity framework.
Each algorithm computes a tropical invariant that yields circuit depth lower bounds.
"""

import numpy as np
from itertools import permutations
from typing import Tuple, List, Optional


def tropical_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus (tropical) matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n matrix with entries in ℝ ∪ {∞}
        B: n×n matrix with entries in ℝ ∪ {∞}

    Returns:
        The tropical product A ⊗ B
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def tropical_pow(M: np.ndarray, k: int) -> np.ndarray:
    """
    Tropical matrix power: M^⊗(k+1).

    Encodes minimum-cost walks of exactly k+1 edges.
    tropPow M 0 = M (one copy, one edge per walk)

    Time complexity: O(k × n³)
    Space complexity: O(n²)

    Args:
        M: n×n weight matrix
        k: power index (result uses k+1 copies of M)

    Returns:
        The (k+1)-fold tropical product of M
    """
    result = M.copy()
    for _ in range(k):
        result = tropical_mul(result, M)
    return result


def tropical_perm(M: np.ndarray) -> Tuple[float, Optional[tuple]]:
    """
    Tropical permanent: min over all permutations σ of Σ_i M[i, σ(i)].

    This is equivalent to the minimum weight perfect matching in the
    complete bipartite graph with weight matrix M.

    Time complexity: O(n! × n) — exact computation via enumeration
    Space complexity: O(n)

    For n > 10, use the Hungarian algorithm (O(n³)) instead.

    Args:
        M: n×n weight matrix

    Returns:
        (permanent_value, optimal_permutation)
    """
    n = M.shape[0]
    best_cost = np.inf
    best_perm = None
    for perm in permutations(range(n)):
        cost = sum(M[i, perm[i]] for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = perm
    return best_cost, best_perm


def tropical_chain_product(layers: List[np.ndarray]) -> np.ndarray:
    """
    Sequential tropical product of a list of (possibly different) matrices.

    layers = [L₀, L₁, ..., L_d] → L₀ ⊗ L₁ ⊗ ... ⊗ L_d

    Time complexity: O(d × n³)
    Space complexity: O(n²)

    Args:
        layers: list of n×n matrices

    Returns:
        The tropical product of all layers
    """
    result = layers[0].copy()
    for L in layers[1:]:
        result = tropical_mul(result, L)
    return result


def depth_lower_bound_from_perm(M: np.ndarray, W: float) -> int:
    """
    Compute circuit depth lower bound from tropical permanent.

    Uses Theorem B: tropPerm(M) ≤ n × (d+1) × W
    Hence: d+1 ≥ tropPerm(M) / (n × W)
    So: d ≥ ⌈tropPerm(M) / (n × W)⌉ - 1

    Args:
        M: n×n weight matrix (the target)
        W: weight cap per layer

    Returns:
        Lower bound on circuit depth d
    """
    n = M.shape[0]
    perm_val, _ = tropical_perm(M)
    if W <= 0 or n <= 0:
        return 0
    d_plus_1 = int(np.ceil(perm_val / (n * W)))
    return max(0, d_plus_1 - 1)


def depth_lower_bound_from_spectral_gap(M: np.ndarray, B: float) -> int:
    """
    Compute circuit depth lower bound from spectral gap.

    Uses the spectral gap theorem: if minEntry(M) = w > 0,
    then any walk of d+1 edges has cost ≥ (d+1) × w.
    If cost ≤ B, then d+1 ≤ B/w + 1, so d ≤ B/w.

    Args:
        M: n×n weight matrix
        B: target cost budget

    Returns:
        Lower bound on minimum edges needed, minus 1
    """
    w = np.min(M)
    if w <= 0:
        return 0
    return int(np.floor(B / w))


def verify_entry_bound(M: np.ndarray, max_k: int = 10) -> List[dict]:
    """
    Verify the entry bound theorem: tropPow M k ≤ (k+1) × maxEntry(M).

    Args:
        M: n×n weight matrix
        max_k: maximum power to check

    Returns:
        List of verification results
    """
    W = np.max(M)
    results = []
    for k in range(max_k):
        Mk = tropical_pow(M, k)
        actual_max = np.max(Mk)
        bound = (k + 1) * W
        results.append({
            'k': k,
            'edges': k + 1,
            'actual_max': actual_max,
            'bound': bound,
            'holds': actual_max <= bound + 1e-10
        })
    return results


def verify_minentry_growth(M: np.ndarray, max_k: int = 10) -> List[dict]:
    """
    Verify the minEntry growth theorem: tropPow M k ≥ (k+1) × minEntry(M).

    Args:
        M: n×n weight matrix
        max_k: maximum power to check

    Returns:
        List of verification results
    """
    w = np.min(M)
    results = []
    for k in range(max_k):
        Mk = tropical_pow(M, k)
        actual_min = np.min(Mk)
        bound = (k + 1) * w
        results.append({
            'k': k,
            'edges': k + 1,
            'actual_min': actual_min,
            'bound': bound,
            'holds': actual_min >= bound - 1e-10
        })
    return results


def find_optimal_walks(M: np.ndarray, k: int, i: int, j: int) -> List[Tuple[list, float]]:
    """
    Find all minimum-cost walks of exactly k+1 edges from i to j.

    Uses dynamic programming / backtracking.

    Time complexity: O(n^(k+1)) in the worst case
    Space complexity: O(n × k)

    Args:
        M: n×n weight matrix
        k: power index (walk uses k+1 edges)
        i, j: start and end vertices

    Returns:
        List of (walk, cost) pairs achieving the minimum
    """
    n = M.shape[0]
    Mk = tropical_pow(M, k)
    target = Mk[i, j]

    optimal = []

    def backtrack(pos: int, path: list, cost: float, edges_left: int):
        if edges_left == 0:
            if pos == j and abs(cost - target) < 1e-10:
                optimal.append((list(path), cost))
            return
        for next_v in range(n):
            new_cost = cost + M[pos, next_v]
            if new_cost <= target + 1e-10:  # pruning
                path.append(next_v)
                backtrack(next_v, path, new_cost, edges_left - 1)
                path.pop()

    backtrack(i, [i], 0.0, k + 1)
    return optimal


# Example usage
if __name__ == "__main__":
    print("Tropical Circuit Lower Bounds — Algorithm Examples\n")

    M = np.array([[5, 3], [4, 6]], dtype=float)
    print(f"Matrix: {M.tolist()}")
    print(f"Tropical permanent: {tropical_perm(M)}")
    print(f"Depth bound (W=1): d ≥ {depth_lower_bound_from_perm(M, 1)}")
    print(f"Depth bound (W=3): d ≥ {depth_lower_bound_from_perm(M, 3)}")

    print("\nEntry bound verification:")
    for r in verify_entry_bound(M, 5):
        print(f"  k={r['k']}: max={r['actual_max']:.0f} ≤ {r['bound']:.0f} {'✓' if r['holds'] else '✗'}")

    print("\nMinEntry growth verification:")
    for r in verify_minentry_growth(M, 5):
        print(f"  k={r['k']}: min={r['actual_min']:.0f} ≥ {r['bound']:.0f} {'✓' if r['holds'] else '✗'}")
