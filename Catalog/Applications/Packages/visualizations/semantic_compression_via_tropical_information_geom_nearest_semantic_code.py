def nearest_semantic_code(s, codebook):
    """Find the nearest code under tropical Fisher distance."""
    import numpy as np
    def tfd(a, b):
        d = a - b
        return float(np.max(d) - np.min(d))
    dists = [tfd(s, c) for c in codebook]
    best = int(np.argmin(dists))
    return codebook[best], dists[best]