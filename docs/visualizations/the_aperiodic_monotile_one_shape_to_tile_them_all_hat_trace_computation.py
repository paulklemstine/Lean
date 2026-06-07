def hat_trace(n: int) -> int:
    if n == 0: return 2
    if n == 1: return 4
    prev2, prev1 = 2, 4
    for _ in range(2, n + 1):
        prev2, prev1 = prev1, 4 * prev1 - prev2
    return prev1