def spectral_numerator(n: int, theta: float) -> float:
    import math
    return math.cos(theta) - math.cos((2 * n + 1) * theta)