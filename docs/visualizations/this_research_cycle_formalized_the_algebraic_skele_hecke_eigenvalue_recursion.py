def hecke_seq(a: int, q: int, n: int) -> int:
    if n == 0: return 1
    if n == 1: return a
    prev2, prev1 = 1, a
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, a * prev1 - q * prev2
    return prev1