def chebyshev_sequence(N: int, theta: float) -> list[float]:
    import math
    result = [0.0, math.sin(theta)]
    two_cos = 2 * math.cos(theta)
    for k in range(2, N + 1):
        result.append(two_cos * result[-1] - result[-2])
    return result