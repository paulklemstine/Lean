import math
def hyperbolic_distance(z: complex, w: complex) -> float:
    cross_ratio = abs(z - w) / abs(1 - z.conjugate() * w)
    return 2 * math.atanh(min(cross_ratio, 0.9999999))