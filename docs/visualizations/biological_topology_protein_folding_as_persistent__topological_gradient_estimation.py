def topological_gradient(coords, delta=0.01):
    import numpy as np
    n = coords.shape[0]
    grad = np.zeros_like(coords)
    base_dm = compute_distance_matrix(coords)
    base_tp = total_persistence(compute_persistence_intervals(base_dm))
    for i in range(n):
        for j in range(3):
            p = coords.copy()
            p[i, j] += delta
            dm = compute_distance_matrix(p)
            tp = total_persistence(compute_persistence_intervals(dm))
            grad[i, j] = (tp - base_tp) / delta
    return grad