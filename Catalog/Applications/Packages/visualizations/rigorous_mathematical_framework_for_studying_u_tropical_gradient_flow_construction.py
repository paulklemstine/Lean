def tropical_gradient_flow(W):
    n = W.shape[0]
    raw_depth = np.array([-np.max(W[:, i]) for i in range(n)])
    depth = raw_depth - np.min(raw_depth)
    def step(i):
        best_j, best_d = i, depth[i]
        for j in range(n):
            if W[i,j] > 0 and depth[j] < best_d:
                best_j, best_d = j, depth[j]
        return best_j
    return LyapunovDDS(n, step, lambda i: float(depth[i]))