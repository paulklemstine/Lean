#!/usr/bin/env python3
"""
Algorithms for Tropical Semantic Compression

Implements the core algorithms from the research paper:
1. Tropical Fisher seminorm computation
2. Optimal recentering (half-range algorithm)
3. Nearest semantic code search
4. Greedy semantic codebook construction
5. Tropical projection via pointwise infimum
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


# =============================================================================
# Algorithm 1: Tropical Fisher Seminorm
# =============================================================================

def tropical_fisher_seminorm(v: np.ndarray) -> float:
    """
    Compute the tropical Fisher seminorm of a vector.

    Algorithm: O(n) time, O(1) space.
      ||v||_TF = max(v) - min(v)

    Args:
        v: Score vector of shape (n,).

    Returns:
        The oscillation (range) of v.

    Example:
        >>> tropical_fisher_seminorm(np.array([3.0, 1.0, 5.0, 2.0]))
        4.0
    """
    return float(np.max(v) - np.min(v))


def tropical_fisher_dist(s: np.ndarray, c: np.ndarray) -> float:
    """
    Compute the tropical Fisher distance between two score vectors.

    Algorithm: O(n) time, O(n) space (for the difference).

    This is the gauge-invariant projective distance:
      d_TF(s, c) = ||s - c||_TF = max(s-c) - min(s-c)

    Args:
        s: Source score vector of shape (n,).
        c: Code score vector of shape (n,).

    Returns:
        The tropical Fisher distance.
    """
    diff = s - c
    return float(np.max(diff) - np.min(diff))


# =============================================================================
# Algorithm 2: Optimal Recentering (Half-Range)
# =============================================================================

@dataclass
class RecenteringResult:
    """Result of the optimal recentering algorithm."""
    optimal_shift: float
    min_max_deviation: float
    seminorm: float


def optimal_recentering(v: np.ndarray) -> RecenteringResult:
    """
    Find the optimal additive shift minimizing max absolute deviation.

    Algorithm: O(n) time, O(1) space.
      k* = (max(v) + min(v)) / 2
      min_k max_i |v_i - k| = (max(v) - min(v)) / 2

    This implements the half-range theorem:
      inf_k sup_i |v_i - k| = ||v||_TF / 2

    Args:
        v: Score vector of shape (n,).

    Returns:
        RecenteringResult with optimal shift and achieved distortion.

    Example:
        >>> r = optimal_recentering(np.array([1.0, 5.0, 3.0]))
        >>> r.optimal_shift  # (5 + 1) / 2 = 3.0
        3.0
        >>> r.min_max_deviation  # (5 - 1) / 2 = 2.0
        2.0
    """
    M = float(np.max(v))
    m = float(np.min(v))
    k_star = (M + m) / 2
    half_range = (M - m) / 2

    return RecenteringResult(
        optimal_shift=k_star,
        min_max_deviation=half_range,
        seminorm=M - m
    )


# =============================================================================
# Algorithm 3: Nearest Semantic Code Search
# =============================================================================

@dataclass
class EncodingResult:
    """Result of nearest semantic code search."""
    code_index: int
    code_vector: np.ndarray
    distance: float
    all_distances: List[float]


def nearest_semantic_code(
    s: np.ndarray,
    codebook: List[np.ndarray]
) -> EncodingResult:
    """
    Find the nearest code in a codebook under tropical Fisher distance.

    Algorithm: O(K * n) time where K = |codebook|, n = dimension.

    Args:
        s: Source score vector of shape (n,).
        codebook: List of K code vectors, each of shape (n,).

    Returns:
        EncodingResult with the nearest code and distance.

    Example:
        >>> cb = [np.array([1,0,0]), np.array([0,1,0]), np.array([0,0,1])]
        >>> r = nearest_semantic_code(np.array([0.9, 0.1, 0.0]), cb)
        >>> r.code_index
        0
    """
    if not codebook:
        raise ValueError("Codebook must be nonempty")

    distances = [tropical_fisher_dist(s, c) for c in codebook]
    best_idx = int(np.argmin(distances))

    return EncodingResult(
        code_index=best_idx,
        code_vector=codebook[best_idx].copy(),
        distance=distances[best_idx],
        all_distances=distances
    )


# =============================================================================
# Algorithm 4: Greedy Semantic Codebook Construction
# =============================================================================

def greedy_codebook(
    sources: List[np.ndarray],
    K: int,
    max_iter: int = 100
) -> Tuple[List[np.ndarray], List[float]]:
    """
    Construct a semantic codebook by greedy farthest-point insertion.

    Algorithm:
      1. Initialize with the source having largest seminorm.
      2. Repeat K-1 times:
         - Find the source with largest min-distance to current codebook.
         - Add it to the codebook.

    Complexity: O(K * N * n) where N = |sources|, n = dimension.

    This is the tropical analogue of the k-center greedy algorithm.

    Args:
        sources: List of N source vectors.
        K: Desired codebook size.
        max_iter: (unused, for compatibility)

    Returns:
        Tuple of (codebook, coverage_radius_history).

    Example:
        >>> sources = [np.random.randn(5) for _ in range(100)]
        >>> cb, radii = greedy_codebook(sources, K=4)
        >>> len(cb)
        4
    """
    if K <= 0 or not sources:
        raise ValueError("Need K > 0 and nonempty sources")

    K = min(K, len(sources))
    n = len(sources[0])

    # Initialize: pick source with largest seminorm
    seminorms = [tropical_fisher_seminorm(s) for s in sources]
    first_idx = int(np.argmax(seminorms))

    codebook = [sources[first_idx].copy()]
    used = {first_idx}
    radii = []

    for _ in range(K - 1):
        # Compute min-distance to current codebook for each source
        min_dists = []
        for j, s in enumerate(sources):
            if j in used:
                min_dists.append(-1.0)
            else:
                d = min(tropical_fisher_dist(s, c) for c in codebook)
                min_dists.append(d)

        # Find farthest source
        best_j = -1
        best_d = -1.0
        for j, d in enumerate(min_dists):
            if j not in used and d > best_d:
                best_d = d
                best_j = j

        if best_j < 0:
            break

        codebook.append(sources[best_j].copy())
        used.add(best_j)

        # Record coverage radius
        coverage = max(
            min(tropical_fisher_dist(s, c) for c in codebook)
            for s in sources
        )
        radii.append(coverage)

    return codebook, radii


# =============================================================================
# Algorithm 5: Tropical Projection (Pointwise Infimum)
# =============================================================================

def pointwise_infimum(family: List[np.ndarray]) -> np.ndarray:
    """
    Compute the pointwise infimum (tropical projection) of a family.

    Algorithm: O(K * n) time.

    The pointwise infimum is:
      (π_G)(i) = min_{g in G} g(i)

    This is an idempotent operation: π_{π_G} = π_G.

    Args:
        family: Nonempty list of score vectors.

    Returns:
        The pointwise minimum vector.

    Example:
        >>> G = [np.array([5,3,1]), np.array([2,6,3]), np.array([1,2,5])]
        >>> pointwise_infimum(G)
        array([1, 2, 1])
    """
    if not family:
        raise ValueError("Family must be nonempty")
    return np.min(np.array(family), axis=0)


def tropical_hull(
    generators: List[np.ndarray],
    num_samples: int = 1000
) -> List[np.ndarray]:
    """
    Sample from the tropical convex hull of generators.

    The tropical convex hull is:
      tconv(G) = {x -> min_{g in G} (g(x) + w_g) | w in R^|G|}

    We sample by choosing random weights w.

    Args:
        generators: List of generator vectors.
        num_samples: Number of samples to generate.

    Returns:
        List of sampled vectors from the tropical hull.
    """
    if not generators:
        raise ValueError("Need at least one generator")

    K = len(generators)
    n = len(generators[0])
    G = np.array(generators)  # Shape (K, n)

    samples = []
    for _ in range(num_samples):
        w = np.random.randn(K) * 2  # Random weights
        # For each coordinate i, compute min_g (g(i) + w_g)
        shifted = G + w[:, np.newaxis]  # Shape (K, n)
        sample = np.min(shifted, axis=0)  # Shape (n,)
        samples.append(sample)

    return samples


# =============================================================================
# Algorithm 6: Semantic Encoding with Projective Invariance Check
# =============================================================================

def semantic_encoder(
    codebook: List[np.ndarray]
) -> callable:
    """
    Create a semantic encoder function from a codebook.

    The returned function maps score vectors to their nearest code
    under tropical Fisher distance. It is provably projectively invariant:
    encode(s + k) = encode(s) for all constants k.

    Args:
        codebook: Nonempty list of code vectors.

    Returns:
        Encoder function: np.ndarray -> EncodingResult
    """
    def encode(s: np.ndarray) -> EncodingResult:
        return nearest_semantic_code(s, codebook)
    return encode


def verify_projective_invariance(
    encode: callable,
    s: np.ndarray,
    shifts: List[float] = None,
    tol: float = 1e-10
) -> bool:
    """
    Verify that an encoder is projectively invariant on a given input.

    Args:
        encode: Encoder function.
        s: Source vector.
        shifts: List of shifts to test (default: several values).
        tol: Tolerance for distance comparison.

    Returns:
        True if the encoder produces the same code for all shifts.
    """
    if shifts is None:
        shifts = [0.0, 1.0, -1.0, 100.0, -100.0, 3.14159, 1e6]

    base_result = encode(s)

    for k in shifts:
        shifted_result = encode(s + k)
        if shifted_result.code_index != base_result.code_index:
            # Check if distances are tied (both are valid minimizers)
            if not np.isclose(shifted_result.distance, base_result.distance, atol=tol):
                return False

    return True


# =============================================================================
# Main: Run all algorithms with examples
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Tropical Semantic Compression Algorithms")
    print("=" * 70)

    # Example 1: Basic operations
    v = np.array([3.2, 1.1, 5.7, 2.3, 4.8])
    print(f"\n1. Seminorm of {v}: {tropical_fisher_seminorm(v):.4f}")

    r = optimal_recentering(v)
    print(f"   Optimal shift: {r.optimal_shift:.4f}")
    print(f"   Min-max deviation: {r.min_max_deviation:.4f}")

    # Example 2: Codebook construction
    np.random.seed(42)
    sources = [np.random.randn(5) * 3 for _ in range(50)]
    codebook, radii = greedy_codebook(sources, K=5)
    print(f"\n2. Built codebook of size {len(codebook)}")
    print(f"   Coverage radii: {[f'{r:.3f}' for r in radii]}")

    # Example 3: Encoding
    encode = semantic_encoder(codebook)
    s = np.random.randn(5) * 3
    result = encode(s)
    print(f"\n3. Encoded source to code #{result.code_index} (dist = {result.distance:.4f})")

    # Example 4: Projective invariance
    invariant = verify_projective_invariance(encode, s)
    print(f"\n4. Projective invariance verified: {invariant}")

    # Example 5: Tropical hull sampling
    G = [np.array([5, 1, 1]), np.array([1, 5, 1]), np.array([1, 1, 5])]
    hull_samples = tropical_hull(G, num_samples=100)
    print(f"\n5. Sampled {len(hull_samples)} points from tropical hull")
    seminorms = [tropical_fisher_seminorm(s) for s in hull_samples]
    print(f"   Seminorm range: [{min(seminorms):.3f}, {max(seminorms):.3f}]")

    print("\n" + "=" * 70)
    print("All algorithms executed successfully.")
    print("=" * 70)
