import math
def diagonal_gap(x):
    assert x > 0
    return math.exp(x) - math.log(x) >= 2.0