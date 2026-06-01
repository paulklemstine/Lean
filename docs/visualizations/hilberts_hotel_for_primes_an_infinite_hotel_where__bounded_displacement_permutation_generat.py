def bounded_displacement_permutation(n, k):
    import random
    perm = list(range(n))
    for i in range(n - 1):
        j = random.randint(i, min(n - 1, i + k))
        perm[i], perm[j] = perm[j], perm[i]
    return perm