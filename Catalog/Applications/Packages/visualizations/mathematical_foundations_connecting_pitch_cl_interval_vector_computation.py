def interval_vector(S: frozenset) -> list:
    from itertools import combinations
    vec = [0] * 6
    for a, b in combinations(sorted(S), 2):
        ic = min((b-a) % 12, 12 - (b-a) % 12)
        if 1 <= ic <= 6:
            vec[ic - 1] += 1
    return vec