import math
def rapidity(x: float) -> float:
    return math.log((1 + x) / (1 - x)) / 2