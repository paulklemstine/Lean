from __future__ import annotations
from math import gcd
from typing import Callable, Sequence


def strong_identity_check(
    u: Callable[[int], int], indices: Sequence[int]
) -> bool:
    """Check u(gcd(m,n)) = gcd(u(m),u(n)) over all pairs from `indices`."""
    for m in indices:
        for n in indices:
            if u(gcd(m, n)) != gcd(u(m), u(n)):
                return False
    return True
