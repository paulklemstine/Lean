#!/usr/bin/env python3
"""
Tropical Information Theory — Algorithms

Complete implementations of core algorithms with docstrings,
type hints, complexity analysis, and example usage.
"""

from __future__ import annotations
import numpy as np
from typing import Optional


def postprocess(K: np.ndarray, g: np.ndarray) -> np.ndarray:
    """
    Post-process a tropical channel by a deterministic map.

    Given a channel matrix K : X → Y → ℝ (shape m×n) and a deterministic
    map g : Y → Z (array of length n with values in {0,...,k-1}),
    compute the pushed channel (K ▷ g) : X → Z → ℝ defined by:

        (K ▷ g)(x, z) = max { K(x, y) : g(y) = z }

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix with real-valued weights.
    g : np.ndarray, shape (n,), dtype int
        Deterministic surjective map from outputs Y to coarsened outputs Z.

    Returns
    -------
    np.ndarray, shape (m, k)
        Post-processed channel matrix, where k = max(g) + 1.

    Complexity
    ----------
    Time:  O(m * n)
    Space: O(m * k)

    Examples
    --------
    >>> K = np.array([[5., 2., 8.], [3., 7., 4.]])
    >>> g = np.array([0, 1, 0])
    >>> postprocess(K, g)
    array([[8., 2.],
           [4., 7.]])
    """
    m, n = K.shape
    k = int(g.max()) + 1
    result = np.full((m, k), -np.inf)
    for y in range(n):
        z = g[y]
        result[:, z] = np.maximum(result[:, z], K[:, y])
    return result


def tropical_one_sided_sep(K: np.ndarray, x1: int, x2: int) -> float:
    """
    One-sided tropical separation between two inputs.

    Computes φ_K(x1, x2) = max_y (K(x1, y) - K(x2, y)).

    This measures the maximum advantage of input x1 over x2
    across all outputs. It is the key building block for
    tropical distinguishability.

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix.
    x1, x2 : int
        Input indices.

    Returns
    -------
    float
        The one-sided separation value.

    Complexity
    ----------
    Time:  O(n)
    Space: O(1)
    """
    return float(np.max(K[x1] - K[x2]))


def tropical_dist(K: np.ndarray, x1: int, x2: int) -> float:
    """
    Tropical distinguishability between two inputs through a channel.

    Computes δ_K(x1, x2) = φ_K(x1, x2) + φ_K(x2, x1), where
    φ_K(a, b) = max_y (K(a, y) - K(b, y)).

    Properties:
    - δ_K(x, x) = 0 (self-distance is zero)
    - δ_K(x1, x2) = δ_K(x2, x1) (symmetric)
    - δ_K(x1, x2) ≥ 0 (non-negative)
    - δ_{K▷g}(x1, x2) ≤ δ_K(x1, x2) for surjective g (contraction)

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix.
    x1, x2 : int
        Input indices.

    Returns
    -------
    float
        The tropical distinguishability value.

    Complexity
    ----------
    Time:  O(n)
    Space: O(1)
    """
    return (tropical_one_sided_sep(K, x1, x2) +
            tropical_one_sided_sep(K, x2, x1))


def tropical_mutual_information(K: np.ndarray) -> float:
    """
    Tropical mutual information of a channel.

    Computes TMI(K) = max_{x1, x2} δ_K(x1, x2), the maximum
    pairwise tropical distinguishability across all input pairs.

    Key properties (all formally verified):
    - TMI(K) ≥ 0
    - TMI(K ▷ g) ≤ TMI(K) for surjective g (data processing inequality)
    - TMI(K₁ ⊗ K₂) = TMI(K₁) + TMI(K₂) (tensor additivity)

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix.

    Returns
    -------
    float
        The tropical mutual information value.

    Complexity
    ----------
    Time:  O(m² * n)
    Space: O(1)
    """
    m = K.shape[0]
    max_dist = 0.0
    for x1 in range(m):
        for x2 in range(m):
            max_dist = max(max_dist, tropical_dist(K, x1, x2))
    return max_dist


def tropical_dist_matrix(K: np.ndarray) -> np.ndarray:
    """
    Compute the full pairwise tropical distinguishability matrix.

    Returns the m×m matrix D where D[i,j] = δ_K(i, j).

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix.

    Returns
    -------
    np.ndarray, shape (m, m)
        Symmetric non-negative matrix of tropical distances.

    Complexity
    ----------
    Time:  O(m² * n)
    Space: O(m²)
    """
    m = K.shape[0]
    D = np.zeros((m, m))
    for i in range(m):
        for j in range(m):
            D[i, j] = tropical_dist(K, i, j)
    return D


