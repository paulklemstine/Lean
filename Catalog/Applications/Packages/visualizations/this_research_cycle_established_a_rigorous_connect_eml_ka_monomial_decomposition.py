def eml_ka_monomial(a: float, b: float, x: float, y: float) -> float:
    import math
    return math.exp(a * math.log(x) + b * math.log(y))