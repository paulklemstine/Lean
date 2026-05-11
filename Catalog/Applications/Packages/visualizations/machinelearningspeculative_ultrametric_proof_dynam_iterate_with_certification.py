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

def iterate_with_certification(
    F: Callable[[np.ndarray], np.ndarray],
    x0: np.ndarray,
    q: float,
    epsilon: float,
    max_iter: int = 10000,
    dist: Optional[Callable[[np.ndarray, np.ndarray], float]] = None,
) -> Tuple[np.ndarray, int, float]:
    """
    Iterate F from x0 until the compression threshold ε is reached.

    Based on certified_orbit_radius and compression_threshold_exists theorems.
    Uses the diagonal stability guarantee: step distances are monotone decreasing,
    so we can safely stop as soon as one step is below ε.

    Algorithm:
        1. Compute x_{n+1} = F(x_n)
        2. Check d(x_n, x_{n+1}) ≤ ε
        3. Return x_N when threshold is met

    Complexity: O(N · cost(F)) where N = O(log(1/ε) / log(1/q)).

    Args:
        F: Contractive map
        x0: Initial point
        q: Contraction ratio (for certification, not used in iteration)
        epsilon: Target accuracy
        max_iter: Safety limit on iterations
        dist: Distance function (default: L-infinity)

    Returns:
        (final_point, num_iterations, final_step_distance)

    Certificate: By iterate_step_bound_geometric, the returned point satisfies
        d(x_N, F(x_N)) ≤ ε, and by certified_orbit_radius, all subsequent
        iterates remain within d(F(x0), x0) of x0.
    """
    if dist is None:
        dist = lambda a, b: float(np.max(np.abs(a - b)))

    current = x0.copy()
    for n in range(max_iter):
        next_val = F(current)
        step_dist = dist(current, next_val)
        if step_dist <= epsilon:
            return next_val, n + 1, step_dist
        current = next_val

    return current, max_iter, dist(current, F(current))