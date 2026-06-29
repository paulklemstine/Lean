#!/usr/bin/env python3
"""
Tropical One-Way Functions — Algorithms

Implements the core algorithms for tropical matrix powering, strict separation
analysis, orbit hash generation, and inversion attacks.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict

INF = float('inf')


def trop_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        A: n×n matrix with entries in ℝ ∪ {+∞}
        B: n×n matrix with entries in ℝ ∪ {+∞}

    Returns:
        n×n tropical product matrix
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, +∞ off diagonal."""
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


def trop_pow(G: np.ndarray, k: int) -> np.ndarray:
    """
    Tropical matrix power G^{⊗k} using repeated squaring.

    Time complexity: O(n³ log k)
    Space complexity: O(n²)

    Args:
        G: n×n adjacency matrix
        k: power (non-negative integer)

    Returns:
        G^{⊗k}: the k-th tropical power
    """
    n = G.shape[0]
    if k == 0:
        return trop_identity(n)
    if k == 1:
        return G.copy()

    # Repeated squaring
    result = trop_identity(n)
    base = G.copy()
    while k > 0:
        if k % 2 == 1:
            result = trop_mul(result, base)
        base = trop_mul(base, base)
        k //= 2
    return result


def find_all_midpoints(G: np.ndarray) -> Dict[Tuple[int, int], List[int]]:
    """
    Find all minimizing midpoints for each entry of G².

    For each (i,j), returns all k such that G²[i,j] = G[i,k] + G[k,j].

    Time complexity: O(n³)

    Returns:
        Dictionary mapping (i,j) to list of minimizing midpoints
    """
    n = G.shape[0]
    G2 = trop_mul(G, G)
    result = {}
    for i in range(n):
        for j in range(n):
            val = G2[i, j]
            midpoints = []
            for k in range(n):
                if abs(G[i, k] + G[k, j] - val) < 1e-10:
                    midpoints.append(k)
            result[(i, j)] = midpoints
    return result


def is_strictly_separated(G: np.ndarray) -> bool:
    """Check if every entry of G² has a unique minimizer."""
    midpoints = find_all_midpoints(G)
    return all(len(ms) == 1 for ms in midpoints.values())


def is_diag_separated(G: np.ndarray) -> bool:
    """Check if every diagonal entry G²(i,i) has unique minimizer i."""
    midpoints = find_all_midpoints(G)
    n = G.shape[0]
    return all(midpoints[(i, i)] == [i] for i in range(n))


def separation_gap(G: np.ndarray) -> float:
    """
    Compute the minimum separation gap across all entries of G².

    The gap for entry (i,j) is the difference between the second-best
    and best midpoint values. A positive gap means unique minimizer.

    Returns:
        Minimum gap across all entries (> 0 iff strictly separated)
    """
    n = G.shape[0]
    min_gap = INF
    for i in range(n):
        for j in range(n):
            values = sorted(G[i, k] + G[k, j] for k in range(n))
            if len(values) >= 2:
                gap = values[1] - values[0]
                min_gap = min(min_gap, gap)
    return min_gap


def orbit_hash(G: np.ndarray, exponents: List[int]) -> List[np.ndarray]:
    """
    Generate orbit hash sequence from iterated tropical powers.

    Args:
        G: Generator matrix
        exponents: List of powers to compute

    Returns:
        List of tropical powers [G^{k₁}, G^{k₂}, ...]
    """
    return [trop_pow(G, k) for k in exponents]


def generate_separated_instance(n: int, seed: int = 42) -> np.ndarray:
    """
    Generate a random strictly separated n×n tropical matrix.

    Strategy: use well-spaced integer entries to maximize
    the probability of unique minimizers.

    Args:
        n: matrix dimension
        seed: random seed

    Returns:
        n×n matrix that is strictly separated (with high probability)
    """
    rng = np.random.RandomState(seed)
    # Use prime-spaced entries to minimize ties
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    while True:
        G = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                # Use large spread to ensure separation
                G[i, j] = rng.randint(1, 100) * primes[rng.randint(0, min(n*n, len(primes)))]
        if is_strictly_separated(G):
            return G


def naive_inversion_attack(Y: np.ndarray, k: int) -> Optional[np.ndarray]:
    """
    Naive brute-force inversion: given Y = G^{⊗k}, try to recover G.

    This is intentionally inefficient (exponential in entry range)
    to illustrate the hardness of inversion.

    Only works for small matrices with small integer entries.

    Args:
        Y: Target matrix (purported k-th power)
        k: Known power

    Returns:
        G such that G^{⊗k} = Y, or None if not found
    """
    n = Y.shape[0]
    if n > 2 or k > 2:
        return None  # Too expensive

    # Try all possible 2x2 matrices with entries in range
    max_val = int(np.max(Y[Y < INF])) + 5 if np.any(Y < INF) else 10
    for a in range(max_val + 1):
        for b in range(max_val + 1):
            for c in range(max_val + 1):
                for d in range(max_val + 1):
                    G = np.array([[a, b], [c, d]], dtype=float)
                    if np.allclose(trop_pow(G, k), Y):
                        return G
    return None


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Tropical One-Way Function Algorithms")
    print("=" * 50)

    # Generate a separated instance
    G = np.array([[1, 3, 7],
                  [5, 2, 4],
                  [8, 6, 3]], dtype=float)

    print(f"\nGenerator G:\n{G}")
    print(f"\nStrictly separated: {is_strictly_separated(G)}")
    print(f"Diagonal separated: {is_diag_separated(G)}")
    print(f"Separation gap: {separation_gap(G)}")

    # Orbit hash
    exps = [2, 3, 5, 7, 11]
    orbit = orbit_hash(G, exps)
    print(f"\nOrbit hash with prime exponents {exps}:")
    for k, Gk in zip(exps, orbit):
        print(f"  G^{k} diagonal: {[Gk[i,i] for i in range(3)]}")

    # Naive inversion on small instance
    G2 = np.array([[1, 3], [5, 2]], dtype=float)
    Y2 = trop_pow(G2, 2)
    print(f"\n2×2 instance G:\n{G2}")
    print(f"G²:\n{Y2}")
    recovered = naive_inversion_attack(Y2, 2)
    if recovered is not None:
        print(f"Recovered G:\n{recovered}")
        print(f"Matches: {np.allclose(recovered, G2)}")
