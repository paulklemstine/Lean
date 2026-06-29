"""
Algorithms for Tropical Persistence Stability and Network Robustness.

Implements the core computational methods from the tropical bottleneck
stability framework. All algorithms have certified correctness guarantees
backed by the formal proofs in the Lean development.

Key algorithms:
- weight_sup_dist: O(|E|) sup-norm distance
- certified_barcode_shift_bound: O(|E|) certified interleaving bound
- robustness_certificate: O(|E|) margin computation
- tropical_rank_function: O(|E|) rank function evaluation
- tropical_sublevel_filtration: O(|E| log |E|) full filtration
"""

from __future__ import annotations
import numpy as np
from typing import List, Tuple, Dict, Optional


def weight_sup_dist(w: np.ndarray, w_prime: np.ndarray) -> float:
    """Compute the sup-norm distance between two weight functions.

    This is the fundamental metric on the space of weighted filtrations.
    By Theorem 3.3 (optimal_interleaving_eq_supDist), this equals the
    interleaving distance.

    Args:
        w: Edge weight array of shape (m,)
        w_prime: Edge weight array of shape (m,)

    Returns:
        max_e |w(e) - w'(e)|

    Complexity: O(m) time, O(1) space.

    Example:
        >>> w = np.array([1.0, 2.0, 3.0])
        >>> w_prime = np.array([1.1, 1.8, 3.2])
        >>> weight_sup_dist(w, w_prime)
        0.2
    """
    return float(np.max(np.abs(w - w_prime)))


def certified_barcode_shift_bound(w: np.ndarray, w_prime: np.ndarray) -> float:
    """Compute a certified upper bound on barcode displacement.

    By certifiedBarcodeShiftBound_correct, the returned value ε guarantees
    that the two weight functions are ε-interleaved. By tightness
    (certifiedBarcodeShiftBound_tight), no smaller ε suffices.

    Args:
        w: Original edge weights
        w_prime: Perturbed edge weights

    Returns:
        Certified interleaving bound ε = ‖w - w'‖∞

    Complexity: O(m) time.
    """
    return weight_sup_dist(w, w_prime)


def tropical_sublevel_set(w: np.ndarray, t: float) -> np.ndarray:
    """Compute the sublevel set F_w(t) = {e : w(e) ≤ t}.

    Args:
        w: Edge weight array
        t: Threshold

    Returns:
        Boolean array indicating membership in the sublevel set.
    """
    return w <= t


def tropical_rank_function(w: np.ndarray, t: float) -> int:
    """Compute the tropical rank function ρ_w(t) = |F_w(t)|.

    Args:
        w: Edge weight array
        t: Threshold

    Returns:
        Number of edges with weight ≤ t.

    Complexity: O(m) time.
    """
    return int(np.sum(w <= t))


def tropical_rank_function_array(w: np.ndarray, thresholds: np.ndarray) -> np.ndarray:
    """Compute the rank function at multiple thresholds.

    Args:
        w: Edge weight array of shape (m,)
        thresholds: Array of thresholds of shape (k,)

    Returns:
        Array of rank values of shape (k,).

    Complexity: O(m * k) time, or O(m log m + k) with sorting.
    """
    sorted_w = np.sort(w)
    return np.searchsorted(sorted_w, thresholds, side='right')


def merge_time(w: np.ndarray) -> float:
    """Compute the merge time τ(w) = max_e w(e).

    The merge time is the threshold at which all edges have entered
    the filtration. By mergeTime_lipschitz, this is 1-Lipschitz.

    Args:
        w: Edge weight array

    Returns:
        Maximum edge weight.
    """
    return float(np.max(w))


def min_critical_value(w: np.ndarray) -> float:
    """Compute the minimum critical value μ(w) = min_e w(e).

    By minCriticalValue_lipschitz, this is 1-Lipschitz.

    Args:
        w: Edge weight array

    Returns:
        Minimum edge weight.
    """
    return float(np.min(w))


def weight_range(w: np.ndarray) -> float:
    """Compute the weight range τ(w) - μ(w).

    By weight_range_lipschitz, this is 2-Lipschitz.

    Args:
        w: Edge weight array

    Returns:
        Range of edge weights.
    """
    return merge_time(w) - min_critical_value(w)


def has_long_bar(w: np.ndarray, L: float) -> bool:
    """Check if the weight function has a bar of length ≥ L.

    Args:
        w: Edge weight array
        L: Minimum bar length

    Returns:
        True if weight_range(w) ≥ L.
    """
    return weight_range(w) >= L


