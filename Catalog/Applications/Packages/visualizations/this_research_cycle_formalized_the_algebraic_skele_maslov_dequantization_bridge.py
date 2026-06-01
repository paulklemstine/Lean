def maslov_hecke_seq(t: float, a: float, q: float, n: int) -> float:
    if n == 0: return 0.0
    if n == 1: return a
    prev2, prev1 = 0.0, a
    for _ in range(2, n + 1):
        x, y = a + prev1, q + prev2
        val = (t * max(x, y) + min(x, y)) / (t + 1) if t + 1 != 0 else min(x, y)
        prev2, prev1 = prev1, val
    return prev1