def neural_info_defect(n: int, k: int, m: int) -> float:
    import math
    if m >= k or m <= 0 or k <= 0:
        return 0.0
    return n * n * (math.log2(k) - math.log2(m))