def robustness_certificate(w: np.ndarray, L: float) -> float:
    """Compute the robustness margin for a long-bar event.

    By long_bar_robust_under_weight_perturbation, if the margin is δ,
    then any perturbation with ‖Δw‖∞ < δ/2 preserves the event
    hasLongBar(w, L).

    Args:
        w: Edge weight array
        L: Target bar length

    Returns:
        Margin δ such that perturbations < δ/2 preserve the feature.
        Returns 0 if the feature is not present.

    Complexity: O(m) time.

    Example:
        >>> w = np.array([1.0, 3.0, 5.0, 7.0])
        >>> robustness_certificate(w, 4.0)
        2.0
        >>> # Any perturbation < 1.0 preserves the bar of length 4
    """
    margin = weight_range(w) - L
    return max(0.0, margin)


def tropical_sublevel_filtration(w: np.ndarray) -> List[Tuple[float, int]]:
    """Compute the full sublevel filtration.

    Returns the sequence of (threshold, rank) pairs at which the
    rank function changes. These are the critical values of the filtration.

    Args:
        w: Edge weight array

    Returns:
        List of (critical_value, rank_after) pairs, sorted by threshold.

    Complexity: O(m log m) time.
    """
    sorted_weights = np.sort(w)
    events = []
    for i, t in enumerate(sorted_weights):
        events.append((float(t), i + 1))
    return events


def interleaving_distance(w: np.ndarray, w_prime: np.ndarray) -> float:
    """Compute the exact interleaving distance.

    By optimal_interleaving_eq_supDist, this equals the sup-norm distance.

    Args:
        w: First weight function
        w_prime: Second weight function

    Returns:
        Interleaving distance = ‖w - w'‖∞.
    """
    return weight_sup_dist(w, w_prime)


def verify_interleaving(w: np.ndarray, w_prime: np.ndarray, eps: float,
                         thresholds: np.ndarray) -> bool:
    """Verify that two weight functions are ε-interleaved at given thresholds.

    Checks both directions of the interleaving:
    ρ_w(t) ≤ ρ_{w'}(t + ε) and ρ_{w'}(t) ≤ ρ_w(t + ε)

    Args:
        w: First weight function
        w_prime: Second weight function
        eps: Interleaving parameter
        thresholds: Thresholds at which to check

    Returns:
        True if interleaving holds at all given thresholds.
    """
    rho_w = tropical_rank_function_array(w, thresholds)
    rho_w_shifted = tropical_rank_function_array(w, thresholds + eps)
    rho_wp = tropical_rank_function_array(w_prime, thresholds)
    rho_wp_shifted = tropical_rank_function_array(w_prime, thresholds + eps)

    forward = np.all(rho_w <= rho_wp_shifted)
    reverse = np.all(rho_wp <= rho_w_shifted)
    return bool(forward and reverse)


# ── Example usage ──

if __name__ == "__main__":
    np.random.seed(42)

    # Create a weighted graph (10 edges)
    m = 10
    w = np.random.uniform(0, 10, m)
    print(f"Original weights: {w.round(2)}")
    print(f"Merge time: {merge_time(w):.2f}")
    print(f"Min critical value: {min_critical_value(w):.2f}")
    print(f"Weight range: {weight_range(w):.2f}")

    # Perturb
    eps = 0.5
    noise = np.random.uniform(-eps, eps, m)
    w_prime = w + noise
    print(f"\nPerturbation bound: {eps}")
    print(f"Actual sup-dist: {weight_sup_dist(w, w_prime):.4f}")

    # Certified bound
    bound = certified_barcode_shift_bound(w, w_prime)
    print(f"Certified interleaving bound: {bound:.4f}")

    # Robustness certificate
    L = 5.0
    margin = robustness_certificate(w, L)
    print(f"\nLong bar (L={L}) present: {has_long_bar(w, L)}")
    print(f"Robustness margin: {margin:.4f}")
    print(f"Max allowable perturbation: {margin/2:.4f}")

    # Verify interleaving
    thresholds = np.linspace(min(w.min(), w_prime.min()) - 1,
                              max(w.max(), w_prime.max()) + 1, 1000)
    valid = verify_interleaving(w, w_prime, bound, thresholds)
    print(f"\nInterleaving verified: {valid}")
