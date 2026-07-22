import math

def search_dimension(b: int, k: int) -> float:
    if b < 2:
        raise ValueError('b must be >= 2')
    if not (1 <= k <= b):
        raise ValueError('require 1 <= k <= b')
    return math.log(k) / math.log(b)
