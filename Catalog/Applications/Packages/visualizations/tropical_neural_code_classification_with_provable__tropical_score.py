#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Algorithms

Complete implementations of the algorithms from the research paper,
with docstrings, type hints, and example usage.
"""

import numpy as np
from typing import List, Tuple, FrozenSet, Optional


def tropical_score(prototype: np.ndarray, observation: np.ndarray) -> float:
    """
    Compute the tropical score of an observation against a prototype.

    The tropical score is the max-plus inner product:
        score(P_k, x) = max_i (P_k[i] - x[i])

    Lower score means better match — the prototype is closer to or
    below the observation in every coordinate.

    Parameters
    ----------
    prototype : np.ndarray of shape (d,)
        The prototype vector for a label.
    observation : np.ndarray of shape (d,)
        The observed firing pattern.

    Returns
    -------
    float
        The tropical score.

    Complexity
    ----------
    Time: O(d), Space: O(1)

    Example
    -------
    >>> tropical_score(np.array([1.0, 2.0, 0.0]), np.array([1.5, 1.0, 0.5]))
    1.0
    """
    return float(np.max(prototype - observation))


def tropical_scores_all(codebook: np.ndarray, observation: np.ndarray) -> np.ndarray:
    """
    Compute tropical scores for all labels in a codebook.

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
        Matrix of prototypes, one per label.
    observation : np.ndarray of shape (d,)
        The observed firing pattern.

    Returns
    -------
    np.ndarray of shape (c,)
        Scores for each label.

    Complexity
    ----------
    Time: O(cd), Space: O(c)
    """
    return np.max(codebook - observation[np.newaxis, :], axis=1)


def tropical_margin(codebook: np.ndarray, observation: np.ndarray,
                    true_label: int) -> float:
    """
    Compute the tropical margin at a true label.

    margin(P, x, y) = min_{j ≠ y} (score(x, j) - score(x, y))

    A positive margin certifies correct classification (Theorem A).
    The margin lower-bounds the robustness radius: perturbations
    of size < margin/2 preserve classification (Theorem 7.2).

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
    observation : np.ndarray of shape (d,)
    true_label : int

    Returns
    -------
    float
        The tropical margin. Positive = certified correct.

    Complexity
    ----------
    Time: O(cd), Space: O(c)
    """
    scores = tropical_scores_all(codebook, observation)
    true_score = scores[true_label]
    competitors = np.delete(scores, true_label)
    return float(np.min(competitors - true_score))


def tropical_classify(codebook: np.ndarray, observation: np.ndarray) -> int:
    """
    Classify an observation using the tropical codebook.

    Returns the label minimizing tropical score (best match).

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
    observation : np.ndarray of shape (d,)

    Returns
    -------
    int
        The predicted label.

    Complexity
    ----------
    Time: O(cd), Space: O(c)
    """
    scores = tropical_scores_all(codebook, observation)
    return int(np.argmin(scores))


def tropical_argmin_set(codebook: np.ndarray, observation: np.ndarray,
                        tol: float = 1e-10) -> FrozenSet[int]:
    """
    Compute the set of labels achieving minimum tropical score.

    In the non-degenerate case, this is a singleton (the classifier output).
    Ties produce multi-element sets, corresponding to decision boundaries.

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
    observation : np.ndarray of shape (d,)
    tol : float
        Tolerance for floating-point comparison.

    Returns
    -------
    FrozenSet[int]
        The set of optimal labels.

    Complexity
    ----------
    Time: O(cd), Space: O(c)
    """
    scores = tropical_scores_all(codebook, observation)
    min_score = np.min(scores)
    return frozenset(int(i) for i in np.where(np.abs(scores - min_score) < tol)[0])


def certified_robustness_radius(codebook: np.ndarray, observation: np.ndarray,
                                 true_label: int) -> float:
    """
    Compute the certified adversarial robustness radius.

    By the margin stability theorem (Theorem 7.2), any perturbation
    of size ε < margin/2 preserves classification.

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
    observation : np.ndarray of shape (d,)
    true_label : int

    Returns
    -------
    float
        The certified robustness radius (margin/2).
        Non-negative; zero if classification is not certified.

    Complexity
    ----------
    Time: O(cd), Space: O(c)
    """
    m = tropical_margin(codebook, observation, true_label)
    return max(0.0, m / 2.0)


def count_decision_patterns(codebook: np.ndarray, n_samples: int = 10000,
                            seed: Optional[int] = None) -> int:
    """
    Estimate the number of distinct tropical decision patterns.

    By Theorem C, this is at most 2^c where c is the number of labels.

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
    n_samples : int
        Number of random samples to test.
    seed : int, optional
        Random seed for reproducibility.

    Returns
    -------
    int
        Number of distinct decision patterns observed.

    Complexity
    ----------
    Time: O(n_samples * cd), Space: O(n_samples)
    """
    rng = np.random.RandomState(seed)
    c, d = codebook.shape
    patterns = set()

    for _ in range(n_samples):
        x = rng.randn(d) * 3
        pattern = tropical_argmin_set(codebook, x)
        patterns.add(pattern)

    return len(patterns)


def coboundary_margin_bound(local_margins: np.ndarray,
                            lipschitz_constants: np.ndarray,
                            gauge_corrections: np.ndarray) -> float:
    """
    Compute the global margin lower bound from coboundary data.

    Given local margin certificates m_i, Lipschitz constants L_i,
    and gauge corrections b_i, the global adjusted margin is:

        δ = min_i (m_i - L_i * |b_i|) / L_i

    By Theorem B, if δ > 0, classification is certified.

    Parameters
    ----------
    local_margins : np.ndarray of shape (n,)
        Local margin certificates (must be non-negative).
    lipschitz_constants : np.ndarray of shape (n,)
        Lipschitz constants (must be positive).
    gauge_corrections : np.ndarray of shape (n,)
        Gauge corrections from coboundary computation.

    Returns
    -------
    float
        The global adjusted margin δ.

    Complexity
    ----------
    Time: O(n), Space: O(n)
    """
    adjusted = (local_margins - lipschitz_constants * np.abs(gauge_corrections)) / lipschitz_constants
    return float(np.min(adjusted))


def tropical_decision_region_membership(codebook: np.ndarray,
                                         observation: np.ndarray,
                                         label: int) -> bool:
    """
    Check if an observation lies in the decision region of a label.

    An observation is in the decision region of label y if y
    achieves the minimum tropical score (possibly tied).

    Parameters
    ----------
    codebook : np.ndarray of shape (c, d)
    observation : np.ndarray of shape (d,)
    label : int

    Returns
    -------
    bool
        True if label is an argmin of tropical score at observation.

    Complexity
    ----------
    Time: O(cd), Space: O(c)
    """
    return label in tropical_argmin_set(codebook, observation)


# ============================================================
# Example Usage
# ============================================================

if __name__ == '__main__':
    print("Tropical Neural Code Classification — Algorithm Examples")
    print("=" * 60)

    # Create a codebook: 4 classes, 6 neurons
    P = np.array([
        [2.0, 0.0, 1.0, 0.5, 1.5, 0.0],
        [0.0, 2.0, 0.5, 1.0, 0.0, 1.5],
        [1.0, 1.0, 2.0, 0.0, 0.5, 0.5],
        [0.5, 0.5, 0.0, 2.0, 1.0, 1.0],
    ])

    # Observation close to class 0
    x = np.array([2.3, 0.2, 1.1, 0.6, 1.4, 0.1])

    print(f"\nCodebook shape: {P.shape}")
    print(f"Observation: {x}")

    # Score computation
    scores = tropical_scores_all(P, x)
    print(f"\nScores: {scores}")

    # Classification
    label = tropical_classify(P, x)
    print(f"Predicted label: {label}")

    # Margin
    margin = tropical_margin(P, x, label)
    print(f"Margin: {margin:.4f}")

    # Robustness radius
    radius = certified_robustness_radius(P, x, label)
    print(f"Certified robustness radius: {radius:.4f}")

    # Decision pattern counting
    n_patterns = count_decision_patterns(P, n_samples=5000, seed=42)
    print(f"\nDistinct decision patterns: {n_patterns}")
    print(f"Upper bound (2^c): {2**P.shape[0]}")

    # Coboundary bound example
    local_m = np.array([1.0, 0.8, 1.2, 0.9])
    local_L = np.array([0.5, 0.6, 0.4, 0.7])
    local_b = np.array([0.1, -0.2, 0.15, 0.05])
    delta = coboundary_margin_bound(local_m, local_L, local_b)
    print(f"\nCoboundary margin bound: {delta:.4f}")
    if delta > 0:
        print("  ✓ Classification certified via coboundary")
