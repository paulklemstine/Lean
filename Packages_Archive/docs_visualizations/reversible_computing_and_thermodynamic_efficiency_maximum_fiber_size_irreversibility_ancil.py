from typing import Callable, Dict, Hashable, Sequence, Tuple

def max_fiber(f: Callable[[Hashable], Hashable],
              support: Sequence[Hashable]) -> Tuple[int, bool]:
    counts: Dict[Hashable, int] = {}
    for x in support:
        y = f(x)
        counts[y] = counts.get(y, 0) + 1
    m = max(counts.values()) if counts else 0
    return m, m <= 1
