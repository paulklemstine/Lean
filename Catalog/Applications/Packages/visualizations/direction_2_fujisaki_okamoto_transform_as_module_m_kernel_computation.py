def compute_kernel(matrix, q, n):
    import itertools
    kernel = []
    for v in itertools.product(range(q), repeat=n):
        if all(sum(a*b for a,b in zip(row,v)) % q == 0 for row in matrix):
            kernel.append(v)
    return kernel