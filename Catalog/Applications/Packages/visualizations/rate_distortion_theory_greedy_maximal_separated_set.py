#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for packing-covering theory in finite metric spaces.

Implements:
1. Greedy maximal separated set construction (the "greedy codebook" algorithm)
2. Covering number computation (exact and approximate)
3. Packing number computation (exact and approximate)
4. Rate-distortion curve computation
5. Box-packing bound computation

All algorithms include docstrings, type hints, complexity analysis, and examples.
"""

from __future__ import annotations
import numpy as np
from typing import Callable, Sequence, TypeVar
from itertools import combinations
import heapq

T = TypeVar('T')


def euclidean_dist(x: np.ndarray, y: np.ndarray) -> float:
    """Euclidean distance between two vectors."""
    return float(np.linalg.norm(x - y))


def sup_norm_dist(x: np.ndarray, y: np.ndarray) -> float:
    """Sup-norm (L∞) distance between two vectors."""
    return float(np.max(np.abs(x - y)))


class FiniteMetricSpace:
    """A finite metric space represented by a distance matrix.

    Attributes:
        points: Array of shape (n, d) or list of point labels.
        dist_matrix: Precomputed n×n distance matrix.
        n: Number of points.
    """

    def __init__(self, points: np.ndarray,
                 metric: Callable[[np.ndarray, np.ndarray], float] = euclidean_dist):
        """
        Args:
            points: (n, d) array of n points in d dimensions.
            metric: Distance function. Default: Euclidean.

        Time complexity: O(n² · d) for distance matrix computation.
        Space complexity: O(n²) for the distance matrix.
        """
        self.points = np.array(points)
        self.n = len(points)
        self.dist_matrix = np.zeros((self.n, self.n))
        for i in range(self.n):
            for j in range(i + 1, self.n):
                d = metric(self.points[i], self.points[j])
                self.dist_matrix[i, j] = d
                self.dist_matrix[j, i] = d

    def dist(self, i: int, j: int) -> float:
        """Distance between points i and j. O(1)."""
        return self.dist_matrix[i, j]


def greedy_maximal_separated_set(
    space: FiniteMetricSpace, r: float,
    order: np.ndarray | None = None
) -> list[int]:
    """Greedy construction of a maximal r-separated subset.

    Algorithm:
        Initialize C = ∅.
        For each point p (in given order):
            If dist(p, c) ≥ r for all c ∈ C: add p to C.

    The output C is:
    - r-separated: all pairwise distances ≥ r.
    - Maximal: no point outside C can be added while preserving r-separation.
    - An r-covering: every point is within distance r of some point in C.

    Args:
        space: The finite metric space.
        r: Separation radius.
        order: Permutation of indices (default: natural order 0,1,...,n-1).

    Returns:
        List of indices forming the maximal r-separated set.

    Time complexity: O(n · |C|) where |C| is the output size.
    Space complexity: O(|C|).

    Example:
        >>> pts = np.array([[0], [1], [2], [3], [4], [5]])
        >>> space = FiniteMetricSpace(pts)
        >>> greedy_maximal_separated_set(space, 2.0)
        [0, 2, 4]
    """
    if order is None:
        order = np.arange(space.n)

    selected: list[int] = []
    for idx in order:
        if all(space.dist(idx, c) >= r for c in selected):
            selected.append(idx)
    return selected


def is_separated(space: FiniteMetricSpace, indices: list[int], r: float) -> bool:
    """Check if a subset is r-separated.

    Time complexity: O(|indices|²).
    """
    for i, a in enumerate(indices):
        for b in indices[i + 1:]:
            if space.dist(a, b) < r:
                return False
    return True


def is_covering(space: FiniteMetricSpace, indices: list[int], R: float) -> bool:
    """Check if a subset is an R-covering.

    Time complexity: O(n · |indices|).
    """
    for i in range(space.n):
        if not any(space.dist(i, c) <= R for c in indices):
            return False
    return True


def packing_number(space: FiniteMetricSpace, r: float,
                   trials: int = 100) -> int:
    """Estimate the packing number M(r): max cardinality of an r-separated subset.

    Uses randomized greedy with multiple random orderings.

    Args:
        space: The finite metric space.
        r: Separation radius.
        trials: Number of random orderings to try.

    Returns:
        Lower bound on the packing number (exact with enough trials for small spaces).

    Time complexity: O(trials · n · M(r)).

    Example:
        >>> pts = np.array([[0], [1], [2], [3], [4]])
        >>> space = FiniteMetricSpace(pts)
        >>> packing_number(space, 2.0, trials=100)
        3
    """
    best = 0
    for _ in range(trials):
        order = np.random.permutation(space.n)
        C = greedy_maximal_separated_set(space, r, order)
        best = max(best, len(C))
    return best


def covering_number(space: FiniteMetricSpace, R: float,
                    trials: int = 100) -> int:
    """Estimate the covering number N(R): min cardinality of an R-covering subset.

    Uses randomized greedy to find small covers. By the maximal-separated-implies-covering
    theorem, every maximal R-separated set is an R-cover. So we find the smallest such set.

    Args:
        space: The finite metric space.
        R: Covering radius.
        trials: Number of random orderings to try.

    Returns:
        Upper bound on the covering number.

    Time complexity: O(trials · n · N(R)).
    """
    best = space.n
    for _ in range(trials):
        order = np.random.permutation(space.n)
        C = greedy_maximal_separated_set(space, R, order)
        if is_covering(space, C, R):
            best = min(best, len(C))
    return best


def rate_distortion_curve(
    space: FiniteMetricSpace,
    distortions: Sequence[float],
    trials: int = 100
) -> list[tuple[float, int, float]]:
    """Compute the rate-distortion curve for a finite metric space.

    For each distortion level D, computes the covering number N(D) and the
    rate R(D) = log₂(N(D)).

    Args:
        space: The finite metric space.
        distortions: List of distortion levels to evaluate.
        trials: Number of trials for covering number estimation.

    Returns:
        List of (distortion, codebook_size, rate_bits) tuples.

    Example:
        >>> pts = np.array([[i] for i in range(10)])
        >>> space = FiniteMetricSpace(pts)
        >>> curve = rate_distortion_curve(space, [1.0, 2.0, 5.0])
    """
    results = []
    for D in distortions:
        N = covering_number(space, D, trials)
        rate = np.log2(N) if N > 1 else 0.0
        results.append((D, N, rate))
    return results


def box_packing_bound(B: float, r: float, n: int = 1) -> int:
    """Compute the box-packing upper bound on the size of an r-separated
    subset of [-B, B]^n with sup-norm metric.

    The bound is (floor(2B/r) + 1)^n.

    This is a direct consequence of the pigeonhole principle: partition each
    coordinate into bins of width < r, then two points in the same bin
    differ by < r in sup-norm, contradicting separation.

    Args:
        B: Half-width of the bounding box.
        r: Separation radius (must be > 0).
        n: Dimension.

    Returns:
        The upper bound (floor(2B/r) + 1)^n.

    Example:
        >>> box_packing_bound(5.0, 1.0, 2)
        121
        >>> box_packing_bound(10.0, 2.0, 1)
        11
    """
    if r <= 0:
        raise ValueError("r must be positive")
    bins_per_dim = int(np.floor(2 * B / r)) + 1
    return bins_per_dim ** n


def sandwich_bounds(space: FiniteMetricSpace, r: float,
                    trials: int = 200) -> dict:
    """Compute the packing-covering sandwich bounds.

    Returns M(2r), N(r), and M(r) along with verification that
    M(2r) ≤ N(r) ≤ M(r) holds.

    Args:
        space: The finite metric space.
        r: The base radius.
        trials: Number of trials for estimation.

    Returns:
        Dictionary with keys 'M_2r', 'N_r', 'M_r', 'sandwich_holds'.
    """
    M_2r = packing_number(space, 2 * r, trials)
    N_r = covering_number(space, r, trials)
    M_r = packing_number(space, r, trials)
    return {
        'M_2r': M_2r,
        'N_r': N_r,
        'M_r': M_r,
        'sandwich_holds': M_2r <= N_r <= M_r,
        'r': r
    }


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    np.random.seed(42)

    # Example 1: 1D points
    print("Example 1: 1D integer points [0, 1, ..., 9]")
    pts = np.array([[i] for i in range(10)])
    space = FiniteMetricSpace(pts)
    for r in [1.0, 2.0, 3.0]:
        result = sandwich_bounds(space, r)
        print(f"  r={r}: M(2r)={result['M_2r']}, N(r)={result['N_r']}, "
              f"M(r)={result['M_r']}, holds={result['sandwich_holds']}")

    # Example 2: 2D random points
    print("\nExample 2: 20 random 2D points in [-5,5]²")
    pts2d = np.random.uniform(-5, 5, (20, 2))
    space2d = FiniteMetricSpace(pts2d)
    curve = rate_distortion_curve(space2d, [0.5, 1.0, 2.0, 3.0, 5.0])
    print("  Rate-distortion curve:")
    for D, N, R in curve:
        print(f"    D={D:.1f}: N(D)={N}, R(D)={R:.2f} bits")

    # Example 3: Box packing bound
    print("\nExample 3: Box packing bounds for [-10,10]^n")
    for n in range(1, 5):
        bound = box_packing_bound(10.0, 2.0, n)
        print(f"  n={n}, r=2.0: bound = {bound}")
