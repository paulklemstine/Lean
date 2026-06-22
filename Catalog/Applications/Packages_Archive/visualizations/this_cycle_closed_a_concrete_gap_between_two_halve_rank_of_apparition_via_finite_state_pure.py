from typing import Tuple

def fib_rank(m: int) -> int:
    """
    Rank of apparition R(m): least k > 0 with m | Fib(k).

    Iterates the transition T(a, b) = (b, a + b) on the reduced state pair
    (Fib(k) mod m, Fib(k+1) mod m), starting from (0, 1).  By pure periodicity
    of a bijection on the finite set (Z/mZ)^2, the first coordinate returns to 0
    in at most m*m steps; the first such index is R(m).

    Complexity: O(R(m)) modular additions, O(1) space.  R(m) <= m*m always, and
    R(p) <= p + 1 for primes by the Pisano bound.
    """
    if m < 1:
        raise ValueError("R(m) defined only for m >= 1")
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, m * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0:
            return k
    raise RuntimeError("unreachable by periodicity")
