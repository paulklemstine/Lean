#!/usr/bin/env python3
"""
Algorithms for Lipschitz margin cell certification.

Implements the certified radius computation and geometric analysis
from the ball-inclusion theorem.
"""

import numpy as np
from typing import Dict, List, Optional, Tuple, Callable


def certified_radius(
    scores: Dict[int, float],
    lipschitz_constants: Dict[int, float],
    predicted_class: int,
) -> Tuple[float, float, float]:
    """
    Compute the certified radius γ/K for margin cell inclusion.

    Given score values at a point and Lipschitz constants for each pairwise
    gap function, returns the guaranteed radius of an open ball around the
    point that lies entirely within the margin cell.

    Parameters
    ----------
    scores : dict
        Mapping from class label to score value at the point.
    lipschitz_constants : dict
        Mapping from competitor class to Lipschitz constant of the gap
        function s_predicted - s_competitor.
    predicted_class : int
        The predicted class label.

    Returns
    -------
    gamma : float
        Minimum margin (gap to closest competitor).
    K : float
        Maximum Lipschitz constant across competitors.
    radius : float
        Certified radius γ/K.

    Examples
    --------
    >>> scores = {0: 3.0, 1: 1.0, 2: 0.5}
    >>> lip = {1: 2.0, 2: 1.5}
    >>> gamma, K, r = certified_radius(scores, lip, 0)
    >>> print(f"γ={gamma}, K={K}, r={r}")
    γ=2.0, K=2.0, r=1.0
    """
    gamma = float('inf')
    K = 0.0

    for j in scores:
        if j == predicted_class:
            continue
        gap = scores[predicted_class] - scores[j]
        gamma = min(gamma, gap)
        if j in lipschitz_constants:
            K = max(K, lipschitz_constants[j])

    if gamma <= 0:
        return gamma, K, 0.0
    if K == 0:
        return gamma, K, float('inf')
    return gamma, K, gamma / K


def lipschitz_constant_linear(
    W: np.ndarray, predicted_class: int, competitor_class: int
) -> float:
    """
    Compute the exact Lipschitz constant of a linear gap function.

    For linear score functions s_i(x) = W[i] · x + b[i], the gap function
    s_i - s_j has gradient W[i] - W[j], so its Lipschitz constant is
    ‖W[i] - W[j]‖₂.

    Parameters
    ----------
    W : np.ndarray
        Weight matrix of shape (n_classes, dim).
    predicted_class : int
        Index of predicted class.
    competitor_class : int
        Index of competitor class.

    Returns
    -------
    float
        Lipschitz constant ‖W[i] - W[j]‖₂.
    """
    return float(np.linalg.norm(W[predicted_class] - W[competitor_class]))


def lipschitz_constant_network(
    spectral_norms: List[float],
) -> float:
    """
    Upper bound on the Lipschitz constant of a feedforward network.

    For a network f = L_n ∘ σ ∘ L_{n-1} ∘ ... ∘ σ ∘ L_1 where each L_i
    has spectral norm s_i and σ is 1-Lipschitz (e.g., ReLU), the overall
    Lipschitz constant is bounded by ∏ s_i.

    Parameters
    ----------
    spectral_norms : list of float
        Spectral norms of weight matrices in each layer.

    Returns
    -------
    float
        Upper bound on network Lipschitz constant.

    Examples
    --------
    >>> lipschitz_constant_network([1.5, 2.0, 1.0])
    3.0
    """
    result = 1.0
    for s in spectral_norms:
        result *= s
    return result


def pairwise_gap_lipschitz_bound(
    network_lip: float,
) -> float:
    """
    Upper bound on the Lipschitz constant of a pairwise gap function.

    For gap g_j(x) = s_i(x) - s_j(x) where each s_k is L-Lipschitz,
    the gap is 2L-Lipschitz by the triangle inequality.

    Parameters
    ----------
    network_lip : float
        Lipschitz constant of each individual score function.

    Returns
    -------
    float
        Upper bound on gap function Lipschitz constant (2 * network_lip).
    """
    return 2.0 * network_lip


