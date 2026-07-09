from typing import Callable, Tuple


def pisano_period(m: int) -> int:
    """Compute the Pisano period of the Fibonacci sequence modulo m.

    Searches for the smallest p >= 1 with F_p == 0 and F_(p+1) == 1 (mod m);
    these are exactly the two seed residues required by the paired-induction
    certificate fib_pisano_step. The period is guaranteed to occur within 6*m.
    Complexity: O(period) integer operations, each O(1) for fixed-width m.
    """
    a, b = 0, 1
    for p in range(1, 6 * m + 1):
        a, b = b, (a + b) % m
        if a == 0 and b == 1:
            return p
    raise RuntimeError("Pisano period not found within bound 6*m")


def periodicity_holds(m: int, p: int, horizon: int = 100) -> bool:
    """Empirically confirm the certificate F_(n+p) == F_n (mod m)."""
    def fib_mod(n: int) -> int:
        x, y = 0 % m, 1 % m
        for _ in range(n):
            x, y = y, (x + y) % m
        return x
    return all(fib_mod(n + p) == fib_mod(n) for n in range(horizon))
