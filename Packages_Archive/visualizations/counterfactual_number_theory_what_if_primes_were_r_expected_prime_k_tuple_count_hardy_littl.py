import math
from typing import Sequence

def expected_tuple_count(N: int, offsets: Sequence[int]) -> float:
    """Cramer expectation of n in [2,N] with all n+h random-prime."""
    total: float = 0.0
    for n in range(2, N + 1):
        prod = 1.0
        for h in offsets:
            prod *= 1.0 / math.log(n + h)
        total += prod
    return total
