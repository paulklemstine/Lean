from __future__ import annotations
from typing import Callable, Tuple


def collapse_detector(a_lo: Callable[[int], int], a_hi: Callable[[int], int],
                      n_max: int = 8) -> Tuple[bool, bool]:
    """Test whether two consecutive rungs are mutually polynomially dominated on
    a sample. Returns (lo_sim_hi, hi_sim_lo). If both True the rungs COLLAPSE to
    one p-degree; if hi_sim_lo is False the chain SEPARATES.

    Mathematical foundation: 2^((k+1)n) = (2^(kn))^2 makes the exponential ladder
    collapse, whereas 2^(n^(k+1)) escapes every polynomial inflation of 2^(n^k).
    Complexity: O(k_max * n_max) big-integer comparisons.
    """
    def sim(a: Callable[[int], int], b: Callable[[int], int]) -> bool:
        for k in range(13):
            if all(a(n) + 1 <= (b(n) + 2) ** k for n in range(n_max + 1)):
                return True
        return False
    return sim(a_lo, a_hi), sim(a_hi, a_lo)
