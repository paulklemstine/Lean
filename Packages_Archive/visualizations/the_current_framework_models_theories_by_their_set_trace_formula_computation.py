def trace_periodic_count(step, states, n):
    """Compute periodic point count via the trace formula tr(A^n)."""
    k = len(states)
    idx = {s: i for i, s in enumerate(states)}
    # Build transition matrix
    A = [[0]*k for _ in range(k)]
    for i, s in enumerate(states):
        A[i][idx[step[s]]] = 1
    # Matrix power by repeated squaring
    def mat_mul(X, Y):
        return [[sum(X[i][l]*Y[l][j] for l in range(k)) for j in range(k)] for i in range(k)]
    result = [[int(i==j) for j in range(k)] for i in range(k)]
    base = [row[:] for row in A]
    m = n
    while m > 0:
        if m % 2: result = mat_mul(result, base)
        base = mat_mul(base, base)
        m //= 2
    return sum(result[i][i] for i in range(k))

step = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
for n in range(8):
    print(f'tr(A^{n}) = {trace_periodic_count(step, list(range(6)), n)}')