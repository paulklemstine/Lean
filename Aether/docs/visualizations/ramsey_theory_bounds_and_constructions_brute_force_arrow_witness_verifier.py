from itertools import combinations
from typing import Callable

def is_arrow_witness_free(n: int, red: Callable[[int, int], bool],
                          s: int, t: int) -> bool:
    """Brute-force check that a coloring on {0..n-1} has no red K_s and no
    blue K_t, certifying n -/-> (s, t). Cost O(C(n,s)*s^2 + C(n,t)*t^2)."""
    def mono(size: int, want_red: bool) -> bool:
        for verts in combinations(range(n), size):
            if all(red(a, b) == want_red for a, b in combinations(verts, 2)):
                return True
        return False
    return not mono(s, True) and not mono(t, False)
