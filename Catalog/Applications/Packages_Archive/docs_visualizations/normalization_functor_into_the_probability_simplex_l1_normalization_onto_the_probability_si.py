from typing import List, Sequence


def normalize(v: Sequence[float]) -> List[float]:
    """ell^1-normalization onto the probability simplex.

    Total convention: if the total mass is 0, returns the all-zeros vector.
    Complexity: O(n) time, O(n) space.
    """
    total: float = sum(v)
    if total == 0.0:
        return [0.0 for _ in v]
    return [x / total for x in v]
