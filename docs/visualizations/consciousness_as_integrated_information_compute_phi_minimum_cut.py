def compute_phi(weights, n):
    if n <= 1: return 0.0
    best = float('inf')
    for size in range(1, n):
        for subset in itertools.combinations(range(n), size):
            a_set = set(subset)
            complement = set(range(n)) - a_set
            ci = sum(weights[i][j] for i in a_set for j in complement) + sum(weights[i][j] for i in complement for j in a_set)
            best = min(best, ci)
    return best