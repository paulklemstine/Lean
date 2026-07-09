import math

def gamma_integral(N: int = 5000, m: int = 2000) -> float:
    """Midpoint-rule estimate of gamma = int_1^inf (1/floor(x) - 1/x) dx."""
    total: float = 0.0
    for k in range(N):
        a: float = k + 1.0
        h: float = 1.0 / m
        c: float = 1.0 / (k + 1)
        acc: float = math.fsum(c - 1.0 / (a + (j + 0.5) * h) for j in range(m))
        total += acc * h
    return total
