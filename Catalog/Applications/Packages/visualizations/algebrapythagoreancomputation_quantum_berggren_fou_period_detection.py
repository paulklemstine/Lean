import numpy as np
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple, Optional
BERG_MATRICES = {
    'A': np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    'B': np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]]),
    'C': np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
}
BERG_LIST = [BERG_MATRICES['A'], BERG_MATRICES['B'], BERG_MATRICES['C']]
ROOT_TRIPLE = np.array([3, 4, 5])

def certified_period_detection(
    signal: np.ndarray,
    words: List[Tuple[int, ...]],
    noise_bound: float,
    depth: int
) -> Optional[int]:
    """
    Certified period detection on the Berggren tree.

    Given a possibly noisy signal g = f + noise where f is k-prefix-constant
    and ‖noise‖∞ ≤ ε, determine k with certification.

    Algorithm:
        1. Compute wavelet coefficients of g
        2. For each level k from n-1 down to 0:
            - Compute max |detail coeff| at level k
            - If max > noise_threshold(ε, k): mark k as active
        3. Return smallest k such that all levels ≥ k are inactive

    Certification: By the Certified Robust Recovery theorem, if the signal
    detail coefficients are zero and the noise is bounded, the observed
    detail coefficients are bounded by a function of ε. If observed
    coefficients exceed this bound, the signal has genuine structure at that level.

    Complexity: O(3^n · n) for the transform, O(n) for the detection.
    """
    transform = BerggrenWaveletTransform(depth)
    coeffs = transform.forward(signal)

    # Noise threshold at each level
    for k in range(depth - 1, -1, -1):
        level_coeffs = [abs(v) for key, v in coeffs.items()
                       if isinstance(key, tuple) and key[0] == k]
        if not level_coeffs:
            continue
        max_coeff = max(level_coeffs)
        # Threshold based on noise bound and cylinder structure
        threshold = noise_bound * np.sqrt(2)  # Conservative bound
        if max_coeff > threshold:
            return k + 1

    return 0