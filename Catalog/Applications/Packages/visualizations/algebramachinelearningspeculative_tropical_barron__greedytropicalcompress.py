import numpy as np
from typing import Tuple, List, Optional, NamedTuple
from dataclasses import dataclass

def greedy_tropical_compress(target_vals: np.ndarray,
                              features: np.ndarray,
                              budget: int) -> CompressionResult:
    """
    Greedy feature selection for tropical compression.

    Iteratively selects the feature that best reduces the approximation
    error, one at a time, up to the budget.

    Args:
        target_vals: target function values, shape (num_points,)
        features: feature evaluations, shape (n, num_points)
        budget: maximum number of features to select (N)

    Returns:
        CompressionResult with greedy-selected features

    Complexity: O(budget * n * num_points) time per iteration
    """
    n, num_pts = features.shape
    selected = []
    weights = np.full(n, -1e10)  # Very negative = inactive

    for step in range(min(budget, n)):
        best_i = -1
        best_w = 0.0
        best_error = float('inf')

        for i in range(n):
            if i in selected:
                continue

            # Try adding feature i with optimal weight
            trial_weights = weights.copy()
            # Optimal weight: minimize max|target - env|
            # A good heuristic: w_i = median(target - φ_i)
            residuals = target_vals - features[i]
            w_opt = np.median(residuals)
            trial_weights[i] = w_opt

            env = max_plus_envelope(trial_weights, features)
            err = np.max(np.abs(target_vals - env))

            if err < best_error:
                best_error = err
                best_i = i
                best_w = w_opt

        if best_i < 0:
            break

        selected.append(best_i)
        weights[best_i] = best_w

    # Clean up: set unselected weights to very negative
    final_weights = np.zeros(n)
    for i in selected:
        final_weights[i] = weights[i]

    # Recompute with only selected features active
    active_weights = np.full(n, -1e10)
    for i in selected:
        active_weights[i] = weights[i]

    env = max_plus_envelope(active_weights, features)
    error = float(np.max(np.abs(target_vals - env)))

    return CompressionResult(
        weights=final_weights,
        support_size=len(selected),
        error=error,
        variation=tropical_variation(final_weights),
        original_variation=0.0,  # Not applicable for greedy
    )