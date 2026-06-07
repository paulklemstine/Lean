import math
def threshold_N(b: int, k: int) -> int:
    N = math.ceil(k * math.log(b) / math.log(3))
    while 3**N <= b**k:
        N += 1
    return N