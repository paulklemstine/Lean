from itertools import product
from typing import Sequence

def walk_cgf_bruteforce(val: Sequence[float], w: Sequence[float],
                        n: int, lam: float) -> float:
    """CGF of the n-step max-plus random walk, by exhaustive path enumeration.

    Verifies the exact scaling Lambda_walk(lam) = n * Lambda(lam), where
    Lambda(lam) = max_x ( lam*val(x) + w(x) ) is the single-step CGF.
    Complexity O((#X)^n * n); use only as a ground-truth check for small n.
    """
    states = range(len(w))
    best = float("-inf")
    for path in product(states, repeat=n):
        weight = sum(w[i] for i in path)
        displacement = sum(val[i] for i in path)
        best = max(best, lam * displacement + weight)
    return best

def walk_cgf_fast(val: Sequence[float], w: Sequence[float],
                  n: int, lam: float) -> float:
    """The same quantity in O(#X) via the separation identity n * Lambda(lam)."""
    single = max(lam * v + wx for v, wx in zip(val, w))
    return n * single
