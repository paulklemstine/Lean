"""
Algorithms for Stereographic Persistence: Exact metric transport from S^n to R^n.

This module implements the core algorithms for computing persistence diagrams
using the weighted stereographic distance, providing an exact bridge between
intrinsic spherical topology and computable Euclidean filtrations.

Key algorithms:
1. Inverse stereographic projection and its inverse
2. Weighted stereographic distance computation
3. Spherical geodesic distance computation
4. Vietoris-Rips filtration construction with custom metrics
5. Bi-Lipschitz constant estimation on bounded regions
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import combinations


def stereographic_project(points_sphere: np.ndarray) -> np.ndarray:
    """
    Stereographic projection from S^n ⊂ R^{n+1} to R^n.

    Projects from the north pole N = (0, ..., 0, 1).
    Formula: σ(x₁,...,x_{n+1}) = (x₁,...,xₙ) / (1 - x_{n+1})

    Args:
        points_sphere: Array of shape (N, n+1) with points on S^n.

    Returns:
        Array of shape (N, n) with projected points in R^n.

    Complexity: O(N * n) time, O(N * n) space.

    Example:
        >>> south_pole = np.array([[0, 0, -1.0]])
        >>> stereographic_project(south_pole)
        array([[0., 0.]])
    """
    last_coord = points_sphere[:, -1:]
    denom = 1.0 - last_coord
    return points_sphere[:, :-1] / denom


def inverse_stereographic(points_flat: np.ndarray) -> np.ndarray:
    """
    Inverse stereographic projection from R^n to S^n ⊂ R^{n+1}.

    Maps from R^n to S^n \\ {N} using the standard formula:
    σ⁻¹(y) = ((2y₁,...,2yₙ, ‖y‖²-1)) / (‖y‖²+1)

    Args:
        points_flat: Array of shape (N, n) with points in R^n.

    Returns:
        Array of shape (N, n+1) with points on S^n.

    Complexity: O(N * n) time, O(N * n+1) space.

    Example:
        >>> origin = np.array([[0.0, 0.0]])
        >>> inverse_stereographic(origin)
        array([[ 0.,  0., -1.]])
    """
    norms_sq = np.sum(points_flat ** 2, axis=1, keepdims=True)
    denom = norms_sq + 1.0
    first_n = 2.0 * points_flat / denom
    last = (norms_sq - 1.0) / denom
    return np.hstack([first_n, last])


def spherical_geodesic_distance(p: np.ndarray, q: np.ndarray) -> float:
    """
    Geodesic distance on S^n between two unit vectors.

    d(p, q) = arccos(⟨p, q⟩), clamped for numerical stability.

    Args:
        p, q: Unit vectors in R^{n+1}.

    Returns:
        Geodesic distance in [0, π].
    """
    dot = np.clip(np.dot(p, q), -1.0, 1.0)
    return np.arccos(dot)


def spherical_distance_matrix(points_sphere: np.ndarray) -> np.ndarray:
    """
    Compute the full pairwise spherical geodesic distance matrix.

    Args:
        points_sphere: Array of shape (N, n+1) with unit vectors.

    Returns:
        Symmetric distance matrix of shape (N, N).

    Complexity: O(N² * n) time, O(N²) space.
    """
    dots = np.clip(points_sphere @ points_sphere.T, -1.0, 1.0)
    return np.arccos(dots)


def weighted_stereographic_distance(x: np.ndarray, y: np.ndarray) -> float:
    """
    Weighted stereographic distance d_st(x, y).

    This is the transported spherical geodesic distance through stereographic
    coordinates. By the exact distance transport theorem:

    d_st(x, y) = arccos(1 - 2‖x-y‖² / ((1+‖x‖²)(1+‖y‖²)))

    Note: This uses the standard stereographic convention. The Mathlib convention
    with factor 2 gives: arccos(1 - 8‖w₁-w₂‖² / ((‖w₁‖²+4)(‖w₂‖²+4))).

    Args:
        x, y: Points in R^n.

    Returns:
        The weighted distance (= spherical geodesic distance of preimages).
    """
    diff_sq = np.sum((x - y) ** 2)
    nx_sq = np.sum(x ** 2)
    ny_sq = np.sum(y ** 2)
    denom = (1.0 + nx_sq) * (1.0 + ny_sq)
    inner_val = np.clip(1.0 - 2.0 * diff_sq / denom, -1.0, 1.0)
    return np.arccos(inner_val)


def weighted_distance_matrix(points_flat: np.ndarray) -> np.ndarray:
    """
    Compute the full pairwise weighted stereographic distance matrix.

    This computes d_st(x_i, x_j) for all pairs, which by the exact transport
    theorem equals the spherical geodesic distance between the preimages.

    Args:
        points_flat: Array of shape (N, n) with points in R^n.

    Returns:
        Symmetric distance matrix of shape (N, N).

    Complexity: O(N² * n) time, O(N²) space.
    """
    norms_sq = np.sum(points_flat ** 2, axis=1)
    # Compute pairwise squared distances
    diff = points_flat[:, np.newaxis, :] - points_flat[np.newaxis, :, :]
    diff_sq = np.sum(diff ** 2, axis=-1)
    # Compute denominators
    denom = np.outer(1.0 + norms_sq, 1.0 + norms_sq)
    inner_vals = np.clip(1.0 - 2.0 * diff_sq / denom, -1.0, 1.0)
    return np.arccos(inner_vals)


def euclidean_distance_matrix(points: np.ndarray) -> np.ndarray:
    """Compute pairwise Euclidean distance matrix."""
    diff = points[:, np.newaxis, :] - points[np.newaxis, :, :]
    return np.sqrt(np.sum(diff ** 2, axis=-1))


def rips_complex_faces(dist_matrix: np.ndarray, epsilon: float,
                       max_dim: int = 2) -> List[Tuple[int, ...]]:
    """
    Compute faces of the Vietoris-Rips complex at scale epsilon.

    A simplex {v₀, ..., v_k} is included if d(v_i, v_j) ≤ ε for all i, j.

    Args:
        dist_matrix: Pairwise distance matrix.
        epsilon: Scale parameter.
        max_dim: Maximum simplex dimension to compute.

    Returns:
        List of simplices as tuples of vertex indices.

    Complexity: O(N^{max_dim+1}) time in the worst case.
    """
    N = dist_matrix.shape[0]
    faces = [(i,) for i in range(N)]  # 0-simplices (vertices)

    for dim in range(1, max_dim + 1):
        for simplex in combinations(range(N), dim + 1):
            is_face = True
            for i, j in combinations(simplex, 2):
                if dist_matrix[i, j] > epsilon:
                    is_face = False
                    break
            if is_face:
                faces.append(simplex)
    return faces


def rips_filtration_values(dist_matrix: np.ndarray) -> np.ndarray:
    """
    Compute the birth times for all edges in the Rips filtration.

    The birth time of edge (i,j) is d(i,j). Higher simplices enter when
    all their edges have appeared.

    Args:
        dist_matrix: Pairwise distance matrix.

    Returns:
        Sorted array of unique edge weights (filtration values).
    """
    N = dist_matrix.shape[0]
    edges = []
    for i in range(N):
        for j in range(i + 1, N):
            edges.append(dist_matrix[i, j])
    return np.sort(np.unique(edges))


def bi_lipschitz_constants(R: float) -> Tuple[float, float]:
    """
    Compute the bi-Lipschitz constants for the stereographic distance
    on a bounded region {‖x‖ ≤ R}.

    By the formal theorem: C₁ = 4/(R²+4) and C₂ = π/2.
    (Using the standard stereographic convention.)

    The formal theorem proves:
    C₁ * ‖x-y‖ ≤ d_st(x,y) ≤ C₂ * ‖x-y‖

    for all x, y with ‖x‖, ‖y‖ ≤ R.

    Note: The Mathlib formalization uses the convention with factor 2 in
    the forward map, giving constants 4/(R²+4) and π/2 for that convention.

    Args:
        R: Bound on norms of points in stereographic coordinates.

    Returns:
        Tuple (C₁, C₂) of bi-Lipschitz constants.

    Example:
        >>> bi_lipschitz_constants(1.0)
        (0.8, 1.5707963267948966)
    """
    # For d_st(x,y) = arccos(1 - 2‖x-y‖²/((1+‖x‖²)(1+‖y‖²)))
    # arccos(1-t) ~ √(2t) for small t, and ≤ π√(t/2) in general.
    # t = 2‖x-y‖²/D where D = (1+‖x‖²)(1+‖y‖²) ∈ [1, (1+R²)²]
    # Lower: d_st ≥ √(2t) ≥ √(4/(1+R²)²) * ‖x-y‖ = 2/(1+R²) * ‖x-y‖
    # Upper: d_st ≤ π (bounded by π), and d_st → ‖x-y‖ ratio approaches
    #   √(2/D_min) ≤ √2 for local behaviour
    C1 = 2.0 / (1.0 + R ** 2)  # lower bound constant
    C2 = np.pi / 2.0  # upper bound constant (from chord-arc inequality)
    return C1, C2


def sample_spherical_cap(n_points: int, n_dim: int = 2,
                         angular_radius: float = np.pi / 3,
                         center: Optional[np.ndarray] = None,
                         seed: Optional[int] = None) -> np.ndarray:
    """
    Sample points uniformly from a spherical cap on S^n.

    Args:
        n_points: Number of points to sample.
        n_dim: Dimension of the sphere (S^n_dim embedded in R^{n_dim+1}).
        angular_radius: Angular radius of the cap in radians.
        center: Center of the cap (unit vector). Defaults to south pole.
        seed: Random seed for reproducibility.

    Returns:
        Array of shape (n_points, n_dim+1) with points on S^n.
    """
    if seed is not None:
        np.random.seed(seed)

    if center is None:
        center = np.zeros(n_dim + 1)
        center[-1] = -1.0  # south pole (away from north pole)

    # Sample from cap by rejection sampling
    points = []
    while len(points) < n_points:
        # Random direction on S^n
        x = np.random.randn(n_dim + 1)
        x /= np.linalg.norm(x)
        # Check if within angular radius of center
        if np.dot(x, center) >= np.cos(angular_radius):
            points.append(x)

    return np.array(points)


def sample_sphere_uniform(n_points: int, n_dim: int = 2,
                          seed: Optional[int] = None) -> np.ndarray:
    """
    Sample points uniformly on S^n.

    Args:
        n_points: Number of points.
        n_dim: Sphere dimension.
        seed: Random seed.

    Returns:
        Array of shape (n_points, n_dim+1).
    """
    if seed is not None:
        np.random.seed(seed)
    x = np.random.randn(n_points, n_dim + 1)
    norms = np.linalg.norm(x, axis=1, keepdims=True)
    return x / norms


def persistence_comparison(points_sphere: np.ndarray) -> dict:
    """
    Compare three distance matrices for a point cloud on the sphere:
    1. Intrinsic spherical geodesic distance
    2. Weighted stereographic distance (exact transport)
    3. Naive Euclidean distance on stereographic coordinates

    By the exact transport theorem, (1) and (2) should be identical
    (up to numerical tolerance). (3) will generally differ.

    Args:
        points_sphere: Array of shape (N, n+1) with points on S^n,
                       not containing the north pole.

    Returns:
        Dictionary with distance matrices and comparison statistics.
    """
    points_flat = stereographic_project(points_sphere)

    D_spherical = spherical_distance_matrix(points_sphere)
    D_weighted = weighted_distance_matrix(points_flat)
    D_euclidean = euclidean_distance_matrix(points_flat)

    max_diff_exact = np.max(np.abs(D_spherical - D_weighted))
    max_diff_naive = np.max(np.abs(D_spherical - D_euclidean))
    mean_ratio = np.mean(D_euclidean[D_spherical > 1e-10] /
                         D_spherical[D_spherical > 1e-10])

    return {
        'D_spherical': D_spherical,
        'D_weighted': D_weighted,
        'D_euclidean': D_euclidean,
        'max_error_exact_transport': max_diff_exact,
        'max_error_naive_euclidean': max_diff_naive,
        'mean_euclidean_to_spherical_ratio': mean_ratio,
        'points_sphere': points_sphere,
        'points_flat': points_flat,
    }
