def cheb_trace(t: int, n: int) -> int:
    if n == 0: return 2
    if n == 1: return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b