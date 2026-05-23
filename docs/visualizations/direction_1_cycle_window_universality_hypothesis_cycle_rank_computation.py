#!/usr/bin/env python3
"""
Algorithms for Cycle-Window Universality Analysis

Implements the computational pipeline for:
1. Graph filtration construction from feature families
2. Cycle rank computation via Euler characteristic formula
3. Normalized cycle-rank profile generation
4. Profile comparison via sup-norm and KS-style distances

All algorithms have verified correctness properties formalized in Lean 4.
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
import numpy as np


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 1: Union-Find for Connected Components
# ─────────────────────────────────────────────────────────────────────────────

class UnionFind:
    """
    Disjoint-set data structure with union by rank and path compression.

    Time complexity:
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized
    Space complexity: O(n)

    The component count is maintained incrementally.
    """

    def __init__(self, n: int):
        """Initialize n singleton components."""
        self.parent: List[int] = list(range(n))
        self.rank: List[int] = [0] * n
        self.num_components: int = n

    def find(self, x: int) -> int:
        """Find root representative with path compression."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]  # path halving
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """Union two components. Returns True if they were distinct."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 2: Cycle Rank Computation
# ─────────────────────────────────────────────────────────────────────────────

def cycle_rank(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """
    Compute the cycle rank (first Betti number) of a simple graph.

    β₁(G) = |E| - |V| + c(G)

    where |E| = number of edges, |V| = number of vertices,
    c(G) = number of connected components.

    This is the Euler characteristic formula for 1-dimensional CW complexes.
    Verified in Lean as `cycleRankOfFiltration_eq`.

    Args:
        n_vertices: Number of vertices |V|
        edges: List of edges as (u, v) pairs with u < v

    Returns:
        Cycle rank β₁ ≥ 0

    Time complexity: O(|E| · α(|V|))
    Space complexity: O(|V|)

    Example:
        >>> cycle_rank(3, [(0,1), (1,2), (0,2)])  # triangle
        1
        >>> cycle_rank(4, [(0,1), (1,2), (2,3)])  # path
        0
    """
    uf = UnionFind(n_vertices)
    for u, v in edges:
        uf.union(u, v)
    return max(0, len(edges) - n_vertices + uf.num_components)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 3: Symmetric Difference Distance
# ─────────────────────────────────────────────────────────────────────────────

def symmetric_difference_distance(A: Set, B: Set) -> int:
    """
    Compute |A Δ B| = |A \\ B| + |B \\ A|.

    Verified equivalent to Hamming distance for Boolean feature vectors
    (Lean theorem: `symmDiffCard_eq_hammingDist`).

    Time complexity: O(|A| + |B|)

    Example:
        >>> symmetric_difference_distance({1, 2, 3}, {2, 3, 4})
        2
    """
    return len(A.symmetric_difference(B))


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 4: Threshold Graph Construction
# ─────────────────────────────────────────────────────────────────────────────

def threshold_graph(
    n: int,
    dist_matrix: np.ndarray,
    epsilon: float
) -> List[Tuple[int, int]]:
    """
    Construct the threshold graph G_ε: edges between vertices with distance ≤ ε.

    The threshold graph filtration {G_ε}_{ε≥0} is monotone: if ε ≤ ε', then
    G_ε ⊆ G_ε'. Verified in Lean as `semanticGraph_mono` (in the existing catalog).

    Args:
        n: Number of vertices
        dist_matrix: n×n symmetric distance matrix
        epsilon: Threshold parameter

    Returns:
        List of edges (i, j) with i < j and dist(i, j) ≤ epsilon

    Time complexity: O(n²)
    Space complexity: O(n²) for output in worst case
    """
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if dist_matrix[i, j] <= epsilon:
                edges.append((i, j))
    return edges


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 5: Full Cycle-Rank Curve Computation
# ─────────────────────────────────────────────────────────────────────────────

def compute_cycle_rank_curve(
    n_vertices: int,
    dist_matrix: np.ndarray,
    thresholds: np.ndarray
) -> np.ndarray:
    """
    Compute the cycle rank curve β₁(ε) over a grid of thresholds.

    Verified in Lean: `computeCycleRankCurve_correct` proves that the k-th
    entry equals cycleRankOfFiltration applied to the k-th data point.

    Args:
        n_vertices: Number of vertices
        dist_matrix: Pairwise distance matrix
        thresholds: Array of threshold values

    Returns:
        Array of cycle ranks at each threshold

    Time complexity: O(T · n²) where T = len(thresholds)
    Space complexity: O(T + n)

    Example:
        >>> import numpy as np
        >>> D = np.array([[0, 1, 2], [1, 0, 1], [2, 1, 0]])
        >>> compute_cycle_rank_curve(3, D, np.array([0, 1, 2]))
        array([0, 0, 1])
    """
    curve = np.zeros(len(thresholds), dtype=int)
    for k, eps in enumerate(thresholds):
        edges = threshold_graph(n_vertices, dist_matrix, eps)
        curve[k] = cycle_rank(n_vertices, edges)
    return curve


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 6: Normalization
# ─────────────────────────────────────────────────────────────────────────────

def normalize_cycle_rank_curve(
    curve: np.ndarray,
    thresholds: np.ndarray,
    median_distance: float
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Normalize the cycle-rank curve:
    - Rescale thresholds by median pairwise distance
    - Divide cycle rank by its maximum value

    The universality theorem (Lean: `universality_exact`) proves that this
    normalization produces identical profiles for filtrations with matched
    edge/component data.

    Args:
        curve: Raw cycle rank values
        thresholds: Raw threshold values
        median_distance: Median pairwise distance (rescaling parameter)

    Returns:
        (normalized_thresholds, normalized_curve) pair

    Time complexity: O(T)
    Space complexity: O(T)
    """
    max_val = curve.max()
    if max_val == 0:
        norm_curve = np.zeros_like(curve, dtype=float)
    else:
        norm_curve = curve.astype(float) / float(max_val)

    if median_distance == 0:
        norm_thresh = thresholds.astype(float)
    else:
        norm_thresh = thresholds.astype(float) / float(median_distance)

    return norm_thresh, norm_curve


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 7: Discrete Derivative (Susceptibility)
# ─────────────────────────────────────────────────────────────────────────────

