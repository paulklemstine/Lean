import math
def hyp_dist(a: float, b: float) -> float:
    diff = (a - b) / (1 - a * b)
    return math.atanh(abs(diff))