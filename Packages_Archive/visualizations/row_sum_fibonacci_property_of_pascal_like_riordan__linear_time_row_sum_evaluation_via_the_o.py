from math import comb
from typing import List

def row_sum_via_three_term(n_max: int) -> List[int]:
    """Compute A(n) = sum_{k=0}^{n} C(n+k, 2k) = F_{2n+1} for n = 0..n_max
    using the order-two recurrence A(n+2) = 3*A(n+1) - A(n), in O(n_max) steps."""
    if n_max < 0:
        return []
    seq: List[int] = [1]            # A(0) = 1
    if n_max >= 1:
        seq.append(2)               # A(1) = 2
    for _ in range(2, n_max + 1):
        seq.append(3 * seq[-1] - seq[-2])
    return seq[: n_max + 1]

def row_sum_direct(n: int) -> int:
    """Reference O(n) binomial summation for cross-checking."""
    return sum(comb(n + k, 2 * k) for k in range(n + 1))
