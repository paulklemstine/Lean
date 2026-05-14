import numpy as np
INF = float('inf')

def karp_cycle_mean(W):
    n = W.shape[0]
    D = np.full((n+1, n), INF)
    D[0,:] = 0.0
    for k in range(1, n+1):
        for v in range(n):
            for u in range(n):
                if W[u,v] < INF:
                    D[k,v] = min(D[k,v], D[k-1,u] + W[u,v])
    mu = INF
    for v in range(n):
        if D[n,v] < INF:
            max_r = -INF
            for k in range(n):
                if D[k,v] < INF:
                    max_r = max(max_r, (D[n,v]-D[k,v])/(n-k))
            mu = min(mu, max_r)
    return mu

W = np.array([[INF, 1, INF], [INF, INF, 2], [3, INF, INF]])
print(f"Min cycle mean: {karp_cycle_mean(W):.2f}")  # Should be 2.0
