def extremal_dark(m, N):
    assert N % m == 0
    q = N // m
    universe = set(range(N))
    return {i: universe - set(range(i*q, (i+1)*q)) for i in range(m)}