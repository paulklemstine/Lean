def approximate_dimension_from_below(n: int, k: int) -> float:
    if n <= 0 or k <= 0:
        return 0.0
    return math.log(k) / (n * math.log(2))