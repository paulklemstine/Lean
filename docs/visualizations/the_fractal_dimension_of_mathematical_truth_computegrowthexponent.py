def compute_growth_exponent(count: int, n: int) -> float:
    if n <= 0 or count <= 0:
        return 0.0
    return math.log(count) / (n * math.log(2))