def find_witness(A, b, c, x_star):
    import numpy as np
    j_star = np.argmax(c + x_star)
    i_star = np.argmin(b - A[:, j_star])
    return j_star, i_star