def braid_permutation(n, word):
    perm = list(range(n))
    for g in word:
        if 0 <= g.idx < n - 1:
            perm[g.idx], perm[g.idx + 1] = perm[g.idx + 1], perm[g.idx]
    return perm