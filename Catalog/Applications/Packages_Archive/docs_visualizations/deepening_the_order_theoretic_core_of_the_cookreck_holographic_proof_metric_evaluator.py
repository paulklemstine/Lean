from collections import deque
from typing import Callable, List, Optional, Tuple


def min_deriv_len(step: Callable[[int], List[int]], a: int, b: int,
                  bound: int = 10000) -> Optional[int]:
    """Shortest derivation length from a to b (BFS graph distance)."""
    if a == b:
        return 0
    seen = {a}
    q: deque[Tuple[int, int]] = deque([(a, 0)])
    while q:
        node, d = q.popleft()
        if d > bound:
            return None
        for nxt in step(node):
            if nxt == b:
                return d + 1
            if nxt not in seen:
                seen.add(nxt)
                q.append((nxt, d + 1))
    return None


def check_lipschitz(step_t: Callable[[int], List[int]],
                    step_s: Callable[[int], List[int]],
                    phi: Callable[[int], int], L: int,
                    a: int, b: int) -> bool:
    """Verify minDerivLen(S, phi a, phi b) <= L * minDerivLen(T, a, b)."""
    d_t = min_deriv_len(step_t, a, b)
    d_s = min_deriv_len(step_s, phi(a), phi(b))
    assert d_t is not None and d_s is not None
    return d_s <= L * d_t
