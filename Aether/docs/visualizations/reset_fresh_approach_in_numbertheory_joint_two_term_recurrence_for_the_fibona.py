from typing import Tuple


def stern_jacobsthal_pair(n: int) -> Tuple[int, int]:
    """Return (s(J(n)), s(2 J(n)+1)) = (F(2n), F(2n+1)) via the joint
    two-term recurrence, in O(n) additions and without forming J(n)."""
    a, b = 0, 1  # (s(J(0)), s(2 J(0)+1)) = (F(0), F(1))
    for _ in range(n):
        a, b = a + b, (a + b) + b
    return a, b
