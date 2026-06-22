from math import gcd
from typing import Dict


def fib_rank(m: int) -> int:
    """Least positive k with m | F(k); 0 if m == 0.

    Advances the Fibonacci recurrence modulo m and halts at the first zero
    residue. Terminates within the Pisano period pi(m) <= 6m.
    Complexity: O(fibRank(m)) modular steps.
    """
    if m == 0:
        return 0
    if m == 1:
        return 1
    a, b = 0, 1  # (F(0) mod m, F(1) mod m)
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:  # a holds F(k) mod m
            return k
