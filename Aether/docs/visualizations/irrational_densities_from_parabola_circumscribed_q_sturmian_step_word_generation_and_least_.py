import math
from typing import List, Optional

def step_word(alpha: float, length: int) -> List[int]:
    return [math.floor((n+1)*alpha) - math.floor(n*alpha) for n in range(length)]

def least_period(w: List[int], p_max: int) -> Optional[int]:
    cap = min(p_max, len(w)//2)
    for p in range(1, cap+1):
        if all(w[i] == w[i+p] for i in range(len(w)-p)):
            return p
    return None
