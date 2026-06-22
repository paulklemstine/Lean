from typing import Callable, Hashable, Dict, Tuple

def detect_period(next_fn: Callable[[Hashable], Hashable],
                  q0: Hashable) -> Tuple[int, int]:
    """Find (pre_period m, period p) of the orbit of q0 under next_fn,
    so that next^[n] q0 = next^[n+p] q0 for all n >= m. Pure pigeonhole:
    the first repeated state closes the cycle. Time/space O(|Q|)."""
    seen: Dict[Hashable, int] = {}
    q, i = q0, 0
    while q not in seen:
        seen[q] = i
        q = next_fn(q)
        i += 1
    m = seen[q]
    return m, i - m
