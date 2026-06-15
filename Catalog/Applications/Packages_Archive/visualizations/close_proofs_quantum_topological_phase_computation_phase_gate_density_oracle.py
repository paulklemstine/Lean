"""Density oracle: decide if a single phase gate is universal on the torus."""
from __future__ import annotations
from fractions import Fraction
from typing import Optional, Tuple


def density_verdict(alpha: float, max_den: int = 10_000,
                    tol: float = 1e-9) -> Tuple[bool, Optional[int]]:
    """
    Decide whether the orbit { n * alpha mod 1 } is dense.

    Returns (is_dense, order):
      * (True,  None) if alpha is (numerically) irrational  => dense, infinite order
      * (False, q)    if alpha = p/q in lowest terms        => not dense, order q
    """
    frac = Fraction(alpha).limit_denominator(max_den)
    if abs(float(frac) - alpha) < tol:
        return (False, frac.denominator)
    return (True, None)


if __name__ == "__main__":
    import math
    print("sqrt2 :", density_verdict(math.sqrt(2)))   # (True, None)
    print("4/5   :", density_verdict(4 / 5))          # (False, 5)
    print("1/3   :", density_verdict(1 / 3))          # (False, 3)
