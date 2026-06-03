def odd_cosine_sum(N: int, theta: float) -> float:
    import math
    return math.sin(2 * N * theta) / (2 * math.sin(theta))