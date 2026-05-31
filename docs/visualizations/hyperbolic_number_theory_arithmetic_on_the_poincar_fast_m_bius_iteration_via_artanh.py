import math
def moebius_iterate(a: float, n: int) -> float:
    if n == 0: return 0.0
    return math.tanh(n * math.atanh(a))