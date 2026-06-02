import math

def valley_boundaries(alpha: float) -> tuple[float, float] | None:
    disc = alpha * (alpha - 4.0)
    if disc <= 0:
        return None
    sqrt_d = math.sqrt(disc)
    a = (alpha - sqrt_d) / (2.0 * alpha)
    b = (alpha + sqrt_d) / (2.0 * alpha)
    return (a, b)