def hyp_dist(z: complex, w: complex) -> float:
    import math
    t = abs((z - w) / (1.0 - w.conjugate() * z))
    return 2.0 * math.atanh(min(t, 0.9999999))