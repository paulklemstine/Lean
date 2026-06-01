def min_faithful_bits(n: int, k: int) -> int:
    import math
    return math.ceil(n * n * math.log2(k))