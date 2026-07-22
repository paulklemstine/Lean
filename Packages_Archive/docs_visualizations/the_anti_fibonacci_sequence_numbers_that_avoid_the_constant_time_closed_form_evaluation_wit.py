"""Algorithm 2: Constant-time closed-form evaluation with cross-check."""
from __future__ import annotations


def anti_fibonacci_closed(n: int) -> int:
    """Return A(n) = 1 + n(n-1)//2 in O(1) exact integer arithmetic.

    Valid for arbitrarily large n (e.g. n = 10**18) because Python integers
    are unbounded and the formula avoids iteration.
    """
    return 1 + n * (n - 1) // 2


def cross_check(n_max: int) -> bool:
    """Confirm the closed form matches the recurrence for 0 <= n <= n_max."""
    prev = 1
    for n in range(n_max + 1):
        if prev != anti_fibonacci_closed(n):
            return False
        prev = prev + n  # A(n+1) = A(n) + n
    return True


if __name__ == "__main__":
    print("A(10**18) =", anti_fibonacci_closed(10 ** 18))
    print("cross-check to 10000:", cross_check(10_000))
