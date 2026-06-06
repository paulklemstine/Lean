def estimate_k(x, E, N=20):
    y, deflections = x.copy(), []
    for _ in range(N):
        deflections.append(np.linalg.norm(E(y) - y))
        y = E(y)
    ratios = [deflections[i+1]/deflections[i] for i in range(N-1) if deflections[i] > 1e-15]
    return float(np.median(ratios))