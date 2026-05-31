def chebyshev_trace(t: int, n: int) -> int:
    if n == 0: return 2
    if n == 1: return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr