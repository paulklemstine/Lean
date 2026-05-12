#!/usr/bin/env python3
"""
Tropical Barron Duality — Algorithm Implementations

Complete implementations of the algorithms described in the research paper:
1. ThresholdCompress — Deterministic weight pruning
2. GreedyTropicalCompress — Greedy feature selection
3. WitnessCertificateSearch — Optimal witness pair finder
4. TropicalBarronNormEstimator — Numerical Barron norm estimation
5. AtomicCapacityConstructor — Choquet envelope builder

All algorithms include docstrings, type hints, complexity analysis, and
example usage.
"""

import numpy as np
from typing import Tuple, List, Optional, NamedTuple
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class TropicalFeatureFamily:
    """A family of continuous features on [0,1] (discretized).

    Attributes:
        features: shape (n, num_points) — feature evaluations φ_i(x_j)
        domain: shape (num_points,) — domain points
    """
    features: np.ndarray
    domain: np.ndarray

    @property
    def n_features(self) -> int:
        return self.features.shape[0]

    @property
    def n_points(self) -> int:
        return self.features.shape[1]

    @classmethod
    def random_affine(cls, n: int, num_points: int = 500,
                      seed: int = 42) -> 'TropicalFeatureFamily':
        """Generate n random affine features on [0,1]."""
        rng = np.random.RandomState(seed)
        domain = np.linspace(0, 1, num_points)
        slopes = rng.uniform(-5, 5, n)
        intercepts = rng.uniform(-2, 2, n)
        features = slopes[:, None] * domain[None, :] + intercepts[:, None]
        return cls(features=features, domain=domain)


@dataclass
class CompressionResult:
    """Result of a compression algorithm.

    Attributes:
        weights: compressed weight vector
        support_size: number of nonzero weights
        error: sup-norm approximation error
        variation: tropical variation of compressed weights
        original_variation: tropical variation of original weights
    """
    weights: np.ndarray
    support_size: int
    error: float
    variation: float
    original_variation: float


@dataclass
class WitnessResult:
    """Result of witness certificate search.

    Attributes:
        x1_idx, x2_idx: indices of best witness point pair
        gap: witness gap value
        lower_bound: implied lower bound on max |a_i|
    """
    x1_idx: int
    x2_idx: int
    gap: float
    lower_bound: float


@dataclass
class AtomicCapacity:
    """Atomic capacity on a feature space.

    Attributes:
        support_indices: indices of features in the support
        weights: weight for each supported feature
        total_variation: sum of absolute weights
    """
    support_indices: np.ndarray
    weights: np.ndarray
    total_variation: float


# ============================================================
# Core Functions
# ============================================================

def max_plus_envelope(weights: np.ndarray, features: np.ndarray) -> np.ndarray:
    """Compute max_i(a_i + φ_i(x)) for all x.

    Args:
        weights: shape (n,)
        features: shape (n, num_points)

    Returns:
        shape (num_points,)

    Complexity: O(n * num_points) time, O(num_points) space
    """
    return np.max(weights[:, None] + features, axis=0)


def tropical_variation(weights: np.ndarray) -> float:
    """Tropical variation: TV(a) = Σ |a_i|.

    Complexity: O(n) time, O(1) space
    """
    return float(np.sum(np.abs(weights)))


# ============================================================
# Algorithm 1: Threshold Compression
# ============================================================

def threshold_compress(weights: np.ndarray,
                       features: np.ndarray,
                       threshold: float) -> CompressionResult:
    """
    Deterministic threshold-based compression.

    Sets all weights with |a_i| < threshold to zero. By the envelope
    Lipschitz property, the error is at most threshold.

    Args:
        weights: original weight vector, shape (n,)
        features: feature evaluations, shape (n, num_points)
        threshold: pruning threshold τ > 0

    Returns:
        CompressionResult with compressed weights and error bound

    Complexity: O(n * num_points) time
    Guaranteed: error ≤ threshold, TV(compressed) ≤ TV(original)

    Example:
        >>> Phi = TropicalFeatureFamily.random_affine(20)
        >>> w = np.random.randn(20)
        >>> result = threshold_compress(w, Phi.features, 0.5)
        >>> print(f"Kept {result.support_size}/{len(w)} features, error={result.error:.4f}")
    """
    compressed = weights.copy()
    compressed[np.abs(weights) < threshold] = 0.0

    original_env = max_plus_envelope(weights, features)
    compressed_env = max_plus_envelope(compressed, features)

    return CompressionResult(
        weights=compressed,
        support_size=int(np.count_nonzero(compressed)),
        error=float(np.max(np.abs(original_env - compressed_env))),
        variation=tropical_variation(compressed),
        original_variation=tropical_variation(weights),
    )


# ============================================================
# Algorithm 2: Greedy Tropical Compression
# ============================================================

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


# ============================================================
# Algorithm 3: Witness Certificate Search
# ============================================================

