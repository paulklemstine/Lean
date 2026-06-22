from __future__ import annotations
from typing import Callable, Optional, Tuple

SizeFn = Callable[[int], int]


def simulates_size_indexed(a: SizeFn, b: SizeFn, k_max: int, n_max: int
                           ) -> Tuple[bool, Optional[int]]:
    """Decide (on a finite range) whether sysOfSize(a) is p-simulated by
    sysOfSize(b), i.e. whether a(n) <= (b(n)+2)^k for some exponent k <= k_max
    and all n <= n_max. By the Domination Characterization this is sound for
    simulation between size-indexed proof systems on the tested range.

    Returns (simulated?, least witnessing exponent k or None)."""
    for k in range(k_max + 1):
        if all(a(n) <= (b(n) + 2) ** k for n in range(n_max + 1)):
            return True, k
    return False, None
