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

def certified_pruning_depth(
    q: float, initial_radius: float, epsilon: float
) -> int:
    """
    Compute the depth beyond which network layers can be pruned.

    Based on entropy_capacity_ultrametric_barrier: after N layers,
    the compression radius is at most q^N · initial_radius.

    Complexity: O(1).

    Args:
        q: Per-layer contraction ratio
        initial_radius: Compression radius of first layer
        epsilon: Maximum tolerable compression radius

    Returns:
        Minimum depth N such that q^N · initial_radius ≤ ε
    """
    return compute_compression_threshold(q, initial_radius, epsilon)