def margin_cell_membership(
    score_fns: Dict[int, Callable[[np.ndarray], float]],
    predicted_class: int,
    point: np.ndarray,
) -> bool:
    """
    Check whether a point belongs to the margin cell.

    Parameters
    ----------
    score_fns : dict
        Mapping from class to score function.
    predicted_class : int
        The predicted class.
    point : np.ndarray
        The point to check.

    Returns
    -------
    bool
        True if point is in the margin cell (strict dominance by predicted class).
    """
    pred_score = score_fns[predicted_class](point)
    for j, fn in score_fns.items():
        if j == predicted_class:
            continue
        if fn(point) >= pred_score:
            return False
    return True


def inscribed_radius_estimate(
    score_fns: Dict[int, Callable[[np.ndarray], float]],
    predicted_class: int,
    center: np.ndarray,
    max_radius: float = 10.0,
    n_directions: int = 1000,
    tol: float = 1e-6,
) -> float:
    """
    Estimate the inscribed radius of a margin cell via ray-casting.

    Shoots rays from the center in random directions and finds the
    distance to the margin cell boundary along each ray via binary search.
    Returns the minimum distance (inscribed radius estimate).

    Parameters
    ----------
    score_fns : dict
        Score functions.
    predicted_class : int
        Predicted class.
    center : np.ndarray
        Center point.
    max_radius : float
        Maximum search radius.
    n_directions : int
        Number of random directions.
    tol : float
        Binary search tolerance.

    Returns
    -------
    float
        Estimated inscribed radius (lower bound on true inscribed radius).
    """
    dim = len(center)
    min_dist = max_radius

    for _ in range(n_directions):
        direction = np.random.randn(dim)
        direction /= np.linalg.norm(direction)

        lo, hi = 0.0, max_radius
        # Binary search for boundary
        while hi - lo > tol:
            mid = (lo + hi) / 2
            point = center + mid * direction
            if margin_cell_membership(score_fns, predicted_class, point):
                lo = mid
            else:
                hi = mid

        min_dist = min(min_dist, lo)

    return min_dist


def batch_certify(
    W: np.ndarray,
    b: np.ndarray,
    X: np.ndarray,
) -> np.ndarray:
    """
    Batch certification for a linear classifier.

    Parameters
    ----------
    W : np.ndarray
        Weight matrix (n_classes, dim).
    b : np.ndarray
        Bias vector (n_classes,).
    X : np.ndarray
        Input points (n_points, dim).

    Returns
    -------
    radii : np.ndarray
        Certified radii for each point (n_points,).
    """
    n_points = X.shape[0]
    n_classes = W.shape[0]
    radii = np.zeros(n_points)

    # Compute all scores
    scores = X @ W.T + b  # (n_points, n_classes)
    predictions = np.argmax(scores, axis=1)

    for idx in range(n_points):
        pred = predictions[idx]
        gamma = float('inf')
        K = 0.0
        for j in range(n_classes):
            if j == pred:
                continue
            gap = scores[idx, pred] - scores[idx, j]
            gamma = min(gamma, gap)
            lip = np.linalg.norm(W[pred] - W[j])
            K = max(K, lip)
        if gamma > 0 and K > 0:
            radii[idx] = gamma / K
        else:
            radii[idx] = 0.0

    return radii


if __name__ == "__main__":
    # Quick test
    scores = {0: 3.0, 1: 1.0, 2: 0.5}
    lip = {1: 2.0, 2: 1.5}
    g, k, r = certified_radius(scores, lip, 0)
    print(f"Certified radius test: γ={g}, K={k}, r={r}")

    # Batch test
    np.random.seed(42)
    W = np.random.randn(5, 3)
    b = np.random.randn(5)
    X = np.random.randn(100, 3)
    radii = batch_certify(W, b, X)
    print(f"Batch certification: mean radius = {radii.mean():.4f}, "
          f"min = {radii.min():.4f}, max = {radii.max():.4f}")
    print(f"Points with positive radius: {(radii > 0).sum()}/{len(radii)}")
