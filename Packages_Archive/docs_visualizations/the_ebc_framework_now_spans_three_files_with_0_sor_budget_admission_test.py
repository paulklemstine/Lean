import math
def max_admissible_steps(budget: float, tf: float) -> int:
    if tf <= 0:
        raise ValueError('tempFactor must be positive')
    return math.floor(budget / tf)
