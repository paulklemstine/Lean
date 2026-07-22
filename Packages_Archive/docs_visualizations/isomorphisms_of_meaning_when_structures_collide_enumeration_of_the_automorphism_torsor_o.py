from __future__ import annotations
from math import gcd
from typing import Callable, List


def automorphisms_of_cyclic(n: int) -> List[Callable[[int], int]]:
    """Enumerate Aut(Z/nZ): one map x -> (k*x) mod n per unit k mod n.

    Runs in O(n log n) time and returns exactly phi(n) automorphisms.
    """
    units: List[int] = [k for k in range(1, n + 1) if gcd(k, n) == 1]
    return [(lambda x, k=k: (k * x) % n) for k in units]
