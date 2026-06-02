def dirichlet_sum(theta, N):
    import numpy as np
    s = np.sin(theta)
    if abs(s) < 1e-15:
        return float(N)
    return (np.sin((N+1)*theta) + np.sin(N*theta) - s) / (2*s)