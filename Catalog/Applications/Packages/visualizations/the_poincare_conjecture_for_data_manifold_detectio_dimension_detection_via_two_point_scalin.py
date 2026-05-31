def detect_dimension(X, n1, n2, seed=42):
    import numpy as np
    rng = np.random.default_rng(seed)
    idx1 = rng.choice(len(X), n1, replace=False)
    idx2 = rng.choice(len(X), n2, replace=False)
    e1 = poincare_threshold_fast(X[idx1])
    e2 = poincare_threshold_fast(X[idx2])
    slope = (np.log(e2) - np.log(e1)) / (np.log(n2) - np.log(n1))
    return -1.0 / slope if slope != 0 else float('inf')