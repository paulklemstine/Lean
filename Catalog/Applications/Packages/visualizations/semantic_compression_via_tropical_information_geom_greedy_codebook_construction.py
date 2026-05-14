def greedy_codebook(sources, K):
    """Build codebook by farthest-point insertion."""
    import numpy as np
    def tfd(a, b):
        d = a - b
        return float(np.max(d) - np.min(d))
    def seminorm(v):
        return float(np.max(v) - np.min(v))
    cb = [sources[int(np.argmax([seminorm(s) for s in sources]))]]
    used = {0}
    for _ in range(K - 1):
        best_j, best_d = -1, -1
        for j, s in enumerate(sources):
            if j not in used:
                d = min(tfd(s, c) for c in cb)
                if d > best_d:
                    best_j, best_d = j, d
        if best_j < 0: break
        cb.append(sources[best_j])
        used.add(best_j)
    return cb