def tropical_fisher_seminorm(v):
    """Compute the tropical Fisher seminorm (oscillation) of a vector."""
    import numpy as np
    return float(np.max(v) - np.min(v))