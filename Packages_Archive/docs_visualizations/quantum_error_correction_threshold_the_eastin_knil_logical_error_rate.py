def logical_error_rate(c: float, p: float, n: int) -> float:
    x = p
    for _ in range(n):
        x = c * x * x
    return x
