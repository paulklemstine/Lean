import math
def contrapuntal_entropy(b: int, perfect={0,7}) -> float:
    size = 3 if b in perfect else 4
    return math.log2(size)