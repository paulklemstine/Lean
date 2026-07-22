import math
from typing import List


def twin_bar_count(gaps: List[int]) -> int:
    """Count length-2 bars (= twin prime pairs) in the barcode."""
    return sum(1 for g in gaps if g == 2)


def hardy_littlewood_twin_estimate(bound: int) -> float:
    """Asymptotic prediction 2 C_2 N / (log N)^2 for twins below `bound`."""
    C2 = 0.6601618158
    if bound < 3:
        return 0.0
    return 2.0 * C2 * bound / (math.log(bound) ** 2)
