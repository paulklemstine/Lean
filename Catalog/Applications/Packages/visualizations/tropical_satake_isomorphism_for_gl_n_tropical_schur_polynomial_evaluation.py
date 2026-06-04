def tropical_schur(w, x):
    from itertools import permutations
    n = len(w)
    return min(sum(w[p[i]] * x[i] for i in range(n)) for p in permutations(range(n)))