import math
def iterated_exponential(k, x):
    result = x
    for _ in range(k):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result