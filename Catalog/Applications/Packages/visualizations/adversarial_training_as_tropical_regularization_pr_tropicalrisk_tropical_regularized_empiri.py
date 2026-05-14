#!/usr/bin/env python3
"""
Algorithms for Tropical Adversarial Regularization

Implements the core algorithms from the research:
  1. Tropical margin computation for multi-class classifiers
  2. Tropical distance transform (min-plus distance to adversarial set)
  3. Certified robustness radius computation
  4. Tropical regularized empirical risk minimization
  5. Min-plus erosion of loss functions

All algorithms work on finite-dimensional real-valued classifiers
with arbitrary cost functions.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class CertifiedPoint:
    """A data point with its certified robustness information."""
    x: np.ndarray
    y: int
    margin: float
    certified_radius: float
    robust_loss: float
    tropical_bound: float


def compute_margin(
    score_fn: Callable[[np.ndarray], np.ndarray],
    x: np.ndarray,
    y: int
) -> float:
    """
    Compute the classification margin at (x, y).

    margin(x, y) = score(x, y) - max_{y' ≠ y} score(x, y')

    Args:
        score_fn: Maps input x to score vector of shape (c,)
        x: Input point
        y: True label index

    Returns:
        The classification margin (positive means correct classification)

    Complexity: O(c) where c is the number of classes
    """
    scores = score_fn(x)
    c = len(scores)
    competitor_scores = [scores[j] for j in range(c) if j != y]
    return float(scores[y] - max(competitor_scores))


def certified_radius_from_lipschitz(
    score_fn: Callable[[np.ndarray], np.ndarray],
    x: np.ndarray,
    y: int,
    lipschitz_constant: float
) -> float:
    """
    Compute the certified robustness radius via the tropical margin formula.

    r_cert = margin(x, y) / L

    This is the idempotent closure radius lower bound from Theorem C.

    Args:
        score_fn: Score function
        x: Input point
        y: True label
        lipschitz_constant: L-Lipschitz constant of the margin

    Returns:
        Certified radius (≥ 0); 0 if margin is non-positive

    Complexity: O(c) for margin computation
    """
    m = compute_margin(score_fn, x, y)
    if m <= 0 or lipschitz_constant <= 0:
        return 0.0
    return m / lipschitz_constant


def tropical_erosion(
    phi: Callable[[float], float],
    margin_value: float,
    lipschitz_constant: float,
    epsilon: float
) -> float:
    """
    Compute the tropical erosion (min-plus translation) of the loss.

    φ_ε^trop(m) = φ(m - L·ε)

    This is the tropical regularization term from Theorem B:
    the robust loss is bounded by this quantity.

    Args:
        phi: Loss transfer function (antitone in margin)
        margin_value: Current margin m(x, y)
        lipschitz_constant: L
        epsilon: Perturbation budget

    Returns:
        The tropically eroded loss value

    Complexity: O(1)
    """
    return phi(margin_value - lipschitz_constant * epsilon)


def compute_robust_loss_montecarlo(
    score_fn: Callable[[np.ndarray], np.ndarray],
    phi: Callable[[float], float],
    cost_fn: Callable[[np.ndarray, np.ndarray], float],
    x: np.ndarray,
    y: int,
    epsilon: float,
    n_samples: int = 10000,
    rng: Optional[np.random.Generator] = None
) -> float:
    """
    Monte Carlo estimate of the robust loss.

    robust_loss(x, y) = sup{φ(margin(x', y)) : cost(x, x') ≤ ε}

    Uses random sampling within the cost ball. For exact computation
    on finite discrete spaces, see compute_robust_loss_exact.

    Args:
        score_fn: Score function
        phi: Loss transfer function
        cost_fn: Cost function
        x: Center point
        y: True label
        epsilon: Perturbation budget
        n_samples: Number of Monte Carlo samples
        rng: Random number generator

    Returns:
        Lower bound on robust loss (approaches true value as n_samples → ∞)

    Complexity: O(n_samples · (c + d)) per point
    """
    if rng is None:
        rng = np.random.default_rng(42)

    d = len(x)
    best_loss = phi(compute_margin(score_fn, x, y))

    for _ in range(n_samples):
        # Sample uniformly from L-infinity ball
        delta = rng.uniform(-epsilon, epsilon, size=d)
        x_perturbed = x + delta
        if cost_fn(x, x_perturbed) <= epsilon:
            loss = phi(compute_margin(score_fn, x_perturbed, y))
            best_loss = max(best_loss, loss)

    return best_loss


def tropical_regularized_risk(
    score_fn: Callable[[np.ndarray], np.ndarray],
    phi: Callable[[float], float],
    dataset: List[Tuple[np.ndarray, int]],
    lipschitz_constant: float,
    epsilon: float
) -> float:
    """
    Compute the tropical regularized empirical risk.

    R_trop(ε) = (1/m) Σ_i φ(margin(x_i, y_i) - L·ε)

    By Theorem B, this is an upper bound on the robust empirical risk.

    Args:
        score_fn: Score function
        phi: Loss transfer (antitone)
        dataset: List of (input, label) pairs
        lipschitz_constant: L
        epsilon: Perturbation budget

    Returns:
        The tropical regularized risk value

    Complexity: O(m · c) where m = dataset size, c = number of classes

    Algorithm:
        1. For each (x_i, y_i) in dataset:
           a. Compute margin m_i = margin(x_i, y_i)
           b. Compute eroded margin m_i - L·ε
           c. Apply loss: φ(m_i - L·ε)
        2. Return average
    """
    if not dataset:
        return 0.0

    total = 0.0
    for x, y in dataset:
        m = compute_margin(score_fn, x, y)
        total += tropical_erosion(phi, m, lipschitz_constant, epsilon)

    return total / len(dataset)


def certify_dataset(
    score_fn: Callable[[np.ndarray], np.ndarray],
    dataset: List[Tuple[np.ndarray, int]],
    lipschitz_constant: float,
    phi: Callable[[float], float],
    epsilon: float
) -> List[CertifiedPoint]:
    """
    Certify all points in a dataset with tropical robustness certificates.

    For each point, computes:
    - Classification margin
    - Certified radius (margin / L)
    - Tropical regularization bound on robust loss

    Args:
        score_fn: Score function
        dataset: List of (input, label) pairs
        lipschitz_constant: L
        phi: Loss transfer function
        epsilon: Perturbation budget for loss computation

    Returns:
        List of CertifiedPoint objects with full certification info

    Complexity: O(m · c) total
    """
    results = []
    for x, y in dataset:
        m = compute_margin(score_fn, x, y)
        r = max(0.0, m / lipschitz_constant) if lipschitz_constant > 0 else 0.0
        trop_bound = tropical_erosion(phi, m, lipschitz_constant, epsilon)
        results.append(CertifiedPoint(
            x=x, y=y,
            margin=m,
            certified_radius=r,
            robust_loss=trop_bound,  # Upper bound
            tropical_bound=trop_bound
        ))
    return results


def tropical_distance_transform(
    score_fn: Callable[[np.ndarray], np.ndarray],
    cost_fn: Callable[[np.ndarray, np.ndarray], float],
    x: np.ndarray,
    y: int,
    candidate_points: List[np.ndarray]
) -> float:
    """
    Compute the tropical distance from x to the adversarial set.

    d_trop(x, y) = inf{cost(x, x') : margin(x', y) ≤ 0}

    Uses a finite set of candidate points as a proxy for the full
    adversarial set. For linear classifiers, the adversarial set is
    a half-space and the exact distance can be computed analytically.

    Args:
        score_fn: Score function
        cost_fn: Cost function
        x: Query point
        y: True label
        candidate_points: Finite set to search over

    Returns:
        Approximate tropical distance (upper bound on true infimum)

    Complexity: O(|candidates| · (c + d))
    """
    min_dist = float('inf')
    for xp in candidate_points:
        m = compute_margin(score_fn, xp, y)
        if m <= 0:
            d = cost_fn(x, xp)
            min_dist = min(min_dist, d)
    return min_dist


# ──────────────────────────────────────────────────────────────────────
# Loss functions
# ──────────────────────────────────────────────────────────────────────

def hinge_loss(m: float) -> float:
    """Hinge loss: max(0, 1 - m). Antitone in m."""
    return max(0.0, 1.0 - m)

def ramp_loss(m: float, s: float = 1.0) -> float:
    """Ramp loss: clipped hinge. Antitone in m."""
    return min(1.0, max(0.0, 1.0 - m / s))

def exponential_loss(m: float) -> float:
    """Exponential loss: exp(-m). Antitone in m."""
    return np.exp(-m)

def logistic_loss(m: float) -> float:
    """Logistic loss: log(1 + exp(-m)). Antitone in m."""
    return np.log1p(np.exp(-m))


# ──────────────────────────────────────────────────────────────────────
# Cost functions
# ──────────────────────────────────────────────────────────────────────

def linf_cost(x: np.ndarray, xp: np.ndarray) -> float:
    """L-infinity cost: max_i |x_i - x'_i|."""
    return float(np.max(np.abs(x - xp)))

def l2_cost(x: np.ndarray, xp: np.ndarray) -> float:
    """L2 cost: ||x - x'||_2."""
    return float(np.linalg.norm(x - xp))

def l1_cost(x: np.ndarray, xp: np.ndarray) -> float:
    """L1 cost: Σ_i |x_i - x'_i|."""
    return float(np.sum(np.abs(x - xp)))


if __name__ == "__main__":
    # Quick example
    W = np.array([[1.0, 0.5], [-0.5, 1.0]])
    b = np.array([0.0, -1.0])

    def my_score(x):
        return W @ x + b

    x = np.array([2.0, 1.0])
    y = 0

    m = compute_margin(my_score, x, y)
    r = certified_radius_from_lipschitz(my_score, x, y, lipschitz_constant=2.0)
    eroded = tropical_erosion(hinge_loss, m, 2.0, 0.3)

    print(f"Margin: {m:.3f}")
    print(f"Certified radius: {r:.3f}")
    print(f"Tropical eroded loss (ε=0.3): {eroded:.3f}")

    dataset = [(np.array([2.0, 1.0]), 0), (np.array([1.0, 0.5]), 0)]
    risk = tropical_regularized_risk(my_score, hinge_loss, dataset, 2.0, 0.3)
    print(f"Tropical regularized risk (ε=0.3): {risk:.3f}")

    certs = certify_dataset(my_score, dataset, 2.0, hinge_loss, 0.3)
    for c in certs:
        print(f"  x={c.x}, margin={c.margin:.3f}, cert_radius={c.certified_radius:.3f}")
