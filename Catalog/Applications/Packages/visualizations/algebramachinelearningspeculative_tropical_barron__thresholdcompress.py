import numpy as np
from typing import Tuple, List, Optional, NamedTuple
from dataclasses import dataclass

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