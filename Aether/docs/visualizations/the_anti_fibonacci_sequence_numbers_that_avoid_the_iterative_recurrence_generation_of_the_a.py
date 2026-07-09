"""Algorithm 1: Recurrence generation of the anti-Fibonacci sequence."""
from __future__ import annotations
from typing import List


def anti_fibonacci_recurrence(n_max: int) -> List[int]:
    """Generate [A(0), ..., A(n_max)] via A(k+1) = A(k) + k.

    Time O(n_max); space O(n_max) (O(1) if only the last term is retained).
    """
    if n_max < 0:
        return []
    seq: List[int] = [1]
    for k in range(n_max):
        seq.append(seq[-1] + k)
    return seq


if __name__ == "__main__":
    print(anti_fibonacci_recurrence(11))
