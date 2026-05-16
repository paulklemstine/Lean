from scipy.optimize import linear_sum_assignment
import numpy as np
def orbit_cost_hungarian(mu, nu):
    C = np.abs(mu[:, None] - nu[None, :])
    row, col = linear_sum_assignment(C)
    return C[row, col].sum()