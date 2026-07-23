from math import gcd
from typing import Tuple

def fib_rank(m: int) -> int:
    """Rank of apparition z(m): the least k > 0 with m | F(k).

    Iterates the Fibonacci state pair (F(k), F(k+1)) modulo m via the affine
    shift T(a, b) = (b, a + b). Since T is a bijection of the finite set
    (Z/mZ)^2, the orbit of (0, 1) is purely periodic and returns to a state with
    a zero Fibonacci coordinate, guaranteeing termination.
    """
    if m <= 0:
        raise ValueError("rank of apparition requires m >= 1")
    if m == 1:
        return 1
    a, b = 0 % m, 1 % m
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k
