"""
Reference implementations of the four algorithms of the paper, in exact
rational arithmetic.  Each is written to be copy-pasteable and standalone.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Algorithm A: attenuation coefficient of a tie profile
# ---------------------------------------------------------------------------


def attenuation_coefficient(profile: Sequence[int]) -> Fraction:
    """Exact squared Spearman ceiling of a tie profile against a refining response.

    rho^2 = 1 - 12 * sum_j (m_j^3 - m_j) / (n^3 - n).

    Cost: O(g) big-integer operations for g blocks, versus O(n) for building the
    rank vectors explicitly -- decisive when n = 2^64.
    """
    if any(m < 1 for m in profile):
        raise ValueError("block sizes must be positive")
    n = sum(profile)
    if n < 2:
        raise ValueError("need at least two observations")
    tie = sum(Fraction(m) ** 3 - m for m in profile)
    return 1 - tie / (Fraction(n) ** 3 - n)


# ---------------------------------------------------------------------------
# Algorithm B: two-sided (nested) coefficient
# ---------------------------------------------------------------------------


def nested_coefficient(nested: Sequence[Sequence[int]]) -> Fraction:
    """Exact rho^2 for a nested pair of profiles: fine blocks inside coarse blocks.

    rho^2 = (V - T_coarse) / (V - T_fine),  V = (n^3 - n)/12.
    Cost: O(total number of fine blocks).
    """
    fine: List[int] = [m for block in nested for m in block]
    coarse: List[int] = [sum(block) for block in nested]
    n = sum(fine)
    if n < 2:
        raise ValueError("need at least two observations")
    V = (Fraction(n) ** 3 - n) / 12
    T = lambda p: sum((Fraction(m) ** 3 - m) / 12 for m in p)  # noqa: E731
    return (V - T(coarse)) / (V - T(fine))


# ---------------------------------------------------------------------------
# Algorithm C: base-rate inversion (calibration of a reading)
# ---------------------------------------------------------------------------


def invert_binary_base_rate(rho: float) -> Optional[Tuple[float, float]]:
    """Given an observed rho, return the two base rates q of a binary response whose
    asymptotic ceiling sqrt(3q(1-q)) equals rho, or None if rho exceeds sqrt(3)/2.

    Solves 3q(1-q) = rho^2, i.e. q = (1 +- sqrt(1 - 4 rho^2 / 3)) / 2.
    Cost: O(1).
    """
    r = rho * rho
    disc = 1 - 4 * r / 3
    if disc < 0:
        return None  # infeasible: no binary response can produce this reading
    root = disc ** 0.5
    return ((1 - root) / 2, (1 + root) / 2)


# ---------------------------------------------------------------------------
# Algorithm D: exact ceiling tables for dyadic and capped zero-count profiles
# ---------------------------------------------------------------------------


def dyadic_ceiling(b: int) -> Fraction:
    """(6/7)(1 + 1/(2^b(2^b+1))), the exact ceiling for uniform b-bit draws."""
    if b < 1:
        raise ValueError("b must be at least 1")
    x = Fraction(2) ** b
    return Fraction(6, 7) * (1 + 1 / (x * (x + 1)))


def capped_ceiling(b: int, c: int) -> Fraction:
    """(6/7)(8^b - 8^(b-c))/(8^b - 2^b), the exact ceiling for a zero-count capped at c."""
    if not (1 <= c <= b):
        raise ValueError("require 1 <= c <= b")
    return Fraction(6, 7) * Fraction(8 ** b - 8 ** (b - c), 8 ** b - 2 ** b)


def ceiling_table(b: int, caps: Sequence[int]) -> Dict[int, Fraction]:
    """Exact ceilings for a range of caps at word length b; caps[i] = b gives the
    full dyadic ceiling, caps[i] = 1 the balanced two-class value 3/4 * 4^b/(4^b-1)."""
    return {c: capped_ceiling(b, c) for c in caps}


if __name__ == "__main__":
    print("A  rho^2([8,4,2,1,1])      =", attenuation_coefficient([8, 4, 2, 1, 1]))
    print("B  nested [[2,1],[3],[1,1,1]] =", nested_coefficient([[2, 1], [3], [1, 1, 1]]))
    print("C  invert(0.648)           =", invert_binary_base_rate(0.648))
    print("C  invert(0.95)            =", invert_binary_base_rate(0.95), "(infeasible)")
    print("D  dyadic_ceiling(64)      =", float(dyadic_ceiling(64)))
    print("D  capped_ceiling(64, 1)   =", float(capped_ceiling(64, 1)))
    assert capped_ceiling(20, 20) == dyadic_ceiling(20)
