def semantic_distance(c1, c2):
    from itertools import permutations
    n = len(c1)
    return min(sum(1 for i in range(n) if c1[i] != c2[perm[i]]) for perm in permutations(range(n)))