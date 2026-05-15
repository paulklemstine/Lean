def tropical_channel_output(E, K):
    """Tropical channel: Ch(b) = min_a [E(a) + K(a,b)]."""
    import numpy as np
    return np.min(E[:, None] + K, axis=0)