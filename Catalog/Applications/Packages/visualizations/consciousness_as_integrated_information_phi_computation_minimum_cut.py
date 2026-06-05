def phi(weights):
    n = len(weights)
    if n < 2: return 0.0
    from itertools import combinations
    best = float('inf')
    for size in range(1, n):
        for combo in combinations(range(n), size):
            subset = set(combo)
            complement = set(range(n)) - subset
            cw = sum(weights[i][j] for i in subset for j in complement)
            cw += sum(weights[i][j] for i in complement for j in subset)
            best = min(best, cw)
    return best