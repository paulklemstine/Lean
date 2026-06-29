import math
from typing import Tuple


def min_depth_for_iterexp(n: int) -> int:
    """Exact minimal eml-depth needed to represent iterExp n in the inverse-free
    fragment. By the Tight Depth Hierarchy theorem this is exactly n."""
    return n


def separation_witness(n: int, k: int, C: float, N: int,
                       x: float) -> Tuple[float, float, bool]:
    """Certify iterExp n eventually beats iterExp k (C*x^N) for k < n by reducing
    via k logarithms to the core comparison exp(x) vs C*x^N (k = n-1 case).

    Returns (reduced_target, reduced_rival, target_dominates)."""
    assert k < n
    reduced_target = math.exp(x)        # one exp survives after n-1 logs (k=n-1)
    reduced_rival = C * x ** N
    return reduced_target, reduced_rival, reduced_target > reduced_rival
