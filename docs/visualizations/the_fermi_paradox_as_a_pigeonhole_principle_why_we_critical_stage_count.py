import math
def critical_stage_count(p: float, B: float) -> int:
    if p <= 0 or p >= 1 or B <= 1:
        return 0
    return math.ceil(math.log(B) / math.log(1 / p))