from __future__ import annotations
from typing import Tuple


def bottom_degree_parity(n: int, r1: int, r2: int) -> int:
    m = n % 4
    if m in (0, 1):
        return 0
    if m == 2:
        return (r1 + r2) % 2
    return r2 % 2


def contragredient_sign(n: int, r1: int, r2: int) -> Tuple[int, bool]:
    """Return (sign, self_dual_possible).

    sign = (-1)^{b(F,n)} in {+1, -1};
    self_dual_possible is True iff sign == +1 (a self-dual generic pi can
    exist only when the bottom degree is even).
    """
    parity = bottom_degree_parity(n, r1, r2)
    sign = 1 if parity == 0 else -1
    return sign, (sign == 1)