def find_best_witness(f_vals: np.ndarray,
                       features: np.ndarray,
                       epsilon: float = 0.0) -> WitnessResult:
    """
    Find the point pair (x₁, x₂) maximizing the witness gap.

    The witness gap is:
        gap(x₁, x₂) = |f(x₁) - f(x₂)| - max_i|φ_i(x₁) - φ_i(x₂)| - 2ε

    A positive gap implies: max_i|a_i| ≥ gap/2 for any ε-approximation.

    Args:
        f_vals: target function values, shape (num_points,)
        features: feature evaluations, shape (n, num_points)
        epsilon: approximation tolerance

    Returns:
        WitnessResult with best pair and lower bound

    Complexity: O(num_points² * n) time
    """
    num_pts = len(f_vals)
    best_gap = -float('inf')
    best_i, best_j = 0, 0

    for i in range(num_pts):
        for j in range(i + 1, num_pts):
            f_diff = abs(f_vals[i] - f_vals[j])
            feat_max_diff = np.max(np.abs(features[:, i] - features[:, j]))
            gap = f_diff - feat_max_diff - 2 * epsilon

            if gap > best_gap:
                best_gap = gap
                best_i, best_j = i, j

    return WitnessResult(
        x1_idx=best_i,
        x2_idx=best_j,
        gap=max(0.0, best_gap),
        lower_bound=max(0.0, best_gap / 2),
    )


# ============================================================
# Algorithm 4: Barron Norm Estimator
# ============================================================

def estimate_barron_norm(f_vals: np.ndarray,
                          features: np.ndarray,
                          epsilon: float,
                          n_trials: int = 5000,
                          seed: int = 42) -> float:
    """
    Estimate the tropical Barron norm via Monte Carlo optimization.

    Samples random weight vectors and keeps the one with minimum
    tropical variation that achieves ε-approximation.

    Args:
        f_vals: target function values, shape (num_points,)
        features: feature evaluations, shape (n, num_points)
        epsilon: approximation tolerance
        n_trials: number of random trials
        seed: random seed

    Returns:
        Upper bound on the Barron norm

    Complexity: O(n_trials * n * num_points) time
    """
    rng = np.random.RandomState(seed)
    n = features.shape[0]
    best_tv = float('inf')

    for _ in range(n_trials):
        # Sample random weights
        w = rng.randn(n) * 3
        env = max_plus_envelope(w, features)
        if np.max(np.abs(f_vals - env)) <= epsilon:
            tv = tropical_variation(w)
            best_tv = min(best_tv, tv)

    return best_tv


# ============================================================
# Algorithm 5: Atomic Capacity Constructor
# ============================================================

def construct_atomic_capacity(weights: np.ndarray,
                                threshold: float = 0.0) -> AtomicCapacity:
    """
    Construct an atomic capacity from a weight vector.

    Creates a finitely-supported capacity on the feature space by
    selecting features with |weight| > threshold.

    Args:
        weights: weight vector, shape (n,)
        threshold: minimum absolute weight to include

    Returns:
        AtomicCapacity with support, weights, and total variation

    Complexity: O(n) time
    """
    support = np.where(np.abs(weights) > threshold)[0]
    active_weights = weights[support]

    return AtomicCapacity(
        support_indices=support,
        weights=active_weights,
        total_variation=float(np.sum(np.abs(active_weights))),
    )


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Barron Duality — Algorithm Examples\n")

    # Setup
    Phi = TropicalFeatureFamily.random_affine(20, num_points=500)
    true_weights = np.array([3, 2, 1.5, 1, 0.8, 0.5, 0.3, 0.2, 0.1, 0.05,
                             -2, -1, -0.5, -0.3, -0.1, 0.08, -0.04, 0.02, -0.01, 0.005])
    f_vals = max_plus_envelope(true_weights, Phi.features)
    print(f"Target: {Phi.n_features}-feature envelope, TV = {tropical_variation(true_weights):.4f}\n")

    # Algorithm 1: Threshold Compression
    print("--- Threshold Compression ---")
    for tau in [0.1, 0.5, 1.0]:
        result = threshold_compress(true_weights, Phi.features, tau)
        print(f"  τ={tau:.1f}: {result.support_size} features, "
              f"error={result.error:.6f}, TV={result.variation:.4f}")

    # Algorithm 2: Greedy Compression
    print("\n--- Greedy Compression ---")
    for budget in [5, 10, 15]:
        result = greedy_tropical_compress(f_vals, Phi.features, budget)
        print(f"  N={budget}: {result.support_size} features, "
              f"error={result.error:.6f}, TV={result.variation:.4f}")

    # Algorithm 3: Witness Certificate
    print("\n--- Witness Certificate Search ---")
    witness = find_best_witness(f_vals, Phi.features)
    print(f"  Best pair: x₁={Phi.domain[witness.x1_idx]:.3f}, "
          f"x₂={Phi.domain[witness.x2_idx]:.3f}")
    print(f"  Gap = {witness.gap:.4f}, Lower bound on max|a_i| = {witness.lower_bound:.4f}")
    print(f"  Actual max|a_i| = {np.max(np.abs(true_weights)):.4f}")

    # Algorithm 4: Barron Norm
    print("\n--- Barron Norm Estimation ---")
    for eps in [0.1, 0.5, 1.0]:
        norm_est = estimate_barron_norm(f_vals, Phi.features, eps)
        print(f"  ε={eps:.1f}: ‖f‖_B ≈ {norm_est:.4f}")

    # Algorithm 5: Atomic Capacity
    print("\n--- Atomic Capacity Construction ---")
    cap = construct_atomic_capacity(true_weights, threshold=0.1)
    print(f"  Support size: {len(cap.support_indices)}")
    print(f"  Total variation: {cap.total_variation:.4f}")
    print(f"  Support indices: {cap.support_indices}")
