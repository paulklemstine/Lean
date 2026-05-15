import math
def minimum_states(H: float) -> int:
    return math.ceil(math.exp(H))