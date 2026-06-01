def trop_hecke_seq(a: int, q: int, n: int) -> int:
    if n == 0: return 0
    if n == 1: return a
    prev2, prev1 = 0, a
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, max(a + prev1, q + prev2)
    return prev1