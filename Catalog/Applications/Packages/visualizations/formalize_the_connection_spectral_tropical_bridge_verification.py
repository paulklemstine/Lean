#!/usr/bin/env python3
"""
Tropical Complexity Transfer — Algorithms

Implements the core algorithms from the research paper:
1. Log-weight transform
2. Triangle cycle gap computation
3. Spectral-tropical bridge verification
4. Transport theorem bound computation
"""

import numpy as np
from typing import Tuple, List, Optional


def log_weight_transform(P: np.ndarray) -> np.ndarray:
    """
    Compute the log-weight transform W(i,j) = -log(P(i,j)).

    Converts a stochastic matrix (multiplicative probability transport)
    into a tropical weight matrix (additive cost geometry).

    Args:
        P: Positive matrix (all entries > 0).

    Returns:
        W: Log-weight matrix.

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    if np.any(P <= 0):
        raise ValueError("Matrix must have strictly positive entries")
    return -np.log(P)


def triangle_mean(W: np.ndarray, i: int, j: int, k: int) -> float:
    """
    Compute the mean weight of triangle cycle i → j → k → i.

    Args:
        W: Weight matrix.
        i, j, k: Vertex indices.

    Returns:
        (W[i,j] + W[j,k] + W[k,i]) / 3
    """
    return (W[i, j] + W[j, k] + W[k, i]) / 3.0


def triangle_cycle_gap(W: np.ndarray) -> float:
    """
    Compute the triangle cycle gap: minimum triangle mean over all triples.

    This is a tractable surrogate for the full tropical cycle gap
    (minimum over all cycle means), computable in O(n³) time.

    Args:
        W: Weight matrix of shape (n, n).

    Returns:
        Minimum triangle mean over all (i, j, k) triples.

    Time complexity: O(n³)
    Space complexity: O(1)
    """
    n = W.shape[0]
    gap = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = triangle_mean(W, i, j, k)
                gap = min(gap, mean)
    return gap


def spectral_gap_surrogate(P: np.ndarray) -> float:
    """
    Compute the spectral gap surrogate: 1 - max(P[i,j]).

    This is an elementary surrogate that does not require eigenvalue
    computation. It is positive iff no entry dominates (equals 1).

    Args:
        P: Matrix of shape (n, n).

    Returns:
        1 - max entry of P.

    Time complexity: O(n²)
    """
    return 1.0 - float(np.max(P))


def spectral_gap_exact(P: np.ndarray) -> float:
    """
    Compute the exact spectral gap: 1 - |λ₂|.

    Args:
        P: Square matrix.

    Returns:
        1 - second largest eigenvalue modulus.

    Time complexity: O(n³) via eigendecomposition.
    """
    eigenvalues = np.linalg.eigvals(P)
    mods = np.sort(np.abs(eigenvalues))[::-1]
    if len(mods) < 2:
        return 1.0
    return float(1.0 - mods[1])


def verify_spectral_tropical_bridge(
    P: np.ndarray,
    verbose: bool = True
) -> Tuple[float, float, bool]:
    """
    Verify the spectral-tropical bridge for a given matrix.

    Checks that:
    1. P is positive (all entries > 0)
    2. P is row-stochastic (rows sum to 1)
    3. The tropical cycle gap is positive
    4. The gap is ≥ -log(max entry)

    Args:
        P: Matrix to verify.
        verbose: Print detailed output.

    Returns:
        (gap, lower_bound, verified): cycle gap, predicted bound, verification status.

    Time complexity: O(n³)
    """
    n = P.shape[0]

    # Check positivity
    is_positive = bool(np.all(P > 0))

    # Check row-stochasticity
    row_sums = P.sum(axis=1)
    is_stochastic = bool(np.allclose(row_sums, 1.0))

    # Compute log-weight and cycle gap
    W = log_weight_transform(P)
    gap = triangle_cycle_gap(W)

    # Predicted lower bound
    max_e = float(np.max(P))
    lower_bound = -np.log(max_e) if max_e < 1.0 else 0.0

    # Verification
    verified = is_positive and is_stochastic and gap >= lower_bound - 1e-10

    if verbose:
        print(f"Matrix size: {n}×{n}")
        print(f"Positive:        {is_positive}")
        print(f"Row-stochastic:  {is_stochastic}")
        print(f"Max entry:       {max_e:.6f}")
        print(f"Spectral gap:    {spectral_gap_exact(P):.6f}")
        print(f"Cycle gap:       {gap:.6f}")
        print(f"Lower bound:     {lower_bound:.6f}")
        print(f"Verified:        {verified}")

    return gap, lower_bound, verified


def transport_bound(
    L: float,
    C: float,
    measure: str = "depth"
) -> float:
    """
    Compute the branching program lower bound from tropical cost.

    Given tropical cost lower bound L and simulation overhead C,
    returns L/C as the BP depth/size lower bound.

    Args:
        L: Tropical cost lower bound (must be real).
        C: Simulation overhead constant (must be > 0).
        measure: "depth" or "size".

    Returns:
        L / C

    Raises:
        ValueError if C ≤ 0.
    """
    if C <= 0:
        raise ValueError(f"Simulation overhead C must be positive, got {C}")
    return L / C


def direct_sum_bound(
    lower_bounds: List[float],
    C: float
) -> float:
    """
    Compute the direct-sum branching program lower bound.

    For independent functions with tropical cost lower bounds L₁, ..., Lₖ,
    the product function has BP depth ≥ (L₁ + ... + Lₖ) / C.

    Args:
        lower_bounds: List of individual tropical cost lower bounds.
        C: Simulation overhead constant (must be > 0).

    Returns:
        sum(lower_bounds) / C
    """
    if C <= 0:
        raise ValueError(f"Simulation overhead C must be positive, got {C}")
    return sum(lower_bounds) / C


def find_minimizing_triple(W: np.ndarray) -> Tuple[int, int, int, float]:
    """
    Find the triple (i, j, k) achieving the minimum triangle mean.

    Args:
        W: Weight matrix.

    Returns:
        (i, j, k, mean): minimizing triple and its mean.

    Time complexity: O(n³)
    """
    n = W.shape[0]
    best_i, best_j, best_k = 0, 0, 0
    best_mean = float('inf')
    for i in range(n):
        for j in range(n):
            for k in range(n):
                mean = triangle_mean(W, i, j, k)
                if mean < best_mean:
                    best_mean = mean
                    best_i, best_j, best_k = i, j, k
    return best_i, best_j, best_k, best_mean


if __name__ == "__main__":
    print("Tropical Complexity Transfer — Algorithm Tests")
    print("=" * 50)

    # Test 1: Log-weight transform
    P = np.array([[0.5, 0.5], [0.3, 0.7]])
    W = log_weight_transform(P)
    print(f"\nP = \n{P}")
    print(f"W = -log(P) = \n{W}")

    # Test 2: Triangle cycle gap
    gap = triangle_cycle_gap(W)
    print(f"\nTriangle cycle gap: {gap:.6f}")

    # Test 3: Bridge verification
    print("\n--- Bridge Verification ---")
    P3 = np.array([[0.4, 0.3, 0.3],
                    [0.2, 0.5, 0.3],
                    [0.3, 0.3, 0.4]])
    verify_spectral_tropical_bridge(P3)

    # Test 4: Transport bounds
    print("\n--- Transport Bounds ---")
    for n in [4, 8, 16]:
        bound = transport_bound(float(n), 1.0)
        print(f"AND({n}): BP depth ≥ {bound:.0f}")

    # Test 5: Direct sum
    print("\n--- Direct Sum ---")
    bounds = [5.0, 8.0, 3.0]
    ds = direct_sum_bound(bounds, 2.0)
    print(f"Bounds {bounds}, C=2: Product BP depth ≥ {ds:.1f}")
