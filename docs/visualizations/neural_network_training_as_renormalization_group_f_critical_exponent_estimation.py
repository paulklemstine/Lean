import numpy as np
def estimate_critical_exponent(trajectory, w_star):
    dists = np.abs(np.array(trajectory) - w_star)
    dists = dists[dists > 1e-15]
    ns = np.arange(len(dists))
    log_dists = np.log(dists)
    slope, _ = np.polyfit(ns, log_dists, 1)
    return -1.0 / slope