def discrete_derivative(curve: np.ndarray) -> np.ndarray:
    """
    Compute the discrete derivative Δf(n) = f(n+1) - f(n).

    In the statistical mechanics interpretation, this is the susceptibility-like
    observable. The Lean theorem `exists_positive_discrete_derivative` proves
    that if f starts at 0 and later becomes positive, there exists an index
    where this derivative is positive.

    Args:
        curve: Integer-valued sequence

    Returns:
        Array of differences (length = len(curve) - 1)

    Time complexity: O(T)
    """
    return np.diff(curve.astype(float))


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 8: Profile Comparison
# ─────────────────────────────────────────────────────────────────────────────

def sup_norm_distance(curve1: np.ndarray, curve2: np.ndarray) -> float:
    """
    Compute the sup-norm (L∞) distance between two curves.

    This is bounded by δ/maxVal when component counts differ by at most δ,
    as proven in Lean theorem `universality_approximate`.

    Args:
        curve1, curve2: Arrays of same length

    Returns:
        max_i |curve1[i] - curve2[i]|

    Time complexity: O(T)
    """
    return float(np.max(np.abs(curve1 - curve2)))


def ks_distance(
    thresh1: np.ndarray, curve1: np.ndarray,
    thresh2: np.ndarray, curve2: np.ndarray,
    n_interp: int = 200
) -> float:
    """
    Compute KS-style distance between two normalized cycle-rank profiles.

    Interpolates both curves to a common threshold grid and computes
    the sup-norm distance.

    Args:
        thresh1, curve1: First normalized profile
        thresh2, curve2: Second normalized profile
        n_interp: Number of interpolation points

    Returns:
        KS distance ∈ [0, 1]

    Time complexity: O(n_interp + T₁ + T₂)
    """
    max_thresh = max(thresh1.max(), thresh2.max())
    common = np.linspace(0, max_thresh, n_interp)
    interp1 = np.interp(common, thresh1, curve1)
    interp2 = np.interp(common, thresh2, curve2)
    return sup_norm_distance(interp1, interp2)


