import numpy as np
def orbit_cost_sorted(mu, nu):
    return np.sum(np.abs(np.sort(mu) - np.sort(nu)))