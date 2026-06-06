def verify_contraction(a, b, c, lo, hi):
    import math
    if b * lo + c <= 0 or b * hi + c <= 0:
        return None
    if b > 0:
        rho = abs(math.exp(a) * b / (b * lo + c))
    elif b < 0:
        rho = abs(math.exp(a) * b / (b * hi + c))
    else:
        rho = 0.0
    return rho if rho < 1 else None