def growth_exponent(count: int, n: int) -> float:
    if n == 0: return 1.0
    return math.log2(count) / n