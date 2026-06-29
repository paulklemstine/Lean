from fractions import Fraction
from typing import Callable

Diamond = Callable[[int, int], Fraction]


def euler_char(n: int, h: Diamond) -> Fraction:
    return sum(Fraction((-1) ** (p + q)) * h(p, q)
               for p in range(n + 1) for q in range(n + 1))


def mirror_euler(n: int, h: Diamond) -> Fraction:
    """Compute chi(mirror h) WITHOUT re-summing, using the proven identity
    chi(mirror h) = (-1)^n chi(h).  O((n+1)^2) -> reuses one euler_char call.
    """
    return Fraction((-1) ** n) * euler_char(n, h)
