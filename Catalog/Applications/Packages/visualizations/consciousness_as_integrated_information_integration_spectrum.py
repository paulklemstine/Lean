def compute_integration_spectrum(weights, n, max_k=None):
    if max_k is None: max_k = n
    spectrum = []
    for k in range(2, min(max_k, n) + 1):
        best = float('inf')
        for assignment in itertools.product(range(k), repeat=n):
            if len(set(assignment)) < k: continue
            flow = sum(weights[i][j] for i in range(n) for j in range(n) if assignment[i] != assignment[j])
            best = min(best, flow)
        spectrum.append(best)
    return spectrum