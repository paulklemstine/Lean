def optimal_recentering(v):
    """Find the shift minimizing max absolute deviation."""
    import numpy as np
    M, m = float(np.max(v)), float(np.min(v))
    return (M + m) / 2, (M - m) / 2