# ─────────────────────────────────────────────────────────────────────────────
# Algorithm 9: Cycle Window Detection
# ─────────────────────────────────────────────────────────────────────────────

def detect_cycle_window(
    curve: np.ndarray,
    thresholds: np.ndarray
) -> Optional[Tuple[float, float, float]]:
    """
    Detect the cycle window: the interval [ε_a, ε_b] where β₁ > 0.

    The existence of this window is guaranteed by the Lean theorem
    `exists_nontrivial_cycle_window` when the cycle rank transitions
    from 0 to positive and then drops.

    Args:
        curve: Cycle rank values
        thresholds: Corresponding threshold values

    Returns:
        (window_start, window_end, window_width) or None if no cycles found

    Time complexity: O(T)
    """
    positive = np.where(curve > 0)[0]
    if len(positive) == 0:
        return None
    start = thresholds[positive[0]]
    end = thresholds[positive[-1]]
    return (float(start), float(end), float(end - start))


# ─────────────────────────────────────────────────────────────────────────────
# Full Pipeline
# ─────────────────────────────────────────────────────────────────────────────

def full_analysis_pipeline(
    feature_sets: List[Set],
    n_thresholds: int = 50,
    metric: str = 'symmetric_difference'
) -> Dict:
    """
    Run the complete cycle-window universality analysis pipeline.

    1. Compute pairwise distances
    2. Build threshold graph filtration
    3. Compute cycle-rank curve
    4. Normalize by median distance and peak cycle rank
    5. Detect cycle window
    6. Compute discrete derivative (susceptibility)

    Args:
        feature_sets: List of feature sets (one per statement)
        n_thresholds: Number of threshold points
        metric: Distance metric to use

    Returns:
        Dictionary with all analysis results

    Time complexity: O(n² · T) where n = |feature_sets|, T = n_thresholds
    """
    n = len(feature_sets)

    # Step 1: Pairwise distances
    dist_matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            d = symmetric_difference_distance(feature_sets[i], feature_sets[j])
            dist_matrix[i, j] = d
            dist_matrix[j, i] = d

    # Median distance
    upper_tri = dist_matrix[np.triu_indices_from(dist_matrix, k=1)]
    median_dist = float(np.median(upper_tri))

    # Step 2-3: Threshold grid and cycle rank curve
    max_dist = upper_tri.max()
    thresholds = np.linspace(0, max_dist, n_thresholds)
    raw_curve = compute_cycle_rank_curve(n, dist_matrix, thresholds)

    # Step 4: Normalize
    norm_thresh, norm_curve = normalize_cycle_rank_curve(
        raw_curve, thresholds, median_dist
    )

    # Step 5: Cycle window
    window = detect_cycle_window(raw_curve, thresholds)

    # Step 6: Discrete derivative
    deriv = discrete_derivative(raw_curve)
    peak_idx = int(np.argmax(deriv)) if len(deriv) > 0 else 0
    peak_thresh = float(thresholds[peak_idx]) if len(thresholds) > 0 else 0.0

    return {
        'n_vertices': n,
        'dist_matrix': dist_matrix,
        'median_distance': median_dist,
        'thresholds': thresholds,
        'raw_curve': raw_curve,
        'norm_thresholds': norm_thresh,
        'norm_curve': norm_curve,
        'cycle_window': window,
        'max_cycle_rank': int(raw_curve.max()),
        'derivative': deriv,
        'peak_derivative_threshold': peak_thresh,
    }


if __name__ == "__main__":
    # Example usage
    import random
    random.seed(42)

    # Generate a small family of feature sets
    alphabet = list(range(15))
    family = [set(random.sample(alphabet, random.randint(3, 8))) for _ in range(20)]

    result = full_analysis_pipeline(family, n_thresholds=30)

    print("Analysis Results:")
    print(f"  Vertices: {result['n_vertices']}")
    print(f"  Median distance: {result['median_distance']:.2f}")
    print(f"  Max cycle rank: {result['max_cycle_rank']}")
    print(f"  Cycle window: {result['cycle_window']}")
    print(f"  Peak derivative at ε = {result['peak_derivative_threshold']:.2f}")
    print(f"  Normalized curve: {result['norm_curve'][:10]}...")
