def fenchel_young_gap(x: float, s: float) -> float:
    import math
    return math.exp(x) + s * math.log(s) - s - x * s