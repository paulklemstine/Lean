def estimate_expansion(adj, n, samples=1000):
    import random
    min_ratio = float('inf')
    for _ in range(samples):
        size = random.randint(1, n // 2)
        S = set(random.sample(range(n), size))
        bdry = len({v for u in S for v in adj.get(u, set())} - S)
        min_ratio = min(min_ratio, bdry / len(S))
    return min_ratio