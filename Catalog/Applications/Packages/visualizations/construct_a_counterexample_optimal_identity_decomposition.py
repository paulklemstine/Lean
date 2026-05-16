import numpy as np
INF = float("inf")

def optimal_identity_decomposition(n):
    """Construct the optimal rank-n decomposition of I^trop_n."""
    summands = []
    for k in range(n):
        u = np.full(n, INF)
        v = np.full(n, INF)
        u[k] = 0.0
        v[k] = 0.0
        summands.append((u, v))
    return summands

def verify(n):
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0.0)
    summands = optimal_identity_decomposition(n)
    result = np.full((n, n), INF)
    for u, v in summands:
        for i in range(n):
            for j in range(n):
                if u[i] != INF and v[j] != INF:
                    result[i, j] = min(result[i, j], u[i] + v[j])
    return np.array_equal(I, result)

for n in [2, 3, 5, 10, 20]:
    print(f"I^trop({n}): verified = {verify(n)}, factor_rank = {n}")
