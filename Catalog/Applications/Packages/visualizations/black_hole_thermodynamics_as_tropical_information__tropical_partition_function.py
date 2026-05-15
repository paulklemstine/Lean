def tropical_partition(E):
    """Tropical partition function: Z_trop = min_i E(i)."""
    import numpy as np
    return float(np.min(E))