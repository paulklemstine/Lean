import numpy as np
from typing import Callable, Tuple, Optional
import numpy as np
from algorithms import (
    compute_compression_threshold,
    iterate_with_certification,
    orbit_separation_bound,
    verify_ultrametric,
)
import numpy as np
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import base64
from io import BytesIO

def compute_compression_threshold(
    q: float, d0: float, epsilon: float
) -> int:
    """
    Compute the minimal iteration count N such that q^N · d0 ≤ ε.

    Based on compression_threshold_exists theorem.

    Algorithm:
        N = ⌈log(ε / d0) / log(q)⌉

    Complexity: O(1) time and space.

    Args:
        q: Contraction ratio, 0 ≤ q < 1
        d0: Initial compression radius d(F(x), x)
        epsilon: Target accuracy ε > 0

    Returns:
        Minimal N such that q^N · d0 ≤ ε

    Examples:
        >>> compute_compression_threshold(0.5, 100.0, 0.01)
        14
        >>> compute_compression_threshold(0.9, 1.0, 0.001)
        66
    """
    if d0 <= 0:
        return 0
    if q <= 0:
        return 1 if d0 > epsilon else 0
    if epsilon >= d0:
        return 0
    return int(np.ceil(np.log(epsilon / d0) / np.log(q)))