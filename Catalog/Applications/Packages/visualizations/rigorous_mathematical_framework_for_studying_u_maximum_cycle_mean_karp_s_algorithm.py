def compute_max_cycle_mean(W):
    n = W.shape[0]
    d = np.full((n+1, n), -np.inf)
    for i in range(n): d[0][i] = 0.0
    for k in range(1, n+1):
        for i in range(n):
            for j in range(n):
                if d[k-1][j] > -np.inf:
                    d[k][i] = max(d[k][i], d[k-1][j] + W[j,i])
    lam = -np.inf
    for i in range(n):
        if d[n][i] > -np.inf:
            min_r = np.inf
            for k in range(n):
                if d[k][i] > -np.inf:
                    min_r = min(min_r, (d[n][i]-d[k][i])/(n-k))
            lam = max(lam, min_r)
    return lam