def chebyshev_T(n: int, x: float) -> float:
    if n == 0: return 1.0
    if n == 1: return x
    t0, t1 = 1.0, x
    for _ in range(2, n + 1):
        t0, t1 = t1, 2 * x * t1 - t0
    return t1