def tensor_channel(K1: np.ndarray, K2: np.ndarray) -> np.ndarray:
    """
    Tropical tensor product of two channels.

    Computes (K₁ ⊗ K₂)((x1,x2), (y1,y2)) = K₁(x1,y1) + K₂(x2,y2).

    The product channel represents independent parallel use of both channels
    in the max-plus algebra (where + plays the role of ×).

    Parameters
    ----------
    K1 : np.ndarray, shape (m1, n1)
    K2 : np.ndarray, shape (m2, n2)

    Returns
    -------
    np.ndarray, shape (m1*m2, n1*n2)
        Tensor product channel.

    Complexity
    ----------
    Time:  O(m1 * m2 * n1 * n2)
    Space: O(m1 * m2 * n1 * n2)
    """
    m1, n1 = K1.shape
    m2, n2 = K2.shape
    result = np.zeros((m1 * m2, n1 * n2))
    for x1 in range(m1):
        for x2 in range(m2):
            for y1 in range(n1):
                for y2 in range(n2):
                    result[x1 * m2 + x2, y1 * n2 + y2] = K1[x1, y1] + K2[x2, y2]
    return result


def optimal_coarsening(K: np.ndarray, target_outputs: int,
                       n_trials: int = 1000) -> tuple[np.ndarray, float]:
    """
    Find the coarsening map that preserves the most TMI.

    Searches over random surjective maps g : {0,...,n-1} → {0,...,k-1}
    to find the one that maximizes TMI(K ▷ g).

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix.
    target_outputs : int
        Desired number of output categories (k).
    n_trials : int
        Number of random maps to try.

    Returns
    -------
    best_g : np.ndarray
        The best surjective map found.
    best_tmi : float
        The TMI of the best post-processed channel.

    Complexity
    ----------
    Time:  O(n_trials * m² * n)
    Space: O(m * k)
    """
    n = K.shape[1]
    k = target_outputs
    best_g = None
    best_tmi = -np.inf

    for _ in range(n_trials):
        # Generate random surjective map
        g = np.random.randint(0, k, size=n)
        # Ensure surjectivity
        perm = np.random.permutation(n)
        for i in range(min(k, n)):
            g[perm[i]] = i % k

        K_post = postprocess(K, g)
        tmi = tropical_mutual_information(K_post)
        if tmi > best_tmi:
            best_tmi = tmi
            best_g = g.copy()

    return best_g, best_tmi


def tropical_channel_rank(K: np.ndarray, tol: float = 1e-10) -> int:
    """
    Compute the tropical rank of a channel: the number of
    tropically distinguishable input classes.

    Two inputs x1, x2 are tropically indistinguishable if
    δ_K(x1, x2) < tol. The tropical rank is the number of
    equivalence classes.

    Parameters
    ----------
    K : np.ndarray, shape (m, n)
        Channel matrix.
    tol : float
        Tolerance for distinguishability.

    Returns
    -------
    int
        Number of distinguishable input classes.

    Complexity
    ----------
    Time:  O(m² * n)
    Space: O(m²)
    """
    m = K.shape[0]
    D = tropical_dist_matrix(K)

    # Union-find for equivalence classes
    parent = list(range(m))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for i in range(m):
        for j in range(i + 1, m):
            if D[i, j] < tol:
                union(i, j)

    return len(set(find(i) for i in range(m)))


if __name__ == "__main__":
    print("=== Tropical Information Theory Algorithms ===\n")

    # Example 1: Basic channel
    K = np.array([[5., 2., 8., 1.],
                  [3., 7., 4., 6.],
                  [1., 9., 2., 5.]])

    print(f"Channel K:\n{K}\n")
    print(f"TMI(K) = {tropical_mutual_information(K):.4f}")
    print(f"Distance matrix:\n{tropical_dist_matrix(K)}\n")
    print(f"Tropical rank: {tropical_channel_rank(K)}")

    # Example 2: Post-processing
    g = np.array([0, 1, 0, 1])
    K_post = postprocess(K, g)
    print(f"\nPost-processed (g={g}):\n{K_post}")
    print(f"TMI(K▷g) = {tropical_mutual_information(K_post):.4f}")

    # Example 3: Optimal coarsening
    best_g, best_tmi = optimal_coarsening(K, target_outputs=2, n_trials=100)
    print(f"\nBest 2-output coarsening: g={best_g}")
    print(f"TMI of best coarsening: {best_tmi:.4f}")

    # Example 4: Tensor product
    K1 = np.array([[3., 1.], [0., 4.]])
    K2 = np.array([[2., 5.], [6., 1.]])
    Kt = tensor_channel(K1, K2)
    print(f"\nTensor: TMI(K1)={tropical_mutual_information(K1):.4f}, "
          f"TMI(K2)={tropical_mutual_information(K2):.4f}, "
          f"TMI(K1⊗K2)={tropical_mutual_information(Kt):.4f}")
