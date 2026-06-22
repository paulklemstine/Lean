from typing import Tuple

def fib_rank(m: int) -> int:
    """Rank of apparition of m: least k>0 with m | F_k.

    Iterates the Fibonacci pair (F_k, F_{k+1}) mod m until the first coordinate
    is 0. Terminates for every m >= 1 by the existence theorem (pigeonhole on
    the reversible Fibonacci shift over (Z/mZ)^2). Each step is O(1) modular
    operations; the number of steps is rank(m) <= Pisano(m) = O(m^2).
    """
    if m < 1:
        raise ValueError("modulus must be >= 1")
    if m == 1:
        return 1
    a, b, k = 0, 1, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k

def divides_fib(m: int, n: int) -> bool:
    """Test m | F_n in O(rank(m)) without building F_n, via the spine:
    m | F_n  <=>  rank(m) | n."""
    return n % fib_rank(m) == 0
