def archimedean_bound(epsilon):
    N = 1
    while N * epsilon < 1:
        N += 1
    return N