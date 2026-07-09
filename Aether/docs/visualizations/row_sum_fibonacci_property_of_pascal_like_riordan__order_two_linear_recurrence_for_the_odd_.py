from typing import List


def riordan_row_sums_three_term(n_max: int) -> List[int]:
    """Compute A(n) = sum_{k=0}^{n} C(n+k, 2k) for n = 0..n_max.

    Uses the order-two recurrence (Theorem pascalRiordan_three_term):
        A(n+2) = 3*A(n+1) - A(n),   A(0) = 1, A(1) = 2.
    This is the combinatorial shadow of the generating function
    (1 - x) / (1 - 3x + x^2).

    Complexity: O(n_max) big-integer operations (one multiply-by-3 and one
    subtraction per term); strictly cheaper than the O(n^2) direct binomial sum.
    """
    if n_max < 0:
        return []
    seq: List[int] = [1, 2][: n_max + 1]
    while len(seq) <= n_max:
        seq.append(3 * seq[-1] - seq[-2])
    return seq
