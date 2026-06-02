def chebyshev_recurrence(theta, n_max):
    import numpy as np
    result = [0.0, 1.0]
    two_cos = 2.0 * np.cos(theta)
    for _ in range(2, n_max + 2):
        result.append(two_cos * result[-1] - result[-2])
    return [result[n] * result[n+1] for n in range(n_max + 1)]