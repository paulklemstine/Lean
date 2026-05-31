def moebius_iter(g: float, n: int) -> float:
    result = 0.0
    for _ in range(n):
        result = (result + g) / (1 + result * g)
    return result