def diagonal_iterate(encode, g, steps):
    n = len(g)
    iterates = [g]; current = g
    for _ in range(steps):
        diag = tuple(encode(x)[x] for x in range(n))
        current = tuple(current[diag[x]] for x in range(n))
        iterates.append(current)
    return iterates