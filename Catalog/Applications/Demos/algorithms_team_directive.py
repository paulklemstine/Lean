#!/usr/bin/env python3
"""
Tropical Separation Classifier — Algorithms

Implements the algorithms from the research paper with complete
docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Optional, Tuple, List


def tropical_score(w: np.ndarray, phi: np.ndarray) -> float:
    """
    Compute the tropical (max-plus) score.
    
    The tropical score is defined as:
        score(w, φ) = max_i (w_i + φ_i)
    
    This is the fundamental operation in max-plus algebra,
    replacing the usual inner product ⟨w, φ⟩ = Σ w_i · φ_i.
    
    Args:
        w: Weight vector of shape (n_features,)
        phi: Feature vector of shape (n_features,)
    
    Returns:
        The tropical score (scalar)
    
    Complexity: O(n_features) time, O(1) space
    
    Example:
        >>> tropical_score(np.array([0, -10]), np.array([8, 5]))
        8.0  # max(0+8, -10+5) = max(8, -5) = 8
    """
    return float(np.max(w + phi))


def tropical_score_batch(w: np.ndarray, phi_matrix: np.ndarray) -> np.ndarray:
    """
    Compute tropical scores for a batch of feature vectors.
    
    Args:
        w: Weight vector of shape (n_features,)
        phi_matrix: Feature matrix of shape (n_samples, n_features)
    
    Returns:
        Array of tropical scores, shape (n_samples,)
    
    Complexity: O(n_samples * n_features) time
    """
    return np.max(w[np.newaxis, :] + phi_matrix, axis=1)


def find_separating_coordinate(
    phi: np.ndarray,
    P_idx: List[int],
    N_idx: List[int]
) -> Tuple[Optional[int], float]:
    """
    Find the best uniformly separating coordinate.
    
    A coordinate i is "uniformly separating" if:
        min_{p ∈ P} φ(p, i) > max_{n ∈ N} φ(n, i)
    
    Returns the coordinate with the largest gap, or None if no
    coordinate uniformly separates.
    
    Args:
        phi: Feature matrix of shape (n_samples, n_features)
        P_idx: Indices of positive samples
        N_idx: Indices of negative samples
    
    Returns:
        (coord_index, min_gap) or (None, 0.0)
    
    Complexity: O(n_features * (|P| + |N|)) time
    
    Example:
        >>> phi = np.array([[10, 1], [8, 2], [3, 5], [2, 7]])
        >>> find_separating_coordinate(phi, [0,1], [2,3])
        (0, 5.0)  # Coordinate 0 separates with gap 5
    """
    n_features = phi.shape[1]
    best_coord = None
    best_gap = 0.0
    
    phi_P = phi[P_idx]  # (|P|, n_features)
    phi_N = phi[N_idx]  # (|N|, n_features)
    
    for i in range(n_features):
        min_pos = np.min(phi_P[:, i])
        max_neg = np.max(phi_N[:, i])
        gap = min_pos - max_neg
        if gap > best_gap:
            best_coord = i
            best_gap = gap
    
    return best_coord, best_gap


def construct_tropical_classifier(
    phi: np.ndarray,
    P_idx: List[int],
    N_idx: List[int],
    i0: int
) -> Tuple[np.ndarray, float]:
    """
    Construct a tropical classifier with certified margin.
    
    Given a separating coordinate i0, constructs a weight vector w
    and computes the certified margin γ such that:
        ∀ p ∈ P, n ∈ N: score(w, φ(p)) ≥ score(w, φ(n)) + γ
    
    The weight construction follows the formal proof:
    1. Compute M = Σ_{x ∈ P∪N} Σ_i |φ(x,i) - φ(x,i0)|
    2. Set w[i0] = 0, w[i] = -M for i ≠ i0
    3. Compute γ = min_{p,n} (φ(p,i0) - φ(n,i0))
    
    This makes the tropical score reduce to φ(x, i0) for all x ∈ P ∪ N,
    since the penalty -M suppresses all other coordinates.
    
    Args:
        phi: Feature matrix of shape (n_samples, n_features)
        P_idx: Indices of positive samples
        N_idx: Indices of negative samples
        i0: Separating coordinate index
    
    Returns:
        (w, gamma): Weight vector and certified margin
    
    Complexity: O((|P| + |N|) * n_features) time, O(n_features) space
    
    Theorem guarantee: gamma > 0 when i0 uniformly separates P from N.
    """
    all_idx = P_idx + N_idx
    n_features = phi.shape[1]
    
    # Step 1: Compute suppression bound
    M = 0.0
    for x in all_idx:
        for i in range(n_features):
            M += abs(phi[x, i] - phi[x, i0])
    
    # Step 2: Construct weight vector
    w = np.full(n_features, -M)
    w[i0] = 0.0
    
    # Step 3: Compute margin
    gamma = float('inf')
    for p in P_idx:
        for n in N_idx:
            gap = phi[p, i0] - phi[n, i0]
            gamma = min(gamma, gap)
    
    return w, gamma


def construct_tighter_classifier(
    phi: np.ndarray,
    P_idx: List[int],
    N_idx: List[int],
    i0: int
) -> Tuple[np.ndarray, float]:
    """
    Construct a tropical classifier with tighter weight bounds.
    
    Instead of the global suppression bound M, uses per-point bounds
    to reduce the magnitude of negative weights. The margin is identical,
    but the weight vector has smaller magnitude, improving numerical stability.
    
    Uses M = max_{x ∈ P∪N} max_{i≠i0} (φ(x,i) - φ(x,i0)) + 1
    instead of the sum-based bound.
    
    Args:
        phi: Feature matrix
        P_idx: Positive indices
        N_idx: Negative indices
        i0: Separating coordinate
    
    Returns:
        (w, gamma): Weight vector and certified margin
    """
    all_idx = P_idx + N_idx
    n_features = phi.shape[1]
    
    # Tighter suppression bound
    M = 0.0
    for x in all_idx:
        for i in range(n_features):
            if i != i0:
                M = max(M, phi[x, i] - phi[x, i0])
    M += 1.0  # Strict inequality margin
    
    # Weight vector
    w = np.full(n_features, -M)
    w[i0] = 0.0
    
    # Margin
    gamma = float('inf')
    for p in P_idx:
        for n in N_idx:
            gamma = min(gamma, phi[p, i0] - phi[n, i0])
    
    return w, gamma


def verify_tropical_separation(
    phi: np.ndarray,
    w: np.ndarray,
    gamma: float,
    P_idx: List[int],
    N_idx: List[int],
    tol: float = 1e-10
) -> Tuple[bool, Optional[Tuple[int, int, float]]]:
    """
    Verify that w achieves tropical separation with margin gamma.
    
    Checks: ∀ p ∈ P, n ∈ N: score(w, φ(p)) ≥ score(w, φ(n)) + γ
    
    Args:
        phi: Feature matrix
        w: Weight vector
        gamma: Claimed margin
        P_idx: Positive indices
        N_idx: Negative indices
        tol: Numerical tolerance
    
    Returns:
        (verified, counterexample):
            verified is True if separation holds
            counterexample is (p, n, actual_gap) if violated
    """
    for p in P_idx:
        score_p = tropical_score(w, phi[p])
        for n in N_idx:
            score_n = tropical_score(w, phi[n])
            actual_gap = score_p - score_n
            if actual_gap < gamma - tol:
                return False, (p, n, actual_gap)
    return True, None


def tropical_coord_margin(
    phi: np.ndarray,
    i0: int,
    P_idx: List[int],
    N_idx: List[int]
) -> float:
    """
    Compute the coordinate margin: min_{p∈P, n∈N} (φ(p,i0) - φ(n,i0)).
    
    This is the exact margin achievable by the optimal tropical classifier
    using coordinate i0 as the separating coordinate.
    
    Args:
        phi: Feature matrix
        i0: Coordinate index
        P_idx: Positive indices
        N_idx: Negative indices
    
    Returns:
        The coordinate margin
    """
    return min(
        phi[p, i0] - phi[n, i0]
        for p in P_idx
        for n in N_idx
    )


def full_tropical_pipeline(
    phi: np.ndarray,
    P_idx: List[int],
    N_idx: List[int],
    verbose: bool = True
) -> Optional[Tuple[np.ndarray, float, int]]:
    """
    Complete tropical classification pipeline.
    
    1. Search for a separating coordinate
    2. Construct the classifier
    3. Verify the separation
    
    Args:
        phi: Feature matrix (n_samples, n_features)
        P_idx: Positive sample indices
        N_idx: Negative sample indices
        verbose: Print progress
    
    Returns:
        (w, gamma, i0) or None if no separating coordinate exists
    """
    if verbose:
        print(f"Searching {phi.shape[1]} coordinates for separation...")
    
    i0, gap = find_separating_coordinate(phi, P_idx, N_idx)
    
    if i0 is None:
        if verbose:
            print("No uniformly separating coordinate found.")
        return None
    
    if verbose:
        print(f"Found separating coordinate {i0} with gap {gap:.6f}")
    
    w, gamma = construct_tighter_classifier(phi, P_idx, N_idx, i0)
    
    if verbose:
        print(f"Constructed weight vector (max |w_i| = {np.max(np.abs(w)):.2f})")
        print(f"Certified margin: γ = {gamma:.6f}")
    
    verified, cex = verify_tropical_separation(phi, w, gamma, P_idx, N_idx)
    
    if verbose:
        print(f"Verification: {'PASSED' if verified else 'FAILED'}")
        if not verified:
            print(f"  Counterexample: points {cex[0]}, {cex[1]}, gap = {cex[2]:.6f}")
    
    return (w, gamma, i0) if verified else None


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Tropical Separation Classifier — Algorithm Demo\n")
    
    # Paper example
    phi = np.array([
        [10.0, 1.0],
        [8.0,  2.0],
        [3.0,  5.0],
        [2.0,  7.0],
    ])
    
    result = full_tropical_pipeline(phi, [0, 1], [2, 3])
    if result:
        w, gamma, i0 = result
        print(f"\nClassifier weights: {w}")
        print(f"Margin: {gamma}")
        
        print("\nScores:")
        scores = tropical_score_batch(w, phi)
        for i, s in enumerate(scores):
            print(f"  Point {i}: {s:.2f}")
