def q_integer(q: float, n: int) -> float:
    if n == 0:
        return 0.0
    return sum(q ** (n - 1 - 2 * k) for k in range(n))