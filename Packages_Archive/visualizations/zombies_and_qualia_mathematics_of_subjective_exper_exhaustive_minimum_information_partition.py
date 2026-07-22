from collections.abc import Callable
from itertools import combinations

def minimum_information_partition(n: int, value: Callable[[tuple[int, ...]], float]) -> tuple[tuple[int, ...], float]:
    if n < 2:
        raise ValueError("at least two components are required")
    cuts = (cut for k in range(1, n) for cut in combinations(range(n), k))
    best = min(cuts, key=value)
    return best, value(best)
