def satake_transform(f, x):
    from itertools import permutations
    n = len(x)
    return min(f([x[p[i]] for i in range(n)]) for p in permutations(range(n)))