def erdos_ramsey_bound(k):
    edges = k * (k-1) // 2
    threshold = 2 ** edges
    best_n = 1
    for n in range(1, 100000):
        if 2 * math.comb(n, k) < threshold:
            best_n = n
        else:
            break
    return best_n