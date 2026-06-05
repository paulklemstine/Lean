def chaitin_threshold(b: int, k: int) -> int:
    return b**k + 1

def min_cost_at_level(k: int, temperature: float) -> float:
    import math
    return k * temperature * math.log(2)