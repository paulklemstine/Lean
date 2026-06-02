def contraction_exponent(k: int, s: int) -> float:
    import math
    return k * math.log(2) - s * math.log(3)