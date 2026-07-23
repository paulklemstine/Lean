from itertools import combinations
from typing import Callable, List, Sequence, Tuple

def rips_rank_curve(
    points: Sequence[Tuple[float, ...]],
    d: Callable[[Tuple[float, ...], Tuple[float, ...]], float],
) -> Tuple[List[float], List[int]]:
    """Return (breaks, counts) of the Rips edge-count curve."""
    scales = sorted(d(points[i], points[j])
                    for i, j in combinations(range(len(points)), 2))
    breaks: List[float] = []
    counts: List[int] = []
    c = 0
    for s in scales:
        c += 1
        if breaks and breaks[-1] == s:
            counts[-1] = c
        else:
            breaks.append(s)
            counts.append(c)
    return breaks, counts