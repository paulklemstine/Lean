def cascade_throughput(probs: list[float], base: float) -> float:
    result = base
    for p in probs:
        result *= p
    return result