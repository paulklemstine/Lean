from math import gcd
from typing import Tuple


def fib(k: int) -> int:
    """k-th Fibonacci number (F_0 = 0, F_1 = 1) in O(k)."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def resonant_window_gcd(t_beacon: int, t_receiver: int) -> Tuple[int, int]:
    """
    Resonant listening window strength via Fibonacci strong divisibility.

    Returns (alignment_gcd, shared_harmonic) where
      alignment_gcd   = gcd(t_beacon, t_receiver)   (alignment density)
      shared_harmonic = gcd(F_{t_beacon}, F_{t_receiver}) = F_{alignment_gcd}.
    """
    g = gcd(t_beacon, t_receiver)
    shared_harmonic = gcd(fib(t_beacon), fib(t_receiver))
    assert shared_harmonic == fib(g)  # Lemma 6.2
    return g, shared_harmonic
