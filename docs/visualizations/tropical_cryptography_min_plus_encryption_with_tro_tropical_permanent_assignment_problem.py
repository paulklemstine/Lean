def tropical_permanent(A):
    n = A.shape[0]
    best = float('inf')
    for perm in permutations(range(n)):
        cost = sum(A[i, perm[i]] for i in range(n))
        best = min(best, cost)
    return best