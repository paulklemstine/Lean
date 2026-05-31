def amplification_steps_needed(eps: float, target_gap: float) -> int:
    import math
    if eps >= target_gap: return 1
    return math.ceil(math.log(1 - target_gap) / math.log(1 - eps))