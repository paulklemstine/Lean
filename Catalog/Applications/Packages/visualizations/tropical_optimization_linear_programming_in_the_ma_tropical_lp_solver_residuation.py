def solve_tropical_lp(A, b, c):
    import numpy as np
    x_star = np.array([np.min(b - A[:, j]) for j in range(A.shape[1])])
    obj = np.max(c + x_star)
    return x_star, obj