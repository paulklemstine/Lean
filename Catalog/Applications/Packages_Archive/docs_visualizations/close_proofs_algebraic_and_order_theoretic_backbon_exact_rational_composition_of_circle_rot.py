from fractions import Fraction
from typing import List, Tuple


def stereo_add_exact(t: Fraction, s: Fraction) -> Fraction:
    """Tangent half-angle addition (t+s)/(1-ts) in exact rational arithmetic.

    Raises ZeroDivisionError on the singular locus ts = 1, which is the preimage
    of the point at infinity of the one-point compactification of the line.
    Complexity: O(1) rational operations.
    """
    denom = 1 - t * s
    if denom == 0:
        raise ZeroDivisionError("undefined on the singular locus ts = 1")
    return (t + s) / denom


def compose_rotations(addresses: List[Fraction]) -> Fraction:
    """Compose a list of rotations given by their stereographic addresses.

    Folds stereo_add over the list. Complexity: O(n) rational operations for n
    rotations. Returns the address of the composite rotation.
    """
    acc = Fraction(0)
    for t in addresses:
        acc = stereo_add_exact(acc, t)
    return acc


def project(t: Fraction) -> Tuple[Fraction, Fraction]:
    """Exact inverse stereographic chart sigma(t) = (2t/(1+t^2),(1-t^2)/(1+t^2))."""
    d = 1 + t * t
    return (2 * t / d, (1 - t * t) / d)
