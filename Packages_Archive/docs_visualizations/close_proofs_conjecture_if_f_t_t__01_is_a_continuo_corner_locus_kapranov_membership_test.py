from typing import Sequence

def attained_at_least_twice(weights: Sequence[float]) -> bool:
    if len(weights) < 2:
        return False
    mu = min(weights)
    return sum(1 for w in weights if w == mu) >= 2
