import numpy as np
def maslov(a, b, eps):
    m = max(a/eps, b/eps)
    return eps * (m + np.log(np.exp(a/eps - m) + np.exp(b/eps - m)))