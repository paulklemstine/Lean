import numpy as np
def spectral_gap(T):
    eigs = sorted(np.linalg.eigvalsh((T + T.T)/2), reverse=True)
    return max(0, eigs[0] - eigs[1]) if len(eigs) >= 2 else 1.0