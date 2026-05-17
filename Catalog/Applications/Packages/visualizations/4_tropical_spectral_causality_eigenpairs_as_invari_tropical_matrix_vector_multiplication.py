def trop_mat_vec_mul(A, v):
    """Min-plus matrix-vector product: O(n^2)"""
    import numpy as np
    return np.min(A + v[np.newaxis, :], axis=1)