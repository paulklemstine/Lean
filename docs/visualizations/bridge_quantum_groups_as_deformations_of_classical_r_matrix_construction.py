import numpy as np
def r_matrix(q: float) -> np.ndarray:
    R = np.zeros((4, 4))
    R[0, 0] = q
    R[3, 3] = q
    R[1, 2] = 1
    R[2, 1] = 1
    R[2, 2] = q - 1/q
    return R