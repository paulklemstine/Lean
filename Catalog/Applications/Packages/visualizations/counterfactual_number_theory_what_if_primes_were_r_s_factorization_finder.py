def find_factorizations(S, n, min_factor=2):
    results = []
    if n in S and n >= min_factor:
        results.append([n])
    for s in sorted(s for s in S if s >= max(2, min_factor) and s*s <= n):
        if n % s == 0:
            for sub in find_factorizations(S, n//s, s):
                results.append([s] + sub)
    return results