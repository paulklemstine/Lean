from typing import List, Sequence


def conical_to_convex(weights: Sequence[float]) -> List[float]:
    total = float(sum(weights))
    if total <= 0:
        raise ValueError("weights must be nonnegative, not all zero")
    return [w / total for w in weights]
