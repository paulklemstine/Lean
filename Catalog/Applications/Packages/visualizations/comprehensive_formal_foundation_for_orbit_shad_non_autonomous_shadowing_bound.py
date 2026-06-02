def non_autonomous_bound(L, delta, n):
    total = 0.0
    for k in range(n):
        prod = 1.0
        for j in range(k+1, n):
            prod *= L[j]
        total += prod
    return delta * total