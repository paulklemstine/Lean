def trop_mv(A, v):
    import numpy as np
    return np.min(A + v[np.newaxis, :], axis=1)