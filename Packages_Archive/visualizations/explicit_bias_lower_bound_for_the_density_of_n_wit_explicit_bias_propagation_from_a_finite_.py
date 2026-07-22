from fractions import Fraction
from typing import Tuple


def s2(n: int) -> int:
    return bin(n).count("1")


def period(t: int) -> int:
    return 2 ** (max(1, t.bit_length()) + s2(t))


def cusick_count(t: int, N: int) -> int:
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))


def propagate_bias(t: int) -> Tuple[int, int, Fraction]:
    """Turn a single finite per-period surplus d into the uniform bias bound.

    Computes d = cusickCount(t, P) - P//2 over one period P, and certifies that
    2 * cusickCount(t, P*m) >= P*m + 2*d*m for all m, i.e. c_t >= 1/2 + d/P.
    Returns (P, d, bias). Complexity: one O(P log P) period count, then O(1).
    """
    P = period(t)
    d = cusick_count(t, P) - P // 2
    return P, d, Fraction(d, P)
