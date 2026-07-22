from __future__ import annotations
from typing import Callable, Tuple

def stabilize(F: Callable[[int], int], x: int, N: int) -> Tuple[int, int]:
    """Iterate a monotone descending F on a finite poset of size N from x to its
    fixed point. Terminates within N steps by finite_garden_of_eden_descent."""
    cur = x
    for n in range(N + 1):
        nxt = F(cur)
        if nxt == cur:
            return (n, cur)
        cur = nxt
    raise RuntimeError("did not stabilize within N steps (violates theorem)")
