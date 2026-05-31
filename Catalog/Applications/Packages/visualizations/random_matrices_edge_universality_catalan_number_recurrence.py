def catalan_number(n: int) -> int:
    if n == 0:
        return 1
    c = 1
    for k in range(n):
        c = c * (4 * k + 2) // (k + 2)
    return c