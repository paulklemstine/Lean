import numpy as np
def spectral_gap(T):
    eigs = np.linalg.eigvals(T)
    mags = sorted(np.abs(eigs), reverse=True)
    return float(mags[0] - mags[1]) if len(mags) >= 2 